import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:flutter_stripe/flutter_stripe.dart' hide Card;

import '../../Stripe/stripe_service.dart' ;
import 'BookingScreen.dart';

class BookingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('My Bookings', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepOrange.shade600,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HistoryScreen()),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Bookings')
            .where('userId', isEqualTo: user?.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error loading bookings'));
          }

          final bookings = snapshot.data?.docs ?? [];

          // Filter bookings - show only upcoming or active ones
          final currentBookings = bookings.where((doc) {
            final booking = doc.data() as Map<String, dynamic>;
            final status = booking['status']?.toString().toLowerCase();
            final isPast = isPastBooking(booking);

            // Show in bookings screen if:
            // 1. Not past booking
            // 2. Status is not completed/cancelled
            // 3. For declined, only if within last day
            return !isPast &&
                status != 'completed' &&
                status != 'cancelled' &&
                (status != 'declined' || !isDeclinedMoreThanOneDay(booking));
          }).toList();

          if (currentBookings.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.calendar_today, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No upcoming bookings',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: currentBookings.length,
            itemBuilder: (context, index) {
              final booking = currentBookings[index].data() as Map<String, dynamic>;
              return BookingCard(
                booking: booking,
                bookingId: currentBookings[index].id,
                onCancel: () async {
                  // Show confirmation dialog
                  final shouldCancel = await showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Confirm Cancellation'),
                      content: Text('Are you sure you want to cancel this booking?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: Text('No'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: Text('Yes'),
                        ),
                      ],
                    ),
                  );

                  if (shouldCancel == true) {
                    try {
                      // Show loading indicator
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) => Center(child: CircularProgressIndicator()),
                      );

                      // Get the document ID from the document snapshot
                      final bookingDocId = currentBookings[index].id;

                      // Update booking status in Firestore
                      await FirebaseFirestore.instance
                          .collection('Bookings')
                          .doc(bookingDocId)
                          .update({
                        'status': 'cancelled',
                        'cancelledAt': FieldValue.serverTimestamp(),
                      });

                      // Close loading indicator
                      Navigator.pop(context);

                      // Show success message
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Booking cancelled successfully')),
                      );
                    } catch (e) {
                      // Close loading indicator
                      Navigator.pop(context);

                      // Show error message
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to cancel booking: ${e.toString()}')),
                      );
                    }
                  }
                },
              );
            },
          );
        },
      ),
    );
  }

  static bool isPastBooking(Map<String, dynamic> booking) {
    if (booking['date'] == null || booking['time'] == null) return false;

    final now = DateTime.now();
    final bookingDate = booking['date'].toDate();
    final timeParts = (booking['time'] as String).split(':');

    try {
      final bookingDateTime = DateTime(
        bookingDate.year,
        bookingDate.month,
        bookingDate.day,
        int.parse(timeParts[0]),
        int.parse(timeParts[1]),
      );
      return bookingDateTime.isBefore(now);
    } catch (e) {
      return false;
    }
  }

  static bool isDeclinedMoreThanOneDay(Map<String, dynamic> booking) {
    if (booking['status']?.toString().toLowerCase() != 'declined') return false;
    if (booking['date'] == null) return false;

    final now = DateTime.now();
    final bookingDate = booking['date'].toDate();
    final oneDayAgo = now.subtract(Duration(days: 1));

    return bookingDate.isBefore(oneDayAgo);
  }
}

class HistoryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('History', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepOrange.shade600,
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Bookings')
            .where('userId', isEqualTo: user?.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error loading history'));
          }

          final bookings = snapshot.data?.docs ?? [];

          // Filter bookings - show only past appointments or completed/cancelled ones
          final historyBookings = bookings.where((doc) {
            final booking = doc.data() as Map<String, dynamic>;
            final status = booking['status']?.toString().toLowerCase();

            // Show in history screen if:
            // 1. It's a past booking
            // 2. Or status is completed/cancelled
            // 3. Or status is declined and older than 1 day
            return BookingsScreen.isPastBooking(booking) ||
                status == 'completed' ||
                status == 'cancelled' ||
                (status == 'declined' && BookingsScreen.isDeclinedMoreThanOneDay(booking));
          }).toList();

          if (historyBookings.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No booking history',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: historyBookings.length,
            itemBuilder: (context, index) {
              final booking = historyBookings[index].data() as Map<String, dynamic>;
              return HistoryCard(
                booking: booking,
                bookingId: historyBookings[index].id,
              );
            },
          );
        },
      ),
    );
  }
}

