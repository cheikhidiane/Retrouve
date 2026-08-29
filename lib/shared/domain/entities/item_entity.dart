import 'package:equatable/equatable.dart';

enum ItemKind { lost, found }

/// Unified entity for a declared lost or found item.
///
/// Both `DeclareLostPage` and `DeclareFoundPage` create instances of this
/// entity (with [kind] set accordingly) so they can share one local
/// repository/storage key and be matched against each other.
class ItemEntity extends Equatable {
  const ItemEntity({
    required this.id,
    required this.kind,
    required this.title,
    required this.description,
    required this.category,
    required this.location,
    required this.date,
    required this.ownerId,
    required this.createdAt,
    this.storageLocation,
    this.secretQuestion,
    this.secretAnswer,
    this.isMatched = false,
  });

  final String id;
  final ItemKind kind;
  final String title;
  final String description;
  final String category;
  final String location;
  final String date;
  final String ownerId;
  final DateTime createdAt;

  /// Only relevant for found items: where the item was dropped off.
  final String? storageLocation;

  /// Only relevant for lost items: used during the verification step.
  final String? secretQuestion;
  final String? secretAnswer;

  /// Whether this item is already part of a confirmed match.
  final bool isMatched;

  ItemEntity copyWith({bool? isMatched}) {
    return ItemEntity(
      id: id,
      kind: kind,
      title: title,
      description: description,
      category: category,
      location: location,
      date: date,
      ownerId: ownerId,
      createdAt: createdAt,
      storageLocation: storageLocation,
      secretQuestion: secretQuestion,
      secretAnswer: secretAnswer,
      isMatched: isMatched ?? this.isMatched,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'kind': kind.name,
        'title': title,
        'description': description,
        'category': category,
        'location': location,
        'date': date,
        'ownerId': ownerId,
        'createdAt': createdAt.toIso8601String(),
        'storageLocation': storageLocation,
        'secretQuestion': secretQuestion,
        'secretAnswer': secretAnswer,
        'isMatched': isMatched,
      };

  factory ItemEntity.fromJson(Map<String, dynamic> json) {
    return ItemEntity(
      id: json['id'] as String,
      kind: ItemKind.values.byName(json['kind'] as String),
      title: json['title'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      location: json['location'] as String,
      date: json['date'] as String,
      ownerId: json['ownerId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      storageLocation: json['storageLocation'] as String?,
      secretQuestion: json['secretQuestion'] as String?,
      secretAnswer: json['secretAnswer'] as String?,
      isMatched: json['isMatched'] as bool? ?? false,
    );
  }

  @override
  List<Object?> get props => [
        id,
        kind,
        title,
        description,
        category,
        location,
        date,
        ownerId,
        createdAt,
        storageLocation,
        secretQuestion,
        secretAnswer,
        isMatched,
      ];
}
