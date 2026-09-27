import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../provider/auth_provider.dart';
import '../services/user_service.dart';
import '../theme/app_colors.dart';


class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  _AccountScreenState createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {

  String? userName;
  String? email;
  String? phone;
  final userService = UserService();

  @override
  void initState() {
    super.initState();
    loadData();
  }
  Future<void> loadData() async {
    final auth = context.read<AuthProvider>();
    final uid = auth.userId;

    if (uid == null) return;

    final name = await userService.getFullName(uid);
    final e = await userService.getEmail(uid);
    final no = await userService.getNoTelp(uid);
    setState(() {
      userName = name ?? "Pengguna";
      email = e ?? "Tidak ada";
      phone = no ?? "Tidak ada";
    });
  }


  void editField(String field) async {
    String? newValue = await showDialog<String>(
      context: context,
      builder: (context) {
        TextEditingController controller;
        if (field == 'Nama') {
          controller = TextEditingController(text: userName);
        }
        // else if (field == 'Email') {
        //   controller = TextEditingController(text: email);
        // }
        else{
          controller = TextEditingController(text: phone);
        }

        if(field != 'Email'){
          return AlertDialog(
            title: Text('Edit $field'),
            content: TextField(
                controller: controller,
                autofocus: true,
                decoration: InputDecoration(hintText: 'Masukkan $field'),
                keyboardType: TextInputType.text
              //field == 'Email' ? TextInputType.emailAddress : TextInputType.text,
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Batal')),
              TextButton(
                  onPressed: () {
                    Navigator.pop(context, controller.text);
                  },
                  child: Text('Simpan')),
            ],
          );
        }
        else{
          return AlertDialog(
            content: Text(
              'Untuk menganti Email, lakukan sign-in ulang dengan email baru atau registasi akun email yang baru',
              style: TextStyle(
                color: Colors.black,
                fontSize: 18
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('OK'))
            ],
          );
        }

      },
    );

    if (newValue != null && newValue.trim().isNotEmpty) {
      setState(() async {
        if (field == 'Nama') {
          userName = newValue.trim();
          List<String> list = newValue.trim().split(' ');
          if (list.length == 1){
            updateData('nama_depan', list[0]);
            updateData('nama_belakang', "");
          } else if(list.length == 2){
            updateData('nama_depan', list[0]);
            updateData('nama_belakang', list[1]);
          } else{
            String d = "";
            for (int i = 0; i < list.length - 1; i++) {
              d += "${list[i]} ";
            }
            updateData('nama_depan', d);
            updateData('nama_belakang', list[list.length - 1]);
          }
        }
        // else if (field == 'Email') {
        //   email = newValue.trim();
        //   // if (await _handleReauthenticate(newValue.trim())){
        //   //   updateData('email', newValue.trim());
        //   // }
        // }
        else if (field == 'No. Handphone') {
          phone = newValue.trim();
          updateData('no_telepon', newValue.trim());
        }
      });
    }
  }

  Future<void> updateData(String field, String data) async {
    final auth = context.read<AuthProvider>();
    final uid = auth.userId;

    if (uid == null) return;

    await userService.updateData(uid, field, data);
  }

