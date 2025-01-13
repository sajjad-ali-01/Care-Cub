import 'package:flutter/material.dart';
import 'User/ChildDetailsScreen.dart';

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
          colors: [ Colors.white38,Colors.white38,],//[ Color(0xFFFFADD2),Color(0xFFFFE3EC),],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        ),
        borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(20),
        bottomRight: Radius.circular(20),
      ),
    ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 30,),
            GestureDetector(
              onTap: (){},
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
                      width: 120, // Adjust the width as needed
                      height: 120, // Adjust the height as needed
                      // Adjust how the image fits in the container
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
                          onPressed: () {},
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
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context)=>ChildDetailsScreen()));
              },
              child: Card(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Baby Tracker',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text(
                            'Last diaper changed',
                            style: TextStyle(fontSize: 16),
                          ),
                          Text(
                            '1 month',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          //primary: Colors.purple,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Optimize your baby\'s sleep'),
                      ),
                    ],
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
                  _buildCard("Feed", Icons.local_drink, Color(0xFFE6DFFF)),
                  _buildCard("Express", Icons.water_drop, Color(0xFFFFE6E6)),
                  _buildCard("Nappy", Icons.baby_changing_station,
                      Color(0xFFDFFAFF)),
                  _buildCard("Sleep", Icons.bedtime, Color(0xFFFFE6DD)),
                  _buildCard("Growth", Icons.show_chart, Color(0xFFFFFFD6)),
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
Widget _buildCard(String title, IconData icon, Color color) {
  return Container(
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(16),
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
                fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
          ),
        ],
      ),
    ),
  );
}
