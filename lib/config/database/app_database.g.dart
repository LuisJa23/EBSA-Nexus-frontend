// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $OfflineIncidentsTable extends OfflineIncidents
    with TableInfo<$OfflineIncidentsTable, OfflineIncidentData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OfflineIncidentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _serverIdMeta =
      const VerificationMeta('serverId');
  @override
  late final GeneratedColumn<int> serverId = GeneratedColumn<int>(
      'server_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _areaIdMeta = const VerificationMeta('areaId');
  @override
  late final GeneratedColumn<int> areaId = GeneratedColumn<int>(
      'area_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _accountNumberMeta =
      const VerificationMeta('accountNumber');
  @override
  late final GeneratedColumn<String> accountNumber = GeneratedColumn<String>(
      'account_number', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _meterNumberMeta =
      const VerificationMeta('meterNumber');
  @override
  late final GeneratedColumn<String> meterNumber = GeneratedColumn<String>(
      'meter_number', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _areaMeta = const VerificationMeta('area');
  @override
  late final GeneratedColumn<String> area = GeneratedColumn<String>(
      'area', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _reasonMeta = const VerificationMeta('reason');
  @override
  late final GeneratedColumn<String> reason = GeneratedColumn<String>(
      'reason', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _motivoMeta = const VerificationMeta('motivo');
  @override
  late final GeneratedColumn<String> motivo = GeneratedColumn<String>(
      'motivo', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _municipioMeta =
      const VerificationMeta('municipio');
  @override
  late final GeneratedColumn<String> municipio = GeneratedColumn<String>(
      'municipio', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _municipalityMeta =
      const VerificationMeta('municipality');
  @override
  late final GeneratedColumn<String> municipality = GeneratedColumn<String>(
      'municipality', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _addressMeta =
      const VerificationMeta('address');
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
      'address', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _activeReadingMeta =
      const VerificationMeta('activeReading');
  @override
  late final GeneratedColumn<String> activeReading = GeneratedColumn<String>(
      'active_reading', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _reactiveReadingMeta =
      const VerificationMeta('reactiveReading');
  @override
  late final GeneratedColumn<String> reactiveReading = GeneratedColumn<String>(
      'reactive_reading', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _observationsMeta =
      const VerificationMeta('observations');
  @override
  late final GeneratedColumn<String> observations = GeneratedColumn<String>(
      'observations', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  static const VerificationMeta _errorMessageMeta =
      const VerificationMeta('errorMessage');
  @override
  late final GeneratedColumn<String> errorMessage = GeneratedColumn<String>(
      'error_message', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _createdByMeta =
      const VerificationMeta('createdBy');
  @override
  late final GeneratedColumn<int> createdBy = GeneratedColumn<int>(
      'created_by', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        serverId,
        areaId,
        accountNumber,
        meterNumber,
        area,
        reason,
        motivo,
        municipio,
        municipality,
        address,
        description,
        activeReading,
        reactiveReading,
        observations,
        syncStatus,
        errorMessage,
        createdAt,
        updatedAt,
        createdBy
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'offline_incidents';
  @override
  VerificationContext validateIntegrity(
      Insertable<OfflineIncidentData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('server_id')) {
      context.handle(_serverIdMeta,
          serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta));
    }
    if (data.containsKey('area_id')) {
      context.handle(_areaIdMeta,
          areaId.isAcceptableOrUnknown(data['area_id']!, _areaIdMeta));
    } else if (isInserting) {
      context.missing(_areaIdMeta);
    }
    if (data.containsKey('account_number')) {
      context.handle(
          _accountNumberMeta,
          accountNumber.isAcceptableOrUnknown(
              data['account_number']!, _accountNumberMeta));
    } else if (isInserting) {
      context.missing(_accountNumberMeta);
    }
    if (data.containsKey('meter_number')) {
      context.handle(
          _meterNumberMeta,
          meterNumber.isAcceptableOrUnknown(
              data['meter_number']!, _meterNumberMeta));
    } else if (isInserting) {
      context.missing(_meterNumberMeta);
    }
    if (data.containsKey('area')) {
      context.handle(
          _areaMeta, area.isAcceptableOrUnknown(data['area']!, _areaMeta));
    } else if (isInserting) {
      context.missing(_areaMeta);
    }
    if (data.containsKey('reason')) {
      context.handle(_reasonMeta,
          reason.isAcceptableOrUnknown(data['reason']!, _reasonMeta));
    } else if (isInserting) {
      context.missing(_reasonMeta);
    }
    if (data.containsKey('motivo')) {
      context.handle(_motivoMeta,
          motivo.isAcceptableOrUnknown(data['motivo']!, _motivoMeta));
    } else if (isInserting) {
      context.missing(_motivoMeta);
    }
    if (data.containsKey('municipio')) {
      context.handle(_municipioMeta,
          municipio.isAcceptableOrUnknown(data['municipio']!, _municipioMeta));
    } else if (isInserting) {
      context.missing(_municipioMeta);
    }
    if (data.containsKey('municipality')) {
      context.handle(
          _municipalityMeta,
          municipality.isAcceptableOrUnknown(
              data['municipality']!, _municipalityMeta));
    } else if (isInserting) {
      context.missing(_municipalityMeta);
    }
    if (data.containsKey('address')) {
      context.handle(_addressMeta,
          address.isAcceptableOrUnknown(data['address']!, _addressMeta));
    } else if (isInserting) {
      context.missing(_addressMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('active_reading')) {
      context.handle(
          _activeReadingMeta,
          activeReading.isAcceptableOrUnknown(
              data['active_reading']!, _activeReadingMeta));
    } else if (isInserting) {
      context.missing(_activeReadingMeta);
    }
    if (data.containsKey('reactive_reading')) {
      context.handle(
          _reactiveReadingMeta,
          reactiveReading.isAcceptableOrUnknown(
              data['reactive_reading']!, _reactiveReadingMeta));
    } else if (isInserting) {
      context.missing(_reactiveReadingMeta);
    }
    if (data.containsKey('observations')) {
      context.handle(
          _observationsMeta,
          observations.isAcceptableOrUnknown(
              data['observations']!, _observationsMeta));
    } else if (isInserting) {
      context.missing(_observationsMeta);
    }
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(
              data['sync_status']!, _syncStatusMeta));
    }
    if (data.containsKey('error_message')) {
      context.handle(
          _errorMessageMeta,
          errorMessage.isAcceptableOrUnknown(
              data['error_message']!, _errorMessageMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('created_by')) {
      context.handle(_createdByMeta,
          createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta));
    } else if (isInserting) {
      context.missing(_createdByMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  OfflineIncidentData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OfflineIncidentData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      serverId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}server_id']),
      areaId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}area_id'])!,
      accountNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}account_number'])!,
      meterNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}meter_number'])!,
      area: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}area'])!,
      reason: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}reason'])!,
      motivo: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}motivo'])!,
      municipio: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}municipio'])!,
      municipality: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}municipality'])!,
      address: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}address'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description'])!,
      activeReading: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}active_reading'])!,
      reactiveReading: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}reactive_reading'])!,
      observations: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}observations'])!,
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status'])!,
      errorMessage: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}error_message']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      createdBy: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_by'])!,
    );
  }

  @override
  $OfflineIncidentsTable createAlias(String alias) {
    return $OfflineIncidentsTable(attachedDatabase, alias);
  }
}

