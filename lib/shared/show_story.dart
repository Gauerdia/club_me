import 'dart:io' as io;
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

import '../services/supabase_service.dart';
import 'custom_text_style.dart';

class ShowStory extends StatefulWidget {

  String storyUUID;

  ShowStory({Key? key, required this.storyUUID}) : super(key: key);

  @override
  State<ShowStory> createState() => _ShowStoryState();
}

class _ShowStoryState extends State<ShowStory> {

  late VideoPlayerController _controller;
  late Future<void> _initializeControllerFuture;

  final SupabaseService _supabaseService = SupabaseService();

  late CustomTextStyle customTextStyle;

  late Future getVideo;

  bool readyToDisplay = false;

  @override
  void initState() {
    super.initState();
    fetchVideo();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.pause();
  }

  void fetchVideo() async {

    try{
      Uint8List? videoFile = await _supabaseService.getVideo(widget.storyUUID);

      io.Directory tempDir = await getTemporaryDirectory();
      String tempPath = tempDir.path;
      var filePath = '$tempPath/file_01.mp4';

      io.File test = await io.File(filePath).writeAsBytes(videoFile!);

      _controller = VideoPlayerController.file(test);

      _initializeControllerFuture = _controller.initialize();
      _controller.setLooping(true);

      setState(() {
        readyToDisplay = true;
      });

    }catch(e){
      print(e);
      _supabaseService.createErrorLog("Error in fetchVideo: ${e.toString()}");
    }
  }


  @override
  Widget build(BuildContext context) {

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    customTextStyle = CustomTextStyle(context: context);

    return Scaffold(
      appBar: AppBar(
          title: SizedBox(
            width: screenWidth,
            child: Text(
                'Schau dir die Club-Story an!',
              textAlign: TextAlign.center,
              style: customTextStyle.size1Bold(),
            ),
          )
      ),
      body: readyToDisplay?
      FutureBuilder(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            _controller.play();
            return AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: VideoPlayer(_controller),
            );
          } else {
            return SizedBox(
              height: screenHeight,
              width: screenWidth,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
        },
      ):SizedBox(
        height: screenHeight,
        width: screenWidth,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      ),

      floatingActionButton: readyToDisplay ?FloatingActionButton(
        onPressed: () {
          setState(() {
            if (_controller.value.isPlaying) {
              _controller.pause();
            } else {
              _controller.play();
            }
          });
        },
        child: Icon(
          _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
        ),
      ): FloatingActionButton(
          onPressed: (){}
      ),
    );
  }
}
