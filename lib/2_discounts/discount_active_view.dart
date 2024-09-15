import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:glowy_borders/glowy_borders.dart';
import 'package:no_screenshot/no_screenshot.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../provider/current_and_liked_elements_provider.dart';
import '../provider/state_provider.dart';

import '../shared/custom_text_style.dart';

class DiscountActiveView extends StatefulWidget {
  const DiscountActiveView({Key? key}) : super(key: key);

  @override
  State<DiscountActiveView> createState() => _DiscountActiveViewState();
}

class _DiscountActiveViewState extends State<DiscountActiveView>
  with TickerProviderStateMixin{


  /// TODO: 30 min before expiration, display timer

  int _start = 10;

  late Timer _timer;
  late StateProvider stateProvider;
  late AnimationController _controller;
  late CustomStyleClass customStyleClass;
  late double screenHeight, screenWidth;
  late CurrentAndLikedElementsProvider currentAndLikedElementsProvider;

  final _noScreenshot = NoScreenshot.instance;

  @override
  void initState() {
    // TODO: Block the coupon directly so that the user cant avoid the block by closing the app
    super.initState();
    _noScreenshot.screenshotOff();
    _controller = AnimationController(
      vsync: this,
      lowerBound: 0.3,
      duration: const Duration(seconds: 5),
    )..repeat();
    startTimer();
  }
  @override
  void dispose() {
    _controller.dispose();
    _timer.cancel();
    super.dispose();
  }

  // MISC
  void startTimer() async{

    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(
      oneSec,
          (Timer timer) async {
        if (_start <= 0) {
          setState(() {
            _start = 0;
            timer.cancel();
            markDiscountAsRedeemed();
            context.go('/user_coupons');
            // Todo: lock the code
          });
        } else {
          setState(() {
            _start--;
          });
        }
      },
    );
  }
  void markDiscountAsRedeemed(){
    /// TODO: IMPLEMENT FOR LAUNCH
  }
  String formatClock(){

    String hour = stateProvider.getBerlinTime().hour.toString();
    String minute = stateProvider.getBerlinTime().minute.toString();
    String second = stateProvider.getBerlinTime().second.toString();

    if(hour.length == 1){
      hour = "0$hour";
    }
    if(minute.length == 1){
      minute = "0$minute";
    }
    if(second.length == 1){
      second = "0$second";
    }

    return "$hour:$minute:$second";
  }

  // BUILD
  AppBar _buildAppBar(){
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.transparent,
      title: Stack(
        children: [
          SizedBox(
            width: screenWidth,
            child: Text(
              textAlign: TextAlign.center,
              currentAndLikedElementsProvider.currentClubMeDiscount.getDiscountTitle(),
              style: customStyleClass.getFontStyle2(),
            ),
          ),
          SizedBox(
            width: screenWidth,
            child: Text(
              formatClock(),
              textAlign: TextAlign.left,
              style: customStyleClass.getFontStyle3BoldPrimeColor(),
            ),
          )
        ],
      )
    );
  }
  Widget _buildContainer(double radius) {
    return Container(
      width: radius,
      height: radius,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: customStyleClass.primeColor.withOpacity(1 - _controller.value),
      ),
    );
  }
  Widget _buildBody(double screenWidth, double screenHeight) {

    customStyleClass = CustomStyleClass(context: context);

    var currentProgress = null;

    return Stack(
      alignment: Alignment.center,
      children: <Widget>[

        // CircleAvatar
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            SizedBox(
              child: Text(
                _start.toString(),
                style: customStyleClass.getFontStyleHeadline1Bold(),
              ),
            ),

            SizedBox(
              width: screenWidth,
              child: SizedBox(
                child: Center(
                  child: AnimatedGradientBorder(
                      borderSize: 2,
                      glowSize: 10,
                      gradientColors: [
                        Colors.transparent,
                        Colors.transparent,
                        Colors.transparent,
                        customStyleClass.primeColor
                      ],
                      animationProgress: currentProgress,
                      borderRadius: const BorderRadius.all(Radius.circular(210)),
                      child: SizedBox(
                        // width: 300,
                        // height: 300,
                        child:
                          ClipRRect(
                            borderRadius: BorderRadius.circular(210),
                            child: Image(
                              width: 200,
                              height: 200,
                              image: FileImage(
                                  File(
                                      "${stateProvider.appDocumentsDir.path}/${currentAndLikedElementsProvider.currentClubMeDiscount.getBannerId()}"
                                  )
                              ),
                              fit: BoxFit.cover,
                            ),
                          )

                        // Container(
                        //   decoration: const BoxDecoration(
                        //       borderRadius: BorderRadius.all(Radius.circular(999)),
                        //       color: Colors.black),
                        //   child: Column(
                        //     mainAxisAlignment: MainAxisAlignment.center,
                        //     children: [
                        //       Container(
                        //         decoration: const BoxDecoration(
                        //             borderRadius: BorderRadius.all(Radius.circular(30)),
                        //             color: Colors.black),
                        //         width: 300,
                        //         height: 300,
                        //         child: CircleAvatar(
                        //           radius: 30,
                        //           backgroundColor: Colors.transparent,
                        //           child: Image(
                        //             image: FileImage(
                        //                 File(
                        //                     "${stateProvider.appDocumentsDir.path}/${currentAndLikedElementsProvider.currentClubMeDiscount.getBannerId()}"
                        //                 )
                        //             ),
                        //             fit: BoxFit.cover,
                        //           ),
                        //         ),
                        //       )
                        //     ],
                        //   ),
                        // ),
                      ),
                    )
              ),
            )
            )
          ],
        ),
      ],
    );
  }


  @override
  Widget build(BuildContext context) {

    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    customStyleClass = CustomStyleClass(context: context);
    stateProvider = Provider.of<StateProvider>(context);
    currentAndLikedElementsProvider = Provider.of<CurrentAndLikedElementsProvider>(context);

    return Scaffold(
        extendBody: true,
        appBar: _buildAppBar(),
        body: _buildBody(screenWidth, screenHeight)
    );
  }
}


