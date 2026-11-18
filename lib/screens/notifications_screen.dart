import 'package:flutter/material.dart';

import '../models/lapak_model.dart';

class NotificationsScreen extends StatefulWidget {
  final List<LapakItem> items;
  final ValueChanged<LapakItem> onOpenDetail;

  const NotificationsScreen({
    super.key,
    required this.items,
    required this.onOpenDetail,
  });

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  static const _filters = ['Semua', 'Pesanan', 'Layanan', 'Info RW'];
  String _selectedFilter = 'Semua';
  final Set<String> _readNotices = {};

  @override
  Widget build(BuildContext context) {
    final notices = _createNotices()
        .where(
          (notice) =>
              _selectedFilter == 'Semua' || notice.type == _selectedFilter,
        )
        .toList();
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Notifikasi',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          TextButton(
            onPressed: () => setState(
              () => _readNotices.addAll(_createNotices().map((n) => n.id)),
            ),
            child: const Text('Tandai dibaca'),
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 54,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              scrollDirection: Axis.horizontal,
              itemCount: _filters.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final filter = _filters[index];
                final selected = filter == _selectedFilter;
                final count = filter == 'Semua'
                    ? _createNotices().length
                    : _createNotices()
                          .where((notice) => notice.type == filter)
                          .length;
                return ChoiceChip(
                  label: Text('$filter $count'),
                  selected: selected,
                  showCheckmark: false,
                  onSelected: (_) => setState(() => _selectedFilter = filter),
                  selectedColor: Theme.of(context).colorScheme.primary,
                  backgroundColor: Colors.white,
                  labelStyle: TextStyle(
                    color: selected ? Colors.white : const Color(0xFF50615F),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  side: BorderSide(
                    color: selected
                        ? Theme.of(context).colorScheme.primary
                        : const Color(0xFFE5ECEA),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: notices.isEmpty
                ? const Center(
                    child: Text('Belum ada notifikasi pada kategori ini.'),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                    itemCount: notices.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) =>
                        _noticeCard(notices[index]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _noticeCard(_Notice notice) {
    final isRead = _readNotices.contains(notice.id);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isRead ? Colors.white : const Color(0xFFF0F7F4),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: const Color(0xFFE4ECE9)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: Colors.white,
            child: Icon(notice.icon, color: const Color(0xFF0F766E), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        notice.title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (!isRead)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFF0F766E),
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  notice.message,
                  style: TextStyle(
                    color: Colors.blueGrey.shade700,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  notice.time,
                  style: TextStyle(
                    color: Colors.blueGrey.shade500,
                    fontSize: 11,
                  ),
                ),
                if (notice.item != null) ...[
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: () {
                        setState(() => _readNotices.add(notice.id));
                        widget.onOpenDetail(notice.item!);
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        minimumSize: const Size(0, 36),
                      ),
                      child: const Text('Lihat lapak'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<_Notice> _createNotices() {
    final service = _findItem((item) => item.kategori == 'Jasa Tukang');
    final product = _findItem((item) => item.kategori == 'Jual Beli');
    return [
      if (product != null)
        _Notice(
          id: 'order',
          type: 'Pesanan',
          title: 'Ada pesanan baru',
          message:
              'Warga tertarik dengan ${product.judul}. Lihat detail lapak untuk informasi lebih lanjut.',
          time: '10 menit lalu',
          icon: Icons.shopping_bag_outlined,
          item: product,
        ),
      if (service != null)
        _Notice(
          id: 'service',
          type: 'Layanan',
          title: 'Permintaan layanan sekitar',
          message:
              '${service.judul} sedang dicari oleh warga di lingkungan Anda.',
          time: '1 jam lalu',
          icon: Icons.handyman_outlined,
          item: service,
        ),
      const _Notice(
        id: 'rw',
        type: 'Info RW',
        title: 'Kerja bakti lingkungan',
        message: 'Jadwal kerja bakti warga akan diumumkan melalui pengurus RT.',
        time: 'Kemarin',
        icon: Icons.campaign_outlined,
      ),
      if (widget.items.length > 2)
        _Notice(
          id: 'favorite',
          type: 'Pesanan',
          title: 'Lapak ramai dikunjungi',
          message: 'Warga sekitar sedang melihat ${widget.items[2].judul}.',
          time: 'Kemarin',
          icon: Icons.favorite_border_rounded,
          item: widget.items[2],
        ),
    ];
  }

  LapakItem? _findItem(bool Function(LapakItem) predicate) {
    for (final item in widget.items) {
      if (predicate(item)) return item;
    }
    return null;
  }
}

class _Notice {
  final String id;
  final String type;
  final String title;
  final String message;
  final String time;
  final IconData icon;
  final LapakItem? item;

  const _Notice({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.time,
    required this.icon,
    this.item,
  });
}
