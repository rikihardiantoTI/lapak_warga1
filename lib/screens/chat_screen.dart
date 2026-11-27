import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/chat_message.dart';
import '../models/lapak_model.dart';
import '../widgets/chat_message_bubble.dart';

class ChatScreen extends StatefulWidget {
  final LapakItem lapak;

  const ChatScreen({super.key, required this.lapak});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  static const _emojis = [
    '😀',
    '😄',
    '😁',
    '😂',
    '🥰',
    '😍',
    '😎',
    '🤗',
    '😊',
    '🙂',
    '😉',
    '😅',
    '🤔',
    '🙏',
    '👍',
    '👎',
    '👏',
    '🙌',
    '💪',
    '🤝',
    '❤️',
    '💚',
    '✨',
    '🎉',
    '🔥',
    '✅',
    '📍',
    '🏡',
    '🍜',
    '☕',
    '🛵',
    '📦',
  ];

  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final AudioRecorder _recorder = AudioRecorder();
  final ImagePicker _imagePicker = ImagePicker();
  final List<ChatMessage> _messages = [
    ChatMessage(
      id: 'welcome',
      isMine: false,
      createdAt: DateTime.now(),
      type: ChatMessageType.text,
      text: 'Halo, Tetangga! Ada yang bisa dibantu? Silakan tanya ketersediaan atau bagikan lokasi Anda.',
    ),
  ];

  bool _showEmojiPicker = false;
  bool _isRecording = false;
  bool _isPreparingLocation = false;
  bool _isOpeningCamera = false;
  Duration _recordingDuration = Duration.zero;
  DateTime? _recordingStartedAt;
  Timer? _recordingTimer;

