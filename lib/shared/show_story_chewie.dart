
import 'dart:typed_data';
import 'dart:io' as io;

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

import '../services/supabase_service.dart';

class ShowStoryChewie extends StatefulWidget {
  ShowStoryChewie({Key? key, required this.storyUUID}) : super(key: key);

  String storyUUID;

  @override
  State<ShowStoryChewie> createState() => _ShowStoryChewieState();
}

class _ShowStoryChewieState extends State<ShowStoryChewie> {

  ChewieController? _chewieController;
  late VideoPlayerController _controller;

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

  Future<void> initializePlayer() async {

    late io.File file;

    try{
      Uint8List? videoFile = await _supabaseService.getVideo(widget.storyUUID);

      io.Directory tempDir = await getTemporaryDirectory();
      String tempPath = tempDir.path;
      var filePath = '$tempPath/file_01.tmp';

      file = await io.File(filePath).writeAsBytes(videoFile!);

    }catch(e){
      print(e);
      _supabaseService.createErrorLog("Error in fetchVideo: ${e.toString()}");
    }

      _controller = VideoPlayerController.file(file);
      await _controller.initialize();
      setState((){
        _createChewieController();
      });

  }

  _createChewieController() {
    _chewieController = ChewieController(
      videoPlayerController: _controller,
      autoPlay: false,
      looping: true,
      allowFullScreen: true,
      showOptions: true,
      autoInitialize: true,
    );
  }



  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: MediaQuery.of(context).size.width,
        width: MediaQuery.of(context).size.width * 1,
        child: ClipRRect(
            child: FittedBox(
                fit: BoxFit.cover,
                alignment: Alignment.center,
                child: _chewieController != null &&
                    _chewieController!
                        .videoPlayerController.value.isInitialized
                    ? Chewie(
                  controller: _chewieController!,
                )
                    : Container()
            )
        )
    );
  }
}
