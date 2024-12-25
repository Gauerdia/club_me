import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mime/mime.dart';
import 'package:uuid/uuid.dart';

import '../../../services/supabase_service.dart';
import '../../../shared/custom_text_style.dart';
import '../../../shared/dialogs/TitleAndContentDialog.dart';

class UploadInfoScreenView extends StatefulWidget {
  const UploadInfoScreenView({super.key});

  @override
  State<UploadInfoScreenView> createState() => _UploadInfoScreenViewState();
}

class _UploadInfoScreenViewState extends State<UploadInfoScreenView> {

  late double screenHeight, screenWidth;
  late CustomStyleClass customStyleClass;
  File? file;
  String fileExtension = "";
  int buttonChoice = 0;
  int buttonColor = 0;

  final SupabaseService _supabaseService = SupabaseService();

  bool isUploading = false;

  late FixedExtentScrollController _buttonChoiceController;
  late FixedExtentScrollController _buttonColorController;

  @override
  void initState(){

    _buttonChoiceController = FixedExtentScrollController(initialItem: 0);
    _buttonColorController = FixedExtentScrollController(initialItem: 0);

    super.initState();
  }

  List<String> buttonChoices = [
    "Kein Button",
    "Event-Button",
    "Coupon-Button"
  ];

  List<String> buttonColors = [
    "Türkis",
    "Gold"
  ];

  AppBar _buildAppBar(){
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: customStyleClass.backgroundColorMain,
      surfaceTintColor: customStyleClass.backgroundColorMain,
      title:
      SizedBox(
        width: screenWidth,
        child: Stack(
          children: [

            // Icon: Back
            Container(
              alignment: Alignment.centerLeft,
              height: 50,
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(
                  Icons.arrow_back_ios,
                  color: Colors.white,
                  // size: 20,
                ),
              ),
            ),

            // Text: Headline
            SizedBox(
              width: screenWidth,
              height: 50,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Neuen Info-Screen hochladen",
                    textAlign: TextAlign.center,
                    style: customStyleClass.getFontStyle2Bold(),
                  )
                ],
              ),
            )

          ],
        ),
      ),
    );
  }

  Widget _buildMainView(){
    return Container(
      width: screenWidth,
      height: screenHeight,
      child: Column(

        children: [

          SizedBox(
            height: screenHeight*0.05,
          ),

          Container(
            width: screenWidth*0.51,
            height: screenHeight*0.5,
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.grey,
                width: 1
              )
            ),
            child: file == null ?
              Center(
                child: InkWell(
                  child: Icon(
                    Icons.add,
                    color: customStyleClass.primeColor,
                  ),
                  onTap: () => clickEventChooseContent(),
                ),
              ):Image.file(file!),
          ),

          if(file != null)
          Container(
            padding: const EdgeInsets.symmetric(
              vertical: 20
            ),
            width: screenWidth*0.5,
            child: CupertinoPicker(
                scrollController: _buttonChoiceController,
                itemExtent: 50,
                onSelectedItemChanged: (int index){
                  setState(() {
                    buttonChoice = index;
                  });
                },
                children: buttonChoices.map((item) => Center(
                  child: Text(
                    item,
                    style: customStyleClass.getFontStyle3(),
                  ),
                )).toList(),
            ),
          ),

          if(buttonChoice != 0)
            SizedBox(
              width: screenWidth*0.5,
              child: CupertinoPicker(
                scrollController: _buttonColorController,
                itemExtent: 50,
                onSelectedItemChanged: (int index){
                  setState(() {
                    buttonColor = index;
                  });
                },
                children: buttonColors.map((item) => Center(
                  child: Text(
                    item,
                    style: customStyleClass.getFontStyle3(),
                  ),
                )).toList(),
              ),
            ),

          if(file != null)
            Container(
              padding: const EdgeInsets.only(
                top: 40
              ),
              width: screenWidth,
              alignment: Alignment.bottomRight,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [

                  isUploading ?
                      CircularProgressIndicator(
                        color: customStyleClass.primeColor,
                      ) :
                  InkWell(
                    child: Row(
                      children: [
                        Text(
                          "Abschicken",
                          style: customStyleClass.getFontStyle3BoldPrimeColor(),
                        ),
                        Icon(
                          Icons.arrow_forward_outlined,
                          color: customStyleClass.primeColor,
                        )
                      ],
                    ),
                    onTap: () => uploadInfoScreen(),
                  )

                ],
              ),
            )

        ],

      ),
    );
  }


  void uploadInfoScreen() async{
    setState(() {
      isUploading = true;
    });

    var uuid = const Uuid();
    var uuidV4 = uuid.v4();

    String contentFileName = "$uuidV4.$fileExtension";

    _supabaseService.insertInfoScreen(
     file, contentFileName
    ).then((response) async{

      if(response == 0){
        await _supabaseService.updateInfoScreen(
            contentFileName, buttonChoice, buttonColor
        );
        Navigator.pop(context);
      }else{
        Navigator.pop(context);
      }
    });
  }

  void clickEventChooseContent() async{

    try{

      FilePickerResult? result = await FilePicker.platform.pickFiles(
        withData: true,
        allowMultiple: false,
        type: FileType.media,
      );
      if (result != null) {

        file = File(result.files.single.path!);
        PlatformFile pFile = result.files.first;
        String mimeStr = lookupMimeType(file!.path)!;
        var fileType = mimeStr.split("/");
        fileExtension = pFile.extension.toString();

        if(!fileType.contains('image')){
          file = null;
          showOnlyImagesDialog();
        }
        setState(() {

        });
      }

    }catch(e){
      // _supabaseService.createErrorLog(
      //     "Error in ClubNewEventView. Fct: clickEventChooseContent. Error: ${e.toString()}"
      // );
    }

  }


  void showOnlyImagesDialog(){
    showDialog(context: context,
        builder: (BuildContext context){
          return TitleAndContentDialog(
              titleToDisplay: "Fehlerhaftes Format",
              contentToDisplay: "Bitte lade ein Bild hoch.");
        });
  }


  @override
  Widget build(BuildContext context) {

    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;

    customStyleClass = CustomStyleClass(context: context);

    return Scaffold(

      extendBody: true,
      extendBodyBehindAppBar: false,
      resizeToAvoidBottomInset: false,

      appBar: _buildAppBar() ,
      body: _buildMainView(),
    );
  }
}
