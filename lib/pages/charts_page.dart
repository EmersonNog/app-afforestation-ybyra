// ignore_for_file: library_private_types_in_public_api, avoid_print

import 'package:fl_chart/fl_chart.dart' as fl_chart;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lottie/lottie.dart';
import 'package:pie_chart/pie_chart.dart';

class PieChartScreen extends StatefulWidget {
  final String selectedCity;

  const PieChartScreen({Key? key, required this.selectedCity})
      : super(key: key);

  @override
  _PieChartScreenState createState() => _PieChartScreenState();
}

class _PieChartScreenState extends State<PieChartScreen> {
  late Map<String, double> dataMap;
  late Map<String, double> injuryDataMap;
  late Map<String, double> networksDataMap;
  late Map<String, double> floweringDataMap;
  late Map<String, double> exoticNativesDataMap = {};
  late Map<String, double> infestationDataMap;
  String selectedChart = 'initial';

  @override
  void initState() {
    super.initState();
    dataMap = {
      'Sem Vitalidade': 0,
      'Com Vitalidade': 0,
    };
    _fetchSemVitalidadeCount();
    injuryDataMap = {
      'Sem Injurias Mecanicas': 0,
      'Injurias Mecanicas com Boa Recuperacao': 0,
      'Injurias Mecanicas Sem Sinais de Recuperação': 0,
    };
    _fetchInjuryCount();
    networksDataMap = {
      'Interfere': 0,
      'Nao Interfere': 0,
    };
    _fetchNetWorksCount();
    floweringDataMap = {
      'Sim': 0,
      'Nao': 0,
    };
    _fetchFloweringCount();
    exoticNativesDataMap = {
      'Exótica': 0,
      'Nativa': 0,
      'N/A': 0,
    };
    _fetchExoticNativesCount();
    infestationDataMap = {
      'Presente': 0,
      'Ausente': 0,
    };
    _fetchInfestationCount();
  }

  Future<void> _fetchExoticNativesCount() async {
    try {
      QuerySnapshot<Object?> querySnapshotExotic = await FirebaseFirestore
          .instance
          .collection('pontos')
          .where('cidade', isEqualTo: widget.selectedCity)
          .where('especie', isEqualTo: 'Exótica')
          .get();

      setState(() {
        exoticNativesDataMap['Exótica'] = querySnapshotExotic.size.toDouble();
      });

      QuerySnapshot<Object?> querySnapshotNative = await FirebaseFirestore
          .instance
          .collection('pontos')
          .where('cidade', isEqualTo: widget.selectedCity)
          .where('especie', isEqualTo: 'Nativa')
          .get();

      setState(() {
        exoticNativesDataMap['Nativa'] = querySnapshotNative.size.toDouble();
      });

      QuerySnapshot<Object?> querySnapshotNA = await FirebaseFirestore.instance
          .collection('pontos')
          .where('cidade', isEqualTo: widget.selectedCity)
          .where('especie', isEqualTo: 'N/A')
          .get();

      setState(() {
        exoticNativesDataMap['N/A'] = querySnapshotNA.size.toDouble();
      });
    } catch (e) {
      print('Error fetching Exotic/Natives count: $e');
    }
  }

  Future<void> _fetchSemVitalidadeCount() async {
    try {
      QuerySnapshot<Object?> querySnapshotInfo = await FirebaseFirestore
          .instance
          .collection('additional_info')
          .where('city', isEqualTo: widget.selectedCity)
          .get();

      QuerySnapshot<Object?> querySnapshotApp = await FirebaseFirestore.instance
          .collection('additional_info_app')
          .where('city', isEqualTo: widget.selectedCity)
          .get();

      int semVitalidadeInfoCount = querySnapshotInfo.docs
          .where((doc) => doc['selectedVitality'] == 'Sem Vitalidade')
          .toList()
          .length;

      int semVitalidadeAppCount = querySnapshotApp.docs
          .where((doc) => doc['selectedVitality'] == 'Sem Vitalidade')
          .toList()
          .length;

      int comVitalidadeInfoCount = querySnapshotInfo.docs
          .where((doc) => doc['selectedVitality'] == 'Com Vitalidade')
          .toList()
          .length;

      int comVitalidadeAppCount = querySnapshotApp.docs
          .where((doc) => doc['selectedVitality'] == 'Com Vitalidade')
          .toList()
          .length;

      setState(() {
        dataMap['Sem Vitalidade'] =
            semVitalidadeInfoCount + semVitalidadeAppCount.toDouble();
        dataMap['Com Vitalidade'] =
            comVitalidadeInfoCount + comVitalidadeAppCount.toDouble();
      });
    } catch (e) {
      print('Error fetching Sem Vitalidade count: $e');
    }
  }

