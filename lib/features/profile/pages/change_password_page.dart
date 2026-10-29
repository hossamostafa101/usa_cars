import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/profile_provider.dart';

class ChangePasswordPage
    extends StatefulWidget {
  const ChangePasswordPage({
    super.key,
  });

  @override
  State<ChangePasswordPage>
  createState() =>
      _ChangePasswordPageState();
}

class _ChangePasswordPageState
    extends State<ChangePasswordPage> {
  final formKey =
  GlobalKey<FormState>();

  final currentController =
  TextEditingController();

  final passwordController =
  TextEditingController();

  final confirmController =
  TextEditingController();

  bool obscureCurrent = true;
  bool obscureNew = true;
  bool obscureConfirm = true;

  @override
  void dispose() {
    currentController.dispose();
    passwordController.dispose();
    confirmController.dispose();

    super.dispose();
  }

  Future<void> submit() async {
    if (!formKey.currentState!
        .validate()) {
      return;
    }

    final provider =
    context.read<ProfileProvider>();

    final success =
    await provider.changePassword(
      currentPassword:
      currentController.text,
      password:
      passwordController.text,
      passwordConfirmation:
      confirmController.text,
    );

    if (!mounted) return;

    if (success) {
      Navigator.pop(context);

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Password changed successfully.',
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            provider.errorMessage ??
                'Failed to change password.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider =
    context.watch<ProfileProvider>();

    return Scaffold(
      appBar: AppBar(
        title:
        const Text(
          'Change password',
        ),
      ),
      body:
      Form(
        key: formKey,
        child:
        ListView(
          padding:
          const EdgeInsets.all(
            16,
          ),
          children: [
            TextFormField(
              controller:
              currentController,
              obscureText:
              obscureCurrent,
              decoration:
              InputDecoration(
                labelText:
                'Current password',
                suffixIcon:
                IconButton(
                  onPressed:
                      () {
                    setState(() {
                      obscureCurrent =
                      !obscureCurrent;
                    });
                  },
                  icon:
                  Icon(
                    obscureCurrent
                        ? Icons
                        .visibility_outlined
                        : Icons
                        .visibility_off_outlined,
                  ),
                ),
              ),
              validator:
                  (value) {
                if ((value ?? '')
                    .isEmpty) {
                  return 'Current password is required.';
                }

                return null;
              },
            ),

            const SizedBox(
              height: 14,
            ),

            TextFormField(
              controller:
              passwordController,
              obscureText:
              obscureNew,
              decoration:
              InputDecoration(
                labelText:
                'New password',
                suffixIcon:
                IconButton(
                  onPressed:
                      () {
                    setState(() {
                      obscureNew =
                      !obscureNew;
                    });
                  },
                  icon:
                  Icon(
                    obscureNew
                        ? Icons
                        .visibility_outlined
                        : Icons
                        .visibility_off_outlined,
                  ),
                ),
              ),
              validator:
                  (value) {
                if ((value ?? '')
                    .length <
                    6) {
                  return 'Password must be at least 6 characters.';
                }

                return null;
              },
            ),

            const SizedBox(
              height: 14,
            ),

            TextFormField(
              controller:
              confirmController,
              obscureText:
              obscureConfirm,
              decoration:
              InputDecoration(
                labelText:
                'Confirm new password',
                suffixIcon:
                IconButton(
                  onPressed:
                      () {
                    setState(() {
                      obscureConfirm =
                      !obscureConfirm;
                    });
                  },
                  icon:
                  Icon(
                    obscureConfirm
                        ? Icons
                        .visibility_outlined
                        : Icons
                        .visibility_off_outlined,
                  ),
                ),
              ),
              validator:
                  (value) {
                if (value !=
                    passwordController
                        .text) {
                  return 'Passwords do not match.';
                }

                return null;
              },
            ),

            const SizedBox(
              height: 24,
            ),

            SizedBox(
              height: 52,
              child:
              ElevatedButton(
                onPressed:
                provider.isSubmitting
                    ? null
                    : submit,
                child:
                const Text(
                  'Update password',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}