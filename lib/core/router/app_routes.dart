import 'app_route_path_cache.dart';

export 'package:go_router/go_router.dart';

enum AppRoutes {
  splash('/', 'splash'),
  onboarding('/onboarding', 'onboarding'),
  login('/login', 'login'),
  resetPassword('reset-password', 'resetPassword'),
  resetPasswordDone('reset-password-done', 'resetPasswordDone'),
  changePassword('change-password', 'changePassword'),
  updateProfile('/update-profile', 'updateProfile'),
  register('/register', 'register'),
  resetPasswordConfirm('reset-password-confirm', 'resetPasswordConfirm'),
  updatePassword('update-password', 'updatePassword'),
  registerConfirm('confirm-register', 'registerConfirm'),

  root('/root', 'root'),
  profile('/profile', 'profile'),
  help('/help', 'help'),
  about('/about', 'about'),
  termsConditions('/terms-conditions', 'termsConditions'),
  privacyPolicy('/privacy-policy', 'privacyPolicy'),
  home('/home', 'home'),
  web('/web', 'web'),
  favorite('/favorite', 'favorite'),
  posts('/posts', 'posts'),
  postDetails('post-details', 'postDetails'),
  notifications('/notifications', 'notifications'),
  settings('/settings', 'settings'),
  category('/category', 'category'),
  search('/search', 'search');

  final String path;
  final String name;
  // ignore: sort_constructors_first
  const AppRoutes(this.path, this.name);

  String get fullPath => AppRoutePathCache.instance.getFullPath(this);
}

// extension AppRoutesX on AppRoutes {
//   String get fullPath => AppRoutePathCache.instance.getFullPath(this);
// }
