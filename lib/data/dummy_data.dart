import '../models/club.dart';
import '../models/event.dart';

// List<ClubMeEvent> minorEvents = [
//   ClubMeEvent(
//       title: "DJ Kheeling - Tropical Techno",
//       clubId: "0",
//       clubName: "Berghain",
//       DjName: "DJ Kheeling",
//       date: "Freitag",
//       price: 4,
//       imagePath: "assets/images/img_4.png",
//       description: "Tauch ein in die Nacht und erlebe die ultimative Disco-Party!"
//           "Bist du bereit, die Nacht zum Tag zu machen? Dann ist diese Disco genau das Richtige für dich!"
//           "Feiere mit uns zu den besten Hits der 70er, 80er und 90er Jahre."
//           "Egal ob Discofox, Boogie oder einfach nur Tanzen - hier ist für jeden etwas dabei."
//           "Unsere erfahrenen DJs sorgen für eine ausgelassene Stimmung und bringen dich garantiert zum Schwitzen."
//           "Lasse dich von den bunten Lichtern und den pulsierenden Beats mitreißen und genieße die unvergessliche Atmosphäre."
//           "Ob alleine, mit Freunden oder deinem Partner - hier ist jeder willkommen."
//           "Komm vorbei und erlebe eine Nacht voller Spaß, Musik und Tanz!"
//           "Dresscode:"
//           "Zeige deinen ganz eigenen Style!"
//           "Von bunten Outfits bis hin zu klassischen Disco-Looks - alles ist erlaubt.",
//       musicGenres: "House, Trance, Psy",
//       hours: "22:00 - 07:00 Uhr", eventId: '0252-2033-1123'
//   ),
//   ClubMeEvent(
//       title: "The Halloween Special",
//       clubId: "0",
//       clubName: "Berghain",
//       DjName: "DJ Jürgen",
//       date: "Samstag",
//       price: 14,
//       imagePath: "assets/images/img_4.png",
//       description: "Tauch ein in die Nacht und erlebe die ultimative Disco-Party!"
//           "Bist du bereit, die Nacht zum Tag zu machen? Dann ist diese Disco genau das Richtige für dich!"
//           "Feiere mit uns zu den besten Hits der 70er, 80er und 90er Jahre."
//           "Egal ob Discofox, Boogie oder einfach nur Tanzen - hier ist für jeden etwas dabei."
//           "Unsere erfahrenen DJs sorgen für eine ausgelassene Stimmung und bringen dich garantiert zum Schwitzen."
//           "Lasse dich von den bunten Lichtern und den pulsierenden Beats mitreißen und genieße die unvergessliche Atmosphäre."
//           "Ob alleine, mit Freunden oder deinem Partner - hier ist jeder willkommen."
//           "Komm vorbei und erlebe eine Nacht voller Spaß, Musik und Tanz!"
//           "Dresscode:"
//           "Zeige deinen ganz eigenen Style!"
//           "Von bunten Outfits bis hin zu klassischen Disco-Looks - alles ist erlaubt.",
//       musicGenres: "House, Trance, Psy",
//       hours: "23:00 - 08:00 Uhr", eventId: '0137-2873-2729'
//   )
// ];
//
// List<ClubMeEvent> mayorEvents = [
//   ClubMeEvent(
//       title: "LATINO NIGHT",
//       clubName: "Untergrund Bochum",
//       DjName: "DJ Angerfist",
//       clubId: "0",
//       date: "Samstag",
//       price: 5,
//       imagePath: 'assets/images/img_4.png',
//       description: "Tauch ein in die Nacht und erlebe die ultimative Disco-Party!"
//           "Bist du bereit, die Nacht zum Tag zu machen? Dann ist diese Disco genau das Richtige für dich!"
//           "Feiere mit uns zu den besten Hits der 70er, 80er und 90er Jahre."
//           "Egal ob Discofox, Boogie oder einfach nur Tanzen - hier ist für jeden etwas dabei."
//           "Unsere erfahrenen DJs sorgen für eine ausgelassene Stimmung und bringen dich garantiert zum Schwitzen."
//           "Lasse dich von den bunten Lichtern und den pulsierenden Beats mitreißen und genieße die unvergessliche Atmosphäre."
//           "Ob alleine, mit Freunden oder deinem Partner - hier ist jeder willkommen."
//           "Komm vorbei und erlebe eine Nacht voller Spaß, Musik und Tanz!"
//           "Dresscode:"
//           "Zeige deinen ganz eigenen Style!"
//           "Von bunten Outfits bis hin zu klassischen Disco-Looks - alles ist erlaubt.",
//       musicGenres: "Latin",
//       hours: "22:00 - 03:00 Uhr", eventId: '2222-8888-1234'
//   ),
//   ClubMeEvent(
//       title: "TECHNO TECHNO",
//       clubName: "Zombiekeller",
//       clubId: "0",
//       DjName: "DJ Thomas",
//       date: "Samstag",
//       price: 3,
//       imagePath: "assets/images/dj_wallpaper_3.png",
//       description: "Tauch ein in die Nacht und erlebe die ultimative Disco-Party!"
//           "Bist du bereit, die Nacht zum Tag zu machen? Dann ist diese Disco genau das Richtige für dich!"
//           "Feiere mit uns zu den besten Hits der 70er, 80er und 90er Jahre."
//           "Egal ob Discofox, Boogie oder einfach nur Tanzen - hier ist für jeden etwas dabei."
//           "Unsere erfahrenen DJs sorgen für eine ausgelassene Stimmung und bringen dich garantiert zum Schwitzen."
//           "Lasse dich von den bunten Lichtern und den pulsierenden Beats mitreißen und genieße die unvergessliche Atmosphäre."
//           "Ob alleine, mit Freunden oder deinem Partner - hier ist jeder willkommen."
//           "Komm vorbei und erlebe eine Nacht voller Spaß, Musik und Tanz!"
//           "Dresscode:"
//           "Zeige deinen ganz eigenen Style!"
//           "Von bunten Outfits bis hin zu klassischen Disco-Looks - alles ist erlaubt.",
//       musicGenres: "Techno",
//       hours: "22:00 - 03:00 Uhr", eventId: '9877-2356-1205'
//   ),
//   ClubMeEvent(
//       title: "BEST OF 90s",
//       clubName: "Village Dortmund",
//       DjName: "DJ Gunnar",
//       date: "Sonntag",
//       clubId: "0",
//       price: 12,
//       imagePath: "assets/images/dj_wallpaper_4.png",
//       description: "Tauch ein in die Nacht und erlebe die ultimative Disco-Party!"
//           "Bist du bereit, die Nacht zum Tag zu machen? Dann ist diese Disco genau das Richtige für dich!"
//           "Feiere mit uns zu den besten Hits der 70er, 80er und 90er Jahre."
//           "Egal ob Discofox, Boogie oder einfach nur Tanzen - hier ist für jeden etwas dabei."
//           "Unsere erfahrenen DJs sorgen für eine ausgelassene Stimmung und bringen dich garantiert zum Schwitzen."
//           "Lasse dich von den bunten Lichtern und den pulsierenden Beats mitreißen und genieße die unvergessliche Atmosphäre."
//           "Ob alleine, mit Freunden oder deinem Partner - hier ist jeder willkommen."
//           "Komm vorbei und erlebe eine Nacht voller Spaß, Musik und Tanz!"
//           "Dresscode:"
//           "Zeige deinen ganz eigenen Style!"
//           "Von bunten Outfits bis hin zu klassischen Disco-Looks - alles ist erlaubt.",
//       musicGenres: "90s",
//       hours: "22:00 - 03:00 Uhr", eventId: '3626-1235-8534'
//   ),
//   ClubMeEvent(
//       title: "THE MASH!",
//       clubName: "Sausalitos Essen",
//       DjName: "DJ Fed&Up",
//       clubId: "0",
//       date: "24.05.2004",
//       price: 4,
//       imagePath: "assets/images/dj_wallpaper_5.png",
//       description: "Tauch ein in die Nacht und erlebe die ultimative Disco-Party!"
//           "Bist du bereit, die Nacht zum Tag zu machen? Dann ist diese Disco genau das Richtige für dich!"
//           "Feiere mit uns zu den besten Hits der 70er, 80er und 90er Jahre."
//           "Egal ob Discofox, Boogie oder einfach nur Tanzen - hier ist für jeden etwas dabei."
//           "Unsere erfahrenen DJs sorgen für eine ausgelassene Stimmung und bringen dich garantiert zum Schwitzen."
//           "Lasse dich von den bunten Lichtern und den pulsierenden Beats mitreißen und genieße die unvergessliche Atmosphäre."
//           "Ob alleine, mit Freunden oder deinem Partner - hier ist jeder willkommen."
//           "Komm vorbei und erlebe eine Nacht voller Spaß, Musik und Tanz!"
//           "Dresscode:"
//           "Zeige deinen ganz eigenen Style!"
//           "Von bunten Outfits bis hin zu klassischen Disco-Looks - alles ist erlaubt.",
//       musicGenres: "90s",
//       hours: "22:00 - 03:00 Uhr", eventId: '7024-7012-4210'
//   ),
// ];
//
// List<ClubMeClub> exampleClubs = [
//
//   ClubMeClub(
//       clubId: "1111",
//       clubName: "Berghain",
//       news: "Hier stehen irgendwelche News über den Berghain.",
//       priceList: priceList,
//       musicGenres: musicGenres,
//       storyPath: storyPath,
//       bannerPath: bannerPath,
//       photoPaths: photoPaths,
//       geoCoordLat: geoCoordLat,
//       geoCoordLng: geoCoordLng,
//       contactCity: contactCity,
//       contactName: contactName,
//       contactStreet: contactStreet,
//       contactZip: contactZip
//   ),
//
//   ClubMeClub(
//     clubId:"0000-0000-0000",
//       clubName: "Berghain",
//       distance: "1.2",
//       NOfPeople: "54",
//       genre: "Techno",
//       imagePath: 'assets/images/berghain_logo.jpg',
//       price: "10"
//   ),
//   ClubMeClub(
//       clubId:"1111-0000-0000",
//       clubName: "Nightrooms Dortmund",
//       distance: "2.5",
//       NOfPeople: "163",
//       genre: "Pop, R&B",
//       imagePath: 'assets/images/dj_wallpaper_4.png',
//       price: "15"
//   ),
//   ClubMeClub(
//       clubId:"2222-0000-0000",
//       clubName: "Village Essen",
//       distance: "0.2",
//       NOfPeople: "89",
//       genre: "90s",
//       imagePath: 'assets/images/img_4.png',
//       price: "7"
//   ),
// ];