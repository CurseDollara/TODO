import 'package:flutter/material.dart';

class Task {
  String title;
  bool isCompleted;
  DateTime? date;
  TimeOfDay? time;
  String? notes;

  Task({
    required this.title,
    this.isCompleted = false,
    this.date,
    this.time,
    this.notes,
  });
}

