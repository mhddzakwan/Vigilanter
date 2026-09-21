import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:vigilanter_flutter/theme/app_colors.dart';
import '../config/router.dart';
import '../provider/app_state_provider.dart';
import '../provider/auth_provider.dart';
import '../utils/snackbar_helper.dart';
import '../utils/validators.dart';
import 'signin.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {

  final _namaDepanController = TextEditingController();
  final _namaBelakangController = TextEditingController();
  final _tanggalLahirController = TextEditingController();
  final _nikController = TextEditingController();
  final _noTeleponController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmpasswordController = TextEditingController();

  bool _showPassword = false;
  bool _showConfirmPassword = false;
  bool _isLoading = false;
  bool isChecked = false;

  final List<String> jenisKelaminList = ['Laki-laki', 'Perempuan'];
  String? selectedJenisKelamin;

  @override
  void dispose() {
    _namaDepanController.dispose();
    _namaBelakangController.dispose();
    _tanggalLahirController.dispose();
    _nikController.dispose();
    _noTeleponController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmpasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {

    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmpasswordController.text;

    final emailError = Validators.validateEmail(email);
    if (emailError != null) {
      SnackbarHelper.showError(context, emailError);
      return;
    }

    final passwordError = Validators.validatePassword(password);
    if (passwordError != null) {
      SnackbarHelper.showError(context, passwordError);
      return;
    }

    final confirmPasswordError = Validators.validatePasswordConfirmation(password, confirmPassword);
    if (confirmPasswordError != null) {
      SnackbarHelper.showError(context, confirmPasswordError);
      return;
    }

    setState(() => _isLoading = true);

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.signUpWithEmail(
      email: email,
      password: password,
    );

    if (mounted) {
      setState(() => _isLoading = false);
    }

    if (success) {
      tambahAkun();
      Provider.of<AppStateProvider>(context, listen: false).userId = FirebaseAuth.instance.currentUser?.uid;
      if (mounted) {
        SnackbarHelper.showSuccess(context, 'Register berhasil!');
        context.go(AppRoutes.home);
      }
    } else {
      if (mounted) {
        final errorMessage = authProvider.errorMessage ?? 'Register gagal';
        SnackbarHelper.showError(context, errorMessage);
      }
    }
  }

  Future<void> tambahAkun() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
  
    await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .set({
          "nama_depan": _namaDepanController.text,
          "nama_belakang": _namaBelakangController.text,
          "jenis_kelamin": selectedJenisKelamin,
          "tanggal_lahir": _tanggalLahirController.text,
          "nik": _nikController.text,
          "no_telepon": _noTeleponController.text,
          "email": _emailController.text,
        });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isLargeScreen = screenWidth > 600;

    return Scaffold(
      backgroundColor: AppColors.biruVigilanter,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: EdgeInsets.all(screenWidth * 0.09),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Judul
                Text(
                  "Buat Akun",
                  style: TextStyle(
                    fontSize: screenWidth * (isLargeScreen ? 0.06 : 0.08),
                    color: Colors.white,
                    fontWeight: FontWeight.w800, // paling tebal
                  ),
                ),
        
                SizedBox(height: screenHeight * 0.03),
        
                // Nama Depan
                _buildControllerTextField(
                  hint: 'Nama Depan',
                  controller: _namaDepanController,
                  loading: !_isLoading,
                  screenWidth: screenWidth,
                  screenHeight: screenHeight,
                ),
        
                SizedBox(height: screenHeight * 0.025),
        
                // Nama Belakang
                _buildControllerTextField(
                  hint: 'Nama Belakang',
                  controller: _namaBelakangController,
                  loading: !_isLoading,
                  screenWidth: screenWidth,
                  screenHeight: screenHeight,
                ),
        
                SizedBox(height: screenHeight * 0.025),
        
                // Jenis Kelamin (Dropdown) — dibuat selebar form
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                  decoration: BoxDecoration(
                    color: AppColors.biruGelap,
                    borderRadius: BorderRadius.circular(21), // lebih kecil
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      dropdownColor: AppColors.biruGelap,
                      value: selectedJenisKelamin,
                      hint: Text(
                        'Jenis Kelamin',
                        style: TextStyle(
                          color: AppColors.abuMuda,
                          fontSize: screenWidth * 0.04,
                        ),
                      ),
                      isExpanded: true,
                      icon: Icon(
                        Icons.arrow_drop_down,
                        color: AppColors.abuMuda,
                        size: screenWidth * 0.06,
                      ),
                      items: jenisKelaminList.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                            value,
                            style: TextStyle(
                              color: AppColors.abuMuda,
                              fontSize: screenWidth * 0.04,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          selectedJenisKelamin = newValue;
                        });
                      },
                    ),
                  ),
                ),
        
                SizedBox(height: screenHeight * 0.025),
        
                _buildControllerTextField(
                  hint: 'Tanggal Lahir (hh/bb/tttt)',
                  controller: _tanggalLahirController,
                  loading: !_isLoading,
                  screenWidth: screenWidth,
                  screenHeight: screenHeight,
                  enableDatePicker: true,
                  onDateTap: () async {
                    DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime(2000),
                      firstDate: DateTime(1950),
                      lastDate: DateTime.now(),
                      helpText: "Pilih Tanggal Lahir",
                    );

                    if (picked != null) {
                      _tanggalLahirController.text =
                          "${picked.day.toString().padLeft(2, '0')}/"
                          "${picked.month.toString().padLeft(2, '0')}/"
                          "${picked.year}";
                      setState(() {});
                    }
                  },
                ),
        
                SizedBox(height: screenHeight * 0.025),
        
                _buildControllerTextField(
                  hint: 'Nomor Induk Kependudukan (NIK)',
                  controller: _nikController,
                  loading: !_isLoading,
                  screenWidth: screenWidth,
                  screenHeight: screenHeight,
                ),
        
                SizedBox(height: screenHeight * 0.025),
        
                _buildControllerTextField(
                  hint: 'Nomor Telepon',
                  controller: _noTeleponController,
                  loading: !_isLoading,
                  screenWidth: screenWidth,
                  screenHeight: screenHeight,
                ),
        
                SizedBox(height: screenHeight * 0.025),
        
                _buildControllerTextField(
                  hint: 'E-mail',
                  controller: _emailController,
                  loading: !_isLoading,
                  screenWidth: screenWidth,
                  screenHeight: screenHeight,
                ),
        
        
                SizedBox(height: screenHeight * 0.025),
                _buildControllerTextField(
                  hint: 'Kata Sandi Baru',
                  controller: _passwordController,
                  loading: !_isLoading,
                  screenWidth: screenWidth,
                  screenHeight: screenHeight,
                  obscureText: !_showPassword,
                  isPassword: true,
                  onTogglePassword: () {
                    setState(() {
                      _showPassword = !_showPassword;
                    });
                  },
                ),
        
                SizedBox(height: screenHeight * 0.025),
                _buildControllerTextField(
                  hint: 'Konfirmasi Kata Sandi Baru',
                  controller: _confirmpasswordController,
                  loading: !_isLoading,
                  screenWidth: screenWidth,
                  screenHeight: screenHeight,
                  obscureText: !_showConfirmPassword,
                  isPassword: true,
                  onTogglePassword: () {
                    setState(() {
                      _showConfirmPassword = !_showConfirmPassword;
                    });
                  },
                ),
    
                SizedBox(height: screenHeight * 0.03),
        
                // Checkbox + teks
                Row(
                  children: [
                    Checkbox(
                      value: isChecked,
                      onChanged: (value) {
                        setState(() {
                          isChecked = value ?? false;
                        });
                      },
                      activeColor: Colors.white,
                      checkColor: Colors.black,
                      visualDensity: const VisualDensity(horizontal: -4),
                    ),
                    Expanded(
                      child: Text(
                        "Saya menyetujui syarat & kebijakan privasi",
                        style: TextStyle(
                          color: AppColors.abuMuda,
                          fontSize: screenWidth * 0.035,
                        ),
                      ),
                    ),
                  ],
                ),
        
                SizedBox(height: screenHeight * 0.03),
        
                // Tombol Buat Akun (sesuai gaya tombol login)
                SizedBox(
                  width: double.infinity,
                  height: screenHeight * 0.053,
                  child: ElevatedButton(
                    onPressed: _isLoading && isChecked ? null : _handleRegister,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.kuningVigilanter,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(screenWidth * 0.1),
                      ),
                      elevation: 5,
                    ),
                    child: Text(
                      'Buat Akun',
                      style: TextStyle(
                        fontSize: screenWidth * 0.04,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
        
                SizedBox(height: screenHeight * 0.02),
        
                // Sudah punya akun? Masuk
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Sudah punya akun?",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: screenWidth * 0.037,
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.015),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const Signin(),
                          ),
                        );
                      },
                      child: Text(
                        "Masuk",
                        style: TextStyle(
                          color: AppColors.kuningVigilanter,
                          fontWeight: FontWeight.w900,
                          fontSize: screenWidth * 0.04,
                          decoration: TextDecoration.underline,
                          decorationColor: AppColors.kuningVigilanter,
                          decorationThickness: 1.2,
                        ),
                      ),
                    ),
                  ],
                ),
        
                SizedBox(height: screenHeight * 0.05),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget reusable untuk input field

}

