import 'dart:typed_data';

enum ChatMessageType { text, location, image, voice }

class ChatMessage {
  final String id;
  final bool isMine;
  final DateTime createdAt;
  final ChatMessageType type;
  final String? text;
  final double? latitude;
  final double? longitude;
  final Uint8List? imageBytes;
  final String? audioPath;
  final Duration? audioDuration;

  const ChatMessage({
    required this.id,
    required this.isMine,
    required this.createdAt,
    required this.type,
    this.text,
    this.latitude,
    this.longitude,
    this.imageBytes,
    this.audioPath,
    this.audioDuration,
  });
}
