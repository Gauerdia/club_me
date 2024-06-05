import 'package:url_launcher/url_launcher.dart';

class MapUtils {

  MapUtils._();

  static Future<void> openMap(double latitude, double longitude) async {

    Uri googleUrl = Uri.parse('https://www.google.com/maps/place/$latitude,$longitude');

    await canLaunchUrl(googleUrl)
    ? await launchUrl(googleUrl)
        : print("Error");
  }
}