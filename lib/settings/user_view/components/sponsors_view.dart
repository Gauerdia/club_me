import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../provider/fetched_content_provider.dart';
import '../../../provider/state_provider.dart';
import '../../../shared/custom_text_style.dart';

class SponsorsView extends StatefulWidget {
  const SponsorsView({super.key});

  @override
  State<SponsorsView> createState() => _SponsorsViewState();
}

class _SponsorsViewState extends State<SponsorsView>
    with TickerProviderStateMixin{

  String headLine = "Kooperationspartner";

  late CustomStyleClass customStyleClass;
  late StateProvider stateProvider;
  late FetchedContentProvider fetchedContentProvider;
  late double screenHeight, screenWidth;

  int _currentPageIndex = 0;
  late TabController _tabController;
  late PageController _pageViewController;

  int imageToShowIndex = 0;
  bool showImageFullScreen = false;

  @override
  void initState() {
    super.initState();
    _pageViewController = PageController();
    _tabController = TabController(length: 3, vsync: this);
  }

  void _handlePageViewChanged(int currentPageIndex) {
    _tabController.index = currentPageIndex;
    setState(() {
      _currentPageIndex = currentPageIndex;
    });
  }

  Future<void> clickEventShopLink() async {

    final Uri url = Uri.parse("https://shop.runesvodka.com/");
    if (!await launchUrl(url)) {
    throw Exception('Could not launch $url');
    }

  }

  AppBar _buildAppBar(){
    return AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: customStyleClass.backgroundColorMain,
        surfaceTintColor: customStyleClass.backgroundColorMain,
        title: SizedBox(
          width: screenWidth,
          child: Stack(
            children: [

              // Headline
              Container(
                  alignment: Alignment.bottomCenter,
                  height: screenHeight*0.2,
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
                                  headLine,
                                  textAlign: TextAlign.center,
                                  style: customStyleClass.getFontStyleHeadline1Bold()
                              ),
                            ],
                          ),
                        ],
                      )
                    ],
                  )
              ),


              // back icon
              Container(
                  width: screenWidth,
                  height: screenHeight*0.2,
                  // color: Colors.red,
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white,
                        // size: 20,
                      )
                  )
              ),

            ],
          ),
        )
    );
  }

  void resetDetailView(){
    setState(() {
      showImageFullScreen = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    stateProvider = Provider.of<StateProvider>(context);
    fetchedContentProvider = Provider.of<FetchedContentProvider>(context);

    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;

    customStyleClass = CustomStyleClass(context: context);



    return Scaffold(

        extendBody: true,
        appBar: _buildAppBar(),
        body: Container(
            width: screenWidth,
            height: screenHeight,
            color: customStyleClass.backgroundColorMain,
            child: Stack(

              children: [

                // MAIN CONTENT
                Center(
                  child:  SingleChildScrollView(
                    child: Column(
                      children: [



                        SizedBox(
                          height: screenHeight*0.03,
                        ),

                        SizedBox(
                          width: screenWidth*0.81,
                          height: screenHeight*0.55,
                          child: Image.asset(
                            "assets/images/runes_info_2.PNG",
                            fit: BoxFit.cover,
                          ),
                        ),

                        Container(
                          padding: EdgeInsets.only(
                            top: 10
                          ),
                          width: screenWidth*0.8,
                          height: screenHeight*0.2,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              InkWell(
                                child: Image.asset(
                                  "assets/images/rune_1.jpg",
                                ),
                                onTap: (){
                                  setState(() {
                                    imageToShowIndex = 0;
                                    showImageFullScreen = true;
                                  });
                                },
                              ),

                              InkWell(
                                child: Image.asset(
                                  "assets/images/rune_2.jpg",
                                ),
                                onTap: (){
                                  setState(() {
                                    imageToShowIndex = 1;
                                    showImageFullScreen = true;
                                  });
                                },
                              ),


                              InkWell(
                                child: Image.asset(
                                  "assets/images/rune_3.jpg",
                                ),
                                onTap: (){
                                  setState(() {
                                    imageToShowIndex = 2;
                                    showImageFullScreen = true;
                                  });
                                },
                              ),


                            ],
                          ),
                        ),

                        Container(
                          width: screenWidth*0.8,
                          height: screenHeight*0.1,
                          alignment: Alignment.centerRight,
                          child: InkWell(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  "Zum Online-Shop",
                                  style: customStyleClass.getFontStyle3BoldPrimeColor(),
                                ),
                                Icon(
                                  Icons.arrow_forward_outlined,
                                  color: customStyleClass.primeColor,
                                )
                              ],
                            ),
                            onTap: () => clickEventShopLink(),
                          ),
                        ),


                      ],
                    ),
                  ),
                ),

                // DETAIL VIEW
                if(showImageFullScreen)
                InkWell(
                  child: Container(
                    width: screenWidth,
                    height: screenHeight,
                    color: Colors.black.withOpacity(0.6),
                    child: Center(
                      child: SizedBox(
                        width: screenWidth*0.85,
                        height: screenHeight*0.85,
                        child: Image.asset(
                            imageToShowIndex == 0 ? "assets/images/rune_1.jpg" :
                            imageToShowIndex == 1 ? "assets/images/rune_2.jpg":
                            "assets/images/rune_3.jpg"
                        ),
                      ),
                    ),
                  ),
                  onTap: () => resetDetailView(),
                )
              ],


            )
        )
    );
  }
}
