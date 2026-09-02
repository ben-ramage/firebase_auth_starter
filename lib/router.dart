import 'dart:async';

import 'package:firebase_auth_starter/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:firebase_auth_starter/features/auth/presentation/cubits/auth_states.dart';
import 'package:firebase_auth_starter/features/auth/presentation/pages/auth_page.dart';
import 'package:firebase_auth_starter/features/auth/presentation/pages/reset_password_page.dart';
import 'package:firebase_auth_starter/features/auth/presentation/pages/splash.dart';
import 'package:firebase_auth_starter/features/auth/presentation/pages/verify_email_action_page.dart'
    show VerifyEmailActionPage;
import 'package:firebase_auth_starter/features/auth/presentation/pages/verify_email_change_action_page.dart';
import 'package:firebase_auth_starter/features/auth/presentation/pages/verify_email_page.dart';
import 'package:firebase_auth_starter/features/profile/presentation/pages/edit_profile_page.dart';
import 'package:firebase_auth_starter/features/settings/presentation/account_settings_page.dart';
import 'package:firebase_auth_starter/features/settings/presentation/update_email_page.dart';
import 'package:firebase_auth_starter/features/settings/presentation/update_password_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth_starter/app_scaffold_with_navbar.dart';
import 'package:firebase_auth_starter/features/home/presentation/pages/home_page.dart';
import 'package:firebase_auth_starter/features/profile/presentation/pages/profile_page.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> shellNavigatorKey = GlobalKey<NavigatorState>();

class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<AuthState> _subscription;

  GoRouterRefreshStream(Stream<AuthState> stream) {
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

GoRouter createRouter(AuthCubit authCubit) {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/splash',
    refreshListenable: GoRouterRefreshStream(authCubit.stream),
    redirect: (context, state) {
      final path = state.uri.path;

      // Allow Firebase auth action links through
      if (path == '/__/auth/action') return null;

      final authState = authCubit.state;

      if (authState is CheckingAuthState) {
        return path == '/splash' ? null : '/splash';
      }

      if (authState is AuthLoading) return null;

      // Normal auth gates
      if (authState is Unauthenticated) {
        return path == '/' ? null : '/';
      }

      if (authState is EmailVerificationPending) {
        return path == '/verify-email' ? null : '/verify-email';
      }

      if (authState is Authenticated) {
        if (path == '/' || path == '/splash' || path == '/verify-email') {
          return '/home';
        }
      }

      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (context, state) => SplashPage()),
      GoRoute(path: '/', builder: (context, state) => AuthPage()),
      GoRoute(
        path: '/verify-email',
        builder: (context, state) => VerifyEmailPage(),
      ),
      GoRoute(
        path: '/__/auth/action',
        builder: (context, state) {
          final mode = state.uri.queryParameters['mode'];
          final actionCode = state.uri.queryParameters['oobCode'];

          if (mode == 'resetPassword' && actionCode != null) {
            return ResetPasswordPage(actionCode: actionCode);
          }

          if (mode == 'verifyEmail' && actionCode != null) {
            return VerifyEmailActionPage(actionCode: actionCode);
          }

          if (mode == 'verifyAndChangeEmail' && actionCode != null) {
            return VerifyEmailChangeActionPage(actionCode: actionCode);
          }

          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.go('/');
          });

          return const SizedBox();
        },
      ),
      ShellRoute(
        navigatorKey: shellNavigatorKey,
        builder: (context, state, child) {
          return AppScaffoldWithNavbar(state: state, child: child);
        },
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomePage(title: 'Home'),
          ),
          GoRoute(
            path: '/profile',
            redirect: (context, state) {
              final uid = authCubit.currentUser?.uid;

              if (uid == null || uid.isEmpty) {
                return '/';
              }

              return '/profile/$uid';
            },
          ),
          GoRoute(
            path: '/profile/:uid',
            redirect: (context, state) {
              final requestedUid = state.pathParameters['uid'];
              final currentUid = authCubit.currentUser?.uid;

              if (currentUid == null || currentUid.isEmpty) {
                return '/';
              }

              if (requestedUid != currentUid) {
                return '/profile/$currentUid';
              }

              return null;
            },
            builder: (context, state) => const ProfilePage(uid: 'uid'),
          ),
          GoRoute(
            path: '/profile/edit',
            builder: (context, state) => const EditProfilePage(),
          ),
        ],
      ),
      GoRoute(
        path: 'account_settings',
        builder: (context, state) => AccountSettingsPage(uid: 'uid'),
      ),
      GoRoute(
        path: 'security/email',
        builder: (context, state) => const UpdateEmailPage(),
      ),
      GoRoute(
        path: 'security/password',
        builder: (context, state) => const UpdatePasswordPage(),
      ),
    ],
  );
}
