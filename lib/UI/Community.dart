import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CommunityScreenDark(
        userData: {
          "Email": "test@example.com",
          "Name": "You",
          "Pic": "assets/images/profile_pic.png"
        },
      ),
    );
  }
}

class CommunityScreenDark extends StatefulWidget {
  final Map<String, dynamic> userData;

  CommunityScreenDark({Key? key, required this.userData}) : super(key: key);

  @override
  State<CommunityScreenDark> createState() => _CommunityScreenDarkState();
}

class _CommunityScreenDarkState extends State<CommunityScreenDark> {
  TextEditingController messageController = TextEditingController();
  List<Map<String, dynamic>> messages = [];

  @override
  void initState() {
    super.initState();
    loadSampleMessages();
  }

  void loadSampleMessages() {
    messages = [
      {
        "Email": "user1@example.com",
        "Name": "Alice",
        "message": "Hello everyone! 👋",
        "isImage": false
      },
      {
        "Email": "user2@example.com",
        "Name": "Bob",
        "message": "How's your day going?",
        "isImage": false
      },
      {
        "Email": widget.userData["Email"],
        "Name": "You",
        "message": "Great! Just working on my project. 🚀",
        "isImage": false
      },
      {
        "Email": "user4@example.com",
        "Name": "David",
        "message": "Anyone here into Flutter? 🧑‍💻",
        "isImage": false
      },
      {
        "Email": widget.userData["Email"],
        "Name": "You",
        "message": "Yes! I love building apps with Flutter. 💙",
        "isImage": false
      }
    ];
  }

  void sendMessage() {
    if (messageController.text.trim().isEmpty) return;

    setState(() {
      messages.add({
        "Email": widget.userData["Email"],
        "Name": "You",
        "message": messageController.text.trim(),
        "isImage": false
      });
      messageController.clear();
    });
  }

  Future<void> pickImage(ImageSource imageSource) async {
    try {
      final photo = await ImagePicker().pickImage(source: imageSource);
      if (photo == null) return;
      final tempImage = File(photo.path);

      setState(() {
        messages.add({
          "Email": widget.userData["Email"],
          "Name": "You",
          "message": tempImage.path,
          "isImage": true
        });
      });
    } catch (ex) {
      print("Error picking image: ${ex.toString()}");
    }
  }

  void showAlertBox() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Pick Image From"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                onTap: () {
                  pickImage(ImageSource.camera);
                  Navigator.pop(context);
                },
                leading: Icon(Icons.camera_alt),
                title: Text("Camera"),
              ),
              ListTile(
                onTap: () {
                  pickImage(ImageSource.gallery);
                  Navigator.pop(context);
                },
                leading: Icon(Icons.image),
                title: Text("Gallery"),
              )
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.teal,
          title: Text("Community Chat"),
          centerTitle: true,
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  var messageData = messages[index];
                  bool isCurrentUser = messageData["Email"] == widget.userData["Email"];
                  String senderName = messageData["Name"];
                  bool isImage = messageData["isImage"];

                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 4, horizontal: 10),
                    child: Row(
                      mainAxisAlignment: isCurrentUser
                          ? MainAxisAlignment.end
                          : MainAxisAlignment.start,
                      children: [
                        if (!isCurrentUser)
                          CircleAvatar(
                            backgroundImage: AssetImage("assets/images/profile_pic.png"),
                            radius: 20,
                          ),
                        SizedBox(width: 8),
                        Column(
                          crossAxisAlignment:
                          isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                          children: [
                            if (!isCurrentUser)
                              Padding(
                                padding: EdgeInsets.only(bottom: 2),
                                child: Text(
                                  senderName,
                                  style: TextStyle(color: Colors.white70, fontSize: 13),
                                ),
                              ),
                            Container(
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: isCurrentUser
                                    ? Colors.teal.shade300
                                    : Colors.grey.shade800,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(15),
                                  topRight: Radius.circular(15),
                                  bottomLeft: isCurrentUser ? Radius.circular(15) : Radius.zero,
                                  bottomRight: isCurrentUser ? Radius.zero : Radius.circular(15),
                                ),
                              ),
                              child: isImage
                                  ? Image.file(
                                File(messageData["message"]),
                                height: 200,
                                width: 150,
                                fit: BoxFit.cover,
                              )
                                  : Text(
                                messageData["message"],
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(width: 8),
                        if (isCurrentUser)
                          CircleAvatar(
                            backgroundImage: AssetImage("assets/images/profile_pic.png"),
                            radius: 20,
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              color: Colors.grey.shade900,
              child: Row(
                children: [
                  IconButton(
                    onPressed: showAlertBox,
                    icon: Icon(Icons.camera_alt, color: Colors.white),
                  ),
                  Expanded(
                    child: TextField(
                      controller: messageController,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        hintStyle: TextStyle(color: Colors.white54),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: sendMessage,
                    icon: Icon(Icons.send, color: Colors.teal),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
