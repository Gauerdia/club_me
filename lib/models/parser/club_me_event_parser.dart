import '../event.dart';
import '../opening_times.dart';

ClubMeEvent parseClubMeEvent(var data){

  ClubMeEvent clubMeEvent =
  ClubMeEvent(
      eventId: data['event_id'],
      eventTitle: data["event_title"],
      clubName: data["club_name"],
      djName: data["dj_name"],
      eventDate: DateTime.tryParse(data["event_date"])!,
      eventPrice: data["event_price"].toDouble(),
      // bannerId: data["banner_id"],
      eventDescription: data["event_description"],
      musicGenres: data["music_genres"],
      clubId: data["club_id"],
      eventMarketingFileName: data['event_marketing_file_name'],
      eventMarketingCreatedAt: data['event_marketing_created_at'] != null ?
      DateTime.tryParse(data['event_marketing_created_at']): null,
      priorityScore: data["priority_score"].toDouble(),
      openingTimes: OpeningTimes.fromJson(data['opening_times']),
      ticketLink: data["ticket_link"],
      isRepeatedDays: data['is_repeated_days'],
      bannerImageFileName: data['banner_image_file_name']
  );

  return clubMeEvent;
}