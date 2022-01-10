import 'package:flutter/material.dart';

import 'package:mister/models/database/autonomous.dart';

abstract class AuthenticationMethods {
  Future<void> signUp(
    BuildContext context,
    String email,
    String password,
    Autonomous autonomous,
    VoidCallback callback,
  );

  Future<void> signInWithEmailProvider(
    BuildContext context,
    String email,
    String password,
  );

  Future<void> requestPasswordReset(BuildContext context, String email);
  Future<void> signInWithGoogleProvider(BuildContext context);
  Future<void> signInAnonymously(BuildContext context);
  Future<void> signOut(BuildContext context);
}
