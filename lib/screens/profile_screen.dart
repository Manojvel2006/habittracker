// lib/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatefulWidget {
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final user = FirebaseAuth.instance.currentUser;
  final _firestore = FirebaseFirestore.instance;

  String userName = "";
  String email = "";
  String mobile = "";

  bool _loading = true;
  bool _savingMobile = false;

  final _formKey = GlobalKey<FormState>();
  final _mobileController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  @override
  void dispose() {
    _mobileController.dispose();
    super.dispose();
  }

  Future<void> fetchUserData() async {
    if (user == null) {
      // No user logged in, handle accordingly (maybe redirect)
      setState(() {
        _loading = false;
      });
      return;
    }

    try {
      final doc = await _firestore.collection('users').doc(user!.uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          userName = data['name'] ?? "";
          email = data['email'] ?? user!.email ?? "";
          mobile = data['mobile'] ?? "";
          _mobileController.text = mobile;
          _loading = false;
        });
      } else {
        // Document not found, fallback to auth email
        setState(() {
          userName = "";
          email = user!.email ?? "";
          mobile = "";
          _loading = false;
        });
      }
    } catch (e) {
      print("Error fetching user data: $e");
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> saveMobile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _savingMobile = true;
    });

    try {
      await _firestore.collection('users').doc(user!.uid).set({
        'mobile': _mobileController.text.trim(),
        // If you want, also update name/email here or keep them unchanged
      }, SetOptions(merge: true));

      setState(() {
        mobile = _mobileController.text.trim();
        _savingMobile = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Mobile number saved")),
      );
    } catch (e) {
      setState(() {
        _savingMobile = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to save mobile number")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeBlue = Color(0xFF1976D2);

    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: Text("Settings & Profile"), backgroundColor: themeBlue),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Settings & Profile"),
        backgroundColor: themeBlue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: ListView(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: themeBlue,
              child: Text(
                userName.isNotEmpty ? userName[0].toUpperCase() : "",
                style: TextStyle(fontSize: 40, color: Colors.white),
              ),
            ),
            SizedBox(height: 24),

            Text("Name", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            SizedBox(height: 6),
            Text(userName.isNotEmpty ? userName : "(Not set)", style: TextStyle(fontSize: 18)),

            SizedBox(height: 20),

            Text("Email", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            SizedBox(height: 6),
            Text(email, style: TextStyle(fontSize: 18)),

            SizedBox(height: 20),

            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Mobile Number", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  SizedBox(height: 6),
                  TextFormField(
                    controller: _mobileController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      hintText: "Enter your mobile number",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      suffixIcon: _savingMobile
                          ? Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                          : IconButton(
                        icon: Icon(Icons.save, color: themeBlue),
                        onPressed: saveMobile,
                        tooltip: "Save Mobile Number",
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) return "Please enter your mobile number";
                      if (!RegExp(r'^\+?[0-9]{7,15}$').hasMatch(value)) return "Enter a valid phone number";
                      return null;
                    },
                  ),
                ],
              ),
            ),

            SizedBox(height: 30),

            ElevatedButton.icon(
              onPressed: () {
                // TODO: Add change password functionality or navigate to change password screen
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Change Password tapped")),
                );
              },
              icon: Icon(Icons.lock_outline),
              label: Text("Change Password"),
              style: ElevatedButton.styleFrom(
                backgroundColor: themeBlue,
                padding: EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),

            SizedBox(height: 15),

            ElevatedButton.icon(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
              },
              icon: Icon(Icons.logout),
              label: Text("Logout"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                padding: EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