  Future<void> _fetchInjuryCount() async {
    try {
      QuerySnapshot<Object?> querySnapshotInfo = await FirebaseFirestore
          .instance
          .collection('additional_info')
          .where('city', isEqualTo: widget.selectedCity)
          .get();

      QuerySnapshot<Object?> querySnapshotApp = await FirebaseFirestore.instance
          .collection('additional_info_app')
          .where('city', isEqualTo: widget.selectedCity)
          .get();

      int semInjuriasInfoCount = querySnapshotInfo.docs
          .where((doc) => doc['selectedInjury'] == 'Sem Injurias Mecanicas')
          .toList()
          .length;

      int semInjuriasAppCount = querySnapshotApp.docs
          .where((doc) => doc['selectedInjury'] == 'Sem Injurias Mecanicas')
          .toList()
          .length;

      int comBoaRecuperacaoInfoCount = querySnapshotInfo.docs
          .where((doc) =>
              doc['selectedInjury'] == 'Injurias Mecanicas com Boa Recuperacao')
          .toList()
          .length;

      int comBoaRecuperacaoAppCount = querySnapshotApp.docs
          .where((doc) =>
              doc['selectedInjury'] == 'Injurias Mecanicas com Boa Recuperacao')
          .toList()
          .length;

      int semSinaisRecuperacaoInfoCount = querySnapshotInfo.docs
          .where((doc) =>
              doc['selectedInjury'] ==
              'Injurias Mecanicas sem Sinais de Recuperacao')
          .toList()
          .length;

      int semSinaisRecuperacaoAppCount = querySnapshotApp.docs
          .where((doc) =>
              doc['selectedInjury'] ==
              'Injurias Mecanicas sem Sinais de Recuperacao')
          .toList()
          .length;

      setState(() {
        injuryDataMap['Sem Injurias Mecanicas'] =
            semInjuriasInfoCount + semInjuriasAppCount.toDouble();
        injuryDataMap['Injurias Mecanicas com Boa Recuperacao'] =
            comBoaRecuperacaoInfoCount + comBoaRecuperacaoAppCount.toDouble();
        injuryDataMap['Injurias Mecanicas Sem Sinais de Recuperação'] =
            semSinaisRecuperacaoInfoCount +
                semSinaisRecuperacaoAppCount.toDouble();
      });
    } catch (e) {
      print('Error fetching Injury count: $e');
    }
  }

  Future<void> _fetchInfestationCount() async {
    try {
      QuerySnapshot<Object?> querySnapshotInfo = await FirebaseFirestore
          .instance
          .collection('additional_info')
          .where('city', isEqualTo: widget.selectedCity)
          .get();

      QuerySnapshot<Object?> querySnapshotApp = await FirebaseFirestore.instance
          .collection('additional_info_app')
          .where('city', isEqualTo: widget.selectedCity)
          .get();

      int presenteInfoCount = querySnapshotInfo.docs
          .where((doc) => doc['selectedInfection'] == 'Presente')
          .toList()
          .length;

      int presenteAppCount = querySnapshotApp.docs
          .where((doc) => doc['selectedInfection'] == 'Presente')
          .toList()
          .length;

      int ausenteInfoCount = querySnapshotInfo.docs
          .where((doc) => doc['selectedInfection'] == 'Ausente')
          .toList()
          .length;

      int ausenteAppCount = querySnapshotApp.docs
          .where((doc) => doc['selectedInfection'] == 'Ausente')
          .toList()
          .length;

      setState(() {
        infestationDataMap['Presente'] =
            presenteInfoCount + presenteAppCount.toDouble();
        infestationDataMap['Ausente'] =
            ausenteInfoCount + ausenteAppCount.toDouble();
      });
    } catch (e) {
      print('Error fetching infestation count: $e');
    }
  }

  Future<void> _fetchNetWorksCount() async {
    try {
      QuerySnapshot<Object?> querySnapshot = await FirebaseFirestore.instance
          .collection('additional_info')
          .where('city', isEqualTo: widget.selectedCity)
          .where('selectedWebs', isEqualTo: 'Interfere')
          .get();

      setState(() {
        networksDataMap['Interfere'] = querySnapshot.size.toDouble();
      });

      querySnapshot = await FirebaseFirestore.instance
          .collection('additional_info')
          .where('city', isEqualTo: widget.selectedCity)
          .where('selectedWebs', isEqualTo: 'Nao Interfere')
          .get();

      setState(() {
        networksDataMap['Nao Interfere'] = querySnapshot.size.toDouble();
      });
    } catch (e) {
      print('Error fetching networks count: $e');
    }
  }

