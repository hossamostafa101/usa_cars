// add_service_page.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// Brand colors (from your request)
const kPrimary = Color(0xFF00B2CA);
const kAccent = Color(0xFFFA6E53);

/// Data object to send to your backend later
class ServiceCreateRequest {
  String title = '';
  String category = '';
  String description = '';
  List<String> skills = [];
  String wantedService = '';
  List<String> requirements = [];
  String availability = 'Weekdays';
  String responseTime = 'Within 24h';
  String location = '';
  bool isRemote = false;
  String budget = '';
  String notes = '';
  List<File> portfolioFiles = [];
  List<String> portfolioUrls = []; // if you want to accept links too

  Map<String, dynamic> toJson() => {
    'title': title.trim(),
    'category': category.trim(),
    'description': description.trim(),
    'skills': skills,
    'wantedService': wantedService.trim(),
    'requirements': requirements,
    'availability': availability,
    'responseTime': responseTime,
    'location': location.trim(),
    'isRemote': isRemote,
    'budget': budget.trim(),
    'notes': notes.trim(),
    'portfolioUrls': portfolioUrls,
    // You’ll upload files separately and attach returned URLs
  };
}

class AddServicePage extends StatefulWidget {
  const AddServicePage({super.key});

  @override
  State<AddServicePage> createState() => _AddServicePageState();
}

class _AddServicePageState extends State<AddServicePage> {
  final _formKeys = [
    GlobalKey<FormState>(), // Basics
    GlobalKey<FormState>(), // Skills & Portfolio
    GlobalKey<FormState>(), // Swap Preference
    GlobalKey<FormState>(), // Final Details
  ];

  int _currentStep = 0;
  final req = ServiceCreateRequest();

  // Controllers
  final _titleCtrl = TextEditingController();
  final _categoryCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _newSkillCtrl = TextEditingController();
  final _wantedCtrl = TextEditingController();
  final _requirementCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _budgetCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  // Options
  final _availabilityOptions = const [
    'Weekdays',
    'Weekends',
    'Evenings',
    'Flexible',
  ];
  final _responseTimeOptions = const [
    'Within 1h',
    'Within 6h',
    'Within 12h',
    'Within 24h',
  ];

  // Images
  final _picker = ImagePicker();

  // Helpers
  void _addSkill() {
    final t = _newSkillCtrl.text.trim();
    if (t.isNotEmpty && !req.skills.contains(t)) {
      setState(() => req.skills.add(t));
      _newSkillCtrl.clear();
    }
  }

  void _addRequirement() {
    final t = _requirementCtrl.text.trim();
    if (t.isNotEmpty) {
      setState(() => req.requirements.add(t));
      _requirementCtrl.clear();
    }
  }

  Future<void> _pickPortfolio(bool camera) async {
    final XFile? x = await _picker.pickImage(
      source: camera ? ImageSource.camera : ImageSource.gallery,
      imageQuality: 85,
    );
    if (x != null) {
      setState(() => req.portfolioFiles.add(File(x.path)));
    }
  }

  Future<void> _pickMultiple() async {
    final images = await _picker.pickMultiImage(imageQuality: 85);
    if (images.isNotEmpty) {
      setState(() => req.portfolioFiles.addAll(images.map((e) => File(e.path))));
    }
  }

  void _next() {
    if (_formKeys[_currentStep].currentState?.validate() ?? false) {
      _formKeys[_currentStep].currentState?.save();
      if (_currentStep < 3) {
        setState(() => _currentStep++);
      } else {
        _submit();
      }
    }
  }

  void _back() {
    if (_currentStep > 0) setState(() => _currentStep--);
  }

  void _submit() {
    // Collect all controllers
    req.title = _titleCtrl.text;
    req.category = _categoryCtrl.text;
    req.description = _descCtrl.text;
    req.wantedService = _wantedCtrl.text;
    req.location = _locationCtrl.text;
    req.budget = _budgetCtrl.text;
    req.notes = _notesCtrl.text;

    // Example: validate minimal portfolio or skills if needed
    if (req.skills.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one skill.')),
      );
      setState(() => _currentStep = 1);
      return;
    }

