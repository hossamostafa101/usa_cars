import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../data/models/vehicle_catalog_model.dart';
import '../data/models/vehicle_model.dart';
import '../data/services/vehicle_api_service.dart';
import '../providers/vehicle_provider.dart';

class CarsManagementPage extends StatefulWidget {
  const CarsManagementPage({super.key});

  static const Color primaryOrange = Color(0xFFF57C00);
  static const Color lightBackground = Color(0xFFF5F6F8);

  @override
  State<CarsManagementPage> createState() => _CarsManagementPageState();
}

class _CarsManagementPageState extends State<CarsManagementPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<VehicleProvider>().loadVehicles();
    });
  }

  Future<void> _openForm({VehicleModel? vehicle}) async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _VehicleFormSheet(vehicle: vehicle),
    );
    if (!mounted || saved != true) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(vehicle == null ? 'Car added successfully' : 'Car updated successfully')),
    );
  }

  Future<void> _confirmDelete(VehicleModel vehicle) async {
    if (vehicle.id == null) return;
    final answer = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete car?'),
        content: Text('Delete ${vehicle.displayName}? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (!mounted || answer != true) return;
    final success = await context.read<VehicleProvider>().deleteVehicle(vehicle.id!);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(success ? 'Car deleted' : 'Could not delete car')),
    );
  }

  Future<void> _makePrimary(VehicleModel vehicle) async {
    if (vehicle.id == null) return;
    final success = await context.read<VehicleProvider>().setPrimary(vehicle.id!);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(success ? 'Default car updated' : 'Could not update default car')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<VehicleProvider>();
    return Scaffold(
      backgroundColor: CarsManagementPage.lightBackground,
      appBar: AppBar(
        title: const Text('My Cars', style: TextStyle(fontWeight: FontWeight.w800)),
        backgroundColor: CarsManagementPage.lightBackground,
      ),
      floatingActionButton: provider.vehicles.isEmpty
          ? null
          : FloatingActionButton.extended(
        onPressed: () => _openForm(),
        backgroundColor: CarsManagementPage.primaryOrange,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add car'),
      ),
      body: RefreshIndicator(
        onRefresh: provider.loadVehicles,
        child: provider.isLoading && provider.vehicles.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : provider.vehicles.isEmpty
            ? ListView(
          padding: const EdgeInsets.fromLTRB(24, 64, 24, 24),
          children: [
            const Icon(Icons.directions_car_outlined, size: 76, color: CarsManagementPage.primaryOrange),
            const SizedBox(height: 20),
            const Text('No cars added yet',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 23, fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            const Text(
              'Add your car once to get more accurate parts quotes, repair and roadside services.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Color(0xFF667085), height: 1.5),
            ),
            if (provider.errorMessage != null) ...[
              const SizedBox(height: 12),
              Text(provider.errorMessage!, textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red)),
              TextButton(onPressed: provider.loadVehicles, child: const Text('Try again')),
            ],
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => _openForm(),
              style: FilledButton.styleFrom(
                backgroundColor: CarsManagementPage.primaryOrange,
                minimumSize: const Size.fromHeight(52),
              ),
              icon: const Icon(Icons.add),
              label: const Text('Add your first car'),
            ),
          ],
        )
            : ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 104),
          itemCount: provider.vehicles.length + 1,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            if (index == 0) {
              return const Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Text('Manage your saved vehicles. Your default car is selected first when requesting parts.',
                    style: TextStyle(color: Color(0xFF667085), height: 1.45)),
              );
            }
            final vehicle = provider.vehicles[index - 1];
            return _VehicleCard(
              vehicle: vehicle,
              onEdit: () => _openForm(vehicle: vehicle),
              onDelete: vehicle.id == null ? null : () => _confirmDelete(vehicle),
              onSetPrimary: vehicle.id == null || vehicle.isPrimary
                  ? null
                  : () => _makePrimary(vehicle),
            );
          },
        ),
      ),
    );
  }
}

