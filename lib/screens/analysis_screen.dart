import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';

class AnalysisScreen extends StatelessWidget {
  final String text;
  final String appLanguage; // Dil bilgisi
  const AnalysisScreen({super.key, required this.text, required this.appLanguage});

  @override
  Widget build(BuildContext context) {
    final isTr = appLanguage == 'Türkçe';

    return Scaffold(
      backgroundColor: const Color(0xFF2C2C2C),
      appBar: AppBar(
        title: Text(isTr ? "Performans Notları" : "Performance Notes"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFDF0),
            borderRadius: BorderRadius.circular(4),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 15)],
          ),
          child: Column(
            children: [
              Container(height: 2, width: 40, color: Colors.red.withOpacity(0.5), margin: const EdgeInsets.only(bottom: 20)),

              Expanded(
                child: SelectionArea(
                  child: Markdown(
                    data: text,
                    styleSheet: MarkdownStyleSheet(
                      p: GoogleFonts.kalam(fontSize: 18, color: const Color(0xFF1A237E), height: 1.5),
                      h1: GoogleFonts.kalam(fontSize: 28, fontWeight: FontWeight.bold, color: const Color(0xFFB71C1C)),
                      h2: GoogleFonts.kalam(fontSize: 24, fontWeight: FontWeight.bold, color: const Color(0xFFB71C1C)),
                      strong: GoogleFonts.kalam(fontWeight: FontWeight.bold, color: Colors.red),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Text(
                isTr ? "İpucu: Kopyalamak için metnin üzerine basılı tut." : "Tip: Long press text to copy.",
                style: const TextStyle(color: Colors.grey, fontSize: 12, fontStyle: FontStyle.italic),
              ),

              // ÇAKIŞMAYI ÖNLEMEK İÇİN EK BOŞLUK
              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        icon: const Icon(Icons.home_rounded),
        label: Text(isTr ? "Ana Menü" : "Main Menu"),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}