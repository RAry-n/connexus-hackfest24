import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
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
  List<String> registeredNumbers = [];

  @override
  void initState() {
    super.initState();
    _requestContactsPermission();
    _searchController.addListener(() {
      filterContacts();
    });
    getRegisteredNumbers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _isSearching ? _buildSearchAppBar() : _buildNormalAppBar(),
      body: Container(
        padding: const EdgeInsets.all(20),
        child: ListView.builder(
          itemCount: _isSearching ? filteredContactsList.length : contacts.length,
          itemBuilder: (context, index) {
            final currentContact = _isSearching ? filteredContactsList[index] : contacts[index];
            if (currentContact.phones == null || currentContact.phones!.isEmpty) {
              return const SizedBox.shrink();
            }
            String? phoneNumber = currentContact.phones!.first.value;
            String formattedPhoneNumber = phoneNumber!.replaceAll(RegExp(r'\D'), '');
            if(formattedPhoneNumber.length == 12) formattedPhoneNumber = formattedPhoneNumber.substring(2);
            bool isRegistered = registeredNumbers.contains(formattedPhoneNumber);
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListTile(
                onTap: () {
                  if (isRegistered) {
                    Map data = {'contact': currentContact};
                    Navigator.pushNamed(context, '/chat', arguments: data);
                  } else {
                    shareApp();
                  }
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
                  phoneNumber,
                  style: const TextStyle(
                    fontWeight: FontWeight.w200,
                    fontFamily: 'Futura',
                  ),
                ),
                trailing: isRegistered ? const Icon(Icons.arrow_forward_ios_rounded) : const Icon(Icons.add),
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
        cursorColor: Colors.greenAccent,
        autofocus: true,
        style: const TextStyle(
          color: Colors.white, // Set text color to white
          fontFamily: 'Futura', // Use Futura font
        ),
        decoration: InputDecoration(
          hintText: 'Search...',
          hintStyle: TextStyle(
            color: Colors.grey[300], // Set hint text color to white
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

  void getRegisteredNumbers() async {
    List<String> numbers = [];
    // Get the phone numbers from Firestore
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('users').get();
    for (var doc in querySnapshot.docs) {
      // Extract the phone number from the document ID
      numbers.add(doc.id);
    }
    setState(() {
      registeredNumbers = numbers;
    });
  }

  void shareApp() {
    String appLink = 'your_app_link';
    Share.share('Check out this awesome app: $appLink');
  }

  Future<void> _logout() async {
    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            "Confirm Logout",
            style: TextStyle(
              color: MyColors.text,
              fontWeight: FontWeight.w500,
              fontFamily: 'Futura',
            ),
          ),
          content: const Text(
            "Are you sure you want to logout?",
            style: TextStyle(
              color: MyColors.text,
              fontWeight: FontWeight.w300,
              fontFamily: 'Futura',
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Close the dialog
                // Perform logout
                await performLogout();
              },
              child: const Text(
                "Yes",
                style: TextStyle(
                  color: Colors.cyan,
                  fontWeight: FontWeight.w300,
                  fontFamily: 'Futura',
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text(
                "No",
                style: TextStyle(
                  color: Colors.cyan,
                  fontWeight: FontWeight.w300,
                  fontFamily: 'Futura',
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> performLogout() async {
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
