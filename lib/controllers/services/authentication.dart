import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:get_it/get_it.dart';
import 'package:mister/models/database/autonomous.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mister/models/interfaces/services/authentication.dart';
import 'package:mister/models/routes/app_routes.dart';
import 'package:mister/models/utils/constants.dart';
import 'package:mister/models/database/account.dart';

import 'package:mister/controllers/stores/account.dart';
import 'package:mister/controllers/stores/theme.dart';

class Authentication implements AuthenticationMethods {
  static final Authentication instance = Authentication();
  final FirebaseAuth _firebaseAuthentication = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseDatabase _firebaseDatabase = FirebaseDatabase.instance;

  Future<void> _navigateToMainScreen(BuildContext context) async {
    await Navigator.of(context).pushReplacementNamed(AppRoutes.mainScreen);
  }

  Future<void> _navigateToSignInScreen(BuildContext context) async {
    await Navigator.of(context).pushReplacementNamed(AppRoutes.signInScreen);
  }

  Future<void> _saveUserSession(BuildContext context, Account account) async {
    final AccountStore accountStore = GetIt.I.get<AccountStore>();
    accountStore.signIn(account);

    final SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setString(StoragedValues.userUID, account.id!);
    await preferences
        .setString(StoragedValues.profession, account.profession!)
        .then((_) async {
      await _navigateToMainScreen(context);
    });
  }

