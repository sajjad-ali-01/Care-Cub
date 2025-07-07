import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'ThankyouScreen.dart';

class AddClinicScreen extends StatefulWidget {
  @override
  _AddClinicScreenState createState() => _AddClinicScreenState();
}

class _AddClinicScreenState extends State<AddClinicScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController clinicNameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController feeController = TextEditingController();
  bool isLoading = false;
  LatLng? selectedLocation;
  String? selectedAddress;

  final List<String> daysOfWeek = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  final Map<String, Map<String, dynamic>> selectedDays = {
    'Monday': {'start': TimeOfDay(hour: 9, minute: 0), 'end': TimeOfDay(hour: 17, minute: 0), 'isSelected': false},
    'Tuesday': {'start': TimeOfDay(hour: 9, minute: 0), 'end': TimeOfDay(hour: 17, minute: 0), 'isSelected': false},
    'Wednesday': {'start': TimeOfDay(hour: 9, minute: 0), 'end': TimeOfDay(hour: 17, minute: 0), 'isSelected': false},
    'Thursday': {'start': TimeOfDay(hour: 9, minute: 0), 'end': TimeOfDay(hour: 17, minute: 0), 'isSelected': false},
    'Friday': {'start': TimeOfDay(hour: 9, minute: 0), 'end': TimeOfDay(hour: 17, minute: 0), 'isSelected': false},
    'Saturday': {'start': TimeOfDay(hour: 9, minute: 0), 'end': TimeOfDay(hour: 17, minute: 0), 'isSelected': false},
    'Sunday': {'start': TimeOfDay(hour: 9, minute: 0), 'end': TimeOfDay(hour: 17, minute: 0), 'isSelected': false},
  };

  Future<void> selectTime(BuildContext context, String day, bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStartTime ? selectedDays[day]!['start']! : selectedDays[day]!['end']!,
    );
    if (picked != null) {
      setState(() {
        if (isStartTime) {
          selectedDays[day]!['start'] = picked;
        } else {
          selectedDays[day]!['end'] = picked;
        }
      });
    }
  }

  void toggleDaySelection(String day) {
    setState(() {
      selectedDays[day]!['isSelected'] = !selectedDays[day]!['isSelected']!;
    });
  }

  Future<void> _selectLocation() async {
    // Request location permission
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Location services are disabled.')),
      );
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Location permissions are denied')),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Location permissions are permanently denied.')),
      );
      return;
    }

    // Get current position
    Position position = await Geolocator.getCurrentPosition();

    // Show map for location selection
    final LatLng? picked = await Navigator.of(context).push<LatLng>(
      MaterialPageRoute(
        builder: (context) => LocationPickerScreen(
          initialPosition: LatLng(position.latitude, position.longitude),
        ),
      ),
    );

    if (picked != null) {
      setState(() {
        selectedLocation = picked;
      });

      // Get address from coordinates
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          picked.latitude,
          picked.longitude,
        );

        if (placemarks.isNotEmpty) {
          Placemark place = placemarks.first;
          setState(() {
            selectedAddress = "${place.street}, ${place.locality}, ${place.country}";
            addressController.text = selectedAddress ?? '';
            cityController.text = place.locality ?? '';
          });
        }
      } catch (e) {
        print("Error getting address: $e");
      }
    }
  }

  Future<void> saveClinicInfo() async {
    if (_formKey.currentState!.validate()) {
      if (selectedLocation == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Please select a location from the map")),
        );
        return;
      }

      setState(() {
        isLoading = true;
      });

      final User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("User not logged in!")),
        );
        setState(() {
          isLoading = false;
        });
        return;
      }

      try {
        final Map<String, Map<String, String>> availability = {};
        selectedDays.forEach((day, timings) {
          if (timings['isSelected']!) {
            availability[day] = {
              'start': timings['start']!.format(context),
              'end': timings['end']!.format(context),
            };
          }
        });

        await FirebaseFirestore.instance
            .collection('Doctors')
            .doc(user.uid)
            .collection('clinics')
            .add({
          'ClinicName': clinicNameController.text,
          'ClinicCity': cityController.text,
          'Address': addressController.text,
          'Location': GeoPoint(selectedLocation!.latitude, selectedLocation!.longitude),
          'Availability': availability,
          'Fees': feeController.text,
          'FormattedAddress': selectedAddress,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Clinic Info Saved Successfully!")),
        );

        clinicNameController.clear();
        cityController.clear();
        addressController.clear();
        feeController.clear();
        setState(() {
          selectedDays.forEach((key, value) {
            value['isSelected'] = false;
          });
          selectedLocation = null;
          selectedAddress = null;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to save clinic: ${e.toString()}")),
        );
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFEBFF),
      appBar: AppBar(
        backgroundColor: Colors.deepOrange,
        title: Text("Add Clinic/Hospital", style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Add one or more Clinics/Hospitals where you can be available",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),

              TextFormField(
                controller: clinicNameController,
                decoration: InputDecoration(
                  labelText: "Clinic/Hospital Name",
                  hintText: "Ali Hospital",
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value!.isEmpty ? "Please enter clinic/hospital name" : null,
              ),
              SizedBox(height: 20),

              TextFormField(
                controller: feeController,
                decoration: InputDecoration(
                  labelText: "Fees",
                  hintText: "1000",
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value!.isEmpty ? "Please enter fees" : null,
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 20),

              TextFormField(
                controller: addressController,
                decoration: InputDecoration(
                  labelText: "Address",
                  border: OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.map),
                    onPressed: _selectLocation,
                  ),
                ),
                validator: (value) => value!.isEmpty ? "Please enter address" : null,
                readOnly: true,
                onTap: _selectLocation,
              ),
              SizedBox(height: 20),

              TextFormField(
                controller: cityController,
                decoration: InputDecoration(
                  labelText: "City",
                  hintText: "Lahore",
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value!.isEmpty ? "Please enter city" : null,
              ),
              SizedBox(height: 20),

              if (selectedLocation != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Selected Location:",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text("Latitude: ${selectedLocation!.latitude}"),
                    Text("Longitude: ${selectedLocation!.longitude}"),
                    SizedBox(height: 10),
                  ],
                ),

              Text(
                "Select Availability Days and Timings",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),

              Column(
                children: daysOfWeek.map((day) {
                  return Column(
                    children: [
                      CheckboxListTile(
                        title: Text(day),
                        value: selectedDays[day]!['isSelected'],
                        onChanged: (value) {
                          toggleDaySelection(day);
                        },
                      ),
                      if (selectedDays[day]!['isSelected']!)
                        Row(
                          children: [
                            Expanded(
                              child: ListTile(
                                title: Text("Start Time"),
                                subtitle: Text(selectedDays[day]!['start']!.format(context)),
                                trailing: Icon(Icons.access_time),
                                onTap: () => selectTime(context, day, true),
                              ),
                            ),
                            Expanded(
                              child: ListTile(
                                title: Text("End Time"),
                                subtitle: Text(selectedDays[day]!['end']!.format(context)),
                                trailing: Icon(Icons.access_time),
                                onTap: () => selectTime(context, day, false),
                              ),
                            ),
                          ],
                        ),
                    ],
                  );
                }).toList(),
              ),
              SizedBox(height: 30),

              Center(
                child: ElevatedButton(
                  onPressed: saveClinicInfo,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange,
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  ),
                  child: isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text("Save Clinic Info", style: TextStyle(color: Colors.white, fontSize: 18)),
                ),
              ),
              SizedBox(height: 10),
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      await saveClinicInfo();
                      if (!mounted) return;
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => ThankYouScreen()),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  ),
                  child: isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text("Save and Finish", style: TextStyle(color: Colors.white, fontSize: 18)),
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
  final LatLng initialPosition;

  LocationPickerScreen({required this.initialPosition});

  @override
  _LocationPickerScreenState createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  late GoogleMapController mapController;
  LatLng? selectedLocation;
  final Set<Marker> markers = {};
  final TextEditingController searchController = TextEditingController();
  bool isSearching = false;

  @override
  void initState() {
    super.initState();
    selectedLocation = widget.initialPosition;
    markers.add(
      Marker(
        markerId: MarkerId('selectedLocation'),
        position: widget.initialPosition,
        draggable: true,
      ),
    );
  }

  Future<void> searchPlace(String query) async {
    if (query.isEmpty) return;

    setState(() {
      isSearching = true;
    });

    try {
      List<Location> locations = await locationFromAddress(query);
      if (locations.isNotEmpty) {
        final location = locations.first;
        final newPosition = LatLng(location.latitude, location.longitude);

        setState(() {
          selectedLocation = newPosition;
          markers.clear();
          markers.add(
            Marker(
              markerId: MarkerId('selectedLocation'),
              position: newPosition,
              draggable: true,
            ),
          );
          mapController.animateCamera(
            CameraUpdate.newLatLngZoom(newPosition, 15),
          );
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No results found for "$query"')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error searching location: ${e.toString()}')),
      );
    } finally {
      setState(() {
        isSearching = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Clinic Location'),
        actions: [
          IconButton(
            icon: Icon(Icons.check),
            onPressed: () {
              if (selectedLocation != null) {
                Navigator.pop(context, selectedLocation);
              }
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: widget.initialPosition,
              zoom: 15,
            ),
            onMapCreated: (controller) {
              setState(() {
                mapController = controller;
              });
            },
            markers: markers,
            onTap: (LatLng location) {
              setState(() {
                selectedLocation = location;
                markers.clear();
                markers.add(
                  Marker(
                    markerId: MarkerId('selectedLocation'),
                    position: location,
                    draggable: true,
                  ),
                );
              });
            },
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
          ),
          Positioned(
            top: 10,
            left: 10,
            right: 10,
            child: Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: searchController,
                        decoration: InputDecoration(
                          hintText: 'Search for a place...',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 15),
                        ),
                        onSubmitted: searchPlace,
                      ),
                    ),
                    if (isSearching)
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(),
                      )
                    else
                      IconButton(
                        icon: Icon(Icons.search),
                        onPressed: () => searchPlace(searchController.text),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.my_location),
        onPressed: () async {
          Position position = await Geolocator.getCurrentPosition();
          setState(() {
            selectedLocation = LatLng(position.latitude, position.longitude);
            markers.clear();
            markers.add(
              Marker(
                markerId: MarkerId('selectedLocation'),
                position: selectedLocation!,
                draggable: true,
              ),
            );
            mapController.animateCamera(
              CameraUpdate.newLatLng(selectedLocation!),
            );
          });
        },
      ),
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}