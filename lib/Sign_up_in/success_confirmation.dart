import 'package:flutter/material.dart';

class SuccessConfirmationPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Success")),
      body: Center(
        child: Text("Password reset successful! You can now log in."),
      ),
    );
  }
}
