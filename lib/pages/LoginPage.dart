import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'RegisterPage.dart';
import '../providers/auth_provider.dart';
import '../widgets/RootShell.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _isObscure = true;

  // نفس ألوان الريجيستر
  static const Color primaryOrange = Color(0xFFF57C00);
  static const Color darkGrey = Color(0xFF374151);

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
    String? hint,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
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
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(14)),
        borderSide: BorderSide(
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
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // ===== Logo =====
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
                          'assets/icons/otlobha_logo_b.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // ===== Title =====
                    Text(
                      "Welcome back",
                      textAlign: TextAlign.center,
                      style: themeData.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: darkGrey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Log in to manage your car, order parts and request help.",
                      textAlign: TextAlign.center,
                      style: themeData.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ===== Card with form =====
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                      ),
                      elevation: 8,
                      shadowColor: Colors.black12,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                        child: Form(
                          key: _formKey,
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Email
                                TextFormField(
                                  controller: emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: _inputDecoration(
                                    label: "Email address",
                                    icon: Icons.email_outlined,
                                    hint: "you@example.com",
                                  ),
                                  validator: (value) {
                                    final v = value?.trim() ?? '';
                                    if (v.isEmpty) {
                                      return 'Please enter your email';
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
                                    label: "Password",
                                    icon: Icons.lock_outline_rounded,
                                  ).copyWith(
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _isObscure
                                            ? Icons.visibility
                                            : Icons.visibility_off,
                                        color: Colors.grey.withOpacity(0.9),
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
                                      return 'Please enter your password';
                                    }
                                    if (value.length < 6) {
                                      return 'Password must be at least 6 characters';
                                    }
                                    return null;
                                  },
                                ),

                                const SizedBox(height: 10),

                                // Forgot password
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: () {
                                      // TODO: forgot password flow
                                    },
                                    child: const Text(
                                      'Forgot password?',
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 8),

                                // Login button
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      if (_formKey.currentState!.validate()) {
                                        await _login();
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
                                      "Log in",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 18),

                                // Divider
                                Row(
                                  children: [
                                    Expanded(
                                      child: Divider(
                                        color: Colors.grey[300],
                                        thickness: 1,
                                      ),
                                    ),
                                    const Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 8.0),
                                      child: Text(
                                        'or',
                                        style: TextStyle(fontSize: 12),
                                      ),
                                    ),
                                    Expanded(
                                      child: Divider(
                                        color: Colors.grey[300],
                                        thickness: 1,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),

                                // Go to register
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text(
                                      "Don’t have an account? ",
                                      style: TextStyle(fontSize: 13),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                            const RegisterPage(),
                                          ),
                                        );
                                      },
                                      child: const Text(
                                        "Sign up",
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
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

  Future<void> _login() async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    final auth = context.read<AuthProvider>();

    // Dialog تحميل
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(
          color: primaryOrange,
        ),
      ),
    );

    // final success = await auth.login(
    //   email: email,
    //   password: password,
    // );

    if (!mounted) return;
    Navigator.pop(context); // إغلاق اللودينج

    // if (success) {
    //   Navigator.pushReplacement(
    //     context,
    //     MaterialPageRoute(builder: (_) => const RootShell()),
    //   );
    // } else {
      // final msg =
      //     auth.errorMessage ?? 'Login failed, please check your credentials.';
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text(msg)),
      // );
    // }
  }
}
