import 'dart:ui';

import 'package:flutter/material.dart';
import 'hexbutton.dart';

class BuildBottomNavBar extends StatelessWidget {
  final int currIndex;
  final ValueChanged<int> onTap;
  final VoidCallback onCenterTap;

  const BuildBottomNavBar({
    super.key,
    required this.currIndex,
    required this.onTap,
    required this.onCenterTap,
  });

  // ترجمة بسيطة حسب اتجاه الواجهة
  String _t(BuildContext ctx, String en, String ar) {
    return Directionality.of(ctx) == TextDirection.rtl ? ar : ar;
  }

  Widget _navItem({
    required int index,
    required IconData icon,
    required String title,
    required BuildContext context,
  }) {
    final theme = Theme.of(context);
    final selected = currIndex == index;

    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              child: AnimatedScale(
                scale: selected ? 1.12 : 1.0,
                duration: const Duration(milliseconds: 180),
                child: Icon(
                  icon,
                  size: selected ? 24 : 22,
                  color: selected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 180),
              style: TextStyle(
                fontSize: 10,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface.withOpacity(0.6),
                letterSpacing: 0.1,
              ),
              child: Text(title, overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SafeArea(
      top: false,
      child: SizedBox(
        height: 88,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.bottomCenter,
          children: [
            // خلفية البار (زجاجي خفيف)
            Positioned(
              left: 16,
              right: 16,
              bottom: 18,
              height: 60,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: isDark
                            ? [
                          const Color(0xFF0B0F0C).withOpacity(0.90),
                          const Color(0xFF0B0F0C).withOpacity(0.96),
                        ]
                            : [
                          Colors.white.withOpacity(0.95),
                          Colors.white.withOpacity(0.98),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withOpacity(0.06)
                            : const Color(0xFFFFC400).withOpacity(0.12),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFFA800)
                              .withOpacity(isDark ? 0.18 : 0.10),
                          blurRadius: 22,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // 0: Home
                        Expanded(
                          child: _navItem(
                            index: 0,
                            icon: Icons.home_rounded,
                            title: 'Home',
                            context: context,
                          ),
                        ),
                        // 1: Parts (Marketplace)
                        Expanded(
                          child: _navItem(
                            index: 1,
                            icon: Icons.build_circle_rounded,
                            title: 'Parts',
                            context: context,
                          ),
                        ),
                        const SizedBox(width: 80), // center button space
                        // 3: Repairs (Workshops / Services)
                        Expanded(
                          child: _navItem(
                            index: 3,
                            icon: Icons.home_repair_service_rounded,
                            title: 'Repairs',
                            context: context,
                          ),
                        ),
                        // 4: Profile
                        Expanded(
                          child: _navItem(
                            index: 4,
                            icon: Icons.person_rounded,
                            title: 'Profile',
                            context: context,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Center button: Roadside / Help Now
            Positioned(
              bottom: 48,
              child: HexagonButton(
                size: const Size(64, 64),
                lift: 0,
                onTap: onCenterTap, // اربطه بتاب/شاشة الطوارئ (index 2 في RootShell مثلاً)
                child: const Icon(
                  Icons.electric_bolt_rounded,
                  size: 26,
                  color: Colors.white,
                ),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFE6890D),
                    Color(0xFFC55E07),
                  ],
                ),
                highlightGradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x66FFFFFF),
                    Color(0xFFFFFF),
                  ],
                ),
                borderColor: Colors.white.withOpacity(0.22),
                borderWidth: 1.4,
                shadowBlur: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}