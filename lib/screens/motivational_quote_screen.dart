import 'package:flutter/material.dart';
import 'dart:async';
import '../utils/constants.dart';

class MotivationalQuoteScreen extends StatefulWidget {
  const MotivationalQuoteScreen({super.key});

  @override
  State<MotivationalQuoteScreen> createState() => _MotivationalQuoteScreenState();
}

class _MotivationalQuoteScreenState extends State<MotivationalQuoteScreen> 
    with TickerProviderStateMixin {
  late Timer _timer;
  int _currentIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  final List<Map<String, dynamic>> _benefits = [
    {
      'text': 'Helps reduce stress by taking a break from constant notifications.',
      'icon': Icons.notifications_off,
      'color': AppConstants.primaryColor,
      'gradient': [AppConstants.primaryColor, AppConstants.primaryColor.withOpacity(0.7)],
    },
    {
      'text': 'Can lower anxiety and boost your mental health.',
      'icon': Icons.psychology,
      'color': AppConstants.accentColor,
      'gradient': [AppConstants.accentColor, AppConstants.accentColor.withOpacity(0.7)],
    },
    {
      'text': 'Increases productivity and focus, as you\'re less distracted by screens.',
      'icon': Icons.trending_up,
      'color': AppConstants.successColor,
      'gradient': [AppConstants.successColor, AppConstants.successColor.withOpacity(0.7)],
    },
    {
      'text': 'Improves your self-esteem by reducing social comparison on social media.',
      'icon': Icons.self_improvement,
      'color': AppConstants.warningColor,
      'gradient': [AppConstants.warningColor, AppConstants.warningColor.withOpacity(0.7)],
    },
    {
      'text': 'Contributes to better quality sleep by limiting blue light exposure.',
      'icon': Icons.bedtime,
      'color': const Color(0xFF9B59B6),
      'gradient': [const Color(0xFF9B59B6), const Color(0xFF8E44AD)],
    },
    {
      'text': 'Reduces eye strain, headaches, and physical discomfort caused by excessive screen time.',
      'icon': Icons.visibility,
      'color': const Color(0xFFE67E22),
      'gradient': [const Color(0xFFE67E22), const Color(0xFFD35400)],
    },
    {
      'text': 'Promotes mindfulness and being present in the moment.',
      'icon': Icons.spa,
      'color': const Color(0xFF16A085),
      'gradient': [const Color(0xFF16A085), const Color(0xFF138D75)],
    },
    {
      'text': 'Allows you to reconnect with nature and your surroundings.',
      'icon': Icons.nature,
      'color': const Color(0xFF27AE60),
      'gradient': [const Color(0xFF27AE60), const Color(0xFF229954)],
    },
    {
      'text': 'Improves your ability to regulate emotions and self-control.',
      'icon': Icons.psychology_alt,
      'color': const Color(0xFF8E44AD),
      'gradient': [const Color(0xFF8E44AD), const Color(0xFF7D3C98)],
    },
    {
      'text': 'Reduces risk of digital addiction and excessive device dependency.',
      'icon': Icons.phone_disabled,
      'color': const Color(0xFFE74C3C),
      'gradient': [const Color(0xFFE74C3C), const Color(0xFFC0392B)],
    },
    {
      'text': 'Enhances overall life satisfaction.',
      'icon': Icons.favorite,
      'color': const Color(0xFFE91E63),
      'gradient': [const Color(0xFFE91E63), const Color(0xFFC2185B)],
    },
    {
      'text': 'Provides greater contentment and calmness by living outside of screen-based routines.',
      'icon': Icons.sentiment_satisfied,
      'color': const Color(0xFF00BCD4),
      'gradient': [const Color(0xFF00BCD4), const Color(0xFF0097A7)],
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _startTimer();
    _animationController.forward();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 6), (timer) {
      if (mounted) {
        _changeBenefit();
      }
    });
  }

  void _changeBenefit() {
    _animationController.reverse().then((_) {
      if (mounted) {
        setState(() {
          _currentIndex = (_currentIndex + 1) % _benefits.length;
        });
        _animationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Digital Detox Benefits',
         style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_back, size: 20),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF6366f1),
              Color(0xFF8b5cf6),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Section
                  _buildHeaderSection(),
                  
                  const SizedBox(height: 24),
                  
                  // Current Benefit Card
                  _buildBenefitCard(),
                  
                  const SizedBox(height: 24),
                  
                  // Navigation Controls
                  _buildNavigationControls(),
                  
                  const SizedBox(height: 16),
                  
                  // Auto-play indicator
                  _buildAutoplayIndicator(),
                  
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildHeaderSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.lightbulb_outline,
              size: 40,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Why Digital Detox?',
           style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Discover the amazing benefits of taking a break from your devices',
           style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Colors.white.withOpacity(0.9),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  Widget _buildBenefitCard() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withOpacity(0.2),
              Colors.white.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon with animated background
            Stack(
              alignment: Alignment.center,
              children: [
                // Animated background circles
                ...List.generate(3, (index) {
                  final double size = 80 + (index * 20);
                  final double opacity = 0.1 - (index * 0.03);
                  
                  return Container(
                    width: size,
                    height: size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(opacity),
                    ),
                  );
                }),
                
                // Icon container
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _benefits[_currentIndex]['icon'],
                    size: 40,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Benefit text
            Text(
              _benefits[_currentIndex]['text'],
             style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 24),
            
            // Progress Indicators
            SizedBox(
              height: 8,
              child: ListView.builder(
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                itemCount: _benefits.length,
                itemBuilder: (context, index) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: index == _currentIndex ? 24 : 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: index == _currentIndex
                          ? Colors.white
                          : Colors.white.withOpacity(0.3),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildNavigationControls() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Previous button
          _buildNavButton(
            icon: Icons.arrow_back_ios_rounded,
            onPressed: () {
              _animationController.reverse().then((_) {
                if (mounted) {
                  setState(() {
                    _currentIndex = (_currentIndex - 1 + _benefits.length) % _benefits.length;
                  });
                  _animationController.forward();
                }
              });
            },
          ),
          
          // Counter
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${_currentIndex + 1} / ${_benefits.length}',
             style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          
          // Next button
          _buildNavButton(
            icon: Icons.arrow_forward_ios_rounded,
            onPressed: () => _changeBenefit(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildNavButton({required IconData icon, required VoidCallback onPressed}) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }
  
  Widget _buildAutoplayIndicator() {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.play_circle_outline_rounded,
              color: Colors.white,
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(
              'Auto-rotates every 6 seconds',
             style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 