import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../models/event.dart';
import '../../provider/state_provider.dart';
import '../../services/hive_service.dart';
import '../../shared/custom_text_style.dart';
import '../../user_clubs/components/event_card.dart';

class ClubInfoBottomSheet extends StatefulWidget {
  ClubInfoBottomSheet({
    Key? key,
    required this.showBottomSheet,
    this.clubMeEvent,
    required this.noEventAvailable
  }) : super(key: key);

  late bool showBottomSheet;
  late ClubMeEvent? clubMeEvent;
  late bool noEventAvailable;

  @override
  State<ClubInfoBottomSheet> createState() => _ClubInfoBottomSheetState();
}

class _ClubInfoBottomSheetState extends State<ClubInfoBottomSheet> {


  late StateProvider stateProvider;
  late bool noEventAvailable;
  late bool showBottomSheet;
  late ClubMeEvent? clubMeEvent;
  late CustomTextStyle customTextStyle;

  double imageHeightFactor = 0.09;
  double headlineHeightFactor = 0.09;
  double iconWidthFactor = 0.05;

  final HiveService _hiveService = HiveService();

  double calculateDistanceToClub(){

    if(stateProvider.getUserLatCoord() != 0){

      var distance = Geolocator.distanceBetween(
          stateProvider.getUserLatCoord(),
          stateProvider.getUserLongCoord(),
          stateProvider.clubMeClub.getGeoCoordLat(),
          stateProvider.clubMeClub.getGeoCoordLng()
      );

      if(distance/1000 > 1000){
        return 999;
      }else{
        return distance/1000;
      }
    }else{
      return 0;
    }
  }

  void clickOnInfo(){
    print("Info");
  }

  void clickOnLike(){
    likeIconClicked(stateProvider.clubMeClub.getClubId());
  }

  void clickOnShare(){
    showDialog(context: context, builder: (BuildContext context){
      return AlertDialog(
        title: const Text("Teilen"),
        content: Text(
          "Diese Funktion steht zurzeit noch nicht zur Verfügung! Wir bitten um Verständnis!",
          textAlign: TextAlign.left,
          style: customTextStyle.size4(),
        ),
      );
    });
  }

  String getAndFormatMusicGenre() {

    String genreToReturn = "";

    if (stateProvider.clubMeClub.getMusicGenres().contains(",")) {
      var index = stateProvider.clubMeClub.getMusicGenres().indexOf(",");
      genreToReturn = stateProvider.clubMeClub.getMusicGenres().substring(0, index);
    } else {
      genreToReturn = stateProvider.clubMeClub.getMusicGenres();
    }

    if(genreToReturn.length>8){
      genreToReturn = "${genreToReturn.substring(0, 7)}...";
    }
    return genreToReturn;

  }

  void likeIconClicked(String clubId){
    if(stateProvider.checkIfClubIsAlreadyLiked(clubId)){
      stateProvider.deleteLikedClub(clubId);
      _hiveService.deleteFavoriteClub(clubId);
    }else{
      stateProvider.addLikedClub(clubId);
      _hiveService.insertFavoriteClub(clubId);
    }
  }

