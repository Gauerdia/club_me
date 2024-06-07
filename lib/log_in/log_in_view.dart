import 'package:club_me/models/club.dart';
import 'package:club_me/models/club_me_user_data.dart';
import 'package:club_me/models/parser/club_me_club_parser.dart';
import 'package:club_me/shared/custom_text_style.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../provider/state_provider.dart';
import '../services/hive_service.dart';
import '../services/supabase_service.dart';
import 'package:geolocator/geolocator.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

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
  late CustomTextStyle customTextStyle;
  late double screenHeight, screenWidth;

  final HiveService _hiveService = HiveService();
  final SupabaseService _supabaseService = SupabaseService();

  List<String> clubIds = [
    "e6c9bfb4-a8a0-490c-be9e-1cad0c29d864",
    "55c3f95b-cb67-4e38-bce7-d6e4ab45e607",
    "cf49bc92-909b-41a8-8ec5-2013cde1ef0a",
    "42db0a81-ef59-4972-9a61-cc29b20084f2",
    "2733b675-d574-4580-90c8-5fe371007b70"
  ];
  List<String> clubNames = [
    "LKA", "Climax", "Boa", "7grad", "HiLife"
  ];

  String selectedClubId = "e6c9bfb4-a8a0-490c-be9e-1cad0c29d864";

  bool isLoading = false;
  bool hasUserData = false;

  Color primeColorDark = Colors.teal;
  Color primeColor = Colors.tealAccent;

  Widget _buildClubButton(String textToDisplay, String clubId){
    return Padding(
      padding: EdgeInsets.only(
        top:screenHeight*0.015,
        right: 7,
        bottom: 7,
      ),
      child: Align(
        // alignment: Alignment.bottomRight,
        child: GestureDetector(
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
                  textToDisplay,
                  style: customTextStyle.size5Bold()
                ),
              )
          ),
          onTap: (){
            // stateProvider.setClubUiActive(true);
            // fetchClubAndProceed(clubId);
          },
        ),
      ),
    );
  }


  Future<bool?> _showBackDialog() {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Are you sure?'),
          content: const Text(
            'Are you sure you want to leave this page?',
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Nevermind'),
              onPressed: () {
                Navigator.pop(context, false);
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Leave'),
              onPressed: () {
                Navigator.pop(context, true);
              },
            ),
          ],
        );
      },
    );
  }

  void fetchClubAndProceed() async{
    isLoading = true;
    try{
      var _list = await _supabaseService.getSpecificClub(selectedClubId);
      if(_list != null){
        ClubMeClub clubMeClub = parseClubMeClub(_list[0]);
        stateProvider.setUserClub(clubMeClub);
        stateProvider.setUserData(
            ClubMeUserData(
              firstName: "...",
              lastName: "...",
              birthDate: DateTime.now(),
              eMail: "test@test.de",
              gender: 0,
              userId: clubMeClub.getClubId(),
              profileType: 1
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
          stateProvider.setUserData(userData[0]);
          print("LogIn Test: ${userData[0].getUserId()}");
          if(userData[0].getProfileType() == 0){
            context.go("/user_events");
          }else{
            context.go("/club_events");
          }
        }

      });
    }catch(e){
      log.d("Error in fetchUserDataFromHive: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    _determinePosition().then((value) => {
      stateProvider.setUserCoordinates(value)
    });
    fetchUserDataFromHive();
  }

  @override
  Widget build(BuildContext context) {

    stateProvider = Provider.of<StateProvider>(context);

    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;

    customTextStyle = CustomTextStyle(context: context);

    return Scaffold(
      appBar:
      AppBar(
          backgroundColor: Colors.transparent,
          title: SizedBox(
            width: screenWidth,
            child: Text(
              headLine,
              textAlign: TextAlign.center,
              style: customTextStyle.size2(),
            ),
          )
      ),

      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          isLoading ?
          const Center(
            child: CircularProgressIndicator(),
          ):SizedBox(
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
                                  style: customTextStyle.size5Bold(),
                                ),
                              )
                          ),
                          onTap: (){
                            context.go("/user_events");
                          },
                        ),
                      ),
                    ),

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
                                      style: customTextStyle.size5Bold()
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
                                      style: const TextStyle(
                                          fontSize: 24
                                      ),
                                    ),
                                  );
                                })
                            ),
                          )
                        ],
                      ),
                    ),

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
                                style: customTextStyle.size5Bold()
                            ),
                          )
                      ),
                      onTap: (){
                        context.go("/register");
                      },
                    )


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
