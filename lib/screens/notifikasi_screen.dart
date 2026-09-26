import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vigilanter_flutter/config/router.dart';

import '../theme/app_colors.dart';
import '../widgets/notifikasi_list.dart';


class NotifikasiScreen extends StatefulWidget {
  const NotifikasiScreen({super.key});

  @override
  State<NotifikasiScreen> createState() => _NotifikasiScreenState();
}

class _NotifikasiScreenState extends State<NotifikasiScreen> {


  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final appBarHeight = screenWidth * 0.15;

    return Scaffold(
      backgroundColor: AppColors.biruVigilanter,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(appBarHeight),
        child: AppBar(
          backgroundColor: const Color(0xFF000229),
          elevation: 0,
          leadingWidth: screenWidth * 0.12,
          leading: IconButton(
            padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.05
            ),
            icon: Icon(Icons.arrow_back,
                size: screenWidth * 0.08,
                color: Colors.white),
            onPressed: () {
              context.go(AppRoutes.home);
            },
          ),
          title: Text(
            'Notifikasi',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: screenWidth * 0.07, color: Colors.white),
          ),
          centerTitle: true,
        ),
      ),
      body: const NotifikasiList(),
    );
  }
}