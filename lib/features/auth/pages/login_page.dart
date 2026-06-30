import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:talabatfresh/app_entry_page.dart';

import '../../../core/enums/account_type.dart';
import '../../../core/enums/auth_status.dart';
import '../../../providers/auth_provider.dart';
import 'register_customer_page.dart';
import 'register_vendor_page.dart';

class LoginPage extends StatefulWidget {
  final AccountType appType;

  const LoginPage({
    super.key,
    this.appType = AccountType.customer,
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  static const Color primaryOrange = Color(0xFFF57C00);
  static const Color darkGrey = Color(0xFF374151);
  static const Color pageBg = Color(0xFFF3F4F6);

  final formKey = GlobalKey<FormState>();

  final loginController = TextEditingController();
  final passwordController = TextEditingController();

  bool obscurePassword = true;

  @override
  void dispose() {
    loginController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    if (!formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();

    final success = await auth.login(
      login: loginController.text.trim(),
      password: passwordController.text.trim(),
      expectedType: widget.appType,
    );

    if (!mounted) return;

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: darkGrey,
          content: Text(
            auth.errorMessage ?? 'Login failed',
          ),
        ),
      );
      return;
    }

    if (auth.authStatus == AuthStatus.vendorPending) {
      _showVendorPendingDialog(
        title: 'Vendor account pending',
        message:
        'Your workshop account is under review. We’ll notify you once approved.',
      );
      return;
    }

    if (auth.authStatus == AuthStatus.vendorRejected) {
      _showVendorPendingDialog(
        title: 'Vendor account rejected',
        message:
        'Your workshop account was rejected. Please contact support.',
      );
      return;
    }

    if (auth.authStatus == AuthStatus.authenticated) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => const AppEntryPage(),
        ),
            (_) => false,
      );
    }
  }

  void _showVendorPendingDialog({
    required String title,
    required String message,
  }) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  InputDecoration inputDecoration({
    required String label,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: darkGrey),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(
          color: primaryOrange,
          width: 1.6,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    final isVendorApp = widget.appType == AccountType.vendor;

    final title = isVendorApp
        ? 'Workshop dashboard access'
        : 'Welcome back';

    final subtitle = isVendorApp
        ? 'Manage requests, repairs, roadside jobs and your workshop operations.'
        : 'Login to manage repairs, roadside assistance and your vehicles.';

    return Scaffold(
      backgroundColor: pageBg,
      body: Stack(
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.36,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  darkGrey,
                  Color(0xFF111827),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
              child: Form(
                key: formKey,
                child: Column(
                  children: [
                    Row(
                      children: [
                        if (Navigator.canPop(context))
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: Colors.white,
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    Container(
                      width: 78,
                      height: 78,
                      decoration: BoxDecoration(
                        color: primaryOrange,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: primaryOrange.withOpacity(0.35),
                            blurRadius: 24,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      // child: Icon(
                      //   isVendorApp
                      //       ? Icons.storefront_rounded
                      //       : Icons.directions_car_filled_rounded,
                      //   color: Colors.white,
                      //   size: 42,
                      // ),
                      child: Image.asset(
                        'assets/icons/otlobha_logo_b.png',
                        fit: BoxFit.contain,
                      ),
                    ),

                    const SizedBox(height: 18),

                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      subtitle,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white70,
                        height: 1.5,
                        fontSize: 13,
                      ),
                    ),

                    const SizedBox(height: 34),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(18, 22, 18, 18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 26,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextFormField(
                            controller: loginController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: inputDecoration(
                              label: 'Email or phone number',
                              icon: Icons.person_outline_rounded,
                            ),
                            validator: (value) {
                              if (value == null ||
                                  value.trim().isEmpty) {
                                return 'Enter email or phone';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 14),

                          TextFormField(
                            controller: passwordController,
                            obscureText: obscurePassword,
                            decoration: inputDecoration(
                              label: 'Password',
                              icon: Icons.lock_outline_rounded,
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    obscurePassword = !obscurePassword;
                                  });
                                },
                                icon: Icon(
                                  obscurePassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null ||
                                  value.trim().isEmpty) {
                                return 'Enter password';
                              }

                              if (value.length < 6) {
                                return 'Password is too short';
                              }

                              return null;
                            },
                          ),

                          const SizedBox(height: 10),

                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Forgot password flow later',
                                    ),
                                  ),
                                );
                              },
                              child: const Text(
                                'Forgot password?',
                                style: TextStyle(
                                  color: primaryOrange,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 8),

                          SizedBox(
                            height: 56,
                            child: ElevatedButton(
                              onPressed:
                              auth.isLoading ? null : submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryOrange,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                disabledBackgroundColor:
                                primaryOrange.withOpacity(0.65),
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.circular(18),
                                ),
                              ),
                              child: auth.isLoading
                                  ? const SizedBox(
                                width: 24,
                                height: 24,
                                child:
                                CircularProgressIndicator(
                                  strokeWidth: 2.4,
                                  color: Colors.white,
                                ),
                              )
                                  : const Text(
                                'Login',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 18),

                          Row(
                            mainAxisAlignment:
                            MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Don’t have an account? ',
                                style: TextStyle(
                                  color: Color(0xFF6B7280),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => isVendorApp
                                          ? const RegisterVendorPage()
                                          : const RegisterCustomerPage(),
                                    ),
                                  );
                                },
                                child: const Text(
                                  'Create account',
                                  style: TextStyle(
                                    color: primaryOrange,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF3E0),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: primaryOrange.withOpacity(0.25),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.security_rounded,
                            color: primaryOrange,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              isVendorApp
                                  ? 'Vendor accounts go through approval before activation.'
                                  : 'Your data is protected and securely stored.',
                              style: const TextStyle(
                                color: darkGrey,
                                fontWeight: FontWeight.w600,
                                height: 1.4,
                                fontSize: 12.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}