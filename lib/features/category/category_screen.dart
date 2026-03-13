import 'package:flutter/material.dart';

import 'package:dio/dio.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:template/components/loading/loading_widget.dart';
import 'package:template/core/errors/app_error_widget.dart';

final dataProvider = FutureProvider.autoDispose<bool>((ref) async {
  // await ref.watch(networkServiceProvider).get('/');
  throw DioException.badResponse(
    statusCode: 422,
    requestOptions: RequestOptions(path: '/'),
    response: Response(
      requestOptions: RequestOptions(path: '/'),
      statusCode: 422,
      statusMessage: 'Internal Server Error',
    ),
  ); // Simulating an error
});

class CategoryScreen extends ConsumerWidget {
  const CategoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataAsync = ref.watch(dataProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Category'),
      ),
      body: dataAsync.when(
        data: (data) {
          if (data) {
            return const Center(child: Text('Data Loaded'));
          } else {
            return const Center(child: Text('No Data Available'));
          }
        },
        loading: LoadingWidget.new,
        // Error state - integrated with your error handling system
        error: (error, stackTrace) => AppErrorWidget.fromError(
          error,
          stackTrace,
          onRetry: () {
            // Refresh the provider to retry the API call
            ref.refresh(dataProvider);
          },
          onLogin: () {
            // Navigate to login if authentication error
            Navigator.pushNamed(context, '/login');
          },
          showDebugInfo: true, // Enable in debug mode
        ),
      ),
    );
  }
}
