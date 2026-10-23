import 'package:flutter_riverpod/flutter_riverpod.dart';

/// UI-only stand-in for Firebase Auth: holds the signed-in profile in memory.
class UserProfile {
  const UserProfile({required this.name, required this.email});

  final String name;
  final String email;
}

final authProvider =
    NotifierProvider<AuthNotifier, UserProfile?>(AuthNotifier.new);

class AuthNotifier extends Notifier<UserProfile?> {
  @override
  UserProfile? build() => null;

  Future<void> signIn(String email, String password) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    state = UserProfile(name: email.split('@').first, email: email);
  }

  Future<void> signInWithProvider(String provider) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    state = const UserProfile(name: 'User Name', email: 'useremail@gmail.com');
  }

  Future<void> register(String name, String email, String password) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    state = UserProfile(name: name, email: email);
  }

  void updateName(String name) {
    final current = state;
    if (current != null) state = UserProfile(name: name, email: current.email);
  }

  void signOut() => state = null;
}