  Future<void> _fetchFloweringCount() async {
    try {
      QuerySnapshot<Object?> querySnapshot = await FirebaseFirestore.instance
          .collection('additional_info')
          .where('city', isEqualTo: widget.selectedCity)
          .where('selectedOutcrop', isEqualTo: 'Sim')
          .get();

      setState(() {
        floweringDataMap['Sim'] = querySnapshot.size.toDouble();
      });

      querySnapshot = await FirebaseFirestore.instance
          .collection('additional_info')
          .where('city', isEqualTo: widget.selectedCity)
          .where('selectedOutcrop', isEqualTo: 'Nao')
          .get();

      setState(() {
        floweringDataMap['Nao'] = querySnapshot.size.toDouble();
      });
    } catch (e) {
      print('Error fetching networks count: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Dados de ${widget.selectedCity}',
          style: const TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromRGBO(6, 31, 73, 1),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back),
          style: const ButtonStyle(
            iconColor: MaterialStatePropertyAll(Colors.white),
          ),
        ),
      ),
      body: SizedBox(
        width: MediaQuery.of(context).size.width * 1,
        child: Column(
          children: [
            Column(
              children: [
                if (selectedChart == 'initial')
                  Column(
                    children: [
                      Lottie.asset('assets/images/charts.json',
                          width: 700, height: 300),
                      Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: Padding(
                          padding: const EdgeInsets.all(18.0),
                          child: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              style: const TextStyle(
                                  fontSize: 18,
                                  letterSpacing: 2,
                                  color: Colors.black),
                              children: [
                                const TextSpan(
                                  text: "Escolha um ",
                                ),
                                TextSpan(
                                  text: "gráfico",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.amber[700],
                                  ),
                                ),
                                const TextSpan(
                                  text: " para visualizar os ",
                                ),
                                const TextSpan(
                                  text: "dados",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.deepPurpleAccent,
                                  ), // Cor da palavra "dados"
                                ),
                                const TextSpan(
                                  text: "!",
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                DropdownButton<String>(
                  elevation: 5,
                  icon: const Icon(Icons.keyboard_double_arrow_down_outlined),
                  padding: const EdgeInsets.all(10),
                  value: selectedChart,
                  items: const [
                    DropdownMenuItem<String>(
                      value: 'initial',
                      child: Text(
                        'Selecione um gráfico',
                        style: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    DropdownMenuItem<String>(
                      value: 'vitality',
                      child: Text('Vitalidade'),
                    ),
                    DropdownMenuItem<String>(
                      value: 'injury',
                      child: Text('Injúrias'),
                    ),
                    DropdownMenuItem<String>(
                      value: 'network',
                      child: Text('Redes Elét. e Iluminação Públi.'),
                    ),
                    DropdownMenuItem<String>(
                      value: 'flowering',
                      child: Text('Possuí Afloramento'),
                    ),
                    DropdownMenuItem<String>(
                      value: 'exoticNatives',
                      child: Text('Espécies'),
                    ),
                    DropdownMenuItem<String>(
                      value: 'infestation',
                      child: Text('Infestação'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedChart = value!;
                    });
                  },
                ),
                if (selectedChart == 'vitality')
                  Column(
                    children: [
                      const Text("Dados sobre vitalidade em porcentagem (%)"),
                      PieChart(
                        centerText: "Vitalidade",
                        dataMap: dataMap,
                        animationDuration: const Duration(milliseconds: 800),
                        chartLegendSpacing: 32,
                        chartRadius: MediaQuery.of(context).size.width / 1.7,
                        colorList: const [
                          Colors.grey,
                          Colors.red,
                        ],
                        legendOptions: const LegendOptions(
                            legendPosition: LegendPosition.bottom,
                            legendTextStyle: TextStyle(color: Colors.black)),
                        chartValuesOptions: const ChartValuesOptions(
                          decimalPlaces: 0,
                          showChartValuesInPercentage: true,
                        ),
                        chartType: ChartType.disc,
                      ),
                    ],
                  ),
                if (selectedChart == 'injury')
                  Column(
                    children: [
                      const Text("Dados sobre injúarias em porcentagem (%)"),
                      PieChart(
                        centerText: "Injúrias",
                        dataMap: injuryDataMap,
                        animationDuration: const Duration(milliseconds: 800),
                        chartLegendSpacing: 32,
                        chartRadius: MediaQuery.of(context).size.width / 1.7,
                        colorList: const [
                          Colors.green,
                          Colors.yellow,
                          Colors.red,
                        ],
                        legendOptions: const LegendOptions(
                          legendPosition: LegendPosition.bottom,
                        ),
                        chartValuesOptions: const ChartValuesOptions(
                          decimalPlaces: 0,
                          showChartValuesInPercentage: true,
                        ),
                        chartType: ChartType.disc,
                      ),
                    ],
                  ),
                if (selectedChart == 'network')
                  Column(
                    children: [
                      const Text("Dados sobre redes aéreas em porcentagem (%)"),
                      PieChart(
                        centerText: "Redes",
                        dataMap: networksDataMap,
                        animationDuration: const Duration(milliseconds: 800),
                        chartLegendSpacing: 32,
                        chartRadius: MediaQuery.of(context).size.width / 1.7,
                        colorList: const [
                          Colors.grey,
                          Colors.red,
                        ],
                        legendOptions: const LegendOptions(
                          legendPosition: LegendPosition.bottom,
                        ),
                        chartValuesOptions: const ChartValuesOptions(
                          decimalPlaces: 0,
                          showChartValuesInPercentage: true,
                        ),
                        chartType: ChartType.disc,
                      ),
                    ],
                  ),
                if (selectedChart == 'flowering')
                  Column(
                    children: [
                      const Text("Dados de afloramento em porcentagem (%)"),
                      PieChart(
                        centerText: "Afloramento",
                        dataMap: floweringDataMap,
                        animationDuration: const Duration(milliseconds: 800),
                        chartLegendSpacing: 32,
                        chartRadius: MediaQuery.of(context).size.width / 1.7,
                        colorList: const [
                          Colors.red,
                          Colors.grey,
                        ],
                        legendOptions: const LegendOptions(
                          legendPosition: LegendPosition.bottom,
                        ),
                        chartValuesOptions: const ChartValuesOptions(
                          decimalPlaces: 0,
                          showChartValuesInPercentage: true,
                        ),
                        chartType: ChartType.disc,
                      ),
                    ],
                  ),
                if (selectedChart == 'exoticNatives')
                  Column(
                    children: [
                      const Text("Gráfico de barras - Espécies (quantidade)"),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.4,
                        child: fl_chart.BarChart(
                          fl_chart.BarChartData(
                            gridData: const fl_chart.FlGridData(show: true),
                            backgroundColor: Colors.black,
                            barTouchData: fl_chart.BarTouchData(),
                            titlesData: fl_chart.FlTitlesData(
                              show: true,
                              topTitles: const fl_chart.AxisTitles(
                                sideTitles:
                                    fl_chart.SideTitles(showTitles: false),
                              ),
                              bottomTitles: fl_chart.AxisTitles(
                                  sideTitles: fl_chart.SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  switch (value.toInt()) {
                                    case 0:
                                      return const Text('Exótica');
                                    case 1:
                                      return const Text('Nativa');
                                    case 2:
                                      return const Text('Não Identificada');
                                    default:
                                      return const Text('');
                                  }
                                },
                              )),
                            ),
                            borderData: fl_chart.FlBorderData(show: true),
                            barGroups: [
                              fl_chart.BarChartGroupData(x: 0, barRods: [
                                fl_chart.BarChartRodData(
                                    toY: exoticNativesDataMap['Exótica'] ?? 0,
                                    color: Colors.purple,
                                    width: 40,
                                    borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(10),
                                        topRight: Radius.circular(10))),
                              ]),
                              fl_chart.BarChartGroupData(x: 1, barRods: [
                                fl_chart.BarChartRodData(
                                    toY: exoticNativesDataMap['Nativa'] ?? 0,
                                    color: Colors.green,
                                    width: 40,
                                    borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(10),
                                        topRight: Radius.circular(10))),
                              ]),
                              fl_chart.BarChartGroupData(x: 2, barRods: [
                                fl_chart.BarChartRodData(
                                    toY: exoticNativesDataMap['N/A'] ?? 0,
                                    color: Colors.red,
                                    width: 40,
                                    borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(10),
                                        topRight: Radius.circular(10))),
                              ]),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                if (selectedChart == 'infestation')
                  Column(
                    children: [
                      const Text("Dados de infestação em porcentagem (%)"),
                      PieChart(
                        centerText: "Infestação",
                        dataMap: infestationDataMap,
                        animationDuration: const Duration(milliseconds: 800),
                        chartLegendSpacing: 32,
                        chartRadius: MediaQuery.of(context).size.width / 1.7,
                        colorList: const [
                          Colors.red,
                          Colors.grey,
                        ],
                        legendOptions: const LegendOptions(
                          legendPosition: LegendPosition.bottom,
                        ),
                        chartValuesOptions: const ChartValuesOptions(
                          decimalPlaces: 0,
                          showChartValuesInPercentage: true,
                        ),
                        chartType: ChartType.disc,
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
