import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'add_task.dart';
import '../components/colors.dart';
import '../components/task.dart';
import '../widgets/auth_page.dart';

class DailyTask extends StatefulWidget {
  const DailyTask({super.key});

  @override
  DailyTaskState createState() => DailyTaskState();
}

class DailyTaskState extends State<DailyTask> {
  List<Task> currentTasks = [];
  List<Task> completedTasks = [];
  final TextEditingController _taskController = TextEditingController();
  
  String _username = '';
  String _email = '';

  @override
  void initState() {
    super.initState();
    _loadUserData(); 
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = prefs.getString('username') ?? 'Пользователь';
      _email = prefs.getString('email') ?? '';
    });
  }

  // Выход из аккаунта
  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Очищаем все сохраненные данные
    
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const AuthPage()),
    );
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
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Привет, $_username!',
                              style: const TextStyle(
                                color: AppColors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (_email.isNotEmpty)
                              Text(
                                _email,
                                style: const TextStyle(
                                  color: AppColors.white,
                                  fontSize: 14,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.logout,
                          color: AppColors.white,
                          size: 28,
                        ),
                        onPressed: _logout,
                        tooltip: 'Выйти',
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 30),
                  
                  Center(
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
                ],
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
                      
                    if (currentTasks.isEmpty && completedTasks.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(40),
                        child: Column(
                          children: [
                            Icon(
                              Icons.checklist,
                              size: 80,
                              color: AppColors.primary.withOpacity(0.3),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'Пока нет задач',
                              style: TextStyle(
                                fontSize: 18,
                                color: AppColors.textGrey.withOpacity(0.6),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Нажмите "Добавить новую задачу"',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textGrey.withOpacity(0.5),
                              ),
                            ),
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
