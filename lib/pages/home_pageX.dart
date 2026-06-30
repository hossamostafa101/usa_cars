// import 'package:flutter/material.dart';
//
// class HomePage extends StatelessWidget {
//   final VoidCallback? onTapParts;
//   final VoidCallback? onTapRoadside;
//   final VoidCallback? onTapRepairs;
//
//   const HomePage({
//     super.key,
//     this.onTapParts,
//     this.onTapRoadside,
//     this.onTapRepairs,
//   });
//
//   // Brand colors (نفس ألوان login / register)
//   static const Color primaryOrange = Color(0xFFF57C00);
//   static const Color darkGrey = Color(0xFF374151);
//
//   @override
//   void initState() {
//     super.initState();
//
//     Future.microtask(() {
//       context.read<HomeProvider>().loadHome();
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final isDark = theme.brightness == Brightness.dark;
//
//     final textColor = isDark ? Colors.white : darkGrey;
//     final subtleTextColor =
//         isDark ? Colors.white.withOpacity(0.7) : const Color(0xFF6B7280);
//
//     return SafeArea(
//       child: Container(
//         color: const Color(0xFFF3F4F6), // نفس خلفية auth
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // ===== Header =====
//               Row(
//                 children: [
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           'Good morning, Alex',
//                           style: theme.textTheme.titleMedium?.copyWith(
//                             fontWeight: FontWeight.w800,
//                             color: textColor,
//                             letterSpacing: 0.1,
//                           ),
//                         ),
//                         const SizedBox(height: 4),
//                         Text(
//                           'What do you need today?',
//                           style: theme.textTheme.bodyMedium?.copyWith(
//                             color: subtleTextColor,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   // Logo bubble – نفس إحساس auth
//                   Container(
//                     width: 44,
//                     height: 44,
//                     decoration: BoxDecoration(
//                       shape: BoxShape.circle,
//                       color: Colors.white,
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black.withOpacity(0.06),
//                           blurRadius: 10,
//                           offset: const Offset(0, 4),
//                         ),
//                       ],
//                     ),
//                     child: Padding(
//                       padding: const EdgeInsets.all(6),
//                       child: Image.asset(
//                         'assets/icons/otlobha_logo_b.png',
//                         fit: BoxFit.contain,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//
//               const SizedBox(height: 16),
//
//
//               // ===== Current car card =====
//               _CurrentCarCard(
//                 isDark: isDark,
//                 textColor: textColor,
//                 subtleTextColor: subtleTextColor,
//               ),
//
//               const SizedBox(height: 20),
//
//               // ===== Sliding banner =====
//               const _HeroBannerCarousel(),
//
//               const SizedBox(height: 20),
//
//               // ===== Quick actions =====
//               Text(
//                 'Quick actions',
//                 style: theme.textTheme.titleMedium?.copyWith(
//                   fontWeight: FontWeight.w600,
//                   color: textColor,
//                 ),
//               ),
//               const SizedBox(height: 10),
//
//               /*Row(
//                 children: [
//                   Expanded(
//                     child: _QuickActionCard(
//                       title: 'Buy parts',
//                       subtitle: 'Find the right parts\nfor your car',
//                       icon: Icons.build_circle_rounded,
//                       onTap: onTapParts,
//                       accentColor: primaryOrange,
//                       isDark: isDark,
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: _QuickActionCard(
//                       title: 'Roadside help',
//                       subtitle: 'Tow, battery,\nflat tire & more',
//                       icon: Icons.electric_bolt_rounded,
//                       onTap: onTapRoadside,
//                       accentColor: const Color(0xFFFA9D3B),
//                       // برتقالي أفتح
//                       isDark: isDark,
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 12),
//               Row(
//                 children: [
//                   Expanded(
//                     child: _QuickActionCard(
//                       title: 'Book a repair',
//                       subtitle: 'Certified shops\nnear you',
//                       icon: Icons.home_repair_service_rounded,
//                       onTap: onTapRepairs,
//                       accentColor: const Color(0xFFEF6C00),
//                       // برتقالي أغمق
//                       isDark: isDark,
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   const Expanded(
//                     child: SizedBox(), // empty slot
//                   ),
//                 ],
//               ),
//
//               const SizedBox(height: 24),*/
//
//               LayoutBuilder(
//                 builder: (context, constraints) {
//                   final itemWidth = (constraints.maxWidth - 12) / 2;
//
//                   return Wrap(
//                     spacing: 12,
//                     runSpacing: 12,
//                     children: [
//                       // 1) Car repair
//                       SizedBox(
//                         width: itemWidth,
//                         child: _QuickActionCard(
//                           title: 'Car repair',
//                           subtitle: 'Mechanical &\nelectrical issues',
//                           icon: Icons.build_circle_rounded,
//                           onTap: onTapRepairs,
//                           accentColor: primaryOrange,
//                           isDark: isDark,
//                         ),
//                       ),
//
//                       // 2) Tires service
//                       SizedBox(
//                         width: itemWidth,
//                         child: _QuickActionCard(
//                           title: 'Tires service',
//                           subtitle: 'Flat tire,\nreplace & balance',
//                           icon: Icons.blur_circular_rounded,
//                           onTap: onTapRoadside,
//                           // نفس صفحة المساعدة على الطريق
//                           accentColor: const Color(0xFFFA9D3B),
//                           isDark: isDark,
//                         ),
//                       ),
//
//                       // 2) Tires service
//                       SizedBox(
//                         width: itemWidth,
//                         child: _QuickActionCard(
//                           title: 'Roadside help',
//                           subtitle: 'Tow, battery,\nflat tire & more',
//                           icon: Icons.electric_bolt_rounded,
//                           onTap: onTapRoadside,
//                           accentColor: const Color(0xFFFA9D3B),
//                           // برتقالي أفتح
//                           isDark: isDark,
//                         ),
//                       ),
//
//                       // 3) Car parts
//                       SizedBox(
//                         width: itemWidth,
//                         child: _QuickActionCard(
//                           title: 'Car parts',
//                           subtitle: 'Order the\nright spare parts',
//                           icon: Icons.shopping_bag_rounded,
//                           onTap: onTapParts,
//                           accentColor: const Color(0xFFEF6C00),
//                           isDark: isDark,
//                         ),
//                       ),
//
//                       // 4) Tow truck (Tracher / ونش)
//                       SizedBox(
//                         width: itemWidth,
//                         child: _QuickActionCard(
//                           title: 'Tow truck',
//                           subtitle: 'We tow your car\nto the repair shop',
//                           icon: Icons.local_shipping_rounded,
//                           onTap: onTapRoadside,
//                           accentColor: const Color(0xFFFB923C),
//                           isDark: isDark,
//                         ),
//                       ),
//
//                       // 5) Body repair (سمكرة)
//                       SizedBox(
//                         width: itemWidth,
//                         child: _QuickActionCard(
//                           title: 'Body repair',
//                           subtitle: 'Dents, paint\n& body work',
//                           icon: Icons.car_repair_rounded,
//                           onTap: onTapRepairs,
//                           accentColor: const Color(0xFF6B7280),
//                           isDark: isDark,
//                         ),
//                       ),
//                     ],
//                   );
//                 },
//               ),
//
//               const SizedBox(height: 24),
//
//               // ===== Featured offers =====
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     'Featured offers',
//                     style: theme.textTheme.titleMedium?.copyWith(
//                       fontWeight: FontWeight.w600,
//                       color: textColor,
//                     ),
//                   ),
//                   Text(
//                     'View all',
//                     style: theme.textTheme.bodySmall?.copyWith(
//                       color: primaryOrange,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 12),
//               SizedBox(
//                 height: 140,
//                 child: ListView.separated(
//                   scrollDirection: Axis.horizontal,
//                   itemCount: _offers.length,
//                   separatorBuilder: (_, __) => const SizedBox(width: 12),
//                   itemBuilder: (ctx, index) {
//                     final offer = _offers[index];
//                     return _OfferCard(
//                       title: offer['title'] as String,
//                       subtitle: offer['subtitle'] as String,
//                       tag: offer['tag'] as String,
//                       color: offer['color'] as Color,
//                       isDark: isDark,
//                     );
//                   },
//                 ),
//               ),
//
//               const SizedBox(height: 24),
//
//               // ===== Recent activity =====
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     'Recent activity',
//                     style: theme.textTheme.titleMedium?.copyWith(
//                       fontWeight: FontWeight.w600,
//                       color: textColor,
//                     ),
//                   ),
//                   Text(
//                     'View all',
//                     style: theme.textTheme.bodySmall?.copyWith(
//                       color: primaryOrange,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 8),
//               ListView.separated(
//                 physics: const NeverScrollableScrollPhysics(),
//                 shrinkWrap: true,
//                 itemCount: _recentActivity.length,
//                 separatorBuilder: (_, __) => const SizedBox(height: 8),
//                 itemBuilder: (ctx, index) {
//                   final item = _recentActivity[index];
//                   return _ActivityTile(
//                     icon: item['icon'] as IconData,
//                     title: item['title'] as String,
//                     subtitle: item['subtitle'] as String,
//                     status: item['status'] as String,
//                     statusColor: item['statusColor'] as Color,
//                     isDark: isDark,
//                   );
//                 },
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// /// ===== Dummy offers data =====
// const List<Map<String, Object>> _offers = [
//   {
//     'title': 'Brake parts',
//     'subtitle': 'Up to 15% off\non selected brands',
//     'tag': 'For a safer ride',
//     'color': Color(0xFFF57C00),
//   },
//   {
//     'title': 'First roadside trip',
//     'subtitle': 'Get 50% off\nyour first request',
//     'tag': 'New users only',
//     'color': Color(0xFFFB923C),
//   },
//   {
//     'title': 'Free inspection',
//     'subtitle': 'Complimentary check\nat partner shops',
//     'tag': 'Limited time',
//     'color': Color(0xFF6B7280),
//   },
// ];
//
// /// ===== Hero banners data =====
// const List<Map<String, String>> _heroBanners = [
//   {
//     // 'image': 'assets/images/banner_maintenance.jpg',
//     'image': 'https://repairsmith-prod-wordpress.s3.amazonaws.com/2022/09/car-repair.jpg',
//     'title': 'All your car services in one app',
//     'subtitle': 'Repair, tires, body work and more – just a few taps away.',
//     'tag': 'Car care made easy',
//   },
//   {
//     // 'image': 'assets/images/banner_roadside.jpg',
//     'image': 'https://thumbs.dreamstime.com/b/driver-near-broken-car-side-road-minibus-repair-128098589.jpg',
//     'title': '24/7 roadside help',
//     'subtitle': 'Tow trucks, battery boost and flat tire assistance anytime.',
//     'tag': 'Always by your side',
//   },
//   {
//     // 'image': 'assets/images/banner_parts.jpg',
//     'image': 'https://www.detailingdevils.com/uploads/blogs/Basic-Parts-of-Car.webp',
//     'title': 'Genuine & aftermarket parts',
//     'subtitle': 'Order the right parts and get them delivered or installed.',
//     'tag': 'Best value for money',
//   },
// ];
//
// /// ===== Dummy recent activity =====
// final List<Map<String, Object>> _recentActivity = [
//   {
//     'icon': Icons.electric_bolt_rounded,
//     'title': 'Roadside help completed',
//     'subtitle': 'Tow truck – 2.4 miles • 32 min',
//     'status': 'Completed',
//     'statusColor': const Color(0xFF10B981),
//   },
//   {
//     'icon': Icons.build_circle_rounded,
//     'title': 'Parts order #48219',
//     'subtitle': 'Front brake pads • ETA: Tomorrow',
//     'status': 'Shipped',
//     'statusColor': const Color(0xFF2563EB),
//   },
//   {
//     'icon': Icons.home_repair_service_rounded,
//     'title': 'Repair booking confirmed',
//     'subtitle': 'Oil change • Monday 10:30 AM',
//     'status': 'Upcoming',
//     'statusColor': const Color(0xFFF59E0B),
//   },
// ];
//
// class _CurrentCarCard extends StatelessWidget {
//   final bool isDark;
//   final Color textColor;
//   final Color subtleTextColor;
//
//   const _CurrentCarCard({
//     required this.isDark,
//     required this.textColor,
//     required this.subtleTextColor,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     // كارت بسيط أبيض مع شريط برتقالي خفيف
//     return Container(
//       padding: const EdgeInsets.all(14),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(18),
//         color: isDark ? const Color(0xFF020617) : Colors.white,
//         border: Border.all(
//           color: const Color(0xFFF57C00).withOpacity(0.18),
//           width: 1,
//         ),
//       ),
//       child: Row(
//         children: [
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Your car',
//                   style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                     color: subtleTextColor,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   '2019 Toyota Camry SE',
//                   style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                     fontWeight: FontWeight.w700,
//                     color: textColor,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   '76,420 miles • Plate: 7XYZ214',
//                   style: Theme.of(
//                     context,
//                   ).textTheme.bodySmall?.copyWith(color: subtleTextColor),
//                 ),
//                 const SizedBox(height: 10),
//                 Row(
//                   children: [
//                     Icon(
//                       Icons.location_on_rounded,
//                       size: 14,
//                       color: subtleTextColor,
//                     ),
//                     const SizedBox(width: 4),
//                     Text(
//                       'Los Angeles, CA',
//                       style: Theme.of(
//                         context,
//                       ).textTheme.bodySmall?.copyWith(color: subtleTextColor),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(width: 12),
//           Container(
//             width: 46,
//             height: 46,
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(16),
//               color: const Color(0xFFF57C00).withOpacity(0.12),
//             ),
//             child: const Icon(
//               Icons.directions_car_filled_rounded,
//               size: 26,
//               color: Color(0xFFF57C00),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class _QuickActionCard extends StatelessWidget {
//   final String title;
//   final String subtitle;
//   final IconData icon;
//   final VoidCallback? onTap;
//   final Color accentColor;
//   final bool isDark;
//
//   const _QuickActionCard({
//     required this.title,
//     required this.subtitle,
//     required this.icon,
//     required this.onTap,
//     required this.accentColor,
//     required this.isDark,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final bg = isDark ? const Color(0xFF020617) : Colors.white;
//
//     return Material(
//       color: bg,
//       borderRadius: BorderRadius.circular(18),
//       elevation: isDark ? 0 : 2,
//       child: InkWell(
//         borderRadius: BorderRadius.circular(18),
//         onTap: onTap,
//         child: Padding(
//           padding: const EdgeInsets.all(12),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Container(
//                 width: 30,
//                 height: 30,
//                 decoration: BoxDecoration(
//                   color: accentColor.withOpacity(0.12),
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 child: Icon(icon, size: 18, color: accentColor),
//               ),
//               const SizedBox(height: 10),
//               Text(
//                 title,
//                 style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                   fontWeight: FontWeight.w700,
//                   color: isDark ? Colors.white : const Color(0xFF111827),
//                 ),
//               ),
//               const SizedBox(height: 4),
//               Text(
//                 subtitle,
//                 style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                   color:
//                       isDark
//                           ? Colors.white.withOpacity(0.7)
//                           : const Color(0xFF6B7280),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// class _OfferCard extends StatelessWidget {
//   final String title;
//   final String subtitle;
//   final String tag;
//   final Color color;
//   final bool isDark;
//
//   const _OfferCard({
//     required this.title,
//     required this.subtitle,
//     required this.tag,
//     required this.color,
//     required this.isDark,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final baseBg = isDark ? const Color(0xFF020617) : Colors.white;
//
//     return Container(
//       width: 230,
//       padding: const EdgeInsets.all(14),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(18),
//         color: baseBg,
//         border: Border.all(color: color.withOpacity(0.20), width: 1),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(999),
//               color: color.withOpacity(0.12),
//             ),
//             child: Text(
//               tag,
//               style: Theme.of(context).textTheme.labelSmall?.copyWith(
//                 color: color,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ),
//           const SizedBox(height: 10),
//           Text(
//             title,
//             style: Theme.of(context).textTheme.bodyLarge?.copyWith(
//               fontWeight: FontWeight.w700,
//               color: isDark ? Colors.white : const Color(0xFF111827),
//             ),
//           ),
//           const SizedBox(height: 4),
//           Text(
//             subtitle,
//             style: Theme.of(context).textTheme.bodySmall?.copyWith(
//               color:
//                   isDark
//                       ? Colors.white.withOpacity(0.75)
//                       : const Color(0xFF4B5563),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class _ActivityTile extends StatelessWidget {
//   final IconData icon;
//   final String title;
//   final String subtitle;
//   final String status;
//   final Color statusColor;
//   final bool isDark;
//
//   const _ActivityTile({
//     required this.icon,
//     required this.title,
//     required this.subtitle,
//     required this.status,
//     required this.statusColor,
//     required this.isDark,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final bg = isDark ? const Color(0xFF020617) : Colors.white;
//
//     return Container(
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: bg,
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(
//           color:
//               isDark ? Colors.white.withOpacity(0.06) : const Color(0xFFE5E7EB),
//           width: 1,
//         ),
//       ),
//       child: Row(
//         children: [
//           Container(
//             width: 34,
//             height: 34,
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(12),
//               color: statusColor.withOpacity(0.12),
//             ),
//             child: Icon(icon, size: 20, color: statusColor),
//           ),
//           const SizedBox(width: 10),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   title,
//                   style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                     fontWeight: FontWeight.w600,
//                     color: isDark ? Colors.white : const Color(0xFF111827),
//                   ),
//                 ),
//                 const SizedBox(height: 2),
//                 Text(
//                   subtitle,
//                   style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                     color:
//                         isDark
//                             ? Colors.white.withOpacity(0.7)
//                             : const Color(0xFF6B7280),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(width: 8),
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(999),
//               color: statusColor.withOpacity(0.12),
//             ),
//             child: Text(
//               status,
//               style: Theme.of(context).textTheme.labelSmall?.copyWith(
//                 color: statusColor,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class _HeroBannerCarousel extends StatefulWidget {
//   const _HeroBannerCarousel({super.key});
//
//   @override
//   State<_HeroBannerCarousel> createState() => _HeroBannerCarouselState();
// }
//
// class _HeroBannerCarouselState extends State<_HeroBannerCarousel> {
//   final PageController _pageController = PageController(viewportFraction: 0.90);
//   int _currentPage = 0;
//
//   @override
//   void dispose() {
//     _pageController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final isDark = theme.brightness == Brightness.dark;
//
//     return SizedBox(
//       height: 170,
//       child: Stack(
//         children: [
//           PageView.builder(
//             controller: _pageController,
//             itemCount: _heroBanners.length,
//             onPageChanged: (index) {
//               setState(() {
//                 _currentPage = index;
//               });
//             },
//             itemBuilder: (context, index) {
//               final banner = _heroBanners[index];
//
//               return Padding(
//                 padding: const EdgeInsets.only(right: 10),
//                 child: ClipRRect(
//                   borderRadius: BorderRadius.circular(22),
//                   child: Stack(
//                     fit: StackFit.expand,
//                     children: [
//                       // صورة الخلفية
//                       // Image.asset(banner['image']!, fit: BoxFit.cover),
//                       Image.network(banner['image']!, fit: BoxFit.cover),
//
//                       // طبقة تغميق + جريدينت
//                       Container(
//                         decoration: BoxDecoration(
//                           gradient: LinearGradient(
//                             begin: Alignment.topCenter,
//                             end: Alignment.bottomCenter,
//                             colors: [
//                               Colors.black.withOpacity(0.15),
//                               Colors.black.withOpacity(0.65),
//                             ],
//                           ),
//                         ),
//                       ),
//
//                       // المحتوى
//                       Padding(
//                         padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Container(
//                               padding: const EdgeInsets.symmetric(
//                                 horizontal: 10,
//                                 vertical: 4,
//                               ),
//                               decoration: BoxDecoration(
//                                 borderRadius: BorderRadius.circular(999),
//                                 color: Colors.white.withOpacity(0.16),
//                               ),
//                               child: Text(
//                                 banner['tag']!,
//                                 style: theme.textTheme.labelSmall?.copyWith(
//                                   color: Colors.white,
//                                   fontWeight: FontWeight.w600,
//                                   letterSpacing: 0.3,
//                                 ),
//                               ),
//                             ),
//                             const Spacer(),
//                             Text(
//                               banner['title']!,
//                               style: theme.textTheme.titleMedium?.copyWith(
//                                 color: Colors.white,
//                                 fontWeight: FontWeight.w800,
//                               ),
//                             ),
//                             const SizedBox(height: 4),
//                             Text(
//                               banner['subtitle']!,
//                               style: theme.textTheme.bodySmall?.copyWith(
//                                 color: Colors.white.withOpacity(0.88),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             },
//           ),
//
//           // المؤشرات (الدوائر الصغيرة)
//           Positioned(
//             bottom: 10,
//             left: 0,
//             right: 0,
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: List.generate(_heroBanners.length, (index) {
//                 final isActive = index == _currentPage;
//                 return AnimatedContainer(
//                   duration: const Duration(milliseconds: 220),
//                   margin: const EdgeInsets.symmetric(horizontal: 3),
//                   height: 6,
//                   width: isActive ? 18 : 6,
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(999),
//                     color:
//                         isActive ? Colors.white : Colors.white.withOpacity(0.4),
//                   ),
//                 );
//               }),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
