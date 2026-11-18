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
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final visibleItems = widget.items
        .where((item) => item.pemilik.toLowerCase().contains(_query.trim().toLowerCase()))
        .toList();
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pesan',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Hubungi penjual dan penyedia jasa di sekitar Anda.',
                  style: TextStyle(color: Colors.blueGrey.shade600, fontSize: 13),
                ),
                const SizedBox(height: 18),
                TextField(
                  decoration: const InputDecoration(
                    hintText: 'Cari percakapan...',
                    prefixIcon: Icon(Icons.search_rounded),
                  ),
                  onChanged: (value) => setState(() => _query = value),
                ),
                const SizedBox(height: 18),
                const Text('Percakapan terbaru', style: TextStyle(fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
        if (visibleItems.isEmpty)
          const SliverFillRemaining(
            hasScrollBody: false,
            child: Center(child: Text('Tidak ada percakapan yang cocok.')),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            sliver: SliverList.builder(
              itemCount: visibleItems.length,
              itemBuilder: (context, index) {
                final item = visibleItems[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  color: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: Color(0xFFE9EFED)),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    leading: CircleAvatar(
                      radius: 25,
                      backgroundColor: const Color(0xFFE8F4F0),
                      child: Text(
                        item.pemilik.isEmpty ? '?' : item.pemilik[0].toUpperCase(),
                        style: const TextStyle(
                          color: Color(0xFF0F766E),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    title: Text(item.pemilik, style: const TextStyle(fontWeight: FontWeight.w700)),
                    subtitle: Text(
                      item.judul,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.blueGrey.shade600),
                    ),
                    trailing: IconButton(
                      tooltip: 'Lihat lapak',
                      onPressed: () => widget.onOpenLapak(item),
                      icon: const Icon(Icons.storefront_outlined),
                    ),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(builder: (_) => ChatScreen(lapak: item)),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
