import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../provider/state_provider.dart';
import '../shared/custom_bottom_navigation_bar_clubs.dart';

class ClubCouponsView extends StatelessWidget {

  ClubCouponsView({Key? key}) : super(key: key);

  String headLine = "Your Coupons";

  double newDiscountContainerHeightFactor = 0.2;
  double discountContainerHeightFactor = 0.52;



  @override
  Widget build(BuildContext context) {

    final stateProvider = Provider.of<StateProvider>(context);

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(

        extendBodyBehindAppBar: true,
        extendBody: true,

        bottomNavigationBar: CustomBottomNavigationBarClubs(),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Text(headLine,
            style: TextStyle(
              // color: Colors.purpleAccent
            ),
          ),
          actions: [
            // Step to club UI
            GestureDetector(
              child: Padding(
                padding: const EdgeInsets.only(
                    right: 10
                ),
                child: Container(
                  padding: const EdgeInsets.all(7),
                  decoration: const BoxDecoration(
                      color: Color(0xff11181f),
                      borderRadius: BorderRadius.all(
                          Radius.circular(45)
                      )
                  ),

                  child: const Icon(
                    Icons.switch_access_shortcut,
                    color: Colors.grey,
                  ),
                ),
              ),
              onTap: (){
                stateProvider.setPageIndex(0);
                stateProvider.toggleClubUIActive();
                context.go("/user_events");
              },
            ),
          ],
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

                          // Spacer
                          SizedBox(
                            height: screenHeight*0.15,
                          ),

                          // Neuer Discount
                          Container(
                            height: screenHeight*newDiscountContainerHeightFactor,
                            child: Container(
                              height: screenHeight*newDiscountContainerHeightFactor,
                              child: Stack(
                                children: [

                                  Container(
                                    width: screenWidth*0.91,
                                    height: screenHeight*(newDiscountContainerHeightFactor+0.004),//0.204,
                                    decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                            begin: Alignment.bottomLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              Colors.grey[900]!, 
                                              Colors.purple.withOpacity(0.4)
                                            ],
                                            stops: [0.6, 0.9]
                                        ),
                                        borderRadius: BorderRadius.circular(
                                            15
                                        )
                                    ),
                                  ),

                                  Container(
                                    width: screenWidth*0.91,
                                    height: screenHeight*newDiscountContainerHeightFactor,
                                    decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                            begin: Alignment.topRight,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              Colors.grey[900]!, 
                                              Colors.purple.withOpacity(0.2)
                                            ],
                                            stops: [0.6, 0.9]
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
                                            stops: [0.1, 0.9]
                                        ),
                                        borderRadius: BorderRadius.circular(
                                            15
                                        )
                                    ),
                                  ),

