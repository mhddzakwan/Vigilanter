import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:vigilanter_flutter/models/laporan_model.dart';
import 'package:vigilanter_flutter/provider/laporan_provider.dart';
import 'package:vigilanter_flutter/widgets/video_player_widget.dart';

import '../theme/app_colors.dart';

class DetailLaporan extends StatefulWidget {
  final LaporanModel laporan;

  const DetailLaporan({super.key, required this.laporan});

  @override
  _DetailLaporanState createState() => _DetailLaporanState();
}
class _DetailLaporanState extends State<DetailLaporan> {
  TextEditingController judul = TextEditingController();
  TextEditingController deskripsi = TextEditingController();
  bool _isReadOnly = true;
  final FocusNode _focusNode = FocusNode();
  Future<void> _saveDescToFirestore(String value) async {
    await FirebaseFirestore.instance
        .collection('reports')
        .doc(widget.laporan.id)
        .update({
      'deskripsi': value,
    });
    // UPDATE DATA LOKAL
    context.read<LaporanProvider>().updateDeskripsi(
      widget.laporan.id,
      value,
    );
  }
  Future<void> _saveNamaToFirestore(String value) async {
    await FirebaseFirestore.instance
        .collection('reports')
        .doc(widget.laporan.id)
        .update({
      'nama_kejahatan': value,
    });
    // UPDATE DATA LOKAL
    context.read<LaporanProvider>().updateNama(
      widget.laporan.id,
      value,
    );
  }

