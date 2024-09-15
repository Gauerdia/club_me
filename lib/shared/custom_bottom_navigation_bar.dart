import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../provider/state_provider.dart';
import 'custom_text_style.dart';

class CustomBottomNavigationBar extends StatelessWidget {

  CustomBottomNavigationBar({Key? key}) : super(key: key);


  var colorTransitionDuration = const Duration(milliseconds: 900);
  late CustomStyleClass customStyleClass;

  @override
  Widget build(BuildContext context) {

    final stateProvider = Provider.of<StateProvider>(context);

    customStyleClass = CustomStyleClass(context: context);

    Color navigationBackgroundColor = Colors.black; //const Color(0xff11181f);
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
              height: 90,
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [

                    // Events icon
                    GestureDetector(
                      child: AnimatedContainer(
                        // padding: const EdgeInsets.all(3),
                        // decoration: BoxDecoration(
                        //   borderRadius: BorderRadius.circular(10),
                        //   color: stateProvider.pageIndex == 0 ? iconBackgroundColor : Colors.transparent
                        // ),
                        duration: colorTransitionDuration,
                        child: Container(
                          // color: Colors.grey,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.calendar_month_outlined,
                                color: stateProvider.pageIndex == 0 ? customStyleClass.primeColor : Colors.white,
                                size: customStyleClass.getIconSize1(),
                              ),
                              Text(
                                  "Events",
                                style: TextStyle(
                                    color: stateProvider.pageIndex == 0 ? customStyleClass.primeColor : Colors.white
                                ),
                              )
                            ],
                          ),
                        )
                      ),
                      onTap: (){
                        stateProvider.setPageIndex(0);
                        context.go('/user_events');
                      },
                    ),

                    GestureDetector(
                      child: AnimatedContainer(
                        duration: colorTransitionDuration,
                        // padding: const EdgeInsets.all(3),
                        // decoration: BoxDecoration(
                        //     borderRadius: BorderRadius.circular(10),
                        //     color: stateProvider.pageIndex == 1 ? iconBackgroundColor : Colors.transparent
                        // ),
                        child: Container(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.wine_bar_outlined,
                                color: stateProvider.pageIndex == 1 ? customStyleClass.primeColor : Colors.white,
                                size: customStyleClass.getIconSize1(),
                              ),
                              Text(
                                "Clubs",
                                style: TextStyle(
                                    color: stateProvider.pageIndex == 1 ? customStyleClass.primeColor : Colors.white
                                ),
                              )
                            ],
                          ),
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
                        // padding: const EdgeInsets.all(3),
                        // decoration: BoxDecoration(
                        //     borderRadius: BorderRadius.circular(10),
                        //     color: stateProvider.pageIndex == 2 ? iconBackgroundColor : Colors.transparent
                        // ),
                        child: Container(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.map,
                                color: stateProvider.pageIndex == 2 ? customStyleClass.primeColor : Colors.white,
                                size: customStyleClass.getIconSize1(),
                              ),
                              Text(
                                "Karte",
                                style: TextStyle(
                                    color: stateProvider.pageIndex == 2 ? customStyleClass.primeColor : Colors.white
                                ),
                              )
                            ],
                          ),
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
                        // padding: const EdgeInsets.all(3),
                        // decoration: BoxDecoration(
                        //     borderRadius: BorderRadius.circular(10),
                        //     color: stateProvider.pageIndex == 3 ? iconBackgroundColor : Colors.transparent
                        // ),
                        child: Container(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.percent,
                                color: stateProvider.pageIndex == 3 ? customStyleClass.primeColor : Colors.white,
                                size: customStyleClass.getIconSize1(),
                              ),
                              Text(
                                "Coupons",
                                style: TextStyle(
                                    color: stateProvider.pageIndex == 3 ? customStyleClass.primeColor : Colors.white
                                ),
                              )
                            ],
                          ),
                        )
                      ),
                      onTap: (){
                        stateProvider.setPageIndex(3);
                        context.go('/user_coupons');
                      },
                    ),

                    GestureDetector(
                      child: AnimatedContainer(
                        duration: colorTransitionDuration,
                        // padding: const EdgeInsets.all(3),
                        // decoration: BoxDecoration(
                        //     borderRadius: BorderRadius.circular(10),
                        //     color: stateProvider.pageIndex == 4 ? iconBackgroundColor : Colors.transparent
                        // ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.person,
                              color: stateProvider.pageIndex == 4 ? customStyleClass.primeColor : Colors.white,
                              size: customStyleClass.getIconSize1(),
                            ),
                            Text(
                              "Profil",
                              style: TextStyle(
                                  color: stateProvider.pageIndex == 4 ? customStyleClass.primeColor : Colors.white
                              ),
                            )
                          ],
                        ),
                      ),
                      onTap: (){
                        stateProvider.setPageIndex(4);
                        context.go('/user_profile');
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
