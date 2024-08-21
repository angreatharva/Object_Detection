import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:objectdetection/scanController.dart';

class CameraView extends StatelessWidget {
  const CameraView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<ScanController>(
        init: ScanController(),
        builder: (controller) {
          return controller.isCamerInitialized.value ?
          Column(
            children: [
              CameraPreview(controller.cameraController),
              Container(

                decoration: BoxDecoration(
                  border: Border.all(color: Colors.green),
                  borderRadius: BorderRadius.circular(8)
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                        color:Colors.white,
                        child: Column(
                          children: [
                            Text("${controller.label}"),
                            Text("${controller.confidenceValue}"),
                          ],
                        )
                    ),
                  ],
                ),
              )
            ],
          ):
          const Text("Detecting...")
          ;
        }
      ),
    );
  }
}
