import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  final String currentAppLang;
  const SettingsScreen({super.key, required this.currentAppLang});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _appLanguage = 'Türkçe'; // Menü Dili
  String _targetLanguage = 'English'; // LLM Dili
  String _selectedLevel = 'A1 (Beginner)';
  int _sessionDuration = 5;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _appLanguage = prefs.getString('appLanguage') ?? 'Türkçe';
      _targetLanguage = prefs.getString('targetLanguage') ?? 'English';
      _selectedLevel = prefs.getString('level') ?? 'A1 (Beginner)';
      _sessionDuration = prefs.getInt('duration') ?? 5;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('appLanguage', _appLanguage);
    await prefs.setString('targetLanguage', _targetLanguage);
    await prefs.setString('level', _selectedLevel);
    await prefs.setInt('duration', _sessionDuration);

    if(mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_appLanguage == 'Türkçe' ? "Ayarlar Kaydedildi! ✅" : "Settings Saved! ✅"))
      );
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Basit Çeviri Mantığı
    final isTr = _appLanguage == 'Türkçe';

    return Scaffold(
      appBar: AppBar(title: Text(isTr ? "Ayarlar" : "Settings")),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(isTr ? "Uygulama Ayarları" : "App Settings", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF6C63FF))),
          const SizedBox(height: 20),

          // 1. UYGULAMA DİLİ (Menüler)
          _buildDropdown(
            label: isTr ? "Uygulama Dili (Menüler)" : "App Language (Menus)",
            value: _appLanguage,
            items: ['Türkçe', 'English'],
            onChanged: (val) => setState(() => _appLanguage = val!),
            icon: Icons.settings_applications,
          ),

          const Divider(),
          const SizedBox(height: 10),

          Text(isTr ? "Öğrenim Ayarları" : "Learning Settings", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF6C63FF))),
          const SizedBox(height: 20),

          // 2. HEDEF DİL (LLM'in konuşacağı dil)
          _buildDropdown(
            label: isTr ? "Öğrenilecek Dil (Hedef)" : "Target Language",
            value: _targetLanguage,
            items: ['English', 'German', 'French', 'Spanish', 'Turkish', 'Italian'],
            onChanged: (val) => setState(() => _targetLanguage = val!),
            icon: Icons.language,
          ),

          // 3. SEVİYE
          _buildDropdown(
            label: isTr ? "Seviyeniz" : "Your Level",
            value: _selectedLevel,
            items: ['A1 (Beginner)', 'A2', 'B1', 'B2', 'C1', 'C2'],
            onChanged: (val) => setState(() => _selectedLevel = val!),
            icon: Icons.bar_chart,
          ),

          // 4. SÜRE
          _buildDropdown(
            label: isTr ? "Seans Süresi (Dk)" : "Session Duration (Min)",
            value: _sessionDuration,
            items: [1, 3, 5, 10, 15],
            onChanged: (val) => setState(() => _sessionDuration = val!),
            icon: Icons.timer,
          ),

          const SizedBox(height: 40),

          ElevatedButton.icon(
            onPressed: _saveSettings,
            icon: const Icon(Icons.save),
            label: Text(isTr ? "KAYDET VE ÇIK" : "SAVE & EXIT"),
            style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
          )
        ],
      ),
    );
  }

  Widget _buildDropdown<T>({required String label, required T value, required List<T> items, required Function(T?) onChanged, required IconData icon}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: DropdownButtonFormField<T>(
        value: value,
        items: items.map((item) => DropdownMenuItem(value: item, child: Text(item.toString()))).toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: const Color(0xFF6C63FF)),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.grey.shade100,
        ),
      ),
    );
  }
}