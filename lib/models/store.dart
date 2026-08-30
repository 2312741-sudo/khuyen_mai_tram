import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class KmtStore extends Equatable {
  final String id;
  final String name;
  final DateTime createdAt;

  const KmtStore({
    required this.id,
    required this.name,
    required this.createdAt,
  });

  factory KmtStore.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return KmtStore(
      id: doc.id,
      name: data['name'] as String? ?? '',
      createdAt: data['created_at'] != null ? (data['created_at'] as Timestamp).toDate() : DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'created_at': Timestamp.fromDate(createdAt),
    };
  }

  @override
  List<Object?> get props => [id, name, createdAt];

  @override
  String toString() => 'KmtStore(id: $id, name: $name)';
}
