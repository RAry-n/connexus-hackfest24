import 'dart:convert';

// import 'dart:math';
import 'dart:developer';
import 'dart:typed_data';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:agora_uikit/agora_uikit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:tflite_flutter/tflite_flutter.dart' as tfl;

import '../constants/utils.dart';
import '../models/call.dart';
import '../models/user.dart';
import '../provider/notiification_service.dart';
import '../widgets/user_photo.dart';
import '../constants/utils.dart';

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
  RtcEngine? rtcEngine;
  String? token;
  int uid = 0;
  bool localUserJoined = false;
  String? callID;
  int? remoteUid;
  late final AgoraClient _client;
  bool _isMuted = false;
  bool _isCamOff = false;
  // late Uint8List data;
  // static int frameCount=0;
  // AudioFrameObserver audioFrameObserver = AudioFrameObserver(
  //     onRecordAudioFrame: (String channelId, AudioFrame audioFrame) {
  //       // Gets the captured audio frame
  //     },
  //     onPlaybackAudioFrame: (String channelId, AudioFrame audioFrame) {
  //       // Gets the audio frame for playback
  //       debugPrint('[onPlaybackAudioFrame] audioFrame: ${audioFrame.toJson()}');
  //     }
  // );
  //
  // VideoFrameObserver videoFrameObserver = VideoFrameObserver(
  //   // onCaptureVideoFrame: (VideoFrame videoFrame) {
  //   //   // The video data that this callback gets has not been pre-processed
  //   //   // After pre-processing, you can send the processed video data back
  //   //   // to the SDK through this callback
  //   //   debugPrint('[onCaptureVideoFrame] videoFrame: ${videoFrame.toJson()}');
  //   // },
  //     onRenderVideoFrame: (String channelId, int remoteUid, VideoFrame videoFrame) {
  //       frameCount++;
  //       if(frameCount%60!=0) return;
  //       var data= yuvToRgb(videoFrame.yBuffer!, videoFrame.uBuffer!, videoFrame.vBuffer!, 224, 224);
  //       List<List<List<List<double>>>> input= convertInput( data );
  //       runInterpreter(input);
  //       // Occurs each time the SDK receives a video frame sent by the remote user.
  //       // In this callback, you can get the video data before encoding.
  //       // You then process the data according to your particular scenario.
  //     }
  // );



  @override
  void initState() {
    setState(() {
      callID = widget.call.id;
      rtcEngine = createAgoraRtcEngine();
    });
    super.initState();
    Future.delayed(const Duration(milliseconds: 1000)).then((_) {
      getToken();
    });
  }

  @override
  void dispose() {
    rtcEngine!.release();
    // rtcEngine!.getMediaEngine().unregisterAudioFrameObserver(audioFrameObserver);
    // rtcEngine!.getMediaEngine().unregisterVideoFrameObserver(videoFrameObserver);
    rtcEngine!.leaveChannel();
    super.dispose();
  }
  // static Uint8List yuvToRgb(Uint8List yData, Uint8List uData, Uint8List vData, int width, int height) {
  //   // Create an empty RGB image buffer
  //   Uint8List rgbData = Uint8List(width * height * 3);
  //
  //   // Iterate through each pixel and convert YUV to RGB
  //   for (int y = 0; y < height; y++) {
  //     for (int x = 0; x < width; x++) {
  //       int index = y * width + x;
  //
  //       int yValue = yData[index].toInt();
  //       int uValue = uData[(y ~/ 2) * (width ~/ 2) + (x ~/ 2)].toInt();
  //       int vValue = vData[(y ~/ 2) * (width ~/ 2) + (x ~/ 2)].toInt();
  //
  //       // YUV to RGB conversion
  //       int r = (yValue + 1.13983 * (vValue - 128)).toInt();
  //       int g = (yValue - 0.39465 * (uValue - 128) - 0.58060 * (vValue - 128)).toInt();
  //       int b = (yValue + 2.03211 * (uValue - 128)).toInt();
  //
  //       // Clamp the values to the range [0, 255]
  //       r = r.clamp(0, 255);
  //       g = g.clamp(0, 255);
  //       b = b.clamp(0, 255);
  //
  //       // Store the RGB values in the buffer
  //       rgbData[index * 3] = r;
  //       rgbData[index * 3 + 1] = g;
  //       rgbData[index * 3 + 2] = b;
  //     }
  //   }
  //
  //   return rgbData;
  // }
  // static List<List<List<List<double>>>> convertInput( Uint8List data ){
  //   //Uint8List data = yuv420ToRgba8888(cameraImage!.planes.map((e) => e.bytes).toList(), 224, 224);
  //   List<List<List<double>>> l3=[];
  //   int p=0;
  //   for(int i=0;i<224;i++){
  //     List<List<double>> l2=[];
  //     for(int j=0;j<224;j++){
  //       List<double> lst=[];
  //       for(int k=0;k<4;k++) {
  //         if(k<3) lst.add(data[p]/256.0);
  //         p++;
  //       }
  //       l2.add(lst);
  //     }
  //     l3.add(l2);
  //   }
  //   //input.add(l3);
  //   return [l3];
  // }


  // Creating matrix representation, [300, 300, 3]

