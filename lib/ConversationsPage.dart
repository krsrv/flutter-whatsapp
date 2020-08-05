import 'package:flutter/material.dart';
import 'session.dart';
import 'dart:convert';
import 'dart:async';
import 'GlobalDetails.dart';
import 'ChatDetailPage.dart';
import 'Chat.dart';
import 'Create.dart';

class ConversationsPage extends StatefulWidget {
  @override
  _ConversationState createState() => new _ConversationState();
}

class _ConversationState extends State<ConversationsPage> {
  final url = ServerDetails.server + "AllConversations";

  bool _loading, _searching;
  List<ChatThread> _list, _queryResult;

  Session session = new Session();

  @override
  void initState() {
    super.initState();
    _loading = true;
    _searching = false;
    _queryResult = null;
    refresh();
  }

  Future<void> refresh() async {
    var response = await session.post(url, null);
    final jsonResponse = json.decode(response);
    if (jsonResponse['status'])
      setState(() {
        _list = ChatThread.fromJSON(jsonResponse['data']);
        _loading = false;
      });
    else
      throw Exception('Failed to load response');
  }

  @override
  Widget build(BuildContext context) {
    final list = RefreshIndicator(
        child: ChatsList(_loading, _list),
        onRefresh: refresh,
        color: Colors.teal,
    );
    if(_searching) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: TextField(
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: 'Search ...',
            ),
            cursorColor: Colors.teal,
            autofocus: true,
            onChanged: (text) {
              text = text.trim().toLowerCase();
              if(text.isEmpty)
                setState(() {
                  _queryResult = null;
                });
              else {
                setState(() {
                  _queryResult = new List();
                  _list.forEach((element) {
                    if(element.name.toLowerCase().contains(text) || element.otherId.toLowerCase().contains(text))
                      _queryResult.add(element);
                  });
                });
              }
            },
          ),
          leading: IconButton(
              icon: Icon(Icons.clear),
              color: Colors.teal,
              onPressed: () {
                setState(() {
                  _searching = false;
                  _queryResult = null;
                });
              },
          ),
        ),
        body: _queryResult == null ? list : ListView.builder(
            itemBuilder: (BuildContext context, int index) {
              return ChatTile(_queryResult[index]);
            },
            itemCount: _queryResult.length,
        ),
      );
    }
    else {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.teal,
          title: Text("Chats"),
          leading: Icon(Icons.home),
          actions: <Widget>[
            // Search Button
            IconButton(
                icon: Icon(Icons.search),
                onPressed: () {
                  setState(() {
                    _searching = true;
                  });
                }
            ),

            // Create Conversation
            IconButton(
                icon: Icon(Icons.create),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Create()));
                }),

            // Logout Button
            IconButton(
                icon: Icon(Icons.exit_to_app),
                onPressed: () {
                  Session()
                      .post(ServerDetails.server + "LogoutServlet", null)
                      .then((response) {
                    User.setUid(null);
                    Navigator.of(context).pushReplacementNamed("/login");
                  });
                }),
          ],
        ),
        body: list,
      );
    }
  }
}

class ChatsList extends StatelessWidget {
  /* Associated conversation URL to get list of all conversations */
  final bool loading;
  List<ChatThread> list;

  ChatsList(this.loading, this.list);

  @override
  Widget build(BuildContext context) {
    if (loading)
      return new Center(
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new Padding(
              padding: new EdgeInsets.all(8.0),
              child: new CircularProgressIndicator(),
            ),
            new Padding(
              padding: new EdgeInsets.all(8.0),
              child: new Text("Loading ..."),
            ),
          ],
        )
      );
    else
      return ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        itemBuilder: (BuildContext context, int index) {
          return ChatTile(list[index]);
        },
        itemCount: list.length,
      );
  }
}

class ChatTile extends StatelessWidget {
  final ChatThread chat;
  ChatTile(this.chat);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.person),
      title: Text(chat.name),
      subtitle: chat.lastTimestamp == null
          ? Text('No messages')
          : Text(chat.lastTimestamp
              .substring(0, chat.lastTimestamp.lastIndexOf(":"))),
      trailing: Text(chat.otherId),
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => new ChatDetailPage(chat: chat)));
      },
    );
  }
}
