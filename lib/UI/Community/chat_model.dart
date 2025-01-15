class Message{
  final int id;
  final String text;
  final bool received;
  final String timeStamp;

  Message({required this.id, required this.text, required this.received, required this.timeStamp});
}

List<Message> messages = [
  Message(
    id: 0,
    received: false,
    text: "Hi everyone, new parent here! Any tips for managing baby sleep schedules?",
    timeStamp: '9:00 am',
  ),
  Message(
    id: 1,
    received: true,
    text: "Welcome! Try maintaining a consistent bedtime routine. It works wonders!",
    timeStamp: '9:05 am',
  ),
  Message(
    id: 2,
    received: false,
    text: "Thanks! Also, any recommendations for teething remedies?",
    timeStamp: '9:10 am',
  ),
  Message(
    id: 3,
    received: true,
    text: "Cold teething rings helped my little one a lot. You can also try a chilled cloth.",
    timeStamp: '9:15 am',
  ),
  Message(
    id: 4,
    received: false,
    text: "That’s helpful! How about recommendations for nutritious baby food?",
    timeStamp: '9:20 am',
  ),
  Message(
    id: 5,
    received: true,
    text: "Start with mashed fruits like bananas or avocado. Homemade purees are great too!",
    timeStamp: '9:25 am',
  ),
  Message(
    id: 6,
    received: false,
    text: "Awesome suggestions! What about advice for colic or fussy babies?",
    timeStamp: '9:30 am',
  ),
  Message(
    id: 7,
    received: true,
    text: "Try gentle tummy massages and a warm bath. Also, keep the baby upright after feeding.",
    timeStamp: '9:35 am',
  ),
];
