import 'package:flutter/material.dart';

class MeetingsHome extends StatefulWidget {
  const MeetingsHome({super.key});

  @override
  State<MeetingsHome> createState() => _MeetingsHomeState();
}

class _MeetingsHomeState extends State<MeetingsHome> {
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text("Meetings"));
  }
}
