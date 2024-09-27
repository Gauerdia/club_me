import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../provider/fetched_content_provider.dart';
import '../../provider/state_provider.dart';
import '../../services/hive_service.dart';
import '../../shared/custom_bottom_navigation_bar.dart';
import '../../shared/custom_bottom_navigation_bar_clubs.dart';
import '../../shared/custom_text_style.dart';

class SettingsUserView extends StatefulWidget {
  const SettingsUserView({super.key});

  @override
  State<SettingsUserView> createState() => _SettingsUserViewState();
}

class _SettingsUserViewState extends State<SettingsUserView> {


  String headLine = "Einstellungen";

  late StateProvider stateProvider;
  late FetchedContentProvider fetchedContentProvider;
  late double screenHeight, screenWidth;

  final HiveService _hiveService = HiveService();

  late CustomStyleClass customStyleClass;

  void clickEventFAQ(){
    context.push("/user_faq");
  }
  void clickEventContact(){

  }
  void clickEventRateUs(){

  }
  void clickEventShare(){

  }
  void clickEventNotifications(){

  }
  void clickEventImpressum(){

  }
  void clickEventAGB(){

  }
  void clickEventPrivacy(){

  }
  void clickEventSponsors(){

  }
  void clickEventLogOut(){
    fetchedContentProvider.setFetchedEvents([]);
    fetchedContentProvider.setFetchedDiscounts([]);
    fetchedContentProvider.setFetchedClubs([]);
    stateProvider.setClubUiActive(false);
    stateProvider.setPageIndex(0);
    stateProvider.activeLogOut = false;
    _hiveService.resetUserData().then((value) => context.go("/log_in"));
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
                  InkWell(
                    child: Container(
                        width: screenWidth,
                        height: screenHeight*0.2,
                        // color: Colors.red,
                        alignment: Alignment.centerLeft,
                        child: const Icon(
                          Icons.arrow_back_ios,
                          color: Colors.white,
                          // size: 20,
                        )
                    ),
                    onTap: () => Navigator.pop(context),
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

                    InkWell(
                      child: Container(
                        width: screenWidth*0.9,
                        padding: const EdgeInsets.only(
                            top: 20
                        ),
                        child: Row(
                          children: [
                            IconButton(onPressed: () => clickEventFAQ(), icon: Icon(
                              Icons.question_mark,
                              color: customStyleClass.primeColor,
                              size: 25,
                            )),
                            SizedBox(
                              width: screenWidth*0.02,
                            ),
                            Text(
                              "FAQ",
                              style: customStyleClass.getFontStyle1(),
                            )
                          ],
                        ),
                      ),
                      onTap: () => clickEventFAQ(),
                    ),

                    SizedBox(
                      width: screenWidth*0.9,
                      child: Row(
                        children: [
                          IconButton(
                              onPressed: () => clickEventContact(),
                              icon: Icon(
                                Icons.mail,
                                color: customStyleClass.primeColor,
                                size: 25,
                              )),
                          SizedBox(
                            width: screenWidth*0.02,
                          ),
                          Text(
                            "Kontakt",
                            style: customStyleClass.getFontStyle1(),
                          )
                        ],
                      ),
                    ),

                    SizedBox(
                      width: screenWidth*0.9,
                      child: Row(
                        children: [
                          IconButton(onPressed: () => clickEventRateUs(), icon: Icon(
                            Icons.star,
                            color: customStyleClass.primeColor,
                            size: 25,
                          )),
                          SizedBox(
                            width: screenWidth*0.02,
                          ),
                          Text(
                            "Bewerten",
                            style: customStyleClass.getFontStyle1(),
                          )
                        ],
                      ),
                    ),

                    SizedBox(
                      width: screenWidth*0.9,
                      child: Row(
                        children: [
                          IconButton(onPressed: () => clickEventShare(), icon: Icon(
                            Icons.share,
                            color: customStyleClass.primeColor,
                            size: 25,
                          )),
                          SizedBox(
                            width: screenWidth*0.02,
                          ),
                          Text(
                            "Teilen",
                            style: customStyleClass.getFontStyle1(),
                          )
                        ],
                      ),
                    ),

                    SizedBox(
                      width: screenWidth*0.9,
                      child: Row(
                        children: [
                          IconButton(onPressed: () => clickEventNotifications(), icon: Icon(
                            Icons.notification_important_rounded,
                            color: customStyleClass.primeColor,
                            size: 25,
                          )),
                          SizedBox(
                            width: screenWidth*0.02,
                          ),
                          Text(
                            "Benachrichtigungen",
                            style: customStyleClass.getFontStyle1(),
                          )
                        ],
                      ),
                    ),

                    SizedBox(
                      width: screenWidth*0.9,
                      child: Row(
                        children: [
                          IconButton(onPressed: () => clickEventImpressum(), icon: Icon(
                            Icons.people,
                            color: customStyleClass.primeColor,
                            size: 25,
                          )),
                          SizedBox(
                            width: screenWidth*0.02,
                          ),
                          Text(
                            "Impressum",
                            style: customStyleClass.getFontStyle1(),
                          )
                        ],
                      ),
                    ),

                    SizedBox(
                      width: screenWidth*0.9,
                      child: Row(
                        children: [
                          IconButton(onPressed: () => clickEventAGB(), icon: Icon(
                            Icons.file_copy,
                            color: customStyleClass.primeColor,
                            size: 25,
                          )),
                          SizedBox(
                            width: screenWidth*0.02,
                          ),
                          Text(
                            "AGB",
                            style: customStyleClass.getFontStyle1(),
                          )
                        ],
                      ),
                    ),

                    SizedBox(
                      width: screenWidth*0.9,
                      child: Row(
                        children: [
                          IconButton(onPressed: () =>clickEventPrivacy(), icon: Icon(
                            Icons.remove_red_eye_outlined,
                            color: customStyleClass.primeColor,
                            size: 25,
                          )),
                          SizedBox(
                            width: screenWidth*0.02,
                          ),
                          Text(
                            "Datenschutz",
                            style: customStyleClass.getFontStyle1(),
                          )
                        ],
                      ),
                    ),

                    SizedBox(
                      width: screenWidth*0.9,
                      child: Row(
                        children: [
                          IconButton(onPressed: () => clickEventSponsors(), icon: Icon(
                            Icons.add_shopping_cart,
                            color: customStyleClass.primeColor,
                            size: 25,
                          )),
                          SizedBox(
                            width: screenWidth*0.02,
                          ),
                          Text(
                            "Werbepartner",
                            style: customStyleClass.getFontStyle1(),
                          )
                        ],
                      ),
                    ),

                    InkWell(
                      child: SizedBox(
                        width: screenWidth*0.9,
                        child: Row(
                          children: [
                            IconButton(onPressed: () => clickEventLogOut(), icon: Icon(
                              Icons.logout,
                              color: customStyleClass.primeColor,
                              size: 25,
                            )),
                            SizedBox(
                              width: screenWidth*0.02,
                            ),
                            Text(
                              "Abmelden",
                              style: customStyleClass.getFontStyle1(),
                            )
                          ],
                        ),
                      ),
                      onTap: () => clickEventLogOut(),
                    ),


                  ],
                )
            )
        )
    );
  }
}
