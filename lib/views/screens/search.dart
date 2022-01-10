import 'dart:math';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

import 'package:mister/models/database/autonomous.dart';

import 'package:mister/views/widgets/search/autonomous_list_tile.dart';
import 'package:mister/views/widgets/autonomous_list.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  static const int _professionsQueryLimit = 10;

  final FirebaseDatabase _firebaseDatabase = FirebaseDatabase.instance;
  List<String> _professions = [];
  List<Autonomous> _autonomous = [];
  List<Autonomous> _quickAutonomous = [];
  List<Autonomous> _filteredQuickAutonomous = [];

  final TextEditingController _searchInputController = TextEditingController();
  final FocusNode _searchInputFocusNode = FocusNode();
  bool _isSearching = false;

  void _clearSearchInputText() {
    _searchInputController.clear();
    setState(() {
      _filteredQuickAutonomous = _quickAutonomous;
    });
  }

  void _dismissKeyboard() {
    _searchInputFocusNode.unfocus();
  }

  void _switchAppBar() {
    setState(() {
      _isSearching = !_isSearching;
    });
  }

  void _dismissSearchBar() {
    _dismissKeyboard();
    _switchAppBar();
    _clearSearchInputText();
  }

  void _filterQuickAutonomous(String text) {
    setState(() {
      _filteredQuickAutonomous = _quickAutonomous.where((autonomous) {
        return autonomous.name!.toLowerCase().contains(text.toLowerCase()) ||
            autonomous.profession!.toLowerCase().contains(text.toLowerCase());
      }).toList();
    });
  }

  String getRandomHeroTagComplement({int length = 10}) {
    final Random random = Random.secure();
    final List<int> values =
        List<int>.generate(length, (i) => random.nextInt(255));

    return base64UrlEncode(values);
  }

  AppBar _renderAppBar() {
    if (_isSearching) {
      return AppBar(
        backgroundColor: const Color(0xFFFFFFFF),
        title: SizedBox(
          child: TextField(
            controller: _searchInputController,
            focusNode: _searchInputFocusNode,
            onChanged: _filterQuickAutonomous,
            autofocus: true,
            style: const TextStyle(
              color: Color(0xFF333333),
              fontSize: 18,
            ),
            decoration: const InputDecoration(
              hintText: 'Pesquisar profissional',
              hintStyle: TextStyle(
                color: Color(0xFF999999),
              ),
              border: InputBorder.none,
            ),
          ),
        ),
        leading: IconButton(
          onPressed: _dismissSearchBar,
          icon: const Icon(
            Icons.arrow_back,
            color: Color(0xFF999999),
          ),
        ),
        actions: <IconButton>[
          IconButton(
            onPressed: _clearSearchInputText,
            icon: const Icon(
              Icons.close,
              color: Color(0xFF999999),
            ),
          ),
        ],
      );
    } else {
      return AppBar(
        backgroundColor: const Color(0xFF4267B2),
        title: const Text('Pesquisar profissionais'),
        leading: IconButton(
          onPressed: _switchAppBar,
          icon: const Icon(Icons.search),
        ),
      );
    }
  }

  void _clearDataStates() {
    setState(() {
      _professions = [];
      _autonomous = [];
      _quickAutonomous = [];
      _filteredQuickAutonomous = [];
    });
  }

  Future<void> _getProfessionsFromDatabase() async {
    await _firebaseDatabase
        .reference()
        .child('professions')
        .limitToFirst(_professionsQueryLimit)
        .once()
        .then((snapshot) {
      final Map<String, dynamic> professionsFromDatabase =
          Map<String, dynamic>.from(snapshot.value);

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
          .reference()
          .child('users')
          .child('autonomous')
          .limitToLast(_professionsQueryLimit)
          .once()
          .then((snapshot) {
        final Map<String, dynamic> professionsFromDatabase =
            Map<String, dynamic>.from(snapshot.value);

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

  Future<void> _getQuickAutonomousFromDatabase() async {
    await _firebaseDatabase
        .reference()
        .child('quickSearch')
        .once()
        .then((snapshot) {
      final Map<String, dynamic> quickAutonomous =
          Map<String, dynamic>.from(snapshot.value);

      quickAutonomous.forEach((id, value) {
        final Map<String, dynamic> autonomousFormatted =
            Map<String, dynamic>.from(value);

        final Autonomous autonomous =
            Autonomous.convertFromQuickSearchFromDatabase(autonomousFormatted);

        autonomous.userUID = id;
        setState(() {
          _quickAutonomous.add(autonomous);
          _filteredQuickAutonomous.add(autonomous);
        });
      });
    });
  }

  Future<void> _getDataFromDatabase() async {
    _clearDataStates();
    await _getProfessionsFromDatabase().then((_) async {
      await _getAutonomousFromDatabase().then((_) async {
        await _getQuickAutonomousFromDatabase();
      });
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
  void dispose() {
    _searchInputController.dispose();
    _searchInputFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isSearching) {
      return Scaffold(
        appBar: _renderAppBar(),
        body: ListView.builder(
          itemCount: _filteredQuickAutonomous.length,
          itemBuilder: (_, index) => AutonomousListTile(
            key: UniqueKey(),
            autonomous: _filteredQuickAutonomous[index],
            heroTagComplement: getRandomHeroTagComplement(),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: _renderAppBar(),
      body: RefreshIndicator(
        onRefresh: _getDataFromDatabase,
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 20),
          itemCount: _professions.length,
          itemBuilder: (_, index) => AutonomousList(
            key: UniqueKey(),
            profession: _professions[index],
            autonomous: _filterAutonomousByProfession(_professions[index]),
          ),
        ),
      ),
    );
  }
}
