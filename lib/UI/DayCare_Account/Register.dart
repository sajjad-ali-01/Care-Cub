import 'package:carecub/UI/DayCare_Account/Login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../Database/DataBaseReadServices.dart';
import '../../Logic/Users/Functions.dart';
import 'EmailVerificationScreen.dart';

class DaycareRegistrationScreen extends StatefulWidget {
  @override
  _DaycareRegistrationScreenState createState() => _DaycareRegistrationScreenState();
}

class _DaycareRegistrationScreenState extends State<DaycareRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final List<Map<String, dynamic>> programs = [];
  final List<String> selectedFacilities = [];
  final List<String> selectedSafetyFeatures = [];

  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final licenseController = TextEditingController();
  final addressController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final capacityController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  TimeOfDay openingTime = TimeOfDay(hour: 7, minute: 30);
  TimeOfDay closingTime = TimeOfDay(hour: 18, minute: 0);
  int minAge = 2;
  int maxAge = 5;

  bool isLoading = false;
  late final daycareData;
  bool is24Hours = false;
  final List<String> _daysOfWeek = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];
  List<String> selectedDays = [];

  // Predefined options
  final List<String> facilityOptions = [
    'Indoor Play Area', 'Outdoor Playground', 'Nap Rooms',
    'Learning Center', 'Kitchen', 'Security Cameras'
  ];

  final List<String> safetyOptions = [
    'First Aid Certified Staff', 'Secure Entry System',
    'Fire Safety System', 'Emergency Drills', 'CPR Trained Staff'
  ];
  Future<void> registerUser({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    setState(() => isLoading = true);

    try {
      final User? user = await BackendService.registerUser(email, password);
      if (user != null) {
        await BackendService.sendVerificationEmail(user);
        showToast(message: "Verification email sent to $email. Please verify your email.");

        await DataBaseReadServices.SaveDayCareData(
          uid: user.uid,
          daycareData: daycareData,

        );
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => EmailVerificationScreen(
              email: email,
              user: user,
              password: password,
            ),
          ),
              (Route<dynamic> route) => false,

        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Daycare Registration'),
        backgroundColor: Colors.deepOrange.shade400,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildBasicInfoSection(),
              buildAgeRangeSection(),
              buildOperatingHoursSection(),
              buildCapacitySection(),
              buildFacilitiesSection(),
              buildSafetyFeaturesSection(),
              buildProgramsSection(),
              buildContactInfoSection(),
              buildLicenseSection(),
              buildPasswordSection(),
              SizedBox(height: 20),
              buildSubmitButton(),
              buildLoginLink(),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildBasicInfoSection() {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Basic Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            TextFormField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Daycare Name', prefixIcon: Icon(Icons.business)),
              validator: (value) => value!.isEmpty ? 'Required field' : null,
            ),
            TextFormField(
              controller: descriptionController,
              decoration: InputDecoration(labelText: 'Description', prefixIcon: Icon(Icons.description)),
              maxLines: 3,
              validator: (value) => value!.isEmpty ? 'Required field' : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildAgeRangeSection() {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Age Range', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: minAge,
                    items: List.generate(12, (index) => index + 1)
                        .map((age) => DropdownMenuItem(value: age - 1, child: Text('${age - 1} years'))).toList(),
                    onChanged: (value) => setState(() => minAge = value!),
                    decoration: InputDecoration(labelText: 'Minimum Age'),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: maxAge,
                    items: List.generate(12, (index) => index + 1)
                        .map((age) => DropdownMenuItem(value: age, child: Text('$age years'))).toList(),
                    onChanged: (value) => setState(() => maxAge = value!),
                    decoration: InputDecoration(labelText: 'Maximum Age'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildOperatingHoursSection() {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Operating Hours', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            CheckboxListTile(
              title: Text('Open 24 Hours'),
              value: is24Hours,
              onChanged: (value) => setState(() => is24Hours = value!),
            ),
            if (!is24Hours) ...[
              Row(
                children: [
                  Expanded(
                    child: ListTile(
                      title: Text('Opening Time'),
                      subtitle: Text(openingTime.format(context)),
                      trailing: Icon(Icons.access_time),
                      onTap: () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: openingTime,
                        );
                        if (time != null) setState(() => openingTime = time);
                      },
                    ),
                  ),
                  Expanded(
                    child: ListTile(
                      title: Text('Closing Time'),
                      subtitle: Text(closingTime.format(context)),
                      trailing: Icon(Icons.access_time),
                      onTap: () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: closingTime,
                        );
                        if (time != null) setState(() => closingTime = time);
                      },
                    ),
                  ),
                ],
              ),
            ],
            SizedBox(height: 16),
            Text('Operating Days', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _daysOfWeek.map((day) => FilterChip(
                label: Text(day),
                selected: selectedDays.contains(day),
                onSelected: (selected) => setState(() {
                  if (selected) {
                    selectedDays.add(day);
                  } else {
                    selectedDays.remove(day);
                  }
                }),
              )).toList(),
            ),
            if (selectedDays.isEmpty)
              Text('Please select at least one day', style: TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }

  Widget buildCapacitySection() {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Capacity', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            TextFormField(
              controller: capacityController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Maximum Children Capacity',
                prefixIcon: Icon(Icons.people),
              ),
              validator: (value) => value!.isEmpty ? 'Required field' : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildFacilitiesSection() {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Facilities', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Wrap(
              spacing: 8,
              children: facilityOptions.map((facility) => FilterChip(
                label: Text(facility),
                selected: selectedFacilities.contains(facility),
                onSelected: (selected) => setState(() {
                  if (selected) {
                    selectedFacilities.add(facility);
                  } else {
                    selectedFacilities.remove(facility);
                  }
                }),
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSafetyFeaturesSection() {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Safety Features', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Wrap(
              spacing: 8,
              children: safetyOptions.map((safety) => FilterChip(
                label: Text(safety),
                selected: selectedSafetyFeatures.contains(safety),
                onSelected: (selected) => setState(() {
                  if (selected) {
                    selectedSafetyFeatures.add(safety);
                  } else {
                    selectedSafetyFeatures.remove(safety);
                  }
                }),
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildProgramsSection() {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Programs Offered', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () => setState(() => programs.add({'name': '', 'ageRange': '', 'description': ''})),
                ),
              ],
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: programs.length,
              itemBuilder: (context, index) => Column(
                children: [
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Program Name'),
                    onChanged: (value) => programs[index]['name'] = value,
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Age Range'),
                    onChanged: (value) => programs[index]['ageRange'] = value,
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Description'),
                    onChanged: (value) => programs[index]['description'] = value,
                    maxLines: 2,
                  ),
                  Divider(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildContactInfoSection() {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Contact Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            TextFormField(
              controller: addressController,
              decoration: InputDecoration(labelText: 'Address', prefixIcon: Icon(Icons.location_on)),
              validator: (value) => value!.isEmpty ? 'Required field' : null,
            ),
            TextFormField(
              controller: phoneController,
              decoration: InputDecoration(labelText: 'Phone Number', prefixIcon: Icon(Icons.phone)),
              keyboardType: TextInputType.phone,
              validator: (value) => value!.isEmpty ? 'Required field' : null,
            ),
            TextFormField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email)),
              keyboardType: TextInputType.emailAddress,
              validator: (value) => value!.isEmpty ? 'Required field' : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildLicenseSection() {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('License Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            TextFormField(
              controller: licenseController,
              decoration: InputDecoration(
                labelText: 'License Number',
                prefixIcon: Icon(Icons.assignment),
              ),
              validator: (value) => value!.isEmpty ? 'Required field' : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildPasswordSection() {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Password', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            TextFormField(
              controller: passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: Icon(Icons.lock),
              ),
              obscureText: true,
              validator: (value) {
                if (value!.isEmpty) return 'Required field';
                if (value.length < 6) return 'Password must be at least 6 characters';
                return null;
              },
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: confirmPasswordController,
              decoration: InputDecoration(
                labelText: 'Confirm Password',
                prefixIcon: Icon(Icons.lock),
              ),
              obscureText: true,
              validator: (value) {
                if (value!.isEmpty) return 'Required field';
                if (value != passwordController.text) return 'Passwords do not match';
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepOrange.shade400,
          padding: EdgeInsets.symmetric(vertical: 16),
        ),
        onPressed: isLoading
            ? null // Disable the button when loading
            : () async {
          if (_formKey.currentState!.validate()) {
            if (passwordController.text != confirmPasswordController.text) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Passwords do not match')),
              );
              return;
            }

            setState(() => isLoading = true); // Start loading

            bool isVerified = false;
            daycareData = {
              'name': nameController.text,
              'description': descriptionController.text,
              'ageRange': '$minAge-$maxAge years',
              'hours': is24Hours
                  ? '24 Hours'
                  : '${openingTime.format(context)} - ${closingTime.format(context)}',
              'operatingDays': selectedDays,
              'capacity': capacityController.text,
              'facilities': selectedFacilities,
              'safetyFeatures': selectedSafetyFeatures,
              'programs': programs,
              'address': addressController.text,
              'phone': phoneController.text,
              'email': emailController.text,
              'license': licenseController.text,
              'createdAt': FieldValue.serverTimestamp(),
              'isVerified': isVerified,
            };

            try {
              await registerUser(
                email: emailController.text,
                password: passwordController.text,
                context: context,
              );

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Daycare registration submitted successfully!')),
              );

              _formKey.currentState!.reset();
              setState(() {
                selectedFacilities.clear();
                selectedSafetyFeatures.clear();
                programs.clear();
                selectedDays.clear();
                is24Hours = false;
                openingTime = TimeOfDay(hour: 7, minute: 30);
                closingTime = TimeOfDay(hour: 18, minute: 0);
                minAge = 2;
                maxAge = 5;
              });
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Failed to submit registration: ${e.toString()}')),
              );
            } finally {
              setState(() => isLoading = false);
            }
          } else {
            showToast(message: "Please fill out all fields");
          }
        },
        child: isLoading
            ? SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 2,
          ),
        )
            : Text(
          'Submit Registration',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
  Widget buildLoginLink() {
    return Center(
      child: TextButton(
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => DayCareLogin()),
          );
        },
        child: Text('Already have an account? Login', style: TextStyle(color: Colors.deepOrange)),
      ),
    );
  }
}