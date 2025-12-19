# Role Play Speak
Role Play Speak is an immersive language learning application built with Flutter. It leverages advanced Large Language Models (LLM) via the Groq API (Llama 3) to simulate real-world conversation scenarios. The application allows users to practice speaking and writing in a target language by interacting with AI characters in specific contexts, such as ordering at a cafe, dealing with a police inquiry, or attending a job interview.

The app focuses on immersion through visual backdrops and ambient audio, while providing educational value through real-time feedback, grammar analysis, and performance scoring.

## Features
Immersive Roleplay Scenarios: Users can choose from various real-life scenarios (e.g., Paris Cafe, Doctor's Visit, Airport Customs). Each scenario includes a specific visual background and looping ambient audio to enhance immersion.

AI-Powered Interaction: Utilizes the Groq API (Llama 3 model) for ultra-fast, context-aware conversational responses. The AI adopts specific personas based on the chosen scenario.

- Voice Integration:
-- Speech-to-Text: Users can speak directly to the app using the microphone.
-- Text-to-Speech: The AI responses are read aloud to help users with pronunciation and listening comprehension.
- Performance Analysis: A dedicated "Teacher Mode" analyzes the conversation upon completion. It provides a score (out of 100), highlights grammatical errors, offers corrections, and suggests better phrasing.
- Dual Language Support:
- Interface Language: Supports English and Turkish for app menus.
- Target Language: Users can practice English, German, French, Spanish, Turkish, or Italian.
- Customizable Experience: Users can set their proficiency level (A1 to C2) and session duration. Settings are persisted locally using Shared Preferences.
- Modern UI: Features a clean, professional interface with blur effects (glassmorphism), custom fonts (Poppins & Kalam), and smooth transitions.

## Tech Stack
- Framework: Flutter (Dart)
- AI Provider: Groq API (Llama 3-8b-8192)
- State Management: setState (Local state management)
- Networking: http package
- Audio & Voice: speech_to_text, flutter_tts, audioplayers
- UI Components: dash_chat_2, flutter_markdown, google_fonts
- Local Storage: shared_preferences
- Environment Management: flutter_dotenv

## Installation and Setup
Follow these steps to run the project locally.

## 1. Prerequisites
- Flutter SDK installed on your machine.
- Android Studio or VS Code configured for Flutter development.
- An API Key from Groq Cloud.

## 2. Clone the Repository
```bash
git clone https://github.com/GulceYurtseven/RolePlaySpeak.git
cd role-play-speak
```

## 3. Install Dependencies
```bash
flutter pub get
```
## 4. Environment Configuration
- This project uses flutter_dotenv to manage sensitive API keys. You must create a local environment file.
- Create a file named .env in the root directory of the project (at the same level as pubspec.yaml).
- Add your Groq API key to this file:

## 5. Android Permissions
- Ensure your Android Manifest includes the necessary permissions for internet and audio recording. These are already configured in android/app/src/main/AndroidManifest.xml:

```bash
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.RECORD_AUDIO"/>
```

## 6. Run the Application
```bash
flutter run
Project Structure
```
The project follows a clean architecture approach, separating logic, models, and UI views.
```bash
lib/
├── models/
│   └── scenario.dart       # Data model for roleplay scenarios
├── screens/
│   ├── home_screen.dart    # Main dashboard for scenario selection
│   ├── chat_screen.dart    # Core logic: Chat interface, AI integration, Audio
│   ├── analysis_screen.dart# Performance review and feedback display
│   └── settings_screen.dart# User preferences (Language, Level, Time)
└── main.dart               # Entry point, Theme configuration, Env loading

```
## Usage
- Settings: Upon first launch, navigate to settings to define your native language, target language, and proficiency level.
- Select Scenario: Choose a scenario from the home screen (e.g., "Paris Cafe").
- Start Roleplay: Click the "Start" button to initialize the AI and ambient sound.
- Interact: Type or speak to interact with the AI character. A timer will track the session duration.
- Finish & Analyze: Click the "Finish" button or wait for the timer to expire. The app will generate a detailed analysis of your performance.
