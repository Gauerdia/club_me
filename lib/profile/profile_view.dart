import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../provider/state_provider.dart';
import '../provider/user_data_provider.dart';
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
  late CustomStyleClass customStyleClass;
  late double screenHeight, screenWidth;
  late UserDataProvider userDataProvider;

  final HiveService _hiveService = HiveService();
  final SupabaseService _supabaseService = SupabaseService();

  Color primeColorDark = Colors.teal;
  Color primeColor = Colors.tealAccent;

  BoxDecoration gradientDecoration = const BoxDecoration(
    gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xff2b353d),
          Color(0xff11181f)
        ],
        stops: [0.15, 0.6]
    ),
  );
  BoxDecoration plainBlackDecoration = const BoxDecoration(
      color: Colors.black
  );

  double discountContainerHeightFactor = 0.52;
  double newDiscountContainerHeightFactor = 0.25;

  AppBar _buildAppBar(){
    return AppBar(
        surfaceTintColor: Colors.black,
        backgroundColor: Colors.transparent,
        title: SizedBox(
          width: screenWidth,
          child: Stack(
            children: [
              Container(
                width: screenWidth,
                height: screenHeight*0.2,
                // padding: EdgeInsets.only(
                //     top: screenHeight*0.005
                // ),
                child: Center(
                  child: Text(headLine,
                      textAlign: TextAlign.center,
                      style: customStyleClass.getFontStyle1()
                  ),
                ),
              ),
              Container(
                width: screenWidth,
                height: screenHeight*0.2,
                alignment: Alignment.centerRight,
                child: IconButton(
                  icon: const Icon(
                    Icons.settings,
                    color: Colors.white,
                  ),
                  onPressed: () => context.push("/user_settings"),
                ),
              )
            ],
          ),
        )
    );
  }

  void clickedOnLogOut(){
    stateProvider.setPageIndex(0);
    stateProvider.activeLogOut = true;
    context.go("/log_in");
    // _hiveService.resetUserData().then((value) => context.go("/log_in"));
  }

  Widget _buildTileView(){
    return SingleChildScrollView(
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

                          // "Personal Information" headline
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
                              style: customStyleClass.getFontStyle1Bold(),
                            ),
                          ),

                          Container(
                            // color: Colors.red,
                              height: screenHeight*0.05,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [

                                  Padding(
                                    padding: EdgeInsets.only(
                                        left: screenWidth*0.05
                                    ),
                                    child: Text(
                                      "Vorname",
                                      textAlign: TextAlign.left,
                                      style: customStyleClass.getFontStyle3(),
                                    ),
                                  ),

                                  Padding(
                                    padding: EdgeInsets.only(
                                        right: screenWidth*0.05
                                    ),
                                    child: Text(
                                      userDataProvider.getUserData().getFirstName(),
                                      style: customStyleClass.getFontStyle3(),
                                    ),
                                  ),

                                ],
                              )
                          ),

                          SizedBox(
                              height: screenHeight*0.05,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [

                                  Padding(
                                    padding: EdgeInsets.only(
                                        left: screenWidth*0.05
                                    ),
                                    child: Text(
                                      "Nachname",
                                      textAlign: TextAlign.left,
                                      style: customStyleClass.getFontStyle3(),
                                    ),
                                  ),

                                  Padding(
                                    padding: EdgeInsets.only(
                                        right: screenWidth*0.05
                                    ),
                                    child: Text(
                                      userDataProvider.getUserData().getLastName(),
                                      style: customStyleClass.getFontStyle3(),
                                    ),
                                  ),

                                ],
                              )
                          ),

                          SizedBox(
                              height: screenHeight*0.05,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [

                                  Padding(
                                    padding: EdgeInsets.only(
                                        left: screenWidth*0.05
                                    ),
                                    child: Text(
                                      "E-Mail-Adresse",
                                      textAlign: TextAlign.left,
                                      style: customStyleClass.getFontStyle3(),
                                    ),
                                  ),

                                  Padding(
                                    padding: EdgeInsets.only(
                                        right: screenWidth*0.05
                                    ),
                                    child: Text(
                                      userDataProvider.getUserData().getEMail(),
                                      style: customStyleClass.getFontStyle3(),
                                    ),
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
                      style: customStyleClass.getFontStyle5Bold()
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
    );
  }

  Widget _buildBasicView(){


    String dayToDisplay = userDataProvider.getUserData().getBirthDate().day < 10 ?
    "0${userDataProvider.getUserData().getBirthDate().day}" :
    userDataProvider.getUserData().getBirthDate().day.toString();

    String monthToDisplay = userDataProvider.getUserData().getBirthDate().month < 10 ?
    "0${userDataProvider.getUserData().getBirthDate().month}" :
    userDataProvider.getUserData().getBirthDate().month.toString();


    String birthDateToDisplay =
        "$dayToDisplay.$monthToDisplay.${userDataProvider.getUserData().getBirthDate().year}";

    return SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        physics: const ScrollPhysics(),
        child: Center(
            child:
            Column(
                children: [

                  SizedBox(
                    height: screenHeight*0.05,
                  ),

                  Container(
                    width: screenWidth*0.9,
                    padding: const EdgeInsets.only(
                      bottom: 10
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: screenWidth*0.1,
                          child: Icon(
                            Icons.person,
                            color: customStyleClass.primeColor,
                            size: 30,
                          ),
                        ),
                        Text(
                          "${userDataProvider.getUserData().getFirstName()}, ${userDataProvider.getUserData().getLastName()}",
                          style: customStyleClass.getFontStyle3(),
                        ),
                      ],
                    ),
                  ),


                  Container(
                    width: screenWidth*0.9,
                    padding: const EdgeInsets.only(
                        bottom: 10
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: screenWidth*0.1,
                          child: Row(
                            children: [
                              Icon(
                                Icons.man,
                                color: customStyleClass.primeColor,
                                size: 20,
                              ),
                              Icon(
                                Icons.woman,
                                color: customStyleClass.primeColor,
                                size: 20,
                              )
                            ],
                          ),
                        ),
                        Text(
                          userDataProvider.getUserData().getGender() == 0 ? "Männlich" :
                          userDataProvider.getUserData().getGender() == 1 ? "Weiblich" :
                          "Divers",
                          style: customStyleClass.getFontStyle3(),
                        ),
                      ],
                    ),
                  ),

                  Container(
                    width: screenWidth*0.9,
                    padding: const EdgeInsets.only(
                        bottom: 10
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: screenWidth*0.1,
                          child: Icon(
                            Icons.person,
                            color: customStyleClass.primeColor,
                            size: 30,
                          ),
                        ),
                        Text(
                          birthDateToDisplay,
                          style: customStyleClass.getFontStyle3(),
                        ),
                      ],
                    ),
                  ),

                  Container(
                    width: screenWidth*0.9,
                    padding: const EdgeInsets.only(
                        bottom: 10
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: screenWidth*0.1,
                          child: Icon(
                            Icons.mail,
                            color: customStyleClass.primeColor,
                            size: 30,
                          ),
                        ),
                        Text(
                          userDataProvider.getUserData().getEMail(),
                          style: customStyleClass.getFontStyle3(),
                        ),
                      ],
                    ),
                  ),

                ]
            )
        )
    );
  }

  @override
  Widget build(BuildContext context) {

    stateProvider = Provider.of<StateProvider>(context);

    userDataProvider = Provider.of<UserDataProvider>(context);

    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;

    customStyleClass = CustomStyleClass(context: context);


    return Scaffold(

      bottomNavigationBar: CustomBottomNavigationBar(),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: _buildAppBar()
      ),
      body: Container(
          width: screenWidth,
          height: screenHeight,
          decoration: plainBlackDecoration,
          child: Stack(
            children: [
              _buildBasicView()
            ],
          )
      ),
    );
  }
}
