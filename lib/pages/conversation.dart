import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:pinput/pinput.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:translator/translator.dart';

import '../constants/my_colors.dart';
import '../themes/text_themes.dart';

class ConversationScreen extends StatefulWidget {
  const ConversationScreen({super.key});

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  String selectedLanguagePart1 = 'English'; // Default language for the first part
  String selectedLanguagePart2 = 'Spanish'; // Default language for the second part

  final _controller1 = TextEditingController();
  final _controller2 = TextEditingController();

  final translator = GoogleTranslator();
  final flutterTts = FlutterTts();
  final _speechToText = SpeechToText();

  int _partListening = 0;
  String _wordsSpoken = "";

  @override
  void initState() {
    super.initState();
    initSpeech();
  }

  void initSpeech() async {
    setState(() {});
  }

  void _startListening(bool isPart1) async {
    await _speechToText.listen(onResult: (result) {
      _onSpeechResult(result, isPart1);
    }, localeId: languageCode(isPart1 ? selectedLanguagePart1 : selectedLanguagePart2));
  }

  void _stopListening() async {
    await _speechToText.stop();
    setState(() {});
  }

  void _onSpeechResult(result, bool isPart1) {
    setState(() {
      _wordsSpoken = "${result.recognizedWords}";

      if(isPart1) {
        _controller1.setText(_wordsSpoken);
      } else {
        _controller2.setText(_wordsSpoken);
      }
    });
  }

  Future<void> _translateText(bool isPart1) async {
    String code1 = languageCode(selectedLanguagePart1);
    String code2 = languageCode(selectedLanguagePart2);

    String inputText = isPart1 ? _controller1.text : _controller2.text;
    String inputLanguage = isPart1 ? code1 : code2;
    String outputLanguage = isPart1 ? code2 : code1;

    final translated = await translator.translate(inputText, from: inputLanguage, to: outputLanguage);
    setState(() {
      if(isPart1) {
        _controller2.setText(translated.text);
      } else {
        _controller1.setText(translated.text);
      }
    });
  }

  String languageCode(String languageName) {
    switch (languageName.toLowerCase()) {
      case 'english':
        return 'en';
      case 'russian':
        return 'ru';
      case 'french':
        return 'fr';
      case 'chinese':
        return 'zh-cn';
      case 'hindi':
        return 'hi';
      case 'german':
        return 'de';
      case 'italian':
        return 'it';
      case 'spanish':
        return 'es';
      case 'japanese':
        return 'ja';
      default:
        return 'hi';
    }
  }

  Future speak(String languageCode, String text) async {
    await flutterTts.setLanguage(languageCode);
    await flutterTts.setPitch(1);
    await flutterTts.setVolume(1);
    await flutterTts.setSpeechRate(1);
    await flutterTts.setPitch(1);
    await flutterTts.speak(text);
  }

