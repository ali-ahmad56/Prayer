import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'prayer.dart';

class FetchPrayersPage extends StatefulWidget {
  final String userId;

  const FetchPrayersPage({super.key, required this.userId});

  @override
  _FetchPrayersPageState createState() => _FetchPrayersPageState();
}

class _FetchPrayersPageState extends State<FetchPrayersPage> {
  final String apiUrl = "https://devtechtop.com/store/public/select_prayer";
  List<dynamic> prayers = [];
  bool isLoading = false;
  String apiResponse = "";

  @override
  void initState() {
    super.initState();
    fetchPrayers(widget.userId);
  }

  Future<void> fetchPrayers(String userId) async {
    setState(() {
      isLoading = true;
    });

    try {
      print("Sending request with user_id: $userId");
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'user_id': userId}),
      );

      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      setState(() {
        apiResponse = response.body; // Store response for debugging
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        print("Parsed data: $data");
        setState(() {
          prayers = data['data'] ?? []; // Update to use the correct field name
        });
        return;
      }
    } catch (e) {
      print("Error: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }
@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text(
        'My Prayers',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white, // Text color set to white
        ),
      ),
      centerTitle: true,
      backgroundColor: Colors.pink,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white), // White back arrow
        onPressed: () {
          // Navigate to PrayerScreen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const PrayerScreen()),
          );
        },
      ),
    ),
    body: Padding(
      padding: const EdgeInsets.all(16.0),
      child: isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.pink),
                  SizedBox(height: 16),
                  Text(
                    'Fetching prayers...',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.pink, // Text color set to pink
                    ),
                  ),
                ],
              ),
            )
          : prayers.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 16),
                      Text(
                        apiResponse,
                        style: const TextStyle(fontSize: 14, color: Colors.pink),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  itemCount: prayers.length,
                  separatorBuilder: (context, index) => Divider(
                    color: Colors.pink.withOpacity(0.5),
                    thickness: 1,
                  ),
                  itemBuilder: (context, index) {
                    final prayer = prayers[index];
                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        title: Text(
                          'Prayer on ${prayer['date']}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.pink,
                          ),
                        ),
                        subtitle: _buildPrayerDetails(prayer),
                      ),
                    );
                  },
                ),
    ),
  );
}

/// Helper method to build prayer details
Widget _buildPrayerDetails(Map<String, dynamic> prayer) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _buildPrayerRow('Fajar', prayer['fajar']),
      _buildPrayerRow('Zuhar', prayer['zuhar']),
      _buildPrayerRow('Asar', prayer['asar']),
      _buildPrayerRow('Mugrab', prayer['mugrab']),
      _buildPrayerRow('Isha', prayer['isha']),
    ],
  );
}

/// Helper method to create a single prayer row
Widget _buildPrayerRow(String prayerName, dynamic prayerStatus) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Text(
      '$prayerName: ${prayerStatus ?? 'N/A'}',
      style: const TextStyle(fontSize: 14, color: Colors.black54),
    ),
  );
}
}