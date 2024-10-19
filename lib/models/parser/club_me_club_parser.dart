import 'package:club_me/models/club_offers.dart';
import 'package:club_me/models/front_page_images.dart';
import 'package:club_me/models/special_opening_times.dart';

import '../club.dart';
import '../opening_times.dart';

ClubMeClub parseClubMeClub(var data){

  ClubMeClub clubMeClub =
  ClubMeClub(
      clubId: data['club_id'],
      clubName: data['club_name'],
      clubNews: data['news'],
      clubMusicGenres: data['music_genres'],
      clubStoryId: data['story_id'],
      storyCreatedAt: data['story_created_at'] != null ? DateTime.tryParse(data['story_created_at']): null,
      clubGeoCoordLat: data['geo_coord_lat'].toDouble(),
      clubGeoCoordLng: data['geo_coord_lng'].toDouble(),
      clubContactCity: data['contact_city'],
      clubContactName: data['contact_name'],
      clubContactStreetNumber: data['contact_street_number'],
      clubContactStreet: data['contact_street'],
      clubContactZip: data['contact_zip_code'],
      clubInstagramLink: data['instagram_link'],
      clubWebsiteLink: data['website_link'],
      priorityScore: data['priority_score'],
      openingTimes: OpeningTimes.fromJson(data['opening_times']),
      frontPageGalleryImages: FrontPageGalleryImages.fromJson(data['front_page_images']),
      clubOffers: ClubOffers.fromJson(data['club_offers']),

      smallLogoFileName: data['small_logo_file_name'],
      bigLogoFileName: data['big_logo_file_name'],
      frontpageBannerFileName: data['frontpage_banner_file_name'],
    mapPinImageName: data['map_pin_image_name'],
    specialOpeningTimes: SpecialOpeningTimes.fromJson(data['special_opening_times']),
    closePartner: data['close_partner']

  );

  return clubMeClub;
}