import 'dart:io';
import 'package:club_me/models/front_page_images.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gradient_icon/gradient_icon.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../../provider/state_provider.dart';
import '../../../provider/user_data_provider.dart';
import '../../../services/supabase_service.dart';
import '../../../shared/custom_bottom_navigation_bar_clubs.dart';
import '../../../shared/custom_text_style.dart';

class UpdatePhotosAndVideosView extends StatefulWidget {
  const UpdatePhotosAndVideosView({super.key});

  @override
  State<UpdatePhotosAndVideosView> createState() => _UpdatePhotosAndVideosViewState();
}

class _UpdatePhotosAndVideosViewState extends State<UpdatePhotosAndVideosView> {

  String headLine = "Bilder hochladen";
  late double screenHeight, screenWidth;

  var log = Logger();

  late StateProvider stateProvider;
  late UserDataProvider userDataProvider;
  late CustomStyleClass customStyleClass;

  final SupabaseService _supabaseService = SupabaseService();

  List<String> alreadyExistingImages = [];

  String fileExtension = "";

  bool isLoading = false;

  File? file;

  // BUILD
  AppBar _buildAppBar(){
    return AppBar(
      backgroundColor: customStyleClass.backgroundColorMain,
      surfaceTintColor: customStyleClass.backgroundColorMain,
      title: SizedBox(
        width: screenWidth,
        child: Stack(
          children: [
            Container(
                alignment: Alignment.bottomCenter,
                height: 50,
                width: screenWidth,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(headLine,
                        textAlign: TextAlign.center,
                        style: customStyleClass.getFontStyleHeadline1Bold()
                    ),
                  ],
                )
            ),

            Container(
                width: screenWidth,
                alignment: Alignment.centerLeft,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(
                          Icons.arrow_back_ios_new_outlined,
                        color: Colors.white,
                      ),
                      onPressed: (){
                        context.go('/club_frontpage');
                      },
                    ),
                  ],
                )
            ),

          ],
        ),
      ),
    );
  }

  Widget _buildMainColumn(){
    return Column(
        children: [

          // Spacer
          SizedBox(
            height: screenHeight*0.02,
          ),

          // List of images
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: alreadyExistingImages.length,
            itemBuilder: (context, index){
              return buildListTile(alreadyExistingImages[index]);
            },
          ),

          alreadyExistingImages.length < 6 ? SizedBox(
            width: screenWidth*0.8,
            child: GestureDetector(
                child: Container(
                    decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        // color: Color(0xff11181f)
                    ),
                    child: const Padding(
                      padding: EdgeInsets.only(bottom: 15),
                      child: Center(
                        child: GradientIcon(
                          icon: Icons.add,
                          gradient: LinearGradient(
                              colors: [Colors.teal, Colors.tealAccent],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              stops: [0.5, 0.55]
                          ),
                          size: 40,
                        ),
                      ),
                    )
                ),
                onTap: () => clickedOnChooseContent()
            ),
          ):Container(),

          SizedBox(
            height: screenHeight*0.4,
          )

        ]
    );
  }

  Widget buildListTile(String imageId){
    return Card(
      color: Colors.grey[900],
      child: Row(
        children: [
          SizedBox(
            width: 100,
            height: 100,
            child: Image(
              width: 100,
              height: 100,
              image: FileImage(
                  File("${stateProvider.appDocumentsDir.path}/$imageId")),
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 5,),
          Expanded(
              child: Text(
                imageId,
                style: customStyleClass.getFontStyle3(),
              )
          ),
          IconButton(
              onPressed: () => askIfWantToDeleteFrontPageImage(imageId),
              icon: Icon(
                Icons.delete,
                color: customStyleClass.primeColor,
              )
          )
        ],
      ),
    );
  }

  void askIfWantToDeleteFrontPageImage(String imageId){
    showDialog(context: context, builder: (BuildContext context){
      return AlertDialog(
        title: const Text("Foto löschen"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            // Question text
            const Text(
              "Möchtest du dieses Foto wirklich löschen?",
              textAlign: TextAlign.left,
            ),

            // Spacer
            SizedBox(
              height: screenHeight*0.03,
            ),

            // "New event" button
            Container(
                width: screenWidth*0.9,
                // color: Colors.red,
                alignment: Alignment.bottomRight,
                child: GestureDetector(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        vertical: screenHeight*0.015,
                        horizontal: screenWidth*0.03
                    ),
                    decoration: const BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.all(Radius.circular(10))
                    ),
                    child: isLoading ?
                      const CircularProgressIndicator() :
                    Text(
                      "Löschen",
                      textAlign: TextAlign.center,
                      style: customStyleClass.getFontStyle4BoldPrimeColor(),
                    ),
                  ),
                  onTap: () => deleteFrontPageImage(imageId),
                )
            ),

          ],
        ),
      );
    });
  }

  void deleteFrontPageImage(String imageId) async{

    setState(() {
      isLoading = true;
    });

    FrontPageGalleryImages newFrontPageGalleryImages = userDataProvider.getUserClub().getFrontPageGalleryImages();
    newFrontPageGalleryImages.images!.removeWhere((entry) => entry.id == imageId);

    try{
      _supabaseService.deleteFrontPageFromStorage(imageId).then((response) {
        if(response == 0){
          _supabaseService.updateFrontPageGalleryImageInClub(userDataProvider.getUserClubId(), newFrontPageGalleryImages).then((result){
            if(result == 0){
              alreadyExistingImages.removeWhere((value) => value == imageId);
              Navigator.of(context).pop();
            }else{
              Navigator.of(context).pop();
            }
            setState(() {
              isLoading = false;
            });
          });
        }else{
          print("Something went wrong");
        }
      });
    }catch(e){
      print("Error in deleteFrontPageImage $e");
    }
  }


  void clickedOnChooseContent() async{

    FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.image
    );
    if (result != null) {
      file = File(result.files.single.path!);
      PlatformFile pFile = result.files.first;
      fileExtension = pFile.extension.toString();
      dialogToConfirmUpload();
    }
  }

  void dialogToConfirmUpload(){
    showDialog(context: context, builder: (BuildContext context){
      return AlertDialog(
        title: const Text("Neues Bild hochladen"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            // Question text
            const Text(
              "Möchtest du dieses Bild bochladen?",
              textAlign: TextAlign.left,
            ),

            // Spacer
            SizedBox(
              height: screenHeight*0.03,
            ),

            Image(
              width: 100,
              height: 100,
              image: FileImage(
                  file!,
              )
            ),

            // Spacer
            SizedBox(
              height: screenHeight*0.03,
            ),

            // "New event" button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [

                  // YES
                  GestureDetector(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          vertical: screenHeight*0.015,
                          horizontal: screenWidth*0.03
                      ),
                      decoration: const BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.all(Radius.circular(10))
                      ),
                      child: Text(
                        "Ja!",
                        textAlign: TextAlign.center,
                        style: customStyleClass.getFontStyle4BoldPrimeColor(),
                      ),
                    ),
                    onTap: () => uploadAndInsertImage().then((result){
                      if(result == 0){
                        if(context.mounted){
                          Navigator.pop(context);
                        }
                      }else{
                        if(context.mounted){
                          Navigator.pop(context);
                        }
                      }
                    }),
                  ),

                  // NO
                  GestureDetector(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          vertical: screenHeight*0.015,
                          horizontal: screenWidth*0.03
                      ),
                      decoration: const BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.all(Radius.circular(10))
                      ),
                      child: Text(
                        "Nein!",
                        textAlign: TextAlign.center,
                        style: customStyleClass.getFontStyle4BoldPrimeColor(),
                      ),
                    ),
                    onTap: () => Navigator.pop(context),
                  )

                ],
            ),
          ],
        ),
      );
    });
  }

  Future<int> uploadAndInsertImage() async{

    String newUuid = "${const Uuid().v4()}.$fileExtension";

    FrontPageGalleryImages newFrontPageImages = userDataProvider.getUserClub().getFrontPageGalleryImages();
    newFrontPageImages.images!.add(Images(id: newUuid));


    return _supabaseService.uploadFrontPageGalleryImage(
        file,
        newUuid,
        userDataProvider.getUserClubId(),
        newFrontPageImages
    ).then((result){
      if(result == 0){
        saveImageLocally(newUuid, file);
      }else{
        print("Error");
      }
      return result;
    });
  }

  void saveImageLocally(String fileName, var imageFile) async{

    final String dirPath = stateProvider.appDocumentsDir.path;
    final filePath = '$dirPath/$fileName';

    await file!.copy(filePath).then((onValue){
      setState(() {
        alreadyExistingImages.add(fileName);
        file = null;
        log.d("saveImageLocally: Finished successfully. Path: $dirPath/$fileName");
      });
    });
  }

  @override
  Widget build(BuildContext context) {

    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;

    customStyleClass = CustomStyleClass(context: context);
    stateProvider = Provider.of<StateProvider>(context);
    userDataProvider = Provider.of<UserDataProvider>(context);

    for(var element in userDataProvider.getUserClub().getFrontPageGalleryImages().images!){
      if(!alreadyExistingImages.contains(element.id!)){
        alreadyExistingImages.add(element.id!);
      }
    }

    return Scaffold(

        extendBody: true,
        resizeToAvoidBottomInset: true,

        bottomNavigationBar: CustomBottomNavigationBarClubs(),
        appBar: _buildAppBar(),
        body: Container(
            width: screenWidth,
            height: screenHeight,
            color: customStyleClass.backgroundColorMain,

            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: _buildMainColumn(),
            )
        )
    );
  }
}
