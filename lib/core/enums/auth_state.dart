enum AuthState {
  initial('initial'),
  loading('loading'),
  authenticated('authenticated'),
  unauthenticated('unauthenticated'),
  profileIncomplete('profile_incomplete'),
  error('error');

  const AuthState(this.value);
  final String value;

  bool get isBusy => this == AuthState.loading;
  bool get isSignedIn =>
      this == AuthState.authenticated || this == AuthState.profileIncomplete;

  static AuthState fromValue(String? value) {
    final String normalized = value?.trim().toLowerCase() ?? '';
    return AuthState.values.firstWhere(
      (AuthState item) => item.value == normalized,
      orElse: () => AuthState.initial,
    );
  }
}
