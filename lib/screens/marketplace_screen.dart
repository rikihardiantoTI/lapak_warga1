import 'package:flutter/material.dart';
import '../models/lapak_model.dart';
import '../widgets/lapak_card.dart';

class MarketplaceScreen extends StatefulWidget {
  final List<LapakItem> items;
  final String title;
  final String? initialCategory;
  final bool showWelcome;
  final ValueChanged<LapakItem> onOpenDetail;
  final VoidCallback? onOpenNotifications;

  const MarketplaceScreen({
    super.key,
    required this.items,
    required this.title,
    required this.onOpenDetail,
    this.onOpenNotifications,
    this.initialCategory,
    this.showWelcome = false,
  });

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  late String _selectedCategory;
  String _query = '';

  static const _categories = ['Semua', 'Jual Beli', 'Jasa Tukang'];

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory ?? 'Semua';
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final visibleItems = widget.items.where((item) {
      final matchesCategory =
          _selectedCategory == 'Semua' || item.kategori == _selectedCategory;
      final normalizedQuery = _query.trim().toLowerCase();
      final matchesQuery = normalizedQuery.isEmpty ||
          item.judul.toLowerCase().contains(normalizedQuery) ||
          item.deskripsi.toLowerCase().contains(normalizedQuery) ||
          item.pemilik.toLowerCase().contains(normalizedQuery);
      return matchesCategory && matchesQuery;
    }).toList()
      ..sort((a, b) => a.jarak.compareTo(b.jarak));

    return CustomScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.showWelcome) ...[
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: colors.primary,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.storefront_rounded, color: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Lapak Warga',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.5,
                                  ),
                            ),
                            Text(
                              'Lingkungan RW 05 · Sekitar Anda',
                              style: TextStyle(color: Colors.blueGrey.shade600, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: 'Notifikasi',
                        onPressed: widget.onOpenNotifications,
                        icon: const Icon(Icons.notifications_none_rounded),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Belanja dekat, kenal tetangga.',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.7,
                        ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Temukan kebutuhan harian dan jasa dari warga sekitar.',
                    style: TextStyle(color: Colors.blueGrey.shade600, height: 1.45),
                  ),
                  const SizedBox(height: 17),
                ] else ...[
                  Text(
                    widget.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Temukan warga yang siap membantu di sekitar Anda.',
                    style: TextStyle(color: Colors.blueGrey.shade600, fontSize: 13),
                  ),
                  const SizedBox(height: 17),
                ],
                TextField(
                  onChanged: (value) => setState(() => _query = value),
                  textInputAction: TextInputAction.search,
                  decoration: const InputDecoration(
                    hintText: 'Cari lapak, makanan, atau jasa...',
                    prefixIcon: Icon(Icons.search_rounded),
                    suffixIcon: Icon(Icons.tune_rounded),
                  ),
                ),
                const SizedBox(height: 16),
                if (widget.showWelcome)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F4F0),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.verified_user_outlined, color: Color(0xFF0F766E)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Dari warga, untuk warga',
                                style: TextStyle(fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Dukung usaha lokal di lingkungan RW 05.',
                                style: TextStyle(
                                  color: Colors.blueGrey.shade700,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                if (widget.showWelcome) const SizedBox(height: 18),
                SizedBox(
                  height: 42,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final category = _categories[index];
                      final selected = category == _selectedCategory;
                      return ChoiceChip(
                        label: Text(category == 'Jual Beli' ? 'Kuliner & Barang' : category),
                        selected: selected,
                        showCheckmark: false,
                        onSelected: (_) => setState(() => _selectedCategory = category),
                        selectedColor: colors.primary,
                        backgroundColor: Colors.white,
                        labelStyle: TextStyle(
                          color: selected ? Colors.white : const Color(0xFF50615F),
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                        side: BorderSide(
                          color: selected ? colors.primary : const Color(0xFFE5ECEA),
                        ),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.showWelcome ? 'Lapak di sekitar' : 'Warga siap membantu',
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
                      ),
                    ),
                    Text(
                      '${visibleItems.length} ditemukan',
                      style: TextStyle(color: Colors.blueGrey.shade600, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
        if (visibleItems.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: _emptyState(context),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            sliver: SliverList.builder(
              itemCount: visibleItems.length,
              itemBuilder: (context, index) => LapakCard(
                item: visibleItems[index],
                onTap: () => widget.onOpenDetail(visibleItems[index]),
              ),
            ),
          ),
      ],
    );
  }

  Widget _emptyState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off_rounded, size: 46, color: Color(0xFF8A9B98)),
          const SizedBox(height: 12),
          const Text('Belum ada lapak yang cocok', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 5),
          Text(
            'Coba kata kunci lain atau ubah kategori pilihan Anda.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.blueGrey.shade600, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
