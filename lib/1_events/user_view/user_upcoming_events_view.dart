import 'package:club_me/models/event.dart';
import 'package:club_me/shared/custom_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../provider/current_and_liked_elements_provider.dart';
import '../../provider/fetched_content_provider.dart';
import '../../provider/state_provider.dart';
import '../../provider/user_data_provider.dart';
import '../../services/hive_service.dart';
import '../../shared/custom_text_style.dart';
import 'components/event_tile.dart';

class UserUpcomingEventsView extends StatefulWidget {
  const UserUpcomingEventsView({super.key});

  @override
  State<UserUpcomingEventsView> createState() => _UserUpcomingEventsViewState();
}

class _UserUpcomingEventsViewState extends State<UserUpcomingEventsView> {

  String headLine = "Events";

  late double screenHeight, screenWidth;

  late StateProvider stateProvider;
  late UserDataProvider userDataProvider;
  late FetchedContentProvider fetchedContentProvider;
  late CustomStyleClass customStyleClass;
  late CurrentAndLikedElementsProvider currentAndLikedElementsProvider;

  final HiveService _hiveService = HiveService();

  List<ClubMeEvent> eventsToDisplay = [];

  Widget _buildAppBarShowTitle(){
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
                  Text(headLine,
                      textAlign: TextAlign.center,
                      style: customStyleClass.getFontStyle1()
                  ),
                ],
              )
          ),

          // back icon
          Container(
              width: screenWidth,
              alignment: Alignment.centerLeft,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    onPressed: () => backButtonPressed(),
                    icon: const Icon(
                      Icons.arrow_back_ios_new_outlined,
                      color: Colors.grey,
                      // size: 20,
                    ),
                  )
                ],
              )
          ),
        ],
      ),
    );
  }

  Widget _buildView(){
    return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: eventsToDisplay.length,
        itemBuilder: ((context, index){

          ClubMeEvent currentEvent = eventsToDisplay[index];

          var isLiked = false;
          if(currentAndLikedElementsProvider.getLikedEvents().contains(currentEvent.getEventId())){
            isLiked = true;
          }

          return GestureDetector(
            child: EventTile(
              clubMeEvent: currentEvent,
              isLiked: isLiked,
              clickEventLike: clickedOnLike,
              clickEventShare: clickedOnShare,
            ),
            onTap: (){
              stateProvider.setAccessedEventDetailFrom(4);
              currentAndLikedElementsProvider.setCurrentEvent(currentEvent);
              context.go('/event_details');
            },
          );

        })
    );
  }

  void clickedOnShare(){
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
    setState(() {
      if(currentAndLikedElementsProvider.getLikedEvents().contains(eventId)){
        currentAndLikedElementsProvider.deleteLikedEvent(eventId);
        _hiveService.deleteFavoriteEvent(eventId);
      }else{
        currentAndLikedElementsProvider.addLikedEvent(eventId);
        _hiveService.insertFavoriteEvent(eventId);
      }
    });
  }

  void backButtonPressed(){
    context.go("/club_details");
  }

  void filterEvents(){

    eventsToDisplay = fetchedContentProvider.getFetchedEvents()
        .where((event){
      return (event.getClubId() == currentAndLikedElementsProvider.currentClubMeClub.getClubId() && checkIfIsEventIsAfterToday(event));
    }).toList();


  }

  bool checkIfIsEventIsAfterToday(ClubMeEvent event){
    if(event.getEventDate().isBefore(stateProvider.getBerlinTime())){
      return false;
    }else{
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    stateProvider = Provider.of<StateProvider>(context);
    customStyleClass = CustomStyleClass(context: context);
    userDataProvider = Provider.of<UserDataProvider>(context);
    fetchedContentProvider = Provider.of<FetchedContentProvider>(context);
    currentAndLikedElementsProvider = Provider.of<CurrentAndLikedElementsProvider>(context);

    filterEvents();

    return Scaffold(

      extendBody: true,


      appBar: AppBar(
          surfaceTintColor: Colors.black,
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          title: _buildAppBarShowTitle()
      ),
      body: SizedBox(
          width: screenWidth,
          height: screenHeight,
          child: Stack(
            children: [

              // main view
              SingleChildScrollView(
                  physics: const ScrollPhysics(),
                  child: Column(
                    children: [

                      _buildView(),

                      // Spacer
                      SizedBox(height: screenHeight*0.1,),
                    ],
                  )
              ),
            ],
          )
      ),
      bottomNavigationBar: CustomBottomNavigationBar(),
    );
  }
}
