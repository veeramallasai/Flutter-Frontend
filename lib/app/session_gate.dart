import 'dart:async';

import 'package:farm_to_home_app/core/auth/backend_auth.dart';
import 'package:flutter/material.dart';

import '../features/auth/login_screen.dart';
import '../features/home/home_screen.dart';
import '../data/repositories/user_repository.dart';

class SessionGate extends StatefulWidget {
  const SessionGate({super.key});

  @override
  State<SessionGate> createState() => _SessionGateState();
}

class _SessionGateState extends State<SessionGate> {
  String _syncUid = '';
  Future<void>? _syncFuture;

  Future<void> _sync(User user) {
    if (_syncUid != user.uid || _syncFuture == null) {
      _syncUid = user.uid;
      _syncFuture = _syncAccount(user);
    }
    return _syncFuture!;
  }

  Future<void> _syncAccount(User user) async {
    await UserRepository().syncCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: BackendAuth.instance.authStateChanges(),
      builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final User? user = snapshot.data;
        if (user == null) {
          _syncUid = '';
          _syncFuture = null;
          return const LoginScreen();
        }

        return FutureBuilder<void>(
          future: _sync(user),
          builder: (BuildContext context, AsyncSnapshot<void> syncSnapshot) {
            if (syncSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            if (syncSnapshot.hasError) {
              return Scaffold(
                body: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        const Icon(Icons.cloud_off_rounded, size: 46),
                        const SizedBox(height: 14),
                        const Text(
                          'Unable to connect your account to Farm To Home.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          onPressed: () {
                            setState(() {
                              _syncFuture = UserRepository().syncCurrentUser();
                            });
                          },
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Text('RETRY'),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }
            return const HomeScreen();
          },
        );
      },
    );
  }
}
