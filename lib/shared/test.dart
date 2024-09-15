import 'dart:io';
import 'dart:typed_data';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import 'package:no_screenshot/no_screenshot.dart';

import 'package:mime/mime.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:video_player/video_player.dart';

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
    _noScreenshot.screenshotOff();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    _chewieController!.dispose();
    _chewieController!.setVolume(0.0);

    super.dispose();
  }

  _createChewieController() {
    _chewieController = ChewieController(
      videoPlayerController: _controller,
      looping: true,
      autoPlay: true,
      showOptions: true,
      autoInitialize: true,
      allowFullScreen: true,
    );
  }

  void test() async{
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: false
      // type: FileType.image
      // type: FileType.custom,
      // allowedExtensions: imageFormats
    );
    if (result != null) {

      file = File(result.files.single.path!);
      PlatformFile pFile = result.files.first;
      String mimeStr = lookupMimeType(file!.path)!;
      var fileType = mimeStr.split("/");
      fileExtension = pFile.extension.toString();

      if(fileType.contains('image')){
        print("is image");
        isImage = true;
      }else if(fileType.contains('video')){

        file = File(result.files.single.path!);
        _controller = VideoPlayerController.file(file!);
        await _controller.initialize();
        _createChewieController();



        print("is video");
        isVideo = true;
      }

      setState(() {
        print(file.runtimeType);
        print(pFile.extension);
      });
    } else {
      // User canceled the picker
    }
  }

  Widget _buildButtonRow(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [

        Container(
          height: screenHeight*0.07,
          width: screenHeight*0.08,
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            color: customStyleClass.primeColorDark,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              // BoxShadow(
              //   color: Colors.grey.withOpacity(0.5),
              //   spreadRadius: 2,
              //   blurRadius: 5,
              //   offset: Offset(0, 5),
              // ),
            ],
          ),
          child: Center(
            child: Text(
              "Zurück",
              style: customStyleClass.getFontStyle3Bold(),
            ),
          ),
        ),

        GestureDetector(
          child: Container(
            height: screenHeight*0.07,
            width: screenHeight*0.08,
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              color: customStyleClass.primeColorDark,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                // BoxShadow(
                //   color: Colors.grey.withOpacity(0.5),
                //   spreadRadius: 2,
                //   blurRadius: 5,
                //   offset: Offset(0, 3),
                // ),
              ],
            ),
            child: Center(
              child: Text(
                "Weiter",
                style: customStyleClass.getFontStyle3Bold(),
              ),
            ),
          ),
          onTap: () =>{
            upload()
          },
        )

      ],
    );
  }

  void upload()async{

    screenshot = await genThumbnailFile(file!.path);

    setState(() {
      isVideo = false;
    });

    // var uuid = const Uuid();
    // var uuidV4 = uuid.v4();
    //
    // String fileName = "$uuidV4.$fileExtension";

    // _supabaseService.uploadEventContent(file, fileName, "1111");

  }

  Future<ByteData> genThumbnailFile(String path) async {
    final fileName = await VideoThumbnail.thumbnailFile(
      video: path,
      thumbnailPath: (await getTemporaryDirectory()).path,
      imageFormat: ImageFormat.PNG,
      maxHeight: 100,
      quality: 75,
    );
    File file = File(fileName!);
    Uint8List bytes = file.readAsBytesSync();
    return ByteData.view(bytes.buffer);
    // return file;
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

      body: isImage ?
          Stack(
            children: [

              // Image container
              Container(
                width: screenWidth,
                height: screenHeight,
                child: Image.file(file!),
              ),

              // ButtonRow
              Container(
                width: screenWidth,
                height: screenHeight,
                alignment: Alignment.bottomCenter,
                padding: const EdgeInsets.only(bottom: 20),
                child: _buildButtonRow(),
              )

            ],
          )
          : isVideo ?
          Stack(
            children: [

              // Video container
              Container(
                width: screenWidth,
                height: screenHeight*0.8,
                child: _chewieController != null &&
                    _chewieController!
                        .videoPlayerController.value.isInitialized
                    ? SizedBox(
                  width: screenWidth,
                  height: screenHeight*0.97,
                  child: Chewie(
                    controller: _chewieController!,
                  ),
                ) :
              SizedBox(
                width: screenWidth,
                height: screenHeight,
                  child: const Center(
                  child: CircularProgressIndicator(),
                  ),
                ),
              ),

              // ButtonRow
              Container(
                width: screenWidth,
                height: screenHeight,
                alignment: Alignment.bottomCenter,
                padding: const EdgeInsets.only(bottom: 20),
                child: _buildButtonRow(),
              )


            ],
          )
          :Container(
        height: screenHeight,
        width: screenWidth,
        decoration: BoxDecoration(
          // color: Colors.green,
          // border: Border.all(
          //   color: Colors.red
          // )
        ),
        child: Column(
          children: [
            IconButton(
              onPressed: () {
                test();
              },
              icon: Icon(
                Icons.add,
                size: 30,
              ),
            ),
            screenshot != null ?
                Image.memory(screenshot!.buffer.asUint8List()):Container()
          ],
        ),
        // child: file != null ? Center(
        //   child: Image.file(
        //     file!,
        //     fit: BoxFit.contain,
        //     width: double.infinity,
        //   ),
        // ): Container(),
      ),

      // floatingActionButton:FloatingActionButton(
      //   onPressed: () {
      //     test();
      //   },
      //   child: const Icon(
      //     Icons.add
      //   )
      // )
    );
  }
}
