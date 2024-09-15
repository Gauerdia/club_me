import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../provider/state_provider.dart';
import '../../services/hive_service.dart';
import '../../services/supabase_service.dart';
import '../../shared/custom_bottom_navigation_bar_clubs.dart';
import '../../shared/custom_text_style.dart';

class ClubChooseDiscountTemplateView extends StatefulWidget{
  const ClubChooseDiscountTemplateView({super.key});

  @override
  State<ClubChooseDiscountTemplateView> createState() => _ClubChooseDiscountTemplateViewState();
}

class _ClubChooseDiscountTemplateViewState extends State<ClubChooseDiscountTemplateView> {

  String headLine = "Deine Vorlagen";

  final SupabaseService _supabaseService = SupabaseService();
  late StateProvider stateProvider;
  late CustomStyleClass customStyleClass;
  late double screenHeight, screenWidth;

  final HiveService _hiveService = HiveService();

  AppBar _buildAppBar(){
    return AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        title: Stack(
          children: [

            Container(
              alignment: Alignment.centerLeft,
              height: 50,
              child: IconButton(
                  icon: const Icon(
                    Icons.clear_rounded,
                    color: Colors.white,
                  ),
                  onPressed: () => clickedOnAbort()
              ),
            ),

            Container(
              height: 50,
              width: screenWidth,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(headLine,
                    textAlign: TextAlign.center,
                    style: customStyleClass.getFontStyle1(),
                  )
                ],
              ),
            )
          ],
        )
    );
  }

  void clickedOnAbort(){

    showDialog(
        context: context,
        builder: (BuildContext context){
          return AlertDialog(
              backgroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  side: BorderSide(
                      color: customStyleClass.primeColor
                  )
              ),
              title: Text(
                "Abbrechen",
                style: customStyleClass.getFontStyle1Bold(),
              ),
              content: Text(
                "Bist du sicher, dass du abbrechen möchtest?",
                textAlign: TextAlign.left,
                style: customStyleClass.getFontStyle4(),
              ),
              actions: [

                TextButton(
                  child: Text(
                    "Zurück",
                    style: customStyleClass.getFontStyle3(),
                  ),
                  onPressed: (){
                    Navigator.of(context).pop();
                  },
                ),

                TextButton(
                  child: Text(
                    "Ja",
                    style: customStyleClass.getFontStyle3(),
                  ),
                  onPressed: (){
                    context.go('/club_discounts');
                  },
                ),

              ]
          );
        }
    );
  }

  @override
  Widget build(BuildContext context) {

    stateProvider = Provider.of<StateProvider>(context);

    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;

    customStyleClass = CustomStyleClass(context: context);

    return Scaffold(

        extendBody: true,

        bottomNavigationBar: CustomBottomNavigationBarClubs(),
        appBar: _buildAppBar(),
        body: Container(
            width: screenWidth,
            height: screenHeight,
            child: SingleChildScrollView(
                child: Column(
                  children: [
                    for(var discountTemplate in stateProvider.getDiscountTemplates())
                      GestureDetector(
                        child: Container(
                          padding: const EdgeInsets.only(
                              top: 10
                          ),
                          child: Card(
                            color: Colors.black,
                            child: Column(
                              children: [
                                ListTile(
                                  shape: RoundedRectangleBorder(
                                    side: const BorderSide(color: Colors.grey, width: 1),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  title: Text(
                                    discountTemplate.getDiscountTitle(),
                                    style: customStyleClass.getFontStyle3(),
                                  ),
                                  trailing: Wrap(
                                    children: [
                                      Icon(
                                        Icons.delete,
                                        color: customStyleClass.primeColor,
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        onTap: (){
                          stateProvider.setCurrentDiscountTemplate(discountTemplate);
                          context.go("/club_new_discount");
                        },
                      )
                  ],
                )
            )
        )
    );
  }
}
