import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import 'package:no_screenshot/no_screenshot.dart';

import 'package:mime/mime.dart';

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

  var videoFormats = ['mp4', 'mov', 'm4v', 'avi'];
  var imageFormats = ['jpg', 'jpeg', 'png', 'avif', 'webp'];

  File? file;

  @override
  void initState() {
    _noScreenshot.screenshotOff();
    super.initState();
  }

  void test() async{
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: false
      // type: FileType.image
      // type: FileType.custom,
      // allowedExtensions: imageFormats
    );
    if (result != null) {
      setState(() {
        file = File(result.files.single.path!);
        PlatformFile pFile = result.files.first;

        String mimeStr = lookupMimeType(file!.path)!;

        var fileType = mimeStr.split("/");
        print('file type $fileType');

        if(fileType.contains('image')){
          print("is image");
          isImage = true;
        }else if(fileType.contains('video')){
          print("is video");
          isVideo = true;
        }

        print(file.runtimeType);
        print(pFile.extension);
      });
    } else {
      // User canceled the picker
    }
  }

  @override
  Widget build(BuildContext context) {

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
          title: const Text('Test')
      ),
      body: Container(
        height: screenHeight,
        width: screenWidth,
        decoration: BoxDecoration(
          color: Colors.green,
          border: Border.all(
            color: Colors.red
          )
        ),
        // child: file != null ? Center(
        //   child: Image.file(
        //     file!,
        //     fit: BoxFit.contain,
        //     width: double.infinity,
        //   ),
        // ): Container(),
      ),
      floatingActionButton:FloatingActionButton(
        onPressed: () {
          test();
        },
        child: const Icon(
          Icons.add
        )
      )
    );
  }
}
