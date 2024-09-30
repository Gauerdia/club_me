import 'dart:io';

import 'package:club_me/models/club.dart';
import 'package:club_me/provider/fetched_content_provider.dart';
import 'package:club_me/provider/state_provider.dart';
import 'package:club_me/services/hive_service.dart';
import 'package:club_me/services/supabase_service.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

class CheckAndFetchService{

  final SupabaseService _supabaseService = SupabaseService();
  final HiveService _hiveService = HiveService();

  List<String> currentlyLoadingFileNames = [];

  var log = Logger();

  void checkAndFetchClubImages(
      List<ClubMeClub> clubMeClubs,
      StateProvider stateProvider,
      FetchedContentProvider fetchedContentProvider
      ){

    for(var currentClub in clubMeClubs){

      List<String> imageFileNamesToCheckAndFetch = [];
      List<String> folderOfImage = [];

      imageFileNamesToCheckAndFetch.add(currentClub.getSmallLogoFileName());
      folderOfImage.add("small_banner_images");

      imageFileNamesToCheckAndFetch.add(currentClub.getBigLogoFileName());
      folderOfImage.add("big_banner_images");

      imageFileNamesToCheckAndFetch.add(currentClub.getFrontpageBannerFileName());
      folderOfImage.add("frontpage_banner_images");

      for(var i = 0; i<imageFileNamesToCheckAndFetch.length; i++){

        if(!fetchedContentProvider.getFetchedBannerImageIds().contains(imageFileNamesToCheckAndFetch[i])){

          // Check if we need to fetch the image
          checkIfImageExistsLocally(imageFileNamesToCheckAndFetch[i], stateProvider).then((exists){
            if(!exists){
              fetchAndSaveBannerImage(imageFileNamesToCheckAndFetch[i], folderOfImage[i], stateProvider, fetchedContentProvider);
            }else{
              fetchedContentProvider.addFetchedBannerImageId(imageFileNamesToCheckAndFetch[i]);
            }
          });
        }
      }
    }
  }

  Future<bool> checkIfImageExistsLocally(
      String fileName,
      StateProvider stateProvider
      ) async{
    final String dirPath = stateProvider.appDocumentsDir.path;
    return await File('$dirPath/$fileName').exists();
  }

  void fetchAndSaveBannerImage(
      String fileName,
      String folder,
      StateProvider stateProvider,
      FetchedContentProvider fetchedContentProvider
      ) async {

    if(!currentlyLoadingFileNames.contains(fileName)){
      currentlyLoadingFileNames.add(fileName);

      var imageFile = await _supabaseService.getBannerImage(fileName, folder);

      final String dirPath = stateProvider.appDocumentsDir.path;

      String finalPath = "";

      try{
        await File("$dirPath/$fileName").writeAsBytes(imageFile).then((onValue){
          print("_buildSupabaseClubs: fetchAndSaveBannerImage");
          log.d("fetchAndSaveBannerImage: Finished successfully. Path: $dirPath/$fileName");
          fetchedContentProvider.addFetchedBannerImageId(fileName);
          print("T1. array after saving and adding: ${fetchedContentProvider.fetchedBannerImageIds}");
        });
      }catch(e){
        log.d("Error in UserClubView, fetchAndSaveBannerImage. Error: $e. Path: $dirPath/$fileName");
      }
    }
    else{
      log.d("fetchAndSaveBannerImage: $fileName is already part of currentlyLoadingFileNames. No Fetching initialized.");
    }
  }

}