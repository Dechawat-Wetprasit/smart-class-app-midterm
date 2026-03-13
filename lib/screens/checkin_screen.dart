import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/app_notification.dart';
import '../models/checkin_record.dart';
import '../services/database_helper.dart';
import '../services/firestore_service.dart';
import '../services/location_service.dart';
import 'qr_scanner_screen.dart';

class CheckInScreen extends StatefulWidget {
  const CheckInScreen({super.key});

  @override
  State<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends State<CheckInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _previousTopicController = TextEditingController();
  final _expectedTopicController = TextEditingController();
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final FirestoreService _firestoreService = FirestoreService();
  String _studentId = '';

  int _currentStep = 0; // 0: GPS, 1: QR, 2: Form
  int _selectedMood = 0;
  double? _latitude;
  double? _longitude;
  String? _qrData;
  bool _isLoadingGPS = false;
  bool _isSubmitting = false;
  DateTime? _timestamp;
  
  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _studentId = prefs.getString('studentId') ?? 'unknown';
    });
  }

  @override
  void dispose() {
    _previousTopicController.dispose();
    _expectedTopicController.dispose();
    super.dispose();
  }

  Future<void> _getLocation() async {
    setState(() => _isLoadingGPS = true);
    try {
      final position = await LocationService.getCurrentLocation();
      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
        _timestamp = DateTime.now();
        _isLoadingGPS = false;
        _currentStep = 1;
      });
    } catch (e) {
      setState(() => _isLoadingGPS = false);
      if (mounted) {
        AppNotification.showError(context, e.toString());
      }
    }
  }

  Future<void> _scanQR() async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const QRScannerScreen()),
    );
    if (result != null) {
      setState(() {
        _qrData = result;
        _currentStep = 2;
      });
    }
  }

  Future<void> _submitCheckIn() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedMood == 0) {
      AppNotification.showWarning(context, 'Please select your mood');
      return;
    }

    setState(() => _isSubmitting = true);

    final record = CheckInRecord(
      studentId: _studentId,
      checkInTime: _timestamp ?? DateTime.now(),
      checkInLatitude: _latitude!,
      checkInLongitude: _longitude!,
      qrCodeData: _qrData!,
      previousTopic: _previousTopicController.text.trim(),
      expectedTopic: _expectedTopicController.text.trim(),
      moodBefore: _selectedMood,
    );

    try {
      await _dbHelper.insertCheckIn(record);
      // Try to sync to Firebase (non-blocking)
      _firestoreService.saveCheckIn(record);

      if (mounted) {
        _showSuccessDialog();
      }
    } catch (e) {
      setState(() => _isSubmitting = false);
      if (mounted) {
        AppNotification.showError(context, 'Error: $e');
      }
    }
  }

  void _showSuccessDialog() {
    AppNotification.showSuccessDialog(
      context,
      title: 'Check-in Successful!',
      message: 'You are now checked in to class.',
      buttonText: 'Done',
      onButtonPressed: () {
        Navigator.pop(context); // close dialog
        Navigator.pop(context); // back to home
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              // App Bar
              FadeInDown(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceLight.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      ShaderMask(
                        shaderCallback: (bounds) =>
                            AppTheme.primaryGradient.createShader(bounds),
                        child: const Text(
                          'Class Check-in',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Step Indicator
              FadeInDown(
                delay: const Duration(milliseconds: 200),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 10),
                  child: _buildStepIndicator(),
                ),
              ),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
                  child: _buildCurrentStep(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndicator() {
    final steps = [
      {'icon': Icons.location_on_rounded, 'label': 'GPS'},
      {'icon': Icons.qr_code_scanner_rounded, 'label': 'QR Code'},
      {'icon': Icons.edit_note_rounded, 'label': 'Reflect'},
    ];

    return Row(
      children: List.generate(3, (index) {
        final isCompleted = index < _currentStep;
        final isCurrent = index == _currentStep;
        return Expanded(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: isCompleted || isCurrent
                            ? AppTheme.primaryGradient
                            : null,
                        color: !isCompleted && !isCurrent
                            ? AppTheme.surfaceLight
                            : null,
                        boxShadow: isCurrent
                            ? [
                                BoxShadow(
                                  color: AppTheme.accentBlue.withValues(alpha: 0.4),
                                  blurRadius: 12,
                                  spreadRadius: 2,
                                ),
                              ]
                            : [],
                      ),
                      child: Icon(
                        isCompleted
                            ? Icons.check_rounded
                            : steps[index]['icon'] as IconData,
                        color: isCompleted || isCurrent
                            ? Colors.white
                            : AppTheme.textSecondary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      steps[index]['label'] as String,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: isCurrent ? FontWeight.w600 : FontWeight.normal,
                        color: isCurrent
                            ? AppTheme.accentCyan
                            : AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (index < 2)
                Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    height: 2,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      gradient: isCompleted
                          ? AppTheme.primaryGradient
                          : null,
                      color: isCompleted ? null : AppTheme.surfaceLight,
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _buildGPSStep();
      case 1:
        return _buildQRStep();
      case 2:
        return _buildFormStep();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildGPSStep() {
    return FadeInUp(
      child: GlassCard(
        padding: const EdgeInsets.all(28),
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppTheme.primaryGradient,
              ),
              child: const Icon(
                Icons.my_location_rounded,
                color: Colors.white,
                size: 40,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Verify Your Location',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'We need to confirm you are in the classroom',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            if (_latitude != null) ...[
              AnimatedInfoTile(
                icon: Icons.location_on_rounded,
                title: 'Latitude',
                subtitle: _latitude!.toStringAsFixed(6),
                color: AppTheme.accentGreen,
              ),
              const SizedBox(height: 12),
              AnimatedInfoTile(
                icon: Icons.location_on_rounded,
                title: 'Longitude',
                subtitle: _longitude!.toStringAsFixed(6),
                color: AppTheme.accentGreen,
              ),
              const SizedBox(height: 20),
            ],
            SizedBox(
              width: double.infinity,
              child: GradientButton(
                text: _isLoadingGPS ? 'Getting Location...' : 'Get GPS Location',
                icon: Icons.gps_fixed_rounded,
                gradient: AppTheme.primaryGradient,
                isLoading: _isLoadingGPS,
                onPressed: _isLoadingGPS ? () {} : _getLocation,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQRStep() {
    return FadeInUp(
      child: GlassCard(
        padding: const EdgeInsets.all(28),
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppTheme.primaryGradient,
              ),
              child: const Icon(
                Icons.qr_code_scanner_rounded,
                color: Colors.white,
                size: 40,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Scan Class QR Code',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Scan the QR code displayed by your instructor',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            if (_latitude != null)
              Text(
                '📍 GPS: ${_latitude!.toStringAsFixed(4)}, ${_longitude!.toStringAsFixed(4)}',
                style: TextStyle(
                  color: AppTheme.accentGreen,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: GradientButton(
                text: 'Open QR Scanner',
                icon: Icons.camera_alt_rounded,
                gradient: AppTheme.primaryGradient,
                onPressed: _scanQR,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormStep() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status summary
          FadeInUp(
            child: GlassCard(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: AnimatedInfoTile(
                      icon: Icons.location_on_rounded,
                      title: 'GPS',
                      subtitle: '${_latitude!.toStringAsFixed(4)}, ${_longitude!.toStringAsFixed(4)}',
                      color: AppTheme.accentGreen,
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: AnimatedInfoTile(
                      icon: Icons.qr_code_rounded,
                      title: 'QR Code',
                      subtitle: _qrData ?? '',
                      color: AppTheme.accentBlue,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Previous Topic
          FadeInUp(
            delay: const Duration(milliseconds: 100),
            child: GlassCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.history_edu_rounded,
                          color: AppTheme.accentCyan, size: 20),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          'Previous Class Topic',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _previousTopicController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: 'What was covered in the last class?',
                    ),
                    maxLines: 2,
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Please enter the previous topic' : null,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Expected Topic
          FadeInUp(
            delay: const Duration(milliseconds: 200),
            child: GlassCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.lightbulb_outline_rounded,
                          color: AppTheme.accentOrange, size: 20),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          'Expected Topic Today',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _expectedTopicController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: 'What do you expect to learn today?',
                    ),
                    maxLines: 2,
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Please enter the expected topic' : null,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Mood
          FadeInUp(
            delay: const Duration(milliseconds: 300),
            child: GlassCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.mood_rounded,
                          color: AppTheme.accentPink, size: 20),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          'How do you feel about today\'s lesson?',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  MoodSelector(
                    selectedMood: _selectedMood,
                    onMoodSelected: (mood) => setState(() => _selectedMood = mood),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Submit Button
          FadeInUp(
            delay: const Duration(milliseconds: 400),
            child: SizedBox(
              width: double.infinity,
              child: GradientButton(
                text: 'Submit Check-in',
                icon: Icons.check_circle_rounded,
                gradient: AppTheme.greenGradient,
                isLoading: _isSubmitting,
                onPressed: _isSubmitting ? () {} : _submitCheckIn,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
