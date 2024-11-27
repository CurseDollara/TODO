import 'package:flutter/material.dart';
import 'add_task.dart';
import '../components/colors.dart';
import '../components/task.dart';


class DailyTask extends StatefulWidget {
  const DailyTask({super.key});

  @override
  DailyTaskState createState() => DailyTaskState();
}

class DailyTaskState extends State<DailyTask> {
  List<Task> currentTasks = [];
  List<Task> completedTasks = [];
  final TextEditingController _taskController = TextEditingController();

  @override
  void dispose() {
    _taskController.dispose();
    super.dispose();
  }

void _addTask(String taskTitle, DateTime? taskDate, TimeOfDay? taskTime, String? taskNotes) {
  if (taskTitle.trim().isEmpty) return;
  setState(() {
    currentTasks.add(Task(
      title: taskTitle,
      date: taskDate,
      time: taskTime,
      notes: taskNotes,
    ));
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
    _addTask(
      newTask['title'],
      newTask['date'],
      newTask['time'],
      newTask['notes'],
    );
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
            color: AppColors.primary,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'My Todo List',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              color: AppColors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    if (currentTasks.isNotEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.lightGrey,
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
                                  onDelete: () => _deleteTask(task, false),
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
                          color: AppColors.lightGrey,
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
                                  onDelete: () => _deleteTask(task, true),
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
            color: AppColors.white,
            child: ElevatedButton(
              onPressed: _navigateToAddTaskPage,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Добавить новую задачу',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
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

  void _showTaskDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(task.title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (task.date != null)
                Text(
                  'Дата: ${task.date!.day.toString().padLeft(2, '0')}-${task.date!.month.toString().padLeft(2, '0')}-${task.date!.year}',
                  style: const TextStyle(fontSize: 16),
                ),
              if (task.time != null)
                Text(
                  'Время: ${task.time!.hour}:${task.time!.minute.toString().padLeft(2, '0')}',
                  style: const TextStyle(fontSize: 16),
                ),
              const SizedBox(height: 10),
              if (task.notes != null && task.notes!.isNotEmpty)
                Text(
                  'Заметки: ${task.notes!}',
                  style: const TextStyle(fontSize: 16),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Закрыть'),
            ),
          ],
        );
      },
    );
  }

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
                  activeColor: AppColors.primary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: () => _showTaskDetails(context),
                  child: Text(
                    task.title,
                    style: TextStyle(
                      fontSize: 18,
                      color: task.isCompleted
                          ? AppColors.textGrey.withOpacity(0.6)
                          : AppColors.textGrey,
                      decoration:
                          task.isCompleted ? TextDecoration.lineThrough : null,
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: AppColors.red),
                onPressed: onDelete,
              ),
            ],
          ),
          if (task.date != null)
            Text(
              'Дата: ${task.date!.day.toString().padLeft(2, '0')}-${task.date!.month.toString().padLeft(2, '0')}-${task.date!.year}',
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textGrey,
              ),
            ),
          if (task.time != null)
            Text(
              'Время: ${task.time!.hour}:${task.time!.minute.toString().padLeft(2, '0')}',
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textGrey,
              ),
            ),
        ],
      ),
    );
  }
}
