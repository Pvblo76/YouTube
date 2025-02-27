import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:youtube/network/exceptions/app_exceptions.dart';

class NetworkApiServices {
  // Method to get API response
  Future<dynamic> getApiResponse(String url) async {
    try {
      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 15)); // Timeout in 10 seconds
      return _responseResult(response);
    } on SocketException {
      // Handle network-related exceptions (like no internet)
      throw FetchDataExceptions("No Internet connection");
    } on TimeoutException {
      // Handle timeout exception specifically
      throw FetchDataExceptions("Request timed out");
    } catch (e) {
      // Handle any other exceptions
      throw FetchDataExceptions("Unexpected error: ${e.toString()}");
    }
  }

  // Method to handle response result based on status code
  dynamic _responseResult(http.Response response) {
    switch (response.statusCode) {
      case 200:
        return jsonDecode(response.body.toString()); // Success case
      case 401:
        throw UnAuthorizedExceptions(response.body.toString()); // Unauthorized
      case 502:
        throw BadrequestExceptions(response.body.toString()); // Bad request
      default:
        throw FetchDataExceptions(
            'Error occurred with status code: ${response.statusCode}, response: ${response.body.toString()}'); // Other errors
    }
  }
}
