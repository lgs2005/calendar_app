import 'package:calendar_app/data_types/result.dart';
import 'package:calendar_app/util/error_prompt.dart';
import 'package:flutter/material.dart';

Future<T> blockInput<T>(BuildContext context, Future<T> future) async {
  showDialog(
    context: context,
    barrierColor: Colors.black.withAlpha(255~/2),
    barrierDismissible: false,
    builder: (context) => const SizedBox.expand(
      child: Center(
        child: SizedBox.square(
          dimension: 50,
          child: CircularProgressIndicator(),
        )
      )
    )
  );

  final result = await future;
  Navigator.pop(context);
  return result;
}

Future<Result<T>> wrapServiceRequest<T>(BuildContext context, Future<T> future) {
  return blockInput(context, Future(
    () => future
      .then((result) => Result.ok(result))
      .catchError((err) async {
        await showErrorPrompt(
          context: context,
        );

        return Result<T>.err(err.toString());
      }),
  ));
}