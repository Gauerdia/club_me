import 'package:club_me/models/club_offers.dart';
import 'package:club_me/models/front_page_images.dart';

import '../models/club.dart';
import '../models/club_me_user_data.dart';
import '../models/opening_times.dart';

ClubMeClub mockUpClub = ClubMeClub(
    clubId: "12345",
    clubName: "Test-Club",
    clubNews: "Test-News",
    clubMusicGenres: "Test-Genre",
    clubStoryId: "",
    clubBannerId: "question_1.png",
    clubEventBannerId: "question_1.png",
    clubGeoCoordLat: 10,
    clubGeoCoordLng: 10,
    clubContactCity: "Test Stadt",
    clubContactName: "Test Club",
    clubContactStreet: "Teststraße",
    clubContactStreetNumber: 101,
    clubContactZip: "12345",
    clubInstagramLink: "https://www.instagram.com",
    clubWebsiteLink: "https://google.de",
    clubFrontpageBackgroundColorId: 0,
    priorityScore: 0,
    openingTimes: OpeningTimes(),
    frontPageImages: FrontPageImages(),
    clubOffers: ClubOffers()
);

ClubMeUserData mockUpUserData = ClubMeUserData(
    firstName: "Max",
    lastName: "Mustermann",
    birthDate: DateTime.now(),
    eMail: "max@mustermann.de",
    gender: 1,
    userId: "000000",
    profileType: 0
);