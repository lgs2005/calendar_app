extension Delay<T> on Future<T> {
  Future<T> delay(int secs) {
    return Future.delayed(
      Duration(seconds: secs),
      () => this,
    );
  }
}