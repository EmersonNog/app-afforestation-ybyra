// Importe os pacotes necessários
// ignore_for_file: library_private_types_in_public_api, avoid_print, use_build_context_synchronously

import 'dart:convert'; 
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../utils/city_dropdown.dart';
import '../utils/scaffold_mensage.dart'; 

class AddCityScreen extends StatefulWidget {
  const AddCityScreen({super.key});

  @override
  _AddCityScreenState createState() => _AddCityScreenState();
}

class _AddCityScreenState extends State<AddCityScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<String>? states;
  String? selectedState;
  String? selectedCity;
  TextEditingController newCityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchStatesFromIBGE();
  }

  Future<List<String>> _fetchStatesFromIBGE() async {
    try {
      final response = await http.get(Uri.parse(
          'https://servicodados.ibge.gov.br/api/v1/localidades/estados'));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        List<String> states =
            data.map((item) => item['sigla'] as String).toList();
        return states;
      } else {
        throw Exception('Failed to load states from IBGE API');
      }
    } catch (e) {
      print('Error fetching states from IBGE API: $e');
      throw Exception('Failed to load states from IBGE API');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(6, 31, 73, 1),
        elevation: 2,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back),
          style: const ButtonStyle(
            iconColor: MaterialStatePropertyAll(Colors.white),
          ),
        ),
        title: const Text(
          'Adicionar Cidades',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset('assets/images/city.json', width: 500, height: 200),
            Padding(
              padding: const EdgeInsets.only(left: 40.0, right: 40.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  FutureBuilder<List<String>>(
                    future: _fetchStatesFromIBGE(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.blue),
                          strokeWidth: 3,
                        );
                      } else if (snapshot.hasError) {
                        return const Text('Erro ao buscar estados');
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Text('Sem estados disponíveis');
                      } else {
                        states = snapshot.data;
                        return DropdownButtonFormField<String>(
                          value: selectedState,
                          items: states!.map((state) {
                            return DropdownMenuItem<String>(
                              value: state,
                              child: Text(state),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedState = value;
                              selectedCity = null;
                            });
                          },
                          decoration: const InputDecoration(
                            labelText: 'Estado',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                          ),
                        );
                      }
                    },
                  ),
                  SizedBox(
                    height: 80,
                    child: CityDropdown(
                      selectedState: selectedState,
                      onCitySelected: (value) {
                        setState(() {
                          selectedCity = value;
                        });
                      },
                    ),
                  ),
                  FloatingActionButton(
                    backgroundColor: const Color.fromARGB(255, 20, 67, 148),
                    onPressed: () {
                      if (selectedState != null && selectedCity != null) {
                        _saveDataToFirestore(selectedState!, selectedCity!);
                      } else {
                        CustomSnackBar.show(
                          context: context,
                          message: 'Não foi possível salvar os dados!',
                          backgroundColor: Colors.red,
                          duration: const Duration(seconds: 2),
                        );
                      }
                    },
                    child: const Icon(Icons.add, color: Colors.white),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveDataToFirestore(String state, String city) async {
    try {
      // Verificar se a cidade já existe na coleção 'cities'
      QuerySnapshot querySnapshot = await _firestore
          .collection('cities')
          .where('state', isEqualTo: state)
          .where('city', isEqualTo: city)
          .get();

      if (querySnapshot.docs.isEmpty) {
        // A cidade não existe, então posso adicioná-la
        await _firestore.collection('cities').add({
          'state': state,
          'city': city,
          'timestamp': FieldValue.serverTimestamp(),
        });

        CustomSnackBar.show(
          context: context,
          message: '$city - $state, salvo com sucesso.',
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        );
      } else {
        CustomSnackBar.show(
          context: context,
          message: '$city - $state, já está cadastrada.',
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      print('Error saving data to Firestore: $e');
    }
  }
}
