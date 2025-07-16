import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/habit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HabitProgressScreen extends StatefulWidget {
  final Habit habit;

  HabitProgressScreen({required this.habit});

  @override
  _HabitProgressScreenState createState() => _HabitProgressScreenState();
}

class _HabitProgressScreenState extends State<HabitProgressScreen> {
  late Map<DateTime, bool> completedDays;
  late DateTime _focusedDay;
  DateTime? _selectedDay;

  final userId = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();

    completedDays = {};
    for (String dateStr in widget.habit.completedDates) {
      DateTime date = _parseDate(dateStr);
      completedDays[DateTime(date.year, date.month, date.day)] = true;
    }
  }

  DateTime _parseDate(String dateStr) {
    final parts = dateStr.split('-');
    int year = int.parse(parts[0]);
    int month = int.parse(parts[1]);
    int day = int.parse(parts[2]);
    return DateTime(year, month, day);
  }

  String _formatDate(DateTime date) {
    return "${date.year}-${date.month}-${date.day}";
  }

  Future<void> _toggleCompletion(DateTime day) async {
    final dayKey = DateTime(day.year, day.month, day.day);
    final habitRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('habits')
        .doc(widget.habit.id);

    setState(() {
      if (completedDays.containsKey(dayKey)) {
        completedDays.remove(dayKey);
      } else {
        completedDays[dayKey] = true;
      }
    });

    List<String> updatedDates = completedDays.keys
        .map((date) => _formatDate(date))
        .toList();

    await habitRef.update({'completedDates': updatedDates});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Progress - ${widget.habit.name}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TableCalendar(
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.now().add(Duration(days: 365)),
          focusedDay: _focusedDay,
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          calendarBuilders: CalendarBuilders(
            defaultBuilder: (context, day, focusedDay) {
              final isCompleted = completedDays[DateTime(day.year, day.month, day.day)] ?? false;
              return Container(
                margin: EdgeInsets.all(6),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted ? Colors.green : null,
                ),
                child: Center(
                  child: Text(
                    '${day.day}',
                    style: TextStyle(
                      color: isCompleted ? Colors.white : null,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
          ),
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
            _toggleCompletion(selectedDay);
          },
        ),
      ),
    );
  }
}
