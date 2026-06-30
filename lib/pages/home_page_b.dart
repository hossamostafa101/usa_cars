import 'package:flutter/material.dart';

const double sidePadding = 10;

// Mock Data Models
class MockItem {
  final int id;
  final String name;
  final String image;
  final String address;
  final String created;
  final String price;
  final bool isFeature;
  final bool isFavorite;

  MockItem({
    required this.id,
    required this.name,
    required this.image,
    required this.address,
    required this.created,
    required this.price,
    this.isFeature = false,
    this.isFavorite = false,
  });
}

class MockCategory {
  final int id;
  final String name;
  final String icon;

  MockCategory({
    required this.id,
    required this.name,
    required this.icon,
  });
}

class MockSlider {
  final int id;
  final String image;
  final String title;

  MockSlider({
    required this.id,
    required this.image,
    required this.title,
  });
}

class MockSection {
  final String title;
  final String style;
  final List<MockItem> items;

  MockSection({
    required this.title,
    required this.style,
    required this.items,
  });
}

class HomePage extends StatefulWidget {
  final String? from;

  const HomePage({super.key, this.from});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomePage>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin<HomePage> {
  @override
  bool get wantKeepAlive => true;

  late final ScrollController _scrollController = ScrollController();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
  GlobalKey<RefreshIndicatorState>();

  // Mock Data
  List<MockSlider> sliders = [];
  List<MockCategory> categories = [];
  List<MockSection> sections = [];
  List<MockItem> allItems = [];
  bool isLoading = false;
  bool isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    loadMockData();
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (!isLoadingMore) {
        _loadMoreItems();
      }
    }
  }

  void _loadMoreItems() {
    setState(() {
      isLoadingMore = true;
    });

    // Simulate loading more items
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          allItems.addAll(_generateMockItems(10, startId: allItems.length));
          isLoadingMore = false;
        });
      }
    });
  }

  void loadMockData() {
    setState(() {
      isLoading = true;
    });

    // Mock sliders
    sliders = [
      MockSlider(
        id: 1,
        image: "https://koshycoding.com/sisitravel/public/admin/assets/img/slider_a.jpg",
        title: "Special Offers",
      ),
      MockSlider(
        id: 2,
        image: "https://koshycoding.com/sisitravel/public/admin/assets/img/slider_a.jpg",
        title: "New Arrivals",
      ),
      MockSlider(
        id: 3,
        image: "https://koshycoding.com/sisitravel/public/admin/assets/img/slider_a.jpg",
        title: "Featured Products",
      ),
      /*MockSlider(
        id: 3,
        image: "https://picsum.photos/800/300?random=3",
        title: "Featured Products",
      ),*/
    ];

    // Mock categories
    categories = [
      MockCategory(id: 1, name: "Editing", icon: "assets/cats/a.png"),
      MockCategory(id: 2, name: "UI/UX", icon: "assets/cats/b.png"),
      MockCategory(id: 3, name: "LOGO", icon: "assets/cats/c.png"),
      MockCategory(id: 4, name: "data entry", icon: "assets/cats/d.png"),
      MockCategory(id: 5, name: "Applications", icon: "assets/cats/e.png"),
      MockCategory(id: 6, name: "Websites", icon: "assets/cats/f.png"),
      MockCategory(id: 7, name: "Websites", icon: "assets/cats/a.png"),
      MockCategory(id: 8, name: "Travel", icon: "assets/cats/a.png"),
      MockCategory(id: 9, name: "Food", icon: "assets/cats/a.png"),
      MockCategory(id: 10, name: "Music", icon: "assets/cats/a.png"),
    ];

    // Mock sections
    sections = [
      MockSection(
        title: "Featured Items",
        style: "style_1",
        items: _generateMockItems(5, featured: true),
      ),
      MockSection(
        title: "Latest Items",
        style: "style_2",
        items: _generateMockItems(6),
      ),
      MockSection(
        title: "Popular Items",
        style: "style_3",
        items: _generateMockItems(4),
      ),
    ];

    // Mock all items
    allItems = _generateMockItems(20);

    setState(() {
      isLoading = false;
    });
  }

  List<MockItem> _generateMockItems(int count, {bool featured = false, int startId = 0}) {
    final items = <MockItem>[];
    final itemNames = [
      "iPhone 14 Pro",
      "Samsung Galaxy S23",
      "MacBook Air M2",
      "Nike Air Jordan",
      "Sony WH-1000XM5",
      "iPad Pro 12.9",
      "Tesla Model 3",
      "Canon EOS R6",
      "Dyson V15",
      "Apple Watch Ultra",
      "Gaming Chair Pro",
      "Wireless Earbuds",
      "Smart TV 65\"",
      "Running Shoes",
      "Coffee Machine",
      "Fitness Tracker",
      "Bluetooth Speaker",
      "Laptop Stand",
      "Phone Case",
      "Power Bank"
    ];

    final locations = [
      "New York, NY",
      "Los Angeles, CA",
      "Chicago, IL",
      "Houston, TX",
      "Phoenix, AZ",
      "Philadelphia, PA",
      "San Antonio, TX",
      "San Diego, CA",
      "Dallas, TX",
      "San Jose, CA"
    ];

    for (int i = 0; i < count; i++) {
      items.add(MockItem(
        id: startId + i + 1,
        name: itemNames[i % itemNames.length],
        image: "https://picsum.photos/300/200?random=${startId + i + 100}",
        address: locations[i % locations.length],
        created: DateTime.now()
            .subtract(Duration(days: i * 2))
            .toIso8601String(),
        price: "\$${(100 + (i * 50) % 900)}",
        isFeature: featured,
        isFavorite: i % 3 == 0,
      ));
    }

    return items;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          leadingWidth: double.maxFinite,
          leading: const Padding(
            padding: EdgeInsetsDirectional.only(
                start: sidePadding, end: sidePadding),
            child: LocationWidget(),
          ),
          backgroundColor: Colors.transparent,
        ),
        backgroundColor: Colors.grey[50],
        body: RefreshIndicator(
          key: _refreshIndicatorKey,
          color: Theme.of(context).primaryColor,
          onRefresh: () async {
            loadMockData();
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            shrinkWrap: true,
            controller: _scrollController,
            padding: const EdgeInsetsDirectional.only(bottom: 30),
            children: [
              if (isLoading)
                _buildShimmerEffect()
              else
                _buildHomeContent(),
              _buildAllItemsWidget(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHomeContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const HomeSearchField(),
        SliderWidget(sliders: sliders),
        CategoryWidgetHome(categories: categories),
        ...sections.map((section) => HomeSectionsAdapter(section: section)),
      ],
    );
  }

  Widget _buildAllItemsWidget() {
    if (allItems.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(50.0),
          child: Text("No items found"),
        ),
      );
    }

    const int crossAxisCount = 2;
    final int items = allItems.length;
    final int total = (items ~/ crossAxisCount) + (items % crossAxisCount != 0 ? 1 : 0);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 10),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: total,
          separatorBuilder: (context, index) => const SizedBox(height: 15),
          itemBuilder: (context, index) {
            int itemIndex = index * crossAxisCount;
            return Padding(padding: EdgeInsets.symmetric(horizontal: 8),
                child: SizedBox(
                  height: MediaQuery.sizeOf(context).height / 3.2,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (int i = 0; i < crossAxisCount; ++i) ...[
                        Expanded(
                          child: itemIndex < items
                              ? ItemCard(item: allItems[itemIndex++])
                              : const SizedBox.shrink(),
                        ),
                        if (i != crossAxisCount - 1)
                          const SizedBox(width: 15)
                      ]
                    ],
                  ),
                )
            );
          },
        ),
        if (isLoadingMore)
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: CircularProgressIndicator(),
          ),
      ],
    );
  }

  Widget _buildShimmerEffect() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Column(
        children: [
          _buildShimmerBox(height: 52),
          const SizedBox(height: 12),
          _buildShimmerBox(height: 170),
          const SizedBox(height: 12),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 10,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.only(right: index == 9 ? 0 : 8.0),
                  child: Column(
                    children: [
                      _buildShimmerBox(height: 70, width: 66),
                      const SizedBox(height: 5),
                      _buildShimmerBox(height: 10, width: 48),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerBox({required double height, double? width}) {
    return Container(
      height: height,
      width: width ?? double.maxFinite,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}

// Location Widget
class LocationWidget extends StatelessWidget {
  const LocationWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.location_on, color: Colors.red, size: 20),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            "New York, NY",
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.keyboard_arrow_down),
        ),
      ],
    );
  }
}

