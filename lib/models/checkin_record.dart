import 'package:uuid/uuid.dart';

class CheckInRecord {
  final String id;
  final String studentId;
  // Check-in data
  final DateTime checkInTime;
  final double checkInLatitude;
  final double checkInLongitude;
  final String qrCodeData;
  final String previousTopic;
  final String expectedTopic;
  final int moodBefore; // 1-5
  // Check-out data (nullable until completed)
  DateTime? checkOutTime;
  double? checkOutLatitude;
  double? checkOutLongitude;
  String? qrCodeDataOut;
  String? learnedToday;
  int? understandingRating; // 1-5
  String? feedback;
  final DateTime createdAt;

  CheckInRecord({
    String? id,
    required this.studentId,
    required this.checkInTime,
    required this.checkInLatitude,
    required this.checkInLongitude,
    required this.qrCodeData,
    required this.previousTopic,
    required this.expectedTopic,
    required this.moodBefore,
    this.checkOutTime,
    this.checkOutLatitude,
    this.checkOutLongitude,
    this.qrCodeDataOut,
    this.learnedToday,
    this.understandingRating,
    this.feedback,
    DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  bool get isCompleted => checkOutTime != null;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'studentId': studentId,
      'checkInTime': checkInTime.toIso8601String(),
      'checkInLatitude': checkInLatitude,
      'checkInLongitude': checkInLongitude,
      'qrCodeData': qrCodeData,
      'previousTopic': previousTopic,
      'expectedTopic': expectedTopic,
      'moodBefore': moodBefore,
      'checkOutTime': checkOutTime?.toIso8601String(),
      'checkOutLatitude': checkOutLatitude,
      'checkOutLongitude': checkOutLongitude,
      'qrCodeDataOut': qrCodeDataOut,
      'learnedToday': learnedToday,
      'understandingRating': understandingRating,
      'feedback': feedback,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory CheckInRecord.fromMap(Map<String, dynamic> map) {
    return CheckInRecord(
      id: map['id'] as String,
      studentId: map['studentId'] as String,
      checkInTime: DateTime.parse(map['checkInTime'] as String),
      checkInLatitude: (map['checkInLatitude'] as num).toDouble(),
      checkInLongitude: (map['checkInLongitude'] as num).toDouble(),
      qrCodeData: map['qrCodeData'] as String,
      previousTopic: map['previousTopic'] as String,
      expectedTopic: map['expectedTopic'] as String,
      moodBefore: map['moodBefore'] as int,
      checkOutTime: map['checkOutTime'] != null
          ? DateTime.parse(map['checkOutTime'] as String)
          : null,
      checkOutLatitude: map['checkOutLatitude'] != null
          ? (map['checkOutLatitude'] as num).toDouble()
          : null,
      checkOutLongitude: map['checkOutLongitude'] != null
          ? (map['checkOutLongitude'] as num).toDouble()
          : null,
      qrCodeDataOut: map['qrCodeDataOut'] as String?,
      learnedToday: map['learnedToday'] as String?,
      understandingRating: map['understandingRating'] as int?,
      feedback: map['feedback'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  CheckInRecord copyWith({
    DateTime? checkOutTime,
    double? checkOutLatitude,
    double? checkOutLongitude,
    String? qrCodeDataOut,
    String? learnedToday,
    int? understandingRating,
    String? feedback,
  }) {
    return CheckInRecord(
      id: id,
      studentId: studentId,
      checkInTime: checkInTime,
      checkInLatitude: checkInLatitude,
      checkInLongitude: checkInLongitude,
      qrCodeData: qrCodeData,
      previousTopic: previousTopic,
      expectedTopic: expectedTopic,
      moodBefore: moodBefore,
      checkOutTime: checkOutTime ?? this.checkOutTime,
      checkOutLatitude: checkOutLatitude ?? this.checkOutLatitude,
      checkOutLongitude: checkOutLongitude ?? this.checkOutLongitude,
      qrCodeDataOut: qrCodeDataOut ?? this.qrCodeDataOut,
      learnedToday: learnedToday ?? this.learnedToday,
      understandingRating: understandingRating ?? this.understandingRating,
      feedback: feedback ?? this.feedback,
      createdAt: createdAt,
    );
  }
}
