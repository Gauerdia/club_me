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

  String headLine = "Kooperationen";

  late CustomStyleClass customStyleClass;
  late StateProvider stateProvider;
  late FetchedContentProvider fetchedContentProvider;
  late double screenHeight, screenWidth;

  int _currentPageIndex = 0;
  late TabController _tabController;
  late PageController _pageViewController;

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

  @override
  Widget build(BuildContext context) {
    stateProvider = Provider.of<StateProvider>(context);
    fetchedContentProvider = Provider.of<FetchedContentProvider>(context);

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    customStyleClass = CustomStyleClass(context: context);



    return Scaffold(

        extendBody: true,
        appBar: AppBar(
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
        ),
        body: Container(
            width: screenWidth,
            height: screenHeight,
            color: customStyleClass.backgroundColorMain,
            child: SingleChildScrollView(

                child: Column(
                  children: [

                    SizedBox(
                      height: screenHeight*0.03,
                    ),

                    SizedBox(
                      width: screenWidth*0.9,
                      height: screenHeight*0.7,
                      child: PageView(
                        controller: _pageViewController,
                        onPageChanged: _handlePageViewChanged,
                        children: <Widget>[

                          Image.asset(
                            "assets/images/rune_1.jpg",
                            fit: BoxFit.cover,
                          ),

                          Image.asset(
                            "assets/images/rune_2.jpg",
                          ),

                          Image.asset(
                            "assets/images/rune_3.jpg",
                          ),

                        ],
                      ),
                    ),

                    Container(
                      width: screenWidth*0.9,
                      height: screenHeight*0.1,
                      alignment: Alignment.centerRight,
                      child: InkWell(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              "Zum Online-shop",
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
                )
            )
        )
    );
  }
}