// Search Field Widget
class HomeSearchField extends StatelessWidget {
  const HomeSearchField({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to search screen
        print("Navigate to search");
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: sidePadding, vertical: 15),
        height: 56,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
        ),
        child: Row(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Icon(Icons.search, color: Colors.grey),
            ),
            Expanded(
              child: Text(
                "Search for items...",
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Slider Widget
class SliderWidget extends StatefulWidget {
  final List<MockSlider> sliders;

  const SliderWidget({super.key, required this.sliders});

  @override
  State<SliderWidget> createState() => _SliderWidgetState();
}

class _SliderWidgetState extends State<SliderWidget> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.sliders.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 170,
      child: PageView.builder(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        itemCount: widget.sliders.length,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: sidePadding),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.grey.shade200,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                widget.sliders[index].image,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[300],
                    child: const Center(
                      child: Icon(Icons.image_not_supported, size: 50),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

// Category Widget
class CategoryWidgetHome extends StatelessWidget {
  final List<MockCategory> categories;

  const CategoryWidgetHome({super.key, required this.categories});

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) return const SizedBox.shrink();

    return Container(
      height: 103,
      margin: const EdgeInsets.only(top: 12),
      child: ListView.separated(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: sidePadding),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length > 10 ? 11 : categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          if (index == 10) {
            return _buildMoreCategory(context);
          }
          return _buildCategoryCard(categories[index]);
        },
      ),
    );
  }

