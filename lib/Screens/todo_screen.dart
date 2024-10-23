import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:todo/Screens/local_storage.dart';
import 'package:todo/Screens/settings_screen.dart';

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  _TodoScreenState createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  List<Map<String, dynamic>> tasks = [];
  final TextEditingController _taskController = TextEditingController();
  DateTime? _selectedDueDate;

  @override
  void initState() {
    super.initState();
    loadTasks();
  }

  void loadTasks() async {
    String? currentUser = LocalStorage.getCurrentUser();
    if (currentUser != null) {
      List<Map<String, dynamic>> loadedTasks =
          LocalStorage.loadUserTasks(currentUser);
      setState(() {
        tasks = loadedTasks;
      });
    }
  }

  void saveTasks() {
    String? currentUser = LocalStorage.getCurrentUser();
    if (currentUser != null) {
      LocalStorage.saveUserTasks(currentUser, tasks);
    }
  }

  void addTask(String task, DateTime dueDate) {
    setState(() {
      tasks.add({'task': task, 'dueDate': dueDate.toIso8601String()});
    });
    saveTasks();
  }

  void updateTask(int index, String updatedTask, DateTime updatedDueDate) {
    setState(() {
      tasks[index]['task'] = updatedTask;
      tasks[index]['dueDate'] = updatedDueDate.toIso8601String();
    });
    saveTasks();
  }

  void completeTask(int index) {
    setState(() {
      tasks.removeAt(index);
    });
    saveTasks();
  }

  Future<void> _selectDueDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDueDate) {
      setState(() {
        _selectedDueDate = picked;
      });
    }
  }

  void showAddOrUpdateTaskDialog({int? index}) {
    _taskController.text = index != null ? tasks[index]['task'] : '';
    _selectedDueDate = index != null
        ? DateTime.parse(tasks[index]['dueDate'])
        : DateTime.now();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(index == null ? 'Add New Task' : 'Update Task'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _taskController,
              decoration: const InputDecoration(labelText: 'Task'),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Text(
                  _selectedDueDate == null
                      ? 'No due date chosen'
                      : 'Due Date: ${DateFormat('dd-MM-yyyy').format(_selectedDueDate!)}',
                ),
                TextButton(
                  onPressed: () => _selectDueDate(context),
                  child: const Text('Select Due Date'),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              String task = _taskController.text;
              if (task.isNotEmpty && _selectedDueDate != null) {
                if (index == null) {
                  addTask(task, _selectedDueDate!);
                } else {
                  updateTask(index, task, _selectedDueDate!);
                }
                Navigator.pop(context);
              }
            },
            child: Text(index == null ? 'Add' : 'Update'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('To-Do List'),
        backgroundColor: Colors.deepPurple,
      ),
      body: ListView.builder(
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          DateTime dueDate = DateTime.parse(tasks[index]['dueDate']);
          return ListTile(
            title: Text(tasks[index]['task']),
            subtitle:
                Text('Due Date: ${DateFormat('dd-MM-yyyy').format(dueDate)}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => showAddOrUpdateTaskDialog(index: index),
                ),
                IconButton(
                  icon: const Icon(Icons.check_circle_outline_outlined,
                      color: Colors.green),
                  onPressed: () {
                    completeTask(index);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Task completed successfully! 🎉'),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'add_task_button',
            onPressed: () => showAddOrUpdateTaskDialog(),
            backgroundColor: Colors.deepPurple,
            child: const Icon(Icons.add),
          ),
          const SizedBox(width: 16),
          FloatingActionButton(
            heroTag: 'settings_button',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
            backgroundColor: Colors.blue,
            child: const Icon(Icons.settings),
          ),
        ],
      ),
    );
  }
}
