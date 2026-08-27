import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:firebase_auth_starter/features/auth/data/firebase_auth_repository.dart';
import 'package:firebase_auth_starter/features/auth/domain/repos/auth_repository.dart';
import 'package:firebase_auth_starter/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:firebase_auth_starter/utils/app_theme.dart';
import 'package:firebase_auth_starter/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class App extends StatefulWidget {
  final firebaseAuthRepository = FirebaseAuthRepository();

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
    } catch (_) {
      // App can continue without an initial deep link.
    }

    _deepLinkSubscription = _appLinks.uriLinkStream.listen(
      (uri) {
        _handleIncomingLink(uri);
      },
      onError: (_) {
        // Ignore deep-link stream errors so they do not break app usage.
      },
    );
  }

  void _handleIncomingLink(Uri uri) {
    debugPrint('APP LINK RECEIVED: $uri');
    debugPrint('APP LINK PATH: ${uri.path}');
    debugPrint('APP LINK QUERY: ${uri.query}');

    final route = uri.hasQuery ? '${uri.path}?${uri.query}' : uri.path;

    debugPrint('APP LINK ROUTING TO: $route');

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
      ],
      child: MultiBlocProvider(
        providers: [BlocProvider<AuthCubit>.value(value: _authCubit)],
        child: MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: 'Firebase Auth Starter',
          theme: AppTheme.lightTheme,
          themeMode: ThemeMode.light,
          routerConfig: _router,
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
