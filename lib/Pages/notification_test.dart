import 'package:flutter/material.dart';
import '../logical/notification.dart';

class NotificationTestPage extends StatefulWidget {
  const NotificationTestPage({super.key});

  @override
  State<NotificationTestPage> createState() => _NotificationTestPageState();
}

class _NotificationTestPageState extends State<NotificationTestPage> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    await NotificationHelper.initializeNotifications();
    setState(() {
      _isInitialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5DC), // Beige background
      appBar: AppBar(
        title: const Text(
          'اختبار الإشعارات',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF4CAF50),
        centerTitle: true,
      ),
      body: _isInitialized
          ? Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 40),

                  // Immediate notification test
                  _buildTestButton(title: 'إشعار فوري', subtitle: 'إرسال إشعار فوري الآن', color: Colors.blue, onPressed: _sendImmediateNotification),

                  const SizedBox(height: 30),

                  // 5 seconds delayed notification
                  _buildTestButton(title: 'إشعار بعد 5 ثواني', subtitle: 'إرسال إشعار مؤجل 5 ثواني', color: Colors.orange, onPressed: _send5SecondNotification),

                  const SizedBox(height: 60),

                  // Cancel all notifications
                  _buildTestButton(
                    title: 'إلغاء جميع الإشعارات',
                    subtitle: 'إلغاء جميع الإشعارات المجدولة',
                    color: Colors.red,
                    onPressed: _cancelAllNotifications,
                  ),
                ],
              ),
            )
          : const Center(child: CircularProgressIndicator(color: Color(0xFF4CAF50))),
    );
  }

  Widget _buildTestButton({required String title, required String subtitle, required Color color, required VoidCallback onPressed}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.3), spreadRadius: 2, blurRadius: 5, offset: const Offset(0, 3))],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.all(20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: 0,
        ),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 5),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _sendImmediateNotification() async {
    await NotificationHelper.sendImmediateNotification(
      id: 1,
      title: 'اختبار الإشعار الفوري',
      message: 'هذا إشعار تجريبي فوري مع الصوت المخصص!',
      //  sessionTime#:#$activityName"
      payload: "25#:#نشط",
      imagePath: 'assets/icons/appIcon.png',
    );
  }

  Future<void> _send5SecondNotification() async {
    await NotificationHelper.sendScheduledNotification(
      id: 1,
      title: 'إشعار مؤجل',
      message: 'هذا إشعار مؤجل لمدة 5 ثواني!',
      seconds: 5,
      imagePath: 'assets/icons/موز.png',
      payload: "5",
    );
  }

  Future<void> _cancelAllNotifications() async {
    await NotificationHelper.cancelAllNotifications();
  }
}
