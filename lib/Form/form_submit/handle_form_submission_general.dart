// ignore_for_file: avoid_types_as_parameter_names

import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../utils/point_info.dart';

Future<void> handleFormSubmission(
  PointInfo pointInfo,
  String nameCommon,
  String cap,
  String dap,
  String height,
  String selectedLocation,
  String alturaBifurcacao,
  String distanceTreePrevious,
  String distanceTreeNext,
  String distanceTreeToHalfWire,
  String distanceTreeToPost,
  String distanceTreeToImmobile,
  List<String> selectedTrafficSignageItems,
  String selectedWebs,
  String selectedTypeCovering,
  String selectedSpacingCovering,
  String selectedAdvanceCovering,
  String selectedOutcrop,
  String selectedWhereOutcrop,
  String selectedVitality,
  String selectedInjury,
  String selectedPruning,
  String selectedShaftInclination,
  String selectedInfection,
  String infestation,
  String sidewalkWidth,
  String areaAeration,
  String widthCentral, {
  String? imageURL,
  required List<String> additionalCapValues,
  List<String>? dapValues,
}) async {
  try {
    double dapRoot = calculateDapRoot(dapValues, dap);

    QuerySnapshot<Object?> querySnapshotPoint = await FirebaseFirestore.instance
        .collection('pontos')
        .where('nome', isEqualTo: pointInfo.name)
        .get();

    if (querySnapshotPoint.docs.isNotEmpty) {
      DocumentSnapshot cityDoc = querySnapshotPoint.docs.first;

      QuerySnapshot<Object?> querySnapshot = await FirebaseFirestore.instance
          .collection('additional_info')
          .where('point_id', isEqualTo: pointInfo.name)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        DocumentSnapshot doc = querySnapshot.docs.first;
        await doc.reference.update({
          'nameCommon': nameCommon,
          'cap': cap,
          'dap': dap,
          'height': height,
          'city': cityDoc['cidade'],
          'location': selectedLocation,
          'heightBifurcation': alturaBifurcacao,
          'distanceTreePrevious': distanceTreePrevious,
          'distanceTreeNext': distanceTreeNext,
          'distanceTreeToHalfWire': distanceTreeToHalfWire,
          'distanceTreeToPost': distanceTreeToPost,
          'distanceTreeToImmobile': distanceTreeToImmobile,
          'sidewalkWidth': sidewalkWidth,
          'areaAeration': areaAeration,
          'widthCentral': widthCentral,
          'trafficSignageItems': selectedTrafficSignageItems,
          'selectedWebs': selectedWebs,
          'selectedTypeCovering': selectedTypeCovering,
          'selectedSpacingCovering': selectedSpacingCovering,
          'selectedAdvanceCovering': selectedAdvanceCovering,
          'selectedOutcrop': selectedOutcrop,
          'selectedWhereOutcrop': selectedWhereOutcrop,
          'selectedVitality': selectedVitality,
          'selectedInjury': selectedInjury,
          'selectedPruning': selectedPruning,
          'selectedShaftInclination': selectedShaftInclination,
          'selectedInfection': selectedInfection,
          'infestation': infestation,
          'additionalCapValues': additionalCapValues,
          'additionalDapValues': dapValues,
          'dapRoot': dapRoot.toStringAsFixed(2),
          'imageURL': imageURL,
          'timestamp': FieldValue.serverTimestamp(),
        });
      } else {
        // If no data exists, create a new document
        await FirebaseFirestore.instance.collection('additional_info').add({
          'point_id': pointInfo.name,
          'nameCommon': nameCommon,
          'cap': cap,
          'dap': dap,
          'height': height,
          'city': cityDoc['cidade'],
          'location': selectedLocation,
          'heightBifurcation': alturaBifurcacao,
          'distanceTreePrevious': distanceTreePrevious,
          'distanceTreeNext': distanceTreeNext,
          'distanceTreeToHalfWire': distanceTreeToHalfWire,
          'distanceTreeToPost': distanceTreeToPost,
          'distanceTreeToImmobile': distanceTreeToImmobile,
          'sidewalkWidth': sidewalkWidth,
          'areaAeration': areaAeration,
          'widthCentral': widthCentral,
          'trafficSignageItems': selectedTrafficSignageItems,
          'selectedWebs': selectedWebs,
          'selectedTypeCovering': selectedTypeCovering,
          'selectedSpacingCovering': selectedSpacingCovering,
          'selectedAdvanceCovering': selectedAdvanceCovering,
          'selectedOutcrop': selectedOutcrop,
          'selectedWhereOutcrop': selectedWhereOutcrop,
          'selectedVitality': selectedVitality,
          'selectedInjury': selectedInjury,
          'selectedPruning': selectedPruning,
          'selectedShaftInclination': selectedShaftInclination,
          'selectedInfection': selectedInfection,
          'infestation': infestation,
          'additionalCapValues': additionalCapValues,
          'additionalDapValues': dapValues,
          'dapRoot': dapRoot.toStringAsFixed(2),
          'imageURL': imageURL,
          'timestamp': FieldValue.serverTimestamp(),
        });
      }
      if (await Connectivity().checkConnectivity() != ConnectivityResult.none) {
        Fluttertoast.showToast(
          msg: 'Formulário enviado com sucesso',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      } else {
        Fluttertoast.showToast(
          msg:
              'Os dados foram armazenados localmente e serão enviados quando estiver online.',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.orange,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    }
  } catch (e) {
    if (kDebugMode) {
      print('Error handling form submission: $e');
    }
    Fluttertoast.showToast(
      msg: 'Erro ao enviar o formulário. Por favor, tente novamente.',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }
}

double calculateDapRoot(List<String>? dapValues, String dap) {
  if (dapValues == null || dapValues.isEmpty) {
    return 0.0; // Retorna 0 se a lista for nula ou vazia
  }

  // Adicione o quadrado do 'dap' diretamente ao somatório
  num dapSquareSum = pow(double.parse(dap), 2);

  dapSquareSum += dapValues.fold(0, (sum, dap) {
    if (double.tryParse(dap) != null) {
      return sum + pow(double.parse(dap), 2);
    } else {
      return sum;
    }
  });

  // Calcula a raiz quadrada da soma dos quadrados
  double squareRootSum = sqrt(dapSquareSum);

  return squareRootSum;
}
