import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

import '../models/habit.dart';
import '../services/auth_service.dart';

import 'login_screen.dart';
import 'add_habit_screen.dart';
import 'edit_habit_screen.dart';
import 'habit_progress_screen.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';

import 'bottom_nav.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final authService = AuthService();
  final userId = FirebaseAuth.instance.currentUser!.uid;
  String userName = "";
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    fetchUserName();
  }

  void _onTabTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> fetchUserName() async {
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
    setState(() {
      userName = userDoc.data()?['name'] ?? 'User';
    });
  }

  Future<List<Habit>> fetchHabits() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('habits')
        .orderBy('createdAt', descending: false)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return Habit.fromMap(doc.id, data);
    }).toList();
  }

  Future<void> toggleHabitToday(Habit habit) async {
    final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final habitRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('habits')
        .doc(habit.id);

    List<String> updatedDates = [...habit.completedDates];
    if (habit.completedDates.contains(todayStr)) {
      updatedDates.remove(todayStr);
    } else {
      updatedDates.add(todayStr);
    }

    await habitRef.update({'completedDates': updatedDates});
    setState(() {});
  }

  void deleteHabit(String habitId) async {
    final confirm = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Delete Habit"),
        content: Text("Are you sure you want to delete this habit?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text("Cancel")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text("Delete", style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('habits')
          .doc(habitId)
          .delete();
      setState(() {}); // Refresh UI
    }
  }

  Widget buildHomeTab() {
    return FutureBuilder<List<Habit>>(
      future: fetchHabits(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting)
          return Center(child: CircularProgressIndicator());

        if (!snapshot.hasData || snapshot.data!.isEmpty)
          return Center(
            child: Text(
              "No habits yet. Tap + to start tracking!",
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
          );

        final habits = snapshot.data!;
        final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());

        return ListView.builder(
          itemCount: habits.length,
          padding: const EdgeInsets.all(12),
          itemBuilder: (context, index) {
            final habit = habits[index];
            final isCompletedToday = habit.completedDates.contains(todayStr);

            return Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 3,
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                tileColor: Colors.white,
                leading: GestureDetector(
                  onTap: () => toggleHabitToday(habit),
                  child: Icon(
                    isCompletedToday ? Icons.check_circle : Icons.radio_button_unchecked,
                    color: isCompletedToday ? Colors.green : Colors.grey,
                    size: 30,
                  ),
                ),
                title: Text(
                  habit.name,
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
                ),
                subtitle: Text(
                  "${habit.category} • ${habit.frequency} @ ${habit.time}",
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
                trailing: Wrap(
                  spacing: 6,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.blue),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EditHabitScreen(habit: habit),
                          ),
                        ).then((_) => setState(() {}));
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => deleteHabit(habit.id),
                    ),
                  ],
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => HabitProgressScreen(habit: habit),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeBlue = Color(0xFF1976D2);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: themeBlue,
        title: Text(
          _selectedIndex == 0 ? "Hi, $userName 👋" : _selectedIndex == 1 ? "Your Profile" : "Settings",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: _selectedIndex == 0
            ? [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await authService.logout();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => LoginScreen()),
              );
            },
          ),
        ]
            : null,
      ),
      backgroundColor: Colors.grey[100],
      body: _selectedIndex == 0
          ? buildHomeTab()
          : _selectedIndex == 1
          ? ProfileScreen()
          : SettingsScreen(),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
        backgroundColor: themeBlue,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddHabitScreen()),
          ).then((_) => setState(() {}));
        },
        child: Icon(Icons.add),
        tooltip: 'Add New Habit',
      )
          : null,
      bottomNavigationBar: BottomNavWidget(
        currentIndex: _selectedIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}
