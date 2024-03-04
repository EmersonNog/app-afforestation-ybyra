// kml_export.dart

// ignore_for_file: avoid_print

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart'; 
import 'package:path_provider/path_provider.dart';

Future<void> exportCityPointsToKML(String kmlContent, String cityName) async {
  try {
    Directory? downloadsDirectory;

    if (Platform.isAndroid) {
      downloadsDirectory = await getExternalStorageDirectory();
    } else if (Platform.isIOS) {
      downloadsDirectory = await getApplicationDocumentsDirectory();
    }

    if (downloadsDirectory != null) {
      final String directoryPath = '${downloadsDirectory.path}/kml';
      await Directory(directoryPath).create(recursive: true); 
      final String filePath = '$directoryPath/$cityName.kml';
      print('Caminho do arquivo: $filePath');

      File file = File(filePath);
      await file.create(recursive: true);
      await file.writeAsString(kmlContent);

      Fluttertoast.showToast(
        msg: 'KML saved successfully!',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 2,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    } else {
      Fluttertoast.showToast(
        msg: 'Failed to access the downloads directory.',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 2,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  } catch (e) {
    Fluttertoast.showToast(
      msg: 'Error saving KML: $e',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 2,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }
}
