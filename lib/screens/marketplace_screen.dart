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
  final GlobalKey _listingKey = GlobalKey();
  late String _selectedCategory;
  String _query = '';

  static const _categories = ['Semua', 'Jual Beli', 'Jasa Tukang'];

  static const _quickActions = [
    _QuickAction(
      id: 'nearby',
      label: 'Semua lapak',
      icon: Icons.storefront_rounded,
      background: Color(0xFFE6F4F1),
      foreground: Color(0xFF0F766E),
      category: 'Semua',
    ),
    _QuickAction(
      id: 'products',
      label: 'Kuliner & barang',
      icon: Icons.ramen_dining_rounded,
      background: Color(0xFFFFF1DF),
      foreground: Color(0xFFB96818),
      category: 'Jual Beli',
    ),
    _QuickAction(
      id: 'services',
      label: 'Jasa & servis',
      icon: Icons.handyman_rounded,
      background: Color(0xFFEAF0FF),
      foreground: Color(0xFF4968B1),
      category: 'Jasa Tukang',
    ),
    _QuickAction(
      id: 'news',
      label: 'Info RW',
      icon: Icons.campaign_rounded,
      background: Color(0xFFF2EAFE),
      foreground: Color(0xFF8056A8),
      opensNotifications: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory ?? 'Semua';
  }

  @override
  Widget build(BuildContext context) {
    final visibleItems = widget.items.where((item) {
      final matchesCategory =
          _selectedCategory == 'Semua' || item.kategori == _selectedCategory;
      final normalizedQuery = _query.trim().toLowerCase();
      final matchesQuery =
          normalizedQuery.isEmpty ||
          item.judul.toLowerCase().contains(normalizedQuery) ||
          item.deskripsi.toLowerCase().contains(normalizedQuery) ||
          item.pemilik.toLowerCase().contains(normalizedQuery);
      return matchesCategory && matchesQuery;
    }).toList()..sort((a, b) => a.jarak.compareTo(b.jarak));

    return CustomScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      slivers: [
        SliverToBoxAdapter(child: _constrainContent(_buildHeader(context))),
        if (widget.showWelcome) ...[
          SliverToBoxAdapter(
            child: _constrainContent(
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: _buildCommunityBanner(),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: _constrainContent(
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                child: _buildQuickCategories(),
              ),
            ),
          ),
          if (visibleItems.isNotEmpty)
            SliverToBoxAdapter(
              child: _constrainContent(
                Padding(
                  padding: const EdgeInsets.only(top: 25),
                  child: _buildFeaturedItems(visibleItems.take(4).toList()),
                ),
              ),
            ),
        ],
        SliverToBoxAdapter(
          child: _constrainContent(
            KeyedSubtree(
              key: _listingKey,
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  20,
                  widget.showWelcome ? 26 : 20,
                  20,
                  0,
                ),
                child: _buildListingHeader(context, visibleItems.length),
              ),
            ),
          ),
        ),
        if (visibleItems.isEmpty)
          SliverFillRemaining(hasScrollBody: false, child: _emptyState(context))
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            sliver: SliverList.builder(
              itemCount: visibleItems.length,
              itemBuilder: (context, index) => _constrainContent(
                LapakCard(
                  item: visibleItems[index],
                  onTap: () => widget.onOpenDetail(visibleItems[index]),
                ),
              ),
            ),
          ),
      ],
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

  void _selectCategory(String category) {
    setState(() => _selectedCategory = category);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final target = _listingKey.currentContext;
      if (target != null) {
        Scrollable.ensureVisible(
          target,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  Widget _buildHeader(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.showWelcome) ...[
            Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F766E),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.storefront_rounded,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Lapak Warga',
                        style: textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                      Text(
                        'Lingkungan RW 05 · Sekitar Anda',
                        style: TextStyle(
                          color: Colors.blueGrey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton.filledTonal(
                  tooltip: 'Notifikasi',
                  onPressed: widget.onOpenNotifications,
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF263B38),
                  ),
                  icon: const Icon(Icons.notifications_none_rounded),
                ),
              ],
            ),
            const SizedBox(height: 22),
            Text(
              'Belanja dekat, kenal tetangga.',
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                height: 1.12,
                letterSpacing: -0.8,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              'Temukan kebutuhan harian dan jasa dari warga sekitar.',
              style: TextStyle(color: Colors.blueGrey.shade600, height: 1.45),
            ),
          ] else ...[
            Text(
              widget.title,
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              'Temukan warga yang siap membantu di sekitar Anda.',
              style: TextStyle(color: Colors.blueGrey.shade600, fontSize: 13),
            ),
          ],
          const SizedBox(height: 17),
          TextField(
            onChanged: (value) => setState(() => _query = value),
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'Cari lapak, makanan, atau jasa...',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: IconButton(
                tooltip: 'Filter kategori',
                onPressed: _showFilterSheet,
                icon: const Icon(Icons.tune_rounded),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommunityBanner() {
    return Container(
      height: 158,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F766E), Color(0xFF084F4A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            right: -34,
            top: -64,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          Positioned(
            right: 24,
            bottom: -78,
            child: Container(
              width: 142,
              height: 142,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 18, 18),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Dari warga,\nuntuk warga.',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          height: 1.15,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.4,
                        ),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        'Dukung usaha lokal di RW 05.',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.82),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextButton.icon(
                        onPressed: () => _selectCategory('Semua'),
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF0F766E),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        icon: const Icon(Icons.explore_rounded, size: 16),
                        label: const Text(
                          'Jelajahi lapak',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.18),
                    ),
                  ),
                  child: const Icon(
                    Icons.volunteer_activism_rounded,
                    color: Colors.white,
                    size: 38,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickCategories() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Pilih kebutuhanmu',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
              ),
            ),
            TextButton(
              onPressed: () => _selectCategory('Semua'),
              child: const Text('Lihat semua'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _quickActions.map(_buildQuickAction).toList(),
        ),
      ],
    );
  }

  Widget _buildQuickAction(_QuickAction action) {
    final selected = action.category == _selectedCategory;

    return Expanded(
      child: Semantics(
        button: true,
        label: action.label,
        child: InkWell(
          key: Key('quick-category-${action.id}'),
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            if (action.opensNotifications) {
              widget.onOpenNotifications?.call();
            } else if (action.category != null) {
              _selectCategory(action.category!);
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
            child: Column(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: action.background,
                    borderRadius: BorderRadius.circular(19),
                    border: selected
                        ? Border.all(color: action.foreground, width: 1.5)
                        : null,
                  ),
                  child: Icon(action.icon, color: action.foreground, size: 25),
                ),
                const SizedBox(height: 8),
                Text(
                  action.label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    height: 1.25,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturedItems(List<LapakItem> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  'Pilihan tetangga',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
                ),
              ),
              Text(
                'Dekat dari Anda',
                style: TextStyle(color: Colors.blueGrey.shade600, fontSize: 12),
              ),
            ],
          ),
        ),
        const SizedBox(height: 13),
        SizedBox(
          height: 224,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) => _featuredCard(items[index]),
          ),
        ),
      ],
    );
  }

  Widget _featuredCard(LapakItem item) {
    final colors = Theme.of(context).colorScheme;

    return SizedBox(
      width: 218,
      child: Card(
        margin: EdgeInsets.zero,
        color: Colors.white,
        elevation: 0,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFFE6ECEA)),
        ),
        child: InkWell(
          onTap: () => widget.onOpenDetail(item),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 116,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    item.fotoUrls.isEmpty
                        ? _featuredImageFallback()
                        : Image.network(
                            item.fotoUrls.first,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => _featuredImageFallback(),
                          ),
                    Positioned(
                      left: 10,
                      top: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          item.kategori,
                          style: TextStyle(
                            color: colors.primary,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 10,
                      top: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.star_rounded,
                              size: 13,
                              color: Colors.amber.shade700,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              item.rating.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 11),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.judul,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${item.jarak} · ${item.pemilik}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.blueGrey.shade600,
                          fontSize: 10,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        item.estimasiHarga,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: colors.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _featuredImageFallback() {
    return Container(
      color: const Color(0xFFE6F4F1),
      alignment: Alignment.center,
      child: const Icon(
        Icons.storefront_rounded,
        color: Color(0xFF0F766E),
        size: 34,
      ),
    );
  }

  Widget _buildListingHeader(BuildContext context, int itemCount) {
    return Column(
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Lapak di sekitar',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
            ),
            Text(
              '$itemCount ditemukan',
              style: TextStyle(color: Colors.blueGrey.shade600, fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 38,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _categories.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final category = _categories[index];
              final selected = category == _selectedCategory;
              return ChoiceChip(
                label: Text(
                  category == 'Jual Beli' ? 'Kuliner & Barang' : category,
                ),
                selected: selected,
                showCheckmark: false,
                onSelected: (_) => setState(() => _selectedCategory = category),
                selectedColor: const Color(0xFF0F766E),
                backgroundColor: Colors.white,
                labelStyle: TextStyle(
                  color: selected ? Colors.white : const Color(0xFF50615F),
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
                side: BorderSide(
                  color: selected
                      ? const Color(0xFF0F766E)
                      : const Color(0xFFE5ECEA),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Filter kategori',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              for (final category in _categories)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    category == 'Jual Beli' ? 'Kuliner & Barang' : category,
                  ),
                  trailing: _selectedCategory == category
                      ? const Icon(
                          Icons.check_circle_rounded,
                          color: Color(0xFF0F766E),
                        )
                      : null,
                  onTap: () {
                    setState(() => _selectedCategory = category);
                    Navigator.of(sheetContext).pop();
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _emptyState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.search_off_rounded,
            size: 46,
            color: Color(0xFF8A9B98),
          ),
          const SizedBox(height: 12),
          const Text(
            'Belum ada lapak yang cocok',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
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

class _QuickAction {
  final String id;
  final String label;
  final IconData icon;
  final Color background;
  final Color foreground;
  final String? category;
  final bool opensNotifications;

  const _QuickAction({
    required this.id,
    required this.label,
    required this.icon,
    required this.background,
    required this.foreground,
    this.category,
    this.opensNotifications = false,
  });
}
