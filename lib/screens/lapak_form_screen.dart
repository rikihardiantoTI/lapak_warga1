import 'package:flutter/material.dart';

import '../models/lapak_model.dart';

class LapakFormScreen extends StatefulWidget {
  const LapakFormScreen({super.key});

  @override
  State<LapakFormScreen> createState() => _LapakFormScreenState();
}

class _LapakFormScreenState extends State<LapakFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _ownerController = TextEditingController(text: 'Budi Santoso');
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController(text: 'RT 02 / RW 05');
  String _category = 'Jual Beli';
  bool _isOpen = true;

  @override
  void dispose() {
    _titleController.dispose();
    _ownerController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Buka lapak',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F4F0),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.lightbulb_outline_rounded,
                    color: Color(0xFF0F766E),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Kenalkan usaha Anda kepada tetangga. Pastikan informasi dan nomor kontak mudah dihubungi.',
                      style: TextStyle(fontSize: 13, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const _FormSectionTitle(title: 'Identitas lapak'),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _category,
              decoration: const InputDecoration(
                labelText: 'Kategori',
                prefixIcon: Icon(Icons.category_outlined),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'Jual Beli',
                  child: Text('Kuliner & barang'),
                ),
                DropdownMenuItem(
                  value: 'Jasa Tukang',
                  child: Text('Jasa & tukang'),
                ),
                DropdownMenuItem(
                  value: 'Info Warga',
                  child: Text('Info warga'),
                ),
              ],
              onChanged: (value) {
                if (value != null) setState(() => _category = value);
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _titleController,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Nama lapak',
                hintText: 'Contoh: Soto Seger Bu Joko',
                prefixIcon: Icon(Icons.storefront_outlined),
              ),
              validator: _requiredValidator,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _ownerController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Nama pemilik',
                prefixIcon: Icon(Icons.person_outline_rounded),
              ),
              validator: _requiredValidator,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descriptionController,
              textCapitalization: TextCapitalization.sentences,
              minLines: 3,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Deskripsi',
                hintText: 'Ceritakan produk atau layanan Anda...',
                alignLabelWithHint: true,
              ),
              validator: _requiredValidator,
            ),
            const SizedBox(height: 22),
            const _FormSectionTitle(title: 'Harga & kontak'),
            const SizedBox(height: 12),
            TextFormField(
              controller: _priceController,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Harga',
                hintText: 'Contoh: Mulai Rp 15.000',
                prefixIcon: Icon(Icons.payments_outlined),
              ),
              validator: _requiredValidator,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Nomor WhatsApp / telepon',
                hintText: '08xxxxxxxxxx',
                prefixIcon: Icon(Icons.phone_outlined),
              ),
              validator: (value) {
                final phone = value?.trim() ?? '';
                if (phone.length < 8) {
                  return 'Masukkan nomor telepon yang valid.';
                }
                return null;
              },
            ),
            const SizedBox(height: 22),
            const _FormSectionTitle(title: 'Lokasi & ketersediaan'),
            const SizedBox(height: 12),
            TextFormField(
              controller: _addressController,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Alamat / patokan',
                prefixIcon: Icon(Icons.location_on_outlined),
              ),
              validator: _requiredValidator,
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 4),
              title: const Text(
                'Lapak sedang buka',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: const Text(
                'Ubah status kapan saja dari halaman profil.',
              ),
              value: _isOpen,
              onChanged: (value) => setState(() => _isOpen = value),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: _publish,
              icon: const Icon(Icons.publish_rounded),
              label: const Text('Terbitkan lapak'),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(54),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Lapak ini disimpan sementara di perangkat dan belum dipublikasikan ke server.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.blueGrey.shade600, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) return 'Bagian ini wajib diisi.';
    return null;
  }

  void _publish() {
    if (!_formKey.currentState!.validate()) return;
    final item = LapakItem(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      judul: _titleController.text.trim(),
      pemilik: _ownerController.text.trim(),
      kategori: _category,
      deskripsi: _descriptionController.text.trim(),
      estimasiHarga: _priceController.text.trim(),
      noHp: _phoneController.text.trim(),
      alamat: _addressController.text.trim(),
      latitude: -6.9215,
      longitude: 106.9261,
      jarak: 'Dekat Anda',
      isBuka: _isOpen,
      fotoUrls: const [],
    );
    Navigator.of(context).pop(item);
  }
}

class _FormSectionTitle extends StatelessWidget {
  final String title;

  const _FormSectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
    );
  }
}
