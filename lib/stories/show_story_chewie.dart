import 'dart:typed_data';
import 'dart:io' as io;
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:no_screenshot/no_screenshot.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import '../services/supabase_service.dart';
import '../shared/custom_text_style.dart';

class ShowStoryChewie extends StatefulWidget {
  ShowStoryChewie({Key? key, required this.storyUUID, required this.clubName}) : super(key: key);

  String storyUUID;
  String clubName;

  @override
  State<ShowStoryChewie> createState() => _ShowStoryChewieState();
}

class _ShowStoryChewieState extends State<ShowStoryChewie>
    with WidgetsBindingObserver {

  String? VIDEO_ON;
  ChewieController? _chewieController;
  late CustomTextStyle customTextStyle;
  late VideoPlayerController _controller;
  final _noScreenshot = NoScreenshot.instance;
  final SupabaseService _supabaseService = SupabaseService();

  late double screenHeight, screenWidth;


  @override
  void initState() {
    _noScreenshot.screenshotOff();
    initializePlayer();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    _chewieController!.dispose();
    _chewieController!.setVolume(0.0);

    super.dispose();
  }

  void goBackClicked(){
    Navigator.pop(context);
  }

  _createChewieController() {
    _chewieController = ChewieController(
      videoPlayerController: _controller,
      looping: true,
      autoPlay: true,
      showOptions: false,
      autoInitialize: true,
      allowFullScreen: true,
    );
  }

  Future<void> initializePlayer() async {

    late io.File file;
    late String filePath;
    late Uint8List? videoFile;

    try{
      videoFile = await _supabaseService.getClubVideo(widget.storyUUID);

      io.Directory tempDir = await getTemporaryDirectory();
      String tempPath = tempDir.path;
      filePath = '$tempPath/file_01.mp4';

      file = await io.File(filePath).writeAsBytes(videoFile!);

      _controller = VideoPlayerController.file(file);
      await _controller.initialize();
      setState((){
        _createChewieController();
      });

    }catch(e){
      print(e);
      _supabaseService.createErrorLog("Error in fetchVideo1: ${e.toString()}");
      try{
        var raw = io.File.fromRawPath(videoFile!);

        _controller = VideoPlayerController.file(raw);
        await _controller.initialize();
        setState((){
          _createChewieController();
        });
      }catch(e){
        _supabaseService.createErrorLog("Error in fetchVideo2: ${e.toString()}");
      }
    }
  }

  Widget test1(){
    return Material(
      child: Stack(
        children: [

          // Video screen
          Container(
              width: screenWidth,
              height: screenHeight,
              padding: EdgeInsets.only(top:screenHeight*0.02),
              child:

              _chewieController != null &&
                  _chewieController!
                      .videoPlayerController.value.isInitialized
                  ? SizedBox(
                width: screenWidth,
                height: screenHeight*0.85, // 0.97
                child: Chewie(
                  controller: _chewieController!,
                ),
              ) : SizedBox(
                width: screenWidth,
                height: screenHeight,
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              )


            // ClipRRect(
            //     child: FittedBox(
            //         // fit: BoxFit.cover,
            //         // alignment: Alignment.center,
            //         child: _chewieController != null &&
            //             _chewieController!
            //                 .videoPlayerController.value.isInitialized
            //             ? SizedBox(
            //           width: screenWidth,
            //           height: screenHeight, // 0.97
            //           child: Chewie(
            //             controller: _chewieController!,
            //           ),
            //         ) : SizedBox(
            //           width: screenWidth,
            //           height: screenHeight,
            //           child: const Center(
            //             child: CircularProgressIndicator(),
            //           ),
            //         )
            //     )
            // ),


          ),

          // Club name
          // Padding(
          //   padding: EdgeInsets.only(
          //       top: screenHeight*0.06
          //   ),
          //   child: SizedBox(
          //     width: screenWidth,
          //     child: Text(
          //       widget.clubName,
          //       textAlign: TextAlign.center,
          //       style: customTextStyle.size2(),
          //     ),
          //   ),
          // ),

          Container(
            color: Color(0xff11181f),
            width: screenWidth,
            height: screenHeight*0.09,
            alignment: Alignment.bottomRight,
            child: IconButton(
                onPressed: () => goBackClicked(),
                icon: const Icon(
                  Icons.clear,
                  size: 30,
                )
            ),
          )

        ],
      ),
    );
  }
  Widget test2(){
    return MaterialApp(
      title: "test",
      theme: ThemeData(
        scaffoldBackgroundColor: Color(0xff11181f),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text(widget.clubName, style: TextStyle(color: Colors.white),),
          backgroundColor: Color(0xff11181f),
          actions: [
            IconButton(
                onPressed: () => goBackClicked(),
                icon: const Icon(
                  Icons.clear,
                  size: 30,
                  color: Colors.white,
                )
            )
          ],
        ),
        body: Column(
          children: [
            Expanded(
                child: Center(
                  child: _chewieController != null && _chewieController!.videoPlayerController.value.isInitialized ?
                  Chewie(
                    controller: _chewieController!,
                  ) : const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 20,),
                      Text("Lädt...")
                    ],
                  ),
                )
            ),
            
            // TextButton(
            //   onPressed: () {
            //     _chewieController?.enterFullScreen();
            //   },
            //   child: const Text('Fullscreen'),
            // ),


          ],
        )
      )
    );
  }

  @override
  Widget build(BuildContext context) {

    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;

    customTextStyle = CustomTextStyle(context: context);

    return test2();

  }
}



