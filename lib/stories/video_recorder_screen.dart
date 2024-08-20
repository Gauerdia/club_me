import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../shared/custom_text_style.dart';
import 'video_player_screen.dart';
// import 'package:adv_camera_example/camera.dart';

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

  late double screenHeight, screenWidth;


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

  void pressedBack(){
    context.go('/club_frontpage');
  }
  void pressedRecord() async{
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

  Widget _buildBottomNavigationBar(){
    return Container(
      height: screenHeight*0.1,
      width: screenWidth,
      child: Row(
        mainAxisAlignment: _isRecording ? MainAxisAlignment.center
        : MainAxisAlignment.spaceEvenly,
        children: [
          Align(
              alignment: AlignmentDirectional.center,
              child: GestureDetector(
                child: Container(
                  padding: EdgeInsets.symmetric(
                      // horizontal: screenWidth*0.055,
                      // vertical: screenHeight*0.02
                  ),
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        width: 4,
                        color: _isRecording ? customTextStyle.primeColor.withOpacity(0.5) : Colors.white.withOpacity(0.5)
                      )
                    ),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _isRecording ? customTextStyle.primeColor: Colors.white,
                        // borderRadius: BorderRadius.circular(20)
                      ),
                    ),
                  )
                ),
                onTap: () => pressedRecord(),
              )
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    customTextStyle = CustomTextStyle(context: context);

    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(

      bottomNavigationBar: _buildBottomNavigationBar(),

      body: canBeDrawn ? FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {

          if(!snapshot.hasData){
            if (snapshot.connectionState == ConnectionState.done) {
              return Stack(
                children: [
                  SizedBox(
                    height: screenHeight*0.95,
                    child: CameraPreview(_controller),
                  ),

                  Container(
                    width: screenWidth,
                    height: screenHeight,
                    alignment: Alignment.topRight,
                    padding: EdgeInsets.only(
                      top: screenHeight*0.07,
                      right: screenWidth*0.05
                    ),
                    child: IconButton(
                      onPressed: () => pressedBack(),
                      icon: const Icon(
                        Icons.close,
                        size: 30,
                        color: Colors.white,
                      ),
                    ),
                  )
                ],
              );
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          }else{
            return const Center(child: CircularProgressIndicator());
          }
        },
      ): const Center(child: CircularProgressIndicator()),
    );
  }
}