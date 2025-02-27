import 'package:youtube/network/response/api_status.dart';

class ApiRespones<T> {
  T? data;
  String? message;
  ApiStatus? status;
  ApiRespones(this.status, this.data, this.message);
  ApiRespones.loading() : status = ApiStatus.Loading;
  ApiRespones.complete(this.data) : status = ApiStatus.Complete;
  ApiRespones.error(this.message) : status = ApiStatus.Error;
  String toString() {
    return "Status : $status \n Data : $data \n Message : $message ";
  }
}
