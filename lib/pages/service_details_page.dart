import 'package:flutter/material.dart';

// Service model (same as in home pages)
class Service {
  final int id;
  final String title;
  final String image;
  final String provider;
  final String location;
  final String created;
  final String category;
  final String wantedService;
  final bool isFeatured;
  final bool isFavorite;
  final List<String> skills;
  final int swapCount;
  final String description;
  final List<String> portfolio;
  final double rating;
  final int reviewCount;
  final String availability;
  final String responseTime;
  final List<String> requirements;

  Service({
    required this.id,
    required this.title,
    required this.image,
    required this.provider,
    required this.location,
    required this.created,
    required this.category,
    required this.wantedService,
    this.isFeatured = false,
    this.isFavorite = false,
    required this.skills,
    this.swapCount = 0,
    required this.description,
    required this.portfolio,
    this.rating = 0.0,
    this.reviewCount = 0,
    required this.availability,
    required this.responseTime,
    required this.requirements,
  });
}

class Review {
  final String reviewerName;
  final String reviewerAvatar;
  final double rating;
  final String comment;
  final String date;
  final String swappedService;

  Review({
    required this.reviewerName,
    required this.reviewerAvatar,
    required this.rating,
    required this.comment,
    required this.date,
    required this.swappedService,
  });
}

class ServiceDetailsPage extends StatefulWidget {
  final Service service;

  const ServiceDetailsPage({super.key, required this.service});

  @override
  State<ServiceDetailsPage> createState() => _ServiceDetailsPageState();
}

