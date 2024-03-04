// ignore_for_file: library_private_types_in_public_api, avoid_print

import 'package:arborizacao/pages/add_city_page.dart';
import 'package:arborizacao/pages/city_details_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:page_animation_transition/animations/fade_animation_transition.dart';
import 'package:page_animation_transition/page_animation_transition.dart';

class CityListScreen extends StatefulWidget {
  const CityListScreen({Key? key}) : super(key: key);

  @override
  _CityListScreenState createState() => _CityListScreenState();
}

class _CityListScreenState extends State<CityListScreen> {
  List<String> cities = [
    "Fortaleza",
    "Ipueiras",
    "Irauçuba",
    "Juazeiro do Norte",
    "Tauá",
  ];

  final TextEditingController _searchController = TextEditingController();
  bool _isSearchVisible = false;
  late QuerySnapshot querySnapshot;

  @override
  void initState() {
    super.initState();
    _fetchCitiesFromFirebase();
  }

  Future<void> _fetchCitiesFromFirebase() async {
    try {
      querySnapshot =
          await FirebaseFirestore.instance.collection('cities').get();

      List<String> fetchedCities =
          querySnapshot.docs.map((DocumentSnapshot document) {
        return document['city'] as String;
      }).toList();

      setState(() {
        cities = [
          "Fortaleza",
          "Ipueiras",
          "Irauçuba",
          "Juazeiro do Norte",
          "Tauá",
          ...fetchedCities
        ];
      });
    } catch (e) {
      print('Error fetching cities from Firestore: $e');
    }
  }

  void _filterCities(String query) {
    setState(() {
      if (query.isNotEmpty) {
        List<String> filteredCities = cities
            .where((city) => city.toLowerCase().contains(query.toLowerCase()))
            .toList();
        cities = filteredCities;
      } else {
        cities = [
          "Fortaleza",
          "Ipueiras",
          "Irauçuba",
          "Juazeiro do Norte",
          "Tauá",
          ...querySnapshot.docs
              .map((document) => document['city'] as String)
              .toList()
        ];
      }
    });
  }

  Widget _buildSearchField() {
    double screenWidth = MediaQuery.of(context).size.width;
    double searchFieldWidth = screenWidth * 0.71;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        width: searchFieldWidth,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: const Color.fromARGB(189, 255, 255, 255),
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (value) {
            _filterCities(value);
          },
          decoration: const InputDecoration(
            hintText: 'Pesquisar cidade...',
            border: InputBorder.none,
            contentPadding:
                EdgeInsets.symmetric(horizontal: 15, vertical: 10.5),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(6, 31, 73, 1),
        elevation: 2,
        title: const Text(
          'Explore as Cidades',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back),
          style: const ButtonStyle(
            iconColor: MaterialStatePropertyAll(Colors.white),
          ),
        ),
        actions: [
          if (_isSearchVisible) _buildSearchField(),
          IconButton(
            icon: Icon(_isSearchVisible ? Icons.close_sharp : Icons.search,
                color: Colors.white),
            onPressed: () {
              setState(() {
                _isSearchVisible = !_isSearchVisible;
                if (!_isSearchVisible) {
                  _searchController.clear();
                  _filterCities('');
                }
              });
            },
          ),
        ],
      ),
      body: Container(
        color: Colors.grey[200],
        child: _isSearchVisible && _searchController.text.isEmpty
            ? Center(
                child: Lottie.asset('assets/images/search.json',
                    width: 220, height: 220),
              )
            : ListView.builder(
                itemCount: cities.length,
                itemBuilder: (context, index) {
                  return Dismissible(
                    key: Key(cities[index]),
                    onDismissed: (direction) {
                      String removedCity = cities[index];
                      setState(() {
                        cities.removeAt(index);
                      });
                      _deleteCityFromFirebase(removedCity);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('$removedCity excluída com sucesso!'),
                          backgroundColor: Colors.red,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    confirmDismiss: (DismissDirection direction) async {
                      String cityToDelete = cities[index];
                      // Check if the city is allowed to be deleted
                      if (allowedToDeleteCity(cityToDelete)) {
                        return await showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text("Confirmar Exclusão"),
                              content: Text(
                                  "Tem certeza de que deseja excluir $cityToDelete?"),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(true),
                                  child: const Text("Sim"),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(false),
                                  child: const Text("Não"),
                                ),
                              ],
                            );
                          },
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content:
                                Text('$cityToDelete não pode ser excluída!'),
                            backgroundColor: Colors.red,
                            duration: const Duration(seconds: 3),
                          ),
                        );
                        return false; // Do not allow dismissal
                      }
                    },
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 16.0),
                      child: const Icon(
                        Icons.delete,
                        color: Colors.white,
                      ),
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          tileColor: Colors.white,
                          title: Text(
                            cities[index],
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          trailing: const Icon(Icons.arrow_forward),
                          onTap: () {
                            _handleCitySelection(context, cities[index]);
                          },
                        ),
                        const Divider(
                          height: 1,
                          color: Colors.grey,
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        elevation: 15,
        backgroundColor: const Color.fromARGB(255, 12, 56, 132),
        onPressed: () {
          Navigator.of(context).push(PageAnimationTransition(
              page: const AddCityScreen(),
              pageAnimationType: FadeAnimationTransition()));
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  bool allowedToDeleteCity(String city) {
    List<String> citiesNotAllowedToDelete = [
      "Fortaleza",
      "Ipueiras",
      "Irauçuba",
      "Juazeiro do Norte",
      "Tauá",
    ];

    return !citiesNotAllowedToDelete.contains(city);
  }

  void _deleteCityFromFirebase(String cityName) async {
    try {
      // Step 1: Delete associated points
      await _deletePointsForCity(cityName);

      // Step 2: Delete the city
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('cities').get();

      for (var doc in querySnapshot.docs) {
        if (doc['city'] == cityName) {
          if (kDebugMode) {
            print('Deleting document with ID: ${doc.id}');
          }
          await FirebaseFirestore.instance
              .collection('cities')
              .doc(doc.id)
              .delete();
        }
      }

      setState(() {
        cities.remove(cityName);
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting city and points from Firestore: $e');
      }
    }
  }

  Future<void> _deletePointsForCity(String cityName) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('pontos')
          .where('cidade', isEqualTo: cityName)
          .get();

      for (var doc in querySnapshot.docs) {
        if (kDebugMode) {
          print('Deletando ponto com o ID: ${doc.id}');
        }
        await FirebaseFirestore.instance
            .collection('pontos')
            .doc(doc.id)
            .delete();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting points for city from Firestore: $e');
      }
    }
  }

  void _handleCitySelection(BuildContext context, String selectedCity) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CityDetailsScreen(selectedCity: selectedCity),
      ),
    );
  }
}
