class EnginError {
  bool error;
  String code;
  String message;
  EnginError({
    this.error,
    this.code,
    this.message,
  });
  factory EnginError.fromMap(Map<dynamic, dynamic> data) {
    return EnginError(
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
