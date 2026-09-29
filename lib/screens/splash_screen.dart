import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _logoController;
  late final AnimationController _contentController;

  late final Animation<double> _logoScale;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _contentOpacity;
  late final Animation<Offset> _contentSlide;

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _logoScale = CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeOutBack,
    );

    _logoOpacity = CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeOut,
    );

    _contentOpacity = CurvedAnimation(
      parent: _contentController,
      curve: Curves.easeOut,
    );

    _contentSlide = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _contentController,
        curve: Curves.easeOutCubic,
      ),
    );

    _startAnimation();
  }

  Future<void> _startAnimation() async {
    await _logoController.forward();

    if (!mounted) return;

    await _contentController.forward();
  }

  @override
  void dispose() {
    _logoController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _getStarted() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, animation, secondaryAnimation) {
          return const LoginScreen();
        },
        transitionsBuilder:
            (_, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration:
            const Duration(milliseconds: 350),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      body: SafeArea(
        child: Stack(
          children: [
            // Background glow
            Positioned(
              top: -140,
              right: -100,
              child: Container(
                width: 320,
                height: 320,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.emerald.withValues(
                        alpha: 0.16,
                      ),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            Positioned(
              bottom: -160,
              left: -120,
              child: Container(
                width: 350,
                height: 350,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.emerald.withValues(
                        alpha: 0.08,
                      ),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // Main content
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FadeTransition(
                      opacity: _logoOpacity,
                      child: ScaleTransition(
                        scale: _logoScale,
                        child: Container(
                          width: 108,
                          height: 108,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient:
                                AppColors.mainGradient,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.emerald
                                    .withValues(
                                  alpha: 0.25,
                                ),
                                blurRadius: 35,
                                spreadRadius: 4,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.location_on_rounded,
                            color: Colors.white,
                            size: 50,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    SlideTransition(
                      position: _contentSlide,
                      child: FadeTransition(
                        opacity: _contentOpacity,
                        child: Column(
                          children: [
                            Text(
                              'GeoRemind',
                              style: AppText.display(
                                size: 31,
                                weight: FontWeight.w800,
                              ),
                            ),

                            const SizedBox(height: 9),

                            Text(
                              'Remember where it matters.',
                              textAlign: TextAlign.center,
                              style: AppText.body(
                                size: 14,
                                color: AppColors.textMid,
                              ),
                            ),

                            const SizedBox(height: 7),

                            Text(
                              'Smart reminders that follow your day.',
                              textAlign: TextAlign.center,
                              style: AppText.body(
                                size: 11.5,
                                color: AppColors.textLow,
                              ),
                            ),

                            const SizedBox(height: 44),

                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: DecoratedBox(
                                decoration:
                                    const BoxDecoration(
                                  gradient:
                                      AppColors.mainGradient,
                                  borderRadius:
                                      BorderRadius.all(
                                    Radius.circular(17),
                                  ),
                                ),
                                child: ElevatedButton(
                                  onPressed: _getStarted,
                                  style:
                                      ElevatedButton.styleFrom(
                                    backgroundColor:
                                        Colors.transparent,
                                    foregroundColor:
                                        Colors.white,
                                    shadowColor:
                                        Colors.transparent,
                                    shape:
                                        RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(
                                        17,
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment
                                            .center,
                                    children: [
                                      const Text(
                                        'Get Started',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight:
                                              FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      const Icon(
                                        Icons
                                            .arrow_forward_rounded,
                                        size: 20,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom text
            Positioned(
              left: 0,
              right: 0,
              bottom: 25,
              child: FadeTransition(
                opacity: _contentOpacity,
                child: Center(
                  child: Text(
                    'YOUR DAY • YOUR PLACES • YOUR REMINDERS',
                    style: AppText.body(
                      size: 9,
                      weight: FontWeight.w600,
                      color: AppColors.textLow,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}