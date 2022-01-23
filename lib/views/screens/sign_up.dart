import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:mister/models/database/autonomous.dart';
import 'package:mister/models/routes/app_routes.dart';

import 'package:mister/controllers/services/authentication.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final Authentication _authentication = Authentication.instance;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _professionController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  bool _isPasswordObscure = true;
  bool _hasAcceptedThePrivacyPolicy = false;
  bool _hasAcceptedTheTermsOfUse = false;
  bool _isLoading = false;

  void _dismissKeyboard() {
    FocusScope.of(context).unfocus();
  }

  void _jumpToNextTextField() {
    FocusScope.of(context).nextFocus();
  }

  void _changePasswordVisibility() {
    setState(() {
      _isPasswordObscure = !_isPasswordObscure;
    });
  }

  void _switcHasAcceptedThePrivacyPolicyState() {
    setState(() {
      _hasAcceptedThePrivacyPolicy = !_hasAcceptedThePrivacyPolicy;
    });
  }

  void _switcHasAcceptedTheTermsOfUseState() {
    setState(() {
      _hasAcceptedTheTermsOfUse = !_hasAcceptedTheTermsOfUse;
    });
  }

  Future<void> _notifyUserAboutPolicyPrivacyAndTermsOfUse() async {
    await showDialog(
      context: context,
      builder: (_) => const AlertDialog(
        content: Text(
          'Você deve aceitar nossa Política de Privacidade e Termos de Uso para criar uma conta!',
          textAlign: TextAlign.justify,
        ),
      ),
    );
  }

  void _showLoadingToUser() {
    setState(() {
      _isLoading = true;
    });
  }

  void _dismissLoading() {
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _createNewAutonomous() async {
    _dismissKeyboard();

    final String email = _emailController.text.toLowerCase();
    final String password = _passwordController.text;
    final String name = _nameController.text;
    final String phone = _phoneController.text;
    final String profession = _professionController.text;
    final String address = _addressController.text;

    final bool allFieldsAreFilled = email.isNotEmpty &&
        password.length >= 6 &&
        name.isNotEmpty &&
        phone.isNotEmpty &&
        profession.isNotEmpty &&
        address.isNotEmpty;

    if (allFieldsAreFilled) {
      if (_hasAcceptedThePrivacyPolicy && _hasAcceptedTheTermsOfUse) {
        _showLoadingToUser();

        Autonomous autonomous = Autonomous(
          email: email,
          name: name,
          phone: phone,
          profession: profession,
          location: AutonomousLocation(address: address),
        );

        await _authentication.signUp(
          context,
          email,
          password,
          autonomous,
          _dismissLoading,
        );
      } else {
        _notifyUserAboutPolicyPrivacyAndTermsOfUse();
      }
    }
  }

  Future<void> _openUrl(String url) async {
    _dismissKeyboard();
    await launch(url);
  }

  Future<void> _navigateToSignInScreen() async {
    _dismissKeyboard();
    await Navigator.of(context).pushReplacementNamed(AppRoutes.signInScreen);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _professionController.dispose();
    _addressController.dispose();
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Center(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: <Widget>[
                      TextField(
                        controller: _emailController,
                        onEditingComplete: _jumpToNextTextField,
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
                      TextField(
                        controller: _passwordController,
                        obscureText: _isPasswordObscure,
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
                      const SizedBox(height: 20),
                      const Divider(color: Color(0xFFB6AFFF), height: 20),
                      TextField(
                        controller: _nameController,
                        onEditingComplete: _jumpToNextTextField,
                        textCapitalization: TextCapitalization.words,
                        style: const TextStyle(
                          fontSize: 18,
                          color: Color(0xFF151054),
                        ),
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.person),
                          hintText: 'Nome completo',
                          hintStyle: TextStyle(
                            color: Color(0xFFB6AFFF),
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      TextField(
                        controller: _phoneController,
                        onEditingComplete: _jumpToNextTextField,
                        keyboardType: TextInputType.phone,
                        style: const TextStyle(
                          fontSize: 18,
                          color: Color(0xFF151054),
                        ),
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.phone),
                          hintText: 'Número de telefone',
                          hintStyle: TextStyle(
                            color: Color(0xFFB6AFFF),
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      TextField(
                        controller: _professionController,
                        onEditingComplete: _jumpToNextTextField,
                        textCapitalization: TextCapitalization.words,
                        style: const TextStyle(
                          fontSize: 18,
                          color: Color(0xFF151054),
                        ),
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.work),
                          hintText: 'Profissão',
                          hintStyle: TextStyle(
                            color: Color(0xFFB6AFFF),
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      TextField(
                        controller: _addressController,
                        textCapitalization: TextCapitalization.words,
                        style: const TextStyle(
                          fontSize: 18,
                          color: Color(0xFF151054),
                        ),
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.location_on),
                          hintText: 'Endereço',
                          hintStyle: TextStyle(
                            color: Color(0xFFB6AFFF),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      FittedBox(
                        child: SizedBox(
                          height: 40,
                          child: TextButton(
                            onPressed: _switcHasAcceptedThePrivacyPolicyState,
                            child: Padding(
                              padding: const EdgeInsets.only(right: 15),
                              child: Row(
                                children: <Widget>[
                                  Radio(
                                    groupValue: true,
                                    value: _hasAcceptedThePrivacyPolicy,
                                    onChanged: (_) =>
                                        _switcHasAcceptedThePrivacyPolicyState(),
                                  ),
                                  const Text(
                                    'Li e concordo com a ',
                                    style: TextStyle(
                                      color: Color(0xFFB6AFFF),
                                      fontSize: 14,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => _openUrl(
                                      'https://drive.google.com/file/d/1EkRqQmHwuxFaFMK5stumh3wEY3ZvCZcO/view',
                                    ),
                                    child: const Text(
                                      'Política de Privacidade',
                                      style: TextStyle(
                                        color: Color(0xFF151054),
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      FittedBox(
                        child: SizedBox(
                          height: 40,
                          child: TextButton(
                            onPressed: _switcHasAcceptedTheTermsOfUseState,
                            child: Padding(
                              padding: const EdgeInsets.only(right: 15),
                              child: Row(
                                children: <Widget>[
                                  Radio(
                                    groupValue: true,
                                    value: _hasAcceptedTheTermsOfUse,
                                    onChanged: (_) =>
                                        _switcHasAcceptedTheTermsOfUseState(),
                                  ),
                                  const Text(
                                    'Li e concordo com os ',
                                    style: TextStyle(
                                      color: Color(0xFFB6AFFF),
                                      fontSize: 16.5,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => _openUrl(
                                      'https://drive.google.com/file/d/1F3_6IYC5TsiMaYY3ESs5kAI7Dt0v_JiT/view',
                                    ),
                                    child: const Text(
                                      'Termos de Uso',
                                      style: TextStyle(
                                        color: Color(0xFF151054),
                                        fontSize: 16.5,
                                        fontWeight: FontWeight.bold,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: !_isLoading ? _createNewAutonomous : null,
                        child: !_isLoading
                            ? const Text(
                                'Cadastrar',
                                style: TextStyle(
                                  fontSize: 18,
                                ),
                              )
                            : const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator.adaptive(
                                  strokeWidth: 2,
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
                      TextButton(
                        onPressed: _navigateToSignInScreen,
                        child: RichText(
                          text: const TextSpan(
                            style: TextStyle(
                              color: Color(0xFFB6AFFF),
                            ),
                            children: <TextSpan>[
                              TextSpan(
                                text: 'Já possui uma conta? ',
                              ),
                              TextSpan(
                                text: 'Então entre!',
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
