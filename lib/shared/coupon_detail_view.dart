import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../provider/state_provider.dart';
import 'custom_bottom_navigation_bar.dart';

class CouponDetailView extends StatelessWidget {
  CouponDetailView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    final stateProvider = Provider.of<StateProvider>(context);

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(

      extendBodyBehindAppBar: true,
      extendBody: true,

      bottomNavigationBar: CustomBottomNavigationBar(),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(stateProvider.clubMeDiscount.getTitle()),
          leading: GestureDetector(
            child: const Icon(
              Icons.arrow_back_ios,
              color: Colors.grey,
              // size: 20,
            ),
            onTap: (){
              switch(stateProvider.pageIndex){
                case(0): context.go('/user_events');break;
                case(1): context.go('/user_clubs'); break;
                case(2): context.go('/user_map'); break;
                case(3): context.go('/user_coupons');break;
                default: context.go('/user_events');break;
              }

            },
          )
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
          child: Column(
            children: [

              // Spacer
              SizedBox(height: screenHeight*0.17,),

              QrImageView(
                  data: "122345435",
                version: QrVersions.auto,
                size: 400.0,
                backgroundColor: Colors.white,
              )

            ],
          ),
        )

    );
  }
}
