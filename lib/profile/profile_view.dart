import 'package:club_me/models/hive_models/0_club_me_user_data.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:toggle_switch/toggle_switch.dart';

import '../provider/state_provider.dart';
import '../provider/user_data_provider.dart';
import '../services/hive_service.dart';
import '../services/supabase_service.dart';
import '../shared/custom_bottom_navigation_bar.dart';
import '../shared/custom_text_style.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({Key? key}) : super(key: key);

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {

  String headLine = "Profil";

  late StateProvider stateProvider;
  late CustomStyleClass customStyleClass;
  late double screenHeight, screenWidth;
  late UserDataProvider userDataProvider;

  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  int genderChoice = 0;
  late DateTime birthDateChoice;

  bool showEditScreen = false;
  bool isLoading = false;

  final HiveService _hiveService = HiveService();
  final SupabaseService _supabaseService = SupabaseService();

  Color primeColorDark = Colors.teal;
  Color primeColor = Colors.tealAccent;

  BoxDecoration gradientDecoration = const BoxDecoration(
    gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xff2b353d),
          Color(0xff11181f)
        ],
        stops: [0.15, 0.6]
    ),
  );
  BoxDecoration plainBlackDecoration = const BoxDecoration(
      color: Colors.black
  );

  double discountContainerHeightFactor = 0.52;
  double newDiscountContainerHeightFactor = 0.25;


  // INIT


  @override
  void initState() {
    super.initState();
    initControllers();
  }
  void initControllers(){

    final userDataProvider = Provider.of<UserDataProvider>(context, listen:  false);

    birthDateChoice = userDataProvider.getUserData().getBirthDate();
    genderChoice = userDataProvider.getUserData().getGender();
    _firstNameController = TextEditingController(text: userDataProvider.getUserData().getFirstName());
    _lastNameController = TextEditingController(text: userDataProvider.getUserData().getLastName());
    _emailController = TextEditingController(text: userDataProvider.getUserData().getEMail());
  }


  // BUILD

  AppBar _buildAppBar(){
    return AppBar(
        surfaceTintColor: customStyleClass.backgroundColorMain,
        backgroundColor: customStyleClass.backgroundColorMain,
        title: SizedBox(
          width: screenWidth,
          child: Stack(
            children: [
              // Headline
              Container(
                padding: const EdgeInsets.only(
                  right: 20
                ),
                  alignment: Alignment.bottomCenter,
                  height: 50,
                  width: screenWidth,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
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
                          ),
                        ],
                      )
                    ],
                  )
              ),
            ],
          ),
        ),
      leading: const Icon(
          Icons.search,
          color: Colors.transparent
        // size: 20,
      ),
      actions: [

        if(showEditScreen)
          InkWell(
            child: const Icon(
              Icons.close,
              color: Colors.white,
            ),
            onTap: () => clickEventClose(),
          ),
        if(!showEditScreen)
        InkWell(
          child: const Icon(
            Icons.settings,
            color: Colors.white,
          ),
          onTap: () => context.push("/user_settings"),
        )
      ],
    );
  }
  Widget _buildBasicView(){


    String dayToDisplay = userDataProvider.getUserData().getBirthDate().day < 10 ?
    "0${userDataProvider.getUserData().getBirthDate().day}" :
    userDataProvider.getUserData().getBirthDate().day.toString();

    String monthToDisplay = userDataProvider.getUserData().getBirthDate().month < 10 ?
    "0${userDataProvider.getUserData().getBirthDate().month}" :
    userDataProvider.getUserData().getBirthDate().month.toString();


    String birthDateToDisplay =
        "$dayToDisplay.$monthToDisplay.${userDataProvider.getUserData().getBirthDate().year}";

    return SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        physics: const ScrollPhysics(),
        child: Center(
            child: Column(
                children: [

                  // SPACER
                  SizedBox(
                    height: screenHeight*0.05,
                  ),

                  // NAME
                  Container(
                    width: screenWidth*0.9,
                    padding: const EdgeInsets.only(
                        bottom: 10
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: screenWidth*0.1,
                          child: Icon(
                            Icons.person,
                            color: customStyleClass.primeColor,
                            size: 30,
                          ),
                        ),
                        Text(
                          "${userDataProvider.getUserData().getFirstName()}, ${userDataProvider.getUserData().getLastName()}",
                          style: customStyleClass.getFontStyle3(),
                        ),
                      ],
                    ),
                  ),

                  // GENDER
                  Container(
                    width: screenWidth*0.9,
                    padding: const EdgeInsets.only(
                        bottom: 10
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: screenWidth*0.1,
                          child: Icon(
                            FontAwesomeIcons.venusMars,
                            color: customStyleClass.primeColor,
                            size: 20,
                          ),
                        ),
                        Text(
                          userDataProvider.getUserData().getGender() == 0 ? "Männlich" :
                          userDataProvider.getUserData().getGender() == 1 ? "Weiblich" :
                          "Divers",
                          style: customStyleClass.getFontStyle3(),
                        ),
                      ],
                    ),
                  ),

                  // BIRTH DATE
                  Container(
                    width: screenWidth*0.9,
                    padding: const EdgeInsets.only(
                        bottom: 10
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: screenWidth*0.1,
                          child: Icon(
                            FontAwesomeIcons.birthdayCake,
                            color: customStyleClass.primeColor,
                            size: 30,
                          ),
                        ),
                        Text(
                          birthDateToDisplay,
                          style: customStyleClass.getFontStyle3(),
                        ),
                      ],
                    ),
                  ),

                  // EMAIL
                  Container(
                    width: screenWidth*0.9,
                    padding: const EdgeInsets.only(
                        bottom: 10
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: screenWidth*0.1,
                          child: Icon(
                            Icons.mail,
                            color: customStyleClass.primeColor,
                            size: 30,
                          ),
                        ),
                        Text(
                          userDataProvider.getUserData().getEMail(),
                          style: customStyleClass.getFontStyle3(),
                        ),
                      ],
                    ),
                  ),

                  Container(
                    alignment: Alignment.centerRight,
                    width: screenWidth*0.87,
                    padding: const EdgeInsets.only(
                        right: 10
                    ),
                    child: InkWell(
                      child:SizedBox(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              "Bearbeiten",
                              style: customStyleClass.getFontStyle3BoldPrimeColor(),
                            ),
                            Icon(
                              Icons.arrow_forward,
                              color: customStyleClass.primeColor,
                            )
                          ],
                        ),
                      ),
                      onTap: (){
                        setState(() {
                          showEditScreen = true;
                        });
                      },
                    ),
                  )

                ]
            )
        )
    );
  }
  Widget _buildEditView(){

    return SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        physics: const ScrollPhysics(),
        child: Center(
            child: Column(
                children: [

                  // SPACER
                  SizedBox(
                    height: screenHeight*0.05,
                  ),

                  // NAME
                  Container(
                    width: screenWidth*0.9,
                    padding: const EdgeInsets.only(
                        bottom: 10
                    ),
                    child: Stack(
                      children: [
                        SizedBox(
                          width: screenWidth*0.1,
                          height: screenHeight*0.07,
                          child: Icon(
                            Icons.person,
                            color: customStyleClass.primeColor,
                            size: 30,
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [

                            // Textfield
                            SizedBox(
                              width: screenWidth*0.42,
                              child: TextField(
                                controller: _firstNameController,
                                cursorColor: customStyleClass.primeColor,
                                decoration: InputDecoration(
                                    focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: customStyleClass.primeColor
                                        )
                                    ),
                                    hintText: "Vorname",
                                    border: OutlineInputBorder(),
                                    contentPadding: EdgeInsets.only(
                                        left: screenWidth*0.1,
                                        top: 20,
                                        bottom: 20
                                    )
                                ),
                                style: customStyleClass.getFontStyle4(),
                                maxLength: 35,

                              ),
                            ),
                            SizedBox(
                              width: screenWidth*0.42,
                              child: TextField(
                                controller: _lastNameController,
                                cursorColor: customStyleClass.primeColor,
                                decoration: InputDecoration(
                                    focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: customStyleClass.primeColor
                                        )
                                    ),
                                    hintText: "Nachname",
                                    border: OutlineInputBorder(),
                                    contentPadding: EdgeInsets.only(
                                        left: screenWidth*0.1,
                                        top: 20,
                                        bottom: 20
                                    )
                                ),
                                style: customStyleClass.getFontStyle4(),
                                maxLength: 35,
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                  ),

                  // SPACER
                  SizedBox(
                    height: screenHeight*0.01,
                  ),

                  // EMAIL
                  Container(
                    // color: Colors.red,
                    width: screenWidth*0.9,
                    // height: screenHeight*0.08,
                    child: Stack(
                      children: [
                        TextField(
                          controller: _emailController,
                          cursorColor: customStyleClass.primeColor,
                          decoration: InputDecoration(
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: customStyleClass.primeColor
                                  )
                              ),
                              hintText: "z.B. Mixed Music",
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.only(
                                  left: screenWidth*0.1,
                                  top: 20,
                                  bottom: 20
                              )
                          ),
                          style: customStyleClass.getFontStyle4(),
                          maxLength: 35,
                        ),
                        Container(
                          padding: EdgeInsets.only(
                            top: 17
                          ),
                          // color: Colors.grey,
                          // alignment: Alignment.centerLeft,
                          width: screenWidth*0.1,
                          // height: screenHeight*0.06,
                          child: Icon(
                            Icons.mail,
                            color: customStyleClass.primeColor,
                            size: 30,
                          ),
                        )
                      ],
                    ),
                  ),

                  // SPACER
                  SizedBox(
                    height: screenHeight*0.01,
                  ),

                  // GENDER
                  Container(
                      width: screenWidth*0.9,
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                                width:screenWidth*0.9,
                                child: ToggleSwitch(
                                  minHeight: screenHeight*0.07,
                                  minWidth: screenWidth*0.9,
                                  initialLabelIndex: genderChoice,
                                  totalSwitches: 3,
                                  activeBgColor: [customStyleClass.primeColor],
                                  activeFgColor: Colors.white,
                                  inactiveFgColor: Colors.white,
                                  inactiveBgColor: customStyleClass.backgroundColorEventTile,
                                  labels: const [
                                    'Männlich',
                                    'Weiblich',
                                    'Divers'
                                  ],
                                  onToggle: (index) {
                                    setState(() {
                                      genderChoice = index!;
                                      print("toggled: $index");
                                    });
                                  },
                                )
                            ),
                          ]
                      )
                  ),

                  // SPACER
                  SizedBox(
                    height: screenHeight*0.02,
                  ),

                  // BIRTH DATE
                  Container(
                    width: screenWidth*0.9,
                    height: screenHeight*0.08,
                    padding: const EdgeInsets.only(
                        bottom: 10
                    ),
                    child: Stack(
                      children: [
                        SizedBox(
                          width: screenWidth*0.4,
                          child:OutlinedButton(
                              onPressed: (){
                                showDatePicker(
                                    context: context,
                                    locale: const Locale("de", "DE"),
                                    initialDate: birthDateChoice,
                                    firstDate: DateTime(1950),
                                    lastDate: DateTime(2024),
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
                                    birthDateChoice = pickedDate;
                                  });
                                });
                              },
                              style: OutlinedButton.styleFrom(
                                  minimumSize: Size(screenHeight*0.05,screenHeight*0.07),
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

                        SizedBox(
                          width: screenWidth*0.1,
                          height: screenHeight*0.07,
                          child: Icon(
                            Icons.cake,
                            color: customStyleClass.primeColor,
                            size: 30,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // BUTTON
                  Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(
                        right: 10
                    ),
                    child: isLoading ? CircularProgressIndicator()
                        : InkWell(
                      child:SizedBox(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              "Speichern",
                              style: customStyleClass.getFontStyle3BoldPrimeColor(),
                            ),
                            Icon(
                              Icons.arrow_forward,
                              color: customStyleClass.primeColor,
                            )
                          ],
                        ),
                      ),
                      onTap: () => clickEventSaveEdit(),
                    ),
                  ),


                  Container(
                    width: screenWidth*0.9,
                    padding: EdgeInsets.only(
                        top: screenHeight*0.1
                    ),
                    child: OutlinedButton(
                        onPressed: () => clickEventDeleteAccount(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.all(20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          side: BorderSide(width: 2, color: customStyleClass.primeColor),
                        ),
                        child: Text(
                          "Account löschen",
                          style: customStyleClass.getFontStyle3BoldPrimeColor(),
                        )
                    ),
                  )

                ]
            )
        )
    );
  }


  // CLICK EVENTS


  void clickedOnLogOut(){
    stateProvider.setPageIndex(0);
    stateProvider.activeLogOut = true;
    context.go("/log_in");
    // _hiveService.resetUserData().then((value) => context.go("/log_in"));
  }
  void clickEventSaveEdit() async{

    setState(() {
      isLoading = true;
    });

    ClubMeUserData newUserData = ClubMeUserData(
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        birthDate: birthDateChoice,
        eMail: _emailController.text,
        gender: genderChoice,
        userId: userDataProvider.getUserData().getUserId(),
        profileType: userDataProvider.getUserData().getProfileType(),
      lastTimeLoggedIn: DateTime.now()
    );

    userDataProvider.setUserData(newUserData);
    await _supabaseService.updateUserData(newUserData);
    setState(() {
      isLoading = false;
      showEditScreen = false;
    });
  }
  void clickEventDeleteAccount(){
    showDialog(context: context, builder: (BuildContext context){
      return AlertDialog(
          backgroundColor: Colors.black,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
              side: BorderSide(
                  color: customStyleClass.primeColor
              )
          ),
          title: Text(
            "Account löschen",
            style: customStyleClass.getFontStyle1Bold(),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              // Question text
              Text(
                "Bist du sicher, dass du deinen Account löschen möchtest?",
                style: customStyleClass.getFontStyle4(),
              ),

              // Spacer
              SizedBox(
                height: screenHeight*0.02,
              ),

              // "I am sure" button
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
                      decoration: BoxDecoration(
                          color: Colors.black54,
                          border: Border.all(
                              color: customStyleClass.primeColor
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(10))
                      ),
                      child: Text(
                        "Ja, bitte meinen Account löschen!",
                        textAlign: TextAlign.center,
                        style: customStyleClass.getFontStyle4BoldPrimeColor(),
                      ),
                    ),
                    onTap: () => clickEventApprovesAccountDeletion(),
                  )
              ),
            ],
          )
      );
    });
  }
  void clickEventApprovesAccountDeletion() async{
    setState(() {
      isLoading = true;
    });
    int response = await _supabaseService.markToDeleteUserData(userDataProvider.getUserData().getUserId());
    if(response == 0){
      _hiveService.resetUserData();
      stateProvider.setPageIndex(0);
      context.go("/log_in");
    }else{
      showErrorDialog();
    }
  }


  // MISC

  void clickEventClose(){
    setState(() {
      showEditScreen = false;
    });
  }
  String formatSelectedDate(){

    String tempDay = "";
    String tempMonth = "";
    String tempYear = "";

    if(birthDateChoice.day.toString().length == 1){
      tempDay = "0${birthDateChoice.day}";
    }else{
      tempDay = "${birthDateChoice.day}";
    }

    if(birthDateChoice.month.toString().length == 1){
      tempMonth = "0${birthDateChoice.month}";
    }else{
      tempMonth = "${birthDateChoice.month}";
    }

    if(birthDateChoice.year.toString().length == 1){
      tempYear = "0${birthDateChoice.year}";
    }else{
      tempYear = "${birthDateChoice.year}";
    }

    return "$tempDay.$tempMonth.$tempYear";
  }
  void showErrorDialog(){
    showDialog(context: context, builder: (BuildContext context){
      return AlertDialog(
          backgroundColor: Colors.black,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
              side: BorderSide(
                  color: customStyleClass.primeColor
              )
          ),
          title: Text(
            "Fehler",
            style: customStyleClass.getFontStyle1Bold(),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              // Question text
              Text(
                "Leider ist bei dem Vorgang ein Fehler aufgetreten. Bitte versuche es später noch einmal.",
                style: customStyleClass.getFontStyle4(),
              ),

              // Spacer
              SizedBox(
                height: screenHeight*0.02,
              ),
            ],
          )
      );
    });
  }




  @override
  Widget build(BuildContext context) {

    stateProvider = Provider.of<StateProvider>(context);

    userDataProvider = Provider.of<UserDataProvider>(context);

    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;

    customStyleClass = CustomStyleClass(context: context);


    return Scaffold(

      bottomNavigationBar: CustomBottomNavigationBar(),

      appBar: AppBar(
        backgroundColor: customStyleClass.backgroundColorMain,
        surfaceTintColor: customStyleClass.backgroundColorMain,
        title: _buildAppBar()
      ),
      body: Container(
          width: screenWidth,
          height: screenHeight,
          color: customStyleClass.backgroundColorMain,
          child: Stack(
            children: [
              showEditScreen ? _buildEditView() : _buildBasicView()
            ],
          )
      ),
    );
  }
}