  Widget _buildCategoryCard(MockCategory category) {
    return SizedBox(
      width: 70,
      child: GestureDetector(
        onTap: () => print("Category tapped: ${category.name}"),
        child: Column(
          children: [
            Container(
              height: 70,
              width: 70,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.grey.shade300),
                color: Colors.white,
              ),
              child: Center(
                child: Image.asset(
                  category.icon,
                  width: 30,
                  height: 30,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: 5),
            Expanded(
              child: Text(
                category.name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoreCategory(BuildContext context) {
    return SizedBox(
      width: 70,
      child: GestureDetector(
        onTap: () => print("More categories"),
        child: Column(
          children: [
            Container(
              height: 70,
              width: 70,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.grey.shade300),
                color: Colors.white,
              ),
              child: const Center(
                child: Icon(Icons.more_horiz, size: 30),
              ),
            ),
            const SizedBox(height: 5),
            const Expanded(
              child: Text(
                "More",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Home Sections Adapter
class HomeSectionsAdapter extends StatelessWidget {
  final MockSection section;

  const HomeSectionsAdapter({super.key, required this.section});

  @override
  Widget build(BuildContext context) {
    if (section.items.isEmpty) return const SizedBox.shrink();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TitleHeader(
          title: section.title,
          onTap: () => print("See all ${section.title}"),
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height / 3.2,
          child: ListView.separated(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: sidePadding),
            scrollDirection: Axis.horizontal,
            separatorBuilder: (context, index) => const SizedBox(width: 14),
            itemCount: section.items.length,
            itemBuilder: (context, index) {
              return ItemCard(
                item: section.items[index],
                width: section.style == "style_1" ? 250 : 144,
                bigCard: section.style == "style_1",
              );
            },
          ),
        ),
      ],
    );
  }
}

// Title Header
class TitleHeader extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const TitleHeader({super.key, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(
          top: 18, bottom: 12, start: sidePadding, end: sidePadding),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          GestureDetector(
            onTap: onTap,
            child: const Text(
              "See All",
              style: TextStyle(
                fontSize: 14,
                color: Colors.blue,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Item Card
class ItemCard extends StatefulWidget {
  final MockItem item;
  final double? width;
  final bool? bigCard;

  const ItemCard({
    super.key,
    required this.item,
    this.width,
    this.bigCard,
  });

  @override
  State<ItemCard> createState() => _ItemCardState();
}

class _ItemCardState extends State<ItemCard> {
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    isFavorite = widget.item.isFavorite;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => print("Item tapped: ${widget.item.name}"),
      child: Container(
        width: widget.width ?? 250,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Stack(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(18),
                      ),
                      child: Image.network(
                        widget.item.image,
                        height: MediaQuery.sizeOf(context).height / 5.45,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: MediaQuery.sizeOf(context).height / 5.45,
                            color: Colors.grey[300],
                            child: const Center(
                              child: Icon(Icons.image_not_supported),
                            ),
                          );
                        },
                      ),
                    ),
                    if (widget.item.isFeature)
                      Positioned(
                        top: 5,
                        left: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            "Featured",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.item.price,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        Text(
                          widget.item.name,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              size: 12,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 2),
                            Expanded(
                              child: Text(
                                widget.item.address,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const Icon(
                              Icons.access_time,
                              size: 12,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              _timeAgo(widget.item.created),
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
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
            Positioned(
              top: (MediaQuery.sizeOf(context).height / 5.45) - 16,
              right: 16,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    isFavorite = !isFavorite;
                  });
                },
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    size: 20,
                    color: isFavorite ? Colors.red : Colors.grey,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _timeAgo(String dateString) {
    final date = DateTime.parse(dateString);
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return "${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago";
    } else if (difference.inHours > 0) {
      return "${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago";
    } else if (difference.inMinutes > 0) {
      return "${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago";
    } else {
      return "Just now";
    }
  }
}