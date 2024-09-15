import 'dart:io';

import 'package:club_me/models/club.dart';
import 'package:club_me/models/event.dart';
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
  String headline = "Deine Clubs";

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

  String searchValue = "";
  int _currentPageIndex = 0;
  late CurrentAndLikedElementsProvider currentAndLikedElementsProvider;

  bool isSearchbarActive = false;
  bool isAnyFilterActive = false;
  bool isFilterMenuActive = false;
  bool onlyFavoritesIsActive = false;

  Color navigationBackgroundColor = const Color(0xff11181f);

  List<String> genresDropdownList = [
    "Alle", "Techno", "90s", "Latin"
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
      if(dropdownValue != genresDropdownList[0] || onlyFavoritesIsActive){
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
      color: Colors.black,
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
                      Icons.stars,
                      color: onlyFavoritesIsActive ? customStyleClass.primeColor : Colors.grey,
                    )
                ),
                Padding(
                    padding: const EdgeInsets.only(right: 0),
                    child: GestureDetector(
                      child: Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: const Color(0xff11181f),
                            borderRadius: BorderRadius.circular(45),
                          ),
                          child: Icon(
                            Icons.filter_list_sharp,
                            color: isAnyFilterActive ? customStyleClass.primeColor : Colors.grey,
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
      color: Colors.black,
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
                  Text(headline,
                      textAlign: TextAlign.center,
                      style: customStyleClass.getFontStyle1()
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
                      Icons.stars,
                      color: onlyFavoritesIsActive ? customStyleClass.primeColor : Colors.grey,
                    )
                ),
                Padding(
                    padding: const EdgeInsets.only(right: 0),
                    child: GestureDetector(
                      child: Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: const Color(0xff11181f),
                            borderRadius: BorderRadius.circular(45),
                          ),
                          child: Icon(
                            Icons.filter_list_sharp,
                            color: isAnyFilterActive ? customStyleClass.primeColor : Colors.grey,
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
              return const Center(
                child: CircularProgressIndicator(),
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
                      print("_buildSupabaseClubs: doesnt exist");
                        fetchAndSaveBannerImage(currentClub.getBannerId());

                    }else{
                      if(!fetchedContentProvider.getFetchedBannerImageIds().contains(currentClub.getBannerId())){
                        print("_buildSupabaseClubs: exists");
                        fetchedContentProvider.addFetchedBannerImageId(currentClub.getBannerId());
                      }
                    }
                  });
                }
              }

              filterClubs();

              fetchedContentProvider.setFetchedClubs(clubsToDisplay);

              return SingleChildScrollView(
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
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
                    )

                  ],
                ),
              );
            }
          }
      );
    }
    else{

      if(clubsToDisplay.isEmpty){
        for(var club in fetchedContentProvider.getFetchedClubs()){
          clubsToDisplay.add(club);
          if(!fetchedContentProvider.getFetchedBannerImageIds().contains(club.getBannerId()))
            {
              print("_buildSupabaseClubs, fetchedclubs not empty, clubsToDisplay empty");
              // fetchedContentProvider.addFetchedBannerImageId(club.getBannerId());
            }
        }
      }else{
        for(var club in clubsToDisplay){
          if(!fetchedContentProvider.getFetchedBannerImageIds().contains(club.getBannerId()))
          {
            fetchedContentProvider.addFetchedBannerImageId(club.getBannerId());
          }
        }
      }

      filterClubs();

      return SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [

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

          ],
        ),
      );
    }
  }

  void fetchAndSaveBannerImage(String fileName) async {
    var imageFile = await _supabaseService.getBannerImage(fileName);

    final String dirPath = stateProvider.appDocumentsDir.path;

    await File("$dirPath/$fileName").writeAsBytes(imageFile).then((onValue){
      setState(() {
        print("_buildSupabaseClubs: fetchAndSaveBannerImage");
        log.d("fetchAndSaveBannerImage: Finished successfully. Path: $dirPath/$fileName");
        fetchedContentProvider.addFetchedBannerImageId(fileName);
      });
    });
  }

  Future<bool> checkIfImageExistsLocally(String fileName) async{
    final String dirPath = stateProvider.appDocumentsDir.path;
    return await File('$dirPath/$fileName').exists();
  }

  Widget _buildFilterMenu(){
    return Container(
      padding: EdgeInsets.only(
          top: screenHeight*0.02
      ),
      height: screenHeight*0.12,
      width: screenWidth,
      color: const Color(0xff2b353d),
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
                DropdownButton(
                    value: dropdownValue,
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
              backgroundColor: Colors.transparent,
              title: _buildAppBarShowSearch(),
            ) :
            AppBar(
              backgroundColor: Colors.transparent,
              title: _buildAppBarShowHeadline(),
            ),

      body: Container(
            width: screenWidth,
            height: screenHeight,
            decoration: plainBlackDecoration,
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
                    height: screenHeight*0.78,
                    // color: Colors.red,
                    alignment: Alignment.bottomCenter,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.keyboard_arrow_left_sharp,
                          size: 50,
                          color: _currentPageIndex > 0 ? Colors.white: Colors.grey,
                        ),
                        Icon(
                          Icons.keyboard_arrow_right_sharp,
                          size: 50,
                          color: _currentPageIndex < (clubsToDisplay.length-1) ? Colors.white: Colors.grey,
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

