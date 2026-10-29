import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/part_request_provider.dart';
import 'part_request_details_page.dart';
import '../../vehicles/pages/cars_management_page.dart';

/// A guided flow for requesting parts or tires.
///
/// Uses the existing PartRequestProvider and createRequest() API.
/// Nothing in the backend payload has been changed.
class CreatePartRequestPage extends StatefulWidget {
  final String categoryType;

  /// Optional navigation callbacks. Vehicle management also has a built-in
  /// route to CarsManagementPage when no callback is supplied.
  final VoidCallback? onManageVehicles;
  final VoidCallback? onManageAddresses;

  const CreatePartRequestPage({
    super.key,
    this.categoryType = 'parts',
    this.onManageVehicles,
    this.onManageAddresses,
  });

  bool get isTireRequest => categoryType == 'tires';

  @override
  State<CreatePartRequestPage> createState() => _CreatePartRequestPageState();
}

class _CreatePartRequestPageState extends State<CreatePartRequestPage> {
  static const _orange = Color(0xFFF57C00);
  static const _ink = Color(0xFF172033);
  static const _muted = Color(0xFF667085);
  static const _background = Color(0xFFF5F6F8);
  static const _border = Color(0xFFE5E7EB);

  static const _stepCount = 5;
  static const _stepLabels = [
    'Vehicle',
    'Part',
    'Details',
    'Sellers',
    'Review',
  ];

  final brandController = TextEditingController();
  final notesController = TextEditingController();

