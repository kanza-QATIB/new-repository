import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
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
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late MediaQueryData _mediaQueryData;

  // Définition des couleurs
  final Color primaryColor = Color(0xFF6C4AB6);

  // Définition des constantes pour le cercle
  final double circleRadius = 150.0;
  late Offset centerPoint;

  final List<String> _quotes = [
    "L'éducation est la clé du succès",
    "Votre potentiel est illimité",
  ];
  String _currentQuote = "";

  // Définition des items du cercle
  final List<Map<String, dynamic>> _circleItems = [
    {
      'icon': Icons.folder_outlined,
      'title': 'Dossiers',
      'description': 'Gérez vos dossiers',
      'color': Color(0xFFE15FED),
      'offset': const Offset(0, -1),
      'angle': 0.0,
    },
    {
      'icon': Icons.description_outlined,
      'title': 'Documents',
      'description': 'Consultez vos documents',
      'color': Color(0xFFFFD966),
      'offset': const Offset(0.7, -0.7),
      'angle': 0.75,
    },
    {
      'icon': Icons.folder_shared_outlined,
      'title': 'Partage',
      'description': 'Partagez avec vos collaborateurs',
      'color': Color(0xFFFF9B50),
      'offset': const Offset(1, 0),
      'angle': 1.5,
    },
    {
      'icon': Icons.insert_drive_file_outlined,
      'title': 'Fichiers',
      'description': 'Accédez à vos fichiers',
      'color': Color(0xFF8AFF80),
      'offset': const Offset(0.7, 0.7),
      'angle': 2.25,
    },
    {
      'icon': Icons.assessment_outlined,
      'title': 'Rapports',
      'description': 'Consultez les rapports',
      'color': Color(0xFF6C4AB6),
      'offset': const Offset(0, 1),
      'angle': 3.0,
    },
    {
      'icon': Icons.account_box_outlined,
      'title': 'Comptes',
      'description': 'Gérez les comptes utilisateurs',
      'color': Color(0xFF5EAEFD),
      'offset': const Offset(-0.7, 0.7),
      'angle': 3.75,
    },
    {
      'icon': Icons.email_outlined,
      'title': 'Messages',
      'description': 'Consultez vos messages',
      'color': Color(0xFFE15FED),
      'offset': const Offset(-1, 0),
      'angle': 4.5,
    },
    {
      'icon': Icons.folder_special_outlined,
      'title': 'Spécial',
      'description': 'Accès aux fonctions spéciales',
      'color': Color(0xFF8A6ED5),
      'offset': const Offset(-0.7, -0.7),
      'angle': 5.25,
    },
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 2000),
      vsync: this,
    );

    _controller.forward();
    _currentQuote =
        _quotes[DateTime.now().millisecondsSinceEpoch % _quotes.length];

    // Initialiser avec l'orientation portrait pour mobile
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _mediaQueryData = MediaQuery.of(context);
    centerPoint = Offset(
      _mediaQueryData.size.width / 2,
      _mediaQueryData.size.height / 3,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    // Réinitialiser les orientations
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    super.dispose();
  }

  // Calculate position on circle
  Offset _calculatePosition(double radius, double angle, Offset center) {
    final double x = center.dx + radius * cos(angle * 3.14);
    final double y = center.dy + radius * sin(angle * 3.14);
    return Offset(x, y);
  }

  // Helper method to determine if we're on a small screen
  bool isSmallScreen(BuildContext context) {
    return MediaQuery.of(context).size.width < 600;
  }

  // Helper method for responsive sizing
  double responsiveSize(
    BuildContext context,
    double mobileSize,
    double webSize,
  ) {
    return isSmallScreen(context) ? mobileSize : webSize;
  }

  @override
  Widget build(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    final size = _mediaQueryData.size;

    // Handle different orientations and platforms
    final isLandscape = _mediaQueryData.orientation == Orientation.landscape;
    final isWebPlatform = size.width > 1000;

    return Scaffold(
      body: Stack(
        children: [
          // Background gradient with a subtle pattern
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFE2DAFD).withOpacity(0.8), Color(0xFFD9E9FF).withOpacity(0.8)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // Elegant semi-transparent overlay
          Container(
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.6)),
          ),

          // Particles animation
          CustomPaint(
            painter: CirclePatternPainter(primaryColor: primaryColor),
            size: Size.infinite,
          ),

          // Main content
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      // Circle outline
                      Positioned(
                        left: MediaQuery.of(context).size.width / 2 - 100,
                        top: MediaQuery.of(context).size.height / 3 - 100,
                        child: Container(
                              width: 200,
                              height: 200,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.6),
                                  width: 2,
                                ),
                              ),
                            )
                            .animate(
                              onPlay: (controller) => controller.repeat(),
                            )
                            .scale(
                              duration: 8.seconds,
                              begin: Offset(1.0, 1.0),
                              end: Offset(1.05, 1.05),
                            )
                            .then()
                            .scale(
                              duration: 8.seconds,
                              begin: Offset(1.05, 1.05),
                              end: Offset(1.0, 1.0),
                            ),
                      ),

                      // Center logo/icon with glassmorphism
                      Positioned(
                        left:
                            MediaQuery.of(context).size.width / 2 -
                            responsiveSize(context, 60, 75),
                        top:
                            MediaQuery.of(context).size.height / 3 -
                            responsiveSize(context, 60, 75),
                        child: GestureDetector(
                              onTap: () {
                                HapticFeedback.lightImpact();
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(
                                  responsiveSize(context, 60, 75),
                                ),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(
                                    sigmaX: 10,
                                    sigmaY: 10,
                                  ),
                                  child: Container(
                                    width: responsiveSize(context, 120, 150),
                                    height: responsiveSize(context, 120, 150),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(
                                        colors: [
                                          Color(0xFF6C4AB6).withOpacity(0.7),
                                          Color(0xFFE15FED).withOpacity(0.7),
                                          Color(0xFFFF9B50).withOpacity(0.7),
                                          Color(0xFFFFD966).withOpacity(0.7),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: primaryColor.withOpacity(0.3),
                                          blurRadius: 15,
                                          spreadRadius: 5,
                                        ),
                                      ],
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.5),
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Center(
                                      child: Image.asset(
                                        'assets/images/logo.png',
                                        width: responsiveSize(
                                          context,
                                          100,
                                          120,
                                        ),
                                        height: responsiveSize(
                                          context,
                                          100,
                                          120,
                                        ),
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            )
                            .animate()
                            .scale(
                              duration: 1.5.seconds,
                              curve: Curves.easeOut,
                              delay: 0.2.seconds,
                            )
                            .then()
                            .shimmer(duration: 2.seconds, delay: 2.seconds),
                      ),

                      // Place icons around the circle
                      ..._circleItems.asMap().entries.map((entry) {
                        final index = entry.key;
                        final item = entry.value;
                        final angle = item['angle'] as double;
                        final position = _calculatePosition(
                          circleRadius,
                          angle,
                          centerPoint,
                        );

                        return Positioned(
                          left: position.dx - 25,
                          top: position.dy - 25,
                          child: GestureDetector(
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                },
                                child: Container(
                                  width: responsiveSize(context, 50, 60),
                                  height: responsiveSize(context, 50, 60),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: item['color'],
                                    boxShadow: [
                                      BoxShadow(
                                        color: item['color'].withOpacity(0.4),
                                        blurRadius: 8,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.8),
                                      width: 2,
                                    ),
                                  ),
                                  child: Icon(
                                    item['icon'],
                                    color: Colors.white,
                                    size: responsiveSize(context, 26, 32),
                                  ),
                                ),
                              )
                              .animate()
                              .scale(
                                duration: 0.8.seconds,
                                curve: Curves.easeOut,
                                delay: 0.1.seconds * index,
                              )
                              .then()
                              .moveY(
                                duration: 2.seconds,
                                begin: 5,
                                end: -5,
                                curve: Curves.easeInOut,
                                delay: 0.2.seconds * index,
                              )
                              .then()
                              .moveY(
                                duration: 2.seconds,
                                begin: -5,
                                end: 5,
                                curve: Curves.easeInOut,
                              ),
                        );
                      }).toList(),
                    ],
                  ),
                ),

                // Bottom section with text and button
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: responsiveSize(context, 24, 40),
                    vertical: responsiveSize(context, 30, 40),
                  ),
                  child: Column(
                    children: [
                      // App name
                      Text(
                            "Bienvenue",
                            style: GoogleFonts.poppins(
                              fontSize: responsiveSize(context, 30, 38),
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                              letterSpacing: 0.5,
                            ),
                          )
                          .animate()
                          .fadeIn(duration: 0.8.seconds)
                          .moveY(
                            begin: 20,
                            end: 0,
                            duration: 0.8.seconds,
                            curve: Curves.easeOut,
                          ),

                      // Subtitle
                      Text(
                            "Gestion des Habilitations",
                            style: GoogleFonts.poppins(
                              fontSize: responsiveSize(context, 16, 20),
                              color: Colors.black54,
                              fontWeight: FontWeight.w500,
                            ),
                          )
                          .animate()
                          .fadeIn(duration: 0.8.seconds, delay: 0.2.seconds)
                          .moveY(
                            begin: 20,
                            end: 0,
                            duration: 0.8.seconds,
                            delay: 0.2.seconds,
                            curve: Curves.easeOut,
                          ),

                      SizedBox(height: responsiveSize(context, 15, 25)),

                      // Quote text
                      Text(
                        "Votre potentiel est illimité",
                        style: GoogleFonts.poppins(
                          fontSize: responsiveSize(context, 14, 16),
                          color: Colors.black45,
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ).animate().fadeIn(
                        duration: 0.8.seconds,
                        delay: 0.4.seconds,
                      ),

                      SizedBox(height: responsiveSize(context, 30, 40)),

                      // Get Started button
                      Container(
                            width:
                                isSmallScreen(context)
                                    ? double.infinity
                                    : size.width * 0.4,
                            height: responsiveSize(context, 50, 60),
                            decoration: BoxDecoration(
                              color: primaryColor,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: primaryColor.withOpacity(0.4),
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
                                  borderRadius: BorderRadius.circular(
                                    responsiveSize(context, 16, 20),
                                  ),
                                ),
                              ),
                              child: Text(
                                "Commencer",
                                style: GoogleFonts.poppins(
                                  fontSize: responsiveSize(context, 16, 20),
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          )
                          .animate()
                          .fadeIn(duration: 0.8.seconds, delay: 0.6.seconds)
                          .moveY(
                            begin: 20,
                            end: 0,
                            duration: 0.8.seconds,
                            delay: 0.6.seconds,
                            curve: Curves.easeOut,
                          )
                          .then()
                          .shimmer(delay: 1.seconds, duration: 1.5.seconds),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Custom painter for background circular patterns
class CirclePatternPainter extends CustomPainter {
  final Color primaryColor;

  CirclePatternPainter({required this.primaryColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = primaryColor.withOpacity(
            0.2,
          ) // Making lines much more transparent
          ..strokeWidth =
              0.5 // Even thinner lines for a more faded look
          ..style = PaintingStyle.stroke;

    // Draw multiple circles of varying sizes
    for (int i = 0; i < 5; i++) {
      final radius = size.width * (0.1 + i * 0.15);
      canvas.drawCircle(
        Offset(size.width * 0.5, size.height * 0.4),
        radius,
        paint,
      );
    }

    // Draw some dots
    final dotPaint =
        Paint()
          ..color = primaryColor.withOpacity(0.15) // Even more transparent dots
          ..style = PaintingStyle.fill;

    for (int i = 0; i < 40; i++) {
      final radius = 2.0 + (i % 3) * 1.0;
      final angle = i * 0.2;
      final distance = 100.0 + (i % 5) * 30.0;
      final x = size.width * 0.5 + cos(angle) * distance;
      final y = size.height * 0.4 + sin(angle) * distance;

      canvas.drawCircle(Offset(x, y), radius, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
// TODO Implement this library.
// TODO Implement this library. 