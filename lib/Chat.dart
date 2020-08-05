class ChatThread {
  final String otherId;
  final String lastTimestamp;
  final int num;
  final String name;

  ChatThread({this.otherId, this.name, this.lastTimestamp, this.num});

  static List<ChatThread> fromJSON(json) {
    List<ChatThread> list = new List();
    json.forEach((element) => list.add(ChatThread(
        otherId: element['uid'],
        name: element['name'],
        lastTimestamp: element['last_timestamp'],
        num: element['num']
    )));
    return list;
  }
}

class Message {
  final String name;
  final String content;
  final String timestamp;

  Message({this.name, this.content, this.timestamp});

  static List<Message> fromJSON(json, ChatThread chat) {
    List<Message> result = new List();
    json.forEach((element) => result.add(Message(
      name: element['uid'] == chat.otherId ? chat.name : null,
      content: element['text'],
      timestamp: element['timestamp'],
    )));
    return result;
  }
}