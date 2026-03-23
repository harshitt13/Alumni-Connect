import 'package:go_router/go_router.dart';
import '../screens/login_screen.dart';
import '../screens/main_navigation_bar.dart';
import '../screens/admin/admin_navigation_bar.dart';

GoRouter createRouter(String initialLocation) {
  return GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const MainNavigation(),
      ),
      GoRoute(
        path: '/admin-home',
        builder: (context, state) => const AdminNavigation(),
      ),
    ],
  );
}
