import 'dart:typed_data';
import 'dart:io' as io;
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import '../services/supabase_service.dart';
import 'custom_text_style.dart';

class ShowStoryChewie extends StatefulWidget {
  ShowStoryChewie({Key? key, required this.storyUUID, required this.clubName}) : super(key: key);

  String storyUUID;
  String clubName;

  @override
  State<ShowStoryChewie> createState() => _ShowStoryChewieState();
}

class _ShowStoryChewieState extends State<ShowStoryChewie> {

  ChewieController? _chewieController;
  late VideoPlayerController _controller;

  late CustomTextStyle customTextStyle;

  final SupabaseService _supabaseService = SupabaseService();

  String? VIDEO_ON;

  @override
  void initState() {
    // VIDEO_ON = widget.thumbnail;
    initializePlayer();
    super.initState();
  }
  @override
  void dispose() {
    // widget.videoPlayerController.dispose();
    _controller.dispose();
    _chewieController!.dispose();
    super.dispose();
    _chewieController!.setVolume(0.0);
  }

  void goBackClicked(){
    Navigator.pop(context);
  }
  _createChewieController() {
    _chewieController = ChewieController(
      videoPlayerController: _controller,
      autoPlay: true,
      looping: true,
      allowFullScreen: true,
      showOptions: true,
      autoInitialize: true,
    );
  }
  Future<void> initializePlayer() async {

    late io.File file;
    late Uint8List? videoFile;
    late String filePath;

    try{
      videoFile = await _supabaseService.getVideo(widget.storyUUID);

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


  @override
  Widget build(BuildContext context) {

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    customTextStyle = CustomTextStyle(context: context);

    return Material(
      child: Stack(
        children: [

          // Video screen
          SizedBox(
              width: screenWidth,
              child: ClipRRect(
                  child: FittedBox(
                      fit: BoxFit.cover,
                      alignment: Alignment.center,
                      child: _chewieController != null &&
                          _chewieController!
                              .videoPlayerController.value.isInitialized
                          ? SizedBox(
                        width: screenWidth,
                        height: screenHeight,
                        child: Chewie(
                          controller: _chewieController!,
                        ),
                      )
                          : SizedBox(
                        width: screenWidth,
                        height: screenHeight,
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      )
                  )
              )
          ),

          // Club name
          Padding(
            padding: EdgeInsets.only(
                top: screenHeight*0.06
            ),
            child: SizedBox(
              width: screenWidth,
              child: Text(
                widget.clubName,
                textAlign: TextAlign.center,
                style: customTextStyle.size2(),
              ),
            ),
          ),

          // Back arrow icon
          Padding(
            padding: EdgeInsets.only(
                top: screenHeight*0.05
            ),
            child: IconButton(
                onPressed: () => goBackClicked(),
                icon: const Icon(
                    Icons.arrow_back_ios
                )
            ),
          ),


        ],
      ),
    );

  }
}
