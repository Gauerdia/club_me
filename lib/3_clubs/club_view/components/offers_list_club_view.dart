import 'package:club_me/models/club_offers.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../provider/state_provider.dart';
import '../../../provider/user_data_provider.dart';
import '../../../services/supabase_service.dart';
import '../../../shared/custom_bottom_navigation_bar_clubs.dart';
import '../../../shared/custom_text_style.dart';

class OffersListClubView extends StatefulWidget {
  const OffersListClubView({super.key});

  @override
  State<OffersListClubView> createState() => _OffersListClubViewState();
}

class _OffersListClubViewState extends State<OffersListClubView> {

  String headline = "Angebote";

  late double screenHeight, screenWidth;
  late CustomStyleClass customStyleClass;
  late UserDataProvider userDataProvider;
  late StateProvider stateProvider;

  List<TextEditingController> titleControllers = [];
  List<TextEditingController> descriptionControllers = [];
  List<TextEditingController> priceControllers = [];

  final SupabaseService _supabaseService = SupabaseService();

  // BUILD
  Widget _buildAppBarShowTitle(){
    return SizedBox(
      width: screenWidth,
      child: Stack(
        children: [
          // Headline
          Container(
              alignment: Alignment.bottomCenter,
              height: 50,
              width: screenWidth,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(headline,
                      textAlign: TextAlign.center,
                      style: customStyleClass.getFontStyle1()
                  ),
                ],
              )
          ),

          // back icon
          Container(
              width: screenWidth,
              alignment: Alignment.centerLeft,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    onPressed: () => backButtonPressed(),
                    icon: const Icon(
                      Icons.arrow_back_ios_new_outlined,
                      color: Colors.grey,
                      // size: 20,
                    ),
                  )
                ],
              )
          ),
        ],
      ),
    );
  }

  void backButtonPressed(){
    if(stateProvider.clubUIActive){
      context.go("/club_frontpage");
    }else{
      context.go("/club_detail");
    }
  }

  void deleteOffer(int index){
    setState(() {
      titleControllers.removeAt(index);
      descriptionControllers.removeAt(index);
      priceControllers.removeAt(index);
    });
  }

  Widget _buildView(){
    return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: titleControllers.length,
        itemBuilder: ((context, index){

          return Center(
            child: Container(
              // color: Colors.red,
              padding: const EdgeInsets.only(
                top: 20
              ),
              width: screenWidth*0.9,
              child: Column(
                children: [

                  // Offer number + delete icon
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                          "Angebot ${index+1}",
                        style: customStyleClass.getFontStyle2(),
                      ),
                      IconButton(
                          onPressed: () => deleteOffer(index),
                          icon: Icon(
                            Icons.delete,
                            color: customStyleClass.primeColor,
                          )
                      )
                    ],
                  ),

                  // Spacer
                  SizedBox(
                    height: screenHeight*0.02,
                  ),

                  // textfields, title and price
                  Row(
                    children: [
                      SizedBox(
                        width: screenWidth*0.6,
                        child: TextField(
                          controller: titleControllers[index],
                          decoration: InputDecoration(
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: customStyleClass.primeColor
                              )
                            ),
                            border: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.grey[100]!
                              ),
                            ),
                            hintText: "Überschrift"
                          ),
                          maxLength: 35,
                          style: customStyleClass.getFontStyle3(),
                        ),
                      ),
                      SizedBox(
                        width: screenWidth*0.1,
                      ),
                      SizedBox(
                        width: screenWidth*0.2,
                        child: TextField(
                          controller: priceControllers[index],
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            focusColor: customStyleClass.primeColor,
                              border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.grey[100]!
                                  ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: customStyleClass.primeColor
                                  )
                              ),
                            hintText: "Preis"
                          ),
                          maxLength: 5,
                          style: customStyleClass.getFontStyle3(),
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: screenHeight*0.02,
                  ),
                  Row(
                    children: [
                      SizedBox(
                        width: screenWidth*0.9,
                        child: TextField(
                          controller: descriptionControllers[index],
                          decoration: InputDecoration(
                              focusColor: customStyleClass.primeColor,
                              border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.grey[100]!
                                  )
                              ),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: customStyleClass.primeColor
                                  )
                              ),
                          hintText: "Beschreibung"
                          ),
                          style: customStyleClass.getFontStyle3(),
                          maxLength: 50,
                        ),
                      ),
                    ],
                  )
                ],
              )
            ),
          );
        }
        )
    );
  }

  void addNewOffer(){
    setState(() {
      TextEditingController titleController =
      TextEditingController();

      TextEditingController descriptionController =
      TextEditingController();

      TextEditingController priceController =
      TextEditingController();

      titleControllers.add(titleController);
      descriptionControllers.add(descriptionController);
      priceControllers.add(priceController);
    });
  }

  void updateOffers(){

    ClubOffers newClubOffers = ClubOffers();

    if(checkIfEveryOfferIsFilled()){
      for(int i=0;i<titleControllers.length;i++){
        Offers currentOffer = Offers(
          title: titleControllers[i].text,
          description: descriptionControllers[i].text,
          price: double.parse(priceControllers[i].text.replaceAll(",", "."))
        );
        newClubOffers.offers.add(currentOffer);
      }
      _supabaseService.updateClubOffers(newClubOffers, userDataProvider.userClub.getClubId()).then((response){
        if(response == 0){
          userDataProvider.userClub.setClubOffers(newClubOffers);
          context.go("/club_frontpage");
        }else{
          showDialogWithTitleAndContent("Fehler", "Leider ist beim Aktualisieren ein Fehler aufgetreten");
        }
      });
    }else{
      showDialogWithTitleAndContent("Offene Felder", "Bitte fülle alle Felder, bevor du die Angebote aktualisierst.");
    }
  }

  void showDialogWithTitleAndContent(String title, String content){
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
          title,
          style: customStyleClass.getFontStyle1Bold(),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            // Question text
            Text(
              content,
              textAlign: TextAlign.left,
              style: customStyleClass.getFontStyle4(),
            ),
          ],
        ),
      );
    });
  }

  bool checkIfEveryOfferIsFilled(){
    for(int i=0;i<titleControllers.length;i++){
      if(titleControllers[i].text == "" ||
         descriptionControllers[i].text == "" ||
         priceControllers[i].text == ""){
        return false;
      }
    }
    return true;
  }

  void setupOffers(){
    if(titleControllers.isEmpty){
      for(var element in userDataProvider.userClub.clubOffers.offers!){
        TextEditingController titleController =
        TextEditingController(text: element.title);

        TextEditingController descriptionController =
        TextEditingController(text: element.description);

        TextEditingController priceController =
        TextEditingController(text: element.price.toString());

        titleControllers.add(titleController);
        descriptionControllers.add(descriptionController);
        priceControllers.add(priceController);
      }
    }
  }

  @override
  Widget build(BuildContext context) {

    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    customStyleClass = CustomStyleClass(context: context);
    userDataProvider = Provider.of<UserDataProvider>(context);
    stateProvider = Provider.of<StateProvider>(context);

    setupOffers();

    return Scaffold(

      extendBody: true,


      appBar: AppBar(
          surfaceTintColor: Colors.black,
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          title: _buildAppBarShowTitle()
      ),
      body: SizedBox(
          width: screenWidth,
          height: screenHeight,
          child: Stack(
            children: [

              // main view
              SingleChildScrollView(
                  physics: const ScrollPhysics(),
                  child: Column(
                    children: [

                      SizedBox(
                        height: screenHeight*0.02,
                      ),

                      _buildView(),

                      GestureDetector(
                        child: Container(
                          width: screenWidth*0.9,
                          alignment: Alignment.centerLeft,
                          child: Row(
                            children: [
                              Text(
                                "Weiteres Angebot",
                                style: customStyleClass.getFontStyle4Bold(),
                              ),
                              Icon(
                                Icons.add,
                                color: customStyleClass.primeColor,
                              )
                            ],
                          ),
                        ),
                        onTap: () => addNewOffer(),
                      ),

                      // Spacer
                      SizedBox(height: screenHeight*0.1,),
                    ],
                  )
              ),
            ],
          )
      ),
      bottomNavigationBar: Container(
        width: screenWidth,
        height: screenHeight*0.06,
        decoration: BoxDecoration(
          color: Colors.black,
          border: Border(
            top: BorderSide(
              color: Colors.grey[500]!
            )
          )
        ),

        // color: Colors.green,
        alignment: Alignment.bottomRight,
        padding: const EdgeInsets.only(
          right: 10,
          bottom: 10
        ),
        child: GestureDetector(
          child: Text(
            "Angebote aktualisieren!",
            style: customStyleClass.getFontStyle3BoldPrimeColor(),
          ),
          onTap: () => updateOffers(),
        ),
      ),
    );
  }
}