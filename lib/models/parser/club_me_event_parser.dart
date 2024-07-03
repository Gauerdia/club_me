import '../event.dart';

ClubMeEvent parseClubMeEvent(var data){
  return ClubMeEvent(
      eventId: data['event_id'],
      eventTitle: data["event_title"],
      clubName: data["club_name"],
      djName: data["dj_name"],
      eventDate: DateTime.tryParse(data["event_date"])!,
      eventPrice: data["event_price"].toDouble(),
      bannerId: data["banner_id"],
      eventDescription: data["event_description"],
      musicGenres: data["music_genres"],
      clubId: data["club_id"],
      storyId: data['story_id'],
      storyCreatedAt: data['story_created_at'] != null ? DateTime.tryParse(data['story_created_at']): null
  );
}