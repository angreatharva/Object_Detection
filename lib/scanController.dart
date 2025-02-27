import 'dart:developer';

import 'package:camera/camera.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tflite/tflite.dart';

class ScanController extends GetxController {
  late CameraController cameraController;
  late List<CameraDescription> cameras;
  var isCamerInitialized = false.obs;

  late CameraImage cameraImage;
  var cameraCount = 0 ;

  var x, y, w, h;
  var label = '';
  var confidence;
  double confidenceValue = 0.0;

  @override
  void onInit() {
    super.onInit();
    initCamera();
    initTFlite();
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  initCamera() async {
    if (await Permission.camera.request().isGranted) {
      cameras = await availableCameras();
      cameraController = CameraController(
        cameras[0],
        ResolutionPreset.max,
      );
      await cameraController.initialize().then((value) {
        cameraController.startImageStream((image) {
          if (cameraCount % 10 == 0) {
            cameraCount = 0;
            objectDetector(image);
          }
          cameraCount++;
          update();
        });
      });
      isCamerInitialized(true);
      update();
    } else {
      print('Permission Denied');
    }
  }

  initTFlite() async {
    String? result = await Tflite.loadModel(
      model: 'assets/model.tflite',
      labels: 'assets/labels.txt',
      isAsset: true,
      numThreads: 1,
      useGpuDelegate: false,
    );
    if (result == null) {
      print('Failed to load the model');
    } else {
      print('Model loaded: $result');
    }
  }

  objectDetector(CameraImage image) async {
    var detector = await Tflite.runModelOnFrame(
      bytesList: image.planes.map((e) {
        return e.bytes;
      }).toList(),
      asynch: true,
      imageHeight: image.height,
      imageWidth: image.width,
      imageMean: 127.5,
      imageStd: 127.5,
      numResults: 1,
      rotation: 90,
      threshold: 0.4,
    );

    if (detector != null && detector.isNotEmpty) {
      print("Result is: $detector");
      var detected = detector.last;
      confidence = detected['confidence'].toString();
      print("detected: $detected");
      print("label: $label");
      print("confidence: $confidence");
      confidenceValue = double.parse(confidence) * 100;
      if (confidenceValue > 45) {
        label = detected['label'].toString();
      }

      /*if (outDetectedObject['confidenceInClass'] * 100 > 45) {
        label = outDetectedObject['detectedClass'].toString();
        h = (outDetectedObject['rect']['h']);
        w = (outDetectedObject['rect']['w']);
        x = (outDetectedObject['rect']['x']);
        y = (outDetectedObject['rect']['y']);
      }*/

    }
  }
}