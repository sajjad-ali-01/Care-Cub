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
  final List<Vaccine> vaccines = [];
  final vaccineController = TextEditingController();
  DateTime? selectedDate;

  void _addVaccine() {
    if (vaccineController.text.isEmpty || selectedDate == null) return;

    setState(() {
      vaccines.add(Vaccine(
        name: vaccineController.text,
        date: selectedDate!,
      ));
    });

    vaccineController.clear();
    selectedDate = null;

    Navigator.of(context).pop();
  }

  void showAddVaccineDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Add New Vaccine"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: vaccineController,
              decoration: InputDecoration(labelText: "Vaccine Name"),
            ),
            SizedBox(height: 10),
            TextButton(
              onPressed: pickDate,
              child: Text(
                selectedDate == null
                    ? "Select Date"
                    : "Selected Date: ${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
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

  void pickDate() async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now.subtract(Duration(days: 365)),
      lastDate: now.add(Duration(days: 365 * 5)),
    );

    if (pickedDate != null) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  void showVaccineDetails(Vaccine vaccine) {
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
        title: Text("Vaccination Tracker",style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.deepOrange.shade400,
      ),
      body: vaccines.isEmpty
          ? Center(
        child: Text(
          "No vaccinations added yet.\nTap + to add a new vaccine.",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      )
          : ListView.builder(
        itemCount: vaccines.length,
        itemBuilder: (ctx, index) {
          final vaccine = vaccines[index];
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
            onTap: () => showVaccineDetails(vaccine),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: showAddVaccineDialog,
        backgroundColor: Colors.deepOrange.shade400,
        child: Icon(Icons.add,color: Colors.white,),
      ),
    );
  }
}

class Vaccine {
  final String name;
  final DateTime date;

  Vaccine({required this.name, required this.date});
}

