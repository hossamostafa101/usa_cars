import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/constants/us_states.dart';

import '../../location/pages/location_picker_page.dart';
import '../data/models/address_model.dart';
import '../data/services/address_api_service.dart';

class AddressesPage extends StatefulWidget {
  /// When opened from checkout with no saved address, return after saving one.
  final bool returnOnSave;

  const AddressesPage({
    super.key,
    this.returnOnSave = false,
  });

  @override
  State<AddressesPage> createState() =>
      _AddressesPageState();
}

class _AddressesPageState
    extends State<AddressesPage> {
  static const Color orange =
  Color(0xFFF57C00);

  final AddressApiService api =
  AddressApiService();

  List<AddressModel> addresses = [];

  bool isLoading = true;

  String? errorMessage;

  @override
  void initState() {
    super.initState();

    _load();
  }

  Future<void> _load() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final result =
      await api.getAddresses();

      if (!mounted) return;

      setState(() {
        addresses = result;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage = e.toString();
      });
    }
  }

  Future<void> _openEditor({AddressModel? address}) async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddressEditorSheet(
        address: address,
        onSave: (data) async {
          if (address?.id == null) {
            await api.createAddress(data: data);
          } else {
            await api.updateAddress(
              addressId: address!.id!,
              data: data,
            );
          }
        },
      ),
    );

    if (saved != true || !mounted) return;

    await _load();
    if (!mounted) return;

    if (widget.returnOnSave && address == null) {
      Navigator.pop(context, true);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(address == null
            ? 'Address added successfully.'
            : 'Address updated successfully.'),
      ),
    );
  }

  Future<void> _setDefault(
      AddressModel address,
      ) async {
    final id = address.id;

    if (id == null ||
        address.isDefault) {
      return;
    }

    try {
      await api.setDefault(
        id,
      );

      await _load();

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Default address updated.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            e.toString(),
          ),
        ),
      );
    }
  }

  Future<void> _delete(
      AddressModel address,
      ) async {
    final id = address.id;

    if (id == null) return;

    final confirmed =
    await showDialog<bool>(
      context: context,
      builder: (_) =>
          AlertDialog(
            title:
            const Text(
              'Delete address?',
            ),
            content:
            Text(
              'Remove ${address.title} from your saved addresses?',
            ),
            actions: [
              TextButton(
                onPressed: () =>
                    Navigator.pop(
                      context,
                      false,
                    ),
                child:
                const Text(
                  'Cancel',
                ),
              ),
              TextButton(
                onPressed: () =>
                    Navigator.pop(
                      context,
                      true,
                    ),
                child:
                const Text(
                  'Delete',
                  style: TextStyle(
                    color:
                    Colors.red,
                  ),
                ),
              ),
            ],
          ),
    );

    if (confirmed != true) {
      return;
    }

    try {
      await api.deleteAddress(
        id,
      );

      await _load();

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Address deleted.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            e.toString(),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context)
            .brightness ==
            Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(
        0xFF0B0F16,
      )
          : const Color(
        0xFFF5F6F8,
      ),
      appBar:
      AppBar(
        title:
        const Text(
          'Saved addresses',
        ),
      ),
      floatingActionButton: isLoading || addresses.isEmpty
          ? null
          : FloatingActionButton.extended(
        onPressed: () => _openEditor(),
        backgroundColor:
        orange,
        foregroundColor:
        Colors.white,
        icon:
        const Icon(
          Icons.add_location_alt_rounded,
        ),
        label:
        const Text(
          'Add address',
        ),
      ),
      body: RefreshIndicator(
        color:
        orange,
        onRefresh:
        _load,
        child: isLoading
            ? const Center(
          child:
          CircularProgressIndicator(
            color:
            orange,
          ),
        )
            : errorMessage != null &&
            addresses.isEmpty
            ? ListView(
          physics:
          const AlwaysScrollableScrollPhysics(),
          padding:
          const EdgeInsets.all(
            24,
          ),
          children: [
            const SizedBox(
              height:
              120,
            ),
            const Icon(
              Icons
                  .error_outline_rounded,
              size:
              44,
            ),
            const SizedBox(
              height:
              12,
            ),
            Text(
              errorMessage!,
              textAlign:
              TextAlign.center,
            ),
            const SizedBox(
              height:
              12,
            ),
            FilledButton(
              onPressed:
              _load,
              child:
              const Text(
                'Retry',
              ),
            ),
          ],
        )
            : addresses.isEmpty
            ? ListView(
          physics:
          const AlwaysScrollableScrollPhysics(),
          padding:
          const EdgeInsets.all(
            24,
          ),
          children: [
            const SizedBox(height: 104),
            Icon(
              Icons
                  .location_off_outlined,
              size:
              54,
              color:
              Color(
                0xFF9CA3AF,
              ),
            ),
            SizedBox(
              height:
              14,
            ),
            const Text(
              'No saved addresses yet',
              textAlign:
              TextAlign.center,
              style:
              TextStyle(
                fontSize:
                17,
                fontWeight:
                FontWeight.w700,
              ),
            ),
            SizedBox(
              height:
              5,
            ),
            const Text(
              'Save your home, work or another location for faster checkout and service requests.',
              textAlign:
              TextAlign.center,
              style:
              TextStyle(
                color:
                Color(
                  0xFF7C8490,
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 52,
              child: FilledButton.icon(
                onPressed: () => _openEditor(),
                style: FilledButton.styleFrom(
                  backgroundColor: orange,
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.add_location_alt_rounded),
                label: const Text('Add your first address'),
              ),
            ),
          ],
        )
            : ListView.separated(
          physics:
          const AlwaysScrollableScrollPhysics(),
          padding:
          const EdgeInsets.fromLTRB(
            16,
            12,
            16,
            100,
          ),
          itemCount:
          addresses.length,
          separatorBuilder:
              (_, __) =>
          const SizedBox(
            height:
            10,
          ),
          itemBuilder:
              (
              context,
              index,
              ) {
            final address =
            addresses[index];

            return _AddressCard(
              address:
              address,
              isDark:
              isDark,
              onEdit:
                  () {
                _openEditor(
                  address:
                  address,
                );
              },
              onDefault:
                  () {
                _setDefault(
                  address,
                );
              },
              onDelete:
                  () {
                _delete(
                  address,
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _AddressCard
    extends StatelessWidget {
  final AddressModel address;
  final bool isDark;

  final VoidCallback onEdit;
  final VoidCallback onDefault;
  final VoidCallback onDelete;

  const _AddressCard({
    required this.address,
    required this.isDark,
    required this.onEdit,
    required this.onDefault,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
      const EdgeInsets.all(
        14,
      ),
      decoration:
      BoxDecoration(
        color: isDark
            ? const Color(
          0xFF151B25,
        )
            : Colors.white,
        borderRadius:
        BorderRadius.circular(
          17,
        ),
        border:
        Border.all(
          color: address.isDefault
              ? _AddressesPageState
              .orange
              .withOpacity(
            .35,
          )
              : isDark
              ? Colors.white
              .withOpacity(
            .06,
          )
              : const Color(
            0xFFE5E7EB,
          ),
        ),
      ),
      child:
      Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width:
                42,
                height:
                42,
                decoration:
                BoxDecoration(
                  color:
                  _AddressesPageState
                      .orange
                      .withOpacity(
                    .10,
                  ),
                  borderRadius:
                  BorderRadius.circular(
                    12,
                  ),
                ),
                child:
                const Icon(
                  Icons
                      .location_on_rounded,
                  color:
                  _AddressesPageState
                      .orange,
                  size:
                  20,
                ),
              ),

              const SizedBox(
                width:
                10,
              ),

              Expanded(
                child:
                Column(
                  crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child:
                          Text(
                            address
                                .title,
                            maxLines:
                            1,
                            overflow:
                            TextOverflow
                                .ellipsis,
                            style:
                            TextStyle(
                              color: isDark
                                  ? Colors.white
                                  : const Color(
                                0xFF172033,
                              ),
                              fontSize:
                              16,
                              fontWeight:
                              FontWeight
                                  .w700,
                            ),
                          ),
                        ),

                        if (address
                            .isDefault) ...[
                          const SizedBox(
                            width:
                            7,
                          ),
                          Container(
                            padding:
                            const EdgeInsets.symmetric(
                              horizontal:
                              7,
                              vertical:
                              3,
                            ),
                            decoration:
                            BoxDecoration(
                              color:
                              _AddressesPageState
                                  .orange
                                  .withOpacity(
                                .10,
                              ),
                              borderRadius:
                              BorderRadius.circular(
                                999,
                              ),
                            ),
                            child:
                            const Text(
                              'Default',
                              style:
                              TextStyle(
                                color:
                                _AddressesPageState
                                    .orange,
                                fontSize:
                                7.5,
                                fontWeight:
                                FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),

                    const SizedBox(
                      height:
                      3,
                    ),

                    Text(
                      address
                          .fullAddress
                          .isEmpty
                          ? 'Address details unavailable'
                          : address
                          .fullAddress,
                      maxLines:
                      2,
                      overflow:
                      TextOverflow
                          .ellipsis,
                      style:
                      const TextStyle(
                        color:
                        Color(
                          0xFF7D8590,
                        ),
                        fontSize:
                        13,
                        height:
                        1.35,
                      ),
                    ),
                  ],
                ),
              ),

              PopupMenuButton<String>(
                onSelected:
                    (value) {
                  switch (value) {
                    case 'edit':
                      onEdit();
                      break;

                    case 'default':
                      onDefault();
                      break;

                    case 'delete':
                      onDelete();
                      break;
                  }
                },
                itemBuilder:
                    (_) => [
                  const PopupMenuItem(
                    value:
                    'edit',
                    child:
                    Text(
                      'Edit',
                    ),
                  ),
                  if (!address
                      .isDefault)
                    const PopupMenuItem(
                      value:
                      'default',
                      child:
                      Text(
                        'Set as default',
                      ),
                    ),
                  const PopupMenuItem(
                    value:
                    'delete',
                    child:
                    Text(
                      'Delete',
                      style:
                      TextStyle(
                        color:
                        Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          if ((address.phone ?? '')
              .trim()
              .isNotEmpty) ...[
            const SizedBox(
              height:
              10,
            ),
            Row(
              children: [
                const Icon(
                  Icons
                      .phone_outlined,
                  size:
                  14,
                  color:
                  Color(
                    0xFF8B929C,
                  ),
                ),
                const SizedBox(
                  width:
                  5,
                ),
                Text(
                  address.phone!,
                  style:
                  const TextStyle(
                    color:
                    Color(
                      0xFF7D8590,
                    ),
                    fontSize:
                    8.5,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _AddressEditorSheet extends StatefulWidget {
  final AddressModel? address;
  final Future<void> Function(Map<String, dynamic> data) onSave;

  const _AddressEditorSheet({
    this.address,
    required this.onSave,
  });

  @override
  State<_AddressEditorSheet>
  createState() =>
      _AddressEditorSheetState();
}

class _AddressEditorSheetState
    extends State<
        _AddressEditorSheet> {
  final formKey =
  GlobalKey<FormState>();

  late final TextEditingController
  labelController;
  late final TextEditingController
  nameController;
  late final TextEditingController
  phoneController;
  late final TextEditingController
  line1Controller;
  late final TextEditingController
  line2Controller;
  late final TextEditingController
  cityController;
  String? selectedState;
  late final TextEditingController
  postalController;
  late final TextEditingController
  countryController;

  LatLng? point;

  bool isDefault = false;
  bool saving = false;
  String? saveError;

  @override
  void initState() {
    super.initState();

    final address =
        widget.address;

    labelController =
        TextEditingController(
          text: address?.label ?? '',
        );

    nameController =
        TextEditingController(
          text:
          address?.fullName ?? '',
        );

    phoneController =
        TextEditingController(
          text: address?.phone ?? '',
        );

    line1Controller =
        TextEditingController(
          text:
          address?.addressLine1 ??
              '',
        );

    line2Controller =
        TextEditingController(
          text:
          address?.addressLine2 ??
              '',
        );

    cityController =
        TextEditingController(
          text: address?.city ?? '',
        );

    selectedState = UsStates.toCode(address?.state);

    postalController =
        TextEditingController(
          text:
          address?.postalCode ??
              '',
        );

    countryController =
        TextEditingController(
          text:
          address?.country ?? '',
        );

    if (address?.latitude != null &&
        address?.longitude != null) {
      point = LatLng(
        address!.latitude!,
        address.longitude!,
      );
    }

    isDefault =
        address?.isDefault ?? false;
  }

  @override
  void dispose() {
    labelController.dispose();
    nameController.dispose();
    phoneController.dispose();
    line1Controller.dispose();
    line2Controller.dispose();
    cityController.dispose();
    postalController.dispose();
    countryController.dispose();

    super.dispose();
  }

  Future<void>
  _pickLocation() async {
    final result =
    await Navigator.of(context)
        .push<LocationSelection>(
      MaterialPageRoute(
        builder: (_) =>
            LocationPickerPage(
              initialPoint:
              point,
              initialAddress:
              line1Controller
                  .text
                  .trim(),
            ),
      ),
    );

    if (result == null ||
        !mounted) {
      return;
    }

    setState(() {
      point =
          result.point;

      if (line1Controller.text
          .trim()
          .isEmpty) {
        line1Controller.text =
            result.address;
      }
    });
  }

  Future<void> _submit() async {
    if (saving || !formKey.currentState!.validate()) return;

    final data = <String, dynamic>{
      if (labelController.text
          .trim()
          .isNotEmpty)
        'label':
        labelController.text
            .trim(),

      if (nameController.text
          .trim()
          .isNotEmpty)
        'full_name':
        nameController.text
            .trim(),

      if (phoneController.text
          .trim()
          .isNotEmpty)
        'phone':
        phoneController.text
            .trim(),

      'address_line_1':
      line1Controller.text
          .trim(),

      if (line2Controller.text
          .trim()
          .isNotEmpty)
        'address_line_2':
        line2Controller.text
            .trim(),

      'city':
      cityController.text
          .trim(),

      'state': selectedState,

      'postal_code':
      postalController.text
          .trim(),

      if (countryController.text
          .trim()
          .isNotEmpty)
        'country':
        countryController.text
            .trim(),

      if (point != null)
        'latitude':
        point!.latitude,

      if (point != null)
        'longitude':
        point!.longitude,

      'is_default':
      isDefault,
    };
    setState(() {
      saving = true;
      saveError = null;
    });

    try {
      await widget.onSave(data);
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => saveError = e.toString());
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize:
      .91,
      minChildSize:
      .65,
      maxChildSize:
      .96,
      expand:
      false,
      builder:
          (
          context,
          scrollController,
          ) {
        return Material(
          color:
          Theme.of(context)
              .brightness ==
              Brightness.dark
              ? const Color(
            0xFF111722,
          )
              : Colors.white,
          borderRadius:
          const BorderRadius.vertical(
            top:
            Radius.circular(
              24,
            ),
          ),
          child:
          Form(
            key:
            formKey,
            child:
            ListView(
              controller:
              scrollController,
              padding:
              EdgeInsets.fromLTRB(
                18,
                8,
                18,
                MediaQuery.of(
                  context,
                )
                    .viewInsets
                    .bottom +
                    24,
              ),
              children: [
                Center(
                  child:
                  Container(
                    width:
                    42,
                    height:
                    4,
                    margin:
                    const EdgeInsets.only(
                      bottom:
                      16,
                    ),
                    decoration:
                    BoxDecoration(
                      color:
                      const Color(
                        0xFFD1D5DB,
                      ),
                      borderRadius:
                      BorderRadius.circular(
                        999,
                      ),
                    ),
                  ),
                ),

                Text(
                  widget.address ==
                      null
                      ? 'Add address'
                      : 'Edit address',
                  style:
                  const TextStyle(
                    fontSize:
                    18,
                    fontWeight:
                    FontWeight.w800,
                  ),
                ),

                const SizedBox(
                  height:
                  18,
                ),

                Text(
                  'Contact & address label',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),

                TextFormField(
                  controller:
                  labelController,
                  decoration:
                  const InputDecoration(
                    labelText:
                    'Label',
                    hintText:
                    'Home, Work...',
                    prefixIcon:
                    Icon(
                      Icons
                          .bookmark_outline_rounded,
                    ),
                  ),
                ),

                const SizedBox(
                  height:
                  12,
                ),

                TextFormField(
                  controller:
                  nameController,
                  decoration:
                  const InputDecoration(
                    labelText:
                    'Full name',
                    prefixIcon:
                    Icon(
                      Icons
                          .person_outline_rounded,
                    ),
                  ),
                ),

                const SizedBox(
                  height:
                  12,
                ),

                TextFormField(
                  controller:
                  phoneController,
                  keyboardType:
                  TextInputType.phone,
                  decoration:
                  const InputDecoration(
                    labelText:
                    'Phone',
                    prefixIcon:
                    Icon(
                      Icons
                          .phone_outlined,
                    ),
                  ),
                ),

                const SizedBox(
                  height:
                  12,
                ),

                Text(
                  'Delivery location',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),

                TextFormField(
                  controller:
                  line1Controller,
                  decoration:
                  InputDecoration(
                    labelText:
                    'Address line 1',
                    prefixIcon:
                    const Icon(
                      Icons
                          .home_outlined,
                    ),
                    suffixIcon:
                    IconButton(
                      onPressed:
                      _pickLocation,
                      icon:
                      const Icon(
                        Icons
                            .map_outlined,
                        color:
                        _AddressesPageState
                            .orange,
                      ),
                    ),
                  ),
                  validator:
                      (value) {
                    if ((value ?? '')
                        .trim()
                        .isEmpty) {
                      return 'Address is required.';
                    }

                    return null;
                  },
                ),

                const SizedBox(
                  height:
                  12,
                ),

                OutlinedButton.icon(
                  onPressed: _pickLocation,
                  icon: const Icon(Icons.map_outlined),
                  label: Text(point == null
                      ? 'Choose location on map (recommended)'
                      : 'Change pinned location'),
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 4),
                  child: Text(
                    'A map pin helps nearby sellers locate your address.',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller:
                  line2Controller,
                  decoration:
                  const InputDecoration(
                    labelText:
                    'Address line 2',
                    prefixIcon:
                    Icon(
                      Icons
                          .apartment_outlined,
                    ),
                  ),
                ),

                const SizedBox(
                  height:
                  12,
                ),

                TextFormField(
                  controller: cityController,
                  decoration: const InputDecoration(
                    labelText: 'City',
                    border: OutlineInputBorder(),
                  ),
                  validator: _required,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedState,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'State',
                    hintText: 'Select US state',
                    border: OutlineInputBorder(),
                  ),
                  items: UsStates.names.entries
                      .map((state) => DropdownMenuItem<String>(
                    value: state.key,
                    child: Text(state.value),
                  ))
                      .toList(),
                  onChanged: (code) => setState(() => selectedState = code),
                  validator: (code) => code == null ? 'Select a state' : null,
                ),

                const SizedBox(
                  height:
                  12,
                ),

                Row(
                  children: [
                    Expanded(
                      child:
                      TextFormField(
                        controller:
                        postalController,
                        decoration:
                        const InputDecoration(
                          labelText:
                          'Postal code',
                        ),
                        validator:
                        _required,
                      ),
                    ),
                    const SizedBox(
                      width:
                      10,
                    ),
                    Expanded(
                      child:
                      TextFormField(
                        controller:
                        countryController,
                        decoration:
                        const InputDecoration(
                          labelText:
                          'Country',
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(
                  height:
                  12,
                ),

                SwitchListTile.adaptive(
                  contentPadding:
                  EdgeInsets.zero,
                  value:
                  isDefault,
                  activeColor:
                  _AddressesPageState
                      .orange,
                  title:
                  const Text(
                    'Default address',
                    style:
                    TextStyle(
                      fontWeight:
                      FontWeight.w700,
                    ),
                  ),
                  subtitle:
                  const Text(
                    'Use this address first during checkout and service requests.',
                  ),
                  onChanged:
                      (value) {
                    setState(() {
                      isDefault =
                          value;
                    });
                  },
                ),

                if (point !=
                    null) ...[
                  const SizedBox(
                    height:
                    4,
                  ),
                  Container(
                    padding:
                    const EdgeInsets.all(
                      11,
                    ),
                    decoration:
                    BoxDecoration(
                      color:
                      _AddressesPageState
                          .orange
                          .withOpacity(
                        .08,
                      ),
                      borderRadius:
                      BorderRadius.circular(
                        12,
                      ),
                    ),
                    child:
                    const Row(
                      children: [
                        Icon(
                          Icons
                              .check_circle_rounded,
                          color:
                          _AddressesPageState
                              .orange,
                          size:
                          18,
                        ),
                        SizedBox(
                          width:
                          7,
                        ),
                        Expanded(
                          child:
                          Text(
                            'Map location saved for this address.',
                            style:
                            TextStyle(
                              fontSize:
                              9.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(
                  height:
                  20,
                ),

                if (saveError != null) ...[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      saveError!,
                      style: TextStyle(color: Theme.of(context).colorScheme.error),
                    ),
                  ),
                ],
                SizedBox(
                  height:
                  52,
                  child:
                  FilledButton(
                    onPressed: saving ? null : _submit,
                    style:
                    FilledButton.styleFrom(
                      backgroundColor:
                      _AddressesPageState
                          .orange,
                    ),
                    child: saving
                        ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                        : Text(widget.address == null
                        ? 'Save address'
                        : 'Save changes'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static String? _required(
      String? value,
      ) {
    if ((value ?? '')
        .trim()
        .isEmpty) {
      return 'Required';
    }

    return null;
  }
}
