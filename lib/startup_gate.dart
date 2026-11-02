import 'package:flutter/material.dart';

/// Draws the first frame before initializing platform services.
class StartupGate extends StatefulWidget {
  const StartupGate({
    super.key,
    required this.initialize,
    required this.builder,
    this.timeout = const Duration(seconds: 30),
  });

  final Future<void> Function() initialize;
  final WidgetBuilder builder;
  final Duration timeout;

  @override
  State<StartupGate> createState() => _StartupGateState();
}

class _StartupGateState extends State<StartupGate> {
  late Future<void> _initialization;

  @override
  void initState() {
    super.initState();
    _initialization = _initialize();
  }

  Future<void> _initialize() async {
    // Let Flutter render a loading frame before invoking native plugins.
    await WidgetsBinding.instance.endOfFrame;
    try {
      await widget.initialize().timeout(widget.timeout);
    } catch (error, stack) {
      debugPrint('Application startup failed: $error\n$stack');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initialization,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            !snapshot.hasError) {
          return widget.builder(context);
        }
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          home: Scaffold(
            body: SafeArea(
              child: Center(
                child:
                    snapshot.hasError
                        ? Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('Unable to start Qotomoto.'),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                              setState(() {
                                _initialization = _initialize();
                              });
                              },
                              child: const Text('Retry'),
                            ),
                          ],
                        )
                        : const Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 16),
                            Text('Starting Qotomoto…'),
                          ],
                        ),
              ),
            ),
          ),
        );
      },
    );
  }
}
