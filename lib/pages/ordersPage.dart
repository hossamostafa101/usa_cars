// lib/pages/ordersPage.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:talabatfresh/pages/CourseLearningPage.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}
enum _FilterKey { all, pending, paid, failed, refunded }

class _Filter {
  final String label;
  final _FilterKey v;
  const _Filter({required this.label, required this.v});
}
class _OrdersPageState extends State<OrdersPage> {
  final TextEditingController _search = TextEditingController();

  final List<_Order> _all = [
    _Order(
      id: 'ORD-10293',
      date: DateTime(2025, 10, 2, 14, 20),
      status: _OrderStatus.paid,
      total: 399,
      method: 'بطاقة بنكية',
      hasInvoice: true,
      items: const [
        _OrderItem(
          title: 'أساسيات طب الطوارئ',
          thumbnail: 'https://free4arab.net/wp-content/uploads/2025/10/HCCDA-Tech-Essentials.jpg',
        ),
      ],
    ),
    _Order(
      id: 'ORD-10258',
      date: DateTime(2025, 9, 24, 11, 5),
      status: _OrderStatus.pending,
      total: 349,
      method: 'فودافون كاش',
      hasInvoice: false,
      items: const [
        _OrderItem(
          title: 'تشريح إشعاعي عملي',
          thumbnail: 'https://resources.reed.co.uk/courses/coursemedia/457387/90c0e62b-7717-494d-aacb-a02df76bcf2e_cover.webp',
        ),
      ],
    ),
    _Order(
      id: 'ORD-10177',
      date: DateTime(2025, 9, 10, 18, 40),
      status: _OrderStatus.failed,
      total: 429,
      method: 'بطاقة بنكية',
      hasInvoice: false,
      items: const [
        _OrderItem(
          title: 'مراجعة ECG متقدمة',
          thumbnail: 'https://cdn-az.allevents.in/events5/banners/d0420d454ff6e56912227bc6da061e65f054d1993c7c3f17c48f61953f6ea93a-rimg-w1200-h628-dcd4d4d5-gmir?v=1758773622',
        ),
      ],
    ),
    _Order(
      id: 'ORD-10112',
      date: DateTime(2025, 8, 29, 9, 15),
      status: _OrderStatus.refunded,
      total: 319,
      method: 'فوري',
      hasInvoice: true,
      items: const [
        _OrderItem(
          title: 'علم الأدوية السريري',
          thumbnail: 'https://blog.jobzella.com/wp-content/uploads/2025/05/Fresh_Graduate_Discover_the_Best_Jobs_and_Career_Programs_in_Egypt_2025_-scaled.jpg',
        ),
      ],
    ),
  ];

  final List<_Filter> _filters = const [
    _Filter(label: 'الكل', v: _FilterKey.all),
    _Filter(label: 'قيد المراجعة', v: _FilterKey.pending),
    _Filter(label: 'مدفوع', v: _FilterKey.paid),
    _Filter(label: 'فشل', v: _FilterKey.failed),
    _Filter(label: 'مسترد', v: _FilterKey.refunded),
  ];

