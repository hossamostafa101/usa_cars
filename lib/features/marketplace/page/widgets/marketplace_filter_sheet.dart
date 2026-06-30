import 'package:flutter/material.dart';

import '../../data/models/marketplace_filter_model.dart';

class MarketplaceFilterSheet extends StatefulWidget {
  final MarketplaceFilterOptionsModel options;
  final MarketplaceFilterState currentFilter;
  final String? productType;

  const MarketplaceFilterSheet({
    super.key,
    required this.options,
    required this.currentFilter,
    required this.productType,
  });

  @override
  State<MarketplaceFilterSheet> createState() => _MarketplaceFilterSheetState();
}

class _MarketplaceFilterSheetState extends State<MarketplaceFilterSheet> {
  late MarketplaceFilterState filter;

  final minPriceController = TextEditingController();
  final maxPriceController = TextEditingController();
  final yearController = TextEditingController();

  @override
  void initState() {
    super.initState();

    filter = MarketplaceFilterState(
      categoryId: widget.currentFilter.categoryId,
      productType: widget.productType,
      brand: widget.currentFilter.brand,
      search: widget.currentFilter.search,
      minPrice: widget.currentFilter.minPrice,
      maxPrice: widget.currentFilter.maxPrice,
      makeId: widget.currentFilter.makeId,
      modelId: widget.currentFilter.modelId,
      year: widget.currentFilter.year,
      tireSize: widget.currentFilter.tireSize,
      width: widget.currentFilter.width,
      aspectRatio: widget.currentFilter.aspectRatio,
      rimDiameter: widget.currentFilter.rimDiameter,
      inStock: widget.currentFilter.inStock,
      sort: widget.currentFilter.sort,
    );

    minPriceController.text = filter.minPrice?.toString() ?? '';
    maxPriceController.text = filter.maxPrice?.toString() ?? '';
    yearController.text = filter.year?.toString() ?? '';
  }

  @override
  void dispose() {
    minPriceController.dispose();
    maxPriceController.dispose();
    yearController.dispose();
    super.dispose();
  }

  void apply() {
    filter.minPrice = double.tryParse(minPriceController.text.trim());
    filter.maxPrice = double.tryParse(maxPriceController.text.trim());
    filter.year = int.tryParse(yearController.text.trim());

    Navigator.pop(context, filter);
  }

  @override
  Widget build(BuildContext context) {
    final isTire = widget.productType == 'tire';

    return DraggableScrollableSheet(
      initialChildSize: 0.86,
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

              const Text(
                'Filter products',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 18),

              _Label('Category'),
              DropdownButtonFormField<int>(
                value: filter.categoryId,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'All categories',
                ),
                items: [
                  const DropdownMenuItem<int>(
                    value: null,
                    child: Text('All categories'),
                  ),
                  ...widget.options.categories.map(
                        (category) => DropdownMenuItem<int>(
                      value: category.id,
                      child: Text(category.name),
                    ),
                  ),
                ],
                onChanged: (value) {
                  setState(() => filter.categoryId = value);
                },
              ),

              const SizedBox(height: 14),

              _Label('Brand'),
              DropdownButtonFormField<String>(
                value: filter.brand,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'All brands',
                ),
                items: [
                  const DropdownMenuItem<String>(
                    value: null,
                    child: Text('All brands'),
                  ),
                  ...widget.options.brands.map(
                        (brand) => DropdownMenuItem<String>(
                      value: brand,
                      child: Text(brand),
                    ),
                  ),
                ],
                onChanged: (value) {
                  setState(() => filter.brand = value);
                },
              ),

              const SizedBox(height: 14),

              _Label('Price range'),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: minPriceController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Min',
                        hintText:
                        widget.options.priceRange?.min?.toString() ?? '0',
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: maxPriceController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Max',
                        hintText:
                        widget.options.priceRange?.max?.toString() ?? '',
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              SwitchListTile(
                value: filter.inStock == 1,
                contentPadding: EdgeInsets.zero,
                activeColor: const Color(0xFFF57C00),
                title: const Text('In stock only'),
                onChanged: (value) {
                  setState(() {
                    filter.inStock = value ? 1 : null;
                  });
                },
              ),

