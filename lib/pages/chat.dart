import 'package:contacts_service/contacts_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../constants/my_colors.dart';
import '../themes/text_themes.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/loading_widget.dart';

class Chat extends StatefulWidget {
  const Chat({super.key});

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  List<Map> chatHistory = [];

  //   {
  //     'msg' : 'hehe',
  //     'time' : '14/04/23 04:20',
  //     'isCurr' : '1',
  //   },
  //
  //   {
  //     'msg' : 'hihi',
  //     'time' : '14/04/23 04:21',
  //     'isCurr' : '0',
  //   },
  // ];
  late DatabaseReference dbRef;
  late Contact contactData;
  bool isFetched = false;
  late String currPhone;
  late String receiverPhone;

  var msgController = TextEditingController();

  void getData() async {
    currPhone = FirebaseAuth.instance.currentUser!.phoneNumber.toString().substring(3);
    // currPhone = "+9162274063";
    dbRef = FirebaseDatabase.instance.ref();
    contactData = (ModalRoute.of(context)?.settings.arguments as Map)['contact'];
    receiverPhone = contactData.phones!.first.value!;
    receiverPhone = receiverPhone.replaceAll(" ", '');
    if (receiverPhone[0] == '+') {
      receiverPhone = receiverPhone.substring(3);
    }
    final snapshot = await dbRef.child('chat/$currPhone/$receiverPhone').get();
    if (snapshot.exists) {
      // print(snapshot.value.toString());
      final dataMap = snapshot.value as Map;
      chatHistory = [];
      dataMap.forEach((key, value) {
        chatHistory.add(value);
      });

      chatHistory.sort((Map a, Map b) {
        return a['time'].compareTo(b['time']);
      });
      // print(chatHistory);
      setState(() {
        isFetched = true;
      });
    } else {
      setState(() {
        isFetched = true;
      });
      // print('No data available.');
    }
  }

  ScrollController listScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    if (!isFetched) {
      getData();
      return const LoadingWidget();
    } else {
      // getData();
      return Scaffold(
        appBar: AppBar(
          backgroundColor: MyColors.appBarColor,
          titleTextStyle: TextThemes.appBar,
          title: Text('${contactData.displayName}'),
          actions: [
            IconButton(
              icon: const Icon(
                Icons.video_call,
                color: Colors.white,
              ),
              onPressed: () {
                connectCall();
              },
            ),
          ],
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: Column(
          children: [
            // Center(child: Text("data")),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                controller: listScrollController,
                shrinkWrap: true,
                children: chatHistory.map((e) {
                  String msg = e['msg'];
                  int milli = e['time'];
                  String time = DateTime.fromMillisecondsSinceEpoch(milli).toString().substring(0, 16);
                  bool isCurr = (e['isCurr'] == '1');
                  return ChatBubble(
                    time: time,
                    text: msg,
                    isCurrentUser: isCurr,
                  );
                }).toList(),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(12),
              child: TextField(
                controller: msgController,
                style: const TextStyle(
                  color: MyColors.text,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Futura',
                ),
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.fromLTRB(24, 16, 16, 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  hintText: "message",
                  suffixIcon: IconButton(
                    onPressed: () {
                      sendMsg(msgController.text);
                      msgController.text = "";
                    },
                    icon: const Icon(Icons.send),
                  ),
                ),
              ),
            )
          ],
        ),
      );
    }
  }

  void scrollToBottom({bool animate = false}) {
    if (listScrollController.hasClients) {
      final position = listScrollController.position.maxScrollExtent;
      if (animate) {
        listScrollController.animateTo(
          position,
          duration: const Duration(seconds: 3),
          curve: Curves.easeOut,
        );
      } else {
        listScrollController.jumpTo(position);
      }
    }
  }

  void sendMsg(String msg) {
    if (msg.isEmpty) return;
    int currTime = DateTime.now().millisecondsSinceEpoch;
    Map val = {
      'msg': msg,
      'time': currTime,
      'isCurr': '1',
    };
    setState(() {
      chatHistory.add(val);
    });
    var ref = dbRef.child("chat/$currPhone/$receiverPhone").push();
    var ref2 = dbRef.child("chat/$receiverPhone/$currPhone").push();
    ref.set(val);
    Map val2 = {
      'msg': msg,
      'time': currTime,
      'isCurr': '0',
    };
    ref2.set(val2);
    scrollToBottom(animate: true);
  }

  void connectCall() {
    // UserModel user = UserModel(
    //     id: receiverPhone,
    //     name: contactData.displayName.toString(),
    //     photo: "",
    //     email: receiverPhone);
    // Navigator.push(context, MaterialPageRoute(builder: (context) {
    //   return VideoPage(
    //       user: user,
    //       call: CallModel(
    //         id: null,
    //         // channel: "video",
    //         channel: "video$currPhone$receiverPhone",
    //         caller: currPhone,
    //         called: receiverPhone,
    //         active: null,
    //         rejected: null,
    //         accepted: null,
    //         connected: null,
    //       ));
    // }));
  }
}
