import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:talabatfresh/core/enums/auth_status.dart';
import 'package:talabatfresh/features/vendor/pages/vendor_pending_page.dart';
import 'package:talabatfresh/providers/auth_provider.dart';

class RegisterVendorPage extends StatefulWidget {
  const RegisterVendorPage({super.key});

  @override
  State<RegisterVendorPage> createState() => _RegisterVendorPageState();
}

class _RegisterVendorPageState extends State<RegisterVendorPage> {
  final formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final businessNameController = TextEditingController();
  final descriptionController = TextEditingController();
  final passwordController = TextEditingController();
  final passwordConfirmationController = TextEditingController();

  String businessType = 'multi_service_vendor';

  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    businessNameController.dispose();
    descriptionController.dispose();
    passwordController.dispose();
    passwordConfirmationController.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    if (!formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();

    final success = await auth.registerVendor(
      name: nameController.text.trim(),
      email: emailController.text.trim(),
      phone: phoneController.text.trim(),
      password: passwordController.text.trim(),
      passwordConfirmation: passwordConfirmationController.text.trim(),
      businessName: businessNameController.text.trim(),
      businessType: businessType,
      description: descriptionController.text.trim().isEmpty
          ? null
          : descriptionController.text.trim(),
      supportEmail: emailController.text.trim(),
      supportPhone: phoneController.text.trim(),
    );

    if (!mounted) return;

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.errorMessage ?? 'فشل إنشاء حساب الورشة')),
      );
      return;
    }

    if (auth.authStatus == AuthStatus.vendorPending ||
        auth.authStatus == AuthStatus.authenticated) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const VendorPendingPage()),
            (_) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('إنشاء حساب ورشة'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),

                const Icon(
                  Icons.storefront_outlined,
                  size: 76,
                ),

                const SizedBox(height: 18),

                const Text(
                  'انضم كمقدم خدمة',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 28),

                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'اسم المسؤول',
                    prefixIcon: Icon(Icons.person_outline),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'أدخل اسم المسؤول';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 14),

                TextFormField(
                  controller: businessNameController,
                  decoration: const InputDecoration(
                    labelText: 'اسم الورشة / الشركة',
                    prefixIcon: Icon(Icons.business_outlined),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'أدخل اسم الورشة';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 14),

                DropdownButtonFormField<String>(
                  value: businessType,
                  decoration: const InputDecoration(
                    labelText: 'نوع النشاط',
                    prefixIcon: Icon(Icons.category_outlined),
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'repair_shop',
                      child: Text('ورشة إصلاح'),
                    ),
                    DropdownMenuItem(
                      value: 'roadside_provider',
                      child: Text('مساعدة طريق / سحب'),
                    ),
                    DropdownMenuItem(
                      value: 'parts_seller',
                      child: Text('بائع قطع غيار'),
                    ),
                    DropdownMenuItem(
                      value: 'tire_shop',
                      child: Text('إطارات'),
                    ),
                    DropdownMenuItem(
                      value: 'multi_service_vendor',
                      child: Text('خدمات متعددة'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => businessType = value);
                    }
                  },
                ),

                const SizedBox(height: 14),

                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'البريد الإلكتروني',
                    prefixIcon: Icon(Icons.email_outlined),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'أدخل البريد الإلكتروني';
                    }
                    if (!value.contains('@')) {
                      return 'البريد الإلكتروني غير صحيح';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 14),

                TextFormField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'رقم الهاتف',
                    prefixIcon: Icon(Icons.phone_outlined),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'أدخل رقم الهاتف';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 14),

                TextFormField(
                  controller: descriptionController,
                  minLines: 3,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    labelText: 'وصف مختصر',
                    prefixIcon: Icon(Icons.description_outlined),
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 14),

                TextFormField(
                  controller: passwordController,
                  obscureText: obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'كلمة المرور',
                    prefixIcon: const Icon(Icons.lock_outline),
                    border: const OutlineInputBorder(),
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
                      return 'أدخل كلمة المرور';
                    }
                    if (value.length < 6) {
                      return 'كلمة المرور يجب ألا تقل عن 6 أحرف';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 14),

                TextFormField(
                  controller: passwordConfirmationController,
                  obscureText: obscureConfirmPassword,
                  decoration: InputDecoration(
                    labelText: 'تأكيد كلمة المرور',
                    prefixIcon: const Icon(Icons.lock_reset_outlined),
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          obscureConfirmPassword = !obscureConfirmPassword;
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
                      return 'أدخل تأكيد كلمة المرور';
                    }
                    if (value != passwordController.text) {
                      return 'كلمة المرور غير متطابقة';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 24),

                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: auth.isLoading ? null : submit,
                    child: auth.isLoading
                        ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                        : const Text(
                      'إرسال طلب التسجيل',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}