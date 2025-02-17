import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:open_filex/open_filex.dart';
class ReportPage extends StatefulWidget {
  final String childName;
  final String childAge;
  final String parentName;

  ReportPage({required this.childName, required this.childAge, required this.parentName});

  @override
  _ReportPageState createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  final TextEditingController activityController = TextEditingController();
  List<Map<String, dynamic>> activities = [];

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

  Future<void> generatePDF() async {
    if (activities.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please add at least one activity before generating a report")),
      );
      return;
    }

    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text("Child Report", style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              pw.Text("Child: ${widget.childName}", style: pw.TextStyle(fontSize: 18)),
              pw.Text("Age: ${widget.childAge}", style: pw.TextStyle(fontSize: 18)),
              pw.Text("Parent: ${widget.parentName}", style: pw.TextStyle(fontSize: 18)),
              pw.SizedBox(height: 20),

              pw.Text("Activities Participated:", style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),

              pw.Table.fromTextArray(
                headers: ["Activity Name", "Performance (%)"],
                data: activities.map((activity) => [activity["name"], "${activity["percentage"].toInt()}%"]).toList(),
              ),

              pw.SizedBox(height: 20),

              pw.Text("Average Performance Score: ${calculateAveragePercentage().toInt()}%",
                  style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),

              pw.SizedBox(height: 10),
              pw.Text(
                calculateAveragePercentage() > 70 ? "Great Job! Keep up the good work!" : "Needs Improvement! Keep encouraging your child!",
                style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.blue),
              ),
              pw.SizedBox(height: 10),
              pw.Text("We appreciate your support! Please visit again for progress updates."),
            ],
          );
        },
      ),
    );

    final directory = await getApplicationDocumentsDirectory();
    final filePath = "${directory.path}/Child_Report_${widget.childName}.pdf";
    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("PDF Report Saved: $filePath")),
    );

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
            SizedBox(height:2),

            Text("Activities Participated:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            TextField(
              controller: activityController,
              decoration: InputDecoration(labelText: "Enter Activity"),
            ),
            ElevatedButton(
              onPressed: _addActivity,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                padding: EdgeInsets.symmetric(
                    vertical: 10, horizontal: 35),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
              ),
              child: Text("Add Activity",style: TextStyle(color: Colors.white),),
            ),
            SizedBox(height: 3),


            Container(
              height: MediaQuery.of(context).size.height * 0.4,
              child: ListView.builder(
                itemCount: activities.length,
                itemBuilder: (context, index) {
                  return ListTile(
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
                  );
                },
              ),
            ),

            Text(
              "Average Performance Score: ${calculateAveragePercentage().toInt()}%",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 3),

            Text(
              calculateAveragePercentage() > 70 ? "Great Job! Keep up the good work!" : "Needs Improvement! Keep encouraging your child! ",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue),
            ),
            SizedBox(height: 5),
            Text("We appreciate your support! Please visit again for progress updates."),

            SizedBox(height: 0),
            Center(
              child: ElevatedButton(
                onPressed: generatePDF,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  padding: EdgeInsets.symmetric(
                      vertical: 10, horizontal: 40),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                ),
                child: Text("Submit Report",style: TextStyle(color: Colors.white),),
              ),
            ),
          ],
        ),
      ),
    );
  }
}