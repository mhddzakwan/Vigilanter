import 'package:flutter/material.dart';
import '../widgets/emergency_popup.dart';

class DialogService {
  static void showEmergencyPopup(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      barrierDismissible: true,
      builder: (context) => EmergencyPopup(
        onClose: () => Navigator.of(context).pop(),
      ),
    );
  }
}