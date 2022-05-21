import 'package:flutter/material.dart';

mixin RouteProviderMixin<T> on Widget {
  Route<T> buildRoute(BuildContext context) => MaterialPageRoute(builder: (context) => this);

  Future<T?> pushOnto(BuildContext context) {
    return Navigator.of(context).push(buildRoute(context));
  }

  Future<T?> pushReplacementOnto(BuildContext context) {
    return Navigator.pushReplacement(context, buildRoute(context));
  }
}