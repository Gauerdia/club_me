import 'dart:io';

import 'package:club_me/4_map/components/club_info_bottom_sheet_2.dart';
import 'package:club_me/models/club.dart';
import 'package:club_me/models/event.dart';
import 'package:club_me/shared/custom_bottom_navigation_bar.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/parser/club_me_club_parser.dart';
import '../provider/current_and_liked_elements_provider.dart';
import '../provider/fetched_content_provider.dart';
import '../provider/state_provider.dart';
import '../provider/user_data_provider.dart';
import '../services/supabase_service.dart';
import '../shared/custom_text_style.dart';
import 'components/club_info_bottom_sheet.dart';
import 'components/club_list_item.dart';


class UserMapView extends StatefulWidget {
  const UserMapView({Key? key}) : super(key: key);

  @override
  State<UserMapView> createState() => _UserMapViewState();
}

class _UserMapViewState extends State<UserMapView>{

  String headline = "Finde deinen Club";

  var log = Logger();

  late Future<PostgrestList> getClubs;
  late StateProvider stateProvider;
  late FetchedContentProvider fetchedContentProvider;
  late CustomStyleClass customStyleClass;
  late ClubMeEvent clubMeEventToDisplay;
  late double screenWidth, screenHeight;
  late UserDataProvider userDataProvider;
  late CurrentAndLikedElementsProvider currentAndLikedElementsProvider;

  // List<String> imageFileNamesToBeFetched = [];
  // List<String> imageFileNamesAlreadyFetched = [];

  final MapController _mapController = MapController();
  final SupabaseService _supabaseService = SupabaseService();

  bool isClubsFetched = false;
  bool showBottomSheet = false;
  bool showListIsActive = false;
  bool noEventAvailable = false;


  List<ClubMeClub> clubsToDisplay = [];
  List<Widget> listWidgetsToDisplay = [];

  /// TODO: isClubsFetched is not updated properly.

  @override
  void initState() {
    super.initState();
    final stateProvider = Provider.of<StateProvider>(context, listen:  false);
    final fetchedContentProvider = Provider.of<FetchedContentProvider>(context, listen:  false);
    if(fetchedContentProvider.getFetchedClubs().isEmpty){
      getClubs = _supabaseService.getAllClubs();
    }
  }

  // COLOR SCHEME
  Widget _darkModeTileBuilder(
      BuildContext context,
      Widget tileWidget,
      TileImage tile,
      ) {
    return ColorFiltered(
      colorFilter: const ColorFilter.matrix(<double>[
        -0.2126, -0.7152, -0.0722, 0, 255, // Red channel
        -0.2126, -0.7152, -0.0722, 0, 255, // Green channel
        -0.2126, -0.7152, -0.0722, 0, 255, // Blue channel
        0,       0,       0,       1, 0,   // Alpha channel
      ]),
      child: tileWidget,
    );
  }

  // TOGGLE
  void toggleShowBottomSheet(){
    setState(() {
      showBottomSheet = !showBottomSheet;
    });
  }
  void toggleShowListIsActive(){
    setState(() {
      showListIsActive = !showListIsActive;
    });
  }

