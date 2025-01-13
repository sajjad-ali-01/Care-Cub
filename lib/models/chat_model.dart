class Message{
  final int id;
  final String text;
  final bool received;
  final String timeStamp;

  Message({required this.id, required this.text, required this.received, required this.timeStamp});
}

List<Message> messages = [
  Message(
    id : 0,
    received: false,
    text: "hi",
    timeStamp: '10:05 pm'
  ),
  Message(
      id : 1,
      received: true,
      text: "hi,Kalu ",
      timeStamp: '10:07 pm'
  ),
  Message(
      id : 2,
      received: false,
      text: "You are so handsome",
      timeStamp: '10:09 pm'
  ),
  Message(
      id : 3,
      received: true,
      text: "How you are so hot??",
      timeStamp: '10:10 pm'
  ),
  Message(
      id : 4,
      received: false,
      text: "Apki beauty ka raaz kya ha ",
      timeStamp: '10:12 pm'
  ),
  Message(
      id : 5,
      received: true,
      text: "Naley mey to nai nahatey",
      timeStamp: '10:14 pm'
  ),
  Message(
      id : 6,
      received: false,
      text: "kya apkey sabun mey saaf krny waley chemical nai hein agr hein to wo asar q nai krty ya phir ap nahatey nai hein  ",
      timeStamp: '10:15 pm'
  ),
  Message(
      id : 7,
      received: true,
      text: "kya apkey sabun mey saaf krny waley chemical nai hein agr hein to wo asar q nai krty ya phir ap nahatey nai hein  ",
      timeStamp: '10:15 pm'
  ),
];