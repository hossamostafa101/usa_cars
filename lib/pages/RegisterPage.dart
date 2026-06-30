import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:talabatfresh/pages/LoginPage.dart';
import 'package:talabatfresh/providers/auth_provider.dart';
import '../data/local/cache_helper.dart';
import '../widgets/RootShell.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
  TextEditingController();

  bool _isObscure = true;
  bool _isCObscure = true;

  // ألوان البرتقالي + الرمادي
  static const Color primaryOrange = Color(0xFFF57C00);
  static const Color darkGrey = Color(0xFF374151);

  @override
  void initState() {
    super.initState();
    requestPermissions();
  }

  Future<void> requestPermissions() async {
    final status = await Permission.photos.request();
    if (status.isGranted) {
      debugPrint("Permission Granted!");
    } else {
      debugPrint("Permission Denied!");
    }
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: darkGrey.withOpacity(0.8)),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: Colors.grey.shade300,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: primaryOrange,
          width: 1.4,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 12,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        backgroundColor: const Color(0xFFF3F4F6), // رمادي فاتح
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Logo + title
                    Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 14,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Image.asset(
                          'assets/icons/otlobha_logo_b.png', // غيّر المسار حسب مشروعك
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Create your account',
                      textAlign: TextAlign.center,
                      style: themeData.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: darkGrey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Sign up to order parts, request roadside help and book repairs.',
                      textAlign: TextAlign.center,
                      style: themeData.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Card with form
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                      ),
                      elevation: 10,
                      shadowColor: Colors.black12,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Full name
                              TextFormField(
                                controller: nameController,
                                decoration: _inputDecoration(
                                  label: 'Full name',
                                  icon: Icons.person_outline,
                                ),
                                validator: (value) {
                                  if (value == null ||
                                      value.trim().isEmpty) {
                                    return 'Please enter your full name';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 12),

                              // Username
                              TextFormField(
                                controller: usernameController,
                                decoration: _inputDecoration(
                                  label: 'Username',
                                  icon: Icons.badge_outlined,
                                ),
                                validator: (value) {
                                  if (value == null ||
                                      value.trim().isEmpty) {
                                    return 'Please enter a username';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 12),

                              // Phone optional
                              TextFormField(
                                controller: phoneController,
                                decoration: _inputDecoration(
                                  label: 'Phone (optional)',
                                  icon: Icons.phone_outlined,
                                ),
                                keyboardType: TextInputType.phone,
                              ),
                              const SizedBox(height: 12),

                              // Email
                              TextFormField(
                                controller: emailController,
                                decoration: _inputDecoration(
                                  label: 'Email address',
                                  icon: Icons.email_outlined,
                                ),
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) {
                                  final v = value?.trim() ?? '';
                                  if (v.isEmpty) {
                                    return 'Email is required';
                                  }
                                  if (!v.contains('@')) {
                                    return 'Please enter a valid email';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),

                              // Password
                              TextFormField(
                                controller: passwordController,
                                obscureText: _isObscure,
                                decoration: _inputDecoration(
                                  label: 'Password',
                                  icon: Icons.lock_outline,
                                ).copyWith(
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _isObscure
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                      color:
                                      Colors.grey.withOpacity(0.9),
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _isObscure = !_isObscure;
                                      });
                                    },
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter a password';
                                  }
                                  if (value.length < 6) {
                                    return 'Password must be at least 6 characters';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 12),

                              // Confirm password
                              TextFormField(
                                controller: confirmPasswordController,
                                obscureText: _isCObscure,
                                decoration: _inputDecoration(
                                  label: 'Confirm password',
                                  icon: Icons.lock_reset_outlined,
                                ).copyWith(
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _isCObscure
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                      color:
                                      Colors.grey.withOpacity(0.9),
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _isCObscure = !_isCObscure;
                                      });
                                    },
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please confirm your password';
                                  }
                                  if (value != passwordController.text) {
                                    return 'Password and confirmation do not match';
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(height: 22),

                              // Sign up button
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () async {
                                    if (_formKey.currentState!
                                        .validate()) {
                                      await register();
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: primaryOrange,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                      BorderRadius.circular(16),
                                    ),
                                    padding:
                                    const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    elevation: 2,
                                  ),
                                  child: const Text(
                                    'Sign up',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 12),

                              // Already have account
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton(
                                  onPressed: () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                        const LoginPage(),
                                      ),
                                    );
                                  },
                                  style: OutlinedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                      BorderRadius.circular(16),
                                    ),
                                    side: BorderSide(
                                      color: Colors.grey.shade300,
                                    ),
                                    padding:
                                    const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                  ),
                                  child: const Text(
                                    'Already have an account? Log in',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF111827),
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
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> register() async {
    final name = nameController.text.trim();
    final username = usernameController.text.trim();
    final email = emailController.text.trim();
    final phone = phoneController.text.trim();
    final password = passwordController.text;
    final confirm = confirmPasswordController.text;

    if (password != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password and confirmation do not match'),
        ),
      );
      return;
    }

    final auth = context.read<AuthProvider>();

    // Loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(
          color: primaryOrange,
        ),
      ),
    );

    // final success = await auth.register(
    //   name: name.isEmpty ? 'New user' : name,
    //   username: username.isEmpty ? name : username,
    //   email: email,
    //   password: password,
    //   phone: phone.isEmpty ? null : phone,
    // );

    if (!mounted) return;
    Navigator.pop(context); // close loading

    // if (success) {
    //   Navigator.pushReplacement(
    //     context,
    //     MaterialPageRoute(builder: (_) => const RootShell()),
    //   );
    // } else {
    //   final msg = auth.errorMessage ??
    //       'Failed to create account, please try again.';
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(content: Text(msg)),
    //   );
    // }
  }
}
