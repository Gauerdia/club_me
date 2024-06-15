import '../../shared/custom_bottom_navigation_bar_clubs.dart';
import '../../services/supabase_service.dart';
import '../../provider/state_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

import '../../shared/custom_text_style.dart';

class UpdateContactView extends StatefulWidget {
  const UpdateContactView({Key? key}) : super(key: key);

  @override
  State<UpdateContactView> createState() => _UpdateContactViewState();
}

class _UpdateContactViewState extends State<UpdateContactView> {



  String headLine = "Kontakt anpassen";

  bool initDone = false;
  bool sendClicked = false;

  late StateProvider stateProvider;
  late CustomTextStyle customTextStyle;
  late double screenWidth, screenHeight;

  final SupabaseService _supabaseService = SupabaseService();
  TextEditingController zipController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController streetController = TextEditingController();


  // BUILD
  AppBar _buildAppBar(){
    return AppBar(
      backgroundColor: Colors.transparent,
      title: SizedBox(
        width: screenWidth,
        child: Text(
          headLine,
          style: customTextStyle.size1Bold(),
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
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              label: Text("Name"),
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
          width: screenWidth*0.8,
          child: TextFormField(
            controller: streetController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              label: Text("Straße"),
            ),
            maxLength: 30,
          ),
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
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      label: Text("PLZ"),
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
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      label: Text("Stadt"),
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
                  "Kontakt anpassen!",
                  textAlign: TextAlign.center,
                  style: customTextStyle.size4BoldPrimeColor(),
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
        stateProvider.getClubId(),
        nameController.text,
        streetController.text,
        zipController.text,
        cityController.text).then((value){
      if(value == 0){
        stateProvider.setUserContact(
            nameController.text,
            streetController.text,
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
    streetController = TextEditingController(
        text:stateProvider.getUserContact()[1]
    );
    nameController = TextEditingController(
        text:stateProvider.getUserContact()[0]
    );
    cityController = TextEditingController(
        text:stateProvider.getUserContact()[3]
    );
    zipController = TextEditingController(
        text:stateProvider.getUserContact()[2]
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
    customTextStyle = CustomTextStyle(context: context);


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
            child:_buildMainColumn(),
          )
        )
    );
  }



}
