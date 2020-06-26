import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chat/src/bloc/register_bloc/bloc.dart';
import 'package:chat/src/bloc/authentication_bloc/bloc.dart';
import 'package:chat/src/ui/register/register_button.dart';
import 'dart:async';
import 'dart:io';
import 'package:crypto/crypto.dart';  
import 'package:firebase_messaging/firebase_messaging.dart';

class RegisterForm extends StatefulWidget {
  @override
  _RegisterFormState createState() => _RegisterFormState();
}
class _RegisterFormState extends State<RegisterForm> {
  // Dos variables
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final  TextEditingController _lastnameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _celudaController = TextEditingController();
 bool passwordVisible;
  String tokenr;
  RegisterBloc _registerBloc;
 FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  bool get isPopulated =>
      _emailController.text.isNotEmpty && _passwordController.text.isNotEmpty;
  
  bool isRegisterButtonEnabled(RegisterState state) {
    return state.isFormValid && isPopulated && !state.isSubmitting;
  }
  initNotifications(){
    _firebaseMessaging.requestNotificationPermissions();
    _firebaseMessaging.getToken().then((token){
      print('TOKEN\n');
      print(token);
      tokenr=token;
    });
}
  @override
  void initState() {
    super.initState();
     passwordVisible = true;
    _registerBloc = BlocProvider.of<RegisterBloc>(context);
    _emailController.addListener(_onEmailChanged);
    _passwordController.addListener(_onPasswordChanged);
      initNotifications();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<RegisterBloc, RegisterState>(
      listener: (context, state) {
        // Si estado es submitting
        if (state.isSubmitting) {
          Scaffold.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text('Registrando datos'),
                    CircularProgressIndicator()
                  ],
                ),
              )
            );
        }
        // Si estado es success
        if (state.isSuccess) {
          BlocProvider.of<AuthenticationBloc>(context)
            .add(LoggedIn());
          Navigator.of(context).pop();
        }
        // Si estado es failure
        if (state.isFailure) {
          Scaffold.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text('Correo ya registrado '),
                  Icon(Icons.error)
                ],
              ),
              backgroundColor: Colors.red,
            )
          );
        }
      },
      child: BlocBuilder<RegisterBloc, RegisterState>(
        builder: (context, state) {
          return Container(
              child: Stack(
                children: <Widget>[
               
                            Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      color: Colors.redAccent,
                    ),
                    Container(
                     child: SingleChildScrollView(
                      child: Container(
                       child: formUI(state),
                     )
  
                  ),
                    ),
                          Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height*1/3.5,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              Colors.redAccent,
                           Colors.redAccent,
                            ],
                          ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top:MediaQuery.of(context).size.height*.4/3.5) ,
                         height: MediaQuery.of(context).size.height* 0.12,
                         width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          fit: BoxFit.contain,
                        image: new ExactAssetImage('assets/regi.png'),
                        ),
                      ),
                    ),
    Positioned(
               top: MediaQuery.of(context).size.height*0.91,
                left: 0.0,
                right: 0.0,
                child:   Container(
                  height: MediaQuery.of(context).size.width * 0.2,
                  width: MediaQuery.of(context).size.height,
                  decoration: BoxDecoration(
                  color: Colors.redAccent,
                 
                  ),
                 child: Center(
                   child: Text("Al acceder, usted acepta las politicas de\n  privacidad y los terminos del acuerdo",textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: MediaQuery.of(context).size.height * 0.018,
                    color: Colors.white,
                  ),
                ),
                 ),
           
            ),
          ),
                ],
           ), );
        },
      )
    );
  }

  Widget formUI(RegisterState state)
 {
   return Column(
       children : <Widget>[
          SizedBox(
            height: MediaQuery.of(context).size.height*0.9/3.5,
             ),
        Container(
             margin: EdgeInsets.only(left: MediaQuery.of(context).size.height*.03,right: MediaQuery.of(context).size.height*.03,
             top:MediaQuery.of(context).size.height*.1/3.5,),
            child: Column(
            children: <Widget>[
                 _nameField(state),
                  _apelidoField(state),
                 _telefonoField(state),
                  _emailField(state),
                    _passwordField(state),
               
    
            ]
          ),
          
        ),
        Container(
                 margin: EdgeInsets.only(left: MediaQuery.of(context).size.height*.10,right: MediaQuery.of(context).size.height*.10,
             top:MediaQuery.of(context).size.height*.1/3.5,),
             height: MediaQuery.of(context).size.width * 0.08,
                  width: MediaQuery.of(context).size.height*0.8/3.5,
                  decoration: BoxDecoration(
                
                  borderRadius: BorderRadius.circular(20.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 3,
                      blurRadius: 5,
                      offset: Offset(0, 1), 
                    ),
                  ],
                  ),
                  child: RegisterButton(
                      onPressed:
                     isRegisterButtonEnabled(state)
                       ? _onFormSubmitted: null, )
            ),
               SizedBox(
            height: MediaQuery.of(context).size.height*0.50/3.5,
             ),
       ]
   );

 }

   Widget _nameField(RegisterState state) {
    return TextFormField(
        keyboardType: TextInputType.text,
        controller: _nameController,
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.account_circle),
          //icon: Icon(Icons.account_circle),
          labelText: 'Nombre',
                  labelStyle: TextStyle(
                    fontSize: MediaQuery.of(context).size.height * 0.018,
                    color: Colors.white,
                    fontWeight: FontWeight.bold
                  ),
                ),
                style: TextStyle(
                  fontSize: MediaQuery.of(context).size.height * 0.018,
                 
                          
                              inherit: false,
                               textBaseline:
                               TextBaseline.alphabetic,
                                
                ),
        autocorrect: false,
        autovalidate: true,
       );
  }

    Widget _apelidoField(RegisterState state) {
    return TextFormField(
        keyboardType: TextInputType.text,
        controller: _lastnameController,
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.account_circle),
          
          labelText: 'Apellido',
                  labelStyle: TextStyle(
                    fontSize: MediaQuery.of(context).size.height * 0.018,
                    color: Colors.white,
                    fontWeight: FontWeight.bold
                  ),
                ),
                style: TextStyle(
                  fontSize: MediaQuery.of(context).size.height * 0.018,
                  
                           
                              inherit: false,
                               textBaseline:
                               TextBaseline.alphabetic,
                                
                ),
        autocorrect: false,
        autovalidate: true,
       );
  }
  Widget _telefonoField(RegisterState state) {
    return TextFormField(
        keyboardType: TextInputType.text,
        controller: _phoneController,
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.account_circle),
          //icon: Icon(Icons.account_circle),
          labelText: 'Teléfono',
                  labelStyle: TextStyle(
                    fontSize: MediaQuery.of(context).size.height * 0.018,
                    color: Colors.white,
                    fontWeight: FontWeight.bold
                  ),
                ),
                style: TextStyle(
                  fontSize: MediaQuery.of(context).size.height * 0.018,
                 
                           
                              inherit: false,
                               textBaseline:
                               TextBaseline.alphabetic,
                                
                ),
        autocorrect: false,
        autovalidate: true,
      );
  }

  Widget _emailField(RegisterState state) {
    return TextFormField(
      keyboardType: TextInputType.emailAddress,
      controller: _emailController,
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.email),
        labelText: 'Correo',
           labelStyle: TextStyle(
            fontSize: MediaQuery.of(context).size.height * 0.018,
                    color: Colors.white,
                    fontWeight: FontWeight.bold
                  ),
                ),
                style: TextStyle(
                  fontSize: MediaQuery.of(context).size.height * 0.018,
                 
                              inherit: false,
                               textBaseline:
                               TextBaseline.alphabetic,
                          
                ),
      autocorrect: false,
      autovalidate: true,
      validator: (_) {
        return !state.isEmailValid ? '\t\t\t\t\t\t         \t Correo inválido\n' : null;
      },
    );
  }

  

  Widget _passwordField(RegisterState state) {
    return TextFormField(
      keyboardType: TextInputType.visiblePassword,
      controller: _passwordController,
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.lock),
        labelText: 'Contraseña',
           labelStyle: TextStyle(
                     fontSize: MediaQuery.of(context).size.height * 0.018,
                 
                         inherit: false,
                    fontWeight: FontWeight.bold
                  ),
        suffixIcon: IconButton(
          icon: Icon(
            passwordVisible ? Icons.visibility : Icons.visibility_off,
            color: Colors.white,
          ),
          onPressed: () {
            setState(() {
              passwordVisible = !passwordVisible;
            });
          },
        ),
      ),
       style: TextStyle(
                   fontSize: MediaQuery.of(context).size.height * 0.018,
                 
                              inherit: false,
                               textBaseline:
                               TextBaseline.alphabetic,
                                
                ),
      obscureText: passwordVisible,
      autocorrect: false,
      autovalidate: true,
      validator: (_) {
        return !state.isPasswordValid
            ? '\t\t\t\t\t\t         \tMinimo 8 caracteres, debe incluir numeros y letras\n'
            : null;
      },
    );
  }

  void _onEmailChanged() {
    _registerBloc.add(
      EmailChanged(email: _emailController.text)
    );
  }

  void _onPasswordChanged() {
    _registerBloc.add(
      PasswordChanged(password: _passwordController.text)
    );
  }

  String encryp(String password)
  {
    var bytes = utf8.encode(password);
    Digest sha256Result = sha256.convert(bytes);
     return sha256Result.toString();
  }
  void _onFormSubmitted() {
    _registerBloc.add(
      Submitted(
        name: _nameController.text,
        email: _emailController.text,
        password: encryp(_passwordController.text),
        phone: _phoneController.text,
        lastname: _lastnameController.text,
        token:tokenr
      )
    );
  }
}
