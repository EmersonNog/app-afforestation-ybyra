// ignore_for_file: avoid_print, avoid_function_literals_in_foreach_calls, use_build_context_synchronously, library_private_types_in_public_api, unused_field
import 'package:arborizacao/pages/charts_page.dart';
import 'package:arborizacao/kml_exporter/kml_structure.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:lottie/lottie.dart';
import 'package:page_animation_transition/animations/fade_animation_transition.dart';
import 'package:page_animation_transition/page_animation_transition.dart';
import 'package:url_launcher/url_launcher.dart';
import '../csv_exporter/csv_export.dart';
import '../kml_exporter/kml_export.dart';
import '../utils/point_filter.dart';
import '../utils/point_info.dart';
import 'point_details_page.dart';

class CityDetailsScreen extends StatefulWidget {
  final String selectedCity;

  const CityDetailsScreen({Key? key, required this.selectedCity})
      : super(key: key);

  @override
  _CityDetailsScreenState createState() => _CityDetailsScreenState();
}

class _CityDetailsScreenState extends State<CityDetailsScreen> {
  late Future<List<PointInfo>> _pointsFuture;
  int _pointsCount = 0;
  String _selectedCategory = 'Categoria';
  String _selectedTeam = 'Equipe';
  late List<String> _teamNames;

  @override
  void initState() {
    super.initState();
    _pointsFuture = _fetchPoints(widget.selectedCity);
    _teamNames = [];
    _fetchTeamNames();
  }

