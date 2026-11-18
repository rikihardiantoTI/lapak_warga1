class LapakItem {
  final String id;
  final String judul;
  final String pemilik;
  final String kategori; // 'Jasa Tukang', 'Jual Beli', 'Info Warga'
  final String deskripsi;
  final String estimasiHarga;
  final String noHp;
  final String alamat;
  final double latitude;
  final double longitude;
  final String jarak;
  final bool isBuka;
  final List<String> fotoUrls;
  final double rating;
  final int jumlahUlasan;
  final bool terverifikasi;

  LapakItem({
    required this.id,
    required this.judul,
    required this.pemilik,
    required this.kategori,
    required this.deskripsi,
    required this.estimasiHarga,
    required this.noHp,
    required this.alamat,
    required this.latitude,
    required this.longitude,
    required this.jarak,
    required this.isBuka,
    required this.fotoUrls,
    this.rating = 4.9,
    this.jumlahUlasan = 24,
    this.terverifikasi = true,
  });
}

// Data Dummy Awal untuk Testing UI
final List<LapakItem> dummyLapakList = [
  LapakItem(
    id: '1',
    judul: 'Bengkel Motor Mas Budi',
    pemilik: 'Budi Santoso',
    kategori: 'Jasa Tukang',
    deskripsi: 'Servis rutin, ganti oli, tambal ban tubeless, dan kelistrikan motor. Bisa dipanggil ke rumah area RW 05.',
    estimasiHarga: 'Mulai Rp 15.000',
    noHp: '081234567890',
    alamat: 'Jl. Melati Blok C No. 12 (Depan Pos Ronda)',
    latitude: -6.9215,
    longitude: 106.9261,
    jarak: '250 m',
    isBuka: true,
    fotoUrls: [
      'https://images.unsplash.com/photo-1558981403-c5f9899a28bc?auto=format&fit=crop&w=800&q=80',
      'https://images.unsplash.com/photo-1625047509168-a7026f36de04?auto=format&fit=crop&w=800&q=80',
    ],
    rating: 4.9,
    jumlahUlasan: 42,
  ),
  LapakItem(
    id: '2',
    judul: 'Servis AC & Kulkas Pak Hendra',
    pemilik: 'Hendra Wijaya',
    kategori: 'Jasa Tukang',
    deskripsi: 'Cuci AC, isi freon, perbaikan kulkas dan mesin cuci segala merk. Garansi servis 1 bulan.',
    estimasiHarga: 'Mulai Rp 65.000',
    noHp: '085712345678',
    alamat: 'Gang Mawar RT 03 / RW 05',
    latitude: -6.9220,
    longitude: 106.9270,
    jarak: '450 m',
    isBuka: true,
    fotoUrls: [
      'https://images.unsplash.com/photo-1581092921461-eab62e97a780?auto=format&fit=crop&w=800&q=80',
    ],
    rating: 4.8,
    jumlahUlasan: 29,
  ),
  LapakItem(
    id: '3',
    judul: 'Nasi Uduk & Gorengan Bu Siti',
    pemilik: 'Siti Aminah',
    kategori: 'Jual Beli',
    deskripsi: 'Buka setiap pagi jam 06.00 - 10.00. Tersedia nasi uduk komplit, bihun, semur jengkol, dan bakwan hangat.',
    estimasiHarga: 'Rp 10.000 / porsi',
    noHp: '089698765432',
    alamat: 'Blok A2 No. 4 (Samping Masjid Al-Ikhlas)',
    latitude: -6.9205,
    longitude: 106.9255,
    jarak: '120 m',
    isBuka: true,
    fotoUrls: [
      'https://images.unsplash.com/photo-1604908176997-125f25cc6f3d?auto=format&fit=crop&w=800&q=80',
    ],
    rating: 4.9,
    jumlahUlasan: 42,
  ),
  LapakItem(
    id: '4',
    judul: 'Nasi Liwet & Sambal Mbak Ning',
    pemilik: 'Ning Rahayu',
    kategori: 'Jual Beli',
    deskripsi: 'Nasi liwet hangat, lauk rumahan, dan aneka sambal. Bisa dipesan untuk makan siang.',
    estimasiHarga: 'Mulai Rp 12.000',
    noHp: '081298765432',
    alamat: 'Gang Kenanga No. 8, RT 02 / RW 05',
    latitude: -6.9210,
    longitude: 106.9265,
    jarak: '350 m',
    isBuka: true,
    fotoUrls: [
      'https://images.unsplash.com/photo-1547592180-85f173990554?auto=format&fit=crop&w=800&q=80',
    ],
    rating: 4.8,
    jumlahUlasan: 29,
  ),
  LapakItem(
    id: '5',
    judul: 'Jajanan Pasar Bu Sri',
    pemilik: 'Sri Wahyuni',
    kategori: 'Jual Beli',
    deskripsi: 'Risoles, lemper ayam, dan jajanan pasar dibuat segar setiap pagi. Pesan lebih awal untuk acara.',
    estimasiHarga: 'Mulai Rp 3.000',
    noHp: '081377665544',
    alamat: 'Jl. Anggrek No. 5, RT 04 / RW 05',
    latitude: -6.9207,
    longitude: 106.9275,
    jarak: '500 m',
    isBuka: true,
    fotoUrls: [
      'https://images.unsplash.com/photo-1604908176997-125f25cc6f3d?auto=format&fit=crop&w=800&q=80',
    ],
    rating: 5.0,
    jumlahUlasan: 18,
  ),
  LapakItem(
    id: '6',
    judul: 'Tukang Ledeng Pak Slamet',
    pemilik: 'Slamet Riyadi',
    kategori: 'Jasa Tukang',
    deskripsi: 'Perbaikan keran, saluran mampet, dan kebocoran pipa. Melayani panggilan di sekitar RW 05.',
    estimasiHarga: 'Mulai Rp 50.000',
    noHp: '081234567891',
    alamat: 'RT 01 / RW 05, dekat pos ronda',
    latitude: -6.9225,
    longitude: 106.9259,
    jarak: '600 m',
    isBuka: true,
    fotoUrls: [
      'https://images.unsplash.com/photo-1621905251918-48416bd8575a?auto=format&fit=crop&w=800&q=80',
    ],
    rating: 4.7,
    jumlahUlasan: 16,
  ),
];