import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.pink, // Changed primary color to orange
        scaffoldBackgroundColor: const Color(0xFFF2F2F2), // Light background color
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.black87),
          titleLarge: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Colors.pink,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.pink, // Changed button color
            foregroundColor: Colors.white,
            textStyle: const TextStyle(fontSize: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30), // Rounded corners for button
            ),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Color(0xFFF1F5F9),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(20)), // Rounded borders for input fields
            borderSide: BorderSide.none,
          ),
        ),
      ),
      home: const LoginScreen(), // Set LoginScreen as the first screen
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  get message => "This User Does not Exsit";

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    final emailRegExp = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegExp.hasMatch(value)) {
      return 'Enter a valid email';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    return null;
  }

  Future<void> _login() async {
    const String url = 'https://devtechtop.com/classproject/public/login';

    final Map<String, String> data = {
      'email': _emailController.text.trim(),
      'password': _passwordController.text,
    };

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse(url),
        body: data,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      );

      setState(() {
        _isLoading = false;
      });

      final responseBody = response.body;
      print('Raw Response: $responseBody');

      if (response.statusCode == 200) {
        if (responseBody.contains('This user does not exist')) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('This user does not exist')),
          );
        } else {
          final decodedResponse = jsonDecode(responseBody);

          if (decodedResponse is Map && decodedResponse['status'] == 'success') {
            final prefs = await SharedPreferences.getInstance();
            final List<dynamic> dataList = decodedResponse['data'];

            if (dataList.isNotEmpty) {
              final userData = dataList[0];

              final String name = userData['name']?.toString() ?? 'No Name';
              final String email = userData['email']?.toString() ?? 'No Email';
              final String degree = userData['degree']?.toString() ?? 'No Degree';
              final String shift = userData['shift']?.toString() ?? 'No Shift';
              
              final int? userId = int.tryParse(userData['id']?.toString() ?? '');
              if (userId == null) {
                print('Error: userId is invalid or null.');
                return;
              }

              await prefs.setInt('userId', userId);
              await prefs.setString('userEmail', email);
              await prefs.setString('userName', name);
              await prefs.setString('userDegree', degree);
              await prefs.setString('userShift', shift);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Login successful!')),
              );

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
              );
            }
          }
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Something went wrong!')),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    body: Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.pinkAccent, Colors.orangeAccent],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Center(
                    child: Text(
                      'Welcome Back',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Please log in to your account',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _emailController,
                    decoration: _inputDecoration(labelText: 'Email'),
                    keyboardType: TextInputType.emailAddress,
                    validator: _validateEmail,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    decoration: _inputDecoration(labelText: 'Password'),
                    obscureText: true,
                    validator: _validatePassword,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      iconColor: Colors.pinkAccent,
                    ),
                    onPressed: () {
                      if (_emailController.text.isNotEmpty &&
                          _passwordController.text.isNotEmpty) {
                        _login();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please fill in both fields'),
                          ),
                        );
                      }
                    },
                    child: const Text(
                      'Login',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  if (_isLoading) ...[
                    const SizedBox(height: 16),
                    const Center(child: CircularProgressIndicator()),
                  ],
                  const SizedBox(height: 24),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SignupScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      'Don\'t have an account? Sign up here',
                      style: TextStyle(color: Colors.pink),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

InputDecoration _inputDecoration({required String labelText}) {
  return InputDecoration(
    filled: true,
    fillColor: Colors.grey[200],
    contentPadding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
    labelText: labelText,
    labelStyle: const TextStyle(color: Colors.black54),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
  );
}
}

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _cellNoController = TextEditingController();
  String? _selectedShift;
  String? _selectedDegree;
  bool _isLoading = false;

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    final nameRegExp = RegExp(r'^[A-Za-z\s]+$');
    if (!nameRegExp.hasMatch(value)) {
      return 'Name cannot contain numbers or special characters';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    final emailRegExp = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegExp.hasMatch(value)) {
      return 'Enter a valid email';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password should be at least 6 characters';
    }
    return null;
  }

  String? _validateCellNo(String? value) {
    if (value == null || value.isEmpty) {
      return 'Cell number is required';
    }
    if (value.length != 11) {
      return 'Cell number must be 11 digits';
    }
    final cellNoRegExp = RegExp(r'^[0-9]+$');
    if (!cellNoRegExp.hasMatch(value)) {
      return 'Cell number must contain only digits';
    }
    return null;
  }

  Future<void> _submitForm() async {
    const String url = 'https://devtechtop.com/classproject/public/insert_user';

    final Map<String, String> data = {
      'name': _nameController.text.trim(),
      'email': _emailController.text.trim(),
      'password': _passwordController.text,
      'cell_no': _cellNoController.text.trim(),
      'degree': _selectedDegree ?? 'BS IT',
      'shift': _selectedShift ?? 'Morning',
      
    };

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse(url),
        body: data,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      );

      setState(() {
        _isLoading = false;
      });

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);

        if (responseBody['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Signup successful!')),
          );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Signup successful!')),
          );
           Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Signup failed')),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

 @override
Widget build(BuildContext context) {
  return Scaffold(
    body: Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.pinkAccent, Colors.orangeAccent],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                    );
                  },
                ),
                const Text(
                  'Sign Up',
                  style: TextStyle(
                    fontSize: 22,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 48), // Placeholder to balance layout
              ],
            ),
            const SizedBox(height: 30),
            Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Center(
                        child: Text(
                          'Create Account',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildTextField(
                        controller: _nameController,
                        labelText: 'Full Name',
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _emailController,
                        labelText: 'Email',
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _passwordController,
                        labelText: 'Password',
                        obscureText: true,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _cellNoController,
                        labelText: 'Cell Number',
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _selectedDegree,
                        hint: const Text('Select Degree'),
                        decoration: _inputDecoration(),
                        items: const [
                          DropdownMenuItem(value: 'BS IT', child: Text('BS IT')),
                          DropdownMenuItem(value: 'BS CS', child: Text('BS CS')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedDegree = value;
                          });
                        },
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Select Shift',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      RadioListTile<String>(
                        value: 'Morning',
                        groupValue: _selectedShift,
                        title: const Text('Morning'),
                        onChanged: (value) {
                          setState(() {
                            _selectedShift = value;
                          });
                        },
                      ),
                      RadioListTile<String>(
                        value: 'Evening',
                        groupValue: _selectedShift,
                        title: const Text('Evening'),
                        onChanged: (value) {
                          setState(() {
                            _selectedShift = value;
                          });
                        },
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16.0), backgroundColor: Colors.pinkAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        onPressed: _submitForm,
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                                'Submit',
                                style: TextStyle(fontSize: 16),
                              ),
                      ),
                      const SizedBox(height: 24),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SignupScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      'Don\'t have an account? Sign up here',
                      style: TextStyle(color: Colors.pink),
                    ),
                  ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

InputDecoration _inputDecoration() {
  return InputDecoration(
    filled: true,
    fillColor: Colors.grey[200],
    contentPadding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
  );
}

Widget _buildTextField({
  required TextEditingController controller,
  required String labelText,
  bool obscureText = false,
  TextInputType keyboardType = TextInputType.text,
}) {
  return TextFormField(
    controller: controller,
    obscureText: obscureText,
    keyboardType: keyboardType,
    decoration: _inputDecoration().copyWith(labelText: labelText),
  );
}
}