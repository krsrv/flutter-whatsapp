import 'package:flutter/material.dart';
import 'session.dart';
import 'dart:convert';
import 'GlobalDetails.dart';
import 'dart:async';
import 'Chat.dart';

class ChatDetailPage extends StatelessWidget {
  final ChatThread chat;

  ChatDetailPage({Key key, @required this.chat}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new WillPopScope(
        child: Scaffold(
          appBar: _buildBar(context),
          body: new Container(
            decoration: BoxDecoration(color: Colors.black12),
            child: Padding(
              padding: EdgeInsets.fromLTRB(8.0, 6.0, 8.0, 4.0),
              child: ChatScreen(chat: chat),
            ),
          ),
        ),
        onWillPop: () async {
          Navigator.of(context)
              .pushNamedAndRemoveUntil('/chats', (route) => false);
          return false;
        });
  }

  Widget _buildBar(BuildContext context) {
    return new AppBar(
//      centerTitle: true,
      backgroundColor: Colors.teal,
      title: Text(chat.name),
      leading: new IconButton(
          icon: Icon(Icons.home),
          onPressed: () {
            Navigator.of(context)
                .pushNamedAndRemoveUntil('/chats', (route) => false);
          }),
//      leading: new IconButton(
//        icon: Icon(Icons.chat),
////        onPressed: _searchPressed,
//
//      ),
    );
  }
}

class ChatScreen extends StatefulWidget {
  final ChatThread chat;
  ChatScreen({Key key, @required this.chat}) : super(key: key);

  @override
  ChatScreenState createState() => new ChatScreenState(chat);
}

class ChatScreenState extends State<ChatScreen> {
  final ChatThread chat;
  List<Message> _list;
  final String url = ServerDetails.server + "ConversationDetail";
  final String urlmsg = ServerDetails.server + "NewMessage";

  Session session = new Session();

  ChatScreenState(this.chat);

  final messageControl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _request();
  }

  Future<void> _request() async {
    var response = await session.post(url, {"other_id": chat.otherId});
    final jsonResponse = json.decode(response);
    if (jsonResponse['status']) {
      setState(() {
        _list = Message.fromJSON(jsonResponse['data'], chat);
      });
    } else
      throw Exception('Failed to load response');
  }

  @override
  Widget build(BuildContext context) {
    if (_list == null)
      return new Center(
        child: new CircularProgressIndicator(),
      );
    else {
      final widgets = _list.map((element) {
        return chatBubble(element, context);
      });
      final input = Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.black26),
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: TextFormField(
          controller: messageControl,
          autofocus: false,
          keyboardType: TextInputType.multiline,
          maxLines: null,
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: 'Type a Message ...',
            contentPadding: EdgeInsets.fromLTRB(12.0, 10.0, 6.0, 10.0),
          ),
        ),
      );

      return Column(
            children: <Widget>[
              Expanded(
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                      reverse: true,
                      child: new Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: widgets.toList(),
                      ))),
              Padding(
                  padding: EdgeInsets.only(top: 10.0),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: input,
                      ),
                      Container(
                          child: IconButton(
                              alignment: Alignment.centerRight,
                              icon: Icon(Icons.send),
                              color: Colors.teal,
                              onPressed: () {
                                var ms = messageControl.text;
                                if (ms.trim().isNotEmpty) {
                                  var data = {
                                    "other_id": chat.otherId,
                                    "msg": ms
                                  };
                                  session.post(urlmsg, data).then((response) {
                                    final resp = json.decode(response);
                                    if (resp['status']) {
                                      _request();
                                      messageControl.clear();
                                    }
                                  });
                                }
                              }))
                    ],
                  )),
            ],
          );
    }
  }

  /* Reference: https://stackoverflow.com/questions/49098856/how-to-create-speech-bubbles-for-text-in-flutter-whatsapp-ui */
  Widget chatBubble(Message msg, BuildContext context) {
    final alignment =
        msg.name == null ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final border = msg.name == null
        ? BorderRadius.only(
            topRight: Radius.circular(5.0),
            topLeft: Radius.circular(10.0),
            bottomLeft: Radius.circular(10.0))
        : BorderRadius.only(
            topRight: Radius.circular(10.0),
            bottomLeft: Radius.circular(5.0),
            bottomRight: Radius.circular(10.0));
    final color = msg.name == null ? Colors.greenAccent[100] : Colors.white;

    return Column(
      crossAxisAlignment: alignment,
      children: <Widget>[
        Container(
          margin: const EdgeInsets.all(6.0),
          padding: const EdgeInsets.all(8.0),
          constraints:
              BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
          decoration: BoxDecoration(boxShadow: [
            BoxShadow(
                blurRadius: 0.5,
                spreadRadius: 1.0,
                color: Colors.black.withOpacity(0.12))
          ], color: color, borderRadius: border),
          child: Stack(children: <Widget>[
            Padding(
              padding: EdgeInsets.only(right: 48.0),
              child: Text(msg.content),
            ),
            Positioned(
                right: 0.0,
                top: 0.0,
                child: Column(children: <Widget>[
                  Text(msg.timestamp.split(" ")[0].substring(2),
                      style: TextStyle(fontSize: 8.0, color: Colors.blueGrey)),
                  Text(msg.timestamp.split(" ")[1].substring(0, 5),
                      style: TextStyle(fontSize: 8.0, color: Colors.blueGrey))
                ]))
          ]),
        )
      ],
    );
  }
}
