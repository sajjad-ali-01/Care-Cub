import 'package:flutter/material.dart';
import 'User/Login.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFFE3D3), Color(0xFFFFAD9E)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 60),
                        const Text(
                          "Welcome To Care Cub",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFFF7043),
                          ),
                        ),
                        const Text(
                          "Because Every Baby Deserves the Best",
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      alignment: WrapAlignment.center,
                      children: [
                        Stack(
                          children: [
                            Center(
                              child: Image.asset(
                                "assets/images/cute_baby.png",
                                height: constraints.maxHeight * 0.483,
                                width: constraints.maxWidth * 0.95,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              top: 0,
                              left: 0,
                              child: RoundedButton(
                                text: 'Translate Cries',
                                icon: Icons.mic,
                                color: Colors.purple.shade100,
                              ),
                            ),
                            Positioned(
                              top: 40,
                              right: 0,
                              child: RoundedButton(
                                text: 'Nutrition Guid',
                                icon: Icons.fastfood_rounded,
                                color: Colors.orange.shade100,
                              ),
                            ),
                            Positioned(
                              top: 80,
                              left: 0,
                              child: RoundedButton(
                                text: 'Track Routines',
                                icon: Icons.timeline,
                                color: Colors.green.shade100,
                              ),
                            ),
                            Positioned(
                              top: 270,
                              right: 0,
                              child: RoundedButton(
                                text: 'Community chat',
                                icon: Icons.question_answer,
                                color: Colors.blue.shade100,
                              ),
                            ),
                            Positioned(
                              top: 320,
                              left: 0,
                              child: RoundedButton(
                                text: 'Dr. Appointment',
                                icon: Icons.local_hospital,
                                color: Colors.yellow.shade100,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 90),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => Login()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade300,
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 75),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text(
                        "Get Starting",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 22,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class RoundedButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color color;

  const RoundedButton({
    Key? key,
    required this.text,
    required this.icon,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () {},
      icon: Icon(icon, color: Colors.black54),
      label: Text(
        text,
        style: const TextStyle(color: Colors.black87),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
    );
  }
}
