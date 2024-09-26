import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../provider/current_and_liked_elements_provider.dart';
import '../../provider/state_provider.dart';
import '../../provider/user_data_provider.dart';
import '../../shared/custom_bottom_navigation_bar.dart';
import '../../shared/custom_bottom_navigation_bar_clubs.dart';
import '../../shared/custom_text_style.dart';

class OffersListView extends StatefulWidget {
  const OffersListView({super.key});

  @override
  State<OffersListView> createState() => _OffersListViewState();
}

class _OffersListViewState extends State<OffersListView> {

  String headline = "Angebote";

  late double screenHeight, screenWidth;
  late CustomStyleClass customStyleClass;
  late StateProvider stateProvider;
  late CurrentAndLikedElementsProvider currentAndLikedElementsProvider;

  // BUILD
  Widget _buildAppBarShowTitle(){
    return SizedBox(
      width: screenWidth*0.67,
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Row(
                        children: [
                          Text(
                            "Angebote",
                            textAlign: TextAlign.center,
                            style: customStyleClass.getFontStyleHeadline1Bold(),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                bottom: 15
                            ),
                            child: Text(
                              "VIP",
                              style: customStyleClass.getFontStyleVIPGold(),
                            ),
                          )
                        ],
                      ),
                    ],
                  )
                ],
              )
          ),

          // back icon
          // Container(
          //     width: screenWidth,
          //     height: 50,
          //     alignment: Alignment.centerLeft,
          //     child: Column(
          //       mainAxisAlignment: MainAxisAlignment.center,
          //       children: [
          //
          //         InkWell(
          //           child: const Icon(
          //             Icons.arrow_back_ios_new_outlined,
          //             color: Colors.white,
          //             // size: 20,
          //           ),
          //           onTap: () => ,
          //         ),
          //
          //       ],
          //     )
          // ),
        ],
      ),
    );
  }

  void backButtonPressed(){
    if(stateProvider.clubUIActive){
      context.go("/club_frontpage");
    }else{
      context.go("/club_details");
    }
  }

  Widget _buildView(){
    return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: currentAndLikedElementsProvider.currentClubMeClub.clubOffers.offers.length,
        itemBuilder: ((context, index){
          return
            Center(
            child: Container(
              padding: const EdgeInsets.only(
                top: 10
              ),
              width: screenWidth*0.9,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    width: screenWidth*0.7,
                    // color: Colors.red,
                    alignment: Alignment.centerLeft,
                    child: Column(
                      children: [
                        SizedBox(
                          width: screenWidth*0.7,
                          child: Text(
                            currentAndLikedElementsProvider.currentClubMeClub.clubOffers.offers[index].title.toString(),
                            style: customStyleClass.getFontStyle2Bold(),
                            textAlign: TextAlign.left,
                          ),
                        ),
                        SizedBox(
                          width: screenWidth*0.7,
                          child: Text(
                            currentAndLikedElementsProvider.currentClubMeClub.clubOffers.offers[index].description.toString(),
                            style: customStyleClass.getFontStyle4(),
                            textAlign: TextAlign.left,
                          ),
                        )
                      ],
                    ),
                  ),
                  Container(
                    width: screenWidth*0.2,
                    // color: Colors.green,
                    alignment: Alignment.topRight,
                    child: Text(
                      "${currentAndLikedElementsProvider.currentClubMeClub.clubOffers.offers[index].price.toString().replaceAll(".", ",")}0 €",
                      style: customStyleClass.getFontStyle2Bold(),
                    ),
                  )
                ],
              ),
            ),
          );
        }
        )
    );
  }

  @override
  Widget build(BuildContext context) {

    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    customStyleClass = CustomStyleClass(context: context);
    currentAndLikedElementsProvider = Provider.of<CurrentAndLikedElementsProvider>(context);
    stateProvider = Provider.of<StateProvider>(context);

    return Scaffold(

      extendBody: true,


      appBar: AppBar(
          surfaceTintColor: Colors.black,
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          title: _buildAppBarShowTitle(),
          leading: InkWell(
            child: const Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
            ),
            onTap: () => backButtonPressed(),
          )
      ),
      body: SizedBox(
          width: screenWidth,
          height: screenHeight,
          child: Stack(
            children: [

              // main view
              SingleChildScrollView(
                  physics: const ScrollPhysics(),
                  child: Column(
                    children: [

                      Container(
                        padding: EdgeInsets.symmetric(
                          vertical: 10
                        ),
                        child: Text(
                          currentAndLikedElementsProvider.currentClubMeClub.getClubName(),
                          style: customStyleClass.getFontStyle1(),
                        ),
                      ),

                      _buildView(),

                      // Spacer
                      SizedBox(height: screenHeight*0.1,),
                    ],
                  )
              ),
            ],
          )
      ),
      bottomNavigationBar: CustomBottomNavigationBar(),
    );
  }
}
