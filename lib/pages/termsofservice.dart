import 'package:flutter/material.dart';

class TermsOfServicePage extends StatelessWidget {
  const TermsOfServicePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Terms of Service"),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: const [
            Text(
              "Terms of Service",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 16),
            Text(
              "By using this app, you agree to the following terms and conditions. Please read them carefully.",
              style: TextStyle(color: Colors.white70),
            ),
            SizedBox(height: 20),
            Text(
              "1. Usage",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            Text(
              "You may use this app only for lawful purposes. You must not misuse or tamper with the functionality of the app.",
              style: TextStyle(color: Colors.white70),
            ),
            SizedBox(height: 16),
            Text(
              "2. Content",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            Text(
              "You are responsible for any content you upload or share. We reserve the right to remove any content deemed inappropriate.",
              style: TextStyle(color: Colors.white70),
            ),
            SizedBox(height: 16),
            Text(
              "3. Privacy",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            Text(
              "We collect and store user data as outlined in our Privacy Policy. By using this app, you consent to our data practices.",
              style: TextStyle(color: Colors.white70),
            ),
            SizedBox(height: 16),
            Text(
              "4. Modifications",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            Text(
              "We may update these terms at any time. Continued use of the app implies acceptance of the updated terms.",
              style: TextStyle(color: Colors.white70),
            ),
            SizedBox(height: 16),
            Text(
              "5. Contact",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            Text(
              "If you have any questions about these Terms, please contact us at support@example.com.",
              style: TextStyle(color: Colors.white70),
            ),
            SizedBox(height: 40),
            Center(
              child: Text(
                "© 2025 Your App Name. All rights reserved.",
                style: TextStyle(color: Colors.white38, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
