import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:mister/models/database/autonomous.dart';

import 'package:mister/views/widgets/autonomous_list.dart';

class AutonomousDetailsArguments {
  AutonomousDetailsArguments(this.autonomous, this.heroTagComplement);

  final Autonomous autonomous;
  final String heroTagComplement;
}

class AutonomousDetailsScreen extends StatelessWidget {
  AutonomousDetailsScreen({Key? key}) : super(key: key);

  final FirebaseDatabase _firebaseDatabase = FirebaseDatabase.instance;
  final int _similarAutonomousQueryLimit = 10;

  Widget _renderCustomListTile(IconData icon, String? title) {
    if (title == null) return Container();

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
      iconColor: const Color(0xFF4267B2),
      leading: Icon(
        icon,
        size: 30,
      ),
      title: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Future<List<Autonomous>> _getSimilarAutonomousFromDatabase(
    String id,
    String profession,
  ) async {
    final List<Autonomous> _similarAutonomous = [];

    await _firebaseDatabase
        .reference()
        .child('users')
        .child('autonomous')
        .child(profession)
        .limitToLast(_similarAutonomousQueryLimit)
        .once()
        .then((snapshot) {
      final Map<String, dynamic> similarAutonomousFromDatabase =
          Map<String, dynamic>.from(snapshot.value);

      similarAutonomousFromDatabase.forEach((key, value) {
        final autonomousFromDatabase = Map<String, dynamic>.from(value);
        final Autonomous autonomous =
            Autonomous.convertFromDatabase(autonomousFromDatabase);

        autonomous.userUID = key;
        _similarAutonomous.add(autonomous);
      });
    });

    return _similarAutonomous
        .where((autonomous) => autonomous.id != id)
        .toList();
  }

  Autonomous _getAutonomousFromModalRoute(BuildContext context) {
    final AutonomousDetailsArguments modalRouteArguments =
        ModalRoute.of(context)!.settings.arguments
            as AutonomousDetailsArguments;

    return modalRouteArguments.autonomous;
  }

  String _getHeroTagComplementFromModalRoute(BuildContext context) {
    final AutonomousDetailsArguments modalRouteArguments =
        ModalRoute.of(context)!.settings.arguments
            as AutonomousDetailsArguments;

    return modalRouteArguments.heroTagComplement;
  }

  @override
  Widget build(BuildContext context) {
    final Autonomous autonomous = _getAutonomousFromModalRoute(context);
    final String heroTagComplement =
        _getHeroTagComplementFromModalRoute(context);

    final getSimilarAutonomous = _getSimilarAutonomousFromDatabase(
      autonomous.id ?? '',
      autonomous.profession ?? '',
    );

    return SafeArea(
      child: Scaffold(
        body: CustomScrollView(
          slivers: <Widget>[
            SliverAppBar(
              backgroundColor: const Color(0xFF151054),
              pinned: true,
              expandedHeight: 200,
              flexibleSpace: FlexibleSpaceBar(
                title: Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Text(
                      autonomous.name ?? '',
                      softWrap: false,
                    ),
                  ),
                ),
                background: Stack(
                  children: <Widget>[
                    if (autonomous.bannerUrl != null)
                      Center(
                        child: Image.network(
                          autonomous.bannerUrl!,
                          height: double.infinity,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      )
                    else
                      Container(),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 70,
                        vertical: 16,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Hero(
                            tag: (autonomous.id ?? 'Default') +
                                heroTagComplement,
                            child: CircleAvatar(
                              maxRadius: 40,
                              backgroundColor: const Color(0xFFEEEEEE),
                              foregroundImage: autonomous.avatarUrl != null
                                  ? NetworkImage(autonomous.avatarUrl!)
                                  : null,
                              child: const Icon(
                                Icons.person,
                                color: Color(0xFF9E9E9E),
                                size: 40,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Text(
                              autonomous.profession ?? '',
                              style: const TextStyle(
                                color: Color(0xFFFFFFFF),
                                fontSize: 22,
                                fontWeight: FontWeight.w500,
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
            SliverList(
              delegate: SliverChildListDelegate([
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Column(
                    children: <Widget>[
                      const Text(
                        'Informações',
                        style: TextStyle(
                          color: Color(0xFF333333),
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _renderCustomListTile(Icons.person, autonomous.name),
                      _renderCustomListTile(Icons.work, autonomous.profession),
                      _renderCustomListTile(
                        Icons.location_on,
                        autonomous.location?.address,
                      ),
                      _renderCustomListTile(Icons.phone, autonomous.phone),
                      _renderCustomListTile(Icons.email, autonomous.email),
                      _renderCustomListTile(
                        Icons.facebook,
                        autonomous.socialNetworks?.facebook,
                      ),
                      _renderCustomListTile(
                        FontAwesomeIcons.instagram,
                        autonomous.socialNetworks?.instagram,
                      ),
                      const SizedBox(height: 40),
                      FutureBuilder(
                        future: getSimilarAutonomous,
                        builder: (_, AsyncSnapshot<List<Autonomous>> snapshot) {
                          return AutonomousList(
                            profession: 'Veja similares',
                            autonomous: snapshot.data ?? [],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}
