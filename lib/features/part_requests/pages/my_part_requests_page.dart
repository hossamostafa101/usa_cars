import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/models/part_request_model.dart';
import '../providers/part_request_provider.dart';
import 'create_part_request_page.dart';
import 'part_request_details_page.dart';

class MyPartRequestsPage extends StatefulWidget {
  const MyPartRequestsPage({super.key});

  static const Color accent = Color(0xFFF57C00);
  static const Color background = Color(0xFFF7F8FA);

  @override
  State<MyPartRequestsPage> createState() => _MyPartRequestsPageState();
}

class _MyPartRequestsPageState extends State<MyPartRequestsPage> {
  final TextEditingController _searchController = TextEditingController();
  String _statusFilter = 'all';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<PartRequestProvider>().loadRequests();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _newRequest() async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute(builder: (_) => const CreatePartRequestPage()),
    );
    if (!mounted) return;
    await context.read<PartRequestProvider>().loadRequests();
  }

  Future<void> _openRequest(int requestId) async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) => PartRequestDetailsPage(requestId: requestId),
      ),
    );
    if (!mounted) return;
    await context.read<PartRequestProvider>().loadRequests();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PartRequestProvider>();
    final all = provider.requests;
    final statuses = all.map((item) => item.status).toSet().toList()..sort();
    final selectedStatus =
    _statusFilter != 'all' && statuses.contains(_statusFilter)
        ? _statusFilter
        : 'all';
    final query = _searchController.text.trim().toLowerCase();
    final visible = all.where((request) {
      final matchesStatus =
          selectedStatus == 'all' || request.status == selectedStatus;
      final matchesSearch = query.isEmpty ||
          request.partPath.toLowerCase().contains(query) ||
          request.requestNumber.toLowerCase().contains(query) ||
          (request.vehicleName ?? '').toLowerCase().contains(query);
      return matchesStatus && matchesSearch;
    }).toList();

    return Scaffold(
      backgroundColor: MyPartRequestsPage.background,
      appBar: AppBar(
        title: const Text('My Part Requests'),
        backgroundColor: MyPartRequestsPage.background,
        surfaceTintColor: MyPartRequestsPage.background,
      ),
      floatingActionButton: all.isNotEmpty
          ? FloatingActionButton.extended(
        heroTag: 'new_part_request',
        onPressed: _newRequest,
        backgroundColor: MyPartRequestsPage.accent,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('New request'),
      )
          : null,
      body: RefreshIndicator(
        onRefresh: provider.loadRequests,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 108),
          children: [
            Text(
              'Find your requests',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: const Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              'Track your part requests and compare sellers\' offers.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 18),
            if (provider.isLoading && all.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 90),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (all.isEmpty && provider.errorMessage != null)
              _MessagePanel(
                icon: Icons.wifi_off_rounded,
                title: 'Could not load your requests',
                message: provider.errorMessage!,
                action: 'Try again',
                onAction: provider.loadRequests,
              )
            else if (all.isEmpty)
                _MessagePanel(
                  icon: Icons.receipt_long_outlined,
                  title: 'No requests yet',
                  message:
                  'Need a car part? Create a request and let sellers send you quotations.',
                  action: 'Request a part',
                  onAction: _newRequest,
                )
              else ...[
                  TextField(
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      hintText: 'Search by part, car, or request #',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: query.isNotEmpty
                          ? IconButton(
                        tooltip: 'Clear search',
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                        icon: const Icon(Icons.close),
                      )
                          : null,
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _filterChip('All (${all.length})', 'all', selectedStatus),
                        ...statuses.map((status) {
                          final count = all.where((e) => e.status == status).length;
                          return _filterChip(
                            '${_readable(status)} ($count)',
                            status,
                            selectedStatus,
                          );
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  if (provider.isLoading) const LinearProgressIndicator(minHeight: 2),
                  if (provider.errorMessage != null) ...[
                    const SizedBox(height: 8),
                    _InlineError(message: provider.errorMessage!),
                  ],
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      '${visible.length} ${visible.length == 1 ? 'request' : 'requests'}',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                  ),
                  if (visible.isEmpty)
                    _MessagePanel(
                      icon: Icons.manage_search,
                      title: 'No matching requests',
                      message: 'Try a different search or status filter.',
                      action: 'Clear filters',
                      onAction: () {
                        _searchController.clear();
                        setState(() => _statusFilter = 'all');
                      },
                    )
                  else
                    ...visible.map((request) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _RequestCard(
                        request: request,
                        onTap: () => _openRequest(request.id),
                      ),
                    )),
                ],
          ],
        ),
      ),
    );
  }

  Widget _filterChip(String label, String value, String selectedValue) {
    final selected = selectedValue == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        selected: selected,
        label: Text(label),
        onSelected: (_) => setState(() => _statusFilter = value),
        selectedColor: const Color(0xFFFFE7D0),
        backgroundColor: Colors.white,
        side: BorderSide(
          color: selected
              ? MyPartRequestsPage.accent
              : const Color(0xFFE5E7EB),
        ),
        labelStyle: TextStyle(
          color: selected ? const Color(0xFF9A4100) : const Color(0xFF4B5563),
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  final PartRequestModel request;
  final VoidCallback onTap;

  const _RequestCard({required this.request, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final quoteCount = request.quotations.length;
    final part = request.partPath.trim().isEmpty
        ? 'Part request'
        : request.partPath;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE7E9EE)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      request.requestNumber,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: const Color(0xFF6B7280),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  _RequestStatus(status: request.status),
                ],
              ),
              const SizedBox(height: 9),
              Text(
                part,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 9),
              Row(
                children: [
                  const Icon(Icons.directions_car_outlined,
                      size: 17, color: Color(0xFF6B7280)),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Text(
                      request.vehicleName ?? 'Vehicle not specified',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Color(0xFF4B5563)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.inventory_2_outlined,
                      size: 17, color: Color(0xFF6B7280)),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Text(
                      'Qty ${request.quantity}  ·  ${_scopeName(request.quotationScope)}',
                      style: const TextStyle(color: Color(0xFF4B5563)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 13),
              const Divider(height: 1, color: Color(0xFFE7E9EE)),
              const SizedBox(height: 11),
              Row(
                children: [
                  Icon(
                    quoteCount > 0
                        ? Icons.mark_chat_unread_outlined
                        : Icons.hourglass_empty_outlined,
                    color: quoteCount > 0
                        ? MyPartRequestsPage.accent
                        : const Color(0xFF6B7280),
                    size: 18,
                  ),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Text(
                      quoteCount == 0
                          ? (request.status == 'open'
                          ? 'Waiting for seller offers'
                          : 'No offers received')
                          : '$quoteCount ${quoteCount == 1 ? 'offer' : 'offers'} received',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Text(
                    quoteCount > 0 ? 'View offers' : 'View details',
                    style: const TextStyle(
                      color: MyPartRequestsPage.accent,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Icon(Icons.chevron_right,
                      color: MyPartRequestsPage.accent),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RequestStatus extends StatelessWidget {
  final String status;
  const _RequestStatus({required this.status});

  @override
  Widget build(BuildContext context) {
    final Color bg;
    final Color fg;
    switch (status.toLowerCase()) {
      case 'open':
        bg = const Color(0xFFFFEDD5);
        fg = const Color(0xFF9A3412);
        break;
      case 'accepted':
      case 'completed':
        bg = const Color(0xFFDCFCE7);
        fg = const Color(0xFF166534);
        break;
      case 'cancelled':
      case 'canceled':
        bg = const Color(0xFFFEE2E2);
        fg = const Color(0xFF991B1B);
        break;
      default:
        bg = const Color(0xFFF3F4F6);
        fg = const Color(0xFF374151);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        _readable(status),
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: fg),
      ),
    );
  }
}

class _MessagePanel extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String action;
  final VoidCallback onAction;

  const _MessagePanel({
    required this.icon,
    required this.title,
    required this.message,
    required this.action,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE7E9EE)),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Icon(icon, size: 56, color: MyPartRequestsPage.accent),
          const SizedBox(height: 16),
          Text(title,
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFF6B7280)),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: onAction,
            icon: const Icon(Icons.arrow_forward),
            label: Text(action),
            style: FilledButton.styleFrom(
              backgroundColor: MyPartRequestsPage.accent,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _InlineError extends StatelessWidget {
  final String message;
  const _InlineError({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3F0),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Color(0xFFB42318)),
          const SizedBox(width: 8),
          Expanded(child: Text(message)),
        ],
      ),
    );
  }
}

String _readable(String value) {
  final text = value.trim().replaceAll('_', ' ').replaceAll('-', ' ');
  return text.isEmpty ? 'Unknown' : '${text[0].toUpperCase()}${text.substring(1)}';
}

String _scopeName(String value) {
  switch (value) {
    case 'nearby':
      return 'Nearby sellers';
    case 'anywhere':
      return 'Sellers anywhere';
    default:
      return _readable(value);
  }
}
