import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:jae_market/main.dart';

class CameraExamplePage extends StatefulWidget {
  const CameraExamplePage({super.key});

  @override
  State<CameraExamplePage> createState() => _CameraExamplePageState();
}

class _CameraExamplePageState extends State<CameraExamplePage> {
  CameraController? controller;

  @override
  void initState() {
    super.initState();
    controller = CameraController(cameras[0], ResolutionPreset.high);
    controller?.initialize().then((value){
      setState(() {
      });
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: controller?.value.isInitialized ?? false ? CameraPreview(controller!) :
      Container(
        child: Center(
          child: Text('초기화 중'),
        ),
      ),

    );
  }
}
