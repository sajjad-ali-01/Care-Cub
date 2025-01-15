import 'package:flutter/material.dart';

class VaccinationTrackerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vaccination Tracker',
      debugShowCheckedModeBanner: false,
      home: VaccinationTrackerScreen(),
    );
  }
}

class VaccinationTrackerScreen extends StatefulWidget {
  @override
  _VaccinationTrackerScreenState createState() =>
      _VaccinationTrackerScreenState();
}

class _VaccinationTrackerScreenState extends State<VaccinationTrackerScreen> {
  final List<Vaccine> _vaccines = [];
  final _vaccineController = TextEditingController();
  DateTime? _selectedDate;

  void _addVaccine() {
    if (_vaccineController.text.isEmpty || _selectedDate == null) return;

    setState(() {
      _vaccines.add(Vaccine(
        name: _vaccineController.text,
        date: _selectedDate!,
      ));
    });

    _vaccineController.clear();
    _selectedDate = null;

    Navigator.of(context).pop();
  }

  void _showAddVaccineDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Add New Vaccine"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _vaccineController,
              decoration: InputDecoration(labelText: "Vaccine Name"),
            ),
            SizedBox(height: 10),
            TextButton(
              onPressed: _pickDate,
              child: Text(
                _selectedDate == null
                    ? "Select Date"
                    : "Selected Date: ${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}",
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: _addVaccine,
            child: Text("Add"),
          ),
        ],
      ),
    );
  }

  void _pickDate() async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now.subtract(Duration(days: 365)), // Past one year
      lastDate: now.add(Duration(days: 365 * 5)), // Next five years
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  void _showVaccineDetails(Vaccine vaccine) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(vaccine.name),
        content: Text(
          "Scheduled Date: ${vaccine.date.day}/${vaccine.date.month}/${vaccine.date.year}",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text("Close"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Vaccination Tracker"),
        backgroundColor: Colors.green,
      ),
      body: _vaccines.isEmpty
          ? Center(
        child: Text(
          "No vaccinations added yet.\nTap + to add a new vaccine.",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      )
          : ListView.builder(
        itemCount: _vaccines.length,
        itemBuilder: (ctx, index) {
          final vaccine = _vaccines[index];
          return ListTile(
            leading: Icon(
              Icons.vaccines,
              color: vaccine.date.isAfter(DateTime.now())
                  ? Colors.orange
                  : Colors.green,
            ),
            title: Text(vaccine.name),
            subtitle: Text(
              "Date: ${vaccine.date.day}/${vaccine.date.month}/${vaccine.date.year}",
            ),
            trailing: vaccine.date.isAfter(DateTime.now())
                ? Text(
              "Upcoming",
              style: TextStyle(color: Colors.orange),
            )
                : Text(
              "Completed",
              style: TextStyle(color: Colors.green),
            ),
            onTap: () => _showVaccineDetails(vaccine),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddVaccineDialog,
        backgroundColor: Colors.green,
        child: Icon(Icons.add),
      ),
    );
  }
}

class Vaccine {
  final String name;
  final DateTime date;

  Vaccine({required this.name, required this.date});
}

void main() => runApp(VaccinationTrackerApp());
