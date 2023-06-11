import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:komuniti/constant/color.dart';
import 'package:komuniti/constant/textfield.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_app_check/firebase_app_check.dart' as firebase_app_check;

class GroupCreationScreen extends StatefulWidget {
  final String currentUserId;

  const GroupCreationScreen({Key? key, required this.currentUserId}) : super(key: key);

  @override
  _GroupCreationScreenState createState() => _GroupCreationScreenState();
}

class _GroupCreationScreenState extends State<GroupCreationScreen> {
  TextEditingController _groupNameController = TextEditingController();
  TextEditingController _groupDescriptionController = TextEditingController();
  late ImagePicker _imagePicker;
  String? _selectedImagePath;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeImagePicker();
    _appCheck();
  }

  void _initializeImagePicker() {
    _imagePicker = ImagePicker();
  }

  Future<void> _selectImage() async {
    final pickedFile = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImagePath = pickedFile.path;
      });
    }
  }

  void _dismissKeyboard() {
    FocusScope.of(context).unfocus();
  }

  Future<void> _handleButtonClick() async {
    _dismissKeyboard();
    setState(() {
      isLoading = true;
    });

    String? groupId = await createGroup();

    if (groupId != null) {
      // Group created successfully, use the groupId as needed
      print('Group created with ID: $groupId');
      await FirebaseFirestore.instance
          .collection('groups')
          .doc(groupId)
          .collection('members')
          .doc(widget.currentUserId)
          .set({
        'userId': widget.currentUserId,
        'role': 'admin',
        // Add other user data if needed
      });
      print('User added as admin and member.');

      // Create a collection for messages
      await FirebaseFirestore.instance
          .collection('groups')
          .doc(groupId)
          .collection('messages')
          .doc(); // Add document ID if needed

      // Reset the form and loading state
      setState(() {
        isLoading = false;
      });
    } else {
      // Group creation failed
      print('Group creation failed. Please fill in all the required fields.');

      // Reset the loading state
      setState(() {
        isLoading = false;
      });
    }
  }
  Future<String?> createGroup() async {
    // Get the group name and description from the text controllers
    String groupName = _groupNameController.text.trim();
    String groupDescription = _groupDescriptionController.text.trim();

    if (groupName.isNotEmpty &&
        groupDescription.isNotEmpty &&
        _selectedImagePath != null) {
      try {
        // Upload the image to Firebase Storage
        String imageFileName =
        DateTime.now().millisecondsSinceEpoch.toString();
        Reference storageReference = FirebaseStorage.instance
            .ref()
            .child('group_images/$imageFileName');
        UploadTask uploadTask =
        storageReference.putFile(File(_selectedImagePath!));
        TaskSnapshot taskSnapshot = await uploadTask;
        String imageUrl = await taskSnapshot.ref.getDownloadURL();

        // Get a reference to the Firestore collection for groups



        CollectionReference groupsCollection =
        FirebaseFirestore.instance.collection('groups');

        // Generate a unique groupId using custom function
        String groupId = generateGroupId();
        DocumentReference groupDocRef = groupsCollection.doc(groupId);

        // Create a map with the group data
        Map<String, dynamic> groupData = {
          'name': groupName,
          'description': groupDescription,
          'image': imageUrl,
          'adminId': widget.currentUserId,
          // Add other group data if needed
        };

        // Create the group document in Firestore
        await groupDocRef.set(groupData);
        print('Group document created');

        // Return the groupId
        return groupId;
      } catch (e) {
        print('Error creating group: $e');
        return null;
      }
    }
    return null;
  }

  void _appCheck() {
    WidgetsFlutterBinding.ensureInitialized();
    // Initialize Firebase App Check
    firebase_app_check.FirebaseAppCheck.instance
        .activate(webRecaptchaSiteKey: '562E1951-BB89-406A-98FA-538D92380F05');

  }
  String generateGroupId() {
    // Implement your custom logic to generate a unique group ID
    // For example, you can use a combination of timestamp and a random string
    String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    String randomString = generateRandomString(); // Implement your own function to generate a random string
    return '$timestamp-$randomString';
  }

  String generateRandomString() {
    // Implement your custom logic to generate a random string
    // For example, you can use the random package or generate a random alphanumeric string
    // Here's an example using the random package
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    const length = 10;
    final random = Random();
    return List.generate(length, (index) => chars[random.nextInt(chars.length)]).join();
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: bgColor,
        title: Text('Create Group'),
      ),
      body: SafeArea(
        child: GestureDetector(
          onTap: _dismissKeyboard,
          child: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.all(16.0),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _selectImage,
                    child: Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color.fromRGBO(255, 255, 0, 0.1), // Yellow color with opacity 0.1
                      ),
                      child: CircleAvatar(
                        radius: 64.0,
                        backgroundImage: _selectedImagePath != null
                            ? FileImage(File(_selectedImagePath!))
                            : null,
                        child: _selectedImagePath == null
                            ? Icon(Icons.add_a_photo, size: 32.0)
                            : null,
                      ),
                    ),
                  ),
                  SizedBox(height: 26.0),
                  AnimatedTextField(
                    controller: _groupNameController,
                    iconData: Icons.group,
                    labelText: 'Group Name',
                  ),
                  SizedBox(height: 16.0),
                  AnimatedTextField(
                    controller: _groupDescriptionController,
                    iconData: Icons.description_outlined,
                    labelText: 'Group Description',
                  ),
                  SizedBox(height: 96.0),
                  GestureDetector(
                    onTap: isLoading ? null : _handleButtonClick,
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: EdgeInsets.all(15),
                      alignment: Alignment.center,
                      child: isLoading
                          ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          valueColor:
                          AlwaysStoppedAnimation<Color>(Colors.white),
                          strokeWidth: 2,
                        ),
                      )
                          : const Padding(
                        padding: EdgeInsets.all(5.0),
                        child: Text(
                          'Create Group',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

}
