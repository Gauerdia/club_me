import 'package:club_me/provider/fetched_content_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:uuid/uuid.dart';

import '../../models/hive_models/0_club_me_user_data.dart';
import '../../provider/state_provider.dart';
import '../../provider/user_data_provider.dart';
import '../../services/hive_service.dart';
import '../../services/supabase_service.dart';
import '../../shared/custom_text_style.dart';
import '../../shared/logger.util.dart';

class RegisterForUserAsClubView extends StatefulWidget {
  const RegisterForUserAsClubView({super.key});

  @override
  State<RegisterForUserAsClubView> createState() => _RegisterForUserAsClubViewState();
}

class _RegisterForUserAsClubViewState extends State<RegisterForUserAsClubView> {

  String headLine = "ClubMe";

  final log = getLogger();

  late UserDataProvider userDataProvider;
  late StateProvider stateProvider;
  late FetchedContentProvider fetchedContentProvider;

  late double screenHeight, screenWidth;
  late CustomStyleClass customStyleClass;

  final HiveService _hiveService = HiveService();
  final SupabaseService _supabaseService = SupabaseService();

  bool isLoading = false;

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _eMailController = TextEditingController();
  final TextEditingController _clubPasswordController = TextEditingController();

  int gender = 0;


  late DateTime newSelectedDate;


  // INIT
  @override
  void initState() {
    super.initState();
    newSelectedDate = DateTime(2000, 1, 1);
  }


  // FORMAT
  String formatSelectedDate(){

    String tempDay = "";
    String tempMonth = "";
    String tempYear = "";

    if(newSelectedDate.day.toString().length == 1){
      tempDay = "0${newSelectedDate.day}";
    }else{
      tempDay = "${newSelectedDate.day}";
    }

    if(newSelectedDate.month.toString().length == 1){
      tempMonth = "0${newSelectedDate.month}";
    }else{
      tempMonth = "${newSelectedDate.month}";
    }

    if(newSelectedDate.year.toString().length == 1){
      tempYear = "0${newSelectedDate.year}";
    }else{
      tempYear = "${newSelectedDate.year}";
    }

    return "$tempDay.$tempMonth.$tempYear";
  }



