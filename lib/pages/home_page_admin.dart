import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat, NumberFormat;

/// Admin Dashboard (Static Demo)
///
/// - No backend: uses in-memory mock data
/// - RTL friendly (set `useRtl = true` to preview Arabic layout)
/// - Neutral, strong visual design with gray + orange accents for KSA context
/// - Drop this file into `lib/` and use `home: AdminDashboardPage()`
///
/// You can theme the whole app by using the `brandTheme` below.

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Toggle RTL to preview Arabic layout quickly
  final bool useRtl = true;

  @override
  Widget build(BuildContext context) {
    final content = Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.text,
        elevation: 0.5,
        titleSpacing: 0,
        title: Row(
          children: [
            const SizedBox(width: 8),
            // _BrandMark(),
            // const SizedBox(width: 8),
            Text(
              'لوحة التحكم — الإدارة',
              style: const TextStyle(fontWeight: FontWeight.w700).copyWith(color: AppColors.text),
            ),
          ],
        ),
        actions: [
          _GhostIconButton(
            icon: Icons.notifications_outlined,
            onTap: () {},
            badge: 2,
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.gray100,
            child: const Icon(Icons.person, color: AppColors.text, size: 18),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Quick Actions Row
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                runSpacing: 12,
                children: [
                  const _WelcomeBlock(),
                  Wrap(
                    spacing: 8,
                    children: [
                      _PrimaryBtn(
                        label: 'إضافة مشروع',
                        icon: Icons.add_business,
                        onTap: () {},
                      ),
                      _OutlineBtn(
                        label: 'إضافة موظف',
                        icon: Icons.person_add_alt_1,
                        onTap: () {},
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // KPI Cards
              LayoutBuilder(
                builder: (context, c) {
                  return Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _KpiCard(title: 'إجمالي المشاريع', value: '8', icon: Icons.domain, trend: 6),
                      _KpiCard(title: 'مشاريع نشطة', value: '6', icon: Icons.check_circle, trend: 2),
                      _KpiCard(title: 'إجمالي المنصرف', value: _sarAr(1232000), icon: Icons.payments_outlined, trend: 4),
                      _KpiCard(title: 'الرصيد المتبقي', value: _sarAr(3541845), icon: Icons.account_balance_wallet_outlined, trend: -3),
                    ],
                  );
                },
              ),

              const SizedBox(height: 16),

              // Charts + Quick List
              _TwoColumn(
                left: const _MonthlySpendCard(),
                right: const _RecentTransactionsCard(),
              ),

              const SizedBox(height: 16),

              // Projects Table
              const _ProjectsTableCard(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _BottomBar(
        items: const [
          _NavItem('الرئيسية', Icons.dashboard_outlined),
          _NavItem('المشاريع', Icons.apartment_outlined),
          _NavItem('حساب الكميات', Icons.calculate_outlined),
          _NavItem('المهام', Icons.checklist_rounded),
          _NavItem('المزيد', Icons.more_horiz),
        ],
        currentIndex: 0,
        onTap: (i) {},
      ),
    );

    return useRtl
        ? Directionality(textDirection: TextDirection.rtl, child: content)
        : content;
  }
}

/// BRAND / THEME
class AppColors {
  // Orange + Gray palette
  static const Color primary = Color(0xFFFF7A00); // strong orange
  static const Color primaryDark = Color(0xFFCC6200);
  static const Color accent = Color(0xFFFFA24D);

  static const Color surface = Color(0xFFF6F7F8);
  static const Color card = Colors.white;
  static const Color text = Color(0xFF1F2937); // gray-800
  static const Color subtext = Color(0xFF6B7280); // gray-500

  static const Color gray50 = Color(0xFFFAFAFA);
  static const Color gray100 = Color(0xFFF3F4F6);
  static const Color gray200 = Color(0xFFE5E7EB);
  static const Color gray300 = Color(0xFFD1D5DB);
  static const Color success = Color(0xFF16A34A);
  static const Color danger = Color(0xFFDC2626);
}

String _sarAr(num n) {
  final f = NumberFormat.decimalPattern('ar'); // أرقام عربية-هندية
  return 'رسال ${f.format(n)}'; // أو 'ر.س'
}

String _dateAr(DateTime d) {
  final f = DateFormat('yyyy/MM/dd  HH:mm', 'ar');
  return f.format(d);
}

ThemeData brandTheme(BuildContext context) {
  final base = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
    ),
    fontFamily: 'Cairo',
    scaffoldBackgroundColor: AppColors.surface,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: AppColors.text,
      elevation: 0,
    ),
  );
  return base.copyWith(
    textTheme: base.textTheme.apply(
      bodyColor: AppColors.text,
      displayColor: AppColors.text,
    ),
  );
}