class _VehicleCard extends StatelessWidget {
  final VehicleModel vehicle;
  final VoidCallback onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onSetPrimary;
  const _VehicleCard({
    required this.vehicle,
    required this.onEdit,
    this.onDelete,
    this.onSetPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: vehicle.isPrimary
            ? CarsManagementPage.primaryOrange
            : const Color(0xFFE5E7EB)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3E5),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.directions_car_filled_outlined,
                color: CarsManagementPage.primaryOrange, size: 25),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(vehicle.displayName.isEmpty ? 'Your vehicle' : vehicle.displayName,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                if (vehicle.isPrimary) ...[
                  const SizedBox(height: 6),
                  const Text('★ Default car',
                      style: TextStyle(color: CarsManagementPage.primaryOrange,
                          fontSize: 12, fontWeight: FontWeight.w700)),
                ],
                if (vehicle.details.isNotEmpty) ...[
                  const SizedBox(height: 7),
                  Text(vehicle.details,
                      style: const TextStyle(color: Color(0xFF667085), fontSize: 12)),
                ],
                if ((vehicle.tireSize ?? '').isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text('Tire size: ${vehicle.tireSize}',
                      style: const TextStyle(color: Color(0xFF667085), fontSize: 12)),
                ],
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined, size: 16),
                  label: const Text('Edit car'),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            tooltip: 'Car options',
            onSelected: (value) {
              if (value == 'primary') onSetPrimary?.call();
              if (value == 'delete') onDelete?.call();
            },
            itemBuilder: (_) => [
              if (onSetPrimary != null)
                const PopupMenuItem(value: 'primary', child: Text('Make default')),
              if (onDelete != null)
                const PopupMenuItem(value: 'delete', child: Text('Delete car')),
            ],
          ),
        ],
      ),
    );
  }
}

class _CatalogChoice {
  final int id;
  final String label;
  const _CatalogChoice(this.id, this.label);
}

class _VehicleFormSheet extends StatefulWidget {
  final VehicleModel? vehicle;
  const _VehicleFormSheet({this.vehicle});

  @override
  State<_VehicleFormSheet> createState() => _VehicleFormSheetState();
}

class _VehicleFormSheetState extends State<_VehicleFormSheet> {
  static const _orange = CarsManagementPage.primaryOrange;
  final _api = VehicleApiService();
  final _formKey = GlobalKey<FormState>();

  final _trim = TextEditingController();
  final _engine = TextEditingController();
  final _color = TextEditingController();
  final _vin = TextEditingController();
  final _plate = TextEditingController();
  final _mileage = TextEditingController();
  final _tireSize = TextEditingController();

  List<int> _years = [];
  List<VehicleMakeModel> _makes = [];
  List<VehicleModelOption> _models = [];
  int? _year;
  int? _makeId;
  int? _modelId;
  String? _fuel;
  String? _transmission;
  bool _primary = false;
  bool _extraExpanded = false;
  bool _loadingYears = true;
  bool _loadingMakes = false;
  bool _loadingModels = false;
  String? _catalogError;
  int _requestGeneration = 0;

  bool get _editing => widget.vehicle != null;

  @override
  void initState() {
    super.initState();
    final vehicle = widget.vehicle;
    if (vehicle != null) {
      _trim.text = vehicle.trimName ?? '';
      _engine.text = vehicle.engine ?? '';
      _color.text = vehicle.color ?? '';
      _vin.text = vehicle.vin ?? '';
      _plate.text = vehicle.plateNumber ?? '';
      _mileage.text = vehicle.mileage?.toString() ?? '';
      _tireSize.text = vehicle.tireSize ?? '';
      _fuel = vehicle.fuelType;
      _transmission = vehicle.transmission;
      _primary = vehicle.isPrimary;
      _extraExpanded = true;
    }
    _initializeCatalog();
  }

  @override
  void dispose() {
    _requestGeneration++;
    _trim.dispose();
    _engine.dispose();
    _color.dispose();
    _vin.dispose();
    _plate.dispose();
    _mileage.dispose();
    _tireSize.dispose();
    super.dispose();
  }

  Future<void> _initializeCatalog() async {
    final generation = ++_requestGeneration;
    setState(() {
      _loadingYears = true;
      _catalogError = null;
    });
    try {
      final years = await _api.getYears();
      if (!mounted || generation != _requestGeneration) return;
      final originalYear = widget.vehicle?.year;
      final selection = originalYear != null && years.contains(originalYear)
          ? originalYear
          : null;
      setState(() {
        _years = years;
        _year = selection;
        _loadingYears = false;
      });
      if (selection != null) {
        await _loadMakes(selection,
          preferredMakeId: widget.vehicle?.makeId,
          preferredModelId: widget.vehicle?.modelId,
        );
      }
    } catch (e) {
      if (!mounted || generation != _requestGeneration) return;
      setState(() {
        _loadingYears = false;
        _catalogError = 'Could not load vehicle years. Check your connection and retry.';
      });
    }
  }

