import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:open_filex/open_filex.dart';

class ReportHistoryPage extends StatefulWidget {
  @override
  _ReportHistoryPageState createState() => _ReportHistoryPageState();
}

class _ReportHistoryPageState extends State<ReportHistoryPage> {
  List<Map<String, String>> reportList = [];
  List<Map<String, String>> filteredList = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadReportHistory();
  }
  Future<void> loadReportHistory() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> savedReports = prefs.getStringList("report_history") ?? [];

    setState(() {
      reportList = savedReports
          .map((report) => Map<String, String>.from(jsonDecode(report)))
          .toList();
      filteredList = List.from(reportList);
    });
  }

  void searchReports(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredList = List.from(reportList);
      } else {
        filteredList = reportList
            .where((report) => report["name"]!.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  Future<void> deleteReport(int index) async {
    final prefs = await SharedPreferences.getInstance();
    reportList.removeAt(index);
    filteredList = List.from(reportList);
    List<String> updatedList = reportList.map((report) => jsonEncode(report)).toList();
    await prefs.setStringList("report_history", updatedList);
    setState(() {});
  }

  void openPDF(String filePath) async {
    if (File(filePath).existsSync()) {
      await OpenFilex.open(filePath);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("File not found! It may have been deleted.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Report History")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: "Search Reports",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onChanged: searchReports,
            ),
            SizedBox(height: 10),

            Expanded(
              child: reportList.isEmpty
                  ? Center(child: Text("No reports found"))
                  : ListView.builder(
                itemCount: filteredList.length,
                itemBuilder: (context, index) {
                  return Card(
                    elevation: 3,
                    child: ListTile(
                      title: Text(filteredList[index]["name"]!),
                      subtitle: Text("Tap to open PDF"),
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => deleteReport(index),
                      ),
                      onTap: () => openPDF(filteredList[index]["path"]!),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
