import 'dart:async';

import 'package:calendar_app/util/refreshing_display.dart';
import 'package:flutter/material.dart';

class ProgressBuilder<T> extends StatelessWidget {
  final Future<T> future;
  final Widget Function(BuildContext, T) builder;
  final bool awaitNewWidget;

  const ProgressBuilder({
    Key? key,
    required this.future,
    required this.builder,
    this.awaitNewWidget = true,
  }) : super(key: key);

  Widget getErrorIndicator(BuildContext context, AsyncSnapshot snapshot) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error, color: Colors.red, size: 50),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Couldn\'t download data.\n${snapshot.error}',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
          )
        ]
      ),
    );
  }

  Widget getProgressIndicator(BuildContext context, AsyncSnapshot snapshot) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          CircularProgressIndicator(color: Colors.grey),
          Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Buscando dados...',
              style: TextStyle(color: Colors.grey),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: future,
      builder: (BuildContext context, AsyncSnapshot<T> snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return getProgressIndicator(context, snapshot);
        } else {
          // TODO: this sucks
          if (snapshot.hasError || snapshot.data is! T) {
            return getErrorIndicator(context, snapshot);
          } else {
            return builder(context, snapshot.data as T);
          }
        }
      },
    );
  }
}

class SourceDownloadBuilder<T> extends StatefulWidget {
  const SourceDownloadBuilder({
    Key? key,
    required this.source,
    required this.builder
  }) : super(key: key);

  final Future<T> Function() source;
  final Widget Function(BuildContext, T) builder;

  @override
  State<SourceDownloadBuilder<T>> createState() => _SourceDownloadBuilderState<T>();
}

class _SourceDownloadBuilderState<T>
  extends State<SourceDownloadBuilder<T>>
  with RouteAware, RefreshingDisplayMixin
{
  late Future<T> _download;

  @override
  void refresh() => setState(() {
    _download = widget.source();
  });

  @override
  Widget build(BuildContext context) {
    return ProgressBuilder(
      builder: widget.builder,
      future: _download,
    );
  }
}