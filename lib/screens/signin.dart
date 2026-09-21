import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:vigilanter_flutter/config/router.dart';
import 'package:vigilanter_flutter/screens/register.dart';
import '../provider/app_state_provider.dart';
import '../provider/auth_provider.dart';
import '../theme/app_colors.dart';
import '../utils/snackbar_helper.dart';
import '../utils/validators.dart';

class Signin extends StatefulWidget {
  const Signin({super.key});

  @override
  State<Signin> createState() => _SigninState();
}

class _SigninState extends State<Signin> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool isChecked = false;
  bool _isObscure = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
  Future<void> _handleSignIn() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

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

    setState(() => _isLoading = true);

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.signInWithEmail(
      email: email,
      password: password,
    );

    if (mounted) {
      setState(() => _isLoading = false);
    }

    if (success) {
      Provider.of<AppStateProvider>(context, listen: false).userId = FirebaseAuth.instance.currentUser?.uid;

      if (mounted) {
        SnackbarHelper.showSuccess(context, 'Sign in berhasil!');
        context.go(AppRoutes.home);
      }
    } else {
      if (mounted) {
        final errorMessage = authProvider.errorMessage ?? 'Sign in gagal';
        SnackbarHelper.showError(context, errorMessage);
      }
    }
  }


  Future<void> _handleForgotPassword() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      SnackbarHelper.showError(context, 'Masukkan email terlebih dahulu');
      return;
    }

    final emailError = Validators.validateEmail(email);
    if (emailError != null) {
      SnackbarHelper.showError(context, emailError);
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Password'),
        content: Text('Kirim email reset password ke $email?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Kirim'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.sendPasswordResetEmail(email);

    if (mounted) {
      setState(() => _isLoading = false);
    }

    if (success) {
      if (mounted) {
        SnackbarHelper.showSuccess(
          context,
          'Email reset password telah dikirim!',
        );
      }
    } else {
      if (mounted) {
        final errorMessage = authProvider.errorMessage ?? 'Gagal mengirim email';
        SnackbarHelper.showError(context, errorMessage);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isLargeScreen = screenWidth > 600;

    return Scaffold(
      backgroundColor: AppColors.biruVigilanter,
      resizeToAvoidBottomInset: false,

      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(screenWidth * 0.07),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Masuk",
                    style: TextStyle(
                      fontSize: screenWidth * (isLargeScreen ? 0.06 : 0.08),
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
        
                SizedBox(height: screenHeight * 0.03),
        
                // Input Email
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    hintText: 'Email',
                    hintStyle: TextStyle(
                      fontSize: screenWidth * 0.04,
                      color: AppColors.abuMuda,
                    ),
                    filled: true,
                    fillColor: AppColors.biruGelap,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(screenWidth * 0.1),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      vertical: screenHeight * 0.012,
                      horizontal: screenWidth * 0.055,
                    ),
                  ),
                  style: TextStyle(
                    fontSize: screenWidth * 0.035,
                    color: AppColors.abuMuda,
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
        
                SizedBox(height: screenHeight * 0.025),
        
                // Input Password
                TextField(
                  controller: _passwordController,
                  obscureText: _isObscure,
                  decoration: InputDecoration(
                    hintText: 'Password',
                    hintStyle: TextStyle(
                      fontSize: screenWidth * 0.04,
                      color: AppColors.abuMuda,
                    ),
                    filled: true,
                    fillColor: AppColors.biruGelap,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(screenWidth * 0.1),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      vertical: screenHeight * 0.012,
                      horizontal: screenWidth * 0.055,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isObscure
                            ? Icons.visibility_off_rounded
                            : Icons.visibility_rounded,
                        color: AppColors.abuTua,
                        size: screenWidth * 0.06,
                      ),
                      onPressed: () {
                        setState(() {
                          _isObscure = !_isObscure;
                        });
                      },
                    ),
                  ),
                  style: TextStyle(
                    fontSize: screenWidth * 0.035,
                    color: AppColors.abuMuda,
                  ),
                ),
        
                SizedBox(height: screenHeight * 0.03),
        
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Checkbox(
                          value: isChecked,
                          onChanged: (value) {
                            setState(() {
                              isChecked = value ?? false;
                              Provider.of<AppStateProvider>(context, listen: false).statusIngatSaya = isChecked;
        
                            });
                            },
                          activeColor: Colors.white,
                          checkColor: Colors.black,
                          visualDensity: const VisualDensity(horizontal: -4),
                        ),
                        Text(
                          "Ingat Saya!", //TODO: Fitur Ingat Saya belum berjalan
                          style: TextStyle(
                            color: AppColors.abuMuda,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: _isLoading ? null : _handleForgotPassword,
                      child: Text(
                        "Lupa Kata Sandi?",
                        style: TextStyle(
                          color: AppColors.kuningVigilanter,
                          fontWeight: FontWeight.w500,
                          decoration: TextDecoration.underline,
                          decorationColor: AppColors.kuningVigilanter,
                          decorationThickness: 1.2,
                        ),
                      ),
                    ),
                  ],
                ),
        
                SizedBox(height: screenHeight * 0.03),
        
                SizedBox(
                  width: double.infinity,
                  height: screenHeight * 0.053,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleSignIn,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.kuningVigilanter,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(screenWidth * 0.1),
                      ),
                      elevation: 5,
                    ),
                    child: Text(
                      'Login',
                      style: TextStyle(
                        fontSize: screenWidth * 0.04,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),

      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(bottom: screenHeight * 0.03),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Belum Punya Akun? ",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const Register()),
                  );
                },
                child: Text(
                  "Buat akun baru",
                  style: TextStyle(
                    color: AppColors.kuningVigilanter,
                    fontWeight: FontWeight.bold,
                    fontSize: screenWidth * 0.038,
                    decoration: TextDecoration.underline,
                    decorationColor: AppColors.kuningVigilanter,
                    decorationThickness: 1.2,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
