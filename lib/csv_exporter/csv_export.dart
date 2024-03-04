// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import '../utils/point_info.dart';

Future<void> exportCityPointsToCSV(
    List<PointInfo> points, String cityName) async {
  try {
    final List<List<String>> rows = [];
    rows.add([
      'ID',
      'Latitude',
      'Longitude',
      'Cidade',
      'Nome Comum',
      'CAP',
      'DAP',
      "CAP's Adicionais",
      "DAP's Adicionais",
      "Raiz do Somatorio dos DAP's^2",
      'Altura',
      'Localizacao',
      'Altura da 1 Bifurcacao',
      'Distancia da Arvore Anterior',
      'Distancia da Arvore Posterior',
      'Distancia da Arvore Para o Meio-Fio',
      'Distancia da Arvore Para o Poste',
      'Distancia da Arvore Para o Imovel',
      'Largura da Calcada',
      'Dimensoes da Area de Aeracao',
      'Largura do Canteiro Central',
      'Sinalizacao de Transito',
      'Redes e Iluminacao',
      'Tipo de Encopamento',
      'Espacamento Entre as Copas',
      'Avanco da Copa',
      'Possui Afloramento',
      'Afetamento',
      'Vitalidade',
      'Injuria Mecanica',
      'Podas Anteriores',
      'Inclinacao do Fuste',
      'Possui Infestacao',
      'Infestacao',
      'Imagem',
    ]);
    for (PointInfo point in points) {
      String collectionName =
          point.category == 'App' ? 'additional_info_app' : 'additional_info';
      QuerySnapshot<Object?> querySnapshotAdditional = await FirebaseFirestore
          .instance
          .collection(collectionName)
          .where('point_id', isEqualTo: point.name)
          .get();

      if (querySnapshotAdditional.docs.isNotEmpty) {
        DocumentSnapshot additionalInfoDoc = querySnapshotAdditional.docs.first;
        String getField(String fieldName) {
          Map<String, dynamic> data =
              additionalInfoDoc.data() as Map<String, dynamic>;

          return data.containsKey(fieldName)
              ? data[fieldName].toString()
              : 'N/A';
        }

        String locationValue =
            point.category == 'App' ? 'APP' : getField('location');

        rows.add([
          point.name,
          point.coordinates.latitude.toString(),
          point.coordinates.longitude.toString(),
          point.city,
          getField('nameCommon'),
          getField('cap'),
          getField('dap'),
          getField('additionalCapValues'),
          getField('additionalDapValues'),
          getField('dapRoot'),
          getField('height'),
          locationValue,
          getField('heightBifurcation'),
          getField('distanceTreePrevious'),
          getField('distanceTreeNext'),
          getField('distanceTreeToHalfWire'),
          getField('distanceTreeToPost'),
          getField('distanceTreeToImmobile'),
          getField('sidewalkWidth'),
          getField('areaAeration'),
          getField('widthCentral'),
          getField('trafficSignageItems'),
          getField('selectedWebs'),
          getField('selectedTypeCovering'),
          getField('selectedSpacingCovering'),
          getField('selectedAdvanceCovering'),
          getField('selectedOutcrop'),
          getField('selectedWhereOutcrop'),
          getField('selectedVitality'),
          getField('selectedInjury'),
          getField('selectedPruning'),
          getField('selectedShaftInclination'),
          getField('selectedInfection'),
          getField('infestation'),
          getField('imageURL'),
        ]);
      } else {
        rows.add([
          point.name,
          point.coordinates.latitude.toString(),
          point.coordinates.longitude.toString(),
          point.city,
          '',
          '',
          '',
          '',
          '',
          '',
          '',
          '',
          '',
          '',
          '',
          '',
          '',
          '',
          '',
          '',
          '',
          '',
          '',
          '',
          '',
          '',
          '',
          '',
          '',
          '',
          '',
          '',
          '',
          '',
          '',
        ]);
      }
    }

    final Directory? downloadsDirectory = await getExternalStorageDirectory();
    final String directoryPath = '${downloadsDirectory?.path}/planilha';
    await Directory(directoryPath).create(recursive: true);
    final String filePath =
        '${downloadsDirectory?.path}/planilha/$cityName.csv';
    final File file = File(filePath);
    file.writeAsString(const ListToCsvConverter().convert(rows),
        mode: FileMode.write, encoding: utf8);

    Fluttertoast.showToast(
      msg: 'CSV salvo com sucesso!',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 2,
      backgroundColor: Colors.green,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  } catch (e) {
    print(e);
    Fluttertoast.showToast(
      msg: 'Erro ao salvar CSV: $e',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 2,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }
}
