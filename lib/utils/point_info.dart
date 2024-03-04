import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

class PointInfo {
  final String name;
  final LatLng coordinates;
  final String city;
  final Color? color;
  final String? species;
  final String? category;
  final String? teamName;
  final DateTime createdAt;

  PointInfo(
    this.name,
    this.coordinates, {
    required this.city,
    this.color,
    this.species,
    this.category,
    this.teamName,
    required this.createdAt,
  });
}
