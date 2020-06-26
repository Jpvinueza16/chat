import 'package:chat/mensaje.dart';
import 'package:chat/src/ui/commonComponents/customCard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chat/src/bloc/authentication_bloc/bloc.dart';

class HomeScreen extends StatelessWidget {
  final String ui;

  HomeScreen({Key key, @required this.ui}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Elige usuario para chatear'),
        backgroundColor: Colors.redAccent.shade100,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () {
              BlocProvider.of<AuthenticationBloc>(context).add(LoggedOut());
            },
          )
        ],
      ),
     body: Center(
        child: Container(

          color: Colors.brown.shade100,
            padding: const EdgeInsets.all(20.0),
            child: StreamBuilder<QuerySnapshot>(
              stream: Firestore.instance
                  .collection("users")
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError)
                  return new Text('Error: ${snapshot.error}');
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                    return new Text('Loading...');
                  default:
                    return new ListView(  
                      children: snapshot.data.documents
                          .map((DocumentSnapshot document) {
                        return new CustomCard(
                          name: document['name'],
                          token: document['token'],
                          keypublic:document['pubkey'],
                          ui: ui,
                          lastname: document['lastname'],
                        );
                      }).toList(),
                    );
                }
              },
            )),
      ),
    );
  }
}