                                  Padding(
                                      padding: EdgeInsets.only(
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
                                                stops: [0.1, 0.9]
                                            ),
                                            borderRadius: BorderRadius.circular(
                                                15
                                            )
                                        ),
                                      )
                                  ),

                                  // main Div
                                  Padding(
                                    padding: EdgeInsets.only(
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
                                              stops: [0.1,0.9]
                                          ),
                                          borderRadius: BorderRadius.circular(
                                              15
                                          )
                                      ),
                                      child: Column(
                                        children: [
                                          // Events headline
                                          Container(
                                            width: screenWidth,
                                            // color: Colors.red,
                                            padding: EdgeInsets.only(
                                                left: screenWidth*0.05,
                                                top: screenHeight*0.03
                                            ),
                                            child: const Text(
                                              "Neuer Discount",
                                              textAlign: TextAlign.left,
                                              style: TextStyle(
                                                  fontSize: 24,
                                                fontWeight: FontWeight.bold
                                              ),
                                            ),
                                          ),

                                          // Neuen Discount erstellen button
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
                                                    decoration: const BoxDecoration(
                                                      color: Colors.deepPurple,
                                                      gradient: LinearGradient(
                                                          colors: [
                                                            // Colors.deepPurple, Colors.deepPurpleAccent
                                                            Colors.purple,
                                                            Colors.purpleAccent,
                                                          ],
                                                        begin: Alignment.topLeft,
                                                        end: Alignment.bottomRight,
                                                        stops: [0.2, 0.9]
                                                      ),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors.black54,
                                                          spreadRadius: 1,
                                                          blurRadius: 7,
                                                          offset: Offset(3, 3), // changes position of shadow
                                                        ),
                                                      ],
                                                      borderRadius: BorderRadius.all(
                                                          Radius.circular(10)
                                                      ),
                                                      // border: Border.all(
                                                      //     color: Colors.purpleAccent
                                                      // )
                                                    ),
                                                    padding: EdgeInsets.all(18),
                                                    child: const Center(
                                                      child: Text(
                                                        "Neuen Discount erstellen!",
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            // fontWeight: FontWeight.bold,
                                                            fontSize: 16,
                                                          fontWeight: FontWeight.bold
                                                        ),
                                                      ),
                                                    )
                                                ),
                                                onTap: (){

                                                  // ClubMeEvent newEvent = ClubMeEvent(
                                                  //     title: _textEditingControllerTitle.text,
                                                  //     clubName: _textEditingControllerClub.text,
                                                  //     DjName: _textEditingControllerDJName.text,
                                                  //     date: _selectedDay.toString() + "." + _selectedMonth.toString() + "." + _selectedYear.toString(),
                                                  //     price: _textEditingControllerPrice.text,
                                                  //     imagePath: "assets/images/img_6.png"
                                                  // );
                                                  //
                                                  // stateProvider.setCurrentEvent(newEvent);
                                                  // context.go("/event_details");

                                                },
                                              ),
                                            ),
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
                          SizedBox(
                            height: screenHeight*0.05,
                          ),

                          // Bisherige Discounts
                          Container(
                            height: screenHeight*0.7,
                            // color: Colors.red,
                            child: Container(
                              child: Stack(
                                children: [

                                  // gradient from bottom left to bottom right
                                  Container(
                                    width: screenWidth*0.91,
                                    height: screenHeight*(discountContainerHeightFactor+0.004),
                                    decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                            begin: Alignment.bottomLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              Colors.grey[900]!,
                                              Colors.purple.withOpacity(0.4)
                                            ],
                                            stops: [0.6, 0.9]
                                        ),
                                        borderRadius: BorderRadius.circular(
                                            15
                                        )
                                    ),
                                  ),

                                  // gradient from top right to bottom right
                                  Container(
                                    width: screenWidth*0.91,
                                    height: screenHeight*discountContainerHeightFactor,
                                    decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                            begin: Alignment.topRight,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              Colors.grey[900]!,
                                              Colors.purple.withOpacity(0.2)
                                            ],
                                            stops: [0.6, 0.9]
                                        ),
                                        borderRadius: BorderRadius.circular(
                                            15
                                        )
                                    ),
                                  ),

                                  // left highlight
                                  Container(
                                    width: screenWidth*0.89,
                                    height: screenHeight*discountContainerHeightFactor,
                                    decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [Colors.grey[600]!, Colors.grey[900]!],
                                            stops: [0.1, 0.9]
                                        ),
                                        borderRadius: BorderRadius.circular(
                                            15
                                        )
                                    ),
                                  ),

                                  // top left to top right
                                  Padding(
                                      padding: EdgeInsets.only(
                                          left:2
                                      ),
                                      child: Container(
                                        width: screenWidth*0.9,
                                        height: screenHeight*discountContainerHeightFactor,
                                        decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                                begin: Alignment.topLeft,
                                                end: Alignment.topRight,
                                                colors: [Colors.grey[600]!, Colors.grey[900]!],
                                                stops: [0.1, 0.9]
                                            ),
                                            borderRadius: BorderRadius.circular(
                                                15
                                            )
                                        ),
                                      )
                                  ),

                                  // main Div
                                  Padding(
                                    padding: EdgeInsets.only(
                                        left:2,
                                        top: 2
                                    ),
                                    child: Container(
                                      width: screenWidth*0.9,
                                      height: screenHeight*discountContainerHeightFactor,
                                      decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                              colors: [
                                                Colors.grey[800]!.withOpacity(0.7),
                                                Colors.grey[900]!
                                              ],
                                              stops: [0.1,0.7]
                                          ),
                                          borderRadius: BorderRadius.circular(
                                              15
                                          )
                                      ),
                                      child: Column(
                                        children: [
                                          // Events headline
                                          Container(
                                            width: screenWidth,
                                            // color: Colors.red,
                                            padding: EdgeInsets.only(
                                                left: screenWidth*0.05,
                                                top: screenHeight*0.03
                                            ),
                                            child: const Text(
                                              "Bisherige Discounts",
                                              textAlign: TextAlign.left,
                                              style: TextStyle(
                                                  fontSize: 24,
                                                  fontWeight: FontWeight.bold
                                              ),
                                            ),
                                          ),

                                          SizedBox(
                                            height: screenHeight*0.03,
                                          ),

                                          const SmallDiscountTile(),

                                          // Check it out button
                                          Padding(
                                            padding: EdgeInsets.only(
                                              // top:screenHeight*0.005,
                                              right: screenWidth*0.05,
                                              bottom: 7,
                                            ),
                                            child: Align(
                                              alignment: Alignment.bottomRight,
                                              child: GestureDetector(
                                                child: Container(
                                                    width: screenWidth*0.4,
                                                    decoration: const BoxDecoration(
                                                      gradient:LinearGradient(
                                                          colors: [
                                                            // Colors.deepPurple, Colors.deepPurpleAccent
                                                            Colors.purple,
                                                            Colors.purpleAccent,
                                                          ],
                                                          begin: Alignment.topLeft,
                                                          end: Alignment.bottomRight,
                                                          stops: [0.2, 0.9]
                                                      ),
                                                      // color: Colors.deepPurple,
                                                      // gradient: LinearGradient(
                                                      //     colors: [
                                                      //       Colors.deepPurple, Colors.deepPurpleAccent
                                                      //     ]
                                                      // ),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors.black54,
                                                          spreadRadius: 1,
                                                          blurRadius: 7,
                                                          offset: Offset(3, 3), // changes position of shadow
                                                        ),
                                                      ],
                                                      borderRadius: BorderRadius.all(
                                                          Radius.circular(10)
                                                      ),
                                                      // border: Border.all(
                                                      //     color: Colors.purpleAccent
                                                      // )
                                                    ),
                                                    padding: EdgeInsets.all(18),
                                                    child: const Center(
                                                      child: Text(
                                                        "Mehr Discounts!",
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            // fontWeight: FontWeight.bold,
                                                            fontSize: 12,
                                                            fontWeight: FontWeight.bold
                                                        ),
                                                      ),
                                                    )
                                                ),
                                                onTap: (){

                                                  // ClubMeEvent newEvent = ClubMeEvent(
                                                  //     title: _textEditingControllerTitle.text,
                                                  //     clubName: _textEditingControllerClub.text,
                                                  //     DjName: _textEditingControllerDJName.text,
                                                  //     date: _selectedDay.toString() + "." + _selectedMonth.toString() + "." + _selectedYear.toString(),
                                                  //     price: _textEditingControllerPrice.text,
                                                  //     imagePath: "assets/images/img_6.png"
                                                  // );
                                                  //
                                                  // stateProvider.setCurrentEvent(newEvent);
                                                  // context.go("/event_details");

                                                },
                                              ),
                                            ),
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
                          SizedBox(
                            height: screenHeight*0.05,
                          ),

                        ]
                    )
                )
            )
    );
  }
}