class _BrandMark extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.construction, color: Colors.white, size: 18),
        ),
        const SizedBox(width: 8),
        Text('BuildX', style: TextStyle(color: AppColors.text, fontWeight: FontWeight.w700)),
      ],
    );
  }
}

/// WIDGETS
class _WelcomeBlock extends StatelessWidget {
  const _WelcomeBlock();

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 72),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.gray100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.engineering, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('Welcome back, Admin', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              SizedBox(height: 2),
              Text('Manage projects, expenses and teams', style: TextStyle(color: AppColors.subtext)),
            ],
          )
        ],
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final int trend; // + / -
  const _KpiCard({required this.title, required this.value, required this.icon, required this.trend});

  @override
  Widget build(BuildContext context) {
    final isUp = trend >= 0;
    return SizedBox(
      width: 320,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.gray200),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.gray100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: AppColors.subtext, fontSize: 12)),
                  const SizedBox(height: 4),
                  Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                ],
              ),
            ),
            Row(
              children: [
                Icon(isUp ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                    size: 18, color: isUp ? AppColors.success : AppColors.danger),
                const SizedBox(width: 2),
                Text('${trend.abs()}%', style: TextStyle(color: isUp ? AppColors.success : AppColors.danger, fontWeight: FontWeight.w700)),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class _TwoColumn extends StatelessWidget {
  final Widget left;
  final Widget right;
  const _TwoColumn({required this.left, required this.right});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final isWide = c.maxWidth > 820;
        if (isWide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: left),
              const SizedBox(width: 12),
              SizedBox(width: 360, child: right),
            ],
          );
        }
        return Column(
          children: [left, const SizedBox(height: 12), right],
        );
      },
    );
  }
}

class _MonthlySpendCard extends StatelessWidget {
  const _MonthlySpendCard();
  @override
  Widget build(BuildContext context) {
    const data = <_Bar>[
      _Bar('Jan', 120000.0),
      _Bar('Feb',  90000.0),
      _Bar('Mar', 150000.0),
      _Bar('Apr', 110000.0),
      _Bar('May', 170000.0),
      _Bar('Jun', 130000.0),
    ];

    return _Card(
      title: 'المصروفات الشهرية',
      trailing: _GhostIconButton(icon: Icons.download_outlined, onTap: () {}),
      child: SizedBox(
        height: 220,
        child: _SimpleBarChart(data: data),
      ),
    );
  }
}

class _RecentTransactionsCard extends StatelessWidget {
  const _RecentTransactionsCard();
  @override
  Widget build(BuildContext context) {
    final items = [
      _Tx(
        title: 'وقود — موقع أ',
        date: DateTime(2025, 11, 2, 23, 42),
        amount: 160,
        tag: 'صيانة',
      ),
      _Tx(
        title: 'خرسانة — صب البلاطة',
        date: DateTime(2025, 11, 5, 13, 39),
        amount: 7500,
        tag: 'أعمال هيكل',
      ),
      _Tx(
        title: 'ضريبة التصرف العقاري (5%)',
        date: DateTime(2025, 11, 10),
        amount: 7500,
        tag: 'رسوم',
      ),
    ];

    return _Card(
      title: 'آخر المعاملات',
      child: Column(
        children: [
          for (final tx in items) _TxTile(tx: tx),
          const SizedBox(height: 6),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.receipt_long_outlined),
              label: const Text('عرض الكل'),
            ),
          )
        ],
      ),
    );
  }
}


class _ProjectsTableCard extends StatelessWidget {
  const _ProjectsTableCard();
  @override
  Widget build(BuildContext context) {
    final rows = [
      const _ProjectRow('برج الزمرد',          'Active',  18155,  3560000, 3541845, 35),
      const _ProjectRow('فيلا روز جاردن',      'Active',  159098,  450000,  290902, 35),
      const _ProjectRow('الماسة السكني',       'Paused',  124343, 1200000,  875657, 22),
      const _ProjectRow('زِرْنوق دهب',         'Planned',      0,  980000,  980000,  0),
    ];

    return _Card(
      title: 'Projects',
      trailing: _OutlineBtn(label: 'Add Project', icon: Icons.add, onTap: () {}),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('الاسم')),
            DataColumn(label: Text('الحالة')),
            DataColumn(label: Text('المنصرف')),
            DataColumn(label: Text('المتوقّع')),
            DataColumn(label: Text('المتبقي')),
            DataColumn(label: Text('التقدّم')),
          ],
          rows: [
            for (final r in rows)
              DataRow(cells: [
                DataCell(Text(r.name)),
                DataCell(_StatusPill(status: r.status)),
                DataCell(Text('SAR ${_fmt(r.spent)}')),
                DataCell(Text('SAR ${_fmt(r.expected)}')),
                DataCell(Text('SAR ${_fmt(r.remaining)}')),
                DataCell(_ProgressBar(value: r.progress / 100)),
              ])
          ],
        ),
      ),
    );
  }
}