              const SizedBox(height: 14),

              _Label('Sort'),
              DropdownButtonFormField<String>(
                value: filter.sort,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Default sorting',
                ),
                items: [
                  const DropdownMenuItem<String>(
                    value: null,
                    child: Text('Default'),
                  ),
                  ...widget.options.sortOptions.map(
                        (sort) => DropdownMenuItem<String>(
                      value: sort.key,
                      child: Text(sort.title),
                    ),
                  ),
                ],
                onChanged: (value) {
                  setState(() => filter.sort = value);
                },
              ),

              if (!isTire) ...[
                const SizedBox(height: 20),
                _Label('Vehicle fitment'),

                DropdownButtonFormField<int>(
                  value: filter.makeId,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Select make',
                  ),
                  items: widget.options.vehicleMakes
                      .map(
                        (make) => DropdownMenuItem<int>(
                      value: make.id,
                      child: Text(make.name),
                    ),
                  )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      filter.makeId = value;
                      filter.modelId = null;
                    });
                  },
                ),

                const SizedBox(height: 10),

                DropdownButtonFormField<int>(
                  value: filter.modelId,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Select model',
                  ),
                  items: widget.options.vehicleModels
                      .where((model) {
                    if (filter.makeId == null) return true;
                    return model.makeId == filter.makeId;
                  })
                      .map(
                        (model) => DropdownMenuItem<int>(
                      value: model.id,
                      child: Text(model.name),
                    ),
                  )
                      .toList(),
                  onChanged: (value) {
                    setState(() => filter.modelId = value);
                  },
                ),

                const SizedBox(height: 10),

                TextField(
                  controller: yearController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Year',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],

              if (isTire) ...[
                const SizedBox(height: 20),
                _Label('Tire size'),

                DropdownButtonFormField<String>(
                  value: filter.tireSize,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Select tire size',
                  ),
                  items: [
                    const DropdownMenuItem<String>(
                      value: null,
                      child: Text('Any size'),
                    ),
                    ...(widget.options.tireFilters?.sizes ?? []).map(
                          (size) => DropdownMenuItem<String>(
                        value: size,
                        child: Text(size),
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() => filter.tireSize = value);
                  },
                ),

                const SizedBox(height: 10),

                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        value: filter.width,
                        decoration: const InputDecoration(
                          labelText: 'Width',
                          border: OutlineInputBorder(),
                        ),
                        items: (widget.options.tireFilters?.widths ?? [])
                            .map(
                              (value) => DropdownMenuItem<int>(
                            value: value,
                            child: Text(value.toString()),
                          ),
                        )
                            .toList(),
                        onChanged: (value) {
                          setState(() => filter.width = value);
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        value: filter.aspectRatio,
                        decoration: const InputDecoration(
                          labelText: 'Aspect',
                          border: OutlineInputBorder(),
                        ),
                        items:
                        (widget.options.tireFilters?.aspectRatios ?? [])
                            .map(
                              (value) => DropdownMenuItem<int>(
                            value: value,
                            child: Text(value.toString()),
                          ),
                        )
                            .toList(),
                        onChanged: (value) {
                          setState(() => filter.aspectRatio = value);
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        value: filter.rimDiameter,
                        decoration: const InputDecoration(
                          labelText: 'Rim',
                          border: OutlineInputBorder(),
                        ),
                        items:
                        (widget.options.tireFilters?.rimDiameters ?? [])
                            .map(
                              (value) => DropdownMenuItem<int>(
                            value: value,
                            child: Text(value.toString()),
                          ),
                        )
                            .toList(),
                        onChanged: (value) {
                          setState(() => filter.rimDiameter = value);
                        },
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 22),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        final cleared = MarketplaceFilterState(
                          productType: widget.productType,
                        );

                        Navigator.pop(context, cleared);
                      },
                      child: const Text('Clear'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: apply,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF57C00),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Apply filters'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Label extends StatelessWidget {
  final String text;

  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          color: Color(0xFF111827),
        ),
      ),
    );
  }
}