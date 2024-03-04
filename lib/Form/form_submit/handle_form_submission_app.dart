import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../utils/point_info.dart';

Future<void> handleFormSubmissionApp(
  PointInfo pointInfo,
  String nameCommon,
  String cap,
  String dap,
  String height,
  String selectedVitality,
  String selectedInjury,
  String selectedInfection,
  String infestation, {
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
          .collection('additional_info_app')
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
          'selectedVitality': selectedVitality,
          'selectedInjury': selectedInjury,
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
        await FirebaseFirestore.instance.collection('additional_info_app').add({
          'point_id': pointInfo.name,
          'nameCommon': nameCommon,
          'cap': cap,
          'dap': dap,
          'height': height,
          'city': cityDoc['cidade'],
          'selectedVitality': selectedVitality,
          'selectedInjury': selectedInjury,
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
    return 0.0; 
  }
 
  num dapSquareSum = pow(double.parse(dap), 2);

  dapSquareSum += dapValues.fold(0, (sum, dap) {
    if (double.tryParse(dap) != null) {
      return sum + pow(double.parse(dap), 2);
    } else {
      return sum;
    }
  });
 
  double squareRootSum = sqrt(dapSquareSum);

  return squareRootSum;
}
