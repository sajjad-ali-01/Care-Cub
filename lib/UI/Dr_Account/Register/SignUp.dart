import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../Database/DatabaseServices.dart';
import '../../../Logic/Users/ParentsLogic.dart';
import 'Professional_Info.dart';
import 'EmailVerificationScreen.dart';


class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();
  final _countryController = TextEditingController(text: "Pakistan");


  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  String? _selectedTitle;
  String? _selectedCity;
  bool _isLoading = false;
  final List<String> _cities = [
    'Karachi', 'Lahore', 'Islamabad'
  ];

  Future<void> _registerUser({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    setState(() => _isLoading = true);

    try {
      final User? user = await BackendService.registerUser(email, password);
      if (user != null) {
        await BackendService.sendVerificationEmail(user);
        showToast(message: "Verification email sent to $email. Please verify your email.");

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EmailVerificationScreen(
              name: _nameController.text.trim(),
              email: email,
              phone: _phoneController.text.trim(),
              title: _selectedTitle ??'',
              city: _selectedCity ?? "",
              user: user,
              password: password,
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFEBFF),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                SizedBox(height: 30),
                Text(
                  "Sign In ",
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w900,
                    color: Colors.deepOrange,
                  ),
                ),
                SizedBox(height: 25),

                // Title Dropdown
                DropdownButtonFormField<String>(
                  value: _selectedTitle,
                  dropdownColor: Color(0xFFFFEBFF),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: Icon(Icons.person_outline),
                    hintText: 'Select Title',
                  ),
                  items: ['Dr.', 'Prof.', 'Assist. Prof.', 'Assoc. Prof.']
                      .map((title) => DropdownMenuItem<String>(
                    value: title,
                    child: Text(title),
                  ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedTitle = value;
                    });
                  },
                  validator: (value) =>
                  value == null ? 'Please select a title' : null,
                ),
                SizedBox(height: 15),

                // Name Field
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.person),
                    hintText: 'Full Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (value) =>
                  value == null || value.isEmpty ? 'Enter your name' : null,
                ),
                SizedBox(height: 15),

                // Country Field (Fixed)
                TextFormField(
                  controller: _countryController,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.flag),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  enabled: false,
                ),
                SizedBox(height: 15),

                // City Dropdown
                DropdownButtonFormField<String>(
                  value: _selectedCity,
                  dropdownColor: Color(0xFFFFEBFF),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: Icon(Icons.location_city),
                    hintText: 'Select City',
                  ),
                  items: _cities
                      .map((city) => DropdownMenuItem<String>(
                    value: city,
                    child: Text(city),
                  ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCity = value;
                    });
                  },
                  validator: (value) =>
                  value == null ? 'Please select a city' : null,
                ),
                SizedBox(height: 15),

                // Email Field
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.email_outlined),
                    hintText: 'Email',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (value) =>
                  value == null || value.isEmpty ? 'Enter your email' : null,
                ),
                SizedBox(height: 15),

                // Phone Number Field
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    prefixIcon: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        "+92",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    prefixIconConstraints: BoxConstraints(minWidth: 50, minHeight: 0),
                    hintText: 'Phone Number',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Enter your phone number';
                    } else if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) {
                      return 'Enter a valid 10-digit phone number';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 15),

                // Password Field
                TextFormField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.lock_outline),
                    hintText: 'Password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Enter your password';
                    } else if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 15),

                // Confirm Password Field
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: !_isConfirmPasswordVisible,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.lock_outline),
                    hintText: 'Confirm Password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isConfirmPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Confirm your password';
                    } else if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),

                //Next Button
                ElevatedButton(
                  onPressed: (){
                    _registerUser(email: _emailController.text, password: _passwordController.text, context: context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange,
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 100),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    "Next",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}