import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../provider/state_provider.dart';
import '../../services/supabase_service.dart';
import '../../shared/custom_bottom_navigation_bar_clubs.dart';
import '../../shared/custom_text_style.dart';

class UpdateNewsView extends StatefulWidget {
  const UpdateNewsView({Key? key}) : super(key: key);

  @override
  State<UpdateNewsView> createState() => _UpdateNewsViewState();
}

class _UpdateNewsViewState extends State<UpdateNewsView> {

  String headLine = "News anpassen";

  bool sendClicked = false;

  late StateProvider stateProvider;

  late CustomTextStyle customTextStyle;

  final SupabaseService _supabaseService = SupabaseService();

  bool initDone = false;

  TextEditingController controller = TextEditingController();

  void initController(){
    setState(() {
      controller = TextEditingController(
          text:stateProvider.getUserClubNews()
      );
      initDone = true;
    });
  }


  void clickOnUpdateButton(StateProvider stateProvider, TextEditingController controller) async{

    setState(() {
      sendClicked = true;
    });

    await _supabaseService.updateClub(
        stateProvider.getClubId(),
        1,
        controller.text
    ).then((value){
      if(value == 0){
        stateProvider.setClubNews(controller.text);
        context.go('/club_frontpage');
      }else{
        setState(() {
          sendClicked = false;
        });
        showModalBottomSheet(
            context: context,
            builder: (BuildContext context){
              return const SizedBox(
                height: 200,
                child: Center(
                  child: Text("Sorry, something went wrong!"),
                ),
              );
            }
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {

    stateProvider = Provider.of<StateProvider>(context);

    customTextStyle = CustomTextStyle(context: context);

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    if(!initDone){
      initController();
    }

    return Scaffold(

        extendBodyBehindAppBar: true,
        extendBody: true,
        resizeToAvoidBottomInset: true,

        bottomNavigationBar: CustomBottomNavigationBarClubs(),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: SizedBox(
            width: screenWidth,
            child: Text(headLine,
              style: customTextStyle.size1Bold()
            ),
          ),
          leading: IconButton(
            icon: const Icon(
                Icons.arrow_back_ios_new_outlined
            ),
            onPressed: (){
              context.go('/club_frontpage');
            },
          ),
        ),
        body: Container(
            width: screenWidth,
            height: screenHeight,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xff2b353d),
                    Color(0xff11181f)
                  ],
                  stops: [0.15, 0.6]
              ),
            ),

            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: Column(
                  children: [

                    // Spacer
                    SizedBox(
                      height: screenHeight*0.2,
                    ),

                    // ProgressIndicator / Textfield
                    sendClicked ? const Center(
                      child: CircularProgressIndicator(),
                    )
                        : SizedBox(
                      width: screenWidth*0.8,
                      child: TextField(
                        controller: controller,
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        decoration: const InputDecoration(
                            border: OutlineInputBorder()
                        ),
                        maxLength: 300,
                      ),
                    ),

                    // Spacer
                    SizedBox(
                      height: screenHeight*0.01,
                    ),

                    // Unfocus - Button
                    // Container(
                    //   width: screenWidth*0.8,
                    //   alignment: Alignment.bottomRight,
                    //   child: Padding(
                    //     padding: EdgeInsets.symmetric(
                    //         vertical: screenHeight*0.01,
                    //         horizontal: screenWidth*0.01
                    //     ),
                    //     child: GestureDetector(
                    //       child: Container(
                    //         padding: EdgeInsets.symmetric(
                    //             horizontal: screenWidth*0.035,
                    //             vertical: screenHeight*0.02
                    //         ),
                    //         decoration: BoxDecoration(
                    //           borderRadius: const BorderRadius.all(
                    //               Radius.circular(10)
                    //           ),
                    //           gradient: LinearGradient(
                    //               colors: [
                    //                 stateProvider.getPrimeColorDark(),
                    //                 stateProvider.getPrimeColor(),
                    //               ],
                    //               begin: Alignment.topLeft,
                    //               end: Alignment.bottomRight,
                    //               stops: const [0.2, 0.9]
                    //           ),
                    //           boxShadow: const [
                    //             BoxShadow(
                    //               color: Colors.black54,
                    //               spreadRadius: 1,
                    //               blurRadius: 7,
                    //               offset: Offset(3, 3),
                    //             ),
                    //           ],
                    //         ),
                    //         child: Text(
                    //           "Fertig",
                    //           style: TextStyle(
                    //               fontSize: screenHeight*0.015,
                    //               fontWeight: FontWeight.bold
                    //           ),
                    //         ),
                    //       ),
                    //       onTap: ()=> FocusScope.of(context).unfocus(),
                    //     ),
                    //   ),
                    // ),

                    // Spacer
                    SizedBox(
                      height: screenHeight*0.05,
                    ),

                    sendClicked ? const Padding(
                      padding: EdgeInsets.only(top: 5),
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    ) :

                    Container(
                        width: screenWidth*0.9,
                        // color: Colors.red,
                        alignment: Alignment.bottomRight,
                        child: GestureDetector(
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                vertical: screenHeight*0.015,
                                horizontal: screenWidth*0.03
                            ),
                            decoration: const BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.all(Radius.circular(10))
                            ),
                            child: Text(
                              "News anpassen!",
                              textAlign: TextAlign.center,
                              style: customTextStyle.size4BoldPrimeColor(),
                            ),
                          ),
                          onTap: () => clickOnUpdateButton(stateProvider, controller),
                        )
                    ),

                    SizedBox(
                      height: screenHeight*0.4,
                    )

                  ]
              ),
            )
        )
    );
  }

}
