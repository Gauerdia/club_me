import 'package:club_me/models/event.dart';
import 'package:club_me/shared/custom_bottom_navigation_bar.dart';
import 'package:club_me/shared/dialogs/TitleAndContentDialog.dart';
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

  String headline = "Events";

  late double screenHeight, screenWidth;

  late StateProvider stateProvider;
  late UserDataProvider userDataProvider;
  late FetchedContentProvider fetchedContentProvider;
  late CustomStyleClass customStyleClass;
  late CurrentAndLikedElementsProvider currentAndLikedElementsProvider;

  final HiveService _hiveService = HiveService();

  List<ClubMeEvent> eventsToDisplay = [];

  void initGeneralSettings(){
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    stateProvider = Provider.of<StateProvider>(context);
    customStyleClass = CustomStyleClass(context: context);
    userDataProvider = Provider.of<UserDataProvider>(context);
    fetchedContentProvider = Provider.of<FetchedContentProvider>(context);
    currentAndLikedElementsProvider = Provider.of<CurrentAndLikedElementsProvider>(context);
  }

  AppBar _buildAppBar(){
    return AppBar(
        surfaceTintColor: Colors.black,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        title: SizedBox(
              width: screenWidth,
              child: Stack(
                children: [

                  // Text: Headline
                  Container(
                      alignment: Alignment.bottomCenter,
                      height: 50,
                      width: screenWidth,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(headline,
                              textAlign: TextAlign.center,
                              style: customStyleClass.getFontStyle1()
                          ),
                        ],
                      )
                  ),

                  // Icon: Back
                  Container(
                      width: screenWidth,
                      alignment: Alignment.centerLeft,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            onPressed: () => clickEventBack(),
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
            )
    );
  }
  Widget _buildMainView(){
    return SizedBox(
        width: screenWidth,
        height: screenHeight,
        child: Stack(
          children: [

            // _buildListView
            SingleChildScrollView(
                physics: const ScrollPhysics(),
                child: Column(
                  children: [

                    _buildListView(),

                    // Spacer
                    SizedBox(height: screenHeight*0.1,),
                  ],
                )
            ),
          ],
        )
    );
  }
  Widget _buildListView(){
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
              clickEventLike: clickEventLike,
              clickEventShare: clickEventShare,
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

  void clickEventShare(){
    showDialog<String>(
        context: context,
        builder: (BuildContext context) =>
        TitleAndContentDialog(
            titleToDisplay: "Event teilen",
            contentToDisplay: "Die Funktion, ein Event zu teilen, ist derzeit noch "
                "nicht implementiert. Wir bitten um Verständnis.")
    );
  }
  void clickEventLike(StateProvider stateProvider, String eventId){
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

  void clickEventBack(){
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

    initGeneralSettings();
    filterEvents();

    return Scaffold(

      extendBody: true,

      appBar: _buildAppBar(),
      body: _buildMainView(),
      bottomNavigationBar: CustomBottomNavigationBar(),
    );
  }
}
