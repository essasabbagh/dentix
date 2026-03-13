import 'package:flutter/material.dart';

import 'package:dio/dio.dart';

import 'app_error_widget.dart';
import 'app_exception.dart';
import 'status_code.dart';

/// Usage examples and helper methods
class ErrorHandlerUsageExamples extends StatefulWidget {
  const ErrorHandlerUsageExamples({super.key});

  @override
  State<ErrorHandlerUsageExamples> createState() =>
      _ErrorHandlerUsageExamplesState();
}

class _ErrorHandlerUsageExamplesState extends State<ErrorHandlerUsageExamples> {
  Future<String> _simulateApiCall() async {
    await Future.delayed(const Duration(seconds: 1));
    // Simulate different types of errors
    throw DioException(
      requestOptions: RequestOptions(path: '/api/data'),
      type: DioExceptionType.connectionTimeout,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Error Handler Examples')),
      body: Column(
        children: [
          // Example 1: FutureBuilder with integrated error handling
          Expanded(
            child: FutureBuilder<String>(
              future: _simulateApiCall(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return AppErrorWidget.fromError(
                    snapshot.error!,
                    snapshot.stackTrace,
                    onRetry: () => setState(() {}), // Trigger rebuild to retry
                    onGoBack: () => Navigator.pop(context),
                    showDebugInfo: true, // Enable in debug mode
                  );
                }

                return Center(child: Text(snapshot.data ?? 'Success!'));
              },
            ),
          ),

          // Example 2: Manual error widget creation
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: () {
                final exception = AppException(
                  message: 'Custom error message',
                  statusCode: StatusCode.unauthorized,
                );

                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    content: SizedBox(
                      height: 400,
                      child: AppErrorWidget(
                        exception: exception,
                        onLogin: () {
                          Navigator.pop(context);
                          // Handle login logic
                        },
                      ),
                    ),
                  ),
                );
              },
              child: const Text('Show Custom Error Dialog'),
            ),
          ),
        ],
      ),
    );
  }
}
