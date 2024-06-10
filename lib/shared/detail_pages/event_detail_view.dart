import 'package:club_me/shared/custom_bottom_navigation_bar_clubs.dart';
import 'package:club_me/shared/map_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../provider/state_provider.dart';
import '../../services/hive_service.dart';
import '../../services/supabase_service.dart';
import '../custom_bottom_navigation_bar.dart';
import 'package:intl/intl.dart';

import '../custom_text_style.dart';

import 'package:timezone/standalone.dart' as tz;

class EventDetailView extends StatefulWidget {
  const EventDetailView({Key? key}) : super(key: key);

  @override
  State<EventDetailView> createState() => _EventDetailViewState();
}

class _EventDetailViewState extends State<EventDetailView>{

  final HiveService _hiveService = HiveService();
  final SupabaseService _supabaseService = SupabaseService();

  bool isUploading = false;
  bool isDateSelected = false;

  late StateProvider stateProvider;
  late CustomTextStyle customTextStyle;
  late double screenHeight, screenWidth;

  @override
  void dispose() {
    super.dispose();
  }

  void clickedOnImIn(){

  }

  void clickedOnShare(BuildContext context){
    showDialog<String>(
        context: context,
        builder: (BuildContext context) => const AlertDialog(
            title: Text("Teilen noch nicht möglich!"),
            content: Text("Die Funktion, ein Event zu teilen, ist derzeit noch"
                "nicht implementiert. Wir bitten um Verständnis.")
        )
    );
  }

  void clickedOnLike(StateProvider stateProvider, String eventId){
    if(stateProvider.getIsEventEditable()){
      showDialog<String>(
          context: context,
          builder: (BuildContext context) => const AlertDialog(
              title: Text("Liken des Events"),
              content: Text("Das Liken des Events ist in dieser Ansicht nicht"
                  "möglich. Wir bitten um Verständnis.")
          )
      );
    }else{
      if(stateProvider.getLikedEvents().contains(eventId)){
        stateProvider.deleteLikedEvent(eventId);
        _hiveService.deleteFavoriteEvent(eventId);
      }else{
        stateProvider.addLikedEvent(eventId);
        _hiveService.insertFavoriteEvent(eventId);
      }
    }
  }

  void clickOnInfo(){
    showDialog<String>(
        context: context,
        builder: (BuildContext context) => const AlertDialog(
            title: Text("Event-Infos!"),
            content: Text("Die Funktion, mehr Informationen zu erhalten, ist derzeit noch"
                "nicht implementiert. Wir bitten um Verständnis.")
        )
    );
  }

