import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../provider/state_provider.dart';

class CustomBottomNavigationBar extends StatelessWidget {

  CustomBottomNavigationBar({Key? key}) : super(key: key);


  var colorTransitionDuration = const Duration(milliseconds: 900);

  @override
  Widget build(BuildContext context) {

    final stateProvider = Provider.of<StateProvider>(context);

    Color navigationBackgroundColor = const Color(0xff11181f);
    Color iconBackgroundColor = const Color(0xffF03ADE); //const Color(0xff68d6cf);

    return Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
                topRight: Radius.circular(30),
                topLeft: Radius.circular(30)
            ),
            color: navigationBackgroundColor
        ),
        child: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(30),
                    topLeft: Radius.circular(30)
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
                        child: const Icon(
                          Icons.calendar_month_outlined,
                          color: Colors.white,
                          size: 35,
                        ),
                      ),
                      onTap: (){
                        stateProvider.setPageIndex(0);
                        context.go('/user_events');
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
                        child: const Icon(
                          Icons.wine_bar_outlined,
                          color: Colors.white,
                          size: 35,
                        ),
                      ),
                      onTap: (){
                        stateProvider.setPageIndex(1);
                        context.go('/user_clubs');
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
                        child: const Icon(
                          Icons.map,
                          color: Colors.white,
                          size: 35,
                        ),
                      ),
                      onTap: (){
                        stateProvider.setPageIndex(2);
                        context.go('/user_map');
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
                        child: const Icon(
                          Icons.percent,
                          color: Colors.white,
                          size: 35,
                        ),
                      ),
                      onTap: (){
                        stateProvider.setPageIndex(3);
                        context.go('/user_coupons');
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
