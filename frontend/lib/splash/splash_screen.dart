import 'package:flutter/material.dart';
import '../auth/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double _opacity = 0.0;
  double _scale = 0.5;

  @override
  void initState() {
    super.initState();
    
    // Start animation after widget builds
    Future.delayed(Duration.zero, () {
      setState(() {
        _opacity = 1.0;
        _scale = 1.0;
      });
    });

    // Delay before moving to Login screen
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const LoginScreen(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: const Color(0xFF3BC1A8), 
      backgroundColor: const Color(0xFF008080),

      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedOpacity(
              duration: const Duration(milliseconds: 1200),
              opacity: _opacity,
              child: AnimatedScale(
                duration: const Duration(milliseconds: 1200),
                scale: _scale,
                child: Image.asset(
                  'assets/images/splash_image.png',
                  width: 300,
                  fit: BoxFit.contain,
                ),
              ),
            ),

            SizedBox(height: 16),

            AnimatedOpacity(
              duration: const Duration(milliseconds: 1200),
              opacity: _opacity,
              child: AnimatedScale(
                duration: const Duration(milliseconds: 1200),
                scale: _scale,
                child: const Text(
                  'FinGuide',
                  style: TextStyle(
                    fontSize: 35,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            SizedBox(height: 5),

            AnimatedOpacity(
              duration: const Duration(milliseconds: 1200),
              opacity: _opacity,
              child: AnimatedScale(
                duration: const Duration(milliseconds: 1200),
                scale: _scale, 
                child: const Text(
                  'Think Smart, Spend Smart',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Colors.white70
                  )
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
