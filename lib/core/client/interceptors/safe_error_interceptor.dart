import 'package:dio/dio.dart';

class SafeErrorInterceptor extends Interceptor {
  @override
  void onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) {
    // Final safety net:
    // ensures no Dio request stays pending forever
    handler.next(err);
  }
}
