import 'package:cloud_firestore/cloud_firestore.dart';

class TodoItem {
  final String id;
  final String title;
  final DateTime dateTime;
  bool isCompleted;

  TodoItem({
    required this.id,
    required this.title,
    required this.dateTime,
    this.isCompleted = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'dateTime': dateTime,
      'isCompleted': isCompleted,
    };
  }

  factory TodoItem.fromMap(Map<String, dynamic> map, String id) {
    return TodoItem(
      id: id,
      title: map['title'],
      dateTime: (map['dateTime'] as Timestamp).toDate(),
      isCompleted: map['isCompleted'] ?? false,
    );
  }
}
