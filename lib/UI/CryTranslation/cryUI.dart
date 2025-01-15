import 'Result.dart';
import 'package:flutter/material.dart';

class CryCaptureScreen extends StatefulWidget {
  const CryCaptureScreen({super.key});

  @override
  State<CryCaptureScreen> createState() => _CryCaptureScreenState();
}

class _CryCaptureScreenState extends State<CryCaptureScreen> {
  bool isRecording = false;
  int recordingDuration=0;
  late final DateTime startTime;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }
  void startRecording (){
    setState(() {
      isRecording=true;
      recordingDuration=0;
      startTime=DateTime.now();
    });
    simulateRecording();
  }
  void stopRecording(){
    setState(() {
      isRecording=false;
    });
    Navigator.push(context, MaterialPageRoute(builder: (context)=>CryPredictionResultScreen()));
  }
  void simulateRecording(){
    Future.delayed(Duration(seconds: 1),(){
      if(isRecording){
        setState(() {
          recordingDuration=DateTime.now().difference(startTime).inSeconds;
        });
      }
      simulateRecording();
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFDFFAFF),
      appBar: AppBar(
        backgroundColor: Color(0xFFDFFAFF),
        elevation: 0,
        leading: IconButton(
            onPressed: (){Navigator.pop(context);},
            icon: Icon(Icons.arrow_back,color: Colors.black,)
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 150,
                  height: 150,
                  child: CircularProgressIndicator(
                    value: isRecording? recordingDuration/60:0.0,
                    strokeWidth: 8,
                    color: Colors.teal.shade700,
                    backgroundColor: Colors.teal.shade100,
                  ),
                ),
                GestureDetector(
                  onTap: (){
                    if(isRecording){
                      stopRecording();
                    }else{
                      startRecording();
                    }
                  },
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle
                    ),
                    child: Icon(
                      isRecording?Icons.stop : Icons.play_arrow,
                      color: Colors.teal,
                      size: 40,
                    ),
                  ),
                )
              ],
            ),
            SizedBox(height: 20,),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Recording ',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              Text(
                '$recordingDuration s',
                style: TextStyle(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
              ),
              Icon(Icons.circle, color: Colors.redAccent, size: 10),
            ],
          ),
        ),
            SizedBox(height: 30),
            Text(
              'Cry captured?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Press the button to start or stop recording',
              style: TextStyle(
                fontSize: 14,
                color: Colors.black,
              ),
            ),

          ],
        ),
      ),
    );
  }
}
