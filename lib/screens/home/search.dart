import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:komuniti/constant/color.dart';
import 'package:komuniti/constant/textfield.dart';
import 'package:komuniti/screens/chat/chatScreen.dart';
class SearchScreen extends StatefulWidget {
  SearchScreen({Key? key}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  bool isLoading = false;
  final TextEditingController _controller = TextEditingController();

  Future<DocumentSnapshot<Object?>?>? userEntry;

  void _handleButtonClick() {
    FocusScope.of(context).requestFocus(FocusNode());
    setState(() {
      isLoading = true;
    });

    Future.delayed(Duration(seconds: 2), () {
      final trimmedEmail = _controller.text.replaceAll(' ', ''); // Remove spaces from email

      searchUserEntry(trimmedEmail).then((result) {
        setState(() {
          isLoading = false;
        });

        if (result != null) {
          // Handle the user entry
          print('User found: ${result.data()}');
        } else {
          // Handle user not found
          print('User not found');
        }
      });
    });
  }

  Future<DocumentSnapshot<Object?>?> searchUserEntry(String email) async {
    // Check if user exists in Firestore collection "users" based on email
    final userRef = FirebaseFirestore.instance.collection('users');
    final userSnapshot = await userRef.where('email', isEqualTo: email).get();

    if (userSnapshot.docs.isNotEmpty) {
      // User entry found, return the first document
      return userSnapshot.docs[0];
    } else {
      // User entry not found
      return null;
    }
  }


  Future<void> navigateToChatScreen(DocumentSnapshot<Object?> user) async {
    final name = user['name'];
    final photoUrl = user['photoUrl'];
    final userId = user['id'];
    final token = user['token'];
    final myId = FirebaseAuth.instance.currentUser?.uid;

    print('myId = $myId');
    print('userId = $userId');

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          name: name,
          photoUrl: photoUrl,
          userId: userId,
          rToken: token,
          myId: myId ?? '',
          // Use an empty string as a fallback value if myId is null
        ),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: bgColor,
        title: Text('Find a Friend',style: TextStyle(fontFamily: 'Product Sans'),),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 18.0),
                child: Column(
                  children: [
                    Text('Searching for a friend using email is a convenient way to reconnect or establish new connections. By entering an email address, you can quickly locate individuals and potentially initiate meaningful conversations.\n \nEmail-based friend searches streamline the process of finding and reaching out to friends, making it efficient and straightforward.',
                        style: TextStyle(fontFamily: 'Product Sans',fontSize: 16,fontWeight: FontWeight.w500),).animate().fadeIn(delay: 200.ms, duration: 200.ms).saturate(),
                   SizedBox(height: 30,),
                    AnimatedTextField(
                      controller: _controller,
                      iconData: Icons.person,
                      labelText: 'Enter an Email: johndoe@gmail.com',
                    ).animate().fadeIn(delay: 400.ms, duration: 400.ms).saturate(),
                  ],
                ),
              ),
              SizedBox(height: 15,),
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
                      : Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Text(
                      'Search',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ).animate().fadeIn(delay: 600.ms, duration: 600.ms).saturate(),
              SizedBox(height: 16),
              Divider(),
              if (userEntry != null)
                FutureBuilder<DocumentSnapshot<Object?>?>(
                  future: userEntry,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    } else {
                      if (snapshot.hasData && snapshot.data != null) {
                        // User found
                        final user =
                        snapshot.data!.data() as Map<String, dynamic>;
                        return ListTile(
                          onTap: () => navigateToChatScreen(snapshot.data!),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: CircleAvatar(
                              backgroundImage: NetworkImage(user['photoUrl']),
                            ),
                          ),
                          tileColor: Colors.yellow.withOpacity(0.1),
                          title: Text(
                            user['name'],
                            style: TextStyle(
                              fontSize: 18,
                              fontFamily: 'Rufina',
                              fontWeight: FontWeight.bold,
                              color: bgDarkColor,
                              letterSpacing: 1.0,
                            ),
                          ),
                          subtitle: Text(
                            user['email'],
                            style: TextStyle(
                              fontSize: 12,
                              fontFamily: 'Rufina',
                              fontWeight: FontWeight.normal,
                              color: bgDarkColor,
                              letterSpacing: 1.0,
                            ),
                          ),
                          trailing: Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.black,
                          ),
                        ).animate().fadeIn(delay: 400.ms, duration: 400.ms).saturate();
                      } else {
                        // User not found
                        return Text('User not found');
                      }
                    }
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}