  Future<void> _loadMakes(
      int year, {
        int? preferredMakeId,
        int? preferredModelId,
      }) async {
    final generation = ++_requestGeneration;
    setState(() {
      _makeId = null;
      _modelId = null;
      _makes = [];
      _models = [];
      _loadingMakes = true;
      _loadingModels = false;
      _catalogError = null;
    });
    try {
      final makes = await _api.getMakes(year: year);
      if (!mounted || generation != _requestGeneration) return;
      final preferred = makes.any((item) => item.id == preferredMakeId)
          ? preferredMakeId
          : null;
      setState(() {
        _makes = makes;
        _makeId = preferred;
        _loadingMakes = false;
      });
      if (preferred != null) {
        await _loadModels(preferred, preferredModelId: preferredModelId);
      }
    } catch (_) {
      if (!mounted || generation != _requestGeneration) return;
      setState(() {
        _loadingMakes = false;
        _catalogError = 'Could not load makes for this year. Please retry.';
      });
    }
  }

  Future<void> _loadModels(int makeId, {int? preferredModelId}) async {
    final year = _year;
    if (year == null) return;
    final generation = ++_requestGeneration;
    setState(() {
      _modelId = null;
      _models = [];
      _loadingModels = true;
      _catalogError = null;
    });
    try {
      final models = await _api.getModelsByMake(makeId, year: year);
      if (!mounted || generation != _requestGeneration) return;
      setState(() {
        _models = models;
        _modelId = models.any((item) => item.id == preferredModelId)
            ? preferredModelId
            : null;
        _loadingModels = false;
      });
    } catch (_) {
      if (!mounted || generation != _requestGeneration) return;
      setState(() {
        _loadingModels = false;
        _catalogError = 'Could not load models. Please choose the make again.';
      });
    }
  }

  void _selectYear(int? year) {
    if (year == _year) return;
    _requestGeneration++; // Prevent stale requests from restoring old makes/models.
    setState(() {
      _year = year;
      _makeId = null;
      _modelId = null;
      _makes = [];
      _models = [];
      _loadingMakes = false;
      _loadingModels = false;
      _catalogError = null;
    });
    if (year != null) _loadMakes(year);
  }

