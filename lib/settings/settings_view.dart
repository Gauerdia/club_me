import 'package:club_me/provider/state_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../provider/fetched_content_provider.dart';
import '../services/hive_service.dart';
import '../shared/custom_bottom_navigation_bar_clubs.dart';
import '../shared/custom_text_style.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({Key? key}) : super(key: key);

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {

  String headLine = "Einstellungen";

  late StateProvider stateProvider;
  late FetchedContentProvider fetchedContentProvider;
  late double screenHeight, screenWidth;

  final HiveService _hiveService = HiveService();

  late CustomStyleClass customStyleClass;

  Color primeColorDark = Colors.teal;
  Color primeColor = Colors.tealAccent;

  void logOutClicked(){
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

      // extendBodyBehindAppBar: true,
        extendBody: true,

        bottomNavigationBar: CustomBottomNavigationBarClubs(),
        appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Colors.transparent,
            title: SizedBox(
              width: screenWidth,
              child: Stack(
                children: [
                  Container(
                    width: screenWidth,
                    height: 50,
                    // color: Colors.red,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(headLine,
                          textAlign: TextAlign.center,
                          style: customStyleClass.getFontStyle2(),
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
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(
                                Icons.arrow_back_ios,
                                // size: 20,
                              )
                          )
                        ],
                      )
                  ),

                ],
              ),
            )
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
            child: SingleChildScrollView(

                child: Column(
                  children: [

                    Padding(
                      padding: EdgeInsets.only(
                        top:screenHeight*0.015,
                        right: 7,
                        bottom: 7,
                      ),
                      child: Align(
                        // alignment: Alignment.bottomRight,
                        child: GestureDetector(
                          child: Container(
                              width: screenWidth*0.8,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                    colors: [
                                      primeColorDark,
                                      primeColor,
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    stops: const [0.2, 0.9]
                                ),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black54,
                                    spreadRadius: 1,
                                    blurRadius: 7,
                                    offset: Offset(3, 3),
                                  ),
                                ],
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(10)
                                ),
                              ),
                              padding: const EdgeInsets.all(18),
                              child: Center(
                                child: Text(
                                    "Ausloggen",
                                    style: customStyleClass.getFontStyle5Bold()
                                ),
                              )
                          ),
                          onTap: () => logOutClicked(),
                        ),
                      ),
                    )

                  ],
                )
            )
        )
    );
  }
}
