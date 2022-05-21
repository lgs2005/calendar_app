import 'package:flutter/material.dart';

class ErrorPrompt extends StatelessWidget {
  const ErrorPrompt({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Ocorreu um erro'),
      content: const Text('A operação foi cancelada.'),
      actions: [
        TextButton(
          child: const Text('OK'),
          onPressed: () => Navigator.pop(context),
        )
      ],
    );
  }
}

Future<void> showErrorPrompt({
    required BuildContext context,
    void Function()? onDismissed,
}) async {
  await showDialog(
    context: context,
    builder: (context) => const ErrorPrompt(),
  );
  
  onDismissed?.call();
}