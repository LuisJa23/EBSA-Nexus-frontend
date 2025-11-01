// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $NoveltyCacheTableTable extends NoveltyCacheTable
    with TableInfo<$NoveltyCacheTableTable, NoveltyCacheTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NoveltyCacheTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _noveltyIdMeta =
      const VerificationMeta('noveltyId');
  @override
  late final GeneratedColumn<int> noveltyId = GeneratedColumn<int>(
      'novelty_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _areaIdMeta = const VerificationMeta('areaId');
  @override
  late final GeneratedColumn<int> areaId = GeneratedColumn<int>(
      'area_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _reasonMeta = const VerificationMeta('reason');
  @override
  late final GeneratedColumn<String> reason = GeneratedColumn<String>(
      'reason', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
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
  static const VerificationMeta _activeReadingMeta =
      const VerificationMeta('activeReading');
  @override
  late final GeneratedColumn<double> activeReading = GeneratedColumn<double>(
      'active_reading', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _reactiveReadingMeta =
      const VerificationMeta('reactiveReading');
  @override
  late final GeneratedColumn<double> reactiveReading = GeneratedColumn<double>(
      'reactive_reading', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
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
  static const VerificationMeta _observationsMeta =
      const VerificationMeta('observations');
  @override
  late final GeneratedColumn<String> observations = GeneratedColumn<String>(
      'observations', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdByMeta =
      const VerificationMeta('createdBy');
  @override
  late final GeneratedColumn<int> createdBy = GeneratedColumn<int>(
      'created_by', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _crewIdMeta = const VerificationMeta('crewId');
  @override
  late final GeneratedColumn<int> crewId = GeneratedColumn<int>(
      'crew_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _completedAtMeta =
      const VerificationMeta('completedAt');
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
      'completed_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _closedAtMeta =
      const VerificationMeta('closedAt');
  @override
  late final GeneratedColumn<DateTime> closedAt = GeneratedColumn<DateTime>(
      'closed_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _cancelledAtMeta =
      const VerificationMeta('cancelledAt');
  @override
  late final GeneratedColumn<DateTime> cancelledAt = GeneratedColumn<DateTime>(
      'cancelled_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _cachedAtMeta =
      const VerificationMeta('cachedAt');
  @override
  late final GeneratedColumn<DateTime> cachedAt = GeneratedColumn<DateTime>(
      'cached_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _rawJsonMeta =
      const VerificationMeta('rawJson');
  @override
  late final GeneratedColumn<String> rawJson = GeneratedColumn<String>(
      'raw_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        noveltyId,
        areaId,
        reason,
        accountNumber,
        meterNumber,
        activeReading,
        reactiveReading,
        municipality,
        address,
        description,
        observations,
        status,
        createdBy,
        crewId,
        createdAt,
        updatedAt,
        completedAt,
        closedAt,
        cancelledAt,
        cachedAt,
        rawJson
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'novelty_cache';
  @override
  VerificationContext validateIntegrity(
      Insertable<NoveltyCacheTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('novelty_id')) {
      context.handle(_noveltyIdMeta,
          noveltyId.isAcceptableOrUnknown(data['novelty_id']!, _noveltyIdMeta));
    }
    if (data.containsKey('area_id')) {
      context.handle(_areaIdMeta,
          areaId.isAcceptableOrUnknown(data['area_id']!, _areaIdMeta));
    } else if (isInserting) {
      context.missing(_areaIdMeta);
    }
    if (data.containsKey('reason')) {
      context.handle(_reasonMeta,
          reason.isAcceptableOrUnknown(data['reason']!, _reasonMeta));
    } else if (isInserting) {
      context.missing(_reasonMeta);
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
    if (data.containsKey('observations')) {
      context.handle(
          _observationsMeta,
          observations.isAcceptableOrUnknown(
              data['observations']!, _observationsMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('created_by')) {
      context.handle(_createdByMeta,
          createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta));
    } else if (isInserting) {
      context.missing(_createdByMeta);
    }
    if (data.containsKey('crew_id')) {
      context.handle(_crewIdMeta,
          crewId.isAcceptableOrUnknown(data['crew_id']!, _crewIdMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('completed_at')) {
      context.handle(
          _completedAtMeta,
          completedAt.isAcceptableOrUnknown(
              data['completed_at']!, _completedAtMeta));
    }
    if (data.containsKey('closed_at')) {
      context.handle(_closedAtMeta,
          closedAt.isAcceptableOrUnknown(data['closed_at']!, _closedAtMeta));
    }
    if (data.containsKey('cancelled_at')) {
      context.handle(
          _cancelledAtMeta,
          cancelledAt.isAcceptableOrUnknown(
              data['cancelled_at']!, _cancelledAtMeta));
    }
    if (data.containsKey('cached_at')) {
      context.handle(_cachedAtMeta,
          cachedAt.isAcceptableOrUnknown(data['cached_at']!, _cachedAtMeta));
    } else if (isInserting) {
      context.missing(_cachedAtMeta);
    }
    if (data.containsKey('raw_json')) {
      context.handle(_rawJsonMeta,
          rawJson.isAcceptableOrUnknown(data['raw_json']!, _rawJsonMeta));
    } else if (isInserting) {
      context.missing(_rawJsonMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {noveltyId};
  @override
  NoveltyCacheTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NoveltyCacheTableData(
      noveltyId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}novelty_id'])!,
      areaId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}area_id'])!,
      reason: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}reason'])!,
      accountNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}account_number'])!,
      meterNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}meter_number'])!,
      activeReading: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}active_reading'])!,
      reactiveReading: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}reactive_reading'])!,
      municipality: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}municipality'])!,
      address: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}address'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description'])!,
      observations: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}observations']),
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      createdBy: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_by'])!,
      crewId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}crew_id']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      completedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}completed_at']),
      closedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}closed_at']),
      cancelledAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}cancelled_at']),
      cachedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}cached_at'])!,
      rawJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}raw_json'])!,
    );
  }

  @override
  $NoveltyCacheTableTable createAlias(String alias) {
    return $NoveltyCacheTableTable(attachedDatabase, alias);
  }
}

