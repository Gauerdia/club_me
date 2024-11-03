import 'dart:async';
import 'dart:io' as io;
import 'dart:io';
import 'dart:typed_data';
import 'package:adv_camera/adv_camera.dart';
import 'package:camera/camera.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:googleapis/admin/directory_v1.dart';

import 'package:no_screenshot/no_screenshot.dart';

import 'package:mime/mime.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:video_player/video_player.dart';

import '../main.dart';
import '../services/supabase_service.dart';
import 'custom_text_style.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import 'dart:math' as math;

class Test extends StatefulWidget {
  const Test({Key? key}) : super(key: key);

  @override
  State<Test> createState() => _TestState();
}

class _TestState extends State<Test> {

  final _noScreenshot = NoScreenshot.instance;

  late String _path;

  bool isImage = false;
  bool isVideo = false;

  String? VIDEO_ON;
  ChewieController? _chewieController;


  late double screenHeight, screenWidth;

  late CustomStyleClass customStyleClass;

  String fileExtension = "";

  var videoFormats = ['mp4', 'mov', 'm4v', 'avi'];
  var imageFormats = ['jpg', 'jpeg', 'png', 'avif', 'webp'];

  final SupabaseService _supabaseService = SupabaseService();

  File? file;
  ByteData? screenshot;

  late CameraController _cameraController;
  late VideoPlayerController _videoPlayerController;
  late VideoPlayerController _chewieVideoPlayerController;


  late Future<void> _initializeCameraControllerFuture;
  late Future<void> _initializeVideoPlayerControllerFuture;
  // late Future<void> _initializeChewieVideoPlayerControllerFuture;

  bool showFocusCircle = false;
  double x = 0;
  double y = 0;

  bool canBeDrawn = false;
  bool _isRecording = false;

  AdvCameraController? cameraController;
  List<String> pictureSizes = <String>[];
  String? imagePath;

  late Timer _timer;
  late double deviceRatio;
  late double xScale;
  int _start = 10;

  int showViewIndex = 0;

  String videoPath = "";

  late File video;

