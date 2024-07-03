# club_me


To-Dos:

- Bilder nicht mehr mitgeben, sondern am Anfang runterladen lassen. Am besten per versionsnummer im
club-eintrag.








// Internet permission for Iphone?

Icon
- flutter pub run flutter_launcher_icons:main

Hive
- flutter packages pub run build_runner build


    DateTime eventDateRaw = clubMeEvent.getEventDate();
    String eventDate = DateFormat('yyyy-MM-dd').format(eventDateRaw);
    DateTime eventDate2 = DateTime.parse(eventDate);

    var eventDateWeekDay = eventDateRaw.weekday;

    var testFriday = DateTime.now().subtract(Duration(days:1));

    var testNextFriday = testFriday.next(DateTime.friday);

    var todayRaw = DateTime.now();
    var today = DateFormat('yyyy-MM-dd').format(todayRaw);

    var nextFridayRaw = todayRaw.next(DateTime.friday);
    var nextFriday = DateFormat('yyyy-MM-dd').format(nextFridayRaw);

    var nextSaturdayRaw = todayRaw.next(DateTime.sunday);
    String nextSaturday = DateFormat('yyyy-MM-dd').format(nextSaturdayRaw);
    DateTime nextSaturday2 = DateTime.parse(nextSaturday);

    print("test: $testFriday, $testNextFriday");

    if(eventDate2.isBefore(nextSaturday2) || eventDate2.isAtSameMomentAs(nextSaturday2)){
      print("weekday: $eventDateWeekDay, eventDate: $eventDate, today: $today, friday: $nextFriday, saturday: $nextSaturday");
    }




https://techblog.geekyants.com/implementing-flutter-maps-with-osm

https://dribbble.com/shots/23774169-Finance-Management-Mobile-App


The first draft of the ClubMe app.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
