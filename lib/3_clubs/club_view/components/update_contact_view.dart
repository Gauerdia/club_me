import 'package:flutter/services.dart';

import '../../../provider/state_provider.dart';
import '../../../provider/user_data_provider.dart';
import '../../../services/supabase_service.dart';
import '../../../shared/custom_bottom_navigation_bar_clubs.dart';
import '../../../shared/custom_text_style.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

class UpdateContactView extends StatefulWidget {
  const UpdateContactView({Key? key}) : super(key: key);

  @override
  State<UpdateContactView> createState() => _UpdateContactViewState();
}

class _UpdateContactViewState extends State<UpdateContactView> {



  String headLine = "Kontakt anpassen";

  bool initDone = false;
  bool sendClicked = false;

  late UserDataProvider userDataProvider;
  late StateProvider stateProvider;
  late CustomStyleClass customStyleClass;
  late double screenWidth, screenHeight;

  final SupabaseService _supabaseService = SupabaseService();
  TextEditingController zipController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController streetController = TextEditingController();
  TextEditingController streetNumberController = TextEditingController();


  // BUILD
  AppBar _buildAppBar(){
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: customStyleClass.backgroundColorMain,
      surfaceTintColor: customStyleClass.backgroundColorMain,
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
                        style: customStyleClass.getFontStyleHeadline1Bold()
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
    return  Column(
      children: [

        // Spacer
        SizedBox(
          height: screenHeight*0.2,
        ),

        // Textfield, name
        SizedBox(
          width: screenWidth*0.8,
          child: TextFormField(
            controller: nameController,
            style: customStyleClass.getFontStyle3(),
            cursorColor: customStyleClass.primeColor,
            decoration: InputDecoration(
              focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: customStyleClass.primeColor
                  )
              ),
              border: OutlineInputBorder(),
              label: Text("Name"),
              labelStyle: customStyleClass.getFontStyle3(),
              hintStyle: customStyleClass.getFontStyle3()
            ),
            maxLength: 30,
          ),
        ),

        // Spacer
        SizedBox(
          height: screenHeight*0.03,
        ),

        // Textfield Straße
        SizedBox(
            width: screenWidth*0.82,
            child: Row(
              children: [
                SizedBox(
                  width: screenWidth*0.6,
                  child: TextFormField(
                    controller: streetController,
                    style: customStyleClass.getFontStyle3(),
                    cursorColor: customStyleClass.primeColor,
                    decoration: InputDecoration(
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: customStyleClass.primeColor
                            )
                        ),
                        border: OutlineInputBorder(),
                        label: Text("Straße"),
                        labelStyle: customStyleClass.getFontStyle3(),
                        hintStyle: customStyleClass.getFontStyle3()
                    ),
                    maxLength: 30,
                  ),
                ),

                // Spacer
                SizedBox(
                  width: screenHeight*0.01,
                ),

                // Textfield city
                SizedBox(
                  width: screenWidth*0.18,
                  child: TextFormField(
                    controller: streetNumberController,
                    // keyboardType: TextInputType.number,
                    // inputFormatters: [
                    //   FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                    // ],
                    style: customStyleClass.getFontStyle3(),
                    cursorColor: customStyleClass.primeColor,
                    decoration: InputDecoration(
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: customStyleClass.primeColor
                            )
                        ),
                        border: OutlineInputBorder(),
                        label: Text("Nr."),
                        labelStyle: customStyleClass.getFontStyle3(),
                        hintStyle: customStyleClass.getFontStyle3()
                    ),
                    maxLength: 3,
                  ),
                )
              ],
            )
        ),


        // Spacer
        SizedBox(
          height: screenHeight*0.03,
        ),

        // Textfield PLZ
        SizedBox(
            width: screenWidth*0.82,
            child: Row(
              children: [
                SizedBox(
                  width: screenWidth*0.3,
                  child: TextFormField(
                    controller: zipController,
                    style: customStyleClass.getFontStyle3(),
                    cursorColor: customStyleClass.primeColor,
                    decoration: InputDecoration(
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: customStyleClass.primeColor
                            )
                        ),
                        border: OutlineInputBorder(),
                        label: Text("PLZ"),
                        labelStyle: customStyleClass.getFontStyle3(),
                        hintStyle: customStyleClass.getFontStyle3()
                    ),
                    maxLength: 6,
                  ),
                ),

                // Spacer
                SizedBox(
                  width: screenHeight*0.01,
                ),

                // Textfield city
                SizedBox(
                  width: screenWidth*0.48,
                  child: TextFormField(
                    controller: cityController,
                    style: customStyleClass.getFontStyle3(),
                    cursorColor: customStyleClass.primeColor,
                    decoration: InputDecoration(
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: customStyleClass.primeColor
                            )
                        ),
                        border: OutlineInputBorder(),
                        label: Text("Stadt"),
                        labelStyle: customStyleClass.getFontStyle3(),
                        hintStyle: customStyleClass.getFontStyle3()
                    ),
                    maxLength: 15,
                  ),
                )
              ],
            )
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
        ):


        Container(
            width: screenWidth*0.9,
            alignment: Alignment.bottomRight,
            child: GestureDetector(
              child: Container(
                padding: EdgeInsets.symmetric(
                    vertical: screenHeight*0.015,
                    horizontal: screenWidth*0.03
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [

                    Text(
                      "Kontakt anpassen",
                      textAlign: TextAlign.center,
                      style: customStyleClass.getFontStyle4BoldPrimeColor(),
                    ),
                    Icon(
                      Icons.arrow_forward_outlined,
                      color: customStyleClass.primeColor,
                    )

                  ],
                ),
              ),
              onTap: () => clickOnUpdateButton(
                  stateProvider,
                  nameController,
                  streetController,
                  zipController,
                  cityController
              ),
            )
        ),

        SizedBox(
          height: screenHeight*0.4,
        )

      ],
    );
  }

  // CLICK
  void clickOnUpdateButton(
      StateProvider stateProvider,
      TextEditingController nameController,
      TextEditingController streetController,
      TextEditingController zipController,
      TextEditingController cityController
      ) async{

    setState(() {
      sendClicked = true;
    });

    await _supabaseService.updateClubContactInfo(
        userDataProvider.getUserClubId(),
        nameController.text,
        streetController.text,
        streetNumberController.text,
        zipController.text,
        cityController.text).then((value){
      if(value == 0){
        userDataProvider.setUserClubContact(
            nameController.text,
            streetController.text,
            streetNumberController.text,
            zipController.text,
            cityController.text
        );
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
                  child: Text("Sorry, Es ist ein Fehler aufgetreten!"),
                ),
              );
            }
        );
      }
    });
  }

  // MISC
  void initController(){
    nameController = TextEditingController(
        text:userDataProvider.getUserClubContact()[0]
    );
    streetController = TextEditingController(
        text:userDataProvider.getUserClubContact()[1]
    );
    streetNumberController = TextEditingController(
        text: userDataProvider.getUserClubContact()[2]
    );
    zipController = TextEditingController(
        text: userDataProvider.getUserClubContact()[3]
    );
    cityController = TextEditingController(
        text: userDataProvider.getUserClubContact()[4]
    );
    setState(() {
      initDone = true;
    });
  }



  @override
  Widget build(BuildContext context) {

    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    stateProvider = Provider.of<StateProvider>(context);
    customStyleClass = CustomStyleClass(context: context);
    userDataProvider = Provider.of<UserDataProvider>(context);

    if(!initDone){
      initController();
    }

    return Scaffold(

        extendBody: true,
        resizeToAvoidBottomInset: true,

        bottomNavigationBar: CustomBottomNavigationBarClubs(),
        appBar: _buildAppBar(),
        body: Container(
          color: customStyleClass.backgroundColorMain,
          width: screenWidth,
          height: screenHeight,
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child:_buildMainColumn(),
          )
        )
    );
  }



}
