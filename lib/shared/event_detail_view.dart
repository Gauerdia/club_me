import 'package:club_me/shared/custom_bottom_navigation_bar_clubs.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../provider/state_provider.dart';
import 'custom_bottom_navigation_bar.dart';

class EventDetailView extends StatelessWidget {
  const EventDetailView({
    Key? key
  }) : super(key: key);


  Widget _buildIconRow(){
    return const Padding(
        padding: EdgeInsets.only(
          // top: screenHeight*0.09
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.purpleAccent,
                ),
                SizedBox(width: 15,),
                Icon(
                  Icons.star_border,
                  color: Colors.purpleAccent,
                ),
                SizedBox(width: 15,),
                Icon(
                  Icons.share,
                  color: Colors.purpleAccent,
                ),
                SizedBox(width: 25,),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  "Info",
                  style: TextStyle(
                    fontSize: 12,

                  ),
                ),
                SizedBox(width: 12,),
                Text(
                  "Like",
                  style: TextStyle(
                    fontSize: 12,

                  ),
                ),
                SizedBox(width: 10,),
                Text(
                  "Share",
                  style: TextStyle(
                    fontSize: 12,

                  ),
                ),
                SizedBox(width: 18,),
              ],
            ),
            SizedBox(
              height: 10,
            )
          ],
        )
    );
  }

  @override
  Widget build(BuildContext context) {

    final stateProvider = Provider.of<StateProvider>(context);

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    String eventPrice = stateProvider.clubMeEvent.getPrice();
    
    String titleToDisplay = "";
    
    if(stateProvider.clubMeEvent.getTitle().length > 20){
      titleToDisplay = "${stateProvider.clubMeEvent.getTitle().substring(0, 20)}...";
    }else{
      titleToDisplay = stateProvider.clubMeEvent.getTitle();
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,

      bottomNavigationBar: stateProvider.clubUIActive ? CustomBottomNavigationBarClubs() : CustomBottomNavigationBar(),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text("Events Details"),

        actions: [

          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: const Color(0xff11181f),
                  borderRadius: BorderRadius.circular(45),
                ),
                child: const Icon(
                  Icons.menu,
                  color: Colors.grey,
                )
            ),
          )
        ],

        leading: GestureDetector(
          child: const Icon(
            Icons.arrow_back_ios,
            color: Colors.grey,
            // size: 20,
          ),
          onTap: (){

            if(stateProvider.wentFromClubDetailToEventDetail){
              if(stateProvider.clubUIActive){
                context.go("/club_frontpage");
              }else{
                context.go("/club_details");
              }
            }else{
              stateProvider.resetWentFromCLubDetailToEventDetail();
              if(stateProvider.clubUIActive){
                switch(stateProvider.pageIndex){
                  case(0): context.go('/club_events');break;
                  case(1): context.go('/club_stats'); break;
                  case(2): context.go('/club_coupons'); break;
                  case(3): context.go('/club_frontpage');break;
                  default: context.go('/club_events');break;
                }
              }else{
                switch(stateProvider.pageIndex){
                  case(0): context.go('/user_events');break;
                  case(1): context.go('/user_clubs'); break;
                  case(2): context.go('/user_map'); break;
                  case(3): context.go('/user_coupons');break;
                  default: context.go('/user_events');break;
                }
              }
            }

          },
        )

      ),

      body: Column(
        children: [

          // Padding top
          SizedBox(
            height: screenHeight*0.14,
          ),

          // Header
          Container(
            width: screenWidth,
            height: screenHeight*0.2,
            color: Colors.red,
            child: Image.asset(
              stateProvider.clubMeEvent.getImagePath(),
              fit: BoxFit.cover,
            ),
          ),

          // Main Infos
          Container(
            width: screenWidth,
            height: screenHeight*0.18,
            decoration: BoxDecoration(
              border: const Border(
                bottom: BorderSide(color: Colors.white60)
              ),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.grey[850]!, Colors.grey[700]!],
                stops: const [0.4, 0.8]
              )
            ),
            child: Stack(
              children: [


                Column(
                  children: [



                    // Title
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 10,
                          left: 10
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          titleToDisplay,
                          // "LATINO NIGHT",
                          style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            color: Color(0xffc0c0c0)
                          ),
                        ),
                      ),
                    ),

                    // Location
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 10
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                            stateProvider.clubMeEvent.getClubName(),
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xffc0c0c0)
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
                            stateProvider.clubMeEvent.getDjName(),
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[500]
                          ),
                        ),
                      ),
                    ),

                    // When
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 3,
                          left: 10
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                            stateProvider.clubMeEvent.getDate(),
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[500]
                          ),
                        ),
                      ),
                    ),

                  ],
                ),

                // Price
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.only(
                        top: 10,
                        right: 15
                    ),
                    child: Align(
                      alignment: Alignment.topRight,
                      child: Text(
                        "$eventPrice €",
                        style: const TextStyle(
                            fontSize: 22,
                            color: Colors.white70
                        ),
                      ),
                    ),
                  ),
                ),

                // Icons
                Container(
                  alignment: Alignment.bottomRight,
                  width: screenWidth,
                  height: screenHeight*0.2,
                  child: _buildIconRow()
                ),

              ],
            )
          ),

          // Description
          Container(
            padding: const EdgeInsets.all(20),
            height: screenHeight*0.3,
            // color: Colors.red,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Text(stateProvider.clubMeEvent.getDescription(),
                    style: const TextStyle(
                      // fontFamily: GoogleFonts.actor
                    ),
                  ),
                ],
              ),
            )
          ),

          // Buttons
          Container(
            height: screenHeight*0.07,
            width: screenWidth,
            alignment: Alignment.centerRight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.grey[800],
                        borderRadius: const BorderRadius.all(
                            Radius.circular(10)
                        ),
                        border: Border.all(color: Colors.grey[600]!)
                    ),
                    padding: const EdgeInsets.all(10),
                    child: const Text(
                      "Directions!",
                      style: TextStyle(
                          color: Colors.purpleAccent,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
                  onTap: (){

                  },
                ),

                SizedBox(width: screenWidth*0.02,),

                GestureDetector(
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.grey[800],
                        borderRadius: const BorderRadius.all(
                            Radius.circular(10)
                        ),
                      border: Border.all(color: Colors.grey[600]!)
                    ),
                    padding: const EdgeInsets.all(10),
                    child: const Text(
                      "I'm in!",
                      style: TextStyle(
                          color: Colors.purpleAccent,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
                  onTap: (){

                  },
                ),

                SizedBox(width: screenWidth*0.02,),

              ],
            ),
          )

        ],
      ),


    );
  }
}
