import 'package:flutter/material.dart';

import '../constants/my_colors.dart';
import '../themes/text_themes.dart';

class MeetingsHome extends StatefulWidget {
  const MeetingsHome({super.key});

  @override
  State<MeetingsHome> createState() => _MeetingsHomeState();
}

class _MeetingsHomeState extends State<MeetingsHome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyColors.appBarColor,
        titleTextStyle: TextThemes.appBar,
        title: const Text('Meetings'),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.all(25),
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.pushNamed(context, '/new_meeting');
            },
            icon: const Icon(
              Icons.add,
              color: Colors.white,
            ),
            label: const Text(
              "New Meeting",
              style: TextStyle(
                color: MyColors.alter,
                fontWeight: FontWeight.w300,
                fontFamily: 'Futura',
              ),
            ),
            style: ElevatedButton.styleFrom(
              fixedSize: const Size(350, 30),
              backgroundColor: Colors.cyan,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            ),
          ),
        ),
        const Divider(
          thickness: 1,
          height: 10,
          indent: 40,
          endIndent: 20,
        ),
        Padding(
          padding: const EdgeInsets.all(25),
          child: OutlinedButton.icon(
            onPressed: () {
              Navigator.pushNamed(context, '/join_with_code');
            },
            icon: const Icon(Icons.margin, color: Colors.cyan,),
            label: const Text("Join with a code",
              style: TextStyle(
                color: Colors.cyan,
                fontWeight: FontWeight.w300,
                fontFamily: 'Futura',
              ),),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.cyan,
              side: const BorderSide(color: Colors.cyan),
              fixedSize: const Size(350, 30),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            ),
          ),
        ),
        Image.network("https://user-images.githubusercontent.com/67534990/127524449-fa11a8eb-473a-4443-962a-07a3e41c71c0.png")
      ]),
    );
  }
}
