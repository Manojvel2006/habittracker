import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/habit.dart';

class AddHabitScreen extends StatefulWidget {
  @override
  _AddHabitScreenState createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends State<AddHabitScreen> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final timeController = TextEditingController();
  String frequency = "Daily";
  String category = "Health";
  int target = 1;

  final themeBlue = Color(0xFF1976D2);

  void addHabit() async {
    if (_formKey.currentState!.validate()) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        Habit habit = Habit(
          id: '', // Placeholder
          name: nameController.text.trim(),
          frequency: frequency,
          category: category,
          time: timeController.text.trim(),
          target: target,
        );

        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('habits')
            .add(habit.toMap());

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("✅ Habit added successfully!")),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text("Create New Habit"),
        backgroundColor: themeBlue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Habit name
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: "Habit Name",
                  prefixIcon: Icon(Icons.edit, color: themeBlue),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? "Please enter habit name" : null,
              ),
              SizedBox(height: 20),

              // Time
              TextFormField(
                controller: timeController,
                decoration: InputDecoration(
                  labelText: "Preferred Time (e.g., 8:00 AM)",
                  prefixIcon: Icon(Icons.access_time, color: themeBlue),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? "Please enter time" : null,
              ),
              SizedBox(height: 20),

              // Frequency
              DropdownButtonFormField<String>(
                value: frequency,
                decoration: InputDecoration(
                  labelText: "Frequency",
                  prefixIcon: Icon(Icons.repeat, color: themeBlue),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: ["Daily", "Weekly", "Custom"]
                    .map((val) =>
                        DropdownMenuItem(value: val, child: Text(val)))
                    .toList(),
                onChanged: (val) => setState(() => frequency = val!),
              ),
              SizedBox(height: 20),

              // Category
              DropdownButtonFormField<String>(
                value: category,
                decoration: InputDecoration(
                  labelText: "Category",
                  prefixIcon: Icon(Icons.category, color: themeBlue),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: [
                  "Health",
                  "Productivity",
                  "Learning",
                  "Fitness",
                  "Other"
                ].map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(),
                onChanged: (val) => setState(() => category = val!),
              ),
              SizedBox(height: 30),

              Text(
                "Target (times/day)",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Slider(
                value: target.toDouble(),
                min: 1,
                max: 10,
                divisions: 9,
                label: "$target",
                activeColor: themeBlue,
                onChanged: (value) => setState(() => target = value.toInt()),
              ),
              SizedBox(height: 30),

              // Save button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: addHabit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: themeBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: Icon(Icons.save),
                  label: Text("Save Habit", style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
