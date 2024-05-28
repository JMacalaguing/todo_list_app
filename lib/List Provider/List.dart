import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:todo_list_app/List%20Provider/TodoItem.dart';
import 'package:todo_list_app/Services/firestore.dart';


class TodoListWidget extends StatefulWidget {
  final List<TodoItem> todoItems;

  const TodoListWidget({super.key, required this.todoItems});

  @override
  _TodoListWidgetState createState() => _TodoListWidgetState();
}

class _TodoListWidgetState extends State<TodoListWidget> {
  final FirestoreServices _firestoreServices = FirestoreServices();

  final List<Color> _containerColors = [
    Colors.red.shade100,
    Colors.blue.shade100,
    Colors.green.shade100,
    Colors.yellow.shade100,
    Colors.orange.shade100,
    Colors.purple.shade100,
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.todoItems.length,
      itemBuilder: (context, index) {
        TodoItem todoItem = widget.todoItems[index];
        Color containerColor = _containerColors[index % _containerColors.length];

        return GestureDetector(
          onLongPress: () {
            // Show a dialog or confirm the deletion
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Delete Todo'),
                  content: const Text('Are you sure you want to delete this todo item?'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Close the dialog
                      },
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        await _firestoreServices.deleteTodoItem(todoItem.id);
                        setState(() {
                          widget.todoItems.removeAt(index);

                        });
                        Navigator.of(context).pop();
                      },
                      child: const Text('Delete'),
                    ),
                  ],
                );
              },
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            margin: const EdgeInsets.only(bottom: 15),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              color: containerColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade400,
                  spreadRadius: 0,
                  blurRadius: 5,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CheckboxListTile(
                  title: Text(
                    todoItem.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      decoration: todoItem.isCompleted ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  subtitle: Text(
                    'Due: ${DateFormat.yMMMd().add_jm().format(todoItem.dateTime)}',
                    style: TextStyle(
                      color: Colors.grey,
                      decoration: todoItem.isCompleted ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  value: todoItem.isCompleted,
                  onChanged: (bool? value) async {
                    if (value != null) {
                      setState(() {
                        widget.todoItems[index].isCompleted = value;
                      });
                      todoItem.isCompleted = value;
                      await _firestoreServices.updateTodoItem(todoItem);
                    }
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                  secondary: IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      _showEditTodoDialog(context, todoItem, index);
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showEditTodoDialog(BuildContext context, TodoItem todoItem, int index) async {
    TextEditingController titleController = TextEditingController(text: todoItem.title);
    DateTime selectedDate = todoItem.dateTime;
    TimeOfDay selectedTime = TimeOfDay.fromDateTime(todoItem.dateTime);

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, setState) {
            return AlertDialog(
              title: const Text('Edit Todo'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(labelText: 'Title'),
                  ),
                  const SizedBox(height: 20),
                  InkWell(
                    onTap: () async {
                      final DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2101),
                      );
                      if (pickedDate != null) {
                        setState(() {
                          selectedDate = pickedDate;
                        });
                      }
                    },
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today),
                        const SizedBox(width: 10),
                        Text(
                          DateFormat.yMMMd().format(selectedDate),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  InkWell(
                    onTap: () async {
                      final TimeOfDay? pickedTime = await showTimePicker(
                        context: context,
                        initialTime: selectedTime,
                      );
                      if (pickedTime != null) {
                        setState(() {
                          selectedTime = pickedTime;
                        });
                      }
                    },
                    child: Row(
                      children: [
                        const Icon(Icons.access_time),
                        const SizedBox(width: 10),
                        Text(
                          selectedTime.format(context),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    // Create a new TodoItem with updated values
                    TodoItem updatedItem = TodoItem(
                      id: todoItem.id,
                      title: titleController.text,
                      dateTime: DateTime(
                        selectedDate.year,
                        selectedDate.month,
                        selectedDate.day,
                        selectedTime.hour,
                        selectedTime.minute,
                      ),
                      isCompleted: todoItem.isCompleted,
                    );

                    await _firestoreServices.updateTodoItem(updatedItem);

                    setState(() {
                      widget.todoItems[index] = updatedItem;
                    });

                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