class NoveltyCacheTableData extends DataClass
    implements Insertable<NoveltyCacheTableData> {
  /// ID de la novedad (clave primaria, del servidor)
  final int noveltyId;

  /// ID del área
  final int areaId;

  /// Razón/motivo de la novedad
  final String reason;

  /// Número de cuenta
  final String accountNumber;

  /// Número de medidor
  final String meterNumber;

  /// Lectura activa
  final double activeReading;

  /// Lectura reactiva
  final double reactiveReading;

  /// Municipio
  final String municipality;

  /// Dirección
  final String address;

  /// Descripción
  final String description;

  /// Observaciones (opcional)
  final String? observations;

  /// Estado de la novedad
  final String status;

  /// ID del usuario que creó la novedad
  final int createdBy;

  /// ID de la cuadrilla asignada (opcional)
  final int? crewId;

  /// Fecha de creación en el servidor
  final DateTime createdAt;

  /// Fecha de última actualización en el servidor
  final DateTime updatedAt;

  /// Fecha de completado (opcional)
  final DateTime? completedAt;

  /// Fecha de cierre (opcional)
  final DateTime? closedAt;

  /// Fecha de cancelación (opcional)
  final DateTime? cancelledAt;

  /// Fecha de almacenamiento en cache
  final DateTime cachedAt;

  /// Datos JSON completos para información adicional
  final String rawJson;
  const NoveltyCacheTableData(
      {required this.noveltyId,
      required this.areaId,
      required this.reason,
      required this.accountNumber,
      required this.meterNumber,
      required this.activeReading,
      required this.reactiveReading,
      required this.municipality,
      required this.address,
      required this.description,
      this.observations,
      required this.status,
      required this.createdBy,
      this.crewId,
      required this.createdAt,
      required this.updatedAt,
      this.completedAt,
      this.closedAt,
      this.cancelledAt,
      required this.cachedAt,
      required this.rawJson});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['novelty_id'] = Variable<int>(noveltyId);
    map['area_id'] = Variable<int>(areaId);
    map['reason'] = Variable<String>(reason);
    map['account_number'] = Variable<String>(accountNumber);
    map['meter_number'] = Variable<String>(meterNumber);
    map['active_reading'] = Variable<double>(activeReading);
    map['reactive_reading'] = Variable<double>(reactiveReading);
    map['municipality'] = Variable<String>(municipality);
    map['address'] = Variable<String>(address);
    map['description'] = Variable<String>(description);
    if (!nullToAbsent || observations != null) {
      map['observations'] = Variable<String>(observations);
    }
    map['status'] = Variable<String>(status);
    map['created_by'] = Variable<int>(createdBy);
    if (!nullToAbsent || crewId != null) {
      map['crew_id'] = Variable<int>(crewId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    if (!nullToAbsent || closedAt != null) {
      map['closed_at'] = Variable<DateTime>(closedAt);
    }
    if (!nullToAbsent || cancelledAt != null) {
      map['cancelled_at'] = Variable<DateTime>(cancelledAt);
    }
    map['cached_at'] = Variable<DateTime>(cachedAt);
    map['raw_json'] = Variable<String>(rawJson);
    return map;
  }

  NoveltyCacheTableCompanion toCompanion(bool nullToAbsent) {
    return NoveltyCacheTableCompanion(
      noveltyId: Value(noveltyId),
      areaId: Value(areaId),
      reason: Value(reason),
      accountNumber: Value(accountNumber),
      meterNumber: Value(meterNumber),
      activeReading: Value(activeReading),
      reactiveReading: Value(reactiveReading),
      municipality: Value(municipality),
      address: Value(address),
      description: Value(description),
      observations: observations == null && nullToAbsent
          ? const Value.absent()
          : Value(observations),
      status: Value(status),
      createdBy: Value(createdBy),
      crewId:
          crewId == null && nullToAbsent ? const Value.absent() : Value(crewId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      closedAt: closedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(closedAt),
      cancelledAt: cancelledAt == null && nullToAbsent
          ? const Value.absent()
          : Value(cancelledAt),
      cachedAt: Value(cachedAt),
      rawJson: Value(rawJson),
    );
  }

  factory NoveltyCacheTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NoveltyCacheTableData(
      noveltyId: serializer.fromJson<int>(json['noveltyId']),
      areaId: serializer.fromJson<int>(json['areaId']),
      reason: serializer.fromJson<String>(json['reason']),
      accountNumber: serializer.fromJson<String>(json['accountNumber']),
      meterNumber: serializer.fromJson<String>(json['meterNumber']),
      activeReading: serializer.fromJson<double>(json['activeReading']),
      reactiveReading: serializer.fromJson<double>(json['reactiveReading']),
      municipality: serializer.fromJson<String>(json['municipality']),
      address: serializer.fromJson<String>(json['address']),
      description: serializer.fromJson<String>(json['description']),
      observations: serializer.fromJson<String?>(json['observations']),
      status: serializer.fromJson<String>(json['status']),
      createdBy: serializer.fromJson<int>(json['createdBy']),
      crewId: serializer.fromJson<int?>(json['crewId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
      closedAt: serializer.fromJson<DateTime?>(json['closedAt']),
      cancelledAt: serializer.fromJson<DateTime?>(json['cancelledAt']),
      cachedAt: serializer.fromJson<DateTime>(json['cachedAt']),
      rawJson: serializer.fromJson<String>(json['rawJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'noveltyId': serializer.toJson<int>(noveltyId),
      'areaId': serializer.toJson<int>(areaId),
      'reason': serializer.toJson<String>(reason),
      'accountNumber': serializer.toJson<String>(accountNumber),
      'meterNumber': serializer.toJson<String>(meterNumber),
      'activeReading': serializer.toJson<double>(activeReading),
      'reactiveReading': serializer.toJson<double>(reactiveReading),
      'municipality': serializer.toJson<String>(municipality),
      'address': serializer.toJson<String>(address),
      'description': serializer.toJson<String>(description),
      'observations': serializer.toJson<String?>(observations),
      'status': serializer.toJson<String>(status),
      'createdBy': serializer.toJson<int>(createdBy),
      'crewId': serializer.toJson<int?>(crewId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
      'closedAt': serializer.toJson<DateTime?>(closedAt),
      'cancelledAt': serializer.toJson<DateTime?>(cancelledAt),
      'cachedAt': serializer.toJson<DateTime>(cachedAt),
      'rawJson': serializer.toJson<String>(rawJson),
    };
  }

  NoveltyCacheTableData copyWith(
          {int? noveltyId,
          int? areaId,
          String? reason,
          String? accountNumber,
          String? meterNumber,
          double? activeReading,
          double? reactiveReading,
          String? municipality,
          String? address,
          String? description,
          Value<String?> observations = const Value.absent(),
          String? status,
          int? createdBy,
          Value<int?> crewId = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt,
          Value<DateTime?> completedAt = const Value.absent(),
          Value<DateTime?> closedAt = const Value.absent(),
          Value<DateTime?> cancelledAt = const Value.absent(),
          DateTime? cachedAt,
          String? rawJson}) =>
      NoveltyCacheTableData(
        noveltyId: noveltyId ?? this.noveltyId,
        areaId: areaId ?? this.areaId,
        reason: reason ?? this.reason,
        accountNumber: accountNumber ?? this.accountNumber,
        meterNumber: meterNumber ?? this.meterNumber,
        activeReading: activeReading ?? this.activeReading,
        reactiveReading: reactiveReading ?? this.reactiveReading,
        municipality: municipality ?? this.municipality,
        address: address ?? this.address,
        description: description ?? this.description,
        observations:
            observations.present ? observations.value : this.observations,
        status: status ?? this.status,
        createdBy: createdBy ?? this.createdBy,
        crewId: crewId.present ? crewId.value : this.crewId,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        completedAt: completedAt.present ? completedAt.value : this.completedAt,
        closedAt: closedAt.present ? closedAt.value : this.closedAt,
        cancelledAt: cancelledAt.present ? cancelledAt.value : this.cancelledAt,
        cachedAt: cachedAt ?? this.cachedAt,
        rawJson: rawJson ?? this.rawJson,
      );
  NoveltyCacheTableData copyWithCompanion(NoveltyCacheTableCompanion data) {
    return NoveltyCacheTableData(
      noveltyId: data.noveltyId.present ? data.noveltyId.value : this.noveltyId,
      areaId: data.areaId.present ? data.areaId.value : this.areaId,
      reason: data.reason.present ? data.reason.value : this.reason,
      accountNumber: data.accountNumber.present
          ? data.accountNumber.value
          : this.accountNumber,
      meterNumber:
          data.meterNumber.present ? data.meterNumber.value : this.meterNumber,
      activeReading: data.activeReading.present
          ? data.activeReading.value
          : this.activeReading,
      reactiveReading: data.reactiveReading.present
          ? data.reactiveReading.value
          : this.reactiveReading,
      municipality: data.municipality.present
          ? data.municipality.value
          : this.municipality,
      address: data.address.present ? data.address.value : this.address,
      description:
          data.description.present ? data.description.value : this.description,
      observations: data.observations.present
          ? data.observations.value
          : this.observations,
      status: data.status.present ? data.status.value : this.status,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      crewId: data.crewId.present ? data.crewId.value : this.crewId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      completedAt:
          data.completedAt.present ? data.completedAt.value : this.completedAt,
      closedAt: data.closedAt.present ? data.closedAt.value : this.closedAt,
      cancelledAt:
          data.cancelledAt.present ? data.cancelledAt.value : this.cancelledAt,
      cachedAt: data.cachedAt.present ? data.cachedAt.value : this.cachedAt,
      rawJson: data.rawJson.present ? data.rawJson.value : this.rawJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NoveltyCacheTableData(')
          ..write('noveltyId: $noveltyId, ')
          ..write('areaId: $areaId, ')
          ..write('reason: $reason, ')
          ..write('accountNumber: $accountNumber, ')
          ..write('meterNumber: $meterNumber, ')
          ..write('activeReading: $activeReading, ')
          ..write('reactiveReading: $reactiveReading, ')
          ..write('municipality: $municipality, ')
          ..write('address: $address, ')
          ..write('description: $description, ')
          ..write('observations: $observations, ')
          ..write('status: $status, ')
          ..write('createdBy: $createdBy, ')
          ..write('crewId: $crewId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('closedAt: $closedAt, ')
          ..write('cancelledAt: $cancelledAt, ')
          ..write('cachedAt: $cachedAt, ')
          ..write('rawJson: $rawJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
        noveltyId,
        areaId,
        reason,
        accountNumber,
        meterNumber,
        activeReading,
        reactiveReading,
        municipality,
        address,
        description,
        observations,
        status,
        createdBy,
        crewId,
        createdAt,
        updatedAt,
        completedAt,
        closedAt,
        cancelledAt,
        cachedAt,
        rawJson
      ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NoveltyCacheTableData &&
          other.noveltyId == this.noveltyId &&
          other.areaId == this.areaId &&
          other.reason == this.reason &&
          other.accountNumber == this.accountNumber &&
          other.meterNumber == this.meterNumber &&
          other.activeReading == this.activeReading &&
          other.reactiveReading == this.reactiveReading &&
          other.municipality == this.municipality &&
          other.address == this.address &&
          other.description == this.description &&
          other.observations == this.observations &&
          other.status == this.status &&
          other.createdBy == this.createdBy &&
          other.crewId == this.crewId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.completedAt == this.completedAt &&
          other.closedAt == this.closedAt &&
          other.cancelledAt == this.cancelledAt &&
          other.cachedAt == this.cachedAt &&
          other.rawJson == this.rawJson);
}

class NoveltyCacheTableCompanion
    extends UpdateCompanion<NoveltyCacheTableData> {
  final Value<int> noveltyId;
  final Value<int> areaId;
  final Value<String> reason;
  final Value<String> accountNumber;
  final Value<String> meterNumber;
  final Value<double> activeReading;
  final Value<double> reactiveReading;
  final Value<String> municipality;
  final Value<String> address;
  final Value<String> description;
  final Value<String?> observations;
  final Value<String> status;
  final Value<int> createdBy;
  final Value<int?> crewId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> completedAt;
  final Value<DateTime?> closedAt;
  final Value<DateTime?> cancelledAt;
  final Value<DateTime> cachedAt;
  final Value<String> rawJson;
  const NoveltyCacheTableCompanion({
    this.noveltyId = const Value.absent(),
    this.areaId = const Value.absent(),
    this.reason = const Value.absent(),
    this.accountNumber = const Value.absent(),
    this.meterNumber = const Value.absent(),
    this.activeReading = const Value.absent(),
    this.reactiveReading = const Value.absent(),
    this.municipality = const Value.absent(),
    this.address = const Value.absent(),
    this.description = const Value.absent(),
    this.observations = const Value.absent(),
    this.status = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.crewId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.closedAt = const Value.absent(),
    this.cancelledAt = const Value.absent(),
    this.cachedAt = const Value.absent(),
    this.rawJson = const Value.absent(),
  });
  NoveltyCacheTableCompanion.insert({
    this.noveltyId = const Value.absent(),
    required int areaId,
    required String reason,
    required String accountNumber,
    required String meterNumber,
    required double activeReading,
    required double reactiveReading,
    required String municipality,
    required String address,
    required String description,
    this.observations = const Value.absent(),
    required String status,
    required int createdBy,
    this.crewId = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.completedAt = const Value.absent(),
    this.closedAt = const Value.absent(),
    this.cancelledAt = const Value.absent(),
    required DateTime cachedAt,
    required String rawJson,
  })  : areaId = Value(areaId),
        reason = Value(reason),
        accountNumber = Value(accountNumber),
        meterNumber = Value(meterNumber),
        activeReading = Value(activeReading),
        reactiveReading = Value(reactiveReading),
        municipality = Value(municipality),
        address = Value(address),
        description = Value(description),
        status = Value(status),
        createdBy = Value(createdBy),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt),
        cachedAt = Value(cachedAt),
        rawJson = Value(rawJson);
  static Insertable<NoveltyCacheTableData> custom({
    Expression<int>? noveltyId,
    Expression<int>? areaId,
    Expression<String>? reason,
    Expression<String>? accountNumber,
    Expression<String>? meterNumber,
    Expression<double>? activeReading,
    Expression<double>? reactiveReading,
    Expression<String>? municipality,
    Expression<String>? address,
    Expression<String>? description,
    Expression<String>? observations,
    Expression<String>? status,
    Expression<int>? createdBy,
    Expression<int>? crewId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? completedAt,
    Expression<DateTime>? closedAt,
    Expression<DateTime>? cancelledAt,
    Expression<DateTime>? cachedAt,
    Expression<String>? rawJson,
  }) {
    return RawValuesInsertable({
      if (noveltyId != null) 'novelty_id': noveltyId,
      if (areaId != null) 'area_id': areaId,
      if (reason != null) 'reason': reason,
      if (accountNumber != null) 'account_number': accountNumber,
      if (meterNumber != null) 'meter_number': meterNumber,
      if (activeReading != null) 'active_reading': activeReading,
      if (reactiveReading != null) 'reactive_reading': reactiveReading,
      if (municipality != null) 'municipality': municipality,
      if (address != null) 'address': address,
      if (description != null) 'description': description,
      if (observations != null) 'observations': observations,
      if (status != null) 'status': status,
      if (createdBy != null) 'created_by': createdBy,
      if (crewId != null) 'crew_id': crewId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (completedAt != null) 'completed_at': completedAt,
      if (closedAt != null) 'closed_at': closedAt,
      if (cancelledAt != null) 'cancelled_at': cancelledAt,
      if (cachedAt != null) 'cached_at': cachedAt,
      if (rawJson != null) 'raw_json': rawJson,
    });
  }

  NoveltyCacheTableCompanion copyWith(
      {Value<int>? noveltyId,
      Value<int>? areaId,
      Value<String>? reason,
      Value<String>? accountNumber,
      Value<String>? meterNumber,
      Value<double>? activeReading,
      Value<double>? reactiveReading,
      Value<String>? municipality,
      Value<String>? address,
      Value<String>? description,
      Value<String?>? observations,
      Value<String>? status,
      Value<int>? createdBy,
      Value<int?>? crewId,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<DateTime?>? completedAt,
      Value<DateTime?>? closedAt,
      Value<DateTime?>? cancelledAt,
      Value<DateTime>? cachedAt,
      Value<String>? rawJson}) {
    return NoveltyCacheTableCompanion(
      noveltyId: noveltyId ?? this.noveltyId,
      areaId: areaId ?? this.areaId,
      reason: reason ?? this.reason,
      accountNumber: accountNumber ?? this.accountNumber,
      meterNumber: meterNumber ?? this.meterNumber,
      activeReading: activeReading ?? this.activeReading,
      reactiveReading: reactiveReading ?? this.reactiveReading,
      municipality: municipality ?? this.municipality,
      address: address ?? this.address,
      description: description ?? this.description,
      observations: observations ?? this.observations,
      status: status ?? this.status,
      createdBy: createdBy ?? this.createdBy,
      crewId: crewId ?? this.crewId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      completedAt: completedAt ?? this.completedAt,
      closedAt: closedAt ?? this.closedAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      cachedAt: cachedAt ?? this.cachedAt,
      rawJson: rawJson ?? this.rawJson,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (noveltyId.present) {
      map['novelty_id'] = Variable<int>(noveltyId.value);
    }
    if (areaId.present) {
      map['area_id'] = Variable<int>(areaId.value);
    }
    if (reason.present) {
      map['reason'] = Variable<String>(reason.value);
    }
    if (accountNumber.present) {
      map['account_number'] = Variable<String>(accountNumber.value);
    }
    if (meterNumber.present) {
      map['meter_number'] = Variable<String>(meterNumber.value);
    }
    if (activeReading.present) {
      map['active_reading'] = Variable<double>(activeReading.value);
    }
    if (reactiveReading.present) {
      map['reactive_reading'] = Variable<double>(reactiveReading.value);
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
    if (observations.present) {
      map['observations'] = Variable<String>(observations.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<int>(createdBy.value);
    }
    if (crewId.present) {
      map['crew_id'] = Variable<int>(crewId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (closedAt.present) {
      map['closed_at'] = Variable<DateTime>(closedAt.value);
    }
    if (cancelledAt.present) {
      map['cancelled_at'] = Variable<DateTime>(cancelledAt.value);
    }
    if (cachedAt.present) {
      map['cached_at'] = Variable<DateTime>(cachedAt.value);
    }
    if (rawJson.present) {
      map['raw_json'] = Variable<String>(rawJson.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NoveltyCacheTableCompanion(')
          ..write('noveltyId: $noveltyId, ')
          ..write('areaId: $areaId, ')
          ..write('reason: $reason, ')
          ..write('accountNumber: $accountNumber, ')
          ..write('meterNumber: $meterNumber, ')
          ..write('activeReading: $activeReading, ')
          ..write('reactiveReading: $reactiveReading, ')
          ..write('municipality: $municipality, ')
          ..write('address: $address, ')
          ..write('description: $description, ')
          ..write('observations: $observations, ')
          ..write('status: $status, ')
          ..write('createdBy: $createdBy, ')
          ..write('crewId: $crewId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('closedAt: $closedAt, ')
          ..write('cancelledAt: $cancelledAt, ')
          ..write('cachedAt: $cachedAt, ')
          ..write('rawJson: $rawJson')
          ..write(')'))
        .toString();
  }
}

class $CrewCacheTableTable extends CrewCacheTable
    with TableInfo<$CrewCacheTableTable, CrewCacheTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CrewCacheTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _crewIdMeta = const VerificationMeta('crewId');
  @override
  late final GeneratedColumn<int> crewId = GeneratedColumn<int>(
      'crew_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdByMeta =
      const VerificationMeta('createdBy');
  @override
  late final GeneratedColumn<int> createdBy = GeneratedColumn<int>(
      'created_by', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _activeMemberCountMeta =
      const VerificationMeta('activeMemberCount');
  @override
  late final GeneratedColumn<int> activeMemberCount = GeneratedColumn<int>(
      'active_member_count', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _hasActiveAssignmentsMeta =
      const VerificationMeta('hasActiveAssignments');
  @override
  late final GeneratedColumn<bool> hasActiveAssignments = GeneratedColumn<bool>(
      'has_active_assignments', aliasedName, true,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("has_active_assignments" IN (0, 1))'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _cachedAtMeta =
      const VerificationMeta('cachedAt');
  @override
  late final GeneratedColumn<DateTime> cachedAt = GeneratedColumn<DateTime>(
      'cached_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _rawJsonMeta =
      const VerificationMeta('rawJson');
  @override
  late final GeneratedColumn<String> rawJson = GeneratedColumn<String>(
      'raw_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        crewId,
        name,
        description,
        status,
        createdBy,
        activeMemberCount,
        hasActiveAssignments,
        createdAt,
        updatedAt,
        deletedAt,
        cachedAt,
        rawJson
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'crew_cache';
  @override
  VerificationContext validateIntegrity(Insertable<CrewCacheTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('crew_id')) {
      context.handle(_crewIdMeta,
          crewId.isAcceptableOrUnknown(data['crew_id']!, _crewIdMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('created_by')) {
      context.handle(_createdByMeta,
          createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta));
    } else if (isInserting) {
      context.missing(_createdByMeta);
    }
    if (data.containsKey('active_member_count')) {
      context.handle(
          _activeMemberCountMeta,
          activeMemberCount.isAcceptableOrUnknown(
              data['active_member_count']!, _activeMemberCountMeta));
    }
    if (data.containsKey('has_active_assignments')) {
      context.handle(
          _hasActiveAssignmentsMeta,
          hasActiveAssignments.isAcceptableOrUnknown(
              data['has_active_assignments']!, _hasActiveAssignmentsMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    if (data.containsKey('cached_at')) {
      context.handle(_cachedAtMeta,
          cachedAt.isAcceptableOrUnknown(data['cached_at']!, _cachedAtMeta));
    } else if (isInserting) {
      context.missing(_cachedAtMeta);
    }
    if (data.containsKey('raw_json')) {
      context.handle(_rawJsonMeta,
          rawJson.isAcceptableOrUnknown(data['raw_json']!, _rawJsonMeta));
    } else if (isInserting) {
      context.missing(_rawJsonMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {crewId};
  @override
  CrewCacheTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CrewCacheTableData(
      crewId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}crew_id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      createdBy: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_by'])!,
      activeMemberCount: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}active_member_count']),
      hasActiveAssignments: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}has_active_assignments']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deleted_at']),
      cachedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}cached_at'])!,
      rawJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}raw_json'])!,
    );
  }

  @override
  $CrewCacheTableTable createAlias(String alias) {
    return $CrewCacheTableTable(attachedDatabase, alias);
  }
}

class CrewCacheTableData extends DataClass
    implements Insertable<CrewCacheTableData> {
  /// ID de la cuadrilla (clave primaria, del servidor)
  final int crewId;

  /// Nombre de la cuadrilla
  final String name;

  /// Descripción
  final String description;

  /// Estado (ACTIVA, INACTIVA, etc.)
  final String status;

  /// ID del usuario que creó la cuadrilla
  final int createdBy;

  /// Cantidad de miembros activos
  final int? activeMemberCount;

  /// Tiene asignaciones activas
  final bool? hasActiveAssignments;

  /// Fecha de creación en el servidor
  final DateTime createdAt;

  /// Fecha de última actualización en el servidor
  final DateTime updatedAt;

  /// Fecha de eliminación (opcional)
  final DateTime? deletedAt;

  /// Fecha de almacenamiento en cache
  final DateTime cachedAt;

  /// Datos JSON completos para información adicional (miembros, etc.)
  final String rawJson;
  const CrewCacheTableData(
      {required this.crewId,
      required this.name,
      required this.description,
      required this.status,
      required this.createdBy,
      this.activeMemberCount,
      this.hasActiveAssignments,
      required this.createdAt,
      required this.updatedAt,
      this.deletedAt,
      required this.cachedAt,
      required this.rawJson});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['crew_id'] = Variable<int>(crewId);
    map['name'] = Variable<String>(name);
    map['description'] = Variable<String>(description);
    map['status'] = Variable<String>(status);
    map['created_by'] = Variable<int>(createdBy);
    if (!nullToAbsent || activeMemberCount != null) {
      map['active_member_count'] = Variable<int>(activeMemberCount);
    }
    if (!nullToAbsent || hasActiveAssignments != null) {
      map['has_active_assignments'] = Variable<bool>(hasActiveAssignments);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['cached_at'] = Variable<DateTime>(cachedAt);
    map['raw_json'] = Variable<String>(rawJson);
    return map;
  }

  CrewCacheTableCompanion toCompanion(bool nullToAbsent) {
    return CrewCacheTableCompanion(
      crewId: Value(crewId),
      name: Value(name),
      description: Value(description),
      status: Value(status),
      createdBy: Value(createdBy),
      activeMemberCount: activeMemberCount == null && nullToAbsent
          ? const Value.absent()
          : Value(activeMemberCount),
      hasActiveAssignments: hasActiveAssignments == null && nullToAbsent
          ? const Value.absent()
          : Value(hasActiveAssignments),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      cachedAt: Value(cachedAt),
      rawJson: Value(rawJson),
    );
  }

  factory CrewCacheTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CrewCacheTableData(
      crewId: serializer.fromJson<int>(json['crewId']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String>(json['description']),
      status: serializer.fromJson<String>(json['status']),
      createdBy: serializer.fromJson<int>(json['createdBy']),
      activeMemberCount: serializer.fromJson<int?>(json['activeMemberCount']),
      hasActiveAssignments:
          serializer.fromJson<bool?>(json['hasActiveAssignments']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      cachedAt: serializer.fromJson<DateTime>(json['cachedAt']),
      rawJson: serializer.fromJson<String>(json['rawJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'crewId': serializer.toJson<int>(crewId),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String>(description),
      'status': serializer.toJson<String>(status),
      'createdBy': serializer.toJson<int>(createdBy),
      'activeMemberCount': serializer.toJson<int?>(activeMemberCount),
      'hasActiveAssignments': serializer.toJson<bool?>(hasActiveAssignments),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'cachedAt': serializer.toJson<DateTime>(cachedAt),
      'rawJson': serializer.toJson<String>(rawJson),
    };
  }

  CrewCacheTableData copyWith(
          {int? crewId,
          String? name,
          String? description,
          String? status,
          int? createdBy,
          Value<int?> activeMemberCount = const Value.absent(),
          Value<bool?> hasActiveAssignments = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt,
          Value<DateTime?> deletedAt = const Value.absent(),
          DateTime? cachedAt,
          String? rawJson}) =>
      CrewCacheTableData(
        crewId: crewId ?? this.crewId,
        name: name ?? this.name,
        description: description ?? this.description,
        status: status ?? this.status,
        createdBy: createdBy ?? this.createdBy,
        activeMemberCount: activeMemberCount.present
            ? activeMemberCount.value
            : this.activeMemberCount,
        hasActiveAssignments: hasActiveAssignments.present
            ? hasActiveAssignments.value
            : this.hasActiveAssignments,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
        cachedAt: cachedAt ?? this.cachedAt,
        rawJson: rawJson ?? this.rawJson,
      );
  CrewCacheTableData copyWithCompanion(CrewCacheTableCompanion data) {
    return CrewCacheTableData(
      crewId: data.crewId.present ? data.crewId.value : this.crewId,
      name: data.name.present ? data.name.value : this.name,
      description:
          data.description.present ? data.description.value : this.description,
      status: data.status.present ? data.status.value : this.status,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      activeMemberCount: data.activeMemberCount.present
          ? data.activeMemberCount.value
          : this.activeMemberCount,
      hasActiveAssignments: data.hasActiveAssignments.present
          ? data.hasActiveAssignments.value
          : this.hasActiveAssignments,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      cachedAt: data.cachedAt.present ? data.cachedAt.value : this.cachedAt,
      rawJson: data.rawJson.present ? data.rawJson.value : this.rawJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CrewCacheTableData(')
          ..write('crewId: $crewId, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('status: $status, ')
          ..write('createdBy: $createdBy, ')
          ..write('activeMemberCount: $activeMemberCount, ')
          ..write('hasActiveAssignments: $hasActiveAssignments, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('cachedAt: $cachedAt, ')
          ..write('rawJson: $rawJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      crewId,
      name,
      description,
      status,
      createdBy,
      activeMemberCount,
      hasActiveAssignments,
      createdAt,
      updatedAt,
      deletedAt,
      cachedAt,
      rawJson);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CrewCacheTableData &&
          other.crewId == this.crewId &&
          other.name == this.name &&
          other.description == this.description &&
          other.status == this.status &&
          other.createdBy == this.createdBy &&
          other.activeMemberCount == this.activeMemberCount &&
          other.hasActiveAssignments == this.hasActiveAssignments &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.cachedAt == this.cachedAt &&
          other.rawJson == this.rawJson);
}

class CrewCacheTableCompanion extends UpdateCompanion<CrewCacheTableData> {
  final Value<int> crewId;
  final Value<String> name;
  final Value<String> description;
  final Value<String> status;
  final Value<int> createdBy;
  final Value<int?> activeMemberCount;
  final Value<bool?> hasActiveAssignments;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<DateTime> cachedAt;
  final Value<String> rawJson;
  const CrewCacheTableCompanion({
    this.crewId = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.status = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.activeMemberCount = const Value.absent(),
    this.hasActiveAssignments = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.cachedAt = const Value.absent(),
    this.rawJson = const Value.absent(),
  });
  CrewCacheTableCompanion.insert({
    this.crewId = const Value.absent(),
    required String name,
    required String description,
    required String status,
    required int createdBy,
    this.activeMemberCount = const Value.absent(),
    this.hasActiveAssignments = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    required DateTime cachedAt,
    required String rawJson,
  })  : name = Value(name),
        description = Value(description),
        status = Value(status),
        createdBy = Value(createdBy),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt),
        cachedAt = Value(cachedAt),
        rawJson = Value(rawJson);
  static Insertable<CrewCacheTableData> custom({
    Expression<int>? crewId,
    Expression<String>? name,
    Expression<String>? description,
    Expression<String>? status,
    Expression<int>? createdBy,
    Expression<int>? activeMemberCount,
    Expression<bool>? hasActiveAssignments,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<DateTime>? cachedAt,
    Expression<String>? rawJson,
  }) {
    return RawValuesInsertable({
      if (crewId != null) 'crew_id': crewId,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (status != null) 'status': status,
      if (createdBy != null) 'created_by': createdBy,
      if (activeMemberCount != null) 'active_member_count': activeMemberCount,
      if (hasActiveAssignments != null)
        'has_active_assignments': hasActiveAssignments,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (cachedAt != null) 'cached_at': cachedAt,
      if (rawJson != null) 'raw_json': rawJson,
    });
  }

  CrewCacheTableCompanion copyWith(
      {Value<int>? crewId,
      Value<String>? name,
      Value<String>? description,
      Value<String>? status,
      Value<int>? createdBy,
      Value<int?>? activeMemberCount,
      Value<bool?>? hasActiveAssignments,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<DateTime?>? deletedAt,
      Value<DateTime>? cachedAt,
      Value<String>? rawJson}) {
    return CrewCacheTableCompanion(
      crewId: crewId ?? this.crewId,
      name: name ?? this.name,
      description: description ?? this.description,
      status: status ?? this.status,
      createdBy: createdBy ?? this.createdBy,
      activeMemberCount: activeMemberCount ?? this.activeMemberCount,
      hasActiveAssignments: hasActiveAssignments ?? this.hasActiveAssignments,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      cachedAt: cachedAt ?? this.cachedAt,
      rawJson: rawJson ?? this.rawJson,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (crewId.present) {
      map['crew_id'] = Variable<int>(crewId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<int>(createdBy.value);
    }
    if (activeMemberCount.present) {
      map['active_member_count'] = Variable<int>(activeMemberCount.value);
    }
    if (hasActiveAssignments.present) {
      map['has_active_assignments'] =
          Variable<bool>(hasActiveAssignments.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (cachedAt.present) {
      map['cached_at'] = Variable<DateTime>(cachedAt.value);
    }
    if (rawJson.present) {
      map['raw_json'] = Variable<String>(rawJson.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CrewCacheTableCompanion(')
          ..write('crewId: $crewId, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('status: $status, ')
          ..write('createdBy: $createdBy, ')
          ..write('activeMemberCount: $activeMemberCount, ')
          ..write('hasActiveAssignments: $hasActiveAssignments, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('cachedAt: $cachedAt, ')
          ..write('rawJson: $rawJson')
          ..write(')'))
        .toString();
  }
}

class $ReportTableTable extends ReportTable
    with TableInfo<$ReportTableTable, ReportTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReportTableTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _noveltyIdMeta =
      const VerificationMeta('noveltyId');
  @override
  late final GeneratedColumn<int> noveltyId = GeneratedColumn<int>(
      'novelty_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _workDescriptionMeta =
      const VerificationMeta('workDescription');
  @override
  late final GeneratedColumn<String> workDescription = GeneratedColumn<String>(
      'work_description', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _observationsMeta =
      const VerificationMeta('observations');
  @override
  late final GeneratedColumn<String> observations = GeneratedColumn<String>(
      'observations', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _workTimeMeta =
      const VerificationMeta('workTime');
  @override
  late final GeneratedColumn<int> workTime = GeneratedColumn<int>(
      'work_time', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _workStartDateMeta =
      const VerificationMeta('workStartDate');
  @override
  late final GeneratedColumn<DateTime> workStartDate =
      GeneratedColumn<DateTime>('work_start_date', aliasedName, false,
          type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _workEndDateMeta =
      const VerificationMeta('workEndDate');
  @override
  late final GeneratedColumn<DateTime> workEndDate = GeneratedColumn<DateTime>(
      'work_end_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _participantIdsMeta =
      const VerificationMeta('participantIds');
  @override
  late final GeneratedColumn<String> participantIds = GeneratedColumn<String>(
      'participant_ids', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _resolutionStatusMeta =
      const VerificationMeta('resolutionStatus');
  @override
  late final GeneratedColumn<String> resolutionStatus = GeneratedColumn<String>(
      'resolution_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('COMPLETADO'));
  static const VerificationMeta _latitudeMeta =
      const VerificationMeta('latitude');
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
      'latitude', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _longitudeMeta =
      const VerificationMeta('longitude');
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
      'longitude', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _accuracyMeta =
      const VerificationMeta('accuracy');
  @override
  late final GeneratedColumn<double> accuracy = GeneratedColumn<double>(
      'accuracy', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _isSyncedMeta =
      const VerificationMeta('isSynced');
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
      'is_synced', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_synced" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _syncedAtMeta =
      const VerificationMeta('syncedAt');
  @override
  late final GeneratedColumn<DateTime> syncedAt = GeneratedColumn<DateTime>(
      'synced_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _lastSyncAttemptMeta =
      const VerificationMeta('lastSyncAttempt');
  @override
  late final GeneratedColumn<DateTime> lastSyncAttempt =
      GeneratedColumn<DateTime>('last_sync_attempt', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _syncAttemptsMeta =
      const VerificationMeta('syncAttempts');
  @override
  late final GeneratedColumn<int> syncAttempts = GeneratedColumn<int>(
      'sync_attempts', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _syncErrorMeta =
      const VerificationMeta('syncError');
  @override
  late final GeneratedColumn<String> syncError = GeneratedColumn<String>(
      'sync_error', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        serverId,
        noveltyId,
        workDescription,
        observations,
        workTime,
        workStartDate,
        workEndDate,
        participantIds,
        resolutionStatus,
        latitude,
        longitude,
        accuracy,
        createdAt,
        updatedAt,
        isSynced,
        syncedAt,
        lastSyncAttempt,
        syncAttempts,
        syncError
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reports';
  @override
  VerificationContext validateIntegrity(Insertable<ReportTableData> instance,
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
    if (data.containsKey('novelty_id')) {
      context.handle(_noveltyIdMeta,
          noveltyId.isAcceptableOrUnknown(data['novelty_id']!, _noveltyIdMeta));
    } else if (isInserting) {
      context.missing(_noveltyIdMeta);
    }
    if (data.containsKey('work_description')) {
      context.handle(
          _workDescriptionMeta,
          workDescription.isAcceptableOrUnknown(
              data['work_description']!, _workDescriptionMeta));
    } else if (isInserting) {
      context.missing(_workDescriptionMeta);
    }
    if (data.containsKey('observations')) {
      context.handle(
          _observationsMeta,
          observations.isAcceptableOrUnknown(
              data['observations']!, _observationsMeta));
    }
    if (data.containsKey('work_time')) {
      context.handle(_workTimeMeta,
          workTime.isAcceptableOrUnknown(data['work_time']!, _workTimeMeta));
    } else if (isInserting) {
      context.missing(_workTimeMeta);
    }
    if (data.containsKey('work_start_date')) {
      context.handle(
          _workStartDateMeta,
          workStartDate.isAcceptableOrUnknown(
              data['work_start_date']!, _workStartDateMeta));
    } else if (isInserting) {
      context.missing(_workStartDateMeta);
    }
    if (data.containsKey('work_end_date')) {
      context.handle(
          _workEndDateMeta,
          workEndDate.isAcceptableOrUnknown(
              data['work_end_date']!, _workEndDateMeta));
    } else if (isInserting) {
      context.missing(_workEndDateMeta);
    }
    if (data.containsKey('participant_ids')) {
      context.handle(
          _participantIdsMeta,
          participantIds.isAcceptableOrUnknown(
              data['participant_ids']!, _participantIdsMeta));
    } else if (isInserting) {
      context.missing(_participantIdsMeta);
    }
    if (data.containsKey('resolution_status')) {
      context.handle(
          _resolutionStatusMeta,
          resolutionStatus.isAcceptableOrUnknown(
              data['resolution_status']!, _resolutionStatusMeta));
    }
    if (data.containsKey('latitude')) {
      context.handle(_latitudeMeta,
          latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta));
    } else if (isInserting) {
      context.missing(_latitudeMeta);
    }
    if (data.containsKey('longitude')) {
      context.handle(_longitudeMeta,
          longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta));
    } else if (isInserting) {
      context.missing(_longitudeMeta);
    }
    if (data.containsKey('accuracy')) {
      context.handle(_accuracyMeta,
          accuracy.isAcceptableOrUnknown(data['accuracy']!, _accuracyMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('is_synced')) {
      context.handle(_isSyncedMeta,
          isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta));
    }
    if (data.containsKey('synced_at')) {
      context.handle(_syncedAtMeta,
          syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta));
    }
    if (data.containsKey('last_sync_attempt')) {
      context.handle(
          _lastSyncAttemptMeta,
          lastSyncAttempt.isAcceptableOrUnknown(
              data['last_sync_attempt']!, _lastSyncAttemptMeta));
    }
    if (data.containsKey('sync_attempts')) {
      context.handle(
          _syncAttemptsMeta,
          syncAttempts.isAcceptableOrUnknown(
              data['sync_attempts']!, _syncAttemptsMeta));
    }
    if (data.containsKey('sync_error')) {
      context.handle(_syncErrorMeta,
          syncError.isAcceptableOrUnknown(data['sync_error']!, _syncErrorMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReportTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReportTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      serverId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}server_id']),
      noveltyId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}novelty_id'])!,
      workDescription: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}work_description'])!,
      observations: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}observations']),
      workTime: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}work_time'])!,
      workStartDate: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}work_start_date'])!,
      workEndDate: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}work_end_date'])!,
      participantIds: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}participant_ids'])!,
      resolutionStatus: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}resolution_status'])!,
      latitude: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}latitude'])!,
      longitude: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}longitude'])!,
      accuracy: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}accuracy']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      isSynced: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_synced'])!,
      syncedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}synced_at']),
      lastSyncAttempt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_sync_attempt']),
      syncAttempts: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sync_attempts'])!,
      syncError: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_error']),
    );
  }

  @override
  $ReportTableTable createAlias(String alias) {
    return $ReportTableTable(attachedDatabase, alias);
  }
}

class ReportTableData extends DataClass implements Insertable<ReportTableData> {
  /// ID local del reporte (UUID generado localmente)
  final String id;

  /// ID del servidor (null hasta sincronizar)
  final int? serverId;

  /// ID de la novedad asociada
  final int noveltyId;

  /// Descripción del trabajo realizado
  final String workDescription;

  /// Observaciones adicionales (opcional)
  final String? observations;

  /// Tiempo de trabajo en minutos
  final int workTime;

  /// Fecha de inicio del trabajo
  final DateTime workStartDate;

  /// Fecha de fin del trabajo
  final DateTime workEndDate;

  /// IDs de participantes (JSON array)
  final String participantIds;

  /// Estado de resolución (COMPLETADO, NO_COMPLETADO)
  final String resolutionStatus;

  /// Latitud
  final double latitude;

  /// Longitud
  final double longitude;

  /// Precisión del GPS (metros)
  final double? accuracy;

  /// Fecha de creación local
  final DateTime createdAt;

  /// Fecha de última modificación local
  final DateTime updatedAt;

  /// Está sincronizado con el servidor
  final bool isSynced;

  /// Fecha de sincronización exitosa
  final DateTime? syncedAt;

  /// Último intento de sincronización
  final DateTime? lastSyncAttempt;

  /// Cantidad de intentos de sincronización
  final int syncAttempts;

  /// Error de sincronización (si existe)
  final String? syncError;
  const ReportTableData(
      {required this.id,
      this.serverId,
      required this.noveltyId,
      required this.workDescription,
      this.observations,
      required this.workTime,
      required this.workStartDate,
      required this.workEndDate,
      required this.participantIds,
      required this.resolutionStatus,
      required this.latitude,
      required this.longitude,
      this.accuracy,
      required this.createdAt,
      required this.updatedAt,
      required this.isSynced,
      this.syncedAt,
      this.lastSyncAttempt,
      required this.syncAttempts,
      this.syncError});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || serverId != null) {
      map['server_id'] = Variable<int>(serverId);
    }
    map['novelty_id'] = Variable<int>(noveltyId);
    map['work_description'] = Variable<String>(workDescription);
    if (!nullToAbsent || observations != null) {
      map['observations'] = Variable<String>(observations);
    }
    map['work_time'] = Variable<int>(workTime);
    map['work_start_date'] = Variable<DateTime>(workStartDate);
    map['work_end_date'] = Variable<DateTime>(workEndDate);
    map['participant_ids'] = Variable<String>(participantIds);
    map['resolution_status'] = Variable<String>(resolutionStatus);
    map['latitude'] = Variable<double>(latitude);
    map['longitude'] = Variable<double>(longitude);
    if (!nullToAbsent || accuracy != null) {
      map['accuracy'] = Variable<double>(accuracy);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['is_synced'] = Variable<bool>(isSynced);
    if (!nullToAbsent || syncedAt != null) {
      map['synced_at'] = Variable<DateTime>(syncedAt);
    }
    if (!nullToAbsent || lastSyncAttempt != null) {
      map['last_sync_attempt'] = Variable<DateTime>(lastSyncAttempt);
    }
    map['sync_attempts'] = Variable<int>(syncAttempts);
    if (!nullToAbsent || syncError != null) {
      map['sync_error'] = Variable<String>(syncError);
    }
    return map;
  }

  ReportTableCompanion toCompanion(bool nullToAbsent) {
    return ReportTableCompanion(
      id: Value(id),
      serverId: serverId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverId),
      noveltyId: Value(noveltyId),
      workDescription: Value(workDescription),
      observations: observations == null && nullToAbsent
          ? const Value.absent()
          : Value(observations),
      workTime: Value(workTime),
      workStartDate: Value(workStartDate),
      workEndDate: Value(workEndDate),
      participantIds: Value(participantIds),
      resolutionStatus: Value(resolutionStatus),
      latitude: Value(latitude),
      longitude: Value(longitude),
      accuracy: accuracy == null && nullToAbsent
          ? const Value.absent()
          : Value(accuracy),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isSynced: Value(isSynced),
      syncedAt: syncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(syncedAt),
      lastSyncAttempt: lastSyncAttempt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncAttempt),
      syncAttempts: Value(syncAttempts),
      syncError: syncError == null && nullToAbsent
          ? const Value.absent()
          : Value(syncError),
    );
  }

  factory ReportTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReportTableData(
      id: serializer.fromJson<String>(json['id']),
      serverId: serializer.fromJson<int?>(json['serverId']),
      noveltyId: serializer.fromJson<int>(json['noveltyId']),
      workDescription: serializer.fromJson<String>(json['workDescription']),
      observations: serializer.fromJson<String?>(json['observations']),
      workTime: serializer.fromJson<int>(json['workTime']),
      workStartDate: serializer.fromJson<DateTime>(json['workStartDate']),
      workEndDate: serializer.fromJson<DateTime>(json['workEndDate']),
      participantIds: serializer.fromJson<String>(json['participantIds']),
      resolutionStatus: serializer.fromJson<String>(json['resolutionStatus']),
      latitude: serializer.fromJson<double>(json['latitude']),
      longitude: serializer.fromJson<double>(json['longitude']),
      accuracy: serializer.fromJson<double?>(json['accuracy']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
      syncedAt: serializer.fromJson<DateTime?>(json['syncedAt']),
      lastSyncAttempt: serializer.fromJson<DateTime?>(json['lastSyncAttempt']),
      syncAttempts: serializer.fromJson<int>(json['syncAttempts']),
      syncError: serializer.fromJson<String?>(json['syncError']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'serverId': serializer.toJson<int?>(serverId),
      'noveltyId': serializer.toJson<int>(noveltyId),
      'workDescription': serializer.toJson<String>(workDescription),
      'observations': serializer.toJson<String?>(observations),
      'workTime': serializer.toJson<int>(workTime),
      'workStartDate': serializer.toJson<DateTime>(workStartDate),
      'workEndDate': serializer.toJson<DateTime>(workEndDate),
      'participantIds': serializer.toJson<String>(participantIds),
      'resolutionStatus': serializer.toJson<String>(resolutionStatus),
      'latitude': serializer.toJson<double>(latitude),
      'longitude': serializer.toJson<double>(longitude),
      'accuracy': serializer.toJson<double?>(accuracy),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'isSynced': serializer.toJson<bool>(isSynced),
      'syncedAt': serializer.toJson<DateTime?>(syncedAt),
      'lastSyncAttempt': serializer.toJson<DateTime?>(lastSyncAttempt),
      'syncAttempts': serializer.toJson<int>(syncAttempts),
      'syncError': serializer.toJson<String?>(syncError),
    };
  }

  ReportTableData copyWith(
          {String? id,
          Value<int?> serverId = const Value.absent(),
          int? noveltyId,
          String? workDescription,
          Value<String?> observations = const Value.absent(),
          int? workTime,
          DateTime? workStartDate,
          DateTime? workEndDate,
          String? participantIds,
          String? resolutionStatus,
          double? latitude,
          double? longitude,
          Value<double?> accuracy = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt,
          bool? isSynced,
          Value<DateTime?> syncedAt = const Value.absent(),
          Value<DateTime?> lastSyncAttempt = const Value.absent(),
          int? syncAttempts,
          Value<String?> syncError = const Value.absent()}) =>
      ReportTableData(
        id: id ?? this.id,
        serverId: serverId.present ? serverId.value : this.serverId,
        noveltyId: noveltyId ?? this.noveltyId,
        workDescription: workDescription ?? this.workDescription,
        observations:
            observations.present ? observations.value : this.observations,
        workTime: workTime ?? this.workTime,
        workStartDate: workStartDate ?? this.workStartDate,
        workEndDate: workEndDate ?? this.workEndDate,
        participantIds: participantIds ?? this.participantIds,
        resolutionStatus: resolutionStatus ?? this.resolutionStatus,
        latitude: latitude ?? this.latitude,
        longitude: longitude ?? this.longitude,
        accuracy: accuracy.present ? accuracy.value : this.accuracy,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        isSynced: isSynced ?? this.isSynced,
        syncedAt: syncedAt.present ? syncedAt.value : this.syncedAt,
        lastSyncAttempt: lastSyncAttempt.present
            ? lastSyncAttempt.value
            : this.lastSyncAttempt,
        syncAttempts: syncAttempts ?? this.syncAttempts,
        syncError: syncError.present ? syncError.value : this.syncError,
      );
  ReportTableData copyWithCompanion(ReportTableCompanion data) {
    return ReportTableData(
      id: data.id.present ? data.id.value : this.id,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      noveltyId: data.noveltyId.present ? data.noveltyId.value : this.noveltyId,
      workDescription: data.workDescription.present
          ? data.workDescription.value
          : this.workDescription,
      observations: data.observations.present
          ? data.observations.value
          : this.observations,
      workTime: data.workTime.present ? data.workTime.value : this.workTime,
      workStartDate: data.workStartDate.present
          ? data.workStartDate.value
          : this.workStartDate,
      workEndDate:
          data.workEndDate.present ? data.workEndDate.value : this.workEndDate,
      participantIds: data.participantIds.present
          ? data.participantIds.value
          : this.participantIds,
      resolutionStatus: data.resolutionStatus.present
          ? data.resolutionStatus.value
          : this.resolutionStatus,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      accuracy: data.accuracy.present ? data.accuracy.value : this.accuracy,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
      lastSyncAttempt: data.lastSyncAttempt.present
          ? data.lastSyncAttempt.value
          : this.lastSyncAttempt,
      syncAttempts: data.syncAttempts.present
          ? data.syncAttempts.value
          : this.syncAttempts,
      syncError: data.syncError.present ? data.syncError.value : this.syncError,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReportTableData(')
          ..write('id: $id, ')
          ..write('serverId: $serverId, ')
          ..write('noveltyId: $noveltyId, ')
          ..write('workDescription: $workDescription, ')
          ..write('observations: $observations, ')
          ..write('workTime: $workTime, ')
          ..write('workStartDate: $workStartDate, ')
          ..write('workEndDate: $workEndDate, ')
          ..write('participantIds: $participantIds, ')
          ..write('resolutionStatus: $resolutionStatus, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('accuracy: $accuracy, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isSynced: $isSynced, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('lastSyncAttempt: $lastSyncAttempt, ')
          ..write('syncAttempts: $syncAttempts, ')
          ..write('syncError: $syncError')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      serverId,
      noveltyId,
      workDescription,
      observations,
      workTime,
      workStartDate,
      workEndDate,
      participantIds,
      resolutionStatus,
      latitude,
      longitude,
      accuracy,
      createdAt,
      updatedAt,
      isSynced,
      syncedAt,
      lastSyncAttempt,
      syncAttempts,
      syncError);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReportTableData &&
          other.id == this.id &&
          other.serverId == this.serverId &&
          other.noveltyId == this.noveltyId &&
          other.workDescription == this.workDescription &&
          other.observations == this.observations &&
          other.workTime == this.workTime &&
          other.workStartDate == this.workStartDate &&
          other.workEndDate == this.workEndDate &&
          other.participantIds == this.participantIds &&
          other.resolutionStatus == this.resolutionStatus &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.accuracy == this.accuracy &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isSynced == this.isSynced &&
          other.syncedAt == this.syncedAt &&
          other.lastSyncAttempt == this.lastSyncAttempt &&
          other.syncAttempts == this.syncAttempts &&
          other.syncError == this.syncError);
}

class ReportTableCompanion extends UpdateCompanion<ReportTableData> {
  final Value<String> id;
  final Value<int?> serverId;
  final Value<int> noveltyId;
  final Value<String> workDescription;
  final Value<String?> observations;
  final Value<int> workTime;
  final Value<DateTime> workStartDate;
  final Value<DateTime> workEndDate;
  final Value<String> participantIds;
  final Value<String> resolutionStatus;
  final Value<double> latitude;
  final Value<double> longitude;
  final Value<double?> accuracy;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> isSynced;
  final Value<DateTime?> syncedAt;
  final Value<DateTime?> lastSyncAttempt;
  final Value<int> syncAttempts;
  final Value<String?> syncError;
  final Value<int> rowid;
  const ReportTableCompanion({
    this.id = const Value.absent(),
    this.serverId = const Value.absent(),
    this.noveltyId = const Value.absent(),
    this.workDescription = const Value.absent(),
    this.observations = const Value.absent(),
    this.workTime = const Value.absent(),
    this.workStartDate = const Value.absent(),
    this.workEndDate = const Value.absent(),
    this.participantIds = const Value.absent(),
    this.resolutionStatus = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.accuracy = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.lastSyncAttempt = const Value.absent(),
    this.syncAttempts = const Value.absent(),
    this.syncError = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReportTableCompanion.insert({
    required String id,
    this.serverId = const Value.absent(),
    required int noveltyId,
    required String workDescription,
    this.observations = const Value.absent(),
    required int workTime,
    required DateTime workStartDate,
    required DateTime workEndDate,
    required String participantIds,
    this.resolutionStatus = const Value.absent(),
    required double latitude,
    required double longitude,
    this.accuracy = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.isSynced = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.lastSyncAttempt = const Value.absent(),
    this.syncAttempts = const Value.absent(),
    this.syncError = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        noveltyId = Value(noveltyId),
        workDescription = Value(workDescription),
        workTime = Value(workTime),
        workStartDate = Value(workStartDate),
        workEndDate = Value(workEndDate),
        participantIds = Value(participantIds),
        latitude = Value(latitude),
        longitude = Value(longitude),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<ReportTableData> custom({
    Expression<String>? id,
    Expression<int>? serverId,
    Expression<int>? noveltyId,
    Expression<String>? workDescription,
    Expression<String>? observations,
    Expression<int>? workTime,
    Expression<DateTime>? workStartDate,
    Expression<DateTime>? workEndDate,
    Expression<String>? participantIds,
    Expression<String>? resolutionStatus,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<double>? accuracy,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isSynced,
    Expression<DateTime>? syncedAt,
    Expression<DateTime>? lastSyncAttempt,
    Expression<int>? syncAttempts,
    Expression<String>? syncError,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (serverId != null) 'server_id': serverId,
      if (noveltyId != null) 'novelty_id': noveltyId,
      if (workDescription != null) 'work_description': workDescription,
      if (observations != null) 'observations': observations,
      if (workTime != null) 'work_time': workTime,
      if (workStartDate != null) 'work_start_date': workStartDate,
      if (workEndDate != null) 'work_end_date': workEndDate,
      if (participantIds != null) 'participant_ids': participantIds,
      if (resolutionStatus != null) 'resolution_status': resolutionStatus,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (accuracy != null) 'accuracy': accuracy,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isSynced != null) 'is_synced': isSynced,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (lastSyncAttempt != null) 'last_sync_attempt': lastSyncAttempt,
      if (syncAttempts != null) 'sync_attempts': syncAttempts,
      if (syncError != null) 'sync_error': syncError,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ReportTableCompanion copyWith(
      {Value<String>? id,
      Value<int?>? serverId,
      Value<int>? noveltyId,
      Value<String>? workDescription,
      Value<String?>? observations,
      Value<int>? workTime,
      Value<DateTime>? workStartDate,
      Value<DateTime>? workEndDate,
      Value<String>? participantIds,
      Value<String>? resolutionStatus,
      Value<double>? latitude,
      Value<double>? longitude,
      Value<double?>? accuracy,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<bool>? isSynced,
      Value<DateTime?>? syncedAt,
      Value<DateTime?>? lastSyncAttempt,
      Value<int>? syncAttempts,
      Value<String?>? syncError,
      Value<int>? rowid}) {
    return ReportTableCompanion(
      id: id ?? this.id,
      serverId: serverId ?? this.serverId,
      noveltyId: noveltyId ?? this.noveltyId,
      workDescription: workDescription ?? this.workDescription,
      observations: observations ?? this.observations,
      workTime: workTime ?? this.workTime,
      workStartDate: workStartDate ?? this.workStartDate,
      workEndDate: workEndDate ?? this.workEndDate,
      participantIds: participantIds ?? this.participantIds,
      resolutionStatus: resolutionStatus ?? this.resolutionStatus,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      accuracy: accuracy ?? this.accuracy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
      syncedAt: syncedAt ?? this.syncedAt,
      lastSyncAttempt: lastSyncAttempt ?? this.lastSyncAttempt,
      syncAttempts: syncAttempts ?? this.syncAttempts,
      syncError: syncError ?? this.syncError,
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
    if (noveltyId.present) {
      map['novelty_id'] = Variable<int>(noveltyId.value);
    }
    if (workDescription.present) {
      map['work_description'] = Variable<String>(workDescription.value);
    }
    if (observations.present) {
      map['observations'] = Variable<String>(observations.value);
    }
    if (workTime.present) {
      map['work_time'] = Variable<int>(workTime.value);
    }
    if (workStartDate.present) {
      map['work_start_date'] = Variable<DateTime>(workStartDate.value);
    }
    if (workEndDate.present) {
      map['work_end_date'] = Variable<DateTime>(workEndDate.value);
    }
    if (participantIds.present) {
      map['participant_ids'] = Variable<String>(participantIds.value);
    }
    if (resolutionStatus.present) {
      map['resolution_status'] = Variable<String>(resolutionStatus.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (accuracy.present) {
      map['accuracy'] = Variable<double>(accuracy.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<DateTime>(syncedAt.value);
    }
    if (lastSyncAttempt.present) {
      map['last_sync_attempt'] = Variable<DateTime>(lastSyncAttempt.value);
    }
    if (syncAttempts.present) {
      map['sync_attempts'] = Variable<int>(syncAttempts.value);
    }
    if (syncError.present) {
      map['sync_error'] = Variable<String>(syncError.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReportTableCompanion(')
          ..write('id: $id, ')
          ..write('serverId: $serverId, ')
          ..write('noveltyId: $noveltyId, ')
          ..write('workDescription: $workDescription, ')
          ..write('observations: $observations, ')
          ..write('workTime: $workTime, ')
          ..write('workStartDate: $workStartDate, ')
          ..write('workEndDate: $workEndDate, ')
          ..write('participantIds: $participantIds, ')
          ..write('resolutionStatus: $resolutionStatus, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('accuracy: $accuracy, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isSynced: $isSynced, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('lastSyncAttempt: $lastSyncAttempt, ')
          ..write('syncAttempts: $syncAttempts, ')
          ..write('syncError: $syncError, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ReportEvidenceTableTable extends ReportEvidenceTable
    with TableInfo<$ReportEvidenceTableTable, ReportEvidenceTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReportEvidenceTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _reportIdMeta =
      const VerificationMeta('reportId');
  @override
  late final GeneratedColumn<String> reportId = GeneratedColumn<String>(
      'report_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _localPathMeta =
      const VerificationMeta('localPath');
  @override
  late final GeneratedColumn<String> localPath = GeneratedColumn<String>(
      'local_path', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _fileNameMeta =
      const VerificationMeta('fileName');
  @override
  late final GeneratedColumn<String> fileName = GeneratedColumn<String>(
      'file_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _fileSizeMeta =
      const VerificationMeta('fileSize');
  @override
  late final GeneratedColumn<int> fileSize = GeneratedColumn<int>(
      'file_size', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _mimeTypeMeta =
      const VerificationMeta('mimeType');
  @override
  late final GeneratedColumn<String> mimeType = GeneratedColumn<String>(
      'mime_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _serverUrlMeta =
      const VerificationMeta('serverUrl');
  @override
  late final GeneratedColumn<String> serverUrl = GeneratedColumn<String>(
      'server_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isUploadedMeta =
      const VerificationMeta('isUploaded');
  @override
  late final GeneratedColumn<bool> isUploaded = GeneratedColumn<bool>(
      'is_uploaded', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_uploaded" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _uploadedAtMeta =
      const VerificationMeta('uploadedAt');
  @override
  late final GeneratedColumn<DateTime> uploadedAt = GeneratedColumn<DateTime>(
      'uploaded_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        reportId,
        type,
        localPath,
        fileName,
        fileSize,
        mimeType,
        serverUrl,
        isUploaded,
        uploadedAt,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'report_evidence';
  @override
  VerificationContext validateIntegrity(
      Insertable<ReportEvidenceTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('report_id')) {
      context.handle(_reportIdMeta,
          reportId.isAcceptableOrUnknown(data['report_id']!, _reportIdMeta));
    } else if (isInserting) {
      context.missing(_reportIdMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('local_path')) {
      context.handle(_localPathMeta,
          localPath.isAcceptableOrUnknown(data['local_path']!, _localPathMeta));
    } else if (isInserting) {
      context.missing(_localPathMeta);
    }
    if (data.containsKey('file_name')) {
      context.handle(_fileNameMeta,
          fileName.isAcceptableOrUnknown(data['file_name']!, _fileNameMeta));
    } else if (isInserting) {
      context.missing(_fileNameMeta);
    }
    if (data.containsKey('file_size')) {
      context.handle(_fileSizeMeta,
          fileSize.isAcceptableOrUnknown(data['file_size']!, _fileSizeMeta));
    } else if (isInserting) {
      context.missing(_fileSizeMeta);
    }
    if (data.containsKey('mime_type')) {
      context.handle(_mimeTypeMeta,
          mimeType.isAcceptableOrUnknown(data['mime_type']!, _mimeTypeMeta));
    } else if (isInserting) {
      context.missing(_mimeTypeMeta);
    }
    if (data.containsKey('server_url')) {
      context.handle(_serverUrlMeta,
          serverUrl.isAcceptableOrUnknown(data['server_url']!, _serverUrlMeta));
    }
    if (data.containsKey('is_uploaded')) {
      context.handle(
          _isUploadedMeta,
          isUploaded.isAcceptableOrUnknown(
              data['is_uploaded']!, _isUploadedMeta));
    }
    if (data.containsKey('uploaded_at')) {
      context.handle(
          _uploadedAtMeta,
          uploadedAt.isAcceptableOrUnknown(
              data['uploaded_at']!, _uploadedAtMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReportEvidenceTableData map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReportEvidenceTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      reportId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}report_id'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      localPath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}local_path'])!,
      fileName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}file_name'])!,
      fileSize: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}file_size'])!,
      mimeType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}mime_type'])!,
      serverUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}server_url']),
      isUploaded: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_uploaded'])!,
      uploadedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}uploaded_at']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $ReportEvidenceTableTable createAlias(String alias) {
    return $ReportEvidenceTableTable(attachedDatabase, alias);
  }
}

class ReportEvidenceTableData extends DataClass
    implements Insertable<ReportEvidenceTableData> {
  /// ID de la evidencia
  final int id;

  /// ID del reporte asociado
  final String reportId;

  /// Tipo de evidencia (FOTO, VIDEO, AUDIO)
  final String type;

  /// Ruta local del archivo
  final String localPath;

  /// Nombre del archivo
  final String fileName;

  /// Tamaño del archivo en bytes
  final int fileSize;

  /// MIME type del archivo
  final String mimeType;

  /// URL del servidor (null hasta sincronizar)
  final String? serverUrl;

  /// Está subido al servidor
  final bool isUploaded;

  /// Fecha de subida al servidor
  final DateTime? uploadedAt;

  /// Fecha de creación
  final DateTime createdAt;
  const ReportEvidenceTableData(
      {required this.id,
      required this.reportId,
      required this.type,
      required this.localPath,
      required this.fileName,
      required this.fileSize,
      required this.mimeType,
      this.serverUrl,
      required this.isUploaded,
      this.uploadedAt,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['report_id'] = Variable<String>(reportId);
    map['type'] = Variable<String>(type);
    map['local_path'] = Variable<String>(localPath);
    map['file_name'] = Variable<String>(fileName);
    map['file_size'] = Variable<int>(fileSize);
    map['mime_type'] = Variable<String>(mimeType);
    if (!nullToAbsent || serverUrl != null) {
      map['server_url'] = Variable<String>(serverUrl);
    }
    map['is_uploaded'] = Variable<bool>(isUploaded);
    if (!nullToAbsent || uploadedAt != null) {
      map['uploaded_at'] = Variable<DateTime>(uploadedAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ReportEvidenceTableCompanion toCompanion(bool nullToAbsent) {
    return ReportEvidenceTableCompanion(
      id: Value(id),
      reportId: Value(reportId),
      type: Value(type),
      localPath: Value(localPath),
      fileName: Value(fileName),
      fileSize: Value(fileSize),
      mimeType: Value(mimeType),
      serverUrl: serverUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(serverUrl),
      isUploaded: Value(isUploaded),
      uploadedAt: uploadedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(uploadedAt),
      createdAt: Value(createdAt),
    );
  }

  factory ReportEvidenceTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReportEvidenceTableData(
      id: serializer.fromJson<int>(json['id']),
      reportId: serializer.fromJson<String>(json['reportId']),
      type: serializer.fromJson<String>(json['type']),
      localPath: serializer.fromJson<String>(json['localPath']),
      fileName: serializer.fromJson<String>(json['fileName']),
      fileSize: serializer.fromJson<int>(json['fileSize']),
      mimeType: serializer.fromJson<String>(json['mimeType']),
      serverUrl: serializer.fromJson<String?>(json['serverUrl']),
      isUploaded: serializer.fromJson<bool>(json['isUploaded']),
      uploadedAt: serializer.fromJson<DateTime?>(json['uploadedAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'reportId': serializer.toJson<String>(reportId),
      'type': serializer.toJson<String>(type),
      'localPath': serializer.toJson<String>(localPath),
      'fileName': serializer.toJson<String>(fileName),
      'fileSize': serializer.toJson<int>(fileSize),
      'mimeType': serializer.toJson<String>(mimeType),
      'serverUrl': serializer.toJson<String?>(serverUrl),
      'isUploaded': serializer.toJson<bool>(isUploaded),
      'uploadedAt': serializer.toJson<DateTime?>(uploadedAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  ReportEvidenceTableData copyWith(
          {int? id,
          String? reportId,
          String? type,
          String? localPath,
          String? fileName,
          int? fileSize,
          String? mimeType,
          Value<String?> serverUrl = const Value.absent(),
          bool? isUploaded,
          Value<DateTime?> uploadedAt = const Value.absent(),
          DateTime? createdAt}) =>
      ReportEvidenceTableData(
        id: id ?? this.id,
        reportId: reportId ?? this.reportId,
        type: type ?? this.type,
        localPath: localPath ?? this.localPath,
        fileName: fileName ?? this.fileName,
        fileSize: fileSize ?? this.fileSize,
        mimeType: mimeType ?? this.mimeType,
        serverUrl: serverUrl.present ? serverUrl.value : this.serverUrl,
        isUploaded: isUploaded ?? this.isUploaded,
        uploadedAt: uploadedAt.present ? uploadedAt.value : this.uploadedAt,
        createdAt: createdAt ?? this.createdAt,
      );
  ReportEvidenceTableData copyWithCompanion(ReportEvidenceTableCompanion data) {
    return ReportEvidenceTableData(
      id: data.id.present ? data.id.value : this.id,
      reportId: data.reportId.present ? data.reportId.value : this.reportId,
      type: data.type.present ? data.type.value : this.type,
      localPath: data.localPath.present ? data.localPath.value : this.localPath,
      fileName: data.fileName.present ? data.fileName.value : this.fileName,
      fileSize: data.fileSize.present ? data.fileSize.value : this.fileSize,
      mimeType: data.mimeType.present ? data.mimeType.value : this.mimeType,
      serverUrl: data.serverUrl.present ? data.serverUrl.value : this.serverUrl,
      isUploaded:
          data.isUploaded.present ? data.isUploaded.value : this.isUploaded,
      uploadedAt:
          data.uploadedAt.present ? data.uploadedAt.value : this.uploadedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReportEvidenceTableData(')
          ..write('id: $id, ')
          ..write('reportId: $reportId, ')
          ..write('type: $type, ')
          ..write('localPath: $localPath, ')
          ..write('fileName: $fileName, ')
          ..write('fileSize: $fileSize, ')
          ..write('mimeType: $mimeType, ')
          ..write('serverUrl: $serverUrl, ')
          ..write('isUploaded: $isUploaded, ')
          ..write('uploadedAt: $uploadedAt, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, reportId, type, localPath, fileName,
      fileSize, mimeType, serverUrl, isUploaded, uploadedAt, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReportEvidenceTableData &&
          other.id == this.id &&
          other.reportId == this.reportId &&
          other.type == this.type &&
          other.localPath == this.localPath &&
          other.fileName == this.fileName &&
          other.fileSize == this.fileSize &&
          other.mimeType == this.mimeType &&
          other.serverUrl == this.serverUrl &&
          other.isUploaded == this.isUploaded &&
          other.uploadedAt == this.uploadedAt &&
          other.createdAt == this.createdAt);
}

class ReportEvidenceTableCompanion
    extends UpdateCompanion<ReportEvidenceTableData> {
  final Value<int> id;
  final Value<String> reportId;
  final Value<String> type;
  final Value<String> localPath;
  final Value<String> fileName;
  final Value<int> fileSize;
  final Value<String> mimeType;
  final Value<String?> serverUrl;
  final Value<bool> isUploaded;
  final Value<DateTime?> uploadedAt;
  final Value<DateTime> createdAt;
  const ReportEvidenceTableCompanion({
    this.id = const Value.absent(),
    this.reportId = const Value.absent(),
    this.type = const Value.absent(),
    this.localPath = const Value.absent(),
    this.fileName = const Value.absent(),
    this.fileSize = const Value.absent(),
    this.mimeType = const Value.absent(),
    this.serverUrl = const Value.absent(),
    this.isUploaded = const Value.absent(),
    this.uploadedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  ReportEvidenceTableCompanion.insert({
    this.id = const Value.absent(),
    required String reportId,
    required String type,
    required String localPath,
    required String fileName,
    required int fileSize,
    required String mimeType,
    this.serverUrl = const Value.absent(),
    this.isUploaded = const Value.absent(),
    this.uploadedAt = const Value.absent(),
    required DateTime createdAt,
  })  : reportId = Value(reportId),
        type = Value(type),
        localPath = Value(localPath),
        fileName = Value(fileName),
        fileSize = Value(fileSize),
        mimeType = Value(mimeType),
        createdAt = Value(createdAt);
  static Insertable<ReportEvidenceTableData> custom({
    Expression<int>? id,
    Expression<String>? reportId,
    Expression<String>? type,
    Expression<String>? localPath,
    Expression<String>? fileName,
    Expression<int>? fileSize,
    Expression<String>? mimeType,
    Expression<String>? serverUrl,
    Expression<bool>? isUploaded,
    Expression<DateTime>? uploadedAt,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (reportId != null) 'report_id': reportId,
      if (type != null) 'type': type,
      if (localPath != null) 'local_path': localPath,
      if (fileName != null) 'file_name': fileName,
      if (fileSize != null) 'file_size': fileSize,
      if (mimeType != null) 'mime_type': mimeType,
      if (serverUrl != null) 'server_url': serverUrl,
      if (isUploaded != null) 'is_uploaded': isUploaded,
      if (uploadedAt != null) 'uploaded_at': uploadedAt,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  ReportEvidenceTableCompanion copyWith(
      {Value<int>? id,
      Value<String>? reportId,
      Value<String>? type,
      Value<String>? localPath,
      Value<String>? fileName,
      Value<int>? fileSize,
      Value<String>? mimeType,
      Value<String?>? serverUrl,
      Value<bool>? isUploaded,
      Value<DateTime?>? uploadedAt,
      Value<DateTime>? createdAt}) {
    return ReportEvidenceTableCompanion(
      id: id ?? this.id,
      reportId: reportId ?? this.reportId,
      type: type ?? this.type,
      localPath: localPath ?? this.localPath,
      fileName: fileName ?? this.fileName,
      fileSize: fileSize ?? this.fileSize,
      mimeType: mimeType ?? this.mimeType,
      serverUrl: serverUrl ?? this.serverUrl,
      isUploaded: isUploaded ?? this.isUploaded,
      uploadedAt: uploadedAt ?? this.uploadedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (reportId.present) {
      map['report_id'] = Variable<String>(reportId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (localPath.present) {
      map['local_path'] = Variable<String>(localPath.value);
    }
    if (fileName.present) {
      map['file_name'] = Variable<String>(fileName.value);
    }
    if (fileSize.present) {
      map['file_size'] = Variable<int>(fileSize.value);
    }
    if (mimeType.present) {
      map['mime_type'] = Variable<String>(mimeType.value);
    }
    if (serverUrl.present) {
      map['server_url'] = Variable<String>(serverUrl.value);
    }
    if (isUploaded.present) {
      map['is_uploaded'] = Variable<bool>(isUploaded.value);
    }
    if (uploadedAt.present) {
      map['uploaded_at'] = Variable<DateTime>(uploadedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReportEvidenceTableCompanion(')
          ..write('id: $id, ')
          ..write('reportId: $reportId, ')
          ..write('type: $type, ')
          ..write('localPath: $localPath, ')
          ..write('fileName: $fileName, ')
          ..write('fileSize: $fileSize, ')
          ..write('mimeType: $mimeType, ')
          ..write('serverUrl: $serverUrl, ')
          ..write('isUploaded: $isUploaded, ')
          ..write('uploadedAt: $uploadedAt, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $SyncQueueTableTable extends SyncQueueTable
    with TableInfo<$SyncQueueTableTable, SyncQueueTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncQueueTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _operationTypeMeta =
      const VerificationMeta('operationType');
  @override
  late final GeneratedColumn<String> operationType = GeneratedColumn<String>(
      'operation_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _resourceIdMeta =
      const VerificationMeta('resourceId');
  @override
  late final GeneratedColumn<String> resourceId = GeneratedColumn<String>(
      'resource_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _payloadMeta =
      const VerificationMeta('payload');
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
      'payload', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _retryCountMeta =
      const VerificationMeta('retryCount');
  @override
  late final GeneratedColumn<int> retryCount = GeneratedColumn<int>(
      'retry_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _lastErrorMeta =
      const VerificationMeta('lastError');
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
      'last_error', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _lastAttemptAtMeta =
      const VerificationMeta('lastAttemptAt');
  @override
  late final GeneratedColumn<DateTime> lastAttemptAt =
      GeneratedColumn<DateTime>('last_attempt_at', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _completedAtMeta =
      const VerificationMeta('completedAt');
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
      'completed_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        operationType,
        resourceId,
        payload,
        status,
        retryCount,
        lastError,
        createdAt,
        lastAttemptAt,
        completedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_queue';
  @override
  VerificationContext validateIntegrity(Insertable<SyncQueueTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('operation_type')) {
      context.handle(
          _operationTypeMeta,
          operationType.isAcceptableOrUnknown(
              data['operation_type']!, _operationTypeMeta));
    } else if (isInserting) {
      context.missing(_operationTypeMeta);
    }
    if (data.containsKey('resource_id')) {
      context.handle(
          _resourceIdMeta,
          resourceId.isAcceptableOrUnknown(
              data['resource_id']!, _resourceIdMeta));
    } else if (isInserting) {
      context.missing(_resourceIdMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(_payloadMeta,
          payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta));
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('retry_count')) {
      context.handle(
          _retryCountMeta,
          retryCount.isAcceptableOrUnknown(
              data['retry_count']!, _retryCountMeta));
    }
    if (data.containsKey('last_error')) {
      context.handle(_lastErrorMeta,
          lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('last_attempt_at')) {
      context.handle(
          _lastAttemptAtMeta,
          lastAttemptAt.isAcceptableOrUnknown(
              data['last_attempt_at']!, _lastAttemptAtMeta));
    }
    if (data.containsKey('completed_at')) {
      context.handle(
          _completedAtMeta,
          completedAt.isAcceptableOrUnknown(
              data['completed_at']!, _completedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncQueueTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncQueueTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      operationType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}operation_type'])!,
      resourceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}resource_id'])!,
      payload: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payload'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      retryCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}retry_count'])!,
      lastError: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}last_error']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      lastAttemptAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_attempt_at']),
      completedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}completed_at']),
    );
  }

  @override
  $SyncQueueTableTable createAlias(String alias) {
    return $SyncQueueTableTable(attachedDatabase, alias);
  }
}

class SyncQueueTableData extends DataClass
    implements Insertable<SyncQueueTableData> {
  /// ID de la operación
  final int id;

  /// Tipo de operación (REPORT_CREATE, REPORT_UPDATE, etc.)
  final String operationType;

  /// ID del recurso asociado (report ID, evidence ID, etc.)
  final String resourceId;

  /// Datos de la operación (JSON)
  final String payload;

  /// Estado (PENDING, COMPLETED, FAILED)
  final String status;

  /// Cantidad de reintentos
  final int retryCount;

  /// Último error
  final String? lastError;

  /// Fecha de creación de la operación
  final DateTime createdAt;

  /// Fecha de último intento
  final DateTime? lastAttemptAt;

  /// Fecha de completado
  final DateTime? completedAt;
  const SyncQueueTableData(
      {required this.id,
      required this.operationType,
      required this.resourceId,
      required this.payload,
      required this.status,
      required this.retryCount,
      this.lastError,
      required this.createdAt,
      this.lastAttemptAt,
      this.completedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['operation_type'] = Variable<String>(operationType);
    map['resource_id'] = Variable<String>(resourceId);
    map['payload'] = Variable<String>(payload);
    map['status'] = Variable<String>(status);
    map['retry_count'] = Variable<int>(retryCount);
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || lastAttemptAt != null) {
      map['last_attempt_at'] = Variable<DateTime>(lastAttemptAt);
    }
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    return map;
  }

  SyncQueueTableCompanion toCompanion(bool nullToAbsent) {
    return SyncQueueTableCompanion(
      id: Value(id),
      operationType: Value(operationType),
      resourceId: Value(resourceId),
      payload: Value(payload),
      status: Value(status),
      retryCount: Value(retryCount),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
      createdAt: Value(createdAt),
      lastAttemptAt: lastAttemptAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastAttemptAt),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
    );
  }

  factory SyncQueueTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncQueueTableData(
      id: serializer.fromJson<int>(json['id']),
      operationType: serializer.fromJson<String>(json['operationType']),
      resourceId: serializer.fromJson<String>(json['resourceId']),
      payload: serializer.fromJson<String>(json['payload']),
      status: serializer.fromJson<String>(json['status']),
      retryCount: serializer.fromJson<int>(json['retryCount']),
      lastError: serializer.fromJson<String?>(json['lastError']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      lastAttemptAt: serializer.fromJson<DateTime?>(json['lastAttemptAt']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'operationType': serializer.toJson<String>(operationType),
      'resourceId': serializer.toJson<String>(resourceId),
      'payload': serializer.toJson<String>(payload),
      'status': serializer.toJson<String>(status),
      'retryCount': serializer.toJson<int>(retryCount),
      'lastError': serializer.toJson<String?>(lastError),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'lastAttemptAt': serializer.toJson<DateTime?>(lastAttemptAt),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
    };
  }

  SyncQueueTableData copyWith(
          {int? id,
          String? operationType,
          String? resourceId,
          String? payload,
          String? status,
          int? retryCount,
          Value<String?> lastError = const Value.absent(),
          DateTime? createdAt,
          Value<DateTime?> lastAttemptAt = const Value.absent(),
          Value<DateTime?> completedAt = const Value.absent()}) =>
      SyncQueueTableData(
        id: id ?? this.id,
        operationType: operationType ?? this.operationType,
        resourceId: resourceId ?? this.resourceId,
        payload: payload ?? this.payload,
        status: status ?? this.status,
        retryCount: retryCount ?? this.retryCount,
        lastError: lastError.present ? lastError.value : this.lastError,
        createdAt: createdAt ?? this.createdAt,
        lastAttemptAt:
            lastAttemptAt.present ? lastAttemptAt.value : this.lastAttemptAt,
        completedAt: completedAt.present ? completedAt.value : this.completedAt,
      );
  SyncQueueTableData copyWithCompanion(SyncQueueTableCompanion data) {
    return SyncQueueTableData(
      id: data.id.present ? data.id.value : this.id,
      operationType: data.operationType.present
          ? data.operationType.value
          : this.operationType,
      resourceId:
          data.resourceId.present ? data.resourceId.value : this.resourceId,
      payload: data.payload.present ? data.payload.value : this.payload,
      status: data.status.present ? data.status.value : this.status,
      retryCount:
          data.retryCount.present ? data.retryCount.value : this.retryCount,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      lastAttemptAt: data.lastAttemptAt.present
          ? data.lastAttemptAt.value
          : this.lastAttemptAt,
      completedAt:
          data.completedAt.present ? data.completedAt.value : this.completedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueTableData(')
          ..write('id: $id, ')
          ..write('operationType: $operationType, ')
          ..write('resourceId: $resourceId, ')
          ..write('payload: $payload, ')
          ..write('status: $status, ')
          ..write('retryCount: $retryCount, ')
          ..write('lastError: $lastError, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastAttemptAt: $lastAttemptAt, ')
          ..write('completedAt: $completedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, operationType, resourceId, payload,
      status, retryCount, lastError, createdAt, lastAttemptAt, completedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncQueueTableData &&
          other.id == this.id &&
          other.operationType == this.operationType &&
          other.resourceId == this.resourceId &&
          other.payload == this.payload &&
          other.status == this.status &&
          other.retryCount == this.retryCount &&
          other.lastError == this.lastError &&
          other.createdAt == this.createdAt &&
          other.lastAttemptAt == this.lastAttemptAt &&
          other.completedAt == this.completedAt);
}

class SyncQueueTableCompanion extends UpdateCompanion<SyncQueueTableData> {
  final Value<int> id;
  final Value<String> operationType;
  final Value<String> resourceId;
  final Value<String> payload;
  final Value<String> status;
  final Value<int> retryCount;
  final Value<String?> lastError;
  final Value<DateTime> createdAt;
  final Value<DateTime?> lastAttemptAt;
  final Value<DateTime?> completedAt;
  const SyncQueueTableCompanion({
    this.id = const Value.absent(),
    this.operationType = const Value.absent(),
    this.resourceId = const Value.absent(),
    this.payload = const Value.absent(),
    this.status = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.lastError = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.lastAttemptAt = const Value.absent(),
    this.completedAt = const Value.absent(),
  });
  SyncQueueTableCompanion.insert({
    this.id = const Value.absent(),
    required String operationType,
    required String resourceId,
    required String payload,
    required String status,
    this.retryCount = const Value.absent(),
    this.lastError = const Value.absent(),
    required DateTime createdAt,
    this.lastAttemptAt = const Value.absent(),
    this.completedAt = const Value.absent(),
  })  : operationType = Value(operationType),
        resourceId = Value(resourceId),
        payload = Value(payload),
        status = Value(status),
        createdAt = Value(createdAt);
  static Insertable<SyncQueueTableData> custom({
    Expression<int>? id,
    Expression<String>? operationType,
    Expression<String>? resourceId,
    Expression<String>? payload,
    Expression<String>? status,
    Expression<int>? retryCount,
    Expression<String>? lastError,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? lastAttemptAt,
    Expression<DateTime>? completedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (operationType != null) 'operation_type': operationType,
      if (resourceId != null) 'resource_id': resourceId,
      if (payload != null) 'payload': payload,
      if (status != null) 'status': status,
      if (retryCount != null) 'retry_count': retryCount,
      if (lastError != null) 'last_error': lastError,
      if (createdAt != null) 'created_at': createdAt,
      if (lastAttemptAt != null) 'last_attempt_at': lastAttemptAt,
      if (completedAt != null) 'completed_at': completedAt,
    });
  }

  SyncQueueTableCompanion copyWith(
      {Value<int>? id,
      Value<String>? operationType,
      Value<String>? resourceId,
      Value<String>? payload,
      Value<String>? status,
      Value<int>? retryCount,
      Value<String?>? lastError,
      Value<DateTime>? createdAt,
      Value<DateTime?>? lastAttemptAt,
      Value<DateTime?>? completedAt}) {
    return SyncQueueTableCompanion(
      id: id ?? this.id,
      operationType: operationType ?? this.operationType,
      resourceId: resourceId ?? this.resourceId,
      payload: payload ?? this.payload,
      status: status ?? this.status,
      retryCount: retryCount ?? this.retryCount,
      lastError: lastError ?? this.lastError,
      createdAt: createdAt ?? this.createdAt,
      lastAttemptAt: lastAttemptAt ?? this.lastAttemptAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (operationType.present) {
      map['operation_type'] = Variable<String>(operationType.value);
    }
    if (resourceId.present) {
      map['resource_id'] = Variable<String>(resourceId.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (retryCount.present) {
      map['retry_count'] = Variable<int>(retryCount.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (lastAttemptAt.present) {
      map['last_attempt_at'] = Variable<DateTime>(lastAttemptAt.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueTableCompanion(')
          ..write('id: $id, ')
          ..write('operationType: $operationType, ')
          ..write('resourceId: $resourceId, ')
          ..write('payload: $payload, ')
          ..write('status: $status, ')
          ..write('retryCount: $retryCount, ')
          ..write('lastError: $lastError, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastAttemptAt: $lastAttemptAt, ')
          ..write('completedAt: $completedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $NoveltyCacheTableTable noveltyCacheTable =
      $NoveltyCacheTableTable(this);
  late final $CrewCacheTableTable crewCacheTable = $CrewCacheTableTable(this);
  late final $ReportTableTable reportTable = $ReportTableTable(this);
  late final $ReportEvidenceTableTable reportEvidenceTable =
      $ReportEvidenceTableTable(this);
  late final $SyncQueueTableTable syncQueueTable = $SyncQueueTableTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        noveltyCacheTable,
        crewCacheTable,
        reportTable,
        reportEvidenceTable,
        syncQueueTable
      ];
}

typedef $$NoveltyCacheTableTableCreateCompanionBuilder
    = NoveltyCacheTableCompanion Function({
  Value<int> noveltyId,
  required int areaId,
  required String reason,
  required String accountNumber,
  required String meterNumber,
  required double activeReading,
  required double reactiveReading,
  required String municipality,
  required String address,
  required String description,
  Value<String?> observations,
  required String status,
  required int createdBy,
  Value<int?> crewId,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<DateTime?> completedAt,
  Value<DateTime?> closedAt,
  Value<DateTime?> cancelledAt,
  required DateTime cachedAt,
  required String rawJson,
});
typedef $$NoveltyCacheTableTableUpdateCompanionBuilder
    = NoveltyCacheTableCompanion Function({
  Value<int> noveltyId,
  Value<int> areaId,
  Value<String> reason,
  Value<String> accountNumber,
  Value<String> meterNumber,
  Value<double> activeReading,
  Value<double> reactiveReading,
  Value<String> municipality,
  Value<String> address,
  Value<String> description,
  Value<String?> observations,
  Value<String> status,
  Value<int> createdBy,
  Value<int?> crewId,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> completedAt,
  Value<DateTime?> closedAt,
  Value<DateTime?> cancelledAt,
  Value<DateTime> cachedAt,
  Value<String> rawJson,
});

class $$NoveltyCacheTableTableFilterComposer
    extends Composer<_$AppDatabase, $NoveltyCacheTableTable> {
  $$NoveltyCacheTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get noveltyId => $composableBuilder(
      column: $table.noveltyId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get areaId => $composableBuilder(
      column: $table.areaId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get reason => $composableBuilder(
      column: $table.reason, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get accountNumber => $composableBuilder(
      column: $table.accountNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get meterNumber => $composableBuilder(
      column: $table.meterNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get activeReading => $composableBuilder(
      column: $table.activeReading, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get reactiveReading => $composableBuilder(
      column: $table.reactiveReading,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get municipality => $composableBuilder(
      column: $table.municipality, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get address => $composableBuilder(
      column: $table.address, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get observations => $composableBuilder(
      column: $table.observations, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdBy => $composableBuilder(
      column: $table.createdBy, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get crewId => $composableBuilder(
      column: $table.crewId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get closedAt => $composableBuilder(
      column: $table.closedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get cancelledAt => $composableBuilder(
      column: $table.cancelledAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get cachedAt => $composableBuilder(
      column: $table.cachedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get rawJson => $composableBuilder(
      column: $table.rawJson, builder: (column) => ColumnFilters(column));
}

class $$NoveltyCacheTableTableOrderingComposer
    extends Composer<_$AppDatabase, $NoveltyCacheTableTable> {
  $$NoveltyCacheTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get noveltyId => $composableBuilder(
      column: $table.noveltyId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get areaId => $composableBuilder(
      column: $table.areaId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get reason => $composableBuilder(
      column: $table.reason, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get accountNumber => $composableBuilder(
      column: $table.accountNumber,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get meterNumber => $composableBuilder(
      column: $table.meterNumber, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get activeReading => $composableBuilder(
      column: $table.activeReading,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get reactiveReading => $composableBuilder(
      column: $table.reactiveReading,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get municipality => $composableBuilder(
      column: $table.municipality,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get address => $composableBuilder(
      column: $table.address, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get observations => $composableBuilder(
      column: $table.observations,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdBy => $composableBuilder(
      column: $table.createdBy, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get crewId => $composableBuilder(
      column: $table.crewId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get closedAt => $composableBuilder(
      column: $table.closedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get cancelledAt => $composableBuilder(
      column: $table.cancelledAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get cachedAt => $composableBuilder(
      column: $table.cachedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get rawJson => $composableBuilder(
      column: $table.rawJson, builder: (column) => ColumnOrderings(column));
}

class $$NoveltyCacheTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $NoveltyCacheTableTable> {
  $$NoveltyCacheTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get noveltyId =>
      $composableBuilder(column: $table.noveltyId, builder: (column) => column);

  GeneratedColumn<int> get areaId =>
      $composableBuilder(column: $table.areaId, builder: (column) => column);

  GeneratedColumn<String> get reason =>
      $composableBuilder(column: $table.reason, builder: (column) => column);

  GeneratedColumn<String> get accountNumber => $composableBuilder(
      column: $table.accountNumber, builder: (column) => column);

  GeneratedColumn<String> get meterNumber => $composableBuilder(
      column: $table.meterNumber, builder: (column) => column);

  GeneratedColumn<double> get activeReading => $composableBuilder(
      column: $table.activeReading, builder: (column) => column);

  GeneratedColumn<double> get reactiveReading => $composableBuilder(
      column: $table.reactiveReading, builder: (column) => column);

  GeneratedColumn<String> get municipality => $composableBuilder(
      column: $table.municipality, builder: (column) => column);

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<String> get observations => $composableBuilder(
      column: $table.observations, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => column);

  GeneratedColumn<int> get crewId =>
      $composableBuilder(column: $table.crewId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get closedAt =>
      $composableBuilder(column: $table.closedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get cancelledAt => $composableBuilder(
      column: $table.cancelledAt, builder: (column) => column);

  GeneratedColumn<DateTime> get cachedAt =>
      $composableBuilder(column: $table.cachedAt, builder: (column) => column);

  GeneratedColumn<String> get rawJson =>
      $composableBuilder(column: $table.rawJson, builder: (column) => column);
}

class $$NoveltyCacheTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $NoveltyCacheTableTable,
    NoveltyCacheTableData,
    $$NoveltyCacheTableTableFilterComposer,
    $$NoveltyCacheTableTableOrderingComposer,
    $$NoveltyCacheTableTableAnnotationComposer,
    $$NoveltyCacheTableTableCreateCompanionBuilder,
    $$NoveltyCacheTableTableUpdateCompanionBuilder,
    (
      NoveltyCacheTableData,
      BaseReferences<_$AppDatabase, $NoveltyCacheTableTable,
          NoveltyCacheTableData>
    ),
    NoveltyCacheTableData,
    PrefetchHooks Function()> {
  $$NoveltyCacheTableTableTableManager(
      _$AppDatabase db, $NoveltyCacheTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NoveltyCacheTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NoveltyCacheTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NoveltyCacheTableTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> noveltyId = const Value.absent(),
            Value<int> areaId = const Value.absent(),
            Value<String> reason = const Value.absent(),
            Value<String> accountNumber = const Value.absent(),
            Value<String> meterNumber = const Value.absent(),
            Value<double> activeReading = const Value.absent(),
            Value<double> reactiveReading = const Value.absent(),
            Value<String> municipality = const Value.absent(),
            Value<String> address = const Value.absent(),
            Value<String> description = const Value.absent(),
            Value<String?> observations = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<int> createdBy = const Value.absent(),
            Value<int?> crewId = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> completedAt = const Value.absent(),
            Value<DateTime?> closedAt = const Value.absent(),
            Value<DateTime?> cancelledAt = const Value.absent(),
            Value<DateTime> cachedAt = const Value.absent(),
            Value<String> rawJson = const Value.absent(),
          }) =>
              NoveltyCacheTableCompanion(
            noveltyId: noveltyId,
            areaId: areaId,
            reason: reason,
            accountNumber: accountNumber,
            meterNumber: meterNumber,
            activeReading: activeReading,
            reactiveReading: reactiveReading,
            municipality: municipality,
            address: address,
            description: description,
            observations: observations,
            status: status,
            createdBy: createdBy,
            crewId: crewId,
            createdAt: createdAt,
            updatedAt: updatedAt,
            completedAt: completedAt,
            closedAt: closedAt,
            cancelledAt: cancelledAt,
            cachedAt: cachedAt,
            rawJson: rawJson,
          ),
          createCompanionCallback: ({
            Value<int> noveltyId = const Value.absent(),
            required int areaId,
            required String reason,
            required String accountNumber,
            required String meterNumber,
            required double activeReading,
            required double reactiveReading,
            required String municipality,
            required String address,
            required String description,
            Value<String?> observations = const Value.absent(),
            required String status,
            required int createdBy,
            Value<int?> crewId = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<DateTime?> completedAt = const Value.absent(),
            Value<DateTime?> closedAt = const Value.absent(),
            Value<DateTime?> cancelledAt = const Value.absent(),
            required DateTime cachedAt,
            required String rawJson,
          }) =>
              NoveltyCacheTableCompanion.insert(
            noveltyId: noveltyId,
            areaId: areaId,
            reason: reason,
            accountNumber: accountNumber,
            meterNumber: meterNumber,
            activeReading: activeReading,
            reactiveReading: reactiveReading,
            municipality: municipality,
            address: address,
            description: description,
            observations: observations,
            status: status,
            createdBy: createdBy,
            crewId: crewId,
            createdAt: createdAt,
            updatedAt: updatedAt,
            completedAt: completedAt,
            closedAt: closedAt,
            cancelledAt: cancelledAt,
            cachedAt: cachedAt,
            rawJson: rawJson,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$NoveltyCacheTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $NoveltyCacheTableTable,
    NoveltyCacheTableData,
    $$NoveltyCacheTableTableFilterComposer,
    $$NoveltyCacheTableTableOrderingComposer,
    $$NoveltyCacheTableTableAnnotationComposer,
    $$NoveltyCacheTableTableCreateCompanionBuilder,
    $$NoveltyCacheTableTableUpdateCompanionBuilder,
    (
      NoveltyCacheTableData,
      BaseReferences<_$AppDatabase, $NoveltyCacheTableTable,
          NoveltyCacheTableData>
    ),
    NoveltyCacheTableData,
    PrefetchHooks Function()>;
typedef $$CrewCacheTableTableCreateCompanionBuilder = CrewCacheTableCompanion
    Function({
  Value<int> crewId,
  required String name,
  required String description,
  required String status,
  required int createdBy,
  Value<int?> activeMemberCount,
  Value<bool?> hasActiveAssignments,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<DateTime?> deletedAt,
  required DateTime cachedAt,
  required String rawJson,
});
typedef $$CrewCacheTableTableUpdateCompanionBuilder = CrewCacheTableCompanion
    Function({
  Value<int> crewId,
  Value<String> name,
  Value<String> description,
  Value<String> status,
  Value<int> createdBy,
  Value<int?> activeMemberCount,
  Value<bool?> hasActiveAssignments,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<DateTime> cachedAt,
  Value<String> rawJson,
});

class $$CrewCacheTableTableFilterComposer
    extends Composer<_$AppDatabase, $CrewCacheTableTable> {
  $$CrewCacheTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get crewId => $composableBuilder(
      column: $table.crewId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdBy => $composableBuilder(
      column: $table.createdBy, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get activeMemberCount => $composableBuilder(
      column: $table.activeMemberCount,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get hasActiveAssignments => $composableBuilder(
      column: $table.hasActiveAssignments,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get cachedAt => $composableBuilder(
      column: $table.cachedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get rawJson => $composableBuilder(
      column: $table.rawJson, builder: (column) => ColumnFilters(column));
}

class $$CrewCacheTableTableOrderingComposer
    extends Composer<_$AppDatabase, $CrewCacheTableTable> {
  $$CrewCacheTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get crewId => $composableBuilder(
      column: $table.crewId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdBy => $composableBuilder(
      column: $table.createdBy, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get activeMemberCount => $composableBuilder(
      column: $table.activeMemberCount,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get hasActiveAssignments => $composableBuilder(
      column: $table.hasActiveAssignments,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get cachedAt => $composableBuilder(
      column: $table.cachedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get rawJson => $composableBuilder(
      column: $table.rawJson, builder: (column) => ColumnOrderings(column));
}

class $$CrewCacheTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $CrewCacheTableTable> {
  $$CrewCacheTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get crewId =>
      $composableBuilder(column: $table.crewId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => column);

  GeneratedColumn<int> get activeMemberCount => $composableBuilder(
      column: $table.activeMemberCount, builder: (column) => column);

  GeneratedColumn<bool> get hasActiveAssignments => $composableBuilder(
      column: $table.hasActiveAssignments, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get cachedAt =>
      $composableBuilder(column: $table.cachedAt, builder: (column) => column);

  GeneratedColumn<String> get rawJson =>
      $composableBuilder(column: $table.rawJson, builder: (column) => column);
}

class $$CrewCacheTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CrewCacheTableTable,
    CrewCacheTableData,
    $$CrewCacheTableTableFilterComposer,
    $$CrewCacheTableTableOrderingComposer,
    $$CrewCacheTableTableAnnotationComposer,
    $$CrewCacheTableTableCreateCompanionBuilder,
    $$CrewCacheTableTableUpdateCompanionBuilder,
    (
      CrewCacheTableData,
      BaseReferences<_$AppDatabase, $CrewCacheTableTable, CrewCacheTableData>
    ),
    CrewCacheTableData,
    PrefetchHooks Function()> {
  $$CrewCacheTableTableTableManager(
      _$AppDatabase db, $CrewCacheTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CrewCacheTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CrewCacheTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CrewCacheTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> crewId = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> description = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<int> createdBy = const Value.absent(),
            Value<int?> activeMemberCount = const Value.absent(),
            Value<bool?> hasActiveAssignments = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<DateTime> cachedAt = const Value.absent(),
            Value<String> rawJson = const Value.absent(),
          }) =>
              CrewCacheTableCompanion(
            crewId: crewId,
            name: name,
            description: description,
            status: status,
            createdBy: createdBy,
            activeMemberCount: activeMemberCount,
            hasActiveAssignments: hasActiveAssignments,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            cachedAt: cachedAt,
            rawJson: rawJson,
          ),
          createCompanionCallback: ({
            Value<int> crewId = const Value.absent(),
            required String name,
            required String description,
            required String status,
            required int createdBy,
            Value<int?> activeMemberCount = const Value.absent(),
            Value<bool?> hasActiveAssignments = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<DateTime?> deletedAt = const Value.absent(),
            required DateTime cachedAt,
            required String rawJson,
          }) =>
              CrewCacheTableCompanion.insert(
            crewId: crewId,
            name: name,
            description: description,
            status: status,
            createdBy: createdBy,
            activeMemberCount: activeMemberCount,
            hasActiveAssignments: hasActiveAssignments,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            cachedAt: cachedAt,
            rawJson: rawJson,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CrewCacheTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CrewCacheTableTable,
    CrewCacheTableData,
    $$CrewCacheTableTableFilterComposer,
    $$CrewCacheTableTableOrderingComposer,
    $$CrewCacheTableTableAnnotationComposer,
    $$CrewCacheTableTableCreateCompanionBuilder,
    $$CrewCacheTableTableUpdateCompanionBuilder,
    (
      CrewCacheTableData,
      BaseReferences<_$AppDatabase, $CrewCacheTableTable, CrewCacheTableData>
    ),
    CrewCacheTableData,
    PrefetchHooks Function()>;
typedef $$ReportTableTableCreateCompanionBuilder = ReportTableCompanion
    Function({
  required String id,
  Value<int?> serverId,
  required int noveltyId,
  required String workDescription,
  Value<String?> observations,
  required int workTime,
  required DateTime workStartDate,
  required DateTime workEndDate,
  required String participantIds,
  Value<String> resolutionStatus,
  required double latitude,
  required double longitude,
  Value<double?> accuracy,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<bool> isSynced,
  Value<DateTime?> syncedAt,
  Value<DateTime?> lastSyncAttempt,
  Value<int> syncAttempts,
  Value<String?> syncError,
  Value<int> rowid,
});
typedef $$ReportTableTableUpdateCompanionBuilder = ReportTableCompanion
    Function({
  Value<String> id,
  Value<int?> serverId,
  Value<int> noveltyId,
  Value<String> workDescription,
  Value<String?> observations,
  Value<int> workTime,
  Value<DateTime> workStartDate,
  Value<DateTime> workEndDate,
  Value<String> participantIds,
  Value<String> resolutionStatus,
  Value<double> latitude,
  Value<double> longitude,
  Value<double?> accuracy,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<bool> isSynced,
  Value<DateTime?> syncedAt,
  Value<DateTime?> lastSyncAttempt,
  Value<int> syncAttempts,
  Value<String?> syncError,
  Value<int> rowid,
});

class $$ReportTableTableFilterComposer
    extends Composer<_$AppDatabase, $ReportTableTable> {
  $$ReportTableTableFilterComposer({
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

  ColumnFilters<int> get noveltyId => $composableBuilder(
      column: $table.noveltyId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get workDescription => $composableBuilder(
      column: $table.workDescription,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get observations => $composableBuilder(
      column: $table.observations, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get workTime => $composableBuilder(
      column: $table.workTime, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get workStartDate => $composableBuilder(
      column: $table.workStartDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get workEndDate => $composableBuilder(
      column: $table.workEndDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get participantIds => $composableBuilder(
      column: $table.participantIds,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get resolutionStatus => $composableBuilder(
      column: $table.resolutionStatus,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get latitude => $composableBuilder(
      column: $table.latitude, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get longitude => $composableBuilder(
      column: $table.longitude, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get accuracy => $composableBuilder(
      column: $table.accuracy, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isSynced => $composableBuilder(
      column: $table.isSynced, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get syncedAt => $composableBuilder(
      column: $table.syncedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastSyncAttempt => $composableBuilder(
      column: $table.lastSyncAttempt,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get syncAttempts => $composableBuilder(
      column: $table.syncAttempts, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncError => $composableBuilder(
      column: $table.syncError, builder: (column) => ColumnFilters(column));
}

class $$ReportTableTableOrderingComposer
    extends Composer<_$AppDatabase, $ReportTableTable> {
  $$ReportTableTableOrderingComposer({
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

  ColumnOrderings<int> get noveltyId => $composableBuilder(
      column: $table.noveltyId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get workDescription => $composableBuilder(
      column: $table.workDescription,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get observations => $composableBuilder(
      column: $table.observations,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get workTime => $composableBuilder(
      column: $table.workTime, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get workStartDate => $composableBuilder(
      column: $table.workStartDate,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get workEndDate => $composableBuilder(
      column: $table.workEndDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get participantIds => $composableBuilder(
      column: $table.participantIds,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get resolutionStatus => $composableBuilder(
      column: $table.resolutionStatus,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get latitude => $composableBuilder(
      column: $table.latitude, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get longitude => $composableBuilder(
      column: $table.longitude, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get accuracy => $composableBuilder(
      column: $table.accuracy, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isSynced => $composableBuilder(
      column: $table.isSynced, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get syncedAt => $composableBuilder(
      column: $table.syncedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastSyncAttempt => $composableBuilder(
      column: $table.lastSyncAttempt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get syncAttempts => $composableBuilder(
      column: $table.syncAttempts,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncError => $composableBuilder(
      column: $table.syncError, builder: (column) => ColumnOrderings(column));
}

class $$ReportTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReportTableTable> {
  $$ReportTableTableAnnotationComposer({
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

  GeneratedColumn<int> get noveltyId =>
      $composableBuilder(column: $table.noveltyId, builder: (column) => column);

  GeneratedColumn<String> get workDescription => $composableBuilder(
      column: $table.workDescription, builder: (column) => column);

  GeneratedColumn<String> get observations => $composableBuilder(
      column: $table.observations, builder: (column) => column);

  GeneratedColumn<int> get workTime =>
      $composableBuilder(column: $table.workTime, builder: (column) => column);

  GeneratedColumn<DateTime> get workStartDate => $composableBuilder(
      column: $table.workStartDate, builder: (column) => column);

  GeneratedColumn<DateTime> get workEndDate => $composableBuilder(
      column: $table.workEndDate, builder: (column) => column);

  GeneratedColumn<String> get participantIds => $composableBuilder(
      column: $table.participantIds, builder: (column) => column);

  GeneratedColumn<String> get resolutionStatus => $composableBuilder(
      column: $table.resolutionStatus, builder: (column) => column);

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<double> get accuracy =>
      $composableBuilder(column: $table.accuracy, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);

  GeneratedColumn<DateTime> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSyncAttempt => $composableBuilder(
      column: $table.lastSyncAttempt, builder: (column) => column);

  GeneratedColumn<int> get syncAttempts => $composableBuilder(
      column: $table.syncAttempts, builder: (column) => column);

  GeneratedColumn<String> get syncError =>
      $composableBuilder(column: $table.syncError, builder: (column) => column);
}

class $$ReportTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ReportTableTable,
    ReportTableData,
    $$ReportTableTableFilterComposer,
    $$ReportTableTableOrderingComposer,
    $$ReportTableTableAnnotationComposer,
    $$ReportTableTableCreateCompanionBuilder,
    $$ReportTableTableUpdateCompanionBuilder,
    (
      ReportTableData,
      BaseReferences<_$AppDatabase, $ReportTableTable, ReportTableData>
    ),
    ReportTableData,
    PrefetchHooks Function()> {
  $$ReportTableTableTableManager(_$AppDatabase db, $ReportTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReportTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReportTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReportTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<int?> serverId = const Value.absent(),
            Value<int> noveltyId = const Value.absent(),
            Value<String> workDescription = const Value.absent(),
            Value<String?> observations = const Value.absent(),
            Value<int> workTime = const Value.absent(),
            Value<DateTime> workStartDate = const Value.absent(),
            Value<DateTime> workEndDate = const Value.absent(),
            Value<String> participantIds = const Value.absent(),
            Value<String> resolutionStatus = const Value.absent(),
            Value<double> latitude = const Value.absent(),
            Value<double> longitude = const Value.absent(),
            Value<double?> accuracy = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<bool> isSynced = const Value.absent(),
            Value<DateTime?> syncedAt = const Value.absent(),
            Value<DateTime?> lastSyncAttempt = const Value.absent(),
            Value<int> syncAttempts = const Value.absent(),
            Value<String?> syncError = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ReportTableCompanion(
            id: id,
            serverId: serverId,
            noveltyId: noveltyId,
            workDescription: workDescription,
            observations: observations,
            workTime: workTime,
            workStartDate: workStartDate,
            workEndDate: workEndDate,
            participantIds: participantIds,
            resolutionStatus: resolutionStatus,
            latitude: latitude,
            longitude: longitude,
            accuracy: accuracy,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isSynced: isSynced,
            syncedAt: syncedAt,
            lastSyncAttempt: lastSyncAttempt,
            syncAttempts: syncAttempts,
            syncError: syncError,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<int?> serverId = const Value.absent(),
            required int noveltyId,
            required String workDescription,
            Value<String?> observations = const Value.absent(),
            required int workTime,
            required DateTime workStartDate,
            required DateTime workEndDate,
            required String participantIds,
            Value<String> resolutionStatus = const Value.absent(),
            required double latitude,
            required double longitude,
            Value<double?> accuracy = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<bool> isSynced = const Value.absent(),
            Value<DateTime?> syncedAt = const Value.absent(),
            Value<DateTime?> lastSyncAttempt = const Value.absent(),
            Value<int> syncAttempts = const Value.absent(),
            Value<String?> syncError = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ReportTableCompanion.insert(
            id: id,
            serverId: serverId,
            noveltyId: noveltyId,
            workDescription: workDescription,
            observations: observations,
            workTime: workTime,
            workStartDate: workStartDate,
            workEndDate: workEndDate,
            participantIds: participantIds,
            resolutionStatus: resolutionStatus,
            latitude: latitude,
            longitude: longitude,
            accuracy: accuracy,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isSynced: isSynced,
            syncedAt: syncedAt,
            lastSyncAttempt: lastSyncAttempt,
            syncAttempts: syncAttempts,
            syncError: syncError,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ReportTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ReportTableTable,
    ReportTableData,
    $$ReportTableTableFilterComposer,
    $$ReportTableTableOrderingComposer,
    $$ReportTableTableAnnotationComposer,
    $$ReportTableTableCreateCompanionBuilder,
    $$ReportTableTableUpdateCompanionBuilder,
    (
      ReportTableData,
      BaseReferences<_$AppDatabase, $ReportTableTable, ReportTableData>
    ),
    ReportTableData,
    PrefetchHooks Function()>;
typedef $$ReportEvidenceTableTableCreateCompanionBuilder
    = ReportEvidenceTableCompanion Function({
  Value<int> id,
  required String reportId,
  required String type,
  required String localPath,
  required String fileName,
  required int fileSize,
  required String mimeType,
  Value<String?> serverUrl,
  Value<bool> isUploaded,
  Value<DateTime?> uploadedAt,
  required DateTime createdAt,
});
typedef $$ReportEvidenceTableTableUpdateCompanionBuilder
    = ReportEvidenceTableCompanion Function({
  Value<int> id,
  Value<String> reportId,
  Value<String> type,
  Value<String> localPath,
  Value<String> fileName,
  Value<int> fileSize,
  Value<String> mimeType,
  Value<String?> serverUrl,
  Value<bool> isUploaded,
  Value<DateTime?> uploadedAt,
  Value<DateTime> createdAt,
});

class $$ReportEvidenceTableTableFilterComposer
    extends Composer<_$AppDatabase, $ReportEvidenceTableTable> {
  $$ReportEvidenceTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get reportId => $composableBuilder(
      column: $table.reportId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get localPath => $composableBuilder(
      column: $table.localPath, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get fileName => $composableBuilder(
      column: $table.fileName, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get fileSize => $composableBuilder(
      column: $table.fileSize, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get mimeType => $composableBuilder(
      column: $table.mimeType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get serverUrl => $composableBuilder(
      column: $table.serverUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isUploaded => $composableBuilder(
      column: $table.isUploaded, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get uploadedAt => $composableBuilder(
      column: $table.uploadedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$ReportEvidenceTableTableOrderingComposer
    extends Composer<_$AppDatabase, $ReportEvidenceTableTable> {
  $$ReportEvidenceTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get reportId => $composableBuilder(
      column: $table.reportId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get localPath => $composableBuilder(
      column: $table.localPath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get fileName => $composableBuilder(
      column: $table.fileName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get fileSize => $composableBuilder(
      column: $table.fileSize, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get mimeType => $composableBuilder(
      column: $table.mimeType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get serverUrl => $composableBuilder(
      column: $table.serverUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isUploaded => $composableBuilder(
      column: $table.isUploaded, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get uploadedAt => $composableBuilder(
      column: $table.uploadedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$ReportEvidenceTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReportEvidenceTableTable> {
  $$ReportEvidenceTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get reportId =>
      $composableBuilder(column: $table.reportId, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get localPath =>
      $composableBuilder(column: $table.localPath, builder: (column) => column);

  GeneratedColumn<String> get fileName =>
      $composableBuilder(column: $table.fileName, builder: (column) => column);

  GeneratedColumn<int> get fileSize =>
      $composableBuilder(column: $table.fileSize, builder: (column) => column);

  GeneratedColumn<String> get mimeType =>
      $composableBuilder(column: $table.mimeType, builder: (column) => column);

  GeneratedColumn<String> get serverUrl =>
      $composableBuilder(column: $table.serverUrl, builder: (column) => column);

  GeneratedColumn<bool> get isUploaded => $composableBuilder(
      column: $table.isUploaded, builder: (column) => column);

  GeneratedColumn<DateTime> get uploadedAt => $composableBuilder(
      column: $table.uploadedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$ReportEvidenceTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ReportEvidenceTableTable,
    ReportEvidenceTableData,
    $$ReportEvidenceTableTableFilterComposer,
    $$ReportEvidenceTableTableOrderingComposer,
    $$ReportEvidenceTableTableAnnotationComposer,
    $$ReportEvidenceTableTableCreateCompanionBuilder,
    $$ReportEvidenceTableTableUpdateCompanionBuilder,
    (
      ReportEvidenceTableData,
      BaseReferences<_$AppDatabase, $ReportEvidenceTableTable,
          ReportEvidenceTableData>
    ),
    ReportEvidenceTableData,
    PrefetchHooks Function()> {
  $$ReportEvidenceTableTableTableManager(
      _$AppDatabase db, $ReportEvidenceTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReportEvidenceTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReportEvidenceTableTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReportEvidenceTableTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> reportId = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<String> localPath = const Value.absent(),
            Value<String> fileName = const Value.absent(),
            Value<int> fileSize = const Value.absent(),
            Value<String> mimeType = const Value.absent(),
            Value<String?> serverUrl = const Value.absent(),
            Value<bool> isUploaded = const Value.absent(),
            Value<DateTime?> uploadedAt = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              ReportEvidenceTableCompanion(
            id: id,
            reportId: reportId,
            type: type,
            localPath: localPath,
            fileName: fileName,
            fileSize: fileSize,
            mimeType: mimeType,
            serverUrl: serverUrl,
            isUploaded: isUploaded,
            uploadedAt: uploadedAt,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String reportId,
            required String type,
            required String localPath,
            required String fileName,
            required int fileSize,
            required String mimeType,
            Value<String?> serverUrl = const Value.absent(),
            Value<bool> isUploaded = const Value.absent(),
            Value<DateTime?> uploadedAt = const Value.absent(),
            required DateTime createdAt,
          }) =>
              ReportEvidenceTableCompanion.insert(
            id: id,
            reportId: reportId,
            type: type,
            localPath: localPath,
            fileName: fileName,
            fileSize: fileSize,
            mimeType: mimeType,
            serverUrl: serverUrl,
            isUploaded: isUploaded,
            uploadedAt: uploadedAt,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ReportEvidenceTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ReportEvidenceTableTable,
    ReportEvidenceTableData,
    $$ReportEvidenceTableTableFilterComposer,
    $$ReportEvidenceTableTableOrderingComposer,
    $$ReportEvidenceTableTableAnnotationComposer,
    $$ReportEvidenceTableTableCreateCompanionBuilder,
    $$ReportEvidenceTableTableUpdateCompanionBuilder,
    (
      ReportEvidenceTableData,
      BaseReferences<_$AppDatabase, $ReportEvidenceTableTable,
          ReportEvidenceTableData>
    ),
    ReportEvidenceTableData,
    PrefetchHooks Function()>;
typedef $$SyncQueueTableTableCreateCompanionBuilder = SyncQueueTableCompanion
    Function({
  Value<int> id,
  required String operationType,
  required String resourceId,
  required String payload,
  required String status,
  Value<int> retryCount,
  Value<String?> lastError,
  required DateTime createdAt,
  Value<DateTime?> lastAttemptAt,
  Value<DateTime?> completedAt,
});
typedef $$SyncQueueTableTableUpdateCompanionBuilder = SyncQueueTableCompanion
    Function({
  Value<int> id,
  Value<String> operationType,
  Value<String> resourceId,
  Value<String> payload,
  Value<String> status,
  Value<int> retryCount,
  Value<String?> lastError,
  Value<DateTime> createdAt,
  Value<DateTime?> lastAttemptAt,
  Value<DateTime?> completedAt,
});

class $$SyncQueueTableTableFilterComposer
    extends Composer<_$AppDatabase, $SyncQueueTableTable> {
  $$SyncQueueTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get operationType => $composableBuilder(
      column: $table.operationType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get resourceId => $composableBuilder(
      column: $table.resourceId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get payload => $composableBuilder(
      column: $table.payload, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get retryCount => $composableBuilder(
      column: $table.retryCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get lastError => $composableBuilder(
      column: $table.lastError, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastAttemptAt => $composableBuilder(
      column: $table.lastAttemptAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnFilters(column));
}

class $$SyncQueueTableTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncQueueTableTable> {
  $$SyncQueueTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get operationType => $composableBuilder(
      column: $table.operationType,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get resourceId => $composableBuilder(
      column: $table.resourceId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get payload => $composableBuilder(
      column: $table.payload, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get retryCount => $composableBuilder(
      column: $table.retryCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lastError => $composableBuilder(
      column: $table.lastError, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastAttemptAt => $composableBuilder(
      column: $table.lastAttemptAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnOrderings(column));
}

class $$SyncQueueTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncQueueTableTable> {
  $$SyncQueueTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get operationType => $composableBuilder(
      column: $table.operationType, builder: (column) => column);

  GeneratedColumn<String> get resourceId => $composableBuilder(
      column: $table.resourceId, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get retryCount => $composableBuilder(
      column: $table.retryCount, builder: (column) => column);

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastAttemptAt => $composableBuilder(
      column: $table.lastAttemptAt, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => column);
}

class $$SyncQueueTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SyncQueueTableTable,
    SyncQueueTableData,
    $$SyncQueueTableTableFilterComposer,
    $$SyncQueueTableTableOrderingComposer,
    $$SyncQueueTableTableAnnotationComposer,
    $$SyncQueueTableTableCreateCompanionBuilder,
    $$SyncQueueTableTableUpdateCompanionBuilder,
    (
      SyncQueueTableData,
      BaseReferences<_$AppDatabase, $SyncQueueTableTable, SyncQueueTableData>
    ),
    SyncQueueTableData,
    PrefetchHooks Function()> {
  $$SyncQueueTableTableTableManager(
      _$AppDatabase db, $SyncQueueTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncQueueTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncQueueTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncQueueTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> operationType = const Value.absent(),
            Value<String> resourceId = const Value.absent(),
            Value<String> payload = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<int> retryCount = const Value.absent(),
            Value<String?> lastError = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime?> lastAttemptAt = const Value.absent(),
            Value<DateTime?> completedAt = const Value.absent(),
          }) =>
              SyncQueueTableCompanion(
            id: id,
            operationType: operationType,
            resourceId: resourceId,
            payload: payload,
            status: status,
            retryCount: retryCount,
            lastError: lastError,
            createdAt: createdAt,
            lastAttemptAt: lastAttemptAt,
            completedAt: completedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String operationType,
            required String resourceId,
            required String payload,
            required String status,
            Value<int> retryCount = const Value.absent(),
            Value<String?> lastError = const Value.absent(),
            required DateTime createdAt,
            Value<DateTime?> lastAttemptAt = const Value.absent(),
            Value<DateTime?> completedAt = const Value.absent(),
          }) =>
              SyncQueueTableCompanion.insert(
            id: id,
            operationType: operationType,
            resourceId: resourceId,
            payload: payload,
            status: status,
            retryCount: retryCount,
            lastError: lastError,
            createdAt: createdAt,
            lastAttemptAt: lastAttemptAt,
            completedAt: completedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SyncQueueTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SyncQueueTableTable,
    SyncQueueTableData,
    $$SyncQueueTableTableFilterComposer,
    $$SyncQueueTableTableOrderingComposer,
    $$SyncQueueTableTableAnnotationComposer,
    $$SyncQueueTableTableCreateCompanionBuilder,
    $$SyncQueueTableTableUpdateCompanionBuilder,
    (
      SyncQueueTableData,
      BaseReferences<_$AppDatabase, $SyncQueueTableTable, SyncQueueTableData>
    ),
    SyncQueueTableData,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$NoveltyCacheTableTableTableManager get noveltyCacheTable =>
      $$NoveltyCacheTableTableTableManager(_db, _db.noveltyCacheTable);
  $$CrewCacheTableTableTableManager get crewCacheTable =>
      $$CrewCacheTableTableTableManager(_db, _db.crewCacheTable);
  $$ReportTableTableTableManager get reportTable =>
      $$ReportTableTableTableManager(_db, _db.reportTable);
  $$ReportEvidenceTableTableTableManager get reportEvidenceTable =>
      $$ReportEvidenceTableTableTableManager(_db, _db.reportEvidenceTable);
  $$SyncQueueTableTableTableManager get syncQueueTable =>
      $$SyncQueueTableTableTableManager(_db, _db.syncQueueTable);
}
