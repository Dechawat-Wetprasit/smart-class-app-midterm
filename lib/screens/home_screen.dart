import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../services/database_helper.dart';
import '../models/checkin_record.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'checkin_screen.dart';
import 'finish_class_screen.dart';
import 'history_screen.dart';
import 'login_screen.dart';
import 'profile_screen.dart';
import '../widgets/app_notification.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  CheckInRecord? _activeRecord;
  List<CheckInRecord> _todayRecords = [];
  List<CheckInRecord> _allRecords = [];
  late AnimationController _pulseController;
  String _studentName = '';
  String _studentId = '';

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _loadData();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final studentId = prefs.getString('studentId') ?? '';
    
    final active = await _dbHelper.getActiveCheckIn(studentId);
    final today = await _dbHelper.getTodayRecords(studentId);
    final all = await _dbHelper.getAllRecords(studentId);
    
    if (mounted) {
      setState(() {
        _activeRecord = active;
        _todayRecords = today;
        _allRecords = all;
        _studentName = prefs.getString('studentName') ?? 'Student';
        _studentId = studentId;
      });
    }
  }

  int get _totalSessions => _allRecords.length;
  int get _completedSessions =>
      _allRecords.where((r) => r.isCompleted).length;
  double get _avgMood {
    if (_allRecords.isEmpty) return 0;
    final sum = _allRecords.fold<int>(0, (s, r) => s + r.moodBefore);
    return sum / _allRecords.length;
  }

  String get _greetingMessage {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: AppTheme.cardBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: AppTheme.accentBlue.withValues(alpha: 0.3)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppTheme.primaryGradient,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.accentBlue.withValues(alpha: 0.4),
                      blurRadius: 16,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.school_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(height: 20),
              ShaderMask(
                shaderCallback: (bounds) =>
                    AppTheme.primaryGradient.createShader(bounds),
                child: const Text(
                  'Smart Class',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Check-in & Learning Reflection',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 20),
              Divider(color: Colors.white.withValues(alpha: 0.08)),
              const SizedBox(height: 16),
              _aboutRow(Icons.info_outline_rounded, 'Version', '1.1.0'),
              const SizedBox(height: 10),
              _aboutRow(Icons.school_outlined, 'Course', '1305216 Mobile App Dev'),
              const SizedBox(height: 10),
              _aboutRow(Icons.calendar_today_rounded, 'Exam', 'Midterm — 13 Mar 2026'),
              const SizedBox(height: 10),
              _aboutRow(Icons.code_rounded, 'Stack', 'Flutter + Firebase'),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: GradientButton(
                  text: 'Close',
                  icon: Icons.close_rounded,
                  gradient: AppTheme.primaryGradient,
                  onPressed: () => Navigator.pop(context),
                  height: 48,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _aboutRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.accentCyan, size: 18),
        const SizedBox(width: 12),
        Text(label, style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
        const Spacer(),
        Text(value, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13, fontWeight: FontWeight.w500)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: _loadData,
            color: AppTheme.accentBlue,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                // App Bar
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                    child: FadeInDown(
                      duration: const Duration(milliseconds: 600),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      _greetingMessage,
                                      style: TextStyle(
                                        color: AppTheme.textSecondary,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    const Icon(
                                      Icons.waving_hand_rounded,
                                      color: Colors.amber,
                                      size: 16,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _studentName,
                                  style: TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w700,
                                    foreground: Paint()
                                      ..shader = AppTheme.primaryGradient
                                          .createShader(
                                        const Rect.fromLTWH(0, 0, 200, 40),
                                      ),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  DateFormat('EEEE, d MMMM yyyy').format(DateTime.now()),
                                  style: TextStyle(
                                    color: AppTheme.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const ProfileScreen(),
                                  ),
                                ).then((_) => _loadData()),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppTheme.surfaceLight.withValues(alpha: 0.5),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: AppTheme.accentCyan.withValues(alpha: 0.2),
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.person_rounded,
                                    color: AppTheme.accentCyan,
                                    size: 24,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const HistoryScreen(),
                                  ),
                                ).then((_) => _loadData()),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppTheme.surfaceLight.withValues(alpha: 0.5),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: AppTheme.accentBlue.withValues(alpha: 0.2),
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.history_rounded,
                                    color: AppTheme.accentCyan,
                                    size: 24,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: _showAboutDialog,
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppTheme.surfaceLight.withValues(alpha: 0.5),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: AppTheme.accentBlue.withValues(alpha: 0.2),
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.info_outline_rounded,
                                    color: AppTheme.accentBlue,
                                    size: 24,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () async {
                                  final prefs = await SharedPreferences.getInstance();
                                  await prefs.clear();
                                  if (context.mounted) {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                                    );
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppTheme.surfaceLight.withValues(alpha: 0.5),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: AppTheme.accentPink.withValues(alpha: 0.2),
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.logout_rounded,
                                    color: AppTheme.accentPink,
                                    size: 24,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Quick Stats Row
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: FadeInUp(
                      delay: const Duration(milliseconds: 150),
                      duration: const Duration(milliseconds: 600),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildQuickStat(
                              Icons.bar_chart_rounded,
                              '$_totalSessions',
                              'Sessions',
                              AppTheme.accentBlue,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildQuickStat(
                              Icons.check_circle_rounded,
                              '$_completedSessions',
                              'Completed',
                              AppTheme.accentGreen,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildQuickStat(
                              _avgMood >= 4
                                  ? Icons.sentiment_very_satisfied_rounded
                                  : _avgMood >= 3
                                      ? Icons.sentiment_satisfied_rounded
                                      : _avgMood >= 2
                                          ? Icons.sentiment_neutral_rounded
                                          : _avgMood > 0
                                              ? Icons.sentiment_dissatisfied_rounded
                                              : Icons.remove_circle_outline_rounded,
                              _avgMood > 0
                                  ? _avgMood.toStringAsFixed(1)
                                  : '-',
                              'Avg Mood',
                              AppTheme.accentPink,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Status Card
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: FadeInDown(
                      delay: const Duration(milliseconds: 200),
                      duration: const Duration(milliseconds: 600),
                      child: _buildStatusCard(),
                    ),
                  ),
                ),

                // Action Buttons
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: FadeInUp(
                      delay: const Duration(milliseconds: 400),
                      duration: const Duration(milliseconds: 600),
                      child: _buildActionButtons(),
                    ),
                  ),
                ),

                // Today's Activity
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                    child: FadeInUp(
                      delay: const Duration(milliseconds: 600),
                      duration: const Duration(milliseconds: 600),
                      child: Row(
                        children: [
                          Container(
                            width: 4,
                            height: 20,
                            decoration: BoxDecoration(
                              gradient: AppTheme.primaryGradient,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            "Today's Activity",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const Spacer(),
                          if (_todayRecords.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.accentBlue.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${_todayRecords.length} session${_todayRecords.length > 1 ? 's' : ''}',
                                style: const TextStyle(
                                  color: AppTheme.accentCyan,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Activity List
                if (_todayRecords.isEmpty)
                  SliverToBoxAdapter(
                    child: FadeInUp(
                      delay: const Duration(milliseconds: 700),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                        child: GlassCard(
                          child: Column(
                            children: [
                              Icon(
                                Icons.school_outlined,
                                size: 48,
                                color: AppTheme.textSecondary.withValues(alpha: 0.5),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'No activity today',
                                style: TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Check in to start your class session',
                                style: TextStyle(
                                  color: AppTheme.textSecondary.withValues(alpha: 0.6),
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final record = _todayRecords[index];
                        return FadeInUp(
                          delay: Duration(milliseconds: 700 + index * 100),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 4,
                            ),
                            child: _buildActivityCard(record),
                          ),
                        );
                      },
                      childCount: _todayRecords.length,
                    ),
                  ),

                // Bottom spacing
                const SliverToBoxAdapter(
                  child: SizedBox(height: 40),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickStat(IconData icon, String value, String label, Color color) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    final isActive = _activeRecord != null;
    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            children: [
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: isActive
                          ? AppTheme.greenGradient
                          : AppTheme.primaryGradient,
                      boxShadow: [
                        BoxShadow(
                          color: (isActive
                                  ? AppTheme.accentGreen
                                  : AppTheme.accentBlue)
                              .withValues(alpha: 0.3 + _pulseController.value * 0.2),
                          blurRadius: 16,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Icon(
                      isActive
                          ? Icons.check_circle_rounded
                          : Icons.radio_button_unchecked_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  );
                },
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isActive ? 'In Class' : 'Not Checked In',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: isActive
                            ? AppTheme.accentGreen
                            : AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isActive
                          ? 'Checked in at ${DateFormat('HH:mm').format(_activeRecord!.checkInTime)}'
                          : 'Tap Check-in to start your session',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (isActive) ...[
            const SizedBox(height: 20),
            Divider(color: Colors.white.withValues(alpha: 0.08)),
            const SizedBox(height: 16),
            AnimatedInfoTile(
              icon: Icons.location_on_rounded,
              title: 'Location',
              subtitle:
                  '${_activeRecord!.checkInLatitude.toStringAsFixed(4)}, ${_activeRecord!.checkInLongitude.toStringAsFixed(4)}',
              color: AppTheme.accentCyan,
            ),
            const SizedBox(height: 12),
            AnimatedInfoTile(
              icon: Icons.qr_code_rounded,
              title: 'QR Verified',
              subtitle: _activeRecord!.qrCodeData,
              color: AppTheme.accentBlue,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    final isActive = _activeRecord != null;
    return Column(
      children: [
        // Check-in Button
        GradientButton(
          text: isActive ? 'Already Checked In ✓' : 'Check In to Class',
          icon: isActive ? Icons.check_rounded : Icons.login_rounded,
          gradient: isActive
              ? LinearGradient(
                  colors: [Colors.grey.shade700, Colors.grey.shade600],
                )
              : AppTheme.primaryGradient,
          onPressed: () {
            if (!isActive) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CheckInScreen()),
              ).then((_) => _loadData());
            }
          },
        ),
        const SizedBox(height: 14),
        // Finish Class Button
        GradientButton(
          text: 'Finish Class',
          icon: Icons.logout_rounded,
          gradient: isActive
              ? AppTheme.pinkGradient
              : LinearGradient(
                  colors: [Colors.grey.shade700, Colors.grey.shade600],
                ),
          onPressed: () {
            if (isActive) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => FinishClassScreen(record: _activeRecord!),
                ),
              ).then((_) => _loadData());
            } else {
              AppNotification.showWarning(context, 'Please check in first!');
            }
          },
        ),
      ],
    );
  }

  Widget _buildActivityCard(CheckInRecord record) {
    final moodIcons = [
      Icons.sentiment_neutral_rounded, // 0
      Icons.sentiment_very_dissatisfied_rounded, // 1
      Icons.sentiment_dissatisfied_rounded, // 2
      Icons.sentiment_neutral_rounded, // 3
      Icons.sentiment_satisfied_rounded, // 4
      Icons.sentiment_very_satisfied_rounded, // 5
    ];
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: record.isCompleted
                  ? AppTheme.greenGradient
                  : AppTheme.primaryGradient,
            ),
            child: Center(
              child: Icon(
                moodIcons[record.moodBefore],
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Session',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: record.isCompleted
                            ? AppTheme.accentGreen.withValues(alpha: 0.15)
                            : AppTheme.accentOrange.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        record.isCompleted ? 'Completed' : 'In Progress',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: record.isCompleted
                              ? AppTheme.accentGreen
                              : AppTheme.accentOrange,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Check-in: ${DateFormat('HH:mm').format(record.checkInTime)}'
                  '${record.checkOutTime != null ? ' → ${DateFormat('HH:mm').format(record.checkOutTime!)}' : ''}',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: AppTheme.textSecondary.withValues(alpha: 0.5),
          ),
        ],
      ),
    );
  }
}
