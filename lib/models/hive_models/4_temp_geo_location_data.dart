import 'package:hive/hive.dart';
part '4_temp_geo_location_data.g.dart';

@HiveType(typeId:  4)
class TempGeoLocationData{

  TempGeoLocationData({
    required this.longCoord,
    required this.latCoord,
    required this.createdAt});

  @HiveField(0)
  double latCoord;
  @HiveField(1)
  double longCoord;
  @HiveField(2)
  DateTime createdAt;

}