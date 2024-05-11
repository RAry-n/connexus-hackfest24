import 'dart:convert';
import 'package:agora_uikit/agora_uikit.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

class VideoCall extends StatefulWidget {
  String channelName = "";

  VideoCall({required this.channelName});
  @override
  _VideoCallState createState() => _VideoCallState();
}

class _VideoCallState extends State<VideoCall> {
  late final AgoraClient _client;
  bool _loading = true;
  String tempToken = "";

  @override
  void initState() {
    getToken();
    _client = AgoraClient(
        agoraConnectionData: AgoraConnectionData(
          appId: "cfece32da59341699bfd790bced4249f",
          tempToken: tempToken,
          //uid: 565,
          channelName: widget.channelName,
        ),
        enabledPermission: [Permission.camera, Permission.microphone]);
    //_loading=false;

    print(_client.toString());
    Future.delayed(Duration(seconds: 1)).then(
          (value) => setState(() => _loading = false),
    );
    super.initState();
    initAgora();
  }
  void initAgora() async {
    await _client.initialize();
  }
  Future<void> getToken() async {
    String link ="https://connexustoken-e962cf99bf69.herokuapp.com/rtc/${widget.channelName}/publisher/uid/565/?expiry=3600";


    Response _response = await get(Uri.parse(link));

    Map data = jsonDecode(_response.body);
    print(data.toString());
    setState(() {
      tempToken = data["rtcToken"];
      print(tempToken);
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _loading
            ? Center(
          child: CircularProgressIndicator(),
        )
            : Stack(
          children: [
            AgoraVideoViewer(
              client: _client,
              layoutType: Layout.floating,
              enableHostControls: true,
            ),
            AgoraVideoButtons(client: _client)
          ],
        ),
      ),
    );
  }
}
