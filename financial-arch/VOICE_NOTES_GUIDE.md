# Voice Notes Feature - Implementation Guide

## Overview

The Financial Architect app now includes a **Voice-to-Text Note Input** feature that allows users to record transaction notes using their device's microphone. This feature is available in both the **Income** and **Expense** tabs.

## 🎯 Features

### 1. **Dual Input Methods**
- **Manual Input**: Traditional text typing via keyboard
- **Voice Input**: Speak notes and automatically transcribe them to text

### 2. **Real-Time Recognition**
- Live transcription as you speak
- Confidence level indicator (0-100%)
- Automatic appending of recognized text to existing notes

### 3. **User-Friendly Interface**
- Clear recording indicator with red border and mic icon
- Visual feedback showing recognized text in real-time
- Error messages with helpful guidance
- Confidence level progress bar

## 📱 User Guide

### How to Add a Voice Note

#### **Step 1: Navigate to Income or Expense Tab**
```
Home Screen → Transaction Form (INCOME or EXPENSE tab)
```

#### **Step 2: Fill in Transaction Details**
- Select type (Income/Expense)
- Enter amount
- Select category

#### **Step 3: Add Voice Note**
1. Tap the **"Add Voice Note"** button in the Details section
2. The app will request microphone permission (first time only)
3. Grant permission to proceed

#### **Step 4: Speak Your Note**
1. Once permission is granted, the recording interface will appear
2. The app displays:
   - Recording indicator with animated mic icon
   - Real-time transcription of your speech
   - Confidence level (0-100%)
3. Speak clearly into your device's microphone

#### **Step 5: Confirm or Cancel**
- **Done**: Finalize the voice note and add it to the text field
- **Cancel**: Discard the recording and return to normal input

#### **Step 6: Submit Transaction**
- Review the combined text and voice note
- Tap **"Record Expense/Income"** to submit

## 🛠 Technical Implementation

### Components

#### 1. **VoiceService** (`lib/services/voice_service.dart`)
Core service managing speech-to-text operations.

**Key Features:**
- Initializes speech recognition engine
- Manages microphone permissions
- Handles real-time transcription
- Provides error handling
- Manages listener lifecycle

**Methods:**
```dart
Future<bool> initialize()                    // Initialize voice service
Future<bool> requestMicrophonePermission()   // Request mic permission
Future<void> startListening({String localeId})  // Start recording
Future<void> stopListening()                 // Stop and return text
Future<void> cancelListening()               // Cancel without saving
String getAndClearRecognizedText()           // Retrieve and clear text
```

**Properties:**
```dart
String recognizedText              // Current transcription
bool isListening                   // Is currently recording?
bool isAvailable                   // Voice service available?
String? error                      // Error message if any
double confidenceLevel             // 0.0 to 1.0
```

#### 2. **VoiceNoteInput Widget** (`lib/widgets/voice_note_input.dart`)
Reusable UI component for voice input with optional manual text input.

**Features:**
- Integrated text input field
- One-tap voice recording
- Real-time status display
- Error handling UI
- Confidence indicator

**Properties:**
```dart
TextEditingController noteController  // Controller for text field
String? label                         // Field label
String? hint                          // Placeholder text
VoidCallback? onNoteAdded            // Callback when note added
bool autoFocus                        // Auto-focus text field
```

#### 3. **Updated Home Screen** (`lib/screens/home_screen.dart`)
Integrated VoiceNoteInput into the transaction form.

**Changes:**
- Replaced standard text field with `VoiceNoteInput`
- Removed separate mic button (now part of VoiceNoteInput)
- Maintained existing functionality

### Dependencies

Added to `pubspec.yaml`:
```yaml
# Voice to Text & Audio
speech_to_text: ^7.0.0
permission_handler: ^11.4.4
```

### Database Schema

The existing `TransactionModel` already supports voice notes:
```dart
class TransactionModel {
  // ... other fields
  final String? note;           // Text notes
  final String? voiceNotePath;  // Path to voice file (for future)
}
```

## 🔧 Configuration

### Platform-Specific Setup

#### **Android** (`android/app/build.gradle.kts`)
Permissions are automatically handled by permission_handler.

Required permissions added to `AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.INTERNET" />
```

#### **iOS** (`ios/Runner/Info.plist`)
Required keys:
```xml
<key>NSMicrophoneUsageDescription</key>
<string>This app needs microphone access to record voice notes for transactions.</string>
<key>NSSpeechRecognitionUsageDescription</key>
<string>This app uses speech recognition to transcribe voice notes.</string>
```

## 📊 User Flow Diagram

```
Start Transaction Entry
    ↓
Fill Amount & Category
    ↓
Add Notes (2 options):
    ├─ Manual: Type directly in text field
    └─ Voice: Tap "Add Voice Note" button
        ├─ Request Permission (first time)
        ├─ Start Recording
        ├─ Display Real-time Text
        ├─ Show Confidence Level
        └─ Confirm or Cancel
            ├─ Confirm → Append to text field
            └─ Cancel → Discard recording
    ↓
Submit Transaction
    ↓
Transaction Recorded
```

## 🎤 Voice Input Workflow

