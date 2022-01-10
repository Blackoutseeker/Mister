import 'package:mobx/mobx.dart';

import 'package:mister/models/interfaces/stores/autonomous.dart';
import 'package:mister/models/database/autonomous.dart';

part 'autonomous.g.dart';

class AutonomousStore = _AutonomousStore with _$AutonomousStore;

abstract class _AutonomousStore with Store implements AutonomousStoreTemplate {
  @observable
  @override
  Autonomous autonomous = Autonomous();

  @action
  @override
  Future<void> setAutonomous(Autonomous autonomous) async {
    this.autonomous = autonomous;
  }
}
