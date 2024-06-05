import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'custom_text_style.dart';
import 'video_player_screen.dart';

class VideoRecorderScreen extends StatefulWidget {

  const VideoRecorderScreen({super.key});

  @override
  State<VideoRecorderScreen> createState() => _VideoRecorderScreenState();
}

class _VideoRecorderScreenState extends State<VideoRecorderScreen> {

  late CameraController _controller;
  late CustomTextStyle customTextStyle;
  late Future<void> _initializeControllerFuture;

  bool canBeDrawn = false;
  bool _isRecording = false;



  @override
  void initState() {
    super.initState();
    setUpCamera();
  }

  @override
  void dispose() {
    _timer.cancel();
    _controller.dispose();
    super.dispose();
  }

  void setUpCamera() async {
    final cameras = await availableCameras();
    _controller = CameraController(
      cameras.first,
      ResolutionPreset.medium,
    );
    _initializeControllerFuture = _controller.initialize();
    setState(() {
      canBeDrawn = true;
    });
  }

  late Timer _timer;
  int _start = 10;

  void startTimer() async{
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(
      oneSec,
          (Timer timer) {
        if (_start == 0) {
          setState(() async {
            timer.cancel();

            final video = await _controller.stopVideoRecording();

            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => VideoPlayerScreen(videoPath: video!.path),
              ),
            );

          });
        } else {
          setState(() {
            _start--;
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    customTextStyle = CustomTextStyle(context: context);

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
          title: SizedBox(
            width: screenWidth,
            child: Text(
                'Nimm eine Story auf!',
                textAlign: TextAlign.center,
                style: customTextStyle.size1Bold(),
            ),
          ),
        leading: IconButton(
          icon: const Icon(
              Icons.clear_rounded
          ),
          onPressed: () => context.go('/club_frontpage'),
        )
      ),
      body: canBeDrawn ? FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if(!snapshot.hasData){
            if (snapshot.connectionState == ConnectionState.done) {
              return CameraPreview(_controller);
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          }else{
            return const Center(child: CircularProgressIndicator());
          }
        },
      ): const Center(child: CircularProgressIndicator()),

      floatingActionButton: canBeDrawn ?
        FloatingActionButton(
          onPressed: () async {
            try {
              await _initializeControllerFuture;

              if (!mounted) {return;}

              if (_isRecording) {
                final video = await _controller.stopVideoRecording();

                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => VideoPlayerScreen(videoPath: video!.path,),
                  ),
                );
              } else {
                await _controller.prepareForVideoRecording();
                await _controller.startVideoRecording();
                startTimer();
              }

              setState(() {
                _isRecording = !_isRecording;
              });
            } catch (e) {
              print(e);
            }
          },
          child: Icon(_isRecording ? Icons.stop : Icons.circle),
        ): Container()
    );
  }
}