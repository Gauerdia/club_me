import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../provider/state_provider.dart';
import '../services/hive_service.dart';
import '../services/supabase_service.dart';
import '../shared/custom_bottom_navigation_bar.dart';
import '../shared/custom_text_style.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({Key? key}) : super(key: key);

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {

  String headLine = "Dein Profil";

  late StateProvider stateProvider;
  late CustomTextStyle customTextStyle;
  late double screenHeight, screenWidth;

  final HiveService _hiveService = HiveService();
  final SupabaseService _supabaseService = SupabaseService();

  Color primeColorDark = Colors.teal;
  Color primeColor = Colors.tealAccent;


  Widget _buildAppBarShowTitle(){
    return SizedBox(
      width: screenWidth,
      child: Stack(
        children: [
          // Headline
          Container(
              alignment: Alignment.bottomCenter,
              height: 50,
              width: screenWidth,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(headLine,
                      textAlign: TextAlign.center,
                      style: customTextStyle.size2()
                  ),
                ],
              )
          ),
        ],
      ),
    );
  }

  void clickedOnLogOut(){
    stateProvider.setPageIndex(0);
    _hiveService.resetUserData().then((value) => context.go("/log_in"));
  }

  @override
  Widget build(BuildContext context) {

    stateProvider = Provider.of<StateProvider>(context);

    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;

    customTextStyle = CustomTextStyle(context: context);

    double discountContainerHeightFactor = 0.52;
    double newDiscountContainerHeightFactor = 0.25;

    return Scaffold(
      bottomNavigationBar: CustomBottomNavigationBar(),
      appBar: AppBar(
        title: _buildAppBarShowTitle()
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
          child: Stack(
            children: [
              SingleChildScrollView(
                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                  physics: const ScrollPhysics(),
                  child: Center(
                    child:
                    Column(
                      children: [

                        // Spacer
                        SizedBox(height: screenHeight*0.02),

                        // Accent tile
                        SizedBox(
                      child: SizedBox(
                        child: Stack(
                          children: [

                            // Bottom accent
                            Container(
                              width: screenWidth*0.91,
                              height: screenHeight*(newDiscountContainerHeightFactor+0.005),
                              decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                      begin: Alignment.bottomLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Colors.grey[900]!,
                                        primeColorDark.withOpacity(0.4)
                                      ],
                                      stops: const [0.6, 0.9]
                                  ),
                                  borderRadius: BorderRadius.circular(
                                      15
                                  )
                              ),
                            ),

                            // Top accent
                            Container(
                              width: screenWidth*0.91,
                              height: screenHeight*newDiscountContainerHeightFactor,
                              decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                      begin: Alignment.topRight,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Colors.grey[900]!,
                                        primeColorDark.withOpacity(0.2)
                                      ],
                                      stops: const [0.6, 0.9]
                                  ),
                                  borderRadius: BorderRadius.circular(
                                      15
                                  )
                              ),
                            ),

                            // left highlight
                            Container(
                              width: screenWidth*0.89,
                              height: screenHeight*newDiscountContainerHeightFactor,
                              decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [Colors.grey[600]!, Colors.grey[900]!],
                                      stops: const [0.1, 0.9]
                                  ),
                                  borderRadius: BorderRadius.circular(
                                      15
                                  )
                              ),
                            ),

                            // Top accent
                            Padding(
                                padding: const EdgeInsets.only(
                                    left:2
                                ),
                                child: Container(
                                  width: screenWidth*0.9,
                                  height: screenHeight*newDiscountContainerHeightFactor,
                                  decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.topRight,
                                          colors: [Colors.grey[600]!, Colors.grey[900]!],
                                          stops: const [0.1, 0.9]
                                      ),
                                      borderRadius: BorderRadius.circular(
                                          15
                                      )
                                  ),
                                )
                            ),

                            // main Div
                            Padding(
                              padding: const EdgeInsets.only(
                                  left:2,
                                  top: 2
                              ),
                              child: Container(
                                width: screenWidth*0.9,
                                height: screenHeight*newDiscountContainerHeightFactor,
                                decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          Colors.grey[800]!.withOpacity(0.7),
                                          Colors.grey[900]!
                                        ],
                                        stops: const [0.1,0.9]
                                    ),
                                    borderRadius: BorderRadius.circular(
                                        15
                                    )
                                ),
                                child: Column(
                                  children: [

                                    // "New Event" headline
                                    Container(
                                      width: screenWidth,
                                      // color: Colors.red,
                                      padding: EdgeInsets.only(
                                          left: screenWidth*0.05,
                                          top: screenHeight*0.03
                                      ),
                                      child: Text(
                                        "Persönliche Daten",
                                        textAlign: TextAlign.left,
                                        style: customTextStyle.size1Bold(),
                                      ),
                                    ),

                                    SizedBox(
                                      height: screenHeight*0.05,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                        children: [

                                          const Text(
                                              "Vorname"
                                          ),

                                          Text(
                                              stateProvider.getUserData().getFirstName()
                                          ),
                                        ],
                                      )
                                    ),

                                    SizedBox(
                                      height: screenHeight*0.05,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                        children: [

                                          const Text(
                                              "Nachname"
                                          ),

                                          Text(
                                              stateProvider.getUserData().getLastName()
                                          ),
                                        ],
                                      )
                                    ),

                                    SizedBox(
                                        height: screenHeight*0.05,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                                          children: [

                                            const Text(
                                                "E-Mail-Adresse"
                                            ),

                                            Text(
                                                stateProvider.getUserData().getEMail()
                                            ),
                                          ],
                                        )
                                    ),

                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),

                        // Spacer
                        SizedBox(height: screenHeight*0.02),

                        // Button
                        GestureDetector(
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
                                    style: customTextStyle.size5Bold()
                                ),
                              )
                          ),
                          onTap: () => clickedOnLogOut(),
                        ),

                        // Spacer
                        SizedBox(height: screenHeight*0.1,),
                      ],
                    ),
                  )
              ),

            ],
          )
      ),
    );
  }
}
