import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:vigilanter_flutter/models/report_summary.dart';
import 'package:vigilanter_flutter/services/location_service.dart';
import 'package:vigilanter_flutter/services/report_map_service.dart';
import 'package:vigilanter_flutter/widgets/report_summary_sheets.dart';
import 'detail_laporan_screen.dart';

class PetaScreen extends StatefulWidget {
  final double? focusLat;
  final double? focusLng;
  final String? focusReportId;
  final LatLng? focusLatLng;

  const PetaScreen({
    this.focusLat,
    this.focusLng,
    this.focusReportId,
    this.focusLatLng, 
    Key? key,
  }) : super(key: key);

  @override
  State<PetaScreen> createState() => _PetaPageState();
}

class _PetaPageState extends State<PetaScreen> {
  GoogleMapController? mapController;
  TextEditingController cariLokasi = TextEditingController();
  final locationService = LocationService();
  final _reportMapService = ReportMapService();
  StreamSubscription? _markerSub;
  bool _fromNotification = false;
  Key _mapKey = UniqueKey();

  LatLng _currentPos = const LatLng(3.567261, 98.650062);
  Set<Marker> markers = {};

  @override
  void initState() {
    super.initState();

    _fromNotification =
        widget.focusLatLng != null ||
        (widget.focusLat != null && widget.focusLng != null);

    /// PRIORITAS FOKUS DARI NOTIF
    if (widget.focusLatLng != null) {
      _currentPos = widget.focusLatLng!;
    } else if (widget.focusLat != null && widget.focusLng != null) {
      _currentPos = LatLng(widget.focusLat!, widget.focusLng!);
    }

    _markerSub =
        _reportMapService.listenMarkers(_onMarkerTap).listen((m) {
      setState(() {
        markers.addAll(m);
      });
    });
  }

  @override
  void dispose() {
    _markerSub?.cancel();
    cariLokasi.dispose();
    mapController?.dispose();
    super.dispose();
  }

