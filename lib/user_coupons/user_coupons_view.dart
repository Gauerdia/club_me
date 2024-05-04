  import 'package:club_me/models/discount.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../provider/state_provider.dart';
import '../shared/custom_bottom_navigation_bar.dart';
import '../user_clubs/user_clubs_view.dart';

class UserCouponsView extends StatefulWidget {
  const UserCouponsView({Key? key}) : super(key: key);

  @override
  State<UserCouponsView> createState() => _UserCouponsViewState();
}

class _UserCouponsViewState extends State<UserCouponsView>
    with TickerProviderStateMixin{


  String headline = "Discounts for You";


  late PageController _pageViewController;
  late TabController _tabController;
  int _currentPageIndex = 0;

  List<ClubMeDiscount> discounts = [
    ClubMeDiscount(
        clubName: "Untergrund Bochum",
        title: "2 für 1: Moscow Mules!",
        numberOfUsages: 1,
        validUntil: "Bis 24.05.2024",
      imagePath: "assets/images/img_5.png"
    ),
    ClubMeDiscount(
        clubName: "Village Dortmund",
        title: "Frauen free entry!",
        numberOfUsages: 1,
        validUntil: "Bis 24.05.2024",
        imagePath: "assets/images/img_6.png"
    ),
  ];



  @override
  void initState() {
    super.initState();
    _pageViewController = PageController();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    _pageViewController.dispose();
    _tabController.dispose();
  }

  void _handlePageViewChanged(int currentPageIndex) {
    _tabController.index = currentPageIndex;
    setState(() {
      _currentPageIndex = currentPageIndex;
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

  @override
  Widget build(BuildContext context) {

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(

        extendBodyBehindAppBar: true,
        extendBody: true,

        bottomNavigationBar: CustomBottomNavigationBar(),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Text(headline),
          leading: Icon(
            Icons.search,
            color: Colors.grey,
            // size: 20,
          ),
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
          child: Column(
            children: [

              // Spacer
              SizedBox(height: screenHeight*0.17,),

              // Pageview of the club cards
              Container(
                height: screenHeight*0.615,
                color: Colors.transparent,
                // color: Colors.red,
                child: PageView(
                  /// [PageView.scrollDirection] defaults to [Axis.horizontal].
                  /// Use [Axis.vertical] to scroll vertically.
                  controller: _pageViewController,
                  onPageChanged: _handlePageViewChanged,
                  children: <Widget>[
                    Center(
                      child: Container(
                        child: CouponCard(clubMeDiscount: discounts[0],),
                      ),
                    ),
                    Center(
                      child: Container(
                        child: CouponCard(clubMeDiscount: discounts[1],),
                      ),
                    ),
                    Center(
                      child: Text('Third Page', style: TextStyle()),
                    ),
                  ],
                ),
              ),

              // SizedBox(height: screenHeight*0.07,),

              PageIndicator(
                tabController: _tabController,
                currentPageIndex: _currentPageIndex,
                onUpdateCurrentPageIndex: _updateCurrentPageIndex,
              ),
            ],
          )
        )
    );
  }
}

class CouponCard extends StatelessWidget {
  CouponCard({Key? key, required this.clubMeDiscount}) : super(key: key);

  ClubMeDiscount clubMeDiscount;

  @override
  Widget build(BuildContext context) {

    final stateProvider = Provider.of<StateProvider>(context);

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    String validText = clubMeDiscount.getNumberOfUsages().toString() + " Mal";

    return Card(
      child: Column(
        children: [

          // TODO: No matter which image: Everything should be cropped the same

          // Image container
          Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(12),
                    topLeft: Radius.circular(12)
                ),
                border: Border(
                  // top: BorderSide(
                  //     width: 1, color: Colors.white60
                  // ),
                  left: BorderSide(
                      width: 1, color: Colors.white60
                  ),
                  right: BorderSide(
                      width: 1, color: Colors.white60
                  ),
                ),
              ),
              child: Container(
                  height: screenHeight*0.4,
                  child: Stack(
                    children: [

                      // Image
                      Container(
                        height: screenHeight*0.4,
                        child: ClipRRect(
                          borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(12),
                              topLeft: Radius.circular(12)
                          ),
                          child: Image.asset(
                            clubMeDiscount.getImagePath(),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),

                      // Shadow to highlight icons
                      Container(
                        height: screenHeight*0.15,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.black, Colors.transparent]
                          ),
                          borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(12),
                              topLeft: Radius.circular(12)
                          ),
                        ),
                      ),

                      // Icons
                      Padding(padding: EdgeInsets.only(top: screenHeight*0.02),
                      child: const Align(
                          alignment: Alignment.topRight,
                          child: Column(
                            // mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    color: Colors.purpleAccent,
                                  ),
                                  SizedBox(width: 15,),
                                  Icon(
                                    Icons.star_border,
                                    color: Colors.purpleAccent,
                                  ),
                                  SizedBox(width: 15,),
                                  Icon(
                                    Icons.share,
                                    color: Colors.purpleAccent,
                                  ),
                                  SizedBox(width: 25,),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    "Info",
                                    style: TextStyle(
                                        fontSize: 12
                                    ),
                                  ),
                                  SizedBox(width: 12,),
                                  Text(
                                    "Like",
                                    style: TextStyle(
                                        fontSize: 12
                                    ),
                                  ),
                                  SizedBox(width: 10,),
                                  Text(
                                    "Share",
                                    style: TextStyle(
                                        fontSize: 12
                                    ),
                                  ),
                                  SizedBox(width: 18,),
                                ],
                              ),
                              SizedBox(
                                height: 10,
                              )
                            ],
                          )
                      ),
                      )
                    ],
                  )
              )
          ),


          // Content container
          Container(
              height: screenHeight*0.2,
              width: screenWidth,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                    bottomRight: Radius.circular(12),
                    bottomLeft: Radius.circular(12)
                ),
                border: const Border(
                  // bottom: BorderSide(
                  //     width: 1, color: Colors.white60
                  // ),
                  left: BorderSide(
                      width: 1, color: Colors.white60
                  ),
                  right: BorderSide(
                      width: 1, color: Colors.white60
                  ),
                ),
                // color: Colors.grey[800]
                gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.grey[700]!,
                      Colors.grey[850]!
                    ],
                    stops: [0.3, 0.8]
                ),
              ),
              child: Stack(
                children: [
                  Column(
                    children: [

                      // Title
                      Padding(
                        padding: EdgeInsets.only(
                            top: 10,
                            left: 10
                        ),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            clubMeDiscount.getTitle(),
                            style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold
                            ),
                          ),
                        ),
                      ),

                      // Location
                      Padding(
                        padding: EdgeInsets.only(
                          // top: 5,
                            left: 10
                        ),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            clubMeDiscount.getClubName(),
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold
                            ),
                          ),
                        ),
                      ),

                      // When
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 3,
                            left: 10
                        ),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            clubMeDiscount.getValidUntil(),
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[400]
                            ),
                          ),
                        ),
                      ),

                    ],
                  ),

                  // How often
                  Padding(
                    padding: EdgeInsets.only(left: 7, bottom: 7),
                    child: Align(
                      alignment: Alignment.bottomLeft,
                      child: GestureDetector(
                        child: Container(
                          decoration: const BoxDecoration(
                              color: Color(0xff11181f),
                              borderRadius: BorderRadius.all(
                                  Radius.circular(10)
                              )
                          ),
                          padding: EdgeInsets.all(10),
                          child: Text(
                            validText,
                            style: TextStyle(
                                color: Colors.white70,
                                fontWeight: FontWeight.bold,
                                fontSize: 14
                            ),
                          ),
                        ),
                        onTap: (){

                        },
                      ),
                    ),
                  ),

                  // Button
                  Padding(
                    padding: EdgeInsets.only(right: 7, bottom: 7),
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: GestureDetector(
                        child: Container(
                          decoration: const BoxDecoration(
                              color: Color(0xff11181f),
                              borderRadius: BorderRadius.all(
                                  Radius.circular(10)
                              )
                          ),
                          padding: EdgeInsets.all(10),
                          child: const Text(
                            "Einlösen!",
                            style: TextStyle(
                                color: Colors.purpleAccent,
                                fontWeight: FontWeight.bold,
                              fontSize: 20
                            ),
                          ),
                        ),
                        onTap: (){
                          stateProvider.setCurrentDiscount(clubMeDiscount);
                          context.go('/coupon_details');
                        },
                      ),
                    ),
                  )

                ],
              )
          )
        ],
      ),
    );
  }
}
