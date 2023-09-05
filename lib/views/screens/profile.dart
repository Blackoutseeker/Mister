import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:mister/models/database/autonomous.dart';
import 'package:mister/models/routes/app_routes.dart';
import 'package:mister/models/utils/constants.dart';

import 'package:mister/controllers/services/authentication.dart';
import 'package:mister/controllers/stores/autonomous.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseDatabase _firebaseDatabase = FirebaseDatabase.instance;
  final Authentication _authentication = Authentication.instance;
  final AutonomousStore _autonomousStore = GetIt.I.get<AutonomousStore>();

  String _userUID = '';

  Future<void> _navigateToSignUpScreen() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.clear().then((_) async {
      await Navigator.of(context).pushReplacementNamed(AppRoutes.signUpScreen);
    });
  }

  Future<void> _navigateToEditProfileScreen() async {
    await Navigator.of(context).pushNamed(AppRoutes.editProfileScreen);
  }

  Future<void> _getUserUIDFromLocalStorage() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    final String? userUID = preferences.getString(StoragedValues.userUID);
    if (userUID == null) return;

    setState(() {
      _userUID = userUID;
    });
  }

  Future<Autonomous> _getAutonomousFromDatabase() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    final String? profession = preferences.getString(StoragedValues.profession);
    if (profession == null) return Autonomous();

    return await _firebaseDatabase
        .ref()
        .child('users')
        .child('autonomous')
        .child(profession)
        .child(_userUID)
        .once()
        .then((snapshot) {
      final Map<String, dynamic> autonomousFormatted =
          Map<String, dynamic>.from(
              snapshot.snapshot.value as Map<dynamic, dynamic>);

      final Autonomous autonomous =
          Autonomous.convertFromDatabase(autonomousFormatted);

      autonomous.userUID = _userUID;
      return autonomous;
    });
  }

  Future<void> _deleteUserFromDatabase(String id, String profession) async {
    await _firebaseDatabase
        .ref()
        .child('users')
        .child('accounts')
        .child(id)
        .remove()
        .then((_) async {
      await _firebaseDatabase
          .ref()
          .child('quickSearch')
          .child(id)
          .remove()
          .then((_) async {
        await _firebaseDatabase
            .ref()
            .child('users')
            .child('autonomous')
            .child(profession)
            .child(id)
            .remove();
      }).then((_) async {
        await _authentication.signOut(context);
      });
    });
  }

  Future<void> _showDialogToUser(
    String content,
    void Function() onConfirming,
  ) async {
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Você tem certeza?'),
        content: Text(content),
        actions: <TextButton>[
          TextButton(
            onPressed: onConfirming,
            child: const Text('SIM'),
          ),
          TextButton(
            onPressed: Navigator.of(context).pop,
            child: const Text('NÃO'),
          ),
        ],
      ),
    );
  }

  Future<void> _showAccountDeleteConfirmation(
    String id,
    String profession,
  ) async {
    await _showDialogToUser(
      'Sua conta será excluída de forma permanente!',
      () async => await _deleteUserFromDatabase(id, profession),
    );
  }

  Future<void> _showSignOutConfirmation() async {
    await _showDialogToUser(
      'Sua conta continuará salva, não se preocupe!',
      () async => await _authentication.signOut(context),
    );
  }

  Widget _renderCustomListTile({
    required IconData icon,
    required Color iconColor,
    String? title,
    Color? titleColor,
    void Function()? onTap,
  }) {
    if (title == null) return Container();

    return ListTile(
      onTap: onTap,
      iconColor: iconColor,
      leading: Icon(
        icon,
        size: 30,
      ),
      title: Text(
        title,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: titleColor,
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _getUserUIDFromLocalStorage();
  }

  @override
  Widget build(BuildContext context) {
    if (_userUID == 'none') {
      return Scaffold(
        body: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Column(
            children: <Widget>[
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Ainda não tem uma conta profissional? Faça agora e garanta seu lugar no nosso app!',
                  style: TextStyle(
                    color: Color(0xFF333333),
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: ElevatedButton(
                  onPressed: _navigateToSignUpScreen,
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(
                      const Color(0xFF151054),
                    ),
                    minimumSize: MaterialStateProperty.all(
                      const Size(double.infinity, 40),
                    ),
                  ),
                  child: const Text(
                    'Criar conta',
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: FutureBuilder(
        future: _getAutonomousFromDatabase(),
        builder: (_, AsyncSnapshot<Autonomous> autonomous) {
          _autonomousStore.setAutonomous(autonomous.data ?? Autonomous());
          return Observer(
            builder: (_) => CustomScrollView(
              slivers: <Widget>[
                SliverAppBar(
                  backgroundColor: const Color(0xFF151054),
                  pinned: true,
                  expandedHeight: 140,
                  flexibleSpace: FlexibleSpaceBar(
                    titlePadding: const EdgeInsets.all(16),
                    title: Text(
                      _autonomousStore.autonomous.name ?? '',
                      overflow: TextOverflow.fade,
                      softWrap: false,
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    background: Stack(
                      children: <Widget>[
                        if (_autonomousStore.autonomous.bannerUrl != null)
                          Center(
                            child: Image.network(
                              _autonomousStore.autonomous.bannerUrl!,
                              height: double.infinity,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          )
                        else
                          Container(),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Hero(
                            tag:
                                '${_autonomousStore.autonomous.id ?? 'Default'}profile',
                            child: CircleAvatar(
                              maxRadius: 35,
                              backgroundColor: const Color(0xFFEEEEEE),
                              foregroundImage:
                                  _autonomousStore.autonomous.avatarUrl != null
                                      ? NetworkImage(
                                          _autonomousStore
                                              .autonomous.avatarUrl!,
                                        )
                                      : null,
                              child: const Icon(
                                Icons.person,
                                color: Color(0xFF9E9E9E),
                                size: 35,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildListDelegate([
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Column(
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              const Text(
                                'Suas informações',
                                style: TextStyle(
                                  color: Color(0xFF333333),
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 20),
                              IconButton(
                                onPressed: _navigateToEditProfileScreen,
                                icon: const Icon(
                                  Icons.edit,
                                  color: Color(0xFF999999),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          _renderCustomListTile(
                            icon: Icons.person,
                            iconColor: const Color(0xFF4267B2),
                            title: _autonomousStore.autonomous.name,
                          ),
                          _renderCustomListTile(
                            icon: Icons.work,
                            iconColor: const Color(0xFF4267B2),
                            title: _autonomousStore.autonomous.profession,
                          ),
                          _renderCustomListTile(
                            icon: Icons.location_on,
                            iconColor: const Color(0xFF4267B2),
                            title:
                                _autonomousStore.autonomous.location?.address,
                          ),
                          _renderCustomListTile(
                            icon: Icons.phone,
                            iconColor: const Color(0xFF4267B2),
                            title: _autonomousStore.autonomous.phone,
                          ),
                          _renderCustomListTile(
                            icon: Icons.email,
                            iconColor: const Color(0xFF4267B2),
                            title: _autonomousStore.autonomous.email,
                          ),
                          _renderCustomListTile(
                            icon: Icons.facebook,
                            iconColor: const Color(0xFF4267B2),
                            title: _autonomousStore
                                .autonomous.socialNetworks?.facebook,
                          ),
                          _renderCustomListTile(
                            icon: FontAwesomeIcons.instagram,
                            iconColor: const Color(0xFF4267B2),
                            title: _autonomousStore
                                .autonomous.socialNetworks?.instagram,
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Divider(
                              height: 40,
                              color: Color(0xFF999999),
                            ),
                          ),
                          _renderCustomListTile(
                            icon: Icons.delete,
                            iconColor: const Color(0xFF999999),
                            title: 'Deletar conta',
                            titleColor: const Color(0xFF777777),
                            onTap: () async =>
                                await _showAccountDeleteConfirmation(
                              _autonomousStore.autonomous.id ?? '',
                              _autonomousStore.autonomous.profession ?? '',
                            ),
                          ),
                          _renderCustomListTile(
                            icon: Icons.logout,
                            iconColor: const Color(0xFF999999),
                            title: 'Sair',
                            titleColor: const Color(0xFF777777),
                            onTap: _showSignOutConfirmation,
                          ),
                        ],
                      ),
                    ),
                  ]),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