  Future<void> _fetchTeamNames() async {
    try {
      // Consulta Firestore para obter os nomes das equipes
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('team').get();

      setState(() {
        _teamNames = querySnapshot.docs
            .map((DocumentSnapshot document) => document['teamName'] as String)
            .toList();
      });
    } catch (e) {
      print('Erro ao buscar nomes das equipes: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back),
          style: const ButtonStyle(
            iconColor: MaterialStatePropertyAll(Colors.white),
          ),
        ),
        title: FutureBuilder(
          future: _pointsFuture,
          builder: (context, AsyncSnapshot<List<PointInfo>> snapshot) {
            return Text(
              '${widget.selectedCity} - (${snapshot.data?.length ?? 0})',
              style: const TextStyle(fontSize: 17, color: Colors.white),
            );
          },
        ),
        backgroundColor: const Color.fromRGBO(6, 31, 73, 1),
        actions: [
          IconButton(
            icon: const Icon(Icons.polyline_outlined, color: Colors.white),
            onPressed: () async {
              List<PointInfo> cityPoints = await _pointsFuture;
              _exportCityPointsToKML(widget.selectedCity, cityPoints);
            },
          ),
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.fileCsv, color: Colors.white),
            onPressed: () async {
              List<PointInfo> cityPoints = await _pointsFuture;
              _exportCityPointsToCSV(widget.selectedCity, cityPoints);
            },
          ),
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.chartPie, color: Colors.white),
            onPressed: () {
              Navigator.of(context).push(PageAnimationTransition(
                  page: PieChartScreen(selectedCity: widget.selectedCity),
                  pageAnimationType: FadeAnimationTransition()));
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.only(left: 15, right: 15),
              decoration: const BoxDecoration(
                  border: BorderDirectional(
                    bottom: BorderSide(color: Colors.black),
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                  color: Colors.white54),
              height: MediaQuery.of(context).size.height * 0.12,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    const Text(
                      "FILTRO",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        buildDropdown(
                          label: "Equipe",
                          value: _selectedTeam,
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedTeam = newValue!;
                            });
                            _fetchAndSetPoints(widget.selectedCity);
                          },
                          items: [
                            'Equipe',
                            ..._teamNames,
                            'Todas',
                          ],
                        ),
                        const SizedBox(width: 10),
                        buildDropdown(
                          label: "Categoria",
                          value: _selectedCategory,
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedCategory = newValue!;
                            });
                            _fetchAndSetPoints(widget.selectedCity);
                          },
                          items: ['Categoria', 'App', 'Geral', 'Todas'],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (_selectedCategory.isNotEmpty)
              Expanded(
                child: FutureBuilder(
                  future: _pointsFuture,
                  builder: (context, AsyncSnapshot<List<PointInfo>> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text('Error: ${snapshot.error}'),
                      );
                    } else {
                      List<PointInfo> points = snapshot.data!;
                      points.sort((a, b) => b.createdAt.compareTo(a.createdAt));

                      if (points.isEmpty) {
                        return Center(
                          child: Lottie.asset(
                            'assets/images/not_found_point.json',
                            width: 300,
                            height: 300,
                          ),
                        );
                      }

                      return Container(
                        color: Colors.grey[200],
                        child: ListView.separated(
                          padding: const EdgeInsets.all(16.0),
                          separatorBuilder: (context, index) => const Divider(),
                          itemCount: points.length,
                          itemBuilder: (context, index) {
                            final PointInfo point = points[index];

                            return Dismissible(
                              key: Key(point.name),
                              background: Container(
                                color: Colors.red,
                                child: const Align(
                                  alignment: Alignment.centerRight,
                                  child: Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Icon(
                                      Icons.delete,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              onDismissed: (direction) {
                                setState(() {
                                  points.removeAt(index);
                                });
                                _deletePointAndInfo(point);
                              },
                              confirmDismiss:
                                  (DismissDirection direction) async {
                                return await showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text("Confirmar Exclusão"),
                                      content: const Text(
                                          "Tem certeza de que deseja excluir este ponto?"),
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
                              },
                              child: Card(
                                color: Colors.white,
                                elevation: 7.0,
                                child: ListTile(
                                  contentPadding: const EdgeInsets.all(5.0),
                                  leading: const Padding(
                                    padding: EdgeInsets.only(left: 10.0),
                                    child: Icon(Icons.location_on,
                                        color: Colors.green),
                                  ),
                                  title: Text(
                                    '${point.teamName} - ${points.length - index < 10 ? '0' : ''}${points.length - index}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16.0,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        DateFormat('dd/MM/yy - HH:mm:ss')
                                            .format(point.createdAt),
                                      ),
                                    ],
                                  ),
                                  trailing: IconButton(
                                      onPressed: () {
                                        _launchGoogleMaps(point);
                                      },
                                      icon: const FaIcon(
                                        FontAwesomeIcons.earthAmericas,
                                        color: Colors.blue, 
                                      )),
                                  onTap: () {
                                    _handlePointSelection(context, point);
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    }
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchGoogleMaps(PointInfo pointInfo) async {
    final double latitude = pointInfo.coordinates.latitude;
    final double longitude = pointInfo.coordinates.longitude;

    final Uri googleMapsUri = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude');

    try {
      final bool launchable = await canLaunchUrl(googleMapsUri);
      if (launchable) {
        await launchUrl(googleMapsUri);
      } else {
        print('Could not launch Google Maps. Opening in browser.');
        await launchUrl(googleMapsUri);
      }
    } catch (e) {
      print('Error launching Google Maps: $e');
    }
  }

  Future<void> _fetchAndSetPoints(String city) async {
    try {
      List<PointInfo> points = await PointFilter.fetchAndSetPoints(
          city, _selectedCategory, _selectedTeam);

      setState(() {
        _pointsFuture = Future.value(points);
      });
    } catch (e) {
      print('Error fetching points: $e');
      rethrow;
    }
  }

  Widget buildDropdown({
    required String label,
    required String value,
    required Function(String?) onChanged,
    required List<String> items,
  }) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.4,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.black,
          width: 1,
        ),
      ),
      child: DropdownButton<String>(
        value: value,
        iconSize: 24,
        elevation: 16,
        style: const TextStyle(color: Colors.black, fontSize: 16),
        underline: Container(height: 0),
        onChanged: onChanged,
        items: items.map<DropdownMenuItem<String>>((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Text(
                item,
                style: TextStyle(
                  color: item == label ? Colors.grey : Colors.black,
                  fontSize: 16,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Future<void> _deletePointAndInfo(PointInfo pointInfo) async {
    try {
      bool deletionResult = await _deletePointFromFirestore(pointInfo);

      if (deletionResult) {
        await _deleteAdditionalInfo(pointInfo);

        // Atualizar o _pointsCount utilizando o tamanho atual da lista de pontos
        List<PointInfo> points = await _pointsFuture;
        setState(() {
          _pointsCount = points.length;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao excluir ponto. Tente novamente.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Erro durante a exclusão: $e');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro durante a exclusão: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteAdditionalInfo(PointInfo pointInfo) async {
    try {
      // Determine the collection name based on the category
      String collectionName = pointInfo.category == 'App'
          ? 'additional_info_app'
          : 'additional_info';

      // Query Firestore to get documents in the specified collection
      await FirebaseFirestore.instance
          .collection(collectionName)
          .where('point_id', isEqualTo: pointInfo.name)
          .get()
          .then((querySnapshot) {
        querySnapshot.docs.forEach((doc) async {
          // Delete each document in the specified collection
          await doc.reference.delete();
        });
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting additional info: $e');
      }
    }
  }

  Future<bool> _deletePointFromFirestore(PointInfo pointInfo) async {
    try {
      await FirebaseFirestore.instance
          .collection('pontos')
          .where('nome', isEqualTo: pointInfo.name)
          .get()
          .then((querySnapshot) {
        querySnapshot.docs.forEach((doc) async {
          await doc.reference.delete();
        });
      });

      Fluttertoast.showToast(
        msg: 'Ponto excluído com sucesso!',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 2,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0,
      );

      return true; // Indicate success
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Erro ao excluir ponto: $e',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 2,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );

      return false;
    }
  }

  void _exportCityPointsToCSV(String city, List<PointInfo> cityPoints) async {
    await exportCityPointsToCSV(cityPoints, city);
  }

  void _exportCityPointsToKML(String city, List<PointInfo> cityPoints) async {
    final kmlContent = KMLStructure.generateKML(cityPoints);
    await exportCityPointsToKML(kmlContent, city);
  }

  Future<List<PointInfo>> _fetchPoints(String city) async {
    try {
      QuerySnapshot querySnapshot;

      if (_selectedCategory.isNotEmpty) {
        querySnapshot = await FirebaseFirestore.instance
            .collection('pontos')
            .where('cidade', isEqualTo: city)
            .where('categoria', isEqualTo: _selectedCategory)
            .orderBy('createdAt', descending: true)
            .get();
      } else {
        querySnapshot = await FirebaseFirestore.instance
            .collection('pontos')
            .where('cidade', isEqualTo: city)
            .orderBy('createdAt', descending: true)
            .get();
      }

      return querySnapshot.docs.map((DocumentSnapshot document) {
        Map<String, dynamic> data = document.data() as Map<String, dynamic>;

        setState(() {
          _pointsCount = querySnapshot.size;
        });

        String name = data['nome'];
        double latitude = (data['latitude'] as num).toDouble();
        double longitude = (data['longitude'] as num).toDouble();
        String category = data['categoria'];
        DateTime createdAt =
            (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();

        return PointInfo(name, LatLng(latitude, longitude),
            city: city, category: category, createdAt: createdAt);
      }).toList();
    } catch (e) {
      print('Error fetching points: $e');
      rethrow;
    }
  }

  void _handlePointSelection(BuildContext context, PointInfo selectedPoint) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PointDetailsScreen(pointInfo: selectedPoint),
      ),
    );
  }
}
