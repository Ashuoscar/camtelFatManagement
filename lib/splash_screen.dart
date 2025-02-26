import 'dart:async';
import 'package:auto_route/auto_route.dart';
import 'package:fatconnect/routes/app_router.dart';
import 'package:fatconnect/utility/shareprferences.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';


import 'database/user_db/user_controller.dart';
@RoutePage(name: 'SplashScreenRoute')
class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  CustomSharePreference prefs = CustomSharePreference();
  final log = Logger();

  void checkToken() async {
    try {
      String? token = await prefs.getPreferenceValue("user");

      if (token != null) {
        final userController = context.read<UserController>();
        await userController.initializeCurrentUser();
        log.e(userController.currentUser?.userId);
        log.e('Token exists, navigating to EntryPointRoute');
        AutoRouter.of(context).replace(EntryPointRoute());
      } else {
        log.e('No token found, navigating to OnboardingScreenRoute');
        AutoRouter.of(context).replace(OnboardingScreenRoute());
      }
    } catch (e) {
      log.e('Error checking token: $e');
      AutoRouter.of(context).replace(OnboardingScreenRoute());
    }
  }

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 2000),
    );

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(0.0, 1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.fastOutSlowIn,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _controller.forward();

    Timer(Duration(seconds: 2), () {
      checkToken();
    });
  }

  Widget _buildSplashContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SlideTransition(
          position: _slideAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Icon(
              Icons.lan,
              size: 100,
              color: Colors.white,
            ),
          ),
        ),
        SizedBox(height: 20),
        FadeTransition(
          opacity: _animation,
          child: Text(
            'FATConnect',
            style: TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
              fontFamily: 'Roboto',
            ),
          ),
        ),
        SizedBox(height: 10),
        FadeTransition(
          opacity: _animation,
          child: Text(
            'Camtel Fiber Management System',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0D47A1),
      body: Center(
        child: _buildSplashContent(),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}