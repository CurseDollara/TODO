import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'add_task.dart';
import '../components/colors.dart';
import '../components/task.dart';
import '../widgets/auth_page.dart';
import '../services/api_service.dart';

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
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    try {
      final result = await ApiService.getTasks();
      if (result['success'] == true) {
        final tasks = result['tasks'] as List;
        
        setState(() {
          currentTasks.clear();
          completedTasks.clear();
          
          for (var taskData in tasks) {
            final task = Task(
              id: taskData['_id'],
              title: taskData['title'],
              category: taskData['category'] ?? 'Дом',
              isCompleted: taskData['completed'] ?? false,
              date: taskData['date'] != null 
                  ? DateTime.parse(taskData['date']) 
                  : null,
              time: taskData['time'] != null 
                  ? TimeOfDay(
                      hour: int.parse(taskData['time'].split(':')[0]),
                      minute: int.parse(taskData['time'].split(':')[1]),
                    )
                  : null,
              notes: taskData['notes'],
            );
            
            if (task.isCompleted) {
              completedTasks.add(task);
            } else {
              currentTasks.add(task);
            }
          }
        });
      }
    } catch (e) {
      print('Ошибка загрузки задач: $e');
    }
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

  void _addTask(String taskTitle, DateTime? taskDate, TimeOfDay? taskTime, String? taskNotes) async {
    if (taskTitle.trim().isEmpty) return;
    
    // Получаем данные текущего пользователя
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id');
    
    // Создаем задачу локально
    final newTask = Task(
      title: taskTitle,
      date: taskDate,
      time: taskTime,
      notes: taskNotes,
    );
    
    setState(() {
      currentTasks.add(newTask);
    });
    
    // Сохраняем задачу в бэкенд
    final taskData = {
      'title': taskTitle,
      'date': taskDate != null 
          ? '${taskDate.year}-${taskDate.month.toString().padLeft(2, '0')}-${taskDate.day.toString().padLeft(2, '0')}'
          : null,
      'time': taskTime != null
          ? '${taskTime.hour}:${taskTime.minute.toString().padLeft(2, '0')}'
          : null,
      'notes': taskNotes,
    };
    
    final result = await ApiService.createTask(taskData);
    
    if (result['success'] == true) {
      // Обновляем ID задачи из ответа сервера
      setState(() {
        newTask.id = result['task_id'];
      });
    }
    
    _taskController.clear();
  }

  void _toggleTask(Task task, bool? isCompleted) async {
    final newIsCompleted = isCompleted ?? !task.isCompleted;
    
    setState(() {
      if (newIsCompleted == true) {
        currentTasks.remove(task);
        completedTasks.add(task..isCompleted = true);
      } else {
        completedTasks.remove(task);
        currentTasks.add(task..isCompleted = false);
      }
    });

    if (task.id != null && task.id!.isNotEmpty) {
      try {
        final result = await ApiService.updateTask(
          task.id!,
          {'completed': newIsCompleted},
        );
        
        if (!result['success']) {
          print('Ошибка обновления задачи: ${result['error']}');
        }
      } catch (e) {
        print('Ошибка сети: $e');
      }
    }
  }

  void _deleteTask(Task task, bool isCompleted) async {
    // Показываем диалог подтверждения
    bool? confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text(
          'Удалить задачу?',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Вы уверены, что хотите удалить задачу:',
              style: TextStyle(
                color: AppColors.textGrey,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.lightGrey,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '"${task.title}"',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Это действие нельзя отменить.',
              style: TextStyle(
                color: AppColors.red.withOpacity(0.8),
                fontSize: 14,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Отмена',
              style: TextStyle(color: AppColors.textGrey),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Удалить'),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        elevation: 10,
      ),
    );

    // Если пользователь подтвердил удаление
    if (confirm == true) {
      setState(() {
        if (isCompleted) {
          completedTasks.remove(task);
        } else {
          currentTasks.remove(task);
        }
      });

      if (task.id != null && task.id!.isNotEmpty) {
        final result = await ApiService.deleteTask(task.id!);
        if (!result['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                result['error'] ?? 'Ошибка удаления из сервера',
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: AppColors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }

      // Показываем подтверждение удаления
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Задача "${task.title}" удалена',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: AppColors.primary,
          duration: const Duration(seconds: 2),
        ),
      );
    }
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
                  onChanged: (isChecked) {
                    onChanged(isChecked);
                  },
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
