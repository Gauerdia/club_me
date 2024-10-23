import 'dart:io';
import 'dart:typed_data';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

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
  late VideoPlayerController _controller;

  late double screenHeight, screenWidth;

  late CustomStyleClass customStyleClass;

  String fileExtension = "";

  var videoFormats = ['mp4', 'mov', 'm4v', 'avi'];
  var imageFormats = ['jpg', 'jpeg', 'png', 'avif', 'webp'];

  final SupabaseService _supabaseService = SupabaseService();

  File? file;
  ByteData? screenshot;



  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {

    super.dispose();
  }

  void signUpNewUser() async {
    //
    // for(int i=0; i<clubNames.length; i++){
    //
    //   String firstWord = "";
    //
    //   if(clubNames[i].contains(" ")){
    //     firstWord = clubNames[i].substring(0, clubNames[i].indexOf(' '));
    //   }else{
    //     firstWord = clubNames[i];
    //   }
    //
    //   print("firstName: $firstWord");
    //
    //   try{
    //     final AuthResponse res = await supabase.auth.signUp(
    //         email: '$firstWord@club-me.de',
    //         password: clubPasswords[i],
    //         data: {
    //           'full_name': clubNames[i]
    //         }
    //     );
    //   }catch(e){
    //     print("error $e");
    //   }
    //
    //
    // }


    // final AuthResponse res = await supabase.auth.signUp(
    //     email: 'boa@club-me.de',
    //     password: 'be3o4xp3s.2pfe',
    //   data: {
    //       'full_name': "Boa"
    //   }
    // );
    // return res;
  }

  void signIn() async{
    final AuthResponse res = await supabase.auth.signInWithPassword(
      email: 'boa@club-me.de',
      password: 'be3o4xp3s.2pfe',
    );
    final Session? session = res.session;
    final User? user = res.user;
    // if(session != null){
    //   print("session: $session");
    // }
    // if(user != null){
    //   print("user: $user");
    // }
  }

  void testFct() async{
    signUpNewUser();
    // signIn();
    // var res = await signUpNewUser();
    // print("Res: $res");

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

      body: Container(
        width: screenWidth,
        height: screenHeight,
        child: Center(
          child: InkWell(
            child: const Text(
                "test",
              style: TextStyle(
                color: Colors.red
              ),
            ),
            onTap: () => testFct(),
          ),
        ),
      )
    );
  }
}
