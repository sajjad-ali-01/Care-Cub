import 'package:flutter/material.dart';

class AwardPage extends StatefulWidget {
  @override
  _AwardPageState createState() => _AwardPageState();
}

class _AwardPageState extends State<AwardPage> {
  final _formKey = GlobalKey<FormState>();
  String awardName = '';
  String year = '';

  void _saveAward() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      Navigator.pop(context, "$awardName ($year)"); // Return award to previous screen
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add Award"), backgroundColor: Colors.deepOrange),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: "Award Name", border: OutlineInputBorder()),
                validator: (value) => value!.isEmpty ? "Enter Award Name" : null,
                onSaved: (value) => awardName = value!,
              ),
              SizedBox(height: 10),
              TextFormField(
                decoration: InputDecoration(labelText: "Year", border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? "Enter Year" : null,
                onSaved: (value) => year = value!,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveAward,
                child: Text("Save Award"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
