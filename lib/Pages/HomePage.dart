import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:todo_list_app/List%20Provider/List.dart';
import 'package:todo_list_app/List%20Provider/TodoItem.dart';
import 'package:todo_list_app/Services/firestore.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<TodoItem> todoItems = [];
  final FirestoreServices _firestoreServices = FirestoreServices();

  @override
  void initState() {
    super.initState();
    _loadTodoItems();
  }

  void _loadTodoItems() {
    _firestoreServices.getTodoItems().listen((items) {
      setState(() {
        todoItems = items;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Todo List',
          style: GoogleFonts.lato(
            textStyle: const TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 25,
            ),
          ),
        ),
        backgroundColor: const Color.fromRGBO(255, 255, 255, 1.0),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      body: Container(
        padding: const EdgeInsets.all(7.0),
        child: TodoListWidget(todoItems: todoItems),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromRGBO(246, 220, 148, 1.0),
        onPressed: () {
          _showAddTodoDialog(context);
        },
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        child: const Icon(Icons.add, color: Colors.black),
      ),
      bottomNavigationBar: const BottomAppBar(
        color: Color.fromRGBO(213, 215, 215, 1.0),
        shape: CircularNotchedRectangle(),
        height: 50,
      ),
    );
  }

  void _showAddTodoDialog(BuildContext context) async {
    TextEditingController titleController = TextEditingController();
    DateTime? selectedDate;
    TimeOfDay? selectedTime;

    final result = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, setState) {
            return AlertDialog(
              title: const Text('Add Todo'),
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
                        initialDate: DateTime.now(),
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
                          selectedDate == null
                              ? 'Select Date'
                              : DateFormat.yMMMd().format(selectedDate!),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  InkWell(
                    onTap: () async {
                      final TimeOfDay? pickedTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
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
                          selectedTime == null
                              ? 'Select Time'
                              : selectedTime!.format(context),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(null); // Close the dialog
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (titleController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Please enter a title for the todo item.'),
                      ));
                    } else if (selectedDate == null || selectedTime == null) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Please select both date and time.'),
                      ));
                    } else {
                      // Create a new TodoItem without id
                      TodoItem newTodo = TodoItem(
                        id: '', // Temporary id
                        title: titleController.text,
                        dateTime: DateTime(
                          selectedDate!.year,
                          selectedDate!.month,
                          selectedDate!.day,
                          selectedTime!.hour,
                          selectedTime!.minute,
                        ),
                      );

                      // Add the todo item to Firestore
                      await _firestoreServices.addTodoItem(newTodo);

                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result != null && result is TodoItem) {
      setState(() {
        todoItems.add(result);
      });
    }
  }
}
