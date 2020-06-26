import 'package:chat/mensaje.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CustomCard extends StatelessWidget {
  CustomCard({@required this.name, this.token, this.keypublic, this.ui, this.lastname,});

  final name;
  final token;
  final keypublic;
  final ui;
  final lastname;
  
  @override
  Widget build(BuildContext context) {
    return Card(
        child: Container(
          color: Colors.indigo.shade50,
            padding: const EdgeInsets.only(top: 5.0),
            child: Column(
              children: <Widget>[
                Text(name+" "+lastname,
                 overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: MediaQuery.of(context).size.height * 0.018,
                    color: Colors.black,
                  ),),
            
                    FlatButton.icon(
                  color: Colors.blueGrey.shade100,
                  icon: Icon(Icons.chat), 
                  label: Text('Enviar Mensaje'), 
                  onPressed: () {
                      
                        Firestore.instance
                                .collection("users")
                                .document(ui)
                                .get()
                                .then((DocumentSnapshot result) =>
                                    Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => MyHomePage1(
                                                   nombre: name+" "+lastname, token: token,pubkey:keypublic,privKey: result['prikey'] ,ui:ui,name:result['name']+" "+result['lastname'],
                                                ))))
                                .catchError((err) => print(err))
                            .catchError((err) => print(err));
                    }
        ),
              ],
            )));
  }
}
