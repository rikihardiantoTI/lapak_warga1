import 'package:flutter/material.dart';

import '../models/lapak_model.dart';
import 'chat_screen.dart';

class ChatListScreen extends StatefulWidget {
  final List<LapakItem> items;
  final ValueChanged<LapakItem> onOpenLapak;

  const ChatListScreen({
    super.key,
    required this.items,
    required this.onOpenLapak,
  });

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  static const _avatarPalettes = [
    [Color(0xFF0F766E), Color(0xFF36B6A8)],
    [Color(0xFF7454B7), Color(0xFFA888E8)],
    [Color(0xFFCE7441), Color(0xFFF0AA64)],
    [Color(0xFF3977A5), Color(0xFF6EB9C7)],
  ];

  String _query = '';

  @override
  Widget build(BuildContext context) {
    final normalizedQuery = _query.trim().toLowerCase();
    final visibleItems = widget.items.where((item) {
      return item.pemilik.toLowerCase().contains(normalizedQuery) ||
          item.judul.toLowerCase().contains(normalizedQuery) ||
          item.kategori.toLowerCase().contains(normalizedQuery);
    }).toList();

    return CustomScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      slivers: [
        SliverToBoxAdapter(child: _buildHero(visibleItems.length)),
        SliverToBoxAdapter(
          child: _constrainContent(
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
              child: TextField(
                key: const Key('conversation-search'),
                onChanged: (value) => setState(() => _query = value),
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: 'Cari nama warga atau lapak...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: _query.isEmpty
                      ? const Icon(Icons.tune_rounded)
                      : IconButton(
                          tooltip: 'Hapus pencarian',
                          onPressed: () => setState(() => _query = ''),
                          icon: const Icon(Icons.close_rounded),
                        ),
                ),
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: _constrainContent(
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 23, 20, 12),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Warga sekitar',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5F3EF),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${visibleItems.length} lapak',
                      style: const TextStyle(
                        color: Color(0xFF0F766E),
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (visibleItems.isEmpty)
          SliverFillRemaining(hasScrollBody: false, child: _emptyState())
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            sliver: SliverList.builder(
              itemCount: visibleItems.length,
              itemBuilder: (context, index) => _constrainContent(
                _conversationCard(visibleItems[index], index),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildHero(int contactCount) {
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF159A8D), Color(0xFF086B64)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: Stack(
        children: [
          Positioned(right: -32, top: -62, child: _decorationCircle(180, 0.1)),
          Positioned(
            right: 80,
            bottom: -96,
            child: _decorationCircle(150, 0.07),
          ),
          _constrainContent(
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 23, 22, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 43,
                        height: 43,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.24),
                          ),
                        ),
                        child: const Icon(
                          Icons.forum_rounded,
                          color: Colors.white,
                          size: 23,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Pesan',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 25,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.chat_bubble_rounded,
                        color: Color(0xFFB4F3E9),
                        size: 24,
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    'Obrolan hangat dimulai dari sini.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Hubungi penjual dan penyedia jasa di sekitar Anda.',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.82),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 11,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.13),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.people_alt_rounded,
                          size: 15,
                          color: Color(0xFFB4F3E9),
                        ),
                        const SizedBox(width: 7),
                        Text(
                          '$contactCount tetangga siap dihubungi',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _decorationCircle(double size, double opacity) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: opacity),
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _conversationCard(LapakItem item, int index) {
    final palette = _avatarPalettes[index % _avatarPalettes.length];

    return Container(
      margin: const EdgeInsets.only(bottom: 11),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(21),
        border: Border.all(color: const Color(0xFFE4ECE9)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF173B38).withValues(alpha: 0.035),
            blurRadius: 13,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(21),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => ChatScreen(lapak: item)),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(13, 14, 9, 14),
            child: Row(
              children: [
                _ConversationAvatar(
                  name: item.pemilik,
                  palette: palette,
                  isOpen: item.isBuka,
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.pemilik,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF203532),
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        item.judul,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.blueGrey.shade600,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 7,
                        runSpacing: 5,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          _ConversationTag(
                            label: item.kategori,
                            color: palette.first,
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.near_me_rounded,
                                size: 12,
                                color: Colors.blueGrey.shade400,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                item.jarak,
                                style: TextStyle(
                                  color: Colors.blueGrey.shade500,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      tooltip: 'Lihat lapak',
                      onPressed: () => widget.onOpenLapak(item),
                      style: IconButton.styleFrom(
                        backgroundColor: const Color(0xFFF0F6F4),
                        foregroundColor: const Color(0xFF0F766E),
                        minimumSize: const Size(38, 38),
                        padding: EdgeInsets.zero,
                      ),
                      icon: const Icon(Icons.storefront_rounded, size: 18),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      item.isBuka ? 'Buka' : 'Tutup',
                      style: TextStyle(
                        color: item.isBuka
                            ? const Color(0xFF218360)
                            : Colors.blueGrey.shade400,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: const BoxDecoration(
                color: Color(0xFFE5F3EF),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.mark_chat_unread_rounded,
                color: Color(0xFF0F766E),
                size: 34,
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'Warga belum ditemukan',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 5),
            Text(
              'Coba nama atau kata kunci lapak yang lain.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.blueGrey.shade600, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _constrainContent(Widget child) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: child,
      ),
    );
  }
}

class _ConversationAvatar extends StatelessWidget {
  final String name;
  final List<Color> palette;
  final bool isOpen;

  const _ConversationAvatar({
    required this.name,
    required this.palette,
    required this.isOpen,
  });

  @override
  Widget build(BuildContext context) {
    final initial = name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase();

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 54,
          height: 54,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                palette.first.withValues(alpha: 0.18),
                palette.last.withValues(alpha: 0.12),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
          ),
          child: Text(
            initial,
            style: TextStyle(
              color: palette.first,
              fontSize: 21,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        Positioned(
          right: 0,
          bottom: 1,
          child: Container(
            width: 13,
            height: 13,
            decoration: BoxDecoration(
              color: isOpen ? const Color(0xFF38A875) : const Color(0xFFABB7B4),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}

class _ConversationTag extends StatelessWidget {
  final String label;
  final Color color;

  const _ConversationTag({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
