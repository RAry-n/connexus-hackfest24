

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

const appID = "cfece32da59341699bfd790bced4249f";
const tokenBaseUrl = "https://connexustoken-e962cf99bf69.herokuapp.com";
const fcmServerKey = "AAAAbO-RiDA:APA91bGk0cQ-QQSOH75oogaJCAWZc-9nHPyyDRNbG4isioxU0PSb3fhGXRaHfa4wWpsPMM25ltcmYwUOdhzuuF2XN8Pf4EDIX-7EN8EBAgHxg8iU68QS2T9KXy85LKjFAsTbqPXLIhCx";

List<Contact> contacts = [];

String currentUser = FirebaseAuth.instance.currentUser!.uid;
String currentUserName = FirebaseAuth.instance.currentUser!.displayName.toString();

CollectionReference usersCollection = FirebaseFirestore.instance.collection("users");

CollectionReference callsCollection = FirebaseFirestore.instance.collection("calls");

Stream<List<DocumentSnapshot>> userData() async* {
  List<DocumentSnapshot> users = [];
  await usersCollection.get().then(
          (value) {
        if(value.docs.isNotEmpty){
          for(var element in value.docs){
            users.add(element);
          }
        }
      }
  );

  yield users;
}


