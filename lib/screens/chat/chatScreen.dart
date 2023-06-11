import 'dart:async';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path/path.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:komuniti/constant/color.dart';
import 'package:komuniti/screens/chat/message.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatScreen extends StatefulWidget {
  final String name;
  final String photoUrl;
  final String userId;
  final String myId;
  final String  rToken;
  ChatScreen({
    required this.name,
    required this.photoUrl,
    required this.userId,
    required this.myId,
    required this.rToken
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  TextEditingController _controller = TextEditingController();
  String? documentId;
  List<Map<String, dynamic>> chatMessages = [];
  bool _isLoading = true;
  @override
  void initState() {
    super.initState();
    loadChatMessages();
    getChatDocumentId(widget.myId, widget.userId).then((id) {
      setState(() {
        documentId = id;
        _isLoading = false;
      });
    });
  }
  late String _filePath;
  Future<void> loadChatMessages() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? chatMessagesJson = prefs.getString('chatMessages');

      if (chatMessagesJson != null) {
        setState(() {
          chatMessages = List<Map<String, dynamic>>.from(
            jsonDecode(chatMessagesJson),
          );
        });
      }
    } catch (e) {
      print('Error loading chat messages: $e');
    }
  }
  void _playSound() async {
    AudioPlayer().play(AssetSource('images/send.mp3'));
  }
  Future<void> saveChatMessages() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String chatMessagesJson = jsonEncode(chatMessages);
      await prefs.setString('chatMessages', chatMessagesJson);
    } catch (e) {
      print('Error saving chat messages: $e');
    }
  }

  Future<String?> getChatDocumentId(String myId, String userId) async {
    String? documentId;

    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('chats')
          .where('participants', arrayContains: myId)
          .get();

      if (querySnapshot.size > 0) {
        List<QueryDocumentSnapshot> matchingDocs = querySnapshot.docs.where((doc) =>
        doc['participants'].contains(myId) && doc['participants'].contains(userId)).toList();

        if (matchingDocs.isNotEmpty) {
          documentId = matchingDocs.first.id;
        }
      }

      if (documentId == null) {
        DocumentReference newChatRef =
        FirebaseFirestore.instance.collection('chats').doc();

        await newChatRef.set({
          'participants': [myId, userId],
          'last_msg': '',
          'timestamp': FieldValue.serverTimestamp(),
        });

        documentId = newChatRef.id;
      }
    } catch (e) {
      print('Error getting or creating chat document: $e');
    }

    return documentId;
  }



  void sendMessage(String message, String documentId, String name, String rToken,{String? imageUrl, required String voiceNotePath}) async {
    try {
      final messageData = {
        'message': message,
        'senderId': widget.myId,
        'timestamp': DateTime.now(),
        'isRead': false,
        'imageUrl': imageUrl, // Include the imageUrl in the message data
      };
print(documentId);
      _playSound();
      await FirebaseFirestore.instance
          .collection('chats')
          .doc(documentId)
          .collection('messages')
          .add(messageData)
          .then((value) {
        FirebaseFirestore.instance.collection('chats').doc(documentId).update({
          'last_msg': message,
          'timestamp': DateTime.now(),
        });
      });

      // Add the sent message to the chatMessages list
      final sentMessage = {
        'message': message,
        'senderId': widget.myId,
        'timestamp': DateTime.now(),
        'isRead': false,
        'imageUrl': imageUrl, // Include the imageUrl in the sent message
      };
      chatMessages.add(sentMessage);

      _sendPushNotification(message,rToken,name);
      saveChatMessages();
    } catch (e) {
      print('Error sending message: $e');
    }
  }

  void sendImageMessage(String documentId, {String? imageUrl}) async {
    try {
      final messageData = {
        'message': 'Image',
        'senderId': widget.myId,
        'timestamp': DateTime.now(),
        'isRead': false,
        'imageUrl': imageUrl, // Include the imageUrl in the message data
      };

      await FirebaseFirestore.instance
          .collection('chats')
          .doc(documentId)
          .collection('messages')
          .add(messageData)
          .then((value) {
        FirebaseFirestore.instance.collection('chats').doc(documentId).update({
          'last_msg': 'Image',
          'timestamp': DateTime.now(),
        });
      });

      // Add the sent message to the chatMessages list
      final sentMessage = {
        'message': 'Image',
        'senderId': widget.myId,
        'timestamp': DateTime.now(),
        'isRead': false,
        'imageUrl': imageUrl, // Include the imageUrl in the sent message
      };
      chatMessages.add(sentMessage);

      saveChatMessages();
    } catch (e) {
      print('Error sending message: $e');
    }
  }

  void markMessageAsRead(String messageId, String documentId) async {
    try {
      await FirebaseFirestore.instance
          .collection('chats')
          .doc(documentId)
          .collection('messages')
          .doc(messageId)
          .update({'isRead': true});
    } catch (e) {
      print('Error marking message as read: $e');
    }
  }
  Future<void> _sendPushNotification(String message,rToken,name) async {
 try{
   final body =  {
     "to":rToken,
     "notification":{
       "title":name,
       "body": message,
       "andriod_channel":'chats'
     }
   };
   var res = await http.post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
       headers: {
         HttpHeaders.contentTypeHeader:'application/json',
         HttpHeaders.authorizationHeader:'key=AAAAuJIeyeA:APA91bHrOXq20c4DbK1r_-87ix3DhRzhX0vRKhB7TTCyNwBHUFZZF6ChOL8TFj-O6IUMKmH5PsI-Tt-rl9WaaIIeTTJIugQmuVpSsA74T1ts7J2K7abfoaI_SFj_EHAGxwKxz7an7DPM'
       },
       body:jsonEncode(body));
   print('Response status: ${res.statusCode}');
   print('Response body: ${res.body}');

   print(await http.read(Uri.https('example.com', 'foobar.txt')));

 }
     catch(e){
   print('\nsendNotificationE: $e');
     }


}

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
        backgroundColor: satinColor,
        appBar: AppBar(
          backgroundColor: secondColor,
          title: Row(
            children: [
          CircleAvatar(
          backgroundImage: CachedNetworkImageProvider(
          widget.photoUrl,
          ),
        ),
              SizedBox(width: 8),
              Text(
                widget.name,
                style: TextStyle(
                  fontSize: 17,
                  fontFamily: 'GFSDidot',
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.more_vert),
              onPressed: () {},
            ),
          ],
        ),
        body: Column(
          children: [
            if (_isLoading)
              Container(
                alignment: Alignment.topCenter,
                padding: EdgeInsets.all(16.0),
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2, // Adjust the strokeWidth to change the size
                    valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.black), // Set the color to black
                  ),
                ),
              ),
            Expanded(
              child: documentId != null
                  ? StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('chats')
                    .doc(documentId!)
                    .collection('messages')
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }

                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return Container();
                  }

                  if (!snapshot.hasData ||
                      snapshot.data!.docs.isEmpty) {
                    return Center(child: Text('No messages'));
                  }

                  final messages = snapshot.data!.docs;

                  return ListView.builder(
                    reverse: true,
                    padding: EdgeInsets.all(16),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message =
                      messages[index].data() as Map<String, dynamic>;
                      final text = message['message'] as String;
                      final senderId = message['senderId'] as String;
                      final isSentByMe = senderId == widget.myId;

                      // Retrieve the timestamp
                      final timestamp =
                      message['timestamp'] as Timestamp;
                      final dateTime = timestamp.toDate();

                      // Format the time
                      final formattedTime =
                      DateFormat('HH:mm a').format(dateTime);

                      // Retrieve the isRead field value
                      final isRead = message['isRead'] as bool;

                      // Mark the message as read if it belongs to the other user
                      if (!isSentByMe && !isRead) {
                        final messageId =
                            snapshot.data!.docs[index].id;
                        markMessageAsRead(messageId, documentId!);
                      }

                      return ChatMessage(
                        text: text,
                        isSentByMe: isSentByMe,
                        time: formattedTime,
                        isRead: isRead,
                        imageUrl: message['imageUrl'] ?? '', // Use null-aware operator to provide a default empty string if imageUrl is null
                      );


                    },
                  );
                },
              )
                  : Container(),
            ),

              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  border: Border(top: BorderSide(color: Colors.grey)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: InputDecorator(
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          prefixIcon: IconButton(
                            icon: Icon(Icons.attach_file),
                            onPressed: () {
                              showModalBottomSheet<void>(
                                context: context,
                                builder: (BuildContext context) {
                                  return SafeArea(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        ListTile(
                                          leading: Icon(Icons.image),
                                          title: Text('Send Image'),
                                          onTap: () {
                                            Navigator.pop(context);
                                            _pickImage();
                                          },
                                        ),
                                        ListTile(
                                          leading: Icon(Icons.video_library),
                                          title: Text('Send Video'),
                                          onTap: () {
                                            Navigator.pop(context);
                                            _pickVideo();
                                          },
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                          ),

                          ),
                        child: TextField(
                          controller: _controller,
                          decoration: InputDecoration.collapsed(
                            hintText: 'Type a message...',
                            hintStyle: TextStyle(
                              fontSize: 16,
                              fontFamily: 'Rufina',
                              fontWeight: FontWeight.normal,
                              color: Colors.grey,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    FloatingActionButton(
                      onPressed: () async {
                        String message = _controller.text;
                        _controller.clear();

                        if (documentId == null) {
                          documentId = await getChatDocumentId(
                            widget.myId,
                            widget.userId,
                          );
                        }

                        if (documentId != null) {

                          if(message != '' ){
                            sendMessage(message, documentId!, widget.name, widget.rToken, voiceNotePath: '');
                          }else {
                            return null;
                          }

                        }
                      },
                      backgroundColor: bgColor,
                      child: Icon(Icons.send),
                      elevation: 0,
                    ),
                  ],
                ),
              ),



          ],
        ),
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      final File imageFile = File(pickedImage.path);
      final fileName = basename(imageFile.path);

      setState(() {
        _isLoading = true;
      });

      final Reference storageReference =
      FirebaseStorage.instance.ref().child('chat_images').child(fileName);
      final UploadTask uploadTask = storageReference.putFile(imageFile);

      final TaskSnapshot storageSnapshot = await uploadTask.whenComplete(() {});

      final imageUrl = await storageSnapshot.ref.getDownloadURL();

      setState(() {
        _isLoading = false;
      });

      if (documentId == null) {
        documentId = await getChatDocumentId(widget.myId, widget.userId);
      }
      if (documentId != null) {
        sendImageMessage(documentId!, imageUrl: imageUrl);
      }
    }
  }


  Future<void> _pickVideo() async {
    final picker = ImagePicker();
    final pickedVideo = await picker.pickVideo(source: ImageSource.gallery);

    if (pickedVideo != null) {
      final File videoFile = File(pickedVideo.path);
      // Handle the video file and send it to Firestore or any other desired destination
    }
  }




}


