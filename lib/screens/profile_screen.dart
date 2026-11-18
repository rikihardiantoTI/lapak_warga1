import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  final VoidCallback onCreateListing;

  const ProfileScreen({super.key, required this.onCreateListing});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _acceptingOrders = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      children: [
        Text(
          'Profil',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE9EFED)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: Color(0xFFE8F4F0),
                    child: Icon(
                      Icons.person_rounded,
                      color: Color(0xFF0F766E),
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Budi Santoso',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.verified_rounded,
                              color: Color(0xFF0F766E),
                              size: 15,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Warga RT 02 / RW 05',
                              style: TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Edit profil',
                    onPressed: () => _showInfo(
                      context,
                      'Fitur edit profil akan tersedia setelah akun terhubung.',
                    ),
                    icon: const Icon(Icons.edit_outlined),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F7F6),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Row(
                  children: [
                    _ProfileStat(value: '3', label: 'Lapak'),
                    _ProfileStat(value: '48', label: 'Transaksi'),
                    _ProfileStat(value: '4.9', label: 'Rating'),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE9EFED)),
          ),
          child: Row(
            children: [
              const CircleAvatar(
                backgroundColor: Color(0xFFE8F4F0),
                child: Icon(
                  Icons.storefront_outlined,
                  color: Color(0xFF0F766E),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Status lapak',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    Text(
                      _acceptingOrders
                          ? 'Siap menerima pesanan'
                          : 'Sedang tidak menerima pesanan',
                      style: TextStyle(
                        color: Colors.blueGrey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: _acceptingOrders,
                onChanged: (value) => setState(() => _acceptingOrders = value),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _MenuGroup(
          children: [
            _ProfileMenuItem(
              icon: Icons.add_business_outlined,
              title: 'Buka lapak baru',
              subtitle: 'Tawarkan produk atau jasa ke tetangga',
              onTap: widget.onCreateListing,
            ),
            _ProfileMenuItem(
              icon: Icons.home_outlined,
              title: 'Alamat rumah',
              subtitle: 'Blok C3 No. 12, RT 02 / RW 05',
              onTap: () => _showInfo(
                context,
                'Alamat tersimpan hanya sebagai contoh di aplikasi.',
              ),
            ),
            _ProfileMenuItem(
              icon: Icons.receipt_long_outlined,
              title: 'Riwayat pesanan',
              subtitle: 'Lihat transaksi dan pesanan Anda',
              onTap: () => _showInfo(
                context,
                'Riwayat pesanan belum tersedia tanpa akun dan layanan backend.',
              ),
            ),
            _ProfileMenuItem(
              icon: Icons.notifications_none_rounded,
              title: 'Pengaturan notifikasi',
              subtitle: 'Atur pengingat dan pemberitahuan',
              isLast: true,
              onTap: () => _showInfo(
                context,
                'Pengaturan notifikasi belum tersedia di versi demo ini.',
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        OutlinedButton.icon(
          onPressed: () => _showInfo(
            context,
            'Aplikasi ini masih berjalan dalam mode demo lokal.',
          ),
          icon: const Icon(Icons.help_outline_rounded),
          label: const Text('Bantuan & informasi aplikasi'),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(50),
            foregroundColor: const Color(0xFF0F766E),
            side: const BorderSide(color: Color(0xFFDCE7E4)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      ],
    );
  }

  void _showInfo(BuildContext context, String message) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Mengerti'),
          ),
        ],
      ),
    );
  }
}

class _ProfileStat extends StatelessWidget {
  final String value;
  final String label;

  const _ProfileStat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(fontSize: 11, color: Colors.blueGrey.shade600),
          ),
        ],
      ),
    );
  }
}

class _MenuGroup extends StatelessWidget {
  final List<Widget> children;

  const _MenuGroup({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE9EFED)),
      ),
      child: Column(children: children),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isLast;

  const _ProfileMenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: const Color(0xFFF0F5F3),
              child: Icon(icon, size: 20, color: const Color(0xFF0F766E)),
            ),
            title: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
            ),
            subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: onTap,
          ),
        ),
        if (!isLast) const Divider(height: 1, indent: 68, endIndent: 14),
      ],
    );
  }
}
