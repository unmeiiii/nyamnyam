import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../screen/profile_screen.dart';
import '../screen/settings_screen.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  String? _displayName;
  late final StreamSubscription<User?> _authSub;

  @override
  void initState() {
    super.initState();

    // Set display name synchronously from FirebaseAuth (or email fallback)
    // to avoid a brief 'User' placeholder while the async Firestore fetch runs.
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      if (user.displayName != null && user.displayName!.trim().isNotEmpty) {
        _displayName = user.displayName;
      } else {
        _displayName = user.email?.split('@').first;
      }
    }

    // Still refresh from Firestore (async) to pick up changes persisted there.
    _loadDisplayName();
    _authSub = FirebaseAuth.instance.authStateChanges().listen((_) {
      // Update display name on auth changes
      _loadDisplayName();
    });
  }

  Future<void> _loadDisplayName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) setState(() => _displayName = null);
      return;
    }

    // Prefer FirebaseAuth displayName if available
    if (user.displayName != null && user.displayName!.trim().isNotEmpty) {
      if (mounted) setState(() => _displayName = user.displayName);
      return;
    }

    // Fallback to Firestore 'users' collection
    try {
      final doc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();
      final dn = doc.data()?['displayName'] as String?;
      final fallback = user.email?.split('@').first ?? 'User';
      if (mounted)
        setState(
          () => _displayName = (dn != null && dn.isNotEmpty) ? dn : fallback,
        );
    } catch (_) {
      if (mounted)
        setState(() => _displayName = user.email?.split('@').first ?? 'User');
    }
  }

  @override
  void dispose() {
    _authSub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            /// Header
            Container(
              padding: const EdgeInsets.all(16),
              width: double.infinity,
              decoration: const BoxDecoration(color: Color(0xFFF97316)),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person,
                      size: 32,
                      color: Color(0xFFF97316),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Hello!",
                        style: TextStyle(fontSize: 14, color: Colors.white70),
                      ),
                      Text(
                        _displayName ?? 'User',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            /// Menu items
            _drawerItem(
              context,
              icon: Icons.person_outline,
              label: "Profile",
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                );
              },
            ),

            _drawerItem(
              context,
              icon: Icons.favorite_border,
              label: "Favourite Stalls",
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to Favourites screen
              },
            ),

            _drawerItem(
              context,
              icon: Icons.chat_bubble_outline,
              label: "Chat with Admin",
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to Chat screen
              },
            ),

            _drawerItem(
              context,
              icon: Icons.settings_outlined,
              label: "Settings",
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                );
              },
            ),

            const Spacer(),

            const Divider(),

            /// Logout
            _drawerItem(
              context,
              icon: Icons.logout,
              label: "Logout",
              isLogout: true,
              onTap: () async {
                Navigator.pop(context);

                final shouldLogout = await showDialog<bool>(
                  context: context,
                  builder:
                      (ctx) => AlertDialog(
                        title: const Text('Logout'),
                        content: const Text('Are you sure you want to logout?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(true),
                            child: const Text('Logout'),
                          ),
                        ],
                      ),
                );

                if (shouldLogout != true) return;

                try {
                  await FirebaseAuth.instance.signOut();
                  // Sign-out performed. The HomeScreen listens to auth state changes and will navigate to WelcomeScreen.
                } catch (e) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Logout failed: $e')));
                }
              },
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _drawerItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isLogout = false,
  }) {
    // Bubbly style: rounded container with circular icon and subtle shadow
    final Color primaryOrange = const Color(0xFFF97316);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          decoration: BoxDecoration(
            color: isLogout ? Colors.red.withOpacity(0.06) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow:
                isLogout
                    ? null
                    : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
            border: Border.all(
              color:
                  isLogout
                      ? Colors.red.withOpacity(0.08)
                      : Colors.grey.withOpacity(0.08),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color:
                      isLogout
                          ? Colors.red.withOpacity(0.12)
                          : primaryOrange.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: isLogout ? Colors.red : primaryOrange,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: isLogout ? Colors.red : Colors.black87,
                    fontWeight: isLogout ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
              Icon(Icons.chevron_right, size: 20, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }
}