  int _step = 0;
  int? vehicleId;
  int? addressId;
  int quantity = 1;
  String scope = 'anywhere';
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<PartRequestProvider>().loadCreateData(
        categoryType: widget.categoryType,
      );
    });
  }

  @override
  void dispose() {
    brandController.dispose();
    notesController.dispose();
    super.dispose();
  }

  int? _vehicleSelection(PartRequestProvider provider) {
    final preferred = vehicleId ?? provider.preferredVehicleId;
    if (preferred != null &&
        provider.vehicles.any((vehicle) => vehicle.id == preferred)) {
      return preferred;
    }
    // No extra tap when the account has exactly one saved vehicle.
    if (provider.vehicles.length == 1) return provider.vehicles.first.id;
    return null;
  }

  int? _addressSelection(PartRequestProvider provider) {
    final preferred = addressId ?? provider.preferredAddressId;
    if (preferred != null &&
        provider.nearbyAddresses.any((address) => address.id == preferred)) {
      return preferred;
    }
    if (provider.nearbyAddresses.length == 1) {
      return provider.nearbyAddresses.first.id;
    }
    return null;
  }

  String _vehicleName(PartRequestProvider provider) {
    final id = _vehicleSelection(provider);
    for (final vehicle in provider.vehicles) {
      if (vehicle.id == id) return vehicle.displayName;
    }
    return 'Not selected';
  }

  String _addressName(PartRequestProvider provider) {
    final id = _addressSelection(provider);
    for (final address in provider.nearbyAddresses) {
      if (address.id == id) return address.displayName;
    }
    return 'Not selected';
  }

  String _partName(PartRequestProvider provider) {
    final selected = provider.selectedCategory;
    if (selected == null) return 'Not selected';
    return [
      ...provider.categoryPath.map((item) => item.name),
      selected.name,
    ].join('  ›  ');
  }

  void _back() {
    if (_submitting) return;
    FocusScope.of(context).unfocus();
    if (_step > 0) {
      setState(() => _step--);
    } else {
      Navigator.maybePop(context);
    }
  }

  void _continue(PartRequestProvider provider) {
    FocusScope.of(context).unfocus();

    if (_step == 0 && _vehicleSelection(provider) == null) {
      _showError('Please choose a vehicle first.');
      return;
    }

    if (_step == 1 && provider.selectedCategory == null) {
      _showError(
        widget.isTireRequest
            ? 'Choose a tire type to continue.'
            : 'Choose the exact part to continue.',
      );
      return;
    }

    if (_step == 1 && provider.isCategoryLoading) return;

    if (_step == 3 &&
        scope == 'nearby' &&
        _addressSelection(provider) == null) {
      _showError('Choose a saved location, or select Sellers anywhere.');
      return;
    }

    if (_step < _stepCount - 1) {
      setState(() => _step++);
      return;
    }

    _submit(provider);
  }

  Future<void> _submit(PartRequestProvider provider) async {
    if (_submitting || provider.isSubmitting) return;

    final selectedVehicle = _vehicleSelection(provider);
    final selectedAddress = scope == 'nearby'
        ? _addressSelection(provider)
        : null;

    // Check again at submission time, even when previous steps were completed.
    if (selectedVehicle == null) {
      setState(() => _step = 0);
      _showError('Please choose a vehicle.');
      return;
    }
    if (provider.selectedCategory == null) {
      setState(() => _step = 1);
      _showError('Please choose the part you need.');
      return;
    }
    if (scope == 'nearby' && selectedAddress == null) {
      setState(() => _step = 3);
      _showError('Please choose your location.');
      return;
    }

    setState(() => _submitting = true);
    try {
      final result = await provider.createRequest(
        vehicleId: selectedVehicle,
        quotationScope: scope,
        addressId: selectedAddress,
        quantity: quantity,
        brandPreference: brandController.text.trim(),
        notes: notesController.text.trim(),
      );

      if (!mounted) return;
      if (result == null) {
        _showError(provider.errorMessage ?? 'Could not send your request. Try again.');
        return;
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => PartRequestDetailsPage(requestId: result.id),
        ),
      );
    } catch (_) {
      if (mounted) _showError('Could not send your request. Try again.');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  /// Opens the existing My Cars page and refreshes available vehicles
  /// after returning. This default route is used when the caller hasn't
  /// provided its own navigation callback.
  Future<void> _openMyCars() async {
    if (widget.onManageVehicles != null) {
      // Preserve existing callers that supply their own navigation.
      widget.onManageVehicles!();
      return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const CarsManagementPage(),
      ),
    );

    if (!mounted) return;

    // Refresh saved cars only. loadCreateData() would clear the selected
    // part category, category breadcrumb and other data in the wizard.
    await context.read<PartRequestProvider>().refreshVehicles();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PartRequestProvider>();
    final waiting = provider.isLoading && provider.vehicles.isEmpty;
    final busy = _submitting || provider.isSubmitting;

    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: _ink,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: busy ? null : _back,
          tooltip: _step == 0 ? 'Close' : 'Previous step',
        ),
        title: Text(
          widget.isTireRequest ? 'Request a Tire Quote' : 'Request a Part',
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
        ),
      ),
      body: waiting
          ? const Center(child: CircularProgressIndicator(color: _orange))
          : SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _progressHeader(),
            const SizedBox(height: 20),
            if (_step == 0) _vehicleStep(provider),
            if (_step == 1) _partStep(provider),
            if (_step == 2) _detailsStep(),
            if (_step == 3) _sellersStep(provider),
            if (_step == 4) _reviewStep(provider),
            if (provider.errorMessage != null && _step == 4) ...[
              const SizedBox(height: 14),
              _Notice(
                text: provider.errorMessage!,
                icon: Icons.error_outline_rounded,
              ),
            ],
          ],
        ),
      ),
      bottomNavigationBar: waiting
          ? null
          : SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: _border)),
          ),
          child: Row(
            children: [
              if (_step > 0) ...[
                OutlinedButton(
                  onPressed: busy ? null : _back,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(92, 52),
                    foregroundColor: _ink,
                  ),
                  child: const Text('Back'),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: _orange,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: busy || (_step == 0 && provider.vehicles.isEmpty)
                        ? null
                        : () => _continue(provider),
                    child: busy
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                        : Text(
                      _step == _stepCount - 1
                          ? 'Send request'
                          : _step == _stepCount - 2
                          ? 'Review request'
                          : 'Continue',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _progressHeader() {
    final titles = widget.isTireRequest
        ? [
      'Choose your vehicle',
      'Which tire do you need?',
      'Tell us the details',
      'Who should send quotes?',
      'Review your tire request',
    ]
        : [
      'Choose your vehicle',
      'Which part do you need?',
      'Tell us the details',
      'Who should send quotes?',
      'Review your part request',
    ];
    final descriptions = [
      'This helps sellers find a compatible item.',
      'Follow the categories until you reach the exact item.',
      'Quantity is required. Everything else is optional.',
      'You can receive quotes from anywhere or nearby sellers.',
      'Check your choices before sending them to sellers.',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'STEP ${_step + 1} OF $_stepCount',
              style: const TextStyle(
                color: _orange,
                fontSize: 11,
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
              ),
            ),
            const Spacer(),
            Text(
              _stepLabels[_step],
              style: const TextStyle(
                color: _muted,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: List.generate(_stepCount, (index) {
            return Expanded(
              child: Container(
                height: 5,
                margin: EdgeInsets.only(right: index == _stepCount - 1 ? 0 : 5),
                decoration: BoxDecoration(
                  color: index <= _step ? _orange : _border,
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 22),
        Text(
          titles[_step],
          style: const TextStyle(
            color: _ink,
            fontSize: 25,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          descriptions[_step],
          style: const TextStyle(color: _muted, fontSize: 13, height: 1.4),
        ),
      ],
    );
  }

  Widget _vehicleStep(PartRequestProvider provider) {
    if (provider.vehicles.isEmpty) {
      return _Surface(
        child: Column(
          children: [
            const Icon(Icons.directions_car_outlined, color: _orange, size: 42),
            const SizedBox(height: 12),
            const Text(
              'No vehicle saved yet',
              style: TextStyle(color: _ink, fontSize: 17, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            const Text(
              'Add a car in My Cars, then return here to request a compatible part or tire.',
              textAlign: TextAlign.center,
              style: TextStyle(color: _muted, height: 1.45),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _openMyCars,
                style: FilledButton.styleFrom(
                  backgroundColor: _orange,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(50),
                ),
                icon: const Icon(Icons.add_rounded),
                label: const Text('Add your first car'),
              ),
            ),
          ],
        ),
      );
    }

    final value = _vehicleSelection(provider);
    return _Surface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your car',
            style: TextStyle(color: _ink, fontWeight: FontWeight.w800, fontSize: 15),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<int>(
            key: ValueKey('vehicle-$value'),
            value: value,
            isExpanded: true,
            decoration: _inputDecoration('Select a vehicle', Icons.directions_car_outlined),
            items: provider.vehicles
                .map(
                  (vehicle) => DropdownMenuItem<int>(
                value: vehicle.id,
                child: Text(
                  vehicle.displayName,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            )
                .toList(),
            onChanged: (next) => setState(() => vehicleId = next),
          ),
          const SizedBox(height: 14),
          const _HintRow(
            icon: Icons.info_outline_rounded,
            text: 'Selected vehicle details will be included in the request.',
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: _openMyCars,
            icon: const Icon(Icons.edit_outlined),
            label: const Text('Manage my cars'),
          ),
        ],
      ),
    );
  }

  Widget _partStep(PartRequestProvider provider) {
    return _Surface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _HintRow(
            icon: Icons.touch_app_outlined,
            text: 'Tap a category to see more specific options. The final choice will show a check mark.',
          ),
          const SizedBox(height: 18),
          if (provider.selectedCategory != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                border: Border.all(color: const Color(0xFFBBF7D0)),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_rounded, color: Color(0xFF15803D)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Part selected',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF166534),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(_partName(provider), style: const TextStyle(height: 1.35)),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: provider.changeSelectedCategory,
                    child: const Text('Change'),
                  ),
                ],
              ),
            )
          else ...[
            if (provider.categoryPath.isNotEmpty) ...[
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 4,
                runSpacing: 4,
                children: [
                  const Text('Browsing:', style: TextStyle(color: _muted, fontSize: 12)),
                  ...provider.categoryPath.map(
                        (category) => Chip(
                      label: Text(category.name),
                      visualDensity: VisualDensity.compact,
                      side: const BorderSide(color: _border),
                    ),
                  ),
                ],
              ),
              TextButton.icon(
                onPressed: provider.isCategoryLoading ? null : provider.categoryBack,
                icon: const Icon(Icons.arrow_back_rounded, size: 18),
                label: const Text('Previous category'),
              ),
              const Divider(color: _border),
            ],
            if (provider.isCategoryLoading)
              const Padding(
                padding: EdgeInsets.all(30),
                child: Center(child: CircularProgressIndicator(color: _orange)),
              )
            else if (provider.currentCategories.isEmpty)
              _Notice(
                text: provider.errorMessage ??
                    'No options found here. Go back and choose another category.',
                icon: Icons.info_outline_rounded,
              )
            else
              ...provider.currentCategories.map(
                    (category) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: _border),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 13, vertical: 4),
                    leading: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF3E0),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        widget.isTireRequest
                            ? Icons.tire_repair_outlined
                            : Icons.settings_outlined,
                        color: _orange,
                        size: 21,
                      ),
                    ),
                    title: Text(
                      category.name,
                      style: const TextStyle(fontWeight: FontWeight.w700, color: _ink),
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded, color: _muted),
                    onTap: () => provider.openCategory(category),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _detailsStep() {
    return Column(
      children: [
        _Surface(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'How many do you need?',
                style: TextStyle(color: _ink, fontSize: 15, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  _QuantityButton(
                    icon: Icons.remove_rounded,
                    onTap: quantity > 1 ? () => setState(() => quantity--) : null,
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        '$quantity',
                        style: const TextStyle(
                          color: _ink,
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                  _QuantityButton(
                    icon: Icons.add_rounded,
                    onTap: () => setState(() => quantity++),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _Surface(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _OptionalLabel(title: 'Preferred brand'),
              const SizedBox(height: 8),
              TextField(
                controller: brandController,
                textCapitalization: TextCapitalization.words,
                decoration: _inputDecoration(
                  widget.isTireRequest
                      ? 'Example: Michelin, Goodyear'
                      : 'Example: Bosch, Motorcraft',
                  Icons.sell_outlined,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Leave blank if any brand is acceptable.',
                style: TextStyle(color: _muted, fontSize: 12),
              ),
              const SizedBox(height: 20),
              const _OptionalLabel(title: 'Notes for sellers'),
              const SizedBox(height: 8),
              TextField(
                controller: notesController,
                minLines: 3,
                maxLines: 5,
                maxLength: 1000,
                decoration: _inputDecoration(
                  widget.isTireRequest
                      ? 'Size, preferred condition, or other details...'
                      : 'Part number, preferred condition, or extra details...',
                  Icons.edit_note_rounded,
                ),
              ),
              const Text(
                'Add a part number here if you know it. This helps sellers identify the correct item.',
                style: TextStyle(color: _muted, fontSize: 12, height: 1.4),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _sellersStep(PartRequestProvider provider) {
    return Column(
      children: [
        _Surface(
          child: Column(
            children: [
              _ChoiceTile(
                selected: scope == 'anywhere',
                icon: Icons.public_rounded,
                title: 'Sellers anywhere',
                description: 'More sellers can respond. No location required.',
                onTap: () => setState(() => scope = 'anywhere'),
              ),
              const SizedBox(height: 12),
              _ChoiceTile(
                selected: scope == 'nearby',
                icon: Icons.near_me_outlined,
                title: 'Nearby sellers',
                description: 'Only sellers whose branches cover your saved location.',
                onTap: () => setState(() => scope = 'nearby'),
              ),
            ],
          ),
        ),
        if (scope == 'nearby') ...[
          const SizedBox(height: 12),
          _Surface(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Where should sellers look?',
                  style: TextStyle(color: _ink, fontSize: 15, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Choose an address saved with a map location.',
                  style: TextStyle(color: _muted, fontSize: 12),
                ),
                const SizedBox(height: 12),
                if (provider.nearbyAddresses.isEmpty) ...[
                  const _Notice(
                    text: 'No saved location with coordinates was found. Add a mapped address or choose Sellers anywhere.',
                    icon: Icons.location_off_outlined,
                  ),
                  if (widget.onManageAddresses != null)
                    TextButton.icon(
                      onPressed: widget.onManageAddresses,
                      icon: const Icon(Icons.add_location_alt_outlined),
                      label: const Text('Manage addresses'),
                    ),
                ] else ...[
                  DropdownButtonFormField<int>(
                    key: ValueKey('address-${_addressSelection(provider)}'),
                    value: _addressSelection(provider),
                    isExpanded: true,
                    decoration: _inputDecoration('Select location', Icons.place_outlined),
                    items: provider.nearbyAddresses
                        .map(
                          (address) => DropdownMenuItem<int>(
                        value: address.id,
                        child: Text(
                          address.displayName,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
                        .toList(),
                    onChanged: (next) => setState(() => addressId = next),
                  ),
                  if (widget.onManageAddresses != null)
                    TextButton.icon(
                      onPressed: widget.onManageAddresses,
                      icon: const Icon(Icons.edit_location_alt_outlined),
                      label: const Text('Manage addresses'),
                    ),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _reviewStep(PartRequestProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Surface(
          child: Column(
            children: [
              _ReviewRow(
                icon: Icons.directions_car_outlined,
                label: 'Vehicle',
                value: _vehicleName(provider),
                onEdit: () => setState(() => _step = 0),
              ),
              const Divider(height: 26, color: _border),
              _ReviewRow(
                icon: widget.isTireRequest
                    ? Icons.tire_repair_outlined
                    : Icons.settings_outlined,
                label: widget.isTireRequest ? 'Tire' : 'Part',
                value: _partName(provider),
                onEdit: () => setState(() => _step = 1),
              ),
              const Divider(height: 26, color: _border),
              _ReviewRow(
                icon: Icons.numbers_rounded,
                label: 'Quantity',
                value: '$quantity',
                onEdit: () => setState(() => _step = 2),
              ),
              const Divider(height: 26, color: _border),
              _ReviewRow(
                icon: Icons.sell_outlined,
                label: 'Preferred brand',
                value: brandController.text.trim().isEmpty
                    ? 'Any brand'
                    : brandController.text.trim(),
                onEdit: () => setState(() => _step = 2),
              ),
              if (notesController.text.trim().isNotEmpty) ...[
                const Divider(height: 26, color: _border),
                _ReviewRow(
                  icon: Icons.notes_outlined,
                  label: 'Notes',
                  value: notesController.text.trim(),
                  onEdit: () => setState(() => _step = 2),
                ),
              ],
              const Divider(height: 26, color: _border),
              _ReviewRow(
                icon: Icons.public_rounded,
                label: 'Quote requests',
                value: scope == 'nearby'
                    ? 'Nearby sellers · ${_addressName(provider)}'
                    : 'Sellers anywhere',
                onEdit: () => setState(() => _step = 3),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        const _Notice(
          icon: Icons.info_outline_rounded,
          text: 'This sends a quote request. It does not place an order or make a payment.',
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: _muted, size: 20),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _orange, width: 1.5),
      ),
    );
  }
}

class _Surface extends StatelessWidget {
  final Widget child;

  const _Surface({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: child,
    );
  }
}

class _OptionalLabel extends StatelessWidget {
  final String title;

  const _OptionalLabel({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: Color(0xFF172033),
            ),
          ),
        ),
        const Text('Optional', style: TextStyle(color: Color(0xFF667085), fontSize: 12)),
      ],
    );
  }
}

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _QuantityButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(13),
      child: Container(
        width: 58,
        height: 52,
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFE5E7EB)),
          color: onTap == null ? const Color(0xFFF5F6F8) : const Color(0xFFFFF3E0),
          borderRadius: BorderRadius.circular(13),
        ),
        child: Icon(
          icon,
          color: onTap == null ? Colors.grey : const Color(0xFFF57C00),
        ),
      ),
    );
  }
}

class _ChoiceTile extends StatelessWidget {
  final bool selected;
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  const _ChoiceTile({
    required this.selected,
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFFFF7ED) : Colors.white,
          border: Border.all(
            color: selected ? const Color(0xFFF57C00) : const Color(0xFFE5E7EB),
            width: selected ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: selected ? const Color(0xFFF57C00) : const Color(0xFF667085)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF172033),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    description,
                    style: const TextStyle(color: Color(0xFF667085), fontSize: 12, height: 1.4),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              selected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
              color: selected ? const Color(0xFFF57C00) : const Color(0xFF98A2B3),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReviewRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onEdit;

  const _ReviewRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: const Color(0xFFF57C00), size: 21),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF667085))),
              const SizedBox(height: 3),
              Text(
                value,
                style: const TextStyle(
                  color: Color(0xFF172033),
                  fontWeight: FontWeight.w700,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        TextButton(
          onPressed: onEdit,
          child: const Text('Edit'),
        ),
      ],
    );
  }
}

class _Notice extends StatelessWidget {
  final String text;
  final IconData icon;

  const _Notice({required this.text, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: const Color(0xFFFED7AA)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFFC2410C), size: 19),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Color(0xFF9A3412),
                fontSize: 12,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HintRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _HintRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: const Color(0xFFF57C00), size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Color(0xFF667085),
              fontSize: 12,
              height: 1.45,
            ),
          ),
        ),
      ],
    );
  }
}
