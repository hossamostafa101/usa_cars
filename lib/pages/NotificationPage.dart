import 'package:flutter/material.dart';
import '../data/local/dbTablesHelpers/NotificationDb.dart';
import '../data/local/dbTablesHelpers/dbModels/db_models.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({Key? key}) : super(key: key);

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final NotificationDb _notificationDb = NotificationDb();
  List<NotificationItem> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    final items = await _notificationDb.getAllItems();
    setState(() {
      _notifications = items;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF00B2CA),
        foregroundColor: Colors.white,
        title: const Text('Notifications'),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
          ? const Center(child: Text('No notifications found.'))
          : ListView.builder(
        itemCount: _notifications.length,
        itemBuilder: (context, index) {
          final notification = _notifications[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              title: Text(notification.title, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(notification.description),
            ),
          );
        },
      ),
    );
  }
}
