import 'package:flutter/material.dart';

class LoginButton extends StatelessWidget {
  final VoidCallback _onPressed;

  LoginButton({Key key, VoidCallback onPressed})
      : _onPressed = onPressed,
        super(key: key);



  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      color: Colors.white,
      onPressed: _onPressed,
      child: Center(
        child: Text(
          'Iniciar Sesión',
          style: TextStyle(
            fontFamily: "Arial",
            fontSize: (MediaQuery.of(context).size.height * 0.025),
            color: Colors.black,
            fontWeight: FontWeight.bold,
            inherit: false,
          ),
        ),
      ),
    );
  }
}
