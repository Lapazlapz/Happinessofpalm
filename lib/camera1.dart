import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'camera2.dart';

class Camera1 extends StatefulWidget {
  const Camera1({super.key});

  @override
  State<Camera1> createState() => _Camera1State();
}

class _Camera1State extends State<Camera1> {
  CameraController? controller;
  List<CameraDescription>? cameras;
  bool isCameraReady = false;

  @override
  void initState() {
    super.initState();
    initCamera();
  }

  Future<void> initCamera() async {
    cameras = await availableCameras();
    controller = CameraController(cameras!.first, ResolutionPreset.high);
    await controller!.initialize();
    if (!mounted) return;
    setState(() {
      isCameraReady = true;
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  Future<XFile?> takePicture() async {
    if (!controller!.value.isInitialized) return null;
    if (controller!.value.isTakingPicture) return null;

    try {
      final file = await controller!.takePicture();
      return file; // ✅ return ค่าไฟล์รูป
    } catch (e) {
      debugPrint("Error taking picture: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!isCameraReady) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(title: const Text("ถ่ายรูป")),
      body: Stack(
        children: [
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: FloatingActionButton(
                onPressed: () async {
                  final picture = await takePicture();
                  if (picture != null)
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Camera2(imagePath: picture.path)),
                    );
                },
                child: const Icon(Icons.camera_alt),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
