import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/constants.dart';
import '../timer_setup_screen.dart';

class IntroScreen1 extends StatefulWidget {
  const IntroScreen1({super.key});

  @override
  State<IntroScreen1> createState() => _IntroScreen1State();
}

class _IntroScreen1State extends State<IntroScreen1> with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animationController;
  late AnimationController _iconAnimationController;
  late AnimationController _backgroundController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _backgroundAnimation;
  
  int _currentPage = 0;
  final int _totalPages = 4; // Welcome, Features, How it works, Terms
  bool _agreedToTerms = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    
    // Animation controllers with smoother durations
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _iconAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _backgroundController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );
    
    // Smooth animations with better curves
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutQuart,
    ));
    

    
    _backgroundAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _backgroundController,
      curve: Curves.easeInOutSine,
    ));
    
    // Start animations with delays for smoothness
    _animationController.forward();
    _backgroundController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    _iconAnimationController.dispose();
    _backgroundController.dispose();
    super.dispose();
  }

  Future<void> _nextPage() async {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutQuart,
      );
    } else if (_currentPage == _totalPages - 1 && _agreedToTerms) {
      // Complete onboarding and navigate to timer setup
      await _completeOnboarding();
    }
  }

  Future<void> _completeOnboarding() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Mark onboarding as complete
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(AppConstants.keyFirstLaunch, false);
      await prefs.setBool(AppConstants.keyOnboardingComplete, true);

      if (mounted) {
        // Navigate to timer setup with smooth transition
        Navigator.of(context).pushAndRemoveUntil(
        PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const TimerSetupScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                    begin: const Offset(0.0, 0.3),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                    curve: Curves.easeInOut,
                )),
                child: child,
              ),
            );
          },
            transitionDuration: const Duration(milliseconds: 600),
          ),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppConstants.errorColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutQuart,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF8FAFF),
              Color(0xFFEEF4FF),
              Color(0xFFF0F7FF),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Modern progress indicator
              _buildProgressIndicator(),
              
              // PageView with enhanced design and smooth physics
            Expanded(
              child: PageView(
                controller: _pageController,
                  physics: const BouncingScrollPhysics(),
                  pageSnapping: true,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                      if (index == 3) _agreedToTerms = false; // Reset terms on terms page
                  });
                    
                                        // Smooth animation restart with slight delay
                  _animationController.reset();
                    
                    Future.delayed(const Duration(milliseconds: 100), () {
                      if (mounted) {
                  _animationController.forward();
                      }
                    });
                },
                children: [
                    _buildWelcomePage(),
                    _buildFeaturesPage(),
                    _buildHowItWorksPage(),
                    _buildTermsPage(),
                ],
              ),
            ),
            
              // Enhanced navigation
              _buildNavigationSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.largePadding,
        vertical: AppConstants.padding,
      ),
      child: Row(
        children: List.generate(_totalPages, (index) {
          bool isActive = index <= _currentPage;
          bool isCurrent = index == _currentPage;
          
          return Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              height: isCurrent ? 6 : 4,
              margin: EdgeInsets.only(
                right: index < _totalPages - 1 ? 8 : 0,
              ),
              decoration: BoxDecoration(
                gradient: isActive
                    ? AppConstants.primaryGradient
                    : null,
                color: isActive
                    ? null
                    : AppConstants.stoneGray.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(3),
                boxShadow: isCurrent
                    ? [
                        BoxShadow(
                          color: AppConstants.softBlue.withValues(alpha: 0.4),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ]
                    : null,
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildWelcomePage() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Transform.translate(
        offset: Offset(0, (1 - _fadeAnimation.value) * 20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: AppConstants.largePadding),
            child: Column(
              children: [
                const Spacer(),
                
              // Animated logo/icon
              FadeTransition(
                opacity: _fadeAnimation,
                      child: Transform.scale(
                  scale: 0.8 + (_fadeAnimation.value * 0.2),
                  child: AnimatedBuilder(
                    animation: _backgroundAnimation,
                    builder: (context, child) {
                      return Container(
                        width: 160,
                        height: 160,
                          decoration: BoxDecoration(
                          gradient: RadialGradient(
                            colors: [
                              AppConstants.softBlue.withValues(alpha: 0.1 + (_backgroundAnimation.value * 0.1)),
                              AppConstants.mutedGreen.withValues(alpha: 0.05 + (_backgroundAnimation.value * 0.05)),
                              Colors.transparent,
                            ],
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Container(
                          margin: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: AppConstants.primaryGradient,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppConstants.softBlue.withValues(alpha: 0.3),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.psychology_rounded,
                            size: 80,
                            color: Colors.white,
                        ),
                      ),
                    );
                  },
                  ),
                ),
                ),
                
              const SizedBox(height: AppConstants.extraLargePadding),
                
              // Welcome title
                FadeTransition(
                  opacity: _fadeAnimation,
                child: ShaderMask(
                  shaderCallback: (bounds) => AppConstants.primaryGradient
                      .createShader(bounds),
                    child: Text(
                    'Welcome to Dtox',
                                      style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.2,
                    ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                
                const SizedBox(height: AppConstants.padding),
                
              // Subtitle
                FadeTransition(
                  opacity: _fadeAnimation,
                    child: Text(
                  'Break free from digital distractions',
                                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: AppConstants.textMedium,
                    height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                  ),
                ),
                
                  const SizedBox(height: AppConstants.largePadding),
              
              // Description
                  FadeTransition(
                    opacity: _fadeAnimation,
                child: Container(
                  padding: const EdgeInsets.all(AppConstants.largePadding),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppConstants.softBlue.withValues(alpha: 0.2),
                    ),
                  ),
                        child: Text(
                    'Take control of your digital life and break free from mindless scrolling. Start your journey to better focus, productivity, and peace of mind.',
                         style: const TextStyle(
                            fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: AppConstants.textMedium,
                      height: 1.6,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                
                const Spacer(),
              ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturesPage() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Transform.translate(
        offset: Offset(0, (1 - _fadeAnimation.value) * 20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: AppConstants.largePadding),
            child: Column(
              children: [
                  const SizedBox(height: AppConstants.largePadding),
              
              // Title
                FadeTransition(
                  opacity: _fadeAnimation,
                    child: Text(
                  'Why Digital Detox?',
                 style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppConstants.textDark,
                    height: 1.2,
                  ),
                      textAlign: TextAlign.center,
                  ),
                ),
                
                const SizedBox(height: AppConstants.padding),
                
              // Subtitle
                FadeTransition(
                  opacity: _fadeAnimation,
                    child: Text(
                  'Transform your relationship with technology',
                         style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                    color: AppConstants.textMedium,
                            height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                  ),
                ),
                
              const SizedBox(height: AppConstants.extraLargePadding),
                
              // Features grid
                Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                      _buildModernFeatureCard(
                        icon: Icons.psychology_rounded,
                        title: 'Mental Clarity',
                        description: 'Reduce information overload and think more clearly',
                        gradient: const LinearGradient(
                          colors: [Color(0xFF4CAF50), Color(0xFF8BC34A)],
                        ),
                      ),
                      const SizedBox(height: AppConstants.padding),
                      _buildModernFeatureCard(
                        icon: Icons.bedtime_rounded,
                        title: 'Better Sleep',
                        description: 'Improve sleep quality by reducing screen time',
                        gradient: const LinearGradient(
                          colors: [Color(0xFF2196F3), Color(0xFF03DAC6)],
                        ),
                      ),
                      const SizedBox(height: AppConstants.padding),
                      _buildModernFeatureCard(
                        icon: Icons.favorite_rounded,
                        title: 'Reduced Stress',
                        description: 'Lower anxiety and stress from constant notifications',
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF9800), Color(0xFFFFB74D)],
                        ),
                      ),
                      const SizedBox(height: AppConstants.padding),
                      _buildModernFeatureCard(
                        icon: Icons.trending_up_rounded,
                        title: 'Increased Productivity',
                        description: 'Focus better and accomplish more in less time',
                        gradient: const LinearGradient(
                          colors: [Color(0xFF9C27B0), Color(0xFFBA68C8)],
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
    );
  }

  Widget _buildModernFeatureCard({
    required IconData icon,
    required String title,
    required String description,
    required LinearGradient gradient,
  }) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Transform.translate(
        offset: Offset(0, (1 - _fadeAnimation.value) * 10),
        child: Container(
          padding: const EdgeInsets.all(AppConstants.largePadding),
      decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                spreadRadius: 0,
                offset: const Offset(0, 10),
              ),
            ],
      ),
      child: Row(
        children: [
          Container(
                width: 60,
                height: 60,
            decoration: BoxDecoration(
                  gradient: gradient,
                  borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
                  color: Colors.white,
                  size: 28,
            ),
          ),
              const SizedBox(width: AppConstants.largePadding),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                 style: const TextStyle(
                        fontSize: 18,
                    fontWeight: FontWeight.w600,
                        color: AppConstants.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                 style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                        color: AppConstants.textMedium,
                        height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
          ),
        ),
      ),
    );
  }

  Widget _buildHowItWorksPage() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Transform.translate(
        offset: Offset(0, (1 - _fadeAnimation.value) * 20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: AppConstants.largePadding),
            child: Column(
              children: [
              const SizedBox(height: AppConstants.largePadding),
              
              // Animated icon
                FadeTransition(
                  opacity: _fadeAnimation,
                      child: Transform.scale(
                  scale: 0.8 + (_fadeAnimation.value * 0.2),
                  child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                      gradient: AppConstants.primaryGradient,
                      shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                          color: AppConstants.softBlue.withValues(alpha: 0.3),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                    child: const Icon(
                      Icons.shield_rounded,
                            size: 60,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: AppConstants.extraLargePadding),
              
              // Title
                FadeTransition(
                  opacity: _fadeAnimation,
                    child: Text(
                  'How Dtox Works',
                 style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppConstants.textDark,
                    height: 1.2,
                      ),
                      textAlign: TextAlign.center,
                  ),
                ),
                
                const SizedBox(height: AppConstants.largePadding),
                
              // Steps
                Expanded(
                        child: Column(
                          children: [
                    _buildStepCard(
                      number: '1',
                      title: 'Set Your Timer',
                      description: 'Choose your detox duration from 15 minutes to 7 days',
                      color: AppConstants.mutedGreen,
                    ),
                    const SizedBox(height: AppConstants.padding),
                    _buildStepCard(
                      number: '2',
                      title: 'Apps Get Blocked',
                      description: 'Only essential apps like Phone, Camera, and Maps remain accessible',
                            color: AppConstants.softBlue,
                          ),
                    const SizedBox(height: AppConstants.padding),
                    _buildStepCard(
                      number: '3',
                      title: 'Stay Committed',
                      description: 'Breaking early requires a ₹50 penalty to keep you motivated',
                      color: AppConstants.warningColor,
                    ),
                  ],
                ),
              ),
            ],
          ),
                        ),
                      ),
                    );
  }

  Widget _buildStepCard({
    required String number,
    required String title,
    required String description,
    required Color color,
  }) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Transform.translate(
        offset: Offset(0, (1 - _fadeAnimation.value) * 10),
        child: Container(
          padding: const EdgeInsets.all(AppConstants.largePadding),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.1),
                blurRadius: 15,
                spreadRadius: 2,
                            ),
                          ],
                        ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    number,
                   style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppConstants.largePadding),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                     style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppConstants.textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                     style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: AppConstants.textMedium,
                        height: 1.4,
                  ),
                ),
              ],
            ),
              ),
            ],
          ),
        ),
      ),
    );
  }



  Widget _buildTermsPage() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Transform.translate(
        offset: Offset(0, (1 - _fadeAnimation.value) * 20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: AppConstants.largePadding),
            child: Column(
              children: [
                const SizedBox(height: AppConstants.largePadding),
                
              // Animated icon
                FadeTransition(
                  opacity: _fadeAnimation,
                      child: Transform.scale(
                  scale: 0.8 + (_fadeAnimation.value * 0.2),
                  child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                      ),
                      shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                          color: const Color(0xFF6366F1).withValues(alpha: 0.3),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                    child: const Icon(
                      Icons.security_rounded,
                            size: 60,
                      color: Colors.white,
                          ),
                        ),
                      ),
                ),
                
              const SizedBox(height: AppConstants.extraLargePadding),
                
              // Title
                FadeTransition(
                  opacity: _fadeAnimation,
                    child: Text(
                  'Privacy & Terms',
                 style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppConstants.textDark,
                    height: 1.2,
                  ),
                      textAlign: TextAlign.center,
                ),
              ),
              
              const SizedBox(height: AppConstants.largePadding),
              
              // Privacy highlights
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildPrivacyCard(
                        icon: Icons.lock_rounded,
                        title: 'Your Privacy Matters',
                        description: 'We don\'t collect, store, or share your personal data. Everything stays on your device.',
                        color: AppConstants.mutedGreen,
                      ),
                const SizedBox(height: AppConstants.padding),
                      _buildPrivacyCard(
                        icon: Icons.shield_rounded,
                        title: 'Secure by Design',
                        description: 'App permissions are used only for blocking functionality. No data leaves your phone.',
                        color: AppConstants.softBlue,
                      ),
                      const SizedBox(height: AppConstants.padding),
                      _buildPrivacyCard(
                        icon: Icons.account_balance_rounded,
                        title: 'Fair Usage',
                        description: 'Break penalty applies only when you exit detox early. Stay committed to your goals.',
                        color: AppConstants.warningColor,
                      ),
                      const SizedBox(height: AppConstants.extraLargePadding),
                      
                      // Agreement checkbox
                FadeTransition(
                  opacity: _fadeAnimation,
                        child: Transform.translate(
                          offset: Offset(0, (1 - _fadeAnimation.value) * 15),
                          child: Container(
                            padding: const EdgeInsets.all(AppConstants.largePadding),
                            decoration: BoxDecoration(
                              color: _agreedToTerms 
                                  ? AppConstants.softBlue.withValues(alpha: 0.1)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: _agreedToTerms 
                                    ? AppConstants.softBlue
                                    : AppConstants.stoneGray,
                                width: 2,
                              ),
                            ),
                            child: Row(
                              children: [
                                Transform.scale(
                                  scale: 1.2,
                                  child: Checkbox(
                                    value: _agreedToTerms,
                                    onChanged: (value) {
                                      setState(() {
                                        _agreedToTerms = value ?? false;
                                      });
                                    },
                                    activeColor: AppConstants.softBlue,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: AppConstants.padding),
                                Expanded(
                    child: Text(
                                    'I agree to the Terms & Conditions and Privacy Policy',
                                     style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: _agreedToTerms 
                                          ? AppConstants.softBlue
                                          : AppConstants.textMedium,
                                    ),
                                  ),
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
    );
  }

  Widget _buildPrivacyCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.largePadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(width: AppConstants.largePadding),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                 style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppConstants.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                 style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: AppConstants.textMedium,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationSection() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.largePadding),
      child: Row(
        children: [
          // Back button (only show if not on first page)
          if (_currentPage > 0) ...[
            Expanded(
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: AppConstants.stoneGray,
                    width: 1.5,
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _previousPage,
                    borderRadius: BorderRadius.circular(28),
                    child: Center(
                      child: Text(
                        'Back',
                       style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppConstants.textMedium,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppConstants.padding),
          ],
          
          // Next/Get Started button
          Expanded(
            flex: _currentPage > 0 ? 2 : 1,
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                gradient: (_currentPage == _totalPages - 1 && !_agreedToTerms)
                    ? null
                    : AppConstants.primaryGradient,
                color: (_currentPage == _totalPages - 1 && !_agreedToTerms)
                    ? AppConstants.stoneGray.withValues(alpha: 0.3)
                    : null,
                borderRadius: BorderRadius.circular(28),
                boxShadow: (_currentPage == _totalPages - 1 && !_agreedToTerms)
                    ? null
                    : [
                        BoxShadow(
                          color: AppConstants.softBlue.withValues(alpha: 0.3),
                          blurRadius: 15,
                          spreadRadius: 1,
                          offset: const Offset(0, 5),
                        ),
                      ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: (_currentPage == _totalPages - 1 && !_agreedToTerms) 
                      ? null 
                      : () => _nextPage(),
                  borderRadius: BorderRadius.circular(28),
                  child: Center(
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _currentPage == _totalPages - 1
                                    ? 'Get Started'
                                    : 'Continue',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: (_currentPage == _totalPages - 1 && !_agreedToTerms)
                                      ? AppConstants.textMedium
                                      : Colors.white,
                                ),
                              ),
                              if (_currentPage < _totalPages - 1) ...[
                                const SizedBox(width: 8),
                                Icon(
                                  Icons.arrow_forward_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ],
                            ],
                          ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
} 