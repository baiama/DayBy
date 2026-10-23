import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/forgot_password_screen.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/registration_screen.dart';
import '../../features/auth/splash_screen.dart';
import '../../features/calendar/calendar_screen.dart';
import '../../features/lists/lists_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/stats/stats_screen.dart';
import '../../features/tasks/home_screen.dart';
import '../widgets/app_shell.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(path: '/splash', builder: (_, _) => const SplashScreen()),
      GoRoute(path: '/login', builder: (_, _) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, _) => const RegistrationScreen()),
      GoRoute(path: '/forgot-password', builder: (_, _) => const ForgotPasswordScreen()),
      GoRoute(path: '/profile', builder: (_, _) => const ProfileScreen()),
      StatefulShellRoute.indexedStack(
        builder: (_, _, shell) => AppShell(shell: shell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(path: '/home', builder: (_, _) => const HomeScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/lists',
              builder: (_, _) => const ListsScreen(),
              routes: [
                GoRoute(
                  path: ':id',
                  builder: (_, state) =>
                      ListDetailScreen(listId: state.pathParameters['id']!),
                ),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/stats', builder: (_, _) => const StatsScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/calendar', builder: (_, _) => const CalendarScreen()),
          ]),
        ],
      ),
    ],
  );
});
