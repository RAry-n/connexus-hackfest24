import 'package:contacts_service/contacts_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/my_colors.dart';
import '../themes/text_themes.dart';

class ContactsHome extends StatefulWidget {
  const ContactsHome({super.key});

  @override
  State<ContactsHome> createState() => _ContactsHomeState();
}

class _ContactsHomeState extends State<ContactsHome> {
  List<Contact> contacts = [];
  List<Contact> filteredContactsList = [];
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _requestContactsPermission();

    _searchController.addListener(() {
      filterContacts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _isSearching ? _buildSearchAppBar() : _buildNormalAppBar(),
      body: Container(
        padding: const EdgeInsets.all(20),
        child: ListView.builder(
          itemCount: _isSearching == true ? filteredContactsList.length : contacts.length,
          itemBuilder: (context, index) {
            final currentContact = _isSearching == true ? filteredContactsList[index] : contacts[index];
            if (currentContact.phones == null || currentContact.phones!.isEmpty) {
              return const SizedBox.shrink();
            }
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListTile(
                onTap: (){
                  Map data = {
                    'contact' : currentContact
                  };
                  Navigator.pushNamed(context, '/chat', arguments: data);
                },
                title: Text(
                  currentContact.displayName ?? 'Unknown',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w300,
                    fontFamily: 'Futura',
                  ),
                ),
                subtitle: Text(
                  currentContact.phones!.first.value ?? 'Unknown',
                  style: const TextStyle(
                    fontWeight: FontWeight.w200,
                    fontFamily: 'Futura',
                  ),
                ),
                trailing: const Icon(Icons.arrow_forward_ios_rounded),
                leading: (currentContact.avatar != null && currentContact.avatar!.isNotEmpty)
                    ? CircleAvatar(
                  backgroundImage: MemoryImage(currentContact.avatar!),
                )
                    : CircleAvatar(
                  child: Text(currentContact.initials()),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  AppBar _buildNormalAppBar() {
    return AppBar(
      backgroundColor: MyColors.appBarColor,
      titleTextStyle: TextThemes.appBar,
      title: const Text('Contacts'),
      actions: [
        IconButton(
          icon: const Icon(
            Icons.search,
            color: Colors.white,
          ),
          onPressed: () {
            setState(() {
              _isSearching = true;
            });
          },
        ),
        IconButton(
          icon: const Icon(
            Icons.logout,
            color: Colors.white,
          ),
          onPressed: () async {
            await _logout();
          },
        ),
      ],
    );
  }

  AppBar _buildSearchAppBar() {
    return AppBar(
      backgroundColor: MyColors.appBarColor,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back,
          color: Colors.white, // Set arrow icon color to white
        ),
        onPressed: () {
          setState(() {
            _isSearching = false;
            _searchController.clear();
          });
        },
      ),
      title: TextField(
        controller: _searchController,
        cursorColor: Colors.white,
        style: const TextStyle(
          color: Colors.white, // Set text color to white
          fontFamily: 'Futura', // Use Futura font
        ),
        decoration: const InputDecoration(
          hintText: 'Search...',
          hintStyle: TextStyle(
            color: Colors.white, // Set hint text color to white
            fontFamily: 'Futura', // Use Futura font for hint text
          ),
          border: InputBorder.none,
        ),
        onChanged: (value) {
          // Implement search logic here
        },
      ),
    );
  }

  Future<void> _requestContactsPermission() async {
    final PermissionStatus status = await Permission.contacts.request();
    if (status == PermissionStatus.granted) {
      getAllContacts();
    }
  }

  getAllContacts() async {
    List<Contact> contactsList = await ContactsService.getContacts();
    setState(() {
      contacts = contactsList;
    });
  }

  void filterContacts() {
    List<Contact> filteredContacts = [];
    if (_searchController.text.isNotEmpty) {
      filteredContacts = contacts.where((contact) {
        String? searchTerm = _searchController.text.toLowerCase();
        String? contactName = contact.displayName?.toLowerCase(); // Use null-aware operator
        return contactName?.contains(searchTerm) ?? false; // Use null-aware operator
      }).toList();

      setState(() {
        filteredContactsList = filteredContacts;
      });
    }
  }

  Future<void> _logout() async {
    // Clear SharedPreferences
    final SharedPreferences sp = await SharedPreferences.getInstance();
    await sp.clear();

    // Sign out from Firebase
    await FirebaseAuth.instance.signOut();

    // Navigate to GetStartedScreen and pop all routes
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/get_started',
          (route) => false,
    );
  }
}
