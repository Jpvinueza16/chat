import 'dart:convert';

import 'package:chat/main.dart';
import 'package:chat/src/repository/user_repository.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'package:convert/convert.dart';
import 'dart:convert';
import 'package:encrypt/encrypt.dart';
import 'package:flutter_aes_ecb_pkcs5/flutter_aes_ecb_pkcs5.dart';
import 'package:chat/src/ui/home_screen.dart';
import 'package:rsa_util/rsa_util.dart';
  
class MyHomePage1 extends StatefulWidget {
  
  MyHomePage1({ this.nombre, this.token, this.pubkey, this.privKey, this.ui, this.name}) ;
  final String nombre;
  final String token;
  final String pubkey;
 final String privKey;
 final ui;
 final String name;
  @override
  _MyHomePage1State createState() => _MyHomePage1State();
}

class _MyHomePage1State extends State<MyHomePage1> {
  final List<ChatMessage> _messages = <ChatMessage>[];
  final TextEditingController _textController = new TextEditingController();
    final UserRepository userRepository = UserRepository();
  var mymap = {};
  var title = '';
  var body = {};
  var mytoken = '';
  String datos="1";
  int n=1;
  FirebaseMessaging firebaseMessaging = new FirebaseMessaging();
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
  String validar="";
  @override
  void initState() {    
    super.initState();
  
     print("===========================================");
     print("Nombre del receptor " +widget.nombre);
     print("Llave privada del emisor " +widget.privKey);
     print("Llave publica del receptor " +widget.pubkey);
     print("Token del mensaje"+widget.token);
    print("============================================");
    var android = new AndroidInitializationSettings('mipmap/ic_launcher');
    var ios =IOSInitializationSettings();
    var platform = new InitializationSettings(android, ios);
    flutterLocalNotificationsPlugin.initialize(platform);

    firebaseMessaging.configure(onLaunch: (Map<String, dynamic> msg){
        mymap = msg;
      datos=datos+msg.toString();
      showNotification(msg);
    }, onResume: (Map<String, dynamic>msg ){
      mymap = msg;
      datos=datos+msg.toString();
      showNotification(msg);
    }, onMessage: (Map<String, dynamic>msg ){
      mymap = msg;
      datos=datos+msg.toString();
        if(n==1){
        Response(msg['data']['SMS'] ,msg['data']['key']);
        n=0;
        }
        else{
          n=1;
        }
      showNotification(msg);
    });

    firebaseMessaging.requestNotificationPermissions(
      const IosNotificationSettings(sound: true, alert: true, badge: true));
    firebaseMessaging.onIosSettingsRegistered.listen((IosNotificationSettings setting) {
      print("onIosSettingRegistered");
    });
    firebaseMessaging.getToken().then((token){
      update(token);
    });
  }

  showNotification(Map<String, dynamic> msg) async {
    var android = new AndroidNotificationDetails(
        "1", "channelName", "channelDescription");
    var iOS = new IOSNotificationDetails();
    var platform = new NotificationDetails(android, iOS);

    //key and value
    msg.forEach((k, v) {
      title = k;
      body = v;
      setState(() {});
    });

    await flutterLocalNotificationsPlugin.show(0, "${body.keys}", "${body.values}", platform);
  }

  update(String token) {
    print(token);
    DatabaseReference databaseReference = new FirebaseDatabase().reference();
  //  databaseReference.child('fcm-token/$token').set({"token": token});
    mytoken = token;
    setState(() {});
  }

