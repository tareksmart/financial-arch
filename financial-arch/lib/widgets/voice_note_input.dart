import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/voice_service.dart';
import '../theme/index.dart';

/// Reusable voice input widget for recording notes
class VoiceNoteInput extends StatefulWidget {
  final TextEditingController noteController;
  final String? label;
  final String? hint;
  final VoidCallback? onNoteAdded;
  final bool autoFocus;

  const VoiceNoteInput({
    Key? key,
    required this.noteController,
    this.label,
    this.hint,
    this.onNoteAdded,
    this.autoFocus = false,
  }) : super(key: key);

  @override
  State<VoiceNoteInput> createState() => _VoiceNoteInputState();
}

class _VoiceNoteInputState extends State<VoiceNoteInput> {
  bool _voiceInputMode = false;
  late VoiceService _voiceService;
  bool _permissionGranted = false;

  @override
  void initState() {
    super.initState();
    _initializeVoiceService();
  }

  Future<void> _initializeVoiceService() async {
    _voiceService = VoiceService();
    final initialized = await _voiceService.initialize();
    if (initialized) {
      _permissionGranted = await _voiceService.requestMicrophonePermission();
      if (mounted) {
        setState(() {});
      }
    }
  }

  Future<void> _startVoiceInput() async {
    if (!_permissionGranted) {
      _permissionGranted = await _voiceService.requestMicrophonePermission();
      if (!_permissionGranted) return;
    }

    setState(() => _voiceInputMode = true);
    await _voiceService.startListening();
  }

  Future<void> _stopVoiceInput() async {
    await _voiceService.stopListening();

    final recognizedText = _voiceService.getAndClearRecognizedText();

    if (recognizedText.isNotEmpty) {
      final currentText = widget.noteController.text;
      widget.noteController.text =
          currentText.isEmpty ? recognizedText : '$currentText $recognizedText';

      widget.onNoteAdded?.call();
    }

    if (mounted) {
      setState(() => _voiceInputMode = false);
    }
  }

  Future<void> _cancelVoiceInput() async {
    await _voiceService.cancelListening();
    if (mounted) {
      setState(() => _voiceInputMode = false);
    }
  }

  @override
  void dispose() {
    _voiceService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              widget.label!,
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ),

        // Note input field
        TextFormField(
          controller: widget.noteController,
          autofocus: widget.autoFocus,
          maxLines: 3,
          minLines: 2,
          decoration: InputDecoration(
            hintText: widget.hint ?? 'Enter or speak a note...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            contentPadding: const EdgeInsets.all(12),
            suffixIcon: widget.noteController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      widget.noteController.clear();
                      setState(() {});
                    },
                  )
                : null,
          ),
          onChanged: (_) => setState(() {}),
        ),

        const SizedBox(height: 8),

        // Voice input controls
        if (!_voiceInputMode)
          _buildVoiceInputButton(context)
        else
          _buildVoiceListeningUI(context),
      ],
    );
  }

  Widget _buildVoiceInputButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton.icon(
        onPressed: _permissionGranted ? _startVoiceInput : null,
        icon: const Icon(Icons.mic),
        label: const Text('Add Voice Note'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildVoiceListeningUI(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _voiceService,
      child: Consumer<VoiceService>(
        builder: (context, voiceService, _) {
          return Column(
            children: [
              // Recording indicator
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red, width: 2),
                ),
                child: Column(
                  children: [
                    // Animated recording indicator
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.mic,
                          color: Colors.red,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Recording...',
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Recognized text display
                    if (voiceService.recognizedText.isNotEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.grey.shade300,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Recognized:',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              voiceService.recognizedText,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),

                    if (voiceService.recognizedText.isNotEmpty)
                      const SizedBox(height: 12),

                    // Confidence indicator
                    if (voiceService.confidenceLevel > 0)
                      Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Confidence:',
                                style: TextStyle(fontSize: 12),
                              ),
                              Text(
                                '${(voiceService.confidenceLevel * 100).toStringAsFixed(0)}%',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: voiceService.confidenceLevel > 0.7
                                      ? Colors.green
                                      : Colors.orange,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          LinearProgressIndicator(
                            value: voiceService.confidenceLevel,
                            backgroundColor: Colors.grey.shade300,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              voiceService.confidenceLevel > 0.7
                                  ? Colors.green
                                  : Colors.orange,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Error message if any
              if (voiceService.error != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning, color: Colors.orange),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          voiceService.error!,
                          style: const TextStyle(
                            color: Colors.orange,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 12),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _cancelVoiceInput,
                      icon: const Icon(Icons.close),
                      label: const Text('Cancel'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _stopVoiceInput,
                      icon: const Icon(Icons.check),
                      label: const Text('Done'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