class _ProjectRow {
  final String name;
  final String status;
  final num spent;
  final num expected;
  final num remaining;
  final int progress;
  const _ProjectRow(this.name, this.status, this.spent, this.expected, this.remaining, this.progress);
}

String _fmt(num n) {
  return n.toStringAsFixed(0).replaceAllMapped(RegExp(r"(\d)(?=(\d{3})+(?!\d))"), (m) => '${m[1]},');
}

class _StatusPill extends StatelessWidget {
  final String status;
  const _StatusPill({required this.status});
  @override
  Widget build(BuildContext context) {
    Color c = AppColors.gray300;
    Color t = AppColors.text;
    if (status.toLowerCase() == 'active') {
      c = const Color(0xFFEFFAF1);
      t = AppColors.success;
    } else if (status.toLowerCase() == 'paused') {
      c = const Color(0xFFFFF7ED);
      t = AppColors.primaryDark;
    } else if (status.toLowerCase() == 'planned') {
      c = const Color(0xFFEFF6FF);
      t = const Color(0xFF2563EB);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(999)),
      child: Text(status, style: TextStyle(color: t, fontWeight: FontWeight.w700)),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final double value; // 0..1
  const _ProgressBar({required this.value});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: LinearProgressIndicator(
          minHeight: 10,
          value: value,
          backgroundColor: AppColors.gray200,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

/// Simple bar chart without external packages
class _SimpleBarChart extends StatelessWidget {
  final List<_Bar> data;
  const _SimpleBarChart({required this.data});
  @override
  Widget build(BuildContext context) {
    final maxV = data.map((e) => e.v).fold<num>(0, (p, c) => c > p ? c : p).toDouble();

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gray200),
      ),
      child: LayoutBuilder(
        builder: (context, c) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              for (final b in data)
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      width: 28,
                      height: (c.maxHeight - 48) * (b.v / maxV),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, AppColors.accent],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(b.label, style: const TextStyle(color: AppColors.subtext, fontSize: 12)),
                  ],
                )
            ],
          );
        },
      ),
    );
  }
}

class _Bar {
  final String label;
  final double v;
  const _Bar(this.label, this.v);
}

class _Tx {
  final String title;
  final DateTime date;
  final num amount;
  final String tag;
  _Tx({required this.title, required this.date, required this.amount, required this.tag});
}

class _TxTile extends StatelessWidget {
  final _Tx tx;
  const _TxTile({required this.tx});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.gray50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.receipt_long_outlined, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tx.title, style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text('${tx.tag} • ${_dateFmt(tx.date)}', style: const TextStyle(color: AppColors.subtext, fontSize: 12)),
              ],
            ),
          ),
          Text('SAR ${_fmt(tx.amount)}', style: const TextStyle(fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

String _dateFmt(DateTime d) {
  final two = (int x) => x.toString().padLeft(2, '0');
  return '${d.year}-${two(d.month)}-${two(d.day)}  ${two(d.hour)}:${two(d.minute)}';
}

class _Card extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? trailing;
  const _Card({required this.title, required this.child, this.trailing});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
              const Spacer(),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _PrimaryBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  const _PrimaryBtn({required this.label, required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      label: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
    );
  }
}

class _OutlineBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  const _OutlineBtn({required this.label, required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.text,
        side: const BorderSide(color: AppColors.gray300),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: onTap,
      icon: Icon(icon, size: 18, color: AppColors.text),
      label: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
    );
  }
}

class _GhostIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final int? badge;
  const _GhostIconButton({required this.icon, required this.onTap, this.badge});
  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          onPressed: onTap,
          icon: Icon(icon, color: AppColors.text),
        ),
        if (badge != null && badge! > 0)
          Positioned(
            right: 4,
            top: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.danger,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text('$badge', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
            ),
          ),
      ],
    );
  }
}

class _BottomBar extends StatelessWidget {
  final List<_NavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;
  const _BottomBar({required this.items, required this.currentIndex, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, -2))]),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              for (int i = 0; i < items.length; i++)
                _BottomTab(
                  item: items[i],
                  active: i == currentIndex,
                  onTap: () => onTap(i),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomTab extends StatelessWidget {
  final _NavItem item;
  final bool active;
  final VoidCallback onTap;
  const _BottomTab({required this.item, required this.active, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(item.icon, color: active ? AppColors.primary : AppColors.subtext),
            const SizedBox(height: 4),
            Text(item.label, style: TextStyle(color: active ? AppColors.primary : AppColors.subtext, fontWeight: active ? FontWeight.w800 : FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

class _NavItem {
  final String label;
  final IconData icon;
  const _NavItem(this.label, this.icon);
}
