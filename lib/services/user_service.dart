import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Ambil nama depan user dari Firestore
  Future<String?> getUserFirstName(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();

      debugPrint("nama_depan: ${doc.data()?['nama_depan']}");
      debugPrint("uid: $uid");
      if (!doc.exists) return null;

      return doc.data()?['nama_depan'] ?? null;
    } catch (e) {
      print("Error getUserFirstName: $e");
      return null;
    }
  }

  /// Ambil nama lengkap jika mau
  Future<String?> getFullName(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();

      if (!doc.exists) return null;

      final first = doc.data()?['nama_depan'] ?? "";
      final last = doc.data()?['nama_belakang'] ?? "";

      return "$first $last".trim();
    } catch (e) {
      print("Error getFullName: $e");
      return null;
    }
  }
  /// Ambil email
  Future<String?> getEmail(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();

      if (!doc.exists) return null;

      final email = doc.data()?['email'] ?? "";

      return "$email".trim();
    } catch (e) {
      print("Error getEmail: $e");
      return null;
    }
  }
  ///Ambil nomor telepon
  Future<String?> getNoTelp(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();

      if (!doc.exists) return null;

      final noTelp = doc.data()?['no_telepon'] ?? "";

      return "$noTelp".trim();
    } catch (e) {
      print("Error getNoTelp: $e");
      return null;
    }
  }
  ///Update data
  Future<void> updateData(String uid, String field, String data) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .update({
        field: data
      });
    } catch (e) {
      print("Error updateData: $e");
    }



  }
}
