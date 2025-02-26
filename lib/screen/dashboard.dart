import 'package:auto_route/annotations.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:fatconnect/database/user_db/user_controller.dart';
import '../services/location_service.dart';
import 'dart:convert';
import '../models/destination.dart';

@RoutePage(name: 'DashBoardScreenRoute')
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> with SingleTickerProviderStateMixin {
  String userName = "loading";
  String userLocation = "Loading location...";
  final String currentDate = DateFormat('EEEE, MMMM d').format(DateTime.now());

  final List<Map<String, dynamic>> networkStats = [
    {'title': 'Active Connections', 'value': '1,234', 'icon': Icons.lan, 'color': Colors.blue},
    {'title': 'Network Uptime', 'value': '99.98%', 'icon': Icons.timer, 'color': Colors.green},
    {'title': 'Data Transferred', 'value': '2.3 TB', 'icon': Icons.data_usage, 'color': Colors.orange},
    {'title': 'Alerts', 'value': '3', 'icon': Icons.warning, 'color': Colors.red},
  ];

  List<Destination> popularDestinations = [];
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));

    _controller.forward();
    _getUserLocation();
    _loadDestinations();
  }

  Future<void> _getUserLocation() async {
    try {
      final locationService = LocationService();
      final position = await locationService.getCurrentLocation();
      final locationName = await locationService.getLocationName(
        position.latitude,
        position.longitude,
      );
      setState(() {
        userLocation = locationName;
      });
    } catch (e) {
      setState(() {
        userLocation = "Unable to get location";
      });
    }
  }

  Future<void> _loadDestinations() async {
    try {
      // Create a proper JSON string
      final user=context.read<UserController>().currentUser;

      userName=user!.email.toString();

      final List<dynamic> jsonResult = json.decode(jsonString);
      print('Loaded ${jsonResult.length} destinations from JSON');
      setState(() {
        popularDestinations = jsonResult.map((item) => Destination.fromJson(item)).toList();
        
      });
    } catch (e) {
      print('Error loading destinations: $e');
      setState(() {
        popularDestinations = [];
      });
    }
  }

  Widget _buildDestinationSlider() {
    print('Number of destinations: ${popularDestinations.length}');
    
    return SizedBox(
      height: 250,
      child: popularDestinations.isEmpty
          ? Center(
              child: Text(
                'No destinations available',
                style: TextStyle(color: Colors.grey),
              ),
            )
          : ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: popularDestinations.length,
              itemBuilder: (context, index) {
                final destination = popularDestinations[index];
                print('Loading destination: ${destination.name}');
                return Container(
                  width: 300,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(15),
                          ),
                          child: Image.network(
                            destination.imageUrl,
                            height: 150,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              print('Error loading image: ${destination.imageUrl}');
                              return Container(
                                height: 150,
                                color: Colors.grey[200],
                                child: Icon(Icons.broken_image),
                              );
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                destination.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                destination.description,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildQuickActionsSection(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 1024;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Quick Actions",
            style: TextStyle(
              fontSize: isMobile ? 20 : 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              int crossAxisCount;
              double childAspectRatio;

              if (isMobile) {
                crossAxisCount = 2;
                childAspectRatio = 1.3;
              } else if (isTablet) {
                crossAxisCount = 3;
                childAspectRatio = 1.5;
              } else {
                crossAxisCount = 4;
                childAspectRatio = 1.8;
              }

              return GridView.count(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                crossAxisCount: crossAxisCount,
                childAspectRatio: childAspectRatio,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildResponsiveActionCard(
                    icon: Icons.settings,
                    title: "Configure FAT",
                    color: Colors.blue,
                    isMobile: isMobile,
                  ),
                  _buildResponsiveActionCard(
                    icon: Icons.monitor,
                    title: "Monitor Network",
                    color: Colors.green,
                    isMobile: isMobile,
                  ),
                  _buildResponsiveActionCard(
                    icon: Icons.analytics,
                    title: "View Analytics",
                    color: Colors.orange,
                    isMobile: isMobile,
                  ),
                  _buildResponsiveActionCard(
                    icon: Icons.report,
                    title: "Generate Report",
                    color: Colors.purple,
                    isMobile: isMobile,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildResponsiveActionCard({
    required IconData icon,
    required String title,
    required Color color,
    required bool isMobile,
  }) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            // Handle action
          },
          child: Padding(
            padding: EdgeInsets.all(isMobile ? 12 : 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(isMobile ? 8 : 12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: isMobile ? 24 : 28,
                    color: color,
                  ),
                ),
                SizedBox(height: isMobile ? 8 : 16),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: isMobile ? 14 : 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 1024;

    return LayoutBuilder(
      builder: (context, constraints) {
        return GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isMobile ? 2 : (isTablet ? 3 : 4),
            childAspectRatio: isMobile ? 1.2 : 1.5,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: networkStats.length,
          itemBuilder: (context, index) {
            final stat = networkStats[index];
            return Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: EdgeInsets.all(isMobile ? 12 : 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(isMobile ? 8 : 12),
                      decoration: BoxDecoration(
                        color: stat['color'].withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        stat['icon'],
                        size: isMobile ? 24 : 28,
                        color: stat['color'],
                      ),
                    ),
                    SizedBox(height: isMobile ? 8 : 16),
                    Text(
                      stat['value'],
                      style: TextStyle(
                        fontSize: isMobile ? 18 : 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: isMobile ? 4 : 8),
                    Text(
                      stat['title'],
                      style: TextStyle(
                        fontSize: isMobile ? 14 : 16,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        child: FadeTransition(
          opacity: _opacityAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Column(
              children: [
                // Header Section
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.blue.shade900,
                        Colors.blue.shade700,
                      ],
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                  child: SafeArea(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Network Overview",
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.8),
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  "FATConnect",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            CircleAvatar(
                              radius: 25,
                              backgroundColor: Colors.white,
                              child: Icon(
                                Icons.network_check,
                                size: 30,
                                color: Colors.blue.shade800,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Text(
                          currentDate,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                color: Colors.white,
                                size: 30,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Network Location",
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.8),
                                        fontSize: 14,
                                      ),
                                    ),
                                    Text(
                                      userLocation,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Stats Section
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Network Statistics",
                        style: TextStyle(
                          fontSize: MediaQuery.of(context).size.width < 600 ? 20 : 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildStatsGrid(context),
                    ],
                  ),
                ),

                // Quick Actions Section
                _buildQuickActionsSection(context),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

final jsonString = '''
      [
        {
          "name": "Mefou National Park",
          "description": "A wildlife reserve home to various primate species, including gorillas and chimpanzees, located approximately an hour's drive from Yaoundé.",
          "latitude": 3.6333,
          "longitude": 11.5000,
          "image_url": "https://dynamic-media-cdn.tripadvisor.com/media/photo-o/05/55/e6/42/mefou-national-park.jpg?w=900&h=500&s=1"
        },
        {
          "name": "Monument de la Réunification",
          "description": "A monument symbolizing the reunification of British and French Cameroons, situated in Yaoundé.",
          "latitude": 3.8480,
          "longitude": 11.5021,
          "image_url": "https://dynamic-media-cdn.tripadvisor.com/media/photo-o/09/8e/7d/e0/monument-de-la-reunification.jpg?w=800&h=500&s=1"
        },
        {
          "name": "Musée Ethnographique des Peuples de la Fôret",
          "description": "A museum showcasing the cultures and histories of Central African forest peoples, located in Yaoundé.",
          "latitude": 3.8715,
          "longitude": 11.5240,
          "image_url": "https://dynamic-media-cdn.tripadvisor.com/media/photo-o/0f/52/b0/f1/musee-ethnographique.jpg?w=900&h=-1&s=1"
        },
        {
          "name": "National Museum of Yaoundé",
          "description": "Housed in the former presidential palace, this museum offers insights into Cameroon's history and traditions.",
          "latitude": 3.8667,
          "longitude": 11.5167,
          "image_url": "https://dynamic-media-cdn.tripadvisor.com/media/photo-o/0d/80/38/a0/you-can-only-take-photos.jpg?w=900&h=500&s=1"
        },
        {
          "name": "Ebogo Ecotourism Site",
          "description": "An ecotourism site approximately 35 km from Yaoundé, offering forest walks and canoeing on the Nyong River.",
          "latitude": 3.5167,
          "longitude": 11.5000,
          "image_url": "https://dynamic-media-cdn.tripadvisor.com/media/photo-o/18/9d/9b/1a/fluss.jpg?w=1200&h=900&s=1"
        },
        {
          "name": "Nachtigal Waterfalls",
          "description": "A picturesque waterfall located in the Batchenga area, named after the explorer Nachtigal.",
          "latitude": 4.4500,
          "longitude": 11.7000,
          "image_url": "https://dynamic-media-cdn.tripadvisor.com/media/photo-o/18/ad/b0/a3/monument-nachtigal-1.jpg?w=900&h=500&s=1"
        },
        {
          "name": "Akok Bekoe Caves",
          "description": "A series of impressive caves located in the village of Bikoe, on the road from Mbalmayo to Akono.",
          "latitude": 3.4167,
          "longitude": 11.3500,
          "image_url": "https://www.ongola.com/wp-content/uploads/2024/09/akok-bekoe.jpg"
        },
        {
          "name": "Sanaga River Rapids",
          "description": "Spectacular rapids near the presidential residence of Ndjore in the Batchenga district.",
          "latitude": 4.4500,
          "longitude": 11.7000,
          "image_url": "https://images.westend61.de/0001310581pw/cameroon-aerial-view-of-sanaga-river-in-landscape-VEGF01406.jpg"
        },
        {
          "name": "Mbam Minkom Mountain",
          "description": "A prominent mountain offering hiking opportunities and panoramic views of the surrounding region.",
          "latitude": 4.0000,
          "longitude": 11.5000,
          "image_url": "https://peakvisor.com/photo/8/88/Mount_Cameroon_craters.jpg"
        },
        {
          "name": "Nyong River",
          "description": "A major river in the Centre Region, popular for canoeing and observing diverse flora and fauna along its banks.",
          "latitude": 3.7667,
          "longitude": 11.7333,
          "image_url": "https://upload.wikimedia.org/wikipedia/commons/thumb/0/0f/Nyong_river_Cameroon.jpg/800px-Nyong_river_Cameroon.jpg?20160926201150"
        }
      ]
      ''';