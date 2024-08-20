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

  bool initDone = false;
  bool sendClicked = false;

  late StateProvider stateProvider;
  late CustomTextStyle customTextStyle;
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
                        style: customTextStyle.size2()
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
                          Icons.arrow_back_ios_new_outlined
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
    );
  }


  // CLICK
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


  // MISC
  void initController(){
    setState(() {
      controller = TextEditingController(
          text:stateProvider.getUserClubNews()
      );
      initDone = true;
    });
  }


  @override
  Widget build(BuildContext context) {

    stateProvider = Provider.of<StateProvider>(context);

    customTextStyle = CustomTextStyle(context: context);

    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;

    if(!initDone){
      initController();
    }

    return Scaffold(

        // extendBodyBehindAppBar: true,
        extendBody: true,
        resizeToAvoidBottomInset: true,

        bottomNavigationBar: CustomBottomNavigationBarClubs(),
        appBar: _buildAppBar(),
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
              child: _buildMainColumn(),
            )
        )
    );
  }

}
