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

  bool showClubList = false;

  Color primeColorDark = Colors.teal;
  Color primeColor = Colors.tealAccent;

  bool showCrop = false;

  late Image imageToCrop;
  late CropController cropController;

  @override
  void initState() {
    super.initState();

    userDataProvider = Provider.of<UserDataProvider>(context, listen: false);

    _determinePosition().then((value) => setPositionLocallyAndInSupabase(value));
    fetchUserDataFromHive();
  }

  @override
  void dispose() {
    // Remove a callback to receive data sent from the TaskHandler.
    // FlutterForegroundTask.removeTaskDataCallback();
    super.dispose();
  }



  // DB
  void fetchClubAndProceed() async{

    setState(() {
      isLoading = true;
    });

    try{
      var _list = await _supabaseService.getSpecificClub(selectedClubId);
      if(_list.isNotEmpty){

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
                lastTimeLoggedIn: null,
                userProfileAsClub: false,
                clubId: clubMeClub.getClubId()
            )
        );
      }
      context.go('/club_events');
    }catch(e){
      setState(() {
        isLoading = false;
      });
      log.d("Error in LogInView. Fct: fetchClubAndProceed: $e");
      _supabaseService.createErrorLog("Error in LogInView. Fct: fetchClubAndProceed: $e");
    }
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

  // LOCATION
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

    userDataProvider.setUserCoordinates(value);
    _supabaseService.saveUsersGeoLocation(userDataProvider.getUserDataId(), value.latitude, value.longitude);
  }


  void clickEventChooseClub(){
    stateProvider.setClubUiActive(true);
    fetchClubAndProceed();
  }


  void clickOnLogIn(){
    stateProvider.activeLogOut = false;
    if(userDataProvider.getUserData().getProfileType() == 0){
      context.go("/user_events");
    }else{
      context.go("/club_events");
    }
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
            child: Stack(
              children: [

                // TEXT
                Container(
                  // color: Colors.red,
                  height: 50,
                  width: screenWidth,
                  alignment: Alignment.centerRight,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Row(
                        children: [
                          Text(
                              headLine,
                              textAlign: TextAlign.center,
                              style: customStyleClass.getFontStyleHeadline1Bold()
                          ),
                        ],
                      )
                    ],
                  ),
                ),

                Container(
                  height: 50,
                  width: screenWidth,
                  alignment: Alignment.centerLeft,
                  child: InkWell(
                    child: const Icon(
                      Icons.arrow_back_ios,
                      color: Colors.white,
                    ),
                    onTap: (){
                      if(showClubList){
                        setState(() {
                          showClubList = false;
                        });
                      }else{
                        context.go("/register");
                      }
                    },
                  ),
                ),


              ],
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
          ): showClubList ?
          Container(
              color: customStyleClass.backgroundColorMain,
              width: screenWidth,
              height: screenHeight*0.85,
              child:FutureBuilder(
                  future: _supabaseService.getAllClubs(),
                  builder: (context, snapshot){
                    if(!snapshot.hasData){
                      return SizedBox(
                        width: screenWidth,
                        height: screenHeight,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: customStyleClass.primeColor,
                          ),
                        ),
                      );
                    }else{

                      List<TempClubData> clubData = [];

                      for(var element in snapshot.data!){
                        ClubMeClub currentClub = parseClubMeClub(element);

                        clubData.add(
                            TempClubData(
                              clubName: currentClub.getClubName(),
                              clubId: currentClub.getClubId()
                            )
                        );
                      }

                      clubData.sort((a,b) => a.clubName.compareTo(b.clubName));

                      return Column(
                          children: [

                            Text(
                                "Wähle einen Club",
                            style: customStyleClass.getFontStyle4BoldPrimeColor(),
                            ),

                        SizedBox(
                          width: screenWidth,
                          height: screenHeight*0.82,
                          child: ListView.builder(
                            shrinkWrap: true,
                              itemCount: clubData.length,
                              itemBuilder: (context, index){

                                return InkWell(
                                  child: ListTile(
                                    trailing: Icon(
                                      Icons.arrow_forward_outlined,
                                      color: customStyleClass.primeColor,
                                    ),
                                    title: Text(
                                      clubData[index].clubName,
                                      style: customStyleClass.getFontStyle3(),
                                    ),
                                  ),
                                  onTap: (){
                                    selectedClubId = clubData[index].clubId;
                                    clickEventChooseClub();
                                  },
                                );

                              }
                          ),
                        ),

                          ],
                      );
                    }
                  }
              )
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
                                "Starte als Club",
                                style: customStyleClass.getFontStyle3Bold()
                            ),
                          )
                      ),
                      onTap: (){
                        setState(() {
                          showClubList = true;
                        });
                      },
                    ),

                    // Cupertino picker clubs
                    // SizedBox(
                    //   width: screenWidth*0.8,
                    //   child: Row(
                    //     children: [
                    //       GestureDetector(
                    //         child: Container(
                    //             width: screenWidth*0.5,
                    //             decoration: BoxDecoration(
                    //               gradient: LinearGradient(
                    //                   colors: [
                    //                     primeColorDark,
                    //                     primeColor,
                    //                   ],
                    //                   begin: Alignment.topLeft,
                    //                   end: Alignment.bottomRight,
                    //                   stops: const [0.2, 0.9]
                    //               ),
                    //               boxShadow: const [
                    //                 BoxShadow(
                    //                   color: Colors.black54,
                    //                   spreadRadius: 1,
                    //                   blurRadius: 7,
                    //                   offset: Offset(3, 3),
                    //                 ),
                    //               ],
                    //               borderRadius: const BorderRadius.all(
                    //                   Radius.circular(10)
                    //               ),
                    //             ),
                    //             padding: const EdgeInsets.all(18),
                    //             child: Center(
                    //               child: Text(
                    //                   "Starte als Club",
                    //                   style: customStyleClass.getFontStyle3Bold()
                    //               ),
                    //             )
                    //         ),
                    //         onTap: (){
                    //           stateProvider.setClubUiActive(true);
                    //           fetchClubAndProceed();
                    //         },
                    //       ),
                    //       SizedBox(
                    //         width: screenWidth*0.3,
                    //         child: CupertinoPicker(
                    //             itemExtent: 50,
                    //             onSelectedItemChanged: (int index){
                    //               setState(() {
                    //                 selectedClubId = clubIds[index];
                    //               });
                    //             },
                    //             children: List<Widget>.generate(
                    //                 clubNames.length, (index){
                    //               return Center(
                    //                 child: Text(
                    //                   clubNames[index].toString(),
                    //                   style: customStyleClass.getFontStyle2(),
                    //                 ),
                    //               );
                    //             })
                    //         ),
                    //       )
                    //     ],
                    //   ),
                    // ),

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

class TempClubData{

  TempClubData({
    required this.clubName,
    required this.clubId
});

  String clubId;
  String clubName;

}

