import 'package:flutter/material.dart';

import 'package:mister/models/database/autonomous.dart';
import 'package:mister/models/routes/app_routes.dart';

import 'package:mister/views/screens/autonomous_details.dart';

class AutonomousCard extends StatelessWidget {
  const AutonomousCard({
    Key? key,
    required this.autonomous,
    required this.heroTagComplement,
  }) : super(key: key);

  final Autonomous autonomous;
  final String heroTagComplement;

  Future<void> _navigateToAutonomousDetailsScreen(BuildContext context) async {
    await Navigator.of(context).pushNamed(
      AppRoutes.autonomousDetailsScreen,
      arguments: AutonomousDetailsArguments(autonomous, heroTagComplement),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async => await _navigateToAutonomousDetailsScreen(context),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        child: SizedBox(
          width: 220,
          height: 150,
          child: Card(
            color: const Color(0xFFE0E0E0),
            child: ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(4)),
              child: Stack(
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Hero(
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
                      ),
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          color: const Color.fromRGBO(21, 14, 84, 0.8),
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  autonomous.name ?? '',
                                  overflow: TextOverflow.fade,
                                  softWrap: false,
                                  style: const TextStyle(
                                    color: Color(0xFFFFFFFF),
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Row(
                                  children: <Widget>[
                                    const Icon(
                                      Icons.location_on,
                                      color: Color(0xFFFFFFFF),
                                    ),
                                    const SizedBox(width: 8),
                                    Flexible(
                                      child: Text(
                                        autonomous.location?.address ?? '',
                                        overflow: TextOverflow.fade,
                                        softWrap: false,
                                        style: const TextStyle(
                                          color: Color(0xFFFFFFFF),
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
