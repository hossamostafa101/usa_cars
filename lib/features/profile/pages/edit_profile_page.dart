import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/profile_provider.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({
    super.key,
  });

  @override
  State<EditProfilePage>
  createState() =>
      _EditProfilePageState();
}

class _EditProfilePageState
    extends State<EditProfilePage> {
  static const orange =
  Color(0xFFF57C00);

  final formKey =
  GlobalKey<FormState>();

  late final TextEditingController
  nameController;

  late final TextEditingController
  phoneController;

  late final TextEditingController
  birthController;

  String? gender;
  String preferredLanguage = 'en';

  @override
  void initState() {
    super.initState();

    final user =
        context.read<ProfileProvider>().user;

    nameController =
        TextEditingController(
          text: user?.name ?? '',
        );

    phoneController =
        TextEditingController(
          text: user?.phone ?? '',
        );

    birthController =
        TextEditingController(
          text:
          user?.userProfile?.dateOfBirth ??
              '',
        );

    gender =
        user?.userProfile?.gender;

    preferredLanguage =
        user?.userProfile
            ?.preferredLanguage ??
            'en';
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    birthController.dispose();

    super.dispose();
  }

  Future<void> pickBirthDate() async {
    DateTime initial =
    DateTime(1995);

    final parsed =
    DateTime.tryParse(
      birthController.text,
    );

    if (parsed != null) {
      initial = parsed;
    }

    final result =
    await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate:
      DateTime(1900),
      lastDate:
      DateTime.now(),
    );

    if (result == null) return;

    setState(() {
      birthController.text =
      '${result.year.toString().padLeft(4, '0')}-'
          '${result.month.toString().padLeft(2, '0')}-'
          '${result.day.toString().padLeft(2, '0')}';
    });
  }

  Future<void> submit() async {
    if (!formKey.currentState!
        .validate()) {
      return;
    }

    final provider =
    context.read<ProfileProvider>();

    final success =
    await provider.updateProfile(
      name:
      nameController.text.trim(),
      phone:
      phoneController.text.trim(),
      dateOfBirth:
      birthController.text
          .trim()
          .isEmpty
          ? null
          : birthController.text
          .trim(),
      gender:
      gender,
      preferredLanguage:
      preferredLanguage,
    );

    if (!mounted) return;

    if (success) {
      Navigator.pop(
        context,
        true,
      );

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Profile updated successfully.',
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            provider.errorMessage ??
                'Failed to update profile.',
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
          'Edit profile',
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
              nameController,
              decoration:
              const InputDecoration(
                labelText:
                'Name',
                prefixIcon:
                Icon(
                  Icons.person_outline,
                ),
              ),
              validator:
                  (value) {
                if ((value ?? '')
                    .trim()
                    .isEmpty) {
                  return 'Name is required.';
                }

                return null;
              },
            ),

            const SizedBox(
              height: 14,
            ),

            TextFormField(
              controller:
              phoneController,
              keyboardType:
              TextInputType.phone,
              decoration:
              const InputDecoration(
                labelText:
                'Phone',
                prefixIcon:
                Icon(
                  Icons.phone_outlined,
                ),
              ),
            ),

            const SizedBox(
              height: 14,
            ),

            TextFormField(
              controller:
              birthController,
              readOnly: true,
              onTap:
              pickBirthDate,
              decoration:
              const InputDecoration(
                labelText:
                'Date of birth',
                prefixIcon:
                Icon(
                  Icons.cake_outlined,
                ),
                suffixIcon:
                Icon(
                  Icons
                      .calendar_month_outlined,
                ),
              ),
            ),

            const SizedBox(
              height: 14,
            ),

            DropdownButtonFormField<String>(
              value:
              gender,
              decoration:
              const InputDecoration(
                labelText:
                'Gender',
                prefixIcon:
                Icon(
                  Icons.badge_outlined,
                ),
              ),
              items:
              const [
                DropdownMenuItem(
                  value: 'male',
                  child:
                  Text('Male'),
                ),
                DropdownMenuItem(
                  value: 'female',
                  child:
                  Text('Female'),
                ),
                DropdownMenuItem(
                  value: 'other',
                  child:
                  Text('Other'),
                ),
                DropdownMenuItem(
                  value:
                  'prefer_not_to_say',
                  child:
                  Text(
                    'Prefer not to say',
                  ),
                ),
              ],
              onChanged:
                  (value) {
                setState(() {
                  gender = value;
                });
              },
            ),

            const SizedBox(
              height: 14,
            ),

            DropdownButtonFormField<String>(
              value:
              preferredLanguage,
              decoration:
              const InputDecoration(
                labelText:
                'Preferred language',
                prefixIcon:
                Icon(
                  Icons.language_rounded,
                ),
              ),
              items:
              const [
                DropdownMenuItem(
                  value: 'en',
                  child:
                  Text('English'),
                ),
                DropdownMenuItem(
                  value: 'ar',
                  child:
                  Text('Arabic'),
                ),
              ],
              onChanged:
                  (value) {
                if (value == null) {
                  return;
                }

                setState(() {
                  preferredLanguage =
                      value;
                });
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
                style:
                ElevatedButton.styleFrom(
                  backgroundColor:
                  orange,
                  foregroundColor:
                  Colors.white,
                ),
                child: provider
                    .isSubmitting
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child:
                  CircularProgressIndicator(
                    strokeWidth:
                    2,
                    color:
                    Colors.white,
                  ),
                )
                    : const Text(
                  'Save changes',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}