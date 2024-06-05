import 'package:club_me/models/club.dart';
import 'package:club_me/models/event.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/parser/club_me_club_parser.dart';
import '../provider/state_provider.dart';
import '../services/supabase_service.dart';
import '../shared/custom_bottom_navigation_bar.dart';
import '../shared/custom_text_style.dart';
import 'components/club_card.dart';
import 'package:timezone/standalone.dart' as tz;

class UserClubsView extends StatefulWidget {
  const UserClubsView({Key? key}) : super(key: key);

  @override
  State<UserClubsView> createState() => _UserClubsViewState();
}

class _UserClubsViewState extends State<UserClubsView>
  with TickerProviderStateMixin{

  String headline = "Deine Clubs";

  late Future getClubs;
  late String dropdownValue;
  late TabController _tabController;
  late PageController _pageViewController;
  final SupabaseService _supabaseService = SupabaseService();

  late CustomTextStyle customTextStyle;

  late double screenHeight, screenWidth;

  final TextEditingController _textEditingController = TextEditingController();

  late StateProvider stateProvider;

  bool onlyFavoritesIsActive = false;

  String searchValue = "";
  int _currentPageIndex = 0;
  bool isSearchbarActive = false;
  bool isAnyFilterActive = false;
  bool isFilterMenuActive = false;
  Color navigationBackgroundColor = const Color(0xff11181f);

  List<String> genresDropdownList = [
    "All", "Techno", "90s", "Latin"
  ];
  List<ClubMeClub> clubsToDisplay = [];


  @override
  void initState() {

    dropdownValue = genresDropdownList.first;

    _pageViewController = PageController();
    _tabController = TabController(length: 3, vsync: this);

    final stateProvider = Provider.of<StateProvider>(context, listen:  false);
    if(stateProvider.getFetchedClubs().isEmpty) {
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

  void _updateCurrentPageIndex(int index) {
    _tabController.index = index;
    _pageViewController.animateToPage(
      index,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  void filterClubs(){

    if(searchValue != "" || dropdownValue != "All" || onlyFavoritesIsActive){

      // set for coloring
      isAnyFilterActive = true;

      // reset array
      clubsToDisplay = [];

      for(ClubMeClub club in stateProvider.getFetchedClubs()){
        // when one criterium doesnt match, set to false
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
        if(dropdownValue != "All" ){
          if(!club.getMusicGenres().toLowerCase().contains(dropdownValue.toLowerCase())){
            fitsCriteria = false;
          }
        }

        if(onlyFavoritesIsActive){
          if(!stateProvider.getLikedClubs().contains(club.getClubId())){
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
      clubsToDisplay = stateProvider.getFetchedClubs();
    }
  }

  void _handlePageViewChanged(int currentPageIndex) {
    _tabController.index = currentPageIndex;
    setState(() {
      _currentPageIndex = currentPageIndex;
    });
  }

  Widget _buildSupabaseClubs(StateProvider stateProvider){

    if(stateProvider.getFetchedClubs().isEmpty ){

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
                  clubsToDisplay.add(parseClubMeClub(element));
                }
              }

              stateProvider.setFetchedClubs(clubsToDisplay);

              return SingleChildScrollView(
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                child: Column(
                  children: [
                    SizedBox(
                      height: screenHeight*0.8,
                      child: PageView(
                        controller: _pageViewController,
                        onPageChanged: _handlePageViewChanged,
                        children: <Widget>[

                          for(var club in clubsToDisplay)
                            Center(
                              child: ClubCard(
                                  events: stateProvider.getFetchedEvents().where((event){
                                    return event.getClubId() == club.getClubId();
                                  }).toList(),
                                  clubMeClub: club,
                                  triggerSetState: triggerSetState,
                                  clickedOnShare: clickedOnShare
                              ),
                            ),
                        ],
                      ),
                    )
                  ],
                ),
              );
            }
          }
      );
    }else{

      if(clubsToDisplay.isEmpty){
        for(var club in stateProvider.getFetchedClubs()){
          clubsToDisplay.add(club);
        }
      }

      filterClubs();

      return SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Column(
          children: [
            SizedBox(
              height: screenHeight*0.8,
              child: PageView(
                controller: _pageViewController,
                onPageChanged: _handlePageViewChanged,
                children: <Widget>[

                  for(var club in clubsToDisplay)
                    Center(
                      child: ClubCard(
                          events: stateProvider.getFetchedEvents().where((event){
                            return (event.getClubId() == club.getClubId() && checkIfIsEventIsAfterToday(event));
                          }).toList(),
                          clubMeClub: club,
                          triggerSetState: triggerSetState,
                          clickedOnShare: clickedOnShare
                      ),
                    ),
                ],
              ),
            )
          ],
        ),
      );
    }
  }

  bool checkIfIsEventIsAfterToday(ClubMeEvent event){
    final berlin = tz.getLocation('Europe/Berlin');
    final todayTimestampGermany = tz.TZDateTime.from(DateTime.now(), berlin);

    if(event.getEventDate().isBefore(todayTimestampGermany)){
      return false;
    }else{
      return true;
    }

  }

  void filterForFavorites(){
    setState(() {
      onlyFavoritesIsActive = !onlyFavoritesIsActive;
      filterClubs();
    });
  }

  Widget _buildAppBarShowHeadline(){
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
                  Text(headline,
                      textAlign: TextAlign.center,
                      style: customTextStyle.size2()
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
                        color: searchValue != "" ? stateProvider.getPrimeColor() : Colors.grey,
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
                      color: onlyFavoritesIsActive ? stateProvider.getPrimeColor() : Colors.grey,
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
                            color: isAnyFilterActive ? stateProvider.getPrimeColor() : Colors.grey,
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

  Widget _buildAppBarShowSearch(){
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
                  SizedBox(
                    width: screenWidth*0.4,
                    child: TextField(
                      autofocus: true,
                      controller: _textEditingController,
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
                        color: searchValue != "" ? stateProvider.getPrimeColor() : Colors.grey,
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
                      color: onlyFavoritesIsActive ? stateProvider.getPrimeColor() : Colors.grey,
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
                            color: isAnyFilterActive ? stateProvider.getPrimeColor() : Colors.grey,
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

  @override
  Widget build(BuildContext context) {

    stateProvider = Provider.of<StateProvider>(context);

    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;

    customTextStyle = CustomTextStyle(context: context);

    filterClubs();

    return Scaffold(

        // extendBodyBehindAppBar: true,
        extendBody: true,

        resizeToAvoidBottomInset: false,

        bottomNavigationBar: CustomBottomNavigationBar(),
        appBar: isSearchbarActive?
            AppBar(
              title: _buildAppBarShowSearch(),
            ):
            AppBar(
              title: _buildAppBarShowHeadline(),
            ),

        body: Container(
            width: screenWidth,
            height: screenHeight,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    // Color(0xff11181f),
                    Color(0xff2b353d),
                    Color(0xff11181f)
                  ],
                  stops: [0.15, 0.6]
              ),
            ),
            child: Stack(
              children: [

                // // Spacer
                // SizedBox(height: screenHeight*0.07,),

                // Pageview of the club cards
                SizedBox(
                    height: screenHeight*1.2,
                    // color: Colors.red,
                    child: _buildSupabaseClubs(stateProvider)
                ),

                // PageIndicator
                // SizedBox(
                //   height: screenHeight*0.07,
                //   child: PageIndicator(
                //     tabController: _tabController,
                //     currentPageIndex: _currentPageIndex,
                //     onUpdateCurrentPageIndex: _updateCurrentPageIndex,
                //   ),
                // )

                // Filter menu
                isFilterMenuActive?Container(
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

                            // SizedBox(
                            //   height: screenHeight*0.01,
                            // ),

                            const Text(
                                "Musikrichtung"
                            ),

                            DropdownButton(
                                value: dropdownValue,
                                items: genresDropdownList.map<DropdownMenuItem<String>>(
                                        (String value) {
                                      return DropdownMenuItem(
                                          value: value,
                                          child: Text(value)
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
                ):Container()
              ],
            )
        )
    );
  }

}

