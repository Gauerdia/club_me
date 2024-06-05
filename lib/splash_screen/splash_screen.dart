import 'package:club_me/services/hive_service.dart';
import 'package:flutter/cupertino.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  final HiveService _hiveService = HiveService();

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
