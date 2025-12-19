import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/scenario.dart';
import 'analysis_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ChatScreen extends StatefulWidget {
  final String level;
  final String targetLanguage; // LLM'in Dili
  final String appLanguage;    // Arayüz Dili
  final int sessionDurationMinutes;
  final Scenario scenario;

  const ChatScreen({
    super.key,
    required this.level,
    required this.targetLanguage,
    required this.appLanguage,
    required this.sessionDurationMinutes,
    required this.scenario
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatUser _currentUser = ChatUser(id: '1', firstName: 'Student');
  final ChatUser _gptUser = ChatUser(id: '2', firstName: '');
  List<ChatMessage> _messages = [];
  final String _groqApiKey = dotenv.env['GROQ_API_KEY'] ?? '';
  final String _modelId = 'meta-llama/llama-4-scout-17b-16e-instruct';
  List<Map<String, String>> _conversationHistory = [];
  final AudioPlayer _audioPlayer = AudioPlayer();
  final FlutterTts _flutterTts = FlutterTts();
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  bool _isLoading = true;
  Timer? _timer;
  late int _remainingSeconds;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.sessionDurationMinutes * 60;
    _initTTS();
    _startRoleplay();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioPlayer.stop();
    _audioPlayer.dispose();
    _flutterTts.stop();
    super.dispose();
  }

  Future<void> _playAmbience() async {
    try {
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      await _audioPlayer.setVolume(0.15);
      await _audioPlayer.play(AssetSource(widget.scenario.ambiencePath));
    } catch (e) {
      print("Audio Error: $e");
    }
  }

  Future<void> _initTTS() async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setSpeechRate(0.5);
  }

  Future<void> _speak(String text) async { await _flutterTts.speak(text); }

  Future<void> _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) {
            if (val.finalResult) {
              final message = ChatMessage(user: _currentUser, createdAt: DateTime.now(), text: val.recognizedWords);
              _handleUserMessage(message);
              setState(() => _isListening = false);
            }
          },
          localeId: "en_US",
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
      } else {
        _timer?.cancel();
        _triggerAnalysis(autoFinish: true);
      }
    });
  }

  String _formatTime(int totalSeconds) {
    final m = totalSeconds ~/ 60;
    final s = totalSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  Future<void> _startRoleplay() async {
    _playAmbience();
    _startTimer();

    // DİL AYARI BURADA YAPILIYOR
    String systemPrompt = """
    ROLE: Roleplay Actor. SCENARIO: ${widget.scenario.promptContext}
    LEVEL: ${widget.level}. 
    LANGUAGE: Speak ONLY in ${widget.targetLanguage}. 
    INSTRUCTION: Start conversation immediately with a question in ${widget.targetLanguage}.
    Keep responses short.
    """;

    _conversationHistory.add({'role': 'system', 'content': systemPrompt});
    await _sendMessageToGroq("Start roleplay.", isHidden: true);
  }

  Future<void> _sendMessageToGroq(String userMessage, {bool isHidden = false}) async {
    if (!isHidden) {
      _conversationHistory.add({'role': 'user', 'content': userMessage});
      setState(() => _isLoading = true);
    }
    try {
      final url = Uri.parse('https://api.groq.com/openai/v1/chat/completions');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $_groqApiKey'},
        body: jsonEncode({
          'model': _modelId,
          'messages': _conversationHistory,
          'max_tokens': 150,
        }),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final aiResponse = data['choices'][0]['message']['content'].toString();
        _conversationHistory.add({'role': 'assistant', 'content': aiResponse});
        setState(() {
          _messages.insert(0, ChatMessage(user: _gptUser, createdAt: DateTime.now(), text: aiResponse));
          _isLoading = false;
        });
        _speak(aiResponse);
      }
    } catch (e) { setState(() => _isLoading = false); }
  }

  void _handleUserMessage(ChatMessage message) {
    setState(() => _messages.insert(0, message));
    if (message.text.toLowerCase().contains("finish")) {
      _triggerAnalysis();
    } else {
      _sendMessageToGroq(message.text);
    }
  }

  Future<void> _triggerAnalysis({bool autoFinish = false}) async {
    _timer?.cancel();
    await _audioPlayer.stop();

    _conversationHistory.add({
      'role': 'user',
      'content': "STOP ROLEPLAY. Switch to Teacher Mode. Give me a score out of 100. Analyze my mistakes. Output in Markdown."
    });

    setState(() => _isLoading = true);
    if (autoFinish && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(widget.appLanguage == 'Türkçe' ? "Süre doldu!" : "Time's up!")));
    }

    try {
      final url = Uri.parse('https://api.groq.com/openai/v1/chat/completions');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $_groqApiKey'},
        body: jsonEncode({'model': _modelId, 'messages': _conversationHistory}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final analysisText = data['choices'][0]['message']['content'].toString();

        if(mounted) {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => AnalysisScreen(
                  text: analysisText,
                  appLanguage: widget.appLanguage // Analiz ekranına dil bilgisini gönder
              ))
          );
        }
      }
    } catch (e) { setState(() => _isLoading = false); }
  }

  @override
  Widget build(BuildContext context) {
    // Uygulama Dili Kontrolü
    final isTr = widget.appLanguage == 'Türkçe';

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.timer_outlined, size: 20, color: Colors.white),
            const SizedBox(width: 5),
            Text(_formatTime(_remainingSeconds), style: TextStyle(color: _remainingSeconds < 30 ? Colors.redAccent : Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 10),
            decoration: BoxDecoration(color: Colors.red.withOpacity(0.8), borderRadius: BorderRadius.circular(20)),
            child: TextButton.icon(
              icon: const Icon(Icons.stop_circle_outlined, color: Colors.white, size: 20),
              label: Text(isTr ? "BİTİR" : "FINISH", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              onPressed: () => _triggerAnalysis(),
            ),
          )
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(child: Image.network(widget.scenario.imageUrl, fit: BoxFit.cover)),
          Positioned.fill(child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5), child: Container(color: Colors.black.withOpacity(0.3)))),
          SafeArea(
            child: DashChat(
              currentUser: _currentUser,
              onSend: _handleUserMessage,
              messages: _messages,
              readOnly: _isLoading,
              messageOptions: const MessageOptions(
                showOtherUsersName: false,
                currentUserContainerColor: Color(0xFF6C63FF),
                currentUserTextColor: Colors.white,
                containerColor: Colors.white,
                textColor: Colors.black87,
              ),
              inputOptions: InputOptions(
                inputDecoration: InputDecoration(
                  hintText: isTr ? ( _isListening ? "Dinleniyor..." : "Yazın...") : (_isListening ? "Listening..." : "Type..."),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.9),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: BorderSide.none),
                  suffixIcon: IconButton(icon: Icon(Icons.mic, color: _isListening ? Colors.red : const Color(0xFF6C63FF)), onPressed: _listen),
                ),
              ),
            ),
          ),
          if (_isLoading && _messages.isEmpty)
            Center(child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(color: Color(0xFF6C63FF)),
                  const SizedBox(height: 10),
                  Text(isTr ? "Sahne Hazırlanıyor..." : "Setting the scene...", style: const TextStyle(fontWeight: FontWeight.bold))
                ],
              ),
            ))
        ],
      ),
    );
  }
}