class OfflineIncidentData extends DataClass
    implements Insertable<OfflineIncidentData> {
  /// ID local (UUID)
  final String id;

  /// ID del servidor (null hasta sincronizar)
  final int? serverId;

  /// ID numérico del área
  final int areaId;

  /// Número de cuenta
  final String accountNumber;

  /// Número de medidor
  final String meterNumber;

  /// Área de la novedad (nombre)
  final String area;

  /// Motivo de la novedad (reason)
  final String reason;

  /// Motivo de la novedad (nombre legible - motivo)
  final String motivo;

  /// Municipio
  final String municipio;

  /// Municipio (municipality para API)
  final String municipality;

  /// Dirección (address para API)
  final String address;

  /// Descripción
  final String description;

  /// Lectura activa
  final String activeReading;

  /// Lectura reactiva
  final String reactiveReading;

  /// Observaciones
  final String observations;

  /// Estado de sincronización: pending, synced, error
  final String syncStatus;

  /// Mensaje de error (si falla sincronización)
  final String? errorMessage;

  /// Fecha de creación
  final DateTime createdAt;

  /// Fecha de última actualización
  final DateTime updatedAt;

  /// Usuario que creó la novedad
  final int createdBy;
  const OfflineIncidentData(
      {required this.id,
      this.serverId,
      required this.areaId,
      required this.accountNumber,
      required this.meterNumber,
      required this.area,
      required this.reason,
      required this.motivo,
      required this.municipio,
      required this.municipality,
      required this.address,
      required this.description,
      required this.activeReading,
      required this.reactiveReading,
      required this.observations,
      required this.syncStatus,
      this.errorMessage,
      required this.createdAt,
      required this.updatedAt,
      required this.createdBy});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || serverId != null) {
      map['server_id'] = Variable<int>(serverId);
    }
    map['area_id'] = Variable<int>(areaId);
    map['account_number'] = Variable<String>(accountNumber);
    map['meter_number'] = Variable<String>(meterNumber);
    map['area'] = Variable<String>(area);
    map['reason'] = Variable<String>(reason);
    map['motivo'] = Variable<String>(motivo);
    map['municipio'] = Variable<String>(municipio);
    map['municipality'] = Variable<String>(municipality);
    map['address'] = Variable<String>(address);
    map['description'] = Variable<String>(description);
    map['active_reading'] = Variable<String>(activeReading);
    map['reactive_reading'] = Variable<String>(reactiveReading);
    map['observations'] = Variable<String>(observations);
    map['sync_status'] = Variable<String>(syncStatus);
    if (!nullToAbsent || errorMessage != null) {
      map['error_message'] = Variable<String>(errorMessage);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['created_by'] = Variable<int>(createdBy);
    return map;
  }

  OfflineIncidentsCompanion toCompanion(bool nullToAbsent) {
    return OfflineIncidentsCompanion(
      id: Value(id),
      serverId: serverId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverId),
      areaId: Value(areaId),
      accountNumber: Value(accountNumber),
      meterNumber: Value(meterNumber),
      area: Value(area),
      reason: Value(reason),
      motivo: Value(motivo),
      municipio: Value(municipio),
      municipality: Value(municipality),
      address: Value(address),
      description: Value(description),
      activeReading: Value(activeReading),
      reactiveReading: Value(reactiveReading),
      observations: Value(observations),
      syncStatus: Value(syncStatus),
      errorMessage: errorMessage == null && nullToAbsent
          ? const Value.absent()
          : Value(errorMessage),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      createdBy: Value(createdBy),
    );
  }

  factory OfflineIncidentData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OfflineIncidentData(
      id: serializer.fromJson<String>(json['id']),
      serverId: serializer.fromJson<int?>(json['serverId']),
      areaId: serializer.fromJson<int>(json['areaId']),
      accountNumber: serializer.fromJson<String>(json['accountNumber']),
      meterNumber: serializer.fromJson<String>(json['meterNumber']),
      area: serializer.fromJson<String>(json['area']),
      reason: serializer.fromJson<String>(json['reason']),
      motivo: serializer.fromJson<String>(json['motivo']),
      municipio: serializer.fromJson<String>(json['municipio']),
      municipality: serializer.fromJson<String>(json['municipality']),
      address: serializer.fromJson<String>(json['address']),
      description: serializer.fromJson<String>(json['description']),
      activeReading: serializer.fromJson<String>(json['activeReading']),
      reactiveReading: serializer.fromJson<String>(json['reactiveReading']),
      observations: serializer.fromJson<String>(json['observations']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      errorMessage: serializer.fromJson<String?>(json['errorMessage']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      createdBy: serializer.fromJson<int>(json['createdBy']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'serverId': serializer.toJson<int?>(serverId),
      'areaId': serializer.toJson<int>(areaId),
      'accountNumber': serializer.toJson<String>(accountNumber),
      'meterNumber': serializer.toJson<String>(meterNumber),
      'area': serializer.toJson<String>(area),
      'reason': serializer.toJson<String>(reason),
      'motivo': serializer.toJson<String>(motivo),
      'municipio': serializer.toJson<String>(municipio),
      'municipality': serializer.toJson<String>(municipality),
      'address': serializer.toJson<String>(address),
      'description': serializer.toJson<String>(description),
      'activeReading': serializer.toJson<String>(activeReading),
      'reactiveReading': serializer.toJson<String>(reactiveReading),
      'observations': serializer.toJson<String>(observations),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'errorMessage': serializer.toJson<String?>(errorMessage),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'createdBy': serializer.toJson<int>(createdBy),
    };
  }

  OfflineIncidentData copyWith(
          {String? id,
          Value<int?> serverId = const Value.absent(),
          int? areaId,
          String? accountNumber,
          String? meterNumber,
          String? area,
          String? reason,
          String? motivo,
          String? municipio,
          String? municipality,
          String? address,
          String? description,
          String? activeReading,
          String? reactiveReading,
          String? observations,
          String? syncStatus,
          Value<String?> errorMessage = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt,
          int? createdBy}) =>
      OfflineIncidentData(
        id: id ?? this.id,
        serverId: serverId.present ? serverId.value : this.serverId,
        areaId: areaId ?? this.areaId,
        accountNumber: accountNumber ?? this.accountNumber,
        meterNumber: meterNumber ?? this.meterNumber,
        area: area ?? this.area,
        reason: reason ?? this.reason,
        motivo: motivo ?? this.motivo,
        municipio: municipio ?? this.municipio,
        municipality: municipality ?? this.municipality,
        address: address ?? this.address,
        description: description ?? this.description,
        activeReading: activeReading ?? this.activeReading,
        reactiveReading: reactiveReading ?? this.reactiveReading,
        observations: observations ?? this.observations,
        syncStatus: syncStatus ?? this.syncStatus,
        errorMessage:
            errorMessage.present ? errorMessage.value : this.errorMessage,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        createdBy: createdBy ?? this.createdBy,
      );
  OfflineIncidentData copyWithCompanion(OfflineIncidentsCompanion data) {
    return OfflineIncidentData(
      id: data.id.present ? data.id.value : this.id,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      areaId: data.areaId.present ? data.areaId.value : this.areaId,
      accountNumber: data.accountNumber.present
          ? data.accountNumber.value
          : this.accountNumber,
      meterNumber:
          data.meterNumber.present ? data.meterNumber.value : this.meterNumber,
      area: data.area.present ? data.area.value : this.area,
      reason: data.reason.present ? data.reason.value : this.reason,
      motivo: data.motivo.present ? data.motivo.value : this.motivo,
      municipio: data.municipio.present ? data.municipio.value : this.municipio,
      municipality: data.municipality.present
          ? data.municipality.value
          : this.municipality,
      address: data.address.present ? data.address.value : this.address,
      description:
          data.description.present ? data.description.value : this.description,
      activeReading: data.activeReading.present
          ? data.activeReading.value
          : this.activeReading,
      reactiveReading: data.reactiveReading.present
          ? data.reactiveReading.value
          : this.reactiveReading,
      observations: data.observations.present
          ? data.observations.value
          : this.observations,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
      errorMessage: data.errorMessage.present
          ? data.errorMessage.value
          : this.errorMessage,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OfflineIncidentData(')
          ..write('id: $id, ')
          ..write('serverId: $serverId, ')
          ..write('areaId: $areaId, ')
          ..write('accountNumber: $accountNumber, ')
          ..write('meterNumber: $meterNumber, ')
          ..write('area: $area, ')
          ..write('reason: $reason, ')
          ..write('motivo: $motivo, ')
          ..write('municipio: $municipio, ')
          ..write('municipality: $municipality, ')
          ..write('address: $address, ')
          ..write('description: $description, ')
          ..write('activeReading: $activeReading, ')
          ..write('reactiveReading: $reactiveReading, ')
          ..write('observations: $observations, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('errorMessage: $errorMessage, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('createdBy: $createdBy')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      serverId,
      areaId,
      accountNumber,
      meterNumber,
      area,
      reason,
      motivo,
      municipio,
      municipality,
      address,
      description,
      activeReading,
      reactiveReading,
      observations,
      syncStatus,
      errorMessage,
      createdAt,
      updatedAt,
      createdBy);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OfflineIncidentData &&
          other.id == this.id &&
          other.serverId == this.serverId &&
          other.areaId == this.areaId &&
          other.accountNumber == this.accountNumber &&
          other.meterNumber == this.meterNumber &&
          other.area == this.area &&
          other.reason == this.reason &&
          other.motivo == this.motivo &&
          other.municipio == this.municipio &&
          other.municipality == this.municipality &&
          other.address == this.address &&
          other.description == this.description &&
          other.activeReading == this.activeReading &&
          other.reactiveReading == this.reactiveReading &&
          other.observations == this.observations &&
          other.syncStatus == this.syncStatus &&
          other.errorMessage == this.errorMessage &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.createdBy == this.createdBy);
}

class OfflineIncidentsCompanion extends UpdateCompanion<OfflineIncidentData> {
  final Value<String> id;
  final Value<int?> serverId;
  final Value<int> areaId;
  final Value<String> accountNumber;
  final Value<String> meterNumber;
  final Value<String> area;
  final Value<String> reason;
  final Value<String> motivo;
  final Value<String> municipio;
  final Value<String> municipality;
  final Value<String> address;
  final Value<String> description;
  final Value<String> activeReading;
  final Value<String> reactiveReading;
  final Value<String> observations;
  final Value<String> syncStatus;
  final Value<String?> errorMessage;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> createdBy;
  final Value<int> rowid;
  const OfflineIncidentsCompanion({
    this.id = const Value.absent(),
    this.serverId = const Value.absent(),
    this.areaId = const Value.absent(),
    this.accountNumber = const Value.absent(),
    this.meterNumber = const Value.absent(),
    this.area = const Value.absent(),
    this.reason = const Value.absent(),
    this.motivo = const Value.absent(),
    this.municipio = const Value.absent(),
    this.municipality = const Value.absent(),
    this.address = const Value.absent(),
    this.description = const Value.absent(),
    this.activeReading = const Value.absent(),
    this.reactiveReading = const Value.absent(),
    this.observations = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.errorMessage = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  OfflineIncidentsCompanion.insert({
    required String id,
    this.serverId = const Value.absent(),
    required int areaId,
    required String accountNumber,
    required String meterNumber,
    required String area,
    required String reason,
    required String motivo,
    required String municipio,
    required String municipality,
    required String address,
    required String description,
    required String activeReading,
    required String reactiveReading,
    required String observations,
    this.syncStatus = const Value.absent(),
    this.errorMessage = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    required int createdBy,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        areaId = Value(areaId),
        accountNumber = Value(accountNumber),
        meterNumber = Value(meterNumber),
        area = Value(area),
        reason = Value(reason),
        motivo = Value(motivo),
        municipio = Value(municipio),
        municipality = Value(municipality),
        address = Value(address),
        description = Value(description),
        activeReading = Value(activeReading),
        reactiveReading = Value(reactiveReading),
        observations = Value(observations),
        createdBy = Value(createdBy);
  static Insertable<OfflineIncidentData> custom({
    Expression<String>? id,
    Expression<int>? serverId,
    Expression<int>? areaId,
    Expression<String>? accountNumber,
    Expression<String>? meterNumber,
    Expression<String>? area,
    Expression<String>? reason,
    Expression<String>? motivo,
    Expression<String>? municipio,
    Expression<String>? municipality,
    Expression<String>? address,
    Expression<String>? description,
    Expression<String>? activeReading,
    Expression<String>? reactiveReading,
    Expression<String>? observations,
    Expression<String>? syncStatus,
    Expression<String>? errorMessage,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? createdBy,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (serverId != null) 'server_id': serverId,
      if (areaId != null) 'area_id': areaId,
      if (accountNumber != null) 'account_number': accountNumber,
      if (meterNumber != null) 'meter_number': meterNumber,
      if (area != null) 'area': area,
      if (reason != null) 'reason': reason,
      if (motivo != null) 'motivo': motivo,
      if (municipio != null) 'municipio': municipio,
      if (municipality != null) 'municipality': municipality,
      if (address != null) 'address': address,
      if (description != null) 'description': description,
      if (activeReading != null) 'active_reading': activeReading,
      if (reactiveReading != null) 'reactive_reading': reactiveReading,
      if (observations != null) 'observations': observations,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (errorMessage != null) 'error_message': errorMessage,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (createdBy != null) 'created_by': createdBy,
      if (rowid != null) 'rowid': rowid,
    });
  }

  OfflineIncidentsCompanion copyWith(
      {Value<String>? id,
      Value<int?>? serverId,
      Value<int>? areaId,
      Value<String>? accountNumber,
      Value<String>? meterNumber,
      Value<String>? area,
      Value<String>? reason,
      Value<String>? motivo,
      Value<String>? municipio,
      Value<String>? municipality,
      Value<String>? address,
      Value<String>? description,
      Value<String>? activeReading,
      Value<String>? reactiveReading,
      Value<String>? observations,
      Value<String>? syncStatus,
      Value<String?>? errorMessage,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? createdBy,
      Value<int>? rowid}) {
    return OfflineIncidentsCompanion(
      id: id ?? this.id,
      serverId: serverId ?? this.serverId,
      areaId: areaId ?? this.areaId,
      accountNumber: accountNumber ?? this.accountNumber,
      meterNumber: meterNumber ?? this.meterNumber,
      area: area ?? this.area,
      reason: reason ?? this.reason,
      motivo: motivo ?? this.motivo,
      municipio: municipio ?? this.municipio,
      municipality: municipality ?? this.municipality,
      address: address ?? this.address,
      description: description ?? this.description,
      activeReading: activeReading ?? this.activeReading,
      reactiveReading: reactiveReading ?? this.reactiveReading,
      observations: observations ?? this.observations,
      syncStatus: syncStatus ?? this.syncStatus,
      errorMessage: errorMessage ?? this.errorMessage,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (serverId.present) {
      map['server_id'] = Variable<int>(serverId.value);
    }
    if (areaId.present) {
      map['area_id'] = Variable<int>(areaId.value);
    }
    if (accountNumber.present) {
      map['account_number'] = Variable<String>(accountNumber.value);
    }
    if (meterNumber.present) {
      map['meter_number'] = Variable<String>(meterNumber.value);
    }
    if (area.present) {
      map['area'] = Variable<String>(area.value);
    }
    if (reason.present) {
      map['reason'] = Variable<String>(reason.value);
    }
    if (motivo.present) {
      map['motivo'] = Variable<String>(motivo.value);
    }
    if (municipio.present) {
      map['municipio'] = Variable<String>(municipio.value);
    }
    if (municipality.present) {
      map['municipality'] = Variable<String>(municipality.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (activeReading.present) {
      map['active_reading'] = Variable<String>(activeReading.value);
    }
    if (reactiveReading.present) {
      map['reactive_reading'] = Variable<String>(reactiveReading.value);
    }
    if (observations.present) {
      map['observations'] = Variable<String>(observations.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (errorMessage.present) {
      map['error_message'] = Variable<String>(errorMessage.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<int>(createdBy.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OfflineIncidentsCompanion(')
          ..write('id: $id, ')
          ..write('serverId: $serverId, ')
          ..write('areaId: $areaId, ')
          ..write('accountNumber: $accountNumber, ')
          ..write('meterNumber: $meterNumber, ')
          ..write('area: $area, ')
          ..write('reason: $reason, ')
          ..write('motivo: $motivo, ')
          ..write('municipio: $municipio, ')
          ..write('municipality: $municipality, ')
          ..write('address: $address, ')
          ..write('description: $description, ')
          ..write('activeReading: $activeReading, ')
          ..write('reactiveReading: $reactiveReading, ')
          ..write('observations: $observations, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('errorMessage: $errorMessage, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('createdBy: $createdBy, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $OfflineIncidentImagesTable extends OfflineIncidentImages
    with TableInfo<$OfflineIncidentImagesTable, OfflineIncidentImageData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OfflineIncidentImagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _incidentIdMeta =
      const VerificationMeta('incidentId');
  @override
  late final GeneratedColumn<String> incidentId = GeneratedColumn<String>(
      'incident_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES offline_incidents (id) ON DELETE CASCADE'));
  static const VerificationMeta _localPathMeta =
      const VerificationMeta('localPath');
  @override
  late final GeneratedColumn<String> localPath = GeneratedColumn<String>(
      'local_path', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _serverUrlMeta =
      const VerificationMeta('serverUrl');
  @override
  late final GeneratedColumn<String> serverUrl = GeneratedColumn<String>(
      'server_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [id, incidentId, localPath, serverUrl, syncStatus, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'offline_incident_images';
  @override
  VerificationContext validateIntegrity(
      Insertable<OfflineIncidentImageData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('incident_id')) {
      context.handle(
          _incidentIdMeta,
          incidentId.isAcceptableOrUnknown(
              data['incident_id']!, _incidentIdMeta));
    } else if (isInserting) {
      context.missing(_incidentIdMeta);
    }
    if (data.containsKey('local_path')) {
      context.handle(_localPathMeta,
          localPath.isAcceptableOrUnknown(data['local_path']!, _localPathMeta));
    } else if (isInserting) {
      context.missing(_localPathMeta);
    }
    if (data.containsKey('server_url')) {
      context.handle(_serverUrlMeta,
          serverUrl.isAcceptableOrUnknown(data['server_url']!, _serverUrlMeta));
    }
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(
              data['sync_status']!, _syncStatusMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  OfflineIncidentImageData map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OfflineIncidentImageData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      incidentId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}incident_id'])!,
      localPath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}local_path'])!,
      serverUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}server_url']),
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $OfflineIncidentImagesTable createAlias(String alias) {
    return $OfflineIncidentImagesTable(attachedDatabase, alias);
  }
}

class OfflineIncidentImageData extends DataClass
    implements Insertable<OfflineIncidentImageData> {
  /// ID de la imagen
  final int id;

  /// ID de la novedad (FK)
  final String incidentId;

  /// Ruta local del archivo
  final String localPath;

  /// URL del servidor (null hasta sincronizar)
  final String? serverUrl;

  /// Estado de sincronización: pending, synced, error
  final String syncStatus;

  /// Fecha de creación
  final DateTime createdAt;
  const OfflineIncidentImageData(
      {required this.id,
      required this.incidentId,
      required this.localPath,
      this.serverUrl,
      required this.syncStatus,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['incident_id'] = Variable<String>(incidentId);
    map['local_path'] = Variable<String>(localPath);
    if (!nullToAbsent || serverUrl != null) {
      map['server_url'] = Variable<String>(serverUrl);
    }
    map['sync_status'] = Variable<String>(syncStatus);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  OfflineIncidentImagesCompanion toCompanion(bool nullToAbsent) {
    return OfflineIncidentImagesCompanion(
      id: Value(id),
      incidentId: Value(incidentId),
      localPath: Value(localPath),
      serverUrl: serverUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(serverUrl),
      syncStatus: Value(syncStatus),
      createdAt: Value(createdAt),
    );
  }

  factory OfflineIncidentImageData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OfflineIncidentImageData(
      id: serializer.fromJson<int>(json['id']),
      incidentId: serializer.fromJson<String>(json['incidentId']),
      localPath: serializer.fromJson<String>(json['localPath']),
      serverUrl: serializer.fromJson<String?>(json['serverUrl']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'incidentId': serializer.toJson<String>(incidentId),
      'localPath': serializer.toJson<String>(localPath),
      'serverUrl': serializer.toJson<String?>(serverUrl),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  OfflineIncidentImageData copyWith(
          {int? id,
          String? incidentId,
          String? localPath,
          Value<String?> serverUrl = const Value.absent(),
          String? syncStatus,
          DateTime? createdAt}) =>
      OfflineIncidentImageData(
        id: id ?? this.id,
        incidentId: incidentId ?? this.incidentId,
        localPath: localPath ?? this.localPath,
        serverUrl: serverUrl.present ? serverUrl.value : this.serverUrl,
        syncStatus: syncStatus ?? this.syncStatus,
        createdAt: createdAt ?? this.createdAt,
      );
  OfflineIncidentImageData copyWithCompanion(
      OfflineIncidentImagesCompanion data) {
    return OfflineIncidentImageData(
      id: data.id.present ? data.id.value : this.id,
      incidentId:
          data.incidentId.present ? data.incidentId.value : this.incidentId,
      localPath: data.localPath.present ? data.localPath.value : this.localPath,
      serverUrl: data.serverUrl.present ? data.serverUrl.value : this.serverUrl,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OfflineIncidentImageData(')
          ..write('id: $id, ')
          ..write('incidentId: $incidentId, ')
          ..write('localPath: $localPath, ')
          ..write('serverUrl: $serverUrl, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, incidentId, localPath, serverUrl, syncStatus, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OfflineIncidentImageData &&
          other.id == this.id &&
          other.incidentId == this.incidentId &&
          other.localPath == this.localPath &&
          other.serverUrl == this.serverUrl &&
          other.syncStatus == this.syncStatus &&
          other.createdAt == this.createdAt);
}

class OfflineIncidentImagesCompanion
    extends UpdateCompanion<OfflineIncidentImageData> {
  final Value<int> id;
  final Value<String> incidentId;
  final Value<String> localPath;
  final Value<String?> serverUrl;
  final Value<String> syncStatus;
  final Value<DateTime> createdAt;
  const OfflineIncidentImagesCompanion({
    this.id = const Value.absent(),
    this.incidentId = const Value.absent(),
    this.localPath = const Value.absent(),
    this.serverUrl = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  OfflineIncidentImagesCompanion.insert({
    this.id = const Value.absent(),
    required String incidentId,
    required String localPath,
    this.serverUrl = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.createdAt = const Value.absent(),
  })  : incidentId = Value(incidentId),
        localPath = Value(localPath);
  static Insertable<OfflineIncidentImageData> custom({
    Expression<int>? id,
    Expression<String>? incidentId,
    Expression<String>? localPath,
    Expression<String>? serverUrl,
    Expression<String>? syncStatus,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (incidentId != null) 'incident_id': incidentId,
      if (localPath != null) 'local_path': localPath,
      if (serverUrl != null) 'server_url': serverUrl,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  OfflineIncidentImagesCompanion copyWith(
      {Value<int>? id,
      Value<String>? incidentId,
      Value<String>? localPath,
      Value<String?>? serverUrl,
      Value<String>? syncStatus,
      Value<DateTime>? createdAt}) {
    return OfflineIncidentImagesCompanion(
      id: id ?? this.id,
      incidentId: incidentId ?? this.incidentId,
      localPath: localPath ?? this.localPath,
      serverUrl: serverUrl ?? this.serverUrl,
      syncStatus: syncStatus ?? this.syncStatus,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (incidentId.present) {
      map['incident_id'] = Variable<String>(incidentId.value);
    }
    if (localPath.present) {
      map['local_path'] = Variable<String>(localPath.value);
    }
    if (serverUrl.present) {
      map['server_url'] = Variable<String>(serverUrl.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OfflineIncidentImagesCompanion(')
          ..write('id: $id, ')
          ..write('incidentId: $incidentId, ')
          ..write('localPath: $localPath, ')
          ..write('serverUrl: $serverUrl, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $OfflineIncidentsTable offlineIncidents =
      $OfflineIncidentsTable(this);
  late final $OfflineIncidentImagesTable offlineIncidentImages =
      $OfflineIncidentImagesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [offlineIncidents, offlineIncidentImages];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules(
        [
          WritePropagation(
            on: TableUpdateQuery.onTableName('offline_incidents',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('offline_incident_images', kind: UpdateKind.delete),
            ],
          ),
        ],
      );
}

typedef $$OfflineIncidentsTableCreateCompanionBuilder
    = OfflineIncidentsCompanion Function({
  required String id,
  Value<int?> serverId,
  required int areaId,
  required String accountNumber,
  required String meterNumber,
  required String area,
  required String reason,
  required String motivo,
  required String municipio,
  required String municipality,
  required String address,
  required String description,
  required String activeReading,
  required String reactiveReading,
  required String observations,
  Value<String> syncStatus,
  Value<String?> errorMessage,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  required int createdBy,
  Value<int> rowid,
});
typedef $$OfflineIncidentsTableUpdateCompanionBuilder
    = OfflineIncidentsCompanion Function({
  Value<String> id,
  Value<int?> serverId,
  Value<int> areaId,
  Value<String> accountNumber,
  Value<String> meterNumber,
  Value<String> area,
  Value<String> reason,
  Value<String> motivo,
  Value<String> municipio,
  Value<String> municipality,
  Value<String> address,
  Value<String> description,
  Value<String> activeReading,
  Value<String> reactiveReading,
  Value<String> observations,
  Value<String> syncStatus,
  Value<String?> errorMessage,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> createdBy,
  Value<int> rowid,
});

final class $$OfflineIncidentsTableReferences extends BaseReferences<
    _$AppDatabase, $OfflineIncidentsTable, OfflineIncidentData> {
  $$OfflineIncidentsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$OfflineIncidentImagesTable,
      List<OfflineIncidentImageData>> _offlineIncidentImagesRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.offlineIncidentImages,
          aliasName: $_aliasNameGenerator(
              db.offlineIncidents.id, db.offlineIncidentImages.incidentId));

  $$OfflineIncidentImagesTableProcessedTableManager
      get offlineIncidentImagesRefs {
    final manager = $$OfflineIncidentImagesTableTableManager(
            $_db, $_db.offlineIncidentImages)
        .filter((f) => f.incidentId.id($_item.id));

    final cache =
        $_typedResult.readTableOrNull(_offlineIncidentImagesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$OfflineIncidentsTableFilterComposer
    extends Composer<_$AppDatabase, $OfflineIncidentsTable> {
  $$OfflineIncidentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get serverId => $composableBuilder(
      column: $table.serverId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get areaId => $composableBuilder(
      column: $table.areaId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get accountNumber => $composableBuilder(
      column: $table.accountNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get meterNumber => $composableBuilder(
      column: $table.meterNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get area => $composableBuilder(
      column: $table.area, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get reason => $composableBuilder(
      column: $table.reason, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get motivo => $composableBuilder(
      column: $table.motivo, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get municipio => $composableBuilder(
      column: $table.municipio, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get municipality => $composableBuilder(
      column: $table.municipality, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get address => $composableBuilder(
      column: $table.address, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get activeReading => $composableBuilder(
      column: $table.activeReading, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get reactiveReading => $composableBuilder(
      column: $table.reactiveReading,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get observations => $composableBuilder(
      column: $table.observations, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get errorMessage => $composableBuilder(
      column: $table.errorMessage, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdBy => $composableBuilder(
      column: $table.createdBy, builder: (column) => ColumnFilters(column));

  Expression<bool> offlineIncidentImagesRefs(
      Expression<bool> Function($$OfflineIncidentImagesTableFilterComposer f)
          f) {
    final $$OfflineIncidentImagesTableFilterComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.offlineIncidentImages,
            getReferencedColumn: (t) => t.incidentId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$OfflineIncidentImagesTableFilterComposer(
                  $db: $db,
                  $table: $db.offlineIncidentImages,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$OfflineIncidentsTableOrderingComposer
    extends Composer<_$AppDatabase, $OfflineIncidentsTable> {
  $$OfflineIncidentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get serverId => $composableBuilder(
      column: $table.serverId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get areaId => $composableBuilder(
      column: $table.areaId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get accountNumber => $composableBuilder(
      column: $table.accountNumber,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get meterNumber => $composableBuilder(
      column: $table.meterNumber, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get area => $composableBuilder(
      column: $table.area, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get reason => $composableBuilder(
      column: $table.reason, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get motivo => $composableBuilder(
      column: $table.motivo, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get municipio => $composableBuilder(
      column: $table.municipio, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get municipality => $composableBuilder(
      column: $table.municipality,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get address => $composableBuilder(
      column: $table.address, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get activeReading => $composableBuilder(
      column: $table.activeReading,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get reactiveReading => $composableBuilder(
      column: $table.reactiveReading,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get observations => $composableBuilder(
      column: $table.observations,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get errorMessage => $composableBuilder(
      column: $table.errorMessage,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdBy => $composableBuilder(
      column: $table.createdBy, builder: (column) => ColumnOrderings(column));
}

class $$OfflineIncidentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $OfflineIncidentsTable> {
  $$OfflineIncidentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);

  GeneratedColumn<int> get areaId =>
      $composableBuilder(column: $table.areaId, builder: (column) => column);

  GeneratedColumn<String> get accountNumber => $composableBuilder(
      column: $table.accountNumber, builder: (column) => column);

  GeneratedColumn<String> get meterNumber => $composableBuilder(
      column: $table.meterNumber, builder: (column) => column);

  GeneratedColumn<String> get area =>
      $composableBuilder(column: $table.area, builder: (column) => column);

  GeneratedColumn<String> get reason =>
      $composableBuilder(column: $table.reason, builder: (column) => column);

  GeneratedColumn<String> get motivo =>
      $composableBuilder(column: $table.motivo, builder: (column) => column);

  GeneratedColumn<String> get municipio =>
      $composableBuilder(column: $table.municipio, builder: (column) => column);

  GeneratedColumn<String> get municipality => $composableBuilder(
      column: $table.municipality, builder: (column) => column);

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<String> get activeReading => $composableBuilder(
      column: $table.activeReading, builder: (column) => column);

  GeneratedColumn<String> get reactiveReading => $composableBuilder(
      column: $table.reactiveReading, builder: (column) => column);

  GeneratedColumn<String> get observations => $composableBuilder(
      column: $table.observations, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => column);

  GeneratedColumn<String> get errorMessage => $composableBuilder(
      column: $table.errorMessage, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => column);

  Expression<T> offlineIncidentImagesRefs<T extends Object>(
      Expression<T> Function($$OfflineIncidentImagesTableAnnotationComposer a)
          f) {
    final $$OfflineIncidentImagesTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.offlineIncidentImages,
            getReferencedColumn: (t) => t.incidentId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$OfflineIncidentImagesTableAnnotationComposer(
                  $db: $db,
                  $table: $db.offlineIncidentImages,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$OfflineIncidentsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $OfflineIncidentsTable,
    OfflineIncidentData,
    $$OfflineIncidentsTableFilterComposer,
    $$OfflineIncidentsTableOrderingComposer,
    $$OfflineIncidentsTableAnnotationComposer,
    $$OfflineIncidentsTableCreateCompanionBuilder,
    $$OfflineIncidentsTableUpdateCompanionBuilder,
    (OfflineIncidentData, $$OfflineIncidentsTableReferences),
    OfflineIncidentData,
    PrefetchHooks Function({bool offlineIncidentImagesRefs})> {
  $$OfflineIncidentsTableTableManager(
      _$AppDatabase db, $OfflineIncidentsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OfflineIncidentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OfflineIncidentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OfflineIncidentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<int?> serverId = const Value.absent(),
            Value<int> areaId = const Value.absent(),
            Value<String> accountNumber = const Value.absent(),
            Value<String> meterNumber = const Value.absent(),
            Value<String> area = const Value.absent(),
            Value<String> reason = const Value.absent(),
            Value<String> motivo = const Value.absent(),
            Value<String> municipio = const Value.absent(),
            Value<String> municipality = const Value.absent(),
            Value<String> address = const Value.absent(),
            Value<String> description = const Value.absent(),
            Value<String> activeReading = const Value.absent(),
            Value<String> reactiveReading = const Value.absent(),
            Value<String> observations = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<String?> errorMessage = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> createdBy = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              OfflineIncidentsCompanion(
            id: id,
            serverId: serverId,
            areaId: areaId,
            accountNumber: accountNumber,
            meterNumber: meterNumber,
            area: area,
            reason: reason,
            motivo: motivo,
            municipio: municipio,
            municipality: municipality,
            address: address,
            description: description,
            activeReading: activeReading,
            reactiveReading: reactiveReading,
            observations: observations,
            syncStatus: syncStatus,
            errorMessage: errorMessage,
            createdAt: createdAt,
            updatedAt: updatedAt,
            createdBy: createdBy,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<int?> serverId = const Value.absent(),
            required int areaId,
            required String accountNumber,
            required String meterNumber,
            required String area,
            required String reason,
            required String motivo,
            required String municipio,
            required String municipality,
            required String address,
            required String description,
            required String activeReading,
            required String reactiveReading,
            required String observations,
            Value<String> syncStatus = const Value.absent(),
            Value<String?> errorMessage = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            required int createdBy,
            Value<int> rowid = const Value.absent(),
          }) =>
              OfflineIncidentsCompanion.insert(
            id: id,
            serverId: serverId,
            areaId: areaId,
            accountNumber: accountNumber,
            meterNumber: meterNumber,
            area: area,
            reason: reason,
            motivo: motivo,
            municipio: municipio,
            municipality: municipality,
            address: address,
            description: description,
            activeReading: activeReading,
            reactiveReading: reactiveReading,
            observations: observations,
            syncStatus: syncStatus,
            errorMessage: errorMessage,
            createdAt: createdAt,
            updatedAt: updatedAt,
            createdBy: createdBy,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$OfflineIncidentsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({offlineIncidentImagesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (offlineIncidentImagesRefs) db.offlineIncidentImages
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (offlineIncidentImagesRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable: $$OfflineIncidentsTableReferences
                            ._offlineIncidentImagesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$OfflineIncidentsTableReferences(db, table, p0)
                                .offlineIncidentImagesRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.incidentId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$OfflineIncidentsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $OfflineIncidentsTable,
    OfflineIncidentData,
    $$OfflineIncidentsTableFilterComposer,
    $$OfflineIncidentsTableOrderingComposer,
    $$OfflineIncidentsTableAnnotationComposer,
    $$OfflineIncidentsTableCreateCompanionBuilder,
    $$OfflineIncidentsTableUpdateCompanionBuilder,
    (OfflineIncidentData, $$OfflineIncidentsTableReferences),
    OfflineIncidentData,
    PrefetchHooks Function({bool offlineIncidentImagesRefs})>;
typedef $$OfflineIncidentImagesTableCreateCompanionBuilder
    = OfflineIncidentImagesCompanion Function({
  Value<int> id,
  required String incidentId,
  required String localPath,
  Value<String?> serverUrl,
  Value<String> syncStatus,
  Value<DateTime> createdAt,
});
typedef $$OfflineIncidentImagesTableUpdateCompanionBuilder
    = OfflineIncidentImagesCompanion Function({
  Value<int> id,
  Value<String> incidentId,
  Value<String> localPath,
  Value<String?> serverUrl,
  Value<String> syncStatus,
  Value<DateTime> createdAt,
});

final class $$OfflineIncidentImagesTableReferences extends BaseReferences<
    _$AppDatabase, $OfflineIncidentImagesTable, OfflineIncidentImageData> {
  $$OfflineIncidentImagesTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $OfflineIncidentsTable _incidentIdTable(_$AppDatabase db) =>
      db.offlineIncidents.createAlias($_aliasNameGenerator(
          db.offlineIncidentImages.incidentId, db.offlineIncidents.id));

  $$OfflineIncidentsTableProcessedTableManager? get incidentId {
    if ($_item.incidentId == null) return null;
    final manager =
        $$OfflineIncidentsTableTableManager($_db, $_db.offlineIncidents)
            .filter((f) => f.id($_item.incidentId!));
    final item = $_typedResult.readTableOrNull(_incidentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$OfflineIncidentImagesTableFilterComposer
    extends Composer<_$AppDatabase, $OfflineIncidentImagesTable> {
  $$OfflineIncidentImagesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get localPath => $composableBuilder(
      column: $table.localPath, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get serverUrl => $composableBuilder(
      column: $table.serverUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  $$OfflineIncidentsTableFilterComposer get incidentId {
    final $$OfflineIncidentsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.incidentId,
        referencedTable: $db.offlineIncidents,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$OfflineIncidentsTableFilterComposer(
              $db: $db,
              $table: $db.offlineIncidents,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$OfflineIncidentImagesTableOrderingComposer
    extends Composer<_$AppDatabase, $OfflineIncidentImagesTable> {
  $$OfflineIncidentImagesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get localPath => $composableBuilder(
      column: $table.localPath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get serverUrl => $composableBuilder(
      column: $table.serverUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  $$OfflineIncidentsTableOrderingComposer get incidentId {
    final $$OfflineIncidentsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.incidentId,
        referencedTable: $db.offlineIncidents,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$OfflineIncidentsTableOrderingComposer(
              $db: $db,
              $table: $db.offlineIncidents,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$OfflineIncidentImagesTableAnnotationComposer
    extends Composer<_$AppDatabase, $OfflineIncidentImagesTable> {
  $$OfflineIncidentImagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get localPath =>
      $composableBuilder(column: $table.localPath, builder: (column) => column);

  GeneratedColumn<String> get serverUrl =>
      $composableBuilder(column: $table.serverUrl, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$OfflineIncidentsTableAnnotationComposer get incidentId {
    final $$OfflineIncidentsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.incidentId,
        referencedTable: $db.offlineIncidents,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$OfflineIncidentsTableAnnotationComposer(
              $db: $db,
              $table: $db.offlineIncidents,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$OfflineIncidentImagesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $OfflineIncidentImagesTable,
    OfflineIncidentImageData,
    $$OfflineIncidentImagesTableFilterComposer,
    $$OfflineIncidentImagesTableOrderingComposer,
    $$OfflineIncidentImagesTableAnnotationComposer,
    $$OfflineIncidentImagesTableCreateCompanionBuilder,
    $$OfflineIncidentImagesTableUpdateCompanionBuilder,
    (OfflineIncidentImageData, $$OfflineIncidentImagesTableReferences),
    OfflineIncidentImageData,
    PrefetchHooks Function({bool incidentId})> {
  $$OfflineIncidentImagesTableTableManager(
      _$AppDatabase db, $OfflineIncidentImagesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OfflineIncidentImagesTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$OfflineIncidentImagesTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OfflineIncidentImagesTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> incidentId = const Value.absent(),
            Value<String> localPath = const Value.absent(),
            Value<String?> serverUrl = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              OfflineIncidentImagesCompanion(
            id: id,
            incidentId: incidentId,
            localPath: localPath,
            serverUrl: serverUrl,
            syncStatus: syncStatus,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String incidentId,
            required String localPath,
            Value<String?> serverUrl = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              OfflineIncidentImagesCompanion.insert(
            id: id,
            incidentId: incidentId,
            localPath: localPath,
            serverUrl: serverUrl,
            syncStatus: syncStatus,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$OfflineIncidentImagesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({incidentId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
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
                      dynamic>>(state) {
                if (incidentId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.incidentId,
                    referencedTable: $$OfflineIncidentImagesTableReferences
                        ._incidentIdTable(db),
                    referencedColumn: $$OfflineIncidentImagesTableReferences
                        ._incidentIdTable(db)
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
        ));
}

typedef $$OfflineIncidentImagesTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $OfflineIncidentImagesTable,
        OfflineIncidentImageData,
        $$OfflineIncidentImagesTableFilterComposer,
        $$OfflineIncidentImagesTableOrderingComposer,
        $$OfflineIncidentImagesTableAnnotationComposer,
        $$OfflineIncidentImagesTableCreateCompanionBuilder,
        $$OfflineIncidentImagesTableUpdateCompanionBuilder,
        (OfflineIncidentImageData, $$OfflineIncidentImagesTableReferences),
        OfflineIncidentImageData,
        PrefetchHooks Function({bool incidentId})>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$OfflineIncidentsTableTableManager get offlineIncidents =>
      $$OfflineIncidentsTableTableManager(_db, _db.offlineIncidents);
  $$OfflineIncidentImagesTableTableManager get offlineIncidentImages =>
      $$OfflineIncidentImagesTableTableManager(_db, _db.offlineIncidentImages);
}
