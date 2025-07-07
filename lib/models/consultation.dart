class Consultation {
  final int id;
  final int userId;
  final int doctorId;
  final int diagnosisId;
  final String? notes;
  final bool imageAuthorized;
  final String? imagePath;
  final DateTime sentAt;
  final String doctorName;
  final String doctorSpecialty;
  final String diagnosisCondition;
  final double diagnosisConfidence;

  Consultation({
    required this.id,
    required this.userId,
    required this.doctorId,
    required this.diagnosisId,
    this.notes,
    required this.imageAuthorized,
    this.imagePath,
    required this.sentAt,
    required this.doctorName,
    required this.doctorSpecialty,
    required this.diagnosisCondition,
    required this.diagnosisConfidence,
  });

  factory Consultation.fromJson(Map<String, dynamic> json) {
    return Consultation(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      doctorId: json['doctor_id'] as int,
      diagnosisId: json['diagnosis_id'] as int,
      notes: json['notes'] as String?,
      imageAuthorized: json['image_authorized'] as bool,
      imagePath: json['image_path'] as String?,
      sentAt: DateTime.parse(json['sent_at'] as String),
      doctorName: json['doctor']['name'] as String,
      doctorSpecialty: json['doctor']['specialty'] as String,
      diagnosisCondition: json['diagnosis']['condition'] as String,
      diagnosisConfidence: (json['diagnosis']['confidence'] as num).toDouble(),
    );
  }
}