  double distanceBetweenTitleAndTextField = 10;

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
                  onTap: () => Navigator.pop(context)
                ),
              ),

            ],
          ),
        )
    );
  }

  Widget _buildBottomNavigationBar(){
    return

      Container(
        width: screenWidth,
        height: screenHeight*0.08,
        decoration: BoxDecoration(
            color: customStyleClass.backgroundColorMain,
            border: Border(
                top: BorderSide(
                    color: Colors.grey[900]!
                )
            )
        ),

        // color: Colors.green,
        alignment: Alignment.center,
        padding: const EdgeInsets.only(
          right: 10,
          // bottom: 10
        ),
        child: GestureDetector(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                "Registrieren",
                style: customStyleClass.getFontStyle3BoldPrimeColor(),
              ),
              Icon(
                Icons.arrow_forward_outlined,
                color: customStyleClass.primeColor,
              )
            ],
          ),
          onTap: () => clickEventRegister(),
        ),
      );

    //   Container(
    //   // color: Colors.red,
    //   width: screenWidth,
    //   height: 70,
    //   alignment: Alignment.bottomCenter,
    //   child: Center(
    //     child: Image.asset(
    //       "assets/images/runes_footer.PNG",
    //       width: 100,
    //     ),
    //   ),
    // );
  }

  // DB FUNCTIONS
  void transferToHiveAndDB() async{

      var uuid = const Uuid();

      ClubMeUserData newUserData = ClubMeUserData(
          firstName: _firstNameController.text,
          lastName: _lastNameController.text,
          birthDate: newSelectedDate,
          eMail: _eMailController.text,
          gender: gender,
          userId: uuid.v4(),
          profileType: 0,
          lastTimeLoggedIn: DateTime.now(),
          userProfileAsClub: true,
          clubId: userDataProvider.getUserClubId(),

      );

      try{

        await _hiveService.resetUserData();

        _hiveService.addUserData(newUserData).then((value) => {
          _supabaseService.insertUserData(newUserData).then((value){
            userDataProvider.setUserData(newUserData);
            setState(() {
              fetchedContentProvider.fetchedDiscounts = [];
              fetchedContentProvider.fetchedEvents = [];
              fetchedContentProvider.fetchedClubs = [];
              context.go("/user_events");
            });
          })
        });

      }catch(e){
        log.d("Error in transferToHiveAndDB: $e");
      }
  }

  void clickEventRegister() async{

    setState(() {
      isLoading = true;
    });

      if(RegExp(r'^.+@[a-zA-Z]+\.{1}[a-zA-Z]+(\.{0,1}[a-zA-Z]+)$')
          .hasMatch(_eMailController.text)){
        transferToHiveAndDB();
      }else{
        setState(() {
          isLoading = false;
        });
        showDialog(context: context, builder: (BuildContext context){
          return AlertDialog(
              title: const Text("E-Mail Adresse"),
              content: Text(
                "Bitte gib eine gültige E-Mail-Adresse ein!",
                textAlign: TextAlign.left,
                style: customStyleClass.getFontStyle4(),
              )
          );
        });
      }

  }

  void clickEventShowInfo(int index){

    List<String> answers =[
      "Deine E-Mail-Adresse hilft uns, dich wieder in die App zu lassen, falls du irgendwann "
          "dein Handy wechseln solltest.",
      "Dein Geschlecht hilft uns, dir Angebote der Clubs vorzuschlagen, die auf ein bestimmtes "
          "Geschlecht begrenzt sind.",
      "Dein Geburtsdatum hilft uns, dir Angebote der Clubs vorzuschlagen, die auf ein gewisses "
          "Alter begrenzt sind."

    ];

    showDialog(context: context, builder: (BuildContext context){
      return AlertDialog(
        backgroundColor: customStyleClass.backgroundColorMain,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        title: Text(
          "Information",
          style: customStyleClass.getFontStyle1Bold(),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            // Question text
            Text(
              answers[index],
              textAlign: TextAlign.left,
              style: customStyleClass.getFontStyle4(),
            ),

            // Spacer
            SizedBox(
              height: screenHeight*0.03,
            ),

          ],
        ),
      );
    });
  }


  Widget _buildMainView(){
    return Container(
      // height: screenHeight,
        width: screenWidth,
        color: customStyleClass.backgroundColorMain,
        child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Column(
                children: [

                  // Question headline
                  Container(
                    width: screenWidth*0.9,
                    padding: EdgeInsets.symmetric(
                        vertical: screenHeight*0.04,
                        horizontal: screenWidth*0.02
                    ),
                    child: Text(
                      "Erzähl uns ein wenig über dich!",
                      textAlign: TextAlign.center,
                      style: customStyleClass.getFontStyle2Bold(),
                    ),
                  ),

                  // Text: Title
                  Container(
                    width: screenWidth*0.9,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Vorname",
                      style: customStyleClass.getFontStyle3(),
                    ),
                  ),

                  // Textfield first name
                  Container(
                    height: screenHeight*0.12,
                    width: screenWidth*0.9,
                    padding:  EdgeInsets.only(
                        top: distanceBetweenTitleAndTextField
                    ),
                    child: TextField(
                      controller: _firstNameController,
                      cursorColor: customStyleClass.primeColor,
                      decoration: InputDecoration(
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: customStyleClass.primeColor
                            )
                        ),
                        hintText: "z.B. Max",
                        border: const OutlineInputBorder(),
                        contentPadding: const EdgeInsets.only(
                            left: 20,
                            top:20,
                            bottom:20
                        ),
                      ),
                      style: customStyleClass.getFontStyle4(),
                      autofocus: true,
                      maxLength: 35,
                    ),
                  ),

                  // Text: Title
                  Container(
                    width: screenWidth*0.9,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Nachname",
                      style: customStyleClass.getFontStyle3(),
                    ),
                  ),

                  // Textfield last name
                  Container(
                    height: screenHeight*0.12,
                    width: screenWidth*0.9,
                    padding:  EdgeInsets.only(
                        top: distanceBetweenTitleAndTextField
                    ),
                    child: TextField(
                      controller: _lastNameController,
                      cursorColor: customStyleClass.primeColor,
                      decoration: InputDecoration(
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: customStyleClass.primeColor
                            )
                        ),
                        hintText: "z.B. Mustermann",
                        border: const OutlineInputBorder(),
                        contentPadding: const EdgeInsets.only(
                            left: 20,
                            top:20,
                            bottom:20
                        ),
                      ),
                      style: customStyleClass.getFontStyle4(),
                      autofocus: true,
                      maxLength: 35,
                    ),
                  ),

                  // Text: Title
                  Container(
                    width: screenWidth*0.9,
                    alignment: Alignment.centerLeft,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "E-Mail",
                          style: customStyleClass.getFontStyle3(),
                        ),
                        InkWell(
                          child: Icon(
                              Icons.info_outlined,
                              color: customStyleClass.primeColor
                          ),
                          onTap:() => clickEventShowInfo(0),
                        )
                      ],
                    ),
                  ),

                  // Textfield email
                  Container(
                    height: screenHeight*0.12,
                    width: screenWidth*0.9,
                    padding:  EdgeInsets.only(
                        top: distanceBetweenTitleAndTextField
                    ),
                    child: TextFormField(
                      controller: _eMailController,
                      cursorColor: customStyleClass.primeColor,
                      decoration: InputDecoration(
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: customStyleClass.primeColor
                            )
                        ),
                        hintText: "z.B. max.mustermann@gmx.de",
                        border: const OutlineInputBorder(),
                        contentPadding: const EdgeInsets.only(
                            left: 20,
                            top:20,
                            bottom:20
                        ),
                      ),
                      style: customStyleClass.getFontStyle4(),
                      autofocus: true,
                      maxLength: 35,
                    ),
                  ),

                  // Text: Title
                  Container(
                    width: screenWidth*0.9,
                    alignment: Alignment.centerLeft,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Geschlecht",
                          style: customStyleClass.getFontStyle3(),
                        ),
                        InkWell(
                          child: Icon(
                              Icons.info_outlined,
                              color: customStyleClass.primeColor
                          ),
                          onTap: () => clickEventShowInfo(1),
                        )
                      ],
                    ),
                  ),

                  // toggle man, woman, diverse
                  Container(
                    width: screenWidth*0.9,
                    padding:  EdgeInsets.only(
                        top: distanceBetweenTitleAndTextField
                    ),
                    child:  Center(
                      child: ToggleSwitch(
                        initialLabelIndex: gender,
                        totalSwitches: 3,
                        activeBgColor: [customStyleClass.primeColor],
                        activeFgColor: Colors.white,
                        inactiveFgColor: customStyleClass.primeColor,
                        inactiveBgColor: customStyleClass.backgroundColorEventTile,
                        labels: const [
                          'Mann',
                          'Frau',
                          "Divers"
                        ],
                        minWidth: screenWidth*0.9,
                        minHeight: screenHeight*0.07,
                        onToggle: (index) {
                          setState(() {
                            gender = index!;
                          });
                        },
                      ),
                    ),
                  ),

                  SizedBox(
                    height: screenHeight*0.05,
                  ),

                  // Text: Title
                  Container(
                    width: screenWidth*0.9,
                    alignment: Alignment.centerLeft,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Geburtsdatum",
                          style: customStyleClass.getFontStyle3(),
                        ),
                        InkWell(
                          child: Icon(
                            Icons.info_outlined,
                            color: customStyleClass.primeColor,
                          ),
                          onTap: () => clickEventShowInfo(2),
                        )
                      ],
                    ),
                  ),

                  Container(
                    padding:  EdgeInsets.only(
                        top: distanceBetweenTitleAndTextField
                    ),
                    height: screenHeight*0.12,
                    width: screenWidth*0.9,
                    child: Column(
                      children: [

                        // BUTTON
                        Container(
                          width: screenWidth*0.9,
                          alignment: Alignment.centerLeft,
                          child: SizedBox(
                            width: screenWidth*0.32,
                            child:OutlinedButton(
                                onPressed: (){
                                  showDatePicker(
                                      context: context,
                                      locale: const Locale("de", "DE"),
                                      initialDate: DateTime(2000),
                                      firstDate: DateTime(1949),
                                      lastDate: DateTime(2010),
                                      builder: (BuildContext context, Widget? child) {
                                        return Theme(
                                          data: ThemeData.dark(),
                                          child: child!,
                                        );
                                      }).then((pickedDate){
                                    if( pickedDate == null){
                                      return;
                                    }
                                    setState(() {
                                      newSelectedDate = pickedDate;
                                    });
                                  });
                                },
                                style: OutlinedButton.styleFrom(
                                    minimumSize: Size(
                                        screenHeight*0.05,
                                        screenHeight*0.07
                                    ),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5.0)
                                    )
                                ),
                                child: Text(
                                  formatSelectedDate(),
                                  style: customStyleClass.getFontStyle4(),
                                )
                            ),
                          ),
                        )
                      ],
                    ),
                  ),

                  // Spacer
                  SizedBox(
                    height: screenHeight*0.1,
                  ),

                ]
            )
        )
    );
  }

  @override
  Widget build(BuildContext context) {

    stateProvider = Provider.of<StateProvider>(context);
    userDataProvider = Provider.of<UserDataProvider>(context);
    fetchedContentProvider = Provider.of<FetchedContentProvider>(context);

    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;

    customStyleClass = CustomStyleClass(context: context);


    return Scaffold(
      appBar: _buildAppBar(),
      bottomNavigationBar: _buildBottomNavigationBar(),
      body: _buildMainView()
    );
  }
}
