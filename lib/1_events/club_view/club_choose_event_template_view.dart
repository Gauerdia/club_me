import 'package:club_me/shared/dialogs/title_content_and_button_dialog.dart';
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

  String headline = "Vorlagen";

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

            // ICON
            Container(
              alignment: Alignment.centerLeft,
              height: 50,
              child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios,
                    color: Colors.white,
                  ),
                  onPressed: () => clickEventGoBack()
              ),
            ),

            // HEADLINE
            SizedBox(
              height: 50,
              width: screenWidth,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(headline,
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

  Widget _buildMainView(){
    return Container(
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
                                      onTap: ()=> clickEventDeleteEventTemplate(eventTemplate.getTemplateId()),
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
    );
  }

  void clickEventGoBack(){
    Navigator.of(context).pop();
  }

  void clickEventDeleteEventTemplate(String templateId){

    Widget okButton = TextButton(
        onPressed: () {
          setState(() {
            _hiveService.deleteClubMeEventTemplate(templateId).then((response) => {
              if(response == 0){
                afterSuccessfulDeletion(templateId)
              }else{

              }
            });
          });
        },
        child: Text(
          "Ja",
          style: customStyleClass.getFontStyle3BoldPrimeColor(),
    ));

    showDialog<String>(
        context: context,
        builder: (BuildContext context) =>
            TitleContentAndButtonDialog(
                titleToDisplay: "Vorlage löschen",
                contentToDisplay: "Bist du sicher, dass du diese Vorlage löschen möchtest?",
                buttonToDisplay: okButton));
  }

  void afterSuccessfulDeletion(String templateId){

      stateProvider.removeEventTemplate(templateId);
      Navigator.pop(context);

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
        body: _buildMainView()
    );
  }
}
