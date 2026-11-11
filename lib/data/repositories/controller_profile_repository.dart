import 'package:drift/drift.dart';

import '../../core/controllers/controller_profile.dart';
import '../../core/database/app_database.dart';

/// Persists [ControllerProfile]s in `controller_profiles` +
/// `controller_mappings`. One profile per (descriptor, console) pair;
/// `consoleId == null` is the controller's universal profile.
class ControllerProfileRepository {
  ControllerProfileRepository(this._db);
  final AppDatabase _db;

  Expression<bool> _match($ControllerProfilesTable t, String? descriptor, String? consoleId) =>
      (descriptor == null ? t.controllerDescriptor.isNull() : t.controllerDescriptor.equals(descriptor)) &
      (consoleId == null ? t.consoleId.isNull() : t.consoleId.equals(consoleId));

  Future<ControllerProfile?> load(String? descriptor, {String? consoleId}) async {
    final row = await (_db.select(_db.controllerProfiles)
          ..where((t) => _match(t, descriptor, consoleId))
          ..limit(1))
        .getSingleOrNull();
    return row == null ? null : _toModel(row);
  }

  /// Console-specific profile if present, else the universal one.
  Future<ControllerProfile?> effective(String descriptor, {String? consoleId}) async =>
      (consoleId == null ? null : await load(descriptor, consoleId: consoleId)) ?? await load(descriptor);

  Future<List<ControllerProfile>> all() async =>
      Future.wait((await _db.select(_db.controllerProfiles).get()).map(_toModel));

  Future<ControllerProfile> _toModel(ControllerProfileRow row) async {
    final maps = await (_db.select(_db.controllerMappings)..where((m) => m.profileId.equals(row.id))).get();
    final bindings = <PadAction, Binding>{};
    for (final m in maps) {
      final action = PadAction.values.where((a) => a.name == m.action).firstOrNull;
      if (action == null) continue;
      if (m.keyCode != null) {
        bindings[action] = Binding.key(m.keyCode!);
      } else if (m.axis != null && m.axisDirection != null) {
        bindings[action] = Binding.axis(m.axis!, m.axisDirection!);
      }
    }
    return ControllerProfile(
      id: row.id,
      name: row.name,
      descriptor: row.controllerDescriptor,
      consoleId: row.consoleId,
      deadZone: row.deadZone,
      triggerThreshold: row.triggerThreshold,
      vibration: row.vibrationEnabled,
      bindings: bindings,
      calibration: ControllerProfile.parseCalibration(row.calibrationJson),
    );
  }

  /// Inserts or replaces the profile for its (descriptor, console) pair,
  /// including all bindings. Returns the stored profile.
  Future<ControllerProfile> save(ControllerProfile p) async {
    final id = await _db.transaction(() async {
      final existing = await (_db.select(_db.controllerProfiles)
            ..where((t) => _match(t, p.descriptor, p.consoleId))
            ..limit(1))
          .getSingleOrNull();
      final companion = ControllerProfilesCompanion(
        name: Value(p.name),
        controllerDescriptor: Value(p.descriptor),
        consoleId: Value(p.consoleId),
        deadZone: Value(p.deadZone.clamp(0.0, 0.9)),
        triggerThreshold: Value(p.triggerThreshold.clamp(0.05, 0.95)),
        vibrationEnabled: Value(p.vibration),
        calibrationJson: Value(p.calibration.isEmpty ? null : p.calibrationJson()),
      );
      final int id;
      if (existing == null) {
        id = await _db.into(_db.controllerProfiles).insert(companion);
      } else {
        id = existing.id;
        await (_db.update(_db.controllerProfiles)..where((t) => t.id.equals(id))).write(companion);
      }
      await (_db.delete(_db.controllerMappings)..where((m) => m.profileId.equals(id))).go();
      for (final e in p.bindings.entries) {
        await _db.into(_db.controllerMappings).insert(ControllerMappingsCompanion.insert(
              profileId: id,
              action: e.key.name,
              keyCode: Value(e.value.keyCode),
              axis: Value(e.value.axis),
              axisDirection: Value(e.value.direction),
            ));
      }
      return id;
    });
    return (await load(p.descriptor, consoleId: p.consoleId)) ?? p.copyWith().withId(id);
  }

  Future<void> delete(String? descriptor, {String? consoleId}) =>
      (_db.delete(_db.controllerProfiles)..where((t) => _match(t, descriptor, consoleId))).go();

  Future<void> setAssignedPlayer(String descriptor, int? player) =>
      (_db.update(_db.controllerDevices)..where((d) => d.descriptor.equals(descriptor)))
          .write(ControllerDevicesCompanion(assignedPlayer: Value(player)));

  Future<Map<String, int?>> assignedPlayers() async => {
        for (final d in await _db.select(_db.controllerDevices).get()) d.descriptor: d.assignedPlayer,
      };
}

extension on ControllerProfile {
  ControllerProfile withId(int id) => ControllerProfile(
        id: id,
        name: name,
        descriptor: descriptor,
        consoleId: consoleId,
        deadZone: deadZone,
        triggerThreshold: triggerThreshold,
        vibration: vibration,
        bindings: bindings,
        calibration: calibration,
      );
}