  Widget _buildIconRow(StateProvider stateProvider, BuildContext context){
    return Align(
      alignment: Alignment.bottomRight,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [

              // Info
              GestureDetector(
                  child:Column(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: stateProvider.getPrimeColor(),
                        size: customTextStyle.getIconSize1()
                      ),
                      Text(
                        "Info",
                        style: customTextStyle.size5(),
                      ),
                    ],
                  ),
                  onTap: () => clickOnInfo()
              ),

              SizedBox(
                width: screenWidth*0.02,
              ),

              // Like
              GestureDetector(
                  child:Column(
                    children: [
                      Icon(
                        stateProvider.checkIfCurrentEventIsAlreadyLiked() ? Icons.star_outlined : Icons.star_border,
                          color: stateProvider.getPrimeColor(),
                          size: customTextStyle.getIconSize1()
                      ),
                      Text(
                        "Like",
                        style: customTextStyle.size5(),
                      )
                    ],
                  ),
                  onTap: () => clickedOnLike(stateProvider, stateProvider.clubMeEvent.getEventId())
              ),

              SizedBox(
                width: screenWidth*0.02,
              ),

              // Share
              GestureDetector(
                  child:Column(
                    children: [
                      Icon(
                        Icons.share,
                        color: stateProvider.getPrimeColor(),
                        size: customTextStyle.getIconSize1()
                      ),
                      Text(
                        "Share",
                        style: customTextStyle.size5(),
                      ),
                    ],
                  ),
                  onTap: () => clickedOnShare(context)
              ),

              SizedBox(
                width: screenWidth*0.02,
              ),

            ],
          )
        ],
      ),
    );
  }

  void uploadEvent(StateProvider stateProvider, double screenHeight, double screenWidth) async {

    late int returnValue;

    if(stateProvider.getIsCurrentlyOnlyUpdatingAnEvent()){
      try{
        _supabaseService.updateCompleteEvent(stateProvider);
        print("updateCompleteEvent successful");
        leavePage(stateProvider);
      }catch(e){
        print("Error in uploadEvent - updateCompleteEvent: $e");
        setState(() {
          showModalBottomSheet(
              context: context,
              builder: (BuildContext context){
                return SizedBox(
                    height: screenHeight*0.1,
                    width: screenWidth,
                    child: const Center(
                      child: Text("Sorry, something went wrong!"),
                    )
                );
              }
          );
          isUploading = false;
        });
      }
    }else{
      try{
        returnValue = await _supabaseService.insertEvent(stateProvider.clubMeEvent, stateProvider);
      }catch(e){
        print("Error in uploadEvent: $e");
      } finally{
        if(returnValue == 0){
          stateProvider.addEventToFetchedEvents(stateProvider.clubMeEvent);
          stateProvider.sortFetchedEvents();
          stateProvider.resetReviewingANewEvent();
          leavePage(stateProvider);
        }else{
          setState(() {
            showModalBottomSheet(
                context: context,
                builder: (BuildContext context){
                  return SizedBox(
                      height: screenHeight*0.1,
                      width: screenWidth,
                      child: const Center(
                        child: Text("Sorry, something went wrong!"),
                      )
                  );
                }
            );
            isUploading = false;
          });
        }
      }
    }
  }

  void leavePage(StateProvider stateProvider){

    // Reset all parameters
    stateProvider.deactivateIsCurrentlyOnlyUpdatingAnEvent();
    stateProvider.deactivateEventEditable();
    stateProvider.resetReviewingANewEvent();

    if(stateProvider.wentFromClubDetailToEventDetail){
      if(stateProvider.clubUIActive){
        context.go("/club_frontpage");
      }else{
        context.go("/club_details");
      }
    }else{
      stateProvider.resetWentFromCLubDetailToEventDetail();
      if(stateProvider.clubUIActive){
        switch(stateProvider.pageIndex){
          case(0): context.go('/club_events');break;
          case(1): context.go('/club_stats'); break;
          case(2): context.go('/club_coupons'); break;
          case(3): context.go('/club_frontpage');break;
          default: context.go('/club_events');break;
        }
      }else{
        switch(stateProvider.pageIndex){
          case(0): context.go('/user_events');break;
          case(1): context.go('/user_clubs'); break;
          case(2): context.go('/user_map'); break;
          case(3): context.go('/user_coupons');break;
          default: context.go('/user_events');break;
        }
      }
    }
  }

  void editField(int index, String newValue, StateProvider stateProvider){
    FocusScope.of(context).unfocus();
    stateProvider.updateCurrentEvent(index, newValue);
    Navigator.pop(context);
  }

  String formatDateToDisplay(){

    String weekDayToDisplay = "";

    var exactOneWeekFromNow = DateTime.now().add(const Duration(days: 7));

    // Get current time for germany
    final berlin = tz.getLocation('Europe/Berlin');
    final todayGermanTZ = tz.TZDateTime.from(DateTime.now(), berlin);

    final exactlyOneWeekFromNowGermanTZ = todayGermanTZ.add(const Duration(days: 7));

    if(stateProvider.clubMeEvent.getEventDate().isAfter(exactlyOneWeekFromNowGermanTZ)){
      weekDayToDisplay = DateFormat('dd.MM.yyyy').format(stateProvider.clubMeEvent.getEventDate());
    }else{
      var eventDateWeekday = stateProvider.clubMeEvent.getEventDate().weekday;
      switch(eventDateWeekday){
        case(1): weekDayToDisplay = "Montag";
        case(2): weekDayToDisplay = "Dienstag";
        case(3): weekDayToDisplay = "Mittwoch";
        case(4): weekDayToDisplay = "Donnerstag";
        case(5): weekDayToDisplay = "Freitag";
        case(6): weekDayToDisplay = "Samstag";
        case(7): weekDayToDisplay = "Sonntag";
      }
    }
    return weekDayToDisplay;
  }

  String cropEventTitle(){
    String titleToDisplay = "";

    if(stateProvider.clubMeEvent.getEventTitle().length > 42){
      titleToDisplay = "${stateProvider.clubMeEvent.getEventTitle().substring(0, 40)}...";
    }else{
      titleToDisplay = stateProvider.clubMeEvent.getEventTitle();
    }

    return titleToDisplay;
  }

  String cropDjName(){
    String djNameToDisplay = "";

    if(stateProvider.clubMeEvent.getDjName().length > 42){
      djNameToDisplay = "${stateProvider.clubMeEvent.getDjName().substring(0, 40)}...";
    }else{
      djNameToDisplay = stateProvider.clubMeEvent.getDjName();
    }
    return djNameToDisplay;
  }

  String cropGenres(){
    String genresToDisplay = "";
    if(stateProvider.clubMeEvent.getMusicGenres().substring(stateProvider.clubMeEvent.getMusicGenres().length-1) == ","){
      genresToDisplay = stateProvider.clubMeEvent.getMusicGenres().substring(0, stateProvider.clubMeEvent.getMusicGenres().length-1);
    }else{
      genresToDisplay = stateProvider.clubMeEvent.getMusicGenres();
    }
    return genresToDisplay;
  }

  AppBar _buildAppBar(){
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.transparent,
      centerTitle: true,
      title: SizedBox(
        width: screenWidth,
        height: 50,
        child: Stack(
          children: [

            SizedBox(
              child: IconButton(
                onPressed: () => leavePage(stateProvider),
                icon: const Icon(
                  Icons.arrow_back_ios,
                  color: Colors.grey,
                  // size: 20,
                ),
              ),
            ),

            SizedBox(
              width: screenWidth,
              height: 50,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Deine Events",
                    textAlign: TextAlign.center,
                    style: customTextStyle.size2(),
                  )
                ],
              ),
            )

          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    customTextStyle = CustomTextStyle(context: context);
    stateProvider = Provider.of<StateProvider>(context);

    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;

    double eventPrice = stateProvider.clubMeEvent.getEventPrice();

    String titleToDisplay = cropEventTitle();
    String djNameToDisplay = cropDjName();
    String genresToDisplay = cropGenres();

    return Scaffold(

      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,
      extendBody: true,

      bottomNavigationBar: stateProvider.clubUIActive ? CustomBottomNavigationBarClubs() : CustomBottomNavigationBar(),
      appBar: _buildAppBar(),

      body: Column(
        children: [

          // Spacer
          SizedBox(
            height: screenHeight*0.14,
          ),

          // Header
          SizedBox(
            width: screenWidth,
            height: screenHeight*0.2,
            child: Image.asset(
              "assets/images/${stateProvider.clubMeEvent.getBannerId()}",
              fit: BoxFit.cover,
            ),
          ),

          // Main Infos
          Container(
              width: screenWidth,
              height: 170.w,//screenHeight*0.18,
              decoration: BoxDecoration(
                  border: const Border(
                      bottom: BorderSide(color: Colors.white60)
                  ),
                  gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Colors.grey[850]!, Colors.grey[700]!],
                      stops: const [0.4, 0.8]
                  )
              ),
              child: Stack(
                children: [

                  // Key information
                  Column(
                    // mainAxisAlignment: MainAxisAlignment.,
                    children: [

                      // Title
                      Row(
                        children: [
                          Container(
                            // height: 60,//screenHeight*0.055,
                            // color: Colors.red,
                            alignment: Alignment.centerLeft,
                            width: screenWidth*0.8,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                top: 10,
                                left: 10
                              ),
                              child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: GestureDetector(
                                    child: Text(
                                      titleToDisplay,
                                      // textAlign: TextAlign.left,
                                      style: customTextStyle.size2BoldLightWhite(),
                                    ),
                                    onTap: (){
                                    },
                                  )
                              ),
                            ),
                          ),
                          SizedBox(
                            width: screenWidth*0.2,
                            child:                   // Price
                            Align(
                              alignment: Alignment.topRight,
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    top: 10,
                                    right: 15
                                ),
                                child: Align(
                                    alignment: Alignment.topRight,
                                    child: GestureDetector(
                                      child:Text(
                                        "${eventPrice.toString().replaceFirst(".", ",")} €",
                                        style: customTextStyle.size2BoldLightWhite(),
                                      ),
                                      onTap: (){
                                      },
                                    )
                                ),
                              ),
                            ),
                          )
                        ],
                      ),

                      // Location
                      SizedBox(
                        height: 30.w,//screenHeight*0.035,
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: 10
                          ),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: GestureDetector(
                              child: Text(
                                stateProvider.clubMeEvent.getClubName(),
                                style: customTextStyle.size3BoldLightWhite(),
                              ),
                              onTap: (){
                                // if(stateProvider.getIsEventEditable()){
                                //   showEditDialog(1, stateProvider, screenHeight, screenWidth);
                                // }
                              },
                            ),
                          ),
                        ),
                      ),

                      // DJ
                      Row(
                        children: [
                          Container(
                            // color: Colors.red,
                            // height: 30.w,//screenHeight*0.035,
                            width: screenWidth*0.7,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                // top: 3,
                                  left: 10
                              ),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: GestureDetector(
                                  child: Text(
                                      djNameToDisplay,
                                      style: customTextStyle.size4BoldGrey2()
                                  ),
                                  onTap: (){
                                  },
                                ),
                              ),
                            ),
                          )
                        ],
                      )
                    ],
                  ),

                  // When
                  Padding(
                    padding: EdgeInsets.only(
                        left: screenWidth*0.02,
                      bottom: screenHeight*0.01
                    ),
                    child: Align(
                      alignment: Alignment.bottomLeft,
                      child: GestureDetector(
                        child: Text(
                          formatDateToDisplay(),
                          style: customTextStyle.size5Bold(),
                        ),
                        onTap: (){
                          // if(stateProvider.getIsEventEditable()){
                          //   showEditDialog(6, stateProvider, screenHeight, screenWidth);
                          // }
                        },
                      ),
                    ),
                  ),

                  // Icons
                  SizedBox(
                      width: screenWidth,
                      height: screenHeight*0.21,
                      child: _buildIconRow(stateProvider, context)
                  ),

                ],
              )
          ),

          // Description
          Container(
              padding: const EdgeInsets.all(20),
              // height: screenHeight*0.4,
              width: screenWidth,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [

                    // Description headline
                    GestureDetector(
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          "Beschreibung",
                          style: customTextStyle.size3Bold(),
                        ),
                      ),
                      onTap: (){
                      },
                    ),

                    // Description content
                    GestureDetector(
                      child: Align(
                          alignment: Alignment.topLeft,
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: screenHeight*0.02
                            ),
                            child: Text(
                              stateProvider.clubMeEvent.getEventDescription(),
                              style: customTextStyle.size4(),
                            ),
                          )
                      ),
                      onTap: (){
                      },
                    ),

                    // Headline genres
                    GestureDetector(
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          "Musikrichtungen",
                          style: customTextStyle.size3Bold(),
                        ),
                      ),
                      onTap: (){
                      },
                    ),

                    GestureDetector(
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: screenHeight*0.02
                          ),
                          child: Text(
                            genresToDisplay,
                            style: customTextStyle.size4(),
                          ),
                        ),
                      ),
                      onTap: (){
                      },
                    )

                  ],
                ),
              )
          ),
        ],
      ),
    );
  }

}
