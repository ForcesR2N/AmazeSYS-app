import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import '../controllers/splash_controller.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF2847BA), // Try this color first
      body: SplashScreenContent(),
    );
  }
}

class SplashScreenContent extends StatefulWidget {
  const SplashScreenContent({super.key});

  @override
  State<SplashScreenContent> createState() => _SplashScreenContentState();
}

class _SplashScreenContentState extends State<SplashScreenContent>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _lottieController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  SplashController? _splashController;
  bool _animationCompleted = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimationSequence();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _lottieController = AnimationController(vsync: this);

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeIn));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _scaleController, curve: Curves.easeOut));
  }

  void _startAnimationSequence() {
    if (!mounted) return;

    _fadeController.forward();

    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        _scaleController.forward();
      }
    });
  }

  void _onLottieAnimationLoaded(LottieComposition composition) {
    if (!mounted) return;

    print(
      'SplashScreen: Lottie animation loaded - Duration: ${composition.duration}',
    );

    _lottieController.duration = composition.duration;
    _lottieController.forward();
    _lottieController.addStatusListener(_onAnimationStatus);
  }

  void _onAnimationStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed &&
        mounted &&
        !_animationCompleted) {
      print('SplashScreen: Lottie animation completed');
      _animationCompleted = true;
      _notifyControllerAnimationComplete();
    }
  }

  void _notifyControllerAnimationComplete() {
    try {
      _splashController ??= Get.find<SplashController>();
      _splashController?.onAnimationComplete();
      print('SplashScreen: Notified controller of completion');
    } catch (e) {
      print('SplashScreen: Error notifying controller: $e');
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          try {
            _splashController = Get.find<SplashController>();
            _splashController?.onAnimationComplete();
          } catch (e2) {
            print('SplashScreen: Fallback also failed: $e2');
          }
        }
      });
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _lottieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_fadeAnimation, _scaleAnimation]),
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            alignment: Alignment.center,
            child: SizedBox.expand(
              child: Lottie.asset(
                'asset/animation-splash-screen.json',
                controller: _lottieController,
                fit: BoxFit.cover, // ← Changed from cover to fill = NO SPACE
                repeat: false,
                animate: true,
                onLoaded: _onLottieAnimationLoaded,
                errorBuilder: (context, error, stackTrace) {
                  print('SplashScreen: Lottie error: $error');

                  if (!_animationCompleted) {
                    Future.delayed(const Duration(milliseconds: 1500), () {
                      if (mounted && !_animationCompleted) {
                        _animationCompleted = true;
                        _notifyControllerAnimationComplete();
                      }
                    });
                  }

                  return _buildFallbackIcon(context);
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFallbackIcon(BuildContext context) {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
      ),
      child: Icon(
        Icons.app_registration,
        size: 100,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}
