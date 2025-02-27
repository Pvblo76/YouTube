class AppExceptions implements Exception {
  final _message;
  final _prefix;
  AppExceptions([this._message, this._prefix]);
  String toString() {
    return "$_prefix $_message";
  }
}

class FetchDataExceptions extends AppExceptions {
  FetchDataExceptions([String? message])
      : super(message, "Error During Communication");
}

class BadrequestExceptions extends AppExceptions {
  BadrequestExceptions([String? message]) : super(message, "Invalid Request");
}

class UnAuthorizedExceptions extends AppExceptions {
  UnAuthorizedExceptions([String? message]) : super(message, "UnAthorized Url");
}

class InvalidinputExceptions extends AppExceptions {
  InvalidinputExceptions([String? message]) : super(message, "Invalid Input");
}

class NoInternetException extends AppExceptions {
  NoInternetException([String? message])
      : super(message, 'No Internet Connection');
}