  @override
  Widget build(BuildContext context) {

    noEventAvailable = widget.noEventAvailable;
    showBottomSheet = widget.showBottomSheet;
    if(widget.clubMeEvent != null){
     clubMeEvent = widget.clubMeEvent;
    }

    stateProvider = Provider.of<StateProvider>(context);

    customTextStyle = CustomTextStyle(context: context);

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;


    return AnimatedOpacity(
      opacity: showBottomSheet ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 2500),
      child: AnimatedContainer(
        width: screenWidth,
        height: screenHeight*0.4,
        decoration: BoxDecoration(

            gradient: RadialGradient(
                colors: [
                  Colors.grey[600]!,
                  Colors.grey[850]!
                ],
                stops: const [0.1, 0.35],
                center: Alignment.topLeft,
                radius: 3
            ),

            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(25),
                topRight: Radius.circular(25)
            )
        ),
        duration: const Duration(seconds: 2),
        curve: Curves.fastOutSlowIn,
        child: Column(
          children: [

            // Header
            Stack(
              children: [

                // image
                Container(
                  height: screenHeight*imageHeightFactor,
                  width: screenWidth,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage(
                            "assets/images/${stateProvider.clubMeClub.getBannerId()}"
                        ),
                        fit: BoxFit.cover
                    ),
                    borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(25),
                        topRight: Radius.circular(25)
                    ),
                  ),
                ),

                // club name
                Container(
                  height: screenHeight*headlineHeightFactor,
                  width: screenWidth,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                        colors: [
                          Colors.black,
                          Colors.transparent
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        stops: [0.4, 0.6]
                    ),
                    color: Colors.grey,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(25),
                        topRight: Radius.circular(25)
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.only(
                        top: screenHeight*0.015,
                        left: screenWidth*0.03
                    ),
                    child: Text(
                      stateProvider.clubMeClub.getClubName(),
                      // clubMeEvent.getClubName(),
                      style: customTextStyle.size1MapHeadline(),
                    ),
                  ),
                )
              ],
            ),

            // Spacer
            SizedBox(height: screenHeight*0.01,),

            // Event Card
            noEventAvailable ?
            SizedBox(
              height: screenHeight*0.18,
              child: const Center(
                child: Text("Derzeit kein Event geplant!"),
              ),
            ):GestureDetector(
              child: EventCard(clubMeEvent: clubMeEvent!),
              onTap: (){
                stateProvider.setCurrentEvent(clubMeEvent!);
                context.push("/event_details");
              },
            ),

            // Spacer
            SizedBox(height: screenHeight*0.01,),

            // BottomSheet
            Padding(
              padding: EdgeInsets.only(
                  left: screenWidth*0.05
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [

                  // Info, Like, Share
                  Container(
                    width: screenWidth*0.35,
                    height: screenHeight*0.055,
                    padding: EdgeInsets.symmetric(
                        horizontal: screenWidth*0.03,
                        vertical: screenHeight*0.005
                    ),

                    decoration: const BoxDecoration(
                      color: Color(0xff11181f),
                      borderRadius: BorderRadius.all(
                          Radius.circular(12)
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [

                            // Info icon
                            Container(
                                padding: const EdgeInsets.all(
                                    4
                                ),
                                decoration: const BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.all(
                                      Radius.circular(45)
                                  ),
                                ),
                                child: GestureDetector(
                                  child: Icon(
                                    Icons.info_outline,
                                    color: stateProvider.getPrimeColor(),
                                    size: screenWidth*iconWidthFactor,
                                  ),
                                  onTap: () => clickOnInfo,
                                )
                            ),

                            const SizedBox(width: 15,),

                            // star
                            Container(
                              padding: const EdgeInsets.all(
                                  4
                              ),
                              decoration: const BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.all(
                                    Radius.circular(45)
                                ),
                              ),
                              child: GestureDetector(
                                child: Icon(
                                    stateProvider.checkIfSpecificCLubIsAlreadyLiked(stateProvider.clubMeClub.getClubId())
                                        ? Icons.star_outlined
                                        : Icons.star_border,
                                  color: stateProvider.getPrimeColor(),
                                  size: screenWidth*iconWidthFactor,
                                ),
                                onTap: () => clickOnLike(),
                              ),
                            ),

                            const SizedBox(width: 15,),

                            // share
                            Container(
                              padding: const EdgeInsets.all(
                                  4
                              ),
                              decoration: const BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.all(
                                    Radius.circular(45)
                                ),
                              ),
                              child: GestureDetector(
                                child: Icon(
                                  Icons.share,
                                  color: stateProvider.getPrimeColor(),
                                  size: screenWidth*iconWidthFactor,
                                ),
                                onTap: () => clickOnShare(),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Icon Row
                  Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: Container(
                        // width: screenWidth*0.55,
                        // height: screenHeight*0.055,
                        padding: EdgeInsets.symmetric(
                            horizontal: screenWidth*0.03,
                            vertical: screenHeight*0.012
                        ),

                        decoration: const BoxDecoration(
                          color: Color(0xff11181f),
                          borderRadius: BorderRadius.all(
                              Radius.circular(12)
                          ),
                        ),
                        child: Row(
                          children: [

                            // Spacer
                            const SizedBox(width: 5,),

                            // Icon distance
                            Container(
                              padding: const EdgeInsets.all(
                                  4
                              ),
                              decoration: const BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.all(
                                    Radius.circular(45)
                                ),
                              ),
                              child:  Icon(
                                Icons.route,
                                color: stateProvider.getPrimeColor(),
                                size: screenWidth*iconWidthFactor,
                              ),
                            ),

                            // Spacer
                            const SizedBox(width: 5,),

                            // Text distance
                            Text(
                              calculateDistanceToClub().toStringAsFixed(2),
                              style: customTextStyle.size5BoldGrey(),
                            ),

                            // Spacer
                            const SizedBox(width: 5,),

                            // Icon genre
                            Container(
                              padding: const EdgeInsets.all(
                                  4
                              ),
                              decoration: const BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.all(
                                    Radius.circular(45)
                                ),
                              ),
                              child:  Icon(
                                Icons.library_music_outlined,
                                color: stateProvider.getPrimeColor(),
                                size: screenWidth*iconWidthFactor,
                              ),
                            ),

                            // Spacer
                            const SizedBox(width: 5,),

                            // Text Genre
                            Text(
                              getAndFormatMusicGenre(),
                              style: customTextStyle.size5BoldGrey(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}



// class ClubInfoBottomSheet extends StatelessWidget {
//
//   ClubInfoBottomSheet({
//     Key? key,
//     required this.showBottomSheet,
//     this.clubMeEvent,
//     required this.noEventAvailable
//   }) : super(key: key);
//
//   late StateProvider stateProvider;
//
//   late bool noEventAvailable;
//   late bool showBottomSheet;
//   late ClubMeEvent? clubMeEvent;
//   late CustomTextStyle customTextStyle;
//
//   double imageHeightFactor = 0.09;
//   double headlineHeightFactor = 0.09;
//   double iconWidthFactor = 0.05;
//
//
//   double calculateDistanceToClub(){
//
//     if(stateProvider.getUserLatCoord() != 0){
//
//       var distance = Geolocator.distanceBetween(
//           stateProvider.getUserLatCoord(),
//           stateProvider.getUserLongCoord(),
//           stateProvider.clubMeClub.getGeoCoordLat(),
//           stateProvider.clubMeClub.getGeoCoordLng()
//       );
//
//       if(distance/1000 > 1000){
//         return 999;
//       }else{
//         return distance/1000;
//       }
//     }else{
//       return 0;
//     }
//   }
//
//   void clickOnInfo(){
//     print("Info");
//   }
//
//   void clickOnLike(){
//    print("like");
//   }
//
//   void clickOnShare(){
//     print("share");
//   }
//
//   String getAndFormatMusicGenre() {
//
//     String genreToReturn = "";
//
//     if (stateProvider.clubMeClub.getMusicGenres().contains(",")) {
//       var index = stateProvider.clubMeClub.getMusicGenres().indexOf(",");
//       genreToReturn = stateProvider.clubMeClub.getMusicGenres().substring(0, index);
//     } else {
//       genreToReturn = stateProvider.clubMeClub.getMusicGenres();
//     }
//
//     if(genreToReturn.length>8){
//       genreToReturn = "${genreToReturn.substring(0, 7)}...";
//     }
//     return genreToReturn;
//
//   }
//
//   @override
//   Widget build(BuildContext context) {
//
//     stateProvider = Provider.of<StateProvider>(context);
//
//     customTextStyle = CustomTextStyle(context: context);
//
//     double screenWidth = MediaQuery.of(context).size.width;
//     double screenHeight = MediaQuery.of(context).size.height;
//
//
//     return AnimatedOpacity(
//       opacity: showBottomSheet ? 1.0 : 0.0,
//       duration: const Duration(milliseconds: 2500),
//       child: AnimatedContainer(
//         width: screenWidth,
//         height: screenHeight*0.4,
//         decoration: BoxDecoration(
//
//             gradient: RadialGradient(
//                 colors: [
//                   Colors.grey[600]!,
//                   Colors.grey[850]!
//                 ],
//                 stops: const [0.1, 0.35],
//                 center: Alignment.topLeft,
//                 radius: 3
//             ),
//
//             borderRadius: const BorderRadius.only(
//                 topLeft: Radius.circular(25),
//                 topRight: Radius.circular(25)
//             )
//         ),
//         duration: const Duration(seconds: 2),
//         curve: Curves.fastOutSlowIn,
//         child: Column(
//           children: [
//
//             // Header
//             Stack(
//               children: [
//
//                 // image
//                 Container(
//                   height: screenHeight*imageHeightFactor,
//                   width: screenWidth,
//                   decoration: BoxDecoration(
//                     image: DecorationImage(
//                         image: AssetImage(
//                             "assets/images/${stateProvider.clubMeClub.getBannerId()}"
//                         ),
//                         fit: BoxFit.cover
//                     ),
//                     borderRadius: const BorderRadius.only(
//                         topLeft: Radius.circular(25),
//                         topRight: Radius.circular(25)
//                     ),
//                   ),
//                 ),
//
//                 // club name
//                 Container(
//                   height: screenHeight*headlineHeightFactor,
//                   width: screenWidth,
//                   decoration: const BoxDecoration(
//                     gradient: LinearGradient(
//                         colors: [
//                           Colors.black,
//                           Colors.transparent
//                         ],
//                         begin: Alignment.topLeft,
//                         end: Alignment.bottomRight,
//                         stops: [0.4, 0.6]
//                     ),
//                     color: Colors.grey,
//                     borderRadius: BorderRadius.only(
//                         topLeft: Radius.circular(25),
//                         topRight: Radius.circular(25)
//                     ),
//                   ),
//                   child: Padding(
//                     padding: EdgeInsets.only(
//                         top: screenHeight*0.015,
//                         left: screenWidth*0.03
//                     ),
//                     child: Text(
//                       stateProvider.clubMeClub.getClubName(),
//                       // clubMeEvent.getClubName(),
//                       style: customTextStyle.size1MapHeadline(),
//                     ),
//                   ),
//                 )
//               ],
//             ),
//
//             // Spacer
//             SizedBox(height: screenHeight*0.01,),
//
//             // Event Card
//             noEventAvailable ?
//             SizedBox(
//               height: screenHeight*0.18,
//               child: const Center(
//                 child: Text("Derzeit kein Event geplant!"),
//               ),
//             ):GestureDetector(
//               child: EventCard(clubMeEvent: clubMeEvent!),
//               onTap: (){
//                 stateProvider.setCurrentEvent(clubMeEvent!);
//                 context.push("/event_details");
//               },
//             ),
//
//             // Spacer
//             SizedBox(height: screenHeight*0.01,),
//
//             // BottomSheet
//             Padding(
//               padding: EdgeInsets.only(
//                   left: screenWidth*0.05
//               ),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//
//                   // Info, Like, Share
//                   Container(
//                     width: screenWidth*0.35,
//                     height: screenHeight*0.055,
//                     padding: EdgeInsets.symmetric(
//                         horizontal: screenWidth*0.03,
//                       vertical: screenHeight*0.005
//                     ),
//
//                     decoration: const BoxDecoration(
//                       color: Color(0xff11181f),
//                       borderRadius: BorderRadius.all(
//                           Radius.circular(12)
//                       ),
//                     ),
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                           children: [
//
//                             // Info icon
//                             Container(
//                               padding: const EdgeInsets.all(
//                                   4
//                               ),
//                               decoration: const BoxDecoration(
//                                 color: Colors.black,
//                                 borderRadius: BorderRadius.all(
//                                     Radius.circular(45)
//                                 ),
//                               ),
//                               child: GestureDetector(
//                                 child: Icon(
//                                   Icons.info_outline,
//                                   color: stateProvider.getPrimeColor(),
//                                   size: screenWidth*iconWidthFactor,
//                                 ),
//                                 onTap: () => clickOnInfo,
//                               )
//                             ),
//
//                             const SizedBox(width: 15,),
//
//                             // star
//                             Container(
//                               padding: const EdgeInsets.all(
//                                   4
//                               ),
//                               decoration: const BoxDecoration(
//                                 color: Colors.black,
//                                 borderRadius: BorderRadius.all(
//                                     Radius.circular(45)
//                                 ),
//                               ),
//                               child: GestureDetector(
//                                 child: Icon(
//                                   Icons.star_border,
//                                   color: stateProvider.getPrimeColor(),
//                                   size: screenWidth*iconWidthFactor,
//                                 ),
//                                 onTap: () => clickOnLike(),
//                               ),
//                             ),
//
//                             const SizedBox(width: 15,),
//
//                             // share
//                             Container(
//                               padding: const EdgeInsets.all(
//                                   4
//                               ),
//                               decoration: const BoxDecoration(
//                                 color: Colors.black,
//                                 borderRadius: BorderRadius.all(
//                                     Radius.circular(45)
//                                 ),
//                               ),
//                               child: GestureDetector(
//                                 child: Icon(
//                                   Icons.share,
//                                   color: stateProvider.getPrimeColor(),
//                                   size: screenWidth*iconWidthFactor,
//                                 ),
//                                 onTap: () => clickOnShare(),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//
//                   // Icon Row
//                   Padding(
//                     padding: const EdgeInsets.only(right: 10),
//                     child: Align(
//                       alignment: Alignment.bottomRight,
//                       child: Container(
//                         // width: screenWidth*0.55,
//                         // height: screenHeight*0.055,
//                         padding: EdgeInsets.symmetric(
//                             horizontal: screenWidth*0.03,
//                             vertical: screenHeight*0.012
//                         ),
//
//                         decoration: const BoxDecoration(
//                           color: Color(0xff11181f),
//                           borderRadius: BorderRadius.all(
//                               Radius.circular(12)
//                           ),
//                         ),
//                         child: Row(
//                           children: [
//
//                             // Spacer
//                             const SizedBox(width: 5,),
//
//                             // Icon distance
//                             Container(
//                               padding: const EdgeInsets.all(
//                                   4
//                               ),
//                               decoration: const BoxDecoration(
//                                 color: Colors.black,
//                                 borderRadius: BorderRadius.all(
//                                     Radius.circular(45)
//                                 ),
//                               ),
//                               child:  Icon(
//                                 Icons.route,
//                                 color: stateProvider.getPrimeColor(),
//                                 size: screenWidth*iconWidthFactor,
//                               ),
//                             ),
//
//                             // Spacer
//                             const SizedBox(width: 5,),
//
//                             // Text distance
//                             Text(
//                               calculateDistanceToClub().toString(),
//                               style: customTextStyle.size5BoldGrey(),
//                             ),
//
//                             // Spacer
//                             const SizedBox(width: 5,),
//
//                             // Icon genre
//                             Container(
//                               padding: const EdgeInsets.all(
//                                   4
//                               ),
//                               decoration: const BoxDecoration(
//                                 color: Colors.black,
//                                 borderRadius: BorderRadius.all(
//                                     Radius.circular(45)
//                                 ),
//                               ),
//                               child:  Icon(
//                                 Icons.library_music_outlined,
//                                 color: stateProvider.getPrimeColor(),
//                                 size: screenWidth*iconWidthFactor,
//                               ),
//                             ),
//
//                             // Spacer
//                             const SizedBox(width: 5,),
//
//                             // Text Genre
//                             Text(
//                               getAndFormatMusicGenre(),
//                               style: customTextStyle.size5BoldGrey(),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }