import 'package:equatable/equatable.dart';

enum MatchStatus { potential, confirmed, rejected }

class MatchEntity extends Equatable {
  const MatchEntity({
    required this.id,
    required this.lostItemId,
    required this.foundItemId,
    required this.score,
    required this.status,
    required this.createdAt,
    this.confirmedAt,
  });

  final String id;
  final String lostItemId;
  final String foundItemId;
  final int score;
  final MatchStatus status;
  final DateTime createdAt;
  final DateTime? confirmedAt;

  MatchEntity copyWith({MatchStatus? status, DateTime? confirmedAt}) {
    return MatchEntity(
      id: id,
      lostItemId: lostItemId,
      foundItemId: foundItemId,
      score: score,
      status: status ?? this.status,
      createdAt: createdAt,
      confirmedAt: confirmedAt ?? this.confirmedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'lostItemId': lostItemId,
        'foundItemId': foundItemId,
        'score': score,
        'status': status.name,
        'createdAt': createdAt.toIso8601String(),
        'confirmedAt': confirmedAt?.toIso8601String(),
      };

  factory MatchEntity.fromJson(Map<String, dynamic> json) {
    return MatchEntity(
      id: json['id'] as String,
      lostItemId: json['lostItemId'] as String,
      foundItemId: json['foundItemId'] as String,
      score: json['score'] as int,
      status: MatchStatus.values.byName(json['status'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      confirmedAt: json['confirmedAt'] != null
          ? DateTime.parse(json['confirmedAt'] as String)
          : null,
    );
  }

  @override
  List<Object?> get props =>
      [id, lostItemId, foundItemId, score, status, createdAt, confirmedAt];
}
