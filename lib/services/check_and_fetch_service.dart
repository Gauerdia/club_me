import 'dart:io';

import 'package:club_me/models/club.dart';
import 'package:club_me/models/discount.dart';
import 'package:club_me/models/event.dart';
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

  void checkAndFetchDiscountImages(
      List<ClubMeDiscount> clubMeDiscounts,
      StateProvider stateProvider,
      FetchedContentProvider fetchedContentProvider
      ){
    for(var currentDiscount in clubMeDiscounts){

      // Make sure we can show the corresponding image(s)
      checkIfImageExistsLocally(currentDiscount.getBigBannerFileName(), stateProvider).then((exists){
        if(!exists){

          // If we haven't started to fetch the image yet, we ought to
          if(!fetchedContentProvider.getFetchedBannerImageIds().contains(currentDiscount.getBigBannerFileName())){

            fetchAndSaveBannerImage(
                currentDiscount.getBigBannerFileName(),
                "discount_banner_images",
                stateProvider,
                fetchedContentProvider
            );
          }
        }else{
          fetchedContentProvider.addFetchedBannerImageId(currentDiscount.getBigBannerFileName());
        }
      });

      // Make sure we can show the corresponding image(s)
      checkIfImageExistsLocally(currentDiscount.getSmallBannerFileName(), stateProvider).then((exists){
        if(!exists){

          // If we haven't started to fetch the image yet, we ought to
          if(!fetchedContentProvider.getFetchedBannerImageIds().contains(currentDiscount.getSmallBannerFileName())){

            fetchAndSaveBannerImage(
                currentDiscount.getSmallBannerFileName(),
                "discount_small_banner_images",
                stateProvider,
                fetchedContentProvider
            );
          }
        }else{
          fetchedContentProvider.addFetchedBannerImageId(currentDiscount.getSmallBannerFileName());
        }
      });

    }
  }

  void checkAndFetchDiscountImageAfterCreation(
      String bigBannerFileName,
      StateProvider stateProvider,
      FetchedContentProvider fetchedContentProvider
      ){
    // Make sure we can show the corresponding image(s)
    checkIfImageExistsLocally(bigBannerFileName, stateProvider).then((exists){
      if(!exists){

        // If we haven't started to fetch the image yet, we ought to
        if(!fetchedContentProvider.getFetchedBannerImageIds().contains(bigBannerFileName)){

          fetchAndSaveBannerImage(
              bigBannerFileName,
              "discount_banner_images",
              stateProvider,
              fetchedContentProvider
          );
        }
      }else{
        fetchedContentProvider.addFetchedBannerImageId(bigBannerFileName);
      }
    });
  }

  void checkAndFetchEventImages(
      List<ClubMeEvent> clubMeEvents,
      StateProvider stateProvider,
      FetchedContentProvider fetchedContentProvider
      ){

    for(var currentEvent in clubMeEvents){

      // Make sure we can show the corresponding image(s)
      checkIfImageExistsLocally(currentEvent.getBannerImageFileName(), stateProvider).then((exists){
        if(!exists){

          // If we haven't started to fetch the image yet, we ought to
          // if(!fetchedContentProvider.getFetchedBannerImageIds().contains(currentEvent.getBannerImageFileName())){
            fetchAndSaveBannerImage(
                currentEvent.getBannerImageFileName(),
              "big_banner_images",
              stateProvider,
              fetchedContentProvider
            );
          // }
        }else{
          fetchedContentProvider.addFetchedBannerImageId(currentEvent.getBannerImageFileName());
        }
      });

    }
  }

  void checkAndFetchClubImages(
      List<ClubMeClub> clubMeClubs,
      StateProvider stateProvider,
      FetchedContentProvider fetchedContentProvider,
      bool fetchGalleryImages
      ){

    for(var currentClub in clubMeClubs){

      // We collect all possible images and their respective folders
      List<String> imageFileNamesToCheckAndFetch = [];
      List<String> folderOfImage = [];

      // the small logo for circular spaces
      imageFileNamesToCheckAndFetch.add(currentClub.getSmallLogoFileName());
      folderOfImage.add("small_banner_images");

      // The big logos for the club cards
      imageFileNamesToCheckAndFetch.add(currentClub.getBigLogoFileName());
      folderOfImage.add("big_banner_images");

      // the frontpage banner image for the club detail page
      imageFileNamesToCheckAndFetch.add(currentClub.getFrontpageBannerFileName());
      folderOfImage.add("frontpage_banner_images");

      imageFileNamesToCheckAndFetch.add(currentClub.getMapPinImageName());
      folderOfImage.add('map_pin_images');

      // The gallery images to display on the club detail page
      if(fetchGalleryImages && currentClub.getFrontPageGalleryImages().images != null){
        for(var element in currentClub.getFrontPageGalleryImages().images!){
          imageFileNamesToCheckAndFetch.add(element.id!);
          folderOfImage.add("frontpage_gallery_images");
        }
      }

      for(var i = 0; i<imageFileNamesToCheckAndFetch.length; i++){

        if(!fetchedContentProvider.getFetchedBannerImageIds().contains(imageFileNamesToCheckAndFetch[i])){

          // Check if we need to fetch the image
          checkIfImageExistsLocally(
              imageFileNamesToCheckAndFetch[i], stateProvider)
              .then((exists){

            if(!exists){
              log.d("CheckAndFetchService, Fct: checkAndFetchClubImages, Log: File doesn't exist. File name: ${imageFileNamesToCheckAndFetch[i]}");
              fetchAndSaveBannerImage(
                  imageFileNamesToCheckAndFetch[i],
                  folderOfImage[i],
                  stateProvider,
                  fetchedContentProvider
              );
            }else{
              log.d("CheckAndFetchService, Fct: checkAndFetchClubImages, Log: already exists. File name: ${imageFileNamesToCheckAndFetch[i]}");
              fetchedContentProvider.addFetchedBannerImageId(imageFileNamesToCheckAndFetch[i]);
            }
          });
        }
      }
    }
  }

  void checkAndFetchSpecificClubImages(
      ClubMeClub currentClub,
      StateProvider stateProvider,
      FetchedContentProvider fetchedContentProvider,
      ){

      // We collect all possible images and their respective folders
      List<String> imageFileNamesToCheckAndFetch = [];
      List<String> folderOfImage = [];

      // the small logo for circular spaces
      imageFileNamesToCheckAndFetch.add(currentClub.getSmallLogoFileName());
      folderOfImage.add("small_banner_images");

      // The big logos for the club cards
      imageFileNamesToCheckAndFetch.add(currentClub.getBigLogoFileName());
      folderOfImage.add("big_banner_images");

      // the frontpage banner image for the club detail page
      imageFileNamesToCheckAndFetch.add(currentClub.getFrontpageBannerFileName());
      folderOfImage.add("frontpage_banner_images");

      imageFileNamesToCheckAndFetch.add(currentClub.getMapPinImageName());
      folderOfImage.add('map_pin_images');

      // The gallery images to display on the club detail page
      if(currentClub.getFrontPageGalleryImages().images != null){
        for(var element in currentClub.getFrontPageGalleryImages().images!){
          imageFileNamesToCheckAndFetch.add(element.id!);
          folderOfImage.add("frontpage_gallery_images");
        }
      }

      for(var i = 0; i<imageFileNamesToCheckAndFetch.length; i++){

        if(!fetchedContentProvider.getFetchedBannerImageIds().contains(imageFileNamesToCheckAndFetch[i])){

          // Check if we need to fetch the image
          checkIfImageExistsLocally(
              imageFileNamesToCheckAndFetch[i], stateProvider)
              .then((exists){

            if(!exists){
              log.d("CheckAndFetchService, Fct: checkAndFetchSpecificClubImages, Log: File doesn't exist. File name: ${imageFileNamesToCheckAndFetch[i]}");
              fetchAndSaveBannerImage(
                  imageFileNamesToCheckAndFetch[i],
                  folderOfImage[i],
                  stateProvider,
                  fetchedContentProvider
              );
            }else{
              log.d("CheckAndFetchService, Fct: checkAndFetchSpecificClubImages, Log: already exists. File name: ${imageFileNamesToCheckAndFetch[i]}");
              fetchedContentProvider.addFetchedBannerImageId(imageFileNamesToCheckAndFetch[i]);
            }
          });
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

      // We add the file name to a separate array so that we don't fetch the same image several times
      currentlyLoadingFileNames.add(fileName);

      final String dirPath = stateProvider.appDocumentsDir.path;

      try{
        await _supabaseService.getBannerImage(fileName, folder).then(
            (response) async {
              if(response != null){
                await File("$dirPath/$fileName").writeAsBytes(response).then((onValue){
                  log.d("CheckAndFetchService, Fct: fetchAndSaveBannerImage: Finished successfully. Path: $dirPath/$fileName");
                  fetchedContentProvider.addFetchedBannerImageId(fileName);
                });
              }else{
                log.d("Error in CheckAndFetchService, fetchAndSaveBannerImage. Error: Response is null. Image couln't be fetched. Path: $dirPath/$fileName");
              }
            }
        );
      }catch(e){
        log.d("Error in CheckAndFetchService, fetchAndSaveBannerImage. Error: $e. Path: $dirPath/$fileName");
      }
    }
    else{
      log.d("CheckAndFetchService, Fct: fetchAndSaveBannerImage: $fileName is already part of currentlyLoadingFileNames. No Fetching initialized.");
    }
  }

}