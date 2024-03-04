// enums.dart
import 'package:flutter/material.dart';

enum TileLayerType {
  streetMap,
  satellite
}

class LayerDropdownItem {
  final TileLayerType type;
  final String label;
  final IconData icon;

  LayerDropdownItem({
    required this.type,
    required this.label,
    required this.icon,
  });
}
