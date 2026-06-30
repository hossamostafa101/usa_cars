import 'dart:async';

import 'package:flutter/material.dart';
import 'package:talabatfresh/features/marketplace/page/parts_page.dart';
import 'package:talabatfresh/features/repair/pages/repairs_page.dart';
import 'package:talabatfresh/features/roadside/pages/roadside_page.dart';
import 'package:talabatfresh/features/home/pages/customer_home_page.dart';
import 'package:talabatfresh/features/profile/pages/profile_page.dart';
import 'package:talabatfresh/widgets/bottom_nav_bar.dart';

class RootShell extends StatefulWidget {
  const RootShell({super.key});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;


  late List<Widget> _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = [
      _KeepAlive(child: HomePage(
        onTapParts: () => _onItemTapped(1),
        onTapRoadside: () => _onItemTapped(2),
        onTapRepairs: () => _onItemTapped(3),
        onTapTires: () => _onItemTapped(2),
      )),
      const _KeepAlive(child: PartsPage()),
      const _KeepAlive(child: RoadsidePage()),
      const _KeepAlive(child: RepairsPage()),
      const _KeepAlive(child: ProfilePage()),
    ];
  }

  void _onItemTapped(int index) {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _currentIndex = index);
    _pageController.jumpToPage(index);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // لخلفية شفافة جميلة تحت البار
      bottomNavigationBar: BuildBottomNavBar(
        currIndex: _currentIndex,
        onTap: (i) {
          if (i == 2) return;
          _onItemTapped(i);
        },
        onCenterTap: () => _onItemTapped(2),
      ),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: _tabs,
      ),
    );
  }
}

class _KeepAlive extends StatefulWidget {
  final Widget child;
  const _KeepAlive({required this.child});

  @override
  State<_KeepAlive> createState() => _KeepAliveState();
}

class _KeepAliveState extends State<_KeepAlive>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}
