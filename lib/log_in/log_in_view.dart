import 'dart:io';
import 'dart:ui';
import 'package:club_me/models/club.dart';
import 'package:club_me/models/hive_models/0_club_me_user_data.dart';
import 'package:club_me/models/parser/club_me_club_parser.dart';
import 'package:club_me/shared/custom_text_style.dart';
import 'package:crop_image/crop_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:go_router/go_router.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../provider/state_provider.dart';
import '../provider/user_data_provider.dart';
import '../services/hive_service.dart';
import '../services/supabase_service.dart';
import 'package:geolocator/geolocator.dart';

import 'package:image/image.dart' as img;

import '../shared/logger.util.dart';

class LogInView extends StatefulWidget {
  const LogInView({Key? key}) : super(key: key);

  @override
  State<LogInView> createState() => _LogInViewState();
}

class _LogInViewState extends State<LogInView> {

  String headLine = "Willkommen bei ClubMe!";

  final log = getLogger();

  late StateProvider stateProvider;
  late UserDataProvider userDataProvider;
  late CustomStyleClass customStyleClass;
  late double screenHeight, screenWidth;

  final HiveService _hiveService = HiveService();
  final SupabaseService _supabaseService = SupabaseService();

  List<String> clubIds = [
    "e6c9bfb4-a8a0-490c-be9e-1cad0c29d864",
    "55c3f95b-cb67-4e38-bce7-d6e4ab45e607",
    "cf49bc92-909b-41a8-8ec5-2013cde1ef0a",
    "42db0a81-ef59-4972-9a61-cc29b20084f2",
    "2733b675-d574-4580-90c8-5fe371007b70",
    "0e69bc02-bb59-4031-82a6-ec6abb1d5494",
    "a6186222-d5ba-460b-8e40-03bfa58286f0"
  ];
  List<String> clubNames = [
    "LKA", "Climax", "Boa", "7grad", "HiLife", "Kiki", "Vivally"
  ];

  String selectedClubId = "e6c9bfb4-a8a0-490c-be9e-1cad0c29d864";

  bool isLoading = false;
  bool hasUserData = false;

  bool test = false;

  Color primeColorDark = Colors.teal;
  Color primeColor = Colors.tealAccent;

  bool showCrop = false;

  late Image imageToCrop;
  late CropController cropController;

  @override
  void initState() {
    super.initState();
    _determinePosition().then((value) => setPositionLocallyAndInSupabase(value));
    fetchUserDataFromHive();
  }

  @override
  void dispose() {
    // Remove a callback to receive data sent from the TaskHandler.
    // FlutterForegroundTask.removeTaskDataCallback();
    super.dispose();
  }

  void fetchClubAndProceed() async{
    isLoading = true;
    try{
      var _list = await _supabaseService.getSpecificClub(selectedClubId);
      if(_list != null){

        ClubMeClub clubMeClub = parseClubMeClub(_list[0]);
        userDataProvider.setUserClub(clubMeClub);
        userDataProvider.setUserData(
            ClubMeUserData(
              firstName: "...",
              lastName: "...",
              birthDate: DateTime.now(),
              eMail: "test@test.de",
              gender: 0,
              userId: clubMeClub.getClubId(),
              profileType: 1,
              lastTimeLoggedIn: DateTime.now()
            )
        );
      }
      context.go('/club_events');
    }catch(e){
      setState(() {
        isLoading = false;
      });
      log.d("Error in fetchClubAndProceed: $e");
      _supabaseService.createErrorLog(e.toString());
    }
  }

  Future<Position> _determinePosition() async {

    // Check if location services are enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {

      log.d("Error in _determinePosition: Location services are disabled.");

      // Location services are not enabled return an error message
      return Future.error('Location services are disabled.');

    }

    // Check location permissions
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {

        log.d("Error in _determinePosition: Location permissions are denied.");

        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      log.d("Error in _determinePosition: Location permissions are permanently denied, we cannot request permissions.");
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    log.d("_determinePosition: No error. Returning Location.");

    // If permissions are granted, return the current location
    return await Geolocator.getCurrentPosition();
  }

  void setPositionLocallyAndInSupabase(Position value){

    final userDataProvider = Provider.of<UserDataProvider>(context, listen: false);

    userDataProvider.setUserCoordinates(value);
    _supabaseService.saveUsersGeoLocation(userDataProvider.getUserDataId(), value.latitude, value.longitude);
  }

