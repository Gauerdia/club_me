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
          _isRecording ? Container()
              : Align(
              alignment: AlignmentDirectional.center,
              child: GestureDetector(
                child: Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: screenWidth*0.055,
                      vertical: screenHeight*0.02
                  ),
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(
                        Radius.circular(10)
                    ),
                    gradient: LinearGradient(
                        colors: [
                          customTextStyle.primeColorDark,
                          customTextStyle.primeColor,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        stops: [0.2, 0.9]
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black54,
                        spreadRadius: 1,
                        blurRadius: 7,
                        offset: Offset(3, 3),
                      ),
                    ],
                  ),
                  child: Text(
                    "Zurück",
                    style: customTextStyle.size4Bold(),
                  ),
                ),
                onTap: () => pressedBack(),
              )
          ),
          Align(
              alignment: AlignmentDirectional.center,
              child: GestureDetector(
                child: Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: screenWidth*0.055,
                      vertical: screenHeight*0.02
                  ),
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(
                        Radius.circular(10)
                    ),
                    gradient: LinearGradient(
                        colors: [
                          customTextStyle.primeColorDark,
                          customTextStyle.primeColor,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        stops: [0.2, 0.9]
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black54,
                        spreadRadius: 1,
                        blurRadius: 7,
                        offset: Offset(3, 3),
                      ),
                    ],
                  ),
                  child: Text(
                    _isRecording ? "Aufnahme beenden" : "Aufnehmen",
                    style: customTextStyle.size4Bold(),
                  ),
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
              return SizedBox(
                height: screenHeight*0.95,
                child: CameraPreview(_controller),
              );
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          }else{
            return const Center(child: CircularProgressIndicator());
          }
        },
      ): const Center(child: CircularProgressIndicator()),

      // floatingActionButton: canBeDrawn ?
      //   FloatingActionButton(
      //     onPressed: () async {
      //       try {
      //         await _initializeControllerFuture;
      //
      //         if (!mounted) {return;}
      //
      //         if (_isRecording) {
      //           final video = await _controller.stopVideoRecording();
      //
      //           await Navigator.of(context).push(
      //             MaterialPageRoute(
      //               builder: (context) => VideoPlayerScreen(videoPath: video!.path,),
      //             ),
      //           );
      //         } else {
      //           await _controller.prepareForVideoRecording();
      //           await _controller.startVideoRecording();
      //           startTimer();
      //         }
      //
      //         setState(() {
      //           _isRecording = !_isRecording;
      //         });
      //       } catch (e) {
      //         print(e);
      //       }
      //     },
      //     child: Icon(_isRecording ? Icons.stop : Icons.circle),
      //   ): Container()
    );
  }
}