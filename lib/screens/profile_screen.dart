import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../services/database_helper.dart';
import '../models/checkin_record.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  String _studentId = '';
  String _studentName = '';
  List<CheckInRecord> _allRecords = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final studentId = prefs.getString('studentId') ?? 'N/A';
    final records = await _dbHelper.getAllRecords(studentId);
    if (mounted) {
      setState(() {
        _studentId = studentId;
        _studentName = prefs.getString('studentName') ?? 'Student';
        _allRecords = records;
        _isLoading = false;
      });
    }
  }

  int get _totalSessions => _allRecords.length;
  int get _completedSessions =>
      _allRecords.where((r) => r.isCompleted).length;
  double get _completionRate =>
      _totalSessions > 0 ? _completedSessions / _totalSessions : 0;
  double get _avgMood {
    if (_allRecords.isEmpty) return 0;
    final sum = _allRecords.fold<int>(0, (s, r) => s + r.moodBefore);
    return sum / _allRecords.length;
  }

  double get _avgUnderstanding {
    final rated =
        _allRecords.where((r) => r.understandingRating != null).toList();
    if (rated.isEmpty) return 0;
    final sum = rated.fold<int>(0, (s, r) => s + r.understandingRating!);
    return sum / rated.length;
  }

  int get _currentStreak {
    if (_allRecords.isEmpty) return 0;
    int streak = 0;
    final sorted = List<CheckInRecord>.from(_allRecords)
      ..sort((a, b) => b.checkInTime.compareTo(a.checkInTime));
    DateTime? lastDate;
    for (final record in sorted) {
      final date = DateTime(
        record.checkInTime.year,
        record.checkInTime.month,
        record.checkInTime.day,
      );
      if (lastDate == null) {
        streak = 1;
        lastDate = date;
      } else {
        final diff = lastDate.difference(date).inDays;
        if (diff == 1) {
          streak++;
          lastDate = date;
        } else if (diff > 1) {
          break;
        }
      }
    }
    return streak;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: AppTheme.accentBlue))
              : CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    // Header
                    SliverToBoxAdapter(
                      child: FadeInDown(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: AppTheme.surfaceLight
                                        .withValues(alpha: 0.5),
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
                                shaderCallback: (bounds) => AppTheme
                                    .primaryGradient
                                    .createShader(bounds),
                                child: const Text(
                                  'My Profile',
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
                    ),

                    // Profile Card
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                        child: FadeInDown(
                          delay: const Duration(milliseconds: 200),
                          child: GlassCard(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              children: [
                                // Avatar
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: AppTheme.primaryGradient,
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppTheme.accentBlue
                                            .withValues(alpha: 0.4),
                                        blurRadius: 20,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Text(
                                      _studentName.isNotEmpty
                                          ? _studentName[0].toUpperCase()
                                          : '?',
                                      style: const TextStyle(
                                        fontSize: 36,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _studentName,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme.accentCyan
                                        .withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    'ID: $_studentId',
                                    style: const TextStyle(
                                      color: AppTheme.accentCyan,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Attendance Summary
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                        child: FadeInUp(
                          delay: const Duration(milliseconds: 300),
                          child: GlassCard(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: AppTheme.accentGreen
                                            .withValues(alpha: 0.15),
                                        borderRadius:
                                            BorderRadius.circular(10),
                                      ),
                                      child: const Icon(
                                        Icons.pie_chart_rounded,
                                        color: AppTheme.accentGreen,
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    const Text(
                                      'Attendance Rate',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.textPrimary,
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      '${(_completionRate * 100).toStringAsFixed(0)}%',
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w700,
                                        color: AppTheme.accentGreen,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: LinearProgressIndicator(
                                    value: _completionRate,
                                    minHeight: 10,
                                    backgroundColor: Colors.white
                                        .withValues(alpha: 0.08),
                                    valueColor:
                                        const AlwaysStoppedAnimation<Color>(
                                      AppTheme.accentGreen,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  '$_completedSessions of $_totalSessions sessions completed',
                                  style: TextStyle(
                                    color: AppTheme.textSecondary,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Stats Grid
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                        child: FadeInUp(
                          delay: const Duration(milliseconds: 400),
                          child: Row(
                            children: [
                              Expanded(
                                child: _buildStatCard(
                                  icon: Icons.calendar_today_rounded,
                                  label: 'Total',
                                  value: '$_totalSessions',
                                  color: AppTheme.accentBlue,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildStatCard(
                                  icon: Icons.local_fire_department_rounded,
                                  label: 'Streak',
                                  value: '$_currentStreak',
                                  color: AppTheme.accentOrange,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                        child: FadeInUp(
                          delay: const Duration(milliseconds: 500),
                          child: Row(
                            children: [
                              Expanded(
                                child: _buildStatCard(
                                  icon: Icons.mood_rounded,
                                  label: 'Avg Mood',
                                  value: _avgMood > 0
                                      ? _avgMood.toStringAsFixed(1)
                                      : '-',
                                  color: AppTheme.accentPink,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildStatCard(
                                  icon: Icons.psychology_rounded,
                                  label: 'Avg Understanding',
                                  value: _avgUnderstanding > 0
                                      ? _avgUnderstanding.toStringAsFixed(1)
                                      : '-',
                                  color: AppTheme.accentCyan,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Mood Distribution
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                        child: FadeInUp(
                          delay: const Duration(milliseconds: 600),
                          child: GlassCard(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Mood Distribution',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                _buildMoodDistribution(),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    // App Info
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
                        child: FadeInUp(
                          delay: const Duration(milliseconds: 700),
                          child: GlassCard(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              children: [
                                _infoRow(Icons.school_rounded, 'Course',
                                    '1305216 Mobile App Dev'),
                                const SizedBox(height: 12),
                                _infoRow(Icons.info_outline_rounded, 'Version',
                                    '1.1.0'),
                                const SizedBox(height: 12),
                                _infoRow(Icons.code_rounded, 'Framework',
                                    'Flutter 3.41.4'),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return GlassCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodDistribution() {
    final moodIcons = [
      Icons.sentiment_very_dissatisfied_rounded,
      Icons.sentiment_dissatisfied_rounded,
      Icons.sentiment_neutral_rounded,
      Icons.sentiment_satisfied_rounded,
      Icons.sentiment_very_satisfied_rounded,
    ];
    final moodCounts = List<int>.filled(5, 0);

    for (final record in _allRecords) {
      if (record.moodBefore >= 1 && record.moodBefore <= 5) {
        moodCounts[record.moodBefore - 1]++;
      }
    }

    final maxCount =
        moodCounts.reduce((a, b) => a > b ? a : b).clamp(1, double.maxFinite.toInt());

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(5, (index) {
        final ratio = moodCounts[index] / maxCount;
        return Column(
          children: [
            Text(
              '${moodCounts[index]}',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              width: 36,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeOutCubic,
                  width: 36,
                  height: 80 * ratio,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.accentBlue.withValues(alpha: 0.6),
                        AppTheme.accentCyan.withValues(alpha: 0.8),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Icon(
              moodIcons[index],
              color: AppTheme.textSecondary,
              size: 20,
            ),
          ],
        );
      }),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.accentBlue, size: 20),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