  Future<int?> _searchCatalog({
    required String title,
    required List<_CatalogChoice> options,
    int? selectedId,
  }) async {
    String query = '';
    return showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, update) {
          final filtered = options.where((item) =>
              item.label.toLowerCase().contains(query.toLowerCase())).toList();
          return Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: SizedBox(
              height: (MediaQuery.sizeOf(context).height -
                  MediaQuery.of(context).viewInsets.bottom) * 0.65,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: const TextStyle(
                            fontSize: 19, fontWeight: FontWeight.w800)),
                        const SizedBox(height: 14),
                        TextField(
                          autofocus: true,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.search),
                            hintText: 'Search by name',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) => update(() => query = value),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: filtered.isEmpty
                        ? const Center(child: Text('No matches found'))
                        : ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final item = filtered[index];
                        return ListTile(
                          title: Text(item.label),
                          trailing: item.id == selectedId
                              ? const Icon(Icons.check_circle, color: _orange)
                              : null,
                          onTap: () => Navigator.pop(sheetContext, item.id),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String? _nameOfMake(int? id) {
    for (final make in _makes) {
      if (make.id == id) return make.name;
    }
    return null;
  }

  String? _nameOfModel(int? id) {
    for (final model in _models) {
      if (model.id == id) return model.name;
    }
    return null;
  }

  Future<void> _chooseMake() async {
    final year = _year;
    if (year == null || _loadingMakes) return;
    final choice = await _searchCatalog(
      title: 'Select manufacturer',
      options: _makes.where((m) => m.id != null)
          .map((m) => _CatalogChoice(m.id!, m.name)).toList(),
      selectedId: _makeId,
    );
    if (!mounted || choice == null || _year != year) return;
    if (choice == _makeId) return;
    _requestGeneration++;
    setState(() {
      _makeId = choice;
      _modelId = null;
      _models = [];
    });
    await _loadModels(choice);
  }

  Future<void> _chooseModel() async {
    final year = _year;
    final makeId = _makeId;
    if (year == null || makeId == null || _loadingModels) return;
    final choice = await _searchCatalog(
      title: 'Select car model',
      options: _models.where((m) => m.id != null)
          .map((m) => _CatalogChoice(m.id!, m.name)).toList(),
      selectedId: _modelId,
    );
    if (!mounted || choice == null || _year != year || _makeId != makeId) return;
    setState(() => _modelId = choice);
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    if (_loadingYears || _loadingMakes || _loadingModels) return;
    if (_year == null) {
      _error('Please select your car year.');
      return;
    }
    if (_makeId == null) {
      _error('Please select a manufacturer.');
      return;
    }
    if (_modelId == null) {
      _error('Please select a model.');
      return;
    }

    // The optional section may be collapsed and its TextFormFields unmounted.
    // Validate their values independently before sending them to Laravel.
    final vin = _vin.text.trim().toUpperCase();
    if (vin.isNotEmpty && !RegExp(r'^[A-HJ-NPR-Z0-9]{17}$').hasMatch(vin)) {
      setState(() => _extraExpanded = true);
      _error('VIN must contain 17 valid characters (no I, O, Q).');
      return;
    }
    if (_mileage.text.trim().isNotEmpty &&
        int.tryParse(_mileage.text.trim()) == null) {
      setState(() => _extraExpanded = true);
      _error('Enter a valid mileage.');
      return;
    }
    if (!_formKey.currentState!.validate()) {
      setState(() => _extraExpanded = true);
      return;
    }
    final data = <String, dynamic>{
      'year': _year,
      'make_id': _makeId,
      'model_id': _modelId,
      'trim_name': _emptyToNull(_trim.text),
      'engine': _emptyToNull(_engine.text),
      if (_fuel != null) 'fuel_type': _fuel,
      if (_transmission != null) 'transmission': _transmission,
      'color': _emptyToNull(_color.text),
      'vin': vin.isEmpty ? null : vin,
      'plate_number': _emptyToNull(_plate.text),
      if (_mileage.text.trim().isNotEmpty)
        'mileage': int.parse(_mileage.text.trim()),
      'tire_size': _emptyToNull(_tireSize.text),
      'is_primary': _primary,
      if (!_editing) 'status': 'active',
    };
    final provider = context.read<VehicleProvider>();
    final success = _editing
        ? await provider.updateVehicle(widget.vehicle!.id!, data)
        : await provider.createVehicle(data);
    if (!mounted) return;
    if (success) {
      Navigator.pop(context, true);
    } else {
      _error(provider.errorMessage ?? 'Could not save your car. Try again.');
    }
  }

  String? _emptyToNull(String input) =>
      input.trim().isEmpty ? null : input.trim();

  void _error(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  InputDecoration _input(String title, {String? hint}) => InputDecoration(
    labelText: title,
    hintText: hint,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
  );

  Widget _selection({
    required String title,
    required String placeholder,
    required IconData icon,
    required bool enabled,
    required VoidCallback onTap,
    String? selected,
    bool loading = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
        const SizedBox(height: 7),
        Material(
          color: enabled ? Colors.white : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: enabled ? onTap : null,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFD0D5DD)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(icon, color: _orange, size: 19),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(loading ? 'Loading...' : (selected ?? placeholder),
                        style: TextStyle(
                          color: selected != null ? const Color(0xFF172033) : const Color(0xFF667085),
                          fontWeight: selected != null ? FontWeight.w700 : FontWeight.normal,
                        )),
                  ),
                  if (loading)
                    const SizedBox(width: 18, height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2))
                  else
                    const Icon(Icons.keyboard_arrow_down_rounded,
                        color: Color(0xFF667085)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final saving = context.watch<VehicleProvider>().isSubmitting;
    final usableYears = _years.contains(_year) ? _year : null;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: FractionallySizedBox(
        heightFactor: 0.94,
        child: Container(
          decoration: const BoxDecoration(
            color: CarsManagementPage.lightBackground,
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(20, 16, 16, 14),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
                ),
                child: Row(
                  children: [
                    Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_editing ? 'Edit your car' : 'Add your car',
                            style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w800)),
                        const SizedBox(height: 4),
                        const Text('Year, manufacturer and model must match.',
                            style: TextStyle(color: Color(0xFF667085), fontSize: 12)),
                      ],
                    )),
                    IconButton(onPressed: saving ? null : () => Navigator.maybePop(context),
                        icon: const Icon(Icons.close)),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 26),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _whiteCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('1  Car identification',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                              const SizedBox(height: 7),
                              const Text('Choose the year first. Only available makes and models will be shown.',
                                  style: TextStyle(color: Color(0xFF667085), height: 1.4)),
                              const SizedBox(height: 18),
                              if (_loadingYears)
                                const Center(child: Padding(
                                  padding: EdgeInsets.all(20),
                                  child: CircularProgressIndicator(),
                                ))
                              else ...[
                                DropdownButtonFormField<int>(
                                  key: ValueKey('year-${usableYears ?? "none"}'),
                                  value: usableYears,
                                  isExpanded: true,
                                  decoration: _input('Model year'),
                                  hint: const Text('Select year'),
                                  items: _years.map((y) => DropdownMenuItem<int>(
                                    value: y, child: Text(y.toString()),
                                  )).toList(),
                                  onChanged: saving ? null : _selectYear,
                                ),
                                const SizedBox(height: 14),
                                _selection(
                                  title: 'Manufacturer',
                                  placeholder: _year == null ? 'Select year first' : 'Search manufacturers',
                                  icon: Icons.factory_outlined,
                                  enabled: !saving && _year != null && !_loadingMakes && _makes.isNotEmpty,
                                  loading: _loadingMakes,
                                  selected: _nameOfMake(_makeId),
                                  onTap: _chooseMake,
                                ),
                                const SizedBox(height: 14),
                                _selection(
                                  title: 'Model',
                                  placeholder: _makeId == null ? 'Select manufacturer first' : 'Search models',
                                  icon: Icons.directions_car_outlined,
                                  enabled: !saving && _makeId != null && !_loadingModels && _models.isNotEmpty,
                                  loading: _loadingModels,
                                  selected: _nameOfModel(_modelId),
                                  onTap: _chooseModel,
                                ),
                              ],
                              if (_catalogError != null) ...[
                                const SizedBox(height: 14),
                                Text(_catalogError!,
                                    style: const TextStyle(color: Colors.red, fontSize: 12)),
                                TextButton.icon(
                                  onPressed: _loadingYears || _loadingMakes || _loadingModels
                                      ? null
                                      : () {
                                    if (_years.isEmpty) {
                                      _initializeCatalog();
                                    } else if (_year != null && _makeId == null) {
                                      _loadMakes(_year!);
                                    } else if (_makeId != null) {
                                      _loadModels(_makeId!);
                                    }
                                  },
                                  icon: const Icon(Icons.refresh),
                                  label: const Text('Retry'),
                                ),
                              ],
                              if (_year != null && !_loadingMakes && _makes.isEmpty && _catalogError == null)
                                const Padding(
                                  padding: EdgeInsets.only(top: 10),
                                  child: Text('No supported manufacturers for this year.',
                                      style: TextStyle(color: Color(0xFF667085), fontSize: 12)),
                                ),
                              if (_makeId != null && !_loadingModels && _models.isEmpty && _catalogError == null)
                                const Padding(
                                  padding: EdgeInsets.only(top: 10),
                                  child: Text('No models available for the selected year.',
                                      style: TextStyle(color: Color(0xFF667085), fontSize: 12)),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        _whiteCard(
                          child: Column(
                            children: [
                              ListTile(
                                contentPadding: EdgeInsets.zero,
                                title: const Text('2  Additional details (optional)',
                                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                                subtitle: const Padding(
                                  padding: EdgeInsets.only(top: 4),
                                  child: Text('Trim, VIN, mileage and other details can improve matching.',
                                      style: TextStyle(fontSize: 12)),
                                ),
                                trailing: Icon(_extraExpanded
                                    ? Icons.keyboard_arrow_up_rounded
                                    : Icons.keyboard_arrow_down_rounded),
                                onTap: () => setState(() => _extraExpanded = !_extraExpanded),
                              ),
                              if (_extraExpanded) ...[
                                const SizedBox(height: 12),
                                TextFormField(controller: _trim,
                                    decoration: _input('Trim', hint: 'e.g. LE, XLE')),
                                const SizedBox(height: 12),
                                TextFormField(controller: _engine,
                                    decoration: _input('Engine', hint: 'Optional')),
                                const SizedBox(height: 12),
                                DropdownButtonFormField<String>(
                                  value: const ['gasoline', 'diesel', 'hybrid', 'electric', 'plugin_hybrid', 'other'].contains(_fuel)
                                      ? _fuel : null,
                                  decoration: _input('Fuel type (optional)'),
                                  items: const [
                                    DropdownMenuItem(value: 'gasoline', child: Text('Gasoline')),
                                    DropdownMenuItem(value: 'diesel', child: Text('Diesel')),
                                    DropdownMenuItem(value: 'hybrid', child: Text('Hybrid')),
                                    DropdownMenuItem(value: 'electric', child: Text('Electric')),
                                    DropdownMenuItem(value: 'plugin_hybrid', child: Text('Plug-in hybrid')),
                                    DropdownMenuItem(value: 'other', child: Text('Other')),
                                  ],
                                  onChanged: (value) => setState(() => _fuel = value),
                                ),
                                const SizedBox(height: 12),
                                DropdownButtonFormField<String>(
                                  value: const ['automatic', 'manual', 'cvt', 'other'].contains(_transmission)
                                      ? _transmission : null,
                                  decoration: _input('Transmission (optional)'),
                                  items: const [
                                    DropdownMenuItem(value: 'automatic', child: Text('Automatic')),
                                    DropdownMenuItem(value: 'manual', child: Text('Manual')),
                                    DropdownMenuItem(value: 'cvt', child: Text('CVT')),
                                    DropdownMenuItem(value: 'other', child: Text('Other')),
                                  ],
                                  onChanged: (value) => setState(() => _transmission = value),
                                ),
                                const SizedBox(height: 12),
                                TextFormField(controller: _color,
                                    decoration: _input('Color')),
                                const SizedBox(height: 12),
                                TextFormField(
                                  controller: _vin,
                                  textCapitalization: TextCapitalization.characters,
                                  inputFormatters: [
                                    LengthLimitingTextInputFormatter(17),
                                    UpperCaseTextFormatter(),
                                  ],
                                  decoration: _input('VIN (optional)', hint: '17 letters/numbers'),
                                  validator: (value) {
                                    final vin = (value ?? '').trim().toUpperCase();
                                    if (vin.isEmpty) return null;
                                    if (!RegExp(r'^[A-HJ-NPR-Z0-9]{17}$').hasMatch(vin)) {
                                      return 'VIN must contain 17 valid characters (no I, O, Q).';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 12),
                                TextFormField(controller: _plate,
                                    decoration: _input('License plate')),
                                const SizedBox(height: 12),
                                TextFormField(
                                  controller: _mileage,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                  decoration: _input('Mileage', hint: 'Miles'),
                                  validator: (value) {
                                    if ((value ?? '').trim().isEmpty) return null;
                                    return int.tryParse(value!.trim()) == null
                                        ? 'Enter a valid mileage' : null;
                                  },
                                ),
                                const SizedBox(height: 12),
                                TextFormField(controller: _tireSize,
                                    decoration: _input('Tire size', hint: 'e.g. 225/45R17')),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        SwitchListTile.adaptive(
                          title: const Text('Make this my default car'),
                          subtitle: Text(widget.vehicle?.isPrimary == true
                              ? 'To change your default, select another car from My Cars.'
                              : 'Used first when requesting parts'),
                          value: _primary,
                          activeColor: _orange,
                          onChanged: saving || widget.vehicle?.isPrimary == true
                              ? null
                              : (value) => setState(() => _primary = value),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                color: Colors.white,
                width: double.infinity,
                child: FilledButton(
                  onPressed: saving || _loadingYears || _loadingMakes || _loadingModels
                      ? null : _save,
                  style: FilledButton.styleFrom(
                    backgroundColor: _orange,
                    minimumSize: const Size.fromHeight(52),
                  ),
                  child: saving
                      ? const SizedBox(width: 20, height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Text(_editing ? 'Save changes' : 'Add car'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _whiteCard({required Widget child}) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(17),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: const Color(0xFFE5E7EB)),
    ),
    child: child,
  );
}

/// VIN input uses uppercase, matching VehicleController's backend normalization.
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) =>
      newValue.copyWith(text: newValue.text.toUpperCase());
}
