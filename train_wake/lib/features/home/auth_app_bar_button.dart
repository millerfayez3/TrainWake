import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:train_wake/features/auth/application/auth_providers.dart';
import 'package:train_wake/features/auth/domain/auth_state.dart';
import 'package:train_wake/features/auth/l10n/auth_strings.dart';
import 'package:train_wake/features/auth/presentation/admin_dashboard_screen.dart';
import 'package:train_wake/features/auth/presentation/login_screen.dart';

/// AppBar button providing optional auth entry point from HomeScreen.
/// The trip/alarm critical path is completely independent of this widget.
class AuthAppBarButton extends ConsumerWidget {
  final AuthState authState;
  const AuthAppBarButton({super.key, required this.authState});


  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (authState is AuthStateAdminSignedIn) {
      return IconButton(
        icon: const Icon(Icons.admin_panel_settings_outlined),
        tooltip: AuthStrings.adminDashboardButton,
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
        ),
      );
    }

    if (authState is AuthStateSignedIn) {
      final user = (authState as AuthStateSignedIn).user;
      return PopupMenuButton<String>(
        icon: const Icon(Icons.account_circle_outlined),
        tooltip: AuthStrings.accountButton,
        onSelected: (value) async {
          if (value == 'logout') {
            final confirm = await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text(AuthStrings.logoutButton),
                content: const Text(AuthStrings.logoutActiveTrip),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: const Text('\u0625\u0644\u063a\u0627\u0621'),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    child: const Text(AuthStrings.logoutButton),
                  ),
                ],
              ),
            );
            if (confirm == true) {
              await ref.read(authStateProvider.notifier).signOut();
            }
          }
        },
        itemBuilder: (context) => [
          PopupMenuItem(
            enabled: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  AuthStrings.signedInAs,
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Text(
                  user.email ?? '',
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const PopupMenuDivider(),
          const PopupMenuItem(
            value: 'logout',
            child: Row(
              children: [
                Icon(Icons.logout, size: 18),
                SizedBox(width: 8),
                Text(AuthStrings.logoutButton),
              ],
            ),
          ),
        ],
      );
    }

    // Signed out — show login button
    return IconButton(
      icon: const Icon(Icons.account_circle_outlined),
      tooltip: AuthStrings.accountButton,
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      ),
    );
  }
}
