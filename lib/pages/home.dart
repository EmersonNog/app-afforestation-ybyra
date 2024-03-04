import 'package:arborizacao/pages/add_city_page.dart';
import 'package:arborizacao/pages/team.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slide_drawer/flutter_slide_widget.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:page_animation_transition/animations/fade_animation_transition.dart';
import 'package:page_animation_transition/page_animation_transition.dart';

import '../utils/custom_drawer.dart';
import 'map_page.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    final GlobalKey<SliderDrawerWidgetState> drawerKey = GlobalKey();
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
    return SliderDrawerWidget(
      key: drawerKey,
      option: SliderDrawerOption(
        backgroundColor: const Color.fromRGBO(38, 46, 59, 1),
        sliderEffectType: SliderEffectType.Rounded,
        upDownScaleAmount: 50,
        radiusAmount: 50,
        direction: SliderDrawerDirection.LTR,
      ),
      drawer: const CustomDrawer(),
      body: Scaffold(
        key: scaffoldKey,
        backgroundColor: const Color.fromRGBO(1, 17, 42, 1),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          title: const Row(
            children: [
              Text(
                'Tree',
                style:
                    TextStyle(fontWeight: FontWeight.w100, color: Colors.white),
              ),
              Text(
                "Mapper",
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              )
            ],
          ),
          leading: Padding(
            padding: const EdgeInsets.only(left: 20.0),
            child: GestureDetector(
              onTap: () {
                drawerKey.currentState!.toggleDrawer();
              },
              child: const Center(
                  child: FaIcon(
                FontAwesomeIcons.barsStaggered,
                color: Colors.white
              )),
            ),
          ),
        ),
        body: Container(
          decoration: const BoxDecoration(color: Color.fromRGBO(1, 17, 42, 1)),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    Image.asset('assets/images/tree_home.png'), 
                    const Text(
                      "Comece agora mesmo a cadastrar as \ncidades no nosso sistema. \nClique no botão abaixo para iniciar.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 15.0,
                          color: Colors.white,
                          fontWeight: FontWeight.w100),
                    ),
                    const SizedBox(
                      height: 50,
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.5,
                      decoration: const BoxDecoration(
                          color: Color.fromRGBO(33, 149, 243, 0.623),
                          borderRadius:
                              BorderRadius.all(Radius.circular(25))),
                      child: TextButton(
                        child: const Text(
                          "Iniciar",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(context).push(PageAnimationTransition(
                              page: const MapScreen(),
                              pageAnimationType: FadeAnimationTransition()));
                        },
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.6,
                      height: MediaQuery.of(context).size.height * 0.055,
                      decoration: BoxDecoration(
                          borderRadius: const BorderRadius.all(
                            Radius.circular(25),
                          ),
                          border: Border.all(
                              color:
                                  const Color.fromRGBO(33, 149, 243, 0.623),
                              width: 1.7)),
                      child: TextButton(
                        child: const Text(
                          "Cadastrar Cidade",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w200),
                        ),
                        onPressed: () {
                          Navigator.of(context).push(PageAnimationTransition(
                              page: const AddCityScreen(),
                              pageAnimationType: FadeAnimationTransition()));
                        },
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.45,
                      height: MediaQuery.of(context).size.height * 0.050,
                      decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                                color: Color.fromRGBO(33, 149, 243, 0.623),
                                width: 1.5),
                          ),
                          borderRadius:
                              BorderRadius.all(Radius.circular(10))),
                      child: TextButton(
                        child: const Text(
                          "Cadastrar Equipe",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w200),
                        ),
                        onPressed: () {
                          Navigator.of(context).push(PageAnimationTransition(
                              page: const TeamScreen(),
                              pageAnimationType: FadeAnimationTransition()));
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
