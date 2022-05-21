class Result<T> {
  final bool ok;
  final T? value;
  final String? err;

  Result.ok(this.value) : ok = true, err = null;
  Result.err(this.err) : ok = false, value = null;

  static Result<T> fromMap<T, F>(
    Map<String, dynamic> data, {
    bool nullable = false,
    T Function(F)? parser,
  }) {
    if (
      data['ok'] is! bool
      || (!data['ok'] && data['err'] is! String)
      || (data['ok'] && (parser != null ? data['value'] is! F : data['value'] is! T))
    ) throw const FormatException('Bad result format');

    return !data['ok']
      ? Result.err(data['err'])
      : parser != null
        ? Result.ok(parser(data['value']))
        : Result.ok(data['value']);
  }
}