import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as devtools show log;
import 'package:notesapp/constants/routes.dart';
import 'package:notesapp/utilities/show_error_dialog.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController _email;
  late final TextEditingController _password;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Column(
        children: [
          TextField(
            keyboardType: TextInputType.emailAddress,
            controller: _email,
            autocorrect: false,
            decoration:
                const InputDecoration(hintText: "Enter your email address here"),
          ),
          TextField(
            keyboardType: TextInputType.visiblePassword,
            controller: _password,
            obscureText: true,
            enableSuggestions: false,
            autocorrect: false,
            decoration:
                const InputDecoration(hintText: "Enter your password here"),
          ),
          TextButton(
              onPressed: () async {
                final email = _email.text;
                final password = _password.text;
                try {
                  await FirebaseAuth.instance
                      .signInWithEmailAndPassword(
                          email: email, password: password);
                  Navigator.of(context).pushNamedAndRemoveUntil(notes_route, (route) => false);
                } on FirebaseAuthException catch (exception) {
                  if (exception.code == "invalid-credential") {
                    await showErrorDialog(context, "Invalid credentials");
                  } else {
                    await showErrorDialog(context, "Error: ${exception.code}");
                  }
                }catch (e){
                    await showErrorDialog(context, "Error: ${e.toString()}");
                }
              },
              child: const Text("Login")),
              TextButton(onPressed: (){
                Navigator.of(context).pushNamedAndRemoveUntil(register_route, (route) => false);
              }, child: const Text("Not registered yet? Register here!"))
        ],
      ),
    );
  }
}


