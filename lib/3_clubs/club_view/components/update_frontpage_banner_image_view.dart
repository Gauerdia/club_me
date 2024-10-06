import 'dart:io';
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:crop_image/crop_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../../provider/state_provider.dart';
import '../../../provider/user_data_provider.dart';
import '../../../services/supabase_service.dart';
import '../../../shared/custom_bottom_navigation_bar_clubs.dart';
import '../../../shared/custom_text_style.dart';

import 'package:image/image.dart' as img;



import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';






class UpdateFrontpageBannerImageView extends StatefulWidget {
  const UpdateFrontpageBannerImageView({super.key});

  @override
  State<UpdateFrontpageBannerImageView> createState() => _UpdateFrontpageBannerImageViewState();
}

class _UpdateFrontpageBannerImageViewState extends State<UpdateFrontpageBannerImageView> {

  String headline = "Banner";

  var log = Logger();

  late StateProvider stateProvider;
  late UserDataProvider userDataProvider;
  late CustomStyleClass customStyleClass;
  late double screenHeight, screenWidth;

  final SupabaseService _supabaseService = SupabaseService();

  bool showCropView = false;

  late CropController cropController;
  late Image imageToCrop;
  bool isLoading = false;

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
                    Text(headline,
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


  processUpload() async{

    setState(() {
      isLoading = true;
    });

    // upload file
    // save locally
    // update club online
    // update club locally

    // Get data
    var bitmap = await cropController.croppedBitmap();
    var data = await bitmap.toByteData(format: ImageByteFormat.png);

    if(data != null){

      // convert format
      File newFile = await writeToFile(data);

      // compress image
      img.Image? decodedImage = img.decodeImage(newFile.readAsBytesSync());
      List<int> compressedBytes = img.encodeJpg(decodedImage!, quality: 55);


      File compressedFile = File(newFile.path.replaceFirst('.jpg', '_compressed.jpg'));

      compressedFile.writeAsBytesSync(compressedBytes);

      var uuid = const Uuid();
      var uuidV4 = uuid.v4();

      _supabaseService.uploadFrontpageBannerImage(userDataProvider.getUserClubId(),"$uuidV4.png", compressedFile).then(
          (result) => processUploadResult(result, "$uuidV4.png", compressedFile));
    }
  }

  void processUploadResult(int result, String fileName, File file) async{

    StateProvider stateProvider = Provider.of<StateProvider>(context, listen: false);
    final String dirPath = stateProvider.appDocumentsDir.path;

    Uint8List bytes = file.readAsBytesSync();

    if(result == 0){
      await File("$dirPath/$fileName").writeAsBytes(bytes).then((onValue){
        log.d("UpdateFrontpageBannerImageView, Fct: processUploadResult: Finished successfully. Path: $dirPath/$fileName");
        userDataProvider.getUserClub().setFrontpageBannerFileName(fileName);
        context.go("/club_frontpage");
      });
    }else{
      _supabaseService.createErrorLog(
        "UpdateFrontpageBannerImageView. Fct: processUploadResult. Error: result code 1"
      );
    }
  }

  void chooseLocalFile() async{
    FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
      type: FileType.image
    );
    if (result != null) {
      setState(() {
        var file = File(result.files.single.path!);
        setImageAndShowCropTool(file);
      });
    }
  }

  void setImageAndShowCropTool(File image){
    cropController = CropController(
      aspectRatio: 5.0 / 2.0,
      defaultCrop: const Rect.fromLTRB(0.05, 0.05, 0.95, 0.95),
    );

    imageToCrop = Image.file(image);

    setState(() {
      showCropView = true;
    });
  }

  Widget _buildCropView(){

    // cropController = CropController();

    return SizedBox(
      child: Column(
        children: [

          CropImage(
            /// Only needed if you expect to make use of its functionality like setting initial values of
            /// [aspectRatio] and [defaultCrop].
              controller: cropController,
              /// The image to be cropped. Use [Image.file] or [Image.network] or any other [Image].
              image: imageToCrop,
              /// The crop grid color of the outer lines. Defaults to 70% white.
              gridColor: Colors.white,
              /// The crop grid color of the inner lines. Defaults to [gridColor].
              gridInnerColor: Colors.white,
              /// The crop grid color of the corner lines. Defaults to [gridColor].
              gridCornerColor: Colors.white,
              /// The size of the corner of the crop grid. Defaults to 25.
              gridCornerSize: 50,
              /// Whether to display the corners. Defaults to true.
              showCorners: true,
              /// The width of the crop grid thin lines. Defaults to 2.
              gridThinWidth: 3,
              /// The width of the crop grid thick lines. Defaults to 5.
              gridThickWidth: 6,
              /// The crop grid scrim (outside area overlay) color. Defaults to 54% black.
              scrimColor: Colors.grey.withOpacity(0.5),
              /// True: Always show third lines of the crop grid.
              /// False: third lines are only displayed while the user manipulates the grid (default).
              alwaysShowThirdLines: true,
              /// Event called when the user changes the crop rectangle.
              /// The passed [Rect] is normalized between 0 and 1.
              onCrop: (rect) => print(rect),
              /// The minimum pixel size the crop rectangle can be shrunk to. Defaults to 100.
              minimumImageSize: 50,
              /// The maximum pixel size the crop rectangle can be grown to. Defaults to infinity.
              /// You can constrain the crop rectangle to a fixed size by setting
              /// both [minimumImageSize] and [maximumImageSize] to the same value (the width) and using
              /// the [aspectRatio] of the controller to force the other dimension (width / height).
              /// Doing so disables the display of the corners.
              maximumImageSize: 2000
          ),

          SizedBox(
            height: screenHeight*0.1,
            child: isLoading ?
              Center(child: CircularProgressIndicator(
                color: customStyleClass.primeColor,
              )): InkWell(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
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
              onTap: () => processUpload(),
            ),
          )

        ],
      )
    );
  }

  Widget _buildMainColumn(){
    return Column(
        children: [

          // Spacer
          SizedBox(
            height: screenHeight*0.02,
          ),

          showCropView ?
              _buildCropView() :
          SizedBox(
              width: screenWidth*0.9,
              height: screenHeight*0.6,
              child: Center(
                child: InkWell(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 15
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: customStyleClass.primeColor
                      )
                    ),
                    width: screenWidth*0.5,
                    child: Text(
                      "Bitte wähle ein Foto von deinem Smartphone aus",
                      textAlign: TextAlign.center,
                      style: customStyleClass.getFontStyle3BoldPrimeColor(),
                    ),
                  ),
                  onTap: () => chooseLocalFile(),
                ),
              )
          )

        ]
    );
  }


  Future<File> writeToFile(ByteData data) async {
    final buffer = data.buffer;
    Directory tempDir = await getTemporaryDirectory();
    String tempPath = tempDir.path;
    var filePath = tempPath + '/file_01.tmp'; // file_01.tmp is dump file, can be anything
    return new File(filePath).writeAsBytes(
        buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;

    customStyleClass = CustomStyleClass(context: context);
    stateProvider = Provider.of<StateProvider>(context);
    userDataProvider = Provider.of<UserDataProvider>(context);

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