    // TODO: upload files -> get URLs -> call your API with req.toJson()
    // For now we just preview the payload
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Preview payload'),
        content: SingleChildScrollView(
          child: Text(req.toJson().toString()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Submitted! (mock)')),
              );
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: kPrimary),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _categoryCtrl.dispose();
    _descCtrl.dispose();
    _newSkillCtrl.dispose();
    _wantedCtrl.dispose();
    _requirementCtrl.dispose();
    _locationCtrl.dispose();
    _budgetCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final light = Theme.of(context).brightness == Brightness.light;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimary,
        foregroundColor: Colors.white,
        title: const Text('Add Service'),
        elevation: 0,
      ),
      body: SafeArea(child: Stepper(
        type: StepperType.horizontal,
        currentStep: _currentStep,
        onStepCancel: _back,
        onStepContinue: _next,
        controlsBuilder: (context, details) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _currentStep == 0 ? null : details.onStepCancel,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: light ? kPrimary : Colors.white),
                    ),
                    child: const Text('Back'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: details.onStepContinue,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _currentStep == 3 ? kAccent : kPrimary,
                    ),
                    child: Text(_currentStep == 3 ? 'Publish' : 'Next'),
                  ),
                ),
              ],
            ),
          );
        },
        steps: [
          Step(
            isActive: _currentStep >= 0,
            title: const SizedBox.shrink(), // title is ignored in horizontal; avoid layout
            label: const Text('Basics', overflow: TextOverflow.ellipsis, softWrap: false),
            content: Form(
              key: _formKeys[0],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label('Title *'),
                  TextFormField(
                    controller: _titleCtrl,
                    decoration: _input('e.g., Professional Logo Design', Icons.badge),
                    validator: (v) => (v == null || v.trim().length < 4) ? 'Enter a valid title' : null,
                  ),
                  const SizedBox(height: 14),
                  _label('Category *'),
                  TextFormField(
                    controller: _categoryCtrl,
                    decoration: _input('e.g., Design / Branding', Icons.category),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 14),
                  _label('Description *'),
                  TextFormField(
                    controller: _descCtrl,
                    maxLines: 6,
                    decoration: _input('Describe your service, process and deliverables', Icons.description),
                    validator: (v) => (v == null || v.trim().length < 30) ? 'Min 30 characters' : null,
                  ),
                ],
              ),
            ),
          ),
          Step(
            isActive: _currentStep >= 1,
            title: const SizedBox.shrink(),
            label: const Text('Skills', overflow: TextOverflow.ellipsis, softWrap: false),
            content: Form(
              key: _formKeys[1],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label('Skills *'),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _newSkillCtrl,
                          decoration: _input('Add a skill (e.g., Figma)', Icons.add),
                          onSubmitted: (_) => _addSkill(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _addSkill,
                        style: ElevatedButton.styleFrom(backgroundColor: kPrimary),
                        child: const Text('Add'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final s in req.skills)
                        Chip(
                          label: Text(s),
                          onDeleted: () => setState(() => req.skills.remove(s)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _label('Portfolio'),
                  Row(
                    children: [
                      _portfolioBtn(Icons.image, 'Gallery', () => _pickPortfolio(false)),
                      const SizedBox(width: 8),
                      _portfolioBtn(Icons.photo_camera, 'Camera', () => _pickPortfolio(true)),
                      const SizedBox(width: 8),
                      _portfolioBtn(Icons.collections, 'Multiple', _pickMultiple),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 96,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: req.portfolioFiles.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (_, i) {
                        final f = req.portfolioFiles[i];
                        return Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(f, width: 120, height: 96, fit: BoxFit.cover),
                            ),
                            Positioned(
                              top: 6,
                              right: 6,
                              child: InkWell(
                                onTap: () => setState(() => req.portfolioFiles.removeAt(i)),
                                child: Container(
                                  decoration: const BoxDecoration(
                                    color: Colors.black54,
                                    shape: BoxShape.circle,
                                  ),
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
              ),
            ),
          ),
          Step(
            isActive: _currentStep >= 2,
            title: const SizedBox.shrink(),
            label: const Text('Swap', overflow: TextOverflow.ellipsis, softWrap: false),
            content: Form(
              key: _formKeys[2],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label('Looking to swap for *'),
                  TextFormField(
                    controller: _wantedCtrl,
                    decoration: _input('e.g., Mobile App Development', Icons.swap_horiz),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 14),
                  _label('Requirements (what you need from the other side)'),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _requirementCtrl,
                          decoration: _input('e.g., Brand brief, assets…', Icons.check_circle),
                          onSubmitted: (_) => _addRequirement(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _addRequirement,
                        style: ElevatedButton.styleFrom(backgroundColor: kPrimary),
                        child: const Text('Add'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (int i = 0; i < req.requirements.length; i++)
                        ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.check_circle, color: Colors.green),
                          title: Text(req.requirements[i]),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () => setState(() => req.requirements.removeAt(i)),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Step(
            isActive: _currentStep >= 3,
            title: const SizedBox.shrink(),
            label: const Text('Final', overflow: TextOverflow.ellipsis, softWrap: false),
            content: Form(
              key: _formKeys[3],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label('Availability'),
                  DropdownButtonFormField<String>(
                    value: req.availability,
                    items: _availabilityOptions
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (v) => setState(() => req.availability = v ?? req.availability),
                    decoration: _input(null, Icons.event_available),
                  ),
                  const SizedBox(height: 12),
                  _label('Typical response time'),
                  DropdownButtonFormField<String>(
                    value: req.responseTime,
                    items: _responseTimeOptions
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (v) => setState(() => req.responseTime = v ?? req.responseTime),
                    decoration: _input(null, Icons.timelapse),
                  ),
                  const SizedBox(height: 12),
                  _label('Location *'),
                  TextFormField(
                    controller: _locationCtrl,
                    decoration: _input('e.g., Cairo, EG or Remote', Icons.location_on),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                  Row(
                    children: [
                      Checkbox(
                        value: req.isRemote,
                        onChanged: (v) => setState(() => req.isRemote = v ?? false),
                        activeColor: kPrimary,
                      ),
                      const Text('Remote OK'),
                    ],
                  ),
                  const SizedBox(height: 6),
                  _label('Budget (optional)'),
                  TextFormField(
                    controller: _budgetCtrl,
                    keyboardType: TextInputType.number,
                    decoration: _input('e.g., 50 (USD) or Open', Icons.attach_money),
                  ),
                  const SizedBox(height: 12),
                  _label('Notes'),
                  TextFormField(
                    controller: _notesCtrl,
                    maxLines: 4,
                    decoration: _input('Any extra details…', Icons.notes),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: const [
                      Icon(Icons.info_outline, size: 18, color: Colors.grey),
                      SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'By publishing, you agree to SwapUp terms and community rules.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ));
  }

  // ---------- UI helpers ----------
  Widget _portfolioBtn(IconData icon, String label, VoidCallback onTap) {
    return Expanded(
      child: OutlinedButton.icon(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: kPrimary),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        icon: Icon(icon, color: kPrimary),
        label: Text(label),
      ),
    );
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(
      text,
      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
    ),
  );

  InputDecoration _input(String? hint, IconData icon) => InputDecoration(
    hintText: hint,
    prefixIcon: Icon(icon, color: kPrimary),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey.shade300),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: kPrimary, width: 1.6),
    ),
    contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
  );
}