class BookingCard extends StatelessWidget {
  final Map<String, dynamic> booking;
  final VoidCallback? onCancel;
  final String bookingId;

  BookingCard({
    required this.booking,
    this.onCancel,
    required this.bookingId,
  });

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.green;
      case 'completed':
        return Colors.blue;
      case 'declined':
        return Colors.red;
      case 'cancelled':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  final stripService = StripService();

  Future<void> _handlePayment(BuildContext context) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(child: CircularProgressIndicator()),
      );

      // Get the amount from booking
      final amount = double.tryParse(booking['fees']?.toString() ?? '0') ?? 0;

      // Initialize payment sheet
      await stripService.initPaymentSheet(amount, 'usd');

      // Close loading indicator
      Navigator.pop(context);

      // Show payment sheet
      await Stripe.instance.presentPaymentSheet();

      // Payment successful - update booking and create payment record
      await _recordSuccessfulPayment(context, amount);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment successful!')),
      );
    } on StripeException catch (e) {
      // Close loading indicator
      Navigator.pop(context);

      // Handle payment error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment failed: ${e.error.localizedMessage}')),
      );
    } catch (e) {
      // Close loading indicator
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  Future<void> _recordSuccessfulPayment(BuildContext context, double amount) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not logged in');

      // Create payment record
      await FirebaseFirestore.instance.collection('Payments').add({
        'bookingId': bookingId,
        'userId': user.uid,
        'doctorId': booking['doctorId'],
        'doctorName': booking['doctorName'],
        'clinicName': booking['clinicName'],
        'clinicAddress': booking['clinicAddress'],
        'patientName': booking['childName'],
        'patientGender': booking['gender'],
        'contactNumber': booking['contactNumber'],
        'appointmentDate': booking['date'],
        'appointmentTime': booking['time'],
        'amount': amount,
        'currency': 'usd',
        'status': 'paid',
        'paymentMethod': 'card',
        'paymentDate': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Update booking status to show payment was made
      await FirebaseFirestore.instance
          .collection('Bookings')
          .doc(bookingId)
          .update({
        'paymentStatus': 'paid',
        'paidAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to record payment: ${e.toString()}')),
      );
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDeclined = booking['status']?.toString().toLowerCase() == 'declined';
    final isPaid = booking['paymentStatus']?.toString().toLowerCase() == 'paid';
    final canPay = !isPaid &&
        (booking['status']?.toString().toLowerCase() == 'pending' ||
            booking['status']?.toString().toLowerCase() == 'confirmed');

    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with doctor name and status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    booking['doctorName'] ?? 'Doctor Name',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepOrange,
                    ),
                  ),
                ),
                Chip(
                  label: Text(
                    booking['status']?.toUpperCase() ?? 'STATUS',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  backgroundColor: _getStatusColor(booking['status'] ?? 'pending'),
                  shape: StadiumBorder(
                    side: BorderSide(color: Colors.white.withOpacity(0.2)),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),

            // Clinic information
            Row(
              children: [
                Icon(Icons.medical_services, color: Colors.green),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    booking['clinicName'] ?? 'Clinic Name',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade800,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: 4),

            // Payment status
            if (isPaid)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Icon(Icons.payment, color: Colors.green, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Payment completed',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (booking['paidAt'] != null)
                      Text(
                        ' on ${formatDateTime(booking['paidAt'])}',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(Icons.location_on, color: Colors.red),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    booking['clinicAddress'] ?? 'Clinic Address',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
                if (booking['clinicLocation'] != null)
                  ElevatedButton(
                    onPressed: () {
                      final location = booking['clinicLocation'] as GeoPoint;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ClinicLocationScreen(
                            location: LatLng(location.latitude, location.longitude),
                            clinicName: booking['clinicName'] ?? 'Clinic',
                            address: booking['clinicAddress'] ?? '',
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange.shade400,
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      minimumSize: Size(0, 0),
                    ),
                    child: Text("See on map", style: TextStyle(fontSize: 12, color: Colors.white)),
                  ),
              ],
            ),

            SizedBox(height: 16),
            if (isDeclined && booking['declineReason'] != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Decline Reason:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.red.shade700,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Dr. says! ``${booking['declineReason']}``",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  SizedBox(height: 12),
                ],
              ),

            // Divider
            Divider(color: Colors.grey.shade300),
            SizedBox(height: 12),

            // Patient information
            Row(
              children: [
                Icon(Icons.person, size: 18, color: Colors.deepOrange),
                SizedBox(width: 8),
                Text(
                  'Patient: ${booking['childName'] ?? 'N/A'}',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                SizedBox(width: 16),
                Icon(Icons.family_restroom_sharp, size: 18, color: Colors.deepOrange),
                SizedBox(width: 8),
                Text(
                  booking['gender'] ?? 'N/A',
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
            SizedBox(height: 8),

            // Contact information
            Row(
              children: [
                Icon(Icons.phone, size: 18, color: Colors.deepOrange),
                SizedBox(width: 8),
                Text(
                  'Contact: ${booking['contactNumber'] ?? 'N/A'}',
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
            SizedBox(height: 12),

            // Divider
            Divider(color: Colors.grey.shade300),
            SizedBox(height: 12),

            // Appointment details
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Appointment Date',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        formatDate(booking['date']),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Appointment Time',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        booking['time'] ?? 'N/A',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),

            // Payment section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "PKR: ${booking['fees']}",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepOrange,
                  ),
                ),
                if (canPay)
                  ElevatedButton(
                    onPressed: () => _handlePayment(context),
                    child: Text("Pay online"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
              ],
            ),
            SizedBox(height: 12),

            // Cancel button (only for pending/confirmed bookings)
            if (onCancel != null &&
                (booking['status']?.toString().toLowerCase() == 'pending' ||
                    booking['status']?.toString().toLowerCase() == 'confirmed'))
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onCancel,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Cancel Booking',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),

            // Created at information
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Booked on ${formatDateTime(booking['createdAt'])}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String formatDate(Timestamp? timestamp) {
    if (timestamp == null) return 'N/A';
    final date = timestamp.toDate();
    return DateFormat.yMMMMd().format(date);
  }

  String formatDateTime(Timestamp? timestamp) {
    if (timestamp == null) return 'N/A';
    final date = timestamp.toDate();
    return DateFormat('yMMMd – hh:mm a').format(date);
  }
}

class HistoryCard extends StatelessWidget {
  final Map<String, dynamic> booking;
  final String bookingId;

  HistoryCard({required this.booking, required this.bookingId});

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.purple;
      case 'declined':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDeclined = booking['status']?.toString().toLowerCase() == 'declined';
    final isPaid = booking['paymentStatus']?.toString().toLowerCase() == 'paid';

    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Doctor Name and Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  booking['doctorName'] ?? 'Doctor Name',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepOrange,
                  ),
                ),
                Chip(
                  label: Text(
                    booking['status']?.toUpperCase() ?? 'STATUS',
                    style: TextStyle(color: Colors.white),
                  ),
                  backgroundColor: _getStatusColor(booking['status'] ?? ''),
                ),
              ],
            ),
            SizedBox(height: 10),

            // Payment status in history
            if (isPaid)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Icon(Icons.payment, color: Colors.green, size: 16),
                    SizedBox(width: 8),
                    Text(
                      'Payment completed',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (booking['paidAt'] != null)
                      Text(
                        ' on ${formatDateTime(booking['paidAt'])}',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ),

            // Clinic
            Row(
              children: [
                Icon(Icons.medical_services, color: Colors.green),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    booking['clinicName'] ?? 'Clinic Name',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade800,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: 4),

            // Address
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(Icons.location_on, color: Colors.red),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    booking['clinicAddress'] ?? 'Clinic Address',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                ),
                if (booking['clinicLocation'] != null)
                  ElevatedButton(
                    onPressed: () {
                      final location = booking['clinicLocation'] as GeoPoint;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ClinicLocationScreen(
                            location: LatLng(location.latitude, location.longitude),
                            clinicName: booking['clinicName'] ?? 'Clinic',
                            address: booking['clinicAddress'] ?? '',
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange.shade400,
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      minimumSize: Size(0, 0),
                    ),
                    child: Text("See on map", style: TextStyle(fontSize: 12, color: Colors.white)),
                  ),
              ],
            ),
            SizedBox(height: 12),

            // Decline reason (only for declined bookings)
            if (isDeclined && booking['declineReason'] != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Decline Reason:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.red.shade700,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Dr. says! ``${booking['declineReason']}``",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  SizedBox(height: 12),
                ],
              ),

            // Appointment date/time
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Date: ${formatDate(booking['date'])}',
                  style: TextStyle(fontSize: 14),
                ),
                Text(
                  'Time: ${booking['time'] ?? 'N/A'}',
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
            SizedBox(height: 8),

            // Patient info
            Row(
              children: [
                Icon(Icons.person, size: 18, color: Colors.deepOrange),
                SizedBox(width: 8),
                Text(
                  'Patient: ${booking['childName'] ?? 'N/A'}',
                  style: TextStyle(fontSize: 14),
                ),
                SizedBox(width: 16),
                Icon(Icons.family_restroom_sharp, size: 18, color: Colors.deepOrange),
                SizedBox(width: 8),
                Text(
                  booking['gender'] ?? 'N/A',
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
            SizedBox(height: 8),

            // Contact
            Row(
              children: [
                Icon(Icons.phone, size: 18, color: Colors.deepOrange),
                SizedBox(width: 8),
                Text(
                  'Contact: ${booking['contactNumber'] ?? 'N/A'}',
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
            SizedBox(height: 12),

            // Payment amount
            Row(
              children: [
                Icon(Icons.attach_money, size: 18, color: Colors.deepOrange),
                SizedBox(width: 8),
                Text(
                  'Amount: PKR ${booking['fees'] ?? 'N/A'}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),

            // Feedback button (only for completed bookings)
            if (booking['status']?.toString().toLowerCase() == 'completed')
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    _showFeedbackDialog(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Give Feedback',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            SizedBox(height: 8),

            // Created at and declined/cancelled at
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Booked on ${formatDateTime(booking['createdAt'])}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                if (isDeclined && booking['declinedAt'] != null)
                  Text(
                    'Declined on ${formatDateTime(booking['declinedAt'])}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.red,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                if (booking['status']?.toString().toLowerCase() == 'cancelled' &&
                    booking['cancelledAt'] != null)
                  Text(
                    'Cancelled on ${formatDateTime(booking['cancelledAt'])}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.purple,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  Future<String?> _getParentName(String? userId) async {
    if (userId == null) return null;

    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        return userDoc['name'] as String?;
      }
      return null;
    } catch (e) {
      print('Error fetching user name: $e');
      return null;
    }
  }

  void _showFeedbackDialog(BuildContext context) async {
    // Default values
    double doctorRating = 5.0;
    double clinicRating = 5.0;
    double staffRating = 5.0;
    TextEditingController feedbackController = TextEditingController();
    bool hasPreviousFeedback = false;
    String? previousFeedbackId;
    String? parentName = await _getParentName(booking['userId']);

    // Check for previous feedback
    // try {
    //   String? userId = FirebaseAuth.instance.currentUser?.uid;
    //   if (userId != null && booking['doctorId'] != null && booking['clinicName'] != null) {
    //     QuerySnapshot previousFeedback = await FirebaseFirestore.instance
    //         .collection('doctor_reviews')
    //         .where('userId', isEqualTo: userId)
    //         .where('doctorId', isEqualTo: booking['doctorId'])
    //         .where('clinicName', isEqualTo: booking['clinicName'])
    //         .limit(1)
    //         .get();
    //
    //     hasPreviousFeedback = previousFeedback.docs.isNotEmpty;
    //     if (hasPreviousFeedback) {
    //       previousFeedbackId = previousFeedback.docs.first.id;
    //       var prevData = previousFeedback.docs.first.data() as Map<String, dynamic>;
    //       doctorRating = (prevData['doctorRating'] as num?)?.toDouble() ?? 5.0;
    //       clinicRating = (prevData['clinicRating'] as num?)?.toDouble() ?? 5.0;
    //       staffRating = (prevData['staffRating'] as num?)?.toDouble() ?? 5.0;
    //       feedbackController.text = prevData['feedback']?.toString() ?? '';
    //     }
    //   }
    // } catch (e) {
    //   print('Error loading previous feedback: $e');
    // }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text('Rate Your Experience', style: TextStyle(fontWeight: FontWeight.bold)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (hasPreviousFeedback)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        'You submitted feedback for ${booking['clinicName'] ?? 'this clinic'} previously. You can update it below.',
                        style: TextStyle(color: Colors.blue, fontStyle: FontStyle.italic),
                      ),
                    ),

                  Text(
                    'How was your experience with Dr. ${booking['doctorName'] ?? 'the doctor'} at ${booking['clinicName'] ?? 'the clinic'}?',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 20),

                  // Doctor Rating
                  Text('Doctor Checkup:', style: TextStyle(fontWeight: FontWeight.w500)),
                  SizedBox(height: 8),
                  StarRating(
                    rating: doctorRating,
                    onRatingChanged: (rating) => setState(() => doctorRating = rating),
                  ),
                  Center(
                    child: Text(
                      '${doctorRating.toStringAsFixed(1)} / 5',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ),
                  SizedBox(height: 16),

                  // Clinic Rating
                  Text('Clinic Environment:', style: TextStyle(fontWeight: FontWeight.w500)),
                  SizedBox(height: 8),
                  StarRating(
                    rating: clinicRating,
                    onRatingChanged: (rating) => setState(() => clinicRating = rating),
                  ),
                  Center(
                    child: Text(
                      '${clinicRating.toStringAsFixed(1)} / 5',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ),
                  SizedBox(height: 16),

                  // Staff Rating
                  Text('Staff Behaviour:', style: TextStyle(fontWeight: FontWeight.w500)),
                  SizedBox(height: 8),
                  StarRating(
                    rating: staffRating,
                    onRatingChanged: (rating) => setState(() => staffRating = rating),
                  ),
                  Center(
                    child: Text(
                      '${staffRating.toStringAsFixed(1)} / 5',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ),
                  SizedBox(height: 20),

                  // Overall Rating
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Overall Rating:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber, size: 24),
                          SizedBox(width: 4),
                          Text(
                            ((doctorRating + clinicRating + staffRating) / 3).toStringAsFixed(1),
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Text('/5', style: TextStyle(fontSize: 14, color: Colors.grey)),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 20),

                  // Feedback Text
                  Text('Your Feedback (optional):', style: TextStyle(fontWeight: FontWeight.w500)),
                  SizedBox(height: 8),
                  TextField(
                    controller: feedbackController,
                    decoration: InputDecoration(
                      hintText: 'Share your experience...',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.all(12),
                    ),
                    maxLines: 3,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel', style: TextStyle(color: Colors.grey[700])),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (booking['doctorId'] == null || booking['clinicName'] == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: Doctor or clinic information missing')),
                    );
                    return;
                  }

                  // Show loading indicator
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => Center(child: CircularProgressIndicator()),
                  );

                  try {
                    Map<String, dynamic> feedbackData = {
                      'doctorId': booking['doctorId'],
                      'doctorName': booking['doctorName'],
                      'clinicName': booking['clinicName'],
                      'patientName': parentName ?? 'Anonymous',  // Use parent name here
                      'appointmentDate': booking['date'],
                      'doctorRating': doctorRating,
                      'clinicRating': clinicRating,
                      'staffRating': staffRating,
                      'overallRating': (doctorRating + clinicRating + staffRating) / 3,
                      'feedback': feedbackController.text,
                      'createdAt': FieldValue.serverTimestamp(),
                      'userId': FirebaseAuth.instance.currentUser?.uid,
                    };

                    // Update existing feedback or create new
                    // if (hasPreviousFeedback && previousFeedbackId != null) {
                    //   await FirebaseFirestore.instance
                    //       .collection('doctor_reviews')
                    //       .doc(previousFeedbackId)
                    //       .update(feedbackData);
                    // } else {
                    await FirebaseFirestore.instance
                        .collection('doctor_reviews')
                        .add(feedbackData);
                    //}

                    // Close both dialogs
                    Navigator.pop(context); // loading dialog
                    Navigator.pop(context); // feedback dialog

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(hasPreviousFeedback
                          ? 'Feedback updated successfully!'
                          : 'Thank you for your feedback!')),
                    );
                  } catch (e) {
                    Navigator.pop(context); // loading dialog
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to submit feedback. Please try again.')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(hasPreviousFeedback ? 'Update Feedback' : 'Submit Feedback'),
              ),
            ],
          );
        },
      ),
    );
  }
  String formatDate(Timestamp? timestamp) {
    if (timestamp == null) return 'N/A';
    final date = timestamp.toDate();
    return DateFormat.yMMMMd().format(date);
  }

  String formatDateTime(Timestamp? timestamp) {
    if (timestamp == null) return 'N/A';
    final date = timestamp.toDate();
    return DateFormat('yMMMd – hh:mm a').format(date);
  }
}

class StarRating extends StatelessWidget {
  final double rating;
  final Function(double) onRatingChanged;

  const StarRating({
    required this.rating,
    required this.onRatingChanged,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return GestureDetector(
          onTap: () => onRatingChanged(index + 1.0),
          child: Icon(
            index < rating ? Icons.star : Icons.star_border,
            color: Colors.amber,
            size: 40,
          ),
        );
      }),
    );
  }
}