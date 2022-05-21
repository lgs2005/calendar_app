import 'package:flutter/material.dart';

Widget maybeEmptyDescription(String? description) {
  if (description == null || description.isEmpty) {
    return const Text(
      '(Sem descrição)',
      style: TextStyle(
        color: Colors.grey,
      ),
    );
  } else {
    return Text(description);
  }
}