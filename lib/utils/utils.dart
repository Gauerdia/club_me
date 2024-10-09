class Utils{


  static List<String> weekDaysForFiltering = [
    "Alle", "Montag", "Dienstag", "Mittwoch", "Donnerstag",
    "Freitag", "Samstag", "Sonntag"
  ];

  static List<String> usageLimitAnswers = [
  "1x", "2x", "3x", "4x", "5x", "6x", "7x", "8x", "9x", "10x"
  ];

  static List<String> repetitionAnswers = [
    "Wöchentlich", "Zweiwöchentlich"
  ];

  static double creationScreensDistanceBetweenTitleAndTextField = 10;

  static List<String> discountBigImageNames = [
    "free_clubme_500x400.png",
    "free_eintritt_500x400.png",
    "free_getraenk_500x400.png",
    "free_shots_500x400.png",
    "free_sonstiges_500x400.png",
    "special_offer_clubme_500x400.png",
    "special_offer_eintritt_500x400.png",
    "special_offer_flaschen_500x400.png",
    "special_offer_getraenk_500x400.png",
    "special_offer_getraenke_500x400.png",
    "special_offer_sonstiges_500x400.png",
  ];

  static List<String> discountSmallImageNames = [
    "free_clubme_600x300.png",
    "free_eintritt_600x300.png",
    "free_getraenk_600x300.png",
    "free_shots_600x300.png",
    "free_sonstiges_600x300.png",
    "special_offer_clubme_600x300.png",
    "special_offer_eintritt_600x300.png",
    "special_offer_flaschen_600x300.png",
    "special_offer_getraenk_600x300.png",
    "special_offer_getraenke_600x300.png",
    "special_offer_sonstiges_600x300.png",
  ];

  static String noEventElementsDueToNoFavorites = "Derzeit sind keine Events als Favoriten markiert.";
  static String noEventElementsDueToNothingOnTheServer = "Derzeit sind keine aktuellen Events verfügbar.";
  static String noEventElementsDueToFilter = "Entschuldigung, im Rahmen dieser Filter sind keine Events verfügbar.";

  static String noDiscountElementsDueToNoFavorites = "Derzeit sind keine Coupons als Favoriten markiert.";
  static String noDiscountElementsDueToNothingOnTheServer = "Derzeit sind keine aktuellen Coupons verfügbar.";
  static String noDiscountElementsDueToFilter = "Entschuldigung, im Rahmen dieser Filter sind keine Coupons verfügbar.";

  // First one should always be something that means 'no filter' because I
  // compare the current filter value to the first element of this array
  static List<String> genreListForFiltering = [
    "Alle", "Latin", "Rock", "Hip-Hop", "Electronic", "Pop", "Reggaeton", "Afrobeats",
    "R&B", "House", "Techno", "Rap", "90er", "80er", "2000er",
    "Heavy Metal", "Psychedelic", "Balkan"
  ];
  static List<String> genreListForCreating = [
    "Latin", "Rock", "Hip-Hop", "Electronic", "Pop", "Reggaeton", "Afrobeats",
    "R&B", "House", "Techno", "Rap", "90er", "80er", "2000er",
    "Heavy Metal", "Psychedelic", "Balkan"
  ];


  static String mapStyles = '''
  [
  {
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#242f3e"
      }
    ]
  },
  {
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#746855"
      }
    ]
  },
  {
    "elementType": "labels.text.stroke",
    "stylers": [
      {
        "color": "#242f3e"
      }
    ]
  },
  {
    "featureType": "administrative.locality",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#d59563"
      }
    ]
  },
  {
    "featureType": "poi",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#d59563"
      }
    ]
  },
  {
    "featureType": "poi.park",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#263c3f"
      }
    ]
  },
  {
    "featureType": "poi.park",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#6b9a76"
      }
    ]
  },
  {
    "featureType": "road",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#38414e"
      }
    ]
  },
  {
    "featureType": "road",
    "elementType": "geometry.stroke",
    "stylers": [
      {
        "color": "#212a37"
      }
    ]
  },
  {
    "featureType": "road",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#9ca5b3"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#746855"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry.stroke",
    "stylers": [
      {
        "color": "#1f2835"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#f3d19c"
      }
    ]
  },
  {
    "featureType": "transit",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#2f3948"
      }
    ]
  },
  {
    "featureType": "transit.station",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#d59563"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#17263c"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#515c6d"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "labels.text.stroke",
    "stylers": [
      {
        "color": "#17263c"
      }
    ]
  }
]
  
   ''';

}