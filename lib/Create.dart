import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'session.dart';
import 'dart:convert';
import 'GlobalDetails.dart';
import 'ChatDetailPage.dart';
import 'Chat.dart';

class Create extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Create Conversation"),
        backgroundColor: Colors.teal,
        leading: new IconButton(
          icon: Icon(Icons.home),
          onPressed: () {
            Navigator.pop(context);
          }
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(24.0),
        child: CreateForm()
      ),
    );
  }
}

class CreateForm extends StatefulWidget {
  @override
  CreateFormState createState() => new CreateFormState();
}

class CreateFormState extends State<CreateForm>{
  final url = ServerDetails.server + "AutoCompleteUser";
  final chatUrl = ServerDetails.server + "CreateConversation";

  @override
  Widget build(BuildContext context) {
    return TypeAheadField(
      textFieldConfiguration: TextFieldConfiguration(
        autofocus: true,
//        style: DefaultTextStyle.of(context).style.copyWith(
//          fontStyle: FontStyle.italic
//        ),
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0)
          ),
//          color: Colors.white,
//          border: Border.all(color: Colors.black26),
//          borderRadius: BorderRadius.circular(16.0),
          hintText: 'Search for user ...',
          contentPadding: EdgeInsets.fromLTRB(12.0, 10.0, 6.0, 10.0),
        ),
      ),
      suggestionsCallback: (pattern) async {
        final data = {"term" : pattern};
        final response = await Session().post(url, data);
        var jsonResponse = json.decode(response);
        jsonResponse.removeWhere((element) => element['value'] == User.getUid());
        return jsonResponse;
      },
      itemBuilder: (context, suggestion){
//        print(suggestion['value']);
//        print(User.getUid());
        List<String> sug = suggestion['label'].split(",");
        String _name = sug[1].trim().substring(6);
        String _uidphone = sug[0] + ',' + sug[2];
        return ListTile(
          title: Text(_name),
          subtitle: Text(_uidphone),
        );
      },
      onSuggestionSelected: (suggestion){
        var data = {"other_id" : suggestion['value']};
        Session().post(chatUrl, data).then((response){
          var jsonResponse = json.decode(response);
          if(jsonResponse['status']){
            ChatThread chat = new ChatThread(
              otherId: suggestion['value'],
              name: suggestion['label'].split(",")[1].trim().substring(6),
              lastTimestamp: null,
              num: 0
            );
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => new ChatDetailPage(chat: chat)
              )
            );
          }
          else{
            ChatThread chat = new ChatThread(
                otherId: suggestion['value'],
                name: suggestion['label'].split(",")[1].trim().substring(6),
                lastTimestamp: null,
                num: null
            );
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => new ChatDetailPage(chat: chat)
              )
            );
          }
        });
      },
    );
  }
}