import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:uuid/uuid.dart';

class AddPostScreen extends StatefulWidget {
  final String email;
  final String username;

  const AddPostScreen({required this.email, required this.username});

  @override
  _AddPostScreenState createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _captionController = TextEditingController();
  List<File> _images = [];
  bool _isLoading = false;

  Future<void> _pickImages() async {
    final List<XFile>? pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles != null) {
      setState(() {
        _images = pickedFiles.map((file) => File(file.path)).toList();
      });
    }
  }

  Future<File> _compressImage(File file) async {
    final XFile? compressedImage = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      '${file.parent.path}/compressed_${file.path.split('/').last}',
      quality: 85,
    );

    if (compressedImage != null) {
      return File(compressedImage.path);
    } else {
      return file;
    }
  }

  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }

  Future<void> _postToFirebase() async {
    if (_images.isEmpty || _captionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please add images and a caption')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      String postId = Uuid().v4();

      List<String> imageUrls = [];
      for (File image in _images) {
        File compressedImage = await _compressImage(image);
        String fileName = Uuid().v4();
        Reference storageRef = FirebaseStorage.instance
            .ref()
            .child('posts/${widget.username}/$postId/$fileName');
        await storageRef.putFile(compressedImage);
        String downloadUrl = await storageRef.getDownloadURL();
        imageUrls.add(downloadUrl);
      }

      Map<String, dynamic> postData = {
        'caption': _captionController.text,
        'media': imageUrls,
        'username': widget.username,
        'timestamp': DateTime.now().toIso8601String(),
      };

      DatabaseReference userPostRef = FirebaseDatabase.instance
          .ref()
          .child('accounts')
          .child(widget.username)
          .child('posts')
          .child(postId);
      await userPostRef.set(postData);

      DatabaseReference rootPostRef =
      FirebaseDatabase.instance.ref().child('posts').child(postId);
      await rootPostRef.set(postData);

      setState(() {
        _images = [];
        _captionController.clear();
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Post uploaded successfully!')),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload post: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Post'),
        actions: [
          if (!_isLoading)
            IconButton(
              icon: Icon(Icons.done_outline_sharp,color: Colors.green,),
              onPressed: _postToFirebase,
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _captionController,
                    decoration: InputDecoration(
                      labelText: 'Caption',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                ),
                SizedBox(width: 10),
                IconButton(
                  icon: Icon(Icons.add_a_photo),
                  onPressed: _pickImages,
                  color: Colors.blue,
                ),
              ],
            ),
            SizedBox(height: 20),
            _images.isNotEmpty
                ? Container(
              height: 200,
              child: GridView.builder(
                itemCount: _images.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 4.0,
                  mainAxisSpacing: 4.0,
                ),
                itemBuilder: (context, index) {
                  return Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                        ),
                        child: Image.file(_images[index], fit: BoxFit.cover),
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: IconButton(
                          icon: Icon(Icons.highlight_remove, color: Colors.red),
                          onPressed: () => _removeImage(index),
                        ),
                      ),
                    ],
                  );
                },
              ),
            )
                : Container(),
            Spacer(),
            if (_isLoading) CircularProgressIndicator(),

          ],
        ),
      ),
    );
  }
}