//   static runInterpreter(List<List<List<List<double>>>> input) async
//   {
//     print("000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000");
//     final interpreter = await tfl.Interpreter.fromAsset('assets/ml/accha_model.tflite');
//     print("111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111");
//
//     // List<List<List<List<double>>>> input = convertInput();
//
//     print("22222222222222222222222222222222222222222222222222222222222222222222222222222222");
//     List<List<num>> out = [List<num>.filled(29, 0)];
//     print("3333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333");
//
//
//     print("444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444");
// // inference
//     interpreter.run(input, out);
//     print("555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555");
// // print the output
//     print(out);
//     // processOutput(out[0]);
//     // interpreter.close();
//   }
  // void registerframes()
  // {
  //   // Set the format of raw audio data.
  //   int SAMPLE_RATE = 16000, SAMPLE_NUM_OF_CHANNEL = 1, SAMPLES_PER_CALL = 1024;
  //
  //   rtcEngine!.setRecordingAudioFrameParameters(
  //       sampleRate: SAMPLE_RATE,
  //       channel: SAMPLE_NUM_OF_CHANNEL,
  //       mode: RawAudioFrameOpModeType.rawAudioFrameOpModeReadWrite,
  //       samplesPerCall: SAMPLES_PER_CALL);
  //   rtcEngine!.setPlaybackAudioFrameParameters(
  //       sampleRate: SAMPLE_RATE,
  //       channel: SAMPLE_NUM_OF_CHANNEL,
  //       mode: RawAudioFrameOpModeType.rawAudioFrameOpModeReadWrite,
  //       samplesPerCall: SAMPLES_PER_CALL);
  //   rtcEngine!.setMixedAudioFrameParameters(
  //       sampleRate: SAMPLE_RATE,
  //       channel: SAMPLE_NUM_OF_CHANNEL,
  //       samplesPerCall: SAMPLES_PER_CALL);
  //
  //   rtcEngine!.getMediaEngine().registerAudioFrameObserver(audioFrameObserver);
  //   rtcEngine!.getMediaEngine().registerVideoFrameObserver(videoFrameObserver);
  //
  // }
  Future<void> getToken() async {
    final response = await http.get(Uri.parse('$tokenBaseUrl/rtc/${widget.call.channel}/publisher/uid/$uid?expiry=3600'));
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
      RtcEngineEventHandler(onJoinChannelSuccess: (connection, elapsed) {
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
    await joinVideoChannel();
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
          print("#############################################################################################################################");
          log("data : $data");
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
    await rtcEngine?.joinChannel(token: token!, channelId: widget.call.channel, uid: uid, options: options);
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
                                  child: Align(
                                    alignment: Alignment.bottomLeft,
                                    child: Padding(
                                        padding: const EdgeInsets.all(40),
                                        child: FloatingActionButton(
                                          backgroundColor: Colors.transparent,
                                          onPressed: () {
                                            if (_isMuted) {
                                              rtcEngine?.enableLocalAudio(true);
                                            } else {
                                              rtcEngine?.enableLocalAudio(false);
                                            }
                                            setState(() {
                                              _isMuted = !_isMuted;
                                            });
                                          },
                                          child: Icon(
                                            _isMuted ? Icons.mic_off : Icons.mic,
                                            color: Colors.white,
                                          ),
                                        )),
                                  ),
                                ),
                                Positioned.fill(
                                  child: Align(
                                    alignment: Alignment.bottomLeft,
                                    child: Padding(
                                        padding: const EdgeInsets.all(40),
                                        child: FloatingActionButton(
                                          backgroundColor: Colors.transparent,
                                          onPressed: () {
                                            if (_isCamOff) {
                                              rtcEngine?.enableLocalVideo(true);
                                            } else {
                                              rtcEngine?.enableLocalVideo(false);
                                            }
                                            setState(() {
                                              _isCamOff = !_isCamOff;
                                            });
                                          },
                                          child: Icon(
                                            _isCamOff ? Icons.videocam_off : Icons.videocam,
                                            color: Colors.white,
                                          ),
                                        )),
                                  ),
                                ),
                                Positioned.fill(
                                  child: Align(
                                    alignment: Alignment.bottomCenter,
                                    child: Padding(
                                        padding: const EdgeInsets.only(bottom: 40),
                                        child: FloatingActionButton(
                                          backgroundColor: Colors.red,
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
                              ],
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
                  child: Text(call.connected == false ? "Connecting to ${widget.user.name}" : "Waiting Response.."),
                )
              ],
            )),
          )
      ],
    );
  }
}