  @override
  void initState() {
    super.initState();

    initCamera();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      // DeviceOrientation.landscapeLeft,
      // DeviceOrientation.landscapeRight,
    ]);


  }

  @override
  void dispose() {

    super.dispose();
  }


  void initCamera() async {
    final cameras = await availableCameras();
    _cameraController = CameraController(
      cameras.first,
      ResolutionPreset.high,
    );
    _initializeCameraControllerFuture = _cameraController!.initialize();
    setState(() {
      canBeDrawn = true;
    });
  }

  void initVideoPlayer() async{

    _videoPlayerController = VideoPlayerController.file(File(videoPath));

    File video = File(videoPath);

    _initializeVideoPlayerControllerFuture = _videoPlayerController.initialize();
    _videoPlayerController.setLooping(true);
  }

  Future<void> initializeChewiePlayer() async {

    print("Test: initializeChewiePlayer");

    late io.File file;
    late String filePath;
    late Uint8List? videoFile;

    try{
      videoFile = video.readAsBytesSync();

      io.Directory tempDir = await getTemporaryDirectory();
      String tempPath = tempDir.path;
      filePath = '$tempPath/file_01.mp4';

      file = await io.File(filePath).writeAsBytes(videoFile);

      _chewieVideoPlayerController = VideoPlayerController.file(file);
      await _chewieVideoPlayerController.initialize().then(
          (_) => setState(
              () => _chewieController = ChewieController(
                  aspectRatio: _chewieVideoPlayerController.value.aspectRatio,
                  videoPlayerController: _chewieVideoPlayerController,
                  looping: true,
                  autoPlay: true,
                  showOptions: false,
                  autoInitialize: true,
                  allowFullScreen: true,
                  fullScreenByDefault: false
              ),
          ),
      );

      print("Test: _chewieVideoPlayerController 1 init");

      setState((){
        // _createChewieController();
        print("after createChewie 1");
      });

    }catch(e){
      print("Test: Error: $e");
      try{
        var raw = io.File.fromRawPath(videoFile!);

        _chewieVideoPlayerController = VideoPlayerController.file(raw);
        await _chewieVideoPlayerController.initialize();
        print("Test: _chewieVideoPlayerController 2 init");
        setState((){
          // _createChewieController();
          print("Test: after createChewie 2");
        });
      }catch(e){
        print("Test: Error: $e");
      }
    }
  }

  // _createChewieController() {
  //   _chewieController = ChewieController(
  //     aspectRatio: 16/9,
  //     videoPlayerController: _chewieVideoPlayerController,
  //     looping: true,
  //     autoPlay: true,
  //     showOptions: false,
  //     autoInitialize: true,
  //     allowFullScreen: true,
  //     fullScreenByDefault: false
  //   );
  // }

  void pressedBack(){
    context.go('/club_frontpage');
  }
  void pressedRecord() async{
    try {
      await _initializeCameraControllerFuture;

      if (!mounted) {return;}

      if (_isRecording) {
        XFile videoRecording = await _cameraController!.stopVideoRecording();
        video = File(videoRecording.path);

        setState(() {
          videoPath = video.path;
          initVideoPlayer();
          showViewIndex = 1;
        });

      } else {
        await _cameraController!.prepareForVideoRecording();
        await _cameraController!.startVideoRecording();
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

            final video = await _cameraController!.stopVideoRecording();

            setState(() {
              videoPath = video.path;
              showViewIndex = 1;
            });

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
    if(_cameraController!.value.isInitialized) {
      showFocusCircle = true;
      x = details.localPosition.dx;
      y = details.localPosition.dy;

      double fullWidth = MediaQuery.of(context).size.width;
      double cameraHeight = fullWidth * _cameraController!.value.aspectRatio;

      double xp = x / fullWidth;
      double yp = y / cameraHeight;

      Offset point = Offset(xp,yp);
      print("point : $point");

      // Manually focus
      await _cameraController!.setFocusPoint(point);

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

  void pressedPlay(){
    setState(() {
      if (_videoPlayerController.value.isPlaying) {
        _videoPlayerController.pause();
      } else {
        _videoPlayerController.play();
      }
    });
  }

  Widget showRecordingScreen(){

    return Scaffold(

      // bottomNavigationBar: _buildBottomNavigationBar(),

      body: canBeDrawn ? Stack(
        children: [

          FutureBuilder<void>(
            future: _initializeCameraControllerFuture,
            builder: (context, snapshot) {

              final scale = 1 / (_cameraController.value.aspectRatio * MediaQuery.of(context).size.aspectRatio);

              if(!snapshot.hasData){
                if (snapshot.connectionState == ConnectionState.done) {
                  return GestureDetector(
                    onTapUp: (details) {
                      _onTap(details);
                    },
                    child: Stack(
                      children: [

                        // Camera view

                        OrientationBuilder(
                          builder: (context, orientation) {
                            // set the turn as per requirement
                            final turn = orientation == Orientation.landscape ? 1: 4; // set the turn as per requirement
                            return orientation == Orientation.landscape ?
                            CameraPreview(_cameraController) : RotatedBox(
                                quarterTurns: turn,
                                child:

                                CameraPreview(_cameraController)

                              // Transform.scale(
                              //   scale: scale,
                              //   alignment: Alignment.topCenter,
                              //   child: ,
                              // ),
                            );
                          },
                        ),

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

  Widget showRecordingScreen2(){
    return canBeDrawn ? Stack(
      children: [

        FutureBuilder<void>(
          future: _initializeCameraControllerFuture,
          builder: (context, snapshot) {

            final scale = 1 / (_cameraController!.value.aspectRatio * MediaQuery.of(context).size.aspectRatio);

            if(!snapshot.hasData){
              if (snapshot.connectionState == ConnectionState.done) {
                return GestureDetector(
                  onTapUp: (details) {
                    _onTap(details);
                  },
                  child: Stack(
                    children: [

                      // Camera view

                      OrientationBuilder(
                        builder: (context, orientation) {
                          // set the turn as per requirement

                          if(orientation == Orientation.landscape){
                            return RotatedBox(
                              quarterTurns: 1,
                              child:

                                FittedBox(
                                  fit: BoxFit.cover,
                                  child: Container(
                                    width: 100,
                                    child: CameraPreview(_cameraController!),
                                  ),
                                )

                                // Transform.scale(
                                //  scale: scale,
                                //  alignment: Alignment.topCenter,
                                //  child: CameraPreview(_cameraController),
                                // )
                                //
                              // AspectRatio(
                              //   aspectRatio: 1,
                              //   child: CameraPreview(_cameraController),
                              // ),


                            );
                          }else{

                            return RotatedBox(
                              quarterTurns: 1,
                              child: AspectRatio(
                                  aspectRatio: _cameraController!.value.aspectRatio,
                                child: CameraPreview(_cameraController!),
                              ),
                            );

                            // return Transform.scale(
                            //   scale: scale,
                            //   alignment: Alignment.topCenter,
                            //   child: CameraPreview(_cameraController),
                            // );
                          }

                          // final turn = orientation == Orientation.landscape ? 2: 1; // set the turn as per requirement
                          // return RotatedBox(
                          //     quarterTurns: turn,
                          //   child:
                          //   CameraPreview(_cameraController),
                            // AspectRatio(
                            //   aspectRatio: _cameraController.value.aspectRatio,
                            //   child: CameraPreview(_cameraController),
                            // ),
                          // );

                          // CameraPreview(_cameraController) : RotatedBox(
                          //   quarterTurns: turn,
                          //   child:
                          //
                          //   // Transform.scale(
                          //   //   scale: scale,
                          //   //   alignment: Alignment.topCenter,
                          //   //   child: CameraPreview(_cameraController),
                          //   // ),
                          // );
                        },
                      ),

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
                return Center(child: CircularProgressIndicator(color: Colors.red,));
              }
            }else{
              return  Center(child: CircularProgressIndicator(color: Colors.blue));
            }
          },
        )

      ],
    ):
    Center(child: CircularProgressIndicator(color: customStyleClass.primeColor));
  }
  Widget showReviewScreen(){
    return FutureBuilder(
      future: _initializeVideoPlayerControllerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {

          // Camera view
          return Stack(
            children: [

              OrientationBuilder(
                builder: (context, orientation) {
                  // set the turn as per requirement
                  final turn = orientation == Orientation.landscape ? 1: 1; // set the turn as per requirement
                  return RotatedBox(
                    quarterTurns: turn,
                    child: VideoPlayer(_videoPlayerController),
                  );
                },
              ),

              // SizedBox(
              //   height: screenHeight*0.8,
              //   width: screenWidth,
              //   child: VideoPlayer(_controller),
              // ),
              // Three icons
              Container(
                height: screenHeight,
                width: screenWidth,
                padding: const EdgeInsets.only(
                    bottom: 20
                ),
                alignment: Alignment.bottomCenter,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GestureDetector(
                      child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: screenWidth*0.04,
                              vertical: screenHeight*0.013
                          ),
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.all(
                                Radius.circular(10)
                            ),
                            gradient: LinearGradient(
                                colors: [
                                  customStyleClass.primeColorDark,
                                  customStyleClass.primeColor,
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
                          child:
                          const Icon(
                            Icons.close,
                            color: Colors.redAccent,
                            size: 32,
                          )
                      ),
                      onTap: () => pressedBack(),
                    ),
                    GestureDetector(
                      child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: screenWidth*0.04,
                              vertical: screenHeight*0.013
                          ),
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.all(
                                Radius.circular(10)
                            ),
                            gradient: LinearGradient(
                                colors: [
                                  customStyleClass.primeColorDark,
                                  customStyleClass.primeColor,
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
                          child: Icon(
                            _videoPlayerController.value.isPlaying ? Icons.pause : Icons.play_arrow,
                            size: 32,
                            color: Colors.white,
                          )
                      ),
                      onTap: () => pressedPlay(),
                    ),
                    GestureDetector(
                      child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: screenWidth*0.04,
                              vertical: screenHeight*0.013
                          ),
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.all(
                                Radius.circular(10)
                            ),
                            gradient: LinearGradient(
                                colors: [
                                  customStyleClass.primeColorDark,
                                  customStyleClass.primeColor,
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
                          child:
                          const Icon(
                            Icons.check,
                            color: Colors.greenAccent,
                            size: 32,
                          )
                      ),
                      onTap: (){
                        // => pressedSave(),
                        setState(() async {
                          await initializeChewiePlayer();
                          showViewIndex = 2;
                        });
                      }
                    )
                  ],
                ),
              ),

            ],
          );

        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }
  Widget showChewieScreen(){
    return Scaffold(
        // appBar: _buildAppBar(),
        body: Container(
          width: screenWidth,
          height: screenHeight,
          child: _chewieController != null && _chewieController!.videoPlayerController.value.isInitialized ?

          Chewie(
            controller: _chewieController!,
          )

          // AspectRatio(
          //   // aspectRatio: _chewieVideoPlayerController.value.aspectRatio,
          //   child: Chewie(
          //     controller: _chewieController!,
          //   ),
          // )
              : SizedBox()

        )
    );
  }

  Column _buildBasicColumn(){
    return Column(
      children: [
        Expanded(
            child: Center(
              child: _chewieController != null &&
                  _chewieController!.videoPlayerController.value.isInitialized ?

              // main video screen


              AspectRatio(
                aspectRatio: _chewieVideoPlayerController.value.aspectRatio,
                child: Chewie(
                  controller: _chewieController!,
                ),
              )


              //         OrientationBuilder(
              //         builder: (context, orientation) {
              //     // set the turn as per requirement
              //     final turn = orientation == Orientation.landscape ? 1: 1; // set the turn as per requirement
              //     return RotatedBox(
              //     quarterTurns: turn,
              //     child:
              //     // VideoPlayer(_chewieVideoPlayerController)
              //     Chewie(
              //       controller: _chewieController!,
              //     )
              //   );
              // },
              // )

              // Chewie(
              //   controller: _chewieController!,
              // )
                  :

              // loading screen
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: customStyleClass.primeColor,
                  ),
                  const SizedBox(height: 20,),
                  Text(
                    "Lädt...",
                    style: customStyleClass.getFontStyle3(),
                  )
                ],
              ),

            )
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {

    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;

    customStyleClass = CustomStyleClass(context: context);

    return Scaffold(

      appBar: AppBar(
          title: const Text('Vorschau')
      ),

      body:

      showViewIndex == 0 ? showRecordingScreen() :
      showViewIndex == 1 ? showReviewScreen() : showChewieScreen(),

      // Container(
      //   width: screenWidth,
      //   height: screenHeight,
      //   child: Center(
      //     child: InkWell(
      //       child: const Text(
      //           "test",
      //         style: TextStyle(
      //           color: Colors.red
      //         ),
      //       ),
      //       onTap: () => showViewIndex == 0 ? showRecordingScreen() :
      //       showViewIndex == 1 ? showReviewScreen() : showChewieScreen(),
      //     ),
      //   ),
      // )
    );
  }
}
