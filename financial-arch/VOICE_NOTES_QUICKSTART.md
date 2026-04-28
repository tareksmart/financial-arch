# Voice Notes Feature - Quick Start for Developers

## ⚡ 5-Minute Setup Guide

### Step 1: Install Dependencies
```bash
cd financial-arch
flutter pub get
```

### Step 2: Platform-Specific Configuration

#### Android Setup (Already Done)
The `AndroidManifest.xml` already has the required permissions. No additional setup needed.

#### iOS Setup (Manual Steps)
Add to `ios/Runner/Info.plist`:

```xml
<dict>
    ...existing content...
    <key>NSMicrophoneUsageDescription</key>
    <string>This app needs microphone access to record voice notes for transactions.</string>
    <key>NSSpeechRecognitionUsageDescription</key>
    <string>This app uses speech recognition to transcribe voice notes.</string>
</dict>
```

### Step 3: Run the App
```bash
flutter clean
flutter pub get
flutter run
```

## 🎯 How to Use Voice Notes

### In the App
1. Go to Home Screen
2. Select **Income** or **Expense** tab
3. Fill in Amount and Category
4. In the "Details (Optional)" section, click **"Add Voice Note"**
5. Grant microphone permission (first time only)
6. Speak your note
7. Click **"Done"** to add the text, or **"Cancel"** to discard
8. Click **"Record Expense/Income"** to save the transaction

## 📁 File Structure

```
lib/
├── services/
│   ├── voice_service.dart          ← Core voice service
│   └── index.dart                  ← Service exports
├── widgets/
│   ├── voice_note_input.dart       ← UI component
│   └── index.dart                  ← Widget exports
└── screens/
    └── home_screen.dart            ← Updated with voice input
```

## 🔌 Integration Points

### 1. HomeScreen
```dart
// Voice input is now integrated in the transaction form
VoiceNoteInput(
  noteController: _noteController,
  label: 'Details (Optional)',
  hint: 'Tap mic or type your notes...',
)
```

### 2. TransactionModel
```dart
class TransactionModel {
  // ... existing fields
  final String? note;           // Stores voice-to-text results
  final String? voiceNotePath;  // For future: store audio files
}
```

## 🧪 Testing Checklist

### Quick Test
```bash
# 1. Launch app
flutter run

# 2. Go to Home Screen
# 3. Enter an expense
# 4. Click "Add Voice Note"
# 5. Speak: "Lunch with client"
# 6. Should appear in the note field

✓ Text appears in the note field
✓ "Done" button works
✓ Mic button disappears after selecting text
```

### Permission Test
```bash
# 1. Grant permission on first run
# 2. Repeat voice input (should not request permission again)
✓ Permission persists between app sessions
```

### Error Handling Test
```bash
# 1. Deny microphone permission
# 2. Try to use voice input
✓ Shows error message
✓ Offers retry or manual input
```

## 🐛 Common Issues & Solutions

### Issue: "Module speech_to_text not found"
```bash
# Solution: Reinstall dependencies
flutter clean
flutter pub get
flutter pub global activate flutter_gen
```

### Issue: Permissions not working on iOS
```bash
# Solution: Update iOS minimum version
# In ios/Podfile, ensure:
platform :ios, '11.0'
```

### Issue: "Speech recognition not available"
```
# Ensure:
- Device has internet (for cloud recognition)
- Android 5.0+ or iOS 10+
- Microphone is accessible
```

### Issue: App crashes when tapping voice button
```bash
# Solution: Ensure VoiceService is properly initialized
# Check that voice_service.dart has all required imports
```

## 📊 Architecture Overview

```
┌─────────────────────────────────────┐
│  HomeScreen (UI)                    │
│  - Shows transaction form           │
│  - Includes VoiceNoteInput          │
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│  VoiceNoteInput (Widget)            │
│  - Text input field                 │
│  - Voice recording UI               │
│  - Status display                   │
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│  VoiceService (Business Logic)      │
│  - Manages speech-to-text           │
│  - Handles permissions              │
│  - Processes recognition results    │
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│  speech_to_text Package             │
│  - Actual speech recognition        │
│  - Platform bridges (iOS/Android)   │
└─────────────────────────────────────┘
```

## 💡 Key Features Explained

### 1. Real-Time Recognition
```dart
// VoiceService listens to speech and updates in real-time
await _voiceService.startListening();
// onResult callback fires continuously with updates
```

### 2. Confidence Level
```dart
// Shows how confident the system is about the recognition (0-100%)
double confidence = voiceService.confidenceLevel;
// 0.7 (70%) or higher = good recognition
// 0.3-0.7 = fair recognition
// Below 0.3 = poor recognition
```

### 3. Text Appending
```dart
// If user adds multiple voice notes, they append
// "Note 1" + "Note 2" = "Note 1 Note 2"
```

## 🚀 What's Next?

### For Users
- Use voice notes to quickly document expenses
- Speak naturally - the system handles it
- Use manual typing for sensitive information

### For Developers
- Monitor speech recognition accuracy
- Plan for multi-language support
- Consider storing actual audio files
- Add voice commands for common actions

## 📱 Device Requirements

### Android
- Minimum API 21 (Android 5.0)
- Microphone hardware
- Internet connection (recommended)

### iOS
- Minimum iOS 11.0
- Microphone permission
- Internet connection (recommended)

## 🔐 Privacy & Permissions

### Permissions Requested
- **RECORD_AUDIO**: Required to capture voice
- **INTERNET**: Required for speech recognition

### User Privacy
- Voice data is processed locally (device-based recognition)
- No voice files stored by default
- User can deny permissions anytime
- Notes are stored as regular text in database

## 📞 Support

For issues:
1. Check [VOICE_NOTES_GUIDE.md](VOICE_NOTES_GUIDE.md) for detailed guide
2. Review troubleshooting section
3. Check Flutter console for error messages
4. Report issues with device info and reproduction steps

## 🎓 Learning Resources

- [speech_to_text documentation](https://pub.dev/documentation/speech_to_text/latest/)
- [permission_handler documentation](https://pub.dev/documentation/permission_handler/latest/)
- [Flutter plugins guide](https://flutter.dev/docs/development/packages-and-plugins/developing-packages)

---

**Last Updated**: April 28, 2026
**Version**: 1.0
**Status**: Production Ready ✅
