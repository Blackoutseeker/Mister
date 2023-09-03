import 'package:flutter/material.dart';

import 'package:mister/models/routes/app_routes.dart';

import 'package:mister/controllers/services/authentication.dart';

class InitialScreen extends StatelessWidget {
  InitialScreen({Key? key}) : super(key: key);

  final Authentication _authentication = Authentication.instance;

  Future<void> _navigateSignUpScreen(BuildContext context) async {
    await Navigator.of(context).pushReplacementNamed(AppRoutes.signUpScreen);
  }

  Future<void> _navigateToSignInScreen(BuildContext context) async {
    await Navigator.of(context).pushReplacementNamed(AppRoutes.signInScreen);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFFFFFFF),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: <Widget>[
              const SizedBox(height: 20),
              const SizedBox(
                width: double.infinity,
                child: Text(
                  'Mister',
                  style: TextStyle(
                    color: Color(0xFF151054),
                    fontSize: 38,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                'Encontre quem você precisa, sem precisar sair de casa.',
                textAlign: TextAlign.left,
                style: TextStyle(
                  color: Color(0xFF151054),
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  children: <Widget>[
                    ElevatedButton(
                      onPressed: () => _navigateSignUpScreen(context),
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(
                          const Color(0xFF151054),
                        ),
                        minimumSize: MaterialStateProperty.all(
                          const Size(double.infinity, 40),
                        ),
                      ),
                      child: const Text(
                        'Cadastre-se',
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () => _navigateToSignInScreen(context),
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(
                          const Color(0xFF4267B2),
                        ),
                        minimumSize: MaterialStateProperty.all(
                          const Size(double.infinity, 40),
                        ),
                      ),
                      child: const Text(
                        'Entrar',
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    TextButton(
                      onPressed: () async =>
                          await _authentication.signInAnonymously(context),
                      child: const Text(
                        'Testar sem cadastro',
                        style: TextStyle(
                          color: Color(0xFF4267B2),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
