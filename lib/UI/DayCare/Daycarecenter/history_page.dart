import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DaycareHistoryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('Daycare History', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepOrange.shade400,
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('DaycareBookings')
            .where('daycareId', isEqualTo: user?.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error loading history'));
          }

          final bookings = snapshot.data?.docs ?? [];

          // Filter bookings - show only past or completed/cancelled/declined bookings
          final historyBookings = bookings.where((doc) {
            final booking = doc.data() as Map<String, dynamic>;
            final status = booking['status']?.toString().toLowerCase();

            return status == 'completed' ||
                status == 'cancelled' ||
                status == 'declined';
          }).toList();

          if (historyBookings.isEmpty) {
            return Center(
              child: Text(
                'No historical daycare bookings found',
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: historyBookings.length,
            itemBuilder: (context, index) {
              final booking = historyBookings[index].data() as Map<String, dynamic>;
              return DaycareHistoryCard(booking: booking);
            },
          );
        },
      ),
    );
  }
}

class DaycareHistoryCard extends StatelessWidget {
  final Map<String, dynamic> booking;

  DaycareHistoryCard({required this.booking});

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
  // Future<void> _downloadReport(BuildContext context) async {
  //   try {
  //     final scaffoldMessenger = ScaffoldMessenger.of(context);
  //     scaffoldMessenger.showSnackBar(
  //       SnackBar(content: Text('Generating report...')),
  //     );
  //
  //     // Fetch the report data from Firestore
  //     final reportSnapshot = await FirebaseFirestore.instance
  //         .collection('DaycareBookings')
  //         .doc(booking as String?)
  //         .collection('reports')
  //         .orderBy('createdAt', descending: true)
  //         .limit(1)
  //         .get();
  //
  //     if (reportSnapshot.docs.isEmpty) {
  //       throw Exception('No report found for this booking');
  //     }
  //
  //     final reportData = reportSnapshot.docs.first.data();
  //
  //     // Generate PDF
  //     final pdf = pw.Document();
  //     pdf.addPage(
  //       pw.Page(
  //         pageFormat: PdfPageFormat.a4,
  //         build: (pw.Context context) {
  //           return pw.Column(
  //             crossAxisAlignment: pw.CrossAxisAlignment.start,
  //             children: [
  //               pw.Header(
  //                 level: 0,
  //                 child: pw.Text('Daycare Report',
  //                     style: pw.TextStyle(
  //                         fontSize: 24, fontWeight: pw.FontWeight.bold)),
  //               ),
  //               pw.SizedBox(height: 20),
  //               pw.Text('Child: ${reportData['childName'] ?? 'N/A'}'),
  //               pw.Text('Age: ${reportData['childAge'] ?? 'N/A'}'),
  //               pw.Text('Parent: ${reportData['parentName'] ?? 'N/A'}'),
  //               pw.SizedBox(height: 20),
  //               pw.Text('Activities:',
  //                   style: pw.TextStyle(
  //                       fontSize: 18, fontWeight: pw.FontWeight.bold)),
  //               pw.SizedBox(height: 10),
  //               pw.Table.fromTextArray(
  //                 headers: ['Activity', 'Performance'],
  //                 data: (reportData['activities'] as List<dynamic>?)
  //                     ?.map((activity) => [
  //                   activity['name'],
  //                   '${activity['percentage']?.toStringAsFixed(1)}%'
  //                 ])
  //                     .toList() ??
  //                     [],
  //               ),
  //               pw.SizedBox(height: 20),
  //               pw.Text(
  //                   'Average Performance: ${reportData['averagePercentage']?.toStringAsFixed(1) ?? '0'}%',
  //                   style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
  //               pw.SizedBox(height: 10),
  //               pw.Text('Report Date: ${DateFormat('MMMM dd, yyyy').format((reportData['createdAt'] as Timestamp).toDate())}'),
  //             ],
  //           );
  //         },
  //       ),
  //     );
  //
  //     // Save PDF to device
  //     final directory = await getApplicationDocumentsDirectory();
  //     final fileName = 'Daycare_Report_${reportData['childName'] ?? 'report'}.pdf';
  //     final filePath = '${directory.path}/$fileName';
  //     final file = File(filePath);
  //     await file.writeAsBytes(await pdf.save());
  //
  //     // Open the PDF
  //     OpenFilex.open(filePath);
  //
  //     scaffoldMessenger.showSnackBar(
  //       SnackBar(content: Text('Report downloaded successfully!')),
  //     );
  //   } catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Error: ${e.toString()}')),
  //     );
  //   }
  // }


  @override
  Widget build(BuildContext context) {
    final isDeclined = booking['status']?.toString().toLowerCase() == 'declined';

    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Daycare Name and Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  booking['daycareName'] ?? 'Daycare Name',
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

            // Daycare Location
            Row(
              children: [
                Icon(Icons.location_on, color: Colors.red),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    booking['daycareLocation'] ?? 'Daycare Location',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
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
                    booking['declineReason'],
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  SizedBox(height: 12),
                ],
              ),

            // Booking date/time
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Start Date: ${booking['startDate'] ?? 'N/A'}',
                  style: TextStyle(fontSize: 14),
                ),
                Text(
                  'Time: ${booking['preferredTime'] ?? 'N/A'}',
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
            SizedBox(height: 8),

            // Child info
            Row(
              children: [
                Icon(Icons.child_care, size: 18, color: Colors.deepOrange),
                SizedBox(width: 8),
                Text(
                  'Child: ${booking['childName'] ?? 'N/A'}',
                  style: TextStyle(fontSize: 14),
                ),
                SizedBox(width: 16),
                Icon(Icons.family_restroom_sharp, size: 18, color: Colors.deepOrange),
                SizedBox(width: 8),
                Text(
                  booking['childGender'] ?? 'N/A',
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
            SizedBox(height: 8),

            // Parent contact
            Row(
              children: [
                Icon(Icons.phone, size: 18, color: Colors.deepOrange),
                SizedBox(width: 8),
                Text(
                  'Parent Contact: ${booking['parentContact'] ?? 'N/A'}',
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
            SizedBox(height: 12),

            // Special notes
            if (booking['specialNotes'] != null && booking['specialNotes'].isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Special Notes:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    booking['specialNotes'],
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  SizedBox(height: 12),
                ],
              ),

            // Timestamps
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Booked on ${formatDateTime(booking['bookingDate'])}',
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
                if (booking['completedAt'] != null)
                  Text(
                    'Completed on ${formatDateTime(booking['completedAt'])}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                // if (isCompleted)
                //   Padding(
                //     padding: EdgeInsets.only(top: 16),
                //     child: SizedBox(
                //       width: double.infinity,
                //       child: ElevatedButton(
                //         onPressed: () => _downloadReport(context),
                //         style: ElevatedButton.styleFrom(
                //           backgroundColor: Colors.deepOrange,
                //           padding: EdgeInsets.symmetric(vertical: 12),
                //           shape: RoundedRectangleBorder(
                //             borderRadius: BorderRadius.circular(8),
                //           ),
                //         ),
                //         child: Text(
                //           'Download Report',
                //           style: TextStyle(color: Colors.white),
                //         ),
                //       ),
                //     ),
                //   ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String formatDateTime(Timestamp? timestamp) {
    if (timestamp == null) return 'N/A';
    final date = timestamp.toDate();
    return DateFormat('MMM d, yyyy hh:mm a').format(date);
  }
}