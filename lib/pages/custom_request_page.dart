// lib/pages/custom_request_page.dart
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_database/firebase_database.dart';

enum RequestServiceKind { hospital, elderly, kids }
enum Billing { hourly, contract }

class CustomRequestPage extends StatefulWidget {
  final RequestServiceKind? initialKind;
  final Billing initialBilling;

  const CustomRequestPage({
    super.key,
    this.initialKind,
    this.initialBilling = Billing.hourly,
  });

  @override
  State<CustomRequestPage> createState() => _CustomRequestPageState();
}

class _CustomRequestPageState extends State<CustomRequestPage> {
  final _formKey = GlobalKey<FormState>();

  RequestServiceKind? _kind;
  Billing _billing = Billing.hourly;

  DateTime? _dateTime;
  int _durationHours = 2;
  final _address = TextEditingController();
  final _note = TextEditingController();
  final _contactName = TextEditingController();
  final _phone = TextEditingController();
  final _budget = TextEditingController();

  final List<File> _photos = [];
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _kind = widget.initialKind;
    _billing = widget.initialBilling;
  }

  @override
  void dispose() {
    _address.dispose();
    _note.dispose();
    _contactName.dispose();
    _phone.dispose();
    _budget.dispose();
    super.dispose();
  }

  Color get olive => Theme.of(context).colorScheme.primary;

  Future<void> _pickDateTime() async {
    final now = DateTime.now();
    final d = await showDatePicker(
      context: context,
      firstDate: now,
      lastDate: now.add(const Duration(days: 180)),
      initialDate: _dateTime ?? now,
    );
    if (d == null) return;
    final t = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_dateTime ?? now),
    );
    if (t == null) return;
    setState(() => _dateTime = DateTime(d.year, d.month, d.day, t.hour, t.minute));
  }

  Future<void> _useCurrentLocation() async {
    final status = await Permission.location.request();
    if (!status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء منح إذن الموقع')),
      );
      return;
    }
    final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    final placemarks = await placemarkFromCoordinates(pos.latitude, pos.longitude);
    if (placemarks.isNotEmpty) {
      final p = placemarks.first;
      final text = [
        p.street, p.subLocality, p.locality, p.administrativeArea
      ].where((e) => e != null && e!.trim().isNotEmpty).join('، ');
      setState(() => _address.text = text);
    }
  }

  Future<void> _addPhoto() async {
    final x = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 82);
    if (x == null) return;
    setState(() => _photos.add(File(x.path)));
  }

  void _removePhoto(int i) => setState(() => _photos.removeAt(i));

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_dateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('اختر تاريخ ووقت الخدمة')),
      );
      return;
    }
    setState(() => _sending = true);

    final req = CustomServiceRequest(
      kind: _kind!,
      billing: _billing,
      startAt: _dateTime!,
      durationHours: _durationHours,
      address: _address.text.trim(),
      note: _note.text.trim(),
      contactName: _contactName.text.trim(),
      phone: _phone.text.trim(),
      budget: double.tryParse(_budget.text.trim().replaceAll(',', '')),
      localImagePaths: _photos.map((f) => f.path).toList(),
      createdAt: DateTime.now(),
    );

    // Try Firebase Realtime Database (optional)
    bool sentToFirebase = false;
    try {
      final db = FirebaseDatabase.instance;
      await db.ref('custom_requests').push().set(req.toJson());
      sentToFirebase = true;
    } catch (_) {
      // fall back to local
    }

    // Always cache locally (so the sales team can show the record demo)
    final sp = await SharedPreferences.getInstance();
    final key = 'custom_requests';
    final raw = sp.getString(key);
    final list = raw == null ? <String>[] : (jsonDecode(raw) as List).map((e) => e.toString()).toList();
    list.add(jsonEncode(req.toJson()));
    await sp.setString(key, jsonEncode(list));

    if (!mounted) return;
    setState(() => _sending = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(sentToFirebase ? 'تم إرسال الطلب' : 'تم حفظ الطلب محلياً (بدون اتصال)')),
    );
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('طلب خدمة مخصّص')),
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
              children: [
                // نوع الخدمة
                Text('نوع الخدمة', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _ChoicePill(
                      selected: _kind == RequestServiceKind.hospital,
                      label: 'مستشفى',
                      icon: Icons.local_hospital_rounded,
                      onTap: () => setState(() => _kind = RequestServiceKind.hospital),
                    ),
                    _ChoicePill(
                      selected: _kind == RequestServiceKind.elderly,
                      label: 'كبار السن',
                      icon: Icons.elderly_rounded,
                      onTap: () => setState(() => _kind = RequestServiceKind.elderly),
                    ),
                    _ChoicePill(
                      selected: _kind == RequestServiceKind.kids,
                      label: 'أطفال',
                      icon: Icons.child_care_rounded,
                      onTap: () => setState(() => _kind = RequestServiceKind.kids),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // بالفوترة
                Text('طريقة المحاسبة', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                _BillingSwitch(
                  value: _billing,
                  olive: olive,
                  onChanged: (b) => setState(() => _billing = b),
                ),
                const SizedBox(height: 14),

                // الموعد والمدة
                Row(
                  children: [
                    Expanded(
                      child: _FieldButton(
                        label: 'الموعد',
                        value: _dateTime == null ? 'اختر التاريخ والوقت' : _fmtDateTime(_dateTime!),
                        icon: Icons.calendar_month_rounded,
                        onTap: _pickDateTime,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _NumberStepper(
                        label: 'المدة (ساعات)',
                        value: _durationHours,
                        min: 1,
                        max: 24,
                        onChanged: (v) => setState(() => _durationHours = v),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // العنوان و الموقع
                TextFormField(
                  controller: _address,
                  decoration: InputDecoration(
                    labelText: 'العنوان',
                    suffixIcon: IconButton(
                      tooltip: 'استخدم موقعي',
                      onPressed: _useCurrentLocation,
                      icon: const Icon(Icons.my_location_rounded),
                    ),
                  ),
                  validator: (v) {
                    if ((_kind != null) && (v == null || v.trim().isEmpty)) {
                      return 'أدخل العنوان';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),

                // الميزانية + الهاتف
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _budget,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'ميزانية تقريبية (اختياري)'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: _phone,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(labelText: 'رقم الجوال'),
                        validator: (v) {
                          final s = (v ?? '').trim();
                          if (s.isEmpty) return 'أدخل رقم الجوال';
                          if (s.length < 8) return 'رقم غير صحيح';
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // الاسم
                TextFormField(
                  controller: _contactName,
                  decoration: const InputDecoration(labelText: 'اسم صاحب الطلب'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'أدخل الاسم' : null,
                ),
                const SizedBox(height: 10),

                // ملاحظات
                TextField(
                  controller: _note,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'تفاصيل إضافية (اختياري)',
                    hintText: 'أدخل أي ملاحظات خاصة بالحالة أو التوقيت أو المتطلبات',
                  ),
                ),
                const SizedBox(height: 14),

                // صور مرفقة
                _PhotosRow(
                  files: _photos,
                  onAdd: _addPhoto,
                  onRemove: _removePhoto,
                ),
                const SizedBox(height: 18),

                // CTA
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _sending || _kind == null ? null : _submit,
                    icon: _sending
                        ? const SizedBox(
                        width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.send_rounded),
                    label: Text(_sending ? 'جارٍ الإرسال...' : 'إرسال الطلب'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _fmtDateTime(DateTime d) {
    final hh = d.hour.toString().padLeft(2, '0');
    final mm = d.minute.toString().padLeft(2, '0');
    return '${d.year}/${d.month.toString().padLeft(2, '0')}/${d.day.toString().padLeft(2, '0')} — $hh:$mm';
  }
}

/* ======================= Models ======================= */

class CustomServiceRequest {
  final RequestServiceKind kind;
  final Billing billing;
  final DateTime startAt;
  final int durationHours;
  final String address;
  final String note;
  final String contactName;
  final String phone;
  final double? budget;
  final List<String> localImagePaths;
  final DateTime createdAt;

  CustomServiceRequest({
    required this.kind,
    required this.billing,
    required this.startAt,
    required this.durationHours,
    required this.address,
    required this.note,
    required this.contactName,
    required this.phone,
    required this.budget,
    required this.localImagePaths,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'kind': kind.name,
    'billing': billing.name,
    'startAt': startAt.toIso8601String(),
    'durationHours': durationHours,
    'address': address,
    'note': note,
    'contactName': contactName,
    'phone': phone,
    'budget': budget,
    'localImages': localImagePaths,
    'createdAt': createdAt.toIso8601String(),
  };
}

/* ======================= Widgets ======================= */

class _ChoicePill extends StatelessWidget {
  final bool selected;
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  const _ChoicePill({
    required this.selected,
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final olive = Theme.of(context).colorScheme.primary;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? olive.withOpacity(.12) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: selected ? olive : const Color(0x14000000)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: selected ? olive : Colors.black54),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(color: selected ? olive : Colors.black87, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}

class _BillingSwitch extends StatelessWidget {
  final Billing value;
  final ValueChanged<Billing> onChanged;
  final Color olive;
  const _BillingSwitch({required this.value, required this.onChanged, required this.olive});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0x14000000)),
      ),
      child: Row(
        children: [
          _seg('بالساعة', Billing.hourly, value, onChanged, olive),
          _seg('بعقد', Billing.contract, value, onChanged, olive),
        ],
      ),
    );
  }

  Expanded _seg(String label, Billing me, Billing v, ValueChanged<Billing> cb, Color olive) {
    final selected = v == me;
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => cb(me),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 170),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? olive : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: selected ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}

class _FieldButton extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final VoidCallback onTap;
  const _FieldButton({required this.label, required this.value, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final olive = Theme.of(context).colorScheme.primary;
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            children: [
              Icon(icon, color: olive),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              const Icon(Icons.chevron_left_rounded),
            ],
          ),
        ),
      ),
    );
  }
}

class _NumberStepper extends StatelessWidget {
  final String label;
  final int value;
  final int min, max;
  final ValueChanged<int> onChanged;
  const _NumberStepper({required this.label, required this.value, required this.min, required this.max, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Column(
          children: [
            Text(label, style: const TextStyle(fontSize: 12, color: Colors.black54, fontWeight: FontWeight.w700)),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: value > min ? () => onChanged(value - 1) : null,
                  icon: const Icon(Icons.remove_circle_outline),
                ),
                Text('$value', style: const TextStyle(fontWeight: FontWeight.w900)),
                IconButton(
                  onPressed: value < max ? () => onChanged(value + 1) : null,
                  icon: const Icon(Icons.add_circle_outline),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PhotosRow extends StatelessWidget {
  final List<File> files;
  final VoidCallback onAdd;
  final void Function(int index) onRemove;

  const _PhotosRow({required this.files, required this.onAdd, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final olive = Theme.of(context).colorScheme.primary;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('مرفقات (اختياري)', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        SizedBox(
          height: 82,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: files.length + 1,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (_, i) {
              if (i == files.length) {
                return _AddThumb(onTap: onAdd, olive: olive);
              }
              final f = files[i];
              return Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(f, width: 82, height: 82, fit: BoxFit.cover),
                  ),
                  Positioned(
                    top: 4,
                    left: 4,
                    child: InkWell(
                      onTap: () => onRemove(i),
                      child: Container(
                        decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.all(4),
                        child: const Icon(Icons.close, size: 16, color: Colors.white),
                      ),
                    ),
                  )
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class _AddThumb extends StatelessWidget {
  final VoidCallback onTap;
  final Color olive;
  const _AddThumb({required this.onTap, required this.olive});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 82,
        height: 82,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: olive),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(Icons.add_a_photo_rounded, color: olive),
      ),
    );
  }
}
