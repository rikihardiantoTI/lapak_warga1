import 'package:flutter/material.dart';
import '../models/lapak_model.dart';
import 'chat_list_screen.dart';
import 'detail_lapak_screen.dart';
import 'lapak_form_screen.dart';
import 'marketplace_screen.dart';
import 'notifications_screen.dart';
import 'profile_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;
  final List<LapakItem> _items = List.of(dummyLapakList);

  void _openDetail(LapakItem item) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => DetailLapakScreen(item: item)),
    );
  }

  void _openNotifications() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => NotificationsScreen(items: _items, onOpenDetail: _openDetail),
      ),
    );
  }

  Future<void> _openCreateListing() async {
    final item = await Navigator.of(context).push<LapakItem>(
      MaterialPageRoute(builder: (_) => const LapakFormScreen()),
    );
    if (item == null || !mounted) return;
    setState(() {
      _items.insert(0, item);
      _selectedIndex = 0;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Lapak berhasil ditambahkan di perangkat ini.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      MarketplaceScreen(
        items: _items,
        title: 'Beranda',
        showWelcome: true,
        onOpenDetail: _openDetail,
        onOpenNotifications: _openNotifications,
      ),
      MarketplaceScreen(
        items: _items.where((item) => item.kategori == 'Jasa Tukang').toList(),
        title: 'Layanan warga',
        initialCategory: 'Semua',
        onOpenDetail: _openDetail,
      ),
      ChatListScreen(items: _items, onOpenLapak: _openDetail),
      ProfileScreen(onCreateListing: _openCreateListing),
    ];

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: IndexedStack(
          index: _selectedIndex,
          children: pages,
        ),
      ),
      floatingActionButton: _selectedIndex < 2
          ? FloatingActionButton.extended(
              onPressed: _openCreateListing,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Buka lapak'),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) => setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.storefront_outlined),
            selectedIcon: Icon(Icons.storefront_rounded),
            label: 'Beranda',
          ),
          NavigationDestination(
            icon: Icon(Icons.grid_view_outlined),
            selectedIcon: Icon(Icons.grid_view_rounded),
            label: 'Layanan',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline_rounded),
            selectedIcon: Icon(Icons.chat_bubble_rounded),
            label: 'Pesan',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
