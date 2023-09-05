import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

import 'package:mister/models/database/autonomous.dart';
import 'package:mister/models/routes/app_routes.dart';

import 'package:mister/views/screens/autonomous_details.dart';

class AutonomousListTile extends StatelessWidget {
  AutonomousListTile({
    Key? key,
    required this.autonomous,
    required this.heroTagComplement,
  }) : super(key: key);

  final FirebaseDatabase _firebaseDatabase = FirebaseDatabase.instance;

  final Autonomous autonomous;
  final String heroTagComplement;

  Future<Autonomous> _getAutonomousData() async {
    return await _firebaseDatabase
        .ref()
        .child('users')
        .child('autonomous')
        .child(autonomous.profession ?? '')
        .child(autonomous.id ?? '')
        .once()
        .then((snapshot) {
      final Map<String, dynamic> autonomousFormatted =
          Map<String, dynamic>.from(
              snapshot.snapshot.value as Map<dynamic, dynamic>);

      final Autonomous autonomousFromDatabase =
          Autonomous.convertFromDatabase(autonomousFormatted);
      autonomousFromDatabase.userUID = snapshot.snapshot.key ?? '';
      return autonomousFromDatabase;
    });
  }

  Future<void> _navigateToAutonomousDetailsScreen(BuildContext context) async {
    await _getAutonomousData().then(
      (Autonomous autonomousFromDatabase) async {
        await Navigator.of(context).pushNamed(
          AppRoutes.autonomousDetailsScreen,
          arguments: AutonomousDetailsArguments(
            autonomousFromDatabase,
            heroTagComplement,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      key: key,
      onTap: () => _navigateToAutonomousDetailsScreen(context),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 4,
      ),
      title: Text(
        autonomous.name ?? '',
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(
        autonomous.profession ?? '',
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      leading: Hero(
        tag: (autonomous.id ?? 'Default') + heroTagComplement,
        child: CircleAvatar(
          maxRadius: 30,
          backgroundColor: const Color(0xFFEEEEEE),
          foregroundImage: autonomous.avatarUrl != null
              ? NetworkImage(autonomous.avatarUrl!)
              : null,
          child: const Icon(
            Icons.person,
            color: Color(0xFF9E9E9E),
            size: 30,
          ),
        ),
      ),
    );
  }
}
