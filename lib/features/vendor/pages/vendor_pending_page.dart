import 'package:flutter/material.dart';

class VendorPendingPage extends StatelessWidget {
  final bool isRejected;

  const VendorPendingPage({
    super.key,
    this.isRejected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isRejected ? Icons.cancel : Icons.access_time,
                size: 90,
              ),

              const SizedBox(height: 24),

              Text(
                isRejected
                    ? 'تم رفض حساب الورشة'
                    : 'حساب الورشة قيد المراجعة',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16),

              Text(
                isRejected
                    ? 'يرجى التواصل مع الإدارة.'
                    : 'سيتم مراجعة بيانات الورشة قريبًا.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}