import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

import 'package:mister/models/database/autonomous.dart';

import 'package:mister/views/widgets/autonomous_list.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const int _professionsQueryLimit = 20;

  final FirebaseDatabase _firebaseDatabase = FirebaseDatabase.instance;
  List<String> _professions = [];
  List<Autonomous> _autonomous = [];

  void _clearDataStates() {
    setState(() {
      _professions = [];
      _autonomous = [];
    });
  }

  Future<void> _getProfessionsFromDatabase() async {
    await _firebaseDatabase
        .ref()
        .child('professions')
        .limitToLast(_professionsQueryLimit)
        .once()
        .then((snapshot) {
      final Map<String, dynamic> professionsFromDatabase =
          Map<String, dynamic>.from(
              snapshot.snapshot.value as Map<dynamic, dynamic>);

      professionsFromDatabase.forEach((_, value) {
        final String profession = value['profession'];
        setState(() {
          _professions.add(profession);
        });
      });
    });
  }

  Future<void> _getAutonomousFromDatabase() async {
    if (_professions.isNotEmpty) {
      await _firebaseDatabase
          .ref()
          .child('users')
          .child('autonomous')
          .limitToFirst(_professionsQueryLimit)
          .once()
          .then((snapshot) {
        final Map<String, dynamic> professionsFromDatabase =
            Map<String, dynamic>.from(
                snapshot.snapshot.value as Map<dynamic, dynamic>);
        professionsFromDatabase.forEach((_, value) {
          final autonomousFromDatabase = Map<String, dynamic>.from(value);
          autonomousFromDatabase.forEach((id, data) {
            final Map<String, dynamic> autonomousFormatted =
                Map<String, dynamic>.from(data);

            final Autonomous autonomous =
                Autonomous.convertFromDatabase(autonomousFormatted);

            autonomous.userUID = id;
            setState(() {
              _autonomous.add(autonomous);
            });
          });
        });
      });
    }
  }

  Future<void> _getDataFromDatabase() async {
    _clearDataStates();
    await _getProfessionsFromDatabase().then((_) async {
      await _getAutonomousFromDatabase();
    });
  }

  List<Autonomous> _filterAutonomousByProfession(String profession) {
    return _autonomous
        .where((autonomous) => autonomous.profession == profession)
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _getDataFromDatabase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Descubra quais são os profissionais que estão ao seu redor.',
              style: TextStyle(
                color: Color(0xFF151054),
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _getDataFromDatabase,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 20),
                itemCount: _professions.length,
                itemBuilder: (_, index) => AutonomousList(
                  key: UniqueKey(),
                  profession: _professions[index],
                  autonomous: _filterAutonomousByProfession(
                    _professions[index],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
