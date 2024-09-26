import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../provider/state_provider.dart';
import 'custom_text_style.dart';

class CustomBottomNavigationBarClubs extends StatelessWidget {

  CustomBottomNavigationBarClubs({Key? key}) : super(key: key);

  var colorTransitionDuration = const Duration(milliseconds: 900);
  late CustomStyleClass customStyleClass;

  @override
  Widget build(BuildContext context) {

    final stateProvider = Provider.of<StateProvider>(context);

    customStyleClass = CustomStyleClass(context: context);

    Color navigationBackgroundColor = customStyleClass.backgroundColorMain;

    return Container(
        decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
            ),
            color: navigationBackgroundColor,
          border: Border(
            top: BorderSide(
              color: Colors.grey[900]!
            )
          )
        ),
        child: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                ),
              ),
              height: 90,
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    GestureDetector(
                      child: SizedBox(
                        height: 60,
                        child: Column(
                          children: [
                            Icon(
                              Icons.calendar_month_outlined,
                              color: stateProvider.pageIndex == 0 ? customStyleClass.primeColor : Colors.white,
                              size: customStyleClass.getIconSize1(),
                            ),
                            Text(
                                "Events",
                                style: GoogleFonts.inter(
                                    textStyle: TextStyle(
                                      fontSize: customStyleClass.getNavIconTextSize(),
                                      color: stateProvider.pageIndex == 0 ? customStyleClass.primeColor : Colors.white,
                                    )
                                )
                            )
                          ],
                        ),
                      ),
                      onTap: (){
                        stateProvider.setPageIndex(0);
                        stateProvider.resetWentFromCLubDetailToEventDetail();
                        context.go('/club_events');
                      },
                    ),

                    GestureDetector(
                      child: SizedBox(
                        height: 60,
                        child: Column(
                          children: [
                            Icon(
                              Icons.bar_chart,
                              color: stateProvider.pageIndex == 1 ? customStyleClass.primeColor : Colors.white,
                              size: customStyleClass.getIconSize1(),
                            ),
                            Text(
                                "Auswertungen",
                                style: GoogleFonts.inter(
                                    textStyle: TextStyle(
                                      fontSize: customStyleClass.getNavIconTextSize(),
                                      color: stateProvider.pageIndex == 1 ? customStyleClass.primeColor : Colors.white,
                                    )
                                )
                            )
                          ],
                        ),
                      ),
                      onTap: (){
                        stateProvider.setPageIndex(1);
                        stateProvider.resetWentFromCLubDetailToEventDetail();
                        context.go('/club_stats');
                      },
                    ),

                    GestureDetector(
                      child: SizedBox(
                        height: 60,
                        child: Column(
                          children: [
                            Icon(
                              Icons.percent,
                              color: stateProvider.pageIndex == 2 ? customStyleClass.primeColor : Colors.white,
                              size: customStyleClass.getIconSize1(),
                            ),
                            Text(
                                "Coupons",
                                style: GoogleFonts.inter(
                                    textStyle: TextStyle(
                                      fontSize: customStyleClass.getNavIconTextSize(),
                                      color: stateProvider.pageIndex == 2 ? customStyleClass.primeColor : Colors.white,
                                    )
                                )
                            )
                          ],
                        ),
                      ),
                      onTap: (){
                        stateProvider.setPageIndex(2);
                        stateProvider.resetWentFromCLubDetailToEventDetail();
                        context.go('/club_coupons');
                      },
                    ),

                    GestureDetector(
                      child: SizedBox(
                        height: 60,
                        child: Column(
                          children: [
                            Icon(
                              Icons.person,
                              color: stateProvider.pageIndex == 3 ? customStyleClass.primeColor : Colors.white,
                              size: customStyleClass.getIconSize1(),
                            ),
                            Text(
                                "Profil",
                                style: GoogleFonts.inter(
                                    textStyle: TextStyle(
                                      fontSize: customStyleClass.getNavIconTextSize(),
                                      color: stateProvider.pageIndex == 3 ? customStyleClass.primeColor : Colors.white,
                                    )
                                )
                            )
                          ],
                        ),
                      ),
                      onTap: (){
                        stateProvider.setPageIndex(3);
                        stateProvider.resetWentFromCLubDetailToEventDetail();
                        context.go('/club_frontpage');
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        )
    );
  }
}
