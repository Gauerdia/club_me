import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import '../provider/state_provider.dart';
import '../services/supabase_service.dart';
import 'package:uuid/uuid.dart';

import '../shared/custom_text_style.dart';

class VideoPlayerScreen extends StatefulWidget {

  String videoPath;

  VideoPlayerScreen({super.key, required this.videoPath});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {


  late var video;
  late CustomTextStyle customTextStyle;
  late VideoPlayerController _controller;
  late Future<void> _initializeControllerFuture;

  bool showLoading = false;

  late StateProvider stateProvider;

  final SupabaseService _supabaseService = SupabaseService();

  @override
  void initState() {
    super.initState();

    _controller = VideoPlayerController.file(File(widget.videoPath));

    video = File(widget.videoPath);

    _initializeControllerFuture = _controller.initialize();
    _controller.setLooping(true);
  }


  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void pressedBack(){
    context.go("/club_frontpage");
  }
  void pressedPlay(){
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
      } else {
        _controller.play();
      }
    });
  }
  void pressedSave(){
    saveStoryToSupabase(stateProvider, video);
  }

  @override
  Widget build(BuildContext context) {

    stateProvider = Provider.of<StateProvider>(context);

    customTextStyle = CustomTextStyle(context: context);

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(

      body: Stack(
        children: [
          showLoading ? Container()
          : FutureBuilder(
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
          ),
          showLoading? const Center(
              child: CircularProgressIndicator(),
          ):Container()
        ],
      ),

      bottomNavigationBar: Container(
        height: screenHeight*0.13,
        width: screenWidth,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Align(
                alignment: AlignmentDirectional.center,
                child: GestureDetector(
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
                    child:
                    const Icon(
                      Icons.close,
                      color: Colors.redAccent,
                      size: 32,
                    )
                  ),
                  onTap: () => pressedBack(),
                )
            ),
            Align(
                alignment: AlignmentDirectional.center,
                child: GestureDetector(
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
                    child:
                    // Text(
                    //   _controller.value.isPlaying? "Pausieren" : "Abspielen",
                    //   style: customTextStyle.size4Bold(),
                    // ),
                    Icon(
                      _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                      size: 32,
                    )
                  ),
                  onTap: () => pressedPlay(),
                )
            ),
            Align(
                alignment: AlignmentDirectional.center,
                child: GestureDetector(
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
                    child:
                    const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 32,
                    )
                    // Text(
                    //   "Speichern",
                    //   style: customTextStyle.size4Bold(),
                    // ),
                  ),
                  onTap: () => pressedSave(),
                )
            )
          ],
        ),
      ),

    );
  }

  void saveStoryToSupabase(StateProvider stateProvider, var video) async{

    var uuid = const Uuid();
    String uuidV4 = uuid.v4();

    setState(() {
      showLoading = true;
    });

    await _supabaseService.insertClubVideo(video, uuidV4, stateProvider.getClubId(), stateProvider)
        .then((value){
      if(value == 0){
        stateProvider.setClubStoryId(uuidV4);
        context.go('/club_frontpage');
      }else{
        showBottomSheet(
            context: context,
            builder: (BuildContext context){
              return const Text("Sorry, something went wrong!");
            }
        );
      }
      return 0;
    });
  }
}