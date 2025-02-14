import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../Home.dart';

class AddClinicScreen extends StatefulWidget {
  @override
  _AddClinicScreenState createState() => _AddClinicScreenState();
}

class _AddClinicScreenState extends State<AddClinicScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _clinicNameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  TimeOfDay _openingTime = TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _closingTime = TimeOfDay(hour: 17, minute: 0);
  LatLng? _selectedLocation;

  Future<void> _selectTime(BuildContext context, bool isOpeningTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isOpeningTime ? _openingTime : _closingTime,
    );
    if (picked != null) {
      setState(() {
        if (isOpeningTime) {
          _openingTime = picked;
        } else {
          _closingTime = picked;
        }
      });
    }
  }

  Future<void> _selectLocation(BuildContext context) async {
    final LatLng? picked = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LocationPickerScreen(),
      ),
    );
    if (picked != null) {
      setState(() {
        _selectedLocation = picked;
        _locationController.text = "${picked.latitude}, ${picked.longitude}";
      });
    }
  }

  void _saveClinicInfo() async {
    if (_formKey.currentState!.validate()) {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("User not logged in!")),
        );
        return;
      }

      try {
        await FirebaseFirestore.instance
            .collection('Doctors')
            .doc(user.uid)
            .collection('clinics')
            .add({
          'ClinicName': _clinicNameController.text,
          'ClinicCity': _cityController.text,
          'Timings': '${_openingTime.format(context)} - ${_closingTime.format(context)}',
          'Address': _addressController.text,
          'Location': _locationController.text,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Clinic Info Saved Successfully!")),
        );

        // Clear the form
        _clinicNameController.clear();
        _cityController.clear();
        _addressController.clear();
        _locationController.clear();
        setState(() {
          _openingTime = TimeOfDay(hour: 9, minute: 0);
          _closingTime = TimeOfDay(hour: 17, minute: 0);
          _selectedLocation = null;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to save clinic: ${e.toString()}")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFEBFF),
      appBar: AppBar(
        backgroundColor: Colors.deepOrange,
        title: Text("Add Clinic/Hospital",style: TextStyle(color: Colors.white),),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Add one or more Clinics/Hospitals where you can available", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              SizedBox(height: 20),

              TextFormField(
                controller: _clinicNameController,
                decoration: InputDecoration(labelText: "Clinic/Hospital Name", border: OutlineInputBorder()),
                validator: (value) => value!.isEmpty ? "Please enter clinic/hospital name" : null,
              ),
              SizedBox(height: 20),

              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(labelText: "Address", border: OutlineInputBorder()),
                validator: (value) => value!.isEmpty ? "Please enter address" : null,
              ),
              SizedBox(height: 20),

              TextFormField(
                controller: _cityController,
                decoration: InputDecoration(labelText: "City", border: OutlineInputBorder()),
                validator: (value) => value!.isEmpty ? "Please enter city" : null,
              ),
              SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: ListTile(
                      title: Text("Opening Time"),
                      subtitle: Text(_openingTime.format(context)),
                      trailing: Icon(Icons.access_time),
                      onTap: () => _selectTime(context, true),
                    ),
                  ),
                  Expanded(
                    child: ListTile(
                      title: Text("Closing Time"),
                      subtitle: Text(_closingTime.format(context)),
                      trailing: Icon(Icons.access_time),
                      onTap: () => _selectTime(context, false),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),

              ListTile(
                title: Text("Location"),
                subtitle: Text(_selectedLocation != null
                    ? "${_selectedLocation!.latitude}, ${_selectedLocation!.longitude}"
                    : "No location selected"),
                trailing: Icon(Icons.location_on),
                onTap: () => _selectLocation(context),
              ),
              SizedBox(height: 30),

              Center(
                child: ElevatedButton(
                  onPressed: _saveClinicInfo,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange),
                  child: Text("Save Clinic Info", style: TextStyle(color: Colors.white, fontSize: 18)),
                ),
              ),
              SizedBox(height: 10),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _saveClinicInfo();
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Home()));
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: Text("Save and Finish", style: TextStyle(color: Colors.white, fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
class LocationPickerScreen extends StatefulWidget {
  @override
  _LocationPickerScreenState createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  LatLng? _pickedLocation;
  GoogleMapController? _mapController;

  // Default map position (you can change this to your desired initial location)
  static const LatLng _initialPosition = LatLng(33.6844, 73.0479); // Example: Islamabad, Pakistan

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Select Location"),
        actions: [
          IconButton(
            icon: Icon(Icons.check),
            onPressed: () {
              _pickedLocation ="Ahsan Mumtaz Hospita" as LatLng?;
              Navigator.pop(context, _pickedLocation); // Return the selected location
              }

          ),
        ],
      ),
      body:Center(
        child: Image.asset("assets/images/Map.jpg"),
      ) 
      //GoogleMap(
      //   initialCameraPosition: CameraPosition(
      //     target: _initialPosition,
      //     zoom: 12, // Adjust the zoom level as needed
      //   ),
      //   onTap: (LatLng location) {
      //     setState(() {
      //       _pickedLocation = location; // Update the selected location
      //     });
      //   },
      //   markers: _pickedLocation != null
      //       ? {
      //     Marker(
      //       markerId: MarkerId("selected-location"),
      //       position: _pickedLocation!,
      //       infoWindow: InfoWindow(title: "Selected Location"),
      //     ),
      //   }
      //       : {},
      //   onMapCreated: (GoogleMapController controller) {
      //     _mapController = controller;
      //   },
      // ),
    );
  }
}