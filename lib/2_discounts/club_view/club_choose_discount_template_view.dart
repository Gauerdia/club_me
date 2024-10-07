import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../provider/state_provider.dart';
import '../../services/hive_service.dart';
import '../../services/supabase_service.dart';
import '../../shared/custom_bottom_navigation_bar_clubs.dart';
import '../../shared/custom_text_style.dart';
import '../../shared/dialogs/title_content_and_button_dialog.dart';

class ClubChooseDiscountTemplateView extends StatefulWidget{
  const ClubChooseDiscountTemplateView({super.key});

  @override
  State<ClubChooseDiscountTemplateView> createState() => _ClubChooseDiscountTemplateViewState();
}

class _ClubChooseDiscountTemplateViewState extends State<ClubChooseDiscountTemplateView> {

  String headLine = "Vorlagen";

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
                  onPressed: () => clickEventClose()
              ),
            ),

            SizedBox(
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
  Widget _buildMainView(){
    return Container(
        width: screenWidth,
        height: screenHeight,
        color: customStyleClass.backgroundColorMain,
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
                        color: customStyleClass.backgroundColorEventTile,
                        child: Column(
                          children: [
                            Container(
                              width: screenWidth*0.9,
                              child: ListTile(
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
                                    InkWell(
                                      child: Icon(
                                        Icons.delete,
                                        color: customStyleClass.primeColor,
                                      ),
                                      onTap: () => deleteDiscountTemplate(discountTemplate.getTemplateId()),
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
                      stateProvider.setCurrentDiscountTemplate(discountTemplate);
                      context.go("/club_new_discount");
                    },
                  )
              ],
            )
        )
    );
  }

  void clickEventClose(){
    Navigator.pop(context);
  }

  void deleteDiscountTemplate(String templateId){

    Widget okButton = TextButton(
        onPressed: () {
          setState(() {
            _hiveService.deleteClubMeDiscountTemplate(templateId).then((response) => {
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
      stateProvider.removeDiscountTemplate(templateId);
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