  @override
  void dispose() {
    _recordingTimer?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    unawaited(_recorder.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F8F6),
      appBar: _buildAppBar(),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(child: _buildMessageList()),
            if (_showEmojiPicker) _buildEmojiPicker(),
            _buildComposer(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      toolbarHeight: 72,
      foregroundColor: Colors.white,
      backgroundColor: const Color(0xFF0F766E),
      flexibleSpace: const DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF159A8D), Color(0xFF086B64)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      titleSpacing: 0,
      title: Row(
        children: [
          _ContactAvatar(name: widget.lapak.pemilik, size: 42),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.lapak.pemilik,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: widget.lapak.isBuka
                            ? const Color(0xFF9FF4C6)
                            : Colors.white54,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        widget.lapak.isBuka
                            ? 'Melayani · ${widget.lapak.judul}'
                            : 'Lapak sedang tutup · ${widget.lapak.judul}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          tooltip: 'Telepon ${widget.lapak.pemilik}',
          onPressed: _callOwner,
          icon: const Icon(Icons.call_rounded),
          style: IconButton.styleFrom(
            backgroundColor: Colors.white.withValues(alpha: 0.13),
            foregroundColor: Colors.white,
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildMessageList() {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFF7FAF8), Color(0xFFEFF7F4)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: ListView.builder(
        key: const Key('chat-message-list'),
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 22),
        itemCount: _messages.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) return const _DateDivider();
          return ChatMessageBubble(
            message: _messages[index - 1],
            onOpenLocation: _openLocation,
          );
        },
      ),
    );
  }

  Widget _buildComposer() {
    return Material(
      color: Colors.white,
      elevation: 10,
      shadowColor: const Color(0xFF173B38).withValues(alpha: 0.08),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_isRecording) _buildRecordingStatus(),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 10, 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  IconButton(
                    key: const Key('chat-camera-button'),
                    tooltip: 'Ambil foto',
                    onPressed: _isOpeningCamera ? null : _takePhoto,
                    icon: _isOpeningCamera
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.photo_camera_rounded),
                    color: const Color(0xFF0F766E),
                  ),
                  IconButton(
                    key: const Key('chat-location-button'),
                    tooltip: 'Kirim lokasi',
                    onPressed: _isPreparingLocation ? null : _shareLocation,
                    icon: _isPreparingLocation
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.location_on_rounded),
                    color: const Color(0xFFE15D52),
                  ),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2F6F5),
                        borderRadius: BorderRadius.circular(26),
                        border: Border.all(color: const Color(0xFFE3EBE8)),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            key: const Key('chat-emoji-button'),
                            tooltip: _showEmojiPicker
                                ? 'Tutup emoji'
                                : 'Tambah emoji',
                            onPressed: _toggleEmojiPicker,
                            visualDensity: VisualDensity.compact,
                            icon: Icon(
                              _showEmojiPicker
                                  ? Icons.keyboard_rounded
                                  : Icons.emoji_emotions_outlined,
                              color: const Color(0xFFAE7C2C),
                              size: 21,
                            ),
                          ),
                          Expanded(
                            child: TextField(
                              key: const Key('chat-message-input'),
                              controller: _messageController,
                              minLines: 1,
                              maxLines: 4,
                              textCapitalization: TextCapitalization.sentences,
                              textInputAction: TextInputAction.send,
                              onSubmitted: (_) => _sendMessage(),
                              onChanged: (_) => setState(() {}),
                              decoration: InputDecoration(
                                hintText: 'Tulis pesan...',
                                hintStyle: TextStyle(
                                  color: Colors.blueGrey.shade400,
                                  fontSize: 13,
                                ),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 2,
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                            tooltip: 'Lampiran lainnya',
                            onPressed: _showAttachmentOptions,
                            visualDensity: VisualDensity.compact,
                            icon: const Icon(
                              Icons.add_circle_outline_rounded,
                              color: Color(0xFF6B817D),
                              size: 21,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildSendOrRecordButton(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSendOrRecordButton() {
    final hasText = _messageController.text.trim().isNotEmpty;
    final isSend = hasText && !_isRecording;
    final icon = _isRecording
        ? Icons.stop_rounded
        : isSend
        ? Icons.send_rounded
        : Icons.mic_rounded;
    final tooltip = _isRecording
        ? 'Selesai dan kirim voice note'
        : isSend
        ? 'Kirim pesan'
        : 'Rekam voice note';

    return SizedBox(
      width: 46,
      height: 46,
      child: IconButton.filled(
        key: const Key('chat-send-or-record-button'),
        tooltip: tooltip,
        onPressed: _isRecording
            ? _stopVoiceNote
            : isSend
            ? _sendMessage
            : _startVoiceNote,
        style: IconButton.styleFrom(
          backgroundColor: _isRecording
              ? const Color(0xFFE3564A)
              : const Color(0xFF0F8A80),
          foregroundColor: Colors.white,
        ),
        icon: Icon(icon, size: 21),
      ),
    );
  }

  Widget _buildRecordingStatus() {
    return Container(
      width: double.infinity,
      color: const Color(0xFFFFF1EF),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
      child: Row(
        children: [
          const _PulsingRecordDot(),
          const SizedBox(width: 9),
          const Expanded(
            child: Text(
              'Merekam pesan suara',
              style: TextStyle(
                color: Color(0xFF9D3932),
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Text(
            _formatDuration(_recordingDuration),
            style: const TextStyle(
              color: Color(0xFF9D3932),
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
          IconButton(
            tooltip: 'Batalkan rekaman',
            onPressed: _cancelVoiceNote,
            visualDensity: VisualDensity.compact,
            icon: const Icon(
              Icons.delete_outline_rounded,
              color: Color(0xFF9D3932),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmojiPicker() {
    return Container(
      height: 164,
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE8EFED))),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Pilih emoji',
                  style: TextStyle(
                    color: Color(0xFF304541),
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Tutup emoji',
                onPressed: () => setState(() => _showEmojiPicker = false),
                icon: const Icon(Icons.close_rounded, size: 19),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          Expanded(
            child: GridView.builder(
              key: const Key('chat-emoji-picker'),
              itemCount: _emojis.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 8,
                mainAxisSpacing: 2,
                crossAxisSpacing: 2,
              ),
              itemBuilder: (context, index) => InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => _insertEmoji(_emojis[index]),
                child: Center(
                  child: Text(
                    _emojis[index],
                    style: const TextStyle(fontSize: 23),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isRecording) return;

    _messageController.clear();
    setState(() => _showEmojiPicker = false);
    _appendMessage(
      ChatMessage(
        id: _newMessageId(),
        isMine: true,
        createdAt: DateTime.now(),
        type: ChatMessageType.text,
        text: text,
      ),
    );
  }

  void _appendMessage(ChatMessage message) {
    if (!mounted) return;
    setState(() => _messages.add(message));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  void _insertEmoji(String emoji) {
    final value = _messageController.value;
    final selection = value.selection;
    final start = selection.isValid ? selection.start : value.text.length;
    final end = selection.isValid ? selection.end : value.text.length;
    final updatedText = value.text.replaceRange(start, end, emoji);

    _messageController.value = TextEditingValue(
      text: updatedText,
      selection: TextSelection.collapsed(offset: start + emoji.length),
    );
    setState(() {});
  }

  void _toggleEmojiPicker() {
    FocusScope.of(context).unfocus();
    setState(() => _showEmojiPicker = !_showEmojiPicker);
  }

  Future<void> _showAttachmentOptions() async {
    final action = await showModalBottomSheet<_AttachmentAction>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 2, 18, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Text(
                  'Kirim sesuatu',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
              ),
              _AttachmentTile(
                icon: Icons.photo_library_rounded,
                color: const Color(0xFF7C5CC4),
                title: 'Pilih dari galeri',
                subtitle: 'Bagikan foto dengan penjual',
                onTap: () => Navigator.pop(context, _AttachmentAction.gallery),
              ),
              _AttachmentTile(
                icon: Icons.location_on_rounded,
                color: const Color(0xFFE3564A),
                title: 'Bagikan lokasi saya',
                subtitle: 'Kirim pin lokasi perangkat saat ini',
                onTap: () => Navigator.pop(context, _AttachmentAction.location),
              ),
            ],
          ),
        ),
      ),
    );

    if (!mounted || action == null) return;
    switch (action) {
      case _AttachmentAction.gallery:
        await _pickImage(ImageSource.gallery);
      case _AttachmentAction.location:
        await _shareLocation();
    }
  }

  Future<void> _takePhoto() => _pickImage(ImageSource.camera);

  Future<void> _pickImage(ImageSource source) async {
    setState(() => _isOpeningCamera = true);
    try {
      final file = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 84,
        requestFullMetadata: false,
      );
      if (file == null || !mounted) return;

      final bytes = await file.readAsBytes();
      if (bytes.isEmpty) {
        _showMessage('Foto tidak dapat dibaca. Coba pilih gambar lain.');
        return;
      }
      _appendMessage(
        ChatMessage(
          id: _newMessageId(),
          isMine: true,
          createdAt: DateTime.now(),
          type: ChatMessageType.image,
          imageBytes: bytes,
        ),
      );
    } on PlatformException {
      if (mounted) {
        _showMessage(
          source == ImageSource.camera
              ? 'Kamera tidak dapat dibuka. Periksa izin kamera perangkat.'
              : 'Galeri tidak dapat dibuka. Periksa izin foto perangkat.',
        );
      }
    } finally {
      if (mounted) setState(() => _isOpeningCamera = false);
    }
  }

  Future<void> _shareLocation() async {
    final approved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.location_on_rounded, color: Color(0xFFE3564A)),
        title: const Text('Bagikan lokasi Anda?'),
        content: Text(
          'Lokasi perangkat saat ini akan dikirim ke ${widget.lapak.pemilik}. '
          'Anda bisa membatalkan sebelum membagikannya.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.pop(context, true),
            icon: const Icon(Icons.near_me_rounded, size: 17),
            label: const Text('Lanjutkan'),
          ),
        ],
      ),
    );

    if (approved != true || !mounted) return;
    setState(() => _isPreparingLocation = true);

    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        _showMessage('Aktifkan layanan lokasi untuk membagikan pin.');
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.unableToDetermine) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        _showMessage(
          'Izin lokasi belum diberikan. Izinkan akses lalu coba lagi.',
        );
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 20),
        ),
      );
      _appendMessage(
        ChatMessage(
          id: _newMessageId(),
          isMine: true,
          createdAt: DateTime.now(),
          type: ChatMessageType.location,
          latitude: position.latitude,
          longitude: position.longitude,
        ),
      );
    } on LocationServiceDisabledException {
      _showMessage('Layanan lokasi sedang mati. Aktifkan lalu coba lagi.');
    } on PermissionDeniedException {
      _showMessage(
        'Izin lokasi ditolak. Ubah izin lokasi di pengaturan perangkat.',
      );
    } on TimeoutException {
      _showMessage(
        'Lokasi belum ditemukan. Coba lagi di area dengan sinyal GPS.',
      );
    } on PlatformException {
      _showMessage('Lokasi tidak dapat diambil. Periksa pengaturan perangkat.');
    } finally {
      if (mounted) setState(() => _isPreparingLocation = false);
    }
  }

  Future<void> _openLocation(ChatMessage message) async {
    final latitude = message.latitude;
    final longitude = message.longitude;
    if (latitude == null || longitude == null) {
      _showMessage('Tautan lokasi tidak tersedia.');
      return;
    }

    final uri = Uri.https('www.google.com', '/maps/search/', {
      'api': '1',
      'query': '$latitude,$longitude',
    });
    try {
      final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!opened && mounted) {
        _showMessage('Tidak dapat membuka aplikasi peta.');
      }
    } on PlatformException {
      if (mounted) {
        _showMessage('Tidak dapat membuka aplikasi peta.');
      }
    }
  }

  Future<void> _callOwner() async {
    final phone = widget.lapak.noHp.replaceAll(RegExp(r'[^0-9+]'), '');
    if (phone.isEmpty) {
      _showMessage('Nomor telepon penjual belum tersedia.');
      return;
    }

    try {
      final opened = await launchUrl(
        Uri(scheme: 'tel', path: phone),
        mode: LaunchMode.externalApplication,
      );
      if (!opened && mounted) {
        _showMessage('Tidak dapat membuka aplikasi telepon.');
      }
    } on PlatformException {
      if (mounted) {
        _showMessage('Tidak dapat membuka aplikasi telepon.');
      }
    }
  }

  Future<void> _startVoiceNote() async {
    try {
      if (!await _recorder.hasPermission()) {
        _showMessage('Izin mikrofon diperlukan untuk merekam voice note.');
        return;
      }

      final fileName = 'voice_${DateTime.now().microsecondsSinceEpoch}.m4a';
      final outputPath = kIsWeb
          ? fileName
          : path.join((await getTemporaryDirectory()).path, fileName);
      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 64000,
          sampleRate: 44100,
          numChannels: 1,
        ),
        path: outputPath,
      );

      if (!mounted) {
        await _recorder.cancel();
        return;
      }

      _recordingStartedAt = DateTime.now();
      setState(() {
        _isRecording = true;
        _recordingDuration = Duration.zero;
        _showEmojiPicker = false;
      });
      _recordingTimer?.cancel();
      _recordingTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        final startedAt = _recordingStartedAt;
        if (startedAt == null || !mounted) return;
        setState(
          () => _recordingDuration = DateTime.now().difference(startedAt),
        );
      });
    } on PlatformException {
      if (mounted) {
        _showMessage('Rekaman tidak dapat dimulai. Periksa mikrofon.');
      }
    }
  }

  Future<void> _stopVoiceNote() async {
    if (!_isRecording) return;
    _recordingTimer?.cancel();
    final duration = _recordingStartedAt == null
        ? _recordingDuration
        : DateTime.now().difference(_recordingStartedAt!);

    try {
      final audioPath = await _recorder.stop();
      if (!mounted) return;
      setState(() {
        _isRecording = false;
        _recordingDuration = Duration.zero;
        _recordingStartedAt = null;
      });

      if (audioPath == null) {
        _showMessage('Voice note tidak tersimpan. Coba rekam kembali.');
        return;
      }

      _appendMessage(
        ChatMessage(
          id: _newMessageId(),
          isMine: true,
          createdAt: DateTime.now(),
          type: ChatMessageType.voice,
          audioPath: audioPath,
          audioDuration: duration,
        ),
      );
    } on PlatformException {
      if (mounted) {
        _showMessage('Voice note gagal disimpan. Coba rekam kembali.');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isRecording = false;
          _recordingDuration = Duration.zero;
          _recordingStartedAt = null;
        });
      }
    }
  }

  Future<void> _cancelVoiceNote() async {
    if (!_isRecording) return;
    _recordingTimer?.cancel();
    try {
      await _recorder.cancel();
      if (!mounted) return;
      setState(() {
        _isRecording = false;
        _recordingDuration = Duration.zero;
        _recordingStartedAt = null;
      });
    } on PlatformException {
      if (mounted) _showMessage('Rekaman tidak dapat dibatalkan.');
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  String _newMessageId() => DateTime.now().microsecondsSinceEpoch.toString();

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}

class _DateDivider extends StatelessWidget {
  const _DateDivider();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(bottom: 13),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE4ECE9)),
        ),
        child: const Text(
          'HARI INI',
          style: TextStyle(
            color: Color(0xFF71827F),
            fontSize: 9,
            fontWeight: FontWeight.w800,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }
}

class _ContactAvatar extends StatelessWidget {
  final String name;
  final double size;

  const _ContactAvatar({required this.name, required this.size});

  @override
  Widget build(BuildContext context) {
    final initial = name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase();
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.45),
          width: 1.4,
        ),
      ),
      child: Text(
        initial,
        style: TextStyle(
          color: Colors.white,
          fontSize: size * 0.42,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _AttachmentTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _AttachmentTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: color.withValues(alpha: 0.12),
        child: Icon(icon, color: color),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: Text(subtitle),
      onTap: onTap,
    );
  }
}

class _PulsingRecordDot extends StatefulWidget {
  const _PulsingRecordDot();

  @override
  State<_PulsingRecordDot> createState() => _PulsingRecordDotState();
}

class _PulsingRecordDotState extends State<_PulsingRecordDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 850),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.35, end: 1).animate(_controller),
      child: Container(
        width: 9,
        height: 9,
        decoration: const BoxDecoration(
          color: Color(0xFFE3564A),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

enum _AttachmentAction { gallery, location }