class SmallDiscountTile extends StatelessWidget {
  const SmallDiscountTile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Container
      (
      padding: EdgeInsets.only(bottom: screenHeight*0.02),
      child: Card(
        child: Column(
          children: [

            // TODO: No matter which image: Everything should be cropped the same

            // Image container
            Container(
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(12),
                      topLeft: Radius.circular(12)
                  ),
                  border: Border(
                    // top: BorderSide(
                    //     width: 1, color: Colors.white60
                    // ),
                    left: BorderSide(
                        width: 1, color: Colors.white60
                    ),
                    right: BorderSide(
                        width: 1, color: Colors.white60
                    ),
                  ),
                ),
                child: Container(
                  width: screenWidth*0.8,
                    height: screenHeight*0.15,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(12),
                          topLeft: Radius.circular(12)
                      ),
                      child: Image.asset(
                        "assets/images/img_6.png",
                        fit: BoxFit.fill,
                      ),
                    )
                )
            ),


            // Content container
            Container(
                height: screenHeight*0.12,
                width: screenWidth*0.805,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                      bottomRight: Radius.circular(12),
                      bottomLeft: Radius.circular(12)
                  ),
                  border: const Border(
                    // bottom: BorderSide(
                    //     width: 1, color: Colors.white60
                    // ),
                    left: BorderSide(
                        width: 1, color: Colors.white60
                    ),
                    right: BorderSide(
                        width: 1, color: Colors.white60
                    ),
                  ),
                  // color: Colors.grey[800]
                  gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.grey[700]!,
                        Colors.grey[850]!
                      ],
                      stops: [0.3, 0.8]
                  ),
                ),
                child: Stack(
                  children: [
                    Column(
                      children: [

                        // Title
                        const Padding(
                          padding: EdgeInsets.only(
                              top: 10,
                              left: 10
                          ),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Moscow Mule: 2 for 1",
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold
                              ),
                            ),
                          ),
                        ),

                        // Location
                        const Padding(
                          padding: EdgeInsets.only(
                            // top: 5,
                              left: 10
                          ),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "24.05.2024",
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold
                              ),
                            ),
                          ),
                        ),

                        // DJ
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 3,
                              left: 10
                          ),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "153 Mal aufgerufen",
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[400]
                              ),
                            ),
                          ),
                        ),

                      ],
                    ),

                  ],
                )
            )
          ],
        ),
      ),
    );
  }
}
