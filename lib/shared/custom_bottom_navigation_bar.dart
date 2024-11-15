import 'package:club_me/shared/dialogs/title_content_and_button_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../provider/state_provider.dart';
import 'custom_text_style.dart';

class CustomBottomNavigationBar extends StatelessWidget {

  CustomBottomNavigationBar({Key? key}) : super(key: key);

  late StateProvider stateProvider;

  var colorTransitionDuration = const Duration(milliseconds: 900);
  late CustomStyleClass customStyleClass;


  void showRegistrationNeededDialog(BuildContext context){
    showDialog(context: context, builder: (BuildContext context){
      return TitleContentAndButtonDialog(
          titleToDisplay: "Registrierung erforderlich",
          contentToDisplay: "Für diese Funktionalität ist eine Registrierung erforderlich.",
        buttonToDisplay: TextButton(
            onPressed: (){
              stateProvider.resetUsingWithoutRegistration();
              context.go("/register");
            },
            child: Text(
              "Jetzt registrieren",
              style: customStyleClass.getFontStyle3BoldPrimeColor(),
            )
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {

    stateProvider = Provider.of<StateProvider>(context);

    customStyleClass = CustomStyleClass(context: context);

    Color navigationBackgroundColor = customStyleClass.backgroundColorMain;

    return Container(
        decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
            ),
            border: Border(
                top: BorderSide(
                    color: Colors.grey[800]!
                )
            ),
            color: navigationBackgroundColor
        ),
        child: Stack(
          children: [
            Container(
              padding: const EdgeInsets.only(
                top: 8
              ),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                ),
              ),
              height: 80,
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [

                    // Events icon
                    GestureDetector(
                      child: AnimatedContainer(
                        duration: colorTransitionDuration,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
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
                                      color: stateProvider.pageIndex == 0 ? customStyleClass.primeColor : Colors.white,
                                      fontSize: customStyleClass.getNavIconTextSize()
                                  )
                              )
                            )
                          ],
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
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.wine_bar_rounded,
                              color: stateProvider.pageIndex == 1 ? customStyleClass.primeColor : Colors.white,
                              size: customStyleClass.getIconSize1(),
                            ),
                            Text(
                              "Clubs",
                                style: GoogleFonts.inter(
                                    textStyle: TextStyle(
                                        color: stateProvider.pageIndex == 1 ? customStyleClass.primeColor : Colors.white,
                                        fontSize: customStyleClass.getNavIconTextSize()
                                    )
                                )
                            )
                          ],
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
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(
                              CupertinoIcons.location_solid,
                              color: stateProvider.pageIndex == 2 ? customStyleClass.primeColor : Colors.white,
                              size: customStyleClass.getIconSize1(),
                            ),
                            Text(
                              "Karte",
                                style: GoogleFonts.inter(
                                    textStyle: TextStyle(
                                        color: stateProvider.pageIndex == 2 ? customStyleClass.primeColor : Colors.white,
                                        fontSize: customStyleClass.getNavIconTextSize()
                                    )
                                )
                            )
                          ],
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
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.percent,
                              color: stateProvider.pageIndex == 3 ? customStyleClass.primeColor : Colors.white,
                              size: customStyleClass.getIconSize1(),
                            ),
                            Text(
                              "Angebote",
                                style: GoogleFonts.inter(
                                    textStyle: TextStyle(
                                        color: stateProvider.pageIndex == 3 ? customStyleClass.primeColor : Colors.white,
                                        fontSize: customStyleClass.getNavIconTextSize()
                                    )
                                )
                            )
                          ],
                        )
                      ),
                      onTap: (){

                        if(stateProvider.usingWithoutRegistration){
                          context.push("/need_to_register");
                          // showRegistrationNeededDialog(context);
                        }else{
                          stateProvider.setPageIndex(3);
                          context.go('/user_coupons');
                        }
                      },
                    ),

                    GestureDetector(
                      child: AnimatedContainer(
                        duration: colorTransitionDuration,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.person,
                              color: stateProvider.pageIndex == 4 ? customStyleClass.primeColor : Colors.white,
                              size: customStyleClass.getIconSize1(),
                            ),
                            Text(
                              "Profil",
                                style: GoogleFonts.inter(
                                    textStyle: TextStyle(
                                        color: stateProvider.pageIndex == 4 ? customStyleClass.primeColor : Colors.white,
                                        fontSize: customStyleClass.getNavIconTextSize()
                                    )
                                )
                            )
                          ],
                        ),
                      ),
                      onTap: (){

                        if(stateProvider.usingWithoutRegistration){
                          context.go("/register");
                          // showRegistrationNeededDialog(context);
                        }else{
                          stateProvider.setPageIndex(4);
                          context.go('/user_profile');
                        }
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
