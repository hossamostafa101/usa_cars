import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_paymob/flutter_paymob.dart';
import 'package:flutter_paymob/paymob_response.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const PaymobPaymentPage(rideFee: 100),
      debugShowCheckedModeBanner: false,
    );
  }
}

class PaymobPaymentPage extends StatefulWidget {
  final double rideFee;

  const PaymobPaymentPage({Key? key, required this.rideFee}) : super(key: key);

  @override
  State<PaymobPaymentPage> createState() => _PaymobPaymentPageState();
}

class _PaymobPaymentPageState extends State<PaymobPaymentPage> {
  bool _isLoading = false;
  String? _selectedPaymentMethod;
  bool _isInitialized = false;

  final String apiKey = 'ZXlKaGJHY2lPaUpJVXpVeE1pSXNJblI1Y0NJNklrcFhWQ0o5LmV5SmpiR0Z6Y3lJNklrMWxjbU5vWVc1MElpd2ljSEp2Wm1sc1pWOXdheUk2T1RneE1UVTVMQ0p1WVcxbElqb2lhVzVwZEdsaGJDSjkuX04xODBoMlpiNldtTk9CMHJPM1kwdVdrUlVJWVhyeDZuU3B6clFhNXpIaGxEVkJHaGRiMXZQazF5dl9VbUd3X0pQOVhUblR5c3dqZ0hZX2lWQmo0emc=';
  final String iframeId = '851711';
  final String cardIntegrationId = '4595833';
  final String walletIntegrationId = '4597454';

  @override
  void initState() {
    super.initState();
    _initializePaymob();
  }

  Future<void> _initializePaymob() async {
    try {
      await FlutterPaymob.instance.initialize(
        apiKey: apiKey,
        integrationID: int.parse(cardIntegrationId),
        walletIntegrationId: int.parse(walletIntegrationId),
        iFrameID: int.parse(iframeId),
      );

      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      print('Paymob initialization error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل تهيئة Paymob: $e')),
      );
      setState(() {
        _isInitialized = false;
      });
    }
  }

  Future<void> _processPayment() async {
    if (_selectedPaymentMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى اختيار طريقة الدفع')),
      );
      return;
    }

    if (!_isInitialized) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Paymob غير مهيأ.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      if (_selectedPaymentMethod == 'Visa') {
        await FlutterPaymob.instance.payWithCard(
          context: context,
          currency: 'EGP',
          amount: widget.rideFee,
          onPayment: (PaymentPaymobResponse res) {
            print('Paymob card response: $res');
            Navigator.pop(context);
          },
        );
      } else {
        // Wallet payment via WebView
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WalletPaymentScreen(
              rideFee: widget.rideFee,
              apiKey: apiKey,
              walletIntegrationId: walletIntegrationId,
            ),
          ),
        );
      }
    } catch (e) {
      print('Payment error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ في الدفع: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('دفع رسوم الرحلة'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ادفع لرحلتك المشتركة',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.teal,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'رسوم الرحلة: ${widget.rideFee} ج.م',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 24),
            Text(
              'اختر طريقة الدفع',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _PaymentMethodButton(
                  icon: Icons.credit_card,
                  label: 'فيزا',
                  isSelected: _selectedPaymentMethod == 'Visa',
                  onTap: () {
                    setState(() {
                      _selectedPaymentMethod = 'Visa';
                    });
                  },
                ),
                _PaymentMethodButton(
                  icon: Icons.account_balance_wallet,
                  label: 'محفظة',
                  isSelected: _selectedPaymentMethod == 'Wallet',
                  onTap: () {
                    setState(() {
                      _selectedPaymentMethod = 'Wallet';
                    });
                  },
                ),
              ],
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading || !_isInitialized ? null : _processPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('ادفع الآن'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentMethodButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _PaymentMethodButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? Colors.teal : Colors.grey,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8),
          color: isSelected ? Colors.teal.withOpacity(0.1) : Colors.white,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 40,
              color: isSelected ? Colors.teal : Colors.grey,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.teal : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PaymentSuccessScreen extends StatelessWidget {
  const PaymentSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الدفع ناجح')),
      body: const Center(child: Text('تم الدفع بنجاح', style: TextStyle(fontSize: 24))),
    );
  }
}

class WalletPaymentScreen extends StatefulWidget {
  final double rideFee;
  final String apiKey;
  final String walletIntegrationId;

  const WalletPaymentScreen({
    super.key,
    required this.rideFee,
    required this.apiKey,
    required this.walletIntegrationId,
  });

  @override
  State<WalletPaymentScreen> createState() => _WalletPaymentScreenState();
}

class _WalletPaymentScreenState extends State<WalletPaymentScreen> {
  late WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            print('WebView pages started: $url');
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (url) {
            print('WebView pages finished: $url');
            setState(() {
              _isLoading = false;
            });
          },
          onNavigationRequest: (request) {
            print('WebView navigation request: ${request.url}');
            if (request.url.contains('koshycoding.com/koshy/paymob')) {
              print('Paymob redirect detected: ${request.url}');
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const PaymentSuccessScreen()),
              );
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      );

    // Initialize wallet payment
    _startWalletPayment();
  }

  Future<void> _startWalletPayment() async {
    try {
      final response = await FlutterPaymob.instance.payWithWallet(
        context: context,
        currency: 'EGP',
        amount: widget.rideFee,
        number: '01010101010',
        // returnUrl: true,
        onPayment: (PaymentPaymobResponse res) {
          print('Paymob wallet response: $res');
        },
      );
      print('Wallet payment URL: $response');
      if (response != null && response is String && response.startsWith('https://')) {
        await _controller.loadRequest(Uri.parse(response));
      } else {
        throw Exception('Invalid wallet payment URL');
      }
    } catch (e) {
      print('Wallet payment error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ في دفع المحفظة: $e')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('دفع المحفظة')),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}