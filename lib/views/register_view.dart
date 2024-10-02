import 'package:flutter/material.dart';
import 'package:notesapp/constants/routes.dart';
import 'package:notesapp/services/auth/auth_exceptions.dart';
import 'package:notesapp/services/auth/auth_service.dart';
import 'package:notesapp/utilities/dialogs/error_dialog.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
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
      appBar: AppBar(title: const Text("Register")),
      body: Column(
        children: [
          TextField(
            keyboardType: TextInputType.emailAddress,
            controller: _email,
            autocorrect: false,
            decoration: const InputDecoration(
                hintText: "Enter your email address here"),
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
                  await AuthService.firebase()
                      .createUser(email: email, password: password);
                  await AuthService.firebase().sendEmailVerification();
                  Navigator.of(context).pushNamed(verify_email_route);
                } on InvalidEmailAuthException {
                  await showErrorDialog(
                      context, "The provided email address is invalid.");
                } on EmailAlreadyInUseAuthException {
                  await showErrorDialog(context,
                      "There is already an user registerd with this email.");
                } on WeakPasswordAuthException {
                  await showErrorDialog(context,
                      "The password is weak, please create a stronger password.");
                } on GenericAuthException {
                  showErrorDialog(
                      context, "There was an error registering your account");
                }
              },
              child: const Text("Register")),
          TextButton(
              onPressed: () {
                Navigator.of(context)
                    .pushNamedAndRemoveUntil(login_route, (route) => false);
              },
              child: const Text("Already registered? Login here!"))
        ],
      ),
    );
  }
}
