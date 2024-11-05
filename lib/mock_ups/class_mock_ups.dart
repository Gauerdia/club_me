import 'package:club_me/models/club_offers.dart';
import 'package:club_me/models/front_page_images.dart';
import 'package:club_me/models/special_opening_times.dart';

import '../models/club.dart';
import '../models/hive_models/0_club_me_user_data.dart';
import '../models/hive_models/6_opening_times.dart';
import '../models/opening_times.dart';

ClubMeClub mockUpClub = ClubMeClub(
    clubId: "12345",
    clubName: "Test-Club",
    clubNews: "Test-News",
    clubMusicGenres: "Test-Genre",
    clubStoryId: "",
    storyCreatedAt: null,
    // clubBannerId: "question_1.png",
    // clubEventBannerId: "question_1.png",
    clubGeoCoordLat: 10,
    clubGeoCoordLng: 10,
    clubContactCity: "Test Stadt",
    clubContactName: "Test Club",
    clubContactStreet: "Teststraße",
    clubContactStreetNumber: "101",
    clubContactZip: "12345",
    clubInstagramLink: "https://www.instagram.com",
    clubWebsiteLink: "https://google.de",
    // clubFrontpageBackgroundColorId: 0,
    priorityScore: 0,
    openingTimes: OpeningTimes(),
    frontPageGalleryImages: FrontPageGalleryImages(),
    clubOffers: ClubOffers(),
  smallLogoFileName: "",
  bigLogoFileName: "",
  frontpageBannerFileName: "",
  mapPinImageName: "black_100x100.png",
  specialOpeningTimes: SpecialOpeningTimes(),
  closePartner: false,
  showClubInApp: true,
  specialOccasionActive: false
);

ClubMeUserData mockUpUserData = ClubMeUserData(
    firstName: "Max",
    lastName: "Mustermann",
    birthDate: DateTime(1990, 10, 15),
    eMail: "max@mustermann.de",
    gender: 1,
    userId: "000000",
    profileType: 0,
    lastTimeLoggedIn: DateTime.now(),
    userProfileAsClub: false,
    clubId: ''
);