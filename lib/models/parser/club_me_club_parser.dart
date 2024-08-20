import '../club.dart';

ClubMeClub parseClubMeClub(var data){
  return ClubMeClub(
      clubId: data['club_id'],
      clubName: data['club_name'],
      clubNews: data['news'],
      clubPriceList: data['price_list'],
      clubMusicGenres: data['music_genres'],
      clubStoryId: data['story_id'],
      clubBannerId: data['banner_id'],
      clubEventBannerId: data['event_banner_id'],
      clubPhotoPaths: data['photo_paths'],
      clubGeoCoordLat: data['geo_coord_lat'],
      clubGeoCoordLng: data['geo_coord_lng'],
      clubContactCity: data['contact_city'],
      clubContactName: data['contact_name'],
      clubContactStreetNumber: data['contact_street_number'],
      clubContactStreet: data['contact_street'],
      clubContactZip: data['contact_zip_code'],
      clubInstagramLink: data['instagram_link'],
      clubFrontpageBackgroundColorId: data['background_color_id'],
      clubWebsiteLink: data['website_link'],
      priorityScore: data['priority_score']
  );
}