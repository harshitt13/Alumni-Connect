import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import 'firebase_options.dart';
import 'theme/app_theme.dart';
import 'router/app_router.dart';
import 'data/app_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final prefs = await SharedPreferences.getInstance();
  final onboardingComplete = prefs.getBool('onboarding_complete') ?? false;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppProvider()),
      ],
      child: AlumniConnectApp(showOnboarding: !onboardingComplete),
    ),
  );
}

class AlumniConnectApp extends StatelessWidget {
  final bool showOnboarding;

  const AlumniConnectApp({super.key, required this.showOnboarding});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        return MaterialApp(
          title: 'Alumni Connect',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: provider.themeMode,
          debugShowCheckedModeBanner: false,
          home: SplashScreen(
            nextScreen: showOnboarding
                ? OnboardingScreen(nextScreen: const _RouterApp())
                : const _RouterApp(),
          ),
        );
      },
    );
  }
}

class _RouterApp extends StatefulWidget {
  const _RouterApp();

  @override
  State<_RouterApp> createState() => _RouterAppState();
}

class _RouterAppState extends State<_RouterApp> {
  GoRouter? _router;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<AppProvider>(context, listen: false);
    _checkAutoLogin(provider);
  }

  void _checkAutoLogin(AppProvider provider) async {
    final result = await provider.tryAutoLogin();
    if (result == 'ADMIN') {
      _router = createRouter('/admin-home');
    } else if (result == 'USER') {
      _router = createRouter('/home');
    } else {
      _router = createRouter('/login');
    }
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (_router == null) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }
    
    return MaterialApp.router(
      title: 'Alumni Connect',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: Provider.of<AppProvider>(context).themeMode,
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}
