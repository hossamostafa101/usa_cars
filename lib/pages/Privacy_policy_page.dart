import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Text(
          '''
**Privacy Policy for Wheely**

Effective Date: [Insert Date]

Wheely is committed to protecting your privacy. This Privacy Policy explains how we collect, use, and protect your personal data when you use our carpooling mobile application.

**1. Information We Collect**

We may collect the following types of information:

- **Personal Information:** Name, phone number, email address, profile picture.
- **Location Data:** Your GPS location while using the app to offer ride matching and real-time tracking.
- **Usage Data:** App usage data, ride history, device information.
- **Payment Info:** If you use payment services, we may collect billing details (processed via third-party providers like Stripe or PayPal).

**2. How We Use Your Information**

- To match riders and drivers effectively.
- To provide real-time navigation and trip updates.
- To communicate important updates, trip details, and promotions.
- To improve the performance and features of the app.

**3. Sharing Your Information**

We do **not** sell your data. We may share necessary information with:

- Drivers or Riders matched for a ride.
- Third-party services for maps, analytics, or payment processing.
- Law enforcement if legally required.

**4. Data Security**

We use secure encryption and industry-standard practices to protect your data. However, no method is 100% secure.

**5. Your Choices**

- You can update or delete your account information in the app.
- You can revoke location access from your device settings.
- You can request data deletion by contacting us at: support@wheelyapp.com

**6. Children's Privacy**

Wheely is not intended for users under the age of 13. We do not knowingly collect data from children.

**7. Changes to This Policy**

We may update this policy from time to time. You will be notified via the app or email.

**8. Contact Us**

For any questions about this policy, contact us at:
support@wheelyapp.com

Thank you for trusting Wheely.
          ''',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
