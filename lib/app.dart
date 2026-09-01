import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_starter/features/auth/data/firebase_auth_repository.dart';
import 'package:firebase_auth_starter/features/auth/domain/repos/auth_repository.dart';
import 'package:firebase_auth_starter/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:firebase_auth_starter/features/auth/presentation/cubits/auth_states.dart';
import 'package:firebase_auth_starter/features/image_upload/data/firebase_image_upload_repository.dart';
import 'package:firebase_auth_starter/features/image_upload/domain/repos/image_upload_repository.dart';
import 'package:firebase_auth_starter/features/profile/data/firebase_profile_repository.dart';
import 'package:firebase_auth_starter/features/profile/domain/repos/profile_repository.dart';
import 'package:firebase_auth_starter/utils/app_theme.dart';
import 'package:firebase_auth_starter/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class App extends StatefulWidget {
  final firebaseAuthRepository = FirebaseAuthRepository();
  final firebaseProfilerepository = FirebaseProfileRepository();
  final firebaseImageUploadRepository = FirebaseImageUploadRepository();

  App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late final AuthCubit _authCubit;
  late final AppLinks _appLinks;
  late final GoRouter _router;
  StreamSubscription<Uri>? _deepLinkSubscription;

  Future<void> _initDeepLinks() async {
    _appLinks = AppLinks();

    try {
      final initialUri = await _appLinks.getInitialLink();

      if (!mounted) return;

      if (initialUri != null) {
        _handleIncomingLink(initialUri);
      }
    } catch (e) {
      debugPrint('Failed to read initial app link: $e');
    }

    _deepLinkSubscription = _appLinks.uriLinkStream.listen(
      (uri) {
        _handleIncomingLink(uri);
      },
      onError: (Object error) {
        debugPrint('App link stream error: $error');
      },
    );
  }

  void _handleIncomingLink(Uri uri) {
    Uri routeUri = uri;

    // Real Firebase Auth emails use a Hosting wrapper such as:
    //
    // https://PROJECT.firebaseapp.com/__/auth/links
    //   ?link=https%3A%2F%2FPROJECT.firebaseapp.com%2F__%2Fauth%2Faction...
    //
    // Extract the inner Firebase action URL so GoRouter receives
    // /__/auth/action with mode, oobCode and the other query parameters.
    if (uri.host == 'fir-auth-starter-61de1.firebaseapp.com' &&
        uri.path == '/__/auth/links') {
      final wrappedLink = uri.queryParameters['link'];

      if (wrappedLink != null) {
        final innerUri = Uri.tryParse(wrappedLink);

        final isExpectedAuthAction =
            innerUri != null &&
            innerUri.path == '/__/auth/action' &&
            (innerUri.host == 'fir-auth-starter-61de1.firebaseapp.com' ||
                innerUri.host == 'fir-auth-starter-61de1.web.app');

        if (isExpectedAuthAction) {
          routeUri = innerUri;
        }
      }
    }

    final route = routeUri.hasQuery
        ? '${routeUri.path}?${routeUri.query}'
        : routeUri.path;

    _router.go(route);
  }

  @override
  void initState() {
    super.initState();
    _authCubit = AuthCubit(authRepository: widget.firebaseAuthRepository);
    _router = createRouter(_authCubit);
    _initDeepLinks();
  }

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>.value(
          value: widget.firebaseAuthRepository,
        ),
        RepositoryProvider<ProfileRepository>.value(
          value: widget.firebaseProfilerepository,
        ),
        RepositoryProvider<ImageUploadRepository>.value(
          value: widget.firebaseImageUploadRepository,
        ),
      ],
      child: MultiBlocProvider(
        providers: [BlocProvider<AuthCubit>.value(value: _authCubit)],
        child: MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: 'Firebase Auth Starter',
          theme: AppTheme.lightTheme,
          themeMode: ThemeMode.light,
          routerConfig: _router,
          builder: (context, child) {
            return BlocListener<AuthCubit, AuthState>(
              listener: (context, state) {
                if (state is Authenticated) {
                  final uid = FirebaseAuth.instance.currentUser?.uid;
                  if (uid == null) return;
                }
              },
              child: child,
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _deepLinkSubscription?.cancel();
    _router.dispose();
    _authCubit.close();
    super.dispose();
  }
}
