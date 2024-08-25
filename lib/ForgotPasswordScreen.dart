import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lottie/lottie.dart';

class ForgotPasswordScreen extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();

  Future<void> _resetPassword(BuildContext context) async {
    // Show loading animation
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(
          child: Lottie.asset(
            'assets/image/loading.json',
            width: 200,
            height: 200,
          ),
        );
      },
    );

    try {
      final email = _emailController.text.trim().replaceAll(RegExp(r'[.@]'), ''); // Remove @ and . from email
      print(email);

      // Check if email exists in Firebase Realtime Database (assuming 'roles' node)
      DatabaseEvent event = await FirebaseDatabase.instance.reference().child('role').child(email).once();
      DataSnapshot snapshot = event.snapshot;
      print(snapshot.value);

      // Check if snapshot has a value
      if (snapshot.value != null) {
        // Send password reset email
        await FirebaseAuth.instance.sendPasswordResetEmail(email: _emailController.text.trim());

        // Dismiss loading animation
        Navigator.of(context).pop();

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Password reset email sent'),
            backgroundColor: Colors.green,
          ),
        );

        // Close current screen or navigate back
        Navigator.of(context).pop();
      } else {
        // Dismiss loading animation
        Navigator.of(context).pop();

        // Email not registered
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: Email is not registered'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Dismiss loading animation
      Navigator.of(context).pop();

      // Handle any errors
      print('Error: ${e.toString()}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Forgot Password',
          style: TextStyle(fontFamily: 'Monsteraat', fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blueAccent,
      ),
      body: Stack(
        children: [
          Lottie.asset(
            'assets/image/login.json',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          Center(
            child: Opacity(
              opacity: 0.8,
              child: Card(
                margin: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Lottie.asset(
                          'assets/image/forgetani.json',
                          width: 150,
                          height: 150,
                          alignment: Alignment.topCenter,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Enter your email to reset your password',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 18, fontFamily: 'Monsteraat', fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 16),
                        TextField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.email),
                            hintText: 'Email',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => _resetPassword(context),
                          child: Text('Submit'),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                            backgroundColor: Colors.blueAccent,
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
    );
  }
}
