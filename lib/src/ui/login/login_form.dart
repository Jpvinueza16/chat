import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chat/src/bloc/login_bloc/bloc.dart';
import 'package:chat/src/bloc/authentication_bloc/bloc.dart';
import 'package:chat/src/repository/user_repository.dart';
import 'package:chat/src/ui/login/create_account_button.dart';
import 'package:chat/src/ui/login/google_login_button.dart';
import 'package:chat/src/ui/login/login_button.dart';
import 'dart:async';
import 'dart:io';
import 'package:crypto/crypto.dart';  
import 'package:chat/src/ui/register/register_screen.dart';


class LoginForm extends StatefulWidget {
  final UserRepository _userRepository;

  LoginForm({Key key, @required UserRepository userRepository})
      : assert(userRepository != null),
        _userRepository = userRepository,
        super(key: key);

  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool passwordVisible;
  LoginBloc _loginBloc;

  UserRepository get _userRepository => widget._userRepository;

  bool get isPopulated =>
      _emailController.text.isNotEmpty && _passwordController.text.isNotEmpty;

  bool isLoginButtonEnabled(LoginState state) {
    return state.isFormValid && isPopulated && !state.isSubmitting;
  }

  @override
  void initState() {
    super.initState();
    passwordVisible = true;
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(statusBarColor:   Colors.redAccent.shade100,statusBarIconBrightness: Brightness.dark));
    _loginBloc = BlocProvider.of<LoginBloc>(context);
    _emailController.addListener(_onEmailChanged);
    _passwordController.addListener(_onPasswordChanged);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginBloc, LoginState>(listener: (context, state) {
      // tres casos, tres if:
      if (state.isFailure) {
        Scaffold.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [Text('Error verifique los datos'), Icon(Icons.error)],
              ),
              backgroundColor: Colors.red,
            ),
          );
      }
      if (state.isSubmitting) {
        Scaffold.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(
            content: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text('Verificando ingreso... '),
                CircularProgressIndicator(),
              ],
            ),
          ));
      }
      if (state.isSuccess) {
        BlocProvider.of<AuthenticationBloc>(context).add(LoggedIn());
      }
    }, child: BlocBuilder<LoginBloc, LoginState>(
      builder: (context, state) {
  return Container(
                child: Stack(
                  children: <Widget>[
              
                           Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      color: Colors.white,
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
                      height: MediaQuery.of(context).size.height*1.15/3.5,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                                  Colors.redAccent.shade100,
                                 Colors.redAccent.shade100,
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
                        image: new ExactAssetImage('assets/se.png'),
                        ),
                      ),
                    ),
               Positioned(
               top: MediaQuery.of(context).size.height*0.3,
              
                child:   Container(
                  height: MediaQuery.of(context).size.height* 0.05,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(58.0),
               
               
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
                  color:      Colors.redAccent.shade100,
                  
                 
                  ),
                 child: Center(
                   child: Text("Al acceder, usted acepta las politicas de\n  privacidad y los terminos del acuerdo",textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  fontSize: MediaQuery.of(context).size.width *0.03,
                    color: Colors.white,
                  ),
                ),
                 ),
           
            ),
          ),
               
                 
                  ],
                ),
              );
      },
    ));
  }
 Widget formUI(LoginState state)
  {
    return Column(
      children : <Widget>[
             SizedBox(
            height: MediaQuery.of(context).size.height*1.2/3.5,
             ),
        
          Card(
          margin: EdgeInsets.only(left: MediaQuery.of(context).size.height*.03,right: MediaQuery.of(context).size.height*.03,
             ),
            
           shape: RoundedRectangleBorder( 
            borderRadius: BorderRadius.circular(15.0),

            ),
            child: Column(
          
            children: <Widget>[
              TextFormField(
                keyboardType:TextInputType.emailAddress,
                controller: _emailController,
                decoration: new InputDecoration(
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.receipt,color:Colors.black,),
                  labelText: 'Correo Electrónico',
                  labelStyle: TextStyle(
                   fontSize: MediaQuery.of(context).size.height * 0.018,
                 
                    color: Colors.black,
                    fontWeight: FontWeight.bold
                  ),
                ),
                style: TextStyle(
                  fontSize: MediaQuery.of(context).size.height * 0.018,
                  
                               textBaseline:
                               TextBaseline.alphabetic,
                               
                ),
                autocorrect: false,
                autovalidate: true,
                validator: (_) {
                  return !state.isEmailValid
                      ? '\t\t\t\t\t\t         \t Correo inválido\n'
                      : null;
                },
              ),
         
               Divider(
                indent: 20,
                endIndent: 20,
                height: 1,
              ),
             TextFormField(
                 controller: _passwordController,
                decoration: new InputDecoration(
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.home, color: Colors.black,),
                  labelText: 'Contraseña',
                  labelStyle: TextStyle(
                    fontSize: MediaQuery.of(context).size.height * 0.018,
                    color: Colors.black,
                         inherit: false,
                   fontWeight: FontWeight.bold
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                    passwordVisible
                     ? Icons.visibility
                      : Icons.visibility_off,
                      color: Colors.black,
                      size: MediaQuery.of(context).size.width * 0.05,
                                                ),
                                                onPressed: () {
                                                  setState(() {
                                                    passwordVisible =
                                                        !passwordVisible;
                                                  });
                                                },
                                              ),
                ),
                style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width * 0.03,
                     
                       
                               textBaseline:
                               TextBaseline.alphabetic,
                               
                                ),
                               obscureText: passwordVisible,
                                            autovalidate: true,
                                            autocorrect: false,
                                         validator: (_) {
                                              return !state.isPasswordValid
                                                  ? '\t\t\t\t\t\t         \t Contraseña inválido\n'
                                                  : null;
                                            },
              ),
              
            ]
          ),
          
        ),
    
     
        Container(
          margin: EdgeInsets.only(left: MediaQuery.of(context).size.height*.10,right: MediaQuery.of(context).size.height*.10,
             top:MediaQuery.of(context).size.height*.1/3.5,),
             height: MediaQuery.of(context).size.width * 0.08,
                  width: MediaQuery.of(context).size.height*0.8/3.5,
                  decoration: BoxDecoration(
                  color: Colors.pink,
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
                  child: RaisedButton( 
                color:      Colors.deepPurpleAccent.shade100,
                  
                shape: RoundedRectangleBorder(
                  
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: Center(
                  child: Text(
                  'Iniciar Sesión',
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: MediaQuery.of(context).size.height *0.018,
                    color: Colors.white,
                  ),
                ),
              ),
                onPressed: isLoginButtonEnabled(state)
                                            ? _onFormSubmitted
                                            : () {},
              ),
            ),
              
             Container(
         
                  height: MediaQuery.of(context).size.width * 0.1,
                  width: MediaQuery.of(context).size.height*0.8,
          //      color: Colors.black,
               
            ),
             Divider(
                indent: 40,
                endIndent: 40,
                height: 1,
                color: Colors.black38,
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
                  child: RaisedButton( 
                color: Colors.redAccent,
                shape: RoundedRectangleBorder(
                  
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: Center(
                  child: Text(
                  'Crear Cuenta',
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: MediaQuery.of(context).size.height *0.018,
                    color: Colors.white,
                  ),
                ),
              ),
               onPressed: (){
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context){
            return RegisterScreen(userRepository: _userRepository,);
          })
        );
      },
              ),
            ),
                SizedBox(
            height: MediaQuery.of(context).size.height*0.50/3.5,
             ),
      ]
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onEmailChanged() {
    _loginBloc.add(EmailChanged(email: _emailController.text));
  }

  void _onPasswordChanged() {
    _loginBloc.add(PasswordChanged(password: _passwordController.text));
  }
  
  String encryp(String password)
  {
    var bytes = utf8.encode(password);
    Digest sha256Result = sha256.convert(bytes);
     return sha256Result.toString();
  }

  void _onFormSubmitted() {
    _loginBloc.add(
      LoginWithCredentialsPressed(
        email: _emailController.text,
        password: encryp(_passwordController.text)
      )
    );
  }
}
