import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'dart:io';

class BookingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('My Bookings', style: TextStyle(color: Colors.white)),
        leading: IconButton(onPressed: (){Navigator.pop(context);}, icon: Icon(Icons.arrow_back,color: Colors.white,)),
        backgroundColor: Colors.deepOrange.shade600,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.history,color: Colors.white,),
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
            .collection('DaycareBookings')
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

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: currentBookings.length,
            itemBuilder: (context, index) {
              final booking = currentBookings[index].data() as Map<String, dynamic>;
              return BookingCard(
                booking: booking,
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
                          .collection('DaycareBookings')
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
pw.Widget _buildWatermark() {
  return pw.Stack(
    children: [
      pw.Opacity(
        opacity: 0.1,
        child: pw.Center(
          child: pw.Transform.rotate(
            angle: 0.5,
            child: pw.Text(
              'CareCub',
              style: pw.TextStyle(
                fontSize: 60,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.blue400,
              ),
            ),
          ),
        ),
      ),
      pw.Positioned(
        bottom: 20,
        right: 20,
        child: pw.Text(
          'Generated by CareCub',
          style: pw.TextStyle(
            fontSize: 10,
            color: PdfColors.grey600,
          ),
        ),
      ),
    ],
  );
}

class HistoryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('History', style: TextStyle(color: Colors.white)),
        leading: IconButton(onPressed: (){Navigator.pop(context);}, icon: Icon(Icons.arrow_back,color: Colors.white,)),
        backgroundColor: Colors.deepOrange.shade600,
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('DaycareBookings')
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

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: historyBookings.length,
            itemBuilder: (context, index) {
              final booking = historyBookings[index].data() as Map<String, dynamic>;
              final bookingId = historyBookings[index].id; // Get the document ID
              return HistoryCard(booking: booking, bookingId: bookingId); // Pass document ID
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
  late String bookingId;

  BookingCard({required this.booking, this.onCancel});

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
  Future<void> _downloadReport(BuildContext context) async {
    try {
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Generating report...')),
      );

      // Fetch the report data from Firestore using the correct booking ID
      final reportSnapshot = await FirebaseFirestore.instance
          .collection('DaycareBookings')
          .doc(bookingId) // Use the correct booking document ID
          .collection('reports')
          .orderBy('createdAt', descending: true)
          .limit(1)
          .get();

      if (reportSnapshot.docs.isEmpty) {
        throw Exception('No report found for this booking');
      }

      final reportData = reportSnapshot.docs.first.data();
// Generate PDF
      final pdf = pw.Document();
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Header(
                  level: 0,
                  child: pw.Text('Daycare Report',
                      style: pw.TextStyle(
                          fontSize: 24, fontWeight: pw.FontWeight.bold)),
                ),
                pw.SizedBox(height: 20),
                pw.Text('Child: ${reportData['childName'] ?? 'N/A'}'),
                pw.Text('Age: ${reportData['childAge'] ?? 'N/A'}'),
                pw.Text('Parent: ${reportData['parentName'] ?? 'N/A'}'),
                pw.SizedBox(height: 20),
                pw.Text('Activities:',
                    style: pw.TextStyle(
                        fontSize: 18, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 10),
                pw.Table.fromTextArray(
                  headers: ['Activity', 'Performance'],
                  data: (reportData['activities'] as List<dynamic>?)
                      ?.map((activity) => [
                    activity['name'],
                    '${activity['percentage']?.toStringAsFixed(1)}%'
                  ])
                      .toList() ??
                      [],
                ),
                pw.SizedBox(height: 20),
                pw.Text(
                    'Average Performance: ${reportData['averagePercentage']?.toStringAsFixed(1) ?? '0'}%',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 10),
                pw.Text('Report Date: ${DateFormat('MMMM dd, yyyy').format((reportData['createdAt'] as Timestamp).toDate())}'),
              ],
            );
          },
        ),
      );

      // Save PDF to device
      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'Daycare_Report_${reportData['childName'] ?? 'report'}.pdf';
      final filePath = '${directory.path}/$fileName';
      final file = File(filePath);
      await file.writeAsBytes(await pdf.save());

      // Open the PDF
      OpenFilex.open(filePath);

      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Report downloaded successfully!')),
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
      print('Error generating report: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDeclined = booking['status']?.toString().toLowerCase() == 'declined';
    final isDaycare = booking['daycareId'] != null;

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
            // Header with daycare/doctor name and status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    isDaycare
                        ? booking['daycareName'] ?? 'Daycare Center'
                        : booking['doctorName'] ?? 'Doctor Name',
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

            // Daycare/Clinic information
            if (isDaycare) ...[
              Row(
                children: [
                  Icon(Icons.verified, color: Colors.blue),
                  SizedBox(width: 10),
                  Text(
                    booking['daycareType'] ?? 'Daycare',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.location_on, color: Colors.red),
                  SizedBox(width: 10),
                  Text(
                    booking['daycareLocation'] ?? 'Location not specified',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Text(
                booking['daycarePrice'] ?? '',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade700,
                ),
              ),
            ] else ...[
              Row(
                children: [
                  Icon(Icons.medical_services, color: Colors.green),
                  SizedBox(width: 10),
                  Text(
                    booking['clinicName'] ?? 'Clinic Name',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.location_on, color: Colors.red),
                  SizedBox(width: 10),
                  Text(
                    booking['clinicAddress'] ?? 'Clinic Address',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ],
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
                    isDaycare
                        ? "Daycare says: ``${booking['declineReason']}``"
                        : "Dr. says: ``${booking['declineReason']}``",
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

            // Child information
            Row(
              children: [
                Icon(Icons.person, size: 18, color: Colors.deepOrange),
                SizedBox(width: 8),
                Text(
                  'Child: ${booking['childName'] ?? 'N/A'}',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                SizedBox(width: 16),
                Icon(Icons.family_restroom_sharp, size: 18, color: Colors.deepOrange),
                SizedBox(width: 8),
                Text(
                  booking['childGender'] ?? booking['gender'] ?? 'N/A',
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
                  'Contact: ${booking['parentContact'] ?? booking['contactNumber'] ?? 'N/A'}',
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
            SizedBox(height: 12),

            // Special notes (if available)
            if (booking['specialNotes']?.isNotEmpty == true) ...[
              Text(
                'Special Notes: ${booking['specialNotes']}',
                style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
              ),
              SizedBox(height: 12),
            ],

            // Divider
            Divider(color: Colors.grey.shade300),
            SizedBox(height: 12),

            // Booking details
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isDaycare ? 'Start Date' : 'Appointment Date',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        isDaycare
                            ? booking['startDate'] ?? 'N/A'
                            : formatDate(booking['date']),
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
                        isDaycare ? 'Preferred Time' : 'Appointment Time',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        isDaycare
                            ? booking['preferredTime'] ?? 'N/A'
                            : booking['time'] ?? 'N/A',
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

            // Created at and declined/cancelled at
            Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isDeclined && booking['declinedAt'] != null)
                    Text(
                      'Declined on ${formatDateTime(booking['declinedAt'])}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.red,
                        fontStyle: FontStyle.italic,
                      ),
                    )
                ]
            ),

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
                'Booked on ${formatDateTime(booking['bookingDate'] ?? booking['createdAt'])}',
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
  Future<void> _downloadReport(BuildContext context) async {
    try {
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Generating report...')),
      );

      // Fetch the report data from Firestore
      final reportSnapshot = await FirebaseFirestore.instance
          .collection('DaycareBookings')
          .doc(bookingId)
          .collection('reports')
          .orderBy('createdAt', descending: true)
          .limit(1)
          .get();

      if (reportSnapshot.docs.isEmpty) {
        throw Exception('No report found for this booking');
      }

      final reportData = reportSnapshot.docs.first.data();
      final activities = reportData['activities'] as List<dynamic>;
      final averagePercentage = reportData['averagePercentage'] as double;
      final childName = reportData['childName'] as String;
      //final childAge = reportData['childAge'] as String;
      final parentName = reportData['parentName'] as String;
      final createdAt = reportData['createdAt'] as Timestamp;

      // Generate PDF
      final pdf = pw.Document();
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Stack(
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Header(
                      level: 0,
                      child: pw.Text('Daycare Report',
                          style: pw.TextStyle(
                              fontSize: 24, fontWeight: pw.FontWeight.bold)),
                    ),
                    pw.SizedBox(height: 20),
                    pw.Text('Child: $childName'),
                  //  pw.Text('Age: $childAge'),
                    pw.Text('Parent: $parentName'),
                    pw.SizedBox(height: 20),
                    pw.Text('Activities:',
                        style: pw.TextStyle(
                            fontSize: 18, fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 10),
                    pw.Table.fromTextArray(
                      headers: ['Activity', 'Performance'],
                      data: activities.map((activity) => [
                        activity['name'] ?? 'N/A',
                        '${(activity['percentage'] as num).toStringAsFixed(1)}%'
                      ]).toList(),
                    ),
                    pw.SizedBox(height: 20),
                    pw.Text(
                        'Average Performance: ${averagePercentage.toStringAsFixed(1)}%',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 10),
                    pw.Text('Report Date: ${DateFormat('MMMM dd, yyyy').format(createdAt.toDate())}'),
                  ],
                ),
                _buildWatermark(),
              ],
            );
          },
        ),
      );

      // Save PDF to device
      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'Daycare_Report_$childName.pdf';
      final filePath = '${directory.path}/$fileName';
      final file = File(filePath);
      await file.writeAsBytes(await pdf.save());

      // Open the PDF
      OpenFilex.open(filePath);

      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Report downloaded successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
      print('Error generating report: $e');
    }
  }
  @override
  Widget build(BuildContext context) {
    final isDeclined = booking['status']?.toString().toLowerCase() == 'declined';
    final isDaycare = booking['daycareId'] != null;
    final isCompleted = booking['status']?.toString().toLowerCase() == 'completed';

    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Daycare/Doctor Name and Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isDaycare
                      ? booking['daycareName'] ?? 'Daycare Center'
                      : booking['doctorName'] ?? 'Doctor Name',
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

            // Daycare/Clinic info
            Row(
              children: [
                Icon(
                  isDaycare ? Icons.verified : Icons.medical_services,
                  color: isDaycare ? Colors.blue : Colors.green,
                ),
                SizedBox(width: 8),
                Text(
                  isDaycare
                      ? booking['daycareType'] ?? 'Daycare'
                      : booking['clinicName'] ?? 'Clinic Name',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
            SizedBox(height: 4),

            // Address
            Row(
              children: [
                Icon(Icons.location_on, color: Colors.red),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isDaycare
                        ? booking['daycareLocation'] ?? 'Location not specified'
                        : booking['clinicAddress'] ?? 'Clinic Address',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),

            // Price (for daycare)
            if (isDaycare && booking['daycarePrice'] != null) ...[
              Text(
                'Price: ${booking['daycarePrice']}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade700,
                ),
              ),
              SizedBox(height: 12),
            ],

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
                    isDaycare
                        ? "Daycare says: ``${booking['declineReason']}``"
                        : "Dr. says: ``${booking['declineReason']}``",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  SizedBox(height: 12),
                ],
              ),

            // Child info
            Row(
              children: [
                Icon(Icons.person, size: 18, color: Colors.deepOrange),
                SizedBox(width: 8),
                Text(
                  'Child: ${booking['childName'] ?? 'N/A'}',
                  style: TextStyle(fontSize: 14),
                ),
                SizedBox(width: 16),
                Icon(Icons.family_restroom_sharp, size: 18, color: Colors.deepOrange),
                SizedBox(width: 8),
                Text(
                  booking['childGender'] ?? booking['gender'] ?? 'N/A',
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
                  'Contact: ${booking['parentContact'] ?? booking['contactNumber'] ?? 'N/A'}',
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
            SizedBox(height: 12),

            // Special notes (if available)
            if (booking['specialNotes']?.isNotEmpty == true) ...[
              Text(
                'Special Notes: ${booking['specialNotes']}',
                style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
              ),
              SizedBox(height: 12),
            ],

            // Booking date/time
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isDaycare ? 'Date: ${booking['startDate'] ?? 'N/A'}'
                      : 'Date: ${formatDate(booking['date'])}',
                  style: TextStyle(fontSize: 14),
                ),
                Text(
                  isDaycare ? 'Time: ${booking['preferredTime'] ?? 'N/A'}'
                      : 'Time: ${booking['time'] ?? 'N/A'}',
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
            SizedBox(height: 12),

            // Dates
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                if (isCompleted)
                  SizedBox(
                    width: 140,
                    child: ElevatedButton(
                      onPressed: () {
                        _showDaycareFeedbackDialog(context);
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
                SizedBox(width: 10,),
                if (isCompleted)
                  Padding(
                    padding: EdgeInsets.only(top: 0),
                    child: SizedBox(
                      width: 140,
                      child: ElevatedButton(
                        onPressed: () => _downloadReport(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepOrange,
                         // padding: EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Download Report',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),

              ],
            ),
            SizedBox(height: 8),

            // Dates
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Booked on ${formatDateTime(booking['bookingDate'] ?? booking['createdAt'])}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                if (isCompleted && booking['completedAt'] != null)
                  Text(
                    'Completed on ${formatDateTime(booking['completedAt'])}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green,
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
  void _showDaycareFeedbackDialog(BuildContext context) async {
    double daycareRating = 5.0;
    double staffRating = 5.0;
    double facilitiesRating = 5.0;
    TextEditingController feedbackController = TextEditingController();
    bool hasPreviousFeedback = false;
    String? previousFeedbackId;

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
                        'You submitted feedback for ${booking['daycareName'] ?? 'this daycare'} previously. You can update it below.',
                        style: TextStyle(color: Colors.blue, fontStyle: FontStyle.italic),
                      ),
                    ),

                  Text(
                    'How was your experience with ${booking['daycareName'] ?? 'the daycare'}?',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 20),

                  // Daycare Rating
                  Text('Daycare Quality:', style: TextStyle(fontWeight: FontWeight.w500)),
                  SizedBox(height: 8),
                  StarRating(
                    rating: daycareRating,
                    onRatingChanged: (rating) => setState(() => daycareRating = rating),
                  ),
                  Center(
                    child: Text(
                      '${daycareRating.toStringAsFixed(1)} / 5',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ),
                  SizedBox(height: 16),

                  // Staff Rating
                  Text('Staff Friendliness:', style: TextStyle(fontWeight: FontWeight.w500)),
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
                  SizedBox(height: 16),

                  // Facilities Rating
                  Text('Facilities Cleanliness:', style: TextStyle(fontWeight: FontWeight.w500)),
                  SizedBox(height: 8),
                  StarRating(
                    rating: facilitiesRating,
                    onRatingChanged: (rating) => setState(() => facilitiesRating = rating),
                  ),
                  Center(
                    child: Text(
                      '${facilitiesRating.toStringAsFixed(1)} / 5',
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
                            ((daycareRating + staffRating + facilitiesRating) / 3).toStringAsFixed(1),
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
                  if (booking['daycareId'] == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: Daycare information missing')),
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
                      'daycareId': booking['daycareId'],
                      'daycareName': booking['daycareName'],
                      'parentName': booking['userName'],
                      'childName': booking['childName'],
                      'bookingDate': booking['startDate'],
                      'daycareRating': daycareRating,
                      'staffRating': staffRating,
                      'facilitiesRating': facilitiesRating,
                      'overallRating': (daycareRating + staffRating + facilitiesRating) / 3,
                      'feedback': feedbackController.text,
                      'createdAt': FieldValue.serverTimestamp(),
                      'userId': FirebaseAuth.instance.currentUser?.uid,
                    };

                    await FirebaseFirestore.instance
                        .collection('DaycareReviews')
                        .add(feedbackData);

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