// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api, avoid_function_literals_in_foreach_calls, avoid_print
import 'dart:async';
import 'package:arborizacao/pages/city_list_page.dart';
import 'package:arborizacao/pages/home.dart';
import 'package:arborizacao/pages/point_details_page.dart';
import 'package:arborizacao/utils/scaffold_mensage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:page_animation_transition/animations/fade_animation_transition.dart';
import 'package:page_animation_transition/page_animation_transition.dart';
import 'package:uuid/uuid.dart';
import '../utils/layer_dropdown_item.dart';
import '../utils/point_info.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  List<PointInfo> points = [];
  bool isLocatingUser = false;
  bool isMapReady = false;
  late MapController mapController;
  int pointCounter = 1;
  TileLayerType selectedTileLayer = TileLayerType.streetMap;
  List<String> cities = [
    'Fortaleza',
    'Ipueiras',
    'Irauçuba',
    'Juazeiro do Norte',
    'Tauá'
  ];
  TextEditingController newCityController = TextEditingController();
  StreamController<String> pointCodeStreamController =
      StreamController<String>.broadcast();

  Map<Color, String> colorLabels = {
    Colors.red: 'N/A',
    Colors.green: 'Nativa',
    Colors.purple: 'Exótica',
  };

  String selectedCategory = 'Selecione';
  List<String> teams = [];

  @override
  void dispose() {
    pointCodeStreamController.close();
    super.dispose();
  }

  List<PopupMenuEntry<LayerDropdownItem>> get layerOptions {
    return [
      PopupMenuItem<LayerDropdownItem>(
        value: LayerDropdownItem(
          type: TileLayerType.streetMap,
          label: 'Street Map',
          icon: Icons.map,
        ),
        child: Row(
          children: [
            Icon(Icons.map, color: Colors.green[300]),
            const SizedBox(width: 8),
            const Text('Street Map'),
          ],
        ),
      ),
      PopupMenuItem<LayerDropdownItem>(
        value: LayerDropdownItem(
          type: TileLayerType.satellite,
          label: 'Satélite',
          icon: Icons.satellite_alt,
        ),
        child: Row(
          children: [
            Icon(Icons.satellite_alt, color: Colors.grey[500]),
            const SizedBox(width: 8),
            const Text('Satélite'),
          ],
        ),
      ),
    ];
  }

  @override
  void initState() {
    super.initState();
    mapController = MapController();
    _initMap();
  }

  Future<void> _initMap() async {
    await _loadPointsFromFirestore();
    await _fetchTeamsFromFirestore();
    setState(() {
      isMapReady = true;
    });

    _getCurrentLocation();

    FirebaseFirestore.instance
        .collection('pontos')
        .snapshots()
        .listen((querySnapshot) {
      _updateMapWithFirestoreData(querySnapshot);
    });
  }

  Future<void> _fetchTeamsFromFirestore() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('team').get();

      setState(() {
        teams = querySnapshot.docs
            .map((DocumentSnapshot document) => document['teamName'] as String)
            .toList();
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching teams from Firestore: $e');
      }
    }
  }

  Future<void> _loadPointsFromFirestore() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('pontos').get();

      _updateMapWithFirestoreData(querySnapshot);
    } catch (e) {
      if (kDebugMode) {
        print('Error loading points from Firestore: $e');
      }
    }
  }

  Future<void> _updateMapWithFirestoreData(QuerySnapshot querySnapshot) async {
    List<PointInfo> loadedPoints =
        querySnapshot.docs.map((DocumentSnapshot document) {
      Map<String, dynamic> data = document.data() as Map<String, dynamic>;

      String name = data['nome'];
      double latitude = data['latitude'];
      double longitude = data['longitude'];
      String city = data['cidade'];
      int colorValue = data['cor'] ?? Colors.black.value;
      String colorLabel = data['especie'] ?? 'Desconhecida';
      DateTime createdAt =
          (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();

      return PointInfo(name, LatLng(latitude, longitude),
          city: city,
          color: Color(colorValue),
          species: colorLabel,
          teamName: data['equipe'] ?? 'N/A',
          category: data['categoria'] ?? 'N/A',
          createdAt: createdAt);
    }).toList();

    setState(() {
      points = loadedPoints;
      pointCounter = points.length + 1;
    });
  }

  Future<void> _getCurrentLocation() async {
    try {
      setState(() {
        isLocatingUser = true;
      });

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );

      mapController.move(
        LatLng(position.latitude, position.longitude),
        13.0,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao obter a localização do usuário: $e');
      }
    } finally {
      setState(() {
        isLocatingUser = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        children: [
          _buildMap(),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            backgroundColor: Colors.white,
            elevation: 10,
            onPressed: () {
              Navigator.of(context).push(
                PageAnimationTransition(
                  page: const CityListScreen(),
                  pageAnimationType: FadeAnimationTransition(),
                ),
              );
            },
            child: const Icon(
              Icons.arrow_forward_rounded,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            backgroundColor: Colors.white,
            elevation: 10,
            onPressed: () {
              _handleTap();
            },
            child: const Icon(
              Icons.add_location_alt,
              color: Colors.black,
            ),
          ),
        ],
      ),
      bottomNavigationBar:
          isLocatingUser ? const LinearProgressIndicator() : null,
      backgroundColor: Colors.white,
      extendBody: true,
    );
  }

  Widget buildUserLocation() {
    return CurrentLocationLayer(
      alignPositionOnUpdate: AlignOnUpdate.always,
    );
  }

  Widget _buildMap() {
    String tileLayerUrl = '';
    String streetMapTileLayerUrl = '';
    switch (selectedTileLayer) {
      case TileLayerType.streetMap:
        tileLayerUrl = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
        break;
      case TileLayerType.satellite:
        tileLayerUrl =
            'https://api.maptiler.com/tiles/satellite-v2/{z}/{x}/{y}.jpg?key=V50u1wqC84pKH6SHziIY';
        break;

      default:
        tileLayerUrl = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
    }
    return Expanded(
      child: FlutterMap(
        mapController: mapController,
        options: MapOptions(
          initialZoom: 18.0,
          initialCenter: const LatLng(-5.073282, -42.800215),
          onPositionChanged: (MapPosition position, bool hasGesture) {
            if (!isMapReady) {
              _initMap();
            }
          },
        ),
        children: [
          TileLayer(
            urlTemplate: tileLayerUrl,
          ),
          TileLayer(
            urlTemplate: streetMapTileLayerUrl,
          ),
          buildUserLocation(),
          Padding(
            padding: const EdgeInsets.only(top: 70, left: 20),
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).push(PageAnimationTransition(
                  page: const Home(),
                  pageAnimationType: FadeAnimationTransition(),
                ));
              },
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: const [
                    BoxShadow(
                      color: Color.fromARGB(121, 0, 0, 0),
                      blurRadius: 20,
                    )
                  ],
                ),
                child: const Center(
                  child: Icon(Icons.arrow_back_rounded, color: Colors.black),
                ),
              ),
            ),
          ),
          MarkerLayer(
            markers: [
              for (var pointInfo in points)
                Marker(
                  point: pointInfo.coordinates,
                  child: GestureDetector(
                    onLongPress: () {
                      _showDeleteConfirmationDialog(pointInfo);
                    },
                    child: IconButton(
                      icon: FaIcon(FontAwesomeIcons.locationDot,
                          color: pointInfo.color, size: 17),
                      color: Colors.red,
                      onPressed: () {
                        _onMarkerTap(pointInfo);
                      },
                    ),
                  ),
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 20.0, left: 15.0),
            child: Container(
              alignment: Alignment.bottomLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: PopupMenuButton<LayerDropdownItem>(
                  icon: const Icon(
                    Icons.layers_outlined,
                    color: Color.fromARGB(255, 0, 0, 0),
                  ),
                  iconSize: 28,
                  itemBuilder: (BuildContext context) => layerOptions,
                  onSelected: (LayerDropdownItem selected) {
                    setState(() {
                      selectedTileLayer = selected.type;
                    });
                  },
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(2.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    child: Text(
                      '© MapTiler ',
                      style: TextStyle(
                          color: selectedTileLayer == TileLayerType.streetMap
                              ? Colors.black
                              : Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w300),
                    ),
                    onTap: () {
                      launchUrl(Uri(
                          scheme: 'https',
                          host: 'www.maptiler.com',
                          path: '/copyright'));
                    },
                  ),
                  GestureDetector(
                    child: Text(
                      '© OpenStreetMap contributors',
                      style: TextStyle(
                          color: selectedTileLayer == TileLayerType.streetMap
                              ? Colors.black
                              : Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w300),
                    ),
                    onTap: () {
                      launchUrl(Uri(
                          scheme: 'https',
                          host: 'www.openstreetmap.org',
                          path: '/copyright'));
                    },
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleTap() {
    _showNameInputDialog();
  }

  void _showNameInputDialog() {
    String id;
    String selectedCity = cities.first;

    Uuid uuid = const Uuid();
    String defaultId = uuid.v4();

    id = defaultId;

    String updatedPointCode = defaultId;

    List<Color> availableColors = [
      Colors.red,
      Colors.green,
      Colors.purple,
    ];

    Color selectedColor = availableColors[0];
    String selectedTeam = teams.isNotEmpty ? teams[0] : 'N/A';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return FutureBuilder<List<String>>(
          future: _fetchCitiesFromFirebase(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                    strokeWidth: 3,
                  ),
                ),
              );
            }

            if (snapshot.hasError) {
              return AlertDialog(
                title: const Text('Error'),
                content: Text('Erro ao carregar as cidades: ${snapshot.error}'),
              );
            }

            List<String> firebaseCities = snapshot.data ?? [];

            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              backgroundColor: Colors.white,
              elevation: 25,
              title: const Text(
                'Adicionar Ponto',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  StatefulBuilder(
                    builder: (BuildContext context, StateSetter setState) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              const Text("Equipe:   "),
                              DropdownButton<String>(
                                value: selectedTeam,
                                onChanged: (String? newValue) {
                                  setState(() {
                                    selectedTeam = newValue!;
                                  });
                                },
                                items: teams.map<DropdownMenuItem<String>>(
                                  (String team) {
                                    return DropdownMenuItem<String>(
                                      value: team,
                                      child: Text(team),
                                    );
                                  },
                                ).toList(),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              const Text("Cidade:    "),
                              DropdownButton<String>(
                                value: selectedCity,
                                onChanged: (String? newValue) {
                                  setState(() {
                                    selectedCity = newValue!;
                                    pointCodeStreamController
                                        .add(updatedPointCode);
                                  });
                                },
                                items: [
                                  ...cities.map<DropdownMenuItem<String>>(
                                    (String city) {
                                      return DropdownMenuItem<String>(
                                        value: city,
                                        child: Text(city),
                                      );
                                    },
                                  ),
                                  ...firebaseCities
                                      .map<DropdownMenuItem<String>>(
                                    (String city) {
                                      return DropdownMenuItem<String>(
                                        value: city,
                                        child: Text(city),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              const Text("Espécie:   "),
                              DropdownButton<Color>(
                                value: selectedColor,
                                onChanged: (Color? newValue) {
                                  setState(() {
                                    selectedColor = newValue!;
                                  });
                                },
                                items: availableColors
                                    .map<DropdownMenuItem<Color>>(
                                  (Color color) {
                                    return DropdownMenuItem<Color>(
                                      value: color,
                                      child: Row(
                                        children: [
                                          Container(
                                            decoration: BoxDecoration(
                                              color: color,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              border: Border.all(
                                                color: color,
                                                width: 1.0,
                                              ),
                                            ),
                                            width: 20,
                                            height: 20,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(colorLabels[color] ?? ''),
                                        ],
                                      ),
                                    );
                                  },
                                ).toList(),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              const Text("Categoria:  "),
                              DropdownButton<String>(
                                value: selectedCategory,
                                onChanged: (String? newValue) {
                                  setState(() {
                                    selectedCategory = newValue!;
                                  });
                                },
                                items: [
                                  'Selecione',
                                  'App',
                                  'Geral',
                                ].map<DropdownMenuItem<String>>(
                                  (String category) {
                                    return DropdownMenuItem<String>(
                                      value: category,
                                      child: Text(
                                        category,
                                        style: TextStyle(
                                          color: category == 'Selecione'
                                              ? Colors.grey
                                              : Colors.black,
                                        ),
                                      ),
                                    );
                                  },
                                ).toList(),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 16,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _addPoint(
                      id,
                      selectedCity,
                      selectedColor,
                      colorLabels[selectedColor] ?? 'Desconhecida',
                      selectedTeam,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(6, 31, 73, 1),
                  ),
                  child: const Text(
                    'Adicionar',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<List<String>> _fetchCitiesFromFirebase() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('cities').get();

      List<String> firebaseCities = querySnapshot.docs
          .map((DocumentSnapshot document) => document['city'] as String)
          .toList();

      return firebaseCities;
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching cities from Firebase: $e');
      }
      return [];
    }
  }

  void _addPoint(String name, String selectedCity, Color selectedColor,
      String colorLabel, String selectedTeam) async {
    bool isPointNameUnique = _isPointNameUnique(name);

    if (!isPointNameUnique) {
      CustomSnackBar.show(
        context: context,
        message: ('Erro: o id "$name" já foi usado!'),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      );
      return;
    }

    if (selectedCategory == 'Selecione') {
      // Exibir um aviso para o usuário
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Categoria não selecionada',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            content: const Text(
              'Por favor, selecione uma categoria para o ponto.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Fechar'),
              ),
            ],
          );
        },
      );
      return;
    }

    Position? position = await Geolocator.getLastKnownPosition();

    if (position != null) {
      DateTime now = DateTime.now();
      PointInfo namedLatLng = PointInfo(
          name.isNotEmpty
              ? name
              : 'P${pointCounter.toString().padLeft(4, '0')}',
          LatLng(position.latitude, position.longitude),
          city: selectedCity,
          color: selectedColor,
          species: colorLabel,
          category: selectedCategory,
          teamName: selectedTeam,
          createdAt: now);

      await FirebaseFirestore.instance.collection('pontos').add({
        'nome': namedLatLng.name,
        'latitude': namedLatLng.coordinates.latitude,
        'longitude': namedLatLng.coordinates.longitude,
        'cidade': namedLatLng.city,
        'cor': namedLatLng.color?.value,
        'especie': namedLatLng.species,
        'categoria': selectedCategory,
        'equipe': selectedTeam,
        'createdAt': now,
      });

      setState(() {
        points.add(namedLatLng);
        pointCounter = points.isNotEmpty
            ? (int.tryParse(points.last.name.substring(1)) ?? 0) + 1
            : 1;
      });

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PointDetailsScreen(pointInfo: namedLatLng),
        ),
      );

      if (kDebugMode) {
        print(
          'ID do ponto: ${namedLatLng.name}, Coordenadas: ${namedLatLng.coordinates}',
        );
      }
    }
  }

  bool _isPointNameUnique(String name) {
    return points.every((point) => point.name != name);
  }

  void _deletePointAndInfo(PointInfo pointInfo) async {
    await _deleteAdditionalInfo(pointInfo);

    setState(() {
      points.remove(pointInfo);
      pointCounter = points.length + 1;
    });

    _deletePointFromFirestore(pointInfo);
  }

  Future<void> _deleteAdditionalInfo(PointInfo pointInfo) async {
    try {
      await FirebaseFirestore.instance
          .collection('additional_info')
          .where('point_id', isEqualTo: pointInfo.name)
          .get()
          .then((querySnapshot) {
        querySnapshot.docs.forEach((doc) async {
          await doc.reference.delete();
        });
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting additional info: $e');
      }
    }
  }

  void _showDeleteConfirmationDialog(PointInfo pointInfo) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          title: const Text('Confirmação'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Deseja realmente excluir este ponto?'),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.warning, color: Colors.orange),
                  SizedBox(width: 8),
                  Text(
                    'Esta ação não pode ser desfeita.',
                    style: TextStyle(color: Colors.grey, fontSize: 15),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                _deletePointAndInfo(pointInfo);
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red, // Cor do texto
              ),
              child: const Text('Confirmar'),
            ),
          ],
        );
      },
    );
  }

  void _deletePointFromFirestore(PointInfo pointInfo) async {
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
    }
  }

  void _onMarkerTap(PointInfo pointInfo) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          backgroundColor: Colors.white,
          elevation: 25,
          title: const Text(
            'Detalhes do Ponto',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.location_city_rounded),
                title: Text('Cidade: ${pointInfo.city}'),
              ),
              ListTile(
                leading: const Icon(Icons.location_on),
                title: Text(
                  'Latitude: ${pointInfo.coordinates.latitude}\nLongitude: ${pointInfo.coordinates.longitude}',
                ),
              ),
              ListTile(
                leading: const FaIcon(FontAwesomeIcons.tree),
                title: Text('Espécie: ${pointInfo.species ?? 'N/A'}'),
              ),
              ListTile(
                leading: const FaIcon(FontAwesomeIcons.peopleGroup),
                title: Text('Equipe: ${pointInfo.teamName ?? 'N/A'}'),
              ),
              ListTile(
                leading: const FaIcon(FontAwesomeIcons.layerGroup),
                title: Text('Categoria: ${pointInfo.category ?? 'N/A'}'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Fechar',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 16,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) =>
                      PointDetailsScreen(pointInfo: pointInfo),
                ));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromRGBO(6, 31, 73, 1),
              ),
              child: const Text(
                'Editar Dados',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }
}
