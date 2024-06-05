import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../provider/state_provider.dart';
import 'dart:async';
import 'package:timezone/standalone.dart' as tz;

import '../custom_text_style.dart';

class DiscountActiveView extends StatefulWidget {
  const DiscountActiveView({Key? key}) : super(key: key);

  @override
  State<DiscountActiveView> createState() => _DiscountActiveViewState();
}

class _DiscountActiveViewState extends State<DiscountActiveView>
  with TickerProviderStateMixin{


  /// TODO: 30 min before expiration, display timer

  late StateProvider stateProvider;

  late CustomTextStyle customTextStyle;

  late Timer _timer;
  int _start = 10;

  late AnimationController _controller;

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
          print("$_start");
          setState(() {
            _start--;
          });
        }
      },
    );
  }

  void markDiscountAsRedeemed(){}

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      lowerBound: 0.3,
      duration: const Duration(seconds: 5),
    )..repeat();
    startTimer();
  }

  @override
  void dispose() {

    // TODO: Block the coupon so that the user cant avoid the block by closing the app
    _timer.cancel();
    super.dispose();
  }


  String formatClock(tz.TZDateTime timeStamp){

    String hour = timeStamp.hour.toString();
    String minute = timeStamp.minute.toString();
    String second = timeStamp.second.toString();

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




  Widget _buildBody(double screenWidth, double screenHeight) {

    final berlin = tz.getLocation('Europe/Berlin');
    final todayTimestamp = tz.TZDateTime.from(DateTime.now(), berlin);

    customTextStyle = CustomTextStyle(context: context);

    return AnimatedBuilder(
      animation: CurvedAnimation(parent: _controller, curve: Curves.fastOutSlowIn),
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: <Widget>[

            // Waves
            _buildContainer(300 * _controller.value),
            _buildContainer(350 * _controller.value),
            _buildContainer(400 * _controller.value),
            _buildContainer(450 * _controller.value),
            _buildContainer(550 * _controller.value),

            // CircleAvatar
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: screenWidth*0.4,
                  height: screenWidth*0.4,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: AssetImage(
                        "assets/images/${stateProvider.clubMeDiscount.getBannerId()}",
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Padding(
            //   child: Text(
            //     "$_start",
            //     style: customTextStyle.activeDiscountTimer(),
            //   ),
            //   padding: EdgeInsets.only(
            //     bottom: screenHeight*0.6
            //   ),
            // ),
            Padding(
              padding: EdgeInsets.only(top: screenHeight*0.15),
              child: Container(
                  alignment: Alignment.topCenter,
                  height: screenHeight,
                  padding: const EdgeInsets.all(15),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 20,
                        horizontal: 30
                    ),
                    decoration: BoxDecoration(
                        color: const Color(0xff11181f),
                        borderRadius: const BorderRadius.all(Radius.circular(12)),
                        border: Border.all(
                            color: Colors.grey
                        )
                    ),
                    child:  Text(
                      "$_start",
                      style: customTextStyle.activeDiscountTimer(),
                    ),
                  )
              ),
            ),

            Padding(
              padding: EdgeInsets.only(
                bottom: screenHeight*0.02
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // Datetime
                  Container(
                    // width: screenWidth*0.9,
                    // color: Colors.red,
                      alignment: Alignment.bottomRight,
                      child: GestureDetector(
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              vertical: screenHeight*0.025,
                              horizontal: screenWidth*0.04
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                                colors: [
                                  stateProvider.getPrimeColorDark(),
                                  stateProvider.getPrimeColor(),
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
                          child: Text(
                            formatClock(todayTimestamp),
                            textAlign: TextAlign.center,
                            style: customTextStyle.size4Bold(),
                          ),
                        ),
                        onTap: ()=> {
                          setState(() {
                            _start = 0;
                          })
                        },
                      )
                  ),

                  // Schließen button
                  Container(
                    // width: screenWidth*0.9,
                    // color: Colors.red,
                      alignment: Alignment.bottomRight,
                      child: GestureDetector(
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              vertical: screenHeight*0.025,
                              horizontal: screenWidth*0.04
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                                colors: [
                                  stateProvider.getPrimeColorDark(),
                                  stateProvider.getPrimeColor(),
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
                          child: Text(
                            "Schließen",
                            textAlign: TextAlign.center,
                            style: customTextStyle.size4Bold(),
                          ),
                        ),
                        onTap: ()=> {
                          setState(() {
                            _start = 0;
                          })
                        },
                      )
                  ),
                ],
              ),
            ),

          ],
        );
      },
    );
  }

  Widget _buildContainer(double radius) {
    return Container(
      width: radius,
      height: radius,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: stateProvider.getPrimeColor().withOpacity(1 - _controller.value),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    stateProvider = Provider.of<StateProvider>(context);

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    customTextStyle = CustomTextStyle(context: context);

    return Scaffold(

      // extendBodyBehindAppBar: true,
        extendBody: true,

        appBar: AppBar(
          // automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          title: SizedBox(
            width: screenWidth,
            child: Text(
              textAlign: TextAlign.center,
              stateProvider.clubMeDiscount.getDiscountTitle(),
              style: customTextStyle.size2(),
            ),
          ),
        ),

        body: _buildBody(screenWidth, screenHeight)


    );
  }

}


