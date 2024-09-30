import 'dart:io';

import 'package:club_me/models/club.dart';
import 'package:club_me/models/event.dart';
import 'package:club_me/services/check_and_fetch_service.dart';
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

  late Future getClubs;
  late String dropdownValue;
  late StateProvider stateProvider;
  late FetchedContentProvider fetchedContentProvider;
  late TabController _tabController;
  late CustomStyleClass customStyleClass;
  late double screenHeight, screenWidth;
  late PageController _pageViewController;

  final SupabaseService _supabaseService = SupabaseService();
  final TextEditingController _textEditingController = TextEditingController();
  final CheckAndFetchService checkAndFetchService = CheckAndFetchService();

  String searchValue = "";
  int _currentPageIndex = 0;
  late CurrentAndLikedElementsProvider currentAndLikedElementsProvider;

  bool isSearchbarActive = false;
  bool isAnyFilterActive = false;
  bool isFilterMenuActive = false;
  bool onlyFavoritesIsActive = false;

  Color navigationBackgroundColor = const Color(0xff11181f);

  List<String> genresDropdownList = [
    "Alle", "Latin", "Rock", "Hip-Hop", "Electronic", "Pop", "Reggaeton", "Afrobeats",
    "R&B", "House", "Techno", "Rap", "90er", "80er", "2000er",
    "Heavy Metal", "Psychedelic", "Balkan"
  ];
  List<ClubMeClub> clubsToDisplay = [];

  BoxDecoration gradientDecoration = const BoxDecoration(
    gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xff2b353d),
          Color(0xff11181f)
        ],
        stops: [0.15, 0.6]
    ),
  );
  BoxDecoration plainBlackDecoration = const BoxDecoration(
      color: Colors.black,
      // image: DecorationImage(image: AssetImage("assets/images/club_me_icon_round.png"))
  );

  @override
  void initState() {

    dropdownValue = genresDropdownList.first;

    _pageViewController = PageController();
    _tabController = TabController(length: 3, vsync: this);

    final stateProvider = Provider.of<StateProvider>(context, listen:  false);
    final fetchedContentProvider = Provider.of<FetchedContentProvider>(context, listen:  false);
    if(fetchedContentProvider.getFetchedClubs().isEmpty) {
      getClubs = _supabaseService.getAllClubs();
    }

    super.initState();
  }
  @override
  void dispose() {
    super.dispose();
    _pageViewController.dispose();
    _tabController.dispose();
  }


  // CLICKED
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

    if(searchValue != "" || dropdownValue != genresDropdownList[0] || onlyFavoritesIsActive){

      // set for coloring
      if(dropdownValue != genresDropdownList[0]){
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
          print("Search: ${club.getClubName().toLowerCase()}, Term: ${searchValue.toLowerCase()}");
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


  // BUILD
  Widget _buildAppBarShowSearch(){
    return Container(
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
                        color: searchValue != "" ? customStyleClass.primeColor : Colors.grey,
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
    );
  }
  Widget _buildAppBarShowHeadline(){
    return Container(
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
                        color: searchValue != "" ? customStyleClass.primeColor : Colors.grey,
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
    );
  }
  Widget _buildSupabaseClubs(StateProvider stateProvider){

    if(fetchedContentProvider.getFetchedClubs().isEmpty ){

      return FutureBuilder(
          future: getClubs,
          builder: (context, snapshot){

            if(snapshot.hasError){
              print("Error: ${snapshot.error}");
            }

            if(!snapshot.hasData){
              return Center(
                child: CircularProgressIndicator(
                  color: customStyleClass.primeColor,
                ),
              );
            }else{

              final data = snapshot.data!;

              List<ClubMeClub> fetchedClubMeClubs = [];

              for(var element in data){
                ClubMeClub currentClub = parseClubMeClub(element);
                fetchedClubMeClubs.add(currentClub);
              }

              if(clubsToDisplay.isEmpty){
                checkAndFetchService.checkAndFetchClubImages(
                    fetchedClubMeClubs,
                    stateProvider,
                    fetchedContentProvider);
              }

              filterClubs();

              fetchedContentProvider.setFetchedClubs(fetchedClubMeClubs);

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
                                clickedOnShare: clickedOnShare,
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
          }
      );
    }else{

      if(clubsToDisplay.isEmpty){
        checkAndFetchService.checkAndFetchClubImages(
            fetchedContentProvider.getFetchedClubs(),
            stateProvider,
            fetchedContentProvider
        );
      }else{
        checkAndFetchService.checkAndFetchClubImages(
            clubsToDisplay,
            stateProvider,
            fetchedContentProvider
        );
      }

      filterClubs();

      return SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [

            if(clubsToDisplay.isNotEmpty)
            Container(
              height: screenHeight*0.73,
              width: screenWidth,
              child: PageView(
                controller: _pageViewController,
                onPageChanged: _handlePageViewChanged,
                children: <Widget>[

                  for(var club in clubsToDisplay)
                    Center(
                      child: ClubCard(
                        events: fetchedContentProvider.getFetchedEvents().where((event){
                          return (event.getClubId() == club.getClubId() && checkIfIsEventIsAfterToday(event));
                        }).toList(),
                        clubMeClub: club,
                        triggerSetState: triggerSetState,
                        clickedOnShare: clickedOnShare
                      ),
                    ),
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
                  ),
                ),
              ),
          ],
        ),
      );
    }
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
            width: screenWidth*1,
            child: Column(
              children: [

                // Genre text
                Text(
                    "Musikrichtung",
                  style: customStyleClass.getFontStyle3(),
                ),

                // Dropdown
                Theme(
                    data: Theme.of(context).copyWith(
                        canvasColor: customStyleClass.backgroundColorMain
                    ),
                    child: DropdownButton(
                        value: dropdownValue,
                        menuMaxHeight: 200,
                        items: genresDropdownList.map<DropdownMenuItem<String>>(
                                (String value) {
                              return DropdownMenuItem(
                                  value: value,
                                  child: Text(
                                    value,
                                    style: customStyleClass.getFontStyle4Grey2(),
                                  )
                              );
                            }
                        ).toList(),
                        onChanged: (String? value){
                          setState(() {
                            dropdownValue = value!;
                            filterClubs();
                          });
                        }
                    )
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    stateProvider = Provider.of<StateProvider>(context);
    fetchedContentProvider = Provider.of<FetchedContentProvider>(context);
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    currentAndLikedElementsProvider = Provider.of<CurrentAndLikedElementsProvider>(context);
    customStyleClass = CustomStyleClass(context: context);

    filterClubs();

    return Scaffold(

      extendBody: true,
      resizeToAvoidBottomInset: false,

      appBar: isSearchbarActive ?
            AppBar(
              backgroundColor: customStyleClass.backgroundColorMain,
              surfaceTintColor: customStyleClass.backgroundColorMain,
              title: _buildAppBarShowSearch(),
            ) :
            AppBar(
              backgroundColor: customStyleClass.backgroundColorMain,
              surfaceTintColor: customStyleClass.backgroundColorMain,
              title: _buildAppBarShowHeadline(),
            ),

      body: Container(
            width: screenWidth,
            height: screenHeight,
            color: customStyleClass.backgroundColorMain,
            child: Stack(
              children: [

                // Pageview of the club cards
                SizedBox(
                    height: screenHeight*1,
                    child: _buildSupabaseClubs(stateProvider)
                ),

                // Progress marker
                if(clubsToDisplay.isNotEmpty)
                  Container(
                    height: screenHeight*0.77,
                    alignment: Alignment.bottomCenter,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.keyboard_arrow_left_sharp,
                          size: 50,
                          color: _currentPageIndex > 0 ? customStyleClass.primeColor: Colors.grey,
                        ),
                        Icon(
                          Icons.keyboard_arrow_right_sharp,
                          size: 50,
                          color: _currentPageIndex < (clubsToDisplay.length-1) ? customStyleClass.primeColor: Colors.grey,
                        ),
                      ],
                    ),
                  ),

                // Filter menu
                if(isFilterMenuActive)_buildFilterMenu()
              ],
            )
        ),

      bottomNavigationBar: CustomBottomNavigationBar(),
    );
  }

}

