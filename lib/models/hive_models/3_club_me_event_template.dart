import 'package:hive/hive.dart';
part '3_club_me_event_template.g.dart';

@HiveType(typeId:  3)
class ClubMeEventTemplate{

  ClubMeEventTemplate({
    required this.eventTitle,
    required this.djName,
    required this.eventPrice,
    required this.eventDate,
    required this.eventDescription,
    required this.musicGenres,
    required this.templateId,
    required this.ticketLink,
    required this.isRepeatedDays,
    required this.closingDate,
    required this.fileName
  });


  @HiveField(0)
  String djName;
  @HiveField(1)
  String eventTitle;
  @HiveField(2)
  double eventPrice;
  @HiveField(3)
  DateTime eventDate;
  @HiveField(4)
  String eventDescription;
  @HiveField(5)
  String musicGenres;
  @HiveField(6)
  String templateId;
  @HiveField(7)
  String ticketLink;
  @HiveField(8)
  int isRepeatedDays;
  @HiveField(9)
  DateTime? closingDate;
  @HiveField(10)
  String? fileName;

  String? getFileName(){
    return fileName;
  }

  DateTime? getClosingDate(){
    return closingDate;
  }


  int getIsRepeatedDays(){
    return isRepeatedDays;
  }

  String getTicketLink(){
    return ticketLink;
  }

  String getTemplateId(){
    return templateId;
  }


  void setEventTitle(String newValue){
    eventTitle = newValue;
  }
  void setEventDjName(String newValue){
    djName = newValue;
  }
  void setEventDate(DateTime newValue){
    eventDate = newValue;
  }
  void setEventPrice(double newValue){
    eventPrice = newValue;
  }
  void setEventDescription(String newValue){
    eventDescription = newValue;
  }
  void setEventMusicGenres(String newValue){
    musicGenres = newValue;
  }


  String getMusicGenres(){
    return musicGenres;
  }


  String getEventTitle(){
    return eventTitle;
  }

  String getDjName(){
    return djName;
  }
  DateTime getEventDate(){
    return eventDate;
  }

  double getEventPrice(){
    return eventPrice;
  }
  String getEventDescription(){
    return eventDescription;
  }


}