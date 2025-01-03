import 'package:club_me/models/genres_to_display.dart';

import '../event.dart';
import '../hive_models/6_opening_times.dart';

ClubMeEvent parseClubMeEvent(var data){


  ClubMeEvent clubMeEvent =
  ClubMeEvent(
      eventId: data['event_id'],
      eventTitle: data["event_title"],
      clubName: data["club_name"],
      djName: data["dj_name"],
      eventDate: DateTime.tryParse(data["event_date"])!,
      eventPrice: data["event_price"].toDouble(),
      eventDescription: data["event_description"],

      musicGenres: data["music_genres"],
      musicGenresToFilter: data['music_genres_to_filter'],
      musicGenresToDisplay: GenresToDisplay.fromJson(data['music_genres_to_display']),

      clubId: data["club_id"],
      eventMarketingFileName: data['event_marketing_file_name'],
      eventMarketingCreatedAt: data['event_marketing_created_at'] != null ?
      DateTime.tryParse(data['event_marketing_created_at']): null,
      priorityScore: data["priority_score"].toDouble(),
      openingTimes: OpeningTimes.fromJson(data['opening_times']),
      ticketLink: data["ticket_link"],
      isRepeatedDays: data['is_repeated_days'],
      bannerImageFileName: data['banner_image_file_name'],
      closingDate: data['closing_date'] != null ? DateTime.tryParse(data['closing_date']): null,
      showEventInApp: data['show_event_in_app'],
      specialOccasionActive: data['special_occasion_active'],
      specialOccasionIndex: data['special_occasion_index']
  );

  return clubMeEvent;
}