import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class ChatPageController extends GetxController with WidgetsBindingObserver {
  final isPageVisible = false.obs;
  String? currentUserId;
  StreamController<List<Map<String, dynamic>>> chatsController =
  StreamController<List<Map<String, dynamic>>>();

  Stream<List<Map<String, dynamic>>>? chatsStream;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance!.addObserver(this);
    getCurrentUserId();
  }

  @override
  void onClose() {
    chatsController.close();
    WidgetsBinding.instance!.removeObserver(this);
    super.onClose();
  }

  @override
  void getCurrentUserId() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      currentUserId = user.uid;
    }
    fetchChatDataFromFirestore(); // Call fetchChatDataFromFirestore method here
  }

  Future<void> fetchChatDataFromFirestore() async {
    final List<Map<String, dynamic>> users = [];
    final query = FirebaseFirestore.instance
        .collection('chats')
        .where('participants', arrayContains: currentUserId);

    final querySnapshot = await query.get();


    for (var doc in querySnapshot.docs) {
      final chatId = doc.id;
      final participants = doc['participants'] as List<dynamic>;

      String? secondUserId;

      // Find the second user ID
      for (var participant in participants) {
        if (participant != currentUserId) {
          secondUserId = participant as String;
          break;
        }
      }

      if (secondUserId != null) {
        final userSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(secondUserId)
            .get();

        final userDataSnapshot = userSnapshot.data() as Map<String, dynamic>;

        final user = {
          'id': secondUserId,
          'name': userDataSnapshot['name'],
          'photoUrl': userDataSnapshot['photoUrl'],
          'email': userDataSnapshot['email'],
          'token': userDataSnapshot['token'],
          'unreadCount': 0,
          'lastMessage': '', // Keep the existing last message
        };

        final chatDocRef =
        FirebaseFirestore.instance.collection('chats').doc(chatId);

        final chatDocSnapshot = await chatDocRef.get();
        final readCount = chatDocSnapshot.data()?['read_count'] as int?;

        if (readCount != null) {
          final unreadCount = chatDocSnapshot.data()?['unread_count'] as int?;
          user['unreadCount'] = unreadCount ?? 0;
        }

        // Fetch the last message from the "last_msg" field in the chat document
        final lastMessage = chatDocSnapshot.data()?['last_msg'] as String?;
        if (lastMessage != null) {
          user['lastMessage'] = lastMessage;
        }

        // Calculate the unread message count from the "messages" subcollection
        final messagesCollection = chatDocRef.collection('messages');
        final unreadQuerySnapshot = await messagesCollection
            .where('isRead', isEqualTo: false)
            .where('senderId', isNotEqualTo: currentUserId)
            .get();

        final unreadCount = unreadQuerySnapshot.docs.length;
        user['unreadCount'] = unreadCount;

        users.add(user);
      }
    }

    // Sort the users list based on unread message count
    users.sort((a, b) => b['unreadCount'].compareTo(a['unreadCount']));

    chatsController.add(users);

    chatsStream = query.snapshots().listen((querySnapshot) async {
      final List<Map<String, dynamic>> updatedUsers = [];

      for (var docChange in querySnapshot.docChanges) {
        final doc = docChange.doc;
        final chatId = doc.id;
        final participants = doc['participants'] as List<dynamic>;

        String? secondUserId;

        // Find the second user ID
        for (var participant in participants) {
          if (participant != currentUserId) {
            secondUserId = participant as String;
            break;
          }
        }

        if (secondUserId != null) {
          final userSnapshot = await FirebaseFirestore.instance
              .collection('users')
              .doc(secondUserId)
              .get();

          final userDataSnapshot = userSnapshot.data() as Map<String, dynamic>;

          final user = {
            'id': secondUserId,
            'name': userDataSnapshot['name'],
            'photoUrl': userDataSnapshot['photoUrl'],
            'email': userDataSnapshot['email'],
            'token': userDataSnapshot['token'],
            'unreadCount': 0,
            'lastMessage': '', // Keep the existing last message
          };

          final chatDocRef =
          FirebaseFirestore.instance.collection('chats').doc(chatId);

          final chatDocSnapshot = await chatDocRef.get();
          final readCount = chatDocSnapshot.data()?['read_count'] as int?;

          if (readCount != null) {
            final unreadCount = chatDocSnapshot.data()?['unread_count'] as int?;
            user['unreadCount'] = unreadCount ?? 0;
          }

          // Fetch the last message from the "last_msg" field in the chat document
          final lastMessage = chatDocSnapshot.data()?['last_msg'] as String?;
          if (lastMessage != null) {
            user['lastMessage'] = lastMessage;
          }

          // Calculate the unread message count from the "messages" subcollection
          final messagesCollection = chatDocRef.collection('messages');
          final unreadQuerySnapshot = await messagesCollection
              .where('isRead', isEqualTo: false)
              .where('senderId', isNotEqualTo: currentUserId)
              .get();

          final unreadCount = unreadQuerySnapshot.docs.length;
          user['unreadCount'] = unreadCount;

          updatedUsers.add(user);
        }
      }

      // Update the existing user data with the updated data
      for (var updatedUser in updatedUsers) {
        final index = users.indexWhere((user) => user['id'] == updatedUser['id']);
        if (index != -1) {
          users[index]['unreadCount'] = updatedUser['unreadCount'];
          users[index]['lastMessage'] = updatedUser['lastMessage'];
        } else {
          users.add(updatedUser);
        }
      }

      // Sort the users list based on unread message count
      users.sort((a, b) => b['unreadCount'].compareTo(a['unreadCount']));

      chatsController.add(users);
    }) as Stream<List<Map<String, dynamic>>>?;
  }
}


