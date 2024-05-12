import 'dart:convert';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:agora_uikit/agora_uikit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart';

import '../constants/my_colors.dart';
import '../ml/sign_language_model.dart';

class VideoCall extends StatefulWidget {
  String channelName = "";

  VideoCall({required this.channelName});
  @override
  _VideoCallState createState() => _VideoCallState();
}

class _VideoCallState extends State<VideoCall> {
  late final AgoraClient _client;
  late RtcEngine rtcEngine;
  bool _loading = true;
  String tempToken = "";
  bool _signLanguageOn=false;
  static SignLanguageModel model = SignLanguageModel();
  static String signOutput="";
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
  static int frameCount=0;
  AudioFrameObserver audioFrameObserver = AudioFrameObserver(
      onRecordAudioFrame: (String channelId, AudioFrame audioFrame) {
        // Gets the captured audio frame
        print("###############################################################################################################################");
      },
      onPlaybackAudioFrame: (String channelId, AudioFrame audioFrame) {
        // Gets the audio frame for playback
        print("###############################################################################################################################");
        debugPrint('[onPlaybackAudioFrame] audioFrame: ${audioFrame.toJson()}');
      }
  );

  VideoFrameObserver videoFrameObserver = VideoFrameObserver(
    // onCaptureVideoFrame: (VideoFrame videoFrame) {
    //   //current user video fram
    //   debugPrint('[onCaptureVideoFrame] videoFrame: ${videoFrame.toJson()}');
    // },
    onRenderVideoFrame: (String channelId, int remoteUid, VideoFrame videoFrame) {
      //remote user videoFrame
      frameCount++;
      print("###############################################################################################################################");
      print(frameCount);
      if(frameCount%60!=0) return;
      List<num> output = model.runFromPlanes([videoFrame.yBuffer!, videoFrame.uBuffer!, videoFrame.vBuffer!]);
      processOutput(output);
    }
  );

  @override
  void initState() {


    getToken();
    model.initialize();
    Future.delayed(Duration(seconds: 3)).then(
          (value) => setState(() => _loading = false),
    );
    super.initState();

  }
  Future<void> initAgora() async {
    _client = AgoraClient(
        agoraConnectionData: AgoraConnectionData(
          appId: "cfece32da59341699bfd790bced4249f",
          tempToken: tempToken,
          uid: 0,
          channelName: widget.channelName,
        ),
        enabledPermission: [Permission.camera, Permission.microphone]);
    print(_client.toString());
    await _client.initialize();
    setState(() {
      _loading = false;
    });
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
    registerframes();

  }

  Future<void> registerframes()
  async {
    rtcEngine = await createAgoraRtcEngine();
    await rtcEngine.startPreview();
    ChannelMediaOptions options = const ChannelMediaOptions(
      clientRoleType: ClientRoleType.clientRoleBroadcaster,
      channelProfile: ChannelProfileType.channelProfileCommunication,
    );
    await rtcEngine.joinChannel(
        token: tempToken,
        channelId: widget.channelName,
        uid: 0,
        options: options);
    // Set the format of raw audio data.
    int SAMPLE_RATE = 16000, SAMPLE_NUM_OF_CHANNEL = 1, SAMPLES_PER_CALL = 1024;

    await rtcEngine.setRecordingAudioFrameParameters(
        sampleRate: SAMPLE_RATE,
        channel: SAMPLE_NUM_OF_CHANNEL,
        mode: RawAudioFrameOpModeType.rawAudioFrameOpModeReadWrite,
        samplesPerCall: SAMPLES_PER_CALL);
    await rtcEngine.setPlaybackAudioFrameParameters(
        sampleRate: SAMPLE_RATE,
        channel: SAMPLE_NUM_OF_CHANNEL,
        mode: RawAudioFrameOpModeType.rawAudioFrameOpModeReadWrite,
        samplesPerCall: SAMPLES_PER_CALL);
    await rtcEngine.setMixedAudioFrameParameters(
        sampleRate: SAMPLE_RATE,
        channel: SAMPLE_NUM_OF_CHANNEL,
        samplesPerCall: SAMPLES_PER_CALL);

    rtcEngine.getMediaEngine().registerAudioFrameObserver(audioFrameObserver);
    rtcEngine.getMediaEngine().registerVideoFrameObserver(videoFrameObserver);
    initAgora();

  }

  static void processOutput(List<num> outList){
    int j=0;
    for(int i=0;i<10;i++){
      if(outList[j]<outList[i]) j=i;
    }
    if(outList[j] < modelThreshold ) return;
    signOutput+=labels[j];
    speak('en', labels[j]);

    if(signOutput.length>maxLength){
      signOutput=signOutput.substring(signOutput.length - maxLength);
    }
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
  void dispose() {
    // TODO: implement dispose
    rtcEngine.leaveChannel();
    super.dispose();
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
            Container(
              alignment: Alignment.bottomCenter,
              margin: EdgeInsets.fromLTRB(5, 0, 5, 20),
              child: Text(
                _signLanguageOn ? signOutput : "",
                style: const TextStyle(
                  color: MyColors.text,
                  fontWeight: FontWeight.w300,
                  fontFamily: 'Futura',
                ),
              ),
            ),
            AgoraVideoViewer(
              client: _client,
              layoutType: Layout.floating,
              enableHostControls: true,
            ),
            AgoraVideoButtons(
                client: _client,
              extraButtons: [
                Positioned.fill(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                        padding: const EdgeInsets.only(bottom: 40),
                        child: FloatingActionButton(
                          backgroundColor: Colors.white,
                          onPressed: () {
                            setState(() {
                              _signLanguageOn=!_signLanguageOn;
                            });
                          },
                          child: const Icon(
                            Icons.sign_language,
                            color: Colors.blue,
                          ),
                        )),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
