import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:talabatfresh/app_entry_page.dart';

import '../../../core/enums/auth_status.dart';
import '../../../providers/auth_provider.dart';

class RegisterCustomerPage extends StatefulWidget {
  const RegisterCustomerPage({super.key});

  @override
  State<RegisterCustomerPage> createState() => _RegisterCustomerPageState();
}

class _RegisterCustomerPageState extends State<RegisterCustomerPage> {
  static const Color primaryOrange = Color(0xFFF57C00);
  static const Color darkGrey = Color(0xFF374151);
  static const Color pageBg = Color(0xFFF3F4F6);

  final formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final passwordConfirmationController = TextEditingController();

  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    passwordConfirmationController.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    if (!formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();

    final success = await auth.registerCustomer(
      name: nameController.text.trim(),
      email: emailController.text.trim(),
      phone: phoneController.text.trim(),
      password: passwordController.text.trim(),
      passwordConfirmation: passwordConfirmationController.text.trim(),
    );

    if (!mounted) return;

    if (!success || auth.authStatus != AuthStatus.authenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: darkGrey,
          content: Text(auth.errorMessage ?? 'فشل إنشاء الحساب'),
        ),
      );
      return;
    }

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const AppEntryPage()),
          (_) => false,
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: primaryOrange, width: 1.6),
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
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: pageBg,
      body: Stack(
        children: [
          Container(
            height: size.height * 0.34,
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
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: Colors.white,
                          ),
                        ),
                        const Spacer(),
                      ],
                    ),

                    const SizedBox(height: 6),

                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: primaryOrange,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: primaryOrange.withOpacity(0.30),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      // child: const Icon(
                      //   Icons.directions_car_filled_rounded,
                      //   color: Colors.white,
                      //   size: 38,
                      // ),
                      child: Image.asset(
                        'assets/icons/otlobha_logo_b.png',
                        fit: BoxFit.contain,
                      ),
                    ),

                    const SizedBox(height: 16),

                    const Text(
                      'Create your account',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 6),

                    const Text(
                      'Join and manage your cars, repairs, roadside help and parts.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),

                    const SizedBox(height: 28),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(18, 22, 18, 18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 24,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextFormField(
                            controller: nameController,
                            decoration: inputDecoration(
                              label: 'Full name',
                              icon: Icons.person_outline_rounded,
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Enter your name';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 14),

                          TextFormField(
                            controller: emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: inputDecoration(
                              label: 'Email address',
                              icon: Icons.email_outlined,
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Enter your email';
                              }
                              if (!value.contains('@')) {
                                return 'Invalid email address';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 14),

                          TextFormField(
                            controller: phoneController,
                            keyboardType: TextInputType.phone,
                            decoration: inputDecoration(
                              label: 'Phone number',
                              icon: Icons.phone_outlined,
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Enter your phone number';
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
                              if (value == null || value.isEmpty) {
                                return 'Enter password';
                              }
                              if (value.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 14),

                          TextFormField(
                            controller: passwordConfirmationController,
                            obscureText: obscureConfirmPassword,
                            decoration: inputDecoration(
                              label: 'Confirm password',
                              icon: Icons.lock_reset_outlined,
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    obscureConfirmPassword =
                                    !obscureConfirmPassword;
                                  });
                                },
                                icon: Icon(
                                  obscureConfirmPassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Confirm your password';
                              }
                              if (value != passwordController.text) {
                                return 'Passwords do not match';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 22),

                          SizedBox(
                            height: 56,
                            child: ElevatedButton(
                              onPressed: auth.isLoading ? null : submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryOrange,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                disabledBackgroundColor:
                                primaryOrange.withOpacity(0.65),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                              ),
                              child: auth.isLoading
                                  ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.4,
                                  color: Colors.white,
                                ),
                              )
                                  : const Text(
                                'Create account',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Already have an account? ',
                                style: TextStyle(
                                  color: Color(0xFF6B7280),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              InkWell(
                                onTap: () => Navigator.pop(context),
                                child: const Text(
                                  'Login',
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
                      child: const Row(
                        children: [
                          Icon(
                            Icons.verified_user_outlined,
                            color: primaryOrange,
                            size: 22,
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Your account helps us match your car with the right services and parts.',
                              style: TextStyle(
                                color: darkGrey,
                                fontSize: 12.5,
                                fontWeight: FontWeight.w500,
                                height: 1.4,
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