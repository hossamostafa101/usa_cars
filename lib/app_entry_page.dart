import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:talabatfresh/features/home/pages/customer_home_page.dart';
import 'package:talabatfresh/features/vendor/pages/vendor_home_page.dart';
import 'package:talabatfresh/features/vendor/pages/vendor_pending_page.dart';
import 'package:talabatfresh/features/auth/pages/login_page.dart';
import 'package:talabatfresh/providers/auth_provider.dart';
import 'package:talabatfresh/widgets/RootShell.dart';

import 'core/enums/account_type.dart';
import 'core/enums/auth_status.dart';

class AppEntryPage extends StatefulWidget {
  const AppEntryPage({super.key});

  @override
  State<AppEntryPage> createState() => _AppEntryPageState();
}

class _AppEntryPageState extends State<AppEntryPage> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<AuthProvider>().initAuth();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (_, auth, __) {
        // loading
        if (auth.authStatus == AuthStatus.initial ||
            auth.authStatus == AuthStatus.loading) {
          return const _LoadingPage();
        }

        // not logged in
        if (auth.authStatus == AuthStatus.unauthenticated) {
          return const LoginPage();
        }

        // vendor pending
        if (auth.authStatus == AuthStatus.vendorPending) {
          return const VendorPendingPage();
        }

        // vendor rejected
        if (auth.authStatus == AuthStatus.vendorRejected) {
          return const VendorPendingPage(
            isRejected: true,
          );
        }

        // authenticated
        if (auth.authStatus == AuthStatus.authenticated) {
          if (auth.accountType == AccountType.vendor) {
            return const VendorHomePage();
          }

          return const RootShell();
        }

        // fallback
        return const LoginPage();
      },
    );
  }
}

class _LoadingPage extends StatelessWidget {
  const _LoadingPage();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}