  sendFcmMessage(String d) async {
    try {
      print("===================Envio de mensaje encryp===============================");
     //===========================Simetrico ==================================================
     
     var key = await FlutterAesEcbPkcs5.generateDesKey(128);//Clave simetrica
     var encryptText = await FlutterAesEcbPkcs5.encryptString(d, key);  //Encripta en mensaje
      print("===========================Simetrico=======================");
      print("Llave de simetrica :: "+key);
      print("Mensaje encriptado :: "+encryptText);
      //=====================================================================================
      //===========================ASimetrico ==================================================
        RSAUtil rsa = RSAUtil.getInstance(widget.pubkey, widget.privKey);//Instnancia de las claves
        var llave = rsa.encryptByPublicKey(key);//Encripta la llave
        print("===========================ASimetrico=======================");
        print("Llave de Encriptada Asimetrica :: "+llave);
      //=====================================================================================


      var url = 'https://fcm.googleapis.com/fcm/send';
      var header = {
        "Content-Type": "application/json",
        "Authorization":
            "key=AAAAPtahdXs:APA91bGxwK2StnduhF8kyUTeMtj9Fq45_xSpFvueMq_QdLN8XilCefFQZWWHN14OjExzFXmSoMDLcZ_PfSOvGDZCKpWWMqO8er3ThB7Hu80KXXhK_HjY3GTOH6yBTtqJHGkuC3-CAmqh",
      };
      var request = { 
        "to": widget.token,
          "notification": {"title": "Mensaje", "body": "Leer"},
        "data": {
          "SMS": encryptText, 
          "key":llave
        }
      };
      var client = new http.Client();
      var response =
          await client.post(url, headers: header, body: json.encode(request));
      print(response.body);
      if (response.statusCode == 200) {
       
      }
      return true;
    } catch (e, s) {
      print(e);
      return false;
    }
  }
  Widget _buildTextComposer() {
    return new IconTheme(
      data: new IconThemeData(color: Theme.of(context).accentColor),
      child: new Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        child: new Row(
          children: <Widget>[
            new Flexible(
              child: new TextField(
                controller: _textController,
                onSubmitted: _handleSubmitted,
                decoration:
                new InputDecoration.collapsed(hintText: "   "),
              ),
            ),
            new Container(
              margin: new EdgeInsets.symmetric(horizontal: 4.0),
              child: new IconButton(
                  icon: new Icon(Icons.send,color: Colors.redAccent,),
                  onPressed: () {
                    sendFcmMessage(_textController.text.toString());
                    _handleSubmitted(_textController.text);
                  }
                  ),
            ),
          ],
        ),
      ),
    );
  }
  void Response(query, key1) async {
    _textController.clear();
    print("====================Mensajes resividos======================================");
    print("Mensaje :: "+ query);
    print("Llave :: "+ key1);
    print("===================Desencriptacion de mensaje ===============================");
    RSAUtil rsa = RSAUtil.getInstance(widget.pubkey, widget.privKey);//intancias de las llaves
     var llave = rsa.decryptByPrivateKey(key1);//desencriptado de la llave 
     var decryptText  = await FlutterAesEcbPkcs5.decryptString(query, llave);// desifrado de la llave simetrico
     print("=====================Desifrado=========================");
     print("Llave simetrica desencriptada :: "+llave);
     print("Mensaje resivisdo desencriptado :: " +decryptText);
    ChatMessage message = new ChatMessage(
      text: decryptText,
      name: widget.nombre,
      type: false,
    );
    setState(() {
      _messages.insert(0, message);
    });
  }

  void _handleSubmitted(String text) {
    _textController.clear();
    ChatMessage message = new ChatMessage(
      text: text,
      name: widget.name,
      type: true,
    );
    setState(() {
      _messages.insert(0, message);
    });
  
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        backgroundColor: Colors.redAccent.shade100,
       title:  new Text("Chat"),
       leading: new IconButton(
  icon: new Icon(Icons.arrow_back, color: Colors.white),
  onPressed: () {

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => App(userRepository: userRepository,)),
  );
}
), 
     centerTitle: true,
    
      
      ),
      body: new Column(children: <Widget>[
        new Flexible(
            child: new ListView.builder(
              padding: new EdgeInsets.all(8.0),
              reverse: true,
              itemBuilder: (_, int index) => _messages[index],
              itemCount: _messages.length,
            )),
        new Divider(height: 1.0),
        new Container(
          decoration: new BoxDecoration(color: Theme.of(context).cardColor),
          child: _buildTextComposer(),
        ),
      ]),
    );
  }
}

class ChatMessage extends StatelessWidget {
  ChatMessage({this.text, this.name, this.type});

  final String text;
  final String name;
  final bool type;

  List<Widget> otherMessage(context) {
    return <Widget>[
      new Container(
        margin: const EdgeInsets.only(right: 16.0),
        child: new CircleAvatar(),
      ),
      new Expanded(
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            new Text(this.name, style:new TextStyle(fontWeight:FontWeight.bold )),
            new Container(
              margin: const EdgeInsets.only(top: 5.0),
              child: new Text(text),
            ),
          ],
        ),
      ),
    ];
  }

  List<Widget> myMessage(context) {
    return <Widget>[
      new Expanded(
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            new Text(this.name, style: Theme.of(context).textTheme.subhead),
            new Container(
              margin: const EdgeInsets.only(top: 5.0),
              child: new Text(text),
            ),
          ],
        ),
      ),
      new Container(
        margin: const EdgeInsets.only(left: 16.0),
        child: new CircleAvatar(child: new Text(this.name[0])),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      child: new Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: this.type ? myMessage(context) : otherMessage(context),
      ),
    );
  }

}