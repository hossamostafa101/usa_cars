import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:talabatfresh/data/local/dbTablesHelpers/RideDb.dart';
import '../data/local/dbTablesHelpers/NotificationDb.dart';
import '../data/local/dbTablesHelpers/dbModels/db_models.dart';

class Historypage extends StatefulWidget {
  const Historypage({Key? key}) : super(key: key);

  @override
  State<Historypage> createState() => _HistorypageState();
}

class _HistorypageState extends State<Historypage> {
  final RideDb _rideDb = RideDb();
  List<RideItem> _rideItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    final items = await _rideDb.getAllItems();
    setState(() {
      _rideItems = items;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _rideItems.isEmpty
          ? const Center(child: Text('History is Empty.'))
          : ListView.builder(
        itemCount: _rideItems.length,
        itemBuilder: (context, index) {
          final ride = _rideItems[index];
          return Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  // if (showImage) const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("${ride?.departureDate}",
                            style: GoogleFonts.poppins(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        Text("Left Seats: ${ride?.seats}", style: TextStyle(color: Colors.grey[700])),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(Icons.circle, size: 10, color: Colors.red),
                            SizedBox(width: 4),
                            Expanded(child: Text("${ride?.startName}")),
                          ],
                        ),
                        Row(
                          children: [
                            Icon(Icons.circle, size: 10, color: Colors.amber),
                            SizedBox(width: 4),
                            Expanded(child: Text("${ride?.destName}")),
                          ],
                        ),
                      ],
                    ),
                  ),
                  /*Column(
                    children: [
                      Container(
                        padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.blue[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          "${ride?.departureTime}",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                              fontSize: 12, fontWeight: FontWeight.w500),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Icon(Icons.favorite_border, color: Colors.grey),
                      // const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () {
                          showBookDialog(context, ride!.id, ride);
                        },
                        child: Text('Book'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(horizontal: 16),
                        ),
                      ),
                    ],
                  )*/
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
