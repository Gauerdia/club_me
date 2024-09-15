import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../provider/state_provider.dart';
import '../../../provider/user_data_provider.dart';
import '../../../services/supabase_service.dart';
import '../../../shared/custom_bottom_navigation_bar_clubs.dart';
import '../../../shared/custom_text_style.dart';

class UpdateNewsView extends StatefulWidget {
  const UpdateNewsView({Key? key}) : super(key: key);

  @override
  State<UpdateNewsView> createState() => _UpdateNewsViewState();
}

class _UpdateNewsViewState extends State<UpdateNewsView> {

  String headLine = "News anpassen";

  bool initDone = false;
  bool sendClicked = false;

  late StateProvider stateProvider;
  late UserDataProvider userDataProvider;
  late CustomStyleClass customStyleClass;

  late double screenHeight, screenWidth;

  TextEditingController controller = TextEditingController();
  final SupabaseService _supabaseService = SupabaseService();

  // BUILD
  AppBar _buildAppBar(){
    return AppBar(
      backgroundColor: Colors.transparent,
      title: SizedBox(
        width: screenWidth,
        child: Stack(
          children: [
            Container(
                alignment: Alignment.bottomCenter,
                height: 50,
                width: screenWidth,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(headLine,
                        textAlign: TextAlign.center,
                        style: customStyleClass.getFontStyle1()
                    ),
                  ],
                )
            ),

            Container(
                width: screenWidth,
                alignment: Alignment.centerLeft,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(
                          Icons.arrow_back_ios_new_outlined,
                        color: Colors.white,
                      ),
                      onPressed: (){
                        context.go('/club_frontpage');
                      },
                    ),
                  ],
                )
            ),

          ],
        ),
      ),
    );
  }
  Widget _buildMainColumn(){
    return Column(
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
              cursorColor: customStyleClass.primeColor,
              controller: controller,
              keyboardType: TextInputType.multiline,
              maxLines: null,
              decoration: const InputDecoration(
                  border: OutlineInputBorder()
              ),
              style: customStyleClass.getFontStyle4(),
              maxLength: 300,
            ),
          ),

          // Spacer
          SizedBox(
            height: screenHeight*0.01,
          ),

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
              alignment: Alignment.bottomRight,
              child: GestureDetector(
                child: Container(
                  padding: EdgeInsets.symmetric(
                      vertical: screenHeight*0.015,
                      horizontal: screenWidth*0.03
                  ),
                  decoration: BoxDecoration(
                      color: Colors.black54,
                      border: Border.all(
                          color: customStyleClass.primeColor
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(10))
                  ),
                  child: Text(
                    "News anpassen!",
                    textAlign: TextAlign.center,
                    style: customStyleClass.getFontStyle4BoldPrimeColor(),
                  ),
                ),
                onTap: () => clickOnUpdateButton(stateProvider, controller),
              )
          ),

          SizedBox(
            height: screenHeight*0.4,
          )

        ]
    );
  }

  // CLICK
  void clickOnUpdateButton(StateProvider stateProvider, TextEditingController controller) async{

    setState(() {
      sendClicked = true;
    });

    await _supabaseService.updateClub(
        userDataProvider.getUserClubId(),
        1,
        controller.text
    ).then((value){
      if(value == 0){
        userDataProvider.setUserClubNews(controller.text);
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

  // MISC
  void initController(){
    setState(() {
      controller = TextEditingController(
          text: userDataProvider.getUserClubNews()
      );
      initDone = true;
    });
  }


  @override
  Widget build(BuildContext context) {

    customStyleClass = CustomStyleClass(context: context);
    stateProvider = Provider.of<StateProvider>(context);
    userDataProvider = Provider.of<UserDataProvider>(context);

    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;

    if(!initDone){
      initController();
    }

    return Scaffold(

        extendBody: true,
        resizeToAvoidBottomInset: true,

        bottomNavigationBar: CustomBottomNavigationBarClubs(),
        appBar: _buildAppBar(),
        body: Container(
            width: screenWidth,
            height: screenHeight,
            // decoration: const BoxDecoration(
            //   gradient: LinearGradient(
            //       begin: Alignment.topLeft,
            //       end: Alignment.bottomRight,
            //       colors: [
            //         Color(0xff2b353d),
            //         Color(0xff11181f)
            //       ],
            //       stops: [0.15, 0.6]
            //   ),
            // ),

            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: _buildMainColumn(),
            )
        )
    );
  }

}
