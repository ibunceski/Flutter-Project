import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:notesapp/constants/routes.dart';
import 'package:notesapp/utilities/show_error_dialog.dart';

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
                  final userCredential = await FirebaseAuth.instance
                      .createUserWithEmailAndPassword(
                    email: email,
                    password: password,
                  );
                  final user = FirebaseAuth.instance.currentUser;
                  await user?.sendEmailVerification();
                  Navigator.of(context).pushNamed(verify_email_route);

                } on FirebaseAuthException catch (exception) {
                  if (exception.code == "invalid-email") {
                    await showErrorDialog(
                        context, "The provided email address is invalid.");
                  } else if (exception.code == "email-already-in-use") {
                    await showErrorDialog(context,
                        "There is already an user registerd with this email.");
                  } else if (exception.code == "weak-password") {
                    await showErrorDialog(context,
                        "The password is weak, please create a stronger password.");
                  } else {
                    showErrorDialog(context,
                        "There was an error registering your account ${exception.code}");
                  }
                } catch (exception) {
                  showErrorDialog(context,
                      "There was an error registering your account ${exception.toString()}");
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
