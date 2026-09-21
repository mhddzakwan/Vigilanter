import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../config/router.dart'; // pastikan ini mengarah ke file router kamu

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
    super.initState();

    // Setelah 3 detik, pindah ke halaman Signin
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        context.go(AppRoutes.signin);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screeneight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFF000229),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(screenWidth * 0.07),
            child: Image.asset(
              'assets/images/vigilanter.png',
              width: screenWidth * 0.43,
              height: screenWidth * 0.43,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        bottom: true,
        child: Container(
          margin: const EdgeInsets.only(bottom: 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/images/vgt_txt.png',
                width: screenWidth * 0.4,
                height: screenWidth * 0.4,
                fit: BoxFit.contain,
              ),
              Transform.translate(
                offset: const Offset(0, -4),
                child: const Text(
                  "Vigilance in your hand",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
