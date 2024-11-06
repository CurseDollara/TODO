import 'package:flutter/material.dart';

class AddTaskPage extends StatefulWidget {
  const AddTaskPage({super.key});

  @override
  _AddTaskPageState createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  // Контроллеры для ввода названия задачи и заметок
  final TextEditingController _taskTitleController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  // Переменные для хранения выбранных категории, даты и времени
  String _selectedCategory = 'Дом';
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  @override
  void dispose() {
    // Освобождаем ресурсы контроллеров при удалении виджета
    _taskTitleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  // Выбор даты через диалоговое окно
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // Выбор времени через диалоговое окно
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  // Сохранение задачи и возврат к предыдущему экрану с передачей данных
  void _saveTask() {
    Navigator.pop(context, {
      'title': _taskTitleController.text,
      'category': _selectedCategory,
      'date': _selectedDate,
      'time': _selectedTime,
      'notes': _notesController.text,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Добавить новую задачу'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Поле для ввода названия задачи
            TextField(
              controller: _taskTitleController,
              decoration: const InputDecoration(
                labelText: 'Название задачи',
              ),
            ),
            const SizedBox(height: 16),
            // Выбор категории задачи
            const Text(
              'Выбор категории:',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            DropdownButton<String>(
              value: _selectedCategory,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedCategory = newValue!;
                });
              },
              items: <String>['Дом', 'Работа', 'Хобби']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            // Выбор даты выполнения задачи
            Row(
              children: [
                Expanded(
                  child: Text(
                    _selectedDate == null
                        ? 'Выберите дату'
                        : 'Дата: ${_selectedDate!.toLocal()}'.split(' ')[0],
                  ),
                ),
                TextButton(
                  onPressed: () => _selectDate(context),
                  child: const Text('Выбрать'),
                ),
              ],
            ),
            // Выбор времени выполнения задачи
            Row(
              children: [
                Expanded(
                  child: Text(
                    _selectedTime == null
                        ? 'Выберите время'
                        : 'Время: ${_selectedTime!.hour}:${_selectedTime!.minute}',
                  ),
                ),
                TextButton(
                  onPressed: () => _selectTime(context),
                  child: const Text('Выбрать'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Поле для ввода заметок
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Заметки',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            // Кнопка сохранения задачи
            ElevatedButton(
              onPressed: _saveTask,
              child: const Text('Сохранить задачу'),
            ),
          ],
        ),
      ),
    );
  }
}
