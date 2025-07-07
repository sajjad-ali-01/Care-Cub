import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:open_filex/open_filex.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReportPage extends StatefulWidget {
  final String childName;
  final String childAge;
  final String parentName;
  final String bookingId;

  ReportPage({
    required this.childName,
    required this.childAge,
    required this.parentName,
    required this.bookingId,
  });

  @override
  _ReportPageState createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  final TextEditingController activityController = TextEditingController();
  List<Map<String, dynamic>> activities = [];
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  late String daycareId;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    daycareId = user!.uid;
  }

  void _addActivity() {
    if (activityController.text.isNotEmpty) {
      setState(() {
        activities.add({"name": activityController.text, "percentage": 50.0});
        activityController.clear();
      });
    }
  }

  void removeActivity(int index) {
    setState(() {
      activities.removeAt(index);
    });
  }

  double calculateAveragePercentage() {
    if (activities.isEmpty) return 0.0;
    double total = activities.fold(0.0, (sum, activity) => sum + activity["percentage"]);
    return total / activities.length;
  }

  Future<void> saveReportToFirestore() async {
    try {
      final reportData = {
        'childName': widget.childName,
        'childAge': widget.childAge,
        'parentName': widget.parentName,
        'activities': activities,
        'averagePercentage': calculateAveragePercentage(),
        'createdAt': FieldValue.serverTimestamp(),
        'daycareId': daycareId,
      };

      // First save the report
      await firestore
          .collection('DaycareBookings')
          .doc(widget.bookingId)
          .collection('reports')
          .add(reportData);

      // Then update the booking status
      await firestore
          .collection('DaycareBookings')
          .doc(widget.bookingId)
          .update({
        'hasReport': true,
        'lastReportDate': FieldValue.serverTimestamp(),
        'status': 'completed', // Add this line to mark as completed
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Report saved successfully and booking marked as completed!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to save report: ${e.toString()}")),
      );
    }
  }

  Future<void> generatePDF() async {
    if (activities.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please add at least one activity before generating a report")),
      );
      return;
    }

    // Create PDF (if you still want to generate it locally)
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Child Report', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 20),
              pw.Text('Child: ${widget.childName}', style: pw.TextStyle(fontSize: 18)),
              pw.Text('Age: ${widget.childAge}', style: pw.TextStyle(fontSize: 16)),
              pw.Text('Parent: ${widget.parentName}', style: pw.TextStyle(fontSize: 16)),
              pw.SizedBox(height: 20),
              pw.Text('Activities:', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              ...activities.map((activity) => pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('${activity["name"]}: ${activity["percentage"].toStringAsFixed(1)}%'),
                  pw.SizedBox(height: 5),
                ],
              )).toList(),
              pw.SizedBox(height: 20),
              pw.Text('Average Performance: ${calculateAveragePercentage().toStringAsFixed(1)}%',
                  style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              pw.Text(calculateAveragePercentage() > 70
                  ? 'Great Job! Keep up the good work!'
                  : 'Needs Improvement! Keep encouraging your child!'),
            ],
          );
        },
      ),
    );

    // Save PDF locally (optional)
    final directory = await getApplicationDocumentsDirectory();
    final filePath = "${directory.path}/Daycare_Report_${widget.childName}.pdf";
    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());

    // Save the data to Firestore and update booking status
    await saveReportToFirestore();

    // Open the PDF locally (optional)
    _openPDF(filePath);
  }

  void _openPDF(String filePath) {
    OpenFilex.open(filePath);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Child Report", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepOrange.shade400,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Child: ${widget.childName}", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text("Age: ${widget.childAge}", style: TextStyle(fontSize: 16)),
            Text("Parent: ${widget.parentName}", style: TextStyle(fontSize: 16)),
            SizedBox(height: 20),

            Text("Activities Participated:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            TextField(
              controller: activityController,
              decoration: InputDecoration(
                labelText: "Enter Activity",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _addActivity,
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              child: Text("Add Activity", style: TextStyle(color: Colors.white)),
            ),
            SizedBox(height: 20),

            Container(
              height: MediaQuery.of(context).size.height * 0.4,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: activities.isEmpty
                  ? Center(child: Text("No activities added yet"))
                  : ListView.builder(
                itemCount: activities.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    child: ListTile(
                      title: Text(activities[index]["name"]),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Performance: ${activities[index]["percentage"].toInt()}%"),
                          Slider(
                            value: activities[index]["percentage"],
                            min: 0,
                            max: 100,
                            divisions: 20,
                            label: "${activities[index]["percentage"].toInt()}%",
                            onChanged: (value) {
                              setState(() {
                                activities[index]["percentage"] = value;
                              });
                            },
                          ),
                        ],
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => removeActivity(index),
                      ),
                    ),
                  );
                },
              ),
            ),

            SizedBox(height: 20),
            Text(
              "Average Performance Score: ${calculateAveragePercentage().toInt()}%",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),

            Text(
              calculateAveragePercentage() > 70 ? "Great Job! Keep up the good work!" : "Needs Improvement! Keep encouraging your child!",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue),
            ),
            SizedBox(height: 10),

            Text("We appreciate your support! Please visit again for progress updates."),

            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: generatePDF,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text("Generate Report", style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}