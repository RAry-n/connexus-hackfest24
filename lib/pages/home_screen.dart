import 'package:flutter/material.dart';

import 'contacts_home.dart';
import 'meetings_home.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var myIndex =0;
  List<Widget> widgetList = [
    const MeetingsHome(),
    const ContactsHome(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        onTap: (index){
          setState(() {
            myIndex=index;
          });
        },
        currentIndex: myIndex,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.video_call_sharp),
            label: 'Meetings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.call),
            label: 'Contacts',
          ),
        ],
        showUnselectedLabels: true,
        backgroundColor: Colors.grey[300],
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey[600],
      ),
      body: widgetList[myIndex],
      // backgroundColor: Colors.black,
    );
  }
}