/* void fetchChatDataFromFirestore() async {
    final query = FirebaseFirestore.instance
        .collection('chats')
        .where('participants', arrayContains: currentUserId);

    final querySnapshot = await query.get();
    final List<Map<String, dynamic>> users = [];

    for (var doc in querySnapshot.docs) {
      final chatId = doc.id;
      final participants = doc['participants'] as List<dynamic>;

      String? secondUserId;

      // Find the second user ID
      for (var participant in participants) {
        if (participant != currentUserId) {
          secondUserId = participant as String;
          break;
        }
      }

      if (secondUserId != null) {
        final userSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(secondUserId)
            .get();

        final userDataSnapshot = userSnapshot.data() as Map<String, dynamic>;

        final user = {
          'id': secondUserId,
          'name': userDataSnapshot['name'],
          'photoUrl': userDataSnapshot['photoUrl'],
          'email': userDataSnapshot['email'],
          'token': userDataSnapshot['token'],
          'unreadCount': 0,
          'lastMessage': '', // Keep the existing last message
        };

        final chatDocRef = FirebaseFirestore.instance.collection('chats').doc(
            chatId);

        final chatDocSnapshot = await chatDocRef.get();
        final readCount = chatDocSnapshot.data()?['read_count'] as int?;

        if (readCount != null) {
          final unreadCount = chatDocSnapshot.data()?['unread_count'] as int?;
          user['unreadCount'] = unreadCount ?? 0;
        }

        // Fetch the last message from the "last_msg" field in the chat document
        final lastMessage = chatDocSnapshot.data()?['last_msg'] as String?;
        if (lastMessage != null) {
          user['lastMessage'] = lastMessage;
        }

        // Calculate the unread message count from the "messages" subcollection
        final messagesCollection = chatDocRef.collection('messages');
        final unreadQuerySnapshot = await messagesCollection
            .where('isRead', isEqualTo: false)
            .where('senderId', isNotEqualTo: currentUserId)
            .get();

        final unreadCount = unreadQuerySnapshot.docs.length;
        user['unreadCount'] = unreadCount;

        users.add(user);
      }
    }

    // Sort the users list based on unread message count
    users.sort((a, b) => b['unreadCount'].compareTo(a['unreadCount']));

    chatsController.add(users);

    chatsStream = query.snapshots().listen((querySnapshot) async {
      final List<Map<String, dynamic>> updatedUsers = [];

      for (var docChange in querySnapshot.docChanges) {
        final doc = docChange.doc;
        final chatId = doc.id;
        final participants = doc['participants'] as List<dynamic>;

        String? secondUserId;

        // Find the second user ID
        for (var participant in participants) {
          if (participant != currentUserId) {
            secondUserId = participant as String;
            break;
          }
        }

        if (secondUserId != null) {
          final userSnapshot = await FirebaseFirestore.instance
              .collection('users')
              .doc(secondUserId)
              .get();

          final userDataSnapshot = userSnapshot.data() as Map<String, dynamic>;

          final user = {
            'id': secondUserId,
            'name': userDataSnapshot['name'],
            'photoUrl': userDataSnapshot['photoUrl'],
            'email': userDataSnapshot['email'],
            'token': userDataSnapshot['token'],
            'unreadCount': 0,
            'lastMessage': '', // Keep the existing last message
          };

          final chatDocRef = FirebaseFirestore.instance.collection('chats').doc(
              chatId);

          final chatDocSnapshot = await chatDocRef.get();
          final readCount = chatDocSnapshot.data()?['read_count'] as int?;

          if (readCount != null) {
            final unreadCount = chatDocSnapshot.data()?['unread_count'] as int?;
            user['unreadCount'] = unreadCount ?? 0;
          }

          // Fetch the last message from the "last_msg" field in the chat document
          final lastMessage = chatDocSnapshot.data()?['last_msg'] as String?;
          if (lastMessage != null) {
            user['lastMessage'] = lastMessage;
          }

          // Calculate the unread message count from the "messages" subcollection
          final messagesCollection = chatDocRef.collection('messages');
          final unreadQuerySnapshot = await messagesCollection
              .where('isRead', isEqualTo: false)
              .where('senderId', isNotEqualTo: currentUserId)
              .get();

          final unreadCount = unreadQuerySnapshot.docs.length;
          user['unreadCount'] = unreadCount;

          updatedUsers.add(user);
        }
      }

      // Update the existing user data with the updated data
      for (var updatedUser in updatedUsers) {
        final index = users.indexWhere((user) =>
        user['id'] == updatedUser['id']);
        if (index != -1) {
          users[index]['unreadCount'] = updatedUser['unreadCount'];
          users[index]['lastMessage'] = updatedUser['lastMessage'];
        } else {
          users.add(updatedUser);
        }
      }

      // Sort the users list based on unread message count
      users.sort((a, b) => b['unreadCount'].compareTo(a['unreadCount']));

      chatsController.add(users);
    }) as Stream<List<Map<String, dynamic>>>?;
  }
*/



