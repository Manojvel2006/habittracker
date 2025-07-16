class Habit {
  final String id;
  final String name;
  final String frequency;
  final String category;
  final String time;
  final int target;
  final List<String> completedDates;

  Habit({
    required this.id,
    required this.name,
    required this.frequency,
    required this.category,
    required this.time,
    required this.target,
    this.completedDates = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'frequency': frequency,
      'category': category,
      'time': time,
      'target': target,
      'completedDates': completedDates,
      'createdAt': DateTime.now(),
    };
  }

  factory Habit.fromMap(String id, Map<String, dynamic> map) {
    return Habit(
      id: id,
      name: map['name'] ?? '',
      frequency: map['frequency'] ?? '',
      category: map['category'] ?? '',
      time: map['time'] ?? '',
      target: map['target'] ?? 0,
      completedDates: List<String>.from(map['completedDates'] ?? []),
    );
  }

  bool get isCompletedToday {
    final today = DateTime.now();
    final todayStr = "${today.year}-${today.month}-${today.day}";
    return completedDates.contains(todayStr);
  }
}
