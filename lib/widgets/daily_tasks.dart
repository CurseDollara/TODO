import 'package:flutter/material.dart';
import 'add_task.dart';

class DailyTask extends StatefulWidget {
  const DailyTask({super.key});

  @override
  _DailyTaskState createState() => _DailyTaskState();
}

class _DailyTaskState extends State<DailyTask> {
  List<Task> currentTasks = [];
  List<Task> completedTasks = [];
  final TextEditingController _taskController = TextEditingController();

  @override
  void dispose() {
    _taskController.dispose();
    super.dispose();
  }

  void _addTask(String taskTitle, DateTime? taskDate) {
    if (taskTitle.trim().isEmpty) return;
    setState(() {
      currentTasks.add(Task(title: taskTitle, date: taskDate));
    });
    _taskController.clear();
  }

  void _toggleTask(Task task, bool? isCompleted) {
    setState(() {
      if (isCompleted == true) {
        currentTasks.remove(task);
        completedTasks.add(task..isCompleted = true);
      } else {
        completedTasks.remove(task);
        currentTasks.add(task..isCompleted = false);
      }
    });
  }

  void _deleteTask(Task task, bool isCompleted) {
    setState(() {
      if (isCompleted) {
        completedTasks.remove(task);
      } else {
        currentTasks.remove(task);
      }
    });
  }

  Future<void> _navigateToAddTaskPage() async {
    final newTask = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(builder: (context) => const AddTaskPage()),
    );

    if (newTask != null) {
      _addTask(newTask['title'], newTask['date']);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Column(
        children: [
          Container(
            height: screenHeight * 0.3,
            width: double.infinity,
            color: const Color(0xFF4A3780),
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                decoration: BoxDecoration(
                  color: const Color(0xFF4A3780),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'My Todo List',
                  style: TextStyle(
                    color: Color.fromARGB(255, 255, 255, 255),
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    if (currentTasks.isNotEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0E0E0),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Текущие задачи',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            ...currentTasks.map((task) => TaskItem(
                                  task: task,
                                  onChanged: (isChecked) =>
                                      _toggleTask(task, isChecked),
                                  onDelete: () =>
                                      _deleteTask(task, false),
                                )),
                          ],
                        ),
                      ),
                    const SizedBox(height: 20),
                    if (completedTasks.isNotEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0E0E0),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Выполненные задачи',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            ...completedTasks.map((task) => TaskItem(
                                  task: task,
                                  onChanged: (isChecked) =>
                                      _toggleTask(task, isChecked),
                                  onDelete: () =>
                                      _deleteTask(task, true),
                                )),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: Colors.white,
            child: ElevatedButton(
              onPressed: _navigateToAddTaskPage,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4A3780),
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Добавить новую задачу',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Task {
  String title;
  bool isCompleted;
  DateTime? date;

  Task({required this.title, this.isCompleted = false, this.date});
}

class TaskItem extends StatelessWidget {
  final Task task;
  final ValueChanged<bool?> onChanged;
  final VoidCallback onDelete;

  const TaskItem({
    super.key,
    required this.task,
    required this.onChanged,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Transform.scale(
                scale: 1.5,
                child: Checkbox(
                  value: task.isCompleted,
                  onChanged: onChanged,
                  activeColor: const Color(0xFF4A3780),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  task.title,
                  style: TextStyle(
                    fontSize: 18,
                    color: task.isCompleted
                        ? Colors.grey.withOpacity(0.6)
                        : const Color.fromARGB(255, 97, 97, 97),
                    decoration:
                        task.isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: onDelete,
              ),
            ],
          ),
          if (task.date != null)
            Text(
              'Дата: ${task.date!.toLocal()}'.split(' ')[0],
              style: const TextStyle(
                fontSize: 14,
                color: Color.fromARGB(255, 97, 97, 97),
              ),
            ),
        ],
      ),
    );
  }
}
