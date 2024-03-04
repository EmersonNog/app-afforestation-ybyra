import 'dart:math';

class GeoUtils {
  static const double earthRadius = 6371000; // Radio da terra em metros

  static double degreesToRadians(double degrees) {
    return degrees * pi / 180.0;
  }

  static double calculateHaversineDistance(
      double lat1, double lon1, double lat2, double lon2) {
    // Converte a latitude e longitude para graus decimais
    lat1 = degreesToRadians(lat1);
    lon1 = degreesToRadians(lon1);
    lat2 = degreesToRadians(lat2);
    lon2 = degreesToRadians(lon2);

    // Calculo das distancias
    double dLat = lat2 - lat1;
    double dLon = lon2 - lon1;

    // Haversine formula
    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1) * cos(lat2) * sin(dLon / 2) * sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    // Distancia em metros
    double distance = earthRadius * c;

    return distance;
  }
}
