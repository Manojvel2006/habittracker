import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/habit.dart';

class EditHabitScreen extends StatefulWidget {
  final Habit habit;

  EditHabitScreen({required this.habit});

  @override
  _EditHabitScreenState createState() => _EditHabitScreenState();
}

class _EditHabitScreenState extends State<EditHabitScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController nameController;
  late TextEditingController timeController;
  late String frequency;
  late String category;
  late int target;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.habit.name);
    timeController = TextEditingController(text: widget.habit.time);
    frequency = widget.habit.frequency;
    category = widget.habit.category;
    target = widget.habit.target;
  }

  void updateHabit() async {
    if (!_formKey.currentState!.validate()) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('habits')
          .doc(widget.habit.id)
          .update({
        'name': nameController.text.trim(),
        'time': timeController.text.trim(),
        'frequency': frequency,
        'category': category,
        'target': target,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Habit updated!")),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeBlue = Color(0xFF1976D2);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: themeBlue,
        title: Text("Edit Habit"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(labelText: "Habit Name"),
                validator: (value) => value!.isEmpty ? "Required" : null,
              ),
              TextFormField(
                controller: timeController,
                decoration: InputDecoration(labelText: "Time (e.g., 8:00 AM)"),
                validator: (value) => value!.isEmpty ? "Required" : null,
              ),
              DropdownButtonFormField<String>(
                value: frequency,
                items: ["Daily", "Weekly", "Custom"]
                    .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                    .toList(),
                onChanged: (val) => setState(() => frequency = val!),
                decoration: InputDecoration(labelText: "Frequency"),
              ),
              DropdownButtonFormField<String>(
                value: category,
                items: ["Health", "Productivity", "Learning", "Fitness", "Other"]
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (val) => setState(() => category = val!),
                decoration: InputDecoration(labelText: "Category"),
              ),
              SizedBox(height: 10),
              Text("Target times/day:"),
              Slider(
                value: target.toDouble(),
                min: 1,
                max: 10,
                divisions: 9,
                label: "$target",
                onChanged: (value) => setState(() => target = value.toInt()),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: updateHabit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: themeBlue,
                  padding: EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text("Update Habit", style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
