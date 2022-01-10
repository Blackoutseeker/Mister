import 'dart:math';
import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:mister/models/database/autonomous.dart';

import 'package:mister/views/widgets/autonomous_card.dart';

class AutonomousList extends StatelessWidget {
  const AutonomousList({
    Key? key,
    required this.profession,
    required this.autonomous,
  }) : super(key: key);

  final String profession;
  final List<Autonomous> autonomous;

  String getRandomHeroTagComplement({int length = 10}) {
    final Random random = Random.secure();
    final List<int> values =
        List<int>.generate(length, (i) => random.nextInt(255));

    return base64UrlEncode(values);
  }

  @override
  Widget build(BuildContext context) {
    if (autonomous.isEmpty) return Container();

    return SizedBox(
      width: double.infinity,
      height: 216,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Text(
              profession,
              style: const TextStyle(
                color: Color(0xFF333333),
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Divider(
              height: 10,
              color: Color(0xFF999999),
            ),
          ),
          SizedBox(
            width: double.infinity,
            height: 150,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              scrollDirection: Axis.horizontal,
              itemCount: autonomous.length,
              itemBuilder: (_, index) => AutonomousCard(
                key: UniqueKey(),
                autonomous: autonomous[index],
                heroTagComplement: getRandomHeroTagComplement(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
