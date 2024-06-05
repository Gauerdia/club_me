import 'dart:io' as io;
import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import '../services/supabase_service.dart';


class Test extends StatefulWidget {
  const Test({Key? key}) : super(key: key);

  @override
  State<Test> createState() => _TestState();
}

class _TestState extends State<Test> {

  late VideoPlayerController _controller;
  late Future<void> _initializeControllerFuture;

  final SupabaseService _supabaseService = SupabaseService();

  late Future getVideo;

  bool readyToDisplay = false;

  @override
  void initState() {
    super.initState();
    fetchVideo();
  }

  void fetchVideo() async {

    Uint8List? videoFile = await _supabaseService.getVideo("fewfwef");

    Directory tempDir = await getTemporaryDirectory();
    String tempPath = tempDir.path;
    var filePath = tempPath + '/file_01.tmp';

    io.File test = await io.File(filePath).writeAsBytes(videoFile!);

    _controller = VideoPlayerController.file(test);

    _initializeControllerFuture = _controller.initialize();
    _controller.setLooping(true);

    setState(() {
      readyToDisplay = true;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Video player screen')),
      body: readyToDisplay?
      FutureBuilder(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: VideoPlayer(_controller),
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ):Container(),
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
      ): FloatingActionButton(onPressed: (){}),
    );
  }
}
