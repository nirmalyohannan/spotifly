import 'dart:developer';
import 'package:dio/dio.dart';

class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    var time = DateTime.now();
    var formattedTime =
        '${time.hour}:${time.minute}:${time.second}.${time.millisecond}';
    log('$formattedTime | ${options.method} | ${options.path}');
    super.onRequest(options, handler);
  }

  // @override
  // void onResponse(Response response, ResponseInterceptorHandler handler) {
  //   var time = DateTime.now();
  //   var formattedTime =
  //       '${time.hour}:${time.minute}:${time.second}.${time.millisecond}';
  //   log(
  //     '$formattedTime | RESPONSE | ${response.statusCode} | ${response.requestOptions.path}',
  //   );
  //   super.onResponse(response, handler);
  // }

  // @override
  // void onError(DioException err, ErrorInterceptorHandler handler) {
  //   var time = DateTime.now();
  //   var formattedTime =
  //       '${time.hour}:${time.minute}:${time.second}.${time.millisecond}';
  //   log('$formattedTime | ERROR | ${err.message} | ${err.requestOptions.path}');
  //   super.onError(err, handler);
  // }
}
