import 'package:connexus/pages/video_call_screen.dart';
import 'package:flutter/material.dart';
import '../constants/my_colors.dart';
import '../themes/text_themes.dart';
class JoinWithCodeScreen extends StatefulWidget {
  const JoinWithCodeScreen({super.key});

  @override
  State<JoinWithCodeScreen> createState() => _JoinWithCodeScreenState();
}

class _JoinWithCodeScreenState extends State<JoinWithCodeScreen> {
  final TextEditingController _controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyColors.appBarColor,
        titleTextStyle: TextThemes.appBar,
        title: const Text('Join Using Code'),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Image.network(
            "https://user-images.githubusercontent.com/67534990/127776450-6c7a9470-d4e2-4780-ab10-143f5f86a26e.png",
            fit: BoxFit.cover,
            height: 125,
          ),
          const SizedBox(height: 20),
          const Text(
            "Enter meeting code below",
            style: TextStyle(
              color: MyColors.text,
              fontWeight: FontWeight.w300,
              fontFamily: 'Futura',
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Card(
              color: Colors.grey[300],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              child: TextField(
                controller: _controller,
                textAlign: TextAlign.center,
                decoration: const InputDecoration(border: InputBorder.none, hintText: "Example : abc-efg-dhi"),
                style: TextStyle(
                  color: Colors.grey[800],
                  fontWeight: FontWeight.w300,
                  fontFamily: 'Futura',
                ),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => VideoCall(channelName: _controller.text.trim()),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              fixedSize: const Size(150, 30),
              backgroundColor: Colors.cyan,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            ),
            child: const Text("Join", style: TextStyle(
              color: MyColors.alter,
              fontWeight: FontWeight.w300,
              fontFamily: 'Futura',
            ),),
          ),
        ],
      ),
    );
  }
}
