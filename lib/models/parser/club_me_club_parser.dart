import '../club.dart';

ClubMeClub parseClubMeClub(var data){
  return ClubMeClub(
      clubId: data['club_id'],
      clubName: data['club_name'],
      news: data['news'],
      priceList: data['price_list'],
      musicGenres: data['music_genres'],
      storyId: data['story_id'],
      bannerId: data['banner_id'],
      eventBannerId: data['event_banner_id'],
      photoPaths: data['photo_paths'],
      geoCoordLat: data['geo_coord_lat'],
      geoCoordLng: data['geo_coord_lng'],
      contactCity: data['contact_city'],
      contactName: data['contact_name'],
      contactStreet: data['contact_street'],
      contactZip: data['contact_zip_code'],
      instagramLink: data['instagram_link'],
      backgroundColorId: data['background_color_id'],
      websiteLink: data['website_link']
  );
}