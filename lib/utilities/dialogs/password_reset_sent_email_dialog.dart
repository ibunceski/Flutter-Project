import 'package:flutter/material.dart';
import 'package:notesapp/extensions/list/buildcontext/loc.dart';
import 'package:notesapp/utilities/dialogs/generic_dialog.dart';

Future<void> showPasswordResetSentDialog({required BuildContext context}) {
  return showGenericDialog<void>(
    context: context,
    title: context.loc.password_reset,
    content: context.loc.password_reset_dialog_prompt,
    optionsBuilder: () => {context.loc.ok: null},
  );
}
