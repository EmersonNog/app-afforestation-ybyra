import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _showLottie = false;

  @override
  void initState() {
    super.initState();

    // Mostrar o Lottie após 1 segundo
    Timer(const Duration(seconds: 1), () {
      setState(() {
        _showLottie = true;
      });
    });

    // Navegar para '/home' após 5 segundos
    Timer(const Duration(seconds: 5), () {
      Navigator.of(context).pushReplacementNamed('/home');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          color: Color.fromRGBO(1, 17, 42, 1),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset("assets/images/splash.png"),
              AnimatedOpacity(
                opacity: _showLottie ? 1.0 : 0.0,
                duration: const Duration(seconds: 2),
                child: Lottie.asset('assets/images/loading.json', width: 115, height: 115),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
