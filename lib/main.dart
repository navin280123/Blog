import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lottie/lottie.dart';
import 'blogmain.dart';
import 'login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,

      ),
      debugShowCheckedModeBanner: false, // Remove the debug label
      home: const CheckAuthScreen(),
    );
  }
}

class CheckAuthScreen extends StatefulWidget {
  const CheckAuthScreen({super.key});

  @override
  _CheckAuthScreenState createState() => _CheckAuthScreenState();
}

class _CheckAuthScreenState extends State<CheckAuthScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  void _checkLoginStatus() async {
    // Simulate some delay to show the Lottie animation (e.g., loading, splash screen)
    await Future.delayed(const Duration(seconds: 5));

    // Check the authentication status of the user
    FirebaseAuth.instance.authStateChanges().listen((User? user) async {
      if (user == null) {
        // Navigate to Login screen if the user is not logged in
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => Login()),
        );
      } else {
        // Retrieve the email and find the corresponding username in the database
        String email = user.email ?? '';

        // Reference to the 'username' node in Firebase
        DatabaseReference userRef = FirebaseDatabase.instance.ref().child('username');
        DatabaseEvent event = await userRef.once();
        DataSnapshot snapshot = event.snapshot;

        if (snapshot.exists) {
          String? username;

          // Iterate through the snapshot to find the matching email
          Map<dynamic, dynamic> usersMap = snapshot.value as Map<dynamic, dynamic>;
          usersMap.forEach((key, value) {
            if (value == email) {
              username = key;  // Set username as the key if the email matches
            }
          });

          if (username != null) {
            // Navigate to BlogMain screen with email and username
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => BlogMain(
                  email: email,
                  username: username!,
                ),
              ),
            );
          } else {
            // Handle case where email is not found in the database
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => Login()),
            );
          }
        } else {
          // Handle case where 'username' node doesn't exist
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => Login()),
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Lottie.asset(
          'assets/image/blogloading.json', // Path to your Lottie animation file
          width: 200,
          height: 200,
          fit: BoxFit.fill,
        ),
      ),
    );
  }
}
