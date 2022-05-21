import 'package:flutter/material.dart';

final routeObserver = BlockingRouteObserver();

class BlockingRouteObserver extends RouteObserver<ModalRoute<dynamic>> {
  bool routeWasBlocked = false;

  @override
  void didPop(Route route, Route? previousRoute) {
    routeWasBlocked = route is PageRoute;
    super.didPop(route, previousRoute);
  }
}

mixin RefreshingDisplayMixin<T extends StatefulWidget> on State<T>, RouteAware {
  void refresh();

  @override
  void initState() {
    refresh();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    routeObserver.subscribe(this, ModalRoute.of(context)!);
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override void didPush() => refresh();
  @override void didPopNext() {
    if (routeObserver.routeWasBlocked) {
      refresh();
    }
  }
}