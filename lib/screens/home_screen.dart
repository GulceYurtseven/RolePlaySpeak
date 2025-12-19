import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/scenario.dart';
import 'chat_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Varsayılanlar
  String _appLanguage = 'Türkçe';
  String _targetLanguage = 'English';
  String _level = 'A1 (Beginner)';
  int _duration = 5;

  final List<Scenario> _scenarios = [
    // Kafe Sipariş
    Scenario(
      name: "Paris Cafe",
      promptContext: "Waiter in a cafe. User orders food.",
      imageUrl: "https://images.unsplash.com/photo-1616091216791-a5360b5fc78a?q=80&w=695&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
      ambiencePath: "sounds/cofee-ambience.mp3",
    ),
    // Polis Karakol
    Scenario(
      name: "Police Station",
      promptContext: "Police officer taking a statement from user.",
      imageUrl: "https://plus.unsplash.com/premium_photo-1687950889899-ef36866e50ca?q=80&w=687&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
      ambiencePath: "sounds/office-ambience-6322.mp3",
    ),
    // Mülakat
    Scenario(
      name: "Job Interview",
      promptContext: "HR Manager conducting a job interview.",
      imageUrl: "https://images.unsplash.com/photo-1686771416282-3888ddaf249b?q=80&w=1171&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
      ambiencePath: "sounds/office-ambience-6322.mp3",
    ),

    // Doktorda Muayene
    Scenario(
      name: "Doctor's Visit",
      promptContext: "You are a doctor. The user is a patient describing their symptoms. Be professional and ask medical questions.",
      imageUrl: "https://plus.unsplash.com/premium_photo-1681843129112-f7d11a2f17e3?q=80&w=1170&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
      ambiencePath: "sounds/hospital_ambience.mp3",
    ),

    // Otel Check-in
    Scenario(
      name: "Hotel Check-in",
      promptContext: "You are a hotel receptionist. The user is checking in. Ask for ID and reservation details.",
      imageUrl: "https://images.unsplash.com/photo-1566073771259-6a8506099945?auto=format&fit=crop&q=80&w=1000",
      ambiencePath: "sounds/lobby-ambience.mp3",
    ),

    // Havaalanı Pasaport Kontrolü
    Scenario(
      name: "Airport Customs",
      promptContext: "You are a strict customs officer at the airport. Ask the user about their trip purpose and luggage.",
      imageUrl: "https://images.unsplash.com/photo-1549897411-b06572cdf806?q=80&w=1074&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
      ambiencePath: "sounds/airport-ambience.mp3",
    ),

    // Kıyafet Alışverişi
    Scenario(
      name: "Clothing Store",
      promptContext: "You are a helpful shop assistant. The user is looking for clothes. Advise them on size and color.",
      imageUrl: "https://images.unsplash.com/photo-1441986300917-64674bd600d8?auto=format&fit=crop&q=80&w=1000",
      ambiencePath: "sounds/shopping-ambiance.mp3",
    ),

    // Taksi Yolculuğu
    Scenario(
      name: "Taxi Ride",
      promptContext: "You are a talkative taxi driver. Ask the user where they want to go and make small talk about the city.",
      imageUrl: "https://images.unsplash.com/photo-1490650404312-a2175773bbf5?auto=format&fit=crop&q=80&w=1000",
      ambiencePath: "sounds/city-ambience.mp3",
    ),

    // Ev Kiralama
    Scenario(
      name: "Real Estate",
      promptContext: "You are a real estate agent showing an apartment. The user is a potential tenant asking questions.",
      imageUrl: "https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?auto=format&fit=crop&q=80&w=1000",
      ambiencePath: "sounds/office-ambience-6322.mp3",
    ),

    // Teknik Destek (IT)
    Scenario(
      name: "Tech Support",
      promptContext: "You are an IT support specialist. The user has a problem with their computer. Try to solve it step by step.",
      imageUrl: "https://images.unsplash.com/photo-1531482615713-2afd69097998?auto=format&fit=crop&q=80&w=1000",
      ambiencePath: "sounds/laptop-keyboard.mp3",
    ),

    // Restoranda Şikayet
    Scenario(
      name: "Restaurant Issue",
      promptContext: "You are a restaurant manager. The user is complaining about cold food. Handle the situation politely.",
      imageUrl: "https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?auto=format&fit=crop&q=80&w=1000",
      ambiencePath: "sounds/cofee-ambience.mp3",
    ),

    // Kütüphane
    Scenario(
      name: "Library",
      promptContext: "You are a librarian. The user is looking for a specific book or asking about library rules.",
      imageUrl: "https://images.unsplash.com/photo-1521587760476-6c12a4b040da?auto=format&fit=crop&q=80&w=1000",
      ambiencePath: "sounds/library-ambience.mp3",
    ),

    // Spor Salonu Kaydı
    Scenario(
      name: "Gym Membership",
      promptContext: "You are a gym trainer. The user wants to sign up for a membership. Explain the plans and facilities.",
      imageUrl: "https://images.unsplash.com/photo-1534438327276-14e5300c3a48?auto=format&fit=crop&q=80&w=1000",
      ambiencePath: "sounds/gym-ambience.mp3",
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _appLanguage = prefs.getString('appLanguage') ?? 'Türkçe';
      _targetLanguage = prefs.getString('targetLanguage') ?? 'English';
      _level = prefs.getString('level') ?? 'A1 (Beginner)';
      _duration = prefs.getInt('duration') ?? 5;
    });
  }

  void _openSettings() async {
    final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SettingsScreen(currentAppLang: _appLanguage))
    );
    if (result == true) {
      _loadPrefs();
    }
  }

  void _startRandomScenario() {
    final random = Random();
    final selectedScenario = _scenarios[random.nextInt(_scenarios.length)];

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          level: _level,
          targetLanguage: _targetLanguage, // Hedef dil LLM'e gidiyor
          appLanguage: _appLanguage,       // Uygulama dili Chat arayüzüne gidiyor
          sessionDurationMinutes: _duration,
          scenario: selectedScenario,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isTr = _appLanguage == 'Türkçe';

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text("Role Play Speak"),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _openSettings,
          )
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Bilgi Kartı
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.deepPurple.shade100),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _infoBadge(Icons.translate, _targetLanguage, "Target"),
                    _infoBadge(Icons.bar_chart, _level, "Level"),
                    _infoBadge(Icons.timer, "$_duration ${isTr ? 'dk' : 'min'}", "Time"),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // SAMİMİ BUTON TASARIMI
              GestureDetector(
                onTap: _startRandomScenario,
                child: Container(
                  height: 350,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6C63FF), Color(0xFF8B80F9)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(color: const Color(0xFF6C63FF).withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 10))
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                        child: const Icon(Icons.shuffle_rounded, size: 60, color: Colors.white),
                      ),
                      const SizedBox(height: 30),
                      // İSTEDİĞİN METİNLER BURADA
                      Text(
                        isTr ? "Rastgele Senaryo\nBaşlat" : "Start Random\nScenario",
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 15),
                      Text(
                        isTr ? "Sürpriz bir yere gitmeye hazır mısın?" : "Are you ready for a surprise journey?",
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoBadge(IconData icon, String text, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.deepPurple),
        const SizedBox(height: 4),
        Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}