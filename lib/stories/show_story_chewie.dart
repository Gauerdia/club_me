import 'dart:io';
import 'dart:typed_data';
import 'dart:io' as io;
import 'package:chewie/chewie.dart';
import 'package:club_me/provider/current_and_liked_elements_provider.dart';
import 'package:club_me/provider/user_data_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  ChewieController? _chewieController;
  late CustomStyleClass customStyleClass;
  late VideoPlayerController _controller;
  final _noScreenshot = NoScreenshot.instance;
  final SupabaseService _supabaseService = SupabaseService();
  late CurrentAndLikedElementsProvider currentAndLikedElementsProvider;

  late double screenHeight, screenWidth;

  bool loadingFinished = false;

  @override
  void initState() {
    _noScreenshot.screenshotOff();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    final UserDataProvider userDataProvider = Provider.of<UserDataProvider>(context, listen: false);
    currentAndLikedElementsProvider = Provider.of<CurrentAndLikedElementsProvider>(context, listen:  false);


    _supabaseService.insertStoryWatch(
        currentAndLikedElementsProvider.getCurrentClubStoryId(),
        userDataProvider.getUserData().getUserId());

    initVideoPlayer();
    // initializePlayer();
    super.initState();
  }

  @override
  void dispose() {

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp
    ]);

    _controller.dispose();
    _chewieController!.dispose();
    _chewieController!.setVolume(0.0);

    super.dispose();
  }

  void goBackClicked(){
    Navigator.pop(context);
  }

  void initVideoPlayer() async{

    currentAndLikedElementsProvider = Provider.of<CurrentAndLikedElementsProvider>(context, listen:  false);

    late io.File file;
    late String filePath;
    late Uint8List? videoFile;

    try{

      videoFile = await _supabaseService.getClubVideo(currentAndLikedElementsProvider.getCurrentClubStoryId());

      io.Directory tempDir = await getTemporaryDirectory();
      String tempPath = tempDir.path;
      filePath = '$tempPath/file_01.mp4';

      File file = await io.File(filePath).writeAsBytes(videoFile);

      _controller = VideoPlayerController.file(file);
      await _controller.initialize();
      _controller.setLooping(true);
      _controller.play();

      setState(() {
        loadingFinished = true;
      });

    }catch(e){
      print("Error in ShowStoryChewie. Fct: initVideoPlayer. Error: $e");
      _supabaseService.createErrorLog("Error in ShowStoryChewie. Fct: initVideoPlayer. Error: $e");
    }

}

  // _createChewieController() {
  //   _chewieController = ChewieController(
  //     videoPlayerController: _controller,
  //     looping: true,
  //     autoPlay: true,
  //     showOptions: false,
  //     autoInitialize: true,
  //     allowFullScreen: true,
  //   );
  // }

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
      // setState((){
      //   _createChewieController();
      // });

    }catch(e){
      print(e);
      _supabaseService.createErrorLog("ShowStoryChewie. Fct: initializePlayer, 1st step: $e");
      try{
        var raw = io.File.fromRawPath(videoFile!);

        _controller = VideoPlayerController.file(raw);
        await _controller.initialize();
        // setState((){
        //   _createChewieController();
        // });
      }catch(e){
        _supabaseService.createErrorLog("ShowStoryChewie. Fct: initializePlayer, 2nd step: $e");
      }
    }
  }

  AppBar _buildAppBar(){
    return AppBar(
      title: Container(
        height: 40,
          width: screenWidth,
          child: Stack(
            children: [

              SizedBox(
                height: 40,
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
                height: 40,
                alignment: Alignment.centerLeft,
                width: screenWidth,
                child: Text(
                  formatTimeStamp(),
                  style: customStyleClass.getFontStyle5(),
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
    );
  }

  Widget _buildMainView(){

    currentAndLikedElementsProvider = Provider.of<CurrentAndLikedElementsProvider>(context, listen:  false);

    return MaterialApp(
      title: "test",
      theme: ThemeData(
        scaffoldBackgroundColor: customStyleClass.backgroundColorMain,
      ),
      home: Scaffold(
        extendBodyBehindAppBar: false,

        appBar: _buildAppBar(),
        body: loadingFinished ?
          Platform.isAndroid ?
          RotatedBox(
            quarterTurns: 1,
            child: VideoPlayer(_controller),
          ): VideoPlayer(_controller)

          //
          //     Container(
          //       // padding: EdgeInsets.only(
          //       //   top: screenHeight*0.1
          //       // ),
          //       child: OrientationBuilder(
          //         builder: (context, orientation) {
          //           // set the turn as per requirement
          //           final turn = orientation == Orientation.landscape ? 1: 0; // set the turn as per requirement
          //           return RotatedBox(
          //             quarterTurns: turn,
          //             child: VideoPlayer(_controller),
          //           );
          //         },
          //       ),
          //     )
          //
          //     :VideoPlayer(_controller)
            :
        Center(
          child: CircularProgressIndicator(color: customStyleClass.primeColor),
        )

      )
    );
  }

  String formatTimeStamp(){

    DateTime storyCreatedAt = currentAndLikedElementsProvider.currentClubMeClub.getStoryCreatedAt()!;
    DateTime currentTime = DateTime.now();

    Duration difference = currentTime.difference(storyCreatedAt);

    int dayDifference = difference.inDays % 1;

    int hourDifference = difference.inHours % 24;

    if(dayDifference < 1){
      if(hourDifference < 1){
        return "Vor ${difference.inMinutes % 64} Minuten";
      }else{
        return "Vor $hourDifference Stunden";
      }
    }else{
      return "Gestern";
    }

  }

  @override
  Widget build(BuildContext context) {

    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;

    customStyleClass = CustomStyleClass(context: context);

    return _buildMainView();

  }
}



