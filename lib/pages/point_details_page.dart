// point_details_screen.dart
// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import '../Form/point_details_form_app.dart';
import '../Form/point_details_form_general.dart';
import '../utils/point_info.dart';

class PointDetailsScreen extends StatefulWidget {
  final PointInfo pointInfo;

  const PointDetailsScreen({Key? key, required this.pointInfo})
      : super(key: key);

  @override
  _PointDetailsScreenState createState() => _PointDetailsScreenState();
}

class _PointDetailsScreenState extends State<PointDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.pointInfo.city} - ${widget.pointInfo.teamName}',
          style: const TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back),
          style: const ButtonStyle(
            iconColor: MaterialStatePropertyAll(Colors.white),
          ),
        ),
        backgroundColor: const Color.fromRGBO(6, 31, 73, 1),
      ),
      body: _buildPointDetailsForm(),
    );
  }

  Widget _buildPointDetailsForm() {
    if (widget.pointInfo.category == 'Geral') {
      return PointDetailsForm(pointInfo: widget.pointInfo);
    } else if (widget.pointInfo.category == 'App') {
      return PointDetailsFormApp(pointInfo: widget.pointInfo);
    } else {
      return Container();
    }
  }
}
