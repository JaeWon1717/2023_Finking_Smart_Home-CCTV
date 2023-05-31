import 'dart:html';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  runApp(WebcamScreen());
}

class WebcamScreen extends StatefulWidget {
  @override
  _WebcamScreenState createState() => _WebcamScreenState();
}

class _WebcamScreenState extends State<WebcamScreen> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
      body: AppBody(),
    ));
  }
}

class AppBody extends StatefulWidget {
  @override
  _AppBodyState createState() => _AppBodyState();
}

class _AppBodyState extends State<AppBody> {
  bool cameraAccess = false;
  String? error;
  List<CameraDescription>? cameras;

  @override
  void initState() {
    getCameras();
    super.initState();
  }

  Future<void> getCameras() async {
    try {
      await window.navigator.mediaDevices!
          .getUserMedia({'video': true, 'audio': false});
      setState(() {
        cameraAccess = true;
      });

      final cameras = await availableCameras();
      setState(() {
        this.cameras = cameras;
      });
    } on DomException catch (e) {
      setState(() {
        error = '${e.name}: ${e.message}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (error != null) {
      return Center(child: Text('오류 발생: $error'));
    }
    if (!cameraAccess) {
      return Center(child: Text('아직 카메라 접근 권한이 허용되지 않았습니다.'));
    }
    if (cameras == null) {
      return Center(child: Text('카메라 목록을 가져오는 중입니다.'));
    }
    if (cameras!.isEmpty) {
      return Center(child: Text('사용 가능한 카메라가 없습니다.'));
    }
    return CameraView(cameras: cameras!);
  }
}

class CameraView extends StatefulWidget {
  final List<CameraDescription> cameras;

  const CameraView({Key? key, required this.cameras}) : super(key: key);

  @override
  _CameraViewState createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> {
  String? error;
  CameraController? controller;
  late CameraDescription cameraDescription = widget.cameras[0];

  Future<void> initCam(CameraDescription description) async {
    setState(() {
      controller = CameraController(description, ResolutionPreset.max);
    });

    try {
      await controller!.initialize();
    } catch (e) {
      setState(() {
        error = e.toString();
      });
    }

    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    initCam(cameraDescription);
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (error != null) {
      return Center(
        child: Text('Initializing error: $error\nCamera list:'),
      );
    }
    if (controller == null) {
      return Center(child: Text('Loading controller...'));
    }
    if (!controller!.value.isInitialized) {
      return Center(child: Text('Initializing camera...'));
    }
    var size = MediaQuery.of(context).size;

    return ListView.builder(
      itemCount: 1,
      itemBuilder: (context, index) {
        return Column(
          children: [
            Container(
              color: Colors.amber,
              width: size.width * 0.8,
              padding: EdgeInsets.fromLTRB(30, 30, 30, 0),
              child: AspectRatio(
                  aspectRatio: 16 / 9, child: CameraPreview(controller!)),
            ),
            Container(
              width: size.width * 0.8,
              color: Colors.amberAccent,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Home'),
                    Text('배터리 잔량'),
                    Text('로그 : 2023-05-31')
                  ]),
            )
          ],
        );
      },
    );
  }
}
/*Material(
            child: DropdownButton<CameraDescription>(
              value: cameraDescription,
              icon: const Icon(Icons.arrow_downward),
              iconSize: 24,
              elevation: 16,
              onChanged: (CameraDescription? newValue) async {
                if (controller != null) {
                  await controller!.dispose();
                }
                setState(() {
                  controller = null;
                  cameraDescription = newValue!;
                });

                initCam(newValue!);
              },
              items: widget.cameras
                  .map<DropdownMenuItem<CameraDescription>>((value) {
                return DropdownMenuItem<CameraDescription>(
                  value: value,
                  child: Text('${value.name}: ${value.lensDirection}'),
                );
              }).toList(),
            ),
          ),*/ //카메라 설정
          /*ElevatedButton(
            onPressed: controller == null
                ? null
                : () async {
                    await controller!.startVideoRecording();
                    await Future.delayed(Duration(seconds: 5));
                    final file = await controller!.stopVideoRecording();
                    final bytes = await file.readAsBytes();
                    final uri = Uri.dataFromBytes(bytes,
                        mimeType: 'video/webm;codecs=vp8');

                    final link = AnchorElement(href: uri.toString());
                    link.download = 'recording.webm';
                    link.click();
                    link.remove();
                  },
            child: Text('Record 5 second video.'),
          ),
          ElevatedButton(
            onPressed: controller == null
                ? null
                : () async {
                    final file = await controller!.takePicture();
                    final bytes = await file.readAsBytes();

                    final link = AnchorElement(
                        href: Uri.dataFromBytes(bytes, mimeType: 'image/png')
                            .toString());

                    link.download = 'picture.png';
                    link.click();
                    link.remove();
                  },
            child: Text('Take picture.'),
          )*/ //동영상 재생 및 사진촬영