import 'dart:async';
import 'dart:io';
import 'package:adv_camera/adv_camera.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../shared/custom_text_style.dart';
import 'video_player_screen.dart';

class VideoRecorderScreen extends StatefulWidget {

  const VideoRecorderScreen({super.key});

  @override
  State<VideoRecorderScreen> createState() => _VideoRecorderScreenState();
}

class _VideoRecorderScreenState extends State<VideoRecorderScreen> {

  late CameraController _controller;
  late CustomStyleClass customStyleClass;
  late Future<void> _initializeControllerFuture;

  bool showFocusCircle = false;
  double x = 0;
  double y = 0;

  bool canBeDrawn = false;
  bool _isRecording = false;

  late double screenHeight, screenWidth;

  AdvCameraController? cameraController;
  List<String> pictureSizes = <String>[];
  String? imagePath;

  late Timer _timer;
  late double deviceRatio;
  late double xScale;
  int _start = 10;

  @override
  void initState() {
    super.initState();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    initCamera();
  }
  void initCamera() async {

    final cameras = await availableCameras();

    _controller = CameraController(
      cameras.first,
      ResolutionPreset.high,
    );
    _initializeControllerFuture = _controller.initialize();
    await _controller.lockCaptureOrientation(DeviceOrientation.portraitUp);
    // await _controller.lockCaptureOrientation();
    setState(() {
      canBeDrawn = true;
    });
  }

  @override
  void dispose() {

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp
    ]);

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
            builder: (context) => VideoPlayerScreen(videoPath: video.path,),
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

  // Gives some time before going to the next screen to make sure everything
  // is saved correctly.
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

  // Used for focussing while filming
  Future<void> _onTap(TapUpDetails details) async {
    if(_controller.value.isInitialized) {
      showFocusCircle = true;
      x = details.localPosition.dx;
      y = details.localPosition.dy;

      double fullWidth = MediaQuery.of(context).size.width;
      double cameraHeight = fullWidth * _controller.value.aspectRatio;

      double xp = x / fullWidth;
      double yp = y / cameraHeight;

      Offset point = Offset(xp,yp);
      print("point : $point");

      // Manually focus
      await _controller.setFocusPoint(point);

      // Manually set light exposure
      //controller.setExposurePoint(point);

      setState(() {
        Future.delayed(const Duration(seconds: 2)).whenComplete(() {
          setState(() {
            showFocusCircle = false;
          });
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    customStyleClass = CustomStyleClass(context: context);

    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;

    deviceRatio = screenWidth / screenHeight;

    // Modify the yScale if you are in Landscape
    double yScale = 1;



    return Scaffold(

      // bottomNavigationBar: _buildBottomNavigationBar(),

      body: canBeDrawn ? Stack(
        children: [

          FutureBuilder<void>(
            future: _initializeControllerFuture,
            builder: (context, snapshot) {

              final scale = 1 / (_controller.value.aspectRatio * MediaQuery.of(context).size.aspectRatio);

              if(!snapshot.hasData){
                if (snapshot.connectionState == ConnectionState.done) {
                  return GestureDetector(
                    onTapUp: (details) {
                      _onTap(details);
                    },
                    child: Stack(
                      children: [

                        CameraPreview(_controller),

                        // Focus point
                        if(showFocusCircle) Positioned(
                            top: y-20,
                            left: x-20,
                            child: Container(
                              height: 40,
                              width: 40,
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white,width: 1.5)
                              ),
                            )
                        ),

                        // Record button
                        Container(
                          padding: const EdgeInsets.only(
                              bottom: 20
                          ),
                          height: screenHeight,
                          width: screenWidth,
                          alignment: Alignment.bottomCenter,
                          child: Row(
                            mainAxisAlignment: _isRecording ? MainAxisAlignment.center
                                : MainAxisAlignment.spaceEvenly,
                            children: [
                              GestureDetector(
                                child: Container(
                                    padding: const EdgeInsets.symmetric(
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
                                              color: _isRecording ? customStyleClass.primeColor.withOpacity(0.5) : Colors.white.withOpacity(0.5)
                                          )
                                      ),
                                      child: Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: _isRecording ? customStyleClass.primeColor: Colors.white,
                                          // borderRadius: BorderRadius.circular(20)
                                        ),
                                      ),
                                    )
                                ),
                                onTap: () => pressedRecord(),
                              )
                            ],
                          ),
                        ),


                        //Close Icon
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
                    ),
                  );
                } else {
                  return Center(child: CircularProgressIndicator(color: customStyleClass.primeColor,));
                }
              }else{
                return  Center(child: CircularProgressIndicator(color: customStyleClass.primeColor));
              }
            },
          )

        ],
      ):
      Center(child: CircularProgressIndicator(color: customStyleClass.primeColor)),
    );
  }
}