  _FilterKey _current = _FilterKey.all;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<_Order> get _filtered {
    final q = _search.text.trim();
    bool byFilter(_Order o) {
      switch (_current) {
        case _FilterKey.all:
          return true;
        case _FilterKey.pending:
          return o.status == _OrderStatus.pending;
        case _FilterKey.paid:
          return o.status == _OrderStatus.paid;
        case _FilterKey.failed:
          return o.status == _OrderStatus.failed;
        case _FilterKey.refunded:
          return o.status == _OrderStatus.refunded;
      }
    }

    bool byQuery(_Order o) {
      if (q.isEmpty) return true;
      return o.id.contains(q) ||
          o.items.any((it) => it.title.contains(q));
    }

    final out = _all.where((o) => byFilter(o) && byQuery(o)).toList();
    // أحدث فاتورة أولاً
    out.sort((a, b) => b.date.compareTo(a.date));
    return out;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('طلباتي'),
          centerTitle: true,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(56),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: _SearchBar(
                controller: _search,
                hint: 'ابحث برقم الطلب أو اسم الدورة…',
                onChanged: (_) => setState(() {}),
              ),
            ),
          ),
        ),

        // مهم: فيه Bottom Nav، فخلّي SafeArea(bottom:true)
        body: SafeArea(
          top: false,
          bottom: true,
          child: RefreshIndicator(
            onRefresh: () async {
              HapticFeedback.lightImpact();
              await Future<void>.delayed(const Duration(milliseconds: 500));
            },
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
              slivers: [
                // شريط الفلاتر
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
                    child: _FiltersStrip(
                      filters: _filters,
                      current: _current,
                      onTap: (f) => setState(() => _current = f),
                    ),
                  ),
                ),

                // عدد النتائج
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Text('الطلبات: ${_filtered.length}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            )),
                        const Spacer(),
                        const Icon(Icons.receipt_long_rounded, size: 18),
                        const SizedBox(width: 6),
                        Text('أحدث أولاً', style: theme.textTheme.bodySmall),
                      ],
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 8)),

                // القائمة
                SliverList.builder(
                  itemCount: _filtered.length,
                  itemBuilder: (context, i) {
                    final o = _filtered[i];
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
                      child: _OrderCard(
                        data: o,
                        onDetails: () => _openDetails(o),
                        onInvoice: o.hasInvoice ? () => _showInvoice(o) : null,
                        onPayAgain: o.status == _OrderStatus.failed || o.status == _OrderStatus.pending
                            ? () => _payAgain(o)
                            : null,
                      ),
                    );
                  },
                ),

                // مسافة سفلية علشان البار السفلي
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openDetails(_Order o) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CourseLearningPage.demo(), // لاحقًا مرّر الداتا الحقيقية
      ),
    );
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(builder: (_) => _OrderDetailsPage(order: o)),
    // );
  }

  void _showInvoice(_Order o) {
    showDialog(
      context: context,
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('فاتورة (عرض تجريبي)'),
          content: Text('رقم الطلب: ${o.id}\nالمبلغ: ${o.total} ج.م\nطريقة الدفع: ${o.method}'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('إغلاق')),
          ],
        ),
      ),
    );
  }

  void _payAgain(_Order o) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('إعادة الدفع للطلب ${o.id}', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              const Text('هنا سيتم دمج بوابة الدفع لاحقًا (Paymob).'),
              const SizedBox(height: 16),
              FilledButton(onPressed: () => Navigator.pop(context), child: const Text('متابعة')),
            ],
          ),
        ),
      ),
    );
  }
}

