import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:komuniti/constant/color.dart';
import 'package:komuniti/screens/dashboard/chatsScreen.dart';
import 'package:komuniti/screens/dashboard/profilepage.dart';


class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title:  Text(
            'Komuniti',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontFamily: 'Product Sans',
              fontSize: 18,
            ),),
        leading: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Image.asset(
                  'assets/images/logo.png', // Replace with the actual path to your image asset
                  // Adjust the width of the image as needed
                ),
              ],
            ),
          ),
        actions: [
          InkWell(
            onTap: (){
              showMenu(
                context: context,
                position: RelativeRect.fromLTRB(70, 0, 17, 0), // Adjust the position as per your requirements
                items: [
                  PopupMenuItem(
                    value: 1,
                    child: GestureDetector(
                      onTap:(){
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ProfilePage()),
                        );

                      },
                      child: Row(
                        children: [
                          Icon(Icons.person, color: Colors.blue.shade300, size: 25,),
                        SizedBox(width: 10,),
                          Text('My Profile'),
                        ],
                      ),
                    ),
                  ),


                  // Add more menu items as needed
                ],
                elevation: 8,
              );


            },
            child: Icon(Icons.more_vert),
          ),
        ],
        backgroundColor: bgColor,
      )
      ,


      body: ChatsScreen(),

    );
  }
}


