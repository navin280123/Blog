import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileScreen extends StatefulWidget {
  final String username;

  const EditProfileScreen({required this.username});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _genderController = TextEditingController();
  final _picker = ImagePicker();
  String profileImageUrl = '';
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final dbRef = FirebaseDatabase.instance.ref();
    try {
      final userRef = dbRef.child('accounts').child(widget.username);
      final detailsSnapshot = await userRef.child('details').get();
      final details = detailsSnapshot.value as Map<dynamic, dynamic>? ?? {};

      setState(() {
        _nameController.text = details['name'] as String? ?? '';
        _phoneController.text = details['phone'] as String? ?? '';
        _emailController.text = details['email'] as String? ?? '';
        _genderController.text = details['gender'] as String? ?? '';
        profileImageUrl = details['photo'] as String? ?? '';
      });
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  Future<void> _updateProfile() async {
    final dbRef = FirebaseDatabase.instance.ref();
    final userRef = dbRef.child('accounts').child(widget.username);
    final storageRef = FirebaseStorage.instance.ref();
    String? imageUrl;

    setState(() {
      isLoading = true;
    });

    try {
      // Handle image upload if a new image is selected
      if (profileImageUrl.isNotEmpty) {
        final imageRef = storageRef.child('profile_images').child('${widget.username}.jpg');
        final uploadTask = imageRef.putFile(File(profileImageUrl));
        await uploadTask.whenComplete(() => {});
        imageUrl = await imageRef.getDownloadURL();
        print('Image uploaded, URL: $imageUrl');
      }

      // Prepare updates
      final updates = {
        'name': _nameController.text,
        'phone': _phoneController.text,
        'email': _emailController.text,
        'gender': _genderController.text,
      };

      // Include the image URL if it was successfully uploaded
      if (imageUrl != null) {
        updates['photo'] = imageUrl;
      }

      await userRef.child('details').update(updates);

      setState(() {
        isLoading = false;
      });
      Navigator.pop(context);
    } catch (e) {
      print('Error updating profile: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        profileImageUrl = pickedFile.path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _updateProfile,
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: EdgeInsets.all(16.0),
        child: ListView(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 50,
                backgroundImage: profileImageUrl.isNotEmpty
                    ? NetworkImage(profileImageUrl)
                    : null,
                child: profileImageUrl.isEmpty
                    ? Icon(Icons.person, size: 50)
                    : null,
              ),
            ),
            SizedBox(height: 16.0),
            _buildTextField(_nameController, 'Name'),
            SizedBox(height: 16.0),
            _buildTextField(_phoneController, 'Phone'),
            SizedBox(height: 16.0),
            _buildTextField(_emailController, 'Email'),
            SizedBox(height: 16.0),
            _buildTextField(_genderController, 'Gender'),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      ),
    );
  }
}