  Future<void> _showLanguageDialog(BuildContext context, bool isPart1) async {
    String? newLanguage = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Language'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                _buildLanguageButton(context, 'English', isPart1),
                _buildLanguageButton(context, 'Russian', isPart1),
                _buildLanguageButton(context, 'French', isPart1),
                _buildLanguageButton(context, 'Chinese', isPart1),
                _buildLanguageButton(context, 'Hindi', isPart1),
                _buildLanguageButton(context, 'German', isPart1),
                _buildLanguageButton(context, 'Italian', isPart1),
                _buildLanguageButton(context, 'Spanish', isPart1),
                _buildLanguageButton(context, 'Japanese', isPart1),
                // Add more language options here if needed
              ],
            ),
          ),
        );
      },
    );
    if (newLanguage != null) {
      setState(() {
        if (isPart1) {
          selectedLanguagePart1 = newLanguage;
        } else {
          selectedLanguagePart2 = newLanguage;
        }
      });
    }
  }

  Widget _buildLanguageButton(BuildContext dialogContext, String language, bool isPart1) {
    return InkWell(
      onTap: () {
        Navigator.of(dialogContext).pop(language);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Text(
          language,
          style: TextStyle(
            color: isPart1 ? selectedLanguagePart1 == language ? Colors.blue : Colors.black : selectedLanguagePart2 == language ? Colors.blue : Colors.black,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: MyColors.appBarColor,
        titleTextStyle: TextThemes.appBar,
        title: const Text('Conversation'),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 1,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.all(20.0),
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        TextField(
                          maxLines: null,
                          expands: true,
                          cursorColor: Colors.cyan,
                          style: const TextStyle(
                            color: MyColors.text,
                            fontWeight: FontWeight.w300,
                            fontFamily: 'Futura',
                          ),
                          decoration: InputDecoration(
                            hintText: "Enter text...",
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(4),
                              borderSide: const BorderSide(color: Colors.black12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(4),
                              borderSide: const BorderSide(color: Colors.cyan),
                            ),
                            alignLabelWithHint: true,
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.volume_up_rounded),
                              onPressed: () {
                                speak(languageCode(selectedLanguagePart1), _controller1.text);
                              },
                            ),
                            contentPadding: const EdgeInsets.only(top: 10.0, left: 10.0, right: 10.0, bottom: 30.0),
                          ),
                          textAlignVertical: TextAlignVertical.top,
                          controller: _controller1,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            selectedLanguagePart1,
                            style: const TextStyle(
                              color: MyColors.text,
                              fontWeight: FontWeight.w300,
                              fontFamily: 'Futura',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GestureDetector(
                      onTap: () {
                        _showLanguageDialog(context, true);
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 20.0),
                        child: Material(
                          color: Colors.cyan,
                          borderRadius: BorderRadius.circular(25.0),
                          child: const Padding(
                            padding: EdgeInsets.all(12.0),
                            child: Icon(
                              Icons.language,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(right: 20.0),
                      child: Material(
                        color: Colors.cyan,
                        borderRadius: BorderRadius.circular(25.0),
                        child: InkWell(
                          onTap: () {
                            if(_speechToText.isListening) {
                              _partListening = 0;
                              _stopListening();
                            } else {
                              _partListening = 1;
                              _startListening(true);
                            }
                            // if(_speechToText.isListening) {
                            //   _stopListening();
                            //   if(_partListening == 1) {
                            //     _partListening = 0;
                            //   } else {
                            //     _partListening = 1;
                            //     _startListening(true);
                            //   }
                            // } else {
                            //   _partListening = 1;
                            //   _startListening(true);
                            // }
                          },
                          borderRadius: BorderRadius.circular(25.0),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Icon(
                              (_speechToText.isListening && _partListening == 1) ? Icons.mic : Icons.mic_off,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(right: 20.0),
                      child: Material(
                        color: Colors.cyan,
                        borderRadius: BorderRadius.circular(25.0),
                        child: InkWell(
                          onTap: () {
                            _translateText(true);
                          },
                          borderRadius: BorderRadius.circular(25.0),
                          child: const Padding(
                            padding: EdgeInsets.all(12.0),
                            child: Icon(
                              Icons.arrow_forward,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.all(20.0),
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        TextField(
                          maxLines: null,
                          expands: true,
                          cursorColor: Colors.cyan,
                          style: const TextStyle(
                            color: MyColors.text,
                            fontWeight: FontWeight.w300,
                            fontFamily: 'Futura',
                          ),
                          decoration: InputDecoration(
                            hintText: "Enter text...",
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(4),
                              borderSide: const BorderSide(color: Colors.black12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(4),
                              borderSide: const BorderSide(color: Colors.cyan),
                            ),
                            // Align text to the top left corner
                            alignLabelWithHint: true,
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.volume_up_rounded),
                              onPressed: () {
                                speak(languageCode(selectedLanguagePart2), _controller2.text);
                              },
                            ),
                            contentPadding: const EdgeInsets.only(top: 10.0, left: 10.0, right: 10.0, bottom: 30.0),
                          ),
                          textAlignVertical: TextAlignVertical.top,
                          controller: _controller2,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            selectedLanguagePart2,
                            style: const TextStyle(
                              color: MyColors.text,
                              fontWeight: FontWeight.w300,
                              fontFamily: 'Futura',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GestureDetector(
                      onTap: () {
                        _showLanguageDialog(context, false);
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 20.0),
                        child: Material(
                          color: Colors.cyan,
                          borderRadius: BorderRadius.circular(25.0),
                          child: InkWell(
                            onTap: () {
                              _showLanguageDialog(context, false);
                            },
                            borderRadius: BorderRadius.circular(25.0),
                            child: const Padding(
                              padding: EdgeInsets.all(12.0),
                              child: Icon(
                                Icons.language,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(right: 20.0),
                      child: Material(
                        color: Colors.cyan,
                        borderRadius: BorderRadius.circular(25.0),
                        child: InkWell(
                          onTap: () {
                            if(_speechToText.isListening) {
                              _partListening = 0;
                              _stopListening();
                            } else {
                              _partListening = 2;
                              _startListening(false);
                            }
                          },
                          borderRadius: BorderRadius.circular(25.0),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Icon(
                              (_speechToText.isListening && _partListening == 2) ? Icons.mic : Icons.mic_off,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(right: 20.0),
                      child: Material(
                        color: Colors.cyan,
                        borderRadius: BorderRadius.circular(25.0),
                        child: InkWell(
                          onTap: () {
                            _translateText(false);
                          },
                          borderRadius: BorderRadius.circular(25.0),
                          child: const Padding(
                            padding: EdgeInsets.all(12.0),
                            child: Icon(
                              Icons.arrow_forward,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
