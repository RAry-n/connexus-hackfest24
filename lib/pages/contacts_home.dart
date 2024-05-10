import 'package:flutter/material.dart';

class ContactsHome extends StatefulWidget {
  const ContactsHome({super.key});

  @override
  State<ContactsHome> createState() => _ContactsHomeState();
}

class _ContactsHomeState extends State<ContactsHome> {
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text("Contacts"));
  }
}
