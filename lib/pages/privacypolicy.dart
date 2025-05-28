import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Text(
            '''
Privacy Policy

FitCheck respects your privacy and is committed to protecting your personal data. This Privacy Policy outlines how we collect, use, and store your information.

1. **Data Collection**:
We collect basic user data such as your username, profile picture, uploaded photos, and optionally your bio.

2. **Usage**:
Your data is used to support app functionality like displaying your profile, sharing posts, and interacting with others.

3. **Storage**:
All data is securely stored in Firebase Realtime Database and Firebase Storage.

4. **Third-Party Services**:
We use Firebase services, which may collect additional data governed by their own policies.

5. **Your Consent**:
By using FitCheck, you consent to this policy. You may delete your account at any time.

6. **Updates**:
We may update this policy. Continued use of the app means you accept the updated terms.

If you have any questions, please contact support@fitcheck.app.
            ''',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
        ),
      ),
    );
  }
}