```
┌─────────────────────────────────────────────┐
│  "Add Voice Note" Button                    │
└────────────┬────────────────────────────────┘
             ↓
┌─────────────────────────────────────────────┐
│  Request Microphone Permission              │
│  (Shown only on first use)                  │
└────────────┬────────────────────────────────┘
             ↓
┌─────────────────────────────────────────────┐
│  Recording Interface Appears                │
│  - Red border & mic icon                    │
│  - "Recording..." indicator                 │
│  - Real-time text display                   │
│  - Confidence level bar                     │
└────────────┬────────────────────────────────┘
             ↓
        User Speaks
             ↓
    Speech Recognized
             ↓
┌─────────────────────────────────────────────┐
│  Text Displayed & Updated                   │
│  Confidence shown as progress bar            │
└────────────┬────────────────────────────────┘
             ↓
┌─────────────────────────────────────────────┐
│  User Taps "Done" or "Cancel"               │
└────────────┬────────────────────────────────┘
             ↓
        Done: Add text      Cancel: Discard
             ↓                      ↓
      Return to Form      Return to Form
      (with text)         (unchanged)
             ↓                      ↓
      Continue with            Continue with
      transaction entry        transaction entry
```

## 🧪 Testing

### Manual Testing Checklist

- [ ] Microphone permission request works
- [ ] Voice recording starts on button tap
- [ ] Real-time text appears while speaking
- [ ] Confidence level updates
- [ ] "Done" button appends text to field
- [ ] "Cancel" button discards without changes
- [ ] Error messages display correctly
- [ ] Works in both Income and Expense tabs
- [ ] Works on different Android/iOS versions
- [ ] Handles no microphone gracefully

### Test Scenarios

1. **First-Time User**
   - Launch app → Enter transaction → Tap voice button
   - Should show permission request

2. **Normal Recording**
   - Speak clearly → See real-time text → Tap Done
   - Text should appear in note field

3. **Low Confidence**
   - Speak unclearly or with noise
   - Confidence bar should show low percentage

4. **Error Handling**
   - Deny microphone permission
   - Should show error message
   - Button should remain available for retry

5. **Multiple Notes**
   - Add voice note once → Add again
   - Second note should append to first

## 🐛 Troubleshooting

### Issue: "Microphone permission denied"
**Solution**: 
- Go to Settings → Apps → Financial Architect → Permissions → Microphone
- Enable microphone permission

### Issue: "Voice recognition not available"
**Solution**:
- Requires Android 5.0+ or iOS 10+
- Check device has internet connection (for cloud-based recognition)
- Restart the app

### Issue: "Recognition is slow or inaccurate"
**Solution**:
- Speak clearly and at normal pace
- Reduce background noise
- Try different language setting if available
- Check device microphone is clean

### Issue: "No text appears while recording"
**Solution**:
- Check microphone is not blocked
- Ensure app has microphone permission
- Try recording again
- Restart the app if issue persists

## 🚀 Advanced Usage

### Changing Locale/Language

The service supports different locales. To change language:

```dart
// In VoiceNoteInput widget, modify startListening call:
await _voiceService.startListening(
  localeId: 'ar_EG',  // Arabic (Egypt)
  // Other options:
  // 'en_US' - English (US)
  // 'fr_FR' - French (France)
  // 'es_ES' - Spanish (Spain)
  // etc.
);
```

### Integrating with History/Analytics

Voice notes are stored as regular text, so they appear in:
- Transaction history
- Analytics reports
- Export/Backup features

### Future Enhancements

1. **Voice File Storage**: Save actual audio files
2. **Speech Synthesis**: Read notes aloud
3. **Multi-language Support**: Voice input in multiple languages
4. **Voice Commands**: Commands like "add expense" or "show balance"
5. **Cloud Sync**: Sync voice notes across devices
6. **Voice Search**: Search transactions by spoken keywords

## 📝 Code Examples

### Basic Usage in Widget

```dart
VoiceNoteInput(
  noteController: _noteController,
  label: 'Transaction Notes',
  hint: 'Tap mic or type your notes...',
  onNoteAdded: () {
    print('Note added: ${_noteController.text}');
  },
)
```

### Using VoiceService Directly

```dart
final voiceService = VoiceService();

// Initialize
await voiceService.initialize();

// Request permission
await voiceService.requestMicrophonePermission();

// Start recording
await voiceService.startListening(localeId: 'en_US');

// In your listener:
voiceService.addListener(() {
  print('Recognized: ${voiceService.recognizedText}');
  print('Confidence: ${(voiceService.confidenceLevel * 100).toInt()}%');
});

// Stop recording
await voiceService.stopListening();
final text = voiceService.getAndClearRecognizedText();

// Cleanup
voiceService.dispose();
```

## 📖 References

- [speech_to_text package](https://pub.dev/packages/speech_to_text)
- [permission_handler package](https://pub.dev/packages/permission_handler)
- [Flutter Audio Documentation](https://flutter.dev/docs/cookbook/plugins/using-platform-channels)

## 🤝 Support

For issues or feature requests, contact the development team or file a bug report with:
- Device model and OS version
- Steps to reproduce
- Error messages (if any)
- Device language and locale settings
