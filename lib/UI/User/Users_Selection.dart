import 'package:carecub/UI/User/Login.dart';
import 'package:flutter/material.dart';

import '../DayCare_Account/Login.dart';
import '../Dr_Account/Login.dart';

class RoleSelection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.redAccent.shade100,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 30),
                child: CircleAvatar(
                  radius: 85,
                  backgroundColor: Colors.red.shade300,
                  child: Image.asset("assets/images/Baby.png"),
                ),
              ),

              Center(
                child: Stack(
                  children: [
                    // White stroke (outline)
                    Text(
                      "Let's Go With Us As",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        foreground: Paint()
                          ..style = PaintingStyle.stroke
                          ..strokeWidth = 2.5
                          ..color = Colors.white,
                      ),
                    ),
                    // Main text (filled color)
                    Text(
                      "Let's Go With Us As",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple.shade900,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16,),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  children: [
                    Button(
                      context,
                      icon: Icons.family_restroom_sharp,
                      label: "Parent",
                      color: Color(0xFFDFEEFF),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const Login()),
                        );
                      },
                    ),
                    const SizedBox(height: 30),
                    Button(
                      context,
                      icon: Icons.local_hospital,
                      label: "Doctor",

                      color: Color(0xFFFFDBFF),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const DrLogin()),
                        );
                      },
                    ),
                    const SizedBox(height: 30),
                    Button(
                      context,
                      icon: Icons.maps_home_work_sharp,
                      label: "Daycare Centers",
                      color: Color(0xFFE9FEEF),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => DayCareLogin()),
                        );
                      },
                    ),
                  ],
                ),
              ),

              // Bottom Space
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }

  Widget Button(
      BuildContext context, {
        required IconData icon,
        required String label,
        required Color color,
        required VoidCallback onPressed,
      }) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: color,
        elevation: 0,
        minimumSize: const Size(double.infinity, 80),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(color: color.withOpacity(0.3)),
        ),
      ),
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 30),
          const SizedBox(width: 15),
          Text(
            label,
            style: const TextStyle(
              fontSize: 20,
              color: Colors.black,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

