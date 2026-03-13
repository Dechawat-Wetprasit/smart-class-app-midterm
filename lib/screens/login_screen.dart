import 'dart:async';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/app_notification.dart';
import 'home_screen.dart';
import '../services/database_helper.dart';
import '../services/firestore_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _studentIdController = TextEditingController();
  final _nameController = TextEditingController();
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final FirestoreService _firestoreService = FirestoreService();
  bool _isLoading = false;
  bool _isNameLocked = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _studentIdController.addListener(_onStudentIdChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _studentIdController.removeListener(_onStudentIdChanged);
    _studentIdController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _onStudentIdChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 1000), () {
      final id = _studentIdController.text.trim();
      if (id.length >= 3) {
        _checkExistingUser(id);
      } else if (id.isEmpty) {
        setState(() {
          _isNameLocked = false;
          _nameController.clear();
        });
      }
    });
  }

  Future<void> _checkExistingUser(String studentId) async {
    try {
      // Check local DB
      var user = await _dbHelper.getUser(studentId);
      
      // If not in local, check Firestore
      if (user == null) {
        final firestoreUser = await _firestoreService.getUser(studentId);
        if (firestoreUser != null) {
          user = UserProfile(
            studentId: firestoreUser['studentId'],
            name: firestoreUser['name'],
          );
        }
      }

      if (user != null && mounted) {
        setState(() {
          _nameController.text = user!.name;
          _isNameLocked = true;
        });
        AppNotification.showSnackBar(
          context, 
          'Welcome back, ${user.name}!', 
          icon: Icons.face_rounded,
        );
      } else if (mounted) {
        setState(() {
          _isNameLocked = false;
        });
      }
    } catch (e) {
      debugPrint('Check user error: $e');
    }
  }

  Future<void> _login() async {
    final studentId = _studentIdController.text.trim();
    final name = _nameController.text.trim();

    if (studentId.isEmpty || name.isEmpty) {
      AppNotification.showWarning(context, 'Please enter both Student ID and Name');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. Check local DB first
      var existingUser = await _dbHelper.getUser(studentId);
      
      // 2. If not in local, check Firestore
      if (existingUser == null) {
        final firestoreUser = await _firestoreService.getUser(studentId);
        if (firestoreUser != null) {
          existingUser = UserProfile(
            studentId: firestoreUser['studentId'],
            name: firestoreUser['name'],
          );
          // Sync to local
          await _dbHelper.saveUser(existingUser);
        }
      }

      // 3. Validate
      if (existingUser != null) {
        if (existingUser.name.toLowerCase() != name.toLowerCase()) {
          if (mounted) {
            AppNotification.showWarning(context, 'This Student ID is already registered to: ${existingUser.name}');
          }
          return;
        }
      } else {
        // 4. New User Registration
        final newUser = UserProfile(studentId: studentId, name: name);
        await _dbHelper.saveUser(newUser);
        await _firestoreService.saveUser(studentId, name);
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('studentId', studentId);
      await prefs.setString('studentName', name);

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        AppNotification.showError(context, 'Login failed: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo / Icon
                  FadeInDown(
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppTheme.primaryGradient,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.accentBlue.withValues(alpha: 0.4),
                            blurRadius: 24,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.school_rounded,
                        color: Colors.white,
                        size: 50,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Title
                  FadeInDown(
                    delay: const Duration(milliseconds: 100),
                    child: ShaderMask(
                      shaderCallback: (bounds) =>
                          AppTheme.primaryGradient.createShader(bounds),
                      child: const Text(
                        'Smart Class',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  FadeInDown(
                    delay: const Duration(milliseconds: 200),
                    child: Text(
                      'Welcome! Please verify your identity.',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 48),

                  // Login Form Card
                  FadeInUp(
                    delay: const Duration(milliseconds: 300),
                    child: GlassCard(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          // Student ID Input
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Student ID',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _studentIdController,
                                style: const TextStyle(color: Colors.white),
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  hintText: 'e.g., 6731503011',
                                  hintStyle: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.3)),
                                  prefixIcon: Icon(Icons.badge_rounded,
                                      color: AppTheme.accentBlue),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Name Input
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Full Name',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _nameController,
                                readOnly: _isNameLocked,
                                style: TextStyle(
                                  color: _isNameLocked ? Colors.white70 : Colors.white,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Enter your name',
                                  hintStyle: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.3)),
                                  prefixIcon: Icon(
                                    Icons.person_rounded,
                                    color: _isNameLocked ? AppTheme.accentGreen : AppTheme.accentBlue,
                                  ),
                                  suffixIcon: _isNameLocked 
                                    ? const Tooltip(
                                        message: 'ID already registered',
                                        child: Icon(Icons.verified_user_rounded, color: AppTheme.accentGreen, size: 20),
                                      )
                                    : null,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),

                          // Login Button
                          SizedBox(
                            width: double.infinity,
                            child: GradientButton(
                              text: 'Continue',
                              icon: Icons.login_rounded,
                              gradient: AppTheme.primaryGradient,
                              isLoading: _isLoading,
                              onPressed: _isLoading ? () {} : _login,
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
        ),
      ),
    );
  }
}
