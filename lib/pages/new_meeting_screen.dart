import 'package:connexus/pages/video_call_screen.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:share_plus/share_plus.dart';

import '../constants/my_colors.dart';
import '../themes/text_themes.dart';
class NewMeetingScreen extends StatefulWidget {
  const NewMeetingScreen({super.key});

  @override
  State<NewMeetingScreen> createState() => _NewMeetingScreenState();
}

class _NewMeetingScreenState extends State<NewMeetingScreen> {
  String _meetingCode = "qwerty";

  @override
  void initState() {
    var uuid = const Uuid();
    _meetingCode = uuid.v1().substring(0, 8);
    super.initState();
  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyColors.appBarColor,
        titleTextStyle: TextThemes.appBar,
        title: const Text('New Meeting'),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          Image.network(
            "https://user-images.githubusercontent.com/67534990/127776392-8ef4de2d-2fd8-4b5a-b98b-ea343b19c03e.png",
            fit: BoxFit.cover,
            height: 125,
          ),
          const SizedBox(height: 25),
          const Text(
            "Enter meeting code below",
            style: TextStyle(
              color: MyColors.text,
              fontWeight: FontWeight.w300,
              fontFamily: 'Futura',
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            child: Card(
                color: Colors.grey[300],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                child: ListTile(
                  leading: const Icon(Icons.link),
                  title: SelectableText(
                    _meetingCode,
                    style: TextStyle(
                      color: Colors.grey[800],
                      fontWeight: FontWeight.w300,
                      fontFamily: 'Futura',
                    ),
                  ),
                  trailing: const Icon(Icons.copy),
                )),
          ),
          const Divider(thickness: 1, height: 20, indent: 20, endIndent: 20),
          ElevatedButton.icon(
            onPressed: () {
              Share.share("Meeting Code : $_meetingCode");
            },
            icon: const Icon(
              Icons.arrow_drop_down,
              color: MyColors.alter,
            ),
            label: const Text(
              "Share invite",
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
          const SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed: () {

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => VideoCall(channelName: _meetingCode.trim()),
                ),
              );
            },
            icon: const Icon(Icons.video_call),
            label: const Text("Start Call", style: TextStyle(
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
        ],
      ),
    );
  }
}
