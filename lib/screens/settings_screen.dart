import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatefulWidget {
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool habitRemindersEnabled = true;
  bool notificationSoundEnabled = true;
  bool motivationalQuotesEnabled = true;

  final List<String> reminderTimes = ['Morning', 'Afternoon', 'Evening'];
  String selectedReminderTime = 'Morning';

  Future<void> _launchUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open the link')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        Text(
          "Notification Settings",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SwitchListTile(
          title: Text("Enable Habit Reminders"),
          value: habitRemindersEnabled,
          onChanged: (val) {
            setState(() {
              habitRemindersEnabled = val;
            });
          },
        ),
        if (habitRemindersEnabled) ...[
          ListTile(
            title: Text("Preferred Reminder Time"),
            trailing: DropdownButton<String>(
              value: selectedReminderTime,
              items: reminderTimes
                  .map((time) => DropdownMenuItem(
                value: time,
                child: Text(time),
              ))
                  .toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    selectedReminderTime = val;
                  });
                }
              },
            ),
          ),
          SwitchListTile(
            title: Text("Notification Sound/Vibration"),
            value: notificationSoundEnabled,
            onChanged: (val) {
              setState(() {
                notificationSoundEnabled = val;
              });
            },
          ),
        ],
        SwitchListTile(
          title: Text("Motivational Quotes / Daily Tips"),
          value: motivationalQuotesEnabled,
          onChanged: (val) {
            setState(() {
              motivationalQuotesEnabled = val;
            });
          },
        ),
        Divider(height: 32),
        Text(
          "App Info",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        ListTile(
          title: Text("App Version"),
          subtitle: Text("1.0.0"),
        ),
        ListTile(
          title: Text("Contact Support / Feedback"),
          leading: Icon(Icons.mail_outline),
          onTap: () {
            final Uri emailLaunchUri = Uri(
              scheme: 'mailto',
              path: 'support@yourapp.com',
              queryParameters: {'subject': 'Habit Tracker App Support'},
            );
            _launchUrl(emailLaunchUri.toString());
          },
        ),
        ListTile(
          title: Text("Rate the App"),
          leading: Icon(Icons.star_border),
          onTap: () {
            const appStoreUrl = 'https://play.google.com/store/apps/details?id=com.yourapp';
            _launchUrl(appStoreUrl);
          },
        ),
      ],
    );
  }
}
