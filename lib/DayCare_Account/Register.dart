import 'package:flutter/material.dart';

class DaycareRegistrationScreen extends StatefulWidget {
  @override
  _DaycareRegistrationScreenState createState() => _DaycareRegistrationScreenState();
}

class _DaycareRegistrationScreenState extends State<DaycareRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final List<Map<String, dynamic>> _programs = [];
  final List<String> _selectedFacilities = [];
  final List<String> _selectedSafetyFeatures = [];

  // Controllers
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _licenseController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _capacityController = TextEditingController();
  TimeOfDay _openingTime = TimeOfDay(hour: 7, minute: 30);
  TimeOfDay _closingTime = TimeOfDay(hour: 18, minute: 0);
  int _minAge = 2;
  int _maxAge = 5;

  bool _is24Hours = false;
  final List<String> _daysOfWeek = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];
  List<String> _selectedDays = [];


  // Predefined options
  final List<String> _facilityOptions = [
    'Indoor Play Area', 'Outdoor Playground', 'Nap Rooms',
    'Learning Center', 'Kitchen', 'Security Cameras'
  ];

  final List<String> _safetyOptions = [
    'First Aid Certified Staff', 'Secure Entry System',
    'Fire Safety System', 'Emergency Drills', 'CPR Trained Staff'
  ];

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
              _buildBasicInfoSection(),
              _buildAgeRangeSection(),
              _buildOperatingHoursSection(),
              _buildCapacitySection(),
              _buildFacilitiesSection(),
              _buildSafetyFeaturesSection(),
              _buildProgramsSection(),
              _buildContactInfoSection(),
              _buildLicenseSection(),
              SizedBox(height: 20),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection() {
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
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Daycare Name', prefixIcon: Icon(Icons.business)),
              validator: (value) => value!.isEmpty ? 'Required field' : null,
            ),
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Description', prefixIcon: Icon(Icons.description)),
              maxLines: 3,
              validator: (value) => value!.isEmpty ? 'Required field' : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAgeRangeSection() {
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
                    value: _minAge,
                    items: List.generate(12, (index) => index + 1)
                        .map((age) => DropdownMenuItem(value: age, child: Text('$age years'))).toList(),
                    onChanged: (value) => setState(() => _minAge = value!),
                    decoration: InputDecoration(labelText: 'Minimum Age'),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: _maxAge,
                    items: List.generate(12, (index) => index + 1)
                        .map((age) => DropdownMenuItem(value: age, child: Text('$age years'))).toList(),
                    onChanged: (value) => setState(() => _maxAge = value!),
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

  Widget _buildOperatingHoursSection() {
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
              value: _is24Hours,
              onChanged: (value) => setState(() => _is24Hours = value!),
            ),
            if (!_is24Hours) ...[
              Row(
                children: [
                  Expanded(
                    child: ListTile(
                      title: Text('Opening Time'),
                      subtitle: Text(_openingTime.format(context)),
                      trailing: Icon(Icons.access_time),
                      onTap: () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: _openingTime,
                        );
                        if (time != null) setState(() => _openingTime = time);
                      },
                    ),
                  ),
                  Expanded(
                    child: ListTile(
                      title: Text('Closing Time'),
                      subtitle: Text(_closingTime.format(context)),
                      trailing: Icon(Icons.access_time),
                      onTap: () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: _closingTime,
                        );
                        if (time != null) setState(() => _closingTime = time);
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
                selected: _selectedDays.contains(day),
                onSelected: (selected) => setState(() {
                  if (selected) {
                    _selectedDays.add(day);
                  } else {
                    _selectedDays.remove(day);
                  }
                }),
              )).toList(),
            ),
            if (_selectedDays.isEmpty)
              Text('Please select at least one day', style: TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }

  Widget _buildCapacitySection() {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Capacity', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            TextFormField(
              controller: _capacityController,
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

  Widget _buildFacilitiesSection() {
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
              children: _facilityOptions.map((facility) => FilterChip(
                label: Text(facility),
                selected: _selectedFacilities.contains(facility),
                onSelected: (selected) => setState(() {
                  if (selected) {
                    _selectedFacilities.add(facility);
                  } else {
                    _selectedFacilities.remove(facility);
                  }
                }),
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSafetyFeaturesSection() {
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
              children: _safetyOptions.map((safety) => FilterChip(
                label: Text(safety),
                selected: _selectedSafetyFeatures.contains(safety),
                onSelected: (selected) => setState(() {
                  if (selected) {
                    _selectedSafetyFeatures.add(safety);
                  } else {
                    _selectedSafetyFeatures.remove(safety);
                  }
                }),
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgramsSection() {
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
                  onPressed: () => setState(() => _programs.add({'name': '', 'ageRange': '', 'description': ''})),
                ),
              ],
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: _programs.length,
              itemBuilder: (context, index) => Column(
                children: [
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Program Name'),
                    onChanged: (value) => _programs[index]['name'] = value,
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Age Range'),
                    onChanged: (value) => _programs[index]['ageRange'] = value,
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Description'),
                    onChanged: (value) => _programs[index]['description'] = value,
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

  Widget _buildContactInfoSection() {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Contact Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            TextFormField(
              controller: _addressController,
              decoration: InputDecoration(labelText: 'Address', prefixIcon: Icon(Icons.location_on)),
              validator: (value) => value!.isEmpty ? 'Required field' : null,
            ),
            TextFormField(
              controller: _phoneController,
              decoration: InputDecoration(labelText: 'Phone Number', prefixIcon: Icon(Icons.phone)),
              keyboardType: TextInputType.phone,
              validator: (value) => value!.isEmpty ? 'Required field' : null,
            ),
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email)),
              keyboardType: TextInputType.emailAddress,
              validator: (value) => value!.isEmpty ? 'Required field' : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLicenseSection() {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('License Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            TextFormField(
              controller: _licenseController,
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

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepOrange.shade400,
          padding: EdgeInsets.symmetric(vertical: 16),
        ),
        child: Text('Submit Registration', style: TextStyle(fontSize: 18)),
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            final daycareData = {
              'name': _nameController.text,
              'description': _descriptionController.text,
              'ageRange': '$_minAge-$_maxAge years',
              'hours': '${_openingTime.format(context)} - ${_closingTime.format(context)}',
              'capacity': _capacityController.text,
              'facilities': _selectedFacilities,
              'safetyFeatures': _selectedSafetyFeatures,
              'programs': _programs,
              'address': _addressController.text,
              'phone': _phoneController.text,
              'email': _emailController.text,
              'license': _licenseController.text,
            };
            // Handle submission logic here
            print(daycareData);
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _licenseController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _capacityController.dispose();
    super.dispose();
  }
}