  Future<void> fetchUserDataFromHive() async{

    isLoading = true;

    try{
      await _hiveService.getUserData().then((userData) async {

        if(userData.isEmpty){
          log.d("fetchUserDataFromHive: isEmpty");
          setState(() {
            isLoading = false;
            hasUserData = false;
          });

        }else{
          log.d("fetchUserDataFromHive: isNotEmpty");
          userDataProvider.setUserData(userData[0]);
          if(!stateProvider.activeLogOut){
            if(userData[0].getProfileType() == 0){
              context.go("/user_events");
            }else{
              context.go("/club_events");
            }
          }else{
            isLoading = false;
          }
        }
      });
    }catch(e){
      log.d("Error in fetchUserDataFromHive: $e");
    }
  }

  void clickOnLogIn(){
    stateProvider.activeLogOut = false;
    if(userDataProvider.getUserData().getProfileType() == 0){
      context.go("/user_events");
    }else{
      context.go("/club_events");
    }
  }


  void test2() async{
    FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: false
    );
    if (result != null) {
    setState(() {
      var file = File(result.files.single.path!);
      test4(file);
    });
  }
  }

  void test3(File imageFile) async{

    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: imageFile.path,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Cropper',
          toolbarColor: Colors.teal,
          toolbarWidgetColor: Colors.white,
          aspectRatioPresets: [
            // CropAspectRatioPreset.original,
            // CropAspectRatioPreset.square,
            // CropAspectRatioPresetCustom(),
          ],
        ),
        IOSUiSettings(
          title: 'Cropper',
          aspectRatioPresets: [
            // CropAspectRatioPreset.original,
            // CropAspectRatioPreset.square,
            // CropAspectRatioPresetCustom(), // IMPORTANT: iOS supports only one custom aspect ratio in preset list
          ],
        ),
        WebUiSettings(
          context: context,
        ),
      ],
    );
  }

  void test4(File image){

    cropController = CropController(
      aspectRatio: 5.0 / 2.0,
      defaultCrop: Rect.fromLTRB(0.05, 0.05, 0.95, 0.95),
    );

    imageToCrop = Image.file(image);

    setState(() {
      showCrop = true;
    });
  }

  void uploadCroppedImage() async{

    var bitmap = await cropController.croppedBitmap();

    var data = await bitmap.toByteData(format: ImageByteFormat.png);
    // var bytes = data!.buffer.asUint8List();

    if(data != null){
      File newFile = await writeToFile(data);

      img.Image? decodedImage = img.decodeImage(newFile.readAsBytesSync());

      List<int> compressedBytes = img.encodeJpg(decodedImage!, quality: 55);

      File compressedFile = File(newFile.path.replaceFirst('.jpg', '_compressed.jpg'));

      compressedFile.writeAsBytesSync(compressedBytes);

      var uuid = const Uuid();
      var uuidV4 = uuid.v4();

      // _supabaseService.uploadFrontpageBannerImage("$uuidV4.png", compressedFile);
    }
  }

  Future<XFile?> testCompressAndGetFile(File file, String targetPath) async {
    return await FlutterImageCompress.compressAndGetFile(
      file.absolute.path, targetPath,
      quality: 88,
      rotate: 180,
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

    stateProvider = Provider.of<StateProvider>(context);
    userDataProvider = Provider.of<UserDataProvider>(context);

    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;

    customStyleClass = CustomStyleClass(context: context);

    return Scaffold(
      appBar: AppBar(
          backgroundColor: customStyleClass.backgroundColorMain,
          surfaceTintColor: customStyleClass.backgroundColorMain,
          title: SizedBox(
            width: screenWidth,
            child: Text(
              headLine,
              textAlign: TextAlign.center,
              style: customStyleClass.getFontStyleHeadline1Bold(),
            ),
          )
      ),

      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          isLoading ?
          Center(
            child: CircularProgressIndicator(
              color: customStyleClass.primeColor,
            ),
          ):
          showCrop ?
          Container(
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

                InkWell(
                  child: Text(
                    "Weiter",
                    style: customStyleClass.getFontStyle3(),
                  ),
                  onTap: () => uploadCroppedImage(),
                )

              ],
            ),
          ):
          Container(
            color: customStyleClass.backgroundColorMain,
            width: screenWidth,
            height: screenHeight*0.85,
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  children: [

                    // normaler user
                    Padding(
                      padding: EdgeInsets.only(
                        top:screenHeight*0.015,
                        right: 7,
                        // bottom: 7,
                      ),
                      child: Align(
                        child: GestureDetector(
                          child: Container(
                              width: screenWidth*0.8,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                    colors: [
                                      primeColorDark,
                                      primeColor
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    stops: const [0.2, 0.9]
                                ),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black54,
                                    spreadRadius: 1,
                                    blurRadius: 7,
                                    offset: Offset(3, 3),
                                  ),
                                ],
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(10)
                                ),
                              ),
                              padding: const EdgeInsets.all(18),
                              child: Center(
                                child: Text(
                                  "Starte als normaler User",
                                  style: customStyleClass.getFontStyle3Bold(),
                                ),
                              )
                          ),
                          onTap: (){
                            stateProvider.setClubUiActive(false);
                            context.go("/user_events");
                          },
                        ),
                      ),
                    ),

                    // Spacer
                    SizedBox(
                      height: screenHeight*0.02,
                    ),

                    // Cupertino picker clubs
                    SizedBox(
                      width: screenWidth*0.8,
                      child: Row(
                        children: [
                          GestureDetector(
                            child: Container(
                                width: screenWidth*0.5,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                      colors: [
                                        primeColorDark,
                                        primeColor,
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      stops: const [0.2, 0.9]
                                  ),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black54,
                                      spreadRadius: 1,
                                      blurRadius: 7,
                                      offset: Offset(3, 3),
                                    ),
                                  ],
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(10)
                                  ),
                                ),
                                padding: const EdgeInsets.all(18),
                                child: Center(
                                  child: Text(
                                      "Starte als Club",
                                      style: customStyleClass.getFontStyle3Bold()
                                  ),
                                )
                            ),
                            onTap: (){
                              stateProvider.setClubUiActive(true);
                              fetchClubAndProceed();
                            },
                          ),
                          SizedBox(
                            width: screenWidth*0.3,
                            child: CupertinoPicker(
                                itemExtent: 50,
                                onSelectedItemChanged: (int index){
                                  setState(() {
                                    selectedClubId = clubIds[index];
                                  });
                                },
                                children: List<Widget>.generate(
                                    clubNames.length, (index){
                                  return Center(
                                    child: Text(
                                      clubNames[index].toString(),
                                      style: customStyleClass.getFontStyle2(),
                                    ),
                                  );
                                })
                            ),
                          )
                        ],
                      ),
                    ),

                    // Spacer
                    SizedBox(
                      height: screenHeight*0.02,
                    ),

                    // Register
                    GestureDetector(
                      child: Container(
                          width: screenWidth*0.8,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                                colors: [
                                  primeColorDark,
                                  primeColor,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                stops: const [0.2, 0.9]
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black54,
                                spreadRadius: 1,
                                blurRadius: 7,
                                offset: Offset(3, 3),
                              ),
                            ],
                            borderRadius: const BorderRadius.all(
                                Radius.circular(10)
                            ),
                          ),
                          padding: const EdgeInsets.all(18),
                          child: Center(
                            child: Text(
                                "Registriere dich",
                                style: customStyleClass.getFontStyle3Bold()
                            ),
                          )
                      ),
                      onTap: (){
                        context.push("/register");
                      },
                    ),

                    // Spacer
                    stateProvider.activeLogOut ? SizedBox(
                      height: screenHeight*0.02,
                    ): Container(),

                    stateProvider.activeLogOut ?
                    GestureDetector(
                      child: Container(
                          width: screenWidth*0.8,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                                colors: [
                                  primeColorDark,
                                  primeColor,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                stops: const [0.2, 0.9]
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black54,
                                spreadRadius: 1,
                                blurRadius: 7,
                                offset: Offset(3, 3),
                              ),
                            ],
                            borderRadius: const BorderRadius.all(
                                Radius.circular(10)
                            ),
                          ),
                          padding: const EdgeInsets.all(18),
                          child: Center(
                            child: Text(
                                "Log dich ein!",
                                style: customStyleClass.getFontStyle5Bold()
                            ),
                          )
                      ),
                      onTap: () => clickOnLogIn(),
                    ):Container(),

                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CropAspectRatioPresetCustom implements CropAspectRatioPresetData {
  @override
  (int, int)? get data => (2, 1);

  @override
  String get name => '2x3 (customized)';
}


