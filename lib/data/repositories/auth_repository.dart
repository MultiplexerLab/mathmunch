import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mathmunch/data/local/hive_service.dart';
import 'package:mathmunch/data/models/parent_account.dart';
import 'package:uuid/uuid.dart';

// ---------------------------------------------------------------------------
// Auth state
// ---------------------------------------------------------------------------

class AuthState {
  final ParentAccount? parentAccount;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.parentAccount,
    this.isLoading = false,
    this.error,
  });

  bool get hasParentAccount => parentAccount != null;

  AuthState copyWith({
    ParentAccount? parentAccount,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      parentAccount: parentAccount ?? this.parentAccount,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// ---------------------------------------------------------------------------
// Repository
// ---------------------------------------------------------------------------

class AuthRepository extends Notifier<AuthState> {
  @override
  AuthState build() {
    final saved = HiveService.parentBox.values.firstOrNull;
    return AuthState(parentAccount: saved);
  }

  String _hash(String input) =>
      sha256.convert(utf8.encode(input)).toString();

  Future<void> register({
    required String email,
    required String password,
    required String pin,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final account = ParentAccount(
        id: const Uuid().v4(),
        email: email.trim().toLowerCase(),
        passwordHash: _hash(password),
        parentPin: _hash(pin),
        childProfileIds: [],
        createdAt: DateTime.now(),
      );
      await HiveService.parentBox.put(account.id, account);
      state = state.copyWith(parentAccount: account, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    final account = HiveService.parentBox.values.firstWhere(
      (a) => a.email == email.trim().toLowerCase(),
      orElse: () => throw Exception('Account not found'),
    );
    if (account.passwordHash != _hash(password)) {
      state = state.copyWith(isLoading: false, error: 'Incorrect password');
      return false;
    }
    state = state.copyWith(parentAccount: account, isLoading: false);
    return true;
  }

  bool verifyPin(String pin) {
    return state.parentAccount?.parentPin == _hash(pin);
  }

  Future<void> addChildProfile(String childId) async {
    final account = state.parentAccount;
    if (account == null) return;
    final updated = account.copyWith(
      childProfileIds: [...account.childProfileIds, childId],
    );
    await HiveService.parentBox.put(updated.id, updated);
    state = state.copyWith(parentAccount: updated);
  }

  Future<void> updateEmail(String newEmail) async {
    final account = state.parentAccount;
    if (account == null) return;
    final updated = account.copyWith(email: newEmail.trim().toLowerCase());
    await HiveService.parentBox.put(updated.id, updated);
    state = state.copyWith(parentAccount: updated);
  }

  void logout() {
    state = const AuthState();
  }
}

final authStateProvider = NotifierProvider<AuthRepository, AuthState>(
  AuthRepository.new,
);
