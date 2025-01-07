import 'package:flutter/material.dart';
import 'package:prayer_app/google.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'main.dart';
import 'prayer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _userEmail = '';
  String _userName = '';
  String _userDegree = '';
  String _userShift = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Method to load user data from SharedPreferences
  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      _userEmail = prefs.getString('userEmail') ?? 'No email found';
      _userName = prefs.getString('userName') ?? 'No name found';
      _userDegree = prefs.getString('userDegree') ?? 'No degree found';
      _userShift = prefs.getString('userShift') ?? 'No shift found';
    });
  }
@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text(
        'Home',
        style: TextStyle(color: Colors.white),
      ),
      backgroundColor: Colors.pink,
      automaticallyImplyLeading: false, // Remove default back arrow
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        },
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.access_alarm, color: Colors.white),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const PrayerScreen()),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.map, color: Colors.white),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) =>  MapPage()),
            );
          },
        ),
      ],
    ),
    body: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: Card(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          color: Colors.pink[50],
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.pink[200],
                      child: const Icon(
                        Icons.person,
                        size: 30,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Welcome, $_userName',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.pink[800],
                          ),
                    ),
                  ],
                ),
                const Divider(
                  color: Colors.pink,
                  thickness: 1,
                  height: 30,
                ),
                _infoRow('Email', _userEmail),
                const SizedBox(height: 10),
                _infoRow('Degree', _userDegree),
                const SizedBox(height: 10),
                _infoRow('Shift', _userShift),
                const SizedBox(height: 20),
                
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

Widget _infoRow(String label, String value) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        '$label:',
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.pink,
        ),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: Text(
          value,
          style: const TextStyle(color: Colors.black87),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ],
  );
}
}