  // BUILD
  Widget fetchClubsFromDbAndBuildWidget(double screenHeight, double screenWidth){

    if(fetchedContentProvider.getFetchedClubs().isEmpty){

      return FutureBuilder(
          future: getClubs,
          builder: (context, snapshot){

            if(snapshot.hasError){
              print("Error: ${snapshot.error}");
            }
            if(!snapshot.hasData){
              return SizedBox(
                width: screenWidth,
                height: screenHeight,
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }else{

              final data = snapshot.data!;

              if(clubsToDisplay.isEmpty){
                for(var element in data){

                  ClubMeClub currentClub = parseClubMeClub(element);

                  clubsToDisplay.add(currentClub);

                  // Check if we need to fetch the image
                  checkIfImageExistsLocally(currentClub.getBannerId()).then((exists){
                    if(!exists){

                      // If we haven't started to fetch the image yet, we ought to
                      if(!fetchedContentProvider.getFetchedBannerImageIds().contains(currentClub.getBannerId())){

                        // Save the name so that we don't fetch the same image several times
                        fetchAndSaveBannerImage(currentClub.getBannerId());
                      }
                    }else{
                      fetchedContentProvider.addFetchedBannerImageId(currentClub.getBannerId());
                    }
                  });
                }
              }else{
                for(var club in clubsToDisplay){
                  fetchedContentProvider.addClubToFetchedClubs(club);
                }
              }

              clubsToDisplay.sort((a,b) => b.priorityScore.compareTo(a.priorityScore));

              fetchedContentProvider.setFetchedClubs(clubsToDisplay);

              // isClubsFetched = true;

              // The map
              return clubsToDisplay.isNotEmpty && fetchedContentProvider.getFetchedClubs().isNotEmpty ?
              Column(
                children: [
                  SizedBox(
                    height: screenHeight*0.8,
                    width: screenWidth,
                    child: _buildFlutterMap(),
                  )
                ],
              ):Container();
            }
          }
      );
    }else{

      if(clubsToDisplay.isEmpty){
        for(var club in fetchedContentProvider.getFetchedClubs()){
          clubsToDisplay.add(club);
          fetchedContentProvider.addFetchedBannerImageId(club.getBannerId());
        }
      }else{
        // for(var club in clubsToDisplay){
        //   fetchedContentProvider.addFetchedBannerImageId(club.getBannerId());
        // }
      }

      clubsToDisplay.sort((a,b) => b.priorityScore.compareTo(a.priorityScore));

      return Column(
        children: [
          SizedBox(
            height: screenHeight*0.8,
            width: screenWidth,
            child: _buildFlutterMap(),
          )
        ],
      );
    }
  }
  Widget _buildFlutterMap(){

    return FlutterMap(
        mapController: _mapController,
        options: const MapOptions(
          initialCenter: LatLng(48.773809, 9.182959),
          initialZoom: 15,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.szymendera.club_me',
            tileBuilder: _darkModeTileBuilder,
          ),

          MarkerLayer(
              markers: [

                userDataProvider.getUserLatCoord() != 0 ?
                Marker(
                    point: LatLng(userDataProvider.getUserLatCoord(), userDataProvider.getUserLongCoord()),
                    child: const Icon(Icons.pin_drop_outlined, color: Colors.orangeAccent,)
                )
                    : const Marker(
                    point: LatLng(0,0),
                    child: Icon(Icons.pin_drop_outlined, color: Colors.orangeAccent,)),

                for(ClubMeClub club in clubsToDisplay)
                  Marker(
                      point: LatLng(club.getGeoCoordLat(), club.getGeoCoordLng()),
                      width: 50,
                      rotate: true,
                      height: 50,
                      child: GestureDetector(
                        child: Stack(
                          children: [
                            Image(
                              image: club.clubIsOpen() ?
                              const AssetImage("assets/images/pin.png") :
                              const AssetImage("assets/images/pin_inverted.png"),
                            ),
                            if(fetchedContentProvider.getFetchedBannerImageIds().contains(club.getBannerId()))

                              Container(
                                padding: const EdgeInsets.only(
                                  left: 3,
                                  top: 3
                                ),
                                child: CircleAvatar(
                                  radius: 15,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      // color: Colors.white,
                                      image: DecorationImage(
                                        fit: BoxFit.cover,
                                        image:
                                        FileImage(
                                            File(
                                                "${stateProvider.appDocumentsDir.path}/${club.getBannerId()}"
                                            )
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              )
                          ],
                        ),
                        onTap: (){

                          // Check if there is any event for the club
                          if(fetchedContentProvider.fetchedEvents
                              .where(
                                  (event) => (event.getClubId() == club.getClubId() && event.getEventDate().isAfter(DateTime.now()))
                          ).isEmpty
                          ){
                            noEventAvailable = true;
                          }else{
                            clubMeEventToDisplay = fetchedContentProvider.fetchedEvents.firstWhere(
                                    (event) => (event.getClubId() == club.getClubId() && event.getEventDate().isAfter(DateTime.now()))
                            );
                            noEventAvailable = false;
                          }

                          currentAndLikedElementsProvider.setCurrentClub(club);
                          toggleShowBottomSheet();
                        },
                      )
                  )
              ]
          )
        ]
    );
  }
  Widget _buildAppBar(){

    return SizedBox(
      width: screenWidth,
      child: Stack(
        children: [


          // Headline
          Container(
              alignment: Alignment.bottomCenter,
              height: 50,
              width: screenWidth,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                      headline,
                      textAlign: TextAlign.center,
                      style: customStyleClass.getFontStyle1()
                  ),
                ],
              )
          ),

          Container(
            height: 50,
            alignment: Alignment.centerRight,
            child: GestureDetector(
              child: Padding(
                padding: const EdgeInsets.only(
                  // right: 10
                ),
                child: Container(
                  padding: const EdgeInsets.all(7),
                  decoration: const BoxDecoration(
                      color: Color(0xff11181f),
                      borderRadius: BorderRadius.all(
                          Radius.circular(45)
                      )
                  ),

                  child:  Icon(
                    Icons.list_alt,
                    color: showListIsActive ? customStyleClass.primeColor : Colors.grey,
                  ),
                ),
              ),
              onTap: (){
                toggleShowListIsActive();
              },
            ),
          )

        ],
      ),
    );
  }

