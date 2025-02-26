import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:fatconnect/routes/app_router.dart';


@RoutePage(name: 'OnboardingScreenRoute')
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late PageController _pageController;
  int _pageIndex = 0;
  final List<Onboard> _onboardData = [
    Onboard(
      icon: Icons.analytics,
      title: "FAT Analytics",
      description: "Monitor and analyze your fiber network performance in real-time.",
      color: Color(0xFF1565C0),
    ),
    Onboard(
      icon: Icons.network_check,
      title: "Network Overview",
      description: "Get a comprehensive view of your entire fiber network infrastructure.",
      color: Color(0xFF2E7D32),
    ),
    Onboard(
      icon: Icons.settings_input_composite,
      title: "FAT Configuration",
      description: "Easily manage and configure your Fiber Access Terminals.",
      color: Color(0xFFD84315),
    ),
    Onboard(
      icon: Icons.security,
      title: "Network Security",
      description: "Ensure your network's integrity with advanced security features.",
      color: Color(0xFF6A1B9A),
    ),
  ];

  @override
  void initState() {
    _pageController = PageController(initialPage: 0);
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _onboardData.length,
                onPageChanged: (value) => setState(() => _pageIndex = value),
                itemBuilder: (context, index) => OnboardPage(
                  data: _onboardData[index],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _onboardData.length,
                      (index) => AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        margin: EdgeInsets.symmetric(horizontal: 4),
                        width: _pageIndex == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _pageIndex == index 
                              ? _onboardData[index].color 
                              : Colors.grey[300],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _onboardData[_pageIndex].color,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        if (_pageIndex < _onboardData.length - 1) {
                          _pageController.nextPage(
                            duration: Duration(milliseconds: 500),
                            curve: Curves.easeInOut,
                          );
                        } else {
                          AutoRouter.of(context).push(LoginScreenRoute());
                        }
                      },
                      child: Text(
                        _pageIndex == _onboardData.length - 1 
                            ? 'Get Started' 
                            : 'Next',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => AutoRouter.of(context).push(LoginScreenRoute()),
                    child: Text(
                      'Skip',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OnboardPage extends StatelessWidget {
  final Onboard data;

  const OnboardPage({required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 200,
            width: 200,
            decoration: BoxDecoration(
              color: data.color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              data.icon,
              size: 100,
              color: data.color,
            ),
          ),
          SizedBox(height: 40),
          Text(
            data.title,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: data.color,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          Text(
            data.description,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class Onboard {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  Onboard({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });
}