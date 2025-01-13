import 'package:chattingapp/models/chat_model.dart';
import 'package:chattingapp/widgets/message_widget.dart';
import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key}) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orangeAccent,
      bottomNavigationBar: _chatTextField(),
      body: Column(
        children: [
          const SizedBox(
            height: 60,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                const CircleAvatar(
                  backgroundColor: Colors.grey,
                  radius: 26,
                ),
                const SizedBox(width: 18),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "Parents Community",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),

                ),
              ),
              child: ListView.separated(itemBuilder: (context, index) =>MessageBubble(message: messages[index],) , separatorBuilder: (context, index) => SizedBox(height: 8,) , itemCount: messages.length ),
            ),
          ),
        ],
      ),
    );
  }Widget _chatTextField(){
    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(left: 20, right: 20, top: 10, bottom: MediaQuery.of(context).viewInsets.bottom + 14),
      child: Container(
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(40),
          color: Colors.grey,
        ),
        child: Row(
          children: const [
            Expanded(child: TextField(
              decoration: InputDecoration(
                border: InputBorder.none,
                    hintText: "Enter Your Message",
                hintStyle: TextStyle(fontSize: 15)
              ),
            )),

            CircleAvatar(
              backgroundColor: Colors.orangeAccent,
              child: const Icon(
                Icons.send,
                color: Colors.white,
              ),
            )
          ],
        ),
      ),
    );
  }
}
