import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'show.dart';
class PrayerScreen extends StatefulWidget {
  const PrayerScreen({super.key});

  @override
  _PrayerScreenState createState() => _PrayerScreenState();
}

class _PrayerScreenState extends State<PrayerScreen> {
  late Database _db;
  String _userId = '';
  String _currentDate = '';
  final Map<String, String> _prayerSelection = {
    'Fajr': '',
    'Dhuhr': '',
    'Asr': '',
    'Maghrib': '',
    'Isha': '',
  };

  @override
  void initState() {
    super.initState();
    _initializeDatabase();
    _loadUserData();
    _updateCurrentDate();
  }

  Future<void> _initializeDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, 'prayers.db');

    _db = await openDatabase(
      path,
      onCreate: (db, version) {
        return db.execute(''' 
          CREATE TABLE prayers (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id TEXT,
            date TEXT,
            fajar TEXT,
            zuhar TEXT,
            asar TEXT,
            mugrab TEXT,
            isha TEXT,
            uploaded INTEGER DEFAULT 0
          )
        ''');
      },
      version: 1,
    );
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getInt('userId')?.toString() ?? '';
    });

    if (_userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: userId not found in SharedPreferences.')),
      );
    }
  }

  void _updateCurrentDate() {
    final now = DateTime.now();
    setState(() {
      _currentDate =
          "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    });
  }

 Future<bool> _checkIfDataExists(String userId, String date) async {
  final result = await _db.query(
    'prayers',
    where: 'user_id = ? AND date = ?',
    whereArgs: [userId, date],
  );
  return result.isNotEmpty; // Returns true if the data exists
}


  Future<void> _savePrayerLocally() async {
  final exists = await _checkIfDataExists(_userId, _currentDate); // Pass the actual user ID and current date
  if (exists) {
    ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Data already exists for this user on this date: $_userId , $_currentDate')),
    );
    return; // Exit early if data already exists
  }

  // Proceed to save the prayer data if it doesn't exist
  await _db.insert('prayers', {
    'user_id': _userId,
    'date': _currentDate,
    'fajar': _prayerSelection['Fajr'],
    'zuhar': _prayerSelection['Dhuhr'],
    'asar': _prayerSelection['Asr'],
    'mugrab': _prayerSelection['Maghrib'],
    'isha': _prayerSelection['Isha'],
    'uploaded': 0,
  });

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => PrayerDataPage(
        db: _db,
        currentDate: _currentDate,
        userId: _userId,
      ),
    ),
  );
}
@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text(
        'Daily Prayer',
        style: TextStyle(color: Colors.white),
      ),
      backgroundColor: Colors.pink,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.storage, color: Colors.white),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PrayerDataPage(
                  db: _db,
                  currentDate: _currentDate,
                  userId: _userId,
                ),
              ),
            );
          },
        ),
      ],
    ),
    body: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Track Your Prayers',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.pink,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 10),
          Text(
            'Date: $_currentDate',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.pink,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const Divider(height: 30, thickness: 2),
          Expanded(
            child: ListView.builder(
              itemCount: _prayerSelection.keys.length,
              itemBuilder: (context, index) {
                String prayer = _prayerSelection.keys.elementAt(index);
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      prayer,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.pink,
                          ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<String>(
                            title: const Text('Yes'),
                            value: 'Yes',
                            groupValue: _prayerSelection[prayer],
                            onChanged: (value) {
                              setState(() {
                                _prayerSelection[prayer] = value!;
                              });
                            },
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<String>(
                            title: const Text('No'),
                            value: 'No',
                            groupValue: _prayerSelection[prayer],
                            onChanged: (value) {
                              setState(() {
                                _prayerSelection[prayer] = value!;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                  ],
                );
              },
            ),
          ),
          Center(
            child: ElevatedButton(
              onPressed: _prayerSelection.values.contains('') ? null : _savePrayerLocally,
              style: ElevatedButton.styleFrom(
                backgroundColor: _prayerSelection.values.contains('')
                    ? Colors.pink[200]
                    : Colors.pink,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 5,
              ),
              child: const Text(
                'Save Prayer Data',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
}

class PrayerDataPage extends StatelessWidget {
  final Database db;
  final String currentDate;
  final String userId;

  const PrayerDataPage({
    super.key,
    required this.db,
    required this.currentDate,
    required this.userId,
  });

  Future<List<Map<String, dynamic>>> _fetchPrayerData() async {
    try {
      return await db.query(
        'prayers',
        where: 'user_id = ? AND date = ?',
        whereArgs: [userId, currentDate],
      );
    } catch (error) {
      throw Exception('Failed to fetch prayer data: $error');
    }
  }

  Future<void> _uploadPrayerData(BuildContext context, Map<String, dynamic> prayerData) async {
    const url = 'https://devtechtop.com/store/public/insert_prayer';
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': prayerData['user_id'],
          'date': prayerData['date'],
          'fajar': prayerData['fajar'],
          'zuhar': prayerData['zuhar'],
          'asar': prayerData['asar'],
          'mugrab': prayerData['mugrab'],
          'isha': prayerData['isha'],
        }),
      );

      if (response.statusCode == 200) {
        await db.delete(
          'prayers',
          where: 'id = ?',
          whereArgs: [prayerData['id']],
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Prayer data uploaded and deleted locally.')),
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FetchPrayersPage(userId: prayerData['user_id']),
          ),
        );
      } else {
        await db.delete(
          'prayers',
          where: 'id = ?',
          whereArgs: [prayerData['id']],
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Prayer data uploaded and deleted locally.')),
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FetchPrayersPage(userId: prayerData['user_id']),
          ),
        );
      }
    } catch (error) {
      await db.delete(
        'prayers',
        where: 'id = ?',
        whereArgs: [prayerData['id']],
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Prayer data uploaded and deleted locally.')),
      );
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FetchPrayersPage(userId: prayerData['user_id']),
        ),
      );
    }
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text(
        'Prayer Data',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white, // Text color set to white
        ),
      ),
      backgroundColor: Colors.pink, // AppBar color set to pink
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const PrayerScreen()),
          );
        },
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.cloud_upload, color: Colors.white),
          onPressed: () async {
            final data = await _fetchPrayerData();
            if (data.isNotEmpty) {
              await _uploadPrayerData(context, data.first);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('No data available for upload.'),
                ),
              );
            }
          },
        ),
      ],
    ),
    body: FutureBuilder<List<Map<String, dynamic>>>(
      future: _fetchPrayerData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(
            child: Text(
              'Error loading prayer data.',
              style: TextStyle(color: Colors.red),
            ),
          );
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text(
              'No prayer data found.',
              style: TextStyle(
                color: Colors.pink, // Color set to match the theme
                fontSize: 16,
              ),
            ),
          );
        }
        final data = snapshot.data!;
        return ListView.builder(
          itemCount: data.length,
          itemBuilder: (context, index) {
            final prayer = data[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                title: Text(
                  'Date: ${prayer['date']}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.pink, // Title color set to pink
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPrayerRow('Fajr', prayer['fajar']),
                    _buildPrayerRow('Dhuhr', prayer['zuhar']),
                    _buildPrayerRow('Asr', prayer['asar']),
                    _buildPrayerRow('Maghrib', prayer['mugrab']),
                    _buildPrayerRow('Isha', prayer['isha']),
                  ],
                ),
              ),
            );
          },
        );
      },
    ),
  );
}

/// Helper method to build prayer rows
Widget _buildPrayerRow(String prayerName, dynamic prayerStatus) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Text(
      '$prayerName: ${prayerStatus ?? 'N/A'}',
      style: const TextStyle(
        fontSize: 14,
        color: Colors.black87, // Subtitle text color
      ),
    ),
  );
}
}