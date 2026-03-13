import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../models/checkin_record.dart';
import '../services/database_helper.dart';
import '../services/firestore_service.dart';
import '../widgets/app_notification.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final FirestoreService _firestoreService = FirestoreService();
  List<CheckInRecord> _records = [];
  bool _isLoading = true;
  String _studentId = '';

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    final studentId = prefs.getString('studentId') ?? '';
    final records = await _dbHelper.getAllRecords(studentId);
    if (mounted) {
      setState(() {
        _studentId = studentId;
        _records = records;
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteRecord(CheckInRecord record) async {
    AppNotification.showConfirmDialog(
      context,
      title: 'Delete Session?',
      message: 'This will permanently delete this session record from both local and cloud storage.',
      confirmText: 'Delete',
      onConfirm: () async {
        await _dbHelper.deleteRecord(record.id);
        await _firestoreService.deleteRecord(record.id);
        if (mounted) {
          AppNotification.showSuccess(context, 'Session deleted successfully');
          _loadRecords();
        }
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
                          child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
                        ),
                      ),
                      const SizedBox(width: 16),
                      ShaderMask(
                        shaderCallback: (bounds) => AppTheme.primaryGradient.createShader(bounds),
                        child: const Text('Session History', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white)),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(color: AppTheme.accentBlue.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
                        child: Text('${_records.length} sessions', style: const TextStyle(color: AppTheme.accentCyan, fontSize: 13, fontWeight: FontWeight.w500)),
                      ),
                    ],
                  ),
                ),
              ),

              // Swipe hint
              if (_records.isNotEmpty)
                FadeInDown(
                  delay: const Duration(milliseconds: 200),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.swipe_left_rounded, color: AppTheme.textSecondary.withValues(alpha: 0.5), size: 16),
                        const SizedBox(width: 6),
                        Text(
                          'Swipe left to delete a session',
                          style: TextStyle(
                            color: AppTheme.textSecondary.withValues(alpha: 0.5),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: AppTheme.accentBlue))
                    : _records.isEmpty
                        ? Center(
                            child: FadeInUp(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.history_rounded, size: 64, color: AppTheme.textSecondary.withValues(alpha: 0.3)),
                                  const SizedBox(height: 16),
                                  const Text('No Records Yet', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                                  const SizedBox(height: 8),
                                  Text('Your check-in history will appear here', style: TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
                                ],
                              ),
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadRecords,
                            color: AppTheme.accentBlue,
                            child: ListView.builder(
                              padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
                              itemCount: _records.length,
                              itemBuilder: (context, index) {
                                final record = _records[index];
                                return FadeInUp(
                                  delay: Duration(milliseconds: index * 80),
                                  child: Dismissible(
                                    key: Key(record.id),
                                    direction: DismissDirection.endToStart,
                                    confirmDismiss: (_) async {
                                      await _deleteRecord(record);
                                      return false; // we handle deletion manually
                                    },
                                    background: Container(
                                      margin: const EdgeInsets.only(bottom: 12),
                                      decoration: BoxDecoration(
                                        gradient: AppTheme.pinkGradient,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      alignment: Alignment.centerRight,
                                      padding: const EdgeInsets.only(right: 24),
                                      child: const Icon(
                                        Icons.delete_rounded,
                                        color: Colors.white,
                                        size: 28,
                                      ),
                                    ),
                                    child: _buildRecordCard(record),
                                  ),
                                );
                              },
                            ),
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecordCard(CheckInRecord record) {
    final moodIcons = [
      Icons.sentiment_neutral_rounded,
      Icons.sentiment_very_dissatisfied_rounded,
      Icons.sentiment_dissatisfied_rounded,
      Icons.sentiment_neutral_rounded,
      Icons.sentiment_satisfied_rounded,
      Icons.sentiment_very_satisfied_rounded,
    ];
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        padding: const EdgeInsets.all(20),
        onTap: () => _showDetail(record),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), gradient: record.isCompleted ? AppTheme.greenGradient : AppTheme.primaryGradient),
                  child: Center(child: Icon(moodIcons[record.moodBefore], color: Colors.white, size: 22)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(DateFormat('d MMMM yyyy').format(record.checkInTime), style: const TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textPrimary, fontSize: 15)),
                    const SizedBox(height: 2),
                    Text('Check-in: ${DateFormat('HH:mm').format(record.checkInTime)}${record.checkOutTime != null ? ' → ${DateFormat('HH:mm').format(record.checkOutTime!)}' : ''}', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                  ]),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(color: (record.isCompleted ? AppTheme.accentGreen : AppTheme.accentOrange).withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
                  child: Text(record.isCompleted ? '✓ Done' : '⏳ Active', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: record.isCompleted ? AppTheme.accentGreen : AppTheme.accentOrange)),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Divider(color: Colors.white.withValues(alpha: 0.06)),
            const SizedBox(height: 10),
            Row(children: [
              _infoChip(Icons.school_rounded, record.expectedTopic, AppTheme.accentCyan),
              const SizedBox(width: 10),
              _infoChip(Icons.location_on_rounded, '${record.checkInLatitude.toStringAsFixed(2)}, ${record.checkInLongitude.toStringAsFixed(2)}', AppTheme.accentBlue),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _infoChip(IconData icon, String text, Color color) {
    return Flexible(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 6),
          Flexible(child: Text(text, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis)),
        ]),
      ),
    );
  }

  void _showDetail(CheckInRecord record) {
    final moodIcons = [
      Icons.sentiment_neutral_rounded,
      Icons.sentiment_very_dissatisfied_rounded,
      Icons.sentiment_dissatisfied_rounded,
      Icons.sentiment_neutral_rounded,
      Icons.sentiment_satisfied_rounded,
      Icons.sentiment_very_satisfied_rounded,
    ];
    final moodLabels = ['', 'Very Bad', 'Bad', 'Neutral', 'Good', 'Great'];
    showModalBottomSheet(
      context: context, backgroundColor: Colors.transparent, isScrollControlled: true,
      builder: (context) => Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
        decoration: BoxDecoration(color: AppTheme.cardBg, borderRadius: const BorderRadius.vertical(top: Radius.circular(28)), border: Border.all(color: AppTheme.accentBlue.withValues(alpha: 0.2))),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const SizedBox(height: 12),
          Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(2))),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(
                  children: [
                    Icon(Icons.assignment_rounded, color: AppTheme.accentCyan, size: 22),
                    const SizedBox(width: 8),
                    const Text('Session Details', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                  ],
                ),
                const SizedBox(height: 20),
                _section('📍 Check-in', [
                  _row('Time', DateFormat('HH:mm:ss — d MMM yyyy').format(record.checkInTime)),
                  _row('GPS', '${record.checkInLatitude.toStringAsFixed(6)}, ${record.checkInLongitude.toStringAsFixed(6)}'),
                  _row('QR Code', record.qrCodeData),
                ]),
                const SizedBox(height: 12),
                _section('📝 Before Class', [
                  _row('Previous Topic', record.previousTopic),
                  _row('Expected Topic', record.expectedTopic),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(width: 110, child: Text('Mood', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13))),
                        Icon(moodIcons[record.moodBefore], color: AppTheme.accentPink, size: 16),
                        const SizedBox(width: 6),
                        Text('${moodLabels[record.moodBefore]} (${record.moodBefore}/5)', style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                ]),
                if (record.isCompleted) ...[
                  const SizedBox(height: 12),
                  _section('📍 Check-out', [
                    _row('Time', DateFormat('HH:mm:ss — d MMM yyyy').format(record.checkOutTime!)),
                    _row('GPS', '${record.checkOutLatitude!.toStringAsFixed(6)}, ${record.checkOutLongitude!.toStringAsFixed(6)}'),
                    if (record.qrCodeDataOut != null) _row('QR Code', record.qrCodeDataOut!),
                  ]),
                  const SizedBox(height: 12),
                  _section('📖 After Class', [
                    _row('Learned', record.learnedToday ?? '-'),
                    if (record.understandingRating != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(width: 110, child: Text('Understanding', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13))),
                            Icon(moodIcons[record.understandingRating!], color: AppTheme.accentPink, size: 16),
                            const SizedBox(width: 6),
                            Text('${moodLabels[record.understandingRating!]} (${record.understandingRating}/5)', style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13, fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                    _row('Feedback', record.feedback ?? '-'),
                  ]),
                ],
                const SizedBox(height: 20),
              ]),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _section(String title, List<Widget> children) {
    return GlassCard(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.accentCyan)),
      const SizedBox(height: 12),
      ...children,
    ]));
  }

  Widget _row(String label, String value) {
    return Padding(padding: const EdgeInsets.only(bottom: 8), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(width: 110, child: Text(label, style: TextStyle(color: AppTheme.textSecondary, fontSize: 13))),
      Expanded(child: Text(value, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13, fontWeight: FontWeight.w500))),
    ]));
  }
}
