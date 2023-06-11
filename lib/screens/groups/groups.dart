import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:komuniti/screens/groups/create_group.dart';

class GroupsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Stream<QuerySnapshot> getGroups() {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String currentUserId = user.uid;

        // Get a reference to the Firestore collection for groups
        CollectionReference groupsCollection = FirebaseFirestore.instance.collection('groups');

        // Create a query for groups where the current user ID exists
        Query groupsQuery = groupsCollection.where('members', arrayContains: currentUserId);

        // Listen to the query and return the snapshots
        return groupsQuery.snapshots();
      } else {
        return Stream.empty();
      }
    }

    void navigateToGroupCreationScreen() {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GroupCreationScreen(currentUserId: '',),
        ),
      );
    }

    return Scaffold(
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search for komuniti',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(16),
            child: Text(
              'Kommunities For you',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: getGroups(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  List<QueryDocumentSnapshot> groups = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: groups.length,
                    itemBuilder: (context, index) {
                      QueryDocumentSnapshot group = groups[index];

                      // Extract group data
                      String groupId = group.id;
                      String groupName = group['name'];
                      String groupImage = group['image'];
                      int groupMemberCount = group['members'].length;
                      int unreadCount = 5; // Replace with actual unread count

                      return Container(
                        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 3,
                              blurRadius: 7,
                              offset: Offset(0, 3),
                            ),
                          ],
                          color: Colors.white,
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundImage: groupImage != null ? NetworkImage(groupImage) : null,
                            backgroundColor: Colors.grey,
                          ),
                          title: Text(groupName),
                          subtitle: Text('Members: $groupMemberCount, Unread: $unreadCount'),
                          trailing: Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.black,
                            ),
                            child: Text(
                              unreadCount.toString(),
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          onTap: () {
                            // Handle group tap
                          },
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: navigateToGroupCreationScreen,
        backgroundColor: Colors.black,
        child: Icon(Icons.add, size: 32, color: Colors.white),
      ),
    );
  }
}
