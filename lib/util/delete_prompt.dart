import 'package:flutter/material.dart';

Future<bool?> showDeletePrompt(BuildContext context, String text) {
  return showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Excluir?'),
      content: Text(text),
      actions: [
        TextButton(
          child: const Text('Não'),
          onPressed: () => Navigator.pop(context, false),
        ),

        TextButton(
          child: const Text('Sim'),
          onPressed: () => Navigator.pop(context, true),
        )
      ],
    ),
  );
}