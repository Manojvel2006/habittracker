import 'package:cloud_firestore/cloud_firestore.dart';

class ProgressService {
  final _firestore = FirebaseFirestore.instance;

  Future<List<DateTime>> getHabitProgress(String habitId) async {
    final snapshot = await _firestore
        .collection('habits')
        .doc(habitId)
        .collection('progress')
        .get();

    return snapshot.docs.map((doc) {
      final timestamp = doc['date'] as Timestamp;
      return timestamp.toDate();
    }).toList();
  }
}
