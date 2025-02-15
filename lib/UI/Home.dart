import 'package:carecub/UI/DayCare/DayCareListing.dart';
import 'package:flutter/material.dart';
import '../DayCare_Account/Register.dart';
import 'Community/Community.dart';
import 'CryTranslation/cryUI.dart';
import 'Doctor/Doctorlist.dart';
import 'Dr_Account/Register/SignUp.dart';
import 'Nutrition Guide/NutritionGuidanceScreen.dart';
import 'User/ProfileScreen.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}
class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
      child: Container(
        decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [ Color(0xFFFFADB0),Colors.white60,Color(0xFFFFE3EC),Color(0xFFFFADB0)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        ),
    ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 30),
            GestureDetector(
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context)=>UserProfileScreen()));
              },
              child: Container(
                width: MediaQuery.of(context).size.width, // Set the desired width
                height: 120.0,
                //padding: const EdgeInsets.symmetric(vertical: 40,horizontal: 15),
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                      //colors: [Color(0xFFFFE3EC), Color(0xFFFFADED)],
                      colors: [Color(0xFFFFE3D3), Color(0xFFFFAD9E)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(10),
                      bottomRight: Radius.circular(10),
                    )
                ),
                child: Row(
                  children: [
                    SizedBox(width: 20,),
                    Image.asset(
                      'assets/images/cute_baby.png', // Replace with your image path
                      width: 120,
                      height: 120,
                    ),
                    SizedBox(width: 10,),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Ali Hamza',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 25,
                              fontWeight: FontWeight.bold
                          ),
                        ),
                        const Text(
                          '5 weeks',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.bold
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context)=>UserProfileScreen()));
                          },
                          icon: Icon(Icons.account_circle, color: Colors.black54),
                          label: Text(
                            "Profile",
                            style: const TextStyle(color: Colors.black87),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.pink.shade100, // Add backgroundColor here.
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          ),
                        )
                      ],
                    ),

                  ],
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => CryCaptureScreen()));
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFFFE3EC), Colors.purple.shade50],
                    //colors: [Color(0xFFFFE3D3), Color(0xFFFFAD9E)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  // borderRadius: const BorderRadius.only(
                  //   bottomLeft: Radius.circular(10),
                  //   bottomRight: Radius.circular(10),
                  color: Colors.purple.shade100, // Card background color
                  borderRadius: BorderRadius.circular(12), // Match Card's corner radius
                  boxShadow: [
                    BoxShadow(
                      color: Colors.purple.shade200, // Shadow color with transparency
                      blurRadius: 10, // Spread of the shadow
                      offset: Offset(4, 4), // Position of the shadow
                    ),
                  ],
                ),
                child: Card(
                  elevation: 0, // Set elevation to 0 to avoid conflicting shadows
                  color: Colors.transparent, // Ensure the Card doesn't have a background color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Cry Translator AI',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Text(
                              'Translate your baby`s cry with AI',
                              style: TextStyle(fontSize: 16),
                            ),
                            Text(
                              '1 week',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            backgroundColor: Colors.pink.shade100
                          ),
                          child: const Text('Optimize your baby\'s needs'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(height: 20,),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: GridView(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                children: [
                  buildCard(
                    'Nutrition Guid',
                    Icons.apple,
                    Colors.red.shade100,
                    Colors.pink,
                        () {
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>NutritionGuidanceScreen()));
                    },
                  ),
                  buildCard(
                    "Doctor Appointments",
                    Icons.local_hospital_outlined,
                    Color(0xFFFFEBFF),
                    Colors.red.shade600, // Shadow color
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => Doctorlist()),
                          );
                    },
                  ),
                  buildCard(
                    "Community",
                    Icons.comment,
                    Color(0xFFDFFAFF),
                    Colors.cyan, // Shadow color
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => Community()),
                          );
                    },
                  ),
                  buildCard(
                    "DayCare Centers",
                    Icons.maps_home_work_sharp,
                    Color(0xFFE9FEEF),
                    Colors.blue, // Shadow color
                        () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => DayCareList()),
                      );
                    },
                  ),
                  buildCard(
                    "Trackers",
                    Icons.track_changes,
                    Color(0xFFFFFFF1),
                    Colors.orange, // Shadow color
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => DayCareList()),
                          );
                    },
                  ),
                  buildCard(
                    "Milestone Tracking",
                    Icons.show_chart,
                    Color(0xAFFDFFD6),
                    Colors.yellow, // Shadow color
                        () {
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>DaycareRegistrationScreen()));
                    },
                  ),
                ],
              ),
            ),

            SizedBox(height: 20,),
          ],
        ),
    )
    )
    );
  }
}

// Method to Build Each Card
Widget buildCard(String title, IconData icon, Color cardColor, Color shadowColor, VoidCallback onTap) {
  return InkWell(
    onTap: onTap,
    child: Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16), // Rounded corners
        boxShadow: [
          BoxShadow(
            color: shadowColor.withOpacity(0.5), // Shadow color with transparency
            blurRadius: 10, // Blur effect for the shadow
            offset: Offset(4, 4), // Shadow position (x, y)
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.deepOrange),
            SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
