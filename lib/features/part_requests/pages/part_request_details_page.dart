import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/models/part_request_model.dart';
import '../providers/part_request_provider.dart';

class PartRequestDetailsPage extends StatefulWidget {
  final int requestId;

  const PartRequestDetailsPage({
    super.key,
    required this.requestId,
  });

  static const Color accent = Color(0xFFF57C00);
  static const Color background = Color(0xFFF7F8FA);

  @override
  State<PartRequestDetailsPage> createState() =>
      _PartRequestDetailsPageState();
}

class _PartRequestDetailsPageState extends State<PartRequestDetailsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<PartRequestProvider>().loadRequest(widget.requestId);
      }
    });
  }

  Future<void> _cancelRequest(PartRequestModel request) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cancel this request?'),
        content: const Text(
          'Sellers will no longer be able to send new offers for this request.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Keep request'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFFB42318)),
            child: const Text('Cancel request'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final provider = context.read<PartRequestProvider>();
    final success = await provider.cancelRequest(request.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success
            ? 'Request cancelled.'
            : provider.errorMessage ?? 'Could not cancel your request.'),
      ),
    );
  }

  Future<void> _acceptQuote(
      PartRequestModel request,
      PartQuotationModel quote,
      ) async {
    final total = quote.totalForQuantity(request.quantity);
    final seller = quote.vendorName ?? 'Seller';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Accept this offer?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(seller, style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            _AmountLine(
              label: 'Parts (${request.quantity} × ${_money(quote.unitPrice)})',
              amount: _money(quote.unitPrice * request.quantity),
            ),
            _AmountLine(label: 'Delivery', amount: _money(quote.deliveryFee)),
            const Divider(height: 22),
            _AmountLine(label: 'Total', amount: _money(total), emphasized: true),
            const SizedBox(height: 12),
            const Text(
              'This will select this seller’s quotation for your request.',
              style: TextStyle(color: Color(0xFF6B7280)),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Go back'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: FilledButton.styleFrom(
              backgroundColor: PartRequestDetailsPage.accent,
            ),
            child: const Text('Accept offer'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;
    final provider = context.read<PartRequestProvider>();
    final success = await provider.acceptQuotation(
      requestId: request.id,
      quotationId: quote.id,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success
            ? 'Offer accepted successfully.'
            : provider.errorMessage ?? 'Could not accept this offer.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PartRequestProvider>();
    final candidate = provider.selectedRequest;
    final request = candidate?.id == widget.requestId ? candidate : null;

    return Scaffold(
      backgroundColor: PartRequestDetailsPage.background,
      appBar: AppBar(
        title: const Text('Request Details'),
        backgroundColor: PartRequestDetailsPage.background,
        surfaceTintColor: PartRequestDetailsPage.background,
      ),
      body: provider.isLoading && request == null
          ? const Center(child: CircularProgressIndicator())
          : request == null
          ? _DetailsError(
        message: provider.errorMessage ?? 'Request not found.',
        onRetry: () => provider.loadRequest(widget.requestId),
      )
          : RefreshIndicator(
        onRefresh: () => provider.loadRequest(widget.requestId),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            _RequestHero(request: request),
            if (provider.isLoading) ...[
              const SizedBox(height: 12),
              const LinearProgressIndicator(minHeight: 2),
            ],
            if (provider.errorMessage != null) ...[
              const SizedBox(height: 12),
              _ErrorBanner(message: provider.errorMessage!),
            ],
            const SizedBox(height: 18),
            _DetailSection(
              title: 'Your request',
              icon: Icons.inventory_2_outlined,
              children: [
                _DetailRow(label: 'Part', value: request.partPath),
                _DetailRow(
                  label: 'Car',
                  value: request.vehicleName ?? 'Not specified',
                ),
                if ((request.engine ?? '').trim().isNotEmpty)
                  _DetailRow(label: 'Engine', value: request.engine!),
                _DetailRow(
                  label: 'Quantity',
                  value: request.quantity.toString(),
                ),
                _DetailRow(
                  label: 'Preferred brand',
                  value: (request.brandPreference ?? '').trim().isEmpty
                      ? 'Any brand'
                      : request.brandPreference!,
                ),
                _DetailRow(
                  label: 'Sellers',
                  value: _scopeLabel(request.quotationScope),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Seller offers',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFE7D0),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${request.quotations.length}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF9A4100),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Text(
              request.quotations.isEmpty
                  ? (request.status == 'open'
                  ? 'Sellers can send offers while your request is open.'
                  : 'No offers were received for this request.')
                  : 'Compare the total cost, condition, and delivery time.',
              style: const TextStyle(color: Color(0xFF6B7280)),
            ),
            const SizedBox(height: 14),
            if (request.quotations.isEmpty)
              _NoOffersCard(isOpen: request.status == 'open')
            else
              ...request.quotations.map(
                    (quote) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _QuotationCard(
                    request: request,
                    quotation: quote,
                    isSubmitting: provider.isSubmitting,
                    onAccept: () => _acceptQuote(request, quote),
                  ),
                ),
              ),
            if (request.status == 'open') ...[
              const SizedBox(height: 18),
              Center(
                child: TextButton.icon(
                  onPressed: provider.isSubmitting
                      ? null
                      : () => _cancelRequest(request),
                  icon: const Icon(Icons.close),
                  label: const Text('Cancel this request'),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFFB42318),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _RequestHero extends StatelessWidget {
  final PartRequestModel request;
  const _RequestHero({required this.request});

  @override
  Widget build(BuildContext context) {
    final open = request.status == 'open';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
                  style: const TextStyle(
                    color: Color(0xFF6B7280),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              _StatusLabel(value: request.status),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            request.partPath.isEmpty ? 'Part request' : request.partPath,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: const Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.directions_car_outlined,
                  size: 18, color: Color(0xFF6B7280)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  request.vehicleName ?? 'Vehicle not specified',
                  style: const TextStyle(color: Color(0xFF4B5563)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: open ? const Color(0xFFFFF5E9) : const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  open ? Icons.info_outline : Icons.receipt_long_outlined,
                  size: 19,
                  color: open
                      ? const Color(0xFF9A4100)
                      : const Color(0xFF6B7280),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    open
                        ? (request.quotations.isEmpty
                        ? 'Your request is open. Waiting for seller offers.'
                        : 'Offers have arrived. Review them below.')
                        : 'Review the details and offers for this request.',
                    style: TextStyle(
                      color: open
                          ? const Color(0xFF9A4100)
                          : const Color(0xFF4B5563),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuotationCard extends StatelessWidget {
  final PartRequestModel request;
  final PartQuotationModel quotation;
  final bool isSubmitting;
  final VoidCallback onAccept;

  const _QuotationCard({
    required this.request,
    required this.quotation,
    required this.isSubmitting,
    required this.onAccept,
  });

  @override
  Widget build(BuildContext context) {
    final selected = request.selectedQuotationId == quotation.id ||
        quotation.status == 'accepted';
    final total = quotation.totalForQuantity(request.quantity);
    final canAccept = request.status == 'open' &&
        quotation.status == 'submitted' &&
        !isSubmitting;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: selected
              ? const Color(0xFF16A34A)
              : const Color(0xFFE7E9EE),
          width: selected ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 19,
                backgroundColor: const Color(0xFFFFE7D0),
                child: const Icon(Icons.storefront_outlined,
                    color: PartRequestDetailsPage.accent, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      quotation.vendorName ?? 'Seller',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    if ((quotation.branchName ?? '').trim().isNotEmpty)
                      Text(
                        quotation.branchName!,
                        style: const TextStyle(
                          color: Color(0xFF6B7280),
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ),
              _StatusLabel(value: selected ? 'selected' : quotation.status),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F8FA),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Total incl. delivery',
                    style: TextStyle(
                      color: Color(0xFF4B5563),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  _money(total),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: const Color(0xFF111827),
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _AmountLine(
            label: 'Unit price × ${request.quantity}',
            amount: _money(quotation.unitPrice * request.quantity),
          ),
          const SizedBox(height: 4),
          _AmountLine(
            label: 'Delivery fee',
            amount: _money(quotation.deliveryFee),
          ),
          const Divider(height: 24),
          _DetailRow(
            label: 'Condition',
            value: _friendly(quotation.conditionType),
          ),
          if ((quotation.brand ?? '').trim().isNotEmpty)
            _DetailRow(label: 'Brand', value: quotation.brand!),
          if ((quotation.partNumber ?? '').trim().isNotEmpty)
            _DetailRow(label: 'Part number', value: quotation.partNumber!),
          if (quotation.estimatedDeliveryDays != null)
            _DetailRow(
              label: 'Delivery time',
              value: '${quotation.estimatedDeliveryDays} day(s)',
            ),
          if ((quotation.warrantyText ?? '').trim().isNotEmpty)
            _DetailRow(label: 'Warranty', value: quotation.warrantyText!),
          if ((quotation.notes ?? '').trim().isNotEmpty) ...[
            const Divider(height: 24),
            const Text('Seller notes',
                style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Text(quotation.notes!),
          ],
          if (request.status == 'open' && quotation.status == 'submitted') ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton.icon(
                onPressed: canAccept ? onAccept : null,
                style: FilledButton.styleFrom(
                  backgroundColor: PartRequestDetailsPage.accent,
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.check_circle_outline),
                label: Text(isSubmitting ? 'Please wait...' : 'Accept this offer'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DetailSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _DetailSection({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE7E9EE)),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: PartRequestDetailsPage.accent),
              const SizedBox(width: 9),
              Text(
                title,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const Divider(height: 26),
          ...children,
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 112,
            child: Text(label,
                style: const TextStyle(color: Color(0xFF6B7280))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value.trim().isEmpty ? '—' : value,
              style: const TextStyle(
                color: Color(0xFF111827),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AmountLine extends StatelessWidget {
  final String label;
  final String amount;
  final bool emphasized;

  const _AmountLine({
    required this.label,
    required this.amount,
    this.emphasized = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: emphasized ? const Color(0xFF111827) : const Color(0xFF6B7280),
              fontWeight: emphasized ? FontWeight.w800 : FontWeight.w400,
            ),
          ),
        ),
        Text(
          amount,
          style: TextStyle(
            color: const Color(0xFF111827),
            fontWeight: emphasized ? FontWeight.w900 : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _StatusLabel extends StatelessWidget {
  final String value;
  const _StatusLabel({required this.value});

  @override
  Widget build(BuildContext context) {
    final normalized = value.toLowerCase();
    final Color bg;
    final Color fg;
    switch (normalized) {
      case 'open':
      case 'submitted':
        bg = const Color(0xFFFFEDD5);
        fg = const Color(0xFF9A3412);
        break;
      case 'selected':
      case 'accepted':
      case 'completed':
        bg = const Color(0xFFDCFCE7);
        fg = const Color(0xFF166534);
        break;
      case 'cancelled':
      case 'canceled':
      case 'rejected':
        bg = const Color(0xFFFEE2E2);
        fg = const Color(0xFF991B1B);
        break;
      default:
        bg = const Color(0xFFF3F4F6);
        fg = const Color(0xFF374151);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        _friendly(value),
        style: TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _NoOffersCard extends StatelessWidget {
  final bool isOpen;
  const _NoOffersCard({required this.isOpen});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE7E9EE)),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          const Icon(Icons.mark_chat_unread_outlined,
              color: PartRequestDetailsPage.accent, size: 38),
          const SizedBox(height: 12),
          Text(isOpen ? 'Waiting for seller offers' : 'No offers received',
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          const SizedBox(height: 7),
          Text(
            isOpen
                ? 'Offers will appear here when sellers respond.'
                : 'This request has no quotations to display.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFF6B7280)),
          ),
        ],
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3F0),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Color(0xFFB42318)),
          const SizedBox(width: 9),
          Expanded(child: Text(message)),
        ],
      ),
    );
  }
}

class _DetailsError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _DetailsError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline,
                color: PartRequestDetailsPage.accent, size: 50),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Try again'),
              style: FilledButton.styleFrom(
                backgroundColor: PartRequestDetailsPage.accent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _friendly(String text) {
  final value = text.trim().replaceAll('_', ' ').replaceAll('-', ' ');
  return value.isEmpty ? 'Unknown' : '${value[0].toUpperCase()}${value.substring(1)}';
}

String _scopeLabel(String scope) {
  switch (scope) {
    case 'nearby':
      return 'Nearby sellers';
    case 'anywhere':
      return 'Sellers anywhere';
    default:
      return _friendly(scope);
  }
}

String _money(num amount) => '\$${amount.toStringAsFixed(2)}';