class _ServiceDetailsPageState extends State<ServiceDetailsPage>
    with TickerProviderStateMixin {
  bool isFavorite = false;
  late TabController _tabController;
  final PageController _portfolioController = PageController();
  int _currentPortfolioIndex = 0;

  List<Review> reviews = [];

  @override
  void initState() {
    super.initState();
    isFavorite = widget.service.isFavorite;
    _tabController = TabController(length: 3, vsync: this);
    _loadMockReviews();
  }

  void _loadMockReviews() {
    reviews = [
      Review(
        reviewerName: "Alex Johnson",
        reviewerAvatar: "https://i.pravatar.cc/100?u=alex",
        rating: 5.0,
        comment: "Amazing logo design! Sarah delivered exactly what I needed for my app. The swap was smooth and professional.",
        date: "2 days ago",
        swappedService: "Mobile App Development",
      ),
      Review(
        reviewerName: "Maria Garcia",
        reviewerAvatar: "https://i.pravatar.cc/100?u=maria",
        rating: 4.5,
        comment: "Great work on the branding. Very responsive and delivered on time. Highly recommend!",
        date: "1 week ago",
        swappedService: "Web Development",
      ),
      Review(
        reviewerName: "Tom Wilson",
        reviewerAvatar: "https://i.pravatar.cc/100?u=tom",
        rating: 5.0,
        comment: "Perfect logo design! The communication was excellent throughout the swap process.",
        date: "2 weeks ago",
        swappedService: "Content Writing",
      ),
    ];
  }

  @override
  void dispose() {
    _tabController.dispose();
    _portfolioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildServiceInfo(),
                _buildProviderInfo(),
                _buildTabSection(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? Colors.red : Colors.white,
              size: 20,
            ),
          ),
          onPressed: () {
            setState(() {
              isFavorite = !isFavorite;
            });
          },
        ),
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.share, color: Colors.white, size: 20),
          ),
          onPressed: () {
            // Share functionality
          },
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              widget.service.image,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[300],
                  child: const Center(
                    child: Icon(Icons.work_outline, size: 80, color: Colors.grey),
                  ),
                );
              },
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.3),
                  ],
                ),
              ),
            ),
            if (widget.service.isFeatured)
              Positioned(
                top: 100,
                left: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    "Featured Service",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceInfo() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  widget.service.category,
                  style: const TextStyle(
                    color: Color(0xFF00B2CA),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    "${widget.service.rating}",
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  Text(
                    " (${widget.service.reviewCount} reviews)",
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            widget.service.title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.location_on, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                widget.service.location,
                style: TextStyle(color: Colors.grey[600]),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.swap_horiz, size: 14, color: Colors.green),
                    const SizedBox(width: 4),
                    Text(
                      "${widget.service.swapCount} swaps",
                      style: const TextStyle(
                        color: Colors.green,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.cyan.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.cyan.withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Looking to swap for:",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.service.wantedService,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF00B2CA),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.service.skills.map((skill) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  skill,
                  style: const TextStyle(fontSize: 12),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildProviderInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: Colors.cyan.withOpacity(0.1),
              child: Text(
                widget.service.provider.split(' ').map((e) => e[0]).join(),
                style: const TextStyle(
                  color: Color(0xFF00B2CA),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Text area
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Truncate long names
                  Text(
                    widget.service.provider,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Expanded( // allow wrap/ellipsis if tight
                        child: Text(
                          "Responds in ${widget.service.responseTime}",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          widget.service.availability,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // Make button shrink/fit
            FittedBox(
              fit: BoxFit.scaleDown,
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF00B2CA)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  minimumSize: const Size(0, 36), // no min width
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                ),
                child: const Text("Contact"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabSection() {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(25),
          ),
          child: TabBar(
            controller: _tabController,
            indicator: BoxDecoration(
              color: Color(0xFF00B2CA),
              borderRadius: BorderRadius.circular(25),
            ),
            labelColor: Colors.white,
            unselectedLabelColor: Colors.grey[600],
            indicatorSize: TabBarIndicatorSize.tab,
            tabs: const [
              Tab(text: "Description"),
              Tab(text: "Portfolio"),
              Tab(text: "Reviews"),
            ],
          ),
        ),
        SizedBox(
          height: 400,
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildDescriptionTab(),
              _buildPortfolioTab(),
              _buildReviewsTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "About this service",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            widget.service.description,
            softWrap: true,
            style: const TextStyle(fontSize: 14, height: 1.5),
          ),
          const SizedBox(height: 20),
          const Text(
            "Requirements",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...widget.service.requirements.map((r) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.check_circle, size: 16, color: Colors.green),
                const SizedBox(width: 8),
                Expanded(child: Text(r, style: const TextStyle(fontSize: 14))),
              ],
            ),
          )),
          const SizedBox(height: 16), // small tail padding
        ],
      ),
    );
  }


  Widget _buildPortfolioTab() {
    return Column(
      children: [
        SizedBox(
          height: 250,
          child: PageView.builder(
            controller: _portfolioController,
            onPageChanged: (index) {
              setState(() {
                _currentPortfolioIndex = index;
              });
            },
            itemCount: widget.service.portfolio.length,
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    widget.service.portfolio[index],
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[200],
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
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.service.portfolio.length,
                (index) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _currentPortfolioIndex == index
                    ? Color(0xFF00B2CA)
                    : Colors.grey[300],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          "Portfolio Sample ${_currentPortfolioIndex + 1} of ${widget.service.portfolio.length}",
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildReviewsTab() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: reviews.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final review = reviews[index];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: NetworkImage(review.reviewerAvatar),
                    backgroundColor: Colors.grey[200],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          review.reviewerName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Row(
                          children: [
                            Row(
                              children: List.generate(5, (starIndex) {
                                return Icon(
                                  starIndex < review.rating
                                      ? Icons.star
                                      : Icons.star_border,
                                  size: 16,
                                  color: Colors.amber,
                                );
                              }),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              review.date,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                review.comment,
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "Swapped for: ${review.swappedService}",
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF00B2CA),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                _showMessageDialog();
              },
              icon: const Icon(Icons.chat_bubble_outline),
              label: const Text("Message"),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: const BorderSide(color: Color(0xFF00B2CA)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: () {
                _showSwapDialog();
              },
              icon: const Icon(Icons.swap_horiz),
              label: const Text("Request Swap"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF00B2CA),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showMessageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text("Message ${widget.service.provider}"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              maxLines: 4,
              decoration: InputDecoration(
                hintText: "Write your message here...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Message sent!")),
              );
            },
            child: const Text("Send"),
          ),
        ],
      ),
    );
  }

  void _showSwapDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Request Swap"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "You're requesting to swap your service for:",
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                widget.service.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00B2CA),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: "Your Service Offer",
                hintText: "What service can you provide?",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              maxLines: 3,
              decoration: InputDecoration(
                labelText: "Additional Message",
                hintText: "Describe your proposal...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Swap request sent!")),
              );
            },
            child: const Text("Send Request"),
          ),
        ],
      ),
    );
  }
}

// Mock service data for testing
Service createMockService() {
  return Service(
    id: 1,
    title: "Professional Logo Design",
    image: "https://picsum.photos/400/300?random=1",
    provider: "Sarah Designer",
    location: "New York, NY",
    created: DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
    category: "Design",
    wantedService: "Mobile App Development",
    isFeatured: true,
    isFavorite: false,
    skills: ["Logo Design", "Brand Identity", "Adobe Illustrator", "Graphic Design"],
    swapCount: 12,
    description: "I'm a professional graphic designer with 5+ years of experience creating memorable logos and brand identities. I specialize in modern, clean designs that effectively communicate your brand's message. My process includes initial consultation, concept development, revisions, and final delivery in multiple formats.",
    portfolio: [
      "https://picsum.photos/400/300?random=10",
      "https://picsum.photos/400/300?random=11",
      "https://picsum.photos/400/300?random=12",
      "https://picsum.photos/400/300?random=13",
    ],
    rating: 4.8,
    reviewCount: 24,
    availability: "Available this week",
    responseTime: "2 hours",
    requirements: [
      "Provide detailed brief about your business/project",
      "Share color preferences and style guidelines",
      "Provide examples of logos you like",
      "Be available for feedback during the design process",
    ],
  );
}