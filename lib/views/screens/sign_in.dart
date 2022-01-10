import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:mister/models/routes/app_routes.dart';

import 'package:mister/controllers/services/authentication.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final Authentication _authentication = Authentication.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordObscure = true;

  void _dismissKeyboard() {
    FocusScope.of(context).unfocus();
  }

  void _changePasswordVisibility() {
    setState(() {
      _isPasswordObscure = !_isPasswordObscure;
    });
  }

  Future<void> _resetPassword() async {
    _dismissKeyboard();
    final String email = _emailController.text;
    if (email.isNotEmpty) {
      await _authentication.requestPasswordReset(context, email);
    }
  }

  Future<void> _signInWithEmailAndPassword() async {
    _dismissKeyboard();
    final String email = _emailController.text;
    final String password = _passwordController.text;

    if (email.isNotEmpty && password.length >= 6) {
      await _authentication.signInWithEmailProvider(context, email, password);
    }
  }

  Future<void> _signInWithGoogle() async {
    _dismissKeyboard();
    await _authentication.signInWithGoogleProvider(context);
  }

  Future<void> _navigateToSignUpScreen() async {
    _dismissKeyboard();
    await Navigator.of(context).pushReplacementNamed(AppRoutes.signUpScreen);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFFFFFFF),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          toolbarHeight: 80,
          title: const Text('Mister'),
          titleTextStyle: const TextStyle(
            color: Color(0xFF151054),
            fontSize: 38,
            fontWeight: FontWeight.bold,
          ),
        ),
        body: GestureDetector(
          onTap: _dismissKeyboard,
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: const TextStyle(
                          fontSize: 18,
                          color: Color(0xFF151054),
                        ),
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.email),
                          hintText: 'E-mail',
                          hintStyle: TextStyle(
                            color: Color(0xFFB6AFFF),
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      TextButton(
                        onPressed: _resetPassword,
                        child: const Text(
                          'Esqueci minha senha',
                          style: TextStyle(
                            color: Color(0xFFB6AFFF),
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      TextField(
                        controller: _passwordController,
                        obscureText: _isPasswordObscure,
                        onEditingComplete: _signInWithEmailAndPassword,
                        style: const TextStyle(
                          fontSize: 18,
                          color: Color(0xFF151054),
                        ),
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.vpn_key),
                          suffixIcon: IconButton(
                            onPressed: _changePasswordVisibility,
                            icon: Icon(
                              _isPasswordObscure
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                          ),
                          hintText: 'Senha',
                          hintStyle: const TextStyle(
                            color: Color(0xFFB6AFFF),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: _signInWithEmailAndPassword,
                        child: const Text(
                          'Entrar',
                          style: TextStyle(
                            fontSize: 18,
                          ),
                        ),
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(
                            const Color(0xFF151054),
                          ),
                          minimumSize: MaterialStateProperty.all(
                            const Size(double.infinity, 40),
                          ),
                        ),
                      ),
                      const Divider(color: Color(0xFFB6AFFF), height: 10),
                      ElevatedButton.icon(
                        onPressed: _signInWithGoogle,
                        icon: const FaIcon(FontAwesomeIcons.google),
                        label: const Text(
                          'Entrar com Google',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(
                            const Color(0xFFF41911),
                          ),
                          minimumSize: MaterialStateProperty.all(
                            const Size(double.infinity, 40),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextButton(
                        onPressed: _navigateToSignUpScreen,
                        child: RichText(
                          text: const TextSpan(
                            style: TextStyle(
                              color: Color(0xFFB6AFFF),
                            ),
                            children: <TextSpan>[
                              TextSpan(
                                text: 'Não possui uma conta? ',
                              ),
                              TextSpan(
                                text: 'Crie agora!',
                                style: TextStyle(
                                  color: Color(0xFF151054),
                                ),
                              ),
                            ],
                          ),
                        ),
                        style: ButtonStyle(
                          minimumSize: MaterialStateProperty.all(
                            const Size(double.infinity, 40),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
