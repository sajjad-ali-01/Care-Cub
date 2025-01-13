import 'package:flutter/material.dart';
import 'User/Login.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFE3D3), Color(0xFFFFAD9E)],
            //colors: [Color(0xFFFFE3EC), Color(0xFFFFADED)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 60),
                  const Text(
                    "Welcome To Care Cub",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFFF7043),
                    ),
                  ),
                  Text(
                    "Because Every Baby Deserves the Best",
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 15),
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
                          height: 380,
                          width: 250,
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
                          text: 'Track Milestones',
                          icon: Icons.timeline,
                          color: Colors.green.shade100,
                        ),
                      ),
                      Positioned(
                        top: 250,
                        right: 0,
                        child: RoundedButton(
                          text: 'Community chat',
                          icon: Icons.question_answer,
                          color: Colors.blue.shade100,
                        ),
                      ),
                      Positioned(
                        top: 290,
                        left: 0,
                        child: RoundedButton(
                          text: 'Track Routines',
                          icon: Icons.track_changes,
                          color: Colors.blueGrey.shade200,
                        ),
                      ),
                      Positioned(
                        top: 330,
                        right: 0,
                        child: RoundedButton(
                          text: 'Dr. Appointments',
                          icon: Icons.question_answer,
                          color: Colors.yellow.shade100,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 50,),
            Center(
              child: ElevatedButton(
                onPressed: (){
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>Login()));
                }, // Disable while loading
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade300,
                  padding: EdgeInsets.symmetric(
                      vertical: 10, horizontal: 110),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                ),
                child: Text(
                  "Get Starting",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
              ),
            )
          ],
        ),
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
        backgroundColor: color, // Add backgroundColor here.
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
    );
  }
}
