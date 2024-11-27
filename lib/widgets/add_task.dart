import 'package:flutter/material.dart';

class AddTaskPage extends StatefulWidget {
  const AddTaskPage({super.key});

  @override
  AddTaskPageState createState() => AddTaskPageState();
}

class AddTaskPageState extends State<AddTaskPage> {
  final TextEditingController _taskTitleController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  String _selectedCategory = 'Дом';
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  @override
  void dispose() {
    _taskTitleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

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
          const Text(
            'Выбор категории:',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 8),
          // Выпадающий список для выбора категории
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
          // Выбор даты
          Row(
            children: [
              Expanded(
                child: _selectedDate != null
                    ? Text(
                        'Дата: ${_selectedDate!.day.toString().padLeft(2, '0')}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.year}',
                        style: const TextStyle(fontSize: 16),
                      )
                    : const Text(
                        'Дата: ',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
              TextButton(
                onPressed: () => _selectDate(context),
                child: const Text('Выбрать'),
              ),
            ],
          ),
          // Выбор времени
          Row(
            children: [
              Expanded(
                child: Text(
                  _selectedTime == null
                      ? 'Выберите время'
                      : 'Время: ${_selectedTime!.hour}:${_selectedTime!.minute.toString().padLeft(2, '0')}',
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
