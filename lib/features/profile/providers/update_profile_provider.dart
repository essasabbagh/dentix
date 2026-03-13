import 'dart:io';

import 'package:flutter/material.dart';

import 'package:dio/dio.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import 'package:template/core/locale/generated/l10n.dart';
import 'package:template/core/router/app_router.dart';
import 'package:template/core/utils/snackbars.dart';
import 'package:template/features/auth/models/user_data.dart';
import 'package:template/features/auth/providers/auth_provider.dart';

import '../requests/update_profile_request.dart';

import 'profile_provider.dart';

final updateProfileProvider =
    ChangeNotifierProvider.autoDispose<UpdateProfileNotifier>(
      UpdateProfileNotifier.new,
    );

class UpdateProfileNotifier extends ChangeNotifier {
  UpdateProfileNotifier(this.ref) {
    _initialize();
  }
  final Ref ref;
  UserData? user;

  void _initialize() {
    final res = ref.read(authNotifierProvider.notifier).user;
    user = res;
    if (user != null) {
      _fillInitialValues(user!);
    }
  }

  void _fillInitialValues(UserData user) {
    firstNameController.text = user.firstName ?? '';
    lastNameController.text = user.lastName ?? '';
    phoneController.text = user.phoneNumber != null
        ? user.phoneNumber!.replaceFirst(
            RegExp(r'^(?:\+963|0)'),
            '',
          ) //syrian num
        : '';
    emailController.text = user.email ?? '';

    if (user.image != null) {
      _oldImageUrl = user.image;
    }
    notifyListeners();
  }

  final updateProfileFormKey = GlobalKey<FormState>();

  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();

  File? _selectedImage;
  File? get selectedImage => _selectedImage;

  void addImages(File image) {
    _selectedImage = image;
    notifyListeners();
  }

  void removeImage() {
    _selectedImage = null;
    notifyListeners();
  }

  final firstNameFocusNode = FocusNode();
  final lastNameFocusNode = FocusNode();
  final emailFocusNode = FocusNode();
  final phoneFocusNode = FocusNode();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  File? _imageFile;
  File? get imageFile => _imageFile;

  String? _oldImageUrl;
  String? get oldImageUrl => _oldImageUrl;

  void setLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      _imageFile = File(picked.path);
      _oldImageUrl = null;
      notifyListeners();
    }
  }

  Future<void> updateProfile() async {
    try {
      if (updateProfileFormKey.currentState?.validate() ?? false) {
        firstNameFocusNode.unfocus();
        lastNameFocusNode.unfocus();
        emailFocusNode.unfocus();
        phoneFocusNode.unfocus();
        setLoading(true);

        final request = UpdateProfileRequest(
          firstName: firstNameController.text.trim(),
          lastName: lastNameController.text.trim(),
          emailAddress: emailController.text.trim(),
          phoneNumber: phoneController.text.trim(),
          profileImage: _imageFile == null
              ? null
              : MultipartFile.fromFileSync(_imageFile?.path ?? ''),
        );

        await ref.read(profileServiceProvider).updateProfile(request);
        // refresh user data after update
        await ref.read(authNotifierProvider.notifier).refreshUser();

        AppSnackBar.success(S.current.updateProfileSuccessful);
        ref.read(routerProvider).pop();
        clearFields();
      }
    } catch (e) {
      AppSnackBar.error(e.toString());
    } finally {
      setLoading(false);
    }
  }

  void clearFields() {
    firstNameController.clear();
    lastNameController.clear();
    emailController.clear();
    phoneController.clear();

    _imageFile = null;
    _oldImageUrl = null;
    _selectedImage = null;
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneController.dispose();

    firstNameFocusNode.dispose();
    lastNameFocusNode.dispose();
    emailFocusNode.dispose();
    phoneFocusNode.dispose();

    _imageFile = null;
    _oldImageUrl = null;
    _selectedImage = null;

    super.dispose();
  }
}
