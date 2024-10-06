import 'package:flutter/material.dart';
import 'package:notesapp/utilities/dialogs/generic_dialog.dart';

Future<void> showPasswordResetSentDialog({required BuildContext context}) {
  return showGenericDialog<void>(
    context: context,
    title: "Email sent",
    content:
        "The email for your password reset has been sent. Please check your email for more information",
    optionsBuilder: () => {"OK": null},
  );
}