  void fetchAndSaveBannerImage(String fileName) async {
    var imageFile = await _supabaseService.getBannerImage(fileName);

    final String dirPath = stateProvider.appDocumentsDir.path;

    await File("$dirPath/$fileName").writeAsBytes(imageFile).then((onValue){
      setState(() {
        log.d("fetchAndSaveBannerImage: Finished successfully. Path: $dirPath/$fileName");
        fetchedContentProvider.addFetchedBannerImageId(fileName);
        // imageFileNamesAlreadyFetched.add(fileName);
      });
    });
  }

  Future<bool> checkIfImageExistsLocally(String fileName) async{
    final String dirPath = stateProvider.appDocumentsDir.path;
    return await File('$dirPath/$fileName').exists();
  }

  @override
  Widget build(BuildContext context) {

    stateProvider = Provider.of<StateProvider>(context);

    customStyleClass = CustomStyleClass(context: context);
    fetchedContentProvider = Provider.of<FetchedContentProvider>(context);
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    currentAndLikedElementsProvider = Provider.of<CurrentAndLikedElementsProvider>(context);
    userDataProvider = Provider.of<UserDataProvider>(context);

    if(isClubsFetched == false && fetchedContentProvider.getFetchedClubs().isNotEmpty) {
      isClubsFetched = true;
    }

    return Scaffold(

      // extendBodyBehindAppBar: true,
      extendBody: true,

      bottomNavigationBar: CustomBottomNavigationBar(),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: _buildAppBar(),
      ),

      body: Container(
        width: screenWidth,
          height: screenHeight,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xff2b353d),
                Color(0xff11181f)
              ],
              stops: [0.15, 0.6]
            ),
          ),
          child: Column(
            children: [

              // Spacer
              // SizedBox(height: screenHeight*0.12,),

              // Content
              SizedBox(
                width: screenWidth,
                height: screenHeight*0.83,
                child: Stack(
                  children: [

                    fetchClubsFromDbAndBuildWidget(screenHeight, screenWidth),

                    // transparent layer to click out of bottom sheet
                    showBottomSheet?
                      GestureDetector(
                          child: Container(
                            width: screenWidth,
                            height: screenHeight*0.83,
                            color: Colors.transparent,
                          ),
                          onTap: (){
                            toggleShowBottomSheet();
                          },
                        ) :
                      Container(),

                    // The bottom info container
                    GestureDetector(
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child:
                        showBottomSheet ?
                        noEventAvailable?
                        ClubInfoBottomSheet2
                          (showBottomSheet: showBottomSheet,
                            clubMeEvent: null,
                            noEventAvailable: noEventAvailable
                        ):ClubInfoBottomSheet2
                          (showBottomSheet: showBottomSheet,
                            clubMeEvent: clubMeEventToDisplay,
                            noEventAvailable: noEventAvailable
                        )
                            : Container(),
                      ),
                      onTap: (){
                        // club will be set in stateprovider when clicked on marker
                        context.push("/club_details");
                      },
                    ),

                    // Grey background when list active
                    showListIsActive?
                      GestureDetector(
                          child: Container(
                            width: screenWidth,
                            height: screenHeight,
                            color: Colors.black.withOpacity(0.95),
                          ),
                          onTap: (){
                            setState(() {
                              showListIsActive = false;
                            });
                          },
                        ) :
                      Container(),

                    // List view of clubs
                    showListIsActive ?
                      Padding(
                            padding: const EdgeInsets.only(
                                // top: screenWidth*0.1
                            ),
                          child: Center(

                            // Whole list background
                            child: Container(
                              padding: const EdgeInsets.only(
                                top: 20,
                                bottom: 20
                              ),
                              // width: screenWidth*0.9,
                              // height: screenHeight*0.7,
                              child: SingleChildScrollView(
                                child: Column(
                                  children: [
                                    for( ClubMeClub club in clubsToDisplay)
                                      ClubListItem(
                                          currentClub: club,
                                      )
                                  ],
                                ),
                              )
                              
                            ),
                          )
                        ) :
                      Container()
                  ],
                )
              )
            ],
          )
          ),
    );
  }
}





