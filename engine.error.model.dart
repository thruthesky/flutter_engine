class EngineError {
  bool error;
  String code;
  String message;
  EngineError({
    this.error,
    this.code,
    this.message,
  });
  factory EngineError.fromMap(Map<dynamic, dynamic> data) {
    return EngineError(
      error: data['error'],
      code: data['code'],
      message: data['message'],
    );
  }

  @override
  String toString() {
    return "$code : $message";
  }
}