  void _onMarkerTap(ReportSummary summary) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return ReportSummarySheet(
          data: summary,
          onDetail: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    DetailLaporanScreen(reportId: summary.id),
              ),
            );
          },
        );
      },
    );
  }

  /// ===================== AMBIL LOKASI USER =====================
  Future<void> _loadUserLocation() async {
    Position? position = await locationService.getPosition();
    if (position == null) return;

    final userPos = LatLng(position.latitude, position.longitude);

    setState(() {
      markers.removeWhere((m) => m.markerId.value == "userPos");
      markers.add(
        Marker(
          markerId: const MarkerId("userPos"),
          position: userPos,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueAzure,
          ),
          infoWindow: const InfoWindow(
            title: "Lokasi Anda",
            snippet: "Posisi saat ini",
          ),
        ),
      );
    });

    /// HANYA override _currentPos dan animasi kamera kalau BUKAN dari notifikasi
    if (_fromNotification) return;

    _currentPos = userPos; // <-- Hanya update jika bukan dari notifikasi

    if (mapController != null) {
      mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(_currentPos, 16),
      );
    }
  }

  Future<void> _searchLocation(String query) async {
    if (query.isEmpty) return;
    debugPrint(query);
    try {
      final locations = await locationFromAddress(query);
  
      if (locations.isEmpty) return;
      debugPrint(locations.first.latitude.toString());
  
      final loc = locations.first;
      final target = LatLng(loc.latitude, loc.longitude);
  
      setState(() {
        _currentPos = target;
      });
  
      mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(target, 16),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Lokasi tidak ditemukan"),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.only(
            bottom: 30, 
            left: 16,
            right: 16,
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _refreshMap() {
    setState(() {
      // reset map controller
      mapController?.dispose();
      mapController = null;

      // kosongkan marker (akan di-load ulang dari stream)
      markers.clear();

      // paksa GoogleMap rebuild total
      _mapKey = UniqueKey();
    });
    _markerSub =
        _reportMapService.listenMarkers(_onMarkerTap).listen((m) {
      setState(() {
        markers.addAll(m);
      });
    });

    // trigger ulang ambil lokasi user (jika bukan dari notifikasi)
    if (!_fromNotification) {
      _loadUserLocation();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          GoogleMap(
            key: _mapKey,
            initialCameraPosition: CameraPosition(
              target: _currentPos,
              zoom: 16,
            ),
            markers: markers,
            myLocationEnabled: false,
            onMapCreated: (controller) {
            mapController = controller;
              if (_fromNotification) {
                // Jika dari notifikasi, animasikan ke posisi fokus
                controller.animateCamera(
                  CameraUpdate.newLatLngZoom(_currentPos, 16),
                );
              } else {
                _loadUserLocation();
              }
            },
          ),

          /// --------------------- SEARCH BAR ---------------------
          Positioned(
            top: 40,
            left: 20,
            right: 20,
            child: Container(
              padding:
                  EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
              height: screenHeight * 0.05,
              decoration: BoxDecoration(
                color: const Color(0xFF1A1C3F),
                borderRadius:
                    BorderRadius.circular(screenWidth * 0.08),
              ),
              child: Row(
                children: [
                  Icon(Icons.location_on,
                      color: Colors.white.withValues(alpha: 0.4)),
                  SizedBox(width: screenWidth * 0.02),
                  Expanded(
                    child: TextField(
                      controller: cariLokasi,
                      textInputAction: TextInputAction.search,
                      onSubmitted: _searchLocation,
                      style: TextStyle(
                          color:
                              Colors.white.withValues(alpha: 0.4)),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: "Cari lokasi",
                        hintStyle: TextStyle(color: Colors.white54),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          /// --------------------- BADGE KOORDINAT ---------------------
          Positioned(
            top: 120,
            left: 20,
            right: 20,
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.03,
                    vertical: screenWidth * 0.02,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D1234),
                    borderRadius:
                        BorderRadius.circular(screenWidth * 0.08),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.location_on,
                          color: Colors.red,
                          size: screenWidth * 0.04),
                      SizedBox(width: screenWidth * 0.01),
                      Text(
                        "${_currentPos.latitude.toStringAsFixed(6)}, "
                        "${_currentPos.longitude.toStringAsFixed(6)}",
                        style:
                            const TextStyle(color: Color(0xFF808094)),
                      ),
                      SizedBox(width: screenWidth * 0.01),
                      GestureDetector(
                        onTap: () {
                          Clipboard.setData(
                            ClipboardData(
                              text:
                                  "${_currentPos.latitude},${_currentPos.longitude}",
                            ),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content:
                                  const Text("Koordinat disalin ke clipboard!"),
                              backgroundColor: Colors.green,
                               behavior: SnackBarBehavior.floating,
                               margin: EdgeInsets.only(
                                 bottom: screenHeight * 0.025, 
                                 left: 16,
                                 right: 16,
                               ),
                               duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                        child: const Icon(Icons.copy,
                            size: 16, color: Color(0xFF808094)),
                      ),
                    ],
                  ),
                ),
                const Spacer(),

                /// --------------------- TOMBOL TITIK RAWAN ---------------------
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.03,
                    vertical: screenWidth * 0.02,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius:
                        BorderRadius.circular(screenWidth * 0.025),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning,
                          size: screenWidth * 0.045,
                          color: Colors.white),
                      SizedBox(width: screenWidth * 0.015),
                      Text(
                        "Titik Rawan",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: screenWidth * 0.035,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),

          /// --------------------- TOMBOL REFRESH MAP ---------------------
          Positioned(
            bottom: screenHeight * 0.12,
            right: screenWidth * 0.04,
            child: FloatingActionButton(
              heroTag: "refresh_map",
              backgroundColor: const Color(0xFF1A1C3F),
              onPressed: _refreshMap,
              child: const Icon(Icons.refresh, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
