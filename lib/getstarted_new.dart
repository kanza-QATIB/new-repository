import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';
import 'package:flutter/services.dart';
import 'login.dart';

class GetStartedPage extends StatefulWidget {
  const GetStartedPage({Key? key}) : super(key: key);

  @override
  State<GetStartedPage> createState() => _GetStartedPageState();
}

class _GetStartedPageState extends State<GetStartedPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  // Define colors
  final Color primaryColor = Color(0xFF6C4AB6);
  final Color secondaryColor = Color(0xFF8A6ED5);
  final List<Color> gradientColors = [Color(0xFFE0D5F7), Color(0xFFD3E5FA)];

  // Define icons for the circle
  final List<Map<String, dynamic>> circleIcons = [
    {'icon': Icons.folder, 'color': Color(0xFFE15FED)},
    {'icon': Icons.description, 'color': Color(0xFFFFD966)},
    {'icon': Icons.folder_shared, 'color': Color(0xFFFF9B50)},
    {'icon': Icons.file_copy, 'color': Color(0xFF8AFF80)},
    {'icon': Icons.security, 'color': Color(0xFF6C4AB6)},
    {'icon': Icons.assignment, 'color': Color(0xFF5EAEFD)},
    {'icon': Icons.group, 'color': Color(0xFFE15FED)},
    {'icon': Icons.settings, 'color': Color(0xFF8A6ED5)},
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Calculate position on circle
  Offset _calculatePosition(double radius, double angle, Offset center) {
    final double x = center.dx + radius * cos(angle);
    final double y = center.dy + radius * sin(angle);
    return Offset(x, y);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final centerPoint = Offset(size.width / 2, size.height * 0.4);
    final circleRadius = size.width * 0.35;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: gradientColors,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                flex: 3,
                child: Stack(
                  children: [
                    // Circle outline
                    Positioned(
                      left: centerPoint.dx - circleRadius,
                      top: centerPoint.dy - circleRadius,
                      child: Container(
                        width: circleRadius * 2,
                        height: circleRadius * 2,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withOpacity(0.6),
                            width: 1.5,
                          ),
                        ),
                      ).animate().scale(
                        duration: 2.seconds,
                        curve: Curves.easeInOut,
                        begin: Offset(0.95, 0.95),
                        end: Offset(1.0, 1.0),
                      ),
                    ),

                    // Center logo with gradient background
                    Positioned(
                      left: centerPoint.dx - 50,
                      top: centerPoint.dy - 50,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              primaryColor.withOpacity(0.7),
                              secondaryColor.withOpacity(0.7),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: primaryColor.withOpacity(0.3),
                              blurRadius: 10,
                              spreadRadius: 1,
                            ),
                          ],
                          border: Border.all(
                            color: Colors.white.withOpacity(0.8),
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Image.asset(
                            'assets/images/logo.png',
                            width: 60,
                            height: 60,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ).animate().scale(
                        duration: 800.ms,
                        curve: Curves.easeOut,
                        delay: 300.ms,
                      ),
                    ),

                    // Place icons around the circle
                    ...List.generate(circleIcons.length, (index) {
                      final angle = (2 * pi / circleIcons.length) * index;
                      final position = _calculatePosition(
                        circleRadius,
                        angle,
                        centerPoint,
                      );
                      final item = circleIcons[index];

                      return Positioned(
                        left: position.dx - 20,
                        top: position.dy - 20,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: item['color'],
                            boxShadow: [
                              BoxShadow(
                                color: item['color'].withOpacity(0.4),
                                blurRadius: 5,
                                spreadRadius: 1,
                              ),
                            ],
                            border: Border.all(
                              color: Colors.white.withOpacity(0.8),
                              width: 1.5,
                            ),
                          ),
                          child: Icon(
                            item['icon'],
                            color: Colors.white,
                            size: 20,
                          ),
                        ).animate().scale(
                          duration: 600.ms,
                          curve: Curves.easeOut,
                          delay: 200.ms * (index + 1),
                        ),
                      );
                    }),
                  ],
                ),
              ),

              // Bottom content
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        "Bienvenue",
                        style: GoogleFonts.poppins(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ).animate().fadeIn(duration: 600.ms),

                      // Subtitle
                      Text(
                        "Gestion des Habilitations",
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          color: Colors.black54,
                          fontWeight: FontWeight.w500,
                        ),
                      ).animate().fadeIn(duration: 600.ms, delay: 200.ms),

                      SizedBox(height: 10),

                      // Quote
                      Text(
                        "Votre potentiel est illimité",
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.black45,
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ).animate().fadeIn(duration: 600.ms, delay: 400.ms),

                      Spacer(),

                      // Get Started button
                      Container(
                            width: double.infinity,
                            height: 50,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [primaryColor, secondaryColor],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: primaryColor.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: () {
                                HapticFeedback.mediumImpact();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => LoginPage(),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                "Commencer",
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          )
                          .animate()
                          .fadeIn(duration: 600.ms, delay: 600.ms)
                          .moveY(
                            begin: 20,
                            end: 0,
                            duration: 600.ms,
                            delay: 600.ms,
                          ),

                      SizedBox(height: 20),
                    ],
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
