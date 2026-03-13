// import 'package:flutter/material.dart';

// import 'package:hooks_riverpod/hooks_riverpod.dart';

// import 'auth_provider.dart';

// final emailVerificationProvider =
//     ChangeNotifierProvider<EmailVerificationNotifier>(
//       EmailVerificationNotifier.new,
//     );

// class EmailVerificationNotifier extends ChangeNotifier {
//   EmailVerificationNotifier(this.ref);

//   final Ref ref;

//   final formKey = GlobalKey<FormState>();

//   final codeController = TextEditingController();

//   bool _isLoading = false;
//   bool get isLoading => _isLoading;

//   String? _errorText;
//   String? get errorText => _errorText;

//   void setLoading(bool val) {
//     _isLoading = val;
//     notifyListeners();
//   }

//   void setError(String? val) {
//     _errorText = val;
//     notifyListeners();
//   }

//   // verify Email
//   Future<void> verifyEmail() async {
//     try {
//       final formState = formKey.currentState;
//       if (formState == null || !formState.validate()) return;

//       setError(null);
//       setLoading(true);

//       final code = codeController.text.trim();
//       // await ref.read(authServiceProvider).verifyEmail(code);

//       // Proceed to the prev screen
//       codeController.text = '';
//     } catch (e) {
//       // AppSnackBar.error(e.toString());
//       setError(e.toString());
//     } finally {
//       setLoading(false);
//     }
//   }

//   @override
//   void dispose() {
//     codeController.dispose();
//     super.dispose();
//   }
// }
