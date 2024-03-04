// ignore_for_file: library_private_types_in_public_api, avoid_print

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CityDropdown extends StatefulWidget {
  final String? selectedState;
  final ValueChanged<String>? onCitySelected;

  const CityDropdown({
    Key? key,
    required this.selectedState,
    required this.onCitySelected,
  }) : super(key: key);

  @override
  _CityDropdownState createState() => _CityDropdownState();
}

class _CityDropdownState extends State<CityDropdown> {
  late Future<List<String>> _citiesFuture;

  @override
  void initState() {
    super.initState();
    _citiesFuture = _fetchCitiesFromIBGE(widget.selectedState ?? "");
  }

  @override
  void didUpdateWidget(covariant CityDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedState != oldWidget.selectedState) {
      _citiesFuture = _fetchCitiesFromIBGE(widget.selectedState ?? "");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: FutureBuilder<List<String>>(
            future: _citiesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                    strokeWidth: 3,
                  ),
                );
              } else if (snapshot.hasError) {
                return _buildErrorMessage('Ops! Algo deu errado');
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Align(
                    alignment: Alignment.topCenter,
                    child: _buildErrorMessage('Selecione um estado'));
              } else {
                List<String> ibgeCities = snapshot.data!;
                return DropdownButtonFormField<String>(
                  items: ibgeCities.map((city) {
                    return DropdownMenuItem<String>(
                      value: city,
                      child: Text(city, style: const TextStyle(fontSize: 13)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    widget.onCitySelected?.call(value!);
                  },
                  decoration: const InputDecoration(
                    labelText: 'Selecione a Cidade',
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                );
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildErrorMessage(String message) {
    return Text(
      message,
      style: const TextStyle(color: Colors.red),
    );
  }

  Future<List<String>> _fetchCitiesFromIBGE(String state) async {
    try {
      final response = await http.get(Uri.parse(
          'https://servicodados.ibge.gov.br/api/v1/localidades/estados/$state/municipios'));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        List<String> cities =
            data.map((item) => item['nome'] as String).toList();
        return cities;
      } else {
        throw Exception('Failed to load cities from IBGE API');
      }
    } catch (e) {
      print('Error fetching cities from IBGE API: $e');
      throw Exception('Failed to load cities from IBGE API');
    }
  }
}
