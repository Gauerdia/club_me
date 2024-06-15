import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../provider/state_provider.dart';
import 'custom_text_style.dart';

class CustomBottomNavigationBarClubs extends StatelessWidget {

  CustomBottomNavigationBarClubs({Key? key}) : super(key: key);

  var colorTransitionDuration = const Duration(milliseconds: 900);
  late CustomTextStyle customTextStyle;

  @override
  Widget build(BuildContext context) {

    final stateProvider = Provider.of<StateProvider>(context);

    customTextStyle = CustomTextStyle(context: context);

    Color navigationBackgroundColor = const Color(0xff11181f);
    Color iconBackgroundColor = Colors.teal;

    return Container(
        decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
            ),
            color: navigationBackgroundColor
        ),
        child: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                ),
              ),
              height: 70,
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    GestureDetector(
                      child: AnimatedContainer(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: stateProvider.pageIndex == 0 ? iconBackgroundColor : Colors.transparent
                        ),
                        duration: colorTransitionDuration,
                        child: Icon(
                          Icons.calendar_month_outlined,
                          color: Colors.white,
                          size: customTextStyle.getIconSize1(),
                        ),
                      ),
                      onTap: (){
                        stateProvider.setPageIndex(0);
                        stateProvider.resetWentFromCLubDetailToEventDetail();
                        context.go('/club_events');
                      },
                    ),

                    GestureDetector(
                      child: AnimatedContainer(
                        duration: colorTransitionDuration,
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: stateProvider.pageIndex == 1 ? iconBackgroundColor : Colors.transparent
                        ),
                        child: Icon(
                          Icons.insert_chart_outlined,
                          color: Colors.white,
                          size: customTextStyle.getIconSize1(),
                        ),
                      ),
                      onTap: (){
                        stateProvider.setPageIndex(1);
                        stateProvider.resetWentFromCLubDetailToEventDetail();
                        context.go('/club_stats');
                      },
                    ),

                    GestureDetector(
                      child: AnimatedContainer(
                        duration: colorTransitionDuration,
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: stateProvider.pageIndex == 2 ? iconBackgroundColor : Colors.transparent
                        ),
                        child: Icon(
                          Icons.percent,
                          color: Colors.white,
                          size: customTextStyle.getIconSize1(),
                        ),
                      ),
                      onTap: (){
                        stateProvider.setPageIndex(2);
                        stateProvider.resetWentFromCLubDetailToEventDetail();
                        context.go('/club_coupons');
                      },
                    ),

                    GestureDetector(
                      child: AnimatedContainer(
                        duration: colorTransitionDuration,
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: stateProvider.pageIndex == 3 ? iconBackgroundColor : Colors.transparent
                        ),
                        child: Icon(
                          Icons.camera_front,
                          color: Colors.white,
                          size: customTextStyle.getIconSize1(),
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
