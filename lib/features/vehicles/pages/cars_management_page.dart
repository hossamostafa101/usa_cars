import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/models/vehicle_catalog_model.dart';
import '../data/models/vehicle_model.dart';
import '../providers/vehicle_provider.dart';

class CarsManagementPage extends StatefulWidget {
  const CarsManagementPage({super.key});

  static const Color primaryOrange = Color(0xFFF57C00);
  static const Color lightBackground = Color(0xFFF3F4F6);

  @override
  State<CarsManagementPage> createState() => _CarsManagementPageState();
}

class _CarsManagementPageState extends State<CarsManagementPage> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<VehicleProvider>().loadVehicles();
      context.read<VehicleProvider>().loadMakes();
    });
  }

  void _openVehicleSheet({VehicleModel? vehicle}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return _VehicleFormSheet(vehicle: vehicle);
      },
    );
  }

  Future<void> _confirmDelete(VehicleModel vehicle) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Delete car?'),
          content: Text(
            'Are you sure you want to delete ${vehicle.displayName}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );

    if (result != true) return;

    final success = await context
        .read<VehicleProvider>()
        .deleteVehicle(vehicle.id!);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success ? 'Car deleted successfully' : 'Failed to delete car',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<VehicleProvider>();

    return Scaffold(
      backgroundColor: CarsManagementPage.lightBackground,
      appBar: AppBar(
        title: const Text('My Cars'),
        backgroundColor: CarsManagementPage.lightBackground,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => _openVehicleSheet(),
            icon: const Icon(Icons.add_circle_outline),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: CarsManagementPage.primaryOrange,
        foregroundColor: Colors.white,
        onPressed: () => _openVehicleSheet(),
        icon: const Icon(Icons.add),
        label: const Text('Add car'),
      ),
      body: RefreshIndicator(
        onRefresh: provider.loadVehicles,
        child: provider.isLoading && provider.vehicles.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : provider.vehicles.isEmpty
            ? ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const SizedBox(height: 80),
            Icon(
              Icons.directions_car_filled_outlined,
              size: 90,
              color: Colors.grey.shade500,
            ),
            const SizedBox(height: 16),
            const Text(
              'No cars added yet',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add your car to get accurate repair and roadside services.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _openVehicleSheet(),
              icon: const Icon(Icons.add),
              label: const Text('Add your first car'),
            ),
          ],
        )
            : ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
          itemCount: provider.vehicles.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final vehicle = provider.vehicles[index];

            return _VehicleCard(
              vehicle: vehicle,
              onEdit: () => _openVehicleSheet(vehicle: vehicle),
              onDelete: vehicle.id == null
                  ? null
                  : () => _confirmDelete(vehicle),
              onSetPrimary: vehicle.id == null || vehicle.isPrimary
                  ? null
                  : () async {
                final success = await context
                    .read<VehicleProvider>()
                    .setPrimary(vehicle.id!);

                if (!mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Primary car updated'
                          : 'Failed to update primary car',
                    ),
                  ),
                );
              },
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
    required this.onDelete,
    required this.onSetPrimary,
  });

  @override
  Widget build(BuildContext context) {
    final isPrimary = vehicle.isPrimary;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isPrimary
            ? CarsManagementPage.primaryOrange
            : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isPrimary
              ? CarsManagementPage.primaryOrange
              : const Color(0xFFE5E7EB),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.directions_car_filled_rounded,
                color: isPrimary ? Colors.white : CarsManagementPage.primaryOrange,
                size: 34,
              ),
              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vehicle.displayName.isEmpty
                          ? 'Vehicle'
                          : vehicle.displayName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isPrimary ? Colors.white : const Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      vehicle.details.isEmpty ? 'No details' : vehicle.details,
                      style: TextStyle(
                        color: isPrimary
                            ? Colors.white.withOpacity(0.9)
                            : const Color(0xFF6B7280),
                      ),
                    ),
                    if ((vehicle.tireSize ?? '').isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Tires: ${vehicle.tireSize}',
                        style: TextStyle(
                          color: isPrimary
                              ? Colors.white.withOpacity(0.9)
                              : const Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              PopupMenuButton<String>(
                iconColor: isPrimary ? Colors.white : null,
                onSelected: (value) {
                  if (value == 'edit') onEdit();
                  if (value == 'primary') onSetPrimary?.call();
                  if (value == 'delete') onDelete?.call();
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Text('Edit'),
                  ),
                  if (!isPrimary)
                    const PopupMenuItem(
                      value: 'primary',
                      child: Text('Set as primary'),
                    ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text('Delete'),
                  ),
                ],
              ),
            ],
          ),

          if (isPrimary) ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  color: Colors.white.withOpacity(0.18),
                ),
                child: const Text(
                  'Default car',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
class _VehicleFormSheet extends StatefulWidget {
  final VehicleModel? vehicle;

  const _VehicleFormSheet({
    this.vehicle,
  });

  @override
  State<_VehicleFormSheet> createState() => _VehicleFormSheetState();
}

class _VehicleFormSheetState extends State<_VehicleFormSheet> {
  final formKey = GlobalKey<FormState>();

  int? makeId;
  int? modelId;

  final yearController = TextEditingController();
  final trimController = TextEditingController();
  final engineController = TextEditingController();
  final colorController = TextEditingController();
  final vinController = TextEditingController();
  final plateController = TextEditingController();
  final mileageController = TextEditingController();
  final tireSizeController = TextEditingController();

  String fuelType = 'gasoline';
  String transmission = 'automatic';
  bool isPrimary = false;

  bool get isEdit => widget.vehicle != null;

  @override
  void initState() {
    super.initState();

    final vehicle = widget.vehicle;

    if (vehicle != null) {
      yearController.text = vehicle.year?.toString() ?? '';
      trimController.text = vehicle.trimName ?? '';
      engineController.text = vehicle.engine ?? '';
      colorController.text = vehicle.color ?? '';
      vinController.text = vehicle.vin ?? '';
      plateController.text = vehicle.plateNumber ?? '';
      mileageController.text = vehicle.mileage?.toString() ?? '';
      tireSizeController.text = vehicle.tireSize ?? '';
      isPrimary = vehicle.isPrimary;
    }
  }

  @override
  void dispose() {
    yearController.dispose();
    trimController.dispose();
    engineController.dispose();
    colorController.dispose();
    vinController.dispose();
    plateController.dispose();
    mileageController.dispose();
    tireSizeController.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    if (!formKey.currentState!.validate()) return;

    if (!isEdit && (makeId == null || modelId == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select make and model')),
      );
      return;
    }

    final data = <String, dynamic>{
      if (makeId != null) 'make_id': makeId,
      if (modelId != null) 'model_id': modelId,
      'year': int.tryParse(yearController.text.trim()),
      'trim_name': trimController.text.trim().isEmpty
          ? null
          : trimController.text.trim(),
      'engine': engineController.text.trim().isEmpty
          ? null
          : engineController.text.trim(),
      'fuel_type': fuelType,
      'transmission': transmission,
      'color': colorController.text.trim().isEmpty
          ? null
          : colorController.text.trim(),
      'vin': vinController.text.trim().isEmpty
          ? null
          : vinController.text.trim(),
      'plate_number': plateController.text.trim().isEmpty
          ? null
          : plateController.text.trim(),
      'mileage': int.tryParse(mileageController.text.trim()) ?? 0,
      'tire_size': tireSizeController.text.trim().isEmpty
          ? null
          : tireSizeController.text.trim(),
      'is_primary': isPrimary,
      'status': 'active',
    };

    final provider = context.read<VehicleProvider>();

    final success = isEdit
        ? await provider.updateVehicle(widget.vehicle!.id!, data)
        : await provider.createVehicle(data);

    if (!mounted) return;

    if (success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEdit ? 'Car updated' : 'Car added'),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'Operation failed'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<VehicleProvider>();

    return DraggableScrollableSheet(
      initialChildSize: 0.90,
      minChildSize: 0.55,
      maxChildSize: 0.95,
      builder: (_, controller) {
        return Container(
          padding: EdgeInsets.only(
            left: 18,
            right: 18,
            top: 18,
            bottom: MediaQuery.of(context).viewInsets.bottom + 18,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(28),
            ),
          ),
          child: Form(
            key: formKey,
            child: ListView(
              controller: controller,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                Text(
                  isEdit ? 'Edit Car' : 'Add Car',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 18),

                if (!isEdit) ...[
                  DropdownButtonFormField<int>(
                    value: makeId,
                    decoration: const InputDecoration(
                      labelText: 'Make',
                      border: OutlineInputBorder(),
                    ),
                    items: provider.makes
                        .map(
                          (make) => DropdownMenuItem<int>(
                        value: make.id,
                        child: Text(make.name),
                      ),
                    )
                        .toList(),
                    onChanged: (value) async {
                      setState(() {
                        makeId = value;
                        modelId = null;
                      });

                      if (value != null) {
                        await context
                            .read<VehicleProvider>()
                            .loadModelsByMake(value);
                      }
                    },
                    validator: (value) {
                      if (value == null) return 'Select make';
                      return null;
                    },
                  ),

                  const SizedBox(height: 12),

                  DropdownButtonFormField<int>(
                    value: modelId,
                    decoration: const InputDecoration(
                      labelText: 'Model',
                      border: OutlineInputBorder(),
                    ),
                    items: provider.models
                        .map(
                          (model) => DropdownMenuItem<int>(
                        value: model.id,
                        child: Text(model.name),
                      ),
                    )
                        .toList(),
                    onChanged: (value) {
                      setState(() => modelId = value);
                    },
                    validator: (value) {
                      if (value == null) return 'Select model';
                      return null;
                    },
                  ),

                  const SizedBox(height: 12),
                ],

                TextFormField(
                  controller: yearController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Year',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    final year = int.tryParse(value ?? '');
                    if (year == null) return 'Enter valid year';
                    if (year < 1900 || year > DateTime.now().year + 1) {
                      return 'Invalid year';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 12),

                TextFormField(
                  controller: trimController,
                  decoration: const InputDecoration(
                    labelText: 'Trim',
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: fuelType,
                        decoration: const InputDecoration(
                          labelText: 'Fuel',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'gasoline',
                            child: Text('Gasoline'),
                          ),
                          DropdownMenuItem(
                            value: 'diesel',
                            child: Text('Diesel'),
                          ),
                          DropdownMenuItem(
                            value: 'hybrid',
                            child: Text('Hybrid'),
                          ),
                          DropdownMenuItem(
                            value: 'electric',
                            child: Text('Electric'),
                          ),
                          DropdownMenuItem(
                            value: 'plugin_hybrid',
                            child: Text('Plugin Hybrid'),
                          ),
                          DropdownMenuItem(
                            value: 'other',
                            child: Text('Other'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => fuelType = value);
                          }
                        },
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: transmission,
                        decoration: const InputDecoration(
                          labelText: 'Transmission',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'automatic',
                            child: Text('Automatic'),
                          ),
                          DropdownMenuItem(
                            value: 'manual',
                            child: Text('Manual'),
                          ),
                          DropdownMenuItem(
                            value: 'cvt',
                            child: Text('CVT'),
                          ),
                          DropdownMenuItem(
                            value: 'other',
                            child: Text('Other'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => transmission = value);
                          }
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                TextFormField(
                  controller: engineController,
                  decoration: const InputDecoration(
                    labelText: 'Engine',
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 12),

                TextFormField(
                  controller: colorController,
                  decoration: const InputDecoration(
                    labelText: 'Color',
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 12),

                TextFormField(
                  controller: vinController,
                  decoration: const InputDecoration(
                    labelText: 'VIN',
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 12),

                TextFormField(
                  controller: plateController,
                  decoration: const InputDecoration(
                    labelText: 'Plate Number',
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 12),

                TextFormField(
                  controller: mileageController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Mileage',
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 12),

                TextFormField(
                  controller: tireSizeController,
                  decoration: const InputDecoration(
                    labelText: 'Tire Size',
                    hintText: '225/45R17',
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 8),

                SwitchListTile(
                  value: isPrimary,
                  onChanged: (value) {
                    setState(() => isPrimary = value);
                  },
                  title: const Text('Set as primary car'),
                  activeColor: CarsManagementPage.primaryOrange,
                ),

                const SizedBox(height: 18),

                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: provider.isSubmitting ? null : submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: CarsManagementPage.primaryOrange,
                      foregroundColor: Colors.white,
                    ),
                    child: provider.isSubmitting
                        ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                        : Text(isEdit ? 'Save Changes' : 'Add Car'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
