import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../provider/state_provider.dart';
import '../services/supabase_service.dart';
import '../shared/custom_bottom_navigation_bar_clubs.dart';
import '../shared/custom_text_style.dart';

class ClubChooseEventTemplateView extends StatefulWidget {
  const ClubChooseEventTemplateView({super.key});

  @override
  State<ClubChooseEventTemplateView> createState() => _ClubChooseEventTemplateViewState();
}

class _ClubChooseEventTemplateViewState extends State<ClubChooseEventTemplateView> {

  String headLine = "Deine Vorlagen";

  final SupabaseService _supabaseService = SupabaseService();
  late StateProvider stateProvider;
  late CustomTextStyle customTextStyle;
  late double screenHeight, screenWidth;

  AppBar _buildAppBar(){
    return AppBar(
        backgroundColor: Colors.transparent,
        title: SizedBox(
          width: screenWidth,
          child: Text(headLine,
            textAlign: TextAlign.center,
            style: customTextStyle.size2(),
          ),
        )
    );
  }

  @override
  Widget build(BuildContext context) {

    stateProvider = Provider.of<StateProvider>(context);

    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;

    customTextStyle = CustomTextStyle(context: context);

    return Scaffold(

        extendBody: true,

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
                child: Column(
                  children: [
                    for(var clubTemplate in stateProvider.getEventTemplates())
                      GestureDetector(
                        child: Card(
                          child: Column(
                            children: [
                              ListTile(
                                leading: const Icon(Icons.album_rounded),
                                title: Text(
                                  clubTemplate.clubMeEventHive.getEventTitle(),
                                  style: customTextStyle.getFontStyle3(),
                                ),
                              )
                            ],
                          ),
                        ),
                        onTap: (){
                          stateProvider.setClubMeEventHive(clubTemplate.clubMeEventHive);
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