/// ====== UI PIECES ======

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final ValueChanged<String>? onChanged;
  const _SearchBar({required this.controller, required this.hint, this.onChanged});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(.85),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor.withOpacity(.08)),
      ),
      child: Row(
        children: [
          const SizedBox(width: 10),
          const Icon(Icons.search_rounded, size: 20),
          const SizedBox(width: 6),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: hint,
                border: InputBorder.none,
              ),
            ),
          ),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (_, v, __) => v.text.isEmpty
                ? const SizedBox(width: 10)
                : IconButton(
              tooltip: 'مسح',
              onPressed: () {
                controller.clear();
                onChanged?.call('');
              },
              icon: const Icon(Icons.close_rounded, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}

class _FiltersStrip extends StatelessWidget {
  final List<_Filter> filters;
  final _FilterKey current;
  final ValueChanged<_FilterKey> onTap;
  const _FiltersStrip({required this.filters, required this.current, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        reverse: true,
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final f = filters[i];
          final selected = f.v == current;
          return ChoiceChip(
            label: Text(f.label),
            selected: selected,
            onSelected: (_) => onTap(f.v),
            labelStyle: theme.textTheme.bodyMedium?.copyWith(
              color: selected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface,
            ),
            selectedColor: theme.colorScheme.primary,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
          );
        },
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final _Order data;
  final VoidCallback onDetails;
  final VoidCallback? onInvoice;
  final VoidCallback? onPayAgain;
  const _OrderCard({
    required this.data,
    required this.onDetails,
    this.onInvoice,
    this.onPayAgain,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withOpacity(.06)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(.04), blurRadius: 12, offset: const Offset(0, 6)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // header: id + status
            Row(
              children: [
                Expanded(
                  child: Text(
                    data.id,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                  ),
                ),
                const SizedBox(width: 8),
                _StatusBadge(status: data.status),
              ],
            ),
            const SizedBox(height: 6),

            // date + method
            Row(
              children: [
                Icon(Icons.calendar_today_rounded, size: 14, color: theme.colorScheme.onSurfaceVariant),
                const SizedBox(width: 6),
                Text(_fmtDate(data.date), style: theme.textTheme.bodySmall),
                const SizedBox(width: 14),
                Icon(Icons.payments_rounded, size: 14, color: theme.colorScheme.onSurfaceVariant),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    data.method,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // items thumbs + titles (first item)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Thumb(url: data.items.first.thumbnail),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    data.items.first.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                if (data.items.length > 1) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text('+${data.items.length - 1}', style: theme.textTheme.labelSmall),
                  )
                ],
              ],
            ),
            const SizedBox(height: 10),

            // price + actions (Wrap to avoid overflow)
            LayoutBuilder(
              builder: (ctx, c) {
                final compact = c.maxWidth < 330;
                return Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('الإجمالي: ',
                            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                        Text('${data.total} ج.م',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w800,
                            )),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (onInvoice != null)
                          OutlinedButton.icon(
                            onPressed: onInvoice,
                            icon: const Icon(Icons.receipt_long_rounded, size: 18),
                            label: const Text('فاتورة'),
                          ),
                        if (!compact) const SizedBox(width: 8),
                        if (onPayAgain != null)
                          OutlinedButton.icon(
                            onPressed: onPayAgain,
                            icon: const Icon(Icons.payment_rounded, size: 18),
                            label: const Text('إعادة الدفع'),
                          ),
                        if (!compact) const SizedBox(width: 8),
                        FilledButton(
                          onPressed: onDetails,
                          child: const Text('التفاصيل'),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _Thumb extends StatelessWidget {
  final String url;
  const _Thumb({required this.url});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        width: 72,
        height: 56,
        child: Image.network(
          url,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            color: Colors.grey.shade200,
            child: const Center(child: Icon(Icons.image_not_supported)),
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final _OrderStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final data = _statusData(status, theme);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: data.bg, borderRadius: BorderRadius.circular(999)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(data.icon, size: 14, color: data.fg),
          const SizedBox(width: 4),
          Text(data.label, style: theme.textTheme.labelSmall?.copyWith(color: data.fg, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  _BadgeData _statusData(_OrderStatus s, ThemeData t) {
    switch (s) {
      case _OrderStatus.pending:
        return _BadgeData('قيد المراجعة', Icons.hourglass_bottom_rounded, t.colorScheme.secondary, t.colorScheme.onSecondary);
      case _OrderStatus.paid:
        return _BadgeData('مدفوع', Icons.check_circle_rounded, Colors.green.shade100, Colors.green.shade800);
      case _OrderStatus.failed:
        return _BadgeData('فشل', Icons.error_rounded, Colors.orange.shade100, Colors.orange.shade800);
      case _OrderStatus.refunded:
        return _BadgeData('مسترد', Icons.undo_rounded, t.colorScheme.secondaryContainer, t.colorScheme.onSecondaryContainer);
    }
  }
}

class _BadgeData {
  final String label;
  final IconData icon;
  final Color bg;
  final Color fg;
  _BadgeData(this.label, this.icon, this.bg, this.fg);
}

/// ====== DETAILS PAGE (static) ======

class _OrderDetailsPage extends StatelessWidget {
  final _Order order;
  const _OrderDetailsPage({required this.order});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('تفاصيل الطلب')),
        body: SafeArea(
          bottom: true,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // header
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.dividerColor.withOpacity(.06)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(order.id, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
                          const SizedBox(height: 4),
                          Text(_fmtDate(order.date),
                              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                        ],
                      ),
                    ),
                    _StatusBadge(status: order.status),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // items
              ...order.items.map((it) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Thumb(url: it.thumbnail),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(it.title,
                          maxLines: 3, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodyLarge),
                    ),
                  ],
                ),
              )),

              const SizedBox(height: 8),
              const Divider(),
              const SizedBox(height: 8),

              // payment summary
              Row(
                children: [
                  const Icon(Icons.payments_rounded, size: 18),
                  const SizedBox(width: 6),
                  Text('طريقة الدفع: ${order.method}', style: theme.textTheme.bodyMedium),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Text('الإجمالي:', style: theme.textTheme.bodyMedium),
                  const SizedBox(width: 6),
                  Text('${order.total} ج.م',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w800,
                      )),
                ],
              ),
              const SizedBox(height: 16),

              // actions
              Row(
                children: [
                  if (order.hasInvoice)
                    OutlinedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.receipt_long_rounded),
                      label: const Text('عرض الفاتورة'),
                    ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('تم'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

/// ====== MODELS ======

enum _OrderStatus { pending, paid, failed, refunded }

class _Order {
  final String id;
  final DateTime date;
  final _OrderStatus status;
  final int total;
  final String method;
  final bool hasInvoice;
  final List<_OrderItem> items;

  const _Order({
    required this.id,
    required this.date,
    required this.status,
    required this.total,
    required this.method,
    required this.hasInvoice,
    required this.items,
  });
}

class _OrderItem {
  final String title;
  final String thumbnail;
  const _OrderItem({required this.title, required this.thumbnail});
}

/// ====== HELPERS ======

String _fmtDate(DateTime d) {
  // تنسيق بسيط عربي (YYYY/MM/DD HH:mm)
  final y = d.year.toString().padLeft(4, '0');
  final m = d.month.toString().padLeft(2, '0');
  final day = d.day.toString().padLeft(2, '0');
  final hh = d.hour.toString().padLeft(2, '0');
  final mm = d.minute.toString().padLeft(2, '0');
  return '$y/$m/$day  $hh:$mm';
}
