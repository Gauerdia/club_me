import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../provider/state_provider.dart';
import '../../services/hive_service.dart';
import '../../services/supabase_service.dart';
import '../../shared/custom_bottom_navigation_bar_clubs.dart';
import '../../shared/custom_text_style.dart';

class ClubChooseEventTemplateView extends StatefulWidget {
  const ClubChooseEventTemplateView({super.key});

  @override
  State<ClubChooseEventTemplateView> createState() => _ClubChooseEventTemplateViewState();
}

class _ClubChooseEventTemplateViewState extends State<ClubChooseEventTemplateView> {

  String headLine = "Vorlagen";

  final SupabaseService _supabaseService = SupabaseService();
  late StateProvider stateProvider;
  late CustomStyleClass customStyleClass;
  late double screenHeight, screenWidth;

  final HiveService _hiveService = HiveService();

  AppBar _buildAppBar(){
    return AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: customStyleClass.backgroundColorMain,
        surfaceTintColor: customStyleClass.backgroundColorMain,
        title: Stack(
          children: [

            Container(
              alignment: Alignment.centerLeft,
              height: 50,
              child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios,
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
                    style: customStyleClass.getFontStyleHeadline1Bold(),
                  )
                ],
              ),
            )
          ],
        )
    );
  }

  void clickedOnAbort(){
    Navigator.of(context).pop();
  }

  void deleteEventTemplate(String templateId){
    setState(() {
      _hiveService.deleteClubMeEventTemplate(templateId).then((response) => {
        if(response == 0){
          afterSuccessfulDeletion(templateId)
        }else{

        }
      });
    });
  }

  void afterSuccessfulDeletion(String templateId){
    setState(() {
      stateProvider.resetEventTemplates();
      Navigator.pop(context);
    });
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
            color: customStyleClass.backgroundColorMain,
            child: SingleChildScrollView(
                child: Column(
                  children: [
                    for(var eventTemplate in stateProvider.getClubMeEventTemplates())
                      GestureDetector(
                        child: Container(
                          padding: const EdgeInsets.only(
                            top: 10
                          ),
                          child: Card(
                            color: customStyleClass.backgroundColorEventTile,
                            child: Column(
                              children: [

                                SizedBox(
                                  width: screenWidth*0.9,
                                  child: ListTile(
                                    shape: RoundedRectangleBorder(
                                      side: const BorderSide(color: Colors.grey, width: 1),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    title: Text(
                                      eventTemplate.getEventTitle(),
                                      style: customStyleClass.getFontStyle3(),
                                    ),
                                    trailing: Wrap(
                                      children: [

                                        InkWell(
                                          child: Icon(
                                            Icons.delete,
                                            color: customStyleClass.primeColor,
                                          ),
                                          onTap: ()=> deleteEventTemplate(eventTemplate.getTemplateId()),
                                        )
                                      ],
                                    ),
                                  ),
                                )

                              ],
                            ),
                          ),
                        ),
                        onTap: (){
                          stateProvider.setCurrentEventTemplate(eventTemplate);
                          context.go("/club_new_event");
                        },
                      )
                  ],
                )
            )
        )
    );
  }
}
