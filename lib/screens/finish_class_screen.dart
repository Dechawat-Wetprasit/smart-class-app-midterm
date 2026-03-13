import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/app_notification.dart';
import '../models/checkin_record.dart';
import '../services/database_helper.dart';
import '../services/firestore_service.dart';
import '../services/location_service.dart';
import 'qr_scanner_screen.dart';

class FinishClassScreen extends StatefulWidget {
  final CheckInRecord record;

  const FinishClassScreen({super.key, required this.record});

  @override
  State<FinishClassScreen> createState() => _FinishClassScreenState();
}

class _FinishClassScreenState extends State<FinishClassScreen> {
  final _formKey = GlobalKey<FormState>();
  final _learnedController = TextEditingController();
  final _feedbackController = TextEditingController();
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final FirestoreService _firestoreService = FirestoreService();

  int _currentStep = 0; // 0: QR, 1: GPS, 2: Form
  int _understandingRating = 0;
  double? _latitude;
  double? _longitude;
  String? _qrData;
  bool _isLoadingGPS = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _learnedController.dispose();
    _feedbackController.dispose();
    super.dispose();
  }

  Future<void> _scanQR() async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const QRScannerScreen()),
    );
    if (result != null) {
      setState(() {
        _qrData = result;
        _currentStep = 1;
      });
    }
  }

  Future<void> _getLocation() async {
    setState(() => _isLoadingGPS = true);
    try {
      final position = await LocationService.getCurrentLocation();
      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
        _isLoadingGPS = false;
        _currentStep = 2;
      });
    } catch (e) {
      setState(() => _isLoadingGPS = false);
      if (mounted) {
        AppNotification.showError(context, e.toString());
      }
    }
  }

  Future<void> _submitFinish() async {
    if (!_formKey.currentState!.validate()) return;
    if (_understandingRating == 0) {
      AppNotification.showWarning(context, 'Please rate your understanding');
      return;
    }

    setState(() => _isSubmitting = true);

    final updatedRecord = widget.record.copyWith(
      checkOutTime: DateTime.now(),
      checkOutLatitude: _latitude,
      checkOutLongitude: _longitude,
      qrCodeDataOut: _qrData,
      learnedToday: _learnedController.text.trim(),
      understandingRating: _understandingRating,
      feedback: _feedbackController.text.trim(),
    );

    try {
      await _dbHelper.updateCheckOut(updatedRecord);
      _firestoreService.updateCheckOut(updatedRecord);

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
      title: 'Class Completed!',
      message: 'Great job! Your session has been recorded.',
      buttonText: 'Back to Home',
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
                            AppTheme.pinkGradient.createShader(bounds),
                        child: const Text(
                          'Finish Class',
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
      {'icon': Icons.qr_code_scanner_rounded, 'label': 'QR Code'},
      {'icon': Icons.location_on_rounded, 'label': 'GPS'},
      {'icon': Icons.rate_review_rounded, 'label': 'Feedback'},
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
                            ? AppTheme.pinkGradient
                            : null,
                        color: !isCompleted && !isCurrent
                            ? AppTheme.surfaceLight
                            : null,
                        boxShadow: isCurrent
                            ? [
                                BoxShadow(
                                  color: AppTheme.accentPink.withValues(alpha: 0.4),
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
                            ? AppTheme.accentPink
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
                          ? AppTheme.pinkGradient
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
        return _buildQRStep();
      case 1:
        return _buildGPSStep();
      case 2:
        return _buildFormStep();
      default:
        return const SizedBox.shrink();
    }
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
                gradient: AppTheme.pinkGradient,
              ),
              child: const Icon(
                Icons.qr_code_scanner_rounded,
                color: Colors.white,
                size: 40,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Scan QR Code Again',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Scan the class QR code to confirm you completed the session',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: GradientButton(
                text: 'Open QR Scanner',
                icon: Icons.camera_alt_rounded,
                gradient: AppTheme.pinkGradient,
                onPressed: _scanQR,
              ),
            ),
          ],
        ),
      ),
    );
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
                gradient: AppTheme.pinkGradient,
              ),
              child: const Icon(
                Icons.my_location_rounded,
                color: Colors.white,
                size: 40,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Verify Location',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Confirm you are still in the classroom',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: GradientButton(
                text: _isLoadingGPS ? 'Getting Location...' : 'Get GPS Location',
                icon: Icons.gps_fixed_rounded,
                gradient: AppTheme.pinkGradient,
                isLoading: _isLoadingGPS,
                onPressed: _isLoadingGPS ? () {} : _getLocation,
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
                      icon: Icons.qr_code_rounded,
                      title: 'QR Code',
                      subtitle: _qrData ?? '',
                      color: AppTheme.accentPink,
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
                      icon: Icons.location_on_rounded,
                      title: 'GPS',
                      subtitle: '${_latitude!.toStringAsFixed(4)}, ${_longitude!.toStringAsFixed(4)}',
                      color: AppTheme.accentGreen,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // What did you learn today
          FadeInUp(
            delay: const Duration(milliseconds: 100),
            child: GlassCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.school_rounded,
                          color: AppTheme.accentCyan, size: 20),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          'What did you learn today?',
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
                    controller: _learnedController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: 'Describe what you learned in this session...',
                    ),
                    maxLines: 3,
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Please describe what you learned' : null,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Understanding Rating
          FadeInUp(
            delay: const Duration(milliseconds: 200),
            child: GlassCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.psychology_rounded,
                          color: AppTheme.accentOrange, size: 20),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          'How well did you understand the lesson?',
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
                    selectedMood: _understandingRating,
                    onMoodSelected: (rating) =>
                        setState(() => _understandingRating = rating),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Feedback
          FadeInUp(
            delay: const Duration(milliseconds: 300),
            child: GlassCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.feedback_rounded,
                          color: AppTheme.accentPink, size: 20),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          'Comments or suggestions about the class',
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
                    controller: _feedbackController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: 'Any feedback for the instructor?',
                    ),
                    maxLines: 3,
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Please provide feedback' : null,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Submit
          FadeInUp(
            delay: const Duration(milliseconds: 400),
            child: SizedBox(
              width: double.infinity,
              child: GradientButton(
                text: 'Complete Session',
                icon: Icons.celebration_rounded,
                gradient: AppTheme.pinkGradient,
                isLoading: _isSubmitting,
                onPressed: _isSubmitting ? () {} : _submitFinish,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
