import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:komuniti/constant/color.dart';
import 'package:komuniti/screens/chat/chatScreen.dart';
import 'package:komuniti/screens/chat/contoller.dart';
import 'package:get/get.dart';
import 'package:komuniti/screens/home/search.dart';

class ChatsScreen extends StatefulWidget {
  @override
  _ChatsScreenState createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen>
    with WidgetsBindingObserver, AutomaticKeepAliveClientMixin {
  bool get wantKeepAlive => true;
  final ChatPageController _chatPageController = Get.put(ChatPageController());


  Widget buildChatList(List<Map<String, dynamic>> users) {
    return ListView.builder(
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        final unreadCount = user['unreadCount'] as int?;

        return AnimationConfiguration.staggeredList(
          position: index,
          duration: const Duration(milliseconds: 1900),
          child: FadeInAnimation(
            child: InkWell(
              onTap: () {
                final currentUserId = _chatPageController.currentUserId;
                if (currentUserId != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(
                        name: user['name'],
                        photoUrl: user['photoUrl'],
                        userId: user['id'],
                        rToken: user['token'],
                        myId: currentUserId,
                      ),
                    ),
                  );
                }
              },
              child: Padding(
                padding: const EdgeInsets.only(top: 2.0, bottom: 1),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: CachedNetworkImageProvider(
                      user['photoUrl'],
                    ),
                  ),
                  title: Text(
                    user['name'],
                    style: TextStyle(
                      fontFamily: 'Product Sans',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: user['lastMessage'] == 'Image'
                      ? Row(
                    children: [
                      Icon(Icons.image, size: 18),
                      SizedBox(width: 5),
                      Text(
                        user['lastMessage'],
                        style: TextStyle(
                          fontFamily: 'Product Sans',
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ],
                  )
                      : Text(
                    user['lastMessage'],
                    style: TextStyle(
                      fontFamily: 'Product Sans',
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  trailing: unreadCount != null && unreadCount > 0
                      ? Container(
                    decoration: BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                    ),
                    padding: EdgeInsets.all(6),
                    child: Text(
                      unreadCount.toString(),
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                      : SizedBox.shrink(),

                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
    _chatPageController.getCurrentUserId();
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      body: Stack(
          children: [
            StreamBuilder<List<Map<String, dynamic>>>(
              stream: _chatPageController.chatsController.stream,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  // Show a loading indicator if data is not available yet
                  return Container(
                    alignment: Alignment.topCenter,
                    padding: EdgeInsets.all(16.0),
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.black,
                        ),
                      ),
                    ),
                  );
                }

                if (snapshot.data!.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Center(
                      child: Text(
                        'Get Started. Start Chat by searching for friends',
                        style: TextStyle(
                          fontFamily: 'Product Sans',
                          fontWeight: FontWeight.normal,
                          fontSize: 16,
                        ),
                      ).animate().fadeIn(delay: 1000.ms, duration: 600.ms).saturate(),
                    ),
                  );
                }

                final users = snapshot.data!;

                return buildChatList(users);
              },
            ),

          ],
        ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SearchScreen(),
            ),
          );
        },
        backgroundColor: Colors.black,
        child: Icon(Icons.add, size: 32, color: Colors.white),
      ).animate().fadeIn(delay: 1200.ms, duration: 1000.ms).saturate(),
    );
  }
}