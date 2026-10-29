import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({
    super.key,
  });

  static const Color orange =
  Color(0xFFF57C00);

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness ==
            Brightness.dark;

    final textColor = isDark
        ? Colors.white
        : const Color(0xFF172033);

    final secondaryColor = isDark
        ? Colors.white70
        : const Color(0xFF6B7280);

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0B0F16)
          : const Color(0xFFF5F6F8),
      appBar: AppBar(
        title: const Text(
          'Privacy policy',
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          18,
          16,
          18,
          32,
        ),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: orange.withOpacity(.10),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.shield_outlined,
                  color: orange,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'USA Cars respects your privacy. '
                        'This notice explains what information '
                        'the app may use and how your privacy '
                        'settings affect the app.',
                    style: TextStyle(
                      color: textColor,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          _Section(
            title: '1. Information you provide',
            text:
            'USA Cars may use information that you provide '
                'when creating and managing your account, '
                'including your name, email address, phone number, '
                'profile information and saved addresses.',
            textColor: textColor,
            secondaryColor: secondaryColor,
          ),

          _Section(
            title: '2. Vehicle information',
            text:
            'The app may store vehicle information that you '
                'add, such as make, model, year, VIN, mileage, '
                'tire information and other vehicle details. '
                'This information is used to help match parts '
                'and services to your vehicle.',
            textColor: textColor,
            secondaryColor: secondaryColor,
          ),

          _Section(
            title: '3. Orders and service requests',
            text:
            'Information related to marketplace orders, '
                'part requests, repair requests and roadside '
                'assistance may be stored so the requested '
                'service can be provided and its status can '
                'be shown in the app.',
            textColor: textColor,
            secondaryColor: secondaryColor,
          ),

          _Section(
            title: '4. Location information',
            text:
            'Location may be used when you request features '
                'that depend on location, such as nearby repair '
                'providers or roadside assistance. Automatic '
                'location sharing can be turned on or off from '
                'your Profile preferences.',
            textColor: textColor,
            secondaryColor: secondaryColor,
          ),

          _Section(
            title: '5. Roadside live location',
            text:
            'During an active roadside request, location '
                'information may be used to help connect the '
                'customer and assigned roadside provider. '
                'Location should only be used where necessary '
                'for the requested service.',
            textColor: textColor,
            secondaryColor: secondaryColor,
          ),

          _Section(
            title: '6. Notifications and email',
            text:
            'You can choose whether Push notifications and '
                'Email updates are enabled in your Profile '
                'preferences. Email delivery is not currently '
                'enabled in this version of the app.',
            textColor: textColor,
            secondaryColor: secondaryColor,
          ),

          _Section(
            title: '7. Vendors and service providers',
            text:
            'Information necessary to fulfill an order, '
                'repair or roadside request may be made available '
                'to the vendor or service provider involved in '
                'that request.',
            textColor: textColor,
            secondaryColor: secondaryColor,
          ),

          _Section(
            title: '8. Payments',
            text:
            'USA Cars may keep payment and transaction status '
                'associated with orders and services. The app '
                'should not display or store full payment-card '
                'details unless a supported payment system is '
                'implemented for that purpose.',
            textColor: textColor,
            secondaryColor: secondaryColor,
          ),

          _Section(
            title: '9. Your choices',
            text:
            'You can update your profile information, manage '
                'saved addresses, manage vehicles, and change '
                'notification, email and automatic location '
                'preferences from the app.',
            textColor: textColor,
            secondaryColor: secondaryColor,
          ),

          _Section(
            title: '10. Security',
            text:
            'USA Cars uses account authentication and access '
                'controls intended to limit access to account and '
                'service information. No electronic system can '
                'guarantee absolute security.',
            textColor: textColor,
            secondaryColor: secondaryColor,
          ),

          _Section(
            title: '11. Changes to this policy',
            text:
            'This privacy notice may be updated as USA Cars '
                'adds or changes features. The current version '
                'will be available from the Profile page.',
            textColor: textColor,
            secondaryColor: secondaryColor,
          ),

          const SizedBox(height: 8),

          Text(
            'Last updated: October 8, 2026',
            style: TextStyle(
              color: secondaryColor,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final String text;
  final Color textColor;
  final Color secondaryColor;

  const _Section({
    required this.title,
    required this.text,
    required this.textColor,
    required this.secondaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 22,
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: textColor,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            text,
            style: TextStyle(
              color: secondaryColor,
              height: 1.55,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}