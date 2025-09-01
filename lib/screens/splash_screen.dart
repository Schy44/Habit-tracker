import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mytracker/theme/app_colors.dart';
import 'dart:async';
import 'dart:math' as math;
import 'package:firebase_auth/firebase_auth.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _progressController;
  late AnimationController _circleController;
  
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoFadeAnimation;
  late Animation<double> _textFadeAnimation;
  late Animation<Offset> _textSlideAnimation;
  late Animation<double> _progressAnimation;
  late Animation<double> _circleAnimation;

  @override
  void initState() {
    super.initState();
    
    // Set system UI style for splash
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );

    _initializeAnimations();
    _startAnimationSequence();
  }

  void _initializeAnimations() {
    // Logo animations
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _logoScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    ));

    _logoFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
    ));

    // Text animations
    _textController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _textFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeIn,
    ));

    _textSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeOutCubic,
    ));

    // Progress animation
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    ));

    // Background circles animation
    _circleController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    );

    _circleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _circleController,
      curve: Curves.linear,
    ));
  }

  void _startAnimationSequence() async {
    // Start background animation immediately
    _circleController.repeat();
    
    // Logo animation
    await Future.delayed(const Duration(milliseconds: 300));
    _logoController.forward();
    
    // Text animation
    await Future.delayed(const Duration(milliseconds: 800));
    _textController.forward();
    
    // Progress animation
    await Future.delayed(const Duration(milliseconds: 500));
    _progressController.forward();
    
    // Navigate after animations complete
    await Future.delayed(const Duration(milliseconds: 2500));
    _navigateToNextScreen();
  }

  void _navigateToNextScreen() {
    // Check if user is logged in and navigate accordingly
    Navigator.pushReplacementNamed(context, '/login'); // or '/home' if logged in
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _progressController.dispose();
    _circleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primary,
              AppColors.primary.withOpacity(0.8),
              AppColors.secondary.withOpacity(0.6),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Animated background circles
            _buildAnimatedBackground(),
            
            // Main content
            SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 2),
                  
                  // Logo section
                  _buildLogoSection(),
                  
                  const SizedBox(height: 32),
                  
                  // App name and tagline
                  _buildTextSection(),
                  
                  const Spacer(flex: 2),
                  
                  // Progress indicator
                  _buildProgressSection(),
                  
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _circleAnimation,
      builder: (context, child) {
        return Stack(
          children: [
            // Large background circle
            Positioned(
              top: -100 + (50 * math.sin(_circleAnimation.value * 2 * math.pi)),
              right: -150 + (30 * math.cos(_circleAnimation.value * 2 * math.pi)),
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
            ),
            
            // Medium background circle
            Positioned(
              bottom: -50 + (40 * math.cos(_circleAnimation.value * 1.5 * math.pi)),
              left: -100 + (60 * math.sin(_circleAnimation.value * 1.5 * math.pi)),
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.08),
                ),
              ),
            ),
            
            // Small background circles
            ...List.generate(6, (index) {
              final offset = (index * math.pi / 3) + (_circleAnimation.value * 2 * math.pi);
              return Positioned(
                top: MediaQuery.of(context).size.height * 0.3 + 
                     (100 * math.sin(offset)),
                left: MediaQuery.of(context).size.width * 0.5 + 
                      (120 * math.cos(offset)),
                child: Container(
                  width: 20 + (index * 8.0),
                  height: 20 + (index * 8.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.15 - (index * 0.02)),
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }

  Widget _buildLogoSection() {
    return AnimatedBuilder(
      animation: _logoController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _logoFadeAnimation,
          child: ScaleTransition(
            scale: _logoScaleAnimation,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 20,
                    spreadRadius: 5,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Outer ring
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primary,
                        width: 3,
                      ),
                    ),
                  ),
                  
                  // Inner design - habit tracking circles
                  _buildHabitCircles(),
                  
                  // Center icon
                  Icon(
                    Icons.check_circle_rounded,
                    size: 32,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHabitCircles() {
    return AnimatedBuilder(
      animation: _logoController,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: List.generate(8, (index) {
            final angle = (index * math.pi * 2 / 8) + 
                         (_logoController.value * math.pi * 2);
            final radius = 35.0;
            final x = radius * math.cos(angle);
            final y = radius * math.sin(angle);
            
            return Transform.translate(
              offset: Offset(x, y),
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: index < (_logoController.value * 8).floor()
                      ? AppColors.success
                      : AppColors.primary.withOpacity(0.3),
                ),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildTextSection() {
    return AnimatedBuilder(
      animation: _textController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _textFadeAnimation,
          child: SlideTransition(
            position: _textSlideAnimation,
            child: Column(
              children: [
                // App name
                Text(
                  'HabitTracker',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.2,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.3),
                        offset: const Offset(0, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 12),
                
                // Tagline
                Text(
                  'Build Better Habits, Live Better Life',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.9),
                    letterSpacing: 0.5,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.2),
                        offset: const Offset(0, 1),
                        blurRadius: 2,
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProgressSection() {
    return Column(
      children: [
        // Loading text
        AnimatedBuilder(
          animation: _progressAnimation,
          builder: (context, child) {
            return Opacity(
              opacity: _progressAnimation.value,
              child: Text(
                'Preparing your journey...',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.8),
                  letterSpacing: 0.5,
                ),
              ),
            );
          },
        ),
        
        const SizedBox(height: 16),
        
        // Progress bar
        Container(
          width: 200,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.3),
            borderRadius: BorderRadius.circular(2),
          ),
          child: AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              return Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  width: 200 * _progressAnimation.value,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.5),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Dots indicator
        _buildDotsIndicator(),
      ],
    );
  }

  Widget _buildDotsIndicator() {
    return AnimatedBuilder(
      animation: _progressAnimation,
      builder: (context, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (index) {
            final delay = index * 0.3;
            final animationValue = (_progressAnimation.value - delay).clamp(0.0, 1.0);
            
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              child: AnimatedContainer(
                duration: Duration(milliseconds: (300 + index * 100)),
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.4 + (animationValue * 0.6)),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