Widget _buildControllerTextField({
  required String hint,
  required double screenWidth,
  required double screenHeight,
  required TextEditingController controller,
  bool loading = false,
  bool obscureText = false,
  bool readOnly = false,
  bool isPassword = false,
  VoidCallback? onTogglePassword,
  bool enableDatePicker = false,
  VoidCallback? onDateTap,
}) {
  return TextField(
    controller: controller,
    enabled: loading,
    obscureText: obscureText,
    readOnly: readOnly || enableDatePicker, // tanggal otomatis readOnly
    onTap: enableDatePicker ? onDateTap : null,
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        fontSize: screenWidth * 0.04,
        color: AppColors.abuMuda,
      ),
      filled: true,
      fillColor: AppColors.biruGelap,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(21),
        borderSide: BorderSide.none,
      ),
      contentPadding: EdgeInsets.symmetric(
        vertical: screenHeight * 0.012,
        horizontal: screenWidth * 0.05,
      ),

      // 👇 ikon mata untuk password
      suffixIcon: isPassword
          ? IconButton(
              icon: Icon(
                obscureText
                    ? Icons.visibility_off_rounded
                    : Icons.visibility_rounded,
                color: AppColors.abuTua,
                size: screenWidth * 0.06,
              ),
              onPressed: onTogglePassword,
            )
          : enableDatePicker
              ? Icon(
                  Icons.calendar_today_rounded,
                  color: AppColors.abuTua,
                  size: screenWidth * 0.055,
                )
              : null,
    ),
    style: TextStyle(
      fontSize: screenWidth * 0.037,
      color: AppColors.abuMuda,
    ),
  );
}
