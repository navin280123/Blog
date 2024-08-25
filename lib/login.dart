
import 'package:blog/ForgotPasswordScreen.dart';
import 'package:blog/blogmain.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/gestures.dart';

final FirebaseDatabase _database = FirebaseDatabase.instance;

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool isLogin = true;
  bool _isLoading = false; // Flag for loading animation
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();

  FirebaseAuth _auth = FirebaseAuth.instance;

  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Lottie.asset(
            'assets/image/login.json',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            isLogin ? 'LOGIN' : 'REGISTER',
                            style: TextStyle(
                              fontSize: 34,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 12),
                          Text(
                            isLogin
                                ? 'Welcome back, kindly sign in and continue your journey with us'
                                : 'Create an account to get started',
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    isLogin = true;
                                  });
                                },
                                child: Text(
                                  'Login',
                                  style: TextStyle(
                                    decoration: isLogin
                                        ? TextDecoration.underline
                                        : TextDecoration.none,
                                  ),
                                ),
                              ),
                              SizedBox(width: 16),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    isLogin = false;
                                  });
                                },
                                child: Text(
                                  'Register',
                                  style: TextStyle(
                                    color: isLogin ? Colors.grey : Colors.black,
                                    decoration: !isLogin
                                        ? TextDecoration.underline
                                        : TextDecoration.none,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          AnimatedSwitcher(
                            duration: Duration(milliseconds: 900),
                            transitionBuilder: (Widget child, Animation<double> animation) {
                              return FadeTransition(child: child, opacity: animation);
                            },
                            child: isLogin
                                ? _buildLoginForm()
                                : _buildRegisterForm(),
                          ),
                          SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState?.validate() ?? false) {
                                setState(() {
                                  _isLoading = true; // Show loading animation
                                });
                                if (isLogin) {
                                  _signInWithEmailAndPassword();
                                } else {
                                  _registerWithEmailAndPassword();
                                }
                              }
                            },
                            child: Text(isLogin ? 'Login' : 'Register'),
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 16,
                              ),
                            ),
                          ),
                          SizedBox(height: 16),
                          Text('Or Connect With'),
                          SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 50,
                                height: 50,
                                child: IconButton(
                                  icon: Image.asset('assets/image/facebook.png'),
                                  onPressed: () {
                                    _launchURL('https://www.facebook.com/');
                                  },
                                ),
                              ),
                              SizedBox(width: 16),
                              SizedBox(
                                width: 50,
                                height: 50,
                                child: IconButton(
                                  icon: Image.asset('assets/image/instagram.png'),
                                  onPressed: () {
                                    _launchURL('https://www.instagram.com/');
                                  },
                                ),
                              ),
                              SizedBox(width: 16),
                              SizedBox(
                                width: 50,
                                height: 50,
                                child: IconButton(
                                  icon: Image.asset('assets/image/twitter.png'),
                                  onPressed: () {
                                    _launchURL('https://www.twitter.com/');
                                  },
                                ),
                              ),
                            ],
                          ),
                          Text.rich(
                            TextSpan(
                              text: 'By signing up, you agree to our ',
                              children: [
                                TextSpan(
                                  text: 'Terms, ',
                                  style: TextStyle(color: Colors.blue),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      // terms and condition section
                                    },
                                ),
                                TextSpan(
                                  text: 'Data Policy ',
                                  style: TextStyle(color: Colors.blue),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      // data policy section
                                    },
                                ),
                                TextSpan(
                                  text: 'and ',
                                ),
                                TextSpan(
                                  text: 'Cookie Policy.',
                                  style: TextStyle(color: Colors.blue),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      // cookie policy section
                                    },
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (_isLoading) // Show loading animation on top
            Positioned.fill(
              child: Container(
                color: Colors.black54,
                child: Center(
                  child: Lottie.asset(
                    'assets/image/loading.json', // Replace with your loading animation asset
                    width: 200,
                    height: 200,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLoginForm() {
    return Column(
      key: ValueKey<bool>(isLogin),
      children: [
        TextFormField(
          controller: _emailController,
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.email),
            hintText: 'Email',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value?.isEmpty ?? true) {
              return 'Please enter your email';
            }
            if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value ?? '')) {
              return 'Please enter a valid email address';
            }
            return null;
          },
        ),
        SizedBox(height: 16),
        TextFormField(
          controller: _passwordController,
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.lock),
            hintText: 'Password',
            border: OutlineInputBorder(),
          ),
          obscureText: true,
          validator: (value) {
            if (value?.isEmpty ?? true) {
              return 'Please enter your password';
            }
            return null;
          },
        ),
        SizedBox(height: 16),
        Align(
          alignment: Alignment.centerRight,
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ForgotPasswordScreen(),
                ),
              );
            },
            child: Text('Forgot password?'),
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterForm() {
    return Column(
      key: ValueKey<bool>(!isLogin),
      children: [
        TextFormField(
          controller: _usernameController,
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.person),
            hintText: 'Username',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value?.isEmpty ?? true) {
              return 'Please enter your username';
            }
            return null;
          },
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
          ],
        ),

        SizedBox(height: 16),
        TextFormField(
          controller: _emailController,
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.email),
            hintText: 'Email',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value?.isEmpty ?? true) {
              return 'Please enter your email';
            }
            if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value ?? '')) {
              return 'Please enter a valid email address';
            }
            return null;
          },
        ),
        SizedBox(height: 16),
        TextFormField(
          controller: _passwordController,
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.lock),
            hintText: 'Password',
            border: OutlineInputBorder(),
          ),
          obscureText: true,
          validator: (value) {
            if (value?.isEmpty ?? true) {
              return 'Please enter your password';
            }
            return null;
          },
        ),
        SizedBox(height: 16),
        TextFormField(
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.lock),
            hintText: 'Confirm Password',
            border: OutlineInputBorder(),
          ),
          obscureText: true,
          validator: (value) {
            if (value != _passwordController.text) {
              return 'Passwords do not match';
            }
            return null;
          },
        ),
      ],
    );
  }

  void _signInWithEmailAndPassword() async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      User? user = userCredential.user;
      if (user != null) {
        String email = user.email ?? '';

        DatabaseReference usernameRef = _database.ref().child('username');
        DatabaseEvent usernameEvent = await usernameRef.once();
        DataSnapshot usernameSnapshot = usernameEvent.snapshot;

        if (usernameSnapshot.exists) {
          bool found = false;

          for (var entry in usernameSnapshot.children) {
            if (entry.value == email) {
              String username = entry.key ?? '';

              // Fetch additional data if needed
              DatabaseReference accountRef = _database.ref()
                  .child('accounts')
                  .child(username)
                  .child('details');
              DatabaseEvent accountEvent = await accountRef.once();
              DataSnapshot accountSnapshot = accountEvent.snapshot;

              if (accountSnapshot.exists) {
                Map<String, dynamic> accountData = {
                  'username': username,
                  'email': email,
                };

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Login Successful")),
                );

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BlogMain(
                      username: accountData['username'],
                      email: accountData['email'],
                    ),
                  ),
                );
              }
              found = true;
              break;
            }
          }

          if (!found) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Username not found")),
            );
          }
        }
      }
    } catch (e) {
      print('Sign in failed: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Login Failed: ${e.toString()}")),
      );
    } finally {
      setState(() {
        _isLoading = false; // Hide loading animation
      });
    }
  }

  void _registerWithEmailAndPassword() async {
    try {
      String username = _usernameController.text.trim();
      String email = _emailController.text.trim();

      DatabaseReference usernameRef = _database.ref().child('username');
      DatabaseEvent usernameEvent = await usernameRef.once();
      DataSnapshot usernameSnapshot = usernameEvent.snapshot;

      if (usernameSnapshot.exists) {
        if (usernameSnapshot.hasChild(username)) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Username already exists")),
          );
          return;
        }
      }

      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: _passwordController.text.trim(),
      );

      // Create the username node
      await usernameRef.child(username).set(email);

      // Create the accounts node
      DatabaseReference accountsRef = _database.ref().child('accounts').child(username);
      await accountsRef.child('details').set({
        'username': username,
        'email': email,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Registration Successful")),
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BlogMain(
            username: username,
            email: email,
          ),
        ),
      );
    } catch (e) {
      print('Registration failed: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Registration Failed: ${e.toString()}")),
      );
    } finally {
      setState(() {
        _isLoading = false; // Hide loading animation
      });
    }
  }
}
