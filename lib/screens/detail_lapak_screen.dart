import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/lapak_model.dart';
import 'chat_screen.dart';

class DetailLapakScreen extends StatefulWidget {
  final LapakItem item;

  const DetailLapakScreen({super.key, required this.item});

  @override
  State<DetailLapakScreen> createState() => _DetailLapakScreenState();
}

class _DetailLapakScreenState extends State<DetailLapakScreen> {
  bool _isFavorite = false;

  LapakItem get item => widget.item;

  Future<void> _openExternalLink(Uri uri, String failureMessage) async {
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(failureMessage)));
    }
  }

  Future<void> _openMaps() => _openExternalLink(
        Uri.https('www.google.com', '/maps/search/', {
          'api': '1',
          'query': '${item.latitude},${item.longitude}',
        }),
        'Tidak dapat membuka aplikasi peta.',
      );

  Future<void> _callOwner() async {
    final phone = item.noHp.replaceAll(RegExp(r'[^0-9+]'), '');
    await _openExternalLink(Uri(scheme: 'tel', path: phone), 'Tidak dapat membuka aplikasi telepon.');
  }

  void _copyPhone() {
    Clipboard.setData(ClipboardData(text: item.noHp));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Nomor telepon disalin.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 270,
            pinned: true,
            leading: IconButton(
              tooltip: 'Kembali',
              onPressed: () => Navigator.of(context).maybePop(),
              icon: const CircleAvatar(
                backgroundColor: Color(0xB3000000),
                child: Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
              ),
            ),
            actions: [
              IconButton(
                tooltip: _isFavorite ? 'Hapus dari favorit' : 'Simpan ke favorit',
                onPressed: () => setState(() => _isFavorite = !_isFavorite),
                icon: CircleAvatar(
                  backgroundColor: const Color(0xB3000000),
                  child: Icon(
                    _isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    color: _isFavorite ? const Color(0xFFFF8B80) : Colors.white,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: _heroImage(),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 22),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: _cardDecoration(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _label(item.kategori, colors.primary, const Color(0xFFE8F4F0)),
                          const Spacer(),
                          Icon(LucideIcons.mapPin, size: 14, color: Colors.blueGrey.shade500),
                          const SizedBox(width: 4),
                          Text(
                            item.jarak,
                            style: TextStyle(color: Colors.blueGrey.shade600, fontSize: 12),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        item.judul,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              height: 1.2,
                            ),
                      ),
                      const SizedBox(height: 9),
                      Row(
                        children: [
                          const Icon(Icons.star_rounded, color: Color(0xFFE8A323), size: 18),
                          const SizedBox(width: 3),
                          Text(item.rating.toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.w700)),
                          const SizedBox(width: 5),
                          Text(
                            '(${item.jumlahUlasan} ulasan warga)',
                            style: TextStyle(color: Colors.blueGrey.shade600, fontSize: 12),
                          ),
                          const SizedBox(width: 8),
                          _label(
                            item.isBuka ? 'Buka' : 'Tutup',
                            item.isBuka ? const Color(0xFF17815F) : Colors.blueGrey.shade600,
                            item.isBuka ? const Color(0xFFE9F6F0) : const Color(0xFFF0F2F1),
                          ),
                        ],
                      ),
                      const Divider(height: 26),
                      Text(
                        item.estimasiHarga,
                        style: TextStyle(
                          color: colors.primary,
                          fontSize: 21,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: _cardDecoration(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Pemilik lapak', style: TextStyle(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: const Color(0xFFE8F4F0),
                            child: Text(
                              item.pemilik.isEmpty ? '?' : item.pemilik[0].toUpperCase(),
                              style: TextStyle(color: colors.primary, fontWeight: FontWeight.w700),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        item.pemilik,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontWeight: FontWeight.w700),
                                      ),
                                    ),
                                    if (item.terverifikasi) ...[
                                      const SizedBox(width: 4),
                                      Icon(Icons.verified_rounded, size: 16, color: colors.primary),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  item.noHp,
                                  style: TextStyle(color: Colors.blueGrey.shade600, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          TextButton.icon(
                            onPressed: _copyPhone,
                            icon: const Icon(Icons.copy_rounded, size: 15),
                            label: const Text('Salin'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: _cardDecoration(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Lokasi lapak', style: TextStyle(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.location_on_outlined, color: Color(0xFFDA665D)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              item.alamat,
                              style: TextStyle(color: Colors.blueGrey.shade700, height: 1.4),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: _openMaps,
                        icon: const Icon(Icons.map_outlined, size: 18),
                        label: const Text('Buka titik di Google Maps'),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(46),
                          foregroundColor: colors.primary,
                          side: BorderSide(color: colors.primary.withValues(alpha: 0.35)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: _cardDecoration(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Tentang lapak', style: TextStyle(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      Text(
                        item.deskripsi,
                        style: TextStyle(color: Colors.blueGrey.shade700, height: 1.55),
                      ),
                    ],
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Color(0xFFE9EFED))),
          ),
          child: Row(
            children: [
              SizedBox(
                height: 50,
                width: 52,
                child: OutlinedButton(
                  onPressed: _callOwner,
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.zero,
                    foregroundColor: colors.primary,
                    side: const BorderSide(color: Color(0xFFDCE7E4)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Icon(Icons.call_outlined),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(builder: (_) => ChatScreen(lapak: item)),
                  ),
                  icon: const Icon(Icons.chat_bubble_outline_rounded, size: 19),
                  label: const Text('Chat penjual'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _heroImage() {
    if (item.fotoUrls.isEmpty) return _imageFallback();
    return Image.network(
      item.fotoUrls.first,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => _imageFallback(),
    );
  }

  Widget _imageFallback() {
    return Container(
      color: const Color(0xFFE8F4F0),
      alignment: Alignment.center,
      child: const Icon(Icons.storefront_rounded, color: Color(0xFF0F766E), size: 54),
    );
  }

  Widget _label(String text, Color foreground, Color background) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(20)),
      child: Text(
        text,
        style: TextStyle(color: foreground, fontSize: 11, fontWeight: FontWeight.w700),
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: const Color(0xFFE9EFED)),
    );
  }
}
