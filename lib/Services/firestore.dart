import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:todo_list_app/List%20Provider/TodoItem.dart';

class FirestoreServices {
  final CollectionReference todosCollection =
  FirebaseFirestore.instance.collection('todos');

  // Add a Todo item
  Future<void> addTodoItem(TodoItem todoItem) async {
    await todosCollection.add({
      'title': todoItem.title,
      'dateTime': todoItem.dateTime,
    });
  }

  // Get Todo items
  Stream<List<TodoItem>> getTodoItems() {
    return todosCollection.snapshots().map((snapshot) => snapshot.docs.map((doc) {
      return TodoItem(
        id: doc.id,
        title: doc['title'],
        dateTime: (doc['dateTime'] as Timestamp).toDate(),
      );
    }).toList());
  }

  // Update a Todo item
  Future<void> updateTodoItem(TodoItem todoItem) async {
    await todosCollection.doc(todoItem.id).update({
      'title': todoItem.title,
      'dateTime': todoItem.dateTime,
    });
  }

  // Delete a Todo item
  Future<void> deleteTodoItem(String id) async {
    await todosCollection.doc(id).delete();
  }
}
