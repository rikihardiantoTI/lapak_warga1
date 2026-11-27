import 'dart:async';
import 'dart:math' as math;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/chat_message.dart';

class ChatMessageBubble extends StatelessWidget {
  final ChatMessage message;
  final ValueChanged<ChatMessage> onOpenLocation;

  const ChatMessageBubble({
    super.key,
    required this.message,
    required this.onOpenLocation,
  });

  @override
  Widget build(BuildContext context) {
    final isMine = message.isMine;
    final maxWidth = math.min(MediaQuery.sizeOf(context).width * 0.82, 420.0);

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 5),
          decoration: BoxDecoration(
            color: isMine ? null : Colors.white,
            gradient: isMine
                ? const LinearGradient(
                    colors: [Color(0xFF11998E), Color(0xFF087F76)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            border: isMine ? null : Border.all(color: const Color(0xFFE6ECEA)),
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(20),
              topRight: const Radius.circular(20),
              bottomLeft: Radius.circular(isMine ? 20 : 6),
              bottomRight: Radius.circular(isMine ? 6 : 20),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF173B38).withValues(alpha: 0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(13, 12, 13, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _messageContent(context),
              const SizedBox(height: 6),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _formatTime(message.createdAt),
                    style: TextStyle(
                      color: isMine ? Colors.white70 : Colors.blueGrey.shade400,
                      fontSize: 10,
                    ),
                  ),
                  if (isMine) ...[
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.done_all_rounded,
                      color: Color(0xFFB5FFF3),
                      size: 14,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _messageContent(BuildContext context) {
    switch (message.type) {
      case ChatMessageType.text:
        return Text(
          message.text ?? '',
          style: TextStyle(
            color: message.isMine ? Colors.white : const Color(0xFF243634),
            fontSize: 14,
            height: 1.4,
          ),
        );
      case ChatMessageType.location:
        return _LocationMessage(message: message, onTap: onOpenLocation);
      case ChatMessageType.image:
        final bytes = message.imageBytes;
        if (bytes == null) {
          return const Text('Foto tidak tersedia.');
        }
        return ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Image.memory(
            bytes,
            width: math.min(MediaQuery.sizeOf(context).width * 0.68, 340.0),
            height: 210,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => Container(
              width: 240,
              height: 150,
              color: const Color(0xFFE8F4F0),
              alignment: Alignment.center,
              child: const Icon(Icons.broken_image_outlined, size: 32),
            ),
          ),
        );
      case ChatMessageType.voice:
        final path = message.audioPath;
        if (path == null) {
          return const Text('Voice note tidak tersedia.');
        }
        return _VoiceNotePlayer(
          path: path,
          duration: message.audioDuration ?? Duration.zero,
          isMine: message.isMine,
        );
    }
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:'
        '${time.minute.toString().padLeft(2, '0')}';
  }
}

class _LocationMessage extends StatelessWidget {
  final ChatMessage message;
  final ValueChanged<ChatMessage> onTap;

  const _LocationMessage({required this.message, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final latitude = message.latitude;
    final longitude = message.longitude;
    if (latitude == null || longitude == null) {
      return const Text('Lokasi tidak tersedia.');
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onTap(message),
        borderRadius: BorderRadius.circular(15),
        child: Container(
          width: math.min(MediaQuery.sizeOf(context).width * 0.68, 340.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 98,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFFD8EEE8), Color(0xFFB8DBD2)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ),
                    Positioned(
                      left: 18,
                      top: 16,
                      child: _mapBlock(width: 68, height: 21, angle: -0.16),
                    ),
                    Positioned(
                      right: 12,
                      top: 28,
                      child: _mapBlock(width: 83, height: 18, angle: 0.12),
                    ),
                    Positioned(
                      left: 80,
                      bottom: 13,
                      child: _mapBlock(width: 104, height: 17, angle: -0.1),
                    ),
                    const Center(
                      child: Icon(
                        Icons.location_pin,
                        color: Color(0xFFE3564A),
                        size: 42,
                        shadows: [Shadow(color: Colors.white, blurRadius: 8)],
                      ),
                    ),
                    Positioned(
                      right: 9,
                      bottom: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'PETA',
                          style: TextStyle(
                            color: Color(0xFF0F766E),
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.7,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 11),
                child: Row(
                  children: [
                    const Icon(
                      Icons.place_rounded,
                      color: Color(0xFFE3564A),
                      size: 19,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Lokasi saya',
                            style: TextStyle(
                              color: Color(0xFF243634),
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${latitude.toStringAsFixed(5)}, ${longitude.toStringAsFixed(5)}',
                            style: const TextStyle(
                              color: Color(0xFF71827F),
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.open_in_new_rounded,
                      color: Color(0xFF0F766E),
                      size: 16,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _mapBlock({
    required double width,
    required double height,
    required double angle,
  }) {
    return Transform.rotate(
      angle: angle,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.47),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}

class _VoiceNotePlayer extends StatefulWidget {
  final String path;
  final Duration duration;
  final bool isMine;

  const _VoiceNotePlayer({
    required this.path,
    required this.duration,
    required this.isMine,
  });

  @override
  State<_VoiceNotePlayer> createState() => _VoiceNotePlayerState();
}

class _VoiceNotePlayerState extends State<_VoiceNotePlayer> {
  final AudioPlayer _player = AudioPlayer();
  late final StreamSubscription<PlayerState> _stateSubscription;
  late final StreamSubscription<void> _completeSubscription;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _stateSubscription = _player.onPlayerStateChanged.listen((state) {
      if (mounted) setState(() => _isPlaying = state == PlayerState.playing);
    });
    _completeSubscription = _player.onPlayerComplete.listen((_) {
      if (mounted) setState(() => _isPlaying = false);
    });
  }

  @override
  void dispose() {
    unawaited(_stateSubscription.cancel());
    unawaited(_completeSubscription.cancel());
    unawaited(_player.dispose());
    super.dispose();
  }

  Future<void> _togglePlayback() async {
    try {
      if (_isPlaying) {
        await _player.pause();
        return;
      }

      final source = kIsWeb
          ? UrlSource(widget.path)
          : DeviceFileSource(widget.path);
      await _player.play(source);
    } on PlatformException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Voice note tidak dapat diputar.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final foreground = widget.isMine ? Colors.white : const Color(0xFF0F766E);
    final muted = widget.isMine ? Colors.white70 : Colors.blueGrey.shade500;

    return SizedBox(
      width: 230,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: _isPlaying ? 'Jeda voice note' : 'Putar voice note',
            onPressed: _togglePlayback,
            style: IconButton.styleFrom(
              backgroundColor: widget.isMine
                  ? Colors.white.withValues(alpha: 0.18)
                  : const Color(0xFFE8F4F0),
              foregroundColor: foreground,
              minimumSize: const Size(38, 38),
              padding: EdgeInsets.zero,
            ),
            icon: Icon(
              _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
              size: 23,
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: List.generate(23, (index) {
                    final height = 7 + ((index * 17) % 13).toDouble();
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 1),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          height: _isPlaying && index % 3 == 0
                              ? height + 5
                              : height,
                          decoration: BoxDecoration(
                            color: foreground.withValues(
                              alpha: _isPlaying || index < 5 ? 0.95 : 0.55,
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 5),
                Text(
                  'Pesan suara · ${_formatDuration(widget.duration)}',
                  style: TextStyle(color: muted, fontSize: 10),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
