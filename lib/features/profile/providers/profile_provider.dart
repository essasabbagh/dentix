import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:template/core/client/client.dart';

import '../services/profile_service.dart';

final profileServiceProvider = Provider<ProfileService>(
  (ref) => ProfileService(ref.read(apiClientProvider)),
);
