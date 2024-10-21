import 'dart:io';

import 'package:club_me/models/club.dart';
import 'package:club_me/models/event.dart';
import 'package:club_me/services/check_and_fetch_service.dart';
import 'package:club_me/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import '../../models/parser/club_me_club_parser.dart';
import '../../provider/current_and_liked_elements_provider.dart';
import '../../provider/fetched_content_provider.dart';
import '../../provider/state_provider.dart';
import '../../services/supabase_service.dart';
import '../../shared/custom_bottom_navigation_bar.dart';
import '../../shared/custom_text_style.dart';

import '../../shared/dialogs/TitleAndContentDialog.dart';
import 'components/club_card.dart';

class UserClubsView extends StatefulWidget {
  const UserClubsView({Key? key}) : super(key: key);

  @override
  State<UserClubsView> createState() => _UserClubsViewState();
}

class _UserClubsViewState extends State<UserClubsView>
  with TickerProviderStateMixin{

  var log = Logger();
  String headline = "Clubs";

  late String dropdownValue;
  late String weekDayDropDownValue;


  late StateProvider stateProvider;
  late FetchedContentProvider fetchedContentProvider;
  late CurrentAndLikedElementsProvider currentAndLikedElementsProvider;

  late double screenHeight, screenWidth;
  late CustomStyleClass customStyleClass;

  final SupabaseService _supabaseService = SupabaseService();
  final CheckAndFetchService _checkAndFetchService = CheckAndFetchService();

  late TabController _tabController;
  late PageController _pageViewController;
  final TextEditingController _textEditingController = TextEditingController();


  String searchValue = "";
  int _currentPageIndex = 0;

  bool isSearchbarActive = false;
  bool isAnyFilterActive = false;
  bool isFilterMenuActive = false;
  bool onlyFavoritesIsActive = false;

  List<String> genresDropdownList = [
    "Alle", "Latin", "Rock", "Hip-Hop", "Electronic", "Pop", "Reggaeton", "Afrobeats",
    "R&B", "House", "Techno", "Rap", "90er", "80er", "2000er",
    "Heavy Metal", "Psychedelic", "Balkan"
  ];
  List<ClubMeClub> clubsToDisplay = [];


  @override
  void initState() {

    dropdownValue = genresDropdownList.first;
    weekDayDropDownValue = Utils.weekDaysForFiltering.first;

    _pageViewController = PageController();
    _tabController = TabController(length: 3, vsync: this);

    final stateProvider = Provider.of<StateProvider>(context, listen:  false);
    final fetchedContentProvider = Provider.of<FetchedContentProvider>(context, listen:  false);
    if(fetchedContentProvider.getFetchedClubs().isEmpty) {
      _supabaseService.getAllClubs().then((data) => processClubsFromQuery(data));
    }

    super.initState();
  }
  @override
  void dispose() {
    super.dispose();
    _pageViewController.dispose();
    _tabController.dispose();
  }


  // BUILD
  Widget _buildMainView(){
   return Container(
       width: screenWidth,
       height: screenHeight,
       color: customStyleClass.backgroundColorMain,
       child: Stack(
         children: [

           // Pageview of the club cards

           SizedBox(
               height: screenHeight*1,
               width: screenWidth,
               child: clubsToDisplay.isNotEmpty?
               _buildPageView() :  (isAnyFilterActive || isSearchbarActive) ?
               SizedBox(
                 width: screenWidth,
                 height: screenHeight*0.8,
                 child: Center(
                   child: Text(
                     textAlign: TextAlign.center,
                     "Entschuldigung, im Rahmen dieser Filter sind keine Events verfügbar.",
                     style: customStyleClass.getFontStyle3(),
                   ),
                 ),
               ): onlyFavoritesIsActive ?
               SizedBox(
                 width: screenWidth,
                 height: screenHeight*0.8,
                 child: Center(
                   child: Text(
                     textAlign: TextAlign.center,
                     "Derzeit sind keine Events als Favoriten markiert.",
                     style: customStyleClass.getFontStyle3(),
                   ),
                 ),
               ):
               Center(
                 child: CircularProgressIndicator(
                   color: customStyleClass.primeColor,
                 ),
               )
           ),

           // Progress marker
           if(clubsToDisplay.isNotEmpty)
             Container(
               height: screenHeight*0.775,
               alignment: Alignment.bottomCenter,
               child: Row(
                 mainAxisAlignment: MainAxisAlignment.center,
                 children: [
                   Icon(
                     Icons.keyboard_arrow_left_sharp,
                     size: customStyleClass.navigationArrowSize,
                     color: _currentPageIndex > 0 ? customStyleClass.primeColor: Colors.grey,
                   ),
                   Icon(
                     Icons.keyboard_arrow_right_sharp,
                     size:  customStyleClass.navigationArrowSize,
                     color: _currentPageIndex < (clubsToDisplay.length-1) ? customStyleClass.primeColor: Colors.grey,
                   ),
                 ],
               ),
             ),

           // Filter menu
           if(isFilterMenuActive)_buildFilterMenu()
         ],
       )
   );
  }
  AppBar _buildAppBar(){

    return isSearchbarActive ?
    AppBar(
      backgroundColor: customStyleClass.backgroundColorMain,
      surfaceTintColor: customStyleClass.backgroundColorMain,
      title: Container(
        width: screenWidth,
        color: customStyleClass.backgroundColorMain,
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
                    SizedBox(
                      width: screenWidth*0.4,
                      child: TextField(
                        autofocus: true,
                        controller: _textEditingController,
                        cursorColor: customStyleClass.primeColor,
                        decoration: InputDecoration(
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: customStyleClass.primeColor),
                          ),
                          hintStyle: TextStyle(
                              color: customStyleClass.primeColor
                          ),
                        ),
                        style: const TextStyle(
                            color: Colors.white
                        ),
                        onChanged: (text){
                          _textEditingController.text = text;
                          searchValue = text;
                          setState(() {
                            filterClubs();
                          });
                        },
                      ),
                    ),
                  ],
                )
            ),

            // Search icon
            Container(
                width: screenWidth,
                alignment: Alignment.centerLeft,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                        onPressed: () => toggleIsSearchbarActive(),
                        icon: Icon(
                          Icons.search,
                          color: searchValue != "" ? customStyleClass.primeColor : Colors.white,
                          // size: 20,
                        )
                    )
                  ],
                )
            ),

            // Right icons
            Container(
              width: screenWidth,
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                      onPressed: () => filterForFavorites(),
                      icon: Icon(
                        onlyFavoritesIsActive? Icons.star : Icons.star_border,
                        color: onlyFavoritesIsActive ? customStyleClass.primeColor : Colors.white,
                      )
                  ),
                  Padding(
                      padding: const EdgeInsets.only(right: 0),
                      child: GestureDetector(
                        child: Container(
                            padding: const EdgeInsets.all(7),
                            child: Icon(
                              Icons.filter_alt_outlined,
                              color: isAnyFilterActive ? customStyleClass.primeColor : Colors.white,
                            )
                        ),
                        onTap: (){
                          toggleIsFilterMenuActive();
                        },
                      )
                  )
                ],
              ),
            ),

          ],
        ),
      ),
    ) :
    AppBar(
      backgroundColor: customStyleClass.backgroundColorMain,
      surfaceTintColor: customStyleClass.backgroundColorMain,
      title: Container(
        width: screenWidth,
        color: customStyleClass.backgroundColorMain,
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Row(
                          children: [
                            Text(
                                headline,
                                textAlign: TextAlign.center,
                                style: customStyleClass.getFontStyleHeadline1Bold()
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  bottom: 15
                              ),
                              child: Text(
                                "VIP",
                                style: customStyleClass.getFontStyleVIPGold(),
                              ),
                            )
                          ],
                        ),
                      ],
                    )
                  ],
                )
            ),

            // Search icon
            Container(
                width: screenWidth,
                alignment: Alignment.centerLeft,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                        onPressed: () => toggleIsSearchbarActive(),
                        icon: Icon(
                          Icons.search,
                          color: searchValue != "" ? customStyleClass.primeColor : Colors.white,
                          // size: 20,
                        )
                    )
                  ],
                )
            ),

            // Right icons
            Container(
              width: screenWidth,
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                      onPressed: () => filterForFavorites(),
                      icon: Icon(
                        onlyFavoritesIsActive ? Icons.star : Icons.star_border,
                        color: onlyFavoritesIsActive ? customStyleClass.primeColor : Colors.white,
                      )
                  ),
                  Padding(
                      padding: const EdgeInsets.only(right: 0),
                      child: GestureDetector(
                        child: Container(
                            padding: const EdgeInsets.all(7),
                            // decoration: BoxDecoration(
                            //   color: const Color(0xff11181f),
                            //   borderRadius: BorderRadius.circular(45),
                            // ),
                            child: Icon(
                              Icons.filter_alt_outlined,
                              color: isAnyFilterActive || isFilterMenuActive ? customStyleClass.primeColor : Colors.white,
                            )
                        ),
                        onTap: (){
                          toggleIsFilterMenuActive();
                        },
                      )
                  )
                ],
              ),
            ),

          ],
        ),
      ),
    );
  }
  Widget _buildPageView(){
    return SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [

          if(clubsToDisplay.isNotEmpty)
            SizedBox(
              height: screenHeight*0.73,
              width: screenWidth,
              child: PageView(
                controller: _pageViewController,
                onPageChanged: _handlePageViewChanged,
                children: <Widget>[

                  for(var club in clubsToDisplay)
                    ClubCard(
                      events: fetchedContentProvider.getFetchedEvents().where((event){
                        return (event.getClubId() == club.getClubId() && checkIfIsEventIsAfterToday(event));
                      }).toList(),
                      clubMeClub: club,
                      triggerSetState: triggerSetState,
                      clickEventShare: clickEventShare,
                    )
                ],
              ),
            ),
          if(clubsToDisplay.isEmpty)
            SizedBox(
              height: screenHeight*0.8,
              width: screenWidth,
              child: Center(
                child: Text(
                  onlyFavoritesIsActive ? "Derzeit sind keine Clubs als Favoriten markiert.":
                  "Derzeit sind keine Clubs verfügbar.",
                  style: customStyleClass.getFontStyle3(),
                )
                ,
              ),
            ),

        ],
      ),
    );
  }
  Widget _buildFilterMenu(){
    return Container(
      padding: EdgeInsets.only(
          top: screenHeight*0.02
      ),
      decoration: BoxDecoration(
          color: customStyleClass.backgroundColorMain,
          border: Border(
              bottom: BorderSide(
                  color: Colors.grey[900]!,
                  width: 1
              )
          )
      ),
      height: screenHeight*0.12,
      width: screenWidth,

      child: Row(
        children: [

          SizedBox(
            width: screenWidth*0.5,
            child: Column(
              children: [

                // Genre
                SizedBox(
                  // width: screenWidth*0.5,
                  child: Text(
                    "Wochentag",
                    textAlign: TextAlign.left,
                    style: customStyleClass.getFontStyle3(),
                  ),
                ),

                // Dropdown
                Theme(
                  data: Theme.of(context).copyWith(
                      canvasColor: customStyleClass.backgroundColorMain
                  ),
                  child:

                  DropdownMenu<String>(
                    width: 160,
                    initialSelection: weekDayDropDownValue,
                    onSelected: (String? value){
                      setState(() {
                        weekDayDropDownValue = value!;
                        filterClubs();
                      });
                    },
                    textStyle: const TextStyle(
                        color: Colors.white
                    ),
                    menuStyle: MenuStyle(
                      surfaceTintColor: WidgetStateProperty.all<Color>(customStyleClass.backgroundColorEventTile),
                      backgroundColor: WidgetStateProperty.all<Color>(customStyleClass.backgroundColorEventTile),
                      alignment: Alignment.bottomLeft,
                      maximumSize: const WidgetStatePropertyAll(
                        Size.fromHeight(300),
                      ),
                    ),
                    dropdownMenuEntries: Utils.weekDaysForFiltering
                        .map<DropdownMenuEntry<String>>((String value){
                      return DropdownMenuEntry(
                          value: value,
                          label: value,
                          style: ButtonStyle(
                              foregroundColor: WidgetStateProperty.all<Color>(Colors.white)
                          )
                      );
                    }).toList(),
                  )

                  // DropdownButton(
                  //     value: weekDayDropDownValue,
                  //     menuMaxHeight: 300,
                  //     items: Utils.weekDaysForFiltering.map<DropdownMenuItem<String>>(
                  //             (String value) {
                  //           return DropdownMenuItem(
                  //             value: value,
                  //             child: Text(
                  //               value,
                  //               style: customStyleClass.getFontStyle4Grey2(),
                  //             ),
                  //           );
                  //         }
                  //     ).toList(),
                  //     onChanged: (String? value){
                  //       setState(() {
                  //         weekDayDropDownValue = value!;
                  //         filterClubs();
                  //       });
                  //     }
                  // ),
                )


              ],
            ),
          ),

          // Genre text
          SizedBox(
            width: screenWidth*0.5,
            child: Column(
              children: [

                Text(
                  "Musikrichtung",
                  style: customStyleClass.getFontStyle3(),
                ),

                // Dropdown
                Theme(
                    data: Theme.of(context).copyWith(
                        canvasColor: customStyleClass.backgroundColorMain
                    ),
                    child:

                    DropdownMenu<String>(
                      width: 160,
                      initialSelection: dropdownValue,
                      onSelected: (String? value){
                        setState(() {
                          dropdownValue = value!;
                          filterClubs();
                        });
                      },
                      textStyle: const TextStyle(
                          color: Colors.white
                      ),
                      menuStyle: MenuStyle(
                        surfaceTintColor: WidgetStateProperty.all<Color>(customStyleClass.backgroundColorEventTile),
                        backgroundColor: WidgetStateProperty.all<Color>(customStyleClass.backgroundColorEventTile),
                        alignment: Alignment.bottomLeft,
                        maximumSize: const WidgetStatePropertyAll(
                          Size.fromHeight(200),
                        ),
                      ),
                      dropdownMenuEntries: Utils.genreListForFiltering
                          .map<DropdownMenuEntry<String>>((String value){
                        return DropdownMenuEntry(
                            value: value,
                            label: value,
                            style: ButtonStyle(
                                foregroundColor: WidgetStateProperty.all<Color>(Colors.white)
                            )
                        );
                      }).toList(),
                    )

                    // DropdownButton(
                    //     value: dropdownValue,
                    //     menuMaxHeight: 200,
                    //     items: genresDropdownList.map<DropdownMenuItem<String>>(
                    //             (String value) {
                    //           return DropdownMenuItem(
                    //               value: value,
                    //               child: Text(
                    //                 value,
                    //                 style: customStyleClass.getFontStyle4Grey2(),
                    //               )
                    //           );
                    //         }
                    //     ).toList(),
                    //     onChanged: (String? value){
                    //       setState(() {
                    //         dropdownValue = value!;
                    //         filterClubs();
                    //       });
                    //     }
                    // )
                )

              ],
            ),
          )
        ],
      ),
    );
  }


  // PROCESS
  void processClubsFromQuery(var data){

    for(var element in data){

      ClubMeClub currentClub = parseClubMeClub(element);

      if(!fetchedContentProvider.getFetchedClubs().contains(currentClub)){
        fetchedContentProvider.addClubToFetchedClubs(currentClub);
      }
    }

    // Check if we need to download the corresponding images
    _checkAndFetchService.checkAndFetchClubImages(
        fetchedContentProvider.getFetchedClubs(),
        stateProvider,
        fetchedContentProvider,
      false
    );

    filterClubs();

  }
  void processClubsFromProvider(){

  }


  // CLICKED
  void clickEventShare(){
    showDialog<String>(
        context: context,
        builder: (BuildContext context) =>
            TitleAndContentDialog(
                titleToDisplay: "Teilen",
                contentToDisplay: "Das Teilen von Inhalten aus der App ist derzeit noch nicht möglich. Wir bitten um Entschuldigung.")
    );
  }
  void triggerSetState(){
    setState(() {});
  }
  void toggleIsSearchbarActive(){
    setState(() {
      isSearchbarActive = !isSearchbarActive;
    });
  }
  void toggleIsFilterMenuActive(){
    setState(() {
      isFilterMenuActive = !isFilterMenuActive;
    });
  }


  // FILTER
  void filterClubs(){

    if(
    searchValue != "" ||
        dropdownValue != genresDropdownList[0] ||
        weekDayDropDownValue != Utils.weekDaysForFiltering[0] ||
        onlyFavoritesIsActive){

      // set for coloring
      if(dropdownValue != genresDropdownList[0] || weekDayDropDownValue != Utils.weekDaysForFiltering[0]){
        isAnyFilterActive = true;
      }else{
        isAnyFilterActive = false;
      }

      // reset array
      clubsToDisplay = [];

      for(ClubMeClub club in fetchedContentProvider.getFetchedClubs()){

        // when one criterion doesn't match, set to false
        bool fitsCriteria = true;

        // Search bar used? Then filter
        if(searchValue != "") {
          if (club.getClubName().toLowerCase().contains(
              searchValue.toLowerCase())) {
          } else {
            fitsCriteria = false;
          }
        }

        // music genre doenst match? filter
        if(dropdownValue != genresDropdownList[0] ){
          if(!club.getMusicGenres().toLowerCase().contains(dropdownValue.toLowerCase())){
            fitsCriteria = false;
          }
        }

        if(weekDayDropDownValue != Utils.weekDaysForFiltering[0]){

          int chosenDayIndex = Utils.weekDaysForFiltering.indexWhere((element) => element == weekDayDropDownValue);

          bool atleastOneDayFits = false;

          for(var days in club.getOpeningTimes().days!){

            int weekDayToCompare = days.day!;

            // Some clubs start at 0 am so we have to adjust the algorithm to consider them
            if(days.openingHour! < 10){
              weekDayToCompare = days.day! - 1;
            }

            if(weekDayToCompare == chosenDayIndex){
              atleastOneDayFits = true;
            }
          }
          if(!atleastOneDayFits) fitsCriteria = false;
        }

        if(onlyFavoritesIsActive){
          if(!currentAndLikedElementsProvider.getLikedClubs().contains(club.getClubId())){
            fitsCriteria = false;
          }
        }

        // All filter passed? evaluate
        if(fitsCriteria){
          clubsToDisplay.add(club);
        }
      }
    }else{
      isAnyFilterActive = false;
      clubsToDisplay = fetchedContentProvider.getFetchedClubs();
    }

    // Sort by priority score so that highest numbers come first
    clubsToDisplay.sort((a,b) => b.priorityScore.compareTo(a.priorityScore));

    _tabController = TabController(length: clubsToDisplay.length, vsync: this);

  }
  void filterForFavorites(){
    setState(() {
      onlyFavoritesIsActive = !onlyFavoritesIsActive;
      filterClubs();
    });
  }


  // MISC FUNCTS
  void _handlePageViewChanged(int currentPageIndex) {
    _tabController.index = currentPageIndex;
    setState(() {
      _currentPageIndex = currentPageIndex;
    });
  }
  bool checkIfIsEventIsAfterToday(ClubMeEvent event){
    // final berlin = tz.getLocation('Europe/Berlin');
    // final todayTimestampGermany = tz.TZDateTime.from(DateTime.now(), berlin);

    if(event.getEventDate().isBefore(stateProvider.getBerlinTime())){
      return false;
    }else{
      return true;
    }

  }


  @override
  Widget build(BuildContext context) {

    customStyleClass = CustomStyleClass(context: context);

    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;

    stateProvider = Provider.of<StateProvider>(context);
    fetchedContentProvider = Provider.of<FetchedContentProvider>(context);
    currentAndLikedElementsProvider = Provider.of<CurrentAndLikedElementsProvider>(context);

    filterClubs();

    return Scaffold(
      extendBody: true,
      resizeToAvoidBottomInset: false,

      appBar: _buildAppBar(),
      body: _buildMainView(),
      bottomNavigationBar: CustomBottomNavigationBar(),
    );
  }

}

