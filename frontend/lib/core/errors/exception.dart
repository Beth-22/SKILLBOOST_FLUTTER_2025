class Exception {}

class ServerException extends Exception {
  final String message;

  ServerException(this.message);

  @override
  String toString() {
    return 'ServerException: $message';
  }
}

class NotFoundException extends ServerException {
  NotFoundException(String message) : super(message);
}

class UnauthorizedException extends ServerException {
  UnauthorizedException(String message) : super(message);
}