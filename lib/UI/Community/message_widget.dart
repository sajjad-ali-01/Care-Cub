import 'package:flutter/material.dart';

import 'chat_model.dart';

class MessageBubble extends StatefulWidget {
  final Message message;
  const MessageBubble({super.key, required this.message});

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> {
  bool showtimeS = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Align(
        alignment: widget.message.received ? Alignment.centerLeft : Alignment.centerRight,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            GestureDetector(
              onTap: (){
                setState(() {
                  showtimeS=!showtimeS;
                });
              },

            child : Container(
              width: 300,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: widget.message.received ? Colors.grey : Colors.orangeAccent,
              ),
              child:  Text(widget.message.text,
                style: TextStyle(
                  fontSize: 18,
                  height: 1.4,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ),
            const SizedBox(height: 8),
            if (showtimeS)
               Padding(
                padding: EdgeInsets.only(right: 12),
                child: Text(widget.message.timeStamp,
                  style: TextStyle(
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
