import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';
import '../utils/point_info.dart';

class PointFilter {
  static Future<List<PointInfo>> fetchAndSetPoints(
      String city, String selectedCategory, String selectedTeam) async {
    try {
      QuerySnapshot querySnapshot;

      if (selectedCategory == 'Todas' && selectedTeam != 'Todas') {
        // Fetch points for all categories within the selected team
        querySnapshot = await FirebaseFirestore.instance
            .collection('pontos')
            .where('cidade', isEqualTo: city)
            .where('equipe', isEqualTo: selectedTeam)
            .get();
      } else if (selectedCategory == 'Todas' && selectedTeam == 'Todas') {
        // Fetch points for all categories and all teams
        querySnapshot = await FirebaseFirestore.instance
            .collection('pontos')
            .where('cidade', isEqualTo: city)
            .get();
      } else if (selectedCategory.isNotEmpty && selectedTeam != 'Todas') {
        // Fetch points for a specific category and team
        querySnapshot = await FirebaseFirestore.instance
            .collection('pontos')
            .where('cidade', isEqualTo: city)
            .where('categoria', isEqualTo: selectedCategory)
            .where('equipe', isEqualTo: selectedTeam)
            .get();
      } else if (selectedCategory.isNotEmpty) {
        // Fetch points for a specific category
        querySnapshot = await FirebaseFirestore.instance
            .collection('pontos')
            .where('cidade', isEqualTo: city)
            .where('categoria', isEqualTo: selectedCategory)
            .get();
      } else if (selectedTeam != 'Todas') {
        // Fetch points for a specific team
        querySnapshot = await FirebaseFirestore.instance
            .collection('pontos')
            .where('cidade', isEqualTo: city)
            .where('equipe', isEqualTo: selectedTeam)
            .get();
      } else {
        // Fetch points for all categories and all teams
        querySnapshot = await FirebaseFirestore.instance
            .collection('pontos')
            .where('cidade', isEqualTo: city)
            .get();
      }

      List<PointInfo> points =
          querySnapshot.docs.map((DocumentSnapshot document) {
        Map<String, dynamic> data = document.data() as Map<String, dynamic>;

        String name = data['nome'] ?? '';
        double latitude = (data['latitude'] as num?)?.toDouble() ?? 0.0;
        double longitude = (data['longitude'] as num?)?.toDouble() ?? 0.0;
        String category = data['categoria'] ?? '';
        String team = data['equipe'] ?? '';
        DateTime createdAt =
            (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();

        return PointInfo(
          name,
          LatLng(latitude, longitude),
          city: city,
          category: category,
          teamName: team,
          createdAt: createdAt,
        );
      }).toList();

      return points;
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching points: $e');
      }
      rethrow;
    }
  }
}
