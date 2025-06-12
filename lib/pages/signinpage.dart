import 'package:flutter/material.dart';

import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fitcheck/pages/profile_page.dart';
import 'package:fitcheck/pages/createaccountpage.dart';
import 'package:fitcheck/pages/gsusername.dart';
import 'package:fitcheck/pages/gsemail.dart';



class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final TextEditingController _signInUsernameController = TextEditingController();
  final TextEditingController _signInPasswordController = TextEditingController();
    final DatabaseReference databaseRef = FirebaseDatabase.instance.ref();
  bool _passwordVisible = false;
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  void _signIn() async {
    final username = _signInUsernameController.text.trim();
    final password = _signInPasswordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter username and password')),
      );
      return;
    }

    try {
      final snapshot = await databaseRef.child('users/$username').get();
      if (snapshot.exists) {
        final userData = snapshot.value as Map;
        final storedPassword = userData['password'];

        if (storedPassword == password) {

          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('username', username);
          
           final snapshot = await FirebaseDatabase.instance
        .ref('users/$username/pets')
        .get();

    if (snapshot.exists) {
      final petsMap = Map<String, dynamic>.from(snapshot.value as Map);
      final firstPetName = petsMap.keys.first;
      await prefs.setString('animal', firstPetName);
      
    }


          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Signed in successfully')),
          );
          Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ProfilePage(),
      ),
    );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Incorrect password')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Username does not exist')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error signing in: $e')),
      );
    }
  }

 @override
Widget build(BuildContext context) {
  return   GestureDetector(
    onTap: () => FocusScope.of(context).unfocus(),
    child: Scaffold(
      key: _scaffoldKey,
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: AssetImage('assets/images/background.png'),
                ),
              ),
            ),
          ),

          // Foreground UI
          Center(
  child: SafeArea(child: SingleChildScrollView(
    child: Container(
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'PAWPRINT',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFFBA76),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Let\'s get started by filling out the form below.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFFFFBA76),
              ),
            ),
            const SizedBox(height: 32),
            TextFormField(
  style: const TextStyle(
    color: Color(0xFFFFBA76),
    fontSize: 18,
  ),
  controller: _signInUsernameController,
  decoration: InputDecoration(
    labelText: 'Username',
    labelStyle: TextStyle(
      color: Color(0xFFFFBA76),
      fontSize: 18,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Color(0xFFFFBA76)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Color(0xFFFFBA76), width: 2),
    ),
  ),
  validator: (value) =>
      value == null || value.isEmpty ? 'Enter username' : null,
),

            const SizedBox(height: 16),
           TextFormField(
  style: const TextStyle(
    color: Color(0xFFFFBA76),
    fontSize: 18,
  ),
  controller: _signInPasswordController,
  obscureText: !_passwordVisible,
  decoration: InputDecoration(
    labelText: 'Password',
    labelStyle: TextStyle(
      color: Color(0xFFFFBA76),
      fontSize: 18,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Color(0xFFFFBA76)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Color(0xFFFFBA76), width: 2),
    ),
    suffixIcon: IconButton(
      icon: Icon(
        _passwordVisible ? Icons.visibility : Icons.visibility_off,
        color: Color(0xFFFFBA76),
      ),
      onPressed: () {
        setState(() {
          _passwordVisible = !_passwordVisible;
        });
      },
    ),
  ),
  validator: (value) =>
      value == null || value.isEmpty ? 'Enter password' : null,
),

            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _signIn();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFFFBA76),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                minimumSize: Size(double.infinity, 48),
              ),
              child: Text(
                'Log In',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const PETGettingStartedWidget(),
                                      ),
                                    ),
              child: Text(
                "Don't have an account? Sign up",
                style: TextStyle(
                  color: Color(0xFFFFBA76),
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  ),
  ),
),

        ],
      ),
    ),
  );
  
}
}
