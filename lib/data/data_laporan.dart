class Laporan {
  final String judul;
  final String lokasi;
  final String tanggal;
  final String status;

  Laporan({
    required this.judul,
    required this.lokasi,
    required this.tanggal,
    required this.status,
  });
}

final List<Laporan> laporanTerkirim = [
  Laporan(
    judul: 'Begal Motor',
    lokasi: 'Simpang tiga Kampus USU',
    tanggal: 'Jumat, 21 Juni 2024 (21:03:20 WIB)',
    status: 'Batalkan',
  ),
  Laporan(
    judul: 'Begal Motor',
    lokasi: 'Simpang tiga Kampus USU',
    tanggal: 'Jumat, 21 Juni 2024 (21:03:20 WIB)',
    status: 'Batalkan',
  ),
  Laporan(
    judul: 'Begal Motor',
    lokasi: 'Simpang tiga Kampus USU',
    tanggal: 'Jumat, 21 Juni 2024 (21:03:20 WIB)',
    status: 'Batalkan',
  ),

];

final List<Laporan> laporanSelesai = [
  Laporan(
    judul: 'Orang Bersenjata Tajam',
    lokasi: 'Jalan Gaperta Ujung',
    tanggal: 'Kamis, 20 Juni 2024 (08:07:41 WIB)',
    status: 'Diterima',
  ),
  Laporan(
    judul: 'Perampokan bersenjata',
    lokasi: 'Jalan Ayahanda',
    tanggal: 'Jumat, 21 Juni 2024 (20:42:14 WIB)',
    status: 'Ditolak',
  ),
  Laporan(
    judul: 'Perampokan bersenjata',
    lokasi: 'Jalan Ayahanda',
    tanggal: 'Jumat, 21 Juni 2024 (20:42:14 WIB)',
    status: 'Ditolak',
  ),
];