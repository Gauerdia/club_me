import 'dart:typed_data';
import 'dart:io' as io;
import 'package:chewie/chewie.dart';
import 'package:club_me/provider/current_and_liked_elements_provider.dart';
import 'package:flutter/material.dart';
import 'package:no_screenshot/no_screenshot.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import '../services/supabase_service.dart';
import '../shared/custom_text_style.dart';

class ShowStoryChewie extends StatefulWidget {
  ShowStoryChewie({Key? key}) : super(key: key);

  @override
  State<ShowStoryChewie> createState() => _ShowStoryChewieState();
}

class _ShowStoryChewieState extends State<ShowStoryChewie>
    with WidgetsBindingObserver {

  String? VIDEO_ON;
  ChewieController? _chewieController;
  late CustomStyleClass customStyleClass;
  late VideoPlayerController _controller;
  final _noScreenshot = NoScreenshot.instance;
  final SupabaseService _supabaseService = SupabaseService();
  late CurrentAndLikedElementsProvider currentAndLikedElementsProvider;

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

    currentAndLikedElementsProvider = Provider.of<CurrentAndLikedElementsProvider>(context, listen:  false);

    late io.File file;
    late String filePath;
    late Uint8List? videoFile;

    try{
      videoFile = await _supabaseService.getClubVideo(currentAndLikedElementsProvider.getCurrentClubStoryId());

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

  Widget test2(){

    currentAndLikedElementsProvider = Provider.of<CurrentAndLikedElementsProvider>(context, listen:  false);

    return MaterialApp(
      title: "test",
      theme: ThemeData(
        scaffoldBackgroundColor: customStyleClass.backgroundColorMain,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Container(
            width: screenWidth,
            child:
            Stack(
              children: [
                Container(
                  width: screenWidth,
                  child: Center(
                    child: Text(
                        textAlign: TextAlign.center,
                        currentAndLikedElementsProvider.currentClubMeClub.getClubName(),
                        style: customStyleClass.getFontStyleHeadline1Bold()
                    ),
                  ),
                ),

                Container(
                  alignment: Alignment.centerRight,
                  width: screenWidth,
                  child: InkWell(
                    child: const Icon(
                      Icons.clear,
                      size: 30,
                      color: Colors.white,
                    ),
                    onTap: () => goBackClicked(),
                  ),
                )

              ],
            )

          ),
          backgroundColor: customStyleClass.backgroundColorMain,
        ),
        body: Container(
          width: screenWidth,
          height: screenHeight,
          child: Column(
            children: [
              Expanded(
                  child: Center(
                    child: _chewieController != null && _chewieController!.videoPlayerController.value.isInitialized ?

                    // main video screen
                    Chewie(
                      controller: _chewieController!,
                    ):

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
          ),
        )
      )
    );
  }

  @override
  Widget build(BuildContext context) {

    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;

    customStyleClass = CustomStyleClass(context: context);

    return test2();

  }
}



