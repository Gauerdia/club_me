class Utils{


  static List<String> offerTypeFiltering = [
    "Alle", "Informationen", "Coupons"
  ];

  static List<String> monthsForPicking = [
    "Januar", "Februar", "März", "April", "Mai",
    "Juni", "Juli", "August", "September", "Oktober",
    "November", "Dezember"
  ];

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
    "Alle", "Techno", "House", "Trance", "Drum'n'Bass", "Dubstep", "Electro",
    "Hip-Hop", "R'n'B", "Reggae", "Dancehall", "Rock", "Metal", "Punk",
    "Pop", "70er", "80er", "90er", "2000er", "Pop-Rock",
    "Afrobeats", "Reggaeton", "Latin", "Balkan", "Amapiano", "Mixed Music"
  ];
  static List<String> genreListForCreating = [
    "Techno", "House", "Trance", "Drum'n'Bass", "Dubstep", "Electro",
    "Hip-Hop", "R'n'B", "Reggae", "Dancehall", "Rock", "Metal", "Punk",
    "Pop", "70er", "80er", "90er", "2000er", "Pop-Rock",
    "Afrobeats", "Reggaeton", "Latin", "Balkan", "Amapiano", "Mixed Music"
  ];


  static String googleIconSVG = '''
  <svg version="1.1" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 48 48" xmlns:xlink="http://www.w3.org/1999/xlink" style="display: block;">
        <path fill="#EA4335" d="M24 9.5c3.54 0 6.71 1.22 9.21 3.6l6.85-6.85C35.9 2.38 30.47 0 24 0 14.62 0 6.51 5.38 2.56 13.22l7.98 6.19C12.43 13.72 17.74 9.5 24 9.5z"></path>
        <path fill="#4285F4" d="M46.98 24.55c0-1.57-.15-3.09-.38-4.55H24v9.02h12.94c-.58 2.96-2.26 5.48-4.78 7.18l7.73 6c4.51-4.18 7.09-10.36 7.09-17.65z"></path>
        <path fill="#FBBC05" d="M10.53 28.59c-.48-1.45-.76-2.99-.76-4.59s.27-3.14.76-4.59l-7.98-6.19C.92 16.46 0 20.12 0 24c0 3.88.92 7.54 2.56 10.78l7.97-6.19z"></path>
        <path fill="#34A853" d="M24 48c6.48 0 11.93-2.13 15.89-5.81l-7.73-6c-2.15 1.45-4.92 2.3-8.16 2.3-6.26 0-11.57-4.22-13.47-9.91l-7.98 6.19C6.51 42.62 14.62 48 24 48z"></path>
        <path fill="none" d="M0 0h48v48H0z"></path>
      </svg>
  ''';

  static String logo1SVG = '''
  <svg 
  xmlns="http://www.w3.org/2000/svg" 
  xmlns:xlink="http://www.w3.org/1999/xlink" 
  width="1080" 
  zoomAndPan="magnify" 
  viewBox="0 0 810 299.999988" 
  height="400" 
  preserveAspectRatio="xMidYMid meet" version="1.0">
    <defs>
      <filter x="0%" y="0%" width="100%" height="100%" id="615d0cc105">
      <feColorMatrix values="0 0 0 0 1 0 0 0 0 1 0 0 0 0 1 0 0 0 1 0" color-interpolation-filters="sRGB"/>
      </filter>
      <g/>
      <clipPath id="37a0e2ba7f">
      <path d="M 79.050781 30 L 319.050781 30 L 319.050781 270 L 79.050781 270 Z M 79.050781 30 " clip-rule="nonzero"/>
      </clipPath>
      <image x="0" y="0" width="241" xlink:href="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAPEAAADxCAYAAAAay1EJAAAABmJLR0QA/wD/AP+gvaeTAAACsUlEQVR4nO3WsQ0CQRAEwXn4/EMGEsB659RSVQTrtGY3AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA/ru2vU4fATx3T8SQdm97nz4CeM4SQ5wlhjhLDHGWGOIsMcRZYoizxBBniSHOEkOcJYY4SwxxlhjiLDHEiRjivNMQZ4khzhJDnCWGOEsMcZYY4iwxxFliiLPEEGeJIc4SQ5wlhjhLDHGWGOIsMcRZYogTMcR5pyHOEkOcJYY4SwxxlhjiLDHEWWKIs8QQZ4khzhJDnCWGOEsMcZYY4iwxxFliiLPEECdiiPNOQ5wlhjhLDHGWGOIsMcRZYoizxBBniSHOEkOcJYY4SwxxlhjiLDHEWWKIs8QQZ4khTsQQ552GOEsMcZYY4iwxxFliiLPEEGeJIc4SQ5wlhjhLDHGWGOIsMcRZYoizxBBniSHOEkOciCHOOw1xlhjiLDHEWWKIs8QQZ4khzhJDnCWGOEsMcZYY4iwxxFliiLPEEGeJIc4SQ5wlhjgRQ9y17XP6COC5a9v39BHAc15piBMxxIkY4kQMcSKGOBFDnIghTsQQJ2KIEzHEiRjiRAxxIoY4EUOciCFOxBAnYogTMcSJGOJEDHEihjgRQ5yIIU7EECdiiBMxxIkY4kQMcSKGOBFDnIghTsQQJ2KIEzHEiRjiRAxxIoY4EUOciCFOxBAnYogTMcSJGOJEDHEihjgRQ5yIIU7EECdiiBMxxIkY4kQMcSKGOBFDnIghTsQQJ2KIEzHEiRjiRAxxIoY4EUOciCFOxBAnYogTMcSJGOJEDHEihjgRQ5yIIU7EECdiiBMxxIkY4kQMcSKGOBFDnIghTsQQJ2KIEzHEiRjiRAxxIoY4EUOciCFOxBAnYogTMcSJGOJEDHEihjgRQ5yIIe4HkL4FTriFM7gAAAAASUVORK5CYII=" id="f324b0fb55" height="241" preserveAspectRatio="xMidYMid meet"/>
      <mask id="b59c2d17ae"><g filter="url(#615d0cc105)">
      <g>
      <image x="0" y="0" width="241" xlink:href="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAPEAAADxCAYAAAAay1EJAAAABmJLR0QA/wD/AP+gvaeTAAACsUlEQVR4nO3WsQ0CQRAEwXn4/EMGEsB659RSVQTrtGY3AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA/ru2vU4fATx3T8SQdm97nz4CeM4SQ5wlhjhLDHGWGOIsMcRZYoizxBBniSHOEkOcJYY4SwxxlhjiLDHEiRjivNMQZ4khzhJDnCWGOEsMcZYY4iwxxFliiLPEEGeJIc4SQ5wlhjhLDHGWGOIsMcRZYogTMcR5pyHOEkOcJYY4SwxxlhjiLDHEWWKIs8QQZ4khzhJDnCWGOEsMcZYY4iwxxFliiLPEECdiiPNOQ5wlhjhLDHGWGOIsMcRZYoizxBBniSHOEkOcJYY4SwxxlhjiLDHEWWKIs8QQZ4khTsQQ552GOEsMcZYY4iwxxFliiLPEEGeJIc4SQ5wlhjhLDHGWGOIsMcRZYoizxBBniSHOEkOciCHOOw1xlhjiLDHEWWKIs8QQZ4khzhJDnCWGOEsMcZYY4iwxxFliiLPEEGeJIc4SQ5wlhjgRQ9y17XP6COC5a9v39BHAc15piBMxxIkY4kQMcSKGOBFDnIghTsQQJ2KIEzHEiRjiRAxxIoY4EUOciCFOxBAnYogTMcSJGOJEDHEihjgRQ5yIIU7EECdiiBMxxIkY4kQMcSKGOBFDnIghTsQQJ2KIEzHEiRjiRAxxIoY4EUOciCFOxBAnYogTMcSJGOJEDHEihjgRQ5yIIU7EECdiiBMxxIkY4kQMcSKGOBFDnIghTsQQJ2KIEzHEiRjiRAxxIoY4EUOciCFOxBAnYogTMcSJGOJEDHEihjgRQ5yIIU7EECdiiBMxxIkY4kQMcSKGOBFDnIghTsQQJ2KIEzHEiRjiRAxxIoY4EUOciCFOxBAnYogTMcSJGOJEDHEihjgRQ5yIIe4HkL4FTriFM7gAAAAASUVORK5CYII=" height="241" preserveAspectRatio="xMidYMid meet"/>
      </g>
      </g>
      </mask>
      <linearGradient x1="-0.432975" gradientTransform="matrix(0, -0.184814, -0.184814, 0, 240.05167, 240.91998)" y1="649.32001" x2="1303.577897" gradientUnits="userSpaceOnUse" y2="649.32001" id="5de9c01e17"><stop stop-opacity="1" stop-color="rgb(36.099243%, 88.198853%, 90.19928%)" offset="0"/>
      <stop stop-opacity="1" stop-color="rgb(36.099243%, 88.198853%, 90.19928%)" offset="0.25"/>
      <stop stop-opacity="1" stop-color="rgb(36.099243%, 88.198853%, 90.19928%)" offset="0.375"/>
      <stop stop-opacity="1" stop-color="rgb(36.099243%, 88.198853%, 90.19928%)" offset="0.390625"/>
      <stop stop-opacity="1" stop-color="rgb(36.099243%, 88.198853%, 90.19928%)" offset="0.398438"/>
      <stop stop-opacity="1" stop-color="rgb(35.780334%, 87.419128%, 89.402771%)" offset="0.402344"/>
      <stop stop-opacity="1" stop-color="rgb(35.461426%, 86.64093%, 88.606262%)" offset="0.40625"/>
      <stop stop-opacity="1" stop-color="rgb(35.131836%, 85.836792%, 87.782288%)" offset="0.410156"/>
      <stop stop-opacity="1" stop-color="rgb(34.802246%, 85.032654%, 86.959839%)" offset="0.414062"/>
      <stop stop-opacity="1" stop-color="rgb(34.472656%, 84.22699%, 86.13739%)" offset="0.417969"/>
      <stop stop-opacity="1" stop-color="rgb(34.144592%, 83.422852%, 85.314941%)" offset="0.421875"/>
      <stop stop-opacity="1" stop-color="rgb(33.815002%, 82.617188%, 84.490967%)" offset="0.425781"/>
      <stop stop-opacity="1" stop-color="rgb(33.485413%, 81.813049%, 83.668518%)" offset="0.429688"/>
      <stop stop-opacity="1" stop-color="rgb(33.155823%, 81.008911%, 82.846069%)" offset="0.433594"/>
      <stop stop-opacity="1" stop-color="rgb(32.827759%, 80.204773%, 82.023621%)" offset="0.4375"/>
      <stop stop-opacity="1" stop-color="rgb(32.498169%, 79.399109%, 81.199646%)" offset="0.441406"/>
      <stop stop-opacity="1" stop-color="rgb(32.168579%, 78.594971%, 80.377197%)" offset="0.445312"/>
      <stop stop-opacity="1" stop-color="rgb(31.838989%, 77.790833%, 79.554749%)" offset="0.449219"/>
      <stop stop-opacity="1" stop-color="rgb(31.509399%, 76.986694%, 78.7323%)" offset="0.453125"/>
      <stop stop-opacity="1" stop-color="rgb(31.17981%, 76.18103%, 77.908325%)" offset="0.457031"/>
      <stop stop-opacity="1" stop-color="rgb(30.851746%, 75.376892%, 77.085876%)" offset="0.460938"/>
      <stop stop-opacity="1" stop-color="rgb(30.522156%, 74.572754%, 76.263428%)" offset="0.464844"/>
      <stop stop-opacity="1" stop-color="rgb(30.192566%, 73.768616%, 75.440979%)" offset="0.46875"/>
      <stop stop-opacity="1" stop-color="rgb(29.862976%, 72.962952%, 74.61853%)" offset="0.472656"/>
      <stop stop-opacity="1" stop-color="rgb(29.533386%, 72.158813%, 73.796082%)" offset="0.476563"/>
      <stop stop-opacity="1" stop-color="rgb(29.203796%, 71.354675%, 72.972107%)" offset="0.480469"/>
      <stop stop-opacity="1" stop-color="rgb(28.875732%, 70.550537%, 72.149658%)" offset="0.484375"/>
      <stop stop-opacity="1" stop-color="rgb(28.546143%, 69.744873%, 71.327209%)" offset="0.488281"/>
      <stop stop-opacity="1" stop-color="rgb(28.216553%, 68.940735%, 70.504761%)" offset="0.492188"/>
      <stop stop-opacity="1" stop-color="rgb(27.886963%, 68.136597%, 69.680786%)" offset="0.496094"/>
      <stop stop-opacity="1" stop-color="rgb(27.558899%, 67.332458%, 68.858337%)" offset="0.5"/>
      <stop stop-opacity="1" stop-color="rgb(27.229309%, 66.526794%, 68.035889%)" offset="0.503906"/>
      <stop stop-opacity="1" stop-color="rgb(26.899719%, 65.722656%, 67.21344%)" offset="0.507812"/>
      <stop stop-opacity="1" stop-color="rgb(26.570129%, 64.918518%, 66.389465%)" offset="0.511719"/>
      <stop stop-opacity="1" stop-color="rgb(26.24054%, 64.11438%, 65.567017%)" offset="0.515625"/>
      <stop stop-opacity="1" stop-color="rgb(25.91095%, 63.308716%, 64.744568%)" offset="0.519531"/>
      <stop stop-opacity="1" stop-color="rgb(25.582886%, 62.504578%, 63.922119%)" offset="0.523438"/>
      <stop stop-opacity="1" stop-color="rgb(25.253296%, 61.698914%, 63.098145%)" offset="0.527344"/>
      <stop stop-opacity="1" stop-color="rgb(24.923706%, 60.894775%, 62.275696%)" offset="0.53125"/>
      <stop stop-opacity="1" stop-color="rgb(24.594116%, 60.090637%, 61.453247%)" offset="0.535156"/>
      <stop stop-opacity="1" stop-color="rgb(24.264526%, 59.286499%, 60.630798%)" offset="0.539062"/>
      <stop stop-opacity="1" stop-color="rgb(23.934937%, 58.480835%, 59.80835%)" offset="0.542969"/>
      <stop stop-opacity="1" stop-color="rgb(23.606873%, 57.676697%, 58.985901%)" offset="0.546875"/>
      <stop stop-opacity="1" stop-color="rgb(23.277283%, 56.872559%, 58.161926%)" offset="0.550781"/>
      <stop stop-opacity="1" stop-color="rgb(22.947693%, 56.06842%, 57.339478%)" offset="0.554687"/>
      <stop stop-opacity="1" stop-color="rgb(22.618103%, 55.262756%, 56.517029%)" offset="0.558594"/>
      <stop stop-opacity="1" stop-color="rgb(22.290039%, 54.458618%, 55.69458%)" offset="0.5625"/>
      <stop stop-opacity="1" stop-color="rgb(21.960449%, 53.65448%, 54.870605%)" offset="0.566406"/>
      <stop stop-opacity="1" stop-color="rgb(21.630859%, 52.850342%, 54.048157%)" offset="0.570313"/>
      <stop stop-opacity="1" stop-color="rgb(21.30127%, 52.044678%, 53.225708%)" offset="0.574219"/>
      <stop stop-opacity="1" stop-color="rgb(20.97168%, 51.24054%, 52.403259%)" offset="0.578125"/>
      <stop stop-opacity="1" stop-color="rgb(20.64209%, 50.436401%, 51.579285%)" offset="0.582031"/>
      <stop stop-opacity="1" stop-color="rgb(20.314026%, 49.632263%, 50.756836%)" offset="0.585938"/>
      <stop stop-opacity="1" stop-color="rgb(19.984436%, 48.826599%, 49.934387%)" offset="0.589844"/>
      <stop stop-opacity="1" stop-color="rgb(19.654846%, 48.022461%, 49.111938%)" offset="0.59375"/>
      <stop stop-opacity="1" stop-color="rgb(19.325256%, 47.218323%, 48.287964%)" offset="0.597656"/>
      <stop stop-opacity="1" stop-color="rgb(18.997192%, 46.414185%, 47.465515%)" offset="0.601562"/>
      <stop stop-opacity="1" stop-color="rgb(18.667603%, 45.608521%, 46.643066%)" offset="0.605469"/>
      <stop stop-opacity="1" stop-color="rgb(18.338013%, 44.804382%, 45.820618%)" offset="0.609375"/>
      <stop stop-opacity="1" stop-color="rgb(18.008423%, 44.000244%, 44.996643%)" offset="0.613281"/>
      <stop stop-opacity="1" stop-color="rgb(17.678833%, 43.196106%, 44.174194%)" offset="0.617188"/>
      <stop stop-opacity="1" stop-color="rgb(17.349243%, 42.390442%, 43.351746%)" offset="0.621094"/>
      <stop stop-opacity="1" stop-color="rgb(17.021179%, 41.586304%, 42.529297%)" offset="0.625"/>
      <stop stop-opacity="1" stop-color="rgb(16.691589%, 40.78064%, 41.706848%)" offset="0.628906"/>
      <stop stop-opacity="1" stop-color="rgb(16.362%, 39.976501%, 40.884399%)" offset="0.632812"/>
      <stop stop-opacity="1" stop-color="rgb(16.03241%, 39.172363%, 40.060425%)" offset="0.636719"/>
      <stop stop-opacity="1" stop-color="rgb(15.70282%, 38.368225%, 39.237976%)" offset="0.640625"/>
      <stop stop-opacity="1" stop-color="rgb(15.37323%, 37.562561%, 38.415527%)" offset="0.644531"/>
      <stop stop-opacity="1" stop-color="rgb(15.045166%, 36.758423%, 37.593079%)" offset="0.648437"/>
      <stop stop-opacity="1" stop-color="rgb(14.715576%, 35.954285%, 36.769104%)" offset="0.652344"/>
      <stop stop-opacity="1" stop-color="rgb(14.385986%, 35.150146%, 35.946655%)" offset="0.65625"/>
      <stop stop-opacity="1" stop-color="rgb(14.056396%, 34.344482%, 35.124207%)" offset="0.660156"/>
      <stop stop-opacity="1" stop-color="rgb(13.728333%, 33.540344%, 34.301758%)" offset="0.664063"/>
      <stop stop-opacity="1" stop-color="rgb(13.398743%, 32.736206%, 33.477783%)" offset="0.667969"/>
      <stop stop-opacity="1" stop-color="rgb(13.069153%, 31.932068%, 32.655334%)" offset="0.671875"/>
      <stop stop-opacity="1" stop-color="rgb(12.739563%, 31.126404%, 31.832886%)" offset="0.675781"/>
      <stop stop-opacity="1" stop-color="rgb(12.409973%, 30.322266%, 31.010437%)" offset="0.679688"/>
      <stop stop-opacity="1" stop-color="rgb(12.080383%, 29.518127%, 30.186462%)" offset="0.683594"/>
      <stop stop-opacity="1" stop-color="rgb(11.752319%, 28.713989%, 29.364014%)" offset="0.6875"/>
      <stop stop-opacity="1" stop-color="rgb(11.422729%, 27.908325%, 28.541565%)" offset="0.691406"/>
      <stop stop-opacity="1" stop-color="rgb(11.09314%, 27.104187%, 27.719116%)" offset="0.695312"/>
      <stop stop-opacity="1" stop-color="rgb(10.76355%, 26.300049%, 26.895142%)" offset="0.699219"/>
      <stop stop-opacity="1" stop-color="rgb(10.43396%, 25.495911%, 26.072693%)" offset="0.703125"/>
      <stop stop-opacity="1" stop-color="rgb(10.10437%, 24.690247%, 25.250244%)" offset="0.707031"/>
      <stop stop-opacity="1" stop-color="rgb(9.776306%, 23.886108%, 24.427795%)" offset="0.710938"/>
      <stop stop-opacity="1" stop-color="rgb(9.446716%, 23.08197%, 23.605347%)" offset="0.714844"/>
      <stop stop-opacity="1" stop-color="rgb(9.117126%, 22.277832%, 22.782898%)" offset="0.71875"/>
      <stop stop-opacity="1" stop-color="rgb(8.787537%, 21.472168%, 21.958923%)" offset="0.722656"/>
      <stop stop-opacity="1" stop-color="rgb(8.459473%, 20.66803%, 21.136475%)" offset="0.726562"/>
      <stop stop-opacity="1" stop-color="rgb(8.129883%, 19.862366%, 20.314026%)" offset="0.730469"/>
      <stop stop-opacity="1" stop-color="rgb(7.800293%, 19.058228%, 19.491577%)" offset="0.734375"/>
      <stop stop-opacity="1" stop-color="rgb(7.470703%, 18.254089%, 18.667603%)" offset="0.738281"/>
      <stop stop-opacity="1" stop-color="rgb(7.141113%, 17.449951%, 17.845154%)" offset="0.742187"/>
      <stop stop-opacity="1" stop-color="rgb(6.811523%, 16.644287%, 17.022705%)" offset="0.746094"/>
      <stop stop-opacity="1" stop-color="rgb(6.483459%, 15.840149%, 16.200256%)" offset="0.75"/>
      <stop stop-opacity="1" stop-color="rgb(6.15387%, 15.036011%, 15.376282%)" offset="0.753906"/>
      <stop stop-opacity="1" stop-color="rgb(5.82428%, 14.231873%, 14.553833%)" offset="0.757813"/>
      <stop stop-opacity="1" stop-color="rgb(5.49469%, 13.426208%, 13.731384%)" offset="0.761719"/>
      <stop stop-opacity="1" stop-color="rgb(5.166626%, 12.62207%, 12.908936%)" offset="0.765625"/>
      <stop stop-opacity="1" stop-color="rgb(4.837036%, 11.817932%, 12.084961%)" offset="0.769531"/>
      <stop stop-opacity="1" stop-color="rgb(4.507446%, 11.013794%, 11.262512%)" offset="0.773438"/>
      <stop stop-opacity="1" stop-color="rgb(4.177856%, 10.20813%, 10.440063%)" offset="0.777344"/>
      <stop stop-opacity="1" stop-color="rgb(3.848267%, 9.403992%, 9.617615%)" offset="0.78125"/>
      <stop stop-opacity="1" stop-color="rgb(3.518677%, 8.599854%, 8.795166%)" offset="0.785156"/>
      <stop stop-opacity="1" stop-color="rgb(3.190613%, 7.795715%, 7.972717%)" offset="0.789062"/>
      <stop stop-opacity="1" stop-color="rgb(2.861023%, 6.990051%, 7.148743%)" offset="0.792969"/>
      <stop stop-opacity="1" stop-color="rgb(2.531433%, 6.185913%, 6.326294%)" offset="0.796875"/>
      <stop stop-opacity="1" stop-color="rgb(2.201843%, 5.381775%, 5.503845%)" offset="0.800781"/>
      <stop stop-opacity="1" stop-color="rgb(1.872253%, 4.577637%, 4.681396%)" offset="0.804688"/>
      <stop stop-opacity="1" stop-color="rgb(1.542664%, 3.771973%, 3.857422%)" offset="0.808594"/>
      <stop stop-opacity="1" stop-color="rgb(1.2146%, 2.967834%, 3.034973%)" offset="0.8125"/>
      <stop stop-opacity="1" stop-color="rgb(0.88501%, 2.163696%, 2.212524%)" offset="0.816406"/>
      <stop stop-opacity="1" stop-color="rgb(0.55542%, 1.359558%, 1.390076%)" offset="0.820312"/>
      <stop stop-opacity="1" stop-color="rgb(0.27771%, 0.679016%, 0.694275%)" offset="0.824219"/>
      <stop stop-opacity="1" stop-color="rgb(0%, 0%, 0%)" offset="0.828125"/>
      <stop stop-opacity="1" stop-color="rgb(0%, 0%, 0%)" offset="0.84375"/>
      <stop stop-opacity="1" stop-color="rgb(0%, 0%, 0%)" offset="0.875"/>
      <stop stop-opacity="1" stop-color="rgb(0%, 0%, 0%)" offset="1"/>
      </linearGradient>
      <clipPath id="e244eaaa73">
      <rect x="0" width="241" y="0" height="241"/>
      </clipPath>
      <pattern id="82292b4e23" patternUnits="userSpaceOnUse" width="241" patternTransform="matrix(0, -5.410834, -5.410834, 0, 1303.577927, 1298.87957)" preserveAspectRatio="xMidYMid meet" viewBox="0 0 241 241" height="241" x="0" y="0"><g><g clip-path="url(#e244eaaa73)">
      <g mask="url(#b59c2d17ae)"><rect x="172.409587" fill="url(#5de9c01e17)" width="79.839821" height="215.567524" y="58.286385"/>
      </g></g></g></pattern>
      </defs>
      <g clip-path="url(#37a0e2ba7f)">
      <path stroke-linecap="butt" transform="matrix(0, 0.184814, -0.184814, 0, 319.051661, 29.999998)" fill="none" stroke-linejoin="miter" d="M 1288.645038 649.325951 C 1288.645038 659.788305 1288.391406 670.229524 1287.863004 680.691878 C 1287.355738 691.133096 1286.59484 701.574315 1285.559172 711.994397 C 1284.544641 722.393343 1283.255341 732.771153 1281.712408 743.127827 C 1280.190611 753.484502 1278.394045 763.777767 1276.364982 774.049897 C 1274.314783 784.300891 1272.032088 794.509613 1269.474623 804.654926 C 1266.938295 814.821375 1264.148334 824.882145 1261.10474 834.900642 C 1258.082282 844.919138 1254.785055 854.853091 1251.276467 864.7025 C 1247.746744 874.551908 1243.984523 884.316772 1239.96867 893.975956 C 1235.973953 903.63514 1231.725603 913.209779 1227.265892 922.657602 C 1222.785046 932.126562 1218.071702 941.468704 1213.146998 950.684031 C 1208.222294 959.920493 1203.065093 969.030139 1197.675395 977.991832 C 1192.306833 986.974662 1186.705775 995.809539 1180.893356 1004.5176 C 1175.080937 1013.204524 1169.057157 1021.764633 1162.822016 1030.155652 C 1156.586876 1038.567808 1150.161511 1046.810875 1143.524785 1054.90599 C 1136.888059 1062.979968 1130.061109 1070.905994 1123.022797 1078.662932 C 1116.005622 1086.419869 1108.777086 1093.986582 1101.379462 1101.384207 C 1093.981838 1108.781831 1086.415125 1115.989231 1078.658187 1123.027542 C 1070.90125 1130.044717 1062.99636 1136.892803 1054.901245 1143.529529 C 1046.806131 1150.166255 1038.563063 1156.59162 1030.172044 1162.826761 C 1021.759888 1169.061901 1013.19978 1175.085681 1004.512855 1180.8981 C 995.804795 1186.710519 986.969918 1192.311578 977.987088 1197.68014 C 969.025395 1203.069837 959.915749 1208.227038 950.700422 1213.151742 C 941.46396 1218.076447 932.121817 1222.78979 922.673994 1227.249501 C 913.205035 1231.730348 903.651531 1235.978698 893.971211 1239.973415 C 884.312028 1243.968132 874.547164 1247.751488 864.697755 1251.260076 C 854.848347 1254.789799 844.914394 1258.06589 834.895897 1261.109484 C 824.898536 1264.153078 814.816631 1266.943039 804.671318 1269.479368 C 794.504868 1272.015696 784.317283 1274.319528 774.045153 1276.34859 C 763.773023 1278.398789 753.479757 1280.195355 743.123083 1281.717152 C 732.787545 1283.260085 722.388599 1284.528249 711.989653 1285.563917 C 701.56957 1286.578448 691.149488 1287.360483 680.687134 1287.867748 C 670.245915 1288.375014 659.783561 1288.649783 649.321206 1288.649783 C 638.858852 1288.649783 628.396497 1288.375014 617.955279 1287.867748 C 607.492925 1287.360483 597.072842 1286.578448 586.65276 1285.563917 C 576.232678 1284.528249 565.854868 1283.260085 555.51933 1281.717152 C 545.162655 1280.195355 534.848254 1278.398789 524.59726 1276.34859 C 514.32513 1274.319528 504.137544 1272.015696 493.971095 1269.479368 C 483.825782 1266.943039 473.743876 1264.153078 463.725379 1261.109484 C 453.728019 1258.06589 443.794066 1254.789799 433.944657 1251.260076 C 424.095249 1247.751488 414.330385 1243.968132 404.671201 1239.973415 C 394.990881 1235.978698 385.437378 1231.730348 375.968419 1227.249501 C 366.520596 1222.78979 357.178453 1218.076447 347.94199 1213.151742 C 338.726664 1208.227038 329.617018 1203.069837 320.634189 1197.68014 C 311.672495 1192.311578 302.837618 1186.710519 294.129557 1180.8981 C 285.442633 1175.085681 276.882525 1169.061901 268.470369 1162.826761 C 260.079349 1156.59162 251.836282 1150.166255 243.741167 1143.529529 C 235.646053 1136.892803 227.741163 1130.044717 219.984225 1123.027542 C 212.227288 1115.989231 204.660575 1108.781831 197.26295 1101.384207 C 189.84419 1093.986582 182.63679 1086.419869 175.619615 1078.662932 C 168.581304 1070.905994 161.754354 1062.979968 155.117628 1054.90599 C 148.480902 1046.810875 142.055537 1038.567808 135.820396 1030.155652 C 129.585256 1021.764633 123.561476 1013.204524 117.749057 1004.5176 C 111.936638 995.809539 106.335579 986.974662 100.967018 977.991832 C 95.57732 969.030139 90.420119 959.920493 85.495415 950.684031 C 80.549574 941.468704 75.857367 932.126562 71.37652 922.657602 C 66.916809 913.209779 62.66846 903.63514 58.673742 893.975956 C 54.657889 884.316772 50.895669 874.551908 47.365945 864.7025 C 43.857358 854.853091 40.560131 844.919138 37.537673 834.900642 C 34.494079 824.882145 31.704118 814.821375 29.167789 804.654926 C 26.610325 794.509613 24.327629 784.300891 22.277431 774.049897 C 20.248368 763.777767 18.451802 753.484502 16.930005 743.127827 C 15.387072 732.771153 14.097772 722.393343 13.08324 711.994397 C 12.047573 701.574315 11.286674 691.133096 10.779409 680.691878 C 10.251007 670.229524 9.997374 659.788305 9.997374 649.325951 C 9.997374 638.863596 10.251007 628.401242 10.779409 617.960024 C 11.286674 607.497669 12.047573 597.077587 13.08324 586.657505 C 14.097772 576.237422 15.387072 565.859612 16.930005 555.502938 C 18.451802 545.1674 20.248368 534.852998 22.277431 524.602004 C 24.327629 514.329874 26.610325 504.121153 29.167789 493.975839 C 31.704118 483.830526 34.494079 473.748621 37.537673 463.730124 C 40.560131 453.732763 43.857358 443.79881 47.365945 433.949402 C 50.895669 424.078857 54.657889 414.335129 58.673742 404.654809 C 62.66846 394.995626 66.916809 385.442122 71.37652 375.973163 C 75.857367 366.52534 80.549574 357.183197 85.495415 347.946735 C 90.420119 338.710272 95.57732 329.621763 100.967018 320.638933 C 106.335579 311.677239 111.936638 302.842362 117.749057 294.134302 C 123.561476 285.426241 129.585256 276.887269 135.820396 268.475113 C 142.055537 260.084094 148.480902 251.81989 155.117628 243.745912 C 161.754354 235.650797 168.581304 227.724771 175.619615 219.98897 C 182.63679 212.232032 189.84419 204.644183 197.26295 197.246559 C 204.660575 189.848935 212.227288 182.641535 219.984225 175.62436 C 227.741163 168.586049 235.646053 161.759098 243.741167 155.122372 C 251.836282 148.485646 260.079349 142.039145 268.470369 135.804005 C 276.882525 129.59 285.442633 123.56622 294.129557 117.753801 C 302.837618 111.941382 311.672495 106.340324 320.634189 100.950626 C 329.617018 95.582064 338.726664 90.424863 347.94199 85.500159 C 357.178453 80.554319 366.520596 75.862111 375.968419 71.381265 C 385.437378 66.900418 394.990881 62.673204 404.671201 58.657351 C 414.330385 54.662634 424.095249 50.900413 433.944657 47.37069 C 443.794066 43.840966 453.728019 40.564875 463.725379 37.521281 C 473.743876 34.498823 483.825782 31.708862 493.971095 29.151398 C 504.137544 26.615069 514.32513 24.332374 524.59726 22.282175 C 534.848254 20.253112 545.162655 18.456546 555.51933 16.913613 C 565.854868 15.391816 576.232678 14.102516 586.65276 13.087985 C 597.072842 12.052317 607.492925 11.291419 617.955279 10.763017 C 628.396497 10.255751 638.858852 10.002119 649.321206 10.002119 C 659.783561 10.002119 670.245915 10.255751 680.687134 10.763017 C 691.149488 11.291419 701.56957 12.052317 711.989653 13.087985 C 722.388599 14.102516 732.787545 15.391816 743.123083 16.913613 C 753.479757 18.456546 763.773023 20.253112 774.045153 22.282175 C 784.317283 24.332374 794.504868 26.615069 804.671318 29.151398 C 814.816631 31.708862 824.898536 34.498823 834.895897 37.521281 C 844.914394 40.564875 854.848347 43.840966 864.697755 47.37069 C 874.547164 50.900413 884.312028 54.662634 893.971211 58.657351 C 903.651531 62.673204 913.205035 66.900418 922.673994 71.381265 C 932.121817 75.862111 941.46396 80.554319 950.700422 85.500159 C 959.915749 90.424863 969.025395 95.582064 977.987088 100.950626 C 986.969918 106.340324 995.804795 111.941382 1004.512855 117.753801 C 1013.19978 123.56622 1021.759888 129.59 1030.172044 135.804005 C 1038.563063 142.039145 1046.806131 148.485646 1054.901245 155.122372 C 1062.99636 161.759098 1070.90125 168.586049 1078.658187 175.62436 C 1086.415125 182.641535 1093.981838 189.848935 1101.379462 197.246559 C 1108.777086 204.644183 1116.005622 212.232032 1123.022797 219.98897 C 1130.061109 227.724771 1136.888059 235.650797 1143.524785 243.745912 C 1150.161511 251.81989 1156.586876 260.084094 1162.822016 268.475113 C 1169.057157 276.887269 1175.080937 285.426241 1180.893356 294.134302 C 1186.705775 302.842362 1192.306833 311.677239 1197.675395 320.638933 C 1203.065093 329.621763 1208.222294 338.710272 1213.146998 347.946735 C 1218.071702 357.183197 1222.785046 366.52534 1227.265892 375.973163 C 1231.725603 385.442122 1235.973953 394.995626 1239.96867 404.654809 C 1243.984523 414.335129 1247.746744 424.078857 1251.276467 433.949402 C 1254.785055 443.79881 1258.082282 453.732763 1261.10474 463.730124 C 1264.148334 473.748621 1266.938295 483.830526 1269.474623 493.975839 C 1272.032088 504.121153 1274.314783 514.329874 1276.364982 524.602004 C 1278.394045 534.852998 1280.190611 545.1674 1281.712408 555.502938 C 1283.255341 565.859612 1284.544641 576.237422 1285.559172 586.657505 C 1286.59484 597.077587 1287.355738 607.497669 1287.863004 617.960024 C 1288.391406 628.401242 1288.645038 638.863596 1288.645038 649.325951 Z M 1288.645038 649.325951 " stroke="url(#82292b4e23)" stroke-width="20" stroke-miterlimit="10"/></g><g fill="#ffffff" fill-opacity="1"><g transform="translate(151.333393, 201.018133)"><g><path d="M 57.25 -18.03125 C 44.757812 -18.03125 36.472656 -24.859375 32.390625 -38.515625 C 30.640625 -44.359375 29.765625 -51.128906 29.765625 -58.828125 C 29.765625 -80.078125 34.664062 -93.328125 44.46875 -98.578125 C 47.15625 -99.972656 50.078125 -100.671875 53.234375 -100.671875 C 61.984375 -100.441406 68.109375 -95.132812 71.609375 -84.75 L 94.203125 -90 C 89.535156 -107.15625 79.085938 -117.132812 62.859375 -119.9375 C 59.828125 -120.519531 56.675781 -120.8125 53.40625 -120.8125 C 38.925781 -120.8125 27.191406 -115.09375 18.203125 -103.65625 C 9.566406 -92.332031 5.25 -77.332031 5.25 -58.65625 C 5.25 -36.363281 11.4375 -19.671875 23.8125 -8.578125 C 32.21875 -1.109375 42.253906 2.625 53.921875 2.625 C 66.421875 2.507812 79.03125 -1.515625 91.75 -9.453125 L 83.171875 -26.265625 C 73.710938 -20.773438 65.070312 -18.03125 57.25 -18.03125 Z M 57.25 -18.03125 "/></g></g></g><g fill="#ffffff" fill-opacity="1"><g transform="translate(345.1297, 183.133831)"><g><path d="M 39.40625 -12.40625 C 30.8125 -12.40625 25.109375 -17.109375 22.296875 -26.515625 C 21.085938 -30.523438 20.484375 -35.179688 20.484375 -40.484375 C 20.484375 -55.109375 23.859375 -64.226562 30.609375 -67.84375 C 32.453125 -68.800781 34.457031 -69.28125 36.625 -69.28125 C 42.65625 -69.125 46.875 -65.472656 49.28125 -58.328125 L 64.828125 -61.9375 C 61.617188 -73.75 54.429688 -80.617188 43.265625 -82.546875 C 41.171875 -82.941406 39 -83.140625 36.75 -83.140625 C 26.789062 -83.140625 18.71875 -79.203125 12.53125 -71.328125 C 6.582031 -63.535156 3.609375 -53.210938 3.609375 -40.359375 C 3.609375 -25.023438 7.867188 -13.539062 16.390625 -5.90625 C 22.171875 -0.757812 29.078125 1.8125 37.109375 1.8125 C 45.703125 1.726562 54.378906 -1.039062 63.140625 -6.5 L 57.234375 -18.078125 C 50.722656 -14.296875 44.78125 -12.40625 39.40625 -12.40625 Z M 39.40625 -12.40625 "/></g></g></g><g fill="#ffffff" fill-opacity="1"><g transform="translate(410.797452, 183.133831)"><g><path d="M 23.375 1.8125 C 26.59375 1.8125 30.128906 1.285156 33.984375 0.234375 L 31.203125 -11.453125 C 29.597656 -11.046875 28.316406 -10.84375 27.359375 -10.84375 C 24.378906 -10.84375 22.769531 -12.648438 22.53125 -16.265625 C 22.53125 -16.671875 22.53125 -17.070312 22.53125 -17.46875 L 22.53125 -87.359375 L 6.875 -87.359375 L 6.875 -16.03125 C 6.875 -4.78125 11.8125 1.164062 21.6875 1.8125 C 22.25 1.8125 22.8125 1.8125 23.375 1.8125 Z M 23.375 1.8125 "/></g></g></g><g fill="#ffffff" fill-opacity="1"><g transform="translate(444.775995, 183.133831)"><g><path d="M 56.515625 1.8125 C 58.847656 1.8125 61.097656 1.53125 63.265625 0.96875 L 62.78125 -10.484375 C 62.300781 -10.398438 61.738281 -10.359375 61.09375 -10.359375 C 58.6875 -10.359375 57.320312 -11.644531 57 -14.21875 C 56.914062 -14.78125 56.875 -15.382812 56.875 -16.03125 L 56.875 -60.25 L 41.203125 -60.25 L 41.203125 -29.515625 C 41.203125 -19.472656 38.710938 -13.410156 33.734375 -11.328125 C 32.609375 -10.847656 31.445312 -10.609375 30.25 -10.609375 C 25.101562 -10.765625 22.488281 -14.296875 22.40625 -21.203125 L 22.40625 -60.25 L 6.75 -60.25 L 6.75 -19.40625 C 6.75 -8.800781 10.6875 -2.210938 18.5625 0.359375 C 20.8125 1.085938 23.21875 1.453125 25.78125 1.453125 C 31.8125 1.453125 36.992188 -1.117188 41.328125 -6.265625 C 42.296875 -7.390625 43.140625 -8.554688 43.859375 -9.765625 C 44.660156 -2.128906 48.878906 1.726562 56.515625 1.8125 Z M 56.515625 1.8125 "/></g></g></g><g fill="#ffffff" fill-opacity="1"><g transform="translate(508.997851, 183.133831)"><g><path d="M 58.796875 -33.25 C 58.796875 -44.90625 55.460938 -53.222656 48.796875 -58.203125 C 45.347656 -60.773438 41.332031 -62.0625 36.75 -62.0625 C 31.289062 -61.976562 26.789062 -60.007812 23.25 -56.15625 L 23.015625 -87.359375 L 7.34375 -87.359375 L 7.234375 -3.609375 C 15.097656 0.00390625 22.523438 1.8125 29.515625 1.8125 C 40.609375 1.8125 48.722656 -2.644531 53.859375 -11.5625 C 57.148438 -17.351562 58.796875 -24.582031 58.796875 -33.25 Z M 22.890625 -12.53125 L 23.015625 -34.21875 C 23.015625 -42.8125 25.382812 -47.832031 30.125 -49.28125 C 31.007812 -49.519531 31.894531 -49.640625 32.78125 -49.640625 C 37.03125 -49.640625 40 -46.910156 41.6875 -41.453125 C 42.414062 -38.960938 42.78125 -36.148438 42.78125 -33.015625 C 42.78125 -19.679688 39.328125 -12.367188 32.421875 -11.078125 C 31.691406 -10.921875 30.96875 -10.84375 30.25 -10.84375 C 28.070312 -10.84375 25.617188 -11.40625 22.890625 -12.53125 Z M 22.890625 -12.53125 "/></g></g></g><g fill="#ffffff" fill-opacity="1"><g transform="translate(570.568899, 183.133831)"><g><path d="M 17.359375 0 L 21.5625 -46.640625 C 22.125 -52.984375 22.53125 -57.035156 22.78125 -58.796875 C 23.976562 -53.015625 24.859375 -49.082031 25.421875 -47 L 36.875 -2.53125 L 51.6875 -3.015625 L 63.75 -46.390625 C 64.789062 -50.242188 65.832031 -54.582031 66.875 -59.40625 C 67.195312 -53.300781 67.476562 -49.082031 67.71875 -46.75 L 71.703125 0 L 87.359375 0 L 77.96875 -81.34375 L 60.125 -81.34375 L 47.46875 -32.296875 C 46.832031 -30.046875 46.070312 -26.59375 45.1875 -21.9375 C 44.21875 -27.550781 43.613281 -30.800781 43.375 -31.6875 L 30.84375 -81.34375 L 12.40625 -81.34375 L 2.765625 0 Z M 17.359375 0 "/>
      </g>
      </g>
      </g>
      <g fill="#ffffff" fill-opacity="1">
      <g transform="translate(660.937365, 183.133831)">
      <g>
      <path d="M 54.109375 -5.0625 L 49.53125 -15.421875 C 43.90625 -12.367188 38.640625 -10.84375 33.734375 -10.84375 C 27.390625 -10.84375 23.09375 -14.097656 20.84375 -20.609375 C 20.363281 -22.210938 20.003906 -23.898438 19.765625 -25.671875 L 55.3125 -25.671875 L 55.3125 -30.125 C 55.3125 -47.957031 49.6875 -58.320312 38.4375 -61.21875 C 36.03125 -61.78125 33.421875 -62.0625 30.609375 -62.0625 C 21.523438 -62.0625 14.492188 -58.644531 9.515625 -51.8125 C 5.503906 -46.351562 3.5 -39.363281 3.5 -30.84375 C 3.5 -17.988281 7.59375 -8.710938 15.78125 -3.015625 C 20.519531 0.203125 26.066406 1.8125 32.421875 1.8125 C 40.367188 1.726562 47.597656 -0.5625 54.109375 -5.0625 Z M 30.484375 -50 C 35.304688 -50 38.195312 -47.109375 39.15625 -41.328125 C 39.40625 -40.046875 39.53125 -38.679688 39.53125 -37.234375 L 20 -37.109375 C 21.125 -44.578125 24.015625 -48.796875 28.671875 -49.765625 C 29.316406 -49.921875 29.921875 -50 30.484375 -50 Z M 30.484375 -50 "/>
      </g>
      </g>
      </g>
      </svg>
  ''';

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