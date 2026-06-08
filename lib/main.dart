import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dashboard/core/theme/app_theme.dart';
import 'dashboard/core/services/supabase_service.dart';
import 'dashboard/core/models/models.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/app_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  // Initialize Supabase
  await SupabaseService.initialize();

  runApp(const TrafficCamApp());
}

class TrafficCamApp extends StatelessWidget {
  const TrafficCamApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TrafficCam',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const _AuthGate(),
    );
  }
}

class _AuthGate extends StatefulWidget {
  const _AuthGate();

  @override
  State<_AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<_AuthGate> {
  final _supabase = SupabaseService();
  bool _checking = true;
  Officer? _officer;

  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    // Listen to auth state changes
    _supabase.authStateChanges.listen((event) async {
      if (event.session != null) {
        final officer = await _supabase.getOfficerProfile(
          event.session!.user.id,
        );
        if (mounted) {
          setState(() {
            _officer = officer ?? _mockOfficer(event.session!.user.id);
            _checking = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _officer = null;
            _checking = false;
          });
        }
      }
    });

    // Check existing session
    final existing = SupabaseService.client.auth.currentSession;
    if (existing == null) {
      setState(() => _checking = false);
    }
  }

  /// Mock officer for development (no real Supabase configured yet)
  Officer _mockOfficer(String userId) => Officer(
        id: userId,
        badgeNumber: '10234',
        fullName: 'Agent Mohamed Ben Ali',
        phoneNumber: '+216 55 123 456',
        status: OfficerStatus.onDuty,
        latitude: 36.8065,
        longitude: 10.1815,
        currentZone: 'Centre Ville, Tunis',
        lastSeen: DateTime.now(),
      );

  void _onLoginSuccess() async {
    final user = SupabaseService.client.auth.currentUser;
    if (user == null) return;
    final officer = await _supabase.getOfficerProfile(user.id);
    setState(() => _officer = officer ?? _mockOfficer(user.id));
  }

  @override
  Widget build(BuildContext context) {
    if (_checking) {
      return const Scaffold(
        backgroundColor: AppColors.bgDark,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: AppColors.accent),
              SizedBox(height: 16),
              Text(
                'TrafficCam',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontFamily: 'Montserrat',
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_officer != null) {
      return AppShell(officer: _officer!);
    }

    return LoginScreen(onLoginSuccess: _onLoginSuccess);
  }
}