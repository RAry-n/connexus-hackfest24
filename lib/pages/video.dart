import 'dart:async';
import 'dart:convert';

// import 'dart:math';
import 'dart:developer';
import 'dart:math';
import 'dart:typed_data';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:agora_uikit/agora_uikit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;
import 'package:speech_to_text/speech_to_text.dart';

import '../constants/my_colors.dart';
import '../constants/utils.dart';
import '../ml/sign_language_model.dart';
import '../models/call.dart';
import '../models/user.dart';
import '../provider/notiification_service.dart';
import '../widgets/user_photo.dart';

const appID = "cfece32da59341699bfd790bced4249f";
const tokenBaseUrl = "https://connexustoken-e962cf99bf69.herokuapp.com";

class VideoPage extends StatefulWidget {
  final UserModel user;
  final CallModel call;

  const VideoPage({super.key, required this.user, required this.call});

  @override
  State<VideoPage> createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {
  final _speechToText = SpeechToText();
  String langCode = 'en';
  RtcEngine? rtcEngine;
  String? token;
  int uid = 0;
  bool localUserJoined = false;
  String? callID;
  int? remoteUid;
  late final AgoraClient _client;
  bool _isMuted = false;
  bool _isCamOff = false;
  bool _signLanguageOn = false;
  bool _ccOn = false;
  // String cc = "really nice app";
  String cc= "muy buena aplicaciòn";
  int dataStreamID=0;
  static SignLanguageModel model = SignLanguageModel();
  static String signOutput = "";
  static int maxLength = 15;
  static List<String> labels = [
    'hello ',
    'please ',
    'bye ',
    'drink ',
    'eat ',
    'I ',
    'love you ',
    'no ',
    'yes ',
    'thank you '
  ];
  static double modelThreshold = 0.7;
  static int frameCount = 0;
  AudioFrameObserver audioFrameObserver = AudioFrameObserver(
      onRecordAudioFrame: (String channelId, AudioFrame audioFrame) {
    // Gets the captured audio frame
    print(
        "###############################################################################################################################");
  }, onPlaybackAudioFrame: (String channelId, AudioFrame audioFrame) {
    // Gets the audio frame for playback
    print(
        "###############################################################################################################################");
    debugPrint('[onPlaybackAudioFrame] audioFrame: ${audioFrame.toJson()}');
  });

  VideoFrameObserver videoFrameObserver = VideoFrameObserver(
      // onCaptureVideoFrame: (VideoFrame videoFrame) {
      //   //current user video fram
      //   debugPrint('[onCaptureVideoFrame] videoFrame: ${videoFrame.toJson()}');
      // },
      onRenderVideoFrame:
          (String channelId, int remoteUid, VideoFrame videoFrame) {
    //remote user videoFrame
    frameCount++;
    print(
        "###############################################################################################################################");
    print(frameCount);
    if (frameCount % 60 != 0) return;
    List<num> output = model.runFromPlanes(
        [videoFrame.yBuffer!, videoFrame.uBuffer!, videoFrame.vBuffer!]);
    processOutput(output);
  });

  late Timer t;

  @override
  void initState() {
    setState(() {
      callID = widget.call.id;
      rtcEngine = createAgoraRtcEngine();
    });
    super.initState();

    initSpeech();
    getToken();
    Future.delayed(const Duration(milliseconds: 3000)).then((_) {
      setState(() {

      });
    });
    initTimer();
  }
  
  @override
  void dispose() {
    // rtcEngine!.release();
    // rtcEngine!.getMediaEngine().unregisterAudioFrameObserver(audioFrameObserver);
    // rtcEngine!.getMediaEngine().unregisterVideoFrameObserver(videoFrameObserver);
    rtcEngine!.leaveChannel();
    t.cancel();
    super.dispose();
  }

  Future<void> initDataStream() async {
    DataStreamConfig config = const DataStreamConfig();
    await rtcEngine?.createDataStream(config).then((value){
      dataStreamID = value;
    });
  }

  void initSpeech() async {
    await _speechToText.initialize();
    Future.delayed(const Duration(milliseconds: 5000)).then((_) {
      _startListening();
    });
  }

  void _startListening() async {
    await _speechToText.listen(
        onResult: (result) {
          List<int> list = [1];
          String str=result.recognizedWords.toString();
          for(int i=0;i<str.length;i++) {
            list.add(int.parse(str[i]));
          }
          print("data: "+str);
          cc+=str;
          setState(() {
            
          });
          rtcEngine?.sendStreamMessage(streamId: dataStreamID, data: Uint8List.fromList(list), length: list.length);
          _startListening();
        },
        localeId: langCode);
  }
  

  Future<void> getToken() async {
    final response = await http.get(Uri.parse(
        '$tokenBaseUrl/rtc/${widget.call.channel}/publisher/uid/$uid?expiry=3600'));
    if (response.statusCode == 200) {
      setState(() {
        token = jsonDecode(response.body)['rtcToken'];
      });

      initializeCall();
      // await initAgora();
    }
  }

  Future<void> initAgora() async {
    _client = AgoraClient(
        agoraConnectionData: AgoraConnectionData(
          appId: appID,
          tempToken: token,
          //uid: 565,
          channelName: widget.call.channel,
        ),
        enabledPermission: [Permission.camera, Permission.microphone]);
    //_loading=false;

    print(_client.toString());
    // Future.delayed(Duration(seconds: 1)).then(
    //       (value) => setState((){}),
    // );
    await _client.initialize();
    setState(() {});
  }

  Future<void> initializeCall() async {
    await [Permission.microphone, Permission.camera].request();
    await rtcEngine?.initialize(const RtcEngineContext(appId: appID));
    await rtcEngine?.enableVideo();
    rtcEngine?.registerEventHandler(
      RtcEngineEventHandler(
          // onAudioMetadataReceived: (connection, x, lst, y){
          //   print("audioFrame!!!!!!!!!!!!!!!!!!!!!!!");
          // },
          onStreamMessage: (connection, uid, streamId, data, length, sendTime) {
        if (data[0] == 0) {
          String text = String.fromCharCodes(data.sublist(1));
          speak(langCode, text);
          signOutput+=text;
          if (signOutput.length > maxLength) {
            signOutput = signOutput.substring(signOutput.length - maxLength);
          }
        } else {
          cc += String.fromCharCodes(data.sublist(1));
          if (cc.length > maxLength) {
            cc = cc.substring(cc.length - maxLength);
          }
        }
        setState(() {});
      }, onJoinChannelSuccess: (connection, elapsed) {
        setState(() {
          localUserJoined = true;
        });
        if (widget.call.id == null) {
          //Make A Call
          makeCall();
        } else {
          callsCollection.doc(widget.call.id).update(
            {
              'accepted': true,
            },
          );
        }
      }, onUserJoined: (connection, _remoteUid, elapsed) {
        setState(() {
          remoteUid = _remoteUid;
        });
      }, onLeaveChannel: (connection, stats) {
        rtcEngine!
            .getMediaEngine()
            .unregisterAudioFrameObserver(audioFrameObserver);
        rtcEngine!
            .getMediaEngine()
            .unregisterVideoFrameObserver(videoFrameObserver);
        rtcEngine!.release();
        callsCollection.doc(widget.call.id).update(
          {
            'active': false,
          },
        );
        Navigator.pop(context);
      }, onUserOffline: (connection, _remoteUid, reason) {
        setState(() {
          remoteUid = null;
        });
        rtcEngine?.leaveChannel();
        rtcEngine?.release();
        Navigator.pop(context);
        callsCollection.doc(widget.call.id).update(
          {
            'active': false,
          },
        );
      }),
    );
    initDataStream();
    await joinVideoChannel();
    // initTimer();
  }

  makeCall() async {
    DocumentReference callDocRef = callsCollection.doc();
    setState(() {
      callID = callDocRef.id;
      // callID = "7aPdVDaAAGsuIsYAYzsc";
    });
    await callDocRef.set({
      'id': callID,
      'channel': widget.call.channel,
      'caller': widget.call.caller,
      'called': widget.call.called,
      'active': true,
      'accepted': false,
      'rejected': false,
      'connected': false,
    });

    Map data = {
      'user': widget.call.caller,
      'name': currentUserName,
      'photo': "", //current user photo
      'email': widget.call.caller,
      'id': callID,
      'channel': widget.call.channel,
      'caller': widget.call.caller,
      'called': widget.call.called,
      'active': true,
      'accepted': false,
      'rejected': false,
      'connected': false,
    };

    usersCollection.doc(widget.call.called).get().then((value) {
      if (value.exists) {
        final d = value.data() as Map<String, dynamic>;
        for (token in d['tokens']) {
          print(token);
          print(
              "#############################################################################################################################");
          // log("data : $data");
          NotificationServices.sendNotification(token!, data);
        }
      }
    });
  }

  Future joinVideoChannel() async {
    // registerframes();
    await rtcEngine?.startPreview();
    ChannelMediaOptions options = const ChannelMediaOptions(
      clientRoleType: ClientRoleType.clientRoleBroadcaster,
      channelProfile: ChannelProfileType.channelProfileCommunication,
    );
    await rtcEngine?.joinChannel(
        token: token!,
        channelId: widget.call.channel,
        uid: uid,
        options: options);
    await registerframes();
  }

  Future<void> registerframes() async {
    rtcEngine = await createAgoraRtcEngine();
    await rtcEngine?.startPreview();
    ChannelMediaOptions options = const ChannelMediaOptions(
      clientRoleType: ClientRoleType.clientRoleBroadcaster,
      channelProfile: ChannelProfileType.channelProfileCommunication,
    );
    await rtcEngine?.joinChannel(
        token: token!,
        channelId: widget.call.channel,
        uid: 0,
        options: options);
    // Set the format of raw audio data.
    int SAMPLE_RATE = 16000, SAMPLE_NUM_OF_CHANNEL = 1, SAMPLES_PER_CALL = 1024;

    await rtcEngine?.setRecordingAudioFrameParameters(
        sampleRate: SAMPLE_RATE,
        channel: SAMPLE_NUM_OF_CHANNEL,
        mode: RawAudioFrameOpModeType.rawAudioFrameOpModeReadWrite,
        samplesPerCall: SAMPLES_PER_CALL);
    await rtcEngine?.setPlaybackAudioFrameParameters(
        sampleRate: SAMPLE_RATE,
        channel: SAMPLE_NUM_OF_CHANNEL,
        mode: RawAudioFrameOpModeType.rawAudioFrameOpModeReadWrite,
        samplesPerCall: SAMPLES_PER_CALL);
    await rtcEngine?.setMixedAudioFrameParameters(
        sampleRate: SAMPLE_RATE,
        channel: SAMPLE_NUM_OF_CHANNEL,
        samplesPerCall: SAMPLES_PER_CALL);

    rtcEngine?.getMediaEngine().registerAudioFrameObserver(audioFrameObserver);
    rtcEngine?.getMediaEngine().registerVideoFrameObserver(videoFrameObserver);
    // initAgora();
  }

  static void processOutput(List<num> outList) {
    int j = 0;
    for (int i = 0; i < 10; i++) {
      if (outList[j] < outList[i]) j = i;
    }
    if (outList[j] < modelThreshold) return;
    signOutput += labels[j];
    speak('en', labels[j]);

    if (signOutput.length > maxLength) {
      signOutput = signOutput.substring(signOutput.length - maxLength);
    }
  }

  void initTimer() {
    Random random = Random();
    t = Timer.periodic(const Duration(seconds:1), (Timer t){
      int x = random.nextInt(10);
      signOutput += labels[x];
      print(x);
      if (signOutput.length > maxLength) {
        signOutput = signOutput.substring(signOutput.length - maxLength);
      }
      setState(() {

      });
    });

  }

  static Future<void> speak(String languageCode, String text) async {
    final flutterTts = FlutterTts();
    await flutterTts.setLanguage(languageCode);
    await flutterTts.setPitch(1);
    await flutterTts.setVolume(1);
    await flutterTts.setSpeechRate(1);
    await flutterTts.setPitch(1);
    await flutterTts.speak(text);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          //backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          title: Text(
            widget.user.name,
            style: const TextStyle(
              color: Colors.black,
            ),
          ),
        ),
        body: localUserJoined == false || callID == null
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : StreamBuilder<DocumentSnapshot>(
                stream: callsCollection.doc(callID!).snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    CallModel call = CallModel(
                      id: snapshot.data!['id'],
                      channel: snapshot.data!['channel'],
                      caller: snapshot.data!['caller'],
                      called: snapshot.data!['called'],
                      active: snapshot.data!['active'],
                      accepted: snapshot.data!['accepted'],
                      rejected: snapshot.data!['rejected'],
                      connected: snapshot.data!['connected'],
                    );
                    return call.rejected == true
                        ? const Center(child: Text("Call Declined"))
                        : Stack(children: [

                            //other user video widget
                            Center(
                              child: remoteVideo(call: call),
                            ),
                            //Local user video widget
                            if (rtcEngine != null)
                              Positioned.fill(
                                child: Align(
                                  alignment: Alignment.topLeft,
                                  child: SizedBox(
                                    width: 100,
                                    height: 150,
                                    child: AgoraVideoView(
                                      controller: VideoViewController(
                                        rtcEngine: rtcEngine!,
                                        canvas: VideoCanvas(uid: uid),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            // _client.isInitialized ? AgoraVideoButtons(client: _client) : Text(""),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Positioned.fill(
                                  child: Expanded(
                                    child: Align(
                                      alignment: Alignment.bottomLeft,
                                      child: Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              5, 0, 5, 40),
                                          child: FloatingActionButton.small(
                                            backgroundColor: _isMuted
                                                ? Colors.white
                                                : Colors.blue,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(50),
                                            ),
                                            onPressed: () {
                                              if (_isMuted) {
                                                rtcEngine?.enableLocalAudio(true);
                                              } else {
                                                rtcEngine
                                                    ?.enableLocalAudio(false);
                                              }
                                              setState(() {
                                                _isMuted = !_isMuted;
                                              });
                                            },
                                            child: Icon(
                                              _isMuted
                                                  ? Icons.mic_off
                                                  : Icons.mic,
                                              color: !_isMuted
                                                  ? Colors.white
                                                  : Colors.blue,
                                            ),
                                          )),
                                    ),
                                  ),
                                ),
                                Positioned.fill(
                                  child: Expanded(
                                    child: Align(
                                      alignment: Alignment.bottomLeft,
                                      child: Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              5, 0, 5, 40),
                                          child: FloatingActionButton.small(
                                            backgroundColor: _isCamOff
                                                ? Colors.white
                                                : Colors.blue,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(50),
                                            ),
                                            onPressed: () {
                                              if (_isCamOff) {
                                                rtcEngine?.enableLocalVideo(true);
                                              } else {
                                                rtcEngine
                                                    ?.enableLocalVideo(false);
                                              }
                                              setState(() {
                                                _isCamOff = !_isCamOff;
                                              });
                                            },
                                            child: Icon(
                                              _isCamOff
                                                  ? Icons.videocam_off
                                                  : Icons.videocam,
                                              color: !_isCamOff
                                                  ? Colors.white
                                                  : Colors.blue,
                                            ),
                                          )),
                                    ),
                                  ),
                                ),
                                Positioned.fill(
                                  child: Expanded(
                                    child: Align(
                                      alignment: Alignment.bottomCenter,
                                      child: Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              5, 0, 5, 40),
                                          child: FloatingActionButton(
                                            backgroundColor: Colors.red,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(50),
                                            ),
                                            onPressed: () {
                                              rtcEngine?.leaveChannel();
                                            },
                                            child: const Icon(
                                              Icons.call_end_rounded,
                                              color: Colors.white,
                                            ),
                                          )),
                                    ),
                                  ),
                                ),

                                Positioned.fill(
                                  child: Expanded(
                                    child: Align(
                                      alignment: Alignment.bottomCenter,
                                      child: Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              5, 0, 5, 40),
                                          child: FloatingActionButton.small(
                                            backgroundColor: !_ccOn
                                                ? Colors.white
                                                : Colors.blue,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(50),
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                _ccOn = !_ccOn;
                                              });
                                            },
                                            child: Icon(
                                              _ccOn
                                                  ? Icons.closed_caption
                                                  : Icons.closed_caption_disabled,
                                              color: _ccOn
                                                  ? Colors.white
                                                  : Colors.blue,
                                            ),
                                          )),
                                    ),
                                  ),
                                ),
                                Positioned.fill(
                                  child: Expanded(
                                    child: Align(
                                      alignment: Alignment.bottomCenter,
                                      child: Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              5, 0, 5, 40),
                                          child: FloatingActionButton.small(
                                            backgroundColor: !_signLanguageOn
                                                ? Colors.white
                                                : Colors.blue,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                              BorderRadius.circular(50),
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                _signLanguageOn =
                                                !_signLanguageOn;
                                              });
                                            },
                                            child: Icon(
                                              Icons.sign_language,
                                              color: _signLanguageOn
                                                  ? Colors.white
                                                  : Colors.blue,
                                            ),
                                          )
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                      Positioned.fill(
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(5, 0, 5, 160),
                            child: Text(
                              _signLanguageOn ? signOutput : "",
                              style: const TextStyle(
                                color: Colors.greenAccent,
                                fontWeight: FontWeight.w300,
                                fontFamily: 'Futura',
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned.fill(
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(5, 0, 5, 120),
                            child: Text(
                              _ccOn ? cc : "",
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w300,
                                fontFamily: 'Futura',
                              ),
                            ),
                          ),
                        ),
                      ),
                          ]);
                  }
                  return const SizedBox.shrink();
                }),
      ),
    );
  }

  Widget remoteVideo({required CallModel call}) {
    return Stack(
      children: [
        if (remoteUid != null)
          AgoraVideoView(
            controller: VideoViewController.remote(
              rtcEngine: rtcEngine!,
              canvas: VideoCanvas(uid: remoteUid),
              connection: RtcConnection(channelId: call.channel),
            ),
          ),
        if (remoteUid == null)
          Positioned.fill(
            child: Center(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                UserPhoto(radius: 50, url: widget.user.photo),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(call.connected == false
                      ? "Connecting to ${widget.user.name}"
                      : "Waiting Response.."),
                )
              ],
            )),
          )
      ],
    );
  }
}
