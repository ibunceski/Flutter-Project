import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notesapp/extensions/list/buildcontext/loc.dart';
import 'package:notesapp/services/auth/bloc/auth_bloc.dart';
import 'package:notesapp/services/auth/bloc/auth_event.dart';

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({super.key});

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.loc.verify_email)),
      body: Column(
        children: [
          Text(context.loc.verify_email_view_prompt),
          TextButton(
              onPressed: () {
                context
                    .read<AuthBloc>()
                    .add(const AuthEventSendEmailVerification());
              },
              child: Text(context.loc.verify_email_send_email_verification)),
          TextButton(
            onPressed: () {
              context.read<AuthBloc>().add(const AuthEventLogOut());
            },
            child: Text(context.loc.restart),
          )
        ],
      ),
    );
  }
}
