import 'package:flutter/material.dart';

import '../constants/my_colors.dart';
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
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w200,
          fontFamily: 'Futura',
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w100,
          fontFamily: 'Futura',
        ),
      ),
      body: IndexedStack(
        index: myIndex,
        children: widgetList,
      ),
      floatingActionButton: Stack(
        children: [
          Positioned(
            bottom: 16.0,
            right: 16.0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildSignLanguageButton('Sign Language', Icons.sign_language_rounded),
                const SizedBox(height: 16.0),
                _buildConversationButton('Conversation   ', Icons.translate),
              ],
            ),
          ),
        ],
      ),
      // backgroundColor: Colors.black,
    );
  }

  Widget _buildSignLanguageButton(String label, IconData iconData) {
    return ElevatedButton.icon(
      onPressed: () {
        Navigator.pushNamed(context, '/sign_language');
      },
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color>(Colors.cyan),
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4.0),
          ),
        ),
      ),
      icon: Icon(
        iconData,
        color: Colors.white,
      ),
      label: Text(
        label,
        style: const TextStyle(
          color: MyColors.alter,
          fontWeight: FontWeight.w300,
          fontFamily: 'Futura',
        ),
      ),
    );
  }

  Widget _buildConversationButton(String label, IconData iconData) {
    return ElevatedButton.icon(
      onPressed: () {
        Navigator.pushNamed(context, '/conversation');
      },
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color>(Colors.cyan),
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4.0),
          ),
        ),
      ),
      icon: Icon(
        iconData,
        color: Colors.white,
      ),
      label: Text(
        label,
        style: const TextStyle(
          color: MyColors.alter,
          fontWeight: FontWeight.w300,
          fontFamily: 'Futura',
        ),
      ),
    );
  }
}