  Future<Widget?> _showDialogToUser(
    BuildContext context,
    String title,
    String content,
  ) async {
    return await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: <TextButton>[
          TextButton(
            onPressed: Navigator.of(context).pop,
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<Account?> _getUserAccountFromDatabase(String? userUID) async {
    if (userUID == null) return null;

    final DataSnapshot accountFromDatabase = (await _firebaseDatabase
        .ref()
        .child('users')
        .child('accounts')
        .child(userUID)
        .once()
        .then((value) => value.snapshot));

    if (!accountFromDatabase.exists) return null;

    final Account account = Account.convertFromDatabase(
        userUID, accountFromDatabase.value as Map<dynamic, dynamic>);
    return account;
  }

  Future<bool> _checkIfUserExistsInDatabase(String? userUID) async {
    if (userUID == null) return false;

    final userAccount = await _firebaseDatabase
        .ref()
        .child('users')
        .child('accounts')
        .child(userUID)
        .once();

    final bool userExistsInDatabase = userAccount.snapshot.exists;
    return userExistsInDatabase;
  }

  Future<void> _createNewAutonomousInDatabase(Autonomous autonomous) async {
    final String? id = autonomous.id;

    if (id != null) {
      await _firebaseDatabase
          .ref()
          .child('professions')
          .child(autonomous.profession!)
          .set({'profession': autonomous.profession});

      await _firebaseDatabase
          .ref()
          .child('users')
          .child('accounts')
          .child(id)
          .set({'profession': autonomous.profession});

      await _firebaseDatabase.ref().child('quickSearch').child(id).set({
        'name': autonomous.name,
        'profession': autonomous.profession,
      });

      await _firebaseDatabase
          .ref()
          .child('users')
          .child('autonomous')
          .child(autonomous.profession!)
          .child(id)
          .set(autonomous.convertToDatabaseWithRequiredData());
    }
  }

  @override
  Future<void> signUp(
    BuildContext context,
    String email,
    String password,
    Autonomous autonomous,
    VoidCallback callback,
  ) async {
    await _firebaseAuthentication
        .createUserWithEmailAndPassword(email: email, password: password)
        .then((userCredential) async {
      final user = userCredential.user;
      if (user != null) {
        autonomous.userUID = user.uid;
        await _createNewAutonomousInDatabase(autonomous);
        await user.sendEmailVerification();
        if (context.mounted) {
          await showDialog(
            barrierDismissible: false,
            context: context,
            builder: (_) => AlertDialog(
              title: const Text('Verifique seu e-mail!'),
              content: const Text(
                'Para proceder, é necessário que você verifique seu e-mail para utilizar o nosso aplicativo.',
              ),
              actions: <TextButton>[
                TextButton(
                  child: const Text('OK'),
                  onPressed: () async => await _navigateToSignInScreen(context),
                ),
              ],
            ),
          );
        }
      }
    }).catchError((error) async {
      callback();
      final String errorMessage = error.message;
      if (errorMessage.contains('badly formatted')) {
        await _showDialogToUser(
          context,
          'Ocorreu um erro!',
          'Seu endereço de e-mail está mal formatado.',
        );
      } else if (errorMessage.contains('is already in use')) {
        await _showDialogToUser(
          context,
          'Ocorreu um erro!',
          'O endereço de e-mail fornecido já se encontra em uso por outra conta.',
        );
      } else {
        await _showDialogToUser(
          context,
          'Ocorreu um erro!',
          'Houve algum problema ao tentar criar sua conta. Verifique se seu e-mail está correto, e tente novamente.',
        );
      }
    });
  }

  @override
  Future<void> signInWithEmailProvider(
    BuildContext context,
    String email,
    String password,
  ) async {
    await _firebaseAuthentication
        .signInWithEmailAndPassword(email: email, password: password)
        .then((userCredential) async {
      final user = userCredential.user;
      if (user != null) {
        final bool userNotHaveVerifiedEmail = !user.emailVerified;
        if (userNotHaveVerifiedEmail) {
          await user.sendEmailVerification();
          if (context.mounted) {
            await _showDialogToUser(
              context,
              'Verifique seu e-mail!',
              'Para proceder, é necessário que você verifique seu e-mail para utilizar o nosso aplicativo.',
            );
          }
        } else {
          final Account? account = await _getUserAccountFromDatabase(user.uid);
          if (account != null) {
            if (context.mounted) {
              await _saveUserSession(context, account);
            }
          }
        }
      }
    }).catchError((error) async {
      final String errorMessage = error.message;
      if (errorMessage.contains('badly formatted')) {
        await _showDialogToUser(
          context,
          'Ocorreu um erro!',
          'Seu endereço de e-mail está mal formatado.',
        );
      } else if (errorMessage.contains('is no user record')) {
        await _showDialogToUser(
          context,
          'Ocorreu um erro!',
          'Seu e-mail não está no nosso banco de dados, logo, você ainda não possui uma conta registrada.',
        );
      } else if (errorMessage.contains('password is invalid')) {
        await _showDialogToUser(
          context,
          'Ocorreu um erro!',
          'Sua senha está incorreta.',
        );
      } else if (errorMessage.contains('blocked all requests')) {
        await _showDialogToUser(
          context,
          'Bloqueio temporário',
          'Nós bloqueamos todas as requisições desse dispositivo por atividades suspeitas. Tente mais tarde.',
        );
      }
    });
  }

  @override
  Future<void> requestPasswordReset(BuildContext context, String email) async {
    await _firebaseAuthentication
        .sendPasswordResetEmail(email: email)
        .then((_) async {
      await _showDialogToUser(
        context,
        'Confira seu e-mail!',
        'Um e-mail foi encaminhado para sua caixa de entrada. Abra-o e redefina sua senha.',
      );
    }).catchError((error) async {
      if (error.message != null) {
        await _showDialogToUser(
          context,
          'Erro!',
          'Ocorreu algum erro ao tentar redefinir sua senha. Confira se seu e-mail está correto.',
        );
      }
    });
  }

  @override
  Future<void> signInWithGoogleProvider(BuildContext context) async {
    await _googleSignIn.signOut();
    final googleAccount = await _googleSignIn.signIn();
    if (googleAccount == null) return;

    final googleAuthentication = await googleAccount.authentication;
    final googleAuthenticationProviderCredential =
        GoogleAuthProvider.credential(
      accessToken: googleAuthentication.accessToken,
      idToken: googleAuthentication.idToken,
    );

    await _firebaseAuthentication
        .signInWithCredential(googleAuthenticationProviderCredential)
        .then((userCredential) async {
      final user = userCredential.user;
      if (user == null) return;

      final bool userExistsInDatabase =
          await _checkIfUserExistsInDatabase(user.uid);
      if (userExistsInDatabase) {
        final Account? account = await _getUserAccountFromDatabase(user.uid);
        if (context.mounted) {
          await _saveUserSession(context, account!);
        }
      } else {
        if (user.email != null) {
          if (context.mounted) {
            await _showDialogToUser(
              context,
              'Ocorreu um erro!',
              'Você ainda não possui uma conta. Faça seu cadastro e garanta seu lugar no nosso aplicativo!',
            );
          }
        }
      }
    });
  }

  @override
  Future<void> signInAnonymously(BuildContext context) async {
    final Account anonymousAccount = Account('none', 'none');
    await _saveUserSession(context, anonymousAccount);
  }

  @override
  Future<void> signOut(BuildContext context) async {
    final ThemeStore themeStore = GetIt.I.get<ThemeStore>();
    final AccountStore accountStore = GetIt.I.get<AccountStore>();
    accountStore.signOut();

    await themeStore.changeTheme(false).then((_) async {
      try {
        await _googleSignIn.disconnect();
        await _googleSignIn.signOut();
      } catch (_) {}
      await _firebaseAuthentication.signOut();

      final SharedPreferences preferences =
          await SharedPreferences.getInstance();
      await preferences.clear();
      if (context.mounted) {
        await Navigator.of(context)
            .pushReplacementNamed(AppRoutes.initialScreen);
      }
    });
  }
}
