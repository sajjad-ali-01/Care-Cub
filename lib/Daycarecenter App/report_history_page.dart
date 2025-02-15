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
    _loadReportHistory();
  }

  /// ✅ **Load Saved Reports**
  Future<void> _loadReportHistory() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> savedReports = prefs.getStringList("report_history") ?? [];

    setState(() {
      reportList = savedReports
          .map((report) => Map<String, String>.from(jsonDecode(report)))
          .toList();
      filteredList = List.from(reportList);
    });
  }

  /// ✅ **Search Reports**
  void _searchReports(String query) {
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

  /// ✅ **Delete Report**
  Future<void> _deleteReport(int index) async {
    final prefs = await SharedPreferences.getInstance();
    reportList.removeAt(index);
    filteredList = List.from(reportList);
    List<String> updatedList = reportList.map((report) => jsonEncode(report)).toList();
    await prefs.setStringList("report_history", updatedList);
    setState(() {});
  }

  /// ✅ **Open PDF with Error Handling**
  void _openPDF(String filePath) async {
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
            /// ✅ **Search Bar**
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: "Search Reports",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onChanged: _searchReports,
            ),
            SizedBox(height: 10),

            /// ✅ **List of Reports**
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
                        onPressed: () => _deleteReport(index),
                      ),
                      onTap: () => _openPDF(filteredList[index]["path"]!),
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
