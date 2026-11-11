// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $DevicesTable extends Devices with TableInfo<$DevicesTable, DeviceRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DevicesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _deviceKeyMeta = const VerificationMeta(
    'deviceKey',
  );
  @override
  late final GeneratedColumn<String> deviceKey = GeneratedColumn<String>(
    'device_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _manufacturerMeta = const VerificationMeta(
    'manufacturer',
  );
  @override
  late final GeneratedColumn<String> manufacturer = GeneratedColumn<String>(
    'manufacturer',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _modelMeta = const VerificationMeta('model');
  @override
  late final GeneratedColumn<String> model = GeneratedColumn<String>(
    'model',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deviceNameMeta = const VerificationMeta(
    'deviceName',
  );
  @override
  late final GeneratedColumn<String> deviceName = GeneratedColumn<String>(
    'device_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _androidVersionMeta = const VerificationMeta(
    'androidVersion',
  );
  @override
  late final GeneratedColumn<String> androidVersion = GeneratedColumn<String>(
    'android_version',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sdkIntMeta = const VerificationMeta('sdkInt');
  @override
  late final GeneratedColumn<int> sdkInt = GeneratedColumn<int>(
    'sdk_int',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _buildFingerprintMeta = const VerificationMeta(
    'buildFingerprint',
  );
  @override
  late final GeneratedColumn<String> buildFingerprint = GeneratedColumn<String>(
    'build_fingerprint',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _firstSeenAtMeta = const VerificationMeta(
    'firstSeenAt',
  );
  @override
  late final GeneratedColumn<DateTime> firstSeenAt = GeneratedColumn<DateTime>(
    'first_seen_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastSeenAtMeta = const VerificationMeta(
    'lastSeenAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastSeenAt = GeneratedColumn<DateTime>(
    'last_seen_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    deviceKey,
    manufacturer,
    model,
    deviceName,
    androidVersion,
    sdkInt,
    buildFingerprint,
    firstSeenAt,
    lastSeenAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'devices';
  @override
  VerificationContext validateIntegrity(
    Insertable<DeviceRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('device_key')) {
      context.handle(
        _deviceKeyMeta,
        deviceKey.isAcceptableOrUnknown(data['device_key']!, _deviceKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceKeyMeta);
    }
    if (data.containsKey('manufacturer')) {
      context.handle(
        _manufacturerMeta,
        manufacturer.isAcceptableOrUnknown(
          data['manufacturer']!,
          _manufacturerMeta,
        ),
      );
    }
    if (data.containsKey('model')) {
      context.handle(
        _modelMeta,
        model.isAcceptableOrUnknown(data['model']!, _modelMeta),
      );
    }
    if (data.containsKey('device_name')) {
      context.handle(
        _deviceNameMeta,
        deviceName.isAcceptableOrUnknown(data['device_name']!, _deviceNameMeta),
      );
    }
    if (data.containsKey('android_version')) {
      context.handle(
        _androidVersionMeta,
        androidVersion.isAcceptableOrUnknown(
          data['android_version']!,
          _androidVersionMeta,
        ),
      );
    }
    if (data.containsKey('sdk_int')) {
      context.handle(
        _sdkIntMeta,
        sdkInt.isAcceptableOrUnknown(data['sdk_int']!, _sdkIntMeta),
      );
    }
    if (data.containsKey('build_fingerprint')) {
      context.handle(
        _buildFingerprintMeta,
        buildFingerprint.isAcceptableOrUnknown(
          data['build_fingerprint']!,
          _buildFingerprintMeta,
        ),
      );
    }
    if (data.containsKey('first_seen_at')) {
      context.handle(
        _firstSeenAtMeta,
        firstSeenAt.isAcceptableOrUnknown(
          data['first_seen_at']!,
          _firstSeenAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_firstSeenAtMeta);
    }
    if (data.containsKey('last_seen_at')) {
      context.handle(
        _lastSeenAtMeta,
        lastSeenAt.isAcceptableOrUnknown(
          data['last_seen_at']!,
          _lastSeenAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastSeenAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DeviceRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DeviceRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      deviceKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_key'],
      )!,
      manufacturer: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}manufacturer'],
      ),
      model: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}model'],
      ),
      deviceName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_name'],
      ),
      androidVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}android_version'],
      ),
      sdkInt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sdk_int'],
      ),
      buildFingerprint: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}build_fingerprint'],
      ),
      firstSeenAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}first_seen_at'],
      )!,
      lastSeenAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_seen_at'],
      )!,
    );
  }

  @override
  $DevicesTable createAlias(String alias) {
    return $DevicesTable(attachedDatabase, alias);
  }
}

class DeviceRow extends DataClass implements Insertable<DeviceRow> {
  final int id;

  /// Stable key derived from manufacturer/model/build fingerprint.
  final String deviceKey;
  final String? manufacturer;
  final String? model;
  final String? deviceName;
  final String? androidVersion;
  final int? sdkInt;
  final String? buildFingerprint;
  final DateTime firstSeenAt;
  final DateTime lastSeenAt;
  const DeviceRow({
    required this.id,
    required this.deviceKey,
    this.manufacturer,
    this.model,
    this.deviceName,
    this.androidVersion,
    this.sdkInt,
    this.buildFingerprint,
    required this.firstSeenAt,
    required this.lastSeenAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['device_key'] = Variable<String>(deviceKey);
    if (!nullToAbsent || manufacturer != null) {
      map['manufacturer'] = Variable<String>(manufacturer);
    }
    if (!nullToAbsent || model != null) {
      map['model'] = Variable<String>(model);
    }
    if (!nullToAbsent || deviceName != null) {
      map['device_name'] = Variable<String>(deviceName);
    }
    if (!nullToAbsent || androidVersion != null) {
      map['android_version'] = Variable<String>(androidVersion);
    }
    if (!nullToAbsent || sdkInt != null) {
      map['sdk_int'] = Variable<int>(sdkInt);
    }
    if (!nullToAbsent || buildFingerprint != null) {
      map['build_fingerprint'] = Variable<String>(buildFingerprint);
    }
    map['first_seen_at'] = Variable<DateTime>(firstSeenAt);
    map['last_seen_at'] = Variable<DateTime>(lastSeenAt);
    return map;
  }

  DevicesCompanion toCompanion(bool nullToAbsent) {
    return DevicesCompanion(
      id: Value(id),
      deviceKey: Value(deviceKey),
      manufacturer: manufacturer == null && nullToAbsent
          ? const Value.absent()
          : Value(manufacturer),
      model: model == null && nullToAbsent
          ? const Value.absent()
          : Value(model),
      deviceName: deviceName == null && nullToAbsent
          ? const Value.absent()
          : Value(deviceName),
      androidVersion: androidVersion == null && nullToAbsent
          ? const Value.absent()
          : Value(androidVersion),
      sdkInt: sdkInt == null && nullToAbsent
          ? const Value.absent()
          : Value(sdkInt),
      buildFingerprint: buildFingerprint == null && nullToAbsent
          ? const Value.absent()
          : Value(buildFingerprint),
      firstSeenAt: Value(firstSeenAt),
      lastSeenAt: Value(lastSeenAt),
    );
  }

  factory DeviceRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DeviceRow(
      id: serializer.fromJson<int>(json['id']),
      deviceKey: serializer.fromJson<String>(json['deviceKey']),
      manufacturer: serializer.fromJson<String?>(json['manufacturer']),
      model: serializer.fromJson<String?>(json['model']),
      deviceName: serializer.fromJson<String?>(json['deviceName']),
      androidVersion: serializer.fromJson<String?>(json['androidVersion']),
      sdkInt: serializer.fromJson<int?>(json['sdkInt']),
      buildFingerprint: serializer.fromJson<String?>(json['buildFingerprint']),
      firstSeenAt: serializer.fromJson<DateTime>(json['firstSeenAt']),
      lastSeenAt: serializer.fromJson<DateTime>(json['lastSeenAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'deviceKey': serializer.toJson<String>(deviceKey),
      'manufacturer': serializer.toJson<String?>(manufacturer),
      'model': serializer.toJson<String?>(model),
      'deviceName': serializer.toJson<String?>(deviceName),
      'androidVersion': serializer.toJson<String?>(androidVersion),
      'sdkInt': serializer.toJson<int?>(sdkInt),
      'buildFingerprint': serializer.toJson<String?>(buildFingerprint),
      'firstSeenAt': serializer.toJson<DateTime>(firstSeenAt),
      'lastSeenAt': serializer.toJson<DateTime>(lastSeenAt),
    };
  }

  DeviceRow copyWith({
    int? id,
    String? deviceKey,
    Value<String?> manufacturer = const Value.absent(),
    Value<String?> model = const Value.absent(),
    Value<String?> deviceName = const Value.absent(),
    Value<String?> androidVersion = const Value.absent(),
    Value<int?> sdkInt = const Value.absent(),
    Value<String?> buildFingerprint = const Value.absent(),
    DateTime? firstSeenAt,
    DateTime? lastSeenAt,
  }) => DeviceRow(
    id: id ?? this.id,
    deviceKey: deviceKey ?? this.deviceKey,
    manufacturer: manufacturer.present ? manufacturer.value : this.manufacturer,
    model: model.present ? model.value : this.model,
    deviceName: deviceName.present ? deviceName.value : this.deviceName,
    androidVersion: androidVersion.present
        ? androidVersion.value
        : this.androidVersion,
    sdkInt: sdkInt.present ? sdkInt.value : this.sdkInt,
    buildFingerprint: buildFingerprint.present
        ? buildFingerprint.value
        : this.buildFingerprint,
    firstSeenAt: firstSeenAt ?? this.firstSeenAt,
    lastSeenAt: lastSeenAt ?? this.lastSeenAt,
  );
  DeviceRow copyWithCompanion(DevicesCompanion data) {
    return DeviceRow(
      id: data.id.present ? data.id.value : this.id,
      deviceKey: data.deviceKey.present ? data.deviceKey.value : this.deviceKey,
      manufacturer: data.manufacturer.present
          ? data.manufacturer.value
          : this.manufacturer,
      model: data.model.present ? data.model.value : this.model,
      deviceName: data.deviceName.present
          ? data.deviceName.value
          : this.deviceName,
      androidVersion: data.androidVersion.present
          ? data.androidVersion.value
          : this.androidVersion,
      sdkInt: data.sdkInt.present ? data.sdkInt.value : this.sdkInt,
      buildFingerprint: data.buildFingerprint.present
          ? data.buildFingerprint.value
          : this.buildFingerprint,
      firstSeenAt: data.firstSeenAt.present
          ? data.firstSeenAt.value
          : this.firstSeenAt,
      lastSeenAt: data.lastSeenAt.present
          ? data.lastSeenAt.value
          : this.lastSeenAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DeviceRow(')
          ..write('id: $id, ')
          ..write('deviceKey: $deviceKey, ')
          ..write('manufacturer: $manufacturer, ')
          ..write('model: $model, ')
          ..write('deviceName: $deviceName, ')
          ..write('androidVersion: $androidVersion, ')
          ..write('sdkInt: $sdkInt, ')
          ..write('buildFingerprint: $buildFingerprint, ')
          ..write('firstSeenAt: $firstSeenAt, ')
          ..write('lastSeenAt: $lastSeenAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    deviceKey,
    manufacturer,
    model,
    deviceName,
    androidVersion,
    sdkInt,
    buildFingerprint,
    firstSeenAt,
    lastSeenAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DeviceRow &&
          other.id == this.id &&
          other.deviceKey == this.deviceKey &&
          other.manufacturer == this.manufacturer &&
          other.model == this.model &&
          other.deviceName == this.deviceName &&
          other.androidVersion == this.androidVersion &&
          other.sdkInt == this.sdkInt &&
          other.buildFingerprint == this.buildFingerprint &&
          other.firstSeenAt == this.firstSeenAt &&
          other.lastSeenAt == this.lastSeenAt);
}

class DevicesCompanion extends UpdateCompanion<DeviceRow> {
  final Value<int> id;
  final Value<String> deviceKey;
  final Value<String?> manufacturer;
  final Value<String?> model;
  final Value<String?> deviceName;
  final Value<String?> androidVersion;
  final Value<int?> sdkInt;
  final Value<String?> buildFingerprint;
  final Value<DateTime> firstSeenAt;
  final Value<DateTime> lastSeenAt;
  const DevicesCompanion({
    this.id = const Value.absent(),
    this.deviceKey = const Value.absent(),
    this.manufacturer = const Value.absent(),
    this.model = const Value.absent(),
    this.deviceName = const Value.absent(),
    this.androidVersion = const Value.absent(),
    this.sdkInt = const Value.absent(),
    this.buildFingerprint = const Value.absent(),
    this.firstSeenAt = const Value.absent(),
    this.lastSeenAt = const Value.absent(),
  });
  DevicesCompanion.insert({
    this.id = const Value.absent(),
    required String deviceKey,
    this.manufacturer = const Value.absent(),
    this.model = const Value.absent(),
    this.deviceName = const Value.absent(),
    this.androidVersion = const Value.absent(),
    this.sdkInt = const Value.absent(),
    this.buildFingerprint = const Value.absent(),
    required DateTime firstSeenAt,
    required DateTime lastSeenAt,
  }) : deviceKey = Value(deviceKey),
       firstSeenAt = Value(firstSeenAt),
       lastSeenAt = Value(lastSeenAt);
  static Insertable<DeviceRow> custom({
    Expression<int>? id,
    Expression<String>? deviceKey,
    Expression<String>? manufacturer,
    Expression<String>? model,
    Expression<String>? deviceName,
    Expression<String>? androidVersion,
    Expression<int>? sdkInt,
    Expression<String>? buildFingerprint,
    Expression<DateTime>? firstSeenAt,
    Expression<DateTime>? lastSeenAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (deviceKey != null) 'device_key': deviceKey,
      if (manufacturer != null) 'manufacturer': manufacturer,
      if (model != null) 'model': model,
      if (deviceName != null) 'device_name': deviceName,
      if (androidVersion != null) 'android_version': androidVersion,
      if (sdkInt != null) 'sdk_int': sdkInt,
      if (buildFingerprint != null) 'build_fingerprint': buildFingerprint,
      if (firstSeenAt != null) 'first_seen_at': firstSeenAt,
      if (lastSeenAt != null) 'last_seen_at': lastSeenAt,
    });
  }

  DevicesCompanion copyWith({
    Value<int>? id,
    Value<String>? deviceKey,
    Value<String?>? manufacturer,
    Value<String?>? model,
    Value<String?>? deviceName,
    Value<String?>? androidVersion,
    Value<int?>? sdkInt,
    Value<String?>? buildFingerprint,
    Value<DateTime>? firstSeenAt,
    Value<DateTime>? lastSeenAt,
  }) {
    return DevicesCompanion(
      id: id ?? this.id,
      deviceKey: deviceKey ?? this.deviceKey,
      manufacturer: manufacturer ?? this.manufacturer,
      model: model ?? this.model,
      deviceName: deviceName ?? this.deviceName,
      androidVersion: androidVersion ?? this.androidVersion,
      sdkInt: sdkInt ?? this.sdkInt,
      buildFingerprint: buildFingerprint ?? this.buildFingerprint,
      firstSeenAt: firstSeenAt ?? this.firstSeenAt,
      lastSeenAt: lastSeenAt ?? this.lastSeenAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (deviceKey.present) {
      map['device_key'] = Variable<String>(deviceKey.value);
    }
    if (manufacturer.present) {
      map['manufacturer'] = Variable<String>(manufacturer.value);
    }
    if (model.present) {
      map['model'] = Variable<String>(model.value);
    }
    if (deviceName.present) {
      map['device_name'] = Variable<String>(deviceName.value);
    }
    if (androidVersion.present) {
      map['android_version'] = Variable<String>(androidVersion.value);
    }
    if (sdkInt.present) {
      map['sdk_int'] = Variable<int>(sdkInt.value);
    }
    if (buildFingerprint.present) {
      map['build_fingerprint'] = Variable<String>(buildFingerprint.value);
    }
    if (firstSeenAt.present) {
      map['first_seen_at'] = Variable<DateTime>(firstSeenAt.value);
    }
    if (lastSeenAt.present) {
      map['last_seen_at'] = Variable<DateTime>(lastSeenAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DevicesCompanion(')
          ..write('id: $id, ')
          ..write('deviceKey: $deviceKey, ')
          ..write('manufacturer: $manufacturer, ')
          ..write('model: $model, ')
          ..write('deviceName: $deviceName, ')
          ..write('androidVersion: $androidVersion, ')
          ..write('sdkInt: $sdkInt, ')
          ..write('buildFingerprint: $buildFingerprint, ')
          ..write('firstSeenAt: $firstSeenAt, ')
          ..write('lastSeenAt: $lastSeenAt')
          ..write(')'))
        .toString();
  }
}

class $DeviceHardwareProfilesTable extends DeviceHardwareProfiles
    with TableInfo<$DeviceHardwareProfilesTable, HardwareProfileRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DeviceHardwareProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<int> deviceId = GeneratedColumn<int>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES devices (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _scannedAtMeta = const VerificationMeta(
    'scannedAt',
  );
  @override
  late final GeneratedColumn<DateTime> scannedAt = GeneratedColumn<DateTime>(
    'scanned_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tierMeta = const VerificationMeta('tier');
  @override
  late final GeneratedColumn<String> tier = GeneratedColumn<String>(
    'tier',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _confidenceMeta = const VerificationMeta(
    'confidence',
  );
  @override
  late final GeneratedColumn<String> confidence = GeneratedColumn<String>(
    'confidence',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _abisMeta = const VerificationMeta('abis');
  @override
  late final GeneratedColumn<String> abis = GeneratedColumn<String>(
    'abis',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cpuDescriptionMeta = const VerificationMeta(
    'cpuDescription',
  );
  @override
  late final GeneratedColumn<String> cpuDescription = GeneratedColumn<String>(
    'cpu_description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cpuCoresMeta = const VerificationMeta(
    'cpuCores',
  );
  @override
  late final GeneratedColumn<int> cpuCores = GeneratedColumn<int>(
    'cpu_cores',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _totalRamBytesMeta = const VerificationMeta(
    'totalRamBytes',
  );
  @override
  late final GeneratedColumn<int> totalRamBytes = GeneratedColumn<int>(
    'total_ram_bytes',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _glRendererMeta = const VerificationMeta(
    'glRenderer',
  );
  @override
  late final GeneratedColumn<String> glRenderer = GeneratedColumn<String>(
    'gl_renderer',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _glEsVersionMeta = const VerificationMeta(
    'glEsVersion',
  );
  @override
  late final GeneratedColumn<String> glEsVersion = GeneratedColumn<String>(
    'gl_es_version',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _vulkanSupportedMeta = const VerificationMeta(
    'vulkanSupported',
  );
  @override
  late final GeneratedColumn<bool> vulkanSupported = GeneratedColumn<bool>(
    'vulkan_supported',
    aliasedName,
    true,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("vulkan_supported" IN (0, 1))',
    ),
  );
  static const VerificationMeta _displayWidthMeta = const VerificationMeta(
    'displayWidth',
  );
  @override
  late final GeneratedColumn<int> displayWidth = GeneratedColumn<int>(
    'display_width',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _displayHeightMeta = const VerificationMeta(
    'displayHeight',
  );
  @override
  late final GeneratedColumn<int> displayHeight = GeneratedColumn<int>(
    'display_height',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _rawJsonMeta = const VerificationMeta(
    'rawJson',
  );
  @override
  late final GeneratedColumn<String> rawJson = GeneratedColumn<String>(
    'raw_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    deviceId,
    scannedAt,
    tier,
    confidence,
    abis,
    cpuDescription,
    cpuCores,
    totalRamBytes,
    glRenderer,
    glEsVersion,
    vulkanSupported,
    displayWidth,
    displayHeight,
    rawJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'device_hardware_profiles';
  @override
  VerificationContext validateIntegrity(
    Insertable<HardwareProfileRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('scanned_at')) {
      context.handle(
        _scannedAtMeta,
        scannedAt.isAcceptableOrUnknown(data['scanned_at']!, _scannedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_scannedAtMeta);
    }
    if (data.containsKey('tier')) {
      context.handle(
        _tierMeta,
        tier.isAcceptableOrUnknown(data['tier']!, _tierMeta),
      );
    } else if (isInserting) {
      context.missing(_tierMeta);
    }
    if (data.containsKey('confidence')) {
      context.handle(
        _confidenceMeta,
        confidence.isAcceptableOrUnknown(data['confidence']!, _confidenceMeta),
      );
    } else if (isInserting) {
      context.missing(_confidenceMeta);
    }
    if (data.containsKey('abis')) {
      context.handle(
        _abisMeta,
        abis.isAcceptableOrUnknown(data['abis']!, _abisMeta),
      );
    } else if (isInserting) {
      context.missing(_abisMeta);
    }
    if (data.containsKey('cpu_description')) {
      context.handle(
        _cpuDescriptionMeta,
        cpuDescription.isAcceptableOrUnknown(
          data['cpu_description']!,
          _cpuDescriptionMeta,
        ),
      );
    }
    if (data.containsKey('cpu_cores')) {
      context.handle(
        _cpuCoresMeta,
        cpuCores.isAcceptableOrUnknown(data['cpu_cores']!, _cpuCoresMeta),
      );
    }
    if (data.containsKey('total_ram_bytes')) {
      context.handle(
        _totalRamBytesMeta,
        totalRamBytes.isAcceptableOrUnknown(
          data['total_ram_bytes']!,
          _totalRamBytesMeta,
        ),
      );
    }
    if (data.containsKey('gl_renderer')) {
      context.handle(
        _glRendererMeta,
        glRenderer.isAcceptableOrUnknown(data['gl_renderer']!, _glRendererMeta),
      );
    }
    if (data.containsKey('gl_es_version')) {
      context.handle(
        _glEsVersionMeta,
        glEsVersion.isAcceptableOrUnknown(
          data['gl_es_version']!,
          _glEsVersionMeta,
        ),
      );
    }
    if (data.containsKey('vulkan_supported')) {
      context.handle(
        _vulkanSupportedMeta,
        vulkanSupported.isAcceptableOrUnknown(
          data['vulkan_supported']!,
          _vulkanSupportedMeta,
        ),
      );
    }
    if (data.containsKey('display_width')) {
      context.handle(
        _displayWidthMeta,
        displayWidth.isAcceptableOrUnknown(
          data['display_width']!,
          _displayWidthMeta,
        ),
      );
    }
    if (data.containsKey('display_height')) {
      context.handle(
        _displayHeightMeta,
        displayHeight.isAcceptableOrUnknown(
          data['display_height']!,
          _displayHeightMeta,
        ),
      );
    }
    if (data.containsKey('raw_json')) {
      context.handle(
        _rawJsonMeta,
        rawJson.isAcceptableOrUnknown(data['raw_json']!, _rawJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_rawJsonMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  HardwareProfileRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HardwareProfileRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}device_id'],
      )!,
      scannedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}scanned_at'],
      )!,
      tier: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tier'],
      )!,
      confidence: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}confidence'],
      )!,
      abis: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}abis'],
      )!,
      cpuDescription: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cpu_description'],
      ),
      cpuCores: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cpu_cores'],
      ),
      totalRamBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_ram_bytes'],
      ),
      glRenderer: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}gl_renderer'],
      ),
      glEsVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}gl_es_version'],
      ),
      vulkanSupported: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}vulkan_supported'],
      ),
      displayWidth: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}display_width'],
      ),
      displayHeight: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}display_height'],
      ),
      rawJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}raw_json'],
      )!,
    );
  }

  @override
  $DeviceHardwareProfilesTable createAlias(String alias) {
    return $DeviceHardwareProfilesTable(attachedDatabase, alias);
  }
}

class HardwareProfileRow extends DataClass
    implements Insertable<HardwareProfileRow> {
  final int id;
  final int deviceId;
  final DateTime scannedAt;
  final String tier;
  final String confidence;
  final String abis;
  final String? cpuDescription;
  final int? cpuCores;
  final int? totalRamBytes;
  final String? glRenderer;
  final String? glEsVersion;
  final bool? vulkanSupported;
  final int? displayWidth;
  final int? displayHeight;

  /// Full HardwareProfile as JSON for forward compatibility.
  final String rawJson;
  const HardwareProfileRow({
    required this.id,
    required this.deviceId,
    required this.scannedAt,
    required this.tier,
    required this.confidence,
    required this.abis,
    this.cpuDescription,
    this.cpuCores,
    this.totalRamBytes,
    this.glRenderer,
    this.glEsVersion,
    this.vulkanSupported,
    this.displayWidth,
    this.displayHeight,
    required this.rawJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['device_id'] = Variable<int>(deviceId);
    map['scanned_at'] = Variable<DateTime>(scannedAt);
    map['tier'] = Variable<String>(tier);
    map['confidence'] = Variable<String>(confidence);
    map['abis'] = Variable<String>(abis);
    if (!nullToAbsent || cpuDescription != null) {
      map['cpu_description'] = Variable<String>(cpuDescription);
    }
    if (!nullToAbsent || cpuCores != null) {
      map['cpu_cores'] = Variable<int>(cpuCores);
    }
    if (!nullToAbsent || totalRamBytes != null) {
      map['total_ram_bytes'] = Variable<int>(totalRamBytes);
    }
    if (!nullToAbsent || glRenderer != null) {
      map['gl_renderer'] = Variable<String>(glRenderer);
    }
    if (!nullToAbsent || glEsVersion != null) {
      map['gl_es_version'] = Variable<String>(glEsVersion);
    }
    if (!nullToAbsent || vulkanSupported != null) {
      map['vulkan_supported'] = Variable<bool>(vulkanSupported);
    }
    if (!nullToAbsent || displayWidth != null) {
      map['display_width'] = Variable<int>(displayWidth);
    }
    if (!nullToAbsent || displayHeight != null) {
      map['display_height'] = Variable<int>(displayHeight);
    }
    map['raw_json'] = Variable<String>(rawJson);
    return map;
  }

  DeviceHardwareProfilesCompanion toCompanion(bool nullToAbsent) {
    return DeviceHardwareProfilesCompanion(
      id: Value(id),
      deviceId: Value(deviceId),
      scannedAt: Value(scannedAt),
      tier: Value(tier),
      confidence: Value(confidence),
      abis: Value(abis),
      cpuDescription: cpuDescription == null && nullToAbsent
          ? const Value.absent()
          : Value(cpuDescription),
      cpuCores: cpuCores == null && nullToAbsent
          ? const Value.absent()
          : Value(cpuCores),
      totalRamBytes: totalRamBytes == null && nullToAbsent
          ? const Value.absent()
          : Value(totalRamBytes),
      glRenderer: glRenderer == null && nullToAbsent
          ? const Value.absent()
          : Value(glRenderer),
      glEsVersion: glEsVersion == null && nullToAbsent
          ? const Value.absent()
          : Value(glEsVersion),
      vulkanSupported: vulkanSupported == null && nullToAbsent
          ? const Value.absent()
          : Value(vulkanSupported),
      displayWidth: displayWidth == null && nullToAbsent
          ? const Value.absent()
          : Value(displayWidth),
      displayHeight: displayHeight == null && nullToAbsent
          ? const Value.absent()
          : Value(displayHeight),
      rawJson: Value(rawJson),
    );
  }

  factory HardwareProfileRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HardwareProfileRow(
      id: serializer.fromJson<int>(json['id']),
      deviceId: serializer.fromJson<int>(json['deviceId']),
      scannedAt: serializer.fromJson<DateTime>(json['scannedAt']),
      tier: serializer.fromJson<String>(json['tier']),
      confidence: serializer.fromJson<String>(json['confidence']),
      abis: serializer.fromJson<String>(json['abis']),
      cpuDescription: serializer.fromJson<String?>(json['cpuDescription']),
      cpuCores: serializer.fromJson<int?>(json['cpuCores']),
      totalRamBytes: serializer.fromJson<int?>(json['totalRamBytes']),
      glRenderer: serializer.fromJson<String?>(json['glRenderer']),
      glEsVersion: serializer.fromJson<String?>(json['glEsVersion']),
      vulkanSupported: serializer.fromJson<bool?>(json['vulkanSupported']),
      displayWidth: serializer.fromJson<int?>(json['displayWidth']),
      displayHeight: serializer.fromJson<int?>(json['displayHeight']),
      rawJson: serializer.fromJson<String>(json['rawJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'deviceId': serializer.toJson<int>(deviceId),
      'scannedAt': serializer.toJson<DateTime>(scannedAt),
      'tier': serializer.toJson<String>(tier),
      'confidence': serializer.toJson<String>(confidence),
      'abis': serializer.toJson<String>(abis),
      'cpuDescription': serializer.toJson<String?>(cpuDescription),
      'cpuCores': serializer.toJson<int?>(cpuCores),
      'totalRamBytes': serializer.toJson<int?>(totalRamBytes),
      'glRenderer': serializer.toJson<String?>(glRenderer),
      'glEsVersion': serializer.toJson<String?>(glEsVersion),
      'vulkanSupported': serializer.toJson<bool?>(vulkanSupported),
      'displayWidth': serializer.toJson<int?>(displayWidth),
      'displayHeight': serializer.toJson<int?>(displayHeight),
      'rawJson': serializer.toJson<String>(rawJson),
    };
  }

  HardwareProfileRow copyWith({
    int? id,
    int? deviceId,
    DateTime? scannedAt,
    String? tier,
    String? confidence,
    String? abis,
    Value<String?> cpuDescription = const Value.absent(),
    Value<int?> cpuCores = const Value.absent(),
    Value<int?> totalRamBytes = const Value.absent(),
    Value<String?> glRenderer = const Value.absent(),
    Value<String?> glEsVersion = const Value.absent(),
    Value<bool?> vulkanSupported = const Value.absent(),
    Value<int?> displayWidth = const Value.absent(),
    Value<int?> displayHeight = const Value.absent(),
    String? rawJson,
  }) => HardwareProfileRow(
    id: id ?? this.id,
    deviceId: deviceId ?? this.deviceId,
    scannedAt: scannedAt ?? this.scannedAt,
    tier: tier ?? this.tier,
    confidence: confidence ?? this.confidence,
    abis: abis ?? this.abis,
    cpuDescription: cpuDescription.present
        ? cpuDescription.value
        : this.cpuDescription,
    cpuCores: cpuCores.present ? cpuCores.value : this.cpuCores,
    totalRamBytes: totalRamBytes.present
        ? totalRamBytes.value
        : this.totalRamBytes,
    glRenderer: glRenderer.present ? glRenderer.value : this.glRenderer,
    glEsVersion: glEsVersion.present ? glEsVersion.value : this.glEsVersion,
    vulkanSupported: vulkanSupported.present
        ? vulkanSupported.value
        : this.vulkanSupported,
    displayWidth: displayWidth.present ? displayWidth.value : this.displayWidth,
    displayHeight: displayHeight.present
        ? displayHeight.value
        : this.displayHeight,
    rawJson: rawJson ?? this.rawJson,
  );
  HardwareProfileRow copyWithCompanion(DeviceHardwareProfilesCompanion data) {
    return HardwareProfileRow(
      id: data.id.present ? data.id.value : this.id,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      scannedAt: data.scannedAt.present ? data.scannedAt.value : this.scannedAt,
      tier: data.tier.present ? data.tier.value : this.tier,
      confidence: data.confidence.present
          ? data.confidence.value
          : this.confidence,
      abis: data.abis.present ? data.abis.value : this.abis,
      cpuDescription: data.cpuDescription.present
          ? data.cpuDescription.value
          : this.cpuDescription,
      cpuCores: data.cpuCores.present ? data.cpuCores.value : this.cpuCores,
      totalRamBytes: data.totalRamBytes.present
          ? data.totalRamBytes.value
          : this.totalRamBytes,
      glRenderer: data.glRenderer.present
          ? data.glRenderer.value
          : this.glRenderer,
      glEsVersion: data.glEsVersion.present
          ? data.glEsVersion.value
          : this.glEsVersion,
      vulkanSupported: data.vulkanSupported.present
          ? data.vulkanSupported.value
          : this.vulkanSupported,
      displayWidth: data.displayWidth.present
          ? data.displayWidth.value
          : this.displayWidth,
      displayHeight: data.displayHeight.present
          ? data.displayHeight.value
          : this.displayHeight,
      rawJson: data.rawJson.present ? data.rawJson.value : this.rawJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HardwareProfileRow(')
          ..write('id: $id, ')
          ..write('deviceId: $deviceId, ')
          ..write('scannedAt: $scannedAt, ')
          ..write('tier: $tier, ')
          ..write('confidence: $confidence, ')
          ..write('abis: $abis, ')
          ..write('cpuDescription: $cpuDescription, ')
          ..write('cpuCores: $cpuCores, ')
          ..write('totalRamBytes: $totalRamBytes, ')
          ..write('glRenderer: $glRenderer, ')
          ..write('glEsVersion: $glEsVersion, ')
          ..write('vulkanSupported: $vulkanSupported, ')
          ..write('displayWidth: $displayWidth, ')
          ..write('displayHeight: $displayHeight, ')
          ..write('rawJson: $rawJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    deviceId,
    scannedAt,
    tier,
    confidence,
    abis,
    cpuDescription,
    cpuCores,
    totalRamBytes,
    glRenderer,
    glEsVersion,
    vulkanSupported,
    displayWidth,
    displayHeight,
    rawJson,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HardwareProfileRow &&
          other.id == this.id &&
          other.deviceId == this.deviceId &&
          other.scannedAt == this.scannedAt &&
          other.tier == this.tier &&
          other.confidence == this.confidence &&
          other.abis == this.abis &&
          other.cpuDescription == this.cpuDescription &&
          other.cpuCores == this.cpuCores &&
          other.totalRamBytes == this.totalRamBytes &&
          other.glRenderer == this.glRenderer &&
          other.glEsVersion == this.glEsVersion &&
          other.vulkanSupported == this.vulkanSupported &&
          other.displayWidth == this.displayWidth &&
          other.displayHeight == this.displayHeight &&
          other.rawJson == this.rawJson);
}

class DeviceHardwareProfilesCompanion
    extends UpdateCompanion<HardwareProfileRow> {
  final Value<int> id;
  final Value<int> deviceId;
  final Value<DateTime> scannedAt;
  final Value<String> tier;
  final Value<String> confidence;
  final Value<String> abis;
  final Value<String?> cpuDescription;
  final Value<int?> cpuCores;
  final Value<int?> totalRamBytes;
  final Value<String?> glRenderer;
  final Value<String?> glEsVersion;
  final Value<bool?> vulkanSupported;
  final Value<int?> displayWidth;
  final Value<int?> displayHeight;
  final Value<String> rawJson;
  const DeviceHardwareProfilesCompanion({
    this.id = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.scannedAt = const Value.absent(),
    this.tier = const Value.absent(),
    this.confidence = const Value.absent(),
    this.abis = const Value.absent(),
    this.cpuDescription = const Value.absent(),
    this.cpuCores = const Value.absent(),
    this.totalRamBytes = const Value.absent(),
    this.glRenderer = const Value.absent(),
    this.glEsVersion = const Value.absent(),
    this.vulkanSupported = const Value.absent(),
    this.displayWidth = const Value.absent(),
    this.displayHeight = const Value.absent(),
    this.rawJson = const Value.absent(),
  });
  DeviceHardwareProfilesCompanion.insert({
    this.id = const Value.absent(),
    required int deviceId,
    required DateTime scannedAt,
    required String tier,
    required String confidence,
    required String abis,
    this.cpuDescription = const Value.absent(),
    this.cpuCores = const Value.absent(),
    this.totalRamBytes = const Value.absent(),
    this.glRenderer = const Value.absent(),
    this.glEsVersion = const Value.absent(),
    this.vulkanSupported = const Value.absent(),
    this.displayWidth = const Value.absent(),
    this.displayHeight = const Value.absent(),
    required String rawJson,
  }) : deviceId = Value(deviceId),
       scannedAt = Value(scannedAt),
       tier = Value(tier),
       confidence = Value(confidence),
       abis = Value(abis),
       rawJson = Value(rawJson);
  static Insertable<HardwareProfileRow> custom({
    Expression<int>? id,
    Expression<int>? deviceId,
    Expression<DateTime>? scannedAt,
    Expression<String>? tier,
    Expression<String>? confidence,
    Expression<String>? abis,
    Expression<String>? cpuDescription,
    Expression<int>? cpuCores,
    Expression<int>? totalRamBytes,
    Expression<String>? glRenderer,
    Expression<String>? glEsVersion,
    Expression<bool>? vulkanSupported,
    Expression<int>? displayWidth,
    Expression<int>? displayHeight,
    Expression<String>? rawJson,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (deviceId != null) 'device_id': deviceId,
      if (scannedAt != null) 'scanned_at': scannedAt,
      if (tier != null) 'tier': tier,
      if (confidence != null) 'confidence': confidence,
      if (abis != null) 'abis': abis,
      if (cpuDescription != null) 'cpu_description': cpuDescription,
      if (cpuCores != null) 'cpu_cores': cpuCores,
      if (totalRamBytes != null) 'total_ram_bytes': totalRamBytes,
      if (glRenderer != null) 'gl_renderer': glRenderer,
      if (glEsVersion != null) 'gl_es_version': glEsVersion,
      if (vulkanSupported != null) 'vulkan_supported': vulkanSupported,
      if (displayWidth != null) 'display_width': displayWidth,
      if (displayHeight != null) 'display_height': displayHeight,
      if (rawJson != null) 'raw_json': rawJson,
    });
  }

  DeviceHardwareProfilesCompanion copyWith({
    Value<int>? id,
    Value<int>? deviceId,
    Value<DateTime>? scannedAt,
    Value<String>? tier,
    Value<String>? confidence,
    Value<String>? abis,
    Value<String?>? cpuDescription,
    Value<int?>? cpuCores,
    Value<int?>? totalRamBytes,
    Value<String?>? glRenderer,
    Value<String?>? glEsVersion,
    Value<bool?>? vulkanSupported,
    Value<int?>? displayWidth,
    Value<int?>? displayHeight,
    Value<String>? rawJson,
  }) {
    return DeviceHardwareProfilesCompanion(
      id: id ?? this.id,
      deviceId: deviceId ?? this.deviceId,
      scannedAt: scannedAt ?? this.scannedAt,
      tier: tier ?? this.tier,
      confidence: confidence ?? this.confidence,
      abis: abis ?? this.abis,
      cpuDescription: cpuDescription ?? this.cpuDescription,
      cpuCores: cpuCores ?? this.cpuCores,
      totalRamBytes: totalRamBytes ?? this.totalRamBytes,
      glRenderer: glRenderer ?? this.glRenderer,
      glEsVersion: glEsVersion ?? this.glEsVersion,
      vulkanSupported: vulkanSupported ?? this.vulkanSupported,
      displayWidth: displayWidth ?? this.displayWidth,
      displayHeight: displayHeight ?? this.displayHeight,
      rawJson: rawJson ?? this.rawJson,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<int>(deviceId.value);
    }
    if (scannedAt.present) {
      map['scanned_at'] = Variable<DateTime>(scannedAt.value);
    }
    if (tier.present) {
      map['tier'] = Variable<String>(tier.value);
    }
    if (confidence.present) {
      map['confidence'] = Variable<String>(confidence.value);
    }
    if (abis.present) {
      map['abis'] = Variable<String>(abis.value);
    }
    if (cpuDescription.present) {
      map['cpu_description'] = Variable<String>(cpuDescription.value);
    }
    if (cpuCores.present) {
      map['cpu_cores'] = Variable<int>(cpuCores.value);
    }
    if (totalRamBytes.present) {
      map['total_ram_bytes'] = Variable<int>(totalRamBytes.value);
    }
    if (glRenderer.present) {
      map['gl_renderer'] = Variable<String>(glRenderer.value);
    }
    if (glEsVersion.present) {
      map['gl_es_version'] = Variable<String>(glEsVersion.value);
    }
    if (vulkanSupported.present) {
      map['vulkan_supported'] = Variable<bool>(vulkanSupported.value);
    }
    if (displayWidth.present) {
      map['display_width'] = Variable<int>(displayWidth.value);
    }
    if (displayHeight.present) {
      map['display_height'] = Variable<int>(displayHeight.value);
    }
    if (rawJson.present) {
      map['raw_json'] = Variable<String>(rawJson.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DeviceHardwareProfilesCompanion(')
          ..write('id: $id, ')
          ..write('deviceId: $deviceId, ')
          ..write('scannedAt: $scannedAt, ')
          ..write('tier: $tier, ')
          ..write('confidence: $confidence, ')
          ..write('abis: $abis, ')
          ..write('cpuDescription: $cpuDescription, ')
          ..write('cpuCores: $cpuCores, ')
          ..write('totalRamBytes: $totalRamBytes, ')
          ..write('glRenderer: $glRenderer, ')
          ..write('glEsVersion: $glEsVersion, ')
          ..write('vulkanSupported: $vulkanSupported, ')
          ..write('displayWidth: $displayWidth, ')
          ..write('displayHeight: $displayHeight, ')
          ..write('rawJson: $rawJson')
          ..write(')'))
        .toString();
  }
}

class $DeviceCompatibilityTable extends DeviceCompatibility
    with TableInfo<$DeviceCompatibilityTable, DeviceCompatibilityRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DeviceCompatibilityTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    check: () => source.isIn(const ['detected', 'community', 'verified']),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _manufacturerMeta = const VerificationMeta(
    'manufacturer',
  );
  @override
  late final GeneratedColumn<String> manufacturer = GeneratedColumn<String>(
    'manufacturer',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _modelMeta = const VerificationMeta('model');
  @override
  late final GeneratedColumn<String> model = GeneratedColumn<String>(
    'model',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _chipsetMeta = const VerificationMeta(
    'chipset',
  );
  @override
  late final GeneratedColumn<String> chipset = GeneratedColumn<String>(
    'chipset',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cpuArchitectureMeta = const VerificationMeta(
    'cpuArchitecture',
  );
  @override
  late final GeneratedColumn<String> cpuArchitecture = GeneratedColumn<String>(
    'cpu_architecture',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cpuCharacteristicsMeta =
      const VerificationMeta('cpuCharacteristics');
  @override
  late final GeneratedColumn<String> cpuCharacteristics =
      GeneratedColumn<String>(
        'cpu_characteristics',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _gpuMeta = const VerificationMeta('gpu');
  @override
  late final GeneratedColumn<String> gpu = GeneratedColumn<String>(
    'gpu',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ramBytesMeta = const VerificationMeta(
    'ramBytes',
  );
  @override
  late final GeneratedColumn<int> ramBytes = GeneratedColumn<int>(
    'ram_bytes',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _androidVersionMeta = const VerificationMeta(
    'androidVersion',
  );
  @override
  late final GeneratedColumn<String> androidVersion = GeneratedColumn<String>(
    'android_version',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _graphicsApiMeta = const VerificationMeta(
    'graphicsApi',
  );
  @override
  late final GeneratedColumn<String> graphicsApi = GeneratedColumn<String>(
    'graphics_api',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _emulatorIdMeta = const VerificationMeta(
    'emulatorId',
  );
  @override
  late final GeneratedColumn<String> emulatorId = GeneratedColumn<String>(
    'emulator_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _consoleIdMeta = const VerificationMeta(
    'consoleId',
  );
  @override
  late final GeneratedColumn<String> consoleId = GeneratedColumn<String>(
    'console_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _testedGameMeta = const VerificationMeta(
    'testedGame',
  );
  @override
  late final GeneratedColumn<String> testedGame = GeneratedColumn<String>(
    'tested_game',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _testResultMeta = const VerificationMeta(
    'testResult',
  );
  @override
  late final GeneratedColumn<String> testResult = GeneratedColumn<String>(
    'test_result',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _performanceNotesMeta = const VerificationMeta(
    'performanceNotes',
  );
  @override
  late final GeneratedColumn<String> performanceNotes = GeneratedColumn<String>(
    'performance_notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _knownLimitationsMeta = const VerificationMeta(
    'knownLimitations',
  );
  @override
  late final GeneratedColumn<String> knownLimitations = GeneratedColumn<String>(
    'known_limitations',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _compatibilityDateMeta = const VerificationMeta(
    'compatibilityDate',
  );
  @override
  late final GeneratedColumn<DateTime> compatibilityDate =
      GeneratedColumn<DateTime>(
        'compatibility_date',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _importBatchMeta = const VerificationMeta(
    'importBatch',
  );
  @override
  late final GeneratedColumn<String> importBatch = GeneratedColumn<String>(
    'import_batch',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    source,
    manufacturer,
    model,
    chipset,
    cpuArchitecture,
    cpuCharacteristics,
    gpu,
    ramBytes,
    androidVersion,
    graphicsApi,
    emulatorId,
    consoleId,
    testedGame,
    testResult,
    performanceNotes,
    knownLimitations,
    compatibilityDate,
    importBatch,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'device_compatibility';
  @override
  VerificationContext validateIntegrity(
    Insertable<DeviceCompatibilityRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('manufacturer')) {
      context.handle(
        _manufacturerMeta,
        manufacturer.isAcceptableOrUnknown(
          data['manufacturer']!,
          _manufacturerMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_manufacturerMeta);
    }
    if (data.containsKey('model')) {
      context.handle(
        _modelMeta,
        model.isAcceptableOrUnknown(data['model']!, _modelMeta),
      );
    } else if (isInserting) {
      context.missing(_modelMeta);
    }
    if (data.containsKey('chipset')) {
      context.handle(
        _chipsetMeta,
        chipset.isAcceptableOrUnknown(data['chipset']!, _chipsetMeta),
      );
    }
    if (data.containsKey('cpu_architecture')) {
      context.handle(
        _cpuArchitectureMeta,
        cpuArchitecture.isAcceptableOrUnknown(
          data['cpu_architecture']!,
          _cpuArchitectureMeta,
        ),
      );
    }
    if (data.containsKey('cpu_characteristics')) {
      context.handle(
        _cpuCharacteristicsMeta,
        cpuCharacteristics.isAcceptableOrUnknown(
          data['cpu_characteristics']!,
          _cpuCharacteristicsMeta,
        ),
      );
    }
    if (data.containsKey('gpu')) {
      context.handle(
        _gpuMeta,
        gpu.isAcceptableOrUnknown(data['gpu']!, _gpuMeta),
      );
    }
    if (data.containsKey('ram_bytes')) {
      context.handle(
        _ramBytesMeta,
        ramBytes.isAcceptableOrUnknown(data['ram_bytes']!, _ramBytesMeta),
      );
    }
    if (data.containsKey('android_version')) {
      context.handle(
        _androidVersionMeta,
        androidVersion.isAcceptableOrUnknown(
          data['android_version']!,
          _androidVersionMeta,
        ),
      );
    }
    if (data.containsKey('graphics_api')) {
      context.handle(
        _graphicsApiMeta,
        graphicsApi.isAcceptableOrUnknown(
          data['graphics_api']!,
          _graphicsApiMeta,
        ),
      );
    }
    if (data.containsKey('emulator_id')) {
      context.handle(
        _emulatorIdMeta,
        emulatorId.isAcceptableOrUnknown(data['emulator_id']!, _emulatorIdMeta),
      );
    }
    if (data.containsKey('console_id')) {
      context.handle(
        _consoleIdMeta,
        consoleId.isAcceptableOrUnknown(data['console_id']!, _consoleIdMeta),
      );
    }
    if (data.containsKey('tested_game')) {
      context.handle(
        _testedGameMeta,
        testedGame.isAcceptableOrUnknown(data['tested_game']!, _testedGameMeta),
      );
    }
    if (data.containsKey('test_result')) {
      context.handle(
        _testResultMeta,
        testResult.isAcceptableOrUnknown(data['test_result']!, _testResultMeta),
      );
    }
    if (data.containsKey('performance_notes')) {
      context.handle(
        _performanceNotesMeta,
        performanceNotes.isAcceptableOrUnknown(
          data['performance_notes']!,
          _performanceNotesMeta,
        ),
      );
    }
    if (data.containsKey('known_limitations')) {
      context.handle(
        _knownLimitationsMeta,
        knownLimitations.isAcceptableOrUnknown(
          data['known_limitations']!,
          _knownLimitationsMeta,
        ),
      );
    }
    if (data.containsKey('compatibility_date')) {
      context.handle(
        _compatibilityDateMeta,
        compatibilityDate.isAcceptableOrUnknown(
          data['compatibility_date']!,
          _compatibilityDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_compatibilityDateMeta);
    }
    if (data.containsKey('import_batch')) {
      context.handle(
        _importBatchMeta,
        importBatch.isAcceptableOrUnknown(
          data['import_batch']!,
          _importBatchMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DeviceCompatibilityRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DeviceCompatibilityRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      manufacturer: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}manufacturer'],
      )!,
      model: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}model'],
      )!,
      chipset: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}chipset'],
      ),
      cpuArchitecture: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cpu_architecture'],
      ),
      cpuCharacteristics: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cpu_characteristics'],
      ),
      gpu: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}gpu'],
      ),
      ramBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ram_bytes'],
      ),
      androidVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}android_version'],
      ),
      graphicsApi: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}graphics_api'],
      ),
      emulatorId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}emulator_id'],
      ),
      consoleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}console_id'],
      ),
      testedGame: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tested_game'],
      ),
      testResult: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}test_result'],
      ),
      performanceNotes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}performance_notes'],
      ),
      knownLimitations: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}known_limitations'],
      ),
      compatibilityDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}compatibility_date'],
      )!,
      importBatch: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}import_batch'],
      ),
    );
  }

  @override
  $DeviceCompatibilityTable createAlias(String alias) {
    return $DeviceCompatibilityTable(attachedDatabase, alias);
  }
}

class DeviceCompatibilityRow extends DataClass
    implements Insertable<DeviceCompatibilityRow> {
  final int id;
  final String source;
  final String manufacturer;
  final String model;
  final String? chipset;
  final String? cpuArchitecture;
  final String? cpuCharacteristics;
  final String? gpu;
  final int? ramBytes;
  final String? androidVersion;
  final String? graphicsApi;
  final String? emulatorId;
  final String? consoleId;
  final String? testedGame;
  final String? testResult;
  final String? performanceNotes;
  final String? knownLimitations;
  final DateTime compatibilityDate;

  /// Identifier of the imported database bundle this row came from, if any.
  final String? importBatch;
  const DeviceCompatibilityRow({
    required this.id,
    required this.source,
    required this.manufacturer,
    required this.model,
    this.chipset,
    this.cpuArchitecture,
    this.cpuCharacteristics,
    this.gpu,
    this.ramBytes,
    this.androidVersion,
    this.graphicsApi,
    this.emulatorId,
    this.consoleId,
    this.testedGame,
    this.testResult,
    this.performanceNotes,
    this.knownLimitations,
    required this.compatibilityDate,
    this.importBatch,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['source'] = Variable<String>(source);
    map['manufacturer'] = Variable<String>(manufacturer);
    map['model'] = Variable<String>(model);
    if (!nullToAbsent || chipset != null) {
      map['chipset'] = Variable<String>(chipset);
    }
    if (!nullToAbsent || cpuArchitecture != null) {
      map['cpu_architecture'] = Variable<String>(cpuArchitecture);
    }
    if (!nullToAbsent || cpuCharacteristics != null) {
      map['cpu_characteristics'] = Variable<String>(cpuCharacteristics);
    }
    if (!nullToAbsent || gpu != null) {
      map['gpu'] = Variable<String>(gpu);
    }
    if (!nullToAbsent || ramBytes != null) {
      map['ram_bytes'] = Variable<int>(ramBytes);
    }
    if (!nullToAbsent || androidVersion != null) {
      map['android_version'] = Variable<String>(androidVersion);
    }
    if (!nullToAbsent || graphicsApi != null) {
      map['graphics_api'] = Variable<String>(graphicsApi);
    }
    if (!nullToAbsent || emulatorId != null) {
      map['emulator_id'] = Variable<String>(emulatorId);
    }
    if (!nullToAbsent || consoleId != null) {
      map['console_id'] = Variable<String>(consoleId);
    }
    if (!nullToAbsent || testedGame != null) {
      map['tested_game'] = Variable<String>(testedGame);
    }
    if (!nullToAbsent || testResult != null) {
      map['test_result'] = Variable<String>(testResult);
    }
    if (!nullToAbsent || performanceNotes != null) {
      map['performance_notes'] = Variable<String>(performanceNotes);
    }
    if (!nullToAbsent || knownLimitations != null) {
      map['known_limitations'] = Variable<String>(knownLimitations);
    }
    map['compatibility_date'] = Variable<DateTime>(compatibilityDate);
    if (!nullToAbsent || importBatch != null) {
      map['import_batch'] = Variable<String>(importBatch);
    }
    return map;
  }

  DeviceCompatibilityCompanion toCompanion(bool nullToAbsent) {
    return DeviceCompatibilityCompanion(
      id: Value(id),
      source: Value(source),
      manufacturer: Value(manufacturer),
      model: Value(model),
      chipset: chipset == null && nullToAbsent
          ? const Value.absent()
          : Value(chipset),
      cpuArchitecture: cpuArchitecture == null && nullToAbsent
          ? const Value.absent()
          : Value(cpuArchitecture),
      cpuCharacteristics: cpuCharacteristics == null && nullToAbsent
          ? const Value.absent()
          : Value(cpuCharacteristics),
      gpu: gpu == null && nullToAbsent ? const Value.absent() : Value(gpu),
      ramBytes: ramBytes == null && nullToAbsent
          ? const Value.absent()
          : Value(ramBytes),
      androidVersion: androidVersion == null && nullToAbsent
          ? const Value.absent()
          : Value(androidVersion),
      graphicsApi: graphicsApi == null && nullToAbsent
          ? const Value.absent()
          : Value(graphicsApi),
      emulatorId: emulatorId == null && nullToAbsent
          ? const Value.absent()
          : Value(emulatorId),
      consoleId: consoleId == null && nullToAbsent
          ? const Value.absent()
          : Value(consoleId),
      testedGame: testedGame == null && nullToAbsent
          ? const Value.absent()
          : Value(testedGame),
      testResult: testResult == null && nullToAbsent
          ? const Value.absent()
          : Value(testResult),
      performanceNotes: performanceNotes == null && nullToAbsent
          ? const Value.absent()
          : Value(performanceNotes),
      knownLimitations: knownLimitations == null && nullToAbsent
          ? const Value.absent()
          : Value(knownLimitations),
      compatibilityDate: Value(compatibilityDate),
      importBatch: importBatch == null && nullToAbsent
          ? const Value.absent()
          : Value(importBatch),
    );
  }

  factory DeviceCompatibilityRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DeviceCompatibilityRow(
      id: serializer.fromJson<int>(json['id']),
      source: serializer.fromJson<String>(json['source']),
      manufacturer: serializer.fromJson<String>(json['manufacturer']),
      model: serializer.fromJson<String>(json['model']),
      chipset: serializer.fromJson<String?>(json['chipset']),
      cpuArchitecture: serializer.fromJson<String?>(json['cpuArchitecture']),
      cpuCharacteristics: serializer.fromJson<String?>(
        json['cpuCharacteristics'],
      ),
      gpu: serializer.fromJson<String?>(json['gpu']),
      ramBytes: serializer.fromJson<int?>(json['ramBytes']),
      androidVersion: serializer.fromJson<String?>(json['androidVersion']),
      graphicsApi: serializer.fromJson<String?>(json['graphicsApi']),
      emulatorId: serializer.fromJson<String?>(json['emulatorId']),
      consoleId: serializer.fromJson<String?>(json['consoleId']),
      testedGame: serializer.fromJson<String?>(json['testedGame']),
      testResult: serializer.fromJson<String?>(json['testResult']),
      performanceNotes: serializer.fromJson<String?>(json['performanceNotes']),
      knownLimitations: serializer.fromJson<String?>(json['knownLimitations']),
      compatibilityDate: serializer.fromJson<DateTime>(
        json['compatibilityDate'],
      ),
      importBatch: serializer.fromJson<String?>(json['importBatch']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'source': serializer.toJson<String>(source),
      'manufacturer': serializer.toJson<String>(manufacturer),
      'model': serializer.toJson<String>(model),
      'chipset': serializer.toJson<String?>(chipset),
      'cpuArchitecture': serializer.toJson<String?>(cpuArchitecture),
      'cpuCharacteristics': serializer.toJson<String?>(cpuCharacteristics),
      'gpu': serializer.toJson<String?>(gpu),
      'ramBytes': serializer.toJson<int?>(ramBytes),
      'androidVersion': serializer.toJson<String?>(androidVersion),
      'graphicsApi': serializer.toJson<String?>(graphicsApi),
      'emulatorId': serializer.toJson<String?>(emulatorId),
      'consoleId': serializer.toJson<String?>(consoleId),
      'testedGame': serializer.toJson<String?>(testedGame),
      'testResult': serializer.toJson<String?>(testResult),
      'performanceNotes': serializer.toJson<String?>(performanceNotes),
      'knownLimitations': serializer.toJson<String?>(knownLimitations),
      'compatibilityDate': serializer.toJson<DateTime>(compatibilityDate),
      'importBatch': serializer.toJson<String?>(importBatch),
    };
  }

  DeviceCompatibilityRow copyWith({
    int? id,
    String? source,
    String? manufacturer,
    String? model,
    Value<String?> chipset = const Value.absent(),
    Value<String?> cpuArchitecture = const Value.absent(),
    Value<String?> cpuCharacteristics = const Value.absent(),
    Value<String?> gpu = const Value.absent(),
    Value<int?> ramBytes = const Value.absent(),
    Value<String?> androidVersion = const Value.absent(),
    Value<String?> graphicsApi = const Value.absent(),
    Value<String?> emulatorId = const Value.absent(),
    Value<String?> consoleId = const Value.absent(),
    Value<String?> testedGame = const Value.absent(),
    Value<String?> testResult = const Value.absent(),
    Value<String?> performanceNotes = const Value.absent(),
    Value<String?> knownLimitations = const Value.absent(),
    DateTime? compatibilityDate,
    Value<String?> importBatch = const Value.absent(),
  }) => DeviceCompatibilityRow(
    id: id ?? this.id,
    source: source ?? this.source,
    manufacturer: manufacturer ?? this.manufacturer,
    model: model ?? this.model,
    chipset: chipset.present ? chipset.value : this.chipset,
    cpuArchitecture: cpuArchitecture.present
        ? cpuArchitecture.value
        : this.cpuArchitecture,
    cpuCharacteristics: cpuCharacteristics.present
        ? cpuCharacteristics.value
        : this.cpuCharacteristics,
    gpu: gpu.present ? gpu.value : this.gpu,
    ramBytes: ramBytes.present ? ramBytes.value : this.ramBytes,
    androidVersion: androidVersion.present
        ? androidVersion.value
        : this.androidVersion,
    graphicsApi: graphicsApi.present ? graphicsApi.value : this.graphicsApi,
    emulatorId: emulatorId.present ? emulatorId.value : this.emulatorId,
    consoleId: consoleId.present ? consoleId.value : this.consoleId,
    testedGame: testedGame.present ? testedGame.value : this.testedGame,
    testResult: testResult.present ? testResult.value : this.testResult,
    performanceNotes: performanceNotes.present
        ? performanceNotes.value
        : this.performanceNotes,
    knownLimitations: knownLimitations.present
        ? knownLimitations.value
        : this.knownLimitations,
    compatibilityDate: compatibilityDate ?? this.compatibilityDate,
    importBatch: importBatch.present ? importBatch.value : this.importBatch,
  );
  DeviceCompatibilityRow copyWithCompanion(DeviceCompatibilityCompanion data) {
    return DeviceCompatibilityRow(
      id: data.id.present ? data.id.value : this.id,
      source: data.source.present ? data.source.value : this.source,
      manufacturer: data.manufacturer.present
          ? data.manufacturer.value
          : this.manufacturer,
      model: data.model.present ? data.model.value : this.model,
      chipset: data.chipset.present ? data.chipset.value : this.chipset,
      cpuArchitecture: data.cpuArchitecture.present
          ? data.cpuArchitecture.value
          : this.cpuArchitecture,
      cpuCharacteristics: data.cpuCharacteristics.present
          ? data.cpuCharacteristics.value
          : this.cpuCharacteristics,
      gpu: data.gpu.present ? data.gpu.value : this.gpu,
      ramBytes: data.ramBytes.present ? data.ramBytes.value : this.ramBytes,
      androidVersion: data.androidVersion.present
          ? data.androidVersion.value
          : this.androidVersion,
      graphicsApi: data.graphicsApi.present
          ? data.graphicsApi.value
          : this.graphicsApi,
      emulatorId: data.emulatorId.present
          ? data.emulatorId.value
          : this.emulatorId,
      consoleId: data.consoleId.present ? data.consoleId.value : this.consoleId,
      testedGame: data.testedGame.present
          ? data.testedGame.value
          : this.testedGame,
      testResult: data.testResult.present
          ? data.testResult.value
          : this.testResult,
      performanceNotes: data.performanceNotes.present
          ? data.performanceNotes.value
          : this.performanceNotes,
      knownLimitations: data.knownLimitations.present
          ? data.knownLimitations.value
          : this.knownLimitations,
      compatibilityDate: data.compatibilityDate.present
          ? data.compatibilityDate.value
          : this.compatibilityDate,
      importBatch: data.importBatch.present
          ? data.importBatch.value
          : this.importBatch,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DeviceCompatibilityRow(')
          ..write('id: $id, ')
          ..write('source: $source, ')
          ..write('manufacturer: $manufacturer, ')
          ..write('model: $model, ')
          ..write('chipset: $chipset, ')
          ..write('cpuArchitecture: $cpuArchitecture, ')
          ..write('cpuCharacteristics: $cpuCharacteristics, ')
          ..write('gpu: $gpu, ')
          ..write('ramBytes: $ramBytes, ')
          ..write('androidVersion: $androidVersion, ')
          ..write('graphicsApi: $graphicsApi, ')
          ..write('emulatorId: $emulatorId, ')
          ..write('consoleId: $consoleId, ')
          ..write('testedGame: $testedGame, ')
          ..write('testResult: $testResult, ')
          ..write('performanceNotes: $performanceNotes, ')
          ..write('knownLimitations: $knownLimitations, ')
          ..write('compatibilityDate: $compatibilityDate, ')
          ..write('importBatch: $importBatch')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    source,
    manufacturer,
    model,
    chipset,
    cpuArchitecture,
    cpuCharacteristics,
    gpu,
    ramBytes,
    androidVersion,
    graphicsApi,
    emulatorId,
    consoleId,
    testedGame,
    testResult,
    performanceNotes,
    knownLimitations,
    compatibilityDate,
    importBatch,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DeviceCompatibilityRow &&
          other.id == this.id &&
          other.source == this.source &&
          other.manufacturer == this.manufacturer &&
          other.model == this.model &&
          other.chipset == this.chipset &&
          other.cpuArchitecture == this.cpuArchitecture &&
          other.cpuCharacteristics == this.cpuCharacteristics &&
          other.gpu == this.gpu &&
          other.ramBytes == this.ramBytes &&
          other.androidVersion == this.androidVersion &&
          other.graphicsApi == this.graphicsApi &&
          other.emulatorId == this.emulatorId &&
          other.consoleId == this.consoleId &&
          other.testedGame == this.testedGame &&
          other.testResult == this.testResult &&
          other.performanceNotes == this.performanceNotes &&
          other.knownLimitations == this.knownLimitations &&
          other.compatibilityDate == this.compatibilityDate &&
          other.importBatch == this.importBatch);
}

class DeviceCompatibilityCompanion
    extends UpdateCompanion<DeviceCompatibilityRow> {
  final Value<int> id;
  final Value<String> source;
  final Value<String> manufacturer;
  final Value<String> model;
  final Value<String?> chipset;
  final Value<String?> cpuArchitecture;
  final Value<String?> cpuCharacteristics;
  final Value<String?> gpu;
  final Value<int?> ramBytes;
  final Value<String?> androidVersion;
  final Value<String?> graphicsApi;
  final Value<String?> emulatorId;
  final Value<String?> consoleId;
  final Value<String?> testedGame;
  final Value<String?> testResult;
  final Value<String?> performanceNotes;
  final Value<String?> knownLimitations;
  final Value<DateTime> compatibilityDate;
  final Value<String?> importBatch;
  const DeviceCompatibilityCompanion({
    this.id = const Value.absent(),
    this.source = const Value.absent(),
    this.manufacturer = const Value.absent(),
    this.model = const Value.absent(),
    this.chipset = const Value.absent(),
    this.cpuArchitecture = const Value.absent(),
    this.cpuCharacteristics = const Value.absent(),
    this.gpu = const Value.absent(),
    this.ramBytes = const Value.absent(),
    this.androidVersion = const Value.absent(),
    this.graphicsApi = const Value.absent(),
    this.emulatorId = const Value.absent(),
    this.consoleId = const Value.absent(),
    this.testedGame = const Value.absent(),
    this.testResult = const Value.absent(),
    this.performanceNotes = const Value.absent(),
    this.knownLimitations = const Value.absent(),
    this.compatibilityDate = const Value.absent(),
    this.importBatch = const Value.absent(),
  });
  DeviceCompatibilityCompanion.insert({
    this.id = const Value.absent(),
    required String source,
    required String manufacturer,
    required String model,
    this.chipset = const Value.absent(),
    this.cpuArchitecture = const Value.absent(),
    this.cpuCharacteristics = const Value.absent(),
    this.gpu = const Value.absent(),
    this.ramBytes = const Value.absent(),
    this.androidVersion = const Value.absent(),
    this.graphicsApi = const Value.absent(),
    this.emulatorId = const Value.absent(),
    this.consoleId = const Value.absent(),
    this.testedGame = const Value.absent(),
    this.testResult = const Value.absent(),
    this.performanceNotes = const Value.absent(),
    this.knownLimitations = const Value.absent(),
    required DateTime compatibilityDate,
    this.importBatch = const Value.absent(),
  }) : source = Value(source),
       manufacturer = Value(manufacturer),
       model = Value(model),
       compatibilityDate = Value(compatibilityDate);
  static Insertable<DeviceCompatibilityRow> custom({
    Expression<int>? id,
    Expression<String>? source,
    Expression<String>? manufacturer,
    Expression<String>? model,
    Expression<String>? chipset,
    Expression<String>? cpuArchitecture,
    Expression<String>? cpuCharacteristics,
    Expression<String>? gpu,
    Expression<int>? ramBytes,
    Expression<String>? androidVersion,
    Expression<String>? graphicsApi,
    Expression<String>? emulatorId,
    Expression<String>? consoleId,
    Expression<String>? testedGame,
    Expression<String>? testResult,
    Expression<String>? performanceNotes,
    Expression<String>? knownLimitations,
    Expression<DateTime>? compatibilityDate,
    Expression<String>? importBatch,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (source != null) 'source': source,
      if (manufacturer != null) 'manufacturer': manufacturer,
      if (model != null) 'model': model,
      if (chipset != null) 'chipset': chipset,
      if (cpuArchitecture != null) 'cpu_architecture': cpuArchitecture,
      if (cpuCharacteristics != null) 'cpu_characteristics': cpuCharacteristics,
      if (gpu != null) 'gpu': gpu,
      if (ramBytes != null) 'ram_bytes': ramBytes,
      if (androidVersion != null) 'android_version': androidVersion,
      if (graphicsApi != null) 'graphics_api': graphicsApi,
      if (emulatorId != null) 'emulator_id': emulatorId,
      if (consoleId != null) 'console_id': consoleId,
      if (testedGame != null) 'tested_game': testedGame,
      if (testResult != null) 'test_result': testResult,
      if (performanceNotes != null) 'performance_notes': performanceNotes,
      if (knownLimitations != null) 'known_limitations': knownLimitations,
      if (compatibilityDate != null) 'compatibility_date': compatibilityDate,
      if (importBatch != null) 'import_batch': importBatch,
    });
  }

  DeviceCompatibilityCompanion copyWith({
    Value<int>? id,
    Value<String>? source,
    Value<String>? manufacturer,
    Value<String>? model,
    Value<String?>? chipset,
    Value<String?>? cpuArchitecture,
    Value<String?>? cpuCharacteristics,
    Value<String?>? gpu,
    Value<int?>? ramBytes,
    Value<String?>? androidVersion,
    Value<String?>? graphicsApi,
    Value<String?>? emulatorId,
    Value<String?>? consoleId,
    Value<String?>? testedGame,
    Value<String?>? testResult,
    Value<String?>? performanceNotes,
    Value<String?>? knownLimitations,
    Value<DateTime>? compatibilityDate,
    Value<String?>? importBatch,
  }) {
    return DeviceCompatibilityCompanion(
      id: id ?? this.id,
      source: source ?? this.source,
      manufacturer: manufacturer ?? this.manufacturer,
      model: model ?? this.model,
      chipset: chipset ?? this.chipset,
      cpuArchitecture: cpuArchitecture ?? this.cpuArchitecture,
      cpuCharacteristics: cpuCharacteristics ?? this.cpuCharacteristics,
      gpu: gpu ?? this.gpu,
      ramBytes: ramBytes ?? this.ramBytes,
      androidVersion: androidVersion ?? this.androidVersion,
      graphicsApi: graphicsApi ?? this.graphicsApi,
      emulatorId: emulatorId ?? this.emulatorId,
      consoleId: consoleId ?? this.consoleId,
      testedGame: testedGame ?? this.testedGame,
      testResult: testResult ?? this.testResult,
      performanceNotes: performanceNotes ?? this.performanceNotes,
      knownLimitations: knownLimitations ?? this.knownLimitations,
      compatibilityDate: compatibilityDate ?? this.compatibilityDate,
      importBatch: importBatch ?? this.importBatch,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (manufacturer.present) {
      map['manufacturer'] = Variable<String>(manufacturer.value);
    }
    if (model.present) {
      map['model'] = Variable<String>(model.value);
    }
    if (chipset.present) {
      map['chipset'] = Variable<String>(chipset.value);
    }
    if (cpuArchitecture.present) {
      map['cpu_architecture'] = Variable<String>(cpuArchitecture.value);
    }
    if (cpuCharacteristics.present) {
      map['cpu_characteristics'] = Variable<String>(cpuCharacteristics.value);
    }
    if (gpu.present) {
      map['gpu'] = Variable<String>(gpu.value);
    }
    if (ramBytes.present) {
      map['ram_bytes'] = Variable<int>(ramBytes.value);
    }
    if (androidVersion.present) {
      map['android_version'] = Variable<String>(androidVersion.value);
    }
    if (graphicsApi.present) {
      map['graphics_api'] = Variable<String>(graphicsApi.value);
    }
    if (emulatorId.present) {
      map['emulator_id'] = Variable<String>(emulatorId.value);
    }
    if (consoleId.present) {
      map['console_id'] = Variable<String>(consoleId.value);
    }
    if (testedGame.present) {
      map['tested_game'] = Variable<String>(testedGame.value);
    }
    if (testResult.present) {
      map['test_result'] = Variable<String>(testResult.value);
    }
    if (performanceNotes.present) {
      map['performance_notes'] = Variable<String>(performanceNotes.value);
    }
    if (knownLimitations.present) {
      map['known_limitations'] = Variable<String>(knownLimitations.value);
    }
    if (compatibilityDate.present) {
      map['compatibility_date'] = Variable<DateTime>(compatibilityDate.value);
    }
    if (importBatch.present) {
      map['import_batch'] = Variable<String>(importBatch.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DeviceCompatibilityCompanion(')
          ..write('id: $id, ')
          ..write('source: $source, ')
          ..write('manufacturer: $manufacturer, ')
          ..write('model: $model, ')
          ..write('chipset: $chipset, ')
          ..write('cpuArchitecture: $cpuArchitecture, ')
          ..write('cpuCharacteristics: $cpuCharacteristics, ')
          ..write('gpu: $gpu, ')
          ..write('ramBytes: $ramBytes, ')
          ..write('androidVersion: $androidVersion, ')
          ..write('graphicsApi: $graphicsApi, ')
          ..write('emulatorId: $emulatorId, ')
          ..write('consoleId: $consoleId, ')
          ..write('testedGame: $testedGame, ')
          ..write('testResult: $testResult, ')
          ..write('performanceNotes: $performanceNotes, ')
          ..write('knownLimitations: $knownLimitations, ')
          ..write('compatibilityDate: $compatibilityDate, ')
          ..write('importBatch: $importBatch')
          ..write(')'))
        .toString();
  }
}

class $EmulatorsTable extends Emulators
    with TableInfo<$EmulatorsTable, EmulatorRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EmulatorsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _licenseMeta = const VerificationMeta(
    'license',
  );
  @override
  late final GeneratedColumn<String> license = GeneratedColumn<String>(
    'license',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _strategyMeta = const VerificationMeta(
    'strategy',
  );
  @override
  late final GeneratedColumn<String> strategy = GeneratedColumn<String>(
    'strategy',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _requiresArm64Meta = const VerificationMeta(
    'requiresArm64',
  );
  @override
  late final GeneratedColumn<bool> requiresArm64 = GeneratedColumn<bool>(
    'requires_arm64',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("requires_arm64" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _minSdkMeta = const VerificationMeta('minSdk');
  @override
  late final GeneratedColumn<int> minSdk = GeneratedColumn<int>(
    'min_sdk',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _consoleIdsMeta = const VerificationMeta(
    'consoleIds',
  );
  @override
  late final GeneratedColumn<String> consoleIds = GeneratedColumn<String>(
    'console_ids',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    license,
    strategy,
    requiresArm64,
    minSdk,
    consoleIds,
    notes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'emulators';
  @override
  VerificationContext validateIntegrity(
    Insertable<EmulatorRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('license')) {
      context.handle(
        _licenseMeta,
        license.isAcceptableOrUnknown(data['license']!, _licenseMeta),
      );
    } else if (isInserting) {
      context.missing(_licenseMeta);
    }
    if (data.containsKey('strategy')) {
      context.handle(
        _strategyMeta,
        strategy.isAcceptableOrUnknown(data['strategy']!, _strategyMeta),
      );
    } else if (isInserting) {
      context.missing(_strategyMeta);
    }
    if (data.containsKey('requires_arm64')) {
      context.handle(
        _requiresArm64Meta,
        requiresArm64.isAcceptableOrUnknown(
          data['requires_arm64']!,
          _requiresArm64Meta,
        ),
      );
    }
    if (data.containsKey('min_sdk')) {
      context.handle(
        _minSdkMeta,
        minSdk.isAcceptableOrUnknown(data['min_sdk']!, _minSdkMeta),
      );
    }
    if (data.containsKey('console_ids')) {
      context.handle(
        _consoleIdsMeta,
        consoleIds.isAcceptableOrUnknown(data['console_ids']!, _consoleIdsMeta),
      );
    } else if (isInserting) {
      context.missing(_consoleIdsMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  EmulatorRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EmulatorRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      license: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}license'],
      )!,
      strategy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}strategy'],
      )!,
      requiresArm64: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}requires_arm64'],
      )!,
      minSdk: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}min_sdk'],
      ),
      consoleIds: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}console_ids'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
    );
  }

  @override
  $EmulatorsTable createAlias(String alias) {
    return $EmulatorsTable(attachedDatabase, alias);
  }
}

class EmulatorRow extends DataClass implements Insertable<EmulatorRow> {
  final String id;
  final String name;
  final String license;
  final String strategy;
  final bool requiresArm64;
  final int? minSdk;
  final String consoleIds;
  final String? notes;
  const EmulatorRow({
    required this.id,
    required this.name,
    required this.license,
    required this.strategy,
    required this.requiresArm64,
    this.minSdk,
    required this.consoleIds,
    this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['license'] = Variable<String>(license);
    map['strategy'] = Variable<String>(strategy);
    map['requires_arm64'] = Variable<bool>(requiresArm64);
    if (!nullToAbsent || minSdk != null) {
      map['min_sdk'] = Variable<int>(minSdk);
    }
    map['console_ids'] = Variable<String>(consoleIds);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  EmulatorsCompanion toCompanion(bool nullToAbsent) {
    return EmulatorsCompanion(
      id: Value(id),
      name: Value(name),
      license: Value(license),
      strategy: Value(strategy),
      requiresArm64: Value(requiresArm64),
      minSdk: minSdk == null && nullToAbsent
          ? const Value.absent()
          : Value(minSdk),
      consoleIds: Value(consoleIds),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
    );
  }

  factory EmulatorRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EmulatorRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      license: serializer.fromJson<String>(json['license']),
      strategy: serializer.fromJson<String>(json['strategy']),
      requiresArm64: serializer.fromJson<bool>(json['requiresArm64']),
      minSdk: serializer.fromJson<int?>(json['minSdk']),
      consoleIds: serializer.fromJson<String>(json['consoleIds']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'license': serializer.toJson<String>(license),
      'strategy': serializer.toJson<String>(strategy),
      'requiresArm64': serializer.toJson<bool>(requiresArm64),
      'minSdk': serializer.toJson<int?>(minSdk),
      'consoleIds': serializer.toJson<String>(consoleIds),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  EmulatorRow copyWith({
    String? id,
    String? name,
    String? license,
    String? strategy,
    bool? requiresArm64,
    Value<int?> minSdk = const Value.absent(),
    String? consoleIds,
    Value<String?> notes = const Value.absent(),
  }) => EmulatorRow(
    id: id ?? this.id,
    name: name ?? this.name,
    license: license ?? this.license,
    strategy: strategy ?? this.strategy,
    requiresArm64: requiresArm64 ?? this.requiresArm64,
    minSdk: minSdk.present ? minSdk.value : this.minSdk,
    consoleIds: consoleIds ?? this.consoleIds,
    notes: notes.present ? notes.value : this.notes,
  );
  EmulatorRow copyWithCompanion(EmulatorsCompanion data) {
    return EmulatorRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      license: data.license.present ? data.license.value : this.license,
      strategy: data.strategy.present ? data.strategy.value : this.strategy,
      requiresArm64: data.requiresArm64.present
          ? data.requiresArm64.value
          : this.requiresArm64,
      minSdk: data.minSdk.present ? data.minSdk.value : this.minSdk,
      consoleIds: data.consoleIds.present
          ? data.consoleIds.value
          : this.consoleIds,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EmulatorRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('license: $license, ')
          ..write('strategy: $strategy, ')
          ..write('requiresArm64: $requiresArm64, ')
          ..write('minSdk: $minSdk, ')
          ..write('consoleIds: $consoleIds, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    license,
    strategy,
    requiresArm64,
    minSdk,
    consoleIds,
    notes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EmulatorRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.license == this.license &&
          other.strategy == this.strategy &&
          other.requiresArm64 == this.requiresArm64 &&
          other.minSdk == this.minSdk &&
          other.consoleIds == this.consoleIds &&
          other.notes == this.notes);
}

class EmulatorsCompanion extends UpdateCompanion<EmulatorRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> license;
  final Value<String> strategy;
  final Value<bool> requiresArm64;
  final Value<int?> minSdk;
  final Value<String> consoleIds;
  final Value<String?> notes;
  final Value<int> rowid;
  const EmulatorsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.license = const Value.absent(),
    this.strategy = const Value.absent(),
    this.requiresArm64 = const Value.absent(),
    this.minSdk = const Value.absent(),
    this.consoleIds = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EmulatorsCompanion.insert({
    required String id,
    required String name,
    required String license,
    required String strategy,
    this.requiresArm64 = const Value.absent(),
    this.minSdk = const Value.absent(),
    required String consoleIds,
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       license = Value(license),
       strategy = Value(strategy),
       consoleIds = Value(consoleIds);
  static Insertable<EmulatorRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? license,
    Expression<String>? strategy,
    Expression<bool>? requiresArm64,
    Expression<int>? minSdk,
    Expression<String>? consoleIds,
    Expression<String>? notes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (license != null) 'license': license,
      if (strategy != null) 'strategy': strategy,
      if (requiresArm64 != null) 'requires_arm64': requiresArm64,
      if (minSdk != null) 'min_sdk': minSdk,
      if (consoleIds != null) 'console_ids': consoleIds,
      if (notes != null) 'notes': notes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EmulatorsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? license,
    Value<String>? strategy,
    Value<bool>? requiresArm64,
    Value<int?>? minSdk,
    Value<String>? consoleIds,
    Value<String?>? notes,
    Value<int>? rowid,
  }) {
    return EmulatorsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      license: license ?? this.license,
      strategy: strategy ?? this.strategy,
      requiresArm64: requiresArm64 ?? this.requiresArm64,
      minSdk: minSdk ?? this.minSdk,
      consoleIds: consoleIds ?? this.consoleIds,
      notes: notes ?? this.notes,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (license.present) {
      map['license'] = Variable<String>(license.value);
    }
    if (strategy.present) {
      map['strategy'] = Variable<String>(strategy.value);
    }
    if (requiresArm64.present) {
      map['requires_arm64'] = Variable<bool>(requiresArm64.value);
    }
    if (minSdk.present) {
      map['min_sdk'] = Variable<int>(minSdk.value);
    }
    if (consoleIds.present) {
      map['console_ids'] = Variable<String>(consoleIds.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EmulatorsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('license: $license, ')
          ..write('strategy: $strategy, ')
          ..write('requiresArm64: $requiresArm64, ')
          ..write('minSdk: $minSdk, ')
          ..write('consoleIds: $consoleIds, ')
          ..write('notes: $notes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ConsolesTable extends Consoles
    with TableInfo<$ConsolesTable, ConsoleRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ConsolesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _manufacturerMeta = const VerificationMeta(
    'manufacturer',
  );
  @override
  late final GeneratedColumn<String> manufacturer = GeneratedColumn<String>(
    'manufacturer',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _folderNameMeta = const VerificationMeta(
    'folderName',
  );
  @override
  late final GeneratedColumn<String> folderName = GeneratedColumn<String>(
    'folder_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _extensionsMeta = const VerificationMeta(
    'extensions',
  );
  @override
  late final GeneratedColumn<String> extensions = GeneratedColumn<String>(
    'extensions',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _minTierMeta = const VerificationMeta(
    'minTier',
  );
  @override
  late final GeneratedColumn<String> minTier = GeneratedColumn<String>(
    'min_tier',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recommendedTierMeta = const VerificationMeta(
    'recommendedTier',
  );
  @override
  late final GeneratedColumn<String> recommendedTier = GeneratedColumn<String>(
    'recommended_tier',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _enabledMeta = const VerificationMeta(
    'enabled',
  );
  @override
  late final GeneratedColumn<bool> enabled = GeneratedColumn<bool>(
    'enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    manufacturer,
    category,
    folderName,
    extensions,
    minTier,
    recommendedTier,
    enabled,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'consoles';
  @override
  VerificationContext validateIntegrity(
    Insertable<ConsoleRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('manufacturer')) {
      context.handle(
        _manufacturerMeta,
        manufacturer.isAcceptableOrUnknown(
          data['manufacturer']!,
          _manufacturerMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_manufacturerMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('folder_name')) {
      context.handle(
        _folderNameMeta,
        folderName.isAcceptableOrUnknown(data['folder_name']!, _folderNameMeta),
      );
    } else if (isInserting) {
      context.missing(_folderNameMeta);
    }
    if (data.containsKey('extensions')) {
      context.handle(
        _extensionsMeta,
        extensions.isAcceptableOrUnknown(data['extensions']!, _extensionsMeta),
      );
    } else if (isInserting) {
      context.missing(_extensionsMeta);
    }
    if (data.containsKey('min_tier')) {
      context.handle(
        _minTierMeta,
        minTier.isAcceptableOrUnknown(data['min_tier']!, _minTierMeta),
      );
    } else if (isInserting) {
      context.missing(_minTierMeta);
    }
    if (data.containsKey('recommended_tier')) {
      context.handle(
        _recommendedTierMeta,
        recommendedTier.isAcceptableOrUnknown(
          data['recommended_tier']!,
          _recommendedTierMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_recommendedTierMeta);
    }
    if (data.containsKey('enabled')) {
      context.handle(
        _enabledMeta,
        enabled.isAcceptableOrUnknown(data['enabled']!, _enabledMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ConsoleRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ConsoleRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      manufacturer: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}manufacturer'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      folderName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}folder_name'],
      )!,
      extensions: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}extensions'],
      )!,
      minTier: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}min_tier'],
      )!,
      recommendedTier: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recommended_tier'],
      )!,
      enabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}enabled'],
      )!,
    );
  }

  @override
  $ConsolesTable createAlias(String alias) {
    return $ConsolesTable(attachedDatabase, alias);
  }
}

class ConsoleRow extends DataClass implements Insertable<ConsoleRow> {
  final String id;
  final String name;
  final String manufacturer;
  final String category;
  final String folderName;

  /// Comma-separated lower-case extensions.
  final String extensions;
  final String minTier;
  final String recommendedTier;
  final bool enabled;
  const ConsoleRow({
    required this.id,
    required this.name,
    required this.manufacturer,
    required this.category,
    required this.folderName,
    required this.extensions,
    required this.minTier,
    required this.recommendedTier,
    required this.enabled,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['manufacturer'] = Variable<String>(manufacturer);
    map['category'] = Variable<String>(category);
    map['folder_name'] = Variable<String>(folderName);
    map['extensions'] = Variable<String>(extensions);
    map['min_tier'] = Variable<String>(minTier);
    map['recommended_tier'] = Variable<String>(recommendedTier);
    map['enabled'] = Variable<bool>(enabled);
    return map;
  }

  ConsolesCompanion toCompanion(bool nullToAbsent) {
    return ConsolesCompanion(
      id: Value(id),
      name: Value(name),
      manufacturer: Value(manufacturer),
      category: Value(category),
      folderName: Value(folderName),
      extensions: Value(extensions),
      minTier: Value(minTier),
      recommendedTier: Value(recommendedTier),
      enabled: Value(enabled),
    );
  }

  factory ConsoleRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ConsoleRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      manufacturer: serializer.fromJson<String>(json['manufacturer']),
      category: serializer.fromJson<String>(json['category']),
      folderName: serializer.fromJson<String>(json['folderName']),
      extensions: serializer.fromJson<String>(json['extensions']),
      minTier: serializer.fromJson<String>(json['minTier']),
      recommendedTier: serializer.fromJson<String>(json['recommendedTier']),
      enabled: serializer.fromJson<bool>(json['enabled']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'manufacturer': serializer.toJson<String>(manufacturer),
      'category': serializer.toJson<String>(category),
      'folderName': serializer.toJson<String>(folderName),
      'extensions': serializer.toJson<String>(extensions),
      'minTier': serializer.toJson<String>(minTier),
      'recommendedTier': serializer.toJson<String>(recommendedTier),
      'enabled': serializer.toJson<bool>(enabled),
    };
  }

  ConsoleRow copyWith({
    String? id,
    String? name,
    String? manufacturer,
    String? category,
    String? folderName,
    String? extensions,
    String? minTier,
    String? recommendedTier,
    bool? enabled,
  }) => ConsoleRow(
    id: id ?? this.id,
    name: name ?? this.name,
    manufacturer: manufacturer ?? this.manufacturer,
    category: category ?? this.category,
    folderName: folderName ?? this.folderName,
    extensions: extensions ?? this.extensions,
    minTier: minTier ?? this.minTier,
    recommendedTier: recommendedTier ?? this.recommendedTier,
    enabled: enabled ?? this.enabled,
  );
  ConsoleRow copyWithCompanion(ConsolesCompanion data) {
    return ConsoleRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      manufacturer: data.manufacturer.present
          ? data.manufacturer.value
          : this.manufacturer,
      category: data.category.present ? data.category.value : this.category,
      folderName: data.folderName.present
          ? data.folderName.value
          : this.folderName,
      extensions: data.extensions.present
          ? data.extensions.value
          : this.extensions,
      minTier: data.minTier.present ? data.minTier.value : this.minTier,
      recommendedTier: data.recommendedTier.present
          ? data.recommendedTier.value
          : this.recommendedTier,
      enabled: data.enabled.present ? data.enabled.value : this.enabled,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ConsoleRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('manufacturer: $manufacturer, ')
          ..write('category: $category, ')
          ..write('folderName: $folderName, ')
          ..write('extensions: $extensions, ')
          ..write('minTier: $minTier, ')
          ..write('recommendedTier: $recommendedTier, ')
          ..write('enabled: $enabled')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    manufacturer,
    category,
    folderName,
    extensions,
    minTier,
    recommendedTier,
    enabled,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ConsoleRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.manufacturer == this.manufacturer &&
          other.category == this.category &&
          other.folderName == this.folderName &&
          other.extensions == this.extensions &&
          other.minTier == this.minTier &&
          other.recommendedTier == this.recommendedTier &&
          other.enabled == this.enabled);
}

class ConsolesCompanion extends UpdateCompanion<ConsoleRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> manufacturer;
  final Value<String> category;
  final Value<String> folderName;
  final Value<String> extensions;
  final Value<String> minTier;
  final Value<String> recommendedTier;
  final Value<bool> enabled;
  final Value<int> rowid;
  const ConsolesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.manufacturer = const Value.absent(),
    this.category = const Value.absent(),
    this.folderName = const Value.absent(),
    this.extensions = const Value.absent(),
    this.minTier = const Value.absent(),
    this.recommendedTier = const Value.absent(),
    this.enabled = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ConsolesCompanion.insert({
    required String id,
    required String name,
    required String manufacturer,
    required String category,
    required String folderName,
    required String extensions,
    required String minTier,
    required String recommendedTier,
    this.enabled = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       manufacturer = Value(manufacturer),
       category = Value(category),
       folderName = Value(folderName),
       extensions = Value(extensions),
       minTier = Value(minTier),
       recommendedTier = Value(recommendedTier);
  static Insertable<ConsoleRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? manufacturer,
    Expression<String>? category,
    Expression<String>? folderName,
    Expression<String>? extensions,
    Expression<String>? minTier,
    Expression<String>? recommendedTier,
    Expression<bool>? enabled,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (manufacturer != null) 'manufacturer': manufacturer,
      if (category != null) 'category': category,
      if (folderName != null) 'folder_name': folderName,
      if (extensions != null) 'extensions': extensions,
      if (minTier != null) 'min_tier': minTier,
      if (recommendedTier != null) 'recommended_tier': recommendedTier,
      if (enabled != null) 'enabled': enabled,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ConsolesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? manufacturer,
    Value<String>? category,
    Value<String>? folderName,
    Value<String>? extensions,
    Value<String>? minTier,
    Value<String>? recommendedTier,
    Value<bool>? enabled,
    Value<int>? rowid,
  }) {
    return ConsolesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      manufacturer: manufacturer ?? this.manufacturer,
      category: category ?? this.category,
      folderName: folderName ?? this.folderName,
      extensions: extensions ?? this.extensions,
      minTier: minTier ?? this.minTier,
      recommendedTier: recommendedTier ?? this.recommendedTier,
      enabled: enabled ?? this.enabled,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (manufacturer.present) {
      map['manufacturer'] = Variable<String>(manufacturer.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (folderName.present) {
      map['folder_name'] = Variable<String>(folderName.value);
    }
    if (extensions.present) {
      map['extensions'] = Variable<String>(extensions.value);
    }
    if (minTier.present) {
      map['min_tier'] = Variable<String>(minTier.value);
    }
    if (recommendedTier.present) {
      map['recommended_tier'] = Variable<String>(recommendedTier.value);
    }
    if (enabled.present) {
      map['enabled'] = Variable<bool>(enabled.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ConsolesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('manufacturer: $manufacturer, ')
          ..write('category: $category, ')
          ..write('folderName: $folderName, ')
          ..write('extensions: $extensions, ')
          ..write('minTier: $minTier, ')
          ..write('recommendedTier: $recommendedTier, ')
          ..write('enabled: $enabled, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GamesTable extends Games with TableInfo<$GamesTable, GameRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GamesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sortTitleMeta = const VerificationMeta(
    'sortTitle',
  );
  @override
  late final GeneratedColumn<String> sortTitle = GeneratedColumn<String>(
    'sort_title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _consoleIdMeta = const VerificationMeta(
    'consoleId',
  );
  @override
  late final GeneratedColumn<String> consoleId = GeneratedColumn<String>(
    'console_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES consoles (id)',
    ),
  );
  static const VerificationMeta _preferredEmulatorIdMeta =
      const VerificationMeta('preferredEmulatorId');
  @override
  late final GeneratedColumn<String> preferredEmulatorId =
      GeneratedColumn<String>(
        'preferred_emulator_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES emulators (id)',
        ),
      );
  static const VerificationMeta _addedAtMeta = const VerificationMeta(
    'addedAt',
  );
  @override
  late final GeneratedColumn<DateTime> addedAt = GeneratedColumn<DateTime>(
    'added_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastPlayedAtMeta = const VerificationMeta(
    'lastPlayedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastPlayedAt = GeneratedColumn<DateTime>(
    'last_played_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _playCountMeta = const VerificationMeta(
    'playCount',
  );
  @override
  late final GeneratedColumn<int> playCount = GeneratedColumn<int>(
    'play_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _isMissingMeta = const VerificationMeta(
    'isMissing',
  );
  @override
  late final GeneratedColumn<bool> isMissing = GeneratedColumn<bool>(
    'is_missing',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_missing" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _regionsMeta = const VerificationMeta(
    'regions',
  );
  @override
  late final GeneratedColumn<String> regions = GeneratedColumn<String>(
    'regions',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    sortTitle,
    consoleId,
    preferredEmulatorId,
    addedAt,
    lastPlayedAt,
    playCount,
    isMissing,
    regions,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'games';
  @override
  VerificationContext validateIntegrity(
    Insertable<GameRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('sort_title')) {
      context.handle(
        _sortTitleMeta,
        sortTitle.isAcceptableOrUnknown(data['sort_title']!, _sortTitleMeta),
      );
    } else if (isInserting) {
      context.missing(_sortTitleMeta);
    }
    if (data.containsKey('console_id')) {
      context.handle(
        _consoleIdMeta,
        consoleId.isAcceptableOrUnknown(data['console_id']!, _consoleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_consoleIdMeta);
    }
    if (data.containsKey('preferred_emulator_id')) {
      context.handle(
        _preferredEmulatorIdMeta,
        preferredEmulatorId.isAcceptableOrUnknown(
          data['preferred_emulator_id']!,
          _preferredEmulatorIdMeta,
        ),
      );
    }
    if (data.containsKey('added_at')) {
      context.handle(
        _addedAtMeta,
        addedAt.isAcceptableOrUnknown(data['added_at']!, _addedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_addedAtMeta);
    }
    if (data.containsKey('last_played_at')) {
      context.handle(
        _lastPlayedAtMeta,
        lastPlayedAt.isAcceptableOrUnknown(
          data['last_played_at']!,
          _lastPlayedAtMeta,
        ),
      );
    }
    if (data.containsKey('play_count')) {
      context.handle(
        _playCountMeta,
        playCount.isAcceptableOrUnknown(data['play_count']!, _playCountMeta),
      );
    }
    if (data.containsKey('is_missing')) {
      context.handle(
        _isMissingMeta,
        isMissing.isAcceptableOrUnknown(data['is_missing']!, _isMissingMeta),
      );
    }
    if (data.containsKey('regions')) {
      context.handle(
        _regionsMeta,
        regions.isAcceptableOrUnknown(data['regions']!, _regionsMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GameRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GameRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      sortTitle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sort_title'],
      )!,
      consoleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}console_id'],
      )!,
      preferredEmulatorId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}preferred_emulator_id'],
      ),
      addedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}added_at'],
      )!,
      lastPlayedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_played_at'],
      ),
      playCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}play_count'],
      )!,
      isMissing: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_missing'],
      )!,
      regions: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}regions'],
      ),
    );
  }

  @override
  $GamesTable createAlias(String alias) {
    return $GamesTable(attachedDatabase, alias);
  }
}

class GameRow extends DataClass implements Insertable<GameRow> {
  final int id;
  final String title;
  final String sortTitle;
  final String consoleId;
  final String? preferredEmulatorId;
  final DateTime addedAt;
  final DateTime? lastPlayedAt;
  final int playCount;
  final bool isMissing;

  /// Comma-separated regions parsed from the file name (schema v2).
  final String? regions;
  const GameRow({
    required this.id,
    required this.title,
    required this.sortTitle,
    required this.consoleId,
    this.preferredEmulatorId,
    required this.addedAt,
    this.lastPlayedAt,
    required this.playCount,
    required this.isMissing,
    this.regions,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    map['sort_title'] = Variable<String>(sortTitle);
    map['console_id'] = Variable<String>(consoleId);
    if (!nullToAbsent || preferredEmulatorId != null) {
      map['preferred_emulator_id'] = Variable<String>(preferredEmulatorId);
    }
    map['added_at'] = Variable<DateTime>(addedAt);
    if (!nullToAbsent || lastPlayedAt != null) {
      map['last_played_at'] = Variable<DateTime>(lastPlayedAt);
    }
    map['play_count'] = Variable<int>(playCount);
    map['is_missing'] = Variable<bool>(isMissing);
    if (!nullToAbsent || regions != null) {
      map['regions'] = Variable<String>(regions);
    }
    return map;
  }

  GamesCompanion toCompanion(bool nullToAbsent) {
    return GamesCompanion(
      id: Value(id),
      title: Value(title),
      sortTitle: Value(sortTitle),
      consoleId: Value(consoleId),
      preferredEmulatorId: preferredEmulatorId == null && nullToAbsent
          ? const Value.absent()
          : Value(preferredEmulatorId),
      addedAt: Value(addedAt),
      lastPlayedAt: lastPlayedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastPlayedAt),
      playCount: Value(playCount),
      isMissing: Value(isMissing),
      regions: regions == null && nullToAbsent
          ? const Value.absent()
          : Value(regions),
    );
  }

  factory GameRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GameRow(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      sortTitle: serializer.fromJson<String>(json['sortTitle']),
      consoleId: serializer.fromJson<String>(json['consoleId']),
      preferredEmulatorId: serializer.fromJson<String?>(
        json['preferredEmulatorId'],
      ),
      addedAt: serializer.fromJson<DateTime>(json['addedAt']),
      lastPlayedAt: serializer.fromJson<DateTime?>(json['lastPlayedAt']),
      playCount: serializer.fromJson<int>(json['playCount']),
      isMissing: serializer.fromJson<bool>(json['isMissing']),
      regions: serializer.fromJson<String?>(json['regions']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'sortTitle': serializer.toJson<String>(sortTitle),
      'consoleId': serializer.toJson<String>(consoleId),
      'preferredEmulatorId': serializer.toJson<String?>(preferredEmulatorId),
      'addedAt': serializer.toJson<DateTime>(addedAt),
      'lastPlayedAt': serializer.toJson<DateTime?>(lastPlayedAt),
      'playCount': serializer.toJson<int>(playCount),
      'isMissing': serializer.toJson<bool>(isMissing),
      'regions': serializer.toJson<String?>(regions),
    };
  }

  GameRow copyWith({
    int? id,
    String? title,
    String? sortTitle,
    String? consoleId,
    Value<String?> preferredEmulatorId = const Value.absent(),
    DateTime? addedAt,
    Value<DateTime?> lastPlayedAt = const Value.absent(),
    int? playCount,
    bool? isMissing,
    Value<String?> regions = const Value.absent(),
  }) => GameRow(
    id: id ?? this.id,
    title: title ?? this.title,
    sortTitle: sortTitle ?? this.sortTitle,
    consoleId: consoleId ?? this.consoleId,
    preferredEmulatorId: preferredEmulatorId.present
        ? preferredEmulatorId.value
        : this.preferredEmulatorId,
    addedAt: addedAt ?? this.addedAt,
    lastPlayedAt: lastPlayedAt.present ? lastPlayedAt.value : this.lastPlayedAt,
    playCount: playCount ?? this.playCount,
    isMissing: isMissing ?? this.isMissing,
    regions: regions.present ? regions.value : this.regions,
  );
  GameRow copyWithCompanion(GamesCompanion data) {
    return GameRow(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      sortTitle: data.sortTitle.present ? data.sortTitle.value : this.sortTitle,
      consoleId: data.consoleId.present ? data.consoleId.value : this.consoleId,
      preferredEmulatorId: data.preferredEmulatorId.present
          ? data.preferredEmulatorId.value
          : this.preferredEmulatorId,
      addedAt: data.addedAt.present ? data.addedAt.value : this.addedAt,
      lastPlayedAt: data.lastPlayedAt.present
          ? data.lastPlayedAt.value
          : this.lastPlayedAt,
      playCount: data.playCount.present ? data.playCount.value : this.playCount,
      isMissing: data.isMissing.present ? data.isMissing.value : this.isMissing,
      regions: data.regions.present ? data.regions.value : this.regions,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GameRow(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('sortTitle: $sortTitle, ')
          ..write('consoleId: $consoleId, ')
          ..write('preferredEmulatorId: $preferredEmulatorId, ')
          ..write('addedAt: $addedAt, ')
          ..write('lastPlayedAt: $lastPlayedAt, ')
          ..write('playCount: $playCount, ')
          ..write('isMissing: $isMissing, ')
          ..write('regions: $regions')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    sortTitle,
    consoleId,
    preferredEmulatorId,
    addedAt,
    lastPlayedAt,
    playCount,
    isMissing,
    regions,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GameRow &&
          other.id == this.id &&
          other.title == this.title &&
          other.sortTitle == this.sortTitle &&
          other.consoleId == this.consoleId &&
          other.preferredEmulatorId == this.preferredEmulatorId &&
          other.addedAt == this.addedAt &&
          other.lastPlayedAt == this.lastPlayedAt &&
          other.playCount == this.playCount &&
          other.isMissing == this.isMissing &&
          other.regions == this.regions);
}

class GamesCompanion extends UpdateCompanion<GameRow> {
  final Value<int> id;
  final Value<String> title;
  final Value<String> sortTitle;
  final Value<String> consoleId;
  final Value<String?> preferredEmulatorId;
  final Value<DateTime> addedAt;
  final Value<DateTime?> lastPlayedAt;
  final Value<int> playCount;
  final Value<bool> isMissing;
  final Value<String?> regions;
  const GamesCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.sortTitle = const Value.absent(),
    this.consoleId = const Value.absent(),
    this.preferredEmulatorId = const Value.absent(),
    this.addedAt = const Value.absent(),
    this.lastPlayedAt = const Value.absent(),
    this.playCount = const Value.absent(),
    this.isMissing = const Value.absent(),
    this.regions = const Value.absent(),
  });
  GamesCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    required String sortTitle,
    required String consoleId,
    this.preferredEmulatorId = const Value.absent(),
    required DateTime addedAt,
    this.lastPlayedAt = const Value.absent(),
    this.playCount = const Value.absent(),
    this.isMissing = const Value.absent(),
    this.regions = const Value.absent(),
  }) : title = Value(title),
       sortTitle = Value(sortTitle),
       consoleId = Value(consoleId),
       addedAt = Value(addedAt);
  static Insertable<GameRow> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<String>? sortTitle,
    Expression<String>? consoleId,
    Expression<String>? preferredEmulatorId,
    Expression<DateTime>? addedAt,
    Expression<DateTime>? lastPlayedAt,
    Expression<int>? playCount,
    Expression<bool>? isMissing,
    Expression<String>? regions,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (sortTitle != null) 'sort_title': sortTitle,
      if (consoleId != null) 'console_id': consoleId,
      if (preferredEmulatorId != null)
        'preferred_emulator_id': preferredEmulatorId,
      if (addedAt != null) 'added_at': addedAt,
      if (lastPlayedAt != null) 'last_played_at': lastPlayedAt,
      if (playCount != null) 'play_count': playCount,
      if (isMissing != null) 'is_missing': isMissing,
      if (regions != null) 'regions': regions,
    });
  }

  GamesCompanion copyWith({
    Value<int>? id,
    Value<String>? title,
    Value<String>? sortTitle,
    Value<String>? consoleId,
    Value<String?>? preferredEmulatorId,
    Value<DateTime>? addedAt,
    Value<DateTime?>? lastPlayedAt,
    Value<int>? playCount,
    Value<bool>? isMissing,
    Value<String?>? regions,
  }) {
    return GamesCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      sortTitle: sortTitle ?? this.sortTitle,
      consoleId: consoleId ?? this.consoleId,
      preferredEmulatorId: preferredEmulatorId ?? this.preferredEmulatorId,
      addedAt: addedAt ?? this.addedAt,
      lastPlayedAt: lastPlayedAt ?? this.lastPlayedAt,
      playCount: playCount ?? this.playCount,
      isMissing: isMissing ?? this.isMissing,
      regions: regions ?? this.regions,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (sortTitle.present) {
      map['sort_title'] = Variable<String>(sortTitle.value);
    }
    if (consoleId.present) {
      map['console_id'] = Variable<String>(consoleId.value);
    }
    if (preferredEmulatorId.present) {
      map['preferred_emulator_id'] = Variable<String>(
        preferredEmulatorId.value,
      );
    }
    if (addedAt.present) {
      map['added_at'] = Variable<DateTime>(addedAt.value);
    }
    if (lastPlayedAt.present) {
      map['last_played_at'] = Variable<DateTime>(lastPlayedAt.value);
    }
    if (playCount.present) {
      map['play_count'] = Variable<int>(playCount.value);
    }
    if (isMissing.present) {
      map['is_missing'] = Variable<bool>(isMissing.value);
    }
    if (regions.present) {
      map['regions'] = Variable<String>(regions.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GamesCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('sortTitle: $sortTitle, ')
          ..write('consoleId: $consoleId, ')
          ..write('preferredEmulatorId: $preferredEmulatorId, ')
          ..write('addedAt: $addedAt, ')
          ..write('lastPlayedAt: $lastPlayedAt, ')
          ..write('playCount: $playCount, ')
          ..write('isMissing: $isMissing, ')
          ..write('regions: $regions')
          ..write(')'))
        .toString();
  }
}

class $CompatibilityTestResultsTable extends CompatibilityTestResults
    with TableInfo<$CompatibilityTestResultsTable, CompatibilityTestResultRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CompatibilityTestResultsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<int> deviceId = GeneratedColumn<int>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES devices (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _emulatorIdMeta = const VerificationMeta(
    'emulatorId',
  );
  @override
  late final GeneratedColumn<String> emulatorId = GeneratedColumn<String>(
    'emulator_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES emulators (id)',
    ),
  );
  static const VerificationMeta _consoleIdMeta = const VerificationMeta(
    'consoleId',
  );
  @override
  late final GeneratedColumn<String> consoleId = GeneratedColumn<String>(
    'console_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES consoles (id)',
    ),
  );
  static const VerificationMeta _gameIdMeta = const VerificationMeta('gameId');
  @override
  late final GeneratedColumn<int> gameId = GeneratedColumn<int>(
    'game_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES games (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _resultMeta = const VerificationMeta('result');
  @override
  late final GeneratedColumn<String> result = GeneratedColumn<String>(
    'result',
    aliasedName,
    false,
    check: () => result.isIn(const [
      'excellent',
      'good',
      'limited',
      'unsupported',
      'notTested',
    ]),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    check: () => source.isIn(const ['local', 'community', 'verified']),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _consentToShareMeta = const VerificationMeta(
    'consentToShare',
  );
  @override
  late final GeneratedColumn<bool> consentToShare = GeneratedColumn<bool>(
    'consent_to_share',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("consent_to_share" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _submittedMeta = const VerificationMeta(
    'submitted',
  );
  @override
  late final GeneratedColumn<bool> submitted = GeneratedColumn<bool>(
    'submitted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("submitted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _testedAtMeta = const VerificationMeta(
    'testedAt',
  );
  @override
  late final GeneratedColumn<DateTime> testedAt = GeneratedColumn<DateTime>(
    'tested_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    deviceId,
    emulatorId,
    consoleId,
    gameId,
    result,
    source,
    notes,
    consentToShare,
    submitted,
    testedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'compatibility_test_results';
  @override
  VerificationContext validateIntegrity(
    Insertable<CompatibilityTestResultRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('emulator_id')) {
      context.handle(
        _emulatorIdMeta,
        emulatorId.isAcceptableOrUnknown(data['emulator_id']!, _emulatorIdMeta),
      );
    }
    if (data.containsKey('console_id')) {
      context.handle(
        _consoleIdMeta,
        consoleId.isAcceptableOrUnknown(data['console_id']!, _consoleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_consoleIdMeta);
    }
    if (data.containsKey('game_id')) {
      context.handle(
        _gameIdMeta,
        gameId.isAcceptableOrUnknown(data['game_id']!, _gameIdMeta),
      );
    }
    if (data.containsKey('result')) {
      context.handle(
        _resultMeta,
        result.isAcceptableOrUnknown(data['result']!, _resultMeta),
      );
    } else if (isInserting) {
      context.missing(_resultMeta);
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('consent_to_share')) {
      context.handle(
        _consentToShareMeta,
        consentToShare.isAcceptableOrUnknown(
          data['consent_to_share']!,
          _consentToShareMeta,
        ),
      );
    }
    if (data.containsKey('submitted')) {
      context.handle(
        _submittedMeta,
        submitted.isAcceptableOrUnknown(data['submitted']!, _submittedMeta),
      );
    }
    if (data.containsKey('tested_at')) {
      context.handle(
        _testedAtMeta,
        testedAt.isAcceptableOrUnknown(data['tested_at']!, _testedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_testedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CompatibilityTestResultRow map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CompatibilityTestResultRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}device_id'],
      )!,
      emulatorId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}emulator_id'],
      ),
      consoleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}console_id'],
      )!,
      gameId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}game_id'],
      ),
      result: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}result'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      consentToShare: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}consent_to_share'],
      )!,
      submitted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}submitted'],
      )!,
      testedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}tested_at'],
      )!,
    );
  }

  @override
  $CompatibilityTestResultsTable createAlias(String alias) {
    return $CompatibilityTestResultsTable(attachedDatabase, alias);
  }
}

class CompatibilityTestResultRow extends DataClass
    implements Insertable<CompatibilityTestResultRow> {
  final int id;
  final int deviceId;
  final String? emulatorId;
  final String consoleId;
  final int? gameId;
  final String result;
  final String source;
  final String? notes;
  final bool consentToShare;
  final bool submitted;
  final DateTime testedAt;
  const CompatibilityTestResultRow({
    required this.id,
    required this.deviceId,
    this.emulatorId,
    required this.consoleId,
    this.gameId,
    required this.result,
    required this.source,
    this.notes,
    required this.consentToShare,
    required this.submitted,
    required this.testedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['device_id'] = Variable<int>(deviceId);
    if (!nullToAbsent || emulatorId != null) {
      map['emulator_id'] = Variable<String>(emulatorId);
    }
    map['console_id'] = Variable<String>(consoleId);
    if (!nullToAbsent || gameId != null) {
      map['game_id'] = Variable<int>(gameId);
    }
    map['result'] = Variable<String>(result);
    map['source'] = Variable<String>(source);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['consent_to_share'] = Variable<bool>(consentToShare);
    map['submitted'] = Variable<bool>(submitted);
    map['tested_at'] = Variable<DateTime>(testedAt);
    return map;
  }

  CompatibilityTestResultsCompanion toCompanion(bool nullToAbsent) {
    return CompatibilityTestResultsCompanion(
      id: Value(id),
      deviceId: Value(deviceId),
      emulatorId: emulatorId == null && nullToAbsent
          ? const Value.absent()
          : Value(emulatorId),
      consoleId: Value(consoleId),
      gameId: gameId == null && nullToAbsent
          ? const Value.absent()
          : Value(gameId),
      result: Value(result),
      source: Value(source),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      consentToShare: Value(consentToShare),
      submitted: Value(submitted),
      testedAt: Value(testedAt),
    );
  }

  factory CompatibilityTestResultRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CompatibilityTestResultRow(
      id: serializer.fromJson<int>(json['id']),
      deviceId: serializer.fromJson<int>(json['deviceId']),
      emulatorId: serializer.fromJson<String?>(json['emulatorId']),
      consoleId: serializer.fromJson<String>(json['consoleId']),
      gameId: serializer.fromJson<int?>(json['gameId']),
      result: serializer.fromJson<String>(json['result']),
      source: serializer.fromJson<String>(json['source']),
      notes: serializer.fromJson<String?>(json['notes']),
      consentToShare: serializer.fromJson<bool>(json['consentToShare']),
      submitted: serializer.fromJson<bool>(json['submitted']),
      testedAt: serializer.fromJson<DateTime>(json['testedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'deviceId': serializer.toJson<int>(deviceId),
      'emulatorId': serializer.toJson<String?>(emulatorId),
      'consoleId': serializer.toJson<String>(consoleId),
      'gameId': serializer.toJson<int?>(gameId),
      'result': serializer.toJson<String>(result),
      'source': serializer.toJson<String>(source),
      'notes': serializer.toJson<String?>(notes),
      'consentToShare': serializer.toJson<bool>(consentToShare),
      'submitted': serializer.toJson<bool>(submitted),
      'testedAt': serializer.toJson<DateTime>(testedAt),
    };
  }

  CompatibilityTestResultRow copyWith({
    int? id,
    int? deviceId,
    Value<String?> emulatorId = const Value.absent(),
    String? consoleId,
    Value<int?> gameId = const Value.absent(),
    String? result,
    String? source,
    Value<String?> notes = const Value.absent(),
    bool? consentToShare,
    bool? submitted,
    DateTime? testedAt,
  }) => CompatibilityTestResultRow(
    id: id ?? this.id,
    deviceId: deviceId ?? this.deviceId,
    emulatorId: emulatorId.present ? emulatorId.value : this.emulatorId,
    consoleId: consoleId ?? this.consoleId,
    gameId: gameId.present ? gameId.value : this.gameId,
    result: result ?? this.result,
    source: source ?? this.source,
    notes: notes.present ? notes.value : this.notes,
    consentToShare: consentToShare ?? this.consentToShare,
    submitted: submitted ?? this.submitted,
    testedAt: testedAt ?? this.testedAt,
  );
  CompatibilityTestResultRow copyWithCompanion(
    CompatibilityTestResultsCompanion data,
  ) {
    return CompatibilityTestResultRow(
      id: data.id.present ? data.id.value : this.id,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      emulatorId: data.emulatorId.present
          ? data.emulatorId.value
          : this.emulatorId,
      consoleId: data.consoleId.present ? data.consoleId.value : this.consoleId,
      gameId: data.gameId.present ? data.gameId.value : this.gameId,
      result: data.result.present ? data.result.value : this.result,
      source: data.source.present ? data.source.value : this.source,
      notes: data.notes.present ? data.notes.value : this.notes,
      consentToShare: data.consentToShare.present
          ? data.consentToShare.value
          : this.consentToShare,
      submitted: data.submitted.present ? data.submitted.value : this.submitted,
      testedAt: data.testedAt.present ? data.testedAt.value : this.testedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CompatibilityTestResultRow(')
          ..write('id: $id, ')
          ..write('deviceId: $deviceId, ')
          ..write('emulatorId: $emulatorId, ')
          ..write('consoleId: $consoleId, ')
          ..write('gameId: $gameId, ')
          ..write('result: $result, ')
          ..write('source: $source, ')
          ..write('notes: $notes, ')
          ..write('consentToShare: $consentToShare, ')
          ..write('submitted: $submitted, ')
          ..write('testedAt: $testedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    deviceId,
    emulatorId,
    consoleId,
    gameId,
    result,
    source,
    notes,
    consentToShare,
    submitted,
    testedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CompatibilityTestResultRow &&
          other.id == this.id &&
          other.deviceId == this.deviceId &&
          other.emulatorId == this.emulatorId &&
          other.consoleId == this.consoleId &&
          other.gameId == this.gameId &&
          other.result == this.result &&
          other.source == this.source &&
          other.notes == this.notes &&
          other.consentToShare == this.consentToShare &&
          other.submitted == this.submitted &&
          other.testedAt == this.testedAt);
}

class CompatibilityTestResultsCompanion
    extends UpdateCompanion<CompatibilityTestResultRow> {
  final Value<int> id;
  final Value<int> deviceId;
  final Value<String?> emulatorId;
  final Value<String> consoleId;
  final Value<int?> gameId;
  final Value<String> result;
  final Value<String> source;
  final Value<String?> notes;
  final Value<bool> consentToShare;
  final Value<bool> submitted;
  final Value<DateTime> testedAt;
  const CompatibilityTestResultsCompanion({
    this.id = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.emulatorId = const Value.absent(),
    this.consoleId = const Value.absent(),
    this.gameId = const Value.absent(),
    this.result = const Value.absent(),
    this.source = const Value.absent(),
    this.notes = const Value.absent(),
    this.consentToShare = const Value.absent(),
    this.submitted = const Value.absent(),
    this.testedAt = const Value.absent(),
  });
  CompatibilityTestResultsCompanion.insert({
    this.id = const Value.absent(),
    required int deviceId,
    this.emulatorId = const Value.absent(),
    required String consoleId,
    this.gameId = const Value.absent(),
    required String result,
    required String source,
    this.notes = const Value.absent(),
    this.consentToShare = const Value.absent(),
    this.submitted = const Value.absent(),
    required DateTime testedAt,
  }) : deviceId = Value(deviceId),
       consoleId = Value(consoleId),
       result = Value(result),
       source = Value(source),
       testedAt = Value(testedAt);
  static Insertable<CompatibilityTestResultRow> custom({
    Expression<int>? id,
    Expression<int>? deviceId,
    Expression<String>? emulatorId,
    Expression<String>? consoleId,
    Expression<int>? gameId,
    Expression<String>? result,
    Expression<String>? source,
    Expression<String>? notes,
    Expression<bool>? consentToShare,
    Expression<bool>? submitted,
    Expression<DateTime>? testedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (deviceId != null) 'device_id': deviceId,
      if (emulatorId != null) 'emulator_id': emulatorId,
      if (consoleId != null) 'console_id': consoleId,
      if (gameId != null) 'game_id': gameId,
      if (result != null) 'result': result,
      if (source != null) 'source': source,
      if (notes != null) 'notes': notes,
      if (consentToShare != null) 'consent_to_share': consentToShare,
      if (submitted != null) 'submitted': submitted,
      if (testedAt != null) 'tested_at': testedAt,
    });
  }

  CompatibilityTestResultsCompanion copyWith({
    Value<int>? id,
    Value<int>? deviceId,
    Value<String?>? emulatorId,
    Value<String>? consoleId,
    Value<int?>? gameId,
    Value<String>? result,
    Value<String>? source,
    Value<String?>? notes,
    Value<bool>? consentToShare,
    Value<bool>? submitted,
    Value<DateTime>? testedAt,
  }) {
    return CompatibilityTestResultsCompanion(
      id: id ?? this.id,
      deviceId: deviceId ?? this.deviceId,
      emulatorId: emulatorId ?? this.emulatorId,
      consoleId: consoleId ?? this.consoleId,
      gameId: gameId ?? this.gameId,
      result: result ?? this.result,
      source: source ?? this.source,
      notes: notes ?? this.notes,
      consentToShare: consentToShare ?? this.consentToShare,
      submitted: submitted ?? this.submitted,
      testedAt: testedAt ?? this.testedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<int>(deviceId.value);
    }
    if (emulatorId.present) {
      map['emulator_id'] = Variable<String>(emulatorId.value);
    }
    if (consoleId.present) {
      map['console_id'] = Variable<String>(consoleId.value);
    }
    if (gameId.present) {
      map['game_id'] = Variable<int>(gameId.value);
    }
    if (result.present) {
      map['result'] = Variable<String>(result.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (consentToShare.present) {
      map['consent_to_share'] = Variable<bool>(consentToShare.value);
    }
    if (submitted.present) {
      map['submitted'] = Variable<bool>(submitted.value);
    }
    if (testedAt.present) {
      map['tested_at'] = Variable<DateTime>(testedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CompatibilityTestResultsCompanion(')
          ..write('id: $id, ')
          ..write('deviceId: $deviceId, ')
          ..write('emulatorId: $emulatorId, ')
          ..write('consoleId: $consoleId, ')
          ..write('gameId: $gameId, ')
          ..write('result: $result, ')
          ..write('source: $source, ')
          ..write('notes: $notes, ')
          ..write('consentToShare: $consentToShare, ')
          ..write('submitted: $submitted, ')
          ..write('testedAt: $testedAt')
          ..write(')'))
        .toString();
  }
}

class $EmulatorProfilesTable extends EmulatorProfiles
    with TableInfo<$EmulatorProfilesTable, EmulatorProfileRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EmulatorProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _emulatorIdMeta = const VerificationMeta(
    'emulatorId',
  );
  @override
  late final GeneratedColumn<String> emulatorId = GeneratedColumn<String>(
    'emulator_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES emulators (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _consoleIdMeta = const VerificationMeta(
    'consoleId',
  );
  @override
  late final GeneratedColumn<String> consoleId = GeneratedColumn<String>(
    'console_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES consoles (id)',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _settingsJsonMeta = const VerificationMeta(
    'settingsJson',
  );
  @override
  late final GeneratedColumn<String> settingsJson = GeneratedColumn<String>(
    'settings_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  static const VerificationMeta _isDefaultMeta = const VerificationMeta(
    'isDefault',
  );
  @override
  late final GeneratedColumn<bool> isDefault = GeneratedColumn<bool>(
    'is_default',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_default" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    emulatorId,
    consoleId,
    name,
    settingsJson,
    isDefault,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'emulator_profiles';
  @override
  VerificationContext validateIntegrity(
    Insertable<EmulatorProfileRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('emulator_id')) {
      context.handle(
        _emulatorIdMeta,
        emulatorId.isAcceptableOrUnknown(data['emulator_id']!, _emulatorIdMeta),
      );
    } else if (isInserting) {
      context.missing(_emulatorIdMeta);
    }
    if (data.containsKey('console_id')) {
      context.handle(
        _consoleIdMeta,
        consoleId.isAcceptableOrUnknown(data['console_id']!, _consoleIdMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('settings_json')) {
      context.handle(
        _settingsJsonMeta,
        settingsJson.isAcceptableOrUnknown(
          data['settings_json']!,
          _settingsJsonMeta,
        ),
      );
    }
    if (data.containsKey('is_default')) {
      context.handle(
        _isDefaultMeta,
        isDefault.isAcceptableOrUnknown(data['is_default']!, _isDefaultMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  EmulatorProfileRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EmulatorProfileRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      emulatorId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}emulator_id'],
      )!,
      consoleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}console_id'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      settingsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}settings_json'],
      )!,
      isDefault: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_default'],
      )!,
    );
  }

  @override
  $EmulatorProfilesTable createAlias(String alias) {
    return $EmulatorProfilesTable(attachedDatabase, alias);
  }
}

class EmulatorProfileRow extends DataClass
    implements Insertable<EmulatorProfileRow> {
  final int id;
  final String emulatorId;
  final String? consoleId;
  final String name;
  final String settingsJson;
  final bool isDefault;
  const EmulatorProfileRow({
    required this.id,
    required this.emulatorId,
    this.consoleId,
    required this.name,
    required this.settingsJson,
    required this.isDefault,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['emulator_id'] = Variable<String>(emulatorId);
    if (!nullToAbsent || consoleId != null) {
      map['console_id'] = Variable<String>(consoleId);
    }
    map['name'] = Variable<String>(name);
    map['settings_json'] = Variable<String>(settingsJson);
    map['is_default'] = Variable<bool>(isDefault);
    return map;
  }

  EmulatorProfilesCompanion toCompanion(bool nullToAbsent) {
    return EmulatorProfilesCompanion(
      id: Value(id),
      emulatorId: Value(emulatorId),
      consoleId: consoleId == null && nullToAbsent
          ? const Value.absent()
          : Value(consoleId),
      name: Value(name),
      settingsJson: Value(settingsJson),
      isDefault: Value(isDefault),
    );
  }

  factory EmulatorProfileRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EmulatorProfileRow(
      id: serializer.fromJson<int>(json['id']),
      emulatorId: serializer.fromJson<String>(json['emulatorId']),
      consoleId: serializer.fromJson<String?>(json['consoleId']),
      name: serializer.fromJson<String>(json['name']),
      settingsJson: serializer.fromJson<String>(json['settingsJson']),
      isDefault: serializer.fromJson<bool>(json['isDefault']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'emulatorId': serializer.toJson<String>(emulatorId),
      'consoleId': serializer.toJson<String?>(consoleId),
      'name': serializer.toJson<String>(name),
      'settingsJson': serializer.toJson<String>(settingsJson),
      'isDefault': serializer.toJson<bool>(isDefault),
    };
  }

  EmulatorProfileRow copyWith({
    int? id,
    String? emulatorId,
    Value<String?> consoleId = const Value.absent(),
    String? name,
    String? settingsJson,
    bool? isDefault,
  }) => EmulatorProfileRow(
    id: id ?? this.id,
    emulatorId: emulatorId ?? this.emulatorId,
    consoleId: consoleId.present ? consoleId.value : this.consoleId,
    name: name ?? this.name,
    settingsJson: settingsJson ?? this.settingsJson,
    isDefault: isDefault ?? this.isDefault,
  );
  EmulatorProfileRow copyWithCompanion(EmulatorProfilesCompanion data) {
    return EmulatorProfileRow(
      id: data.id.present ? data.id.value : this.id,
      emulatorId: data.emulatorId.present
          ? data.emulatorId.value
          : this.emulatorId,
      consoleId: data.consoleId.present ? data.consoleId.value : this.consoleId,
      name: data.name.present ? data.name.value : this.name,
      settingsJson: data.settingsJson.present
          ? data.settingsJson.value
          : this.settingsJson,
      isDefault: data.isDefault.present ? data.isDefault.value : this.isDefault,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EmulatorProfileRow(')
          ..write('id: $id, ')
          ..write('emulatorId: $emulatorId, ')
          ..write('consoleId: $consoleId, ')
          ..write('name: $name, ')
          ..write('settingsJson: $settingsJson, ')
          ..write('isDefault: $isDefault')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, emulatorId, consoleId, name, settingsJson, isDefault);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EmulatorProfileRow &&
          other.id == this.id &&
          other.emulatorId == this.emulatorId &&
          other.consoleId == this.consoleId &&
          other.name == this.name &&
          other.settingsJson == this.settingsJson &&
          other.isDefault == this.isDefault);
}

class EmulatorProfilesCompanion extends UpdateCompanion<EmulatorProfileRow> {
  final Value<int> id;
  final Value<String> emulatorId;
  final Value<String?> consoleId;
  final Value<String> name;
  final Value<String> settingsJson;
  final Value<bool> isDefault;
  const EmulatorProfilesCompanion({
    this.id = const Value.absent(),
    this.emulatorId = const Value.absent(),
    this.consoleId = const Value.absent(),
    this.name = const Value.absent(),
    this.settingsJson = const Value.absent(),
    this.isDefault = const Value.absent(),
  });
  EmulatorProfilesCompanion.insert({
    this.id = const Value.absent(),
    required String emulatorId,
    this.consoleId = const Value.absent(),
    required String name,
    this.settingsJson = const Value.absent(),
    this.isDefault = const Value.absent(),
  }) : emulatorId = Value(emulatorId),
       name = Value(name);
  static Insertable<EmulatorProfileRow> custom({
    Expression<int>? id,
    Expression<String>? emulatorId,
    Expression<String>? consoleId,
    Expression<String>? name,
    Expression<String>? settingsJson,
    Expression<bool>? isDefault,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (emulatorId != null) 'emulator_id': emulatorId,
      if (consoleId != null) 'console_id': consoleId,
      if (name != null) 'name': name,
      if (settingsJson != null) 'settings_json': settingsJson,
      if (isDefault != null) 'is_default': isDefault,
    });
  }

  EmulatorProfilesCompanion copyWith({
    Value<int>? id,
    Value<String>? emulatorId,
    Value<String?>? consoleId,
    Value<String>? name,
    Value<String>? settingsJson,
    Value<bool>? isDefault,
  }) {
    return EmulatorProfilesCompanion(
      id: id ?? this.id,
      emulatorId: emulatorId ?? this.emulatorId,
      consoleId: consoleId ?? this.consoleId,
      name: name ?? this.name,
      settingsJson: settingsJson ?? this.settingsJson,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (emulatorId.present) {
      map['emulator_id'] = Variable<String>(emulatorId.value);
    }
    if (consoleId.present) {
      map['console_id'] = Variable<String>(consoleId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (settingsJson.present) {
      map['settings_json'] = Variable<String>(settingsJson.value);
    }
    if (isDefault.present) {
      map['is_default'] = Variable<bool>(isDefault.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EmulatorProfilesCompanion(')
          ..write('id: $id, ')
          ..write('emulatorId: $emulatorId, ')
          ..write('consoleId: $consoleId, ')
          ..write('name: $name, ')
          ..write('settingsJson: $settingsJson, ')
          ..write('isDefault: $isDefault')
          ..write(')'))
        .toString();
  }
}

class $EmulatorAdaptersTable extends EmulatorAdapters
    with TableInfo<$EmulatorAdaptersTable, EmulatorAdapterRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EmulatorAdaptersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _emulatorIdMeta = const VerificationMeta(
    'emulatorId',
  );
  @override
  late final GeneratedColumn<String> emulatorId = GeneratedColumn<String>(
    'emulator_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES emulators (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _packageNameMeta = const VerificationMeta(
    'packageName',
  );
  @override
  late final GeneratedColumn<String> packageName = GeneratedColumn<String>(
    'package_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _strategyMeta = const VerificationMeta(
    'strategy',
  );
  @override
  late final GeneratedColumn<String> strategy = GeneratedColumn<String>(
    'strategy',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _launchMechanismMeta = const VerificationMeta(
    'launchMechanism',
  );
  @override
  late final GeneratedColumn<String> launchMechanism = GeneratedColumn<String>(
    'launch_mechanism',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _installedVersionMeta = const VerificationMeta(
    'installedVersion',
  );
  @override
  late final GeneratedColumn<String> installedVersion = GeneratedColumn<String>(
    'installed_version',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _installedMeta = const VerificationMeta(
    'installed',
  );
  @override
  late final GeneratedColumn<bool> installed = GeneratedColumn<bool>(
    'installed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("installed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _lastDetectedAtMeta = const VerificationMeta(
    'lastDetectedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastDetectedAt =
      GeneratedColumn<DateTime>(
        'last_detected_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    emulatorId,
    packageName,
    strategy,
    launchMechanism,
    installedVersion,
    installed,
    lastDetectedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'emulator_adapters';
  @override
  VerificationContext validateIntegrity(
    Insertable<EmulatorAdapterRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('emulator_id')) {
      context.handle(
        _emulatorIdMeta,
        emulatorId.isAcceptableOrUnknown(data['emulator_id']!, _emulatorIdMeta),
      );
    } else if (isInserting) {
      context.missing(_emulatorIdMeta);
    }
    if (data.containsKey('package_name')) {
      context.handle(
        _packageNameMeta,
        packageName.isAcceptableOrUnknown(
          data['package_name']!,
          _packageNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_packageNameMeta);
    }
    if (data.containsKey('strategy')) {
      context.handle(
        _strategyMeta,
        strategy.isAcceptableOrUnknown(data['strategy']!, _strategyMeta),
      );
    } else if (isInserting) {
      context.missing(_strategyMeta);
    }
    if (data.containsKey('launch_mechanism')) {
      context.handle(
        _launchMechanismMeta,
        launchMechanism.isAcceptableOrUnknown(
          data['launch_mechanism']!,
          _launchMechanismMeta,
        ),
      );
    }
    if (data.containsKey('installed_version')) {
      context.handle(
        _installedVersionMeta,
        installedVersion.isAcceptableOrUnknown(
          data['installed_version']!,
          _installedVersionMeta,
        ),
      );
    }
    if (data.containsKey('installed')) {
      context.handle(
        _installedMeta,
        installed.isAcceptableOrUnknown(data['installed']!, _installedMeta),
      );
    }
    if (data.containsKey('last_detected_at')) {
      context.handle(
        _lastDetectedAtMeta,
        lastDetectedAt.isAcceptableOrUnknown(
          data['last_detected_at']!,
          _lastDetectedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {emulatorId, packageName},
  ];
  @override
  EmulatorAdapterRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EmulatorAdapterRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      emulatorId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}emulator_id'],
      )!,
      packageName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}package_name'],
      )!,
      strategy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}strategy'],
      )!,
      launchMechanism: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}launch_mechanism'],
      ),
      installedVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}installed_version'],
      ),
      installed: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}installed'],
      )!,
      lastDetectedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_detected_at'],
      ),
    );
  }

  @override
  $EmulatorAdaptersTable createAlias(String alias) {
    return $EmulatorAdaptersTable(attachedDatabase, alias);
  }
}

class EmulatorAdapterRow extends DataClass
    implements Insertable<EmulatorAdapterRow> {
  final int id;
  final String emulatorId;
  final String packageName;
  final String strategy;
  final String? launchMechanism;
  final String? installedVersion;
  final bool installed;
  final DateTime? lastDetectedAt;
  const EmulatorAdapterRow({
    required this.id,
    required this.emulatorId,
    required this.packageName,
    required this.strategy,
    this.launchMechanism,
    this.installedVersion,
    required this.installed,
    this.lastDetectedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['emulator_id'] = Variable<String>(emulatorId);
    map['package_name'] = Variable<String>(packageName);
    map['strategy'] = Variable<String>(strategy);
    if (!nullToAbsent || launchMechanism != null) {
      map['launch_mechanism'] = Variable<String>(launchMechanism);
    }
    if (!nullToAbsent || installedVersion != null) {
      map['installed_version'] = Variable<String>(installedVersion);
    }
    map['installed'] = Variable<bool>(installed);
    if (!nullToAbsent || lastDetectedAt != null) {
      map['last_detected_at'] = Variable<DateTime>(lastDetectedAt);
    }
    return map;
  }

  EmulatorAdaptersCompanion toCompanion(bool nullToAbsent) {
    return EmulatorAdaptersCompanion(
      id: Value(id),
      emulatorId: Value(emulatorId),
      packageName: Value(packageName),
      strategy: Value(strategy),
      launchMechanism: launchMechanism == null && nullToAbsent
          ? const Value.absent()
          : Value(launchMechanism),
      installedVersion: installedVersion == null && nullToAbsent
          ? const Value.absent()
          : Value(installedVersion),
      installed: Value(installed),
      lastDetectedAt: lastDetectedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastDetectedAt),
    );
  }

  factory EmulatorAdapterRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EmulatorAdapterRow(
      id: serializer.fromJson<int>(json['id']),
      emulatorId: serializer.fromJson<String>(json['emulatorId']),
      packageName: serializer.fromJson<String>(json['packageName']),
      strategy: serializer.fromJson<String>(json['strategy']),
      launchMechanism: serializer.fromJson<String?>(json['launchMechanism']),
      installedVersion: serializer.fromJson<String?>(json['installedVersion']),
      installed: serializer.fromJson<bool>(json['installed']),
      lastDetectedAt: serializer.fromJson<DateTime?>(json['lastDetectedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'emulatorId': serializer.toJson<String>(emulatorId),
      'packageName': serializer.toJson<String>(packageName),
      'strategy': serializer.toJson<String>(strategy),
      'launchMechanism': serializer.toJson<String?>(launchMechanism),
      'installedVersion': serializer.toJson<String?>(installedVersion),
      'installed': serializer.toJson<bool>(installed),
      'lastDetectedAt': serializer.toJson<DateTime?>(lastDetectedAt),
    };
  }

  EmulatorAdapterRow copyWith({
    int? id,
    String? emulatorId,
    String? packageName,
    String? strategy,
    Value<String?> launchMechanism = const Value.absent(),
    Value<String?> installedVersion = const Value.absent(),
    bool? installed,
    Value<DateTime?> lastDetectedAt = const Value.absent(),
  }) => EmulatorAdapterRow(
    id: id ?? this.id,
    emulatorId: emulatorId ?? this.emulatorId,
    packageName: packageName ?? this.packageName,
    strategy: strategy ?? this.strategy,
    launchMechanism: launchMechanism.present
        ? launchMechanism.value
        : this.launchMechanism,
    installedVersion: installedVersion.present
        ? installedVersion.value
        : this.installedVersion,
    installed: installed ?? this.installed,
    lastDetectedAt: lastDetectedAt.present
        ? lastDetectedAt.value
        : this.lastDetectedAt,
  );
  EmulatorAdapterRow copyWithCompanion(EmulatorAdaptersCompanion data) {
    return EmulatorAdapterRow(
      id: data.id.present ? data.id.value : this.id,
      emulatorId: data.emulatorId.present
          ? data.emulatorId.value
          : this.emulatorId,
      packageName: data.packageName.present
          ? data.packageName.value
          : this.packageName,
      strategy: data.strategy.present ? data.strategy.value : this.strategy,
      launchMechanism: data.launchMechanism.present
          ? data.launchMechanism.value
          : this.launchMechanism,
      installedVersion: data.installedVersion.present
          ? data.installedVersion.value
          : this.installedVersion,
      installed: data.installed.present ? data.installed.value : this.installed,
      lastDetectedAt: data.lastDetectedAt.present
          ? data.lastDetectedAt.value
          : this.lastDetectedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EmulatorAdapterRow(')
          ..write('id: $id, ')
          ..write('emulatorId: $emulatorId, ')
          ..write('packageName: $packageName, ')
          ..write('strategy: $strategy, ')
          ..write('launchMechanism: $launchMechanism, ')
          ..write('installedVersion: $installedVersion, ')
          ..write('installed: $installed, ')
          ..write('lastDetectedAt: $lastDetectedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    emulatorId,
    packageName,
    strategy,
    launchMechanism,
    installedVersion,
    installed,
    lastDetectedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EmulatorAdapterRow &&
          other.id == this.id &&
          other.emulatorId == this.emulatorId &&
          other.packageName == this.packageName &&
          other.strategy == this.strategy &&
          other.launchMechanism == this.launchMechanism &&
          other.installedVersion == this.installedVersion &&
          other.installed == this.installed &&
          other.lastDetectedAt == this.lastDetectedAt);
}

class EmulatorAdaptersCompanion extends UpdateCompanion<EmulatorAdapterRow> {
  final Value<int> id;
  final Value<String> emulatorId;
  final Value<String> packageName;
  final Value<String> strategy;
  final Value<String?> launchMechanism;
  final Value<String?> installedVersion;
  final Value<bool> installed;
  final Value<DateTime?> lastDetectedAt;
  const EmulatorAdaptersCompanion({
    this.id = const Value.absent(),
    this.emulatorId = const Value.absent(),
    this.packageName = const Value.absent(),
    this.strategy = const Value.absent(),
    this.launchMechanism = const Value.absent(),
    this.installedVersion = const Value.absent(),
    this.installed = const Value.absent(),
    this.lastDetectedAt = const Value.absent(),
  });
  EmulatorAdaptersCompanion.insert({
    this.id = const Value.absent(),
    required String emulatorId,
    required String packageName,
    required String strategy,
    this.launchMechanism = const Value.absent(),
    this.installedVersion = const Value.absent(),
    this.installed = const Value.absent(),
    this.lastDetectedAt = const Value.absent(),
  }) : emulatorId = Value(emulatorId),
       packageName = Value(packageName),
       strategy = Value(strategy);
  static Insertable<EmulatorAdapterRow> custom({
    Expression<int>? id,
    Expression<String>? emulatorId,
    Expression<String>? packageName,
    Expression<String>? strategy,
    Expression<String>? launchMechanism,
    Expression<String>? installedVersion,
    Expression<bool>? installed,
    Expression<DateTime>? lastDetectedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (emulatorId != null) 'emulator_id': emulatorId,
      if (packageName != null) 'package_name': packageName,
      if (strategy != null) 'strategy': strategy,
      if (launchMechanism != null) 'launch_mechanism': launchMechanism,
      if (installedVersion != null) 'installed_version': installedVersion,
      if (installed != null) 'installed': installed,
      if (lastDetectedAt != null) 'last_detected_at': lastDetectedAt,
    });
  }

  EmulatorAdaptersCompanion copyWith({
    Value<int>? id,
    Value<String>? emulatorId,
    Value<String>? packageName,
    Value<String>? strategy,
    Value<String?>? launchMechanism,
    Value<String?>? installedVersion,
    Value<bool>? installed,
    Value<DateTime?>? lastDetectedAt,
  }) {
    return EmulatorAdaptersCompanion(
      id: id ?? this.id,
      emulatorId: emulatorId ?? this.emulatorId,
      packageName: packageName ?? this.packageName,
      strategy: strategy ?? this.strategy,
      launchMechanism: launchMechanism ?? this.launchMechanism,
      installedVersion: installedVersion ?? this.installedVersion,
      installed: installed ?? this.installed,
      lastDetectedAt: lastDetectedAt ?? this.lastDetectedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (emulatorId.present) {
      map['emulator_id'] = Variable<String>(emulatorId.value);
    }
    if (packageName.present) {
      map['package_name'] = Variable<String>(packageName.value);
    }
    if (strategy.present) {
      map['strategy'] = Variable<String>(strategy.value);
    }
    if (launchMechanism.present) {
      map['launch_mechanism'] = Variable<String>(launchMechanism.value);
    }
    if (installedVersion.present) {
      map['installed_version'] = Variable<String>(installedVersion.value);
    }
    if (installed.present) {
      map['installed'] = Variable<bool>(installed.value);
    }
    if (lastDetectedAt.present) {
      map['last_detected_at'] = Variable<DateTime>(lastDetectedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EmulatorAdaptersCompanion(')
          ..write('id: $id, ')
          ..write('emulatorId: $emulatorId, ')
          ..write('packageName: $packageName, ')
          ..write('strategy: $strategy, ')
          ..write('launchMechanism: $launchMechanism, ')
          ..write('installedVersion: $installedVersion, ')
          ..write('installed: $installed, ')
          ..write('lastDetectedAt: $lastDetectedAt')
          ..write(')'))
        .toString();
  }
}

class $StorageDevicesTable extends StorageDevices
    with TableInfo<$StorageDevicesTable, StorageDeviceRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StorageDevicesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _volumeIdMeta = const VerificationMeta(
    'volumeId',
  );
  @override
  late final GeneratedColumn<String> volumeId = GeneratedColumn<String>(
    'volume_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _treeUriMeta = const VerificationMeta(
    'treeUri',
  );
  @override
  late final GeneratedColumn<String> treeUri = GeneratedColumn<String>(
    'tree_uri',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isRemovableMeta = const VerificationMeta(
    'isRemovable',
  );
  @override
  late final GeneratedColumn<bool> isRemovable = GeneratedColumn<bool>(
    'is_removable',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_removable" IN (0, 1))',
    ),
  );
  static const VerificationMeta _totalBytesMeta = const VerificationMeta(
    'totalBytes',
  );
  @override
  late final GeneratedColumn<int> totalBytes = GeneratedColumn<int>(
    'total_bytes',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _availableBytesMeta = const VerificationMeta(
    'availableBytes',
  );
  @override
  late final GeneratedColumn<int> availableBytes = GeneratedColumn<int>(
    'available_bytes',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isConnectedMeta = const VerificationMeta(
    'isConnected',
  );
  @override
  late final GeneratedColumn<bool> isConnected = GeneratedColumn<bool>(
    'is_connected',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_connected" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _isDefaultMeta = const VerificationMeta(
    'isDefault',
  );
  @override
  late final GeneratedColumn<bool> isDefault = GeneratedColumn<bool>(
    'is_default',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_default" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _lastSeenAtMeta = const VerificationMeta(
    'lastSeenAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastSeenAt = GeneratedColumn<DateTime>(
    'last_seen_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    volumeId,
    description,
    kind,
    treeUri,
    isRemovable,
    totalBytes,
    availableBytes,
    isConnected,
    isDefault,
    lastSeenAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'storage_devices';
  @override
  VerificationContext validateIntegrity(
    Insertable<StorageDeviceRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('volume_id')) {
      context.handle(
        _volumeIdMeta,
        volumeId.isAcceptableOrUnknown(data['volume_id']!, _volumeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_volumeIdMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('tree_uri')) {
      context.handle(
        _treeUriMeta,
        treeUri.isAcceptableOrUnknown(data['tree_uri']!, _treeUriMeta),
      );
    }
    if (data.containsKey('is_removable')) {
      context.handle(
        _isRemovableMeta,
        isRemovable.isAcceptableOrUnknown(
          data['is_removable']!,
          _isRemovableMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_isRemovableMeta);
    }
    if (data.containsKey('total_bytes')) {
      context.handle(
        _totalBytesMeta,
        totalBytes.isAcceptableOrUnknown(data['total_bytes']!, _totalBytesMeta),
      );
    }
    if (data.containsKey('available_bytes')) {
      context.handle(
        _availableBytesMeta,
        availableBytes.isAcceptableOrUnknown(
          data['available_bytes']!,
          _availableBytesMeta,
        ),
      );
    }
    if (data.containsKey('is_connected')) {
      context.handle(
        _isConnectedMeta,
        isConnected.isAcceptableOrUnknown(
          data['is_connected']!,
          _isConnectedMeta,
        ),
      );
    }
    if (data.containsKey('is_default')) {
      context.handle(
        _isDefaultMeta,
        isDefault.isAcceptableOrUnknown(data['is_default']!, _isDefaultMeta),
      );
    }
    if (data.containsKey('last_seen_at')) {
      context.handle(
        _lastSeenAtMeta,
        lastSeenAt.isAcceptableOrUnknown(
          data['last_seen_at']!,
          _lastSeenAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastSeenAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StorageDeviceRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StorageDeviceRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      volumeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}volume_id'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      treeUri: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tree_uri'],
      ),
      isRemovable: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_removable'],
      )!,
      totalBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_bytes'],
      ),
      availableBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}available_bytes'],
      ),
      isConnected: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_connected'],
      )!,
      isDefault: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_default'],
      )!,
      lastSeenAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_seen_at'],
      )!,
    );
  }

  @override
  $StorageDevicesTable createAlias(String alias) {
    return $StorageDevicesTable(attachedDatabase, alias);
  }
}

class StorageDeviceRow extends DataClass
    implements Insertable<StorageDeviceRow> {
  final int id;
  final String volumeId;
  final String description;
  final String kind;

  /// Persisted SAF tree URI granted by the user, if any.
  final String? treeUri;
  final bool isRemovable;
  final int? totalBytes;
  final int? availableBytes;
  final bool isConnected;
  final bool isDefault;
  final DateTime lastSeenAt;
  const StorageDeviceRow({
    required this.id,
    required this.volumeId,
    required this.description,
    required this.kind,
    this.treeUri,
    required this.isRemovable,
    this.totalBytes,
    this.availableBytes,
    required this.isConnected,
    required this.isDefault,
    required this.lastSeenAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['volume_id'] = Variable<String>(volumeId);
    map['description'] = Variable<String>(description);
    map['kind'] = Variable<String>(kind);
    if (!nullToAbsent || treeUri != null) {
      map['tree_uri'] = Variable<String>(treeUri);
    }
    map['is_removable'] = Variable<bool>(isRemovable);
    if (!nullToAbsent || totalBytes != null) {
      map['total_bytes'] = Variable<int>(totalBytes);
    }
    if (!nullToAbsent || availableBytes != null) {
      map['available_bytes'] = Variable<int>(availableBytes);
    }
    map['is_connected'] = Variable<bool>(isConnected);
    map['is_default'] = Variable<bool>(isDefault);
    map['last_seen_at'] = Variable<DateTime>(lastSeenAt);
    return map;
  }

  StorageDevicesCompanion toCompanion(bool nullToAbsent) {
    return StorageDevicesCompanion(
      id: Value(id),
      volumeId: Value(volumeId),
      description: Value(description),
      kind: Value(kind),
      treeUri: treeUri == null && nullToAbsent
          ? const Value.absent()
          : Value(treeUri),
      isRemovable: Value(isRemovable),
      totalBytes: totalBytes == null && nullToAbsent
          ? const Value.absent()
          : Value(totalBytes),
      availableBytes: availableBytes == null && nullToAbsent
          ? const Value.absent()
          : Value(availableBytes),
      isConnected: Value(isConnected),
      isDefault: Value(isDefault),
      lastSeenAt: Value(lastSeenAt),
    );
  }

  factory StorageDeviceRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StorageDeviceRow(
      id: serializer.fromJson<int>(json['id']),
      volumeId: serializer.fromJson<String>(json['volumeId']),
      description: serializer.fromJson<String>(json['description']),
      kind: serializer.fromJson<String>(json['kind']),
      treeUri: serializer.fromJson<String?>(json['treeUri']),
      isRemovable: serializer.fromJson<bool>(json['isRemovable']),
      totalBytes: serializer.fromJson<int?>(json['totalBytes']),
      availableBytes: serializer.fromJson<int?>(json['availableBytes']),
      isConnected: serializer.fromJson<bool>(json['isConnected']),
      isDefault: serializer.fromJson<bool>(json['isDefault']),
      lastSeenAt: serializer.fromJson<DateTime>(json['lastSeenAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'volumeId': serializer.toJson<String>(volumeId),
      'description': serializer.toJson<String>(description),
      'kind': serializer.toJson<String>(kind),
      'treeUri': serializer.toJson<String?>(treeUri),
      'isRemovable': serializer.toJson<bool>(isRemovable),
      'totalBytes': serializer.toJson<int?>(totalBytes),
      'availableBytes': serializer.toJson<int?>(availableBytes),
      'isConnected': serializer.toJson<bool>(isConnected),
      'isDefault': serializer.toJson<bool>(isDefault),
      'lastSeenAt': serializer.toJson<DateTime>(lastSeenAt),
    };
  }

  StorageDeviceRow copyWith({
    int? id,
    String? volumeId,
    String? description,
    String? kind,
    Value<String?> treeUri = const Value.absent(),
    bool? isRemovable,
    Value<int?> totalBytes = const Value.absent(),
    Value<int?> availableBytes = const Value.absent(),
    bool? isConnected,
    bool? isDefault,
    DateTime? lastSeenAt,
  }) => StorageDeviceRow(
    id: id ?? this.id,
    volumeId: volumeId ?? this.volumeId,
    description: description ?? this.description,
    kind: kind ?? this.kind,
    treeUri: treeUri.present ? treeUri.value : this.treeUri,
    isRemovable: isRemovable ?? this.isRemovable,
    totalBytes: totalBytes.present ? totalBytes.value : this.totalBytes,
    availableBytes: availableBytes.present
        ? availableBytes.value
        : this.availableBytes,
    isConnected: isConnected ?? this.isConnected,
    isDefault: isDefault ?? this.isDefault,
    lastSeenAt: lastSeenAt ?? this.lastSeenAt,
  );
  StorageDeviceRow copyWithCompanion(StorageDevicesCompanion data) {
    return StorageDeviceRow(
      id: data.id.present ? data.id.value : this.id,
      volumeId: data.volumeId.present ? data.volumeId.value : this.volumeId,
      description: data.description.present
          ? data.description.value
          : this.description,
      kind: data.kind.present ? data.kind.value : this.kind,
      treeUri: data.treeUri.present ? data.treeUri.value : this.treeUri,
      isRemovable: data.isRemovable.present
          ? data.isRemovable.value
          : this.isRemovable,
      totalBytes: data.totalBytes.present
          ? data.totalBytes.value
          : this.totalBytes,
      availableBytes: data.availableBytes.present
          ? data.availableBytes.value
          : this.availableBytes,
      isConnected: data.isConnected.present
          ? data.isConnected.value
          : this.isConnected,
      isDefault: data.isDefault.present ? data.isDefault.value : this.isDefault,
      lastSeenAt: data.lastSeenAt.present
          ? data.lastSeenAt.value
          : this.lastSeenAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StorageDeviceRow(')
          ..write('id: $id, ')
          ..write('volumeId: $volumeId, ')
          ..write('description: $description, ')
          ..write('kind: $kind, ')
          ..write('treeUri: $treeUri, ')
          ..write('isRemovable: $isRemovable, ')
          ..write('totalBytes: $totalBytes, ')
          ..write('availableBytes: $availableBytes, ')
          ..write('isConnected: $isConnected, ')
          ..write('isDefault: $isDefault, ')
          ..write('lastSeenAt: $lastSeenAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    volumeId,
    description,
    kind,
    treeUri,
    isRemovable,
    totalBytes,
    availableBytes,
    isConnected,
    isDefault,
    lastSeenAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StorageDeviceRow &&
          other.id == this.id &&
          other.volumeId == this.volumeId &&
          other.description == this.description &&
          other.kind == this.kind &&
          other.treeUri == this.treeUri &&
          other.isRemovable == this.isRemovable &&
          other.totalBytes == this.totalBytes &&
          other.availableBytes == this.availableBytes &&
          other.isConnected == this.isConnected &&
          other.isDefault == this.isDefault &&
          other.lastSeenAt == this.lastSeenAt);
}

class StorageDevicesCompanion extends UpdateCompanion<StorageDeviceRow> {
  final Value<int> id;
  final Value<String> volumeId;
  final Value<String> description;
  final Value<String> kind;
  final Value<String?> treeUri;
  final Value<bool> isRemovable;
  final Value<int?> totalBytes;
  final Value<int?> availableBytes;
  final Value<bool> isConnected;
  final Value<bool> isDefault;
  final Value<DateTime> lastSeenAt;
  const StorageDevicesCompanion({
    this.id = const Value.absent(),
    this.volumeId = const Value.absent(),
    this.description = const Value.absent(),
    this.kind = const Value.absent(),
    this.treeUri = const Value.absent(),
    this.isRemovable = const Value.absent(),
    this.totalBytes = const Value.absent(),
    this.availableBytes = const Value.absent(),
    this.isConnected = const Value.absent(),
    this.isDefault = const Value.absent(),
    this.lastSeenAt = const Value.absent(),
  });
  StorageDevicesCompanion.insert({
    this.id = const Value.absent(),
    required String volumeId,
    required String description,
    required String kind,
    this.treeUri = const Value.absent(),
    required bool isRemovable,
    this.totalBytes = const Value.absent(),
    this.availableBytes = const Value.absent(),
    this.isConnected = const Value.absent(),
    this.isDefault = const Value.absent(),
    required DateTime lastSeenAt,
  }) : volumeId = Value(volumeId),
       description = Value(description),
       kind = Value(kind),
       isRemovable = Value(isRemovable),
       lastSeenAt = Value(lastSeenAt);
  static Insertable<StorageDeviceRow> custom({
    Expression<int>? id,
    Expression<String>? volumeId,
    Expression<String>? description,
    Expression<String>? kind,
    Expression<String>? treeUri,
    Expression<bool>? isRemovable,
    Expression<int>? totalBytes,
    Expression<int>? availableBytes,
    Expression<bool>? isConnected,
    Expression<bool>? isDefault,
    Expression<DateTime>? lastSeenAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (volumeId != null) 'volume_id': volumeId,
      if (description != null) 'description': description,
      if (kind != null) 'kind': kind,
      if (treeUri != null) 'tree_uri': treeUri,
      if (isRemovable != null) 'is_removable': isRemovable,
      if (totalBytes != null) 'total_bytes': totalBytes,
      if (availableBytes != null) 'available_bytes': availableBytes,
      if (isConnected != null) 'is_connected': isConnected,
      if (isDefault != null) 'is_default': isDefault,
      if (lastSeenAt != null) 'last_seen_at': lastSeenAt,
    });
  }

  StorageDevicesCompanion copyWith({
    Value<int>? id,
    Value<String>? volumeId,
    Value<String>? description,
    Value<String>? kind,
    Value<String?>? treeUri,
    Value<bool>? isRemovable,
    Value<int?>? totalBytes,
    Value<int?>? availableBytes,
    Value<bool>? isConnected,
    Value<bool>? isDefault,
    Value<DateTime>? lastSeenAt,
  }) {
    return StorageDevicesCompanion(
      id: id ?? this.id,
      volumeId: volumeId ?? this.volumeId,
      description: description ?? this.description,
      kind: kind ?? this.kind,
      treeUri: treeUri ?? this.treeUri,
      isRemovable: isRemovable ?? this.isRemovable,
      totalBytes: totalBytes ?? this.totalBytes,
      availableBytes: availableBytes ?? this.availableBytes,
      isConnected: isConnected ?? this.isConnected,
      isDefault: isDefault ?? this.isDefault,
      lastSeenAt: lastSeenAt ?? this.lastSeenAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (volumeId.present) {
      map['volume_id'] = Variable<String>(volumeId.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (treeUri.present) {
      map['tree_uri'] = Variable<String>(treeUri.value);
    }
    if (isRemovable.present) {
      map['is_removable'] = Variable<bool>(isRemovable.value);
    }
    if (totalBytes.present) {
      map['total_bytes'] = Variable<int>(totalBytes.value);
    }
    if (availableBytes.present) {
      map['available_bytes'] = Variable<int>(availableBytes.value);
    }
    if (isConnected.present) {
      map['is_connected'] = Variable<bool>(isConnected.value);
    }
    if (isDefault.present) {
      map['is_default'] = Variable<bool>(isDefault.value);
    }
    if (lastSeenAt.present) {
      map['last_seen_at'] = Variable<DateTime>(lastSeenAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StorageDevicesCompanion(')
          ..write('id: $id, ')
          ..write('volumeId: $volumeId, ')
          ..write('description: $description, ')
          ..write('kind: $kind, ')
          ..write('treeUri: $treeUri, ')
          ..write('isRemovable: $isRemovable, ')
          ..write('totalBytes: $totalBytes, ')
          ..write('availableBytes: $availableBytes, ')
          ..write('isConnected: $isConnected, ')
          ..write('isDefault: $isDefault, ')
          ..write('lastSeenAt: $lastSeenAt')
          ..write(')'))
        .toString();
  }
}

class $GameFilesTable extends GameFiles
    with TableInfo<$GameFilesTable, GameFileRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GameFilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _gameIdMeta = const VerificationMeta('gameId');
  @override
  late final GeneratedColumn<int> gameId = GeneratedColumn<int>(
    'game_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES games (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _uriMeta = const VerificationMeta('uri');
  @override
  late final GeneratedColumn<String> uri = GeneratedColumn<String>(
    'uri',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _displayPathMeta = const VerificationMeta(
    'displayPath',
  );
  @override
  late final GeneratedColumn<String> displayPath = GeneratedColumn<String>(
    'display_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _extensionMeta = const VerificationMeta(
    'extension',
  );
  @override
  late final GeneratedColumn<String> extension = GeneratedColumn<String>(
    'extension',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sizeBytesMeta = const VerificationMeta(
    'sizeBytes',
  );
  @override
  late final GeneratedColumn<int> sizeBytes = GeneratedColumn<int>(
    'size_bytes',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sha1Meta = const VerificationMeta('sha1');
  @override
  late final GeneratedColumn<String> sha1 = GeneratedColumn<String>(
    'sha1',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _crc32Meta = const VerificationMeta('crc32');
  @override
  late final GeneratedColumn<String> crc32 = GeneratedColumn<String>(
    'crc32',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _storageDeviceIdMeta = const VerificationMeta(
    'storageDeviceId',
  );
  @override
  late final GeneratedColumn<int> storageDeviceId = GeneratedColumn<int>(
    'storage_device_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES storage_devices (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _fileExistsMeta = const VerificationMeta(
    'fileExists',
  );
  @override
  late final GeneratedColumn<bool> fileExists = GeneratedColumn<bool>(
    'file_exists',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("file_exists" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _lastVerifiedAtMeta = const VerificationMeta(
    'lastVerifiedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastVerifiedAt =
      GeneratedColumn<DateTime>(
        'last_verified_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _rootUriMeta = const VerificationMeta(
    'rootUri',
  );
  @override
  late final GeneratedColumn<String> rootUri = GeneratedColumn<String>(
    'root_uri',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastModifiedMeta = const VerificationMeta(
    'lastModified',
  );
  @override
  late final GeneratedColumn<int> lastModified = GeneratedColumn<int>(
    'last_modified',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isPrimaryMeta = const VerificationMeta(
    'isPrimary',
  );
  @override
  late final GeneratedColumn<bool> isPrimary = GeneratedColumn<bool>(
    'is_primary',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_primary" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _discNumberMeta = const VerificationMeta(
    'discNumber',
  );
  @override
  late final GeneratedColumn<int> discNumber = GeneratedColumn<int>(
    'disc_number',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _headerStatusMeta = const VerificationMeta(
    'headerStatus',
  );
  @override
  late final GeneratedColumn<String> headerStatus = GeneratedColumn<String>(
    'header_status',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _headerDetailMeta = const VerificationMeta(
    'headerDetail',
  );
  @override
  late final GeneratedColumn<String> headerDetail = GeneratedColumn<String>(
    'header_detail',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    gameId,
    uri,
    displayPath,
    extension,
    sizeBytes,
    sha1,
    crc32,
    storageDeviceId,
    fileExists,
    lastVerifiedAt,
    rootUri,
    lastModified,
    isPrimary,
    discNumber,
    headerStatus,
    headerDetail,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'game_files';
  @override
  VerificationContext validateIntegrity(
    Insertable<GameFileRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('game_id')) {
      context.handle(
        _gameIdMeta,
        gameId.isAcceptableOrUnknown(data['game_id']!, _gameIdMeta),
      );
    } else if (isInserting) {
      context.missing(_gameIdMeta);
    }
    if (data.containsKey('uri')) {
      context.handle(
        _uriMeta,
        uri.isAcceptableOrUnknown(data['uri']!, _uriMeta),
      );
    } else if (isInserting) {
      context.missing(_uriMeta);
    }
    if (data.containsKey('display_path')) {
      context.handle(
        _displayPathMeta,
        displayPath.isAcceptableOrUnknown(
          data['display_path']!,
          _displayPathMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_displayPathMeta);
    }
    if (data.containsKey('extension')) {
      context.handle(
        _extensionMeta,
        extension.isAcceptableOrUnknown(data['extension']!, _extensionMeta),
      );
    } else if (isInserting) {
      context.missing(_extensionMeta);
    }
    if (data.containsKey('size_bytes')) {
      context.handle(
        _sizeBytesMeta,
        sizeBytes.isAcceptableOrUnknown(data['size_bytes']!, _sizeBytesMeta),
      );
    }
    if (data.containsKey('sha1')) {
      context.handle(
        _sha1Meta,
        sha1.isAcceptableOrUnknown(data['sha1']!, _sha1Meta),
      );
    }
    if (data.containsKey('crc32')) {
      context.handle(
        _crc32Meta,
        crc32.isAcceptableOrUnknown(data['crc32']!, _crc32Meta),
      );
    }
    if (data.containsKey('storage_device_id')) {
      context.handle(
        _storageDeviceIdMeta,
        storageDeviceId.isAcceptableOrUnknown(
          data['storage_device_id']!,
          _storageDeviceIdMeta,
        ),
      );
    }
    if (data.containsKey('file_exists')) {
      context.handle(
        _fileExistsMeta,
        fileExists.isAcceptableOrUnknown(data['file_exists']!, _fileExistsMeta),
      );
    }
    if (data.containsKey('last_verified_at')) {
      context.handle(
        _lastVerifiedAtMeta,
        lastVerifiedAt.isAcceptableOrUnknown(
          data['last_verified_at']!,
          _lastVerifiedAtMeta,
        ),
      );
    }
    if (data.containsKey('root_uri')) {
      context.handle(
        _rootUriMeta,
        rootUri.isAcceptableOrUnknown(data['root_uri']!, _rootUriMeta),
      );
    }
    if (data.containsKey('last_modified')) {
      context.handle(
        _lastModifiedMeta,
        lastModified.isAcceptableOrUnknown(
          data['last_modified']!,
          _lastModifiedMeta,
        ),
      );
    }
    if (data.containsKey('is_primary')) {
      context.handle(
        _isPrimaryMeta,
        isPrimary.isAcceptableOrUnknown(data['is_primary']!, _isPrimaryMeta),
      );
    }
    if (data.containsKey('disc_number')) {
      context.handle(
        _discNumberMeta,
        discNumber.isAcceptableOrUnknown(data['disc_number']!, _discNumberMeta),
      );
    }
    if (data.containsKey('header_status')) {
      context.handle(
        _headerStatusMeta,
        headerStatus.isAcceptableOrUnknown(
          data['header_status']!,
          _headerStatusMeta,
        ),
      );
    }
    if (data.containsKey('header_detail')) {
      context.handle(
        _headerDetailMeta,
        headerDetail.isAcceptableOrUnknown(
          data['header_detail']!,
          _headerDetailMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GameFileRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GameFileRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      gameId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}game_id'],
      )!,
      uri: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}uri'],
      )!,
      displayPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_path'],
      )!,
      extension: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}extension'],
      )!,
      sizeBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}size_bytes'],
      ),
      sha1: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sha1'],
      ),
      crc32: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}crc32'],
      ),
      storageDeviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}storage_device_id'],
      ),
      fileExists: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}file_exists'],
      )!,
      lastVerifiedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_verified_at'],
      ),
      rootUri: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}root_uri'],
      ),
      lastModified: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_modified'],
      ),
      isPrimary: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_primary'],
      )!,
      discNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}disc_number'],
      ),
      headerStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}header_status'],
      ),
      headerDetail: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}header_detail'],
      ),
    );
  }

  @override
  $GameFilesTable createAlias(String alias) {
    return $GameFilesTable(attachedDatabase, alias);
  }
}

class GameFileRow extends DataClass implements Insertable<GameFileRow> {
  final int id;
  final int gameId;

  /// SAF document URI or absolute path.
  final String uri;
  final String displayPath;
  final String extension;
  final int? sizeBytes;
  final String? sha1;
  final String? crc32;
  final int? storageDeviceId;
  final bool fileExists;
  final DateTime? lastVerifiedAt;

  /// Scan root (SAF tree URI or directory path) the file was found under;
  /// null for manually imported files.
  final String? rootUri;
  final int? lastModified;
  final bool isPrimary;
  final int? discNumber;

  /// valid | invalid | notChecked (see rom_header_validator.dart).
  final String? headerStatus;
  final String? headerDetail;
  const GameFileRow({
    required this.id,
    required this.gameId,
    required this.uri,
    required this.displayPath,
    required this.extension,
    this.sizeBytes,
    this.sha1,
    this.crc32,
    this.storageDeviceId,
    required this.fileExists,
    this.lastVerifiedAt,
    this.rootUri,
    this.lastModified,
    required this.isPrimary,
    this.discNumber,
    this.headerStatus,
    this.headerDetail,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['game_id'] = Variable<int>(gameId);
    map['uri'] = Variable<String>(uri);
    map['display_path'] = Variable<String>(displayPath);
    map['extension'] = Variable<String>(extension);
    if (!nullToAbsent || sizeBytes != null) {
      map['size_bytes'] = Variable<int>(sizeBytes);
    }
    if (!nullToAbsent || sha1 != null) {
      map['sha1'] = Variable<String>(sha1);
    }
    if (!nullToAbsent || crc32 != null) {
      map['crc32'] = Variable<String>(crc32);
    }
    if (!nullToAbsent || storageDeviceId != null) {
      map['storage_device_id'] = Variable<int>(storageDeviceId);
    }
    map['file_exists'] = Variable<bool>(fileExists);
    if (!nullToAbsent || lastVerifiedAt != null) {
      map['last_verified_at'] = Variable<DateTime>(lastVerifiedAt);
    }
    if (!nullToAbsent || rootUri != null) {
      map['root_uri'] = Variable<String>(rootUri);
    }
    if (!nullToAbsent || lastModified != null) {
      map['last_modified'] = Variable<int>(lastModified);
    }
    map['is_primary'] = Variable<bool>(isPrimary);
    if (!nullToAbsent || discNumber != null) {
      map['disc_number'] = Variable<int>(discNumber);
    }
    if (!nullToAbsent || headerStatus != null) {
      map['header_status'] = Variable<String>(headerStatus);
    }
    if (!nullToAbsent || headerDetail != null) {
      map['header_detail'] = Variable<String>(headerDetail);
    }
    return map;
  }

  GameFilesCompanion toCompanion(bool nullToAbsent) {
    return GameFilesCompanion(
      id: Value(id),
      gameId: Value(gameId),
      uri: Value(uri),
      displayPath: Value(displayPath),
      extension: Value(extension),
      sizeBytes: sizeBytes == null && nullToAbsent
          ? const Value.absent()
          : Value(sizeBytes),
      sha1: sha1 == null && nullToAbsent ? const Value.absent() : Value(sha1),
      crc32: crc32 == null && nullToAbsent
          ? const Value.absent()
          : Value(crc32),
      storageDeviceId: storageDeviceId == null && nullToAbsent
          ? const Value.absent()
          : Value(storageDeviceId),
      fileExists: Value(fileExists),
      lastVerifiedAt: lastVerifiedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastVerifiedAt),
      rootUri: rootUri == null && nullToAbsent
          ? const Value.absent()
          : Value(rootUri),
      lastModified: lastModified == null && nullToAbsent
          ? const Value.absent()
          : Value(lastModified),
      isPrimary: Value(isPrimary),
      discNumber: discNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(discNumber),
      headerStatus: headerStatus == null && nullToAbsent
          ? const Value.absent()
          : Value(headerStatus),
      headerDetail: headerDetail == null && nullToAbsent
          ? const Value.absent()
          : Value(headerDetail),
    );
  }

  factory GameFileRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GameFileRow(
      id: serializer.fromJson<int>(json['id']),
      gameId: serializer.fromJson<int>(json['gameId']),
      uri: serializer.fromJson<String>(json['uri']),
      displayPath: serializer.fromJson<String>(json['displayPath']),
      extension: serializer.fromJson<String>(json['extension']),
      sizeBytes: serializer.fromJson<int?>(json['sizeBytes']),
      sha1: serializer.fromJson<String?>(json['sha1']),
      crc32: serializer.fromJson<String?>(json['crc32']),
      storageDeviceId: serializer.fromJson<int?>(json['storageDeviceId']),
      fileExists: serializer.fromJson<bool>(json['fileExists']),
      lastVerifiedAt: serializer.fromJson<DateTime?>(json['lastVerifiedAt']),
      rootUri: serializer.fromJson<String?>(json['rootUri']),
      lastModified: serializer.fromJson<int?>(json['lastModified']),
      isPrimary: serializer.fromJson<bool>(json['isPrimary']),
      discNumber: serializer.fromJson<int?>(json['discNumber']),
      headerStatus: serializer.fromJson<String?>(json['headerStatus']),
      headerDetail: serializer.fromJson<String?>(json['headerDetail']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'gameId': serializer.toJson<int>(gameId),
      'uri': serializer.toJson<String>(uri),
      'displayPath': serializer.toJson<String>(displayPath),
      'extension': serializer.toJson<String>(extension),
      'sizeBytes': serializer.toJson<int?>(sizeBytes),
      'sha1': serializer.toJson<String?>(sha1),
      'crc32': serializer.toJson<String?>(crc32),
      'storageDeviceId': serializer.toJson<int?>(storageDeviceId),
      'fileExists': serializer.toJson<bool>(fileExists),
      'lastVerifiedAt': serializer.toJson<DateTime?>(lastVerifiedAt),
      'rootUri': serializer.toJson<String?>(rootUri),
      'lastModified': serializer.toJson<int?>(lastModified),
      'isPrimary': serializer.toJson<bool>(isPrimary),
      'discNumber': serializer.toJson<int?>(discNumber),
      'headerStatus': serializer.toJson<String?>(headerStatus),
      'headerDetail': serializer.toJson<String?>(headerDetail),
    };
  }

  GameFileRow copyWith({
    int? id,
    int? gameId,
    String? uri,
    String? displayPath,
    String? extension,
    Value<int?> sizeBytes = const Value.absent(),
    Value<String?> sha1 = const Value.absent(),
    Value<String?> crc32 = const Value.absent(),
    Value<int?> storageDeviceId = const Value.absent(),
    bool? fileExists,
    Value<DateTime?> lastVerifiedAt = const Value.absent(),
    Value<String?> rootUri = const Value.absent(),
    Value<int?> lastModified = const Value.absent(),
    bool? isPrimary,
    Value<int?> discNumber = const Value.absent(),
    Value<String?> headerStatus = const Value.absent(),
    Value<String?> headerDetail = const Value.absent(),
  }) => GameFileRow(
    id: id ?? this.id,
    gameId: gameId ?? this.gameId,
    uri: uri ?? this.uri,
    displayPath: displayPath ?? this.displayPath,
    extension: extension ?? this.extension,
    sizeBytes: sizeBytes.present ? sizeBytes.value : this.sizeBytes,
    sha1: sha1.present ? sha1.value : this.sha1,
    crc32: crc32.present ? crc32.value : this.crc32,
    storageDeviceId: storageDeviceId.present
        ? storageDeviceId.value
        : this.storageDeviceId,
    fileExists: fileExists ?? this.fileExists,
    lastVerifiedAt: lastVerifiedAt.present
        ? lastVerifiedAt.value
        : this.lastVerifiedAt,
    rootUri: rootUri.present ? rootUri.value : this.rootUri,
    lastModified: lastModified.present ? lastModified.value : this.lastModified,
    isPrimary: isPrimary ?? this.isPrimary,
    discNumber: discNumber.present ? discNumber.value : this.discNumber,
    headerStatus: headerStatus.present ? headerStatus.value : this.headerStatus,
    headerDetail: headerDetail.present ? headerDetail.value : this.headerDetail,
  );
  GameFileRow copyWithCompanion(GameFilesCompanion data) {
    return GameFileRow(
      id: data.id.present ? data.id.value : this.id,
      gameId: data.gameId.present ? data.gameId.value : this.gameId,
      uri: data.uri.present ? data.uri.value : this.uri,
      displayPath: data.displayPath.present
          ? data.displayPath.value
          : this.displayPath,
      extension: data.extension.present ? data.extension.value : this.extension,
      sizeBytes: data.sizeBytes.present ? data.sizeBytes.value : this.sizeBytes,
      sha1: data.sha1.present ? data.sha1.value : this.sha1,
      crc32: data.crc32.present ? data.crc32.value : this.crc32,
      storageDeviceId: data.storageDeviceId.present
          ? data.storageDeviceId.value
          : this.storageDeviceId,
      fileExists: data.fileExists.present
          ? data.fileExists.value
          : this.fileExists,
      lastVerifiedAt: data.lastVerifiedAt.present
          ? data.lastVerifiedAt.value
          : this.lastVerifiedAt,
      rootUri: data.rootUri.present ? data.rootUri.value : this.rootUri,
      lastModified: data.lastModified.present
          ? data.lastModified.value
          : this.lastModified,
      isPrimary: data.isPrimary.present ? data.isPrimary.value : this.isPrimary,
      discNumber: data.discNumber.present
          ? data.discNumber.value
          : this.discNumber,
      headerStatus: data.headerStatus.present
          ? data.headerStatus.value
          : this.headerStatus,
      headerDetail: data.headerDetail.present
          ? data.headerDetail.value
          : this.headerDetail,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GameFileRow(')
          ..write('id: $id, ')
          ..write('gameId: $gameId, ')
          ..write('uri: $uri, ')
          ..write('displayPath: $displayPath, ')
          ..write('extension: $extension, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('sha1: $sha1, ')
          ..write('crc32: $crc32, ')
          ..write('storageDeviceId: $storageDeviceId, ')
          ..write('fileExists: $fileExists, ')
          ..write('lastVerifiedAt: $lastVerifiedAt, ')
          ..write('rootUri: $rootUri, ')
          ..write('lastModified: $lastModified, ')
          ..write('isPrimary: $isPrimary, ')
          ..write('discNumber: $discNumber, ')
          ..write('headerStatus: $headerStatus, ')
          ..write('headerDetail: $headerDetail')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    gameId,
    uri,
    displayPath,
    extension,
    sizeBytes,
    sha1,
    crc32,
    storageDeviceId,
    fileExists,
    lastVerifiedAt,
    rootUri,
    lastModified,
    isPrimary,
    discNumber,
    headerStatus,
    headerDetail,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GameFileRow &&
          other.id == this.id &&
          other.gameId == this.gameId &&
          other.uri == this.uri &&
          other.displayPath == this.displayPath &&
          other.extension == this.extension &&
          other.sizeBytes == this.sizeBytes &&
          other.sha1 == this.sha1 &&
          other.crc32 == this.crc32 &&
          other.storageDeviceId == this.storageDeviceId &&
          other.fileExists == this.fileExists &&
          other.lastVerifiedAt == this.lastVerifiedAt &&
          other.rootUri == this.rootUri &&
          other.lastModified == this.lastModified &&
          other.isPrimary == this.isPrimary &&
          other.discNumber == this.discNumber &&
          other.headerStatus == this.headerStatus &&
          other.headerDetail == this.headerDetail);
}

class GameFilesCompanion extends UpdateCompanion<GameFileRow> {
  final Value<int> id;
  final Value<int> gameId;
  final Value<String> uri;
  final Value<String> displayPath;
  final Value<String> extension;
  final Value<int?> sizeBytes;
  final Value<String?> sha1;
  final Value<String?> crc32;
  final Value<int?> storageDeviceId;
  final Value<bool> fileExists;
  final Value<DateTime?> lastVerifiedAt;
  final Value<String?> rootUri;
  final Value<int?> lastModified;
  final Value<bool> isPrimary;
  final Value<int?> discNumber;
  final Value<String?> headerStatus;
  final Value<String?> headerDetail;
  const GameFilesCompanion({
    this.id = const Value.absent(),
    this.gameId = const Value.absent(),
    this.uri = const Value.absent(),
    this.displayPath = const Value.absent(),
    this.extension = const Value.absent(),
    this.sizeBytes = const Value.absent(),
    this.sha1 = const Value.absent(),
    this.crc32 = const Value.absent(),
    this.storageDeviceId = const Value.absent(),
    this.fileExists = const Value.absent(),
    this.lastVerifiedAt = const Value.absent(),
    this.rootUri = const Value.absent(),
    this.lastModified = const Value.absent(),
    this.isPrimary = const Value.absent(),
    this.discNumber = const Value.absent(),
    this.headerStatus = const Value.absent(),
    this.headerDetail = const Value.absent(),
  });
  GameFilesCompanion.insert({
    this.id = const Value.absent(),
    required int gameId,
    required String uri,
    required String displayPath,
    required String extension,
    this.sizeBytes = const Value.absent(),
    this.sha1 = const Value.absent(),
    this.crc32 = const Value.absent(),
    this.storageDeviceId = const Value.absent(),
    this.fileExists = const Value.absent(),
    this.lastVerifiedAt = const Value.absent(),
    this.rootUri = const Value.absent(),
    this.lastModified = const Value.absent(),
    this.isPrimary = const Value.absent(),
    this.discNumber = const Value.absent(),
    this.headerStatus = const Value.absent(),
    this.headerDetail = const Value.absent(),
  }) : gameId = Value(gameId),
       uri = Value(uri),
       displayPath = Value(displayPath),
       extension = Value(extension);
  static Insertable<GameFileRow> custom({
    Expression<int>? id,
    Expression<int>? gameId,
    Expression<String>? uri,
    Expression<String>? displayPath,
    Expression<String>? extension,
    Expression<int>? sizeBytes,
    Expression<String>? sha1,
    Expression<String>? crc32,
    Expression<int>? storageDeviceId,
    Expression<bool>? fileExists,
    Expression<DateTime>? lastVerifiedAt,
    Expression<String>? rootUri,
    Expression<int>? lastModified,
    Expression<bool>? isPrimary,
    Expression<int>? discNumber,
    Expression<String>? headerStatus,
    Expression<String>? headerDetail,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (gameId != null) 'game_id': gameId,
      if (uri != null) 'uri': uri,
      if (displayPath != null) 'display_path': displayPath,
      if (extension != null) 'extension': extension,
      if (sizeBytes != null) 'size_bytes': sizeBytes,
      if (sha1 != null) 'sha1': sha1,
      if (crc32 != null) 'crc32': crc32,
      if (storageDeviceId != null) 'storage_device_id': storageDeviceId,
      if (fileExists != null) 'file_exists': fileExists,
      if (lastVerifiedAt != null) 'last_verified_at': lastVerifiedAt,
      if (rootUri != null) 'root_uri': rootUri,
      if (lastModified != null) 'last_modified': lastModified,
      if (isPrimary != null) 'is_primary': isPrimary,
      if (discNumber != null) 'disc_number': discNumber,
      if (headerStatus != null) 'header_status': headerStatus,
      if (headerDetail != null) 'header_detail': headerDetail,
    });
  }

  GameFilesCompanion copyWith({
    Value<int>? id,
    Value<int>? gameId,
    Value<String>? uri,
    Value<String>? displayPath,
    Value<String>? extension,
    Value<int?>? sizeBytes,
    Value<String?>? sha1,
    Value<String?>? crc32,
    Value<int?>? storageDeviceId,
    Value<bool>? fileExists,
    Value<DateTime?>? lastVerifiedAt,
    Value<String?>? rootUri,
    Value<int?>? lastModified,
    Value<bool>? isPrimary,
    Value<int?>? discNumber,
    Value<String?>? headerStatus,
    Value<String?>? headerDetail,
  }) {
    return GameFilesCompanion(
      id: id ?? this.id,
      gameId: gameId ?? this.gameId,
      uri: uri ?? this.uri,
      displayPath: displayPath ?? this.displayPath,
      extension: extension ?? this.extension,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      sha1: sha1 ?? this.sha1,
      crc32: crc32 ?? this.crc32,
      storageDeviceId: storageDeviceId ?? this.storageDeviceId,
      fileExists: fileExists ?? this.fileExists,
      lastVerifiedAt: lastVerifiedAt ?? this.lastVerifiedAt,
      rootUri: rootUri ?? this.rootUri,
      lastModified: lastModified ?? this.lastModified,
      isPrimary: isPrimary ?? this.isPrimary,
      discNumber: discNumber ?? this.discNumber,
      headerStatus: headerStatus ?? this.headerStatus,
      headerDetail: headerDetail ?? this.headerDetail,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (gameId.present) {
      map['game_id'] = Variable<int>(gameId.value);
    }
    if (uri.present) {
      map['uri'] = Variable<String>(uri.value);
    }
    if (displayPath.present) {
      map['display_path'] = Variable<String>(displayPath.value);
    }
    if (extension.present) {
      map['extension'] = Variable<String>(extension.value);
    }
    if (sizeBytes.present) {
      map['size_bytes'] = Variable<int>(sizeBytes.value);
    }
    if (sha1.present) {
      map['sha1'] = Variable<String>(sha1.value);
    }
    if (crc32.present) {
      map['crc32'] = Variable<String>(crc32.value);
    }
    if (storageDeviceId.present) {
      map['storage_device_id'] = Variable<int>(storageDeviceId.value);
    }
    if (fileExists.present) {
      map['file_exists'] = Variable<bool>(fileExists.value);
    }
    if (lastVerifiedAt.present) {
      map['last_verified_at'] = Variable<DateTime>(lastVerifiedAt.value);
    }
    if (rootUri.present) {
      map['root_uri'] = Variable<String>(rootUri.value);
    }
    if (lastModified.present) {
      map['last_modified'] = Variable<int>(lastModified.value);
    }
    if (isPrimary.present) {
      map['is_primary'] = Variable<bool>(isPrimary.value);
    }
    if (discNumber.present) {
      map['disc_number'] = Variable<int>(discNumber.value);
    }
    if (headerStatus.present) {
      map['header_status'] = Variable<String>(headerStatus.value);
    }
    if (headerDetail.present) {
      map['header_detail'] = Variable<String>(headerDetail.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GameFilesCompanion(')
          ..write('id: $id, ')
          ..write('gameId: $gameId, ')
          ..write('uri: $uri, ')
          ..write('displayPath: $displayPath, ')
          ..write('extension: $extension, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('sha1: $sha1, ')
          ..write('crc32: $crc32, ')
          ..write('storageDeviceId: $storageDeviceId, ')
          ..write('fileExists: $fileExists, ')
          ..write('lastVerifiedAt: $lastVerifiedAt, ')
          ..write('rootUri: $rootUri, ')
          ..write('lastModified: $lastModified, ')
          ..write('isPrimary: $isPrimary, ')
          ..write('discNumber: $discNumber, ')
          ..write('headerStatus: $headerStatus, ')
          ..write('headerDetail: $headerDetail')
          ..write(')'))
        .toString();
  }
}

class $GameMetadataTable extends GameMetadata
    with TableInfo<$GameMetadataTable, GameMetadataRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GameMetadataTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _gameIdMeta = const VerificationMeta('gameId');
  @override
  late final GeneratedColumn<int> gameId = GeneratedColumn<int>(
    'game_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES games (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _developerMeta = const VerificationMeta(
    'developer',
  );
  @override
  late final GeneratedColumn<String> developer = GeneratedColumn<String>(
    'developer',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _publisherMeta = const VerificationMeta(
    'publisher',
  );
  @override
  late final GeneratedColumn<String> publisher = GeneratedColumn<String>(
    'publisher',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _releaseDateMeta = const VerificationMeta(
    'releaseDate',
  );
  @override
  late final GeneratedColumn<String> releaseDate = GeneratedColumn<String>(
    'release_date',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _genreMeta = const VerificationMeta('genre');
  @override
  late final GeneratedColumn<String> genre = GeneratedColumn<String>(
    'genre',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _playersMeta = const VerificationMeta(
    'players',
  );
  @override
  late final GeneratedColumn<int> players = GeneratedColumn<int>(
    'players',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _providerMeta = const VerificationMeta(
    'provider',
  );
  @override
  late final GeneratedColumn<String> provider = GeneratedColumn<String>(
    'provider',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _providerIdMeta = const VerificationMeta(
    'providerId',
  );
  @override
  late final GeneratedColumn<String> providerId = GeneratedColumn<String>(
    'provider_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _editedManuallyMeta = const VerificationMeta(
    'editedManually',
  );
  @override
  late final GeneratedColumn<bool> editedManually = GeneratedColumn<bool>(
    'edited_manually',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("edited_manually" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _fetchedAtMeta = const VerificationMeta(
    'fetchedAt',
  );
  @override
  late final GeneratedColumn<DateTime> fetchedAt = GeneratedColumn<DateTime>(
    'fetched_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    gameId,
    description,
    developer,
    publisher,
    releaseDate,
    genre,
    players,
    provider,
    providerId,
    editedManually,
    fetchedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'game_metadata';
  @override
  VerificationContext validateIntegrity(
    Insertable<GameMetadataRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('game_id')) {
      context.handle(
        _gameIdMeta,
        gameId.isAcceptableOrUnknown(data['game_id']!, _gameIdMeta),
      );
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('developer')) {
      context.handle(
        _developerMeta,
        developer.isAcceptableOrUnknown(data['developer']!, _developerMeta),
      );
    }
    if (data.containsKey('publisher')) {
      context.handle(
        _publisherMeta,
        publisher.isAcceptableOrUnknown(data['publisher']!, _publisherMeta),
      );
    }
    if (data.containsKey('release_date')) {
      context.handle(
        _releaseDateMeta,
        releaseDate.isAcceptableOrUnknown(
          data['release_date']!,
          _releaseDateMeta,
        ),
      );
    }
    if (data.containsKey('genre')) {
      context.handle(
        _genreMeta,
        genre.isAcceptableOrUnknown(data['genre']!, _genreMeta),
      );
    }
    if (data.containsKey('players')) {
      context.handle(
        _playersMeta,
        players.isAcceptableOrUnknown(data['players']!, _playersMeta),
      );
    }
    if (data.containsKey('provider')) {
      context.handle(
        _providerMeta,
        provider.isAcceptableOrUnknown(data['provider']!, _providerMeta),
      );
    }
    if (data.containsKey('provider_id')) {
      context.handle(
        _providerIdMeta,
        providerId.isAcceptableOrUnknown(data['provider_id']!, _providerIdMeta),
      );
    }
    if (data.containsKey('edited_manually')) {
      context.handle(
        _editedManuallyMeta,
        editedManually.isAcceptableOrUnknown(
          data['edited_manually']!,
          _editedManuallyMeta,
        ),
      );
    }
    if (data.containsKey('fetched_at')) {
      context.handle(
        _fetchedAtMeta,
        fetchedAt.isAcceptableOrUnknown(data['fetched_at']!, _fetchedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {gameId};
  @override
  GameMetadataRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GameMetadataRow(
      gameId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}game_id'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      developer: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}developer'],
      ),
      publisher: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}publisher'],
      ),
      releaseDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}release_date'],
      ),
      genre: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}genre'],
      ),
      players: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}players'],
      ),
      provider: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}provider'],
      ),
      providerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}provider_id'],
      ),
      editedManually: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}edited_manually'],
      )!,
      fetchedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fetched_at'],
      ),
    );
  }

  @override
  $GameMetadataTable createAlias(String alias) {
    return $GameMetadataTable(attachedDatabase, alias);
  }
}

class GameMetadataRow extends DataClass implements Insertable<GameMetadataRow> {
  final int gameId;
  final String? description;
  final String? developer;
  final String? publisher;
  final String? releaseDate;
  final String? genre;
  final int? players;
  final String? provider;
  final String? providerId;
  final bool editedManually;
  final DateTime? fetchedAt;
  const GameMetadataRow({
    required this.gameId,
    this.description,
    this.developer,
    this.publisher,
    this.releaseDate,
    this.genre,
    this.players,
    this.provider,
    this.providerId,
    required this.editedManually,
    this.fetchedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['game_id'] = Variable<int>(gameId);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || developer != null) {
      map['developer'] = Variable<String>(developer);
    }
    if (!nullToAbsent || publisher != null) {
      map['publisher'] = Variable<String>(publisher);
    }
    if (!nullToAbsent || releaseDate != null) {
      map['release_date'] = Variable<String>(releaseDate);
    }
    if (!nullToAbsent || genre != null) {
      map['genre'] = Variable<String>(genre);
    }
    if (!nullToAbsent || players != null) {
      map['players'] = Variable<int>(players);
    }
    if (!nullToAbsent || provider != null) {
      map['provider'] = Variable<String>(provider);
    }
    if (!nullToAbsent || providerId != null) {
      map['provider_id'] = Variable<String>(providerId);
    }
    map['edited_manually'] = Variable<bool>(editedManually);
    if (!nullToAbsent || fetchedAt != null) {
      map['fetched_at'] = Variable<DateTime>(fetchedAt);
    }
    return map;
  }

  GameMetadataCompanion toCompanion(bool nullToAbsent) {
    return GameMetadataCompanion(
      gameId: Value(gameId),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      developer: developer == null && nullToAbsent
          ? const Value.absent()
          : Value(developer),
      publisher: publisher == null && nullToAbsent
          ? const Value.absent()
          : Value(publisher),
      releaseDate: releaseDate == null && nullToAbsent
          ? const Value.absent()
          : Value(releaseDate),
      genre: genre == null && nullToAbsent
          ? const Value.absent()
          : Value(genre),
      players: players == null && nullToAbsent
          ? const Value.absent()
          : Value(players),
      provider: provider == null && nullToAbsent
          ? const Value.absent()
          : Value(provider),
      providerId: providerId == null && nullToAbsent
          ? const Value.absent()
          : Value(providerId),
      editedManually: Value(editedManually),
      fetchedAt: fetchedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(fetchedAt),
    );
  }

  factory GameMetadataRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GameMetadataRow(
      gameId: serializer.fromJson<int>(json['gameId']),
      description: serializer.fromJson<String?>(json['description']),
      developer: serializer.fromJson<String?>(json['developer']),
      publisher: serializer.fromJson<String?>(json['publisher']),
      releaseDate: serializer.fromJson<String?>(json['releaseDate']),
      genre: serializer.fromJson<String?>(json['genre']),
      players: serializer.fromJson<int?>(json['players']),
      provider: serializer.fromJson<String?>(json['provider']),
      providerId: serializer.fromJson<String?>(json['providerId']),
      editedManually: serializer.fromJson<bool>(json['editedManually']),
      fetchedAt: serializer.fromJson<DateTime?>(json['fetchedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'gameId': serializer.toJson<int>(gameId),
      'description': serializer.toJson<String?>(description),
      'developer': serializer.toJson<String?>(developer),
      'publisher': serializer.toJson<String?>(publisher),
      'releaseDate': serializer.toJson<String?>(releaseDate),
      'genre': serializer.toJson<String?>(genre),
      'players': serializer.toJson<int?>(players),
      'provider': serializer.toJson<String?>(provider),
      'providerId': serializer.toJson<String?>(providerId),
      'editedManually': serializer.toJson<bool>(editedManually),
      'fetchedAt': serializer.toJson<DateTime?>(fetchedAt),
    };
  }

  GameMetadataRow copyWith({
    int? gameId,
    Value<String?> description = const Value.absent(),
    Value<String?> developer = const Value.absent(),
    Value<String?> publisher = const Value.absent(),
    Value<String?> releaseDate = const Value.absent(),
    Value<String?> genre = const Value.absent(),
    Value<int?> players = const Value.absent(),
    Value<String?> provider = const Value.absent(),
    Value<String?> providerId = const Value.absent(),
    bool? editedManually,
    Value<DateTime?> fetchedAt = const Value.absent(),
  }) => GameMetadataRow(
    gameId: gameId ?? this.gameId,
    description: description.present ? description.value : this.description,
    developer: developer.present ? developer.value : this.developer,
    publisher: publisher.present ? publisher.value : this.publisher,
    releaseDate: releaseDate.present ? releaseDate.value : this.releaseDate,
    genre: genre.present ? genre.value : this.genre,
    players: players.present ? players.value : this.players,
    provider: provider.present ? provider.value : this.provider,
    providerId: providerId.present ? providerId.value : this.providerId,
    editedManually: editedManually ?? this.editedManually,
    fetchedAt: fetchedAt.present ? fetchedAt.value : this.fetchedAt,
  );
  GameMetadataRow copyWithCompanion(GameMetadataCompanion data) {
    return GameMetadataRow(
      gameId: data.gameId.present ? data.gameId.value : this.gameId,
      description: data.description.present
          ? data.description.value
          : this.description,
      developer: data.developer.present ? data.developer.value : this.developer,
      publisher: data.publisher.present ? data.publisher.value : this.publisher,
      releaseDate: data.releaseDate.present
          ? data.releaseDate.value
          : this.releaseDate,
      genre: data.genre.present ? data.genre.value : this.genre,
      players: data.players.present ? data.players.value : this.players,
      provider: data.provider.present ? data.provider.value : this.provider,
      providerId: data.providerId.present
          ? data.providerId.value
          : this.providerId,
      editedManually: data.editedManually.present
          ? data.editedManually.value
          : this.editedManually,
      fetchedAt: data.fetchedAt.present ? data.fetchedAt.value : this.fetchedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GameMetadataRow(')
          ..write('gameId: $gameId, ')
          ..write('description: $description, ')
          ..write('developer: $developer, ')
          ..write('publisher: $publisher, ')
          ..write('releaseDate: $releaseDate, ')
          ..write('genre: $genre, ')
          ..write('players: $players, ')
          ..write('provider: $provider, ')
          ..write('providerId: $providerId, ')
          ..write('editedManually: $editedManually, ')
          ..write('fetchedAt: $fetchedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    gameId,
    description,
    developer,
    publisher,
    releaseDate,
    genre,
    players,
    provider,
    providerId,
    editedManually,
    fetchedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GameMetadataRow &&
          other.gameId == this.gameId &&
          other.description == this.description &&
          other.developer == this.developer &&
          other.publisher == this.publisher &&
          other.releaseDate == this.releaseDate &&
          other.genre == this.genre &&
          other.players == this.players &&
          other.provider == this.provider &&
          other.providerId == this.providerId &&
          other.editedManually == this.editedManually &&
          other.fetchedAt == this.fetchedAt);
}

class GameMetadataCompanion extends UpdateCompanion<GameMetadataRow> {
  final Value<int> gameId;
  final Value<String?> description;
  final Value<String?> developer;
  final Value<String?> publisher;
  final Value<String?> releaseDate;
  final Value<String?> genre;
  final Value<int?> players;
  final Value<String?> provider;
  final Value<String?> providerId;
  final Value<bool> editedManually;
  final Value<DateTime?> fetchedAt;
  const GameMetadataCompanion({
    this.gameId = const Value.absent(),
    this.description = const Value.absent(),
    this.developer = const Value.absent(),
    this.publisher = const Value.absent(),
    this.releaseDate = const Value.absent(),
    this.genre = const Value.absent(),
    this.players = const Value.absent(),
    this.provider = const Value.absent(),
    this.providerId = const Value.absent(),
    this.editedManually = const Value.absent(),
    this.fetchedAt = const Value.absent(),
  });
  GameMetadataCompanion.insert({
    this.gameId = const Value.absent(),
    this.description = const Value.absent(),
    this.developer = const Value.absent(),
    this.publisher = const Value.absent(),
    this.releaseDate = const Value.absent(),
    this.genre = const Value.absent(),
    this.players = const Value.absent(),
    this.provider = const Value.absent(),
    this.providerId = const Value.absent(),
    this.editedManually = const Value.absent(),
    this.fetchedAt = const Value.absent(),
  });
  static Insertable<GameMetadataRow> custom({
    Expression<int>? gameId,
    Expression<String>? description,
    Expression<String>? developer,
    Expression<String>? publisher,
    Expression<String>? releaseDate,
    Expression<String>? genre,
    Expression<int>? players,
    Expression<String>? provider,
    Expression<String>? providerId,
    Expression<bool>? editedManually,
    Expression<DateTime>? fetchedAt,
  }) {
    return RawValuesInsertable({
      if (gameId != null) 'game_id': gameId,
      if (description != null) 'description': description,
      if (developer != null) 'developer': developer,
      if (publisher != null) 'publisher': publisher,
      if (releaseDate != null) 'release_date': releaseDate,
      if (genre != null) 'genre': genre,
      if (players != null) 'players': players,
      if (provider != null) 'provider': provider,
      if (providerId != null) 'provider_id': providerId,
      if (editedManually != null) 'edited_manually': editedManually,
      if (fetchedAt != null) 'fetched_at': fetchedAt,
    });
  }

  GameMetadataCompanion copyWith({
    Value<int>? gameId,
    Value<String?>? description,
    Value<String?>? developer,
    Value<String?>? publisher,
    Value<String?>? releaseDate,
    Value<String?>? genre,
    Value<int?>? players,
    Value<String?>? provider,
    Value<String?>? providerId,
    Value<bool>? editedManually,
    Value<DateTime?>? fetchedAt,
  }) {
    return GameMetadataCompanion(
      gameId: gameId ?? this.gameId,
      description: description ?? this.description,
      developer: developer ?? this.developer,
      publisher: publisher ?? this.publisher,
      releaseDate: releaseDate ?? this.releaseDate,
      genre: genre ?? this.genre,
      players: players ?? this.players,
      provider: provider ?? this.provider,
      providerId: providerId ?? this.providerId,
      editedManually: editedManually ?? this.editedManually,
      fetchedAt: fetchedAt ?? this.fetchedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (gameId.present) {
      map['game_id'] = Variable<int>(gameId.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (developer.present) {
      map['developer'] = Variable<String>(developer.value);
    }
    if (publisher.present) {
      map['publisher'] = Variable<String>(publisher.value);
    }
    if (releaseDate.present) {
      map['release_date'] = Variable<String>(releaseDate.value);
    }
    if (genre.present) {
      map['genre'] = Variable<String>(genre.value);
    }
    if (players.present) {
      map['players'] = Variable<int>(players.value);
    }
    if (provider.present) {
      map['provider'] = Variable<String>(provider.value);
    }
    if (providerId.present) {
      map['provider_id'] = Variable<String>(providerId.value);
    }
    if (editedManually.present) {
      map['edited_manually'] = Variable<bool>(editedManually.value);
    }
    if (fetchedAt.present) {
      map['fetched_at'] = Variable<DateTime>(fetchedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GameMetadataCompanion(')
          ..write('gameId: $gameId, ')
          ..write('description: $description, ')
          ..write('developer: $developer, ')
          ..write('publisher: $publisher, ')
          ..write('releaseDate: $releaseDate, ')
          ..write('genre: $genre, ')
          ..write('players: $players, ')
          ..write('provider: $provider, ')
          ..write('providerId: $providerId, ')
          ..write('editedManually: $editedManually, ')
          ..write('fetchedAt: $fetchedAt')
          ..write(')'))
        .toString();
  }
}

class $GameArtworksTable extends GameArtworks
    with TableInfo<$GameArtworksTable, GameArtworkRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GameArtworksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _gameIdMeta = const VerificationMeta('gameId');
  @override
  late final GeneratedColumn<int> gameId = GeneratedColumn<int>(
    'game_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES games (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    check: () => type.isIn(const ['cover', 'screenshot', 'background']),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _localPathMeta = const VerificationMeta(
    'localPath',
  );
  @override
  late final GeneratedColumn<String> localPath = GeneratedColumn<String>(
    'local_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceUrlMeta = const VerificationMeta(
    'sourceUrl',
  );
  @override
  late final GeneratedColumn<String> sourceUrl = GeneratedColumn<String>(
    'source_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _providerMeta = const VerificationMeta(
    'provider',
  );
  @override
  late final GeneratedColumn<String> provider = GeneratedColumn<String>(
    'provider',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fetchedAtMeta = const VerificationMeta(
    'fetchedAt',
  );
  @override
  late final GeneratedColumn<DateTime> fetchedAt = GeneratedColumn<DateTime>(
    'fetched_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    gameId,
    type,
    localPath,
    sourceUrl,
    provider,
    fetchedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'game_artworks';
  @override
  VerificationContext validateIntegrity(
    Insertable<GameArtworkRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('game_id')) {
      context.handle(
        _gameIdMeta,
        gameId.isAcceptableOrUnknown(data['game_id']!, _gameIdMeta),
      );
    } else if (isInserting) {
      context.missing(_gameIdMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('local_path')) {
      context.handle(
        _localPathMeta,
        localPath.isAcceptableOrUnknown(data['local_path']!, _localPathMeta),
      );
    } else if (isInserting) {
      context.missing(_localPathMeta);
    }
    if (data.containsKey('source_url')) {
      context.handle(
        _sourceUrlMeta,
        sourceUrl.isAcceptableOrUnknown(data['source_url']!, _sourceUrlMeta),
      );
    }
    if (data.containsKey('provider')) {
      context.handle(
        _providerMeta,
        provider.isAcceptableOrUnknown(data['provider']!, _providerMeta),
      );
    }
    if (data.containsKey('fetched_at')) {
      context.handle(
        _fetchedAtMeta,
        fetchedAt.isAcceptableOrUnknown(data['fetched_at']!, _fetchedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_fetchedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GameArtworkRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GameArtworkRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      gameId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}game_id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      localPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_path'],
      )!,
      sourceUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_url'],
      ),
      provider: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}provider'],
      ),
      fetchedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fetched_at'],
      )!,
    );
  }

  @override
  $GameArtworksTable createAlias(String alias) {
    return $GameArtworksTable(attachedDatabase, alias);
  }
}

class GameArtworkRow extends DataClass implements Insertable<GameArtworkRow> {
  final int id;
  final int gameId;
  final String type;
  final String localPath;
  final String? sourceUrl;
  final String? provider;
  final DateTime fetchedAt;
  const GameArtworkRow({
    required this.id,
    required this.gameId,
    required this.type,
    required this.localPath,
    this.sourceUrl,
    this.provider,
    required this.fetchedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['game_id'] = Variable<int>(gameId);
    map['type'] = Variable<String>(type);
    map['local_path'] = Variable<String>(localPath);
    if (!nullToAbsent || sourceUrl != null) {
      map['source_url'] = Variable<String>(sourceUrl);
    }
    if (!nullToAbsent || provider != null) {
      map['provider'] = Variable<String>(provider);
    }
    map['fetched_at'] = Variable<DateTime>(fetchedAt);
    return map;
  }

  GameArtworksCompanion toCompanion(bool nullToAbsent) {
    return GameArtworksCompanion(
      id: Value(id),
      gameId: Value(gameId),
      type: Value(type),
      localPath: Value(localPath),
      sourceUrl: sourceUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceUrl),
      provider: provider == null && nullToAbsent
          ? const Value.absent()
          : Value(provider),
      fetchedAt: Value(fetchedAt),
    );
  }

  factory GameArtworkRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GameArtworkRow(
      id: serializer.fromJson<int>(json['id']),
      gameId: serializer.fromJson<int>(json['gameId']),
      type: serializer.fromJson<String>(json['type']),
      localPath: serializer.fromJson<String>(json['localPath']),
      sourceUrl: serializer.fromJson<String?>(json['sourceUrl']),
      provider: serializer.fromJson<String?>(json['provider']),
      fetchedAt: serializer.fromJson<DateTime>(json['fetchedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'gameId': serializer.toJson<int>(gameId),
      'type': serializer.toJson<String>(type),
      'localPath': serializer.toJson<String>(localPath),
      'sourceUrl': serializer.toJson<String?>(sourceUrl),
      'provider': serializer.toJson<String?>(provider),
      'fetchedAt': serializer.toJson<DateTime>(fetchedAt),
    };
  }

  GameArtworkRow copyWith({
    int? id,
    int? gameId,
    String? type,
    String? localPath,
    Value<String?> sourceUrl = const Value.absent(),
    Value<String?> provider = const Value.absent(),
    DateTime? fetchedAt,
  }) => GameArtworkRow(
    id: id ?? this.id,
    gameId: gameId ?? this.gameId,
    type: type ?? this.type,
    localPath: localPath ?? this.localPath,
    sourceUrl: sourceUrl.present ? sourceUrl.value : this.sourceUrl,
    provider: provider.present ? provider.value : this.provider,
    fetchedAt: fetchedAt ?? this.fetchedAt,
  );
  GameArtworkRow copyWithCompanion(GameArtworksCompanion data) {
    return GameArtworkRow(
      id: data.id.present ? data.id.value : this.id,
      gameId: data.gameId.present ? data.gameId.value : this.gameId,
      type: data.type.present ? data.type.value : this.type,
      localPath: data.localPath.present ? data.localPath.value : this.localPath,
      sourceUrl: data.sourceUrl.present ? data.sourceUrl.value : this.sourceUrl,
      provider: data.provider.present ? data.provider.value : this.provider,
      fetchedAt: data.fetchedAt.present ? data.fetchedAt.value : this.fetchedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GameArtworkRow(')
          ..write('id: $id, ')
          ..write('gameId: $gameId, ')
          ..write('type: $type, ')
          ..write('localPath: $localPath, ')
          ..write('sourceUrl: $sourceUrl, ')
          ..write('provider: $provider, ')
          ..write('fetchedAt: $fetchedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, gameId, type, localPath, sourceUrl, provider, fetchedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GameArtworkRow &&
          other.id == this.id &&
          other.gameId == this.gameId &&
          other.type == this.type &&
          other.localPath == this.localPath &&
          other.sourceUrl == this.sourceUrl &&
          other.provider == this.provider &&
          other.fetchedAt == this.fetchedAt);
}

class GameArtworksCompanion extends UpdateCompanion<GameArtworkRow> {
  final Value<int> id;
  final Value<int> gameId;
  final Value<String> type;
  final Value<String> localPath;
  final Value<String?> sourceUrl;
  final Value<String?> provider;
  final Value<DateTime> fetchedAt;
  const GameArtworksCompanion({
    this.id = const Value.absent(),
    this.gameId = const Value.absent(),
    this.type = const Value.absent(),
    this.localPath = const Value.absent(),
    this.sourceUrl = const Value.absent(),
    this.provider = const Value.absent(),
    this.fetchedAt = const Value.absent(),
  });
  GameArtworksCompanion.insert({
    this.id = const Value.absent(),
    required int gameId,
    required String type,
    required String localPath,
    this.sourceUrl = const Value.absent(),
    this.provider = const Value.absent(),
    required DateTime fetchedAt,
  }) : gameId = Value(gameId),
       type = Value(type),
       localPath = Value(localPath),
       fetchedAt = Value(fetchedAt);
  static Insertable<GameArtworkRow> custom({
    Expression<int>? id,
    Expression<int>? gameId,
    Expression<String>? type,
    Expression<String>? localPath,
    Expression<String>? sourceUrl,
    Expression<String>? provider,
    Expression<DateTime>? fetchedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (gameId != null) 'game_id': gameId,
      if (type != null) 'type': type,
      if (localPath != null) 'local_path': localPath,
      if (sourceUrl != null) 'source_url': sourceUrl,
      if (provider != null) 'provider': provider,
      if (fetchedAt != null) 'fetched_at': fetchedAt,
    });
  }

  GameArtworksCompanion copyWith({
    Value<int>? id,
    Value<int>? gameId,
    Value<String>? type,
    Value<String>? localPath,
    Value<String?>? sourceUrl,
    Value<String?>? provider,
    Value<DateTime>? fetchedAt,
  }) {
    return GameArtworksCompanion(
      id: id ?? this.id,
      gameId: gameId ?? this.gameId,
      type: type ?? this.type,
      localPath: localPath ?? this.localPath,
      sourceUrl: sourceUrl ?? this.sourceUrl,
      provider: provider ?? this.provider,
      fetchedAt: fetchedAt ?? this.fetchedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (gameId.present) {
      map['game_id'] = Variable<int>(gameId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (localPath.present) {
      map['local_path'] = Variable<String>(localPath.value);
    }
    if (sourceUrl.present) {
      map['source_url'] = Variable<String>(sourceUrl.value);
    }
    if (provider.present) {
      map['provider'] = Variable<String>(provider.value);
    }
    if (fetchedAt.present) {
      map['fetched_at'] = Variable<DateTime>(fetchedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GameArtworksCompanion(')
          ..write('id: $id, ')
          ..write('gameId: $gameId, ')
          ..write('type: $type, ')
          ..write('localPath: $localPath, ')
          ..write('sourceUrl: $sourceUrl, ')
          ..write('provider: $provider, ')
          ..write('fetchedAt: $fetchedAt')
          ..write(')'))
        .toString();
  }
}

class $FavoritesTable extends Favorites
    with TableInfo<$FavoritesTable, FavoriteRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FavoritesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _gameIdMeta = const VerificationMeta('gameId');
  @override
  late final GeneratedColumn<int> gameId = GeneratedColumn<int>(
    'game_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES games (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _addedAtMeta = const VerificationMeta(
    'addedAt',
  );
  @override
  late final GeneratedColumn<DateTime> addedAt = GeneratedColumn<DateTime>(
    'added_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [gameId, addedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'favorites';
  @override
  VerificationContext validateIntegrity(
    Insertable<FavoriteRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('game_id')) {
      context.handle(
        _gameIdMeta,
        gameId.isAcceptableOrUnknown(data['game_id']!, _gameIdMeta),
      );
    }
    if (data.containsKey('added_at')) {
      context.handle(
        _addedAtMeta,
        addedAt.isAcceptableOrUnknown(data['added_at']!, _addedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_addedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {gameId};
  @override
  FavoriteRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FavoriteRow(
      gameId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}game_id'],
      )!,
      addedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}added_at'],
      )!,
    );
  }

  @override
  $FavoritesTable createAlias(String alias) {
    return $FavoritesTable(attachedDatabase, alias);
  }
}

class FavoriteRow extends DataClass implements Insertable<FavoriteRow> {
  final int gameId;
  final DateTime addedAt;
  const FavoriteRow({required this.gameId, required this.addedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['game_id'] = Variable<int>(gameId);
    map['added_at'] = Variable<DateTime>(addedAt);
    return map;
  }

  FavoritesCompanion toCompanion(bool nullToAbsent) {
    return FavoritesCompanion(gameId: Value(gameId), addedAt: Value(addedAt));
  }

  factory FavoriteRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FavoriteRow(
      gameId: serializer.fromJson<int>(json['gameId']),
      addedAt: serializer.fromJson<DateTime>(json['addedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'gameId': serializer.toJson<int>(gameId),
      'addedAt': serializer.toJson<DateTime>(addedAt),
    };
  }

  FavoriteRow copyWith({int? gameId, DateTime? addedAt}) => FavoriteRow(
    gameId: gameId ?? this.gameId,
    addedAt: addedAt ?? this.addedAt,
  );
  FavoriteRow copyWithCompanion(FavoritesCompanion data) {
    return FavoriteRow(
      gameId: data.gameId.present ? data.gameId.value : this.gameId,
      addedAt: data.addedAt.present ? data.addedAt.value : this.addedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FavoriteRow(')
          ..write('gameId: $gameId, ')
          ..write('addedAt: $addedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(gameId, addedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FavoriteRow &&
          other.gameId == this.gameId &&
          other.addedAt == this.addedAt);
}

class FavoritesCompanion extends UpdateCompanion<FavoriteRow> {
  final Value<int> gameId;
  final Value<DateTime> addedAt;
  const FavoritesCompanion({
    this.gameId = const Value.absent(),
    this.addedAt = const Value.absent(),
  });
  FavoritesCompanion.insert({
    this.gameId = const Value.absent(),
    required DateTime addedAt,
  }) : addedAt = Value(addedAt);
  static Insertable<FavoriteRow> custom({
    Expression<int>? gameId,
    Expression<DateTime>? addedAt,
  }) {
    return RawValuesInsertable({
      if (gameId != null) 'game_id': gameId,
      if (addedAt != null) 'added_at': addedAt,
    });
  }

  FavoritesCompanion copyWith({Value<int>? gameId, Value<DateTime>? addedAt}) {
    return FavoritesCompanion(
      gameId: gameId ?? this.gameId,
      addedAt: addedAt ?? this.addedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (gameId.present) {
      map['game_id'] = Variable<int>(gameId.value);
    }
    if (addedAt.present) {
      map['added_at'] = Variable<DateTime>(addedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FavoritesCompanion(')
          ..write('gameId: $gameId, ')
          ..write('addedAt: $addedAt')
          ..write(')'))
        .toString();
  }
}

class $GameHistoryTable extends GameHistory
    with TableInfo<$GameHistoryTable, GameHistoryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GameHistoryTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _gameIdMeta = const VerificationMeta('gameId');
  @override
  late final GeneratedColumn<int> gameId = GeneratedColumn<int>(
    'game_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES games (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _emulatorIdMeta = const VerificationMeta(
    'emulatorId',
  );
  @override
  late final GeneratedColumn<String> emulatorId = GeneratedColumn<String>(
    'emulator_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endedAtMeta = const VerificationMeta(
    'endedAt',
  );
  @override
  late final GeneratedColumn<DateTime> endedAt = GeneratedColumn<DateTime>(
    'ended_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _durationSecondsMeta = const VerificationMeta(
    'durationSeconds',
  );
  @override
  late final GeneratedColumn<int> durationSeconds = GeneratedColumn<int>(
    'duration_seconds',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _exitStatusMeta = const VerificationMeta(
    'exitStatus',
  );
  @override
  late final GeneratedColumn<String> exitStatus = GeneratedColumn<String>(
    'exit_status',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    gameId,
    emulatorId,
    startedAt,
    endedAt,
    durationSeconds,
    exitStatus,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'game_history';
  @override
  VerificationContext validateIntegrity(
    Insertable<GameHistoryRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('game_id')) {
      context.handle(
        _gameIdMeta,
        gameId.isAcceptableOrUnknown(data['game_id']!, _gameIdMeta),
      );
    } else if (isInserting) {
      context.missing(_gameIdMeta);
    }
    if (data.containsKey('emulator_id')) {
      context.handle(
        _emulatorIdMeta,
        emulatorId.isAcceptableOrUnknown(data['emulator_id']!, _emulatorIdMeta),
      );
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('ended_at')) {
      context.handle(
        _endedAtMeta,
        endedAt.isAcceptableOrUnknown(data['ended_at']!, _endedAtMeta),
      );
    }
    if (data.containsKey('duration_seconds')) {
      context.handle(
        _durationSecondsMeta,
        durationSeconds.isAcceptableOrUnknown(
          data['duration_seconds']!,
          _durationSecondsMeta,
        ),
      );
    }
    if (data.containsKey('exit_status')) {
      context.handle(
        _exitStatusMeta,
        exitStatus.isAcceptableOrUnknown(data['exit_status']!, _exitStatusMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GameHistoryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GameHistoryRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      gameId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}game_id'],
      )!,
      emulatorId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}emulator_id'],
      ),
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      )!,
      endedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}ended_at'],
      ),
      durationSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_seconds'],
      ),
      exitStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}exit_status'],
      ),
    );
  }

  @override
  $GameHistoryTable createAlias(String alias) {
    return $GameHistoryTable(attachedDatabase, alias);
  }
}

class GameHistoryRow extends DataClass implements Insertable<GameHistoryRow> {
  final int id;
  final int gameId;
  final String? emulatorId;
  final DateTime startedAt;
  final DateTime? endedAt;
  final int? durationSeconds;
  final String? exitStatus;
  const GameHistoryRow({
    required this.id,
    required this.gameId,
    this.emulatorId,
    required this.startedAt,
    this.endedAt,
    this.durationSeconds,
    this.exitStatus,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['game_id'] = Variable<int>(gameId);
    if (!nullToAbsent || emulatorId != null) {
      map['emulator_id'] = Variable<String>(emulatorId);
    }
    map['started_at'] = Variable<DateTime>(startedAt);
    if (!nullToAbsent || endedAt != null) {
      map['ended_at'] = Variable<DateTime>(endedAt);
    }
    if (!nullToAbsent || durationSeconds != null) {
      map['duration_seconds'] = Variable<int>(durationSeconds);
    }
    if (!nullToAbsent || exitStatus != null) {
      map['exit_status'] = Variable<String>(exitStatus);
    }
    return map;
  }

  GameHistoryCompanion toCompanion(bool nullToAbsent) {
    return GameHistoryCompanion(
      id: Value(id),
      gameId: Value(gameId),
      emulatorId: emulatorId == null && nullToAbsent
          ? const Value.absent()
          : Value(emulatorId),
      startedAt: Value(startedAt),
      endedAt: endedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(endedAt),
      durationSeconds: durationSeconds == null && nullToAbsent
          ? const Value.absent()
          : Value(durationSeconds),
      exitStatus: exitStatus == null && nullToAbsent
          ? const Value.absent()
          : Value(exitStatus),
    );
  }

  factory GameHistoryRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GameHistoryRow(
      id: serializer.fromJson<int>(json['id']),
      gameId: serializer.fromJson<int>(json['gameId']),
      emulatorId: serializer.fromJson<String?>(json['emulatorId']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      endedAt: serializer.fromJson<DateTime?>(json['endedAt']),
      durationSeconds: serializer.fromJson<int?>(json['durationSeconds']),
      exitStatus: serializer.fromJson<String?>(json['exitStatus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'gameId': serializer.toJson<int>(gameId),
      'emulatorId': serializer.toJson<String?>(emulatorId),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'endedAt': serializer.toJson<DateTime?>(endedAt),
      'durationSeconds': serializer.toJson<int?>(durationSeconds),
      'exitStatus': serializer.toJson<String?>(exitStatus),
    };
  }

  GameHistoryRow copyWith({
    int? id,
    int? gameId,
    Value<String?> emulatorId = const Value.absent(),
    DateTime? startedAt,
    Value<DateTime?> endedAt = const Value.absent(),
    Value<int?> durationSeconds = const Value.absent(),
    Value<String?> exitStatus = const Value.absent(),
  }) => GameHistoryRow(
    id: id ?? this.id,
    gameId: gameId ?? this.gameId,
    emulatorId: emulatorId.present ? emulatorId.value : this.emulatorId,
    startedAt: startedAt ?? this.startedAt,
    endedAt: endedAt.present ? endedAt.value : this.endedAt,
    durationSeconds: durationSeconds.present
        ? durationSeconds.value
        : this.durationSeconds,
    exitStatus: exitStatus.present ? exitStatus.value : this.exitStatus,
  );
  GameHistoryRow copyWithCompanion(GameHistoryCompanion data) {
    return GameHistoryRow(
      id: data.id.present ? data.id.value : this.id,
      gameId: data.gameId.present ? data.gameId.value : this.gameId,
      emulatorId: data.emulatorId.present
          ? data.emulatorId.value
          : this.emulatorId,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      endedAt: data.endedAt.present ? data.endedAt.value : this.endedAt,
      durationSeconds: data.durationSeconds.present
          ? data.durationSeconds.value
          : this.durationSeconds,
      exitStatus: data.exitStatus.present
          ? data.exitStatus.value
          : this.exitStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GameHistoryRow(')
          ..write('id: $id, ')
          ..write('gameId: $gameId, ')
          ..write('emulatorId: $emulatorId, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('exitStatus: $exitStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    gameId,
    emulatorId,
    startedAt,
    endedAt,
    durationSeconds,
    exitStatus,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GameHistoryRow &&
          other.id == this.id &&
          other.gameId == this.gameId &&
          other.emulatorId == this.emulatorId &&
          other.startedAt == this.startedAt &&
          other.endedAt == this.endedAt &&
          other.durationSeconds == this.durationSeconds &&
          other.exitStatus == this.exitStatus);
}

class GameHistoryCompanion extends UpdateCompanion<GameHistoryRow> {
  final Value<int> id;
  final Value<int> gameId;
  final Value<String?> emulatorId;
  final Value<DateTime> startedAt;
  final Value<DateTime?> endedAt;
  final Value<int?> durationSeconds;
  final Value<String?> exitStatus;
  const GameHistoryCompanion({
    this.id = const Value.absent(),
    this.gameId = const Value.absent(),
    this.emulatorId = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.endedAt = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    this.exitStatus = const Value.absent(),
  });
  GameHistoryCompanion.insert({
    this.id = const Value.absent(),
    required int gameId,
    this.emulatorId = const Value.absent(),
    required DateTime startedAt,
    this.endedAt = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    this.exitStatus = const Value.absent(),
  }) : gameId = Value(gameId),
       startedAt = Value(startedAt);
  static Insertable<GameHistoryRow> custom({
    Expression<int>? id,
    Expression<int>? gameId,
    Expression<String>? emulatorId,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? endedAt,
    Expression<int>? durationSeconds,
    Expression<String>? exitStatus,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (gameId != null) 'game_id': gameId,
      if (emulatorId != null) 'emulator_id': emulatorId,
      if (startedAt != null) 'started_at': startedAt,
      if (endedAt != null) 'ended_at': endedAt,
      if (durationSeconds != null) 'duration_seconds': durationSeconds,
      if (exitStatus != null) 'exit_status': exitStatus,
    });
  }

  GameHistoryCompanion copyWith({
    Value<int>? id,
    Value<int>? gameId,
    Value<String?>? emulatorId,
    Value<DateTime>? startedAt,
    Value<DateTime?>? endedAt,
    Value<int?>? durationSeconds,
    Value<String?>? exitStatus,
  }) {
    return GameHistoryCompanion(
      id: id ?? this.id,
      gameId: gameId ?? this.gameId,
      emulatorId: emulatorId ?? this.emulatorId,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      exitStatus: exitStatus ?? this.exitStatus,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (gameId.present) {
      map['game_id'] = Variable<int>(gameId.value);
    }
    if (emulatorId.present) {
      map['emulator_id'] = Variable<String>(emulatorId.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (endedAt.present) {
      map['ended_at'] = Variable<DateTime>(endedAt.value);
    }
    if (durationSeconds.present) {
      map['duration_seconds'] = Variable<int>(durationSeconds.value);
    }
    if (exitStatus.present) {
      map['exit_status'] = Variable<String>(exitStatus.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GameHistoryCompanion(')
          ..write('id: $id, ')
          ..write('gameId: $gameId, ')
          ..write('emulatorId: $emulatorId, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('exitStatus: $exitStatus')
          ..write(')'))
        .toString();
  }
}

class $ControllerDevicesTable extends ControllerDevices
    with TableInfo<$ControllerDevicesTable, ControllerDeviceRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ControllerDevicesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _descriptorMeta = const VerificationMeta(
    'descriptor',
  );
  @override
  late final GeneratedColumn<String> descriptor = GeneratedColumn<String>(
    'descriptor',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _vendorIdMeta = const VerificationMeta(
    'vendorId',
  );
  @override
  late final GeneratedColumn<int> vendorId = GeneratedColumn<int>(
    'vendor_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _productIdMeta = const VerificationMeta(
    'productId',
  );
  @override
  late final GeneratedColumn<int> productId = GeneratedColumn<int>(
    'product_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _controllerTypeMeta = const VerificationMeta(
    'controllerType',
  );
  @override
  late final GeneratedColumn<String> controllerType = GeneratedColumn<String>(
    'controller_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hasVibratorMeta = const VerificationMeta(
    'hasVibrator',
  );
  @override
  late final GeneratedColumn<bool> hasVibrator = GeneratedColumn<bool>(
    'has_vibrator',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("has_vibrator" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _buttonsJsonMeta = const VerificationMeta(
    'buttonsJson',
  );
  @override
  late final GeneratedColumn<String> buttonsJson = GeneratedColumn<String>(
    'buttons_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _axesJsonMeta = const VerificationMeta(
    'axesJson',
  );
  @override
  late final GeneratedColumn<String> axesJson = GeneratedColumn<String>(
    'axes_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _assignedPlayerMeta = const VerificationMeta(
    'assignedPlayer',
  );
  @override
  late final GeneratedColumn<int> assignedPlayer = GeneratedColumn<int>(
    'assigned_player',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _firstSeenAtMeta = const VerificationMeta(
    'firstSeenAt',
  );
  @override
  late final GeneratedColumn<DateTime> firstSeenAt = GeneratedColumn<DateTime>(
    'first_seen_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastSeenAtMeta = const VerificationMeta(
    'lastSeenAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastSeenAt = GeneratedColumn<DateTime>(
    'last_seen_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    descriptor,
    name,
    vendorId,
    productId,
    controllerType,
    hasVibrator,
    buttonsJson,
    axesJson,
    assignedPlayer,
    firstSeenAt,
    lastSeenAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'controller_devices';
  @override
  VerificationContext validateIntegrity(
    Insertable<ControllerDeviceRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('descriptor')) {
      context.handle(
        _descriptorMeta,
        descriptor.isAcceptableOrUnknown(data['descriptor']!, _descriptorMeta),
      );
    } else if (isInserting) {
      context.missing(_descriptorMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('vendor_id')) {
      context.handle(
        _vendorIdMeta,
        vendorId.isAcceptableOrUnknown(data['vendor_id']!, _vendorIdMeta),
      );
    }
    if (data.containsKey('product_id')) {
      context.handle(
        _productIdMeta,
        productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta),
      );
    }
    if (data.containsKey('controller_type')) {
      context.handle(
        _controllerTypeMeta,
        controllerType.isAcceptableOrUnknown(
          data['controller_type']!,
          _controllerTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_controllerTypeMeta);
    }
    if (data.containsKey('has_vibrator')) {
      context.handle(
        _hasVibratorMeta,
        hasVibrator.isAcceptableOrUnknown(
          data['has_vibrator']!,
          _hasVibratorMeta,
        ),
      );
    }
    if (data.containsKey('buttons_json')) {
      context.handle(
        _buttonsJsonMeta,
        buttonsJson.isAcceptableOrUnknown(
          data['buttons_json']!,
          _buttonsJsonMeta,
        ),
      );
    }
    if (data.containsKey('axes_json')) {
      context.handle(
        _axesJsonMeta,
        axesJson.isAcceptableOrUnknown(data['axes_json']!, _axesJsonMeta),
      );
    }
    if (data.containsKey('assigned_player')) {
      context.handle(
        _assignedPlayerMeta,
        assignedPlayer.isAcceptableOrUnknown(
          data['assigned_player']!,
          _assignedPlayerMeta,
        ),
      );
    }
    if (data.containsKey('first_seen_at')) {
      context.handle(
        _firstSeenAtMeta,
        firstSeenAt.isAcceptableOrUnknown(
          data['first_seen_at']!,
          _firstSeenAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_firstSeenAtMeta);
    }
    if (data.containsKey('last_seen_at')) {
      context.handle(
        _lastSeenAtMeta,
        lastSeenAt.isAcceptableOrUnknown(
          data['last_seen_at']!,
          _lastSeenAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastSeenAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ControllerDeviceRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ControllerDeviceRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      descriptor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}descriptor'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      vendorId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}vendor_id'],
      ),
      productId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}product_id'],
      ),
      controllerType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}controller_type'],
      )!,
      hasVibrator: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}has_vibrator'],
      )!,
      buttonsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}buttons_json'],
      )!,
      axesJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}axes_json'],
      )!,
      assignedPlayer: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}assigned_player'],
      ),
      firstSeenAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}first_seen_at'],
      )!,
      lastSeenAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_seen_at'],
      )!,
    );
  }

  @override
  $ControllerDevicesTable createAlias(String alias) {
    return $ControllerDevicesTable(attachedDatabase, alias);
  }
}

class ControllerDeviceRow extends DataClass
    implements Insertable<ControllerDeviceRow> {
  final int id;
  final String descriptor;
  final String name;
  final int? vendorId;
  final int? productId;
  final String controllerType;
  final bool hasVibrator;
  final String buttonsJson;
  final String axesJson;
  final int? assignedPlayer;
  final DateTime firstSeenAt;
  final DateTime lastSeenAt;
  const ControllerDeviceRow({
    required this.id,
    required this.descriptor,
    required this.name,
    this.vendorId,
    this.productId,
    required this.controllerType,
    required this.hasVibrator,
    required this.buttonsJson,
    required this.axesJson,
    this.assignedPlayer,
    required this.firstSeenAt,
    required this.lastSeenAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['descriptor'] = Variable<String>(descriptor);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || vendorId != null) {
      map['vendor_id'] = Variable<int>(vendorId);
    }
    if (!nullToAbsent || productId != null) {
      map['product_id'] = Variable<int>(productId);
    }
    map['controller_type'] = Variable<String>(controllerType);
    map['has_vibrator'] = Variable<bool>(hasVibrator);
    map['buttons_json'] = Variable<String>(buttonsJson);
    map['axes_json'] = Variable<String>(axesJson);
    if (!nullToAbsent || assignedPlayer != null) {
      map['assigned_player'] = Variable<int>(assignedPlayer);
    }
    map['first_seen_at'] = Variable<DateTime>(firstSeenAt);
    map['last_seen_at'] = Variable<DateTime>(lastSeenAt);
    return map;
  }

  ControllerDevicesCompanion toCompanion(bool nullToAbsent) {
    return ControllerDevicesCompanion(
      id: Value(id),
      descriptor: Value(descriptor),
      name: Value(name),
      vendorId: vendorId == null && nullToAbsent
          ? const Value.absent()
          : Value(vendorId),
      productId: productId == null && nullToAbsent
          ? const Value.absent()
          : Value(productId),
      controllerType: Value(controllerType),
      hasVibrator: Value(hasVibrator),
      buttonsJson: Value(buttonsJson),
      axesJson: Value(axesJson),
      assignedPlayer: assignedPlayer == null && nullToAbsent
          ? const Value.absent()
          : Value(assignedPlayer),
      firstSeenAt: Value(firstSeenAt),
      lastSeenAt: Value(lastSeenAt),
    );
  }

  factory ControllerDeviceRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ControllerDeviceRow(
      id: serializer.fromJson<int>(json['id']),
      descriptor: serializer.fromJson<String>(json['descriptor']),
      name: serializer.fromJson<String>(json['name']),
      vendorId: serializer.fromJson<int?>(json['vendorId']),
      productId: serializer.fromJson<int?>(json['productId']),
      controllerType: serializer.fromJson<String>(json['controllerType']),
      hasVibrator: serializer.fromJson<bool>(json['hasVibrator']),
      buttonsJson: serializer.fromJson<String>(json['buttonsJson']),
      axesJson: serializer.fromJson<String>(json['axesJson']),
      assignedPlayer: serializer.fromJson<int?>(json['assignedPlayer']),
      firstSeenAt: serializer.fromJson<DateTime>(json['firstSeenAt']),
      lastSeenAt: serializer.fromJson<DateTime>(json['lastSeenAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'descriptor': serializer.toJson<String>(descriptor),
      'name': serializer.toJson<String>(name),
      'vendorId': serializer.toJson<int?>(vendorId),
      'productId': serializer.toJson<int?>(productId),
      'controllerType': serializer.toJson<String>(controllerType),
      'hasVibrator': serializer.toJson<bool>(hasVibrator),
      'buttonsJson': serializer.toJson<String>(buttonsJson),
      'axesJson': serializer.toJson<String>(axesJson),
      'assignedPlayer': serializer.toJson<int?>(assignedPlayer),
      'firstSeenAt': serializer.toJson<DateTime>(firstSeenAt),
      'lastSeenAt': serializer.toJson<DateTime>(lastSeenAt),
    };
  }

  ControllerDeviceRow copyWith({
    int? id,
    String? descriptor,
    String? name,
    Value<int?> vendorId = const Value.absent(),
    Value<int?> productId = const Value.absent(),
    String? controllerType,
    bool? hasVibrator,
    String? buttonsJson,
    String? axesJson,
    Value<int?> assignedPlayer = const Value.absent(),
    DateTime? firstSeenAt,
    DateTime? lastSeenAt,
  }) => ControllerDeviceRow(
    id: id ?? this.id,
    descriptor: descriptor ?? this.descriptor,
    name: name ?? this.name,
    vendorId: vendorId.present ? vendorId.value : this.vendorId,
    productId: productId.present ? productId.value : this.productId,
    controllerType: controllerType ?? this.controllerType,
    hasVibrator: hasVibrator ?? this.hasVibrator,
    buttonsJson: buttonsJson ?? this.buttonsJson,
    axesJson: axesJson ?? this.axesJson,
    assignedPlayer: assignedPlayer.present
        ? assignedPlayer.value
        : this.assignedPlayer,
    firstSeenAt: firstSeenAt ?? this.firstSeenAt,
    lastSeenAt: lastSeenAt ?? this.lastSeenAt,
  );
  ControllerDeviceRow copyWithCompanion(ControllerDevicesCompanion data) {
    return ControllerDeviceRow(
      id: data.id.present ? data.id.value : this.id,
      descriptor: data.descriptor.present
          ? data.descriptor.value
          : this.descriptor,
      name: data.name.present ? data.name.value : this.name,
      vendorId: data.vendorId.present ? data.vendorId.value : this.vendorId,
      productId: data.productId.present ? data.productId.value : this.productId,
      controllerType: data.controllerType.present
          ? data.controllerType.value
          : this.controllerType,
      hasVibrator: data.hasVibrator.present
          ? data.hasVibrator.value
          : this.hasVibrator,
      buttonsJson: data.buttonsJson.present
          ? data.buttonsJson.value
          : this.buttonsJson,
      axesJson: data.axesJson.present ? data.axesJson.value : this.axesJson,
      assignedPlayer: data.assignedPlayer.present
          ? data.assignedPlayer.value
          : this.assignedPlayer,
      firstSeenAt: data.firstSeenAt.present
          ? data.firstSeenAt.value
          : this.firstSeenAt,
      lastSeenAt: data.lastSeenAt.present
          ? data.lastSeenAt.value
          : this.lastSeenAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ControllerDeviceRow(')
          ..write('id: $id, ')
          ..write('descriptor: $descriptor, ')
          ..write('name: $name, ')
          ..write('vendorId: $vendorId, ')
          ..write('productId: $productId, ')
          ..write('controllerType: $controllerType, ')
          ..write('hasVibrator: $hasVibrator, ')
          ..write('buttonsJson: $buttonsJson, ')
          ..write('axesJson: $axesJson, ')
          ..write('assignedPlayer: $assignedPlayer, ')
          ..write('firstSeenAt: $firstSeenAt, ')
          ..write('lastSeenAt: $lastSeenAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    descriptor,
    name,
    vendorId,
    productId,
    controllerType,
    hasVibrator,
    buttonsJson,
    axesJson,
    assignedPlayer,
    firstSeenAt,
    lastSeenAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ControllerDeviceRow &&
          other.id == this.id &&
          other.descriptor == this.descriptor &&
          other.name == this.name &&
          other.vendorId == this.vendorId &&
          other.productId == this.productId &&
          other.controllerType == this.controllerType &&
          other.hasVibrator == this.hasVibrator &&
          other.buttonsJson == this.buttonsJson &&
          other.axesJson == this.axesJson &&
          other.assignedPlayer == this.assignedPlayer &&
          other.firstSeenAt == this.firstSeenAt &&
          other.lastSeenAt == this.lastSeenAt);
}

class ControllerDevicesCompanion extends UpdateCompanion<ControllerDeviceRow> {
  final Value<int> id;
  final Value<String> descriptor;
  final Value<String> name;
  final Value<int?> vendorId;
  final Value<int?> productId;
  final Value<String> controllerType;
  final Value<bool> hasVibrator;
  final Value<String> buttonsJson;
  final Value<String> axesJson;
  final Value<int?> assignedPlayer;
  final Value<DateTime> firstSeenAt;
  final Value<DateTime> lastSeenAt;
  const ControllerDevicesCompanion({
    this.id = const Value.absent(),
    this.descriptor = const Value.absent(),
    this.name = const Value.absent(),
    this.vendorId = const Value.absent(),
    this.productId = const Value.absent(),
    this.controllerType = const Value.absent(),
    this.hasVibrator = const Value.absent(),
    this.buttonsJson = const Value.absent(),
    this.axesJson = const Value.absent(),
    this.assignedPlayer = const Value.absent(),
    this.firstSeenAt = const Value.absent(),
    this.lastSeenAt = const Value.absent(),
  });
  ControllerDevicesCompanion.insert({
    this.id = const Value.absent(),
    required String descriptor,
    required String name,
    this.vendorId = const Value.absent(),
    this.productId = const Value.absent(),
    required String controllerType,
    this.hasVibrator = const Value.absent(),
    this.buttonsJson = const Value.absent(),
    this.axesJson = const Value.absent(),
    this.assignedPlayer = const Value.absent(),
    required DateTime firstSeenAt,
    required DateTime lastSeenAt,
  }) : descriptor = Value(descriptor),
       name = Value(name),
       controllerType = Value(controllerType),
       firstSeenAt = Value(firstSeenAt),
       lastSeenAt = Value(lastSeenAt);
  static Insertable<ControllerDeviceRow> custom({
    Expression<int>? id,
    Expression<String>? descriptor,
    Expression<String>? name,
    Expression<int>? vendorId,
    Expression<int>? productId,
    Expression<String>? controllerType,
    Expression<bool>? hasVibrator,
    Expression<String>? buttonsJson,
    Expression<String>? axesJson,
    Expression<int>? assignedPlayer,
    Expression<DateTime>? firstSeenAt,
    Expression<DateTime>? lastSeenAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (descriptor != null) 'descriptor': descriptor,
      if (name != null) 'name': name,
      if (vendorId != null) 'vendor_id': vendorId,
      if (productId != null) 'product_id': productId,
      if (controllerType != null) 'controller_type': controllerType,
      if (hasVibrator != null) 'has_vibrator': hasVibrator,
      if (buttonsJson != null) 'buttons_json': buttonsJson,
      if (axesJson != null) 'axes_json': axesJson,
      if (assignedPlayer != null) 'assigned_player': assignedPlayer,
      if (firstSeenAt != null) 'first_seen_at': firstSeenAt,
      if (lastSeenAt != null) 'last_seen_at': lastSeenAt,
    });
  }

  ControllerDevicesCompanion copyWith({
    Value<int>? id,
    Value<String>? descriptor,
    Value<String>? name,
    Value<int?>? vendorId,
    Value<int?>? productId,
    Value<String>? controllerType,
    Value<bool>? hasVibrator,
    Value<String>? buttonsJson,
    Value<String>? axesJson,
    Value<int?>? assignedPlayer,
    Value<DateTime>? firstSeenAt,
    Value<DateTime>? lastSeenAt,
  }) {
    return ControllerDevicesCompanion(
      id: id ?? this.id,
      descriptor: descriptor ?? this.descriptor,
      name: name ?? this.name,
      vendorId: vendorId ?? this.vendorId,
      productId: productId ?? this.productId,
      controllerType: controllerType ?? this.controllerType,
      hasVibrator: hasVibrator ?? this.hasVibrator,
      buttonsJson: buttonsJson ?? this.buttonsJson,
      axesJson: axesJson ?? this.axesJson,
      assignedPlayer: assignedPlayer ?? this.assignedPlayer,
      firstSeenAt: firstSeenAt ?? this.firstSeenAt,
      lastSeenAt: lastSeenAt ?? this.lastSeenAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (descriptor.present) {
      map['descriptor'] = Variable<String>(descriptor.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (vendorId.present) {
      map['vendor_id'] = Variable<int>(vendorId.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<int>(productId.value);
    }
    if (controllerType.present) {
      map['controller_type'] = Variable<String>(controllerType.value);
    }
    if (hasVibrator.present) {
      map['has_vibrator'] = Variable<bool>(hasVibrator.value);
    }
    if (buttonsJson.present) {
      map['buttons_json'] = Variable<String>(buttonsJson.value);
    }
    if (axesJson.present) {
      map['axes_json'] = Variable<String>(axesJson.value);
    }
    if (assignedPlayer.present) {
      map['assigned_player'] = Variable<int>(assignedPlayer.value);
    }
    if (firstSeenAt.present) {
      map['first_seen_at'] = Variable<DateTime>(firstSeenAt.value);
    }
    if (lastSeenAt.present) {
      map['last_seen_at'] = Variable<DateTime>(lastSeenAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ControllerDevicesCompanion(')
          ..write('id: $id, ')
          ..write('descriptor: $descriptor, ')
          ..write('name: $name, ')
          ..write('vendorId: $vendorId, ')
          ..write('productId: $productId, ')
          ..write('controllerType: $controllerType, ')
          ..write('hasVibrator: $hasVibrator, ')
          ..write('buttonsJson: $buttonsJson, ')
          ..write('axesJson: $axesJson, ')
          ..write('assignedPlayer: $assignedPlayer, ')
          ..write('firstSeenAt: $firstSeenAt, ')
          ..write('lastSeenAt: $lastSeenAt')
          ..write(')'))
        .toString();
  }
}

class $ControllerProfilesTable extends ControllerProfiles
    with TableInfo<$ControllerProfilesTable, ControllerProfileRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ControllerProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _controllerDescriptorMeta =
      const VerificationMeta('controllerDescriptor');
  @override
  late final GeneratedColumn<String> controllerDescriptor =
      GeneratedColumn<String>(
        'controller_descriptor',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _consoleIdMeta = const VerificationMeta(
    'consoleId',
  );
  @override
  late final GeneratedColumn<String> consoleId = GeneratedColumn<String>(
    'console_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES consoles (id)',
    ),
  );
  static const VerificationMeta _deadZoneMeta = const VerificationMeta(
    'deadZone',
  );
  @override
  late final GeneratedColumn<double> deadZone = GeneratedColumn<double>(
    'dead_zone',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.15),
  );
  static const VerificationMeta _triggerThresholdMeta = const VerificationMeta(
    'triggerThreshold',
  );
  @override
  late final GeneratedColumn<double> triggerThreshold = GeneratedColumn<double>(
    'trigger_threshold',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.5),
  );
  static const VerificationMeta _vibrationEnabledMeta = const VerificationMeta(
    'vibrationEnabled',
  );
  @override
  late final GeneratedColumn<bool> vibrationEnabled = GeneratedColumn<bool>(
    'vibration_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("vibration_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _isDefaultMeta = const VerificationMeta(
    'isDefault',
  );
  @override
  late final GeneratedColumn<bool> isDefault = GeneratedColumn<bool>(
    'is_default',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_default" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _calibrationJsonMeta = const VerificationMeta(
    'calibrationJson',
  );
  @override
  late final GeneratedColumn<String> calibrationJson = GeneratedColumn<String>(
    'calibration_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    controllerDescriptor,
    consoleId,
    deadZone,
    triggerThreshold,
    vibrationEnabled,
    isDefault,
    calibrationJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'controller_profiles';
  @override
  VerificationContext validateIntegrity(
    Insertable<ControllerProfileRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('controller_descriptor')) {
      context.handle(
        _controllerDescriptorMeta,
        controllerDescriptor.isAcceptableOrUnknown(
          data['controller_descriptor']!,
          _controllerDescriptorMeta,
        ),
      );
    }
    if (data.containsKey('console_id')) {
      context.handle(
        _consoleIdMeta,
        consoleId.isAcceptableOrUnknown(data['console_id']!, _consoleIdMeta),
      );
    }
    if (data.containsKey('dead_zone')) {
      context.handle(
        _deadZoneMeta,
        deadZone.isAcceptableOrUnknown(data['dead_zone']!, _deadZoneMeta),
      );
    }
    if (data.containsKey('trigger_threshold')) {
      context.handle(
        _triggerThresholdMeta,
        triggerThreshold.isAcceptableOrUnknown(
          data['trigger_threshold']!,
          _triggerThresholdMeta,
        ),
      );
    }
    if (data.containsKey('vibration_enabled')) {
      context.handle(
        _vibrationEnabledMeta,
        vibrationEnabled.isAcceptableOrUnknown(
          data['vibration_enabled']!,
          _vibrationEnabledMeta,
        ),
      );
    }
    if (data.containsKey('is_default')) {
      context.handle(
        _isDefaultMeta,
        isDefault.isAcceptableOrUnknown(data['is_default']!, _isDefaultMeta),
      );
    }
    if (data.containsKey('calibration_json')) {
      context.handle(
        _calibrationJsonMeta,
        calibrationJson.isAcceptableOrUnknown(
          data['calibration_json']!,
          _calibrationJsonMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ControllerProfileRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ControllerProfileRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      controllerDescriptor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}controller_descriptor'],
      ),
      consoleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}console_id'],
      ),
      deadZone: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}dead_zone'],
      )!,
      triggerThreshold: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}trigger_threshold'],
      )!,
      vibrationEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}vibration_enabled'],
      )!,
      isDefault: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_default'],
      )!,
      calibrationJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}calibration_json'],
      ),
    );
  }

  @override
  $ControllerProfilesTable createAlias(String alias) {
    return $ControllerProfilesTable(attachedDatabase, alias);
  }
}

class ControllerProfileRow extends DataClass
    implements Insertable<ControllerProfileRow> {
  final int id;
  final String name;
  final String? controllerDescriptor;
  final String? consoleId;
  final double deadZone;
  final double triggerThreshold;
  final bool vibrationEnabled;
  final bool isDefault;

  /// Per-axis centre/min/max captured by the calibration screen (schema v3).
  final String? calibrationJson;
  const ControllerProfileRow({
    required this.id,
    required this.name,
    this.controllerDescriptor,
    this.consoleId,
    required this.deadZone,
    required this.triggerThreshold,
    required this.vibrationEnabled,
    required this.isDefault,
    this.calibrationJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || controllerDescriptor != null) {
      map['controller_descriptor'] = Variable<String>(controllerDescriptor);
    }
    if (!nullToAbsent || consoleId != null) {
      map['console_id'] = Variable<String>(consoleId);
    }
    map['dead_zone'] = Variable<double>(deadZone);
    map['trigger_threshold'] = Variable<double>(triggerThreshold);
    map['vibration_enabled'] = Variable<bool>(vibrationEnabled);
    map['is_default'] = Variable<bool>(isDefault);
    if (!nullToAbsent || calibrationJson != null) {
      map['calibration_json'] = Variable<String>(calibrationJson);
    }
    return map;
  }

  ControllerProfilesCompanion toCompanion(bool nullToAbsent) {
    return ControllerProfilesCompanion(
      id: Value(id),
      name: Value(name),
      controllerDescriptor: controllerDescriptor == null && nullToAbsent
          ? const Value.absent()
          : Value(controllerDescriptor),
      consoleId: consoleId == null && nullToAbsent
          ? const Value.absent()
          : Value(consoleId),
      deadZone: Value(deadZone),
      triggerThreshold: Value(triggerThreshold),
      vibrationEnabled: Value(vibrationEnabled),
      isDefault: Value(isDefault),
      calibrationJson: calibrationJson == null && nullToAbsent
          ? const Value.absent()
          : Value(calibrationJson),
    );
  }

  factory ControllerProfileRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ControllerProfileRow(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      controllerDescriptor: serializer.fromJson<String?>(
        json['controllerDescriptor'],
      ),
      consoleId: serializer.fromJson<String?>(json['consoleId']),
      deadZone: serializer.fromJson<double>(json['deadZone']),
      triggerThreshold: serializer.fromJson<double>(json['triggerThreshold']),
      vibrationEnabled: serializer.fromJson<bool>(json['vibrationEnabled']),
      isDefault: serializer.fromJson<bool>(json['isDefault']),
      calibrationJson: serializer.fromJson<String?>(json['calibrationJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'controllerDescriptor': serializer.toJson<String?>(controllerDescriptor),
      'consoleId': serializer.toJson<String?>(consoleId),
      'deadZone': serializer.toJson<double>(deadZone),
      'triggerThreshold': serializer.toJson<double>(triggerThreshold),
      'vibrationEnabled': serializer.toJson<bool>(vibrationEnabled),
      'isDefault': serializer.toJson<bool>(isDefault),
      'calibrationJson': serializer.toJson<String?>(calibrationJson),
    };
  }

  ControllerProfileRow copyWith({
    int? id,
    String? name,
    Value<String?> controllerDescriptor = const Value.absent(),
    Value<String?> consoleId = const Value.absent(),
    double? deadZone,
    double? triggerThreshold,
    bool? vibrationEnabled,
    bool? isDefault,
    Value<String?> calibrationJson = const Value.absent(),
  }) => ControllerProfileRow(
    id: id ?? this.id,
    name: name ?? this.name,
    controllerDescriptor: controllerDescriptor.present
        ? controllerDescriptor.value
        : this.controllerDescriptor,
    consoleId: consoleId.present ? consoleId.value : this.consoleId,
    deadZone: deadZone ?? this.deadZone,
    triggerThreshold: triggerThreshold ?? this.triggerThreshold,
    vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
    isDefault: isDefault ?? this.isDefault,
    calibrationJson: calibrationJson.present
        ? calibrationJson.value
        : this.calibrationJson,
  );
  ControllerProfileRow copyWithCompanion(ControllerProfilesCompanion data) {
    return ControllerProfileRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      controllerDescriptor: data.controllerDescriptor.present
          ? data.controllerDescriptor.value
          : this.controllerDescriptor,
      consoleId: data.consoleId.present ? data.consoleId.value : this.consoleId,
      deadZone: data.deadZone.present ? data.deadZone.value : this.deadZone,
      triggerThreshold: data.triggerThreshold.present
          ? data.triggerThreshold.value
          : this.triggerThreshold,
      vibrationEnabled: data.vibrationEnabled.present
          ? data.vibrationEnabled.value
          : this.vibrationEnabled,
      isDefault: data.isDefault.present ? data.isDefault.value : this.isDefault,
      calibrationJson: data.calibrationJson.present
          ? data.calibrationJson.value
          : this.calibrationJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ControllerProfileRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('controllerDescriptor: $controllerDescriptor, ')
          ..write('consoleId: $consoleId, ')
          ..write('deadZone: $deadZone, ')
          ..write('triggerThreshold: $triggerThreshold, ')
          ..write('vibrationEnabled: $vibrationEnabled, ')
          ..write('isDefault: $isDefault, ')
          ..write('calibrationJson: $calibrationJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    controllerDescriptor,
    consoleId,
    deadZone,
    triggerThreshold,
    vibrationEnabled,
    isDefault,
    calibrationJson,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ControllerProfileRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.controllerDescriptor == this.controllerDescriptor &&
          other.consoleId == this.consoleId &&
          other.deadZone == this.deadZone &&
          other.triggerThreshold == this.triggerThreshold &&
          other.vibrationEnabled == this.vibrationEnabled &&
          other.isDefault == this.isDefault &&
          other.calibrationJson == this.calibrationJson);
}

class ControllerProfilesCompanion
    extends UpdateCompanion<ControllerProfileRow> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> controllerDescriptor;
  final Value<String?> consoleId;
  final Value<double> deadZone;
  final Value<double> triggerThreshold;
  final Value<bool> vibrationEnabled;
  final Value<bool> isDefault;
  final Value<String?> calibrationJson;
  const ControllerProfilesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.controllerDescriptor = const Value.absent(),
    this.consoleId = const Value.absent(),
    this.deadZone = const Value.absent(),
    this.triggerThreshold = const Value.absent(),
    this.vibrationEnabled = const Value.absent(),
    this.isDefault = const Value.absent(),
    this.calibrationJson = const Value.absent(),
  });
  ControllerProfilesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.controllerDescriptor = const Value.absent(),
    this.consoleId = const Value.absent(),
    this.deadZone = const Value.absent(),
    this.triggerThreshold = const Value.absent(),
    this.vibrationEnabled = const Value.absent(),
    this.isDefault = const Value.absent(),
    this.calibrationJson = const Value.absent(),
  }) : name = Value(name);
  static Insertable<ControllerProfileRow> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? controllerDescriptor,
    Expression<String>? consoleId,
    Expression<double>? deadZone,
    Expression<double>? triggerThreshold,
    Expression<bool>? vibrationEnabled,
    Expression<bool>? isDefault,
    Expression<String>? calibrationJson,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (controllerDescriptor != null)
        'controller_descriptor': controllerDescriptor,
      if (consoleId != null) 'console_id': consoleId,
      if (deadZone != null) 'dead_zone': deadZone,
      if (triggerThreshold != null) 'trigger_threshold': triggerThreshold,
      if (vibrationEnabled != null) 'vibration_enabled': vibrationEnabled,
      if (isDefault != null) 'is_default': isDefault,
      if (calibrationJson != null) 'calibration_json': calibrationJson,
    });
  }

  ControllerProfilesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String?>? controllerDescriptor,
    Value<String?>? consoleId,
    Value<double>? deadZone,
    Value<double>? triggerThreshold,
    Value<bool>? vibrationEnabled,
    Value<bool>? isDefault,
    Value<String?>? calibrationJson,
  }) {
    return ControllerProfilesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      controllerDescriptor: controllerDescriptor ?? this.controllerDescriptor,
      consoleId: consoleId ?? this.consoleId,
      deadZone: deadZone ?? this.deadZone,
      triggerThreshold: triggerThreshold ?? this.triggerThreshold,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      isDefault: isDefault ?? this.isDefault,
      calibrationJson: calibrationJson ?? this.calibrationJson,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (controllerDescriptor.present) {
      map['controller_descriptor'] = Variable<String>(
        controllerDescriptor.value,
      );
    }
    if (consoleId.present) {
      map['console_id'] = Variable<String>(consoleId.value);
    }
    if (deadZone.present) {
      map['dead_zone'] = Variable<double>(deadZone.value);
    }
    if (triggerThreshold.present) {
      map['trigger_threshold'] = Variable<double>(triggerThreshold.value);
    }
    if (vibrationEnabled.present) {
      map['vibration_enabled'] = Variable<bool>(vibrationEnabled.value);
    }
    if (isDefault.present) {
      map['is_default'] = Variable<bool>(isDefault.value);
    }
    if (calibrationJson.present) {
      map['calibration_json'] = Variable<String>(calibrationJson.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ControllerProfilesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('controllerDescriptor: $controllerDescriptor, ')
          ..write('consoleId: $consoleId, ')
          ..write('deadZone: $deadZone, ')
          ..write('triggerThreshold: $triggerThreshold, ')
          ..write('vibrationEnabled: $vibrationEnabled, ')
          ..write('isDefault: $isDefault, ')
          ..write('calibrationJson: $calibrationJson')
          ..write(')'))
        .toString();
  }
}

class $ControllerMappingsTable extends ControllerMappings
    with TableInfo<$ControllerMappingsTable, ControllerMappingRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ControllerMappingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _profileIdMeta = const VerificationMeta(
    'profileId',
  );
  @override
  late final GeneratedColumn<int> profileId = GeneratedColumn<int>(
    'profile_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES controller_profiles (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _actionMeta = const VerificationMeta('action');
  @override
  late final GeneratedColumn<String> action = GeneratedColumn<String>(
    'action',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _keyCodeMeta = const VerificationMeta(
    'keyCode',
  );
  @override
  late final GeneratedColumn<int> keyCode = GeneratedColumn<int>(
    'key_code',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _axisMeta = const VerificationMeta('axis');
  @override
  late final GeneratedColumn<int> axis = GeneratedColumn<int>(
    'axis',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _axisDirectionMeta = const VerificationMeta(
    'axisDirection',
  );
  @override
  late final GeneratedColumn<int> axisDirection = GeneratedColumn<int>(
    'axis_direction',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    profileId,
    action,
    keyCode,
    axis,
    axisDirection,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'controller_mappings';
  @override
  VerificationContext validateIntegrity(
    Insertable<ControllerMappingRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('profile_id')) {
      context.handle(
        _profileIdMeta,
        profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta),
      );
    } else if (isInserting) {
      context.missing(_profileIdMeta);
    }
    if (data.containsKey('action')) {
      context.handle(
        _actionMeta,
        action.isAcceptableOrUnknown(data['action']!, _actionMeta),
      );
    } else if (isInserting) {
      context.missing(_actionMeta);
    }
    if (data.containsKey('key_code')) {
      context.handle(
        _keyCodeMeta,
        keyCode.isAcceptableOrUnknown(data['key_code']!, _keyCodeMeta),
      );
    }
    if (data.containsKey('axis')) {
      context.handle(
        _axisMeta,
        axis.isAcceptableOrUnknown(data['axis']!, _axisMeta),
      );
    }
    if (data.containsKey('axis_direction')) {
      context.handle(
        _axisDirectionMeta,
        axisDirection.isAcceptableOrUnknown(
          data['axis_direction']!,
          _axisDirectionMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {profileId, action},
  ];
  @override
  ControllerMappingRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ControllerMappingRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      profileId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}profile_id'],
      )!,
      action: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}action'],
      )!,
      keyCode: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}key_code'],
      ),
      axis: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}axis'],
      ),
      axisDirection: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}axis_direction'],
      ),
    );
  }

  @override
  $ControllerMappingsTable createAlias(String alias) {
    return $ControllerMappingsTable(attachedDatabase, alias);
  }
}

class ControllerMappingRow extends DataClass
    implements Insertable<ControllerMappingRow> {
  final int id;
  final int profileId;

  /// Logical action, e.g. `A`, `B`, `START`, `DPAD_UP`, `LEFT_STICK_X`.
  final String action;
  final int? keyCode;
  final int? axis;
  final int? axisDirection;
  const ControllerMappingRow({
    required this.id,
    required this.profileId,
    required this.action,
    this.keyCode,
    this.axis,
    this.axisDirection,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['profile_id'] = Variable<int>(profileId);
    map['action'] = Variable<String>(action);
    if (!nullToAbsent || keyCode != null) {
      map['key_code'] = Variable<int>(keyCode);
    }
    if (!nullToAbsent || axis != null) {
      map['axis'] = Variable<int>(axis);
    }
    if (!nullToAbsent || axisDirection != null) {
      map['axis_direction'] = Variable<int>(axisDirection);
    }
    return map;
  }

  ControllerMappingsCompanion toCompanion(bool nullToAbsent) {
    return ControllerMappingsCompanion(
      id: Value(id),
      profileId: Value(profileId),
      action: Value(action),
      keyCode: keyCode == null && nullToAbsent
          ? const Value.absent()
          : Value(keyCode),
      axis: axis == null && nullToAbsent ? const Value.absent() : Value(axis),
      axisDirection: axisDirection == null && nullToAbsent
          ? const Value.absent()
          : Value(axisDirection),
    );
  }

  factory ControllerMappingRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ControllerMappingRow(
      id: serializer.fromJson<int>(json['id']),
      profileId: serializer.fromJson<int>(json['profileId']),
      action: serializer.fromJson<String>(json['action']),
      keyCode: serializer.fromJson<int?>(json['keyCode']),
      axis: serializer.fromJson<int?>(json['axis']),
      axisDirection: serializer.fromJson<int?>(json['axisDirection']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'profileId': serializer.toJson<int>(profileId),
      'action': serializer.toJson<String>(action),
      'keyCode': serializer.toJson<int?>(keyCode),
      'axis': serializer.toJson<int?>(axis),
      'axisDirection': serializer.toJson<int?>(axisDirection),
    };
  }

  ControllerMappingRow copyWith({
    int? id,
    int? profileId,
    String? action,
    Value<int?> keyCode = const Value.absent(),
    Value<int?> axis = const Value.absent(),
    Value<int?> axisDirection = const Value.absent(),
  }) => ControllerMappingRow(
    id: id ?? this.id,
    profileId: profileId ?? this.profileId,
    action: action ?? this.action,
    keyCode: keyCode.present ? keyCode.value : this.keyCode,
    axis: axis.present ? axis.value : this.axis,
    axisDirection: axisDirection.present
        ? axisDirection.value
        : this.axisDirection,
  );
  ControllerMappingRow copyWithCompanion(ControllerMappingsCompanion data) {
    return ControllerMappingRow(
      id: data.id.present ? data.id.value : this.id,
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      action: data.action.present ? data.action.value : this.action,
      keyCode: data.keyCode.present ? data.keyCode.value : this.keyCode,
      axis: data.axis.present ? data.axis.value : this.axis,
      axisDirection: data.axisDirection.present
          ? data.axisDirection.value
          : this.axisDirection,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ControllerMappingRow(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('action: $action, ')
          ..write('keyCode: $keyCode, ')
          ..write('axis: $axis, ')
          ..write('axisDirection: $axisDirection')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, profileId, action, keyCode, axis, axisDirection);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ControllerMappingRow &&
          other.id == this.id &&
          other.profileId == this.profileId &&
          other.action == this.action &&
          other.keyCode == this.keyCode &&
          other.axis == this.axis &&
          other.axisDirection == this.axisDirection);
}

class ControllerMappingsCompanion
    extends UpdateCompanion<ControllerMappingRow> {
  final Value<int> id;
  final Value<int> profileId;
  final Value<String> action;
  final Value<int?> keyCode;
  final Value<int?> axis;
  final Value<int?> axisDirection;
  const ControllerMappingsCompanion({
    this.id = const Value.absent(),
    this.profileId = const Value.absent(),
    this.action = const Value.absent(),
    this.keyCode = const Value.absent(),
    this.axis = const Value.absent(),
    this.axisDirection = const Value.absent(),
  });
  ControllerMappingsCompanion.insert({
    this.id = const Value.absent(),
    required int profileId,
    required String action,
    this.keyCode = const Value.absent(),
    this.axis = const Value.absent(),
    this.axisDirection = const Value.absent(),
  }) : profileId = Value(profileId),
       action = Value(action);
  static Insertable<ControllerMappingRow> custom({
    Expression<int>? id,
    Expression<int>? profileId,
    Expression<String>? action,
    Expression<int>? keyCode,
    Expression<int>? axis,
    Expression<int>? axisDirection,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (profileId != null) 'profile_id': profileId,
      if (action != null) 'action': action,
      if (keyCode != null) 'key_code': keyCode,
      if (axis != null) 'axis': axis,
      if (axisDirection != null) 'axis_direction': axisDirection,
    });
  }

  ControllerMappingsCompanion copyWith({
    Value<int>? id,
    Value<int>? profileId,
    Value<String>? action,
    Value<int?>? keyCode,
    Value<int?>? axis,
    Value<int?>? axisDirection,
  }) {
    return ControllerMappingsCompanion(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      action: action ?? this.action,
      keyCode: keyCode ?? this.keyCode,
      axis: axis ?? this.axis,
      axisDirection: axisDirection ?? this.axisDirection,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (profileId.present) {
      map['profile_id'] = Variable<int>(profileId.value);
    }
    if (action.present) {
      map['action'] = Variable<String>(action.value);
    }
    if (keyCode.present) {
      map['key_code'] = Variable<int>(keyCode.value);
    }
    if (axis.present) {
      map['axis'] = Variable<int>(axis.value);
    }
    if (axisDirection.present) {
      map['axis_direction'] = Variable<int>(axisDirection.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ControllerMappingsCompanion(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('action: $action, ')
          ..write('keyCode: $keyCode, ')
          ..write('axis: $axis, ')
          ..write('axisDirection: $axisDirection')
          ..write(')'))
        .toString();
  }
}

class $SourceConnectorsTable extends SourceConnectors
    with TableInfo<$SourceConnectorsTable, SourceConnectorRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SourceConnectorsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<String> version = GeneratedColumn<String>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, type, version, description];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'source_connectors';
  @override
  VerificationContext validateIntegrity(
    Insertable<SourceConnectorRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    } else if (isInserting) {
      context.missing(_versionMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SourceConnectorRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SourceConnectorRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}version'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
    );
  }

  @override
  $SourceConnectorsTable createAlias(String alias) {
    return $SourceConnectorsTable(attachedDatabase, alias);
  }
}

class SourceConnectorRow extends DataClass
    implements Insertable<SourceConnectorRow> {
  final String id;
  final String name;
  final String type;
  final String version;
  final String? description;
  const SourceConnectorRow({
    required this.id,
    required this.name,
    required this.type,
    required this.version,
    this.description,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['type'] = Variable<String>(type);
    map['version'] = Variable<String>(version);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    return map;
  }

  SourceConnectorsCompanion toCompanion(bool nullToAbsent) {
    return SourceConnectorsCompanion(
      id: Value(id),
      name: Value(name),
      type: Value(type),
      version: Value(version),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
    );
  }

  factory SourceConnectorRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SourceConnectorRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      type: serializer.fromJson<String>(json['type']),
      version: serializer.fromJson<String>(json['version']),
      description: serializer.fromJson<String?>(json['description']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'type': serializer.toJson<String>(type),
      'version': serializer.toJson<String>(version),
      'description': serializer.toJson<String?>(description),
    };
  }

  SourceConnectorRow copyWith({
    String? id,
    String? name,
    String? type,
    String? version,
    Value<String?> description = const Value.absent(),
  }) => SourceConnectorRow(
    id: id ?? this.id,
    name: name ?? this.name,
    type: type ?? this.type,
    version: version ?? this.version,
    description: description.present ? description.value : this.description,
  );
  SourceConnectorRow copyWithCompanion(SourceConnectorsCompanion data) {
    return SourceConnectorRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      type: data.type.present ? data.type.value : this.type,
      version: data.version.present ? data.version.value : this.version,
      description: data.description.present
          ? data.description.value
          : this.description,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SourceConnectorRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('version: $version, ')
          ..write('description: $description')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, type, version, description);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SourceConnectorRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.type == this.type &&
          other.version == this.version &&
          other.description == this.description);
}

class SourceConnectorsCompanion extends UpdateCompanion<SourceConnectorRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> type;
  final Value<String> version;
  final Value<String?> description;
  final Value<int> rowid;
  const SourceConnectorsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.type = const Value.absent(),
    this.version = const Value.absent(),
    this.description = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SourceConnectorsCompanion.insert({
    required String id,
    required String name,
    required String type,
    required String version,
    this.description = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       type = Value(type),
       version = Value(version);
  static Insertable<SourceConnectorRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? type,
    Expression<String>? version,
    Expression<String>? description,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (type != null) 'type': type,
      if (version != null) 'version': version,
      if (description != null) 'description': description,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SourceConnectorsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? type,
    Value<String>? version,
    Value<String?>? description,
    Value<int>? rowid,
  }) {
    return SourceConnectorsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      version: version ?? this.version,
      description: description ?? this.description,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (version.present) {
      map['version'] = Variable<String>(version.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SourceConnectorsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('version: $version, ')
          ..write('description: $description, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GameSourcesTable extends GameSources
    with TableInfo<$GameSourcesTable, GameSourceRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GameSourcesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
    'url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    check: () => type.isIn(const [
      'direct_url',
      'homebrew_repo',
      'public_domain_repo',
      'authorized_distribution',
      'personal_cloud',
      'user_hosting',
      'custom_http_api',
    ]),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _authTypeMeta = const VerificationMeta(
    'authType',
  );
  @override
  late final GeneratedColumn<String> authType = GeneratedColumn<String>(
    'auth_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('none'),
  );
  static const VerificationMeta _connectorIdMeta = const VerificationMeta(
    'connectorId',
  );
  @override
  late final GeneratedColumn<String> connectorId = GeneratedColumn<String>(
    'connector_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES source_connectors (id)',
    ),
  );
  static const VerificationMeta _connectionStatusMeta = const VerificationMeta(
    'connectionStatus',
  );
  @override
  late final GeneratedColumn<String> connectionStatus = GeneratedColumn<String>(
    'connection_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('unknown'),
  );
  static const VerificationMeta _lastCheckedAtMeta = const VerificationMeta(
    'lastCheckedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastCheckedAt =
      GeneratedColumn<DateTime>(
        'last_checked_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _enabledMeta = const VerificationMeta(
    'enabled',
  );
  @override
  late final GeneratedColumn<bool> enabled = GeneratedColumn<bool>(
    'enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    url,
    category,
    type,
    description,
    authType,
    connectorId,
    connectionStatus,
    lastCheckedAt,
    enabled,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'game_sources';
  @override
  VerificationContext validateIntegrity(
    Insertable<GameSourceRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('url')) {
      context.handle(
        _urlMeta,
        url.isAcceptableOrUnknown(data['url']!, _urlMeta),
      );
    } else if (isInserting) {
      context.missing(_urlMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('auth_type')) {
      context.handle(
        _authTypeMeta,
        authType.isAcceptableOrUnknown(data['auth_type']!, _authTypeMeta),
      );
    }
    if (data.containsKey('connector_id')) {
      context.handle(
        _connectorIdMeta,
        connectorId.isAcceptableOrUnknown(
          data['connector_id']!,
          _connectorIdMeta,
        ),
      );
    }
    if (data.containsKey('connection_status')) {
      context.handle(
        _connectionStatusMeta,
        connectionStatus.isAcceptableOrUnknown(
          data['connection_status']!,
          _connectionStatusMeta,
        ),
      );
    }
    if (data.containsKey('last_checked_at')) {
      context.handle(
        _lastCheckedAtMeta,
        lastCheckedAt.isAcceptableOrUnknown(
          data['last_checked_at']!,
          _lastCheckedAtMeta,
        ),
      );
    }
    if (data.containsKey('enabled')) {
      context.handle(
        _enabledMeta,
        enabled.isAcceptableOrUnknown(data['enabled']!, _enabledMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GameSourceRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GameSourceRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      url: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}url'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      ),
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      authType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}auth_type'],
      )!,
      connectorId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}connector_id'],
      ),
      connectionStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}connection_status'],
      )!,
      lastCheckedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_checked_at'],
      ),
      enabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}enabled'],
      )!,
    );
  }

  @override
  $GameSourcesTable createAlias(String alias) {
    return $GameSourcesTable(attachedDatabase, alias);
  }
}

class GameSourceRow extends DataClass implements Insertable<GameSourceRow> {
  final int id;
  final String name;
  final String url;
  final String? category;
  final String type;
  final String? description;
  final String authType;
  final String? connectorId;
  final String connectionStatus;
  final DateTime? lastCheckedAt;
  final bool enabled;
  const GameSourceRow({
    required this.id,
    required this.name,
    required this.url,
    this.category,
    required this.type,
    this.description,
    required this.authType,
    this.connectorId,
    required this.connectionStatus,
    this.lastCheckedAt,
    required this.enabled,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['url'] = Variable<String>(url);
    if (!nullToAbsent || category != null) {
      map['category'] = Variable<String>(category);
    }
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['auth_type'] = Variable<String>(authType);
    if (!nullToAbsent || connectorId != null) {
      map['connector_id'] = Variable<String>(connectorId);
    }
    map['connection_status'] = Variable<String>(connectionStatus);
    if (!nullToAbsent || lastCheckedAt != null) {
      map['last_checked_at'] = Variable<DateTime>(lastCheckedAt);
    }
    map['enabled'] = Variable<bool>(enabled);
    return map;
  }

  GameSourcesCompanion toCompanion(bool nullToAbsent) {
    return GameSourcesCompanion(
      id: Value(id),
      name: Value(name),
      url: Value(url),
      category: category == null && nullToAbsent
          ? const Value.absent()
          : Value(category),
      type: Value(type),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      authType: Value(authType),
      connectorId: connectorId == null && nullToAbsent
          ? const Value.absent()
          : Value(connectorId),
      connectionStatus: Value(connectionStatus),
      lastCheckedAt: lastCheckedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastCheckedAt),
      enabled: Value(enabled),
    );
  }

  factory GameSourceRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GameSourceRow(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      url: serializer.fromJson<String>(json['url']),
      category: serializer.fromJson<String?>(json['category']),
      type: serializer.fromJson<String>(json['type']),
      description: serializer.fromJson<String?>(json['description']),
      authType: serializer.fromJson<String>(json['authType']),
      connectorId: serializer.fromJson<String?>(json['connectorId']),
      connectionStatus: serializer.fromJson<String>(json['connectionStatus']),
      lastCheckedAt: serializer.fromJson<DateTime?>(json['lastCheckedAt']),
      enabled: serializer.fromJson<bool>(json['enabled']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'url': serializer.toJson<String>(url),
      'category': serializer.toJson<String?>(category),
      'type': serializer.toJson<String>(type),
      'description': serializer.toJson<String?>(description),
      'authType': serializer.toJson<String>(authType),
      'connectorId': serializer.toJson<String?>(connectorId),
      'connectionStatus': serializer.toJson<String>(connectionStatus),
      'lastCheckedAt': serializer.toJson<DateTime?>(lastCheckedAt),
      'enabled': serializer.toJson<bool>(enabled),
    };
  }

  GameSourceRow copyWith({
    int? id,
    String? name,
    String? url,
    Value<String?> category = const Value.absent(),
    String? type,
    Value<String?> description = const Value.absent(),
    String? authType,
    Value<String?> connectorId = const Value.absent(),
    String? connectionStatus,
    Value<DateTime?> lastCheckedAt = const Value.absent(),
    bool? enabled,
  }) => GameSourceRow(
    id: id ?? this.id,
    name: name ?? this.name,
    url: url ?? this.url,
    category: category.present ? category.value : this.category,
    type: type ?? this.type,
    description: description.present ? description.value : this.description,
    authType: authType ?? this.authType,
    connectorId: connectorId.present ? connectorId.value : this.connectorId,
    connectionStatus: connectionStatus ?? this.connectionStatus,
    lastCheckedAt: lastCheckedAt.present
        ? lastCheckedAt.value
        : this.lastCheckedAt,
    enabled: enabled ?? this.enabled,
  );
  GameSourceRow copyWithCompanion(GameSourcesCompanion data) {
    return GameSourceRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      url: data.url.present ? data.url.value : this.url,
      category: data.category.present ? data.category.value : this.category,
      type: data.type.present ? data.type.value : this.type,
      description: data.description.present
          ? data.description.value
          : this.description,
      authType: data.authType.present ? data.authType.value : this.authType,
      connectorId: data.connectorId.present
          ? data.connectorId.value
          : this.connectorId,
      connectionStatus: data.connectionStatus.present
          ? data.connectionStatus.value
          : this.connectionStatus,
      lastCheckedAt: data.lastCheckedAt.present
          ? data.lastCheckedAt.value
          : this.lastCheckedAt,
      enabled: data.enabled.present ? data.enabled.value : this.enabled,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GameSourceRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('url: $url, ')
          ..write('category: $category, ')
          ..write('type: $type, ')
          ..write('description: $description, ')
          ..write('authType: $authType, ')
          ..write('connectorId: $connectorId, ')
          ..write('connectionStatus: $connectionStatus, ')
          ..write('lastCheckedAt: $lastCheckedAt, ')
          ..write('enabled: $enabled')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    url,
    category,
    type,
    description,
    authType,
    connectorId,
    connectionStatus,
    lastCheckedAt,
    enabled,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GameSourceRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.url == this.url &&
          other.category == this.category &&
          other.type == this.type &&
          other.description == this.description &&
          other.authType == this.authType &&
          other.connectorId == this.connectorId &&
          other.connectionStatus == this.connectionStatus &&
          other.lastCheckedAt == this.lastCheckedAt &&
          other.enabled == this.enabled);
}

class GameSourcesCompanion extends UpdateCompanion<GameSourceRow> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> url;
  final Value<String?> category;
  final Value<String> type;
  final Value<String?> description;
  final Value<String> authType;
  final Value<String?> connectorId;
  final Value<String> connectionStatus;
  final Value<DateTime?> lastCheckedAt;
  final Value<bool> enabled;
  const GameSourcesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.url = const Value.absent(),
    this.category = const Value.absent(),
    this.type = const Value.absent(),
    this.description = const Value.absent(),
    this.authType = const Value.absent(),
    this.connectorId = const Value.absent(),
    this.connectionStatus = const Value.absent(),
    this.lastCheckedAt = const Value.absent(),
    this.enabled = const Value.absent(),
  });
  GameSourcesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String url,
    this.category = const Value.absent(),
    required String type,
    this.description = const Value.absent(),
    this.authType = const Value.absent(),
    this.connectorId = const Value.absent(),
    this.connectionStatus = const Value.absent(),
    this.lastCheckedAt = const Value.absent(),
    this.enabled = const Value.absent(),
  }) : name = Value(name),
       url = Value(url),
       type = Value(type);
  static Insertable<GameSourceRow> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? url,
    Expression<String>? category,
    Expression<String>? type,
    Expression<String>? description,
    Expression<String>? authType,
    Expression<String>? connectorId,
    Expression<String>? connectionStatus,
    Expression<DateTime>? lastCheckedAt,
    Expression<bool>? enabled,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (url != null) 'url': url,
      if (category != null) 'category': category,
      if (type != null) 'type': type,
      if (description != null) 'description': description,
      if (authType != null) 'auth_type': authType,
      if (connectorId != null) 'connector_id': connectorId,
      if (connectionStatus != null) 'connection_status': connectionStatus,
      if (lastCheckedAt != null) 'last_checked_at': lastCheckedAt,
      if (enabled != null) 'enabled': enabled,
    });
  }

  GameSourcesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? url,
    Value<String?>? category,
    Value<String>? type,
    Value<String?>? description,
    Value<String>? authType,
    Value<String?>? connectorId,
    Value<String>? connectionStatus,
    Value<DateTime?>? lastCheckedAt,
    Value<bool>? enabled,
  }) {
    return GameSourcesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      url: url ?? this.url,
      category: category ?? this.category,
      type: type ?? this.type,
      description: description ?? this.description,
      authType: authType ?? this.authType,
      connectorId: connectorId ?? this.connectorId,
      connectionStatus: connectionStatus ?? this.connectionStatus,
      lastCheckedAt: lastCheckedAt ?? this.lastCheckedAt,
      enabled: enabled ?? this.enabled,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (authType.present) {
      map['auth_type'] = Variable<String>(authType.value);
    }
    if (connectorId.present) {
      map['connector_id'] = Variable<String>(connectorId.value);
    }
    if (connectionStatus.present) {
      map['connection_status'] = Variable<String>(connectionStatus.value);
    }
    if (lastCheckedAt.present) {
      map['last_checked_at'] = Variable<DateTime>(lastCheckedAt.value);
    }
    if (enabled.present) {
      map['enabled'] = Variable<bool>(enabled.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GameSourcesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('url: $url, ')
          ..write('category: $category, ')
          ..write('type: $type, ')
          ..write('description: $description, ')
          ..write('authType: $authType, ')
          ..write('connectorId: $connectorId, ')
          ..write('connectionStatus: $connectionStatus, ')
          ..write('lastCheckedAt: $lastCheckedAt, ')
          ..write('enabled: $enabled')
          ..write(')'))
        .toString();
  }
}

class $DownloadQueueTable extends DownloadQueue
    with TableInfo<$DownloadQueueTable, DownloadQueueRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DownloadQueueTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _sourceIdMeta = const VerificationMeta(
    'sourceId',
  );
  @override
  late final GeneratedColumn<int> sourceId = GeneratedColumn<int>(
    'source_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES game_sources (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
    'url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _destinationMeta = const VerificationMeta(
    'destination',
  );
  @override
  late final GeneratedColumn<String> destination = GeneratedColumn<String>(
    'destination',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _totalBytesMeta = const VerificationMeta(
    'totalBytes',
  );
  @override
  late final GeneratedColumn<int> totalBytes = GeneratedColumn<int>(
    'total_bytes',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _downloadedBytesMeta = const VerificationMeta(
    'downloadedBytes',
  );
  @override
  late final GeneratedColumn<int> downloadedBytes = GeneratedColumn<int>(
    'downloaded_bytes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    check: () => status.isIn(const [
      'queued',
      'downloading',
      'paused',
      'completed',
      'failed',
      'cancelled',
    ]),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _expectedHashMeta = const VerificationMeta(
    'expectedHash',
  );
  @override
  late final GeneratedColumn<String> expectedHash = GeneratedColumn<String>(
    'expected_hash',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _hashAlgorithmMeta = const VerificationMeta(
    'hashAlgorithm',
  );
  @override
  late final GeneratedColumn<String> hashAlgorithm = GeneratedColumn<String>(
    'hash_algorithm',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _errorMessageMeta = const VerificationMeta(
    'errorMessage',
  );
  @override
  late final GeneratedColumn<String> errorMessage = GeneratedColumn<String>(
    'error_message',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _retriesMeta = const VerificationMeta(
    'retries',
  );
  @override
  late final GeneratedColumn<int> retries = GeneratedColumn<int>(
    'retries',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _filePathMeta = const VerificationMeta(
    'filePath',
  );
  @override
  late final GeneratedColumn<String> filePath = GeneratedColumn<String>(
    'file_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _consoleIdMeta = const VerificationMeta(
    'consoleId',
  );
  @override
  late final GeneratedColumn<String> consoleId = GeneratedColumn<String>(
    'console_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _catalogJsonMeta = const VerificationMeta(
    'catalogJson',
  );
  @override
  late final GeneratedColumn<String> catalogJson = GeneratedColumn<String>(
    'catalog_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sha256Meta = const VerificationMeta('sha256');
  @override
  late final GeneratedColumn<String> sha256 = GeneratedColumn<String>(
    'sha256',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _importedGameIdMeta = const VerificationMeta(
    'importedGameId',
  );
  @override
  late final GeneratedColumn<int> importedGameId = GeneratedColumn<int>(
    'imported_game_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sourceId,
    name,
    url,
    destination,
    totalBytes,
    downloadedBytes,
    status,
    expectedHash,
    hashAlgorithm,
    errorMessage,
    retries,
    createdAt,
    updatedAt,
    filePath,
    consoleId,
    catalogJson,
    sha256,
    importedGameId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'download_queue';
  @override
  VerificationContext validateIntegrity(
    Insertable<DownloadQueueRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('source_id')) {
      context.handle(
        _sourceIdMeta,
        sourceId.isAcceptableOrUnknown(data['source_id']!, _sourceIdMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('url')) {
      context.handle(
        _urlMeta,
        url.isAcceptableOrUnknown(data['url']!, _urlMeta),
      );
    } else if (isInserting) {
      context.missing(_urlMeta);
    }
    if (data.containsKey('destination')) {
      context.handle(
        _destinationMeta,
        destination.isAcceptableOrUnknown(
          data['destination']!,
          _destinationMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_destinationMeta);
    }
    if (data.containsKey('total_bytes')) {
      context.handle(
        _totalBytesMeta,
        totalBytes.isAcceptableOrUnknown(data['total_bytes']!, _totalBytesMeta),
      );
    }
    if (data.containsKey('downloaded_bytes')) {
      context.handle(
        _downloadedBytesMeta,
        downloadedBytes.isAcceptableOrUnknown(
          data['downloaded_bytes']!,
          _downloadedBytesMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('expected_hash')) {
      context.handle(
        _expectedHashMeta,
        expectedHash.isAcceptableOrUnknown(
          data['expected_hash']!,
          _expectedHashMeta,
        ),
      );
    }
    if (data.containsKey('hash_algorithm')) {
      context.handle(
        _hashAlgorithmMeta,
        hashAlgorithm.isAcceptableOrUnknown(
          data['hash_algorithm']!,
          _hashAlgorithmMeta,
        ),
      );
    }
    if (data.containsKey('error_message')) {
      context.handle(
        _errorMessageMeta,
        errorMessage.isAcceptableOrUnknown(
          data['error_message']!,
          _errorMessageMeta,
        ),
      );
    }
    if (data.containsKey('retries')) {
      context.handle(
        _retriesMeta,
        retries.isAcceptableOrUnknown(data['retries']!, _retriesMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('file_path')) {
      context.handle(
        _filePathMeta,
        filePath.isAcceptableOrUnknown(data['file_path']!, _filePathMeta),
      );
    }
    if (data.containsKey('console_id')) {
      context.handle(
        _consoleIdMeta,
        consoleId.isAcceptableOrUnknown(data['console_id']!, _consoleIdMeta),
      );
    }
    if (data.containsKey('catalog_json')) {
      context.handle(
        _catalogJsonMeta,
        catalogJson.isAcceptableOrUnknown(
          data['catalog_json']!,
          _catalogJsonMeta,
        ),
      );
    }
    if (data.containsKey('sha256')) {
      context.handle(
        _sha256Meta,
        sha256.isAcceptableOrUnknown(data['sha256']!, _sha256Meta),
      );
    }
    if (data.containsKey('imported_game_id')) {
      context.handle(
        _importedGameIdMeta,
        importedGameId.isAcceptableOrUnknown(
          data['imported_game_id']!,
          _importedGameIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DownloadQueueRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DownloadQueueRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      sourceId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}source_id'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      url: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}url'],
      )!,
      destination: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}destination'],
      )!,
      totalBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_bytes'],
      ),
      downloadedBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}downloaded_bytes'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      expectedHash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}expected_hash'],
      ),
      hashAlgorithm: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hash_algorithm'],
      ),
      errorMessage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}error_message'],
      ),
      retries: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}retries'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      filePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_path'],
      ),
      consoleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}console_id'],
      ),
      catalogJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}catalog_json'],
      ),
      sha256: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sha256'],
      ),
      importedGameId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}imported_game_id'],
      ),
    );
  }

  @override
  $DownloadQueueTable createAlias(String alias) {
    return $DownloadQueueTable(attachedDatabase, alias);
  }
}

class DownloadQueueRow extends DataClass
    implements Insertable<DownloadQueueRow> {
  final int id;
  final int? sourceId;
  final String name;
  final String url;
  final String destination;
  final int? totalBytes;
  final int downloadedBytes;
  final String status;
  final String? expectedHash;
  final String? hashAlgorithm;
  final String? errorMessage;
  final int retries;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Final file path once the server named the file (`<path>.part` while
  /// downloading). [destination] is the target directory.
  final String? filePath;

  /// Console to import as (from a catalogue entry or chosen by the user).
  final String? consoleId;

  /// Catalogue entry JSON (title, licence, description, cover) for metadata.
  final String? catalogJson;

  /// SHA-256 computed while downloading.
  final String? sha256;

  /// Game id once imported into the library.
  final int? importedGameId;
  const DownloadQueueRow({
    required this.id,
    this.sourceId,
    required this.name,
    required this.url,
    required this.destination,
    this.totalBytes,
    required this.downloadedBytes,
    required this.status,
    this.expectedHash,
    this.hashAlgorithm,
    this.errorMessage,
    required this.retries,
    required this.createdAt,
    required this.updatedAt,
    this.filePath,
    this.consoleId,
    this.catalogJson,
    this.sha256,
    this.importedGameId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || sourceId != null) {
      map['source_id'] = Variable<int>(sourceId);
    }
    map['name'] = Variable<String>(name);
    map['url'] = Variable<String>(url);
    map['destination'] = Variable<String>(destination);
    if (!nullToAbsent || totalBytes != null) {
      map['total_bytes'] = Variable<int>(totalBytes);
    }
    map['downloaded_bytes'] = Variable<int>(downloadedBytes);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || expectedHash != null) {
      map['expected_hash'] = Variable<String>(expectedHash);
    }
    if (!nullToAbsent || hashAlgorithm != null) {
      map['hash_algorithm'] = Variable<String>(hashAlgorithm);
    }
    if (!nullToAbsent || errorMessage != null) {
      map['error_message'] = Variable<String>(errorMessage);
    }
    map['retries'] = Variable<int>(retries);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || filePath != null) {
      map['file_path'] = Variable<String>(filePath);
    }
    if (!nullToAbsent || consoleId != null) {
      map['console_id'] = Variable<String>(consoleId);
    }
    if (!nullToAbsent || catalogJson != null) {
      map['catalog_json'] = Variable<String>(catalogJson);
    }
    if (!nullToAbsent || sha256 != null) {
      map['sha256'] = Variable<String>(sha256);
    }
    if (!nullToAbsent || importedGameId != null) {
      map['imported_game_id'] = Variable<int>(importedGameId);
    }
    return map;
  }

  DownloadQueueCompanion toCompanion(bool nullToAbsent) {
    return DownloadQueueCompanion(
      id: Value(id),
      sourceId: sourceId == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceId),
      name: Value(name),
      url: Value(url),
      destination: Value(destination),
      totalBytes: totalBytes == null && nullToAbsent
          ? const Value.absent()
          : Value(totalBytes),
      downloadedBytes: Value(downloadedBytes),
      status: Value(status),
      expectedHash: expectedHash == null && nullToAbsent
          ? const Value.absent()
          : Value(expectedHash),
      hashAlgorithm: hashAlgorithm == null && nullToAbsent
          ? const Value.absent()
          : Value(hashAlgorithm),
      errorMessage: errorMessage == null && nullToAbsent
          ? const Value.absent()
          : Value(errorMessage),
      retries: Value(retries),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      filePath: filePath == null && nullToAbsent
          ? const Value.absent()
          : Value(filePath),
      consoleId: consoleId == null && nullToAbsent
          ? const Value.absent()
          : Value(consoleId),
      catalogJson: catalogJson == null && nullToAbsent
          ? const Value.absent()
          : Value(catalogJson),
      sha256: sha256 == null && nullToAbsent
          ? const Value.absent()
          : Value(sha256),
      importedGameId: importedGameId == null && nullToAbsent
          ? const Value.absent()
          : Value(importedGameId),
    );
  }

  factory DownloadQueueRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DownloadQueueRow(
      id: serializer.fromJson<int>(json['id']),
      sourceId: serializer.fromJson<int?>(json['sourceId']),
      name: serializer.fromJson<String>(json['name']),
      url: serializer.fromJson<String>(json['url']),
      destination: serializer.fromJson<String>(json['destination']),
      totalBytes: serializer.fromJson<int?>(json['totalBytes']),
      downloadedBytes: serializer.fromJson<int>(json['downloadedBytes']),
      status: serializer.fromJson<String>(json['status']),
      expectedHash: serializer.fromJson<String?>(json['expectedHash']),
      hashAlgorithm: serializer.fromJson<String?>(json['hashAlgorithm']),
      errorMessage: serializer.fromJson<String?>(json['errorMessage']),
      retries: serializer.fromJson<int>(json['retries']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      filePath: serializer.fromJson<String?>(json['filePath']),
      consoleId: serializer.fromJson<String?>(json['consoleId']),
      catalogJson: serializer.fromJson<String?>(json['catalogJson']),
      sha256: serializer.fromJson<String?>(json['sha256']),
      importedGameId: serializer.fromJson<int?>(json['importedGameId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sourceId': serializer.toJson<int?>(sourceId),
      'name': serializer.toJson<String>(name),
      'url': serializer.toJson<String>(url),
      'destination': serializer.toJson<String>(destination),
      'totalBytes': serializer.toJson<int?>(totalBytes),
      'downloadedBytes': serializer.toJson<int>(downloadedBytes),
      'status': serializer.toJson<String>(status),
      'expectedHash': serializer.toJson<String?>(expectedHash),
      'hashAlgorithm': serializer.toJson<String?>(hashAlgorithm),
      'errorMessage': serializer.toJson<String?>(errorMessage),
      'retries': serializer.toJson<int>(retries),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'filePath': serializer.toJson<String?>(filePath),
      'consoleId': serializer.toJson<String?>(consoleId),
      'catalogJson': serializer.toJson<String?>(catalogJson),
      'sha256': serializer.toJson<String?>(sha256),
      'importedGameId': serializer.toJson<int?>(importedGameId),
    };
  }

  DownloadQueueRow copyWith({
    int? id,
    Value<int?> sourceId = const Value.absent(),
    String? name,
    String? url,
    String? destination,
    Value<int?> totalBytes = const Value.absent(),
    int? downloadedBytes,
    String? status,
    Value<String?> expectedHash = const Value.absent(),
    Value<String?> hashAlgorithm = const Value.absent(),
    Value<String?> errorMessage = const Value.absent(),
    int? retries,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<String?> filePath = const Value.absent(),
    Value<String?> consoleId = const Value.absent(),
    Value<String?> catalogJson = const Value.absent(),
    Value<String?> sha256 = const Value.absent(),
    Value<int?> importedGameId = const Value.absent(),
  }) => DownloadQueueRow(
    id: id ?? this.id,
    sourceId: sourceId.present ? sourceId.value : this.sourceId,
    name: name ?? this.name,
    url: url ?? this.url,
    destination: destination ?? this.destination,
    totalBytes: totalBytes.present ? totalBytes.value : this.totalBytes,
    downloadedBytes: downloadedBytes ?? this.downloadedBytes,
    status: status ?? this.status,
    expectedHash: expectedHash.present ? expectedHash.value : this.expectedHash,
    hashAlgorithm: hashAlgorithm.present
        ? hashAlgorithm.value
        : this.hashAlgorithm,
    errorMessage: errorMessage.present ? errorMessage.value : this.errorMessage,
    retries: retries ?? this.retries,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    filePath: filePath.present ? filePath.value : this.filePath,
    consoleId: consoleId.present ? consoleId.value : this.consoleId,
    catalogJson: catalogJson.present ? catalogJson.value : this.catalogJson,
    sha256: sha256.present ? sha256.value : this.sha256,
    importedGameId: importedGameId.present
        ? importedGameId.value
        : this.importedGameId,
  );
  DownloadQueueRow copyWithCompanion(DownloadQueueCompanion data) {
    return DownloadQueueRow(
      id: data.id.present ? data.id.value : this.id,
      sourceId: data.sourceId.present ? data.sourceId.value : this.sourceId,
      name: data.name.present ? data.name.value : this.name,
      url: data.url.present ? data.url.value : this.url,
      destination: data.destination.present
          ? data.destination.value
          : this.destination,
      totalBytes: data.totalBytes.present
          ? data.totalBytes.value
          : this.totalBytes,
      downloadedBytes: data.downloadedBytes.present
          ? data.downloadedBytes.value
          : this.downloadedBytes,
      status: data.status.present ? data.status.value : this.status,
      expectedHash: data.expectedHash.present
          ? data.expectedHash.value
          : this.expectedHash,
      hashAlgorithm: data.hashAlgorithm.present
          ? data.hashAlgorithm.value
          : this.hashAlgorithm,
      errorMessage: data.errorMessage.present
          ? data.errorMessage.value
          : this.errorMessage,
      retries: data.retries.present ? data.retries.value : this.retries,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      filePath: data.filePath.present ? data.filePath.value : this.filePath,
      consoleId: data.consoleId.present ? data.consoleId.value : this.consoleId,
      catalogJson: data.catalogJson.present
          ? data.catalogJson.value
          : this.catalogJson,
      sha256: data.sha256.present ? data.sha256.value : this.sha256,
      importedGameId: data.importedGameId.present
          ? data.importedGameId.value
          : this.importedGameId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DownloadQueueRow(')
          ..write('id: $id, ')
          ..write('sourceId: $sourceId, ')
          ..write('name: $name, ')
          ..write('url: $url, ')
          ..write('destination: $destination, ')
          ..write('totalBytes: $totalBytes, ')
          ..write('downloadedBytes: $downloadedBytes, ')
          ..write('status: $status, ')
          ..write('expectedHash: $expectedHash, ')
          ..write('hashAlgorithm: $hashAlgorithm, ')
          ..write('errorMessage: $errorMessage, ')
          ..write('retries: $retries, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('filePath: $filePath, ')
          ..write('consoleId: $consoleId, ')
          ..write('catalogJson: $catalogJson, ')
          ..write('sha256: $sha256, ')
          ..write('importedGameId: $importedGameId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sourceId,
    name,
    url,
    destination,
    totalBytes,
    downloadedBytes,
    status,
    expectedHash,
    hashAlgorithm,
    errorMessage,
    retries,
    createdAt,
    updatedAt,
    filePath,
    consoleId,
    catalogJson,
    sha256,
    importedGameId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DownloadQueueRow &&
          other.id == this.id &&
          other.sourceId == this.sourceId &&
          other.name == this.name &&
          other.url == this.url &&
          other.destination == this.destination &&
          other.totalBytes == this.totalBytes &&
          other.downloadedBytes == this.downloadedBytes &&
          other.status == this.status &&
          other.expectedHash == this.expectedHash &&
          other.hashAlgorithm == this.hashAlgorithm &&
          other.errorMessage == this.errorMessage &&
          other.retries == this.retries &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.filePath == this.filePath &&
          other.consoleId == this.consoleId &&
          other.catalogJson == this.catalogJson &&
          other.sha256 == this.sha256 &&
          other.importedGameId == this.importedGameId);
}

class DownloadQueueCompanion extends UpdateCompanion<DownloadQueueRow> {
  final Value<int> id;
  final Value<int?> sourceId;
  final Value<String> name;
  final Value<String> url;
  final Value<String> destination;
  final Value<int?> totalBytes;
  final Value<int> downloadedBytes;
  final Value<String> status;
  final Value<String?> expectedHash;
  final Value<String?> hashAlgorithm;
  final Value<String?> errorMessage;
  final Value<int> retries;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String?> filePath;
  final Value<String?> consoleId;
  final Value<String?> catalogJson;
  final Value<String?> sha256;
  final Value<int?> importedGameId;
  const DownloadQueueCompanion({
    this.id = const Value.absent(),
    this.sourceId = const Value.absent(),
    this.name = const Value.absent(),
    this.url = const Value.absent(),
    this.destination = const Value.absent(),
    this.totalBytes = const Value.absent(),
    this.downloadedBytes = const Value.absent(),
    this.status = const Value.absent(),
    this.expectedHash = const Value.absent(),
    this.hashAlgorithm = const Value.absent(),
    this.errorMessage = const Value.absent(),
    this.retries = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.filePath = const Value.absent(),
    this.consoleId = const Value.absent(),
    this.catalogJson = const Value.absent(),
    this.sha256 = const Value.absent(),
    this.importedGameId = const Value.absent(),
  });
  DownloadQueueCompanion.insert({
    this.id = const Value.absent(),
    this.sourceId = const Value.absent(),
    required String name,
    required String url,
    required String destination,
    this.totalBytes = const Value.absent(),
    this.downloadedBytes = const Value.absent(),
    required String status,
    this.expectedHash = const Value.absent(),
    this.hashAlgorithm = const Value.absent(),
    this.errorMessage = const Value.absent(),
    this.retries = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.filePath = const Value.absent(),
    this.consoleId = const Value.absent(),
    this.catalogJson = const Value.absent(),
    this.sha256 = const Value.absent(),
    this.importedGameId = const Value.absent(),
  }) : name = Value(name),
       url = Value(url),
       destination = Value(destination),
       status = Value(status),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<DownloadQueueRow> custom({
    Expression<int>? id,
    Expression<int>? sourceId,
    Expression<String>? name,
    Expression<String>? url,
    Expression<String>? destination,
    Expression<int>? totalBytes,
    Expression<int>? downloadedBytes,
    Expression<String>? status,
    Expression<String>? expectedHash,
    Expression<String>? hashAlgorithm,
    Expression<String>? errorMessage,
    Expression<int>? retries,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? filePath,
    Expression<String>? consoleId,
    Expression<String>? catalogJson,
    Expression<String>? sha256,
    Expression<int>? importedGameId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sourceId != null) 'source_id': sourceId,
      if (name != null) 'name': name,
      if (url != null) 'url': url,
      if (destination != null) 'destination': destination,
      if (totalBytes != null) 'total_bytes': totalBytes,
      if (downloadedBytes != null) 'downloaded_bytes': downloadedBytes,
      if (status != null) 'status': status,
      if (expectedHash != null) 'expected_hash': expectedHash,
      if (hashAlgorithm != null) 'hash_algorithm': hashAlgorithm,
      if (errorMessage != null) 'error_message': errorMessage,
      if (retries != null) 'retries': retries,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (filePath != null) 'file_path': filePath,
      if (consoleId != null) 'console_id': consoleId,
      if (catalogJson != null) 'catalog_json': catalogJson,
      if (sha256 != null) 'sha256': sha256,
      if (importedGameId != null) 'imported_game_id': importedGameId,
    });
  }

  DownloadQueueCompanion copyWith({
    Value<int>? id,
    Value<int?>? sourceId,
    Value<String>? name,
    Value<String>? url,
    Value<String>? destination,
    Value<int?>? totalBytes,
    Value<int>? downloadedBytes,
    Value<String>? status,
    Value<String?>? expectedHash,
    Value<String?>? hashAlgorithm,
    Value<String?>? errorMessage,
    Value<int>? retries,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<String?>? filePath,
    Value<String?>? consoleId,
    Value<String?>? catalogJson,
    Value<String?>? sha256,
    Value<int?>? importedGameId,
  }) {
    return DownloadQueueCompanion(
      id: id ?? this.id,
      sourceId: sourceId ?? this.sourceId,
      name: name ?? this.name,
      url: url ?? this.url,
      destination: destination ?? this.destination,
      totalBytes: totalBytes ?? this.totalBytes,
      downloadedBytes: downloadedBytes ?? this.downloadedBytes,
      status: status ?? this.status,
      expectedHash: expectedHash ?? this.expectedHash,
      hashAlgorithm: hashAlgorithm ?? this.hashAlgorithm,
      errorMessage: errorMessage ?? this.errorMessage,
      retries: retries ?? this.retries,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      filePath: filePath ?? this.filePath,
      consoleId: consoleId ?? this.consoleId,
      catalogJson: catalogJson ?? this.catalogJson,
      sha256: sha256 ?? this.sha256,
      importedGameId: importedGameId ?? this.importedGameId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sourceId.present) {
      map['source_id'] = Variable<int>(sourceId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (destination.present) {
      map['destination'] = Variable<String>(destination.value);
    }
    if (totalBytes.present) {
      map['total_bytes'] = Variable<int>(totalBytes.value);
    }
    if (downloadedBytes.present) {
      map['downloaded_bytes'] = Variable<int>(downloadedBytes.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (expectedHash.present) {
      map['expected_hash'] = Variable<String>(expectedHash.value);
    }
    if (hashAlgorithm.present) {
      map['hash_algorithm'] = Variable<String>(hashAlgorithm.value);
    }
    if (errorMessage.present) {
      map['error_message'] = Variable<String>(errorMessage.value);
    }
    if (retries.present) {
      map['retries'] = Variable<int>(retries.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (filePath.present) {
      map['file_path'] = Variable<String>(filePath.value);
    }
    if (consoleId.present) {
      map['console_id'] = Variable<String>(consoleId.value);
    }
    if (catalogJson.present) {
      map['catalog_json'] = Variable<String>(catalogJson.value);
    }
    if (sha256.present) {
      map['sha256'] = Variable<String>(sha256.value);
    }
    if (importedGameId.present) {
      map['imported_game_id'] = Variable<int>(importedGameId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DownloadQueueCompanion(')
          ..write('id: $id, ')
          ..write('sourceId: $sourceId, ')
          ..write('name: $name, ')
          ..write('url: $url, ')
          ..write('destination: $destination, ')
          ..write('totalBytes: $totalBytes, ')
          ..write('downloadedBytes: $downloadedBytes, ')
          ..write('status: $status, ')
          ..write('expectedHash: $expectedHash, ')
          ..write('hashAlgorithm: $hashAlgorithm, ')
          ..write('errorMessage: $errorMessage, ')
          ..write('retries: $retries, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('filePath: $filePath, ')
          ..write('consoleId: $consoleId, ')
          ..write('catalogJson: $catalogJson, ')
          ..write('sha256: $sha256, ')
          ..write('importedGameId: $importedGameId')
          ..write(')'))
        .toString();
  }
}

class $DownloadHistoryTable extends DownloadHistory
    with TableInfo<$DownloadHistoryTable, DownloadHistoryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DownloadHistoryTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _sourceIdMeta = const VerificationMeta(
    'sourceId',
  );
  @override
  late final GeneratedColumn<int> sourceId = GeneratedColumn<int>(
    'source_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES game_sources (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
    'url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _destinationMeta = const VerificationMeta(
    'destination',
  );
  @override
  late final GeneratedColumn<String> destination = GeneratedColumn<String>(
    'destination',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sizeBytesMeta = const VerificationMeta(
    'sizeBytes',
  );
  @override
  late final GeneratedColumn<int> sizeBytes = GeneratedColumn<int>(
    'size_bytes',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sha256Meta = const VerificationMeta('sha256');
  @override
  late final GeneratedColumn<String> sha256 = GeneratedColumn<String>(
    'sha256',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _errorMessageMeta = const VerificationMeta(
    'errorMessage',
  );
  @override
  late final GeneratedColumn<String> errorMessage = GeneratedColumn<String>(
    'error_message',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _finishedAtMeta = const VerificationMeta(
    'finishedAt',
  );
  @override
  late final GeneratedColumn<DateTime> finishedAt = GeneratedColumn<DateTime>(
    'finished_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sourceId,
    name,
    url,
    destination,
    sizeBytes,
    sha256,
    status,
    errorMessage,
    finishedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'download_history';
  @override
  VerificationContext validateIntegrity(
    Insertable<DownloadHistoryRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('source_id')) {
      context.handle(
        _sourceIdMeta,
        sourceId.isAcceptableOrUnknown(data['source_id']!, _sourceIdMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('url')) {
      context.handle(
        _urlMeta,
        url.isAcceptableOrUnknown(data['url']!, _urlMeta),
      );
    } else if (isInserting) {
      context.missing(_urlMeta);
    }
    if (data.containsKey('destination')) {
      context.handle(
        _destinationMeta,
        destination.isAcceptableOrUnknown(
          data['destination']!,
          _destinationMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_destinationMeta);
    }
    if (data.containsKey('size_bytes')) {
      context.handle(
        _sizeBytesMeta,
        sizeBytes.isAcceptableOrUnknown(data['size_bytes']!, _sizeBytesMeta),
      );
    }
    if (data.containsKey('sha256')) {
      context.handle(
        _sha256Meta,
        sha256.isAcceptableOrUnknown(data['sha256']!, _sha256Meta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('error_message')) {
      context.handle(
        _errorMessageMeta,
        errorMessage.isAcceptableOrUnknown(
          data['error_message']!,
          _errorMessageMeta,
        ),
      );
    }
    if (data.containsKey('finished_at')) {
      context.handle(
        _finishedAtMeta,
        finishedAt.isAcceptableOrUnknown(data['finished_at']!, _finishedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_finishedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DownloadHistoryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DownloadHistoryRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      sourceId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}source_id'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      url: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}url'],
      )!,
      destination: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}destination'],
      )!,
      sizeBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}size_bytes'],
      ),
      sha256: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sha256'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      errorMessage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}error_message'],
      ),
      finishedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}finished_at'],
      )!,
    );
  }

  @override
  $DownloadHistoryTable createAlias(String alias) {
    return $DownloadHistoryTable(attachedDatabase, alias);
  }
}

class DownloadHistoryRow extends DataClass
    implements Insertable<DownloadHistoryRow> {
  final int id;
  final int? sourceId;
  final String name;
  final String url;
  final String destination;
  final int? sizeBytes;
  final String? sha256;
  final String status;
  final String? errorMessage;
  final DateTime finishedAt;
  const DownloadHistoryRow({
    required this.id,
    this.sourceId,
    required this.name,
    required this.url,
    required this.destination,
    this.sizeBytes,
    this.sha256,
    required this.status,
    this.errorMessage,
    required this.finishedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || sourceId != null) {
      map['source_id'] = Variable<int>(sourceId);
    }
    map['name'] = Variable<String>(name);
    map['url'] = Variable<String>(url);
    map['destination'] = Variable<String>(destination);
    if (!nullToAbsent || sizeBytes != null) {
      map['size_bytes'] = Variable<int>(sizeBytes);
    }
    if (!nullToAbsent || sha256 != null) {
      map['sha256'] = Variable<String>(sha256);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || errorMessage != null) {
      map['error_message'] = Variable<String>(errorMessage);
    }
    map['finished_at'] = Variable<DateTime>(finishedAt);
    return map;
  }

  DownloadHistoryCompanion toCompanion(bool nullToAbsent) {
    return DownloadHistoryCompanion(
      id: Value(id),
      sourceId: sourceId == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceId),
      name: Value(name),
      url: Value(url),
      destination: Value(destination),
      sizeBytes: sizeBytes == null && nullToAbsent
          ? const Value.absent()
          : Value(sizeBytes),
      sha256: sha256 == null && nullToAbsent
          ? const Value.absent()
          : Value(sha256),
      status: Value(status),
      errorMessage: errorMessage == null && nullToAbsent
          ? const Value.absent()
          : Value(errorMessage),
      finishedAt: Value(finishedAt),
    );
  }

  factory DownloadHistoryRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DownloadHistoryRow(
      id: serializer.fromJson<int>(json['id']),
      sourceId: serializer.fromJson<int?>(json['sourceId']),
      name: serializer.fromJson<String>(json['name']),
      url: serializer.fromJson<String>(json['url']),
      destination: serializer.fromJson<String>(json['destination']),
      sizeBytes: serializer.fromJson<int?>(json['sizeBytes']),
      sha256: serializer.fromJson<String?>(json['sha256']),
      status: serializer.fromJson<String>(json['status']),
      errorMessage: serializer.fromJson<String?>(json['errorMessage']),
      finishedAt: serializer.fromJson<DateTime>(json['finishedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sourceId': serializer.toJson<int?>(sourceId),
      'name': serializer.toJson<String>(name),
      'url': serializer.toJson<String>(url),
      'destination': serializer.toJson<String>(destination),
      'sizeBytes': serializer.toJson<int?>(sizeBytes),
      'sha256': serializer.toJson<String?>(sha256),
      'status': serializer.toJson<String>(status),
      'errorMessage': serializer.toJson<String?>(errorMessage),
      'finishedAt': serializer.toJson<DateTime>(finishedAt),
    };
  }

  DownloadHistoryRow copyWith({
    int? id,
    Value<int?> sourceId = const Value.absent(),
    String? name,
    String? url,
    String? destination,
    Value<int?> sizeBytes = const Value.absent(),
    Value<String?> sha256 = const Value.absent(),
    String? status,
    Value<String?> errorMessage = const Value.absent(),
    DateTime? finishedAt,
  }) => DownloadHistoryRow(
    id: id ?? this.id,
    sourceId: sourceId.present ? sourceId.value : this.sourceId,
    name: name ?? this.name,
    url: url ?? this.url,
    destination: destination ?? this.destination,
    sizeBytes: sizeBytes.present ? sizeBytes.value : this.sizeBytes,
    sha256: sha256.present ? sha256.value : this.sha256,
    status: status ?? this.status,
    errorMessage: errorMessage.present ? errorMessage.value : this.errorMessage,
    finishedAt: finishedAt ?? this.finishedAt,
  );
  DownloadHistoryRow copyWithCompanion(DownloadHistoryCompanion data) {
    return DownloadHistoryRow(
      id: data.id.present ? data.id.value : this.id,
      sourceId: data.sourceId.present ? data.sourceId.value : this.sourceId,
      name: data.name.present ? data.name.value : this.name,
      url: data.url.present ? data.url.value : this.url,
      destination: data.destination.present
          ? data.destination.value
          : this.destination,
      sizeBytes: data.sizeBytes.present ? data.sizeBytes.value : this.sizeBytes,
      sha256: data.sha256.present ? data.sha256.value : this.sha256,
      status: data.status.present ? data.status.value : this.status,
      errorMessage: data.errorMessage.present
          ? data.errorMessage.value
          : this.errorMessage,
      finishedAt: data.finishedAt.present
          ? data.finishedAt.value
          : this.finishedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DownloadHistoryRow(')
          ..write('id: $id, ')
          ..write('sourceId: $sourceId, ')
          ..write('name: $name, ')
          ..write('url: $url, ')
          ..write('destination: $destination, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('sha256: $sha256, ')
          ..write('status: $status, ')
          ..write('errorMessage: $errorMessage, ')
          ..write('finishedAt: $finishedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sourceId,
    name,
    url,
    destination,
    sizeBytes,
    sha256,
    status,
    errorMessage,
    finishedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DownloadHistoryRow &&
          other.id == this.id &&
          other.sourceId == this.sourceId &&
          other.name == this.name &&
          other.url == this.url &&
          other.destination == this.destination &&
          other.sizeBytes == this.sizeBytes &&
          other.sha256 == this.sha256 &&
          other.status == this.status &&
          other.errorMessage == this.errorMessage &&
          other.finishedAt == this.finishedAt);
}

class DownloadHistoryCompanion extends UpdateCompanion<DownloadHistoryRow> {
  final Value<int> id;
  final Value<int?> sourceId;
  final Value<String> name;
  final Value<String> url;
  final Value<String> destination;
  final Value<int?> sizeBytes;
  final Value<String?> sha256;
  final Value<String> status;
  final Value<String?> errorMessage;
  final Value<DateTime> finishedAt;
  const DownloadHistoryCompanion({
    this.id = const Value.absent(),
    this.sourceId = const Value.absent(),
    this.name = const Value.absent(),
    this.url = const Value.absent(),
    this.destination = const Value.absent(),
    this.sizeBytes = const Value.absent(),
    this.sha256 = const Value.absent(),
    this.status = const Value.absent(),
    this.errorMessage = const Value.absent(),
    this.finishedAt = const Value.absent(),
  });
  DownloadHistoryCompanion.insert({
    this.id = const Value.absent(),
    this.sourceId = const Value.absent(),
    required String name,
    required String url,
    required String destination,
    this.sizeBytes = const Value.absent(),
    this.sha256 = const Value.absent(),
    required String status,
    this.errorMessage = const Value.absent(),
    required DateTime finishedAt,
  }) : name = Value(name),
       url = Value(url),
       destination = Value(destination),
       status = Value(status),
       finishedAt = Value(finishedAt);
  static Insertable<DownloadHistoryRow> custom({
    Expression<int>? id,
    Expression<int>? sourceId,
    Expression<String>? name,
    Expression<String>? url,
    Expression<String>? destination,
    Expression<int>? sizeBytes,
    Expression<String>? sha256,
    Expression<String>? status,
    Expression<String>? errorMessage,
    Expression<DateTime>? finishedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sourceId != null) 'source_id': sourceId,
      if (name != null) 'name': name,
      if (url != null) 'url': url,
      if (destination != null) 'destination': destination,
      if (sizeBytes != null) 'size_bytes': sizeBytes,
      if (sha256 != null) 'sha256': sha256,
      if (status != null) 'status': status,
      if (errorMessage != null) 'error_message': errorMessage,
      if (finishedAt != null) 'finished_at': finishedAt,
    });
  }

  DownloadHistoryCompanion copyWith({
    Value<int>? id,
    Value<int?>? sourceId,
    Value<String>? name,
    Value<String>? url,
    Value<String>? destination,
    Value<int?>? sizeBytes,
    Value<String?>? sha256,
    Value<String>? status,
    Value<String?>? errorMessage,
    Value<DateTime>? finishedAt,
  }) {
    return DownloadHistoryCompanion(
      id: id ?? this.id,
      sourceId: sourceId ?? this.sourceId,
      name: name ?? this.name,
      url: url ?? this.url,
      destination: destination ?? this.destination,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      sha256: sha256 ?? this.sha256,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      finishedAt: finishedAt ?? this.finishedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sourceId.present) {
      map['source_id'] = Variable<int>(sourceId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (destination.present) {
      map['destination'] = Variable<String>(destination.value);
    }
    if (sizeBytes.present) {
      map['size_bytes'] = Variable<int>(sizeBytes.value);
    }
    if (sha256.present) {
      map['sha256'] = Variable<String>(sha256.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (errorMessage.present) {
      map['error_message'] = Variable<String>(errorMessage.value);
    }
    if (finishedAt.present) {
      map['finished_at'] = Variable<DateTime>(finishedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DownloadHistoryCompanion(')
          ..write('id: $id, ')
          ..write('sourceId: $sourceId, ')
          ..write('name: $name, ')
          ..write('url: $url, ')
          ..write('destination: $destination, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('sha256: $sha256, ')
          ..write('status: $status, ')
          ..write('errorMessage: $errorMessage, ')
          ..write('finishedAt: $finishedAt')
          ..write(')'))
        .toString();
  }
}

class $SaveStatesTable extends SaveStates
    with TableInfo<$SaveStatesTable, SaveStateRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SaveStatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _gameIdMeta = const VerificationMeta('gameId');
  @override
  late final GeneratedColumn<int> gameId = GeneratedColumn<int>(
    'game_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES games (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _emulatorIdMeta = const VerificationMeta(
    'emulatorId',
  );
  @override
  late final GeneratedColumn<String> emulatorId = GeneratedColumn<String>(
    'emulator_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    check: () => kind.isIn(const ['state', 'native', 'memcard']),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _slotMeta = const VerificationMeta('slot');
  @override
  late final GeneratedColumn<int> slot = GeneratedColumn<int>(
    'slot',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pathMeta = const VerificationMeta('path');
  @override
  late final GeneratedColumn<String> path = GeneratedColumn<String>(
    'path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sizeBytesMeta = const VerificationMeta(
    'sizeBytes',
  );
  @override
  late final GeneratedColumn<int> sizeBytes = GeneratedColumn<int>(
    'size_bytes',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _folderUriMeta = const VerificationMeta(
    'folderUri',
  );
  @override
  late final GeneratedColumn<String> folderUri = GeneratedColumn<String>(
    'folder_uri',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _relativePathMeta = const VerificationMeta(
    'relativePath',
  );
  @override
  late final GeneratedColumn<String> relativePath = GeneratedColumn<String>(
    'relative_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastModifiedMeta = const VerificationMeta(
    'lastModified',
  );
  @override
  late final GeneratedColumn<int> lastModified = GeneratedColumn<int>(
    'last_modified',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    gameId,
    emulatorId,
    kind,
    slot,
    path,
    sizeBytes,
    createdAt,
    folderUri,
    relativePath,
    lastModified,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'save_states';
  @override
  VerificationContext validateIntegrity(
    Insertable<SaveStateRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('game_id')) {
      context.handle(
        _gameIdMeta,
        gameId.isAcceptableOrUnknown(data['game_id']!, _gameIdMeta),
      );
    } else if (isInserting) {
      context.missing(_gameIdMeta);
    }
    if (data.containsKey('emulator_id')) {
      context.handle(
        _emulatorIdMeta,
        emulatorId.isAcceptableOrUnknown(data['emulator_id']!, _emulatorIdMeta),
      );
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('slot')) {
      context.handle(
        _slotMeta,
        slot.isAcceptableOrUnknown(data['slot']!, _slotMeta),
      );
    }
    if (data.containsKey('path')) {
      context.handle(
        _pathMeta,
        path.isAcceptableOrUnknown(data['path']!, _pathMeta),
      );
    } else if (isInserting) {
      context.missing(_pathMeta);
    }
    if (data.containsKey('size_bytes')) {
      context.handle(
        _sizeBytesMeta,
        sizeBytes.isAcceptableOrUnknown(data['size_bytes']!, _sizeBytesMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('folder_uri')) {
      context.handle(
        _folderUriMeta,
        folderUri.isAcceptableOrUnknown(data['folder_uri']!, _folderUriMeta),
      );
    }
    if (data.containsKey('relative_path')) {
      context.handle(
        _relativePathMeta,
        relativePath.isAcceptableOrUnknown(
          data['relative_path']!,
          _relativePathMeta,
        ),
      );
    }
    if (data.containsKey('last_modified')) {
      context.handle(
        _lastModifiedMeta,
        lastModified.isAcceptableOrUnknown(
          data['last_modified']!,
          _lastModifiedMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SaveStateRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SaveStateRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      gameId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}game_id'],
      )!,
      emulatorId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}emulator_id'],
      ),
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      slot: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}slot'],
      ),
      path: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}path'],
      )!,
      sizeBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}size_bytes'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      folderUri: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}folder_uri'],
      ),
      relativePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}relative_path'],
      ),
      lastModified: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_modified'],
      ),
    );
  }

  @override
  $SaveStatesTable createAlias(String alias) {
    return $SaveStatesTable(attachedDatabase, alias);
  }
}

class SaveStateRow extends DataClass implements Insertable<SaveStateRow> {
  final int id;
  final int gameId;
  final String? emulatorId;

  /// `state` (emulator save state), `native` (in-game save) or `memcard`.
  final String kind;
  final int? slot;
  final String path;
  final int? sizeBytes;
  final DateTime createdAt;

  /// Registered save folder (SAF tree or directory) the file was found in.
  final String? folderUri;

  /// File name inside the save folder (relative path).
  final String? relativePath;
  final int? lastModified;
  const SaveStateRow({
    required this.id,
    required this.gameId,
    this.emulatorId,
    required this.kind,
    this.slot,
    required this.path,
    this.sizeBytes,
    required this.createdAt,
    this.folderUri,
    this.relativePath,
    this.lastModified,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['game_id'] = Variable<int>(gameId);
    if (!nullToAbsent || emulatorId != null) {
      map['emulator_id'] = Variable<String>(emulatorId);
    }
    map['kind'] = Variable<String>(kind);
    if (!nullToAbsent || slot != null) {
      map['slot'] = Variable<int>(slot);
    }
    map['path'] = Variable<String>(path);
    if (!nullToAbsent || sizeBytes != null) {
      map['size_bytes'] = Variable<int>(sizeBytes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || folderUri != null) {
      map['folder_uri'] = Variable<String>(folderUri);
    }
    if (!nullToAbsent || relativePath != null) {
      map['relative_path'] = Variable<String>(relativePath);
    }
    if (!nullToAbsent || lastModified != null) {
      map['last_modified'] = Variable<int>(lastModified);
    }
    return map;
  }

  SaveStatesCompanion toCompanion(bool nullToAbsent) {
    return SaveStatesCompanion(
      id: Value(id),
      gameId: Value(gameId),
      emulatorId: emulatorId == null && nullToAbsent
          ? const Value.absent()
          : Value(emulatorId),
      kind: Value(kind),
      slot: slot == null && nullToAbsent ? const Value.absent() : Value(slot),
      path: Value(path),
      sizeBytes: sizeBytes == null && nullToAbsent
          ? const Value.absent()
          : Value(sizeBytes),
      createdAt: Value(createdAt),
      folderUri: folderUri == null && nullToAbsent
          ? const Value.absent()
          : Value(folderUri),
      relativePath: relativePath == null && nullToAbsent
          ? const Value.absent()
          : Value(relativePath),
      lastModified: lastModified == null && nullToAbsent
          ? const Value.absent()
          : Value(lastModified),
    );
  }

  factory SaveStateRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SaveStateRow(
      id: serializer.fromJson<int>(json['id']),
      gameId: serializer.fromJson<int>(json['gameId']),
      emulatorId: serializer.fromJson<String?>(json['emulatorId']),
      kind: serializer.fromJson<String>(json['kind']),
      slot: serializer.fromJson<int?>(json['slot']),
      path: serializer.fromJson<String>(json['path']),
      sizeBytes: serializer.fromJson<int?>(json['sizeBytes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      folderUri: serializer.fromJson<String?>(json['folderUri']),
      relativePath: serializer.fromJson<String?>(json['relativePath']),
      lastModified: serializer.fromJson<int?>(json['lastModified']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'gameId': serializer.toJson<int>(gameId),
      'emulatorId': serializer.toJson<String?>(emulatorId),
      'kind': serializer.toJson<String>(kind),
      'slot': serializer.toJson<int?>(slot),
      'path': serializer.toJson<String>(path),
      'sizeBytes': serializer.toJson<int?>(sizeBytes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'folderUri': serializer.toJson<String?>(folderUri),
      'relativePath': serializer.toJson<String?>(relativePath),
      'lastModified': serializer.toJson<int?>(lastModified),
    };
  }

  SaveStateRow copyWith({
    int? id,
    int? gameId,
    Value<String?> emulatorId = const Value.absent(),
    String? kind,
    Value<int?> slot = const Value.absent(),
    String? path,
    Value<int?> sizeBytes = const Value.absent(),
    DateTime? createdAt,
    Value<String?> folderUri = const Value.absent(),
    Value<String?> relativePath = const Value.absent(),
    Value<int?> lastModified = const Value.absent(),
  }) => SaveStateRow(
    id: id ?? this.id,
    gameId: gameId ?? this.gameId,
    emulatorId: emulatorId.present ? emulatorId.value : this.emulatorId,
    kind: kind ?? this.kind,
    slot: slot.present ? slot.value : this.slot,
    path: path ?? this.path,
    sizeBytes: sizeBytes.present ? sizeBytes.value : this.sizeBytes,
    createdAt: createdAt ?? this.createdAt,
    folderUri: folderUri.present ? folderUri.value : this.folderUri,
    relativePath: relativePath.present ? relativePath.value : this.relativePath,
    lastModified: lastModified.present ? lastModified.value : this.lastModified,
  );
  SaveStateRow copyWithCompanion(SaveStatesCompanion data) {
    return SaveStateRow(
      id: data.id.present ? data.id.value : this.id,
      gameId: data.gameId.present ? data.gameId.value : this.gameId,
      emulatorId: data.emulatorId.present
          ? data.emulatorId.value
          : this.emulatorId,
      kind: data.kind.present ? data.kind.value : this.kind,
      slot: data.slot.present ? data.slot.value : this.slot,
      path: data.path.present ? data.path.value : this.path,
      sizeBytes: data.sizeBytes.present ? data.sizeBytes.value : this.sizeBytes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      folderUri: data.folderUri.present ? data.folderUri.value : this.folderUri,
      relativePath: data.relativePath.present
          ? data.relativePath.value
          : this.relativePath,
      lastModified: data.lastModified.present
          ? data.lastModified.value
          : this.lastModified,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SaveStateRow(')
          ..write('id: $id, ')
          ..write('gameId: $gameId, ')
          ..write('emulatorId: $emulatorId, ')
          ..write('kind: $kind, ')
          ..write('slot: $slot, ')
          ..write('path: $path, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('createdAt: $createdAt, ')
          ..write('folderUri: $folderUri, ')
          ..write('relativePath: $relativePath, ')
          ..write('lastModified: $lastModified')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    gameId,
    emulatorId,
    kind,
    slot,
    path,
    sizeBytes,
    createdAt,
    folderUri,
    relativePath,
    lastModified,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SaveStateRow &&
          other.id == this.id &&
          other.gameId == this.gameId &&
          other.emulatorId == this.emulatorId &&
          other.kind == this.kind &&
          other.slot == this.slot &&
          other.path == this.path &&
          other.sizeBytes == this.sizeBytes &&
          other.createdAt == this.createdAt &&
          other.folderUri == this.folderUri &&
          other.relativePath == this.relativePath &&
          other.lastModified == this.lastModified);
}

class SaveStatesCompanion extends UpdateCompanion<SaveStateRow> {
  final Value<int> id;
  final Value<int> gameId;
  final Value<String?> emulatorId;
  final Value<String> kind;
  final Value<int?> slot;
  final Value<String> path;
  final Value<int?> sizeBytes;
  final Value<DateTime> createdAt;
  final Value<String?> folderUri;
  final Value<String?> relativePath;
  final Value<int?> lastModified;
  const SaveStatesCompanion({
    this.id = const Value.absent(),
    this.gameId = const Value.absent(),
    this.emulatorId = const Value.absent(),
    this.kind = const Value.absent(),
    this.slot = const Value.absent(),
    this.path = const Value.absent(),
    this.sizeBytes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.folderUri = const Value.absent(),
    this.relativePath = const Value.absent(),
    this.lastModified = const Value.absent(),
  });
  SaveStatesCompanion.insert({
    this.id = const Value.absent(),
    required int gameId,
    this.emulatorId = const Value.absent(),
    required String kind,
    this.slot = const Value.absent(),
    required String path,
    this.sizeBytes = const Value.absent(),
    required DateTime createdAt,
    this.folderUri = const Value.absent(),
    this.relativePath = const Value.absent(),
    this.lastModified = const Value.absent(),
  }) : gameId = Value(gameId),
       kind = Value(kind),
       path = Value(path),
       createdAt = Value(createdAt);
  static Insertable<SaveStateRow> custom({
    Expression<int>? id,
    Expression<int>? gameId,
    Expression<String>? emulatorId,
    Expression<String>? kind,
    Expression<int>? slot,
    Expression<String>? path,
    Expression<int>? sizeBytes,
    Expression<DateTime>? createdAt,
    Expression<String>? folderUri,
    Expression<String>? relativePath,
    Expression<int>? lastModified,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (gameId != null) 'game_id': gameId,
      if (emulatorId != null) 'emulator_id': emulatorId,
      if (kind != null) 'kind': kind,
      if (slot != null) 'slot': slot,
      if (path != null) 'path': path,
      if (sizeBytes != null) 'size_bytes': sizeBytes,
      if (createdAt != null) 'created_at': createdAt,
      if (folderUri != null) 'folder_uri': folderUri,
      if (relativePath != null) 'relative_path': relativePath,
      if (lastModified != null) 'last_modified': lastModified,
    });
  }

  SaveStatesCompanion copyWith({
    Value<int>? id,
    Value<int>? gameId,
    Value<String?>? emulatorId,
    Value<String>? kind,
    Value<int?>? slot,
    Value<String>? path,
    Value<int?>? sizeBytes,
    Value<DateTime>? createdAt,
    Value<String?>? folderUri,
    Value<String?>? relativePath,
    Value<int?>? lastModified,
  }) {
    return SaveStatesCompanion(
      id: id ?? this.id,
      gameId: gameId ?? this.gameId,
      emulatorId: emulatorId ?? this.emulatorId,
      kind: kind ?? this.kind,
      slot: slot ?? this.slot,
      path: path ?? this.path,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      createdAt: createdAt ?? this.createdAt,
      folderUri: folderUri ?? this.folderUri,
      relativePath: relativePath ?? this.relativePath,
      lastModified: lastModified ?? this.lastModified,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (gameId.present) {
      map['game_id'] = Variable<int>(gameId.value);
    }
    if (emulatorId.present) {
      map['emulator_id'] = Variable<String>(emulatorId.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (slot.present) {
      map['slot'] = Variable<int>(slot.value);
    }
    if (path.present) {
      map['path'] = Variable<String>(path.value);
    }
    if (sizeBytes.present) {
      map['size_bytes'] = Variable<int>(sizeBytes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (folderUri.present) {
      map['folder_uri'] = Variable<String>(folderUri.value);
    }
    if (relativePath.present) {
      map['relative_path'] = Variable<String>(relativePath.value);
    }
    if (lastModified.present) {
      map['last_modified'] = Variable<int>(lastModified.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SaveStatesCompanion(')
          ..write('id: $id, ')
          ..write('gameId: $gameId, ')
          ..write('emulatorId: $emulatorId, ')
          ..write('kind: $kind, ')
          ..write('slot: $slot, ')
          ..write('path: $path, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('createdAt: $createdAt, ')
          ..write('folderUri: $folderUri, ')
          ..write('relativePath: $relativePath, ')
          ..write('lastModified: $lastModified')
          ..write(')'))
        .toString();
  }
}

class $SaveBackupsTable extends SaveBackups
    with TableInfo<$SaveBackupsTable, SaveBackupRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SaveBackupsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _gameIdMeta = const VerificationMeta('gameId');
  @override
  late final GeneratedColumn<int> gameId = GeneratedColumn<int>(
    'game_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES games (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _saveStateIdMeta = const VerificationMeta(
    'saveStateId',
  );
  @override
  late final GeneratedColumn<int> saveStateId = GeneratedColumn<int>(
    'save_state_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES save_states (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _backupPathMeta = const VerificationMeta(
    'backupPath',
  );
  @override
  late final GeneratedColumn<String> backupPath = GeneratedColumn<String>(
    'backup_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sizeBytesMeta = const VerificationMeta(
    'sizeBytes',
  );
  @override
  late final GeneratedColumn<int> sizeBytes = GeneratedColumn<int>(
    'size_bytes',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    gameId,
    saveStateId,
    backupPath,
    sizeBytes,
    note,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'save_backups';
  @override
  VerificationContext validateIntegrity(
    Insertable<SaveBackupRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('game_id')) {
      context.handle(
        _gameIdMeta,
        gameId.isAcceptableOrUnknown(data['game_id']!, _gameIdMeta),
      );
    }
    if (data.containsKey('save_state_id')) {
      context.handle(
        _saveStateIdMeta,
        saveStateId.isAcceptableOrUnknown(
          data['save_state_id']!,
          _saveStateIdMeta,
        ),
      );
    }
    if (data.containsKey('backup_path')) {
      context.handle(
        _backupPathMeta,
        backupPath.isAcceptableOrUnknown(data['backup_path']!, _backupPathMeta),
      );
    } else if (isInserting) {
      context.missing(_backupPathMeta);
    }
    if (data.containsKey('size_bytes')) {
      context.handle(
        _sizeBytesMeta,
        sizeBytes.isAcceptableOrUnknown(data['size_bytes']!, _sizeBytesMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SaveBackupRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SaveBackupRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      gameId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}game_id'],
      ),
      saveStateId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}save_state_id'],
      ),
      backupPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}backup_path'],
      )!,
      sizeBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}size_bytes'],
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $SaveBackupsTable createAlias(String alias) {
    return $SaveBackupsTable(attachedDatabase, alias);
  }
}

class SaveBackupRow extends DataClass implements Insertable<SaveBackupRow> {
  final int id;
  final int? gameId;
  final int? saveStateId;
  final String backupPath;
  final int? sizeBytes;
  final String? note;
  final DateTime createdAt;
  const SaveBackupRow({
    required this.id,
    this.gameId,
    this.saveStateId,
    required this.backupPath,
    this.sizeBytes,
    this.note,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || gameId != null) {
      map['game_id'] = Variable<int>(gameId);
    }
    if (!nullToAbsent || saveStateId != null) {
      map['save_state_id'] = Variable<int>(saveStateId);
    }
    map['backup_path'] = Variable<String>(backupPath);
    if (!nullToAbsent || sizeBytes != null) {
      map['size_bytes'] = Variable<int>(sizeBytes);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  SaveBackupsCompanion toCompanion(bool nullToAbsent) {
    return SaveBackupsCompanion(
      id: Value(id),
      gameId: gameId == null && nullToAbsent
          ? const Value.absent()
          : Value(gameId),
      saveStateId: saveStateId == null && nullToAbsent
          ? const Value.absent()
          : Value(saveStateId),
      backupPath: Value(backupPath),
      sizeBytes: sizeBytes == null && nullToAbsent
          ? const Value.absent()
          : Value(sizeBytes),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      createdAt: Value(createdAt),
    );
  }

  factory SaveBackupRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SaveBackupRow(
      id: serializer.fromJson<int>(json['id']),
      gameId: serializer.fromJson<int?>(json['gameId']),
      saveStateId: serializer.fromJson<int?>(json['saveStateId']),
      backupPath: serializer.fromJson<String>(json['backupPath']),
      sizeBytes: serializer.fromJson<int?>(json['sizeBytes']),
      note: serializer.fromJson<String?>(json['note']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'gameId': serializer.toJson<int?>(gameId),
      'saveStateId': serializer.toJson<int?>(saveStateId),
      'backupPath': serializer.toJson<String>(backupPath),
      'sizeBytes': serializer.toJson<int?>(sizeBytes),
      'note': serializer.toJson<String?>(note),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  SaveBackupRow copyWith({
    int? id,
    Value<int?> gameId = const Value.absent(),
    Value<int?> saveStateId = const Value.absent(),
    String? backupPath,
    Value<int?> sizeBytes = const Value.absent(),
    Value<String?> note = const Value.absent(),
    DateTime? createdAt,
  }) => SaveBackupRow(
    id: id ?? this.id,
    gameId: gameId.present ? gameId.value : this.gameId,
    saveStateId: saveStateId.present ? saveStateId.value : this.saveStateId,
    backupPath: backupPath ?? this.backupPath,
    sizeBytes: sizeBytes.present ? sizeBytes.value : this.sizeBytes,
    note: note.present ? note.value : this.note,
    createdAt: createdAt ?? this.createdAt,
  );
  SaveBackupRow copyWithCompanion(SaveBackupsCompanion data) {
    return SaveBackupRow(
      id: data.id.present ? data.id.value : this.id,
      gameId: data.gameId.present ? data.gameId.value : this.gameId,
      saveStateId: data.saveStateId.present
          ? data.saveStateId.value
          : this.saveStateId,
      backupPath: data.backupPath.present
          ? data.backupPath.value
          : this.backupPath,
      sizeBytes: data.sizeBytes.present ? data.sizeBytes.value : this.sizeBytes,
      note: data.note.present ? data.note.value : this.note,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SaveBackupRow(')
          ..write('id: $id, ')
          ..write('gameId: $gameId, ')
          ..write('saveStateId: $saveStateId, ')
          ..write('backupPath: $backupPath, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    gameId,
    saveStateId,
    backupPath,
    sizeBytes,
    note,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SaveBackupRow &&
          other.id == this.id &&
          other.gameId == this.gameId &&
          other.saveStateId == this.saveStateId &&
          other.backupPath == this.backupPath &&
          other.sizeBytes == this.sizeBytes &&
          other.note == this.note &&
          other.createdAt == this.createdAt);
}

class SaveBackupsCompanion extends UpdateCompanion<SaveBackupRow> {
  final Value<int> id;
  final Value<int?> gameId;
  final Value<int?> saveStateId;
  final Value<String> backupPath;
  final Value<int?> sizeBytes;
  final Value<String?> note;
  final Value<DateTime> createdAt;
  const SaveBackupsCompanion({
    this.id = const Value.absent(),
    this.gameId = const Value.absent(),
    this.saveStateId = const Value.absent(),
    this.backupPath = const Value.absent(),
    this.sizeBytes = const Value.absent(),
    this.note = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  SaveBackupsCompanion.insert({
    this.id = const Value.absent(),
    this.gameId = const Value.absent(),
    this.saveStateId = const Value.absent(),
    required String backupPath,
    this.sizeBytes = const Value.absent(),
    this.note = const Value.absent(),
    required DateTime createdAt,
  }) : backupPath = Value(backupPath),
       createdAt = Value(createdAt);
  static Insertable<SaveBackupRow> custom({
    Expression<int>? id,
    Expression<int>? gameId,
    Expression<int>? saveStateId,
    Expression<String>? backupPath,
    Expression<int>? sizeBytes,
    Expression<String>? note,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (gameId != null) 'game_id': gameId,
      if (saveStateId != null) 'save_state_id': saveStateId,
      if (backupPath != null) 'backup_path': backupPath,
      if (sizeBytes != null) 'size_bytes': sizeBytes,
      if (note != null) 'note': note,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  SaveBackupsCompanion copyWith({
    Value<int>? id,
    Value<int?>? gameId,
    Value<int?>? saveStateId,
    Value<String>? backupPath,
    Value<int?>? sizeBytes,
    Value<String?>? note,
    Value<DateTime>? createdAt,
  }) {
    return SaveBackupsCompanion(
      id: id ?? this.id,
      gameId: gameId ?? this.gameId,
      saveStateId: saveStateId ?? this.saveStateId,
      backupPath: backupPath ?? this.backupPath,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (gameId.present) {
      map['game_id'] = Variable<int>(gameId.value);
    }
    if (saveStateId.present) {
      map['save_state_id'] = Variable<int>(saveStateId.value);
    }
    if (backupPath.present) {
      map['backup_path'] = Variable<String>(backupPath.value);
    }
    if (sizeBytes.present) {
      map['size_bytes'] = Variable<int>(sizeBytes.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SaveBackupsCompanion(')
          ..write('id: $id, ')
          ..write('gameId: $gameId, ')
          ..write('saveStateId: $saveStateId, ')
          ..write('backupPath: $backupPath, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $BenchmarksTable extends Benchmarks
    with TableInfo<$BenchmarksTable, BenchmarkRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BenchmarksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<int> deviceId = GeneratedColumn<int>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES devices (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _emulatorIdMeta = const VerificationMeta(
    'emulatorId',
  );
  @override
  late final GeneratedColumn<String> emulatorId = GeneratedColumn<String>(
    'emulator_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _consoleIdMeta = const VerificationMeta(
    'consoleId',
  );
  @override
  late final GeneratedColumn<String> consoleId = GeneratedColumn<String>(
    'console_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _gameIdMeta = const VerificationMeta('gameId');
  @override
  late final GeneratedColumn<int> gameId = GeneratedColumn<int>(
    'game_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES games (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _benchmarkTypeMeta = const VerificationMeta(
    'benchmarkType',
  );
  @override
  late final GeneratedColumn<String> benchmarkType = GeneratedColumn<String>(
    'benchmark_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _averageFpsMeta = const VerificationMeta(
    'averageFps',
  );
  @override
  late final GeneratedColumn<double> averageFps = GeneratedColumn<double>(
    'average_fps',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _minimumFpsMeta = const VerificationMeta(
    'minimumFps',
  );
  @override
  late final GeneratedColumn<double> minimumFps = GeneratedColumn<double>(
    'minimum_fps',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _scoreMeta = const VerificationMeta('score');
  @override
  late final GeneratedColumn<double> score = GeneratedColumn<double>(
    'score',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _durationMsMeta = const VerificationMeta(
    'durationMs',
  );
  @override
  late final GeneratedColumn<int> durationMs = GeneratedColumn<int>(
    'duration_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ranAtMeta = const VerificationMeta('ranAt');
  @override
  late final GeneratedColumn<DateTime> ranAt = GeneratedColumn<DateTime>(
    'ran_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    deviceId,
    emulatorId,
    consoleId,
    gameId,
    benchmarkType,
    averageFps,
    minimumFps,
    score,
    durationMs,
    notes,
    ranAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'benchmarks';
  @override
  VerificationContext validateIntegrity(
    Insertable<BenchmarkRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('emulator_id')) {
      context.handle(
        _emulatorIdMeta,
        emulatorId.isAcceptableOrUnknown(data['emulator_id']!, _emulatorIdMeta),
      );
    }
    if (data.containsKey('console_id')) {
      context.handle(
        _consoleIdMeta,
        consoleId.isAcceptableOrUnknown(data['console_id']!, _consoleIdMeta),
      );
    }
    if (data.containsKey('game_id')) {
      context.handle(
        _gameIdMeta,
        gameId.isAcceptableOrUnknown(data['game_id']!, _gameIdMeta),
      );
    }
    if (data.containsKey('benchmark_type')) {
      context.handle(
        _benchmarkTypeMeta,
        benchmarkType.isAcceptableOrUnknown(
          data['benchmark_type']!,
          _benchmarkTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_benchmarkTypeMeta);
    }
    if (data.containsKey('average_fps')) {
      context.handle(
        _averageFpsMeta,
        averageFps.isAcceptableOrUnknown(data['average_fps']!, _averageFpsMeta),
      );
    }
    if (data.containsKey('minimum_fps')) {
      context.handle(
        _minimumFpsMeta,
        minimumFps.isAcceptableOrUnknown(data['minimum_fps']!, _minimumFpsMeta),
      );
    }
    if (data.containsKey('score')) {
      context.handle(
        _scoreMeta,
        score.isAcceptableOrUnknown(data['score']!, _scoreMeta),
      );
    }
    if (data.containsKey('duration_ms')) {
      context.handle(
        _durationMsMeta,
        durationMs.isAcceptableOrUnknown(data['duration_ms']!, _durationMsMeta),
      );
    } else if (isInserting) {
      context.missing(_durationMsMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('ran_at')) {
      context.handle(
        _ranAtMeta,
        ranAt.isAcceptableOrUnknown(data['ran_at']!, _ranAtMeta),
      );
    } else if (isInserting) {
      context.missing(_ranAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BenchmarkRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BenchmarkRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}device_id'],
      )!,
      emulatorId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}emulator_id'],
      ),
      consoleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}console_id'],
      ),
      gameId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}game_id'],
      ),
      benchmarkType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}benchmark_type'],
      )!,
      averageFps: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}average_fps'],
      ),
      minimumFps: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}minimum_fps'],
      ),
      score: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}score'],
      ),
      durationMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_ms'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      ranAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}ran_at'],
      )!,
    );
  }

  @override
  $BenchmarksTable createAlias(String alias) {
    return $BenchmarksTable(attachedDatabase, alias);
  }
}

class BenchmarkRow extends DataClass implements Insertable<BenchmarkRow> {
  final int id;
  final int deviceId;
  final String? emulatorId;
  final String? consoleId;
  final int? gameId;
  final String benchmarkType;
  final double? averageFps;
  final double? minimumFps;
  final double? score;
  final int durationMs;
  final String? notes;
  final DateTime ranAt;
  const BenchmarkRow({
    required this.id,
    required this.deviceId,
    this.emulatorId,
    this.consoleId,
    this.gameId,
    required this.benchmarkType,
    this.averageFps,
    this.minimumFps,
    this.score,
    required this.durationMs,
    this.notes,
    required this.ranAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['device_id'] = Variable<int>(deviceId);
    if (!nullToAbsent || emulatorId != null) {
      map['emulator_id'] = Variable<String>(emulatorId);
    }
    if (!nullToAbsent || consoleId != null) {
      map['console_id'] = Variable<String>(consoleId);
    }
    if (!nullToAbsent || gameId != null) {
      map['game_id'] = Variable<int>(gameId);
    }
    map['benchmark_type'] = Variable<String>(benchmarkType);
    if (!nullToAbsent || averageFps != null) {
      map['average_fps'] = Variable<double>(averageFps);
    }
    if (!nullToAbsent || minimumFps != null) {
      map['minimum_fps'] = Variable<double>(minimumFps);
    }
    if (!nullToAbsent || score != null) {
      map['score'] = Variable<double>(score);
    }
    map['duration_ms'] = Variable<int>(durationMs);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['ran_at'] = Variable<DateTime>(ranAt);
    return map;
  }

  BenchmarksCompanion toCompanion(bool nullToAbsent) {
    return BenchmarksCompanion(
      id: Value(id),
      deviceId: Value(deviceId),
      emulatorId: emulatorId == null && nullToAbsent
          ? const Value.absent()
          : Value(emulatorId),
      consoleId: consoleId == null && nullToAbsent
          ? const Value.absent()
          : Value(consoleId),
      gameId: gameId == null && nullToAbsent
          ? const Value.absent()
          : Value(gameId),
      benchmarkType: Value(benchmarkType),
      averageFps: averageFps == null && nullToAbsent
          ? const Value.absent()
          : Value(averageFps),
      minimumFps: minimumFps == null && nullToAbsent
          ? const Value.absent()
          : Value(minimumFps),
      score: score == null && nullToAbsent
          ? const Value.absent()
          : Value(score),
      durationMs: Value(durationMs),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      ranAt: Value(ranAt),
    );
  }

  factory BenchmarkRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BenchmarkRow(
      id: serializer.fromJson<int>(json['id']),
      deviceId: serializer.fromJson<int>(json['deviceId']),
      emulatorId: serializer.fromJson<String?>(json['emulatorId']),
      consoleId: serializer.fromJson<String?>(json['consoleId']),
      gameId: serializer.fromJson<int?>(json['gameId']),
      benchmarkType: serializer.fromJson<String>(json['benchmarkType']),
      averageFps: serializer.fromJson<double?>(json['averageFps']),
      minimumFps: serializer.fromJson<double?>(json['minimumFps']),
      score: serializer.fromJson<double?>(json['score']),
      durationMs: serializer.fromJson<int>(json['durationMs']),
      notes: serializer.fromJson<String?>(json['notes']),
      ranAt: serializer.fromJson<DateTime>(json['ranAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'deviceId': serializer.toJson<int>(deviceId),
      'emulatorId': serializer.toJson<String?>(emulatorId),
      'consoleId': serializer.toJson<String?>(consoleId),
      'gameId': serializer.toJson<int?>(gameId),
      'benchmarkType': serializer.toJson<String>(benchmarkType),
      'averageFps': serializer.toJson<double?>(averageFps),
      'minimumFps': serializer.toJson<double?>(minimumFps),
      'score': serializer.toJson<double?>(score),
      'durationMs': serializer.toJson<int>(durationMs),
      'notes': serializer.toJson<String?>(notes),
      'ranAt': serializer.toJson<DateTime>(ranAt),
    };
  }

  BenchmarkRow copyWith({
    int? id,
    int? deviceId,
    Value<String?> emulatorId = const Value.absent(),
    Value<String?> consoleId = const Value.absent(),
    Value<int?> gameId = const Value.absent(),
    String? benchmarkType,
    Value<double?> averageFps = const Value.absent(),
    Value<double?> minimumFps = const Value.absent(),
    Value<double?> score = const Value.absent(),
    int? durationMs,
    Value<String?> notes = const Value.absent(),
    DateTime? ranAt,
  }) => BenchmarkRow(
    id: id ?? this.id,
    deviceId: deviceId ?? this.deviceId,
    emulatorId: emulatorId.present ? emulatorId.value : this.emulatorId,
    consoleId: consoleId.present ? consoleId.value : this.consoleId,
    gameId: gameId.present ? gameId.value : this.gameId,
    benchmarkType: benchmarkType ?? this.benchmarkType,
    averageFps: averageFps.present ? averageFps.value : this.averageFps,
    minimumFps: minimumFps.present ? minimumFps.value : this.minimumFps,
    score: score.present ? score.value : this.score,
    durationMs: durationMs ?? this.durationMs,
    notes: notes.present ? notes.value : this.notes,
    ranAt: ranAt ?? this.ranAt,
  );
  BenchmarkRow copyWithCompanion(BenchmarksCompanion data) {
    return BenchmarkRow(
      id: data.id.present ? data.id.value : this.id,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      emulatorId: data.emulatorId.present
          ? data.emulatorId.value
          : this.emulatorId,
      consoleId: data.consoleId.present ? data.consoleId.value : this.consoleId,
      gameId: data.gameId.present ? data.gameId.value : this.gameId,
      benchmarkType: data.benchmarkType.present
          ? data.benchmarkType.value
          : this.benchmarkType,
      averageFps: data.averageFps.present
          ? data.averageFps.value
          : this.averageFps,
      minimumFps: data.minimumFps.present
          ? data.minimumFps.value
          : this.minimumFps,
      score: data.score.present ? data.score.value : this.score,
      durationMs: data.durationMs.present
          ? data.durationMs.value
          : this.durationMs,
      notes: data.notes.present ? data.notes.value : this.notes,
      ranAt: data.ranAt.present ? data.ranAt.value : this.ranAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BenchmarkRow(')
          ..write('id: $id, ')
          ..write('deviceId: $deviceId, ')
          ..write('emulatorId: $emulatorId, ')
          ..write('consoleId: $consoleId, ')
          ..write('gameId: $gameId, ')
          ..write('benchmarkType: $benchmarkType, ')
          ..write('averageFps: $averageFps, ')
          ..write('minimumFps: $minimumFps, ')
          ..write('score: $score, ')
          ..write('durationMs: $durationMs, ')
          ..write('notes: $notes, ')
          ..write('ranAt: $ranAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    deviceId,
    emulatorId,
    consoleId,
    gameId,
    benchmarkType,
    averageFps,
    minimumFps,
    score,
    durationMs,
    notes,
    ranAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BenchmarkRow &&
          other.id == this.id &&
          other.deviceId == this.deviceId &&
          other.emulatorId == this.emulatorId &&
          other.consoleId == this.consoleId &&
          other.gameId == this.gameId &&
          other.benchmarkType == this.benchmarkType &&
          other.averageFps == this.averageFps &&
          other.minimumFps == this.minimumFps &&
          other.score == this.score &&
          other.durationMs == this.durationMs &&
          other.notes == this.notes &&
          other.ranAt == this.ranAt);
}

class BenchmarksCompanion extends UpdateCompanion<BenchmarkRow> {
  final Value<int> id;
  final Value<int> deviceId;
  final Value<String?> emulatorId;
  final Value<String?> consoleId;
  final Value<int?> gameId;
  final Value<String> benchmarkType;
  final Value<double?> averageFps;
  final Value<double?> minimumFps;
  final Value<double?> score;
  final Value<int> durationMs;
  final Value<String?> notes;
  final Value<DateTime> ranAt;
  const BenchmarksCompanion({
    this.id = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.emulatorId = const Value.absent(),
    this.consoleId = const Value.absent(),
    this.gameId = const Value.absent(),
    this.benchmarkType = const Value.absent(),
    this.averageFps = const Value.absent(),
    this.minimumFps = const Value.absent(),
    this.score = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.notes = const Value.absent(),
    this.ranAt = const Value.absent(),
  });
  BenchmarksCompanion.insert({
    this.id = const Value.absent(),
    required int deviceId,
    this.emulatorId = const Value.absent(),
    this.consoleId = const Value.absent(),
    this.gameId = const Value.absent(),
    required String benchmarkType,
    this.averageFps = const Value.absent(),
    this.minimumFps = const Value.absent(),
    this.score = const Value.absent(),
    required int durationMs,
    this.notes = const Value.absent(),
    required DateTime ranAt,
  }) : deviceId = Value(deviceId),
       benchmarkType = Value(benchmarkType),
       durationMs = Value(durationMs),
       ranAt = Value(ranAt);
  static Insertable<BenchmarkRow> custom({
    Expression<int>? id,
    Expression<int>? deviceId,
    Expression<String>? emulatorId,
    Expression<String>? consoleId,
    Expression<int>? gameId,
    Expression<String>? benchmarkType,
    Expression<double>? averageFps,
    Expression<double>? minimumFps,
    Expression<double>? score,
    Expression<int>? durationMs,
    Expression<String>? notes,
    Expression<DateTime>? ranAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (deviceId != null) 'device_id': deviceId,
      if (emulatorId != null) 'emulator_id': emulatorId,
      if (consoleId != null) 'console_id': consoleId,
      if (gameId != null) 'game_id': gameId,
      if (benchmarkType != null) 'benchmark_type': benchmarkType,
      if (averageFps != null) 'average_fps': averageFps,
      if (minimumFps != null) 'minimum_fps': minimumFps,
      if (score != null) 'score': score,
      if (durationMs != null) 'duration_ms': durationMs,
      if (notes != null) 'notes': notes,
      if (ranAt != null) 'ran_at': ranAt,
    });
  }

  BenchmarksCompanion copyWith({
    Value<int>? id,
    Value<int>? deviceId,
    Value<String?>? emulatorId,
    Value<String?>? consoleId,
    Value<int?>? gameId,
    Value<String>? benchmarkType,
    Value<double?>? averageFps,
    Value<double?>? minimumFps,
    Value<double?>? score,
    Value<int>? durationMs,
    Value<String?>? notes,
    Value<DateTime>? ranAt,
  }) {
    return BenchmarksCompanion(
      id: id ?? this.id,
      deviceId: deviceId ?? this.deviceId,
      emulatorId: emulatorId ?? this.emulatorId,
      consoleId: consoleId ?? this.consoleId,
      gameId: gameId ?? this.gameId,
      benchmarkType: benchmarkType ?? this.benchmarkType,
      averageFps: averageFps ?? this.averageFps,
      minimumFps: minimumFps ?? this.minimumFps,
      score: score ?? this.score,
      durationMs: durationMs ?? this.durationMs,
      notes: notes ?? this.notes,
      ranAt: ranAt ?? this.ranAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<int>(deviceId.value);
    }
    if (emulatorId.present) {
      map['emulator_id'] = Variable<String>(emulatorId.value);
    }
    if (consoleId.present) {
      map['console_id'] = Variable<String>(consoleId.value);
    }
    if (gameId.present) {
      map['game_id'] = Variable<int>(gameId.value);
    }
    if (benchmarkType.present) {
      map['benchmark_type'] = Variable<String>(benchmarkType.value);
    }
    if (averageFps.present) {
      map['average_fps'] = Variable<double>(averageFps.value);
    }
    if (minimumFps.present) {
      map['minimum_fps'] = Variable<double>(minimumFps.value);
    }
    if (score.present) {
      map['score'] = Variable<double>(score.value);
    }
    if (durationMs.present) {
      map['duration_ms'] = Variable<int>(durationMs.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (ranAt.present) {
      map['ran_at'] = Variable<DateTime>(ranAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BenchmarksCompanion(')
          ..write('id: $id, ')
          ..write('deviceId: $deviceId, ')
          ..write('emulatorId: $emulatorId, ')
          ..write('consoleId: $consoleId, ')
          ..write('gameId: $gameId, ')
          ..write('benchmarkType: $benchmarkType, ')
          ..write('averageFps: $averageFps, ')
          ..write('minimumFps: $minimumFps, ')
          ..write('score: $score, ')
          ..write('durationMs: $durationMs, ')
          ..write('notes: $notes, ')
          ..write('ranAt: $ranAt')
          ..write(')'))
        .toString();
  }
}

class $AppSettingsTable extends AppSettings
    with TableInfo<$AppSettingsTable, AppSettingRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppSettingRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AppSettingRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSettingRow(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $AppSettingsTable createAlias(String alias) {
    return $AppSettingsTable(attachedDatabase, alias);
  }
}

class AppSettingRow extends DataClass implements Insertable<AppSettingRow> {
  final String key;
  final String value;
  final DateTime updatedAt;
  const AppSettingRow({
    required this.key,
    required this.value,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  AppSettingsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsCompanion(
      key: Value(key),
      value: Value(value),
      updatedAt: Value(updatedAt),
    );
  }

  factory AppSettingRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSettingRow(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  AppSettingRow copyWith({String? key, String? value, DateTime? updatedAt}) =>
      AppSettingRow(
        key: key ?? this.key,
        value: value ?? this.value,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  AppSettingRow copyWithCompanion(AppSettingsCompanion data) {
    return AppSettingRow(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingRow(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSettingRow &&
          other.key == this.key &&
          other.value == this.value &&
          other.updatedAt == this.updatedAt);
}

class AppSettingsCompanion extends UpdateCompanion<AppSettingRow> {
  final Value<String> key;
  final Value<String> value;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const AppSettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    required String key,
    required String value,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value),
       updatedAt = Value(updatedAt);
  static Insertable<AppSettingRow> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppSettingsCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return AppSettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $DevicesTable devices = $DevicesTable(this);
  late final $DeviceHardwareProfilesTable deviceHardwareProfiles =
      $DeviceHardwareProfilesTable(this);
  late final $DeviceCompatibilityTable deviceCompatibility =
      $DeviceCompatibilityTable(this);
  late final $EmulatorsTable emulators = $EmulatorsTable(this);
  late final $ConsolesTable consoles = $ConsolesTable(this);
  late final $GamesTable games = $GamesTable(this);
  late final $CompatibilityTestResultsTable compatibilityTestResults =
      $CompatibilityTestResultsTable(this);
  late final $EmulatorProfilesTable emulatorProfiles = $EmulatorProfilesTable(
    this,
  );
  late final $EmulatorAdaptersTable emulatorAdapters = $EmulatorAdaptersTable(
    this,
  );
  late final $StorageDevicesTable storageDevices = $StorageDevicesTable(this);
  late final $GameFilesTable gameFiles = $GameFilesTable(this);
  late final $GameMetadataTable gameMetadata = $GameMetadataTable(this);
  late final $GameArtworksTable gameArtworks = $GameArtworksTable(this);
  late final $FavoritesTable favorites = $FavoritesTable(this);
  late final $GameHistoryTable gameHistory = $GameHistoryTable(this);
  late final $ControllerDevicesTable controllerDevices =
      $ControllerDevicesTable(this);
  late final $ControllerProfilesTable controllerProfiles =
      $ControllerProfilesTable(this);
  late final $ControllerMappingsTable controllerMappings =
      $ControllerMappingsTable(this);
  late final $SourceConnectorsTable sourceConnectors = $SourceConnectorsTable(
    this,
  );
  late final $GameSourcesTable gameSources = $GameSourcesTable(this);
  late final $DownloadQueueTable downloadQueue = $DownloadQueueTable(this);
  late final $DownloadHistoryTable downloadHistory = $DownloadHistoryTable(
    this,
  );
  late final $SaveStatesTable saveStates = $SaveStatesTable(this);
  late final $SaveBackupsTable saveBackups = $SaveBackupsTable(this);
  late final $BenchmarksTable benchmarks = $BenchmarksTable(this);
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  late final Index idxHwProfilesDevice = Index(
    'idx_hw_profiles_device',
    'CREATE INDEX idx_hw_profiles_device ON device_hardware_profiles (device_id, scanned_at)',
  );
  late final Index idxCompatModel = Index(
    'idx_compat_model',
    'CREATE INDEX idx_compat_model ON device_compatibility (manufacturer, model)',
  );
  late final Index idxGamesConsole = Index(
    'idx_games_console',
    'CREATE INDEX idx_games_console ON games (console_id)',
  );
  late final Index idxGamesLastPlayed = Index(
    'idx_games_last_played',
    'CREATE INDEX idx_games_last_played ON games (last_played_at)',
  );
  late final Index idxGameFilesHash = Index(
    'idx_game_files_hash',
    'CREATE INDEX idx_game_files_hash ON game_files (sha1)',
  );
  late final Index idxGameFilesRoot = Index(
    'idx_game_files_root',
    'CREATE INDEX idx_game_files_root ON game_files (root_uri)',
  );
  late final Index idxGameFilesGame = Index(
    'idx_game_files_game',
    'CREATE INDEX idx_game_files_game ON game_files (game_id)',
  );
  late final Index idxHistoryStarted = Index(
    'idx_history_started',
    'CREATE INDEX idx_history_started ON game_history (started_at)',
  );
  late final Index idxDownloadStatus = Index(
    'idx_download_status',
    'CREATE INDEX idx_download_status ON download_queue (status)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    devices,
    deviceHardwareProfiles,
    deviceCompatibility,
    emulators,
    consoles,
    games,
    compatibilityTestResults,
    emulatorProfiles,
    emulatorAdapters,
    storageDevices,
    gameFiles,
    gameMetadata,
    gameArtworks,
    favorites,
    gameHistory,
    controllerDevices,
    controllerProfiles,
    controllerMappings,
    sourceConnectors,
    gameSources,
    downloadQueue,
    downloadHistory,
    saveStates,
    saveBackups,
    benchmarks,
    appSettings,
    idxHwProfilesDevice,
    idxCompatModel,
    idxGamesConsole,
    idxGamesLastPlayed,
    idxGameFilesHash,
    idxGameFilesRoot,
    idxGameFilesGame,
    idxHistoryStarted,
    idxDownloadStatus,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'devices',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [
        TableUpdate('device_hardware_profiles', kind: UpdateKind.delete),
      ],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'devices',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [
        TableUpdate('compatibility_test_results', kind: UpdateKind.delete),
      ],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'games',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [
        TableUpdate('compatibility_test_results', kind: UpdateKind.update),
      ],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'emulators',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('emulator_profiles', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'emulators',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('emulator_adapters', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'games',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('game_files', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'storage_devices',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('game_files', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'games',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('game_metadata', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'games',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('game_artworks', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'games',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('favorites', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'games',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('game_history', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'controller_profiles',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('controller_mappings', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'game_sources',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('download_queue', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'game_sources',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('download_history', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'games',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('save_states', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'games',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('save_backups', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'save_states',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('save_backups', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'devices',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('benchmarks', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'games',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('benchmarks', kind: UpdateKind.update)],
    ),
  ]);
}

typedef $$DevicesTableCreateCompanionBuilder = DevicesCompanion Function({
  Value<int> id,
  required String deviceKey,
  Value<String?> manufacturer,
  Value<String?> model,
  Value<String?> deviceName,
  Value<String?> androidVersion,
  Value<int?> sdkInt,
  Value<String?> buildFingerprint,
  required DateTime firstSeenAt,
  required DateTime lastSeenAt,
});
typedef $$DevicesTableUpdateCompanionBuilder = DevicesCompanion Function({
  Value<int> id,
  Value<String> deviceKey,
  Value<String?> manufacturer,
  Value<String?> model,
  Value<String?> deviceName,
  Value<String?> androidVersion,
  Value<int?> sdkInt,
  Value<String?> buildFingerprint,
  Value<DateTime> firstSeenAt,
  Value<DateTime> lastSeenAt,
});

final class $$DevicesTableReferences
    extends BaseReferences<_$AppDatabase, $DevicesTable, DeviceRow> {
  $$DevicesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<
    $DeviceHardwareProfilesTable,
    List<HardwareProfileRow>
  >
  _deviceHardwareProfilesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.deviceHardwareProfiles,
        aliasName: 'devices__id__device_hardware_profiles__device_id',
      );

  $$DeviceHardwareProfilesTableProcessedTableManager
  get deviceHardwareProfilesRefs {
    final manager = $$DeviceHardwareProfilesTableTableManager(
      $_db,
      $_db.deviceHardwareProfiles,
    ).filter((f) => f.deviceId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _deviceHardwareProfilesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $CompatibilityTestResultsTable,
    List<CompatibilityTestResultRow>
  >
  _compatibilityTestResultsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.compatibilityTestResults,
        aliasName: 'devices__id__compatibility_test_results__device_id',
      );

  $$CompatibilityTestResultsTableProcessedTableManager
  get compatibilityTestResultsRefs {
    final manager = $$CompatibilityTestResultsTableTableManager(
      $_db,
      $_db.compatibilityTestResults,
    ).filter((f) => f.deviceId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _compatibilityTestResultsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$BenchmarksTable, List<BenchmarkRow>>
  _benchmarksRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.benchmarks,
    aliasName: 'devices__id__benchmarks__device_id',
  );

  $$BenchmarksTableProcessedTableManager get benchmarksRefs {
    final manager = $$BenchmarksTableTableManager(
      $_db,
      $_db.benchmarks,
    ).filter((f) => f.deviceId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_benchmarksRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$DevicesTableFilterComposer
    extends Composer<_$AppDatabase, $DevicesTable> {
  $$DevicesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceKey => $composableBuilder(
    column: $table.deviceKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get manufacturer => $composableBuilder(
    column: $table.manufacturer,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get model => $composableBuilder(
    column: $table.model,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceName => $composableBuilder(
    column: $table.deviceName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get androidVersion => $composableBuilder(
    column: $table.androidVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sdkInt => $composableBuilder(
    column: $table.sdkInt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get buildFingerprint => $composableBuilder(
    column: $table.buildFingerprint,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get firstSeenAt => $composableBuilder(
    column: $table.firstSeenAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSeenAt => $composableBuilder(
    column: $table.lastSeenAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> deviceHardwareProfilesRefs(
    Expression<bool> Function($$DeviceHardwareProfilesTableFilterComposer f) f,
  ) {
    final $$DeviceHardwareProfilesTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.deviceHardwareProfiles,
          getReferencedColumn: (t) => t.deviceId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$DeviceHardwareProfilesTableFilterComposer(
                $db: $db,
                $table: $db.deviceHardwareProfiles,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> compatibilityTestResultsRefs(
    Expression<bool> Function($$CompatibilityTestResultsTableFilterComposer f)
    f,
  ) {
    final $$CompatibilityTestResultsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.compatibilityTestResults,
          getReferencedColumn: (t) => t.deviceId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CompatibilityTestResultsTableFilterComposer(
                $db: $db,
                $table: $db.compatibilityTestResults,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> benchmarksRefs(
    Expression<bool> Function($$BenchmarksTableFilterComposer f) f,
  ) {
    final $$BenchmarksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.benchmarks,
      getReferencedColumn: (t) => t.deviceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BenchmarksTableFilterComposer(
            $db: $db,
            $table: $db.benchmarks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$DevicesTableOrderingComposer
    extends Composer<_$AppDatabase, $DevicesTable> {
  $$DevicesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceKey => $composableBuilder(
    column: $table.deviceKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get manufacturer => $composableBuilder(
    column: $table.manufacturer,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get model => $composableBuilder(
    column: $table.model,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceName => $composableBuilder(
    column: $table.deviceName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get androidVersion => $composableBuilder(
    column: $table.androidVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sdkInt => $composableBuilder(
    column: $table.sdkInt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get buildFingerprint => $composableBuilder(
    column: $table.buildFingerprint,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get firstSeenAt => $composableBuilder(
    column: $table.firstSeenAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSeenAt => $composableBuilder(
    column: $table.lastSeenAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DevicesTableAnnotationComposer
    extends Composer<_$AppDatabase, $DevicesTable> {
  $$DevicesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get deviceKey =>
      $composableBuilder(column: $table.deviceKey, builder: (column) => column);

  GeneratedColumn<String> get manufacturer => $composableBuilder(
    column: $table.manufacturer,
    builder: (column) => column,
  );

  GeneratedColumn<String> get model =>
      $composableBuilder(column: $table.model, builder: (column) => column);

  GeneratedColumn<String> get deviceName => $composableBuilder(
    column: $table.deviceName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get androidVersion => $composableBuilder(
    column: $table.androidVersion,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sdkInt =>
      $composableBuilder(column: $table.sdkInt, builder: (column) => column);

  GeneratedColumn<String> get buildFingerprint => $composableBuilder(
    column: $table.buildFingerprint,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get firstSeenAt => $composableBuilder(
    column: $table.firstSeenAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastSeenAt => $composableBuilder(
    column: $table.lastSeenAt,
    builder: (column) => column,
  );

  Expression<T> deviceHardwareProfilesRefs<T extends Object>(
    Expression<T> Function($$DeviceHardwareProfilesTableAnnotationComposer a) f,
  ) {
    final $$DeviceHardwareProfilesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.deviceHardwareProfiles,
          getReferencedColumn: (t) => t.deviceId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$DeviceHardwareProfilesTableAnnotationComposer(
                $db: $db,
                $table: $db.deviceHardwareProfiles,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> compatibilityTestResultsRefs<T extends Object>(
    Expression<T> Function($$CompatibilityTestResultsTableAnnotationComposer a)
    f,
  ) {
    final $$CompatibilityTestResultsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.compatibilityTestResults,
          getReferencedColumn: (t) => t.deviceId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CompatibilityTestResultsTableAnnotationComposer(
                $db: $db,
                $table: $db.compatibilityTestResults,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> benchmarksRefs<T extends Object>(
    Expression<T> Function($$BenchmarksTableAnnotationComposer a) f,
  ) {
    final $$BenchmarksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.benchmarks,
      getReferencedColumn: (t) => t.deviceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BenchmarksTableAnnotationComposer(
            $db: $db,
            $table: $db.benchmarks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$DevicesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DevicesTable,
          DeviceRow,
          $$DevicesTableFilterComposer,
          $$DevicesTableOrderingComposer,
          $$DevicesTableAnnotationComposer,
          $$DevicesTableCreateCompanionBuilder,
          $$DevicesTableUpdateCompanionBuilder,
          (DeviceRow, $$DevicesTableReferences),
          DeviceRow,
          PrefetchHooks Function({
            bool deviceHardwareProfilesRefs,
            bool compatibilityTestResultsRefs,
            bool benchmarksRefs,
          })
        > {
  $$DevicesTableTableManager(_$AppDatabase db, $DevicesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DevicesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DevicesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DevicesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> deviceKey = const Value.absent(),
                Value<String?> manufacturer = const Value.absent(),
                Value<String?> model = const Value.absent(),
                Value<String?> deviceName = const Value.absent(),
                Value<String?> androidVersion = const Value.absent(),
                Value<int?> sdkInt = const Value.absent(),
                Value<String?> buildFingerprint = const Value.absent(),
                Value<DateTime> firstSeenAt = const Value.absent(),
                Value<DateTime> lastSeenAt = const Value.absent(),
              }) => DevicesCompanion(
                id: id,
                deviceKey: deviceKey,
                manufacturer: manufacturer,
                model: model,
                deviceName: deviceName,
                androidVersion: androidVersion,
                sdkInt: sdkInt,
                buildFingerprint: buildFingerprint,
                firstSeenAt: firstSeenAt,
                lastSeenAt: lastSeenAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String deviceKey,
                Value<String?> manufacturer = const Value.absent(),
                Value<String?> model = const Value.absent(),
                Value<String?> deviceName = const Value.absent(),
                Value<String?> androidVersion = const Value.absent(),
                Value<int?> sdkInt = const Value.absent(),
                Value<String?> buildFingerprint = const Value.absent(),
                required DateTime firstSeenAt,
                required DateTime lastSeenAt,
              }) => DevicesCompanion.insert(
                id: id,
                deviceKey: deviceKey,
                manufacturer: manufacturer,
                model: model,
                deviceName: deviceName,
                androidVersion: androidVersion,
                sdkInt: sdkInt,
                buildFingerprint: buildFingerprint,
                firstSeenAt: firstSeenAt,
                lastSeenAt: lastSeenAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DevicesTable, DeviceRow>(table),
                  $$DevicesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                deviceHardwareProfilesRefs = false,
                compatibilityTestResultsRefs = false,
                benchmarksRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (deviceHardwareProfilesRefs) db.deviceHardwareProfiles,
                    if (compatibilityTestResultsRefs)
                      db.compatibilityTestResults,
                    if (benchmarksRefs) db.benchmarks,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (deviceHardwareProfilesRefs)
                        await $_getPrefetchedDataByColumns<
                          DeviceRow,
                          $DevicesTable,
                          HardwareProfileRow,
                          $DeviceHardwareProfilesTable
                        >(
                          currentTable: table,
                          referencedTable: $$DevicesTableReferences
                              ._deviceHardwareProfilesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$DevicesTableReferences(
                                db,
                                table,
                                p0,
                              ).deviceHardwareProfilesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'device_id',
                          typedResults: items,
                        ),
                      if (compatibilityTestResultsRefs)
                        await $_getPrefetchedDataByColumns<
                          DeviceRow,
                          $DevicesTable,
                          CompatibilityTestResultRow,
                          $CompatibilityTestResultsTable
                        >(
                          currentTable: table,
                          referencedTable: $$DevicesTableReferences
                              ._compatibilityTestResultsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$DevicesTableReferences(
                                db,
                                table,
                                p0,
                              ).compatibilityTestResultsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'device_id',
                          typedResults: items,
                        ),
                      if (benchmarksRefs)
                        await $_getPrefetchedDataByColumns<
                          DeviceRow,
                          $DevicesTable,
                          BenchmarkRow,
                          $BenchmarksTable
                        >(
                          currentTable: table,
                          referencedTable: $$DevicesTableReferences
                              ._benchmarksRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$DevicesTableReferences(
                                db,
                                table,
                                p0,
                              ).benchmarksRefs,
                          currentColumn: 'id',
                          referencedColumn: 'device_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$DevicesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DevicesTable,
      DeviceRow,
      $$DevicesTableFilterComposer,
      $$DevicesTableOrderingComposer,
      $$DevicesTableAnnotationComposer,
      $$DevicesTableCreateCompanionBuilder,
      $$DevicesTableUpdateCompanionBuilder,
      (DeviceRow, $$DevicesTableReferences),
      DeviceRow,
      PrefetchHooks Function({
        bool deviceHardwareProfilesRefs,
        bool compatibilityTestResultsRefs,
        bool benchmarksRefs,
      })
    >;
typedef $$DeviceHardwareProfilesTableCreateCompanionBuilder =
    DeviceHardwareProfilesCompanion Function({
      Value<int> id,
      required int deviceId,
      required DateTime scannedAt,
      required String tier,
      required String confidence,
      required String abis,
      Value<String?> cpuDescription,
      Value<int?> cpuCores,
      Value<int?> totalRamBytes,
      Value<String?> glRenderer,
      Value<String?> glEsVersion,
      Value<bool?> vulkanSupported,
      Value<int?> displayWidth,
      Value<int?> displayHeight,
      required String rawJson,
    });
typedef $$DeviceHardwareProfilesTableUpdateCompanionBuilder =
    DeviceHardwareProfilesCompanion Function({
      Value<int> id,
      Value<int> deviceId,
      Value<DateTime> scannedAt,
      Value<String> tier,
      Value<String> confidence,
      Value<String> abis,
      Value<String?> cpuDescription,
      Value<int?> cpuCores,
      Value<int?> totalRamBytes,
      Value<String?> glRenderer,
      Value<String?> glEsVersion,
      Value<bool?> vulkanSupported,
      Value<int?> displayWidth,
      Value<int?> displayHeight,
      Value<String> rawJson,
    });

final class $$DeviceHardwareProfilesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $DeviceHardwareProfilesTable,
          HardwareProfileRow
        > {
  $$DeviceHardwareProfilesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $DevicesTable _deviceIdTable(_$AppDatabase db) => db.devices
      .createAlias('device_hardware_profiles__device_id__devices__id');

  $$DevicesTableProcessedTableManager get deviceId {
    final $_column = $_itemColumn<int>('device_id')!;

    final manager = $$DevicesTableTableManager(
      $_db,
      $_db.devices,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_deviceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$DeviceHardwareProfilesTableFilterComposer
    extends Composer<_$AppDatabase, $DeviceHardwareProfilesTable> {
  $$DeviceHardwareProfilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get scannedAt => $composableBuilder(
    column: $table.scannedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tier => $composableBuilder(
    column: $table.tier,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get abis => $composableBuilder(
    column: $table.abis,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cpuDescription => $composableBuilder(
    column: $table.cpuDescription,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cpuCores => $composableBuilder(
    column: $table.cpuCores,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalRamBytes => $composableBuilder(
    column: $table.totalRamBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get glRenderer => $composableBuilder(
    column: $table.glRenderer,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get glEsVersion => $composableBuilder(
    column: $table.glEsVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get vulkanSupported => $composableBuilder(
    column: $table.vulkanSupported,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get displayWidth => $composableBuilder(
    column: $table.displayWidth,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get displayHeight => $composableBuilder(
    column: $table.displayHeight,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rawJson => $composableBuilder(
    column: $table.rawJson,
    builder: (column) => ColumnFilters(column),
  );

  $$DevicesTableFilterComposer get deviceId {
    final $$DevicesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.deviceId,
      referencedTable: $db.devices,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DevicesTableFilterComposer(
            $db: $db,
            $table: $db.devices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DeviceHardwareProfilesTableOrderingComposer
    extends Composer<_$AppDatabase, $DeviceHardwareProfilesTable> {
  $$DeviceHardwareProfilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get scannedAt => $composableBuilder(
    column: $table.scannedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tier => $composableBuilder(
    column: $table.tier,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get abis => $composableBuilder(
    column: $table.abis,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cpuDescription => $composableBuilder(
    column: $table.cpuDescription,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cpuCores => $composableBuilder(
    column: $table.cpuCores,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalRamBytes => $composableBuilder(
    column: $table.totalRamBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get glRenderer => $composableBuilder(
    column: $table.glRenderer,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get glEsVersion => $composableBuilder(
    column: $table.glEsVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get vulkanSupported => $composableBuilder(
    column: $table.vulkanSupported,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get displayWidth => $composableBuilder(
    column: $table.displayWidth,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get displayHeight => $composableBuilder(
    column: $table.displayHeight,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rawJson => $composableBuilder(
    column: $table.rawJson,
    builder: (column) => ColumnOrderings(column),
  );

  $$DevicesTableOrderingComposer get deviceId {
    final $$DevicesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.deviceId,
      referencedTable: $db.devices,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DevicesTableOrderingComposer(
            $db: $db,
            $table: $db.devices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DeviceHardwareProfilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $DeviceHardwareProfilesTable> {
  $$DeviceHardwareProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get scannedAt =>
      $composableBuilder(column: $table.scannedAt, builder: (column) => column);

  GeneratedColumn<String> get tier =>
      $composableBuilder(column: $table.tier, builder: (column) => column);

  GeneratedColumn<String> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => column,
  );

  GeneratedColumn<String> get abis =>
      $composableBuilder(column: $table.abis, builder: (column) => column);

  GeneratedColumn<String> get cpuDescription => $composableBuilder(
    column: $table.cpuDescription,
    builder: (column) => column,
  );

  GeneratedColumn<int> get cpuCores =>
      $composableBuilder(column: $table.cpuCores, builder: (column) => column);

  GeneratedColumn<int> get totalRamBytes => $composableBuilder(
    column: $table.totalRamBytes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get glRenderer => $composableBuilder(
    column: $table.glRenderer,
    builder: (column) => column,
  );

  GeneratedColumn<String> get glEsVersion => $composableBuilder(
    column: $table.glEsVersion,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get vulkanSupported => $composableBuilder(
    column: $table.vulkanSupported,
    builder: (column) => column,
  );

  GeneratedColumn<int> get displayWidth => $composableBuilder(
    column: $table.displayWidth,
    builder: (column) => column,
  );

  GeneratedColumn<int> get displayHeight => $composableBuilder(
    column: $table.displayHeight,
    builder: (column) => column,
  );

  GeneratedColumn<String> get rawJson =>
      $composableBuilder(column: $table.rawJson, builder: (column) => column);

  $$DevicesTableAnnotationComposer get deviceId {
    final $$DevicesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.deviceId,
      referencedTable: $db.devices,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DevicesTableAnnotationComposer(
            $db: $db,
            $table: $db.devices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DeviceHardwareProfilesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DeviceHardwareProfilesTable,
          HardwareProfileRow,
          $$DeviceHardwareProfilesTableFilterComposer,
          $$DeviceHardwareProfilesTableOrderingComposer,
          $$DeviceHardwareProfilesTableAnnotationComposer,
          $$DeviceHardwareProfilesTableCreateCompanionBuilder,
          $$DeviceHardwareProfilesTableUpdateCompanionBuilder,
          (HardwareProfileRow, $$DeviceHardwareProfilesTableReferences),
          HardwareProfileRow,
          PrefetchHooks Function({bool deviceId})
        > {
  $$DeviceHardwareProfilesTableTableManager(
    _$AppDatabase db,
    $DeviceHardwareProfilesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DeviceHardwareProfilesTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$DeviceHardwareProfilesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$DeviceHardwareProfilesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> deviceId = const Value.absent(),
                Value<DateTime> scannedAt = const Value.absent(),
                Value<String> tier = const Value.absent(),
                Value<String> confidence = const Value.absent(),
                Value<String> abis = const Value.absent(),
                Value<String?> cpuDescription = const Value.absent(),
                Value<int?> cpuCores = const Value.absent(),
                Value<int?> totalRamBytes = const Value.absent(),
                Value<String?> glRenderer = const Value.absent(),
                Value<String?> glEsVersion = const Value.absent(),
                Value<bool?> vulkanSupported = const Value.absent(),
                Value<int?> displayWidth = const Value.absent(),
                Value<int?> displayHeight = const Value.absent(),
                Value<String> rawJson = const Value.absent(),
              }) => DeviceHardwareProfilesCompanion(
                id: id,
                deviceId: deviceId,
                scannedAt: scannedAt,
                tier: tier,
                confidence: confidence,
                abis: abis,
                cpuDescription: cpuDescription,
                cpuCores: cpuCores,
                totalRamBytes: totalRamBytes,
                glRenderer: glRenderer,
                glEsVersion: glEsVersion,
                vulkanSupported: vulkanSupported,
                displayWidth: displayWidth,
                displayHeight: displayHeight,
                rawJson: rawJson,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int deviceId,
                required DateTime scannedAt,
                required String tier,
                required String confidence,
                required String abis,
                Value<String?> cpuDescription = const Value.absent(),
                Value<int?> cpuCores = const Value.absent(),
                Value<int?> totalRamBytes = const Value.absent(),
                Value<String?> glRenderer = const Value.absent(),
                Value<String?> glEsVersion = const Value.absent(),
                Value<bool?> vulkanSupported = const Value.absent(),
                Value<int?> displayWidth = const Value.absent(),
                Value<int?> displayHeight = const Value.absent(),
                required String rawJson,
              }) => DeviceHardwareProfilesCompanion.insert(
                id: id,
                deviceId: deviceId,
                scannedAt: scannedAt,
                tier: tier,
                confidence: confidence,
                abis: abis,
                cpuDescription: cpuDescription,
                cpuCores: cpuCores,
                totalRamBytes: totalRamBytes,
                glRenderer: glRenderer,
                glEsVersion: glEsVersion,
                vulkanSupported: vulkanSupported,
                displayWidth: displayWidth,
                displayHeight: displayHeight,
                rawJson: rawJson,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DeviceHardwareProfilesTable, HardwareProfileRow>(
                    table,
                  ),
                  $$DeviceHardwareProfilesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({deviceId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (deviceId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.deviceId,
                        referencedTable: $$DeviceHardwareProfilesTableReferences
                            ._deviceIdTable(db),
                        referencedColumn:
                            $$DeviceHardwareProfilesTableReferences
                                ._deviceIdTable(db)
                                .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$DeviceHardwareProfilesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DeviceHardwareProfilesTable,
      HardwareProfileRow,
      $$DeviceHardwareProfilesTableFilterComposer,
      $$DeviceHardwareProfilesTableOrderingComposer,
      $$DeviceHardwareProfilesTableAnnotationComposer,
      $$DeviceHardwareProfilesTableCreateCompanionBuilder,
      $$DeviceHardwareProfilesTableUpdateCompanionBuilder,
      (HardwareProfileRow, $$DeviceHardwareProfilesTableReferences),
      HardwareProfileRow,
      PrefetchHooks Function({bool deviceId})
    >;
typedef $$DeviceCompatibilityTableCreateCompanionBuilder =
    DeviceCompatibilityCompanion Function({
      Value<int> id,
      required String source,
      required String manufacturer,
      required String model,
      Value<String?> chipset,
      Value<String?> cpuArchitecture,
      Value<String?> cpuCharacteristics,
      Value<String?> gpu,
      Value<int?> ramBytes,
      Value<String?> androidVersion,
      Value<String?> graphicsApi,
      Value<String?> emulatorId,
      Value<String?> consoleId,
      Value<String?> testedGame,
      Value<String?> testResult,
      Value<String?> performanceNotes,
      Value<String?> knownLimitations,
      required DateTime compatibilityDate,
      Value<String?> importBatch,
    });
typedef $$DeviceCompatibilityTableUpdateCompanionBuilder =
    DeviceCompatibilityCompanion Function({
      Value<int> id,
      Value<String> source,
      Value<String> manufacturer,
      Value<String> model,
      Value<String?> chipset,
      Value<String?> cpuArchitecture,
      Value<String?> cpuCharacteristics,
      Value<String?> gpu,
      Value<int?> ramBytes,
      Value<String?> androidVersion,
      Value<String?> graphicsApi,
      Value<String?> emulatorId,
      Value<String?> consoleId,
      Value<String?> testedGame,
      Value<String?> testResult,
      Value<String?> performanceNotes,
      Value<String?> knownLimitations,
      Value<DateTime> compatibilityDate,
      Value<String?> importBatch,
    });

class $$DeviceCompatibilityTableFilterComposer
    extends Composer<_$AppDatabase, $DeviceCompatibilityTable> {
  $$DeviceCompatibilityTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get manufacturer => $composableBuilder(
    column: $table.manufacturer,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get model => $composableBuilder(
    column: $table.model,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get chipset => $composableBuilder(
    column: $table.chipset,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cpuArchitecture => $composableBuilder(
    column: $table.cpuArchitecture,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cpuCharacteristics => $composableBuilder(
    column: $table.cpuCharacteristics,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get gpu => $composableBuilder(
    column: $table.gpu,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ramBytes => $composableBuilder(
    column: $table.ramBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get androidVersion => $composableBuilder(
    column: $table.androidVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get graphicsApi => $composableBuilder(
    column: $table.graphicsApi,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get emulatorId => $composableBuilder(
    column: $table.emulatorId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get consoleId => $composableBuilder(
    column: $table.consoleId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get testedGame => $composableBuilder(
    column: $table.testedGame,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get testResult => $composableBuilder(
    column: $table.testResult,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get performanceNotes => $composableBuilder(
    column: $table.performanceNotes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get knownLimitations => $composableBuilder(
    column: $table.knownLimitations,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get compatibilityDate => $composableBuilder(
    column: $table.compatibilityDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get importBatch => $composableBuilder(
    column: $table.importBatch,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DeviceCompatibilityTableOrderingComposer
    extends Composer<_$AppDatabase, $DeviceCompatibilityTable> {
  $$DeviceCompatibilityTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get manufacturer => $composableBuilder(
    column: $table.manufacturer,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get model => $composableBuilder(
    column: $table.model,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get chipset => $composableBuilder(
    column: $table.chipset,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cpuArchitecture => $composableBuilder(
    column: $table.cpuArchitecture,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cpuCharacteristics => $composableBuilder(
    column: $table.cpuCharacteristics,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get gpu => $composableBuilder(
    column: $table.gpu,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ramBytes => $composableBuilder(
    column: $table.ramBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get androidVersion => $composableBuilder(
    column: $table.androidVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get graphicsApi => $composableBuilder(
    column: $table.graphicsApi,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get emulatorId => $composableBuilder(
    column: $table.emulatorId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get consoleId => $composableBuilder(
    column: $table.consoleId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get testedGame => $composableBuilder(
    column: $table.testedGame,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get testResult => $composableBuilder(
    column: $table.testResult,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get performanceNotes => $composableBuilder(
    column: $table.performanceNotes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get knownLimitations => $composableBuilder(
    column: $table.knownLimitations,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get compatibilityDate => $composableBuilder(
    column: $table.compatibilityDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get importBatch => $composableBuilder(
    column: $table.importBatch,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DeviceCompatibilityTableAnnotationComposer
    extends Composer<_$AppDatabase, $DeviceCompatibilityTable> {
  $$DeviceCompatibilityTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get manufacturer => $composableBuilder(
    column: $table.manufacturer,
    builder: (column) => column,
  );

  GeneratedColumn<String> get model =>
      $composableBuilder(column: $table.model, builder: (column) => column);

  GeneratedColumn<String> get chipset =>
      $composableBuilder(column: $table.chipset, builder: (column) => column);

  GeneratedColumn<String> get cpuArchitecture => $composableBuilder(
    column: $table.cpuArchitecture,
    builder: (column) => column,
  );

  GeneratedColumn<String> get cpuCharacteristics => $composableBuilder(
    column: $table.cpuCharacteristics,
    builder: (column) => column,
  );

  GeneratedColumn<String> get gpu =>
      $composableBuilder(column: $table.gpu, builder: (column) => column);

  GeneratedColumn<int> get ramBytes =>
      $composableBuilder(column: $table.ramBytes, builder: (column) => column);

  GeneratedColumn<String> get androidVersion => $composableBuilder(
    column: $table.androidVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get graphicsApi => $composableBuilder(
    column: $table.graphicsApi,
    builder: (column) => column,
  );

  GeneratedColumn<String> get emulatorId => $composableBuilder(
    column: $table.emulatorId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get consoleId =>
      $composableBuilder(column: $table.consoleId, builder: (column) => column);

  GeneratedColumn<String> get testedGame => $composableBuilder(
    column: $table.testedGame,
    builder: (column) => column,
  );

  GeneratedColumn<String> get testResult => $composableBuilder(
    column: $table.testResult,
    builder: (column) => column,
  );

  GeneratedColumn<String> get performanceNotes => $composableBuilder(
    column: $table.performanceNotes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get knownLimitations => $composableBuilder(
    column: $table.knownLimitations,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get compatibilityDate => $composableBuilder(
    column: $table.compatibilityDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get importBatch => $composableBuilder(
    column: $table.importBatch,
    builder: (column) => column,
  );
}

class $$DeviceCompatibilityTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DeviceCompatibilityTable,
          DeviceCompatibilityRow,
          $$DeviceCompatibilityTableFilterComposer,
          $$DeviceCompatibilityTableOrderingComposer,
          $$DeviceCompatibilityTableAnnotationComposer,
          $$DeviceCompatibilityTableCreateCompanionBuilder,
          $$DeviceCompatibilityTableUpdateCompanionBuilder,
          (
            DeviceCompatibilityRow,
            BaseReferences<
              _$AppDatabase,
              $DeviceCompatibilityTable,
              DeviceCompatibilityRow
            >,
          ),
          DeviceCompatibilityRow,
          PrefetchHooks Function()
        > {
  $$DeviceCompatibilityTableTableManager(
    _$AppDatabase db,
    $DeviceCompatibilityTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DeviceCompatibilityTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DeviceCompatibilityTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$DeviceCompatibilityTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<String> manufacturer = const Value.absent(),
                Value<String> model = const Value.absent(),
                Value<String?> chipset = const Value.absent(),
                Value<String?> cpuArchitecture = const Value.absent(),
                Value<String?> cpuCharacteristics = const Value.absent(),
                Value<String?> gpu = const Value.absent(),
                Value<int?> ramBytes = const Value.absent(),
                Value<String?> androidVersion = const Value.absent(),
                Value<String?> graphicsApi = const Value.absent(),
                Value<String?> emulatorId = const Value.absent(),
                Value<String?> consoleId = const Value.absent(),
                Value<String?> testedGame = const Value.absent(),
                Value<String?> testResult = const Value.absent(),
                Value<String?> performanceNotes = const Value.absent(),
                Value<String?> knownLimitations = const Value.absent(),
                Value<DateTime> compatibilityDate = const Value.absent(),
                Value<String?> importBatch = const Value.absent(),
              }) => DeviceCompatibilityCompanion(
                id: id,
                source: source,
                manufacturer: manufacturer,
                model: model,
                chipset: chipset,
                cpuArchitecture: cpuArchitecture,
                cpuCharacteristics: cpuCharacteristics,
                gpu: gpu,
                ramBytes: ramBytes,
                androidVersion: androidVersion,
                graphicsApi: graphicsApi,
                emulatorId: emulatorId,
                consoleId: consoleId,
                testedGame: testedGame,
                testResult: testResult,
                performanceNotes: performanceNotes,
                knownLimitations: knownLimitations,
                compatibilityDate: compatibilityDate,
                importBatch: importBatch,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String source,
                required String manufacturer,
                required String model,
                Value<String?> chipset = const Value.absent(),
                Value<String?> cpuArchitecture = const Value.absent(),
                Value<String?> cpuCharacteristics = const Value.absent(),
                Value<String?> gpu = const Value.absent(),
                Value<int?> ramBytes = const Value.absent(),
                Value<String?> androidVersion = const Value.absent(),
                Value<String?> graphicsApi = const Value.absent(),
                Value<String?> emulatorId = const Value.absent(),
                Value<String?> consoleId = const Value.absent(),
                Value<String?> testedGame = const Value.absent(),
                Value<String?> testResult = const Value.absent(),
                Value<String?> performanceNotes = const Value.absent(),
                Value<String?> knownLimitations = const Value.absent(),
                required DateTime compatibilityDate,
                Value<String?> importBatch = const Value.absent(),
              }) => DeviceCompatibilityCompanion.insert(
                id: id,
                source: source,
                manufacturer: manufacturer,
                model: model,
                chipset: chipset,
                cpuArchitecture: cpuArchitecture,
                cpuCharacteristics: cpuCharacteristics,
                gpu: gpu,
                ramBytes: ramBytes,
                androidVersion: androidVersion,
                graphicsApi: graphicsApi,
                emulatorId: emulatorId,
                consoleId: consoleId,
                testedGame: testedGame,
                testResult: testResult,
                performanceNotes: performanceNotes,
                knownLimitations: knownLimitations,
                compatibilityDate: compatibilityDate,
                importBatch: importBatch,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<
                    $DeviceCompatibilityTable,
                    DeviceCompatibilityRow
                  >(table),
                  BaseReferences<
                    _$AppDatabase,
                    $DeviceCompatibilityTable,
                    DeviceCompatibilityRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DeviceCompatibilityTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DeviceCompatibilityTable,
      DeviceCompatibilityRow,
      $$DeviceCompatibilityTableFilterComposer,
      $$DeviceCompatibilityTableOrderingComposer,
      $$DeviceCompatibilityTableAnnotationComposer,
      $$DeviceCompatibilityTableCreateCompanionBuilder,
      $$DeviceCompatibilityTableUpdateCompanionBuilder,
      (
        DeviceCompatibilityRow,
        BaseReferences<
          _$AppDatabase,
          $DeviceCompatibilityTable,
          DeviceCompatibilityRow
        >,
      ),
      DeviceCompatibilityRow,
      PrefetchHooks Function()
    >;
typedef $$EmulatorsTableCreateCompanionBuilder = EmulatorsCompanion Function({
  required String id,
  required String name,
  required String license,
  required String strategy,
  Value<bool> requiresArm64,
  Value<int?> minSdk,
  required String consoleIds,
  Value<String?> notes,
  Value<int> rowid,
});
typedef $$EmulatorsTableUpdateCompanionBuilder = EmulatorsCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String> license,
  Value<String> strategy,
  Value<bool> requiresArm64,
  Value<int?> minSdk,
  Value<String> consoleIds,
  Value<String?> notes,
  Value<int> rowid,
});

final class $$EmulatorsTableReferences
    extends BaseReferences<_$AppDatabase, $EmulatorsTable, EmulatorRow> {
  $$EmulatorsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$GamesTable, List<GameRow>> _gamesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.games,
    aliasName: 'emulators__id__games__preferred_emulator_id',
  );

  $$GamesTableProcessedTableManager get gamesRefs {
    final manager = $$GamesTableTableManager($_db, $_db.games).filter(
      (f) => f.preferredEmulatorId.id.sqlEquals($_itemColumn<String>('id')!),
    );

    final cache = $_typedResult.readTableOrNull(_gamesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $CompatibilityTestResultsTable,
    List<CompatibilityTestResultRow>
  >
  _compatibilityTestResultsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.compatibilityTestResults,
        aliasName: 'emulators__id__compatibility_test_results__emulator_id',
      );

  $$CompatibilityTestResultsTableProcessedTableManager
  get compatibilityTestResultsRefs {
    final manager = $$CompatibilityTestResultsTableTableManager(
      $_db,
      $_db.compatibilityTestResults,
    ).filter((f) => f.emulatorId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _compatibilityTestResultsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$EmulatorProfilesTable, List<EmulatorProfileRow>>
  _emulatorProfilesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.emulatorProfiles,
    aliasName: 'emulators__id__emulator_profiles__emulator_id',
  );

  $$EmulatorProfilesTableProcessedTableManager get emulatorProfilesRefs {
    final manager = $$EmulatorProfilesTableTableManager(
      $_db,
      $_db.emulatorProfiles,
    ).filter((f) => f.emulatorId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _emulatorProfilesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$EmulatorAdaptersTable, List<EmulatorAdapterRow>>
  _emulatorAdaptersRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.emulatorAdapters,
    aliasName: 'emulators__id__emulator_adapters__emulator_id',
  );

  $$EmulatorAdaptersTableProcessedTableManager get emulatorAdaptersRefs {
    final manager = $$EmulatorAdaptersTableTableManager(
      $_db,
      $_db.emulatorAdapters,
    ).filter((f) => f.emulatorId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _emulatorAdaptersRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$EmulatorsTableFilterComposer
    extends Composer<_$AppDatabase, $EmulatorsTable> {
  $$EmulatorsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get license => $composableBuilder(
    column: $table.license,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get strategy => $composableBuilder(
    column: $table.strategy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get requiresArm64 => $composableBuilder(
    column: $table.requiresArm64,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get minSdk => $composableBuilder(
    column: $table.minSdk,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get consoleIds => $composableBuilder(
    column: $table.consoleIds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> gamesRefs(
    Expression<bool> Function($$GamesTableFilterComposer f) f,
  ) {
    final $$GamesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.games,
      getReferencedColumn: (t) => t.preferredEmulatorId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GamesTableFilterComposer(
            $db: $db,
            $table: $db.games,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> compatibilityTestResultsRefs(
    Expression<bool> Function($$CompatibilityTestResultsTableFilterComposer f)
    f,
  ) {
    final $$CompatibilityTestResultsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.compatibilityTestResults,
          getReferencedColumn: (t) => t.emulatorId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CompatibilityTestResultsTableFilterComposer(
                $db: $db,
                $table: $db.compatibilityTestResults,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> emulatorProfilesRefs(
    Expression<bool> Function($$EmulatorProfilesTableFilterComposer f) f,
  ) {
    final $$EmulatorProfilesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.emulatorProfiles,
      getReferencedColumn: (t) => t.emulatorId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EmulatorProfilesTableFilterComposer(
            $db: $db,
            $table: $db.emulatorProfiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> emulatorAdaptersRefs(
    Expression<bool> Function($$EmulatorAdaptersTableFilterComposer f) f,
  ) {
    final $$EmulatorAdaptersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.emulatorAdapters,
      getReferencedColumn: (t) => t.emulatorId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EmulatorAdaptersTableFilterComposer(
            $db: $db,
            $table: $db.emulatorAdapters,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$EmulatorsTableOrderingComposer
    extends Composer<_$AppDatabase, $EmulatorsTable> {
  $$EmulatorsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get license => $composableBuilder(
    column: $table.license,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get strategy => $composableBuilder(
    column: $table.strategy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get requiresArm64 => $composableBuilder(
    column: $table.requiresArm64,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get minSdk => $composableBuilder(
    column: $table.minSdk,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get consoleIds => $composableBuilder(
    column: $table.consoleIds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$EmulatorsTableAnnotationComposer
    extends Composer<_$AppDatabase, $EmulatorsTable> {
  $$EmulatorsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get license =>
      $composableBuilder(column: $table.license, builder: (column) => column);

  GeneratedColumn<String> get strategy =>
      $composableBuilder(column: $table.strategy, builder: (column) => column);

  GeneratedColumn<bool> get requiresArm64 => $composableBuilder(
    column: $table.requiresArm64,
    builder: (column) => column,
  );

  GeneratedColumn<int> get minSdk =>
      $composableBuilder(column: $table.minSdk, builder: (column) => column);

  GeneratedColumn<String> get consoleIds => $composableBuilder(
    column: $table.consoleIds,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  Expression<T> gamesRefs<T extends Object>(
    Expression<T> Function($$GamesTableAnnotationComposer a) f,
  ) {
    final $$GamesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.games,
      getReferencedColumn: (t) => t.preferredEmulatorId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GamesTableAnnotationComposer(
            $db: $db,
            $table: $db.games,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> compatibilityTestResultsRefs<T extends Object>(
    Expression<T> Function($$CompatibilityTestResultsTableAnnotationComposer a)
    f,
  ) {
    final $$CompatibilityTestResultsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.compatibilityTestResults,
          getReferencedColumn: (t) => t.emulatorId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CompatibilityTestResultsTableAnnotationComposer(
                $db: $db,
                $table: $db.compatibilityTestResults,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> emulatorProfilesRefs<T extends Object>(
    Expression<T> Function($$EmulatorProfilesTableAnnotationComposer a) f,
  ) {
    final $$EmulatorProfilesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.emulatorProfiles,
      getReferencedColumn: (t) => t.emulatorId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EmulatorProfilesTableAnnotationComposer(
            $db: $db,
            $table: $db.emulatorProfiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> emulatorAdaptersRefs<T extends Object>(
    Expression<T> Function($$EmulatorAdaptersTableAnnotationComposer a) f,
  ) {
    final $$EmulatorAdaptersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.emulatorAdapters,
      getReferencedColumn: (t) => t.emulatorId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EmulatorAdaptersTableAnnotationComposer(
            $db: $db,
            $table: $db.emulatorAdapters,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$EmulatorsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EmulatorsTable,
          EmulatorRow,
          $$EmulatorsTableFilterComposer,
          $$EmulatorsTableOrderingComposer,
          $$EmulatorsTableAnnotationComposer,
          $$EmulatorsTableCreateCompanionBuilder,
          $$EmulatorsTableUpdateCompanionBuilder,
          (EmulatorRow, $$EmulatorsTableReferences),
          EmulatorRow,
          PrefetchHooks Function({
            bool gamesRefs,
            bool compatibilityTestResultsRefs,
            bool emulatorProfilesRefs,
            bool emulatorAdaptersRefs,
          })
        > {
  $$EmulatorsTableTableManager(_$AppDatabase db, $EmulatorsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EmulatorsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EmulatorsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EmulatorsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> license = const Value.absent(),
                Value<String> strategy = const Value.absent(),
                Value<bool> requiresArm64 = const Value.absent(),
                Value<int?> minSdk = const Value.absent(),
                Value<String> consoleIds = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EmulatorsCompanion(
                id: id,
                name: name,
                license: license,
                strategy: strategy,
                requiresArm64: requiresArm64,
                minSdk: minSdk,
                consoleIds: consoleIds,
                notes: notes,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String license,
                required String strategy,
                Value<bool> requiresArm64 = const Value.absent(),
                Value<int?> minSdk = const Value.absent(),
                required String consoleIds,
                Value<String?> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EmulatorsCompanion.insert(
                id: id,
                name: name,
                license: license,
                strategy: strategy,
                requiresArm64: requiresArm64,
                minSdk: minSdk,
                consoleIds: consoleIds,
                notes: notes,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$EmulatorsTable, EmulatorRow>(table),
                  $$EmulatorsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                gamesRefs = false,
                compatibilityTestResultsRefs = false,
                emulatorProfilesRefs = false,
                emulatorAdaptersRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (gamesRefs) db.games,
                    if (compatibilityTestResultsRefs)
                      db.compatibilityTestResults,
                    if (emulatorProfilesRefs) db.emulatorProfiles,
                    if (emulatorAdaptersRefs) db.emulatorAdapters,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (gamesRefs)
                        await $_getPrefetchedDataByColumns<
                          EmulatorRow,
                          $EmulatorsTable,
                          GameRow,
                          $GamesTable
                        >(
                          currentTable: table,
                          referencedTable: $$EmulatorsTableReferences
                              ._gamesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$EmulatorsTableReferences(
                                db,
                                table,
                                p0,
                              ).gamesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'preferred_emulator_id',
                          typedResults: items,
                        ),
                      if (compatibilityTestResultsRefs)
                        await $_getPrefetchedDataByColumns<
                          EmulatorRow,
                          $EmulatorsTable,
                          CompatibilityTestResultRow,
                          $CompatibilityTestResultsTable
                        >(
                          currentTable: table,
                          referencedTable: $$EmulatorsTableReferences
                              ._compatibilityTestResultsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$EmulatorsTableReferences(
                                db,
                                table,
                                p0,
                              ).compatibilityTestResultsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'emulator_id',
                          typedResults: items,
                        ),
                      if (emulatorProfilesRefs)
                        await $_getPrefetchedDataByColumns<
                          EmulatorRow,
                          $EmulatorsTable,
                          EmulatorProfileRow,
                          $EmulatorProfilesTable
                        >(
                          currentTable: table,
                          referencedTable: $$EmulatorsTableReferences
                              ._emulatorProfilesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$EmulatorsTableReferences(
                                db,
                                table,
                                p0,
                              ).emulatorProfilesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'emulator_id',
                          typedResults: items,
                        ),
                      if (emulatorAdaptersRefs)
                        await $_getPrefetchedDataByColumns<
                          EmulatorRow,
                          $EmulatorsTable,
                          EmulatorAdapterRow,
                          $EmulatorAdaptersTable
                        >(
                          currentTable: table,
                          referencedTable: $$EmulatorsTableReferences
                              ._emulatorAdaptersRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$EmulatorsTableReferences(
                                db,
                                table,
                                p0,
                              ).emulatorAdaptersRefs,
                          currentColumn: 'id',
                          referencedColumn: 'emulator_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$EmulatorsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EmulatorsTable,
      EmulatorRow,
      $$EmulatorsTableFilterComposer,
      $$EmulatorsTableOrderingComposer,
      $$EmulatorsTableAnnotationComposer,
      $$EmulatorsTableCreateCompanionBuilder,
      $$EmulatorsTableUpdateCompanionBuilder,
      (EmulatorRow, $$EmulatorsTableReferences),
      EmulatorRow,
      PrefetchHooks Function({
        bool gamesRefs,
        bool compatibilityTestResultsRefs,
        bool emulatorProfilesRefs,
        bool emulatorAdaptersRefs,
      })
    >;
typedef $$ConsolesTableCreateCompanionBuilder = ConsolesCompanion Function({
  required String id,
  required String name,
  required String manufacturer,
  required String category,
  required String folderName,
  required String extensions,
  required String minTier,
  required String recommendedTier,
  Value<bool> enabled,
  Value<int> rowid,
});
typedef $$ConsolesTableUpdateCompanionBuilder = ConsolesCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String> manufacturer,
  Value<String> category,
  Value<String> folderName,
  Value<String> extensions,
  Value<String> minTier,
  Value<String> recommendedTier,
  Value<bool> enabled,
  Value<int> rowid,
});

final class $$ConsolesTableReferences
    extends BaseReferences<_$AppDatabase, $ConsolesTable, ConsoleRow> {
  $$ConsolesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$GamesTable, List<GameRow>> _gamesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.games,
    aliasName: 'consoles__id__games__console_id',
  );

  $$GamesTableProcessedTableManager get gamesRefs {
    final manager = $$GamesTableTableManager(
      $_db,
      $_db.games,
    ).filter((f) => f.consoleId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_gamesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $CompatibilityTestResultsTable,
    List<CompatibilityTestResultRow>
  >
  _compatibilityTestResultsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.compatibilityTestResults,
        aliasName: 'consoles__id__compatibility_test_results__console_id',
      );

  $$CompatibilityTestResultsTableProcessedTableManager
  get compatibilityTestResultsRefs {
    final manager = $$CompatibilityTestResultsTableTableManager(
      $_db,
      $_db.compatibilityTestResults,
    ).filter((f) => f.consoleId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _compatibilityTestResultsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$EmulatorProfilesTable, List<EmulatorProfileRow>>
  _emulatorProfilesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.emulatorProfiles,
    aliasName: 'consoles__id__emulator_profiles__console_id',
  );

  $$EmulatorProfilesTableProcessedTableManager get emulatorProfilesRefs {
    final manager = $$EmulatorProfilesTableTableManager(
      $_db,
      $_db.emulatorProfiles,
    ).filter((f) => f.consoleId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _emulatorProfilesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $ControllerProfilesTable,
    List<ControllerProfileRow>
  >
  _controllerProfilesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.controllerProfiles,
        aliasName: 'consoles__id__controller_profiles__console_id',
      );

  $$ControllerProfilesTableProcessedTableManager get controllerProfilesRefs {
    final manager = $$ControllerProfilesTableTableManager(
      $_db,
      $_db.controllerProfiles,
    ).filter((f) => f.consoleId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _controllerProfilesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ConsolesTableFilterComposer
    extends Composer<_$AppDatabase, $ConsolesTable> {
  $$ConsolesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get manufacturer => $composableBuilder(
    column: $table.manufacturer,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get folderName => $composableBuilder(
    column: $table.folderName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get extensions => $composableBuilder(
    column: $table.extensions,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get minTier => $composableBuilder(
    column: $table.minTier,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recommendedTier => $composableBuilder(
    column: $table.recommendedTier,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> gamesRefs(
    Expression<bool> Function($$GamesTableFilterComposer f) f,
  ) {
    final $$GamesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.games,
      getReferencedColumn: (t) => t.consoleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GamesTableFilterComposer(
            $db: $db,
            $table: $db.games,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> compatibilityTestResultsRefs(
    Expression<bool> Function($$CompatibilityTestResultsTableFilterComposer f)
    f,
  ) {
    final $$CompatibilityTestResultsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.compatibilityTestResults,
          getReferencedColumn: (t) => t.consoleId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CompatibilityTestResultsTableFilterComposer(
                $db: $db,
                $table: $db.compatibilityTestResults,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> emulatorProfilesRefs(
    Expression<bool> Function($$EmulatorProfilesTableFilterComposer f) f,
  ) {
    final $$EmulatorProfilesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.emulatorProfiles,
      getReferencedColumn: (t) => t.consoleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EmulatorProfilesTableFilterComposer(
            $db: $db,
            $table: $db.emulatorProfiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> controllerProfilesRefs(
    Expression<bool> Function($$ControllerProfilesTableFilterComposer f) f,
  ) {
    final $$ControllerProfilesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.controllerProfiles,
      getReferencedColumn: (t) => t.consoleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ControllerProfilesTableFilterComposer(
            $db: $db,
            $table: $db.controllerProfiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ConsolesTableOrderingComposer
    extends Composer<_$AppDatabase, $ConsolesTable> {
  $$ConsolesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get manufacturer => $composableBuilder(
    column: $table.manufacturer,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get folderName => $composableBuilder(
    column: $table.folderName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get extensions => $composableBuilder(
    column: $table.extensions,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get minTier => $composableBuilder(
    column: $table.minTier,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recommendedTier => $composableBuilder(
    column: $table.recommendedTier,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ConsolesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ConsolesTable> {
  $$ConsolesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get manufacturer => $composableBuilder(
    column: $table.manufacturer,
    builder: (column) => column,
  );

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get folderName => $composableBuilder(
    column: $table.folderName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get extensions => $composableBuilder(
    column: $table.extensions,
    builder: (column) => column,
  );

  GeneratedColumn<String> get minTier =>
      $composableBuilder(column: $table.minTier, builder: (column) => column);

  GeneratedColumn<String> get recommendedTier => $composableBuilder(
    column: $table.recommendedTier,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get enabled =>
      $composableBuilder(column: $table.enabled, builder: (column) => column);

  Expression<T> gamesRefs<T extends Object>(
    Expression<T> Function($$GamesTableAnnotationComposer a) f,
  ) {
    final $$GamesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.games,
      getReferencedColumn: (t) => t.consoleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GamesTableAnnotationComposer(
            $db: $db,
            $table: $db.games,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> compatibilityTestResultsRefs<T extends Object>(
    Expression<T> Function($$CompatibilityTestResultsTableAnnotationComposer a)
    f,
  ) {
    final $$CompatibilityTestResultsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.compatibilityTestResults,
          getReferencedColumn: (t) => t.consoleId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CompatibilityTestResultsTableAnnotationComposer(
                $db: $db,
                $table: $db.compatibilityTestResults,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> emulatorProfilesRefs<T extends Object>(
    Expression<T> Function($$EmulatorProfilesTableAnnotationComposer a) f,
  ) {
    final $$EmulatorProfilesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.emulatorProfiles,
      getReferencedColumn: (t) => t.consoleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EmulatorProfilesTableAnnotationComposer(
            $db: $db,
            $table: $db.emulatorProfiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> controllerProfilesRefs<T extends Object>(
    Expression<T> Function($$ControllerProfilesTableAnnotationComposer a) f,
  ) {
    final $$ControllerProfilesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.controllerProfiles,
          getReferencedColumn: (t) => t.consoleId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ControllerProfilesTableAnnotationComposer(
                $db: $db,
                $table: $db.controllerProfiles,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$ConsolesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ConsolesTable,
          ConsoleRow,
          $$ConsolesTableFilterComposer,
          $$ConsolesTableOrderingComposer,
          $$ConsolesTableAnnotationComposer,
          $$ConsolesTableCreateCompanionBuilder,
          $$ConsolesTableUpdateCompanionBuilder,
          (ConsoleRow, $$ConsolesTableReferences),
          ConsoleRow,
          PrefetchHooks Function({
            bool gamesRefs,
            bool compatibilityTestResultsRefs,
            bool emulatorProfilesRefs,
            bool controllerProfilesRefs,
          })
        > {
  $$ConsolesTableTableManager(_$AppDatabase db, $ConsolesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ConsolesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ConsolesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ConsolesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> manufacturer = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<String> folderName = const Value.absent(),
                Value<String> extensions = const Value.absent(),
                Value<String> minTier = const Value.absent(),
                Value<String> recommendedTier = const Value.absent(),
                Value<bool> enabled = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ConsolesCompanion(
                id: id,
                name: name,
                manufacturer: manufacturer,
                category: category,
                folderName: folderName,
                extensions: extensions,
                minTier: minTier,
                recommendedTier: recommendedTier,
                enabled: enabled,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String manufacturer,
                required String category,
                required String folderName,
                required String extensions,
                required String minTier,
                required String recommendedTier,
                Value<bool> enabled = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ConsolesCompanion.insert(
                id: id,
                name: name,
                manufacturer: manufacturer,
                category: category,
                folderName: folderName,
                extensions: extensions,
                minTier: minTier,
                recommendedTier: recommendedTier,
                enabled: enabled,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ConsolesTable, ConsoleRow>(table),
                  $$ConsolesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                gamesRefs = false,
                compatibilityTestResultsRefs = false,
                emulatorProfilesRefs = false,
                controllerProfilesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (gamesRefs) db.games,
                    if (compatibilityTestResultsRefs)
                      db.compatibilityTestResults,
                    if (emulatorProfilesRefs) db.emulatorProfiles,
                    if (controllerProfilesRefs) db.controllerProfiles,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (gamesRefs)
                        await $_getPrefetchedDataByColumns<
                          ConsoleRow,
                          $ConsolesTable,
                          GameRow,
                          $GamesTable
                        >(
                          currentTable: table,
                          referencedTable: $$ConsolesTableReferences
                              ._gamesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ConsolesTableReferences(
                                db,
                                table,
                                p0,
                              ).gamesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'console_id',
                          typedResults: items,
                        ),
                      if (compatibilityTestResultsRefs)
                        await $_getPrefetchedDataByColumns<
                          ConsoleRow,
                          $ConsolesTable,
                          CompatibilityTestResultRow,
                          $CompatibilityTestResultsTable
                        >(
                          currentTable: table,
                          referencedTable: $$ConsolesTableReferences
                              ._compatibilityTestResultsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ConsolesTableReferences(
                                db,
                                table,
                                p0,
                              ).compatibilityTestResultsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'console_id',
                          typedResults: items,
                        ),
                      if (emulatorProfilesRefs)
                        await $_getPrefetchedDataByColumns<
                          ConsoleRow,
                          $ConsolesTable,
                          EmulatorProfileRow,
                          $EmulatorProfilesTable
                        >(
                          currentTable: table,
                          referencedTable: $$ConsolesTableReferences
                              ._emulatorProfilesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ConsolesTableReferences(
                                db,
                                table,
                                p0,
                              ).emulatorProfilesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'console_id',
                          typedResults: items,
                        ),
                      if (controllerProfilesRefs)
                        await $_getPrefetchedDataByColumns<
                          ConsoleRow,
                          $ConsolesTable,
                          ControllerProfileRow,
                          $ControllerProfilesTable
                        >(
                          currentTable: table,
                          referencedTable: $$ConsolesTableReferences
                              ._controllerProfilesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ConsolesTableReferences(
                                db,
                                table,
                                p0,
                              ).controllerProfilesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'console_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ConsolesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ConsolesTable,
      ConsoleRow,
      $$ConsolesTableFilterComposer,
      $$ConsolesTableOrderingComposer,
      $$ConsolesTableAnnotationComposer,
      $$ConsolesTableCreateCompanionBuilder,
      $$ConsolesTableUpdateCompanionBuilder,
      (ConsoleRow, $$ConsolesTableReferences),
      ConsoleRow,
      PrefetchHooks Function({
        bool gamesRefs,
        bool compatibilityTestResultsRefs,
        bool emulatorProfilesRefs,
        bool controllerProfilesRefs,
      })
    >;
typedef $$GamesTableCreateCompanionBuilder = GamesCompanion Function({
  Value<int> id,
  required String title,
  required String sortTitle,
  required String consoleId,
  Value<String?> preferredEmulatorId,
  required DateTime addedAt,
  Value<DateTime?> lastPlayedAt,
  Value<int> playCount,
  Value<bool> isMissing,
  Value<String?> regions,
});
typedef $$GamesTableUpdateCompanionBuilder = GamesCompanion Function({
  Value<int> id,
  Value<String> title,
  Value<String> sortTitle,
  Value<String> consoleId,
  Value<String?> preferredEmulatorId,
  Value<DateTime> addedAt,
  Value<DateTime?> lastPlayedAt,
  Value<int> playCount,
  Value<bool> isMissing,
  Value<String?> regions,
});

final class $$GamesTableReferences
    extends BaseReferences<_$AppDatabase, $GamesTable, GameRow> {
  $$GamesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ConsolesTable _consoleIdTable(_$AppDatabase db) =>
      db.consoles.createAlias('games__console_id__consoles__id');

  $$ConsolesTableProcessedTableManager get consoleId {
    final $_column = $_itemColumn<String>('console_id')!;

    final manager = $$ConsolesTableTableManager(
      $_db,
      $_db.consoles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_consoleIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $EmulatorsTable _preferredEmulatorIdTable(_$AppDatabase db) =>
      db.emulators.createAlias('games__preferred_emulator_id__emulators__id');

  $$EmulatorsTableProcessedTableManager? get preferredEmulatorId {
    final $_column = $_itemColumn<String>('preferred_emulator_id');
    if ($_column == null) return null;
    final manager = $$EmulatorsTableTableManager(
      $_db,
      $_db.emulators,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_preferredEmulatorIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<
    $CompatibilityTestResultsTable,
    List<CompatibilityTestResultRow>
  >
  _compatibilityTestResultsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.compatibilityTestResults,
        aliasName: 'games__id__compatibility_test_results__game_id',
      );

  $$CompatibilityTestResultsTableProcessedTableManager
  get compatibilityTestResultsRefs {
    final manager = $$CompatibilityTestResultsTableTableManager(
      $_db,
      $_db.compatibilityTestResults,
    ).filter((f) => f.gameId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _compatibilityTestResultsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$GameFilesTable, List<GameFileRow>>
  _gameFilesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.gameFiles,
    aliasName: 'games__id__game_files__game_id',
  );

  $$GameFilesTableProcessedTableManager get gameFilesRefs {
    final manager = $$GameFilesTableTableManager(
      $_db,
      $_db.gameFiles,
    ).filter((f) => f.gameId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_gameFilesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$GameMetadataTable, List<GameMetadataRow>>
  _gameMetadataRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.gameMetadata,
    aliasName: 'games__id__game_metadata__game_id',
  );

  $$GameMetadataTableProcessedTableManager get gameMetadataRefs {
    final manager = $$GameMetadataTableTableManager(
      $_db,
      $_db.gameMetadata,
    ).filter((f) => f.gameId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_gameMetadataRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$GameArtworksTable, List<GameArtworkRow>>
  _gameArtworksRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.gameArtworks,
    aliasName: 'games__id__game_artworks__game_id',
  );

  $$GameArtworksTableProcessedTableManager get gameArtworksRefs {
    final manager = $$GameArtworksTableTableManager(
      $_db,
      $_db.gameArtworks,
    ).filter((f) => f.gameId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_gameArtworksRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$FavoritesTable, List<FavoriteRow>>
  _favoritesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.favorites,
    aliasName: 'games__id__favorites__game_id',
  );

  $$FavoritesTableProcessedTableManager get favoritesRefs {
    final manager = $$FavoritesTableTableManager(
      $_db,
      $_db.favorites,
    ).filter((f) => f.gameId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_favoritesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$GameHistoryTable, List<GameHistoryRow>>
  _gameHistoryRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.gameHistory,
    aliasName: 'games__id__game_history__game_id',
  );

  $$GameHistoryTableProcessedTableManager get gameHistoryRefs {
    final manager = $$GameHistoryTableTableManager(
      $_db,
      $_db.gameHistory,
    ).filter((f) => f.gameId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_gameHistoryRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$SaveStatesTable, List<SaveStateRow>>
  _saveStatesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.saveStates,
    aliasName: 'games__id__save_states__game_id',
  );

  $$SaveStatesTableProcessedTableManager get saveStatesRefs {
    final manager = $$SaveStatesTableTableManager(
      $_db,
      $_db.saveStates,
    ).filter((f) => f.gameId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_saveStatesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$SaveBackupsTable, List<SaveBackupRow>>
  _saveBackupsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.saveBackups,
    aliasName: 'games__id__save_backups__game_id',
  );

  $$SaveBackupsTableProcessedTableManager get saveBackupsRefs {
    final manager = $$SaveBackupsTableTableManager(
      $_db,
      $_db.saveBackups,
    ).filter((f) => f.gameId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_saveBackupsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$BenchmarksTable, List<BenchmarkRow>>
  _benchmarksRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.benchmarks,
    aliasName: 'games__id__benchmarks__game_id',
  );

  $$BenchmarksTableProcessedTableManager get benchmarksRefs {
    final manager = $$BenchmarksTableTableManager(
      $_db,
      $_db.benchmarks,
    ).filter((f) => f.gameId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_benchmarksRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$GamesTableFilterComposer extends Composer<_$AppDatabase, $GamesTable> {
  $$GamesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sortTitle => $composableBuilder(
    column: $table.sortTitle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastPlayedAt => $composableBuilder(
    column: $table.lastPlayedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get playCount => $composableBuilder(
    column: $table.playCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isMissing => $composableBuilder(
    column: $table.isMissing,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get regions => $composableBuilder(
    column: $table.regions,
    builder: (column) => ColumnFilters(column),
  );

  $$ConsolesTableFilterComposer get consoleId {
    final $$ConsolesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.consoleId,
      referencedTable: $db.consoles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ConsolesTableFilterComposer(
            $db: $db,
            $table: $db.consoles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$EmulatorsTableFilterComposer get preferredEmulatorId {
    final $$EmulatorsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.preferredEmulatorId,
      referencedTable: $db.emulators,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EmulatorsTableFilterComposer(
            $db: $db,
            $table: $db.emulators,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> compatibilityTestResultsRefs(
    Expression<bool> Function($$CompatibilityTestResultsTableFilterComposer f)
    f,
  ) {
    final $$CompatibilityTestResultsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.compatibilityTestResults,
          getReferencedColumn: (t) => t.gameId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CompatibilityTestResultsTableFilterComposer(
                $db: $db,
                $table: $db.compatibilityTestResults,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> gameFilesRefs(
    Expression<bool> Function($$GameFilesTableFilterComposer f) f,
  ) {
    final $$GameFilesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.gameFiles,
      getReferencedColumn: (t) => t.gameId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GameFilesTableFilterComposer(
            $db: $db,
            $table: $db.gameFiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> gameMetadataRefs(
    Expression<bool> Function($$GameMetadataTableFilterComposer f) f,
  ) {
    final $$GameMetadataTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.gameMetadata,
      getReferencedColumn: (t) => t.gameId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GameMetadataTableFilterComposer(
            $db: $db,
            $table: $db.gameMetadata,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> gameArtworksRefs(
    Expression<bool> Function($$GameArtworksTableFilterComposer f) f,
  ) {
    final $$GameArtworksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.gameArtworks,
      getReferencedColumn: (t) => t.gameId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GameArtworksTableFilterComposer(
            $db: $db,
            $table: $db.gameArtworks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> favoritesRefs(
    Expression<bool> Function($$FavoritesTableFilterComposer f) f,
  ) {
    final $$FavoritesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.favorites,
      getReferencedColumn: (t) => t.gameId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FavoritesTableFilterComposer(
            $db: $db,
            $table: $db.favorites,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> gameHistoryRefs(
    Expression<bool> Function($$GameHistoryTableFilterComposer f) f,
  ) {
    final $$GameHistoryTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.gameHistory,
      getReferencedColumn: (t) => t.gameId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GameHistoryTableFilterComposer(
            $db: $db,
            $table: $db.gameHistory,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> saveStatesRefs(
    Expression<bool> Function($$SaveStatesTableFilterComposer f) f,
  ) {
    final $$SaveStatesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.saveStates,
      getReferencedColumn: (t) => t.gameId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SaveStatesTableFilterComposer(
            $db: $db,
            $table: $db.saveStates,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> saveBackupsRefs(
    Expression<bool> Function($$SaveBackupsTableFilterComposer f) f,
  ) {
    final $$SaveBackupsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.saveBackups,
      getReferencedColumn: (t) => t.gameId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SaveBackupsTableFilterComposer(
            $db: $db,
            $table: $db.saveBackups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> benchmarksRefs(
    Expression<bool> Function($$BenchmarksTableFilterComposer f) f,
  ) {
    final $$BenchmarksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.benchmarks,
      getReferencedColumn: (t) => t.gameId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BenchmarksTableFilterComposer(
            $db: $db,
            $table: $db.benchmarks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$GamesTableOrderingComposer
    extends Composer<_$AppDatabase, $GamesTable> {
  $$GamesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sortTitle => $composableBuilder(
    column: $table.sortTitle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastPlayedAt => $composableBuilder(
    column: $table.lastPlayedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get playCount => $composableBuilder(
    column: $table.playCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isMissing => $composableBuilder(
    column: $table.isMissing,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get regions => $composableBuilder(
    column: $table.regions,
    builder: (column) => ColumnOrderings(column),
  );

  $$ConsolesTableOrderingComposer get consoleId {
    final $$ConsolesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.consoleId,
      referencedTable: $db.consoles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ConsolesTableOrderingComposer(
            $db: $db,
            $table: $db.consoles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$EmulatorsTableOrderingComposer get preferredEmulatorId {
    final $$EmulatorsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.preferredEmulatorId,
      referencedTable: $db.emulators,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EmulatorsTableOrderingComposer(
            $db: $db,
            $table: $db.emulators,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GamesTableAnnotationComposer
    extends Composer<_$AppDatabase, $GamesTable> {
  $$GamesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get sortTitle =>
      $composableBuilder(column: $table.sortTitle, builder: (column) => column);

  GeneratedColumn<DateTime> get addedAt =>
      $composableBuilder(column: $table.addedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastPlayedAt => $composableBuilder(
    column: $table.lastPlayedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get playCount =>
      $composableBuilder(column: $table.playCount, builder: (column) => column);

  GeneratedColumn<bool> get isMissing =>
      $composableBuilder(column: $table.isMissing, builder: (column) => column);

  GeneratedColumn<String> get regions =>
      $composableBuilder(column: $table.regions, builder: (column) => column);

  $$ConsolesTableAnnotationComposer get consoleId {
    final $$ConsolesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.consoleId,
      referencedTable: $db.consoles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ConsolesTableAnnotationComposer(
            $db: $db,
            $table: $db.consoles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$EmulatorsTableAnnotationComposer get preferredEmulatorId {
    final $$EmulatorsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.preferredEmulatorId,
      referencedTable: $db.emulators,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EmulatorsTableAnnotationComposer(
            $db: $db,
            $table: $db.emulators,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> compatibilityTestResultsRefs<T extends Object>(
    Expression<T> Function($$CompatibilityTestResultsTableAnnotationComposer a)
    f,
  ) {
    final $$CompatibilityTestResultsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.compatibilityTestResults,
          getReferencedColumn: (t) => t.gameId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CompatibilityTestResultsTableAnnotationComposer(
                $db: $db,
                $table: $db.compatibilityTestResults,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> gameFilesRefs<T extends Object>(
    Expression<T> Function($$GameFilesTableAnnotationComposer a) f,
  ) {
    final $$GameFilesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.gameFiles,
      getReferencedColumn: (t) => t.gameId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GameFilesTableAnnotationComposer(
            $db: $db,
            $table: $db.gameFiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> gameMetadataRefs<T extends Object>(
    Expression<T> Function($$GameMetadataTableAnnotationComposer a) f,
  ) {
    final $$GameMetadataTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.gameMetadata,
      getReferencedColumn: (t) => t.gameId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GameMetadataTableAnnotationComposer(
            $db: $db,
            $table: $db.gameMetadata,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> gameArtworksRefs<T extends Object>(
    Expression<T> Function($$GameArtworksTableAnnotationComposer a) f,
  ) {
    final $$GameArtworksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.gameArtworks,
      getReferencedColumn: (t) => t.gameId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GameArtworksTableAnnotationComposer(
            $db: $db,
            $table: $db.gameArtworks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> favoritesRefs<T extends Object>(
    Expression<T> Function($$FavoritesTableAnnotationComposer a) f,
  ) {
    final $$FavoritesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.favorites,
      getReferencedColumn: (t) => t.gameId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FavoritesTableAnnotationComposer(
            $db: $db,
            $table: $db.favorites,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> gameHistoryRefs<T extends Object>(
    Expression<T> Function($$GameHistoryTableAnnotationComposer a) f,
  ) {
    final $$GameHistoryTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.gameHistory,
      getReferencedColumn: (t) => t.gameId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GameHistoryTableAnnotationComposer(
            $db: $db,
            $table: $db.gameHistory,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> saveStatesRefs<T extends Object>(
    Expression<T> Function($$SaveStatesTableAnnotationComposer a) f,
  ) {
    final $$SaveStatesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.saveStates,
      getReferencedColumn: (t) => t.gameId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SaveStatesTableAnnotationComposer(
            $db: $db,
            $table: $db.saveStates,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> saveBackupsRefs<T extends Object>(
    Expression<T> Function($$SaveBackupsTableAnnotationComposer a) f,
  ) {
    final $$SaveBackupsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.saveBackups,
      getReferencedColumn: (t) => t.gameId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SaveBackupsTableAnnotationComposer(
            $db: $db,
            $table: $db.saveBackups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> benchmarksRefs<T extends Object>(
    Expression<T> Function($$BenchmarksTableAnnotationComposer a) f,
  ) {
    final $$BenchmarksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.benchmarks,
      getReferencedColumn: (t) => t.gameId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BenchmarksTableAnnotationComposer(
            $db: $db,
            $table: $db.benchmarks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$GamesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GamesTable,
          GameRow,
          $$GamesTableFilterComposer,
          $$GamesTableOrderingComposer,
          $$GamesTableAnnotationComposer,
          $$GamesTableCreateCompanionBuilder,
          $$GamesTableUpdateCompanionBuilder,
          (GameRow, $$GamesTableReferences),
          GameRow,
          PrefetchHooks Function({
            bool consoleId,
            bool preferredEmulatorId,
            bool compatibilityTestResultsRefs,
            bool gameFilesRefs,
            bool gameMetadataRefs,
            bool gameArtworksRefs,
            bool favoritesRefs,
            bool gameHistoryRefs,
            bool saveStatesRefs,
            bool saveBackupsRefs,
            bool benchmarksRefs,
          })
        > {
  $$GamesTableTableManager(_$AppDatabase db, $GamesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GamesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GamesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GamesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> sortTitle = const Value.absent(),
                Value<String> consoleId = const Value.absent(),
                Value<String?> preferredEmulatorId = const Value.absent(),
                Value<DateTime> addedAt = const Value.absent(),
                Value<DateTime?> lastPlayedAt = const Value.absent(),
                Value<int> playCount = const Value.absent(),
                Value<bool> isMissing = const Value.absent(),
                Value<String?> regions = const Value.absent(),
              }) => GamesCompanion(
                id: id,
                title: title,
                sortTitle: sortTitle,
                consoleId: consoleId,
                preferredEmulatorId: preferredEmulatorId,
                addedAt: addedAt,
                lastPlayedAt: lastPlayedAt,
                playCount: playCount,
                isMissing: isMissing,
                regions: regions,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String title,
                required String sortTitle,
                required String consoleId,
                Value<String?> preferredEmulatorId = const Value.absent(),
                required DateTime addedAt,
                Value<DateTime?> lastPlayedAt = const Value.absent(),
                Value<int> playCount = const Value.absent(),
                Value<bool> isMissing = const Value.absent(),
                Value<String?> regions = const Value.absent(),
              }) => GamesCompanion.insert(
                id: id,
                title: title,
                sortTitle: sortTitle,
                consoleId: consoleId,
                preferredEmulatorId: preferredEmulatorId,
                addedAt: addedAt,
                lastPlayedAt: lastPlayedAt,
                playCount: playCount,
                isMissing: isMissing,
                regions: regions,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$GamesTable, GameRow>(table),
                  $$GamesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                consoleId = false,
                preferredEmulatorId = false,
                compatibilityTestResultsRefs = false,
                gameFilesRefs = false,
                gameMetadataRefs = false,
                gameArtworksRefs = false,
                favoritesRefs = false,
                gameHistoryRefs = false,
                saveStatesRefs = false,
                saveBackupsRefs = false,
                benchmarksRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (compatibilityTestResultsRefs)
                      db.compatibilityTestResults,
                    if (gameFilesRefs) db.gameFiles,
                    if (gameMetadataRefs) db.gameMetadata,
                    if (gameArtworksRefs) db.gameArtworks,
                    if (favoritesRefs) db.favorites,
                    if (gameHistoryRefs) db.gameHistory,
                    if (saveStatesRefs) db.saveStates,
                    if (saveBackupsRefs) db.saveBackups,
                    if (benchmarksRefs) db.benchmarks,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (consoleId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.consoleId,
                            referencedTable: $$GamesTableReferences
                                ._consoleIdTable(db),
                            referencedColumn: $$GamesTableReferences
                                ._consoleIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (preferredEmulatorId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.preferredEmulatorId,
                            referencedTable: $$GamesTableReferences
                                ._preferredEmulatorIdTable(db),
                            referencedColumn: $$GamesTableReferences
                                ._preferredEmulatorIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (compatibilityTestResultsRefs)
                        await $_getPrefetchedDataByColumns<
                          GameRow,
                          $GamesTable,
                          CompatibilityTestResultRow,
                          $CompatibilityTestResultsTable
                        >(
                          currentTable: table,
                          referencedTable: $$GamesTableReferences
                              ._compatibilityTestResultsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$GamesTableReferences(
                                db,
                                table,
                                p0,
                              ).compatibilityTestResultsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'game_id',
                          typedResults: items,
                        ),
                      if (gameFilesRefs)
                        await $_getPrefetchedDataByColumns<
                          GameRow,
                          $GamesTable,
                          GameFileRow,
                          $GameFilesTable
                        >(
                          currentTable: table,
                          referencedTable: $$GamesTableReferences
                              ._gameFilesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$GamesTableReferences(
                                db,
                                table,
                                p0,
                              ).gameFilesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'game_id',
                          typedResults: items,
                        ),
                      if (gameMetadataRefs)
                        await $_getPrefetchedDataByColumns<
                          GameRow,
                          $GamesTable,
                          GameMetadataRow,
                          $GameMetadataTable
                        >(
                          currentTable: table,
                          referencedTable: $$GamesTableReferences
                              ._gameMetadataRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$GamesTableReferences(
                                db,
                                table,
                                p0,
                              ).gameMetadataRefs,
                          currentColumn: 'id',
                          referencedColumn: 'game_id',
                          typedResults: items,
                        ),
                      if (gameArtworksRefs)
                        await $_getPrefetchedDataByColumns<
                          GameRow,
                          $GamesTable,
                          GameArtworkRow,
                          $GameArtworksTable
                        >(
                          currentTable: table,
                          referencedTable: $$GamesTableReferences
                              ._gameArtworksRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$GamesTableReferences(
                                db,
                                table,
                                p0,
                              ).gameArtworksRefs,
                          currentColumn: 'id',
                          referencedColumn: 'game_id',
                          typedResults: items,
                        ),
                      if (favoritesRefs)
                        await $_getPrefetchedDataByColumns<
                          GameRow,
                          $GamesTable,
                          FavoriteRow,
                          $FavoritesTable
                        >(
                          currentTable: table,
                          referencedTable: $$GamesTableReferences
                              ._favoritesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$GamesTableReferences(
                                db,
                                table,
                                p0,
                              ).favoritesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'game_id',
                          typedResults: items,
                        ),
                      if (gameHistoryRefs)
                        await $_getPrefetchedDataByColumns<
                          GameRow,
                          $GamesTable,
                          GameHistoryRow,
                          $GameHistoryTable
                        >(
                          currentTable: table,
                          referencedTable: $$GamesTableReferences
                              ._gameHistoryRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$GamesTableReferences(
                                db,
                                table,
                                p0,
                              ).gameHistoryRefs,
                          currentColumn: 'id',
                          referencedColumn: 'game_id',
                          typedResults: items,
                        ),
                      if (saveStatesRefs)
                        await $_getPrefetchedDataByColumns<
                          GameRow,
                          $GamesTable,
                          SaveStateRow,
                          $SaveStatesTable
                        >(
                          currentTable: table,
                          referencedTable: $$GamesTableReferences
                              ._saveStatesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$GamesTableReferences(
                                db,
                                table,
                                p0,
                              ).saveStatesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'game_id',
                          typedResults: items,
                        ),
                      if (saveBackupsRefs)
                        await $_getPrefetchedDataByColumns<
                          GameRow,
                          $GamesTable,
                          SaveBackupRow,
                          $SaveBackupsTable
                        >(
                          currentTable: table,
                          referencedTable: $$GamesTableReferences
                              ._saveBackupsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$GamesTableReferences(
                                db,
                                table,
                                p0,
                              ).saveBackupsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'game_id',
                          typedResults: items,
                        ),
                      if (benchmarksRefs)
                        await $_getPrefetchedDataByColumns<
                          GameRow,
                          $GamesTable,
                          BenchmarkRow,
                          $BenchmarksTable
                        >(
                          currentTable: table,
                          referencedTable: $$GamesTableReferences
                              ._benchmarksRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$GamesTableReferences(
                                db,
                                table,
                                p0,
                              ).benchmarksRefs,
                          currentColumn: 'id',
                          referencedColumn: 'game_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$GamesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GamesTable,
      GameRow,
      $$GamesTableFilterComposer,
      $$GamesTableOrderingComposer,
      $$GamesTableAnnotationComposer,
      $$GamesTableCreateCompanionBuilder,
      $$GamesTableUpdateCompanionBuilder,
      (GameRow, $$GamesTableReferences),
      GameRow,
      PrefetchHooks Function({
        bool consoleId,
        bool preferredEmulatorId,
        bool compatibilityTestResultsRefs,
        bool gameFilesRefs,
        bool gameMetadataRefs,
        bool gameArtworksRefs,
        bool favoritesRefs,
        bool gameHistoryRefs,
        bool saveStatesRefs,
        bool saveBackupsRefs,
        bool benchmarksRefs,
      })
    >;
typedef $$CompatibilityTestResultsTableCreateCompanionBuilder =
    CompatibilityTestResultsCompanion Function({
      Value<int> id,
      required int deviceId,
      Value<String?> emulatorId,
      required String consoleId,
      Value<int?> gameId,
      required String result,
      required String source,
      Value<String?> notes,
      Value<bool> consentToShare,
      Value<bool> submitted,
      required DateTime testedAt,
    });
typedef $$CompatibilityTestResultsTableUpdateCompanionBuilder =
    CompatibilityTestResultsCompanion Function({
      Value<int> id,
      Value<int> deviceId,
      Value<String?> emulatorId,
      Value<String> consoleId,
      Value<int?> gameId,
      Value<String> result,
      Value<String> source,
      Value<String?> notes,
      Value<bool> consentToShare,
      Value<bool> submitted,
      Value<DateTime> testedAt,
    });

final class $$CompatibilityTestResultsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $CompatibilityTestResultsTable,
          CompatibilityTestResultRow
        > {
  $$CompatibilityTestResultsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $DevicesTable _deviceIdTable(_$AppDatabase db) => db.devices
      .createAlias('compatibility_test_results__device_id__devices__id');

  $$DevicesTableProcessedTableManager get deviceId {
    final $_column = $_itemColumn<int>('device_id')!;

    final manager = $$DevicesTableTableManager(
      $_db,
      $_db.devices,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_deviceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $EmulatorsTable _emulatorIdTable(_$AppDatabase db) => db.emulators
      .createAlias('compatibility_test_results__emulator_id__emulators__id');

  $$EmulatorsTableProcessedTableManager? get emulatorId {
    final $_column = $_itemColumn<String>('emulator_id');
    if ($_column == null) return null;
    final manager = $$EmulatorsTableTableManager(
      $_db,
      $_db.emulators,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_emulatorIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ConsolesTable _consoleIdTable(_$AppDatabase db) => db.consoles
      .createAlias('compatibility_test_results__console_id__consoles__id');

  $$ConsolesTableProcessedTableManager get consoleId {
    final $_column = $_itemColumn<String>('console_id')!;

    final manager = $$ConsolesTableTableManager(
      $_db,
      $_db.consoles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_consoleIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $GamesTable _gameIdTable(_$AppDatabase db) =>
      db.games.createAlias('compatibility_test_results__game_id__games__id');

  $$GamesTableProcessedTableManager? get gameId {
    final $_column = $_itemColumn<int>('game_id');
    if ($_column == null) return null;
    final manager = $$GamesTableTableManager(
      $_db,
      $_db.games,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_gameIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$CompatibilityTestResultsTableFilterComposer
    extends Composer<_$AppDatabase, $CompatibilityTestResultsTable> {
  $$CompatibilityTestResultsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get result => $composableBuilder(
    column: $table.result,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get consentToShare => $composableBuilder(
    column: $table.consentToShare,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get submitted => $composableBuilder(
    column: $table.submitted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get testedAt => $composableBuilder(
    column: $table.testedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$DevicesTableFilterComposer get deviceId {
    final $$DevicesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.deviceId,
      referencedTable: $db.devices,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DevicesTableFilterComposer(
            $db: $db,
            $table: $db.devices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$EmulatorsTableFilterComposer get emulatorId {
    final $$EmulatorsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.emulatorId,
      referencedTable: $db.emulators,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EmulatorsTableFilterComposer(
            $db: $db,
            $table: $db.emulators,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ConsolesTableFilterComposer get consoleId {
    final $$ConsolesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.consoleId,
      referencedTable: $db.consoles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ConsolesTableFilterComposer(
            $db: $db,
            $table: $db.consoles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$GamesTableFilterComposer get gameId {
    final $$GamesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gameId,
      referencedTable: $db.games,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GamesTableFilterComposer(
            $db: $db,
            $table: $db.games,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CompatibilityTestResultsTableOrderingComposer
    extends Composer<_$AppDatabase, $CompatibilityTestResultsTable> {
  $$CompatibilityTestResultsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get result => $composableBuilder(
    column: $table.result,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get consentToShare => $composableBuilder(
    column: $table.consentToShare,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get submitted => $composableBuilder(
    column: $table.submitted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get testedAt => $composableBuilder(
    column: $table.testedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$DevicesTableOrderingComposer get deviceId {
    final $$DevicesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.deviceId,
      referencedTable: $db.devices,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DevicesTableOrderingComposer(
            $db: $db,
            $table: $db.devices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$EmulatorsTableOrderingComposer get emulatorId {
    final $$EmulatorsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.emulatorId,
      referencedTable: $db.emulators,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EmulatorsTableOrderingComposer(
            $db: $db,
            $table: $db.emulators,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ConsolesTableOrderingComposer get consoleId {
    final $$ConsolesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.consoleId,
      referencedTable: $db.consoles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ConsolesTableOrderingComposer(
            $db: $db,
            $table: $db.consoles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$GamesTableOrderingComposer get gameId {
    final $$GamesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gameId,
      referencedTable: $db.games,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GamesTableOrderingComposer(
            $db: $db,
            $table: $db.games,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CompatibilityTestResultsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CompatibilityTestResultsTable> {
  $$CompatibilityTestResultsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get result =>
      $composableBuilder(column: $table.result, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<bool> get consentToShare => $composableBuilder(
    column: $table.consentToShare,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get submitted =>
      $composableBuilder(column: $table.submitted, builder: (column) => column);

  GeneratedColumn<DateTime> get testedAt =>
      $composableBuilder(column: $table.testedAt, builder: (column) => column);

  $$DevicesTableAnnotationComposer get deviceId {
    final $$DevicesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.deviceId,
      referencedTable: $db.devices,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DevicesTableAnnotationComposer(
            $db: $db,
            $table: $db.devices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$EmulatorsTableAnnotationComposer get emulatorId {
    final $$EmulatorsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.emulatorId,
      referencedTable: $db.emulators,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EmulatorsTableAnnotationComposer(
            $db: $db,
            $table: $db.emulators,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ConsolesTableAnnotationComposer get consoleId {
    final $$ConsolesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.consoleId,
      referencedTable: $db.consoles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ConsolesTableAnnotationComposer(
            $db: $db,
            $table: $db.consoles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$GamesTableAnnotationComposer get gameId {
    final $$GamesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gameId,
      referencedTable: $db.games,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GamesTableAnnotationComposer(
            $db: $db,
            $table: $db.games,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CompatibilityTestResultsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CompatibilityTestResultsTable,
          CompatibilityTestResultRow,
          $$CompatibilityTestResultsTableFilterComposer,
          $$CompatibilityTestResultsTableOrderingComposer,
          $$CompatibilityTestResultsTableAnnotationComposer,
          $$CompatibilityTestResultsTableCreateCompanionBuilder,
          $$CompatibilityTestResultsTableUpdateCompanionBuilder,
          (
            CompatibilityTestResultRow,
            $$CompatibilityTestResultsTableReferences,
          ),
          CompatibilityTestResultRow,
          PrefetchHooks Function({
            bool deviceId,
            bool emulatorId,
            bool consoleId,
            bool gameId,
          })
        > {
  $$CompatibilityTestResultsTableTableManager(
    _$AppDatabase db,
    $CompatibilityTestResultsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CompatibilityTestResultsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$CompatibilityTestResultsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$CompatibilityTestResultsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> deviceId = const Value.absent(),
                Value<String?> emulatorId = const Value.absent(),
                Value<String> consoleId = const Value.absent(),
                Value<int?> gameId = const Value.absent(),
                Value<String> result = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<bool> consentToShare = const Value.absent(),
                Value<bool> submitted = const Value.absent(),
                Value<DateTime> testedAt = const Value.absent(),
              }) => CompatibilityTestResultsCompanion(
                id: id,
                deviceId: deviceId,
                emulatorId: emulatorId,
                consoleId: consoleId,
                gameId: gameId,
                result: result,
                source: source,
                notes: notes,
                consentToShare: consentToShare,
                submitted: submitted,
                testedAt: testedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int deviceId,
                Value<String?> emulatorId = const Value.absent(),
                required String consoleId,
                Value<int?> gameId = const Value.absent(),
                required String result,
                required String source,
                Value<String?> notes = const Value.absent(),
                Value<bool> consentToShare = const Value.absent(),
                Value<bool> submitted = const Value.absent(),
                required DateTime testedAt,
              }) => CompatibilityTestResultsCompanion.insert(
                id: id,
                deviceId: deviceId,
                emulatorId: emulatorId,
                consoleId: consoleId,
                gameId: gameId,
                result: result,
                source: source,
                notes: notes,
                consentToShare: consentToShare,
                submitted: submitted,
                testedAt: testedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<
                    $CompatibilityTestResultsTable,
                    CompatibilityTestResultRow
                  >(table),
                  $$CompatibilityTestResultsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                deviceId = false,
                emulatorId = false,
                consoleId = false,
                gameId = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (deviceId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.deviceId,
                            referencedTable:
                                $$CompatibilityTestResultsTableReferences
                                    ._deviceIdTable(db),
                            referencedColumn:
                                $$CompatibilityTestResultsTableReferences
                                    ._deviceIdTable(db)
                                    .id,
                          ) as T;
                        }
                        if (emulatorId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.emulatorId,
                            referencedTable:
                                $$CompatibilityTestResultsTableReferences
                                    ._emulatorIdTable(db),
                            referencedColumn:
                                $$CompatibilityTestResultsTableReferences
                                    ._emulatorIdTable(db)
                                    .id,
                          ) as T;
                        }
                        if (consoleId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.consoleId,
                            referencedTable:
                                $$CompatibilityTestResultsTableReferences
                                    ._consoleIdTable(db),
                            referencedColumn:
                                $$CompatibilityTestResultsTableReferences
                                    ._consoleIdTable(db)
                                    .id,
                          ) as T;
                        }
                        if (gameId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.gameId,
                            referencedTable:
                                $$CompatibilityTestResultsTableReferences
                                    ._gameIdTable(db),
                            referencedColumn:
                                $$CompatibilityTestResultsTableReferences
                                    ._gameIdTable(db)
                                    .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [];
                  },
                );
              },
        ),
      );
}

typedef $$CompatibilityTestResultsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CompatibilityTestResultsTable,
      CompatibilityTestResultRow,
      $$CompatibilityTestResultsTableFilterComposer,
      $$CompatibilityTestResultsTableOrderingComposer,
      $$CompatibilityTestResultsTableAnnotationComposer,
      $$CompatibilityTestResultsTableCreateCompanionBuilder,
      $$CompatibilityTestResultsTableUpdateCompanionBuilder,
      (CompatibilityTestResultRow, $$CompatibilityTestResultsTableReferences),
      CompatibilityTestResultRow,
      PrefetchHooks Function({
        bool deviceId,
        bool emulatorId,
        bool consoleId,
        bool gameId,
      })
    >;
typedef $$EmulatorProfilesTableCreateCompanionBuilder =
    EmulatorProfilesCompanion Function({
      Value<int> id,
      required String emulatorId,
      Value<String?> consoleId,
      required String name,
      Value<String> settingsJson,
      Value<bool> isDefault,
    });
typedef $$EmulatorProfilesTableUpdateCompanionBuilder =
    EmulatorProfilesCompanion Function({
      Value<int> id,
      Value<String> emulatorId,
      Value<String?> consoleId,
      Value<String> name,
      Value<String> settingsJson,
      Value<bool> isDefault,
    });

final class $$EmulatorProfilesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $EmulatorProfilesTable,
          EmulatorProfileRow
        > {
  $$EmulatorProfilesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $EmulatorsTable _emulatorIdTable(_$AppDatabase db) =>
      db.emulators.createAlias('emulator_profiles__emulator_id__emulators__id');

  $$EmulatorsTableProcessedTableManager get emulatorId {
    final $_column = $_itemColumn<String>('emulator_id')!;

    final manager = $$EmulatorsTableTableManager(
      $_db,
      $_db.emulators,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_emulatorIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ConsolesTable _consoleIdTable(_$AppDatabase db) =>
      db.consoles.createAlias('emulator_profiles__console_id__consoles__id');

  $$ConsolesTableProcessedTableManager? get consoleId {
    final $_column = $_itemColumn<String>('console_id');
    if ($_column == null) return null;
    final manager = $$ConsolesTableTableManager(
      $_db,
      $_db.consoles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_consoleIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$EmulatorProfilesTableFilterComposer
    extends Composer<_$AppDatabase, $EmulatorProfilesTable> {
  $$EmulatorProfilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get settingsJson => $composableBuilder(
    column: $table.settingsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDefault => $composableBuilder(
    column: $table.isDefault,
    builder: (column) => ColumnFilters(column),
  );

  $$EmulatorsTableFilterComposer get emulatorId {
    final $$EmulatorsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.emulatorId,
      referencedTable: $db.emulators,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EmulatorsTableFilterComposer(
            $db: $db,
            $table: $db.emulators,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ConsolesTableFilterComposer get consoleId {
    final $$ConsolesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.consoleId,
      referencedTable: $db.consoles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ConsolesTableFilterComposer(
            $db: $db,
            $table: $db.consoles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EmulatorProfilesTableOrderingComposer
    extends Composer<_$AppDatabase, $EmulatorProfilesTable> {
  $$EmulatorProfilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get settingsJson => $composableBuilder(
    column: $table.settingsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDefault => $composableBuilder(
    column: $table.isDefault,
    builder: (column) => ColumnOrderings(column),
  );

  $$EmulatorsTableOrderingComposer get emulatorId {
    final $$EmulatorsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.emulatorId,
      referencedTable: $db.emulators,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EmulatorsTableOrderingComposer(
            $db: $db,
            $table: $db.emulators,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ConsolesTableOrderingComposer get consoleId {
    final $$ConsolesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.consoleId,
      referencedTable: $db.consoles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ConsolesTableOrderingComposer(
            $db: $db,
            $table: $db.consoles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EmulatorProfilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $EmulatorProfilesTable> {
  $$EmulatorProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get settingsJson => $composableBuilder(
    column: $table.settingsJson,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isDefault =>
      $composableBuilder(column: $table.isDefault, builder: (column) => column);

  $$EmulatorsTableAnnotationComposer get emulatorId {
    final $$EmulatorsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.emulatorId,
      referencedTable: $db.emulators,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EmulatorsTableAnnotationComposer(
            $db: $db,
            $table: $db.emulators,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ConsolesTableAnnotationComposer get consoleId {
    final $$ConsolesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.consoleId,
      referencedTable: $db.consoles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ConsolesTableAnnotationComposer(
            $db: $db,
            $table: $db.consoles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EmulatorProfilesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EmulatorProfilesTable,
          EmulatorProfileRow,
          $$EmulatorProfilesTableFilterComposer,
          $$EmulatorProfilesTableOrderingComposer,
          $$EmulatorProfilesTableAnnotationComposer,
          $$EmulatorProfilesTableCreateCompanionBuilder,
          $$EmulatorProfilesTableUpdateCompanionBuilder,
          (EmulatorProfileRow, $$EmulatorProfilesTableReferences),
          EmulatorProfileRow,
          PrefetchHooks Function({bool emulatorId, bool consoleId})
        > {
  $$EmulatorProfilesTableTableManager(
    _$AppDatabase db,
    $EmulatorProfilesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EmulatorProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EmulatorProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EmulatorProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> emulatorId = const Value.absent(),
                Value<String?> consoleId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> settingsJson = const Value.absent(),
                Value<bool> isDefault = const Value.absent(),
              }) => EmulatorProfilesCompanion(
                id: id,
                emulatorId: emulatorId,
                consoleId: consoleId,
                name: name,
                settingsJson: settingsJson,
                isDefault: isDefault,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String emulatorId,
                Value<String?> consoleId = const Value.absent(),
                required String name,
                Value<String> settingsJson = const Value.absent(),
                Value<bool> isDefault = const Value.absent(),
              }) => EmulatorProfilesCompanion.insert(
                id: id,
                emulatorId: emulatorId,
                consoleId: consoleId,
                name: name,
                settingsJson: settingsJson,
                isDefault: isDefault,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$EmulatorProfilesTable, EmulatorProfileRow>(
                    table,
                  ),
                  $$EmulatorProfilesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({emulatorId = false, consoleId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (emulatorId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.emulatorId,
                        referencedTable: $$EmulatorProfilesTableReferences
                            ._emulatorIdTable(db),
                        referencedColumn: $$EmulatorProfilesTableReferences
                            ._emulatorIdTable(db)
                            .id,
                      ) as T;
                    }
                    if (consoleId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.consoleId,
                        referencedTable: $$EmulatorProfilesTableReferences
                            ._consoleIdTable(db),
                        referencedColumn: $$EmulatorProfilesTableReferences
                            ._consoleIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$EmulatorProfilesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EmulatorProfilesTable,
      EmulatorProfileRow,
      $$EmulatorProfilesTableFilterComposer,
      $$EmulatorProfilesTableOrderingComposer,
      $$EmulatorProfilesTableAnnotationComposer,
      $$EmulatorProfilesTableCreateCompanionBuilder,
      $$EmulatorProfilesTableUpdateCompanionBuilder,
      (EmulatorProfileRow, $$EmulatorProfilesTableReferences),
      EmulatorProfileRow,
      PrefetchHooks Function({bool emulatorId, bool consoleId})
    >;
typedef $$EmulatorAdaptersTableCreateCompanionBuilder =
    EmulatorAdaptersCompanion Function({
      Value<int> id,
      required String emulatorId,
      required String packageName,
      required String strategy,
      Value<String?> launchMechanism,
      Value<String?> installedVersion,
      Value<bool> installed,
      Value<DateTime?> lastDetectedAt,
    });
typedef $$EmulatorAdaptersTableUpdateCompanionBuilder =
    EmulatorAdaptersCompanion Function({
      Value<int> id,
      Value<String> emulatorId,
      Value<String> packageName,
      Value<String> strategy,
      Value<String?> launchMechanism,
      Value<String?> installedVersion,
      Value<bool> installed,
      Value<DateTime?> lastDetectedAt,
    });

final class $$EmulatorAdaptersTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $EmulatorAdaptersTable,
          EmulatorAdapterRow
        > {
  $$EmulatorAdaptersTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $EmulatorsTable _emulatorIdTable(_$AppDatabase db) =>
      db.emulators.createAlias('emulator_adapters__emulator_id__emulators__id');

  $$EmulatorsTableProcessedTableManager get emulatorId {
    final $_column = $_itemColumn<String>('emulator_id')!;

    final manager = $$EmulatorsTableTableManager(
      $_db,
      $_db.emulators,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_emulatorIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$EmulatorAdaptersTableFilterComposer
    extends Composer<_$AppDatabase, $EmulatorAdaptersTable> {
  $$EmulatorAdaptersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get packageName => $composableBuilder(
    column: $table.packageName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get strategy => $composableBuilder(
    column: $table.strategy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get launchMechanism => $composableBuilder(
    column: $table.launchMechanism,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get installedVersion => $composableBuilder(
    column: $table.installedVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get installed => $composableBuilder(
    column: $table.installed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastDetectedAt => $composableBuilder(
    column: $table.lastDetectedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$EmulatorsTableFilterComposer get emulatorId {
    final $$EmulatorsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.emulatorId,
      referencedTable: $db.emulators,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EmulatorsTableFilterComposer(
            $db: $db,
            $table: $db.emulators,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EmulatorAdaptersTableOrderingComposer
    extends Composer<_$AppDatabase, $EmulatorAdaptersTable> {
  $$EmulatorAdaptersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get packageName => $composableBuilder(
    column: $table.packageName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get strategy => $composableBuilder(
    column: $table.strategy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get launchMechanism => $composableBuilder(
    column: $table.launchMechanism,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get installedVersion => $composableBuilder(
    column: $table.installedVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get installed => $composableBuilder(
    column: $table.installed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastDetectedAt => $composableBuilder(
    column: $table.lastDetectedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$EmulatorsTableOrderingComposer get emulatorId {
    final $$EmulatorsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.emulatorId,
      referencedTable: $db.emulators,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EmulatorsTableOrderingComposer(
            $db: $db,
            $table: $db.emulators,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EmulatorAdaptersTableAnnotationComposer
    extends Composer<_$AppDatabase, $EmulatorAdaptersTable> {
  $$EmulatorAdaptersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get packageName => $composableBuilder(
    column: $table.packageName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get strategy =>
      $composableBuilder(column: $table.strategy, builder: (column) => column);

  GeneratedColumn<String> get launchMechanism => $composableBuilder(
    column: $table.launchMechanism,
    builder: (column) => column,
  );

  GeneratedColumn<String> get installedVersion => $composableBuilder(
    column: $table.installedVersion,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get installed =>
      $composableBuilder(column: $table.installed, builder: (column) => column);

  GeneratedColumn<DateTime> get lastDetectedAt => $composableBuilder(
    column: $table.lastDetectedAt,
    builder: (column) => column,
  );

  $$EmulatorsTableAnnotationComposer get emulatorId {
    final $$EmulatorsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.emulatorId,
      referencedTable: $db.emulators,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EmulatorsTableAnnotationComposer(
            $db: $db,
            $table: $db.emulators,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EmulatorAdaptersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EmulatorAdaptersTable,
          EmulatorAdapterRow,
          $$EmulatorAdaptersTableFilterComposer,
          $$EmulatorAdaptersTableOrderingComposer,
          $$EmulatorAdaptersTableAnnotationComposer,
          $$EmulatorAdaptersTableCreateCompanionBuilder,
          $$EmulatorAdaptersTableUpdateCompanionBuilder,
          (EmulatorAdapterRow, $$EmulatorAdaptersTableReferences),
          EmulatorAdapterRow,
          PrefetchHooks Function({bool emulatorId})
        > {
  $$EmulatorAdaptersTableTableManager(
    _$AppDatabase db,
    $EmulatorAdaptersTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EmulatorAdaptersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EmulatorAdaptersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EmulatorAdaptersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> emulatorId = const Value.absent(),
                Value<String> packageName = const Value.absent(),
                Value<String> strategy = const Value.absent(),
                Value<String?> launchMechanism = const Value.absent(),
                Value<String?> installedVersion = const Value.absent(),
                Value<bool> installed = const Value.absent(),
                Value<DateTime?> lastDetectedAt = const Value.absent(),
              }) => EmulatorAdaptersCompanion(
                id: id,
                emulatorId: emulatorId,
                packageName: packageName,
                strategy: strategy,
                launchMechanism: launchMechanism,
                installedVersion: installedVersion,
                installed: installed,
                lastDetectedAt: lastDetectedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String emulatorId,
                required String packageName,
                required String strategy,
                Value<String?> launchMechanism = const Value.absent(),
                Value<String?> installedVersion = const Value.absent(),
                Value<bool> installed = const Value.absent(),
                Value<DateTime?> lastDetectedAt = const Value.absent(),
              }) => EmulatorAdaptersCompanion.insert(
                id: id,
                emulatorId: emulatorId,
                packageName: packageName,
                strategy: strategy,
                launchMechanism: launchMechanism,
                installedVersion: installedVersion,
                installed: installed,
                lastDetectedAt: lastDetectedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$EmulatorAdaptersTable, EmulatorAdapterRow>(
                    table,
                  ),
                  $$EmulatorAdaptersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({emulatorId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (emulatorId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.emulatorId,
                        referencedTable: $$EmulatorAdaptersTableReferences
                            ._emulatorIdTable(db),
                        referencedColumn: $$EmulatorAdaptersTableReferences
                            ._emulatorIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$EmulatorAdaptersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EmulatorAdaptersTable,
      EmulatorAdapterRow,
      $$EmulatorAdaptersTableFilterComposer,
      $$EmulatorAdaptersTableOrderingComposer,
      $$EmulatorAdaptersTableAnnotationComposer,
      $$EmulatorAdaptersTableCreateCompanionBuilder,
      $$EmulatorAdaptersTableUpdateCompanionBuilder,
      (EmulatorAdapterRow, $$EmulatorAdaptersTableReferences),
      EmulatorAdapterRow,
      PrefetchHooks Function({bool emulatorId})
    >;
typedef $$StorageDevicesTableCreateCompanionBuilder =
    StorageDevicesCompanion Function({
      Value<int> id,
      required String volumeId,
      required String description,
      required String kind,
      Value<String?> treeUri,
      required bool isRemovable,
      Value<int?> totalBytes,
      Value<int?> availableBytes,
      Value<bool> isConnected,
      Value<bool> isDefault,
      required DateTime lastSeenAt,
    });
typedef $$StorageDevicesTableUpdateCompanionBuilder =
    StorageDevicesCompanion Function({
      Value<int> id,
      Value<String> volumeId,
      Value<String> description,
      Value<String> kind,
      Value<String?> treeUri,
      Value<bool> isRemovable,
      Value<int?> totalBytes,
      Value<int?> availableBytes,
      Value<bool> isConnected,
      Value<bool> isDefault,
      Value<DateTime> lastSeenAt,
    });

final class $$StorageDevicesTableReferences
    extends
        BaseReferences<_$AppDatabase, $StorageDevicesTable, StorageDeviceRow> {
  $$StorageDevicesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$GameFilesTable, List<GameFileRow>>
  _gameFilesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.gameFiles,
    aliasName: 'storage_devices__id__game_files__storage_device_id',
  );

  $$GameFilesTableProcessedTableManager get gameFilesRefs {
    final manager = $$GameFilesTableTableManager(
      $_db,
      $_db.gameFiles,
    ).filter((f) => f.storageDeviceId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_gameFilesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$StorageDevicesTableFilterComposer
    extends Composer<_$AppDatabase, $StorageDevicesTable> {
  $$StorageDevicesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get volumeId => $composableBuilder(
    column: $table.volumeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get treeUri => $composableBuilder(
    column: $table.treeUri,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isRemovable => $composableBuilder(
    column: $table.isRemovable,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalBytes => $composableBuilder(
    column: $table.totalBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get availableBytes => $composableBuilder(
    column: $table.availableBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isConnected => $composableBuilder(
    column: $table.isConnected,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDefault => $composableBuilder(
    column: $table.isDefault,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSeenAt => $composableBuilder(
    column: $table.lastSeenAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> gameFilesRefs(
    Expression<bool> Function($$GameFilesTableFilterComposer f) f,
  ) {
    final $$GameFilesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.gameFiles,
      getReferencedColumn: (t) => t.storageDeviceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GameFilesTableFilterComposer(
            $db: $db,
            $table: $db.gameFiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$StorageDevicesTableOrderingComposer
    extends Composer<_$AppDatabase, $StorageDevicesTable> {
  $$StorageDevicesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get volumeId => $composableBuilder(
    column: $table.volumeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get treeUri => $composableBuilder(
    column: $table.treeUri,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isRemovable => $composableBuilder(
    column: $table.isRemovable,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalBytes => $composableBuilder(
    column: $table.totalBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get availableBytes => $composableBuilder(
    column: $table.availableBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isConnected => $composableBuilder(
    column: $table.isConnected,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDefault => $composableBuilder(
    column: $table.isDefault,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSeenAt => $composableBuilder(
    column: $table.lastSeenAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$StorageDevicesTableAnnotationComposer
    extends Composer<_$AppDatabase, $StorageDevicesTable> {
  $$StorageDevicesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get volumeId =>
      $composableBuilder(column: $table.volumeId, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get treeUri =>
      $composableBuilder(column: $table.treeUri, builder: (column) => column);

  GeneratedColumn<bool> get isRemovable => $composableBuilder(
    column: $table.isRemovable,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalBytes => $composableBuilder(
    column: $table.totalBytes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get availableBytes => $composableBuilder(
    column: $table.availableBytes,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isConnected => $composableBuilder(
    column: $table.isConnected,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isDefault =>
      $composableBuilder(column: $table.isDefault, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSeenAt => $composableBuilder(
    column: $table.lastSeenAt,
    builder: (column) => column,
  );

  Expression<T> gameFilesRefs<T extends Object>(
    Expression<T> Function($$GameFilesTableAnnotationComposer a) f,
  ) {
    final $$GameFilesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.gameFiles,
      getReferencedColumn: (t) => t.storageDeviceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GameFilesTableAnnotationComposer(
            $db: $db,
            $table: $db.gameFiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$StorageDevicesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StorageDevicesTable,
          StorageDeviceRow,
          $$StorageDevicesTableFilterComposer,
          $$StorageDevicesTableOrderingComposer,
          $$StorageDevicesTableAnnotationComposer,
          $$StorageDevicesTableCreateCompanionBuilder,
          $$StorageDevicesTableUpdateCompanionBuilder,
          (StorageDeviceRow, $$StorageDevicesTableReferences),
          StorageDeviceRow,
          PrefetchHooks Function({bool gameFilesRefs})
        > {
  $$StorageDevicesTableTableManager(
    _$AppDatabase db,
    $StorageDevicesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StorageDevicesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StorageDevicesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StorageDevicesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> volumeId = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String?> treeUri = const Value.absent(),
                Value<bool> isRemovable = const Value.absent(),
                Value<int?> totalBytes = const Value.absent(),
                Value<int?> availableBytes = const Value.absent(),
                Value<bool> isConnected = const Value.absent(),
                Value<bool> isDefault = const Value.absent(),
                Value<DateTime> lastSeenAt = const Value.absent(),
              }) => StorageDevicesCompanion(
                id: id,
                volumeId: volumeId,
                description: description,
                kind: kind,
                treeUri: treeUri,
                isRemovable: isRemovable,
                totalBytes: totalBytes,
                availableBytes: availableBytes,
                isConnected: isConnected,
                isDefault: isDefault,
                lastSeenAt: lastSeenAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String volumeId,
                required String description,
                required String kind,
                Value<String?> treeUri = const Value.absent(),
                required bool isRemovable,
                Value<int?> totalBytes = const Value.absent(),
                Value<int?> availableBytes = const Value.absent(),
                Value<bool> isConnected = const Value.absent(),
                Value<bool> isDefault = const Value.absent(),
                required DateTime lastSeenAt,
              }) => StorageDevicesCompanion.insert(
                id: id,
                volumeId: volumeId,
                description: description,
                kind: kind,
                treeUri: treeUri,
                isRemovable: isRemovable,
                totalBytes: totalBytes,
                availableBytes: availableBytes,
                isConnected: isConnected,
                isDefault: isDefault,
                lastSeenAt: lastSeenAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$StorageDevicesTable, StorageDeviceRow>(table),
                  $$StorageDevicesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({gameFilesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (gameFilesRefs) db.gameFiles],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (gameFilesRefs)
                    await $_getPrefetchedDataByColumns<
                      StorageDeviceRow,
                      $StorageDevicesTable,
                      GameFileRow,
                      $GameFilesTable
                    >(
                      currentTable: table,
                      referencedTable: $$StorageDevicesTableReferences
                          ._gameFilesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$StorageDevicesTableReferences(
                            db,
                            table,
                            p0,
                          ).gameFilesRefs,
                      currentColumn: 'id',
                      referencedColumn: 'storage_device_id',
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$StorageDevicesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StorageDevicesTable,
      StorageDeviceRow,
      $$StorageDevicesTableFilterComposer,
      $$StorageDevicesTableOrderingComposer,
      $$StorageDevicesTableAnnotationComposer,
      $$StorageDevicesTableCreateCompanionBuilder,
      $$StorageDevicesTableUpdateCompanionBuilder,
      (StorageDeviceRow, $$StorageDevicesTableReferences),
      StorageDeviceRow,
      PrefetchHooks Function({bool gameFilesRefs})
    >;
typedef $$GameFilesTableCreateCompanionBuilder = GameFilesCompanion Function({
  Value<int> id,
  required int gameId,
  required String uri,
  required String displayPath,
  required String extension,
  Value<int?> sizeBytes,
  Value<String?> sha1,
  Value<String?> crc32,
  Value<int?> storageDeviceId,
  Value<bool> fileExists,
  Value<DateTime?> lastVerifiedAt,
  Value<String?> rootUri,
  Value<int?> lastModified,
  Value<bool> isPrimary,
  Value<int?> discNumber,
  Value<String?> headerStatus,
  Value<String?> headerDetail,
});
typedef $$GameFilesTableUpdateCompanionBuilder = GameFilesCompanion Function({
  Value<int> id,
  Value<int> gameId,
  Value<String> uri,
  Value<String> displayPath,
  Value<String> extension,
  Value<int?> sizeBytes,
  Value<String?> sha1,
  Value<String?> crc32,
  Value<int?> storageDeviceId,
  Value<bool> fileExists,
  Value<DateTime?> lastVerifiedAt,
  Value<String?> rootUri,
  Value<int?> lastModified,
  Value<bool> isPrimary,
  Value<int?> discNumber,
  Value<String?> headerStatus,
  Value<String?> headerDetail,
});

final class $$GameFilesTableReferences
    extends BaseReferences<_$AppDatabase, $GameFilesTable, GameFileRow> {
  $$GameFilesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $GamesTable _gameIdTable(_$AppDatabase db) =>
      db.games.createAlias('game_files__game_id__games__id');

  $$GamesTableProcessedTableManager get gameId {
    final $_column = $_itemColumn<int>('game_id')!;

    final manager = $$GamesTableTableManager(
      $_db,
      $_db.games,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_gameIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $StorageDevicesTable _storageDeviceIdTable(_$AppDatabase db) => db
      .storageDevices
      .createAlias('game_files__storage_device_id__storage_devices__id');

  $$StorageDevicesTableProcessedTableManager? get storageDeviceId {
    final $_column = $_itemColumn<int>('storage_device_id');
    if ($_column == null) return null;
    final manager = $$StorageDevicesTableTableManager(
      $_db,
      $_db.storageDevices,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_storageDeviceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$GameFilesTableFilterComposer
    extends Composer<_$AppDatabase, $GameFilesTable> {
  $$GameFilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get uri => $composableBuilder(
    column: $table.uri,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayPath => $composableBuilder(
    column: $table.displayPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get extension => $composableBuilder(
    column: $table.extension,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sizeBytes => $composableBuilder(
    column: $table.sizeBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sha1 => $composableBuilder(
    column: $table.sha1,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get crc32 => $composableBuilder(
    column: $table.crc32,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get fileExists => $composableBuilder(
    column: $table.fileExists,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastVerifiedAt => $composableBuilder(
    column: $table.lastVerifiedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rootUri => $composableBuilder(
    column: $table.rootUri,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastModified => $composableBuilder(
    column: $table.lastModified,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isPrimary => $composableBuilder(
    column: $table.isPrimary,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get discNumber => $composableBuilder(
    column: $table.discNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get headerStatus => $composableBuilder(
    column: $table.headerStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get headerDetail => $composableBuilder(
    column: $table.headerDetail,
    builder: (column) => ColumnFilters(column),
  );

  $$GamesTableFilterComposer get gameId {
    final $$GamesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gameId,
      referencedTable: $db.games,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GamesTableFilterComposer(
            $db: $db,
            $table: $db.games,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$StorageDevicesTableFilterComposer get storageDeviceId {
    final $$StorageDevicesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.storageDeviceId,
      referencedTable: $db.storageDevices,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StorageDevicesTableFilterComposer(
            $db: $db,
            $table: $db.storageDevices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GameFilesTableOrderingComposer
    extends Composer<_$AppDatabase, $GameFilesTable> {
  $$GameFilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get uri => $composableBuilder(
    column: $table.uri,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayPath => $composableBuilder(
    column: $table.displayPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get extension => $composableBuilder(
    column: $table.extension,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sizeBytes => $composableBuilder(
    column: $table.sizeBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sha1 => $composableBuilder(
    column: $table.sha1,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get crc32 => $composableBuilder(
    column: $table.crc32,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get fileExists => $composableBuilder(
    column: $table.fileExists,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastVerifiedAt => $composableBuilder(
    column: $table.lastVerifiedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rootUri => $composableBuilder(
    column: $table.rootUri,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastModified => $composableBuilder(
    column: $table.lastModified,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isPrimary => $composableBuilder(
    column: $table.isPrimary,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get discNumber => $composableBuilder(
    column: $table.discNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get headerStatus => $composableBuilder(
    column: $table.headerStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get headerDetail => $composableBuilder(
    column: $table.headerDetail,
    builder: (column) => ColumnOrderings(column),
  );

  $$GamesTableOrderingComposer get gameId {
    final $$GamesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gameId,
      referencedTable: $db.games,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GamesTableOrderingComposer(
            $db: $db,
            $table: $db.games,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$StorageDevicesTableOrderingComposer get storageDeviceId {
    final $$StorageDevicesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.storageDeviceId,
      referencedTable: $db.storageDevices,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StorageDevicesTableOrderingComposer(
            $db: $db,
            $table: $db.storageDevices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GameFilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $GameFilesTable> {
  $$GameFilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get uri =>
      $composableBuilder(column: $table.uri, builder: (column) => column);

  GeneratedColumn<String> get displayPath => $composableBuilder(
    column: $table.displayPath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get extension =>
      $composableBuilder(column: $table.extension, builder: (column) => column);

  GeneratedColumn<int> get sizeBytes =>
      $composableBuilder(column: $table.sizeBytes, builder: (column) => column);

  GeneratedColumn<String> get sha1 =>
      $composableBuilder(column: $table.sha1, builder: (column) => column);

  GeneratedColumn<String> get crc32 =>
      $composableBuilder(column: $table.crc32, builder: (column) => column);

  GeneratedColumn<bool> get fileExists => $composableBuilder(
    column: $table.fileExists,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastVerifiedAt => $composableBuilder(
    column: $table.lastVerifiedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get rootUri =>
      $composableBuilder(column: $table.rootUri, builder: (column) => column);

  GeneratedColumn<int> get lastModified => $composableBuilder(
    column: $table.lastModified,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isPrimary =>
      $composableBuilder(column: $table.isPrimary, builder: (column) => column);

  GeneratedColumn<int> get discNumber => $composableBuilder(
    column: $table.discNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get headerStatus => $composableBuilder(
    column: $table.headerStatus,
    builder: (column) => column,
  );

  GeneratedColumn<String> get headerDetail => $composableBuilder(
    column: $table.headerDetail,
    builder: (column) => column,
  );

  $$GamesTableAnnotationComposer get gameId {
    final $$GamesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gameId,
      referencedTable: $db.games,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GamesTableAnnotationComposer(
            $db: $db,
            $table: $db.games,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$StorageDevicesTableAnnotationComposer get storageDeviceId {
    final $$StorageDevicesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.storageDeviceId,
      referencedTable: $db.storageDevices,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StorageDevicesTableAnnotationComposer(
            $db: $db,
            $table: $db.storageDevices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GameFilesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GameFilesTable,
          GameFileRow,
          $$GameFilesTableFilterComposer,
          $$GameFilesTableOrderingComposer,
          $$GameFilesTableAnnotationComposer,
          $$GameFilesTableCreateCompanionBuilder,
          $$GameFilesTableUpdateCompanionBuilder,
          (GameFileRow, $$GameFilesTableReferences),
          GameFileRow,
          PrefetchHooks Function({bool gameId, bool storageDeviceId})
        > {
  $$GameFilesTableTableManager(_$AppDatabase db, $GameFilesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GameFilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GameFilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GameFilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> gameId = const Value.absent(),
                Value<String> uri = const Value.absent(),
                Value<String> displayPath = const Value.absent(),
                Value<String> extension = const Value.absent(),
                Value<int?> sizeBytes = const Value.absent(),
                Value<String?> sha1 = const Value.absent(),
                Value<String?> crc32 = const Value.absent(),
                Value<int?> storageDeviceId = const Value.absent(),
                Value<bool> fileExists = const Value.absent(),
                Value<DateTime?> lastVerifiedAt = const Value.absent(),
                Value<String?> rootUri = const Value.absent(),
                Value<int?> lastModified = const Value.absent(),
                Value<bool> isPrimary = const Value.absent(),
                Value<int?> discNumber = const Value.absent(),
                Value<String?> headerStatus = const Value.absent(),
                Value<String?> headerDetail = const Value.absent(),
              }) => GameFilesCompanion(
                id: id,
                gameId: gameId,
                uri: uri,
                displayPath: displayPath,
                extension: extension,
                sizeBytes: sizeBytes,
                sha1: sha1,
                crc32: crc32,
                storageDeviceId: storageDeviceId,
                fileExists: fileExists,
                lastVerifiedAt: lastVerifiedAt,
                rootUri: rootUri,
                lastModified: lastModified,
                isPrimary: isPrimary,
                discNumber: discNumber,
                headerStatus: headerStatus,
                headerDetail: headerDetail,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int gameId,
                required String uri,
                required String displayPath,
                required String extension,
                Value<int?> sizeBytes = const Value.absent(),
                Value<String?> sha1 = const Value.absent(),
                Value<String?> crc32 = const Value.absent(),
                Value<int?> storageDeviceId = const Value.absent(),
                Value<bool> fileExists = const Value.absent(),
                Value<DateTime?> lastVerifiedAt = const Value.absent(),
                Value<String?> rootUri = const Value.absent(),
                Value<int?> lastModified = const Value.absent(),
                Value<bool> isPrimary = const Value.absent(),
                Value<int?> discNumber = const Value.absent(),
                Value<String?> headerStatus = const Value.absent(),
                Value<String?> headerDetail = const Value.absent(),
              }) => GameFilesCompanion.insert(
                id: id,
                gameId: gameId,
                uri: uri,
                displayPath: displayPath,
                extension: extension,
                sizeBytes: sizeBytes,
                sha1: sha1,
                crc32: crc32,
                storageDeviceId: storageDeviceId,
                fileExists: fileExists,
                lastVerifiedAt: lastVerifiedAt,
                rootUri: rootUri,
                lastModified: lastModified,
                isPrimary: isPrimary,
                discNumber: discNumber,
                headerStatus: headerStatus,
                headerDetail: headerDetail,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$GameFilesTable, GameFileRow>(table),
                  $$GameFilesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({gameId = false, storageDeviceId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (gameId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.gameId,
                        referencedTable: $$GameFilesTableReferences
                            ._gameIdTable(db),
                        referencedColumn: $$GameFilesTableReferences
                            ._gameIdTable(db)
                            .id,
                      ) as T;
                    }
                    if (storageDeviceId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.storageDeviceId,
                        referencedTable: $$GameFilesTableReferences
                            ._storageDeviceIdTable(db),
                        referencedColumn: $$GameFilesTableReferences
                            ._storageDeviceIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$GameFilesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GameFilesTable,
      GameFileRow,
      $$GameFilesTableFilterComposer,
      $$GameFilesTableOrderingComposer,
      $$GameFilesTableAnnotationComposer,
      $$GameFilesTableCreateCompanionBuilder,
      $$GameFilesTableUpdateCompanionBuilder,
      (GameFileRow, $$GameFilesTableReferences),
      GameFileRow,
      PrefetchHooks Function({bool gameId, bool storageDeviceId})
    >;
typedef $$GameMetadataTableCreateCompanionBuilder =
    GameMetadataCompanion Function({
      Value<int> gameId,
      Value<String?> description,
      Value<String?> developer,
      Value<String?> publisher,
      Value<String?> releaseDate,
      Value<String?> genre,
      Value<int?> players,
      Value<String?> provider,
      Value<String?> providerId,
      Value<bool> editedManually,
      Value<DateTime?> fetchedAt,
    });
typedef $$GameMetadataTableUpdateCompanionBuilder =
    GameMetadataCompanion Function({
      Value<int> gameId,
      Value<String?> description,
      Value<String?> developer,
      Value<String?> publisher,
      Value<String?> releaseDate,
      Value<String?> genre,
      Value<int?> players,
      Value<String?> provider,
      Value<String?> providerId,
      Value<bool> editedManually,
      Value<DateTime?> fetchedAt,
    });

final class $$GameMetadataTableReferences
    extends BaseReferences<_$AppDatabase, $GameMetadataTable, GameMetadataRow> {
  $$GameMetadataTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $GamesTable _gameIdTable(_$AppDatabase db) =>
      db.games.createAlias('game_metadata__game_id__games__id');

  $$GamesTableProcessedTableManager get gameId {
    final $_column = $_itemColumn<int>('game_id')!;

    final manager = $$GamesTableTableManager(
      $_db,
      $_db.games,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_gameIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$GameMetadataTableFilterComposer
    extends Composer<_$AppDatabase, $GameMetadataTable> {
  $$GameMetadataTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get developer => $composableBuilder(
    column: $table.developer,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get publisher => $composableBuilder(
    column: $table.publisher,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get releaseDate => $composableBuilder(
    column: $table.releaseDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get genre => $composableBuilder(
    column: $table.genre,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get players => $composableBuilder(
    column: $table.players,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get provider => $composableBuilder(
    column: $table.provider,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get providerId => $composableBuilder(
    column: $table.providerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get editedManually => $composableBuilder(
    column: $table.editedManually,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$GamesTableFilterComposer get gameId {
    final $$GamesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gameId,
      referencedTable: $db.games,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GamesTableFilterComposer(
            $db: $db,
            $table: $db.games,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GameMetadataTableOrderingComposer
    extends Composer<_$AppDatabase, $GameMetadataTable> {
  $$GameMetadataTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get developer => $composableBuilder(
    column: $table.developer,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get publisher => $composableBuilder(
    column: $table.publisher,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get releaseDate => $composableBuilder(
    column: $table.releaseDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get genre => $composableBuilder(
    column: $table.genre,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get players => $composableBuilder(
    column: $table.players,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get provider => $composableBuilder(
    column: $table.provider,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get providerId => $composableBuilder(
    column: $table.providerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get editedManually => $composableBuilder(
    column: $table.editedManually,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$GamesTableOrderingComposer get gameId {
    final $$GamesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gameId,
      referencedTable: $db.games,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GamesTableOrderingComposer(
            $db: $db,
            $table: $db.games,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GameMetadataTableAnnotationComposer
    extends Composer<_$AppDatabase, $GameMetadataTable> {
  $$GameMetadataTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get developer =>
      $composableBuilder(column: $table.developer, builder: (column) => column);

  GeneratedColumn<String> get publisher =>
      $composableBuilder(column: $table.publisher, builder: (column) => column);

  GeneratedColumn<String> get releaseDate => $composableBuilder(
    column: $table.releaseDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get genre =>
      $composableBuilder(column: $table.genre, builder: (column) => column);

  GeneratedColumn<int> get players =>
      $composableBuilder(column: $table.players, builder: (column) => column);

  GeneratedColumn<String> get provider =>
      $composableBuilder(column: $table.provider, builder: (column) => column);

  GeneratedColumn<String> get providerId => $composableBuilder(
    column: $table.providerId,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get editedManually => $composableBuilder(
    column: $table.editedManually,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get fetchedAt =>
      $composableBuilder(column: $table.fetchedAt, builder: (column) => column);

  $$GamesTableAnnotationComposer get gameId {
    final $$GamesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gameId,
      referencedTable: $db.games,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GamesTableAnnotationComposer(
            $db: $db,
            $table: $db.games,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GameMetadataTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GameMetadataTable,
          GameMetadataRow,
          $$GameMetadataTableFilterComposer,
          $$GameMetadataTableOrderingComposer,
          $$GameMetadataTableAnnotationComposer,
          $$GameMetadataTableCreateCompanionBuilder,
          $$GameMetadataTableUpdateCompanionBuilder,
          (GameMetadataRow, $$GameMetadataTableReferences),
          GameMetadataRow,
          PrefetchHooks Function({bool gameId})
        > {
  $$GameMetadataTableTableManager(_$AppDatabase db, $GameMetadataTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GameMetadataTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GameMetadataTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GameMetadataTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> gameId = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String?> developer = const Value.absent(),
                Value<String?> publisher = const Value.absent(),
                Value<String?> releaseDate = const Value.absent(),
                Value<String?> genre = const Value.absent(),
                Value<int?> players = const Value.absent(),
                Value<String?> provider = const Value.absent(),
                Value<String?> providerId = const Value.absent(),
                Value<bool> editedManually = const Value.absent(),
                Value<DateTime?> fetchedAt = const Value.absent(),
              }) => GameMetadataCompanion(
                gameId: gameId,
                description: description,
                developer: developer,
                publisher: publisher,
                releaseDate: releaseDate,
                genre: genre,
                players: players,
                provider: provider,
                providerId: providerId,
                editedManually: editedManually,
                fetchedAt: fetchedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> gameId = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String?> developer = const Value.absent(),
                Value<String?> publisher = const Value.absent(),
                Value<String?> releaseDate = const Value.absent(),
                Value<String?> genre = const Value.absent(),
                Value<int?> players = const Value.absent(),
                Value<String?> provider = const Value.absent(),
                Value<String?> providerId = const Value.absent(),
                Value<bool> editedManually = const Value.absent(),
                Value<DateTime?> fetchedAt = const Value.absent(),
              }) => GameMetadataCompanion.insert(
                gameId: gameId,
                description: description,
                developer: developer,
                publisher: publisher,
                releaseDate: releaseDate,
                genre: genre,
                players: players,
                provider: provider,
                providerId: providerId,
                editedManually: editedManually,
                fetchedAt: fetchedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$GameMetadataTable, GameMetadataRow>(table),
                  $$GameMetadataTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({gameId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (gameId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.gameId,
                        referencedTable: $$GameMetadataTableReferences
                            ._gameIdTable(db),
                        referencedColumn: $$GameMetadataTableReferences
                            ._gameIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$GameMetadataTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GameMetadataTable,
      GameMetadataRow,
      $$GameMetadataTableFilterComposer,
      $$GameMetadataTableOrderingComposer,
      $$GameMetadataTableAnnotationComposer,
      $$GameMetadataTableCreateCompanionBuilder,
      $$GameMetadataTableUpdateCompanionBuilder,
      (GameMetadataRow, $$GameMetadataTableReferences),
      GameMetadataRow,
      PrefetchHooks Function({bool gameId})
    >;
typedef $$GameArtworksTableCreateCompanionBuilder =
    GameArtworksCompanion Function({
      Value<int> id,
      required int gameId,
      required String type,
      required String localPath,
      Value<String?> sourceUrl,
      Value<String?> provider,
      required DateTime fetchedAt,
    });
typedef $$GameArtworksTableUpdateCompanionBuilder =
    GameArtworksCompanion Function({
      Value<int> id,
      Value<int> gameId,
      Value<String> type,
      Value<String> localPath,
      Value<String?> sourceUrl,
      Value<String?> provider,
      Value<DateTime> fetchedAt,
    });

final class $$GameArtworksTableReferences
    extends BaseReferences<_$AppDatabase, $GameArtworksTable, GameArtworkRow> {
  $$GameArtworksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $GamesTable _gameIdTable(_$AppDatabase db) =>
      db.games.createAlias('game_artworks__game_id__games__id');

  $$GamesTableProcessedTableManager get gameId {
    final $_column = $_itemColumn<int>('game_id')!;

    final manager = $$GamesTableTableManager(
      $_db,
      $_db.games,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_gameIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$GameArtworksTableFilterComposer
    extends Composer<_$AppDatabase, $GameArtworksTable> {
  $$GameArtworksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localPath => $composableBuilder(
    column: $table.localPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceUrl => $composableBuilder(
    column: $table.sourceUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get provider => $composableBuilder(
    column: $table.provider,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$GamesTableFilterComposer get gameId {
    final $$GamesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gameId,
      referencedTable: $db.games,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GamesTableFilterComposer(
            $db: $db,
            $table: $db.games,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GameArtworksTableOrderingComposer
    extends Composer<_$AppDatabase, $GameArtworksTable> {
  $$GameArtworksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localPath => $composableBuilder(
    column: $table.localPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceUrl => $composableBuilder(
    column: $table.sourceUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get provider => $composableBuilder(
    column: $table.provider,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$GamesTableOrderingComposer get gameId {
    final $$GamesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gameId,
      referencedTable: $db.games,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GamesTableOrderingComposer(
            $db: $db,
            $table: $db.games,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GameArtworksTableAnnotationComposer
    extends Composer<_$AppDatabase, $GameArtworksTable> {
  $$GameArtworksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get localPath =>
      $composableBuilder(column: $table.localPath, builder: (column) => column);

  GeneratedColumn<String> get sourceUrl =>
      $composableBuilder(column: $table.sourceUrl, builder: (column) => column);

  GeneratedColumn<String> get provider =>
      $composableBuilder(column: $table.provider, builder: (column) => column);

  GeneratedColumn<DateTime> get fetchedAt =>
      $composableBuilder(column: $table.fetchedAt, builder: (column) => column);

  $$GamesTableAnnotationComposer get gameId {
    final $$GamesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gameId,
      referencedTable: $db.games,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GamesTableAnnotationComposer(
            $db: $db,
            $table: $db.games,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GameArtworksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GameArtworksTable,
          GameArtworkRow,
          $$GameArtworksTableFilterComposer,
          $$GameArtworksTableOrderingComposer,
          $$GameArtworksTableAnnotationComposer,
          $$GameArtworksTableCreateCompanionBuilder,
          $$GameArtworksTableUpdateCompanionBuilder,
          (GameArtworkRow, $$GameArtworksTableReferences),
          GameArtworkRow,
          PrefetchHooks Function({bool gameId})
        > {
  $$GameArtworksTableTableManager(_$AppDatabase db, $GameArtworksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GameArtworksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GameArtworksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GameArtworksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> gameId = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> localPath = const Value.absent(),
                Value<String?> sourceUrl = const Value.absent(),
                Value<String?> provider = const Value.absent(),
                Value<DateTime> fetchedAt = const Value.absent(),
              }) => GameArtworksCompanion(
                id: id,
                gameId: gameId,
                type: type,
                localPath: localPath,
                sourceUrl: sourceUrl,
                provider: provider,
                fetchedAt: fetchedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int gameId,
                required String type,
                required String localPath,
                Value<String?> sourceUrl = const Value.absent(),
                Value<String?> provider = const Value.absent(),
                required DateTime fetchedAt,
              }) => GameArtworksCompanion.insert(
                id: id,
                gameId: gameId,
                type: type,
                localPath: localPath,
                sourceUrl: sourceUrl,
                provider: provider,
                fetchedAt: fetchedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$GameArtworksTable, GameArtworkRow>(table),
                  $$GameArtworksTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({gameId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (gameId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.gameId,
                        referencedTable: $$GameArtworksTableReferences
                            ._gameIdTable(db),
                        referencedColumn: $$GameArtworksTableReferences
                            ._gameIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$GameArtworksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GameArtworksTable,
      GameArtworkRow,
      $$GameArtworksTableFilterComposer,
      $$GameArtworksTableOrderingComposer,
      $$GameArtworksTableAnnotationComposer,
      $$GameArtworksTableCreateCompanionBuilder,
      $$GameArtworksTableUpdateCompanionBuilder,
      (GameArtworkRow, $$GameArtworksTableReferences),
      GameArtworkRow,
      PrefetchHooks Function({bool gameId})
    >;
typedef $$FavoritesTableCreateCompanionBuilder = FavoritesCompanion Function({
  Value<int> gameId,
  required DateTime addedAt,
});
typedef $$FavoritesTableUpdateCompanionBuilder = FavoritesCompanion Function({
  Value<int> gameId,
  Value<DateTime> addedAt,
});

final class $$FavoritesTableReferences
    extends BaseReferences<_$AppDatabase, $FavoritesTable, FavoriteRow> {
  $$FavoritesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $GamesTable _gameIdTable(_$AppDatabase db) =>
      db.games.createAlias('favorites__game_id__games__id');

  $$GamesTableProcessedTableManager get gameId {
    final $_column = $_itemColumn<int>('game_id')!;

    final manager = $$GamesTableTableManager(
      $_db,
      $_db.games,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_gameIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$FavoritesTableFilterComposer
    extends Composer<_$AppDatabase, $FavoritesTable> {
  $$FavoritesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<DateTime> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$GamesTableFilterComposer get gameId {
    final $$GamesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gameId,
      referencedTable: $db.games,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GamesTableFilterComposer(
            $db: $db,
            $table: $db.games,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FavoritesTableOrderingComposer
    extends Composer<_$AppDatabase, $FavoritesTable> {
  $$FavoritesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<DateTime> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$GamesTableOrderingComposer get gameId {
    final $$GamesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gameId,
      referencedTable: $db.games,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GamesTableOrderingComposer(
            $db: $db,
            $table: $db.games,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FavoritesTableAnnotationComposer
    extends Composer<_$AppDatabase, $FavoritesTable> {
  $$FavoritesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<DateTime> get addedAt =>
      $composableBuilder(column: $table.addedAt, builder: (column) => column);

  $$GamesTableAnnotationComposer get gameId {
    final $$GamesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gameId,
      referencedTable: $db.games,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GamesTableAnnotationComposer(
            $db: $db,
            $table: $db.games,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FavoritesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FavoritesTable,
          FavoriteRow,
          $$FavoritesTableFilterComposer,
          $$FavoritesTableOrderingComposer,
          $$FavoritesTableAnnotationComposer,
          $$FavoritesTableCreateCompanionBuilder,
          $$FavoritesTableUpdateCompanionBuilder,
          (FavoriteRow, $$FavoritesTableReferences),
          FavoriteRow,
          PrefetchHooks Function({bool gameId})
        > {
  $$FavoritesTableTableManager(_$AppDatabase db, $FavoritesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FavoritesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FavoritesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FavoritesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> gameId = const Value.absent(),
            Value<DateTime> addedAt = const Value.absent(),
          }) => FavoritesCompanion(gameId: gameId, addedAt: addedAt),
          createCompanionCallback: ({
            Value<int> gameId = const Value.absent(),
            required DateTime addedAt,
          }) => FavoritesCompanion.insert(gameId: gameId, addedAt: addedAt),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$FavoritesTable, FavoriteRow>(table),
                  $$FavoritesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({gameId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (gameId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.gameId,
                        referencedTable: $$FavoritesTableReferences
                            ._gameIdTable(db),
                        referencedColumn: $$FavoritesTableReferences
                            ._gameIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$FavoritesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FavoritesTable,
      FavoriteRow,
      $$FavoritesTableFilterComposer,
      $$FavoritesTableOrderingComposer,
      $$FavoritesTableAnnotationComposer,
      $$FavoritesTableCreateCompanionBuilder,
      $$FavoritesTableUpdateCompanionBuilder,
      (FavoriteRow, $$FavoritesTableReferences),
      FavoriteRow,
      PrefetchHooks Function({bool gameId})
    >;
typedef $$GameHistoryTableCreateCompanionBuilder =
    GameHistoryCompanion Function({
      Value<int> id,
      required int gameId,
      Value<String?> emulatorId,
      required DateTime startedAt,
      Value<DateTime?> endedAt,
      Value<int?> durationSeconds,
      Value<String?> exitStatus,
    });
typedef $$GameHistoryTableUpdateCompanionBuilder =
    GameHistoryCompanion Function({
      Value<int> id,
      Value<int> gameId,
      Value<String?> emulatorId,
      Value<DateTime> startedAt,
      Value<DateTime?> endedAt,
      Value<int?> durationSeconds,
      Value<String?> exitStatus,
    });

final class $$GameHistoryTableReferences
    extends BaseReferences<_$AppDatabase, $GameHistoryTable, GameHistoryRow> {
  $$GameHistoryTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $GamesTable _gameIdTable(_$AppDatabase db) =>
      db.games.createAlias('game_history__game_id__games__id');

  $$GamesTableProcessedTableManager get gameId {
    final $_column = $_itemColumn<int>('game_id')!;

    final manager = $$GamesTableTableManager(
      $_db,
      $_db.games,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_gameIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$GameHistoryTableFilterComposer
    extends Composer<_$AppDatabase, $GameHistoryTable> {
  $$GameHistoryTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get emulatorId => $composableBuilder(
    column: $table.emulatorId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get exitStatus => $composableBuilder(
    column: $table.exitStatus,
    builder: (column) => ColumnFilters(column),
  );

  $$GamesTableFilterComposer get gameId {
    final $$GamesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gameId,
      referencedTable: $db.games,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GamesTableFilterComposer(
            $db: $db,
            $table: $db.games,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GameHistoryTableOrderingComposer
    extends Composer<_$AppDatabase, $GameHistoryTable> {
  $$GameHistoryTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get emulatorId => $composableBuilder(
    column: $table.emulatorId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get exitStatus => $composableBuilder(
    column: $table.exitStatus,
    builder: (column) => ColumnOrderings(column),
  );

  $$GamesTableOrderingComposer get gameId {
    final $$GamesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gameId,
      referencedTable: $db.games,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GamesTableOrderingComposer(
            $db: $db,
            $table: $db.games,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GameHistoryTableAnnotationComposer
    extends Composer<_$AppDatabase, $GameHistoryTable> {
  $$GameHistoryTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get emulatorId => $composableBuilder(
    column: $table.emulatorId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get endedAt =>
      $composableBuilder(column: $table.endedAt, builder: (column) => column);

  GeneratedColumn<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<String> get exitStatus => $composableBuilder(
    column: $table.exitStatus,
    builder: (column) => column,
  );

  $$GamesTableAnnotationComposer get gameId {
    final $$GamesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gameId,
      referencedTable: $db.games,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GamesTableAnnotationComposer(
            $db: $db,
            $table: $db.games,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GameHistoryTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GameHistoryTable,
          GameHistoryRow,
          $$GameHistoryTableFilterComposer,
          $$GameHistoryTableOrderingComposer,
          $$GameHistoryTableAnnotationComposer,
          $$GameHistoryTableCreateCompanionBuilder,
          $$GameHistoryTableUpdateCompanionBuilder,
          (GameHistoryRow, $$GameHistoryTableReferences),
          GameHistoryRow,
          PrefetchHooks Function({bool gameId})
        > {
  $$GameHistoryTableTableManager(_$AppDatabase db, $GameHistoryTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GameHistoryTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GameHistoryTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GameHistoryTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> gameId = const Value.absent(),
                Value<String?> emulatorId = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<DateTime?> endedAt = const Value.absent(),
                Value<int?> durationSeconds = const Value.absent(),
                Value<String?> exitStatus = const Value.absent(),
              }) => GameHistoryCompanion(
                id: id,
                gameId: gameId,
                emulatorId: emulatorId,
                startedAt: startedAt,
                endedAt: endedAt,
                durationSeconds: durationSeconds,
                exitStatus: exitStatus,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int gameId,
                Value<String?> emulatorId = const Value.absent(),
                required DateTime startedAt,
                Value<DateTime?> endedAt = const Value.absent(),
                Value<int?> durationSeconds = const Value.absent(),
                Value<String?> exitStatus = const Value.absent(),
              }) => GameHistoryCompanion.insert(
                id: id,
                gameId: gameId,
                emulatorId: emulatorId,
                startedAt: startedAt,
                endedAt: endedAt,
                durationSeconds: durationSeconds,
                exitStatus: exitStatus,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$GameHistoryTable, GameHistoryRow>(table),
                  $$GameHistoryTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({gameId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (gameId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.gameId,
                        referencedTable: $$GameHistoryTableReferences
                            ._gameIdTable(db),
                        referencedColumn: $$GameHistoryTableReferences
                            ._gameIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$GameHistoryTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GameHistoryTable,
      GameHistoryRow,
      $$GameHistoryTableFilterComposer,
      $$GameHistoryTableOrderingComposer,
      $$GameHistoryTableAnnotationComposer,
      $$GameHistoryTableCreateCompanionBuilder,
      $$GameHistoryTableUpdateCompanionBuilder,
      (GameHistoryRow, $$GameHistoryTableReferences),
      GameHistoryRow,
      PrefetchHooks Function({bool gameId})
    >;
typedef $$ControllerDevicesTableCreateCompanionBuilder =
    ControllerDevicesCompanion Function({
      Value<int> id,
      required String descriptor,
      required String name,
      Value<int?> vendorId,
      Value<int?> productId,
      required String controllerType,
      Value<bool> hasVibrator,
      Value<String> buttonsJson,
      Value<String> axesJson,
      Value<int?> assignedPlayer,
      required DateTime firstSeenAt,
      required DateTime lastSeenAt,
    });
typedef $$ControllerDevicesTableUpdateCompanionBuilder =
    ControllerDevicesCompanion Function({
      Value<int> id,
      Value<String> descriptor,
      Value<String> name,
      Value<int?> vendorId,
      Value<int?> productId,
      Value<String> controllerType,
      Value<bool> hasVibrator,
      Value<String> buttonsJson,
      Value<String> axesJson,
      Value<int?> assignedPlayer,
      Value<DateTime> firstSeenAt,
      Value<DateTime> lastSeenAt,
    });

class $$ControllerDevicesTableFilterComposer
    extends Composer<_$AppDatabase, $ControllerDevicesTable> {
  $$ControllerDevicesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get descriptor => $composableBuilder(
    column: $table.descriptor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get vendorId => $composableBuilder(
    column: $table.vendorId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get productId => $composableBuilder(
    column: $table.productId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get controllerType => $composableBuilder(
    column: $table.controllerType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get hasVibrator => $composableBuilder(
    column: $table.hasVibrator,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get buttonsJson => $composableBuilder(
    column: $table.buttonsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get axesJson => $composableBuilder(
    column: $table.axesJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get assignedPlayer => $composableBuilder(
    column: $table.assignedPlayer,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get firstSeenAt => $composableBuilder(
    column: $table.firstSeenAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSeenAt => $composableBuilder(
    column: $table.lastSeenAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ControllerDevicesTableOrderingComposer
    extends Composer<_$AppDatabase, $ControllerDevicesTable> {
  $$ControllerDevicesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get descriptor => $composableBuilder(
    column: $table.descriptor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get vendorId => $composableBuilder(
    column: $table.vendorId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get productId => $composableBuilder(
    column: $table.productId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get controllerType => $composableBuilder(
    column: $table.controllerType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get hasVibrator => $composableBuilder(
    column: $table.hasVibrator,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get buttonsJson => $composableBuilder(
    column: $table.buttonsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get axesJson => $composableBuilder(
    column: $table.axesJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get assignedPlayer => $composableBuilder(
    column: $table.assignedPlayer,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get firstSeenAt => $composableBuilder(
    column: $table.firstSeenAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSeenAt => $composableBuilder(
    column: $table.lastSeenAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ControllerDevicesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ControllerDevicesTable> {
  $$ControllerDevicesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get descriptor => $composableBuilder(
    column: $table.descriptor,
    builder: (column) => column,
  );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get vendorId =>
      $composableBuilder(column: $table.vendorId, builder: (column) => column);

  GeneratedColumn<int> get productId =>
      $composableBuilder(column: $table.productId, builder: (column) => column);

  GeneratedColumn<String> get controllerType => $composableBuilder(
    column: $table.controllerType,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get hasVibrator => $composableBuilder(
    column: $table.hasVibrator,
    builder: (column) => column,
  );

  GeneratedColumn<String> get buttonsJson => $composableBuilder(
    column: $table.buttonsJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get axesJson =>
      $composableBuilder(column: $table.axesJson, builder: (column) => column);

  GeneratedColumn<int> get assignedPlayer => $composableBuilder(
    column: $table.assignedPlayer,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get firstSeenAt => $composableBuilder(
    column: $table.firstSeenAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastSeenAt => $composableBuilder(
    column: $table.lastSeenAt,
    builder: (column) => column,
  );
}

class $$ControllerDevicesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ControllerDevicesTable,
          ControllerDeviceRow,
          $$ControllerDevicesTableFilterComposer,
          $$ControllerDevicesTableOrderingComposer,
          $$ControllerDevicesTableAnnotationComposer,
          $$ControllerDevicesTableCreateCompanionBuilder,
          $$ControllerDevicesTableUpdateCompanionBuilder,
          (
            ControllerDeviceRow,
            BaseReferences<
              _$AppDatabase,
              $ControllerDevicesTable,
              ControllerDeviceRow
            >,
          ),
          ControllerDeviceRow,
          PrefetchHooks Function()
        > {
  $$ControllerDevicesTableTableManager(
    _$AppDatabase db,
    $ControllerDevicesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ControllerDevicesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ControllerDevicesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ControllerDevicesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> descriptor = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int?> vendorId = const Value.absent(),
                Value<int?> productId = const Value.absent(),
                Value<String> controllerType = const Value.absent(),
                Value<bool> hasVibrator = const Value.absent(),
                Value<String> buttonsJson = const Value.absent(),
                Value<String> axesJson = const Value.absent(),
                Value<int?> assignedPlayer = const Value.absent(),
                Value<DateTime> firstSeenAt = const Value.absent(),
                Value<DateTime> lastSeenAt = const Value.absent(),
              }) => ControllerDevicesCompanion(
                id: id,
                descriptor: descriptor,
                name: name,
                vendorId: vendorId,
                productId: productId,
                controllerType: controllerType,
                hasVibrator: hasVibrator,
                buttonsJson: buttonsJson,
                axesJson: axesJson,
                assignedPlayer: assignedPlayer,
                firstSeenAt: firstSeenAt,
                lastSeenAt: lastSeenAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String descriptor,
                required String name,
                Value<int?> vendorId = const Value.absent(),
                Value<int?> productId = const Value.absent(),
                required String controllerType,
                Value<bool> hasVibrator = const Value.absent(),
                Value<String> buttonsJson = const Value.absent(),
                Value<String> axesJson = const Value.absent(),
                Value<int?> assignedPlayer = const Value.absent(),
                required DateTime firstSeenAt,
                required DateTime lastSeenAt,
              }) => ControllerDevicesCompanion.insert(
                id: id,
                descriptor: descriptor,
                name: name,
                vendorId: vendorId,
                productId: productId,
                controllerType: controllerType,
                hasVibrator: hasVibrator,
                buttonsJson: buttonsJson,
                axesJson: axesJson,
                assignedPlayer: assignedPlayer,
                firstSeenAt: firstSeenAt,
                lastSeenAt: lastSeenAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ControllerDevicesTable, ControllerDeviceRow>(
                    table,
                  ),
                  BaseReferences<
                    _$AppDatabase,
                    $ControllerDevicesTable,
                    ControllerDeviceRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ControllerDevicesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ControllerDevicesTable,
      ControllerDeviceRow,
      $$ControllerDevicesTableFilterComposer,
      $$ControllerDevicesTableOrderingComposer,
      $$ControllerDevicesTableAnnotationComposer,
      $$ControllerDevicesTableCreateCompanionBuilder,
      $$ControllerDevicesTableUpdateCompanionBuilder,
      (
        ControllerDeviceRow,
        BaseReferences<
          _$AppDatabase,
          $ControllerDevicesTable,
          ControllerDeviceRow
        >,
      ),
      ControllerDeviceRow,
      PrefetchHooks Function()
    >;
typedef $$ControllerProfilesTableCreateCompanionBuilder =
    ControllerProfilesCompanion Function({
      Value<int> id,
      required String name,
      Value<String?> controllerDescriptor,
      Value<String?> consoleId,
      Value<double> deadZone,
      Value<double> triggerThreshold,
      Value<bool> vibrationEnabled,
      Value<bool> isDefault,
      Value<String?> calibrationJson,
    });
typedef $$ControllerProfilesTableUpdateCompanionBuilder =
    ControllerProfilesCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String?> controllerDescriptor,
      Value<String?> consoleId,
      Value<double> deadZone,
      Value<double> triggerThreshold,
      Value<bool> vibrationEnabled,
      Value<bool> isDefault,
      Value<String?> calibrationJson,
    });

final class $$ControllerProfilesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $ControllerProfilesTable,
          ControllerProfileRow
        > {
  $$ControllerProfilesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ConsolesTable _consoleIdTable(_$AppDatabase db) =>
      db.consoles.createAlias('controller_profiles__console_id__consoles__id');

  $$ConsolesTableProcessedTableManager? get consoleId {
    final $_column = $_itemColumn<String>('console_id');
    if ($_column == null) return null;
    final manager = $$ConsolesTableTableManager(
      $_db,
      $_db.consoles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_consoleIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<
    $ControllerMappingsTable,
    List<ControllerMappingRow>
  >
  _controllerMappingsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.controllerMappings,
        aliasName: 'controller_profiles__id__controller_mappings__profile_id',
      );

  $$ControllerMappingsTableProcessedTableManager get controllerMappingsRefs {
    final manager = $$ControllerMappingsTableTableManager(
      $_db,
      $_db.controllerMappings,
    ).filter((f) => f.profileId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _controllerMappingsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ControllerProfilesTableFilterComposer
    extends Composer<_$AppDatabase, $ControllerProfilesTable> {
  $$ControllerProfilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get controllerDescriptor => $composableBuilder(
    column: $table.controllerDescriptor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get deadZone => $composableBuilder(
    column: $table.deadZone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get triggerThreshold => $composableBuilder(
    column: $table.triggerThreshold,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get vibrationEnabled => $composableBuilder(
    column: $table.vibrationEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDefault => $composableBuilder(
    column: $table.isDefault,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get calibrationJson => $composableBuilder(
    column: $table.calibrationJson,
    builder: (column) => ColumnFilters(column),
  );

  $$ConsolesTableFilterComposer get consoleId {
    final $$ConsolesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.consoleId,
      referencedTable: $db.consoles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ConsolesTableFilterComposer(
            $db: $db,
            $table: $db.consoles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> controllerMappingsRefs(
    Expression<bool> Function($$ControllerMappingsTableFilterComposer f) f,
  ) {
    final $$ControllerMappingsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.controllerMappings,
      getReferencedColumn: (t) => t.profileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ControllerMappingsTableFilterComposer(
            $db: $db,
            $table: $db.controllerMappings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ControllerProfilesTableOrderingComposer
    extends Composer<_$AppDatabase, $ControllerProfilesTable> {
  $$ControllerProfilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get controllerDescriptor => $composableBuilder(
    column: $table.controllerDescriptor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get deadZone => $composableBuilder(
    column: $table.deadZone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get triggerThreshold => $composableBuilder(
    column: $table.triggerThreshold,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get vibrationEnabled => $composableBuilder(
    column: $table.vibrationEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDefault => $composableBuilder(
    column: $table.isDefault,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get calibrationJson => $composableBuilder(
    column: $table.calibrationJson,
    builder: (column) => ColumnOrderings(column),
  );

  $$ConsolesTableOrderingComposer get consoleId {
    final $$ConsolesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.consoleId,
      referencedTable: $db.consoles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ConsolesTableOrderingComposer(
            $db: $db,
            $table: $db.consoles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ControllerProfilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ControllerProfilesTable> {
  $$ControllerProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get controllerDescriptor => $composableBuilder(
    column: $table.controllerDescriptor,
    builder: (column) => column,
  );

  GeneratedColumn<double> get deadZone =>
      $composableBuilder(column: $table.deadZone, builder: (column) => column);

  GeneratedColumn<double> get triggerThreshold => $composableBuilder(
    column: $table.triggerThreshold,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get vibrationEnabled => $composableBuilder(
    column: $table.vibrationEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isDefault =>
      $composableBuilder(column: $table.isDefault, builder: (column) => column);

  GeneratedColumn<String> get calibrationJson => $composableBuilder(
    column: $table.calibrationJson,
    builder: (column) => column,
  );

  $$ConsolesTableAnnotationComposer get consoleId {
    final $$ConsolesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.consoleId,
      referencedTable: $db.consoles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ConsolesTableAnnotationComposer(
            $db: $db,
            $table: $db.consoles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> controllerMappingsRefs<T extends Object>(
    Expression<T> Function($$ControllerMappingsTableAnnotationComposer a) f,
  ) {
    final $$ControllerMappingsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.controllerMappings,
          getReferencedColumn: (t) => t.profileId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ControllerMappingsTableAnnotationComposer(
                $db: $db,
                $table: $db.controllerMappings,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$ControllerProfilesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ControllerProfilesTable,
          ControllerProfileRow,
          $$ControllerProfilesTableFilterComposer,
          $$ControllerProfilesTableOrderingComposer,
          $$ControllerProfilesTableAnnotationComposer,
          $$ControllerProfilesTableCreateCompanionBuilder,
          $$ControllerProfilesTableUpdateCompanionBuilder,
          (ControllerProfileRow, $$ControllerProfilesTableReferences),
          ControllerProfileRow,
          PrefetchHooks Function({bool consoleId, bool controllerMappingsRefs})
        > {
  $$ControllerProfilesTableTableManager(
    _$AppDatabase db,
    $ControllerProfilesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ControllerProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ControllerProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ControllerProfilesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> controllerDescriptor = const Value.absent(),
                Value<String?> consoleId = const Value.absent(),
                Value<double> deadZone = const Value.absent(),
                Value<double> triggerThreshold = const Value.absent(),
                Value<bool> vibrationEnabled = const Value.absent(),
                Value<bool> isDefault = const Value.absent(),
                Value<String?> calibrationJson = const Value.absent(),
              }) => ControllerProfilesCompanion(
                id: id,
                name: name,
                controllerDescriptor: controllerDescriptor,
                consoleId: consoleId,
                deadZone: deadZone,
                triggerThreshold: triggerThreshold,
                vibrationEnabled: vibrationEnabled,
                isDefault: isDefault,
                calibrationJson: calibrationJson,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String?> controllerDescriptor = const Value.absent(),
                Value<String?> consoleId = const Value.absent(),
                Value<double> deadZone = const Value.absent(),
                Value<double> triggerThreshold = const Value.absent(),
                Value<bool> vibrationEnabled = const Value.absent(),
                Value<bool> isDefault = const Value.absent(),
                Value<String?> calibrationJson = const Value.absent(),
              }) => ControllerProfilesCompanion.insert(
                id: id,
                name: name,
                controllerDescriptor: controllerDescriptor,
                consoleId: consoleId,
                deadZone: deadZone,
                triggerThreshold: triggerThreshold,
                vibrationEnabled: vibrationEnabled,
                isDefault: isDefault,
                calibrationJson: calibrationJson,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ControllerProfilesTable, ControllerProfileRow>(
                    table,
                  ),
                  $$ControllerProfilesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({consoleId = false, controllerMappingsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (controllerMappingsRefs) db.controllerMappings,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (consoleId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.consoleId,
                            referencedTable: $$ControllerProfilesTableReferences
                                ._consoleIdTable(db),
                            referencedColumn:
                                $$ControllerProfilesTableReferences
                                    ._consoleIdTable(db)
                                    .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (controllerMappingsRefs)
                        await $_getPrefetchedDataByColumns<
                          ControllerProfileRow,
                          $ControllerProfilesTable,
                          ControllerMappingRow,
                          $ControllerMappingsTable
                        >(
                          currentTable: table,
                          referencedTable: $$ControllerProfilesTableReferences
                              ._controllerMappingsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ControllerProfilesTableReferences(
                                db,
                                table,
                                p0,
                              ).controllerMappingsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'profile_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ControllerProfilesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ControllerProfilesTable,
      ControllerProfileRow,
      $$ControllerProfilesTableFilterComposer,
      $$ControllerProfilesTableOrderingComposer,
      $$ControllerProfilesTableAnnotationComposer,
      $$ControllerProfilesTableCreateCompanionBuilder,
      $$ControllerProfilesTableUpdateCompanionBuilder,
      (ControllerProfileRow, $$ControllerProfilesTableReferences),
      ControllerProfileRow,
      PrefetchHooks Function({bool consoleId, bool controllerMappingsRefs})
    >;
typedef $$ControllerMappingsTableCreateCompanionBuilder =
    ControllerMappingsCompanion Function({
      Value<int> id,
      required int profileId,
      required String action,
      Value<int?> keyCode,
      Value<int?> axis,
      Value<int?> axisDirection,
    });
typedef $$ControllerMappingsTableUpdateCompanionBuilder =
    ControllerMappingsCompanion Function({
      Value<int> id,
      Value<int> profileId,
      Value<String> action,
      Value<int?> keyCode,
      Value<int?> axis,
      Value<int?> axisDirection,
    });

final class $$ControllerMappingsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $ControllerMappingsTable,
          ControllerMappingRow
        > {
  $$ControllerMappingsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ControllerProfilesTable _profileIdTable(_$AppDatabase db) => db
      .controllerProfiles
      .createAlias('controller_mappings__profile_id__controller_profiles__id');

  $$ControllerProfilesTableProcessedTableManager get profileId {
    final $_column = $_itemColumn<int>('profile_id')!;

    final manager = $$ControllerProfilesTableTableManager(
      $_db,
      $_db.controllerProfiles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_profileIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ControllerMappingsTableFilterComposer
    extends Composer<_$AppDatabase, $ControllerMappingsTable> {
  $$ControllerMappingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get action => $composableBuilder(
    column: $table.action,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get keyCode => $composableBuilder(
    column: $table.keyCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get axis => $composableBuilder(
    column: $table.axis,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get axisDirection => $composableBuilder(
    column: $table.axisDirection,
    builder: (column) => ColumnFilters(column),
  );

  $$ControllerProfilesTableFilterComposer get profileId {
    final $$ControllerProfilesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.controllerProfiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ControllerProfilesTableFilterComposer(
            $db: $db,
            $table: $db.controllerProfiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ControllerMappingsTableOrderingComposer
    extends Composer<_$AppDatabase, $ControllerMappingsTable> {
  $$ControllerMappingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get action => $composableBuilder(
    column: $table.action,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get keyCode => $composableBuilder(
    column: $table.keyCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get axis => $composableBuilder(
    column: $table.axis,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get axisDirection => $composableBuilder(
    column: $table.axisDirection,
    builder: (column) => ColumnOrderings(column),
  );

  $$ControllerProfilesTableOrderingComposer get profileId {
    final $$ControllerProfilesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.controllerProfiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ControllerProfilesTableOrderingComposer(
            $db: $db,
            $table: $db.controllerProfiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ControllerMappingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ControllerMappingsTable> {
  $$ControllerMappingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get action =>
      $composableBuilder(column: $table.action, builder: (column) => column);

  GeneratedColumn<int> get keyCode =>
      $composableBuilder(column: $table.keyCode, builder: (column) => column);

  GeneratedColumn<int> get axis =>
      $composableBuilder(column: $table.axis, builder: (column) => column);

  GeneratedColumn<int> get axisDirection => $composableBuilder(
    column: $table.axisDirection,
    builder: (column) => column,
  );

  $$ControllerProfilesTableAnnotationComposer get profileId {
    final $$ControllerProfilesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.profileId,
          referencedTable: $db.controllerProfiles,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ControllerProfilesTableAnnotationComposer(
                $db: $db,
                $table: $db.controllerProfiles,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$ControllerMappingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ControllerMappingsTable,
          ControllerMappingRow,
          $$ControllerMappingsTableFilterComposer,
          $$ControllerMappingsTableOrderingComposer,
          $$ControllerMappingsTableAnnotationComposer,
          $$ControllerMappingsTableCreateCompanionBuilder,
          $$ControllerMappingsTableUpdateCompanionBuilder,
          (ControllerMappingRow, $$ControllerMappingsTableReferences),
          ControllerMappingRow,
          PrefetchHooks Function({bool profileId})
        > {
  $$ControllerMappingsTableTableManager(
    _$AppDatabase db,
    $ControllerMappingsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ControllerMappingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ControllerMappingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ControllerMappingsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> profileId = const Value.absent(),
                Value<String> action = const Value.absent(),
                Value<int?> keyCode = const Value.absent(),
                Value<int?> axis = const Value.absent(),
                Value<int?> axisDirection = const Value.absent(),
              }) => ControllerMappingsCompanion(
                id: id,
                profileId: profileId,
                action: action,
                keyCode: keyCode,
                axis: axis,
                axisDirection: axisDirection,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int profileId,
                required String action,
                Value<int?> keyCode = const Value.absent(),
                Value<int?> axis = const Value.absent(),
                Value<int?> axisDirection = const Value.absent(),
              }) => ControllerMappingsCompanion.insert(
                id: id,
                profileId: profileId,
                action: action,
                keyCode: keyCode,
                axis: axis,
                axisDirection: axisDirection,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ControllerMappingsTable, ControllerMappingRow>(
                    table,
                  ),
                  $$ControllerMappingsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({profileId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (profileId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.profileId,
                        referencedTable: $$ControllerMappingsTableReferences
                            ._profileIdTable(db),
                        referencedColumn: $$ControllerMappingsTableReferences
                            ._profileIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ControllerMappingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ControllerMappingsTable,
      ControllerMappingRow,
      $$ControllerMappingsTableFilterComposer,
      $$ControllerMappingsTableOrderingComposer,
      $$ControllerMappingsTableAnnotationComposer,
      $$ControllerMappingsTableCreateCompanionBuilder,
      $$ControllerMappingsTableUpdateCompanionBuilder,
      (ControllerMappingRow, $$ControllerMappingsTableReferences),
      ControllerMappingRow,
      PrefetchHooks Function({bool profileId})
    >;
typedef $$SourceConnectorsTableCreateCompanionBuilder =
    SourceConnectorsCompanion Function({
      required String id,
      required String name,
      required String type,
      required String version,
      Value<String?> description,
      Value<int> rowid,
    });
typedef $$SourceConnectorsTableUpdateCompanionBuilder =
    SourceConnectorsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> type,
      Value<String> version,
      Value<String?> description,
      Value<int> rowid,
    });

final class $$SourceConnectorsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $SourceConnectorsTable,
          SourceConnectorRow
        > {
  $$SourceConnectorsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$GameSourcesTable, List<GameSourceRow>>
  _gameSourcesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.gameSources,
    aliasName: 'source_connectors__id__game_sources__connector_id',
  );

  $$GameSourcesTableProcessedTableManager get gameSourcesRefs {
    final manager = $$GameSourcesTableTableManager(
      $_db,
      $_db.gameSources,
    ).filter((f) => f.connectorId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_gameSourcesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SourceConnectorsTableFilterComposer
    extends Composer<_$AppDatabase, $SourceConnectorsTable> {
  $$SourceConnectorsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> gameSourcesRefs(
    Expression<bool> Function($$GameSourcesTableFilterComposer f) f,
  ) {
    final $$GameSourcesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.gameSources,
      getReferencedColumn: (t) => t.connectorId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GameSourcesTableFilterComposer(
            $db: $db,
            $table: $db.gameSources,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SourceConnectorsTableOrderingComposer
    extends Composer<_$AppDatabase, $SourceConnectorsTable> {
  $$SourceConnectorsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SourceConnectorsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SourceConnectorsTable> {
  $$SourceConnectorsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  Expression<T> gameSourcesRefs<T extends Object>(
    Expression<T> Function($$GameSourcesTableAnnotationComposer a) f,
  ) {
    final $$GameSourcesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.gameSources,
      getReferencedColumn: (t) => t.connectorId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GameSourcesTableAnnotationComposer(
            $db: $db,
            $table: $db.gameSources,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SourceConnectorsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SourceConnectorsTable,
          SourceConnectorRow,
          $$SourceConnectorsTableFilterComposer,
          $$SourceConnectorsTableOrderingComposer,
          $$SourceConnectorsTableAnnotationComposer,
          $$SourceConnectorsTableCreateCompanionBuilder,
          $$SourceConnectorsTableUpdateCompanionBuilder,
          (SourceConnectorRow, $$SourceConnectorsTableReferences),
          SourceConnectorRow,
          PrefetchHooks Function({bool gameSourcesRefs})
        > {
  $$SourceConnectorsTableTableManager(
    _$AppDatabase db,
    $SourceConnectorsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SourceConnectorsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SourceConnectorsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SourceConnectorsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> version = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SourceConnectorsCompanion(
                id: id,
                name: name,
                type: type,
                version: version,
                description: description,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String type,
                required String version,
                Value<String?> description = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SourceConnectorsCompanion.insert(
                id: id,
                name: name,
                type: type,
                version: version,
                description: description,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SourceConnectorsTable, SourceConnectorRow>(
                    table,
                  ),
                  $$SourceConnectorsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({gameSourcesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (gameSourcesRefs) db.gameSources],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (gameSourcesRefs)
                    await $_getPrefetchedDataByColumns<
                      SourceConnectorRow,
                      $SourceConnectorsTable,
                      GameSourceRow,
                      $GameSourcesTable
                    >(
                      currentTable: table,
                      referencedTable: $$SourceConnectorsTableReferences
                          ._gameSourcesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$SourceConnectorsTableReferences(
                            db,
                            table,
                            p0,
                          ).gameSourcesRefs,
                      currentColumn: 'id',
                      referencedColumn: 'connector_id',
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$SourceConnectorsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SourceConnectorsTable,
      SourceConnectorRow,
      $$SourceConnectorsTableFilterComposer,
      $$SourceConnectorsTableOrderingComposer,
      $$SourceConnectorsTableAnnotationComposer,
      $$SourceConnectorsTableCreateCompanionBuilder,
      $$SourceConnectorsTableUpdateCompanionBuilder,
      (SourceConnectorRow, $$SourceConnectorsTableReferences),
      SourceConnectorRow,
      PrefetchHooks Function({bool gameSourcesRefs})
    >;
typedef $$GameSourcesTableCreateCompanionBuilder =
    GameSourcesCompanion Function({
      Value<int> id,
      required String name,
      required String url,
      Value<String?> category,
      required String type,
      Value<String?> description,
      Value<String> authType,
      Value<String?> connectorId,
      Value<String> connectionStatus,
      Value<DateTime?> lastCheckedAt,
      Value<bool> enabled,
    });
typedef $$GameSourcesTableUpdateCompanionBuilder =
    GameSourcesCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String> url,
      Value<String?> category,
      Value<String> type,
      Value<String?> description,
      Value<String> authType,
      Value<String?> connectorId,
      Value<String> connectionStatus,
      Value<DateTime?> lastCheckedAt,
      Value<bool> enabled,
    });

final class $$GameSourcesTableReferences
    extends BaseReferences<_$AppDatabase, $GameSourcesTable, GameSourceRow> {
  $$GameSourcesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SourceConnectorsTable _connectorIdTable(_$AppDatabase db) => db
      .sourceConnectors
      .createAlias('game_sources__connector_id__source_connectors__id');

  $$SourceConnectorsTableProcessedTableManager? get connectorId {
    final $_column = $_itemColumn<String>('connector_id');
    if ($_column == null) return null;
    final manager = $$SourceConnectorsTableTableManager(
      $_db,
      $_db.sourceConnectors,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_connectorIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$DownloadQueueTable, List<DownloadQueueRow>>
  _downloadQueueRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.downloadQueue,
    aliasName: 'game_sources__id__download_queue__source_id',
  );

  $$DownloadQueueTableProcessedTableManager get downloadQueueRefs {
    final manager = $$DownloadQueueTableTableManager(
      $_db,
      $_db.downloadQueue,
    ).filter((f) => f.sourceId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_downloadQueueRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$DownloadHistoryTable, List<DownloadHistoryRow>>
  _downloadHistoryRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.downloadHistory,
    aliasName: 'game_sources__id__download_history__source_id',
  );

  $$DownloadHistoryTableProcessedTableManager get downloadHistoryRefs {
    final manager = $$DownloadHistoryTableTableManager(
      $_db,
      $_db.downloadHistory,
    ).filter((f) => f.sourceId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _downloadHistoryRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$GameSourcesTableFilterComposer
    extends Composer<_$AppDatabase, $GameSourcesTable> {
  $$GameSourcesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get authType => $composableBuilder(
    column: $table.authType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get connectionStatus => $composableBuilder(
    column: $table.connectionStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastCheckedAt => $composableBuilder(
    column: $table.lastCheckedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnFilters(column),
  );

  $$SourceConnectorsTableFilterComposer get connectorId {
    final $$SourceConnectorsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.connectorId,
      referencedTable: $db.sourceConnectors,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SourceConnectorsTableFilterComposer(
            $db: $db,
            $table: $db.sourceConnectors,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> downloadQueueRefs(
    Expression<bool> Function($$DownloadQueueTableFilterComposer f) f,
  ) {
    final $$DownloadQueueTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.downloadQueue,
      getReferencedColumn: (t) => t.sourceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DownloadQueueTableFilterComposer(
            $db: $db,
            $table: $db.downloadQueue,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> downloadHistoryRefs(
    Expression<bool> Function($$DownloadHistoryTableFilterComposer f) f,
  ) {
    final $$DownloadHistoryTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.downloadHistory,
      getReferencedColumn: (t) => t.sourceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DownloadHistoryTableFilterComposer(
            $db: $db,
            $table: $db.downloadHistory,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$GameSourcesTableOrderingComposer
    extends Composer<_$AppDatabase, $GameSourcesTable> {
  $$GameSourcesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get authType => $composableBuilder(
    column: $table.authType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get connectionStatus => $composableBuilder(
    column: $table.connectionStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastCheckedAt => $composableBuilder(
    column: $table.lastCheckedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnOrderings(column),
  );

  $$SourceConnectorsTableOrderingComposer get connectorId {
    final $$SourceConnectorsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.connectorId,
      referencedTable: $db.sourceConnectors,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SourceConnectorsTableOrderingComposer(
            $db: $db,
            $table: $db.sourceConnectors,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GameSourcesTableAnnotationComposer
    extends Composer<_$AppDatabase, $GameSourcesTable> {
  $$GameSourcesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get authType =>
      $composableBuilder(column: $table.authType, builder: (column) => column);

  GeneratedColumn<String> get connectionStatus => $composableBuilder(
    column: $table.connectionStatus,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastCheckedAt => $composableBuilder(
    column: $table.lastCheckedAt,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get enabled =>
      $composableBuilder(column: $table.enabled, builder: (column) => column);

  $$SourceConnectorsTableAnnotationComposer get connectorId {
    final $$SourceConnectorsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.connectorId,
      referencedTable: $db.sourceConnectors,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SourceConnectorsTableAnnotationComposer(
            $db: $db,
            $table: $db.sourceConnectors,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> downloadQueueRefs<T extends Object>(
    Expression<T> Function($$DownloadQueueTableAnnotationComposer a) f,
  ) {
    final $$DownloadQueueTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.downloadQueue,
      getReferencedColumn: (t) => t.sourceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DownloadQueueTableAnnotationComposer(
            $db: $db,
            $table: $db.downloadQueue,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> downloadHistoryRefs<T extends Object>(
    Expression<T> Function($$DownloadHistoryTableAnnotationComposer a) f,
  ) {
    final $$DownloadHistoryTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.downloadHistory,
      getReferencedColumn: (t) => t.sourceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DownloadHistoryTableAnnotationComposer(
            $db: $db,
            $table: $db.downloadHistory,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$GameSourcesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GameSourcesTable,
          GameSourceRow,
          $$GameSourcesTableFilterComposer,
          $$GameSourcesTableOrderingComposer,
          $$GameSourcesTableAnnotationComposer,
          $$GameSourcesTableCreateCompanionBuilder,
          $$GameSourcesTableUpdateCompanionBuilder,
          (GameSourceRow, $$GameSourcesTableReferences),
          GameSourceRow,
          PrefetchHooks Function({
            bool connectorId,
            bool downloadQueueRefs,
            bool downloadHistoryRefs,
          })
        > {
  $$GameSourcesTableTableManager(_$AppDatabase db, $GameSourcesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GameSourcesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GameSourcesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GameSourcesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> url = const Value.absent(),
                Value<String?> category = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String> authType = const Value.absent(),
                Value<String?> connectorId = const Value.absent(),
                Value<String> connectionStatus = const Value.absent(),
                Value<DateTime?> lastCheckedAt = const Value.absent(),
                Value<bool> enabled = const Value.absent(),
              }) => GameSourcesCompanion(
                id: id,
                name: name,
                url: url,
                category: category,
                type: type,
                description: description,
                authType: authType,
                connectorId: connectorId,
                connectionStatus: connectionStatus,
                lastCheckedAt: lastCheckedAt,
                enabled: enabled,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required String url,
                Value<String?> category = const Value.absent(),
                required String type,
                Value<String?> description = const Value.absent(),
                Value<String> authType = const Value.absent(),
                Value<String?> connectorId = const Value.absent(),
                Value<String> connectionStatus = const Value.absent(),
                Value<DateTime?> lastCheckedAt = const Value.absent(),
                Value<bool> enabled = const Value.absent(),
              }) => GameSourcesCompanion.insert(
                id: id,
                name: name,
                url: url,
                category: category,
                type: type,
                description: description,
                authType: authType,
                connectorId: connectorId,
                connectionStatus: connectionStatus,
                lastCheckedAt: lastCheckedAt,
                enabled: enabled,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$GameSourcesTable, GameSourceRow>(table),
                  $$GameSourcesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                connectorId = false,
                downloadQueueRefs = false,
                downloadHistoryRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (downloadQueueRefs) db.downloadQueue,
                    if (downloadHistoryRefs) db.downloadHistory,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (connectorId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.connectorId,
                            referencedTable: $$GameSourcesTableReferences
                                ._connectorIdTable(db),
                            referencedColumn: $$GameSourcesTableReferences
                                ._connectorIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (downloadQueueRefs)
                        await $_getPrefetchedDataByColumns<
                          GameSourceRow,
                          $GameSourcesTable,
                          DownloadQueueRow,
                          $DownloadQueueTable
                        >(
                          currentTable: table,
                          referencedTable: $$GameSourcesTableReferences
                              ._downloadQueueRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$GameSourcesTableReferences(
                                db,
                                table,
                                p0,
                              ).downloadQueueRefs,
                          currentColumn: 'id',
                          referencedColumn: 'source_id',
                          typedResults: items,
                        ),
                      if (downloadHistoryRefs)
                        await $_getPrefetchedDataByColumns<
                          GameSourceRow,
                          $GameSourcesTable,
                          DownloadHistoryRow,
                          $DownloadHistoryTable
                        >(
                          currentTable: table,
                          referencedTable: $$GameSourcesTableReferences
                              ._downloadHistoryRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$GameSourcesTableReferences(
                                db,
                                table,
                                p0,
                              ).downloadHistoryRefs,
                          currentColumn: 'id',
                          referencedColumn: 'source_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$GameSourcesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GameSourcesTable,
      GameSourceRow,
      $$GameSourcesTableFilterComposer,
      $$GameSourcesTableOrderingComposer,
      $$GameSourcesTableAnnotationComposer,
      $$GameSourcesTableCreateCompanionBuilder,
      $$GameSourcesTableUpdateCompanionBuilder,
      (GameSourceRow, $$GameSourcesTableReferences),
      GameSourceRow,
      PrefetchHooks Function({
        bool connectorId,
        bool downloadQueueRefs,
        bool downloadHistoryRefs,
      })
    >;
typedef $$DownloadQueueTableCreateCompanionBuilder =
    DownloadQueueCompanion Function({
      Value<int> id,
      Value<int?> sourceId,
      required String name,
      required String url,
      required String destination,
      Value<int?> totalBytes,
      Value<int> downloadedBytes,
      required String status,
      Value<String?> expectedHash,
      Value<String?> hashAlgorithm,
      Value<String?> errorMessage,
      Value<int> retries,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<String?> filePath,
      Value<String?> consoleId,
      Value<String?> catalogJson,
      Value<String?> sha256,
      Value<int?> importedGameId,
    });
typedef $$DownloadQueueTableUpdateCompanionBuilder =
    DownloadQueueCompanion Function({
      Value<int> id,
      Value<int?> sourceId,
      Value<String> name,
      Value<String> url,
      Value<String> destination,
      Value<int?> totalBytes,
      Value<int> downloadedBytes,
      Value<String> status,
      Value<String?> expectedHash,
      Value<String?> hashAlgorithm,
      Value<String?> errorMessage,
      Value<int> retries,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String?> filePath,
      Value<String?> consoleId,
      Value<String?> catalogJson,
      Value<String?> sha256,
      Value<int?> importedGameId,
    });

final class $$DownloadQueueTableReferences
    extends
        BaseReferences<_$AppDatabase, $DownloadQueueTable, DownloadQueueRow> {
  $$DownloadQueueTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $GameSourcesTable _sourceIdTable(_$AppDatabase db) =>
      db.gameSources.createAlias('download_queue__source_id__game_sources__id');

  $$GameSourcesTableProcessedTableManager? get sourceId {
    final $_column = $_itemColumn<int>('source_id');
    if ($_column == null) return null;
    final manager = $$GameSourcesTableTableManager(
      $_db,
      $_db.gameSources,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sourceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$DownloadQueueTableFilterComposer
    extends Composer<_$AppDatabase, $DownloadQueueTable> {
  $$DownloadQueueTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get destination => $composableBuilder(
    column: $table.destination,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalBytes => $composableBuilder(
    column: $table.totalBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get downloadedBytes => $composableBuilder(
    column: $table.downloadedBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get expectedHash => $composableBuilder(
    column: $table.expectedHash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get hashAlgorithm => $composableBuilder(
    column: $table.hashAlgorithm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get retries => $composableBuilder(
    column: $table.retries,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get consoleId => $composableBuilder(
    column: $table.consoleId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get catalogJson => $composableBuilder(
    column: $table.catalogJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sha256 => $composableBuilder(
    column: $table.sha256,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get importedGameId => $composableBuilder(
    column: $table.importedGameId,
    builder: (column) => ColumnFilters(column),
  );

  $$GameSourcesTableFilterComposer get sourceId {
    final $$GameSourcesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceId,
      referencedTable: $db.gameSources,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GameSourcesTableFilterComposer(
            $db: $db,
            $table: $db.gameSources,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DownloadQueueTableOrderingComposer
    extends Composer<_$AppDatabase, $DownloadQueueTable> {
  $$DownloadQueueTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get destination => $composableBuilder(
    column: $table.destination,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalBytes => $composableBuilder(
    column: $table.totalBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get downloadedBytes => $composableBuilder(
    column: $table.downloadedBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get expectedHash => $composableBuilder(
    column: $table.expectedHash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get hashAlgorithm => $composableBuilder(
    column: $table.hashAlgorithm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get retries => $composableBuilder(
    column: $table.retries,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get consoleId => $composableBuilder(
    column: $table.consoleId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get catalogJson => $composableBuilder(
    column: $table.catalogJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sha256 => $composableBuilder(
    column: $table.sha256,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get importedGameId => $composableBuilder(
    column: $table.importedGameId,
    builder: (column) => ColumnOrderings(column),
  );

  $$GameSourcesTableOrderingComposer get sourceId {
    final $$GameSourcesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceId,
      referencedTable: $db.gameSources,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GameSourcesTableOrderingComposer(
            $db: $db,
            $table: $db.gameSources,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DownloadQueueTableAnnotationComposer
    extends Composer<_$AppDatabase, $DownloadQueueTable> {
  $$DownloadQueueTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumn<String> get destination => $composableBuilder(
    column: $table.destination,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalBytes => $composableBuilder(
    column: $table.totalBytes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get downloadedBytes => $composableBuilder(
    column: $table.downloadedBytes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get expectedHash => $composableBuilder(
    column: $table.expectedHash,
    builder: (column) => column,
  );

  GeneratedColumn<String> get hashAlgorithm => $composableBuilder(
    column: $table.hashAlgorithm,
    builder: (column) => column,
  );

  GeneratedColumn<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => column,
  );

  GeneratedColumn<int> get retries =>
      $composableBuilder(column: $table.retries, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get filePath =>
      $composableBuilder(column: $table.filePath, builder: (column) => column);

  GeneratedColumn<String> get consoleId =>
      $composableBuilder(column: $table.consoleId, builder: (column) => column);

  GeneratedColumn<String> get catalogJson => $composableBuilder(
    column: $table.catalogJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sha256 =>
      $composableBuilder(column: $table.sha256, builder: (column) => column);

  GeneratedColumn<int> get importedGameId => $composableBuilder(
    column: $table.importedGameId,
    builder: (column) => column,
  );

  $$GameSourcesTableAnnotationComposer get sourceId {
    final $$GameSourcesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceId,
      referencedTable: $db.gameSources,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GameSourcesTableAnnotationComposer(
            $db: $db,
            $table: $db.gameSources,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DownloadQueueTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DownloadQueueTable,
          DownloadQueueRow,
          $$DownloadQueueTableFilterComposer,
          $$DownloadQueueTableOrderingComposer,
          $$DownloadQueueTableAnnotationComposer,
          $$DownloadQueueTableCreateCompanionBuilder,
          $$DownloadQueueTableUpdateCompanionBuilder,
          (DownloadQueueRow, $$DownloadQueueTableReferences),
          DownloadQueueRow,
          PrefetchHooks Function({bool sourceId})
        > {
  $$DownloadQueueTableTableManager(_$AppDatabase db, $DownloadQueueTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DownloadQueueTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DownloadQueueTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DownloadQueueTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> sourceId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> url = const Value.absent(),
                Value<String> destination = const Value.absent(),
                Value<int?> totalBytes = const Value.absent(),
                Value<int> downloadedBytes = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> expectedHash = const Value.absent(),
                Value<String?> hashAlgorithm = const Value.absent(),
                Value<String?> errorMessage = const Value.absent(),
                Value<int> retries = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String?> filePath = const Value.absent(),
                Value<String?> consoleId = const Value.absent(),
                Value<String?> catalogJson = const Value.absent(),
                Value<String?> sha256 = const Value.absent(),
                Value<int?> importedGameId = const Value.absent(),
              }) => DownloadQueueCompanion(
                id: id,
                sourceId: sourceId,
                name: name,
                url: url,
                destination: destination,
                totalBytes: totalBytes,
                downloadedBytes: downloadedBytes,
                status: status,
                expectedHash: expectedHash,
                hashAlgorithm: hashAlgorithm,
                errorMessage: errorMessage,
                retries: retries,
                createdAt: createdAt,
                updatedAt: updatedAt,
                filePath: filePath,
                consoleId: consoleId,
                catalogJson: catalogJson,
                sha256: sha256,
                importedGameId: importedGameId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> sourceId = const Value.absent(),
                required String name,
                required String url,
                required String destination,
                Value<int?> totalBytes = const Value.absent(),
                Value<int> downloadedBytes = const Value.absent(),
                required String status,
                Value<String?> expectedHash = const Value.absent(),
                Value<String?> hashAlgorithm = const Value.absent(),
                Value<String?> errorMessage = const Value.absent(),
                Value<int> retries = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<String?> filePath = const Value.absent(),
                Value<String?> consoleId = const Value.absent(),
                Value<String?> catalogJson = const Value.absent(),
                Value<String?> sha256 = const Value.absent(),
                Value<int?> importedGameId = const Value.absent(),
              }) => DownloadQueueCompanion.insert(
                id: id,
                sourceId: sourceId,
                name: name,
                url: url,
                destination: destination,
                totalBytes: totalBytes,
                downloadedBytes: downloadedBytes,
                status: status,
                expectedHash: expectedHash,
                hashAlgorithm: hashAlgorithm,
                errorMessage: errorMessage,
                retries: retries,
                createdAt: createdAt,
                updatedAt: updatedAt,
                filePath: filePath,
                consoleId: consoleId,
                catalogJson: catalogJson,
                sha256: sha256,
                importedGameId: importedGameId,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DownloadQueueTable, DownloadQueueRow>(table),
                  $$DownloadQueueTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sourceId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (sourceId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.sourceId,
                        referencedTable: $$DownloadQueueTableReferences
                            ._sourceIdTable(db),
                        referencedColumn: $$DownloadQueueTableReferences
                            ._sourceIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$DownloadQueueTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DownloadQueueTable,
      DownloadQueueRow,
      $$DownloadQueueTableFilterComposer,
      $$DownloadQueueTableOrderingComposer,
      $$DownloadQueueTableAnnotationComposer,
      $$DownloadQueueTableCreateCompanionBuilder,
      $$DownloadQueueTableUpdateCompanionBuilder,
      (DownloadQueueRow, $$DownloadQueueTableReferences),
      DownloadQueueRow,
      PrefetchHooks Function({bool sourceId})
    >;
typedef $$DownloadHistoryTableCreateCompanionBuilder =
    DownloadHistoryCompanion Function({
      Value<int> id,
      Value<int?> sourceId,
      required String name,
      required String url,
      required String destination,
      Value<int?> sizeBytes,
      Value<String?> sha256,
      required String status,
      Value<String?> errorMessage,
      required DateTime finishedAt,
    });
typedef $$DownloadHistoryTableUpdateCompanionBuilder =
    DownloadHistoryCompanion Function({
      Value<int> id,
      Value<int?> sourceId,
      Value<String> name,
      Value<String> url,
      Value<String> destination,
      Value<int?> sizeBytes,
      Value<String?> sha256,
      Value<String> status,
      Value<String?> errorMessage,
      Value<DateTime> finishedAt,
    });

final class $$DownloadHistoryTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $DownloadHistoryTable,
          DownloadHistoryRow
        > {
  $$DownloadHistoryTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $GameSourcesTable _sourceIdTable(_$AppDatabase db) => db.gameSources
      .createAlias('download_history__source_id__game_sources__id');

  $$GameSourcesTableProcessedTableManager? get sourceId {
    final $_column = $_itemColumn<int>('source_id');
    if ($_column == null) return null;
    final manager = $$GameSourcesTableTableManager(
      $_db,
      $_db.gameSources,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sourceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$DownloadHistoryTableFilterComposer
    extends Composer<_$AppDatabase, $DownloadHistoryTable> {
  $$DownloadHistoryTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get destination => $composableBuilder(
    column: $table.destination,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sizeBytes => $composableBuilder(
    column: $table.sizeBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sha256 => $composableBuilder(
    column: $table.sha256,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get finishedAt => $composableBuilder(
    column: $table.finishedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$GameSourcesTableFilterComposer get sourceId {
    final $$GameSourcesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceId,
      referencedTable: $db.gameSources,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GameSourcesTableFilterComposer(
            $db: $db,
            $table: $db.gameSources,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DownloadHistoryTableOrderingComposer
    extends Composer<_$AppDatabase, $DownloadHistoryTable> {
  $$DownloadHistoryTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get destination => $composableBuilder(
    column: $table.destination,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sizeBytes => $composableBuilder(
    column: $table.sizeBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sha256 => $composableBuilder(
    column: $table.sha256,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get finishedAt => $composableBuilder(
    column: $table.finishedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$GameSourcesTableOrderingComposer get sourceId {
    final $$GameSourcesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceId,
      referencedTable: $db.gameSources,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GameSourcesTableOrderingComposer(
            $db: $db,
            $table: $db.gameSources,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DownloadHistoryTableAnnotationComposer
    extends Composer<_$AppDatabase, $DownloadHistoryTable> {
  $$DownloadHistoryTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumn<String> get destination => $composableBuilder(
    column: $table.destination,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sizeBytes =>
      $composableBuilder(column: $table.sizeBytes, builder: (column) => column);

  GeneratedColumn<String> get sha256 =>
      $composableBuilder(column: $table.sha256, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get finishedAt => $composableBuilder(
    column: $table.finishedAt,
    builder: (column) => column,
  );

  $$GameSourcesTableAnnotationComposer get sourceId {
    final $$GameSourcesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceId,
      referencedTable: $db.gameSources,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GameSourcesTableAnnotationComposer(
            $db: $db,
            $table: $db.gameSources,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DownloadHistoryTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DownloadHistoryTable,
          DownloadHistoryRow,
          $$DownloadHistoryTableFilterComposer,
          $$DownloadHistoryTableOrderingComposer,
          $$DownloadHistoryTableAnnotationComposer,
          $$DownloadHistoryTableCreateCompanionBuilder,
          $$DownloadHistoryTableUpdateCompanionBuilder,
          (DownloadHistoryRow, $$DownloadHistoryTableReferences),
          DownloadHistoryRow,
          PrefetchHooks Function({bool sourceId})
        > {
  $$DownloadHistoryTableTableManager(
    _$AppDatabase db,
    $DownloadHistoryTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DownloadHistoryTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DownloadHistoryTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DownloadHistoryTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> sourceId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> url = const Value.absent(),
                Value<String> destination = const Value.absent(),
                Value<int?> sizeBytes = const Value.absent(),
                Value<String?> sha256 = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> errorMessage = const Value.absent(),
                Value<DateTime> finishedAt = const Value.absent(),
              }) => DownloadHistoryCompanion(
                id: id,
                sourceId: sourceId,
                name: name,
                url: url,
                destination: destination,
                sizeBytes: sizeBytes,
                sha256: sha256,
                status: status,
                errorMessage: errorMessage,
                finishedAt: finishedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> sourceId = const Value.absent(),
                required String name,
                required String url,
                required String destination,
                Value<int?> sizeBytes = const Value.absent(),
                Value<String?> sha256 = const Value.absent(),
                required String status,
                Value<String?> errorMessage = const Value.absent(),
                required DateTime finishedAt,
              }) => DownloadHistoryCompanion.insert(
                id: id,
                sourceId: sourceId,
                name: name,
                url: url,
                destination: destination,
                sizeBytes: sizeBytes,
                sha256: sha256,
                status: status,
                errorMessage: errorMessage,
                finishedAt: finishedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DownloadHistoryTable, DownloadHistoryRow>(table),
                  $$DownloadHistoryTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sourceId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (sourceId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.sourceId,
                        referencedTable: $$DownloadHistoryTableReferences
                            ._sourceIdTable(db),
                        referencedColumn: $$DownloadHistoryTableReferences
                            ._sourceIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$DownloadHistoryTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DownloadHistoryTable,
      DownloadHistoryRow,
      $$DownloadHistoryTableFilterComposer,
      $$DownloadHistoryTableOrderingComposer,
      $$DownloadHistoryTableAnnotationComposer,
      $$DownloadHistoryTableCreateCompanionBuilder,
      $$DownloadHistoryTableUpdateCompanionBuilder,
      (DownloadHistoryRow, $$DownloadHistoryTableReferences),
      DownloadHistoryRow,
      PrefetchHooks Function({bool sourceId})
    >;
typedef $$SaveStatesTableCreateCompanionBuilder = SaveStatesCompanion Function({
  Value<int> id,
  required int gameId,
  Value<String?> emulatorId,
  required String kind,
  Value<int?> slot,
  required String path,
  Value<int?> sizeBytes,
  required DateTime createdAt,
  Value<String?> folderUri,
  Value<String?> relativePath,
  Value<int?> lastModified,
});
typedef $$SaveStatesTableUpdateCompanionBuilder = SaveStatesCompanion Function({
  Value<int> id,
  Value<int> gameId,
  Value<String?> emulatorId,
  Value<String> kind,
  Value<int?> slot,
  Value<String> path,
  Value<int?> sizeBytes,
  Value<DateTime> createdAt,
  Value<String?> folderUri,
  Value<String?> relativePath,
  Value<int?> lastModified,
});

final class $$SaveStatesTableReferences
    extends BaseReferences<_$AppDatabase, $SaveStatesTable, SaveStateRow> {
  $$SaveStatesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $GamesTable _gameIdTable(_$AppDatabase db) =>
      db.games.createAlias('save_states__game_id__games__id');

  $$GamesTableProcessedTableManager get gameId {
    final $_column = $_itemColumn<int>('game_id')!;

    final manager = $$GamesTableTableManager(
      $_db,
      $_db.games,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_gameIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$SaveBackupsTable, List<SaveBackupRow>>
  _saveBackupsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.saveBackups,
    aliasName: 'save_states__id__save_backups__save_state_id',
  );

  $$SaveBackupsTableProcessedTableManager get saveBackupsRefs {
    final manager = $$SaveBackupsTableTableManager(
      $_db,
      $_db.saveBackups,
    ).filter((f) => f.saveStateId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_saveBackupsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SaveStatesTableFilterComposer
    extends Composer<_$AppDatabase, $SaveStatesTable> {
  $$SaveStatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get emulatorId => $composableBuilder(
    column: $table.emulatorId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get slot => $composableBuilder(
    column: $table.slot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get path => $composableBuilder(
    column: $table.path,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sizeBytes => $composableBuilder(
    column: $table.sizeBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get folderUri => $composableBuilder(
    column: $table.folderUri,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get relativePath => $composableBuilder(
    column: $table.relativePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastModified => $composableBuilder(
    column: $table.lastModified,
    builder: (column) => ColumnFilters(column),
  );

  $$GamesTableFilterComposer get gameId {
    final $$GamesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gameId,
      referencedTable: $db.games,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GamesTableFilterComposer(
            $db: $db,
            $table: $db.games,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> saveBackupsRefs(
    Expression<bool> Function($$SaveBackupsTableFilterComposer f) f,
  ) {
    final $$SaveBackupsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.saveBackups,
      getReferencedColumn: (t) => t.saveStateId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SaveBackupsTableFilterComposer(
            $db: $db,
            $table: $db.saveBackups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SaveStatesTableOrderingComposer
    extends Composer<_$AppDatabase, $SaveStatesTable> {
  $$SaveStatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get emulatorId => $composableBuilder(
    column: $table.emulatorId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get slot => $composableBuilder(
    column: $table.slot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get path => $composableBuilder(
    column: $table.path,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sizeBytes => $composableBuilder(
    column: $table.sizeBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get folderUri => $composableBuilder(
    column: $table.folderUri,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get relativePath => $composableBuilder(
    column: $table.relativePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastModified => $composableBuilder(
    column: $table.lastModified,
    builder: (column) => ColumnOrderings(column),
  );

  $$GamesTableOrderingComposer get gameId {
    final $$GamesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gameId,
      referencedTable: $db.games,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GamesTableOrderingComposer(
            $db: $db,
            $table: $db.games,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SaveStatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SaveStatesTable> {
  $$SaveStatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get emulatorId => $composableBuilder(
    column: $table.emulatorId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<int> get slot =>
      $composableBuilder(column: $table.slot, builder: (column) => column);

  GeneratedColumn<String> get path =>
      $composableBuilder(column: $table.path, builder: (column) => column);

  GeneratedColumn<int> get sizeBytes =>
      $composableBuilder(column: $table.sizeBytes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get folderUri =>
      $composableBuilder(column: $table.folderUri, builder: (column) => column);

  GeneratedColumn<String> get relativePath => $composableBuilder(
    column: $table.relativePath,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastModified => $composableBuilder(
    column: $table.lastModified,
    builder: (column) => column,
  );

  $$GamesTableAnnotationComposer get gameId {
    final $$GamesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gameId,
      referencedTable: $db.games,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GamesTableAnnotationComposer(
            $db: $db,
            $table: $db.games,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> saveBackupsRefs<T extends Object>(
    Expression<T> Function($$SaveBackupsTableAnnotationComposer a) f,
  ) {
    final $$SaveBackupsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.saveBackups,
      getReferencedColumn: (t) => t.saveStateId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SaveBackupsTableAnnotationComposer(
            $db: $db,
            $table: $db.saveBackups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SaveStatesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SaveStatesTable,
          SaveStateRow,
          $$SaveStatesTableFilterComposer,
          $$SaveStatesTableOrderingComposer,
          $$SaveStatesTableAnnotationComposer,
          $$SaveStatesTableCreateCompanionBuilder,
          $$SaveStatesTableUpdateCompanionBuilder,
          (SaveStateRow, $$SaveStatesTableReferences),
          SaveStateRow,
          PrefetchHooks Function({bool gameId, bool saveBackupsRefs})
        > {
  $$SaveStatesTableTableManager(_$AppDatabase db, $SaveStatesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SaveStatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SaveStatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SaveStatesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> gameId = const Value.absent(),
                Value<String?> emulatorId = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<int?> slot = const Value.absent(),
                Value<String> path = const Value.absent(),
                Value<int?> sizeBytes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String?> folderUri = const Value.absent(),
                Value<String?> relativePath = const Value.absent(),
                Value<int?> lastModified = const Value.absent(),
              }) => SaveStatesCompanion(
                id: id,
                gameId: gameId,
                emulatorId: emulatorId,
                kind: kind,
                slot: slot,
                path: path,
                sizeBytes: sizeBytes,
                createdAt: createdAt,
                folderUri: folderUri,
                relativePath: relativePath,
                lastModified: lastModified,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int gameId,
                Value<String?> emulatorId = const Value.absent(),
                required String kind,
                Value<int?> slot = const Value.absent(),
                required String path,
                Value<int?> sizeBytes = const Value.absent(),
                required DateTime createdAt,
                Value<String?> folderUri = const Value.absent(),
                Value<String?> relativePath = const Value.absent(),
                Value<int?> lastModified = const Value.absent(),
              }) => SaveStatesCompanion.insert(
                id: id,
                gameId: gameId,
                emulatorId: emulatorId,
                kind: kind,
                slot: slot,
                path: path,
                sizeBytes: sizeBytes,
                createdAt: createdAt,
                folderUri: folderUri,
                relativePath: relativePath,
                lastModified: lastModified,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SaveStatesTable, SaveStateRow>(table),
                  $$SaveStatesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({gameId = false, saveBackupsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (saveBackupsRefs) db.saveBackups],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (gameId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.gameId,
                        referencedTable: $$SaveStatesTableReferences
                            ._gameIdTable(db),
                        referencedColumn: $$SaveStatesTableReferences
                            ._gameIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (saveBackupsRefs)
                    await $_getPrefetchedDataByColumns<
                      SaveStateRow,
                      $SaveStatesTable,
                      SaveBackupRow,
                      $SaveBackupsTable
                    >(
                      currentTable: table,
                      referencedTable: $$SaveStatesTableReferences
                          ._saveBackupsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$SaveStatesTableReferences(
                            db,
                            table,
                            p0,
                          ).saveBackupsRefs,
                      currentColumn: 'id',
                      referencedColumn: 'save_state_id',
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$SaveStatesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SaveStatesTable,
      SaveStateRow,
      $$SaveStatesTableFilterComposer,
      $$SaveStatesTableOrderingComposer,
      $$SaveStatesTableAnnotationComposer,
      $$SaveStatesTableCreateCompanionBuilder,
      $$SaveStatesTableUpdateCompanionBuilder,
      (SaveStateRow, $$SaveStatesTableReferences),
      SaveStateRow,
      PrefetchHooks Function({bool gameId, bool saveBackupsRefs})
    >;
typedef $$SaveBackupsTableCreateCompanionBuilder =
    SaveBackupsCompanion Function({
      Value<int> id,
      Value<int?> gameId,
      Value<int?> saveStateId,
      required String backupPath,
      Value<int?> sizeBytes,
      Value<String?> note,
      required DateTime createdAt,
    });
typedef $$SaveBackupsTableUpdateCompanionBuilder =
    SaveBackupsCompanion Function({
      Value<int> id,
      Value<int?> gameId,
      Value<int?> saveStateId,
      Value<String> backupPath,
      Value<int?> sizeBytes,
      Value<String?> note,
      Value<DateTime> createdAt,
    });

final class $$SaveBackupsTableReferences
    extends BaseReferences<_$AppDatabase, $SaveBackupsTable, SaveBackupRow> {
  $$SaveBackupsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $GamesTable _gameIdTable(_$AppDatabase db) =>
      db.games.createAlias('save_backups__game_id__games__id');

  $$GamesTableProcessedTableManager? get gameId {
    final $_column = $_itemColumn<int>('game_id');
    if ($_column == null) return null;
    final manager = $$GamesTableTableManager(
      $_db,
      $_db.games,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_gameIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $SaveStatesTable _saveStateIdTable(_$AppDatabase db) =>
      db.saveStates.createAlias('save_backups__save_state_id__save_states__id');

  $$SaveStatesTableProcessedTableManager? get saveStateId {
    final $_column = $_itemColumn<int>('save_state_id');
    if ($_column == null) return null;
    final manager = $$SaveStatesTableTableManager(
      $_db,
      $_db.saveStates,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_saveStateIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SaveBackupsTableFilterComposer
    extends Composer<_$AppDatabase, $SaveBackupsTable> {
  $$SaveBackupsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get backupPath => $composableBuilder(
    column: $table.backupPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sizeBytes => $composableBuilder(
    column: $table.sizeBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$GamesTableFilterComposer get gameId {
    final $$GamesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gameId,
      referencedTable: $db.games,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GamesTableFilterComposer(
            $db: $db,
            $table: $db.games,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SaveStatesTableFilterComposer get saveStateId {
    final $$SaveStatesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.saveStateId,
      referencedTable: $db.saveStates,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SaveStatesTableFilterComposer(
            $db: $db,
            $table: $db.saveStates,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SaveBackupsTableOrderingComposer
    extends Composer<_$AppDatabase, $SaveBackupsTable> {
  $$SaveBackupsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get backupPath => $composableBuilder(
    column: $table.backupPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sizeBytes => $composableBuilder(
    column: $table.sizeBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$GamesTableOrderingComposer get gameId {
    final $$GamesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gameId,
      referencedTable: $db.games,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GamesTableOrderingComposer(
            $db: $db,
            $table: $db.games,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SaveStatesTableOrderingComposer get saveStateId {
    final $$SaveStatesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.saveStateId,
      referencedTable: $db.saveStates,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SaveStatesTableOrderingComposer(
            $db: $db,
            $table: $db.saveStates,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SaveBackupsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SaveBackupsTable> {
  $$SaveBackupsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get backupPath => $composableBuilder(
    column: $table.backupPath,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sizeBytes =>
      $composableBuilder(column: $table.sizeBytes, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$GamesTableAnnotationComposer get gameId {
    final $$GamesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gameId,
      referencedTable: $db.games,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GamesTableAnnotationComposer(
            $db: $db,
            $table: $db.games,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SaveStatesTableAnnotationComposer get saveStateId {
    final $$SaveStatesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.saveStateId,
      referencedTable: $db.saveStates,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SaveStatesTableAnnotationComposer(
            $db: $db,
            $table: $db.saveStates,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SaveBackupsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SaveBackupsTable,
          SaveBackupRow,
          $$SaveBackupsTableFilterComposer,
          $$SaveBackupsTableOrderingComposer,
          $$SaveBackupsTableAnnotationComposer,
          $$SaveBackupsTableCreateCompanionBuilder,
          $$SaveBackupsTableUpdateCompanionBuilder,
          (SaveBackupRow, $$SaveBackupsTableReferences),
          SaveBackupRow,
          PrefetchHooks Function({bool gameId, bool saveStateId})
        > {
  $$SaveBackupsTableTableManager(_$AppDatabase db, $SaveBackupsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SaveBackupsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SaveBackupsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SaveBackupsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> gameId = const Value.absent(),
                Value<int?> saveStateId = const Value.absent(),
                Value<String> backupPath = const Value.absent(),
                Value<int?> sizeBytes = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => SaveBackupsCompanion(
                id: id,
                gameId: gameId,
                saveStateId: saveStateId,
                backupPath: backupPath,
                sizeBytes: sizeBytes,
                note: note,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> gameId = const Value.absent(),
                Value<int?> saveStateId = const Value.absent(),
                required String backupPath,
                Value<int?> sizeBytes = const Value.absent(),
                Value<String?> note = const Value.absent(),
                required DateTime createdAt,
              }) => SaveBackupsCompanion.insert(
                id: id,
                gameId: gameId,
                saveStateId: saveStateId,
                backupPath: backupPath,
                sizeBytes: sizeBytes,
                note: note,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SaveBackupsTable, SaveBackupRow>(table),
                  $$SaveBackupsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({gameId = false, saveStateId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (gameId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.gameId,
                        referencedTable: $$SaveBackupsTableReferences
                            ._gameIdTable(db),
                        referencedColumn: $$SaveBackupsTableReferences
                            ._gameIdTable(db)
                            .id,
                      ) as T;
                    }
                    if (saveStateId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.saveStateId,
                        referencedTable: $$SaveBackupsTableReferences
                            ._saveStateIdTable(db),
                        referencedColumn: $$SaveBackupsTableReferences
                            ._saveStateIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$SaveBackupsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SaveBackupsTable,
      SaveBackupRow,
      $$SaveBackupsTableFilterComposer,
      $$SaveBackupsTableOrderingComposer,
      $$SaveBackupsTableAnnotationComposer,
      $$SaveBackupsTableCreateCompanionBuilder,
      $$SaveBackupsTableUpdateCompanionBuilder,
      (SaveBackupRow, $$SaveBackupsTableReferences),
      SaveBackupRow,
      PrefetchHooks Function({bool gameId, bool saveStateId})
    >;
typedef $$BenchmarksTableCreateCompanionBuilder = BenchmarksCompanion Function({
  Value<int> id,
  required int deviceId,
  Value<String?> emulatorId,
  Value<String?> consoleId,
  Value<int?> gameId,
  required String benchmarkType,
  Value<double?> averageFps,
  Value<double?> minimumFps,
  Value<double?> score,
  required int durationMs,
  Value<String?> notes,
  required DateTime ranAt,
});
typedef $$BenchmarksTableUpdateCompanionBuilder = BenchmarksCompanion Function({
  Value<int> id,
  Value<int> deviceId,
  Value<String?> emulatorId,
  Value<String?> consoleId,
  Value<int?> gameId,
  Value<String> benchmarkType,
  Value<double?> averageFps,
  Value<double?> minimumFps,
  Value<double?> score,
  Value<int> durationMs,
  Value<String?> notes,
  Value<DateTime> ranAt,
});

final class $$BenchmarksTableReferences
    extends BaseReferences<_$AppDatabase, $BenchmarksTable, BenchmarkRow> {
  $$BenchmarksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $DevicesTable _deviceIdTable(_$AppDatabase db) =>
      db.devices.createAlias('benchmarks__device_id__devices__id');

  $$DevicesTableProcessedTableManager get deviceId {
    final $_column = $_itemColumn<int>('device_id')!;

    final manager = $$DevicesTableTableManager(
      $_db,
      $_db.devices,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_deviceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $GamesTable _gameIdTable(_$AppDatabase db) =>
      db.games.createAlias('benchmarks__game_id__games__id');

  $$GamesTableProcessedTableManager? get gameId {
    final $_column = $_itemColumn<int>('game_id');
    if ($_column == null) return null;
    final manager = $$GamesTableTableManager(
      $_db,
      $_db.games,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_gameIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$BenchmarksTableFilterComposer
    extends Composer<_$AppDatabase, $BenchmarksTable> {
  $$BenchmarksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get emulatorId => $composableBuilder(
    column: $table.emulatorId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get consoleId => $composableBuilder(
    column: $table.consoleId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get benchmarkType => $composableBuilder(
    column: $table.benchmarkType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get averageFps => $composableBuilder(
    column: $table.averageFps,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get minimumFps => $composableBuilder(
    column: $table.minimumFps,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get score => $composableBuilder(
    column: $table.score,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get ranAt => $composableBuilder(
    column: $table.ranAt,
    builder: (column) => ColumnFilters(column),
  );

  $$DevicesTableFilterComposer get deviceId {
    final $$DevicesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.deviceId,
      referencedTable: $db.devices,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DevicesTableFilterComposer(
            $db: $db,
            $table: $db.devices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$GamesTableFilterComposer get gameId {
    final $$GamesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gameId,
      referencedTable: $db.games,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GamesTableFilterComposer(
            $db: $db,
            $table: $db.games,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BenchmarksTableOrderingComposer
    extends Composer<_$AppDatabase, $BenchmarksTable> {
  $$BenchmarksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get emulatorId => $composableBuilder(
    column: $table.emulatorId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get consoleId => $composableBuilder(
    column: $table.consoleId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get benchmarkType => $composableBuilder(
    column: $table.benchmarkType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get averageFps => $composableBuilder(
    column: $table.averageFps,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get minimumFps => $composableBuilder(
    column: $table.minimumFps,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get score => $composableBuilder(
    column: $table.score,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get ranAt => $composableBuilder(
    column: $table.ranAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$DevicesTableOrderingComposer get deviceId {
    final $$DevicesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.deviceId,
      referencedTable: $db.devices,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DevicesTableOrderingComposer(
            $db: $db,
            $table: $db.devices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$GamesTableOrderingComposer get gameId {
    final $$GamesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gameId,
      referencedTable: $db.games,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GamesTableOrderingComposer(
            $db: $db,
            $table: $db.games,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BenchmarksTableAnnotationComposer
    extends Composer<_$AppDatabase, $BenchmarksTable> {
  $$BenchmarksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get emulatorId => $composableBuilder(
    column: $table.emulatorId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get consoleId =>
      $composableBuilder(column: $table.consoleId, builder: (column) => column);

  GeneratedColumn<String> get benchmarkType => $composableBuilder(
    column: $table.benchmarkType,
    builder: (column) => column,
  );

  GeneratedColumn<double> get averageFps => $composableBuilder(
    column: $table.averageFps,
    builder: (column) => column,
  );

  GeneratedColumn<double> get minimumFps => $composableBuilder(
    column: $table.minimumFps,
    builder: (column) => column,
  );

  GeneratedColumn<double> get score =>
      $composableBuilder(column: $table.score, builder: (column) => column);

  GeneratedColumn<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get ranAt =>
      $composableBuilder(column: $table.ranAt, builder: (column) => column);

  $$DevicesTableAnnotationComposer get deviceId {
    final $$DevicesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.deviceId,
      referencedTable: $db.devices,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DevicesTableAnnotationComposer(
            $db: $db,
            $table: $db.devices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$GamesTableAnnotationComposer get gameId {
    final $$GamesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gameId,
      referencedTable: $db.games,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GamesTableAnnotationComposer(
            $db: $db,
            $table: $db.games,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BenchmarksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BenchmarksTable,
          BenchmarkRow,
          $$BenchmarksTableFilterComposer,
          $$BenchmarksTableOrderingComposer,
          $$BenchmarksTableAnnotationComposer,
          $$BenchmarksTableCreateCompanionBuilder,
          $$BenchmarksTableUpdateCompanionBuilder,
          (BenchmarkRow, $$BenchmarksTableReferences),
          BenchmarkRow,
          PrefetchHooks Function({bool deviceId, bool gameId})
        > {
  $$BenchmarksTableTableManager(_$AppDatabase db, $BenchmarksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BenchmarksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BenchmarksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BenchmarksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> deviceId = const Value.absent(),
                Value<String?> emulatorId = const Value.absent(),
                Value<String?> consoleId = const Value.absent(),
                Value<int?> gameId = const Value.absent(),
                Value<String> benchmarkType = const Value.absent(),
                Value<double?> averageFps = const Value.absent(),
                Value<double?> minimumFps = const Value.absent(),
                Value<double?> score = const Value.absent(),
                Value<int> durationMs = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> ranAt = const Value.absent(),
              }) => BenchmarksCompanion(
                id: id,
                deviceId: deviceId,
                emulatorId: emulatorId,
                consoleId: consoleId,
                gameId: gameId,
                benchmarkType: benchmarkType,
                averageFps: averageFps,
                minimumFps: minimumFps,
                score: score,
                durationMs: durationMs,
                notes: notes,
                ranAt: ranAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int deviceId,
                Value<String?> emulatorId = const Value.absent(),
                Value<String?> consoleId = const Value.absent(),
                Value<int?> gameId = const Value.absent(),
                required String benchmarkType,
                Value<double?> averageFps = const Value.absent(),
                Value<double?> minimumFps = const Value.absent(),
                Value<double?> score = const Value.absent(),
                required int durationMs,
                Value<String?> notes = const Value.absent(),
                required DateTime ranAt,
              }) => BenchmarksCompanion.insert(
                id: id,
                deviceId: deviceId,
                emulatorId: emulatorId,
                consoleId: consoleId,
                gameId: gameId,
                benchmarkType: benchmarkType,
                averageFps: averageFps,
                minimumFps: minimumFps,
                score: score,
                durationMs: durationMs,
                notes: notes,
                ranAt: ranAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$BenchmarksTable, BenchmarkRow>(table),
                  $$BenchmarksTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({deviceId = false, gameId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (deviceId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.deviceId,
                        referencedTable: $$BenchmarksTableReferences
                            ._deviceIdTable(db),
                        referencedColumn: $$BenchmarksTableReferences
                            ._deviceIdTable(db)
                            .id,
                      ) as T;
                    }
                    if (gameId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.gameId,
                        referencedTable: $$BenchmarksTableReferences
                            ._gameIdTable(db),
                        referencedColumn: $$BenchmarksTableReferences
                            ._gameIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$BenchmarksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BenchmarksTable,
      BenchmarkRow,
      $$BenchmarksTableFilterComposer,
      $$BenchmarksTableOrderingComposer,
      $$BenchmarksTableAnnotationComposer,
      $$BenchmarksTableCreateCompanionBuilder,
      $$BenchmarksTableUpdateCompanionBuilder,
      (BenchmarkRow, $$BenchmarksTableReferences),
      BenchmarkRow,
      PrefetchHooks Function({bool deviceId, bool gameId})
    >;
typedef $$AppSettingsTableCreateCompanionBuilder =
    AppSettingsCompanion Function({
      required String key,
      required String value,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$AppSettingsTableUpdateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$AppSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$AppSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppSettingsTable,
          AppSettingRow,
          $$AppSettingsTableFilterComposer,
          $$AppSettingsTableOrderingComposer,
          $$AppSettingsTableAnnotationComposer,
          $$AppSettingsTableCreateCompanionBuilder,
          $$AppSettingsTableUpdateCompanionBuilder,
          (
            AppSettingRow,
            BaseReferences<_$AppDatabase, $AppSettingsTable, AppSettingRow>,
          ),
          AppSettingRow,
          PrefetchHooks Function()
        > {
  $$AppSettingsTableTableManager(_$AppDatabase db, $AppSettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion(
                key: key,
                value: value,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion.insert(
                key: key,
                value: value,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AppSettingsTable, AppSettingRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $AppSettingsTable,
                    AppSettingRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppSettingsTable,
      AppSettingRow,
      $$AppSettingsTableFilterComposer,
      $$AppSettingsTableOrderingComposer,
      $$AppSettingsTableAnnotationComposer,
      $$AppSettingsTableCreateCompanionBuilder,
      $$AppSettingsTableUpdateCompanionBuilder,
      (
        AppSettingRow,
        BaseReferences<_$AppDatabase, $AppSettingsTable, AppSettingRow>,
      ),
      AppSettingRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$DevicesTableTableManager get devices =>
      $$DevicesTableTableManager(_db, _db.devices);
  $$DeviceHardwareProfilesTableTableManager get deviceHardwareProfiles =>
      $$DeviceHardwareProfilesTableTableManager(
        _db,
        _db.deviceHardwareProfiles,
      );
  $$DeviceCompatibilityTableTableManager get deviceCompatibility =>
      $$DeviceCompatibilityTableTableManager(_db, _db.deviceCompatibility);
  $$EmulatorsTableTableManager get emulators =>
      $$EmulatorsTableTableManager(_db, _db.emulators);
  $$ConsolesTableTableManager get consoles =>
      $$ConsolesTableTableManager(_db, _db.consoles);
  $$GamesTableTableManager get games =>
      $$GamesTableTableManager(_db, _db.games);
  $$CompatibilityTestResultsTableTableManager get compatibilityTestResults =>
      $$CompatibilityTestResultsTableTableManager(
        _db,
        _db.compatibilityTestResults,
      );
  $$EmulatorProfilesTableTableManager get emulatorProfiles =>
      $$EmulatorProfilesTableTableManager(_db, _db.emulatorProfiles);
  $$EmulatorAdaptersTableTableManager get emulatorAdapters =>
      $$EmulatorAdaptersTableTableManager(_db, _db.emulatorAdapters);
  $$StorageDevicesTableTableManager get storageDevices =>
      $$StorageDevicesTableTableManager(_db, _db.storageDevices);
  $$GameFilesTableTableManager get gameFiles =>
      $$GameFilesTableTableManager(_db, _db.gameFiles);
  $$GameMetadataTableTableManager get gameMetadata =>
      $$GameMetadataTableTableManager(_db, _db.gameMetadata);
  $$GameArtworksTableTableManager get gameArtworks =>
      $$GameArtworksTableTableManager(_db, _db.gameArtworks);
  $$FavoritesTableTableManager get favorites =>
      $$FavoritesTableTableManager(_db, _db.favorites);
  $$GameHistoryTableTableManager get gameHistory =>
      $$GameHistoryTableTableManager(_db, _db.gameHistory);
  $$ControllerDevicesTableTableManager get controllerDevices =>
      $$ControllerDevicesTableTableManager(_db, _db.controllerDevices);
  $$ControllerProfilesTableTableManager get controllerProfiles =>
      $$ControllerProfilesTableTableManager(_db, _db.controllerProfiles);
  $$ControllerMappingsTableTableManager get controllerMappings =>
      $$ControllerMappingsTableTableManager(_db, _db.controllerMappings);
  $$SourceConnectorsTableTableManager get sourceConnectors =>
      $$SourceConnectorsTableTableManager(_db, _db.sourceConnectors);
  $$GameSourcesTableTableManager get gameSources =>
      $$GameSourcesTableTableManager(_db, _db.gameSources);
  $$DownloadQueueTableTableManager get downloadQueue =>
      $$DownloadQueueTableTableManager(_db, _db.downloadQueue);
  $$DownloadHistoryTableTableManager get downloadHistory =>
      $$DownloadHistoryTableTableManager(_db, _db.downloadHistory);
  $$SaveStatesTableTableManager get saveStates =>
      $$SaveStatesTableTableManager(_db, _db.saveStates);
  $$SaveBackupsTableTableManager get saveBackups =>
      $$SaveBackupsTableTableManager(_db, _db.saveBackups);
  $$BenchmarksTableTableManager get benchmarks =>
      $$BenchmarksTableTableManager(_db, _db.benchmarks);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
}