  @override
  void initState() {
    super.initState();
    judul =
        TextEditingController(text: widget.laporan.namaKejahatan);
    deskripsi =
        TextEditingController(text: widget.laporan.deskripsi);
  }
  @override
  void dispose() {
    deskripsi.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final double baseFont = screenWidth * 0.035;
    final laporan = widget.laporan;

    final partWaktu = laporan.waktu.split('(');

    final tanggal = partWaktu[0].trim();                     // "Minggu, 30 November 2025"
    final jam = "(" + partWaktu[1].trim();                   // "(18:07:38 WIB)"

    List<String> partAlamat = laporan.tempat.split(',');

    String jalan = partAlamat[0].trim();
    String kelurahan = partAlamat[1].trim();
    String kecamatan = partAlamat[2].trim();
    String kota = partAlamat[3].trim();
    String provinsi = partAlamat[4].trim();
    
    final laporanProvider = context.read<LaporanProvider>();
    final isDiajukan = laporan.status.trim().toLowerCase() == "diajukan";

    return Scaffold(
      backgroundColor: AppColors.biruVigilanter,
      body: Scrollbar(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(screenWidth * 0.06),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: screenHeight),
            child: IntrinsicHeight(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: screenWidth * 0.09,
                        ),
                        onPressed: () {
                          context.pop();
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.025),

                  // Nama Kejahatan
                  isDiajukan ?
                  TextField(
                    controller: judul,
                    focusNode: _focusNode,
                    style: TextStyle(
                      fontSize: screenWidth * 0.065,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    onSubmitted: (value) async {
                      await _saveNamaToFirestore(value);
                      _focusNode.unfocus();

                    },

                    // Klik di luar / selesai edit
                    onEditingComplete: () async {
                      await _saveNamaToFirestore(judul.text);
                      _focusNode.unfocus();
                    },
                  ) : Text(
                      laporan.namaKejahatan,
                      style: TextStyle(
                        fontSize: screenWidth * 0.065,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                  ),
                  SizedBox(height: screenHeight * 0.02),

                  // Lokasi
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: screenWidth * 0.1,
                        width: screenWidth * 0.1,
                        decoration: BoxDecoration(
                          color: Colors.blue.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.location_on,
                            color: Colors.white70, size: screenWidth * 0.06),
                      ),
                      SizedBox(width: screenWidth * 0.05),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "$jalan, $kelurahan, $kecamatan",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: baseFont * 1.05,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    "${laporan.latitude}, ${laporan.longitude}",
                                    style: TextStyle(
                                      // color: Colors.white.withValues(alpha: 0.4),
                                      color: Colors.white70,
                                      fontSize: baseFont * 0.95,
                                    ),
                                  ),
                                ),
                                SizedBox(width: screenWidth * 0.015),

                                // TOMBOL COPY
                                GestureDetector(
                                  onTap: () async {
                                    final text = "${laporan.latitude}, ${laporan.longitude}";

                                    await Clipboard.setData(ClipboardData(text: text));

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text("Koordinat disalin ke clipboard!"),
                                        backgroundColor: Colors.green,
                                        behavior: SnackBarBehavior.floating,
                                        duration: Duration(seconds: 2),
                                        margin: EdgeInsets.only(
                                          bottom: screenHeight * 0.015,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Icon(
                                    Icons.copy,
                                    size: screenWidth * 0.045,
                                    color: Colors.white.withValues(alpha: 0.7),
                                  ),
                                ),
                              ],
                            )                          
                          ],
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.02),

                  // Tanggal & waktu
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: screenWidth * 0.1,
                        width: screenWidth * 0.1,
                        decoration: BoxDecoration(
                          color: Colors.blue.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.calendar_month_outlined,
                            color: Colors.white70, size: screenWidth * 0.06),
                      ),
                      SizedBox(width: screenWidth * 0.05),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tanggal,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: baseFont * 1.05,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            jam,
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: baseFont * 0.95,
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.02),

                  // Jenis & status
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Jenis Laporan",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: baseFont * 1.05,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.15),
                      Text(
                        "Status",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: baseFont * 1.05,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                       laporan.jenisLaporan,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: baseFont,
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.1),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.05,
                          vertical: screenHeight * 0.004,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.yellowAccent,
                          borderRadius:
                              BorderRadius.circular(screenHeight * 0.05),
                        ),
                        child: Text(
                          laporan.status,
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: baseFont,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.025),

                  // Deskripsi & bukti
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Deskripsi Laporan",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: baseFont * 1.05,
                          color: Colors.white,
                        ),
                      ),
                      isDiajukan ?
                      IconButton(
                        icon: Icon(
                          Icons.mode_edit_outlined,
                          color: Colors.white,
                          size: screenWidth * 0.06, // lebih besar & proporsional
                        ),
                        onPressed: (){
                          setState(() => _isReadOnly = false);

                          // Paksa fokus + buka keyboard
                          Future.delayed(const Duration(milliseconds: 100), () {
                            _focusNode.requestFocus();
                          });
                        },
                      ) :  SizedBox(width: screenWidth * 0.1,)
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  TextField(
                    controller: deskripsi,
                    focusNode: _focusNode,
                    readOnly: _isReadOnly,
                    style: TextStyle(
                      color: Colors.white70,
                      height: 1.5,
                      fontSize: baseFont,
                    ),
                    onSubmitted: (value) async {
                      setState(() => _isReadOnly = true);
                      await _saveDescToFirestore(value);
                      _focusNode.unfocus();

                    },

                    // Klik di luar / selesai edit
                    onEditingComplete: () async {
                      setState(() => _isReadOnly = true);
                      await _saveDescToFirestore(deskripsi.text);
                      _focusNode.unfocus();
                    },
                  ),
                  SizedBox(height: screenHeight * 0.025),

                  Text(
                    "Bukti Video/Foto",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: baseFont * 1.05,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  VideoPlayerWidget(
                    localPath: laporan.videoRealPath,
                    url: laporan.videoDownloadUrl,
                  ),
                  SizedBox(height: screenHeight * 0.04),

                  Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: screenHeight * 0.01,
                      horizontal: screenWidth * 0.012,
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      height: screenHeight * 0.05,
                      child: isDiajukan
                          ? _btnBatalkan(context, laporanProvider, laporan.id)
                          : _btnHapus(context, laporanProvider, laporan.id),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.08),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Widget _btnBatalkan(BuildContext context, LaporanProvider provider, String laporan_id) {
  return TextButton(
    style: TextButton.styleFrom(
      backgroundColor: Colors.red,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    onPressed: () async {
      final konfirm = await _showKonfirmasi(
        context,
        title: "Batalkan Laporan",
        message: "Apakah Anda yakin ingin membatalkan laporan ini?",
        confirmText: "Batalkan",
        isDestructive: true,
      );

      if (konfirm == true) {
        final index = provider.laporanTerkirim.indexWhere((e) => e.id == laporan_id);

        if (index != -1) await provider.batalkan(index);

        if (context.mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text("Laporan berhasil dibatalkan"),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.only(
                bottom: 70,
                left: 16,
                right: 16,
              ),
            ),
          );
        }
      }
    },
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Icon(Icons.not_interested, color: Colors.white),
        SizedBox(width: 10),
        Text(
          "Batalkan Laporan",
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      ],
    ),
  );
}

Widget _btnHapus(BuildContext context, LaporanProvider provider, String laporan_id) {
  return TextButton(
    style: TextButton.styleFrom(
      backgroundColor: Colors.white.withValues(alpha: 0.5),
      side: const BorderSide(color: Colors.white54),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    onPressed: () async {
      final konfirm = await _showKonfirmasi(
        context,
        title: "Hapus Laporan",
        message: "Apakah Anda yakin ingin menghapus laporan ini?",
        confirmText: "Hapus",
        isDestructive: true,
      );

      if (konfirm == true) {
        // tentukan index di daftar selesai
        final index = provider.laporanSelesai.indexWhere((e) => e.id == laporan_id);

        if (index != -1) await provider.hapus(index, false);

        if (context.mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text("Laporan berhasil dihapus"),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.only(
                bottom: 70,
                left: 16,
                right: 16,
              ),
            ),
          );
        }
      }
    },
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Icon(Icons.delete_outline_outlined, color: Color(0xFF000229)),
        SizedBox(width: 10),
        Text(
          "Hapus Laporan",
          style: TextStyle(color: Color(0xFF000229), fontSize: 16),
        ),
      ],
    ),
  );
}

Future<bool?> _showKonfirmasi(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmText,
  bool isDestructive = false,
}) {
  return showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text("Batal"),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(
            confirmText,
            style: TextStyle(
              color: isDestructive ? Colors.red : Colors.blue,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    ),
  );
}
