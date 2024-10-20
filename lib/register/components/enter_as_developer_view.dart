import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:googleapis/connectors/v1.dart';

import '../../models/club_password.dart';
import '../../models/hive_models/0_club_me_user_data.dart';
import '../../models/parser/club_me_password_parser.dart';
import '../../provider/user_data_provider.dart';
import '../../services/hive_service.dart';
import '../../services/supabase_service.dart';
import '../../shared/custom_text_style.dart';
import '../../shared/logger.util.dart';

class EnterAsDeveloperView extends StatefulWidget{
  const EnterAsDeveloperView({super.key});

  @override
  State<EnterAsDeveloperView> createState() => _EnterAsDeveloperViewState();
}

class _EnterAsDeveloperViewState extends State<EnterAsDeveloperView> {


  final log = getLogger();

  late UserDataProvider userDataProvider;

  bool isLoading = false;
  String headLine = "ClubMe";
  late double screenHeight, screenWidth;
  late CustomStyleClass customStyleClass;
  final TextEditingController _clubPasswordController = TextEditingController();

  final SupabaseService _supabaseService = SupabaseService();


  AppBar _buildAppBar(){
    return AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: customStyleClass.backgroundColorMain,
        surfaceTintColor: customStyleClass.backgroundColorMain,
        title: SizedBox(
          width: screenWidth,
          child: Stack(
            children: [

              // TEXT
              Container(
                // color: Colors.red,
                height: 50,
                width: screenWidth,
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Row(
                      children: [
                        Text(
                            headLine,
                            textAlign: TextAlign.center,
                            style: customStyleClass.getFontStyleHeadline1Bold()
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
                    )
                  ],
                ),
              ),

              Container(
                height: 50,
                width: screenWidth,
                alignment: Alignment.centerLeft,
                child: InkWell(
                  child: const Icon(
                    Icons.arrow_back_ios,
                    color: Colors.white,
                  ),
                  onTap: () => Navigator.pop(context),
                ),
              ),

            ],
          ),
        )
    );
  }

  // MISC
  void showErrorDialog(){
    showDialog(context: context, builder: (BuildContext context){
      return AlertDialog(
          title: const Text("Fehler"),
          content: Text(
            "Tut uns leid. Leider war eine Registrierung nicht möglich.",
            textAlign: TextAlign.left,
            style: customStyleClass.getFontStyle4(),
          )
      );
    });
  }

  void checkPassWord() async{

    setState(() {
      isLoading = true;
    });

    try{
      await _supabaseService.checkIfClubPwIsLegit(_clubPasswordController.text).then((value){
        if(value.isEmpty){
          showErrorDialog();
        }else{

          ClubMePassword clubMePassword = parseClubMePassword(value[0]);

          if(clubMePassword.clubId == "1234"){
            context.go("/log_in");
          }

        }
        setState(() {
          isLoading = false;
        });
      });

    }catch(e){
      log.d("Error in transferToHiveAndDB: $e");
    }
  }

  @override
  Widget build(BuildContext context) {

    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;

    customStyleClass = CustomStyleClass(context: context);

    return Scaffold(
      appBar: _buildAppBar(),
      body: Container(
          height: screenHeight,
          color: customStyleClass.backgroundColorMain,
          child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: Column(
                  children: [

                    // Question headline
                    Container(
                      width: screenWidth,
                      padding: EdgeInsets.symmetric(
                          vertical: screenHeight*0.04,
                          horizontal: screenWidth*0.02
                      ),
                      child: Text(
                        "Gib bitte dein Passwort ein!",
                        textAlign: TextAlign.center,
                        style: customStyleClass.getFontStyle1Bold(),
                      ),
                    ),

                    // Textfield email
                    SizedBox(
                      // height: screenHeight*0.15,
                      width: screenWidth*0.8,
                      child: TextField(
                        controller: _clubPasswordController,
                        cursorColor: customStyleClass.primeColor,
                        decoration: InputDecoration(
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: customStyleClass.primeColor
                              )
                          ),
                          hintText: "z.B. passwort1234",
                          border: const OutlineInputBorder(),
                        ),
                        style: customStyleClass.getFontStyle4(),
                        autofocus: true,
                        // maxLength: 35,
                      ),
                    ),

                    Container(
                      padding: const EdgeInsets.only(
                          top: 10
                      ),
                      width: screenWidth*0.9,
                      alignment: Alignment.centerRight,
                      child: isLoading ?
                      Center(child: CircularProgressIndicator(color: customStyleClass.primeColor)):
                      InkWell(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              "Abschicken",
                              style: customStyleClass.getFontStyle3BoldPrimeColor(),
                            ),
                            Icon(
                              Icons.arrow_forward_outlined,
                              color: customStyleClass.primeColor,
                            )
                          ],
                        ),
                        onTap: () => checkPassWord(),
                      ),
                    )

                  ]
              )
          )
      ),
    );
  }
}