  // Future<bool> _handleReauthenticate(String em) async {
  //   String? newValue = await showDialog<String>(
  //     context: context,
  //     builder: (context) {
  //       TextEditingController passwordController = TextEditingController();
  //
  //       return AlertDialog(
  //         title: Text('Autentikasi Ulang'),
  //         content: Column(
  //           children: [
  //             TextField(
  //               controller: TextEditingController(text: em),
  //               readOnly: true,
  //               autofocus: true,
  //               decoration: InputDecoration(hintText: 'Masukkan email'),
  //               keyboardType: TextInputType.emailAddress,
  //             ),
  //             TextField(
  //               controller: passwordController,
  //               autofocus: true,
  //               decoration: InputDecoration(hintText: 'Masukkan password'),
  //               obscureText: true,
  //             ),
  //           ],
  //         ),
  //         actions: [
  //
  //           TextButton(
  //               onPressed: () {
  //                 Navigator.pop(context);
  //               },
  //               child: Text('Batal')),
  //           TextButton(
  //               onPressed: () {
  //                 Navigator.pop(context, passwordController.text);
  //               },
  //               child: Text('Simpan')),
  //         ],
  //       );
  //     },
  //   );
  //
  //   final newEmail = em;
  //   final newPassword = newValue;
  //
  //   final emailError = Validators.validateEmail(newEmail);
  //   if (emailError != null) {
  //     SnackbarHelper.showError(context, emailError);
  //     return false;
  //   }
  //
  //   final passwordError = Validators.validatePassword(newPassword);
  //   if (passwordError != null) {
  //     SnackbarHelper.showError(context, passwordError);
  //     return false;
  //   }
  //
  //   final authProvider = context.read<AuthProvider>();
  //   final success = await authProvider.reauthenticateWithEmail(
  //     email: newEmail,
  //     password: newPassword as String,
  //   );
  //   if (success) {
  //     if (mounted) {
  //       SnackbarHelper.showSuccess(context, 'Autentikasi Ulang berhasil!');
  //       return true;
  //     }
  //   } else {
  //     if (mounted) {
  //       final errorMessage = authProvider.errorMessage ?? 'Autentikasi Ulang gagal';
  //       SnackbarHelper.showError(context, errorMessage);
  //       return false;
  //     }
  //   }
  //   return false;
  // }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    final iconSize = width * 0.1;


    return Scaffold(
      backgroundColor: AppColors.biruVigilanter,
      appBar: AppBar(
        backgroundColor: Color(0xFF000229),
        elevation: 0,
        leading:
        IconButton(
          padding: EdgeInsets.symmetric(
            horizontal: width * 0.05
          ),
          icon: Icon(Icons.arrow_back, color: Colors.white, size: width * 0.1,),
          onPressed: () {
            context.pop();
          },
        ),
        title: Text(
          'Account',
          style: TextStyle(
              color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: width * 0.075
          ) ,
        ),
        centerTitle: true,
      ),

      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: width * 0.07),
        child: Column(
          children: [
            SizedBox(height: height * 0.03),
            Stack(
              children: [
                CircleAvatar(
                  radius: iconSize + 8,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.person,
                    size: iconSize * 2,
                    color: Color(0xFF000229),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: CircleAvatar(
                    radius: iconSize * 0.4,
                    backgroundColor: Color(0xFF0F194F),
                    child: Icon(//TODO: edit photo profile
                      Icons.camera_alt_outlined,
                      size: iconSize * 0.5,
                      color: Colors.white,
                    ),
                  ),
                )
              ],
            ),

            SizedBox(height: height * 0.05),

            _buildInfoRow(
                context, Icons.person_outline, 'Nama', userName ?? 'Loading...', () => editField('Nama')),
            SizedBox(height: height * 0.04),
            _buildInfoRow(context, Icons.email_outlined, 'Email', email ?? 'Loading...',
                    () => editField('Email')),
            SizedBox(height: height * 0.04),
            _buildInfoRow(
                context, Icons.phone_outlined, 'No. Handphone', phone ?? 'Loading...', () => editField('No. Handphone')),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String label,
      String value, VoidCallback onEditTap) {
    final width = MediaQuery.of(context).size.width;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(width: width * 0.02),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    icon,
                    color: Colors.white,
                    size: width * 0.07,
                  ),
                  SizedBox(width: width * 0.02),
                  Text(
                    label,
                    style: TextStyle(
                        color: Colors.white, fontSize: width * 0.045, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: width * 0.045),
              ),
            ],
          ),
        ),
        GestureDetector( //TODO: edit in database & improve UI
          onTap: onEditTap,
          child: Icon(
            Icons.edit_outlined,
            color: Colors.white,
            size: width * 0.06,
          ),
        )
      ],
    );
  }
}