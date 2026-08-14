// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ContactsTableTable extends ContactsTable
    with TableInfo<$ContactsTableTable, ContactEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ContactsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _localIdMeta = const VerificationMeta(
    'localId',
  );
  @override
  late final GeneratedColumn<int> localId = GeneratedColumn<int>(
    'local_id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _serverIdMeta = const VerificationMeta(
    'serverId',
  );
  @override
  late final GeneratedColumn<String> serverId = GeneratedColumn<String>(
    'server_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending_create'),
  );
  static const VerificationMeta _firstNameMeta = const VerificationMeta(
    'firstName',
  );
  @override
  late final GeneratedColumn<String> firstName = GeneratedColumn<String>(
    'first_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _middleNameMeta = const VerificationMeta(
    'middleName',
  );
  @override
  late final GeneratedColumn<String> middleName = GeneratedColumn<String>(
    'middle_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastNameMeta = const VerificationMeta(
    'lastName',
  );
  @override
  late final GeneratedColumn<String> lastName = GeneratedColumn<String>(
    'last_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _alternatePhoneMeta = const VerificationMeta(
    'alternatePhone',
  );
  @override
  late final GeneratedColumn<String> alternatePhone = GeneratedColumn<String>(
    'alternate_phone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tinMeta = const VerificationMeta('tin');
  @override
  late final GeneratedColumn<String> tin = GeneratedColumn<String>(
    'tin',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _vrnMeta = const VerificationMeta('vrn');
  @override
  late final GeneratedColumn<String> vrn = GeneratedColumn<String>(
    'vrn',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _companyMeta = const VerificationMeta(
    'company',
  );
  @override
  late final GeneratedColumn<String> company = GeneratedColumn<String>(
    'company',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _infoSourceMeta = const VerificationMeta(
    'infoSource',
  );
  @override
  late final GeneratedColumn<String> infoSource = GeneratedColumn<String>(
    'info_source',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _leadStatusMeta = const VerificationMeta(
    'leadStatus',
  );
  @override
  late final GeneratedColumn<String> leadStatus = GeneratedColumn<String>(
    'lead_status',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _leadScoreMeta = const VerificationMeta(
    'leadScore',
  );
  @override
  late final GeneratedColumn<int> leadScore = GeneratedColumn<int>(
    'lead_score',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _isCustomerMeta = const VerificationMeta(
    'isCustomer',
  );
  @override
  late final GeneratedColumn<bool> isCustomer = GeneratedColumn<bool>(
    'is_customer',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_customer" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
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
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _localUpdatedAtMeta = const VerificationMeta(
    'localUpdatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> localUpdatedAt =
      GeneratedColumn<DateTime>(
        'local_updated_at',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _serverUpdatedAtMeta = const VerificationMeta(
    'serverUpdatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> serverUpdatedAt =
      GeneratedColumn<DateTime>(
        'server_updated_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    localId,
    serverId,
    syncStatus,
    firstName,
    middleName,
    lastName,
    email,
    phone,
    alternatePhone,
    tin,
    vrn,
    company,
    title,
    infoSource,
    leadStatus,
    leadScore,
    isCustomer,
    notes,
    isActive,
    localUpdatedAt,
    serverUpdatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'contacts_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<ContactEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('local_id')) {
      context.handle(
        _localIdMeta,
        localId.isAcceptableOrUnknown(data['local_id']!, _localIdMeta),
      );
    }
    if (data.containsKey('server_id')) {
      context.handle(
        _serverIdMeta,
        serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    if (data.containsKey('first_name')) {
      context.handle(
        _firstNameMeta,
        firstName.isAcceptableOrUnknown(data['first_name']!, _firstNameMeta),
      );
    } else if (isInserting) {
      context.missing(_firstNameMeta);
    }
    if (data.containsKey('middle_name')) {
      context.handle(
        _middleNameMeta,
        middleName.isAcceptableOrUnknown(data['middle_name']!, _middleNameMeta),
      );
    }
    if (data.containsKey('last_name')) {
      context.handle(
        _lastNameMeta,
        lastName.isAcceptableOrUnknown(data['last_name']!, _lastNameMeta),
      );
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    }
    if (data.containsKey('alternate_phone')) {
      context.handle(
        _alternatePhoneMeta,
        alternatePhone.isAcceptableOrUnknown(
          data['alternate_phone']!,
          _alternatePhoneMeta,
        ),
      );
    }
    if (data.containsKey('tin')) {
      context.handle(
        _tinMeta,
        tin.isAcceptableOrUnknown(data['tin']!, _tinMeta),
      );
    }
    if (data.containsKey('vrn')) {
      context.handle(
        _vrnMeta,
        vrn.isAcceptableOrUnknown(data['vrn']!, _vrnMeta),
      );
    }
    if (data.containsKey('company')) {
      context.handle(
        _companyMeta,
        company.isAcceptableOrUnknown(data['company']!, _companyMeta),
      );
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    }
    if (data.containsKey('info_source')) {
      context.handle(
        _infoSourceMeta,
        infoSource.isAcceptableOrUnknown(data['info_source']!, _infoSourceMeta),
      );
    }
    if (data.containsKey('lead_status')) {
      context.handle(
        _leadStatusMeta,
        leadStatus.isAcceptableOrUnknown(data['lead_status']!, _leadStatusMeta),
      );
    }
    if (data.containsKey('lead_score')) {
      context.handle(
        _leadScoreMeta,
        leadScore.isAcceptableOrUnknown(data['lead_score']!, _leadScoreMeta),
      );
    }
    if (data.containsKey('is_customer')) {
      context.handle(
        _isCustomerMeta,
        isCustomer.isAcceptableOrUnknown(data['is_customer']!, _isCustomerMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('local_updated_at')) {
      context.handle(
        _localUpdatedAtMeta,
        localUpdatedAt.isAcceptableOrUnknown(
          data['local_updated_at']!,
          _localUpdatedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_localUpdatedAtMeta);
    }
    if (data.containsKey('server_updated_at')) {
      context.handle(
        _serverUpdatedAtMeta,
        serverUpdatedAt.isAcceptableOrUnknown(
          data['server_updated_at']!,
          _serverUpdatedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {localId};
  @override
  ContactEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ContactEntry(
      localId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}local_id'],
      )!,
      serverId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}server_id'],
      ),
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
      firstName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}first_name'],
      )!,
      middleName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}middle_name'],
      ),
      lastName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_name'],
      ),
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      ),
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      ),
      alternatePhone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}alternate_phone'],
      ),
      tin: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tin'],
      ),
      vrn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}vrn'],
      ),
      company: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}company'],
      ),
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      ),
      infoSource: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}info_source'],
      ),
      leadStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lead_status'],
      ),
      leadScore: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}lead_score'],
      )!,
      isCustomer: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_customer'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      localUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}local_updated_at'],
      )!,
      serverUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}server_updated_at'],
      ),
    );
  }

  @override
  $ContactsTableTable createAlias(String alias) {
    return $ContactsTableTable(attachedDatabase, alias);
  }
}

class ContactEntry extends DataClass implements Insertable<ContactEntry> {
  final int localId;
  final String? serverId;
  final String syncStatus;
  final String firstName;
  final String? middleName;
  final String? lastName;
  final String? email;
  final String? phone;
  final String? alternatePhone;
  final String? tin;
  final String? vrn;
  final String? company;
  final String? title;
  final String? infoSource;
  final String? leadStatus;
  final int leadScore;
  final bool isCustomer;
  final String? notes;
  final bool isActive;
  final DateTime localUpdatedAt;
  final DateTime? serverUpdatedAt;
  const ContactEntry({
    required this.localId,
    this.serverId,
    required this.syncStatus,
    required this.firstName,
    this.middleName,
    this.lastName,
    this.email,
    this.phone,
    this.alternatePhone,
    this.tin,
    this.vrn,
    this.company,
    this.title,
    this.infoSource,
    this.leadStatus,
    required this.leadScore,
    required this.isCustomer,
    this.notes,
    required this.isActive,
    required this.localUpdatedAt,
    this.serverUpdatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['local_id'] = Variable<int>(localId);
    if (!nullToAbsent || serverId != null) {
      map['server_id'] = Variable<String>(serverId);
    }
    map['sync_status'] = Variable<String>(syncStatus);
    map['first_name'] = Variable<String>(firstName);
    if (!nullToAbsent || middleName != null) {
      map['middle_name'] = Variable<String>(middleName);
    }
    if (!nullToAbsent || lastName != null) {
      map['last_name'] = Variable<String>(lastName);
    }
    if (!nullToAbsent || email != null) {
      map['email'] = Variable<String>(email);
    }
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    if (!nullToAbsent || alternatePhone != null) {
      map['alternate_phone'] = Variable<String>(alternatePhone);
    }
    if (!nullToAbsent || tin != null) {
      map['tin'] = Variable<String>(tin);
    }
    if (!nullToAbsent || vrn != null) {
      map['vrn'] = Variable<String>(vrn);
    }
    if (!nullToAbsent || company != null) {
      map['company'] = Variable<String>(company);
    }
    if (!nullToAbsent || title != null) {
      map['title'] = Variable<String>(title);
    }
    if (!nullToAbsent || infoSource != null) {
      map['info_source'] = Variable<String>(infoSource);
    }
    if (!nullToAbsent || leadStatus != null) {
      map['lead_status'] = Variable<String>(leadStatus);
    }
    map['lead_score'] = Variable<int>(leadScore);
    map['is_customer'] = Variable<bool>(isCustomer);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['is_active'] = Variable<bool>(isActive);
    map['local_updated_at'] = Variable<DateTime>(localUpdatedAt);
    if (!nullToAbsent || serverUpdatedAt != null) {
      map['server_updated_at'] = Variable<DateTime>(serverUpdatedAt);
    }
    return map;
  }

  ContactsTableCompanion toCompanion(bool nullToAbsent) {
    return ContactsTableCompanion(
      localId: Value(localId),
      serverId: serverId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverId),
      syncStatus: Value(syncStatus),
      firstName: Value(firstName),
      middleName: middleName == null && nullToAbsent
          ? const Value.absent()
          : Value(middleName),
      lastName: lastName == null && nullToAbsent
          ? const Value.absent()
          : Value(lastName),
      email: email == null && nullToAbsent
          ? const Value.absent()
          : Value(email),
      phone: phone == null && nullToAbsent
          ? const Value.absent()
          : Value(phone),
      alternatePhone: alternatePhone == null && nullToAbsent
          ? const Value.absent()
          : Value(alternatePhone),
      tin: tin == null && nullToAbsent ? const Value.absent() : Value(tin),
      vrn: vrn == null && nullToAbsent ? const Value.absent() : Value(vrn),
      company: company == null && nullToAbsent
          ? const Value.absent()
          : Value(company),
      title: title == null && nullToAbsent
          ? const Value.absent()
          : Value(title),
      infoSource: infoSource == null && nullToAbsent
          ? const Value.absent()
          : Value(infoSource),
      leadStatus: leadStatus == null && nullToAbsent
          ? const Value.absent()
          : Value(leadStatus),
      leadScore: Value(leadScore),
      isCustomer: Value(isCustomer),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      isActive: Value(isActive),
      localUpdatedAt: Value(localUpdatedAt),
      serverUpdatedAt: serverUpdatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(serverUpdatedAt),
    );
  }

  factory ContactEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ContactEntry(
      localId: serializer.fromJson<int>(json['localId']),
      serverId: serializer.fromJson<String?>(json['serverId']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      firstName: serializer.fromJson<String>(json['firstName']),
      middleName: serializer.fromJson<String?>(json['middleName']),
      lastName: serializer.fromJson<String?>(json['lastName']),
      email: serializer.fromJson<String?>(json['email']),
      phone: serializer.fromJson<String?>(json['phone']),
      alternatePhone: serializer.fromJson<String?>(json['alternatePhone']),
      tin: serializer.fromJson<String?>(json['tin']),
      vrn: serializer.fromJson<String?>(json['vrn']),
      company: serializer.fromJson<String?>(json['company']),
      title: serializer.fromJson<String?>(json['title']),
      infoSource: serializer.fromJson<String?>(json['infoSource']),
      leadStatus: serializer.fromJson<String?>(json['leadStatus']),
      leadScore: serializer.fromJson<int>(json['leadScore']),
      isCustomer: serializer.fromJson<bool>(json['isCustomer']),
      notes: serializer.fromJson<String?>(json['notes']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      localUpdatedAt: serializer.fromJson<DateTime>(json['localUpdatedAt']),
      serverUpdatedAt: serializer.fromJson<DateTime?>(json['serverUpdatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'localId': serializer.toJson<int>(localId),
      'serverId': serializer.toJson<String?>(serverId),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'firstName': serializer.toJson<String>(firstName),
      'middleName': serializer.toJson<String?>(middleName),
      'lastName': serializer.toJson<String?>(lastName),
      'email': serializer.toJson<String?>(email),
      'phone': serializer.toJson<String?>(phone),
      'alternatePhone': serializer.toJson<String?>(alternatePhone),
      'tin': serializer.toJson<String?>(tin),
      'vrn': serializer.toJson<String?>(vrn),
      'company': serializer.toJson<String?>(company),
      'title': serializer.toJson<String?>(title),
      'infoSource': serializer.toJson<String?>(infoSource),
      'leadStatus': serializer.toJson<String?>(leadStatus),
      'leadScore': serializer.toJson<int>(leadScore),
      'isCustomer': serializer.toJson<bool>(isCustomer),
      'notes': serializer.toJson<String?>(notes),
      'isActive': serializer.toJson<bool>(isActive),
      'localUpdatedAt': serializer.toJson<DateTime>(localUpdatedAt),
      'serverUpdatedAt': serializer.toJson<DateTime?>(serverUpdatedAt),
    };
  }

  ContactEntry copyWith({
    int? localId,
    Value<String?> serverId = const Value.absent(),
    String? syncStatus,
    String? firstName,
    Value<String?> middleName = const Value.absent(),
    Value<String?> lastName = const Value.absent(),
    Value<String?> email = const Value.absent(),
    Value<String?> phone = const Value.absent(),
    Value<String?> alternatePhone = const Value.absent(),
    Value<String?> tin = const Value.absent(),
    Value<String?> vrn = const Value.absent(),
    Value<String?> company = const Value.absent(),
    Value<String?> title = const Value.absent(),
    Value<String?> infoSource = const Value.absent(),
    Value<String?> leadStatus = const Value.absent(),
    int? leadScore,
    bool? isCustomer,
    Value<String?> notes = const Value.absent(),
    bool? isActive,
    DateTime? localUpdatedAt,
    Value<DateTime?> serverUpdatedAt = const Value.absent(),
  }) => ContactEntry(
    localId: localId ?? this.localId,
    serverId: serverId.present ? serverId.value : this.serverId,
    syncStatus: syncStatus ?? this.syncStatus,
    firstName: firstName ?? this.firstName,
    middleName: middleName.present ? middleName.value : this.middleName,
    lastName: lastName.present ? lastName.value : this.lastName,
    email: email.present ? email.value : this.email,
    phone: phone.present ? phone.value : this.phone,
    alternatePhone: alternatePhone.present
        ? alternatePhone.value
        : this.alternatePhone,
    tin: tin.present ? tin.value : this.tin,
    vrn: vrn.present ? vrn.value : this.vrn,
    company: company.present ? company.value : this.company,
    title: title.present ? title.value : this.title,
    infoSource: infoSource.present ? infoSource.value : this.infoSource,
    leadStatus: leadStatus.present ? leadStatus.value : this.leadStatus,
    leadScore: leadScore ?? this.leadScore,
    isCustomer: isCustomer ?? this.isCustomer,
    notes: notes.present ? notes.value : this.notes,
    isActive: isActive ?? this.isActive,
    localUpdatedAt: localUpdatedAt ?? this.localUpdatedAt,
    serverUpdatedAt: serverUpdatedAt.present
        ? serverUpdatedAt.value
        : this.serverUpdatedAt,
  );
  ContactEntry copyWithCompanion(ContactsTableCompanion data) {
    return ContactEntry(
      localId: data.localId.present ? data.localId.value : this.localId,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      firstName: data.firstName.present ? data.firstName.value : this.firstName,
      middleName: data.middleName.present
          ? data.middleName.value
          : this.middleName,
      lastName: data.lastName.present ? data.lastName.value : this.lastName,
      email: data.email.present ? data.email.value : this.email,
      phone: data.phone.present ? data.phone.value : this.phone,
      alternatePhone: data.alternatePhone.present
          ? data.alternatePhone.value
          : this.alternatePhone,
      tin: data.tin.present ? data.tin.value : this.tin,
      vrn: data.vrn.present ? data.vrn.value : this.vrn,
      company: data.company.present ? data.company.value : this.company,
      title: data.title.present ? data.title.value : this.title,
      infoSource: data.infoSource.present
          ? data.infoSource.value
          : this.infoSource,
      leadStatus: data.leadStatus.present
          ? data.leadStatus.value
          : this.leadStatus,
      leadScore: data.leadScore.present ? data.leadScore.value : this.leadScore,
      isCustomer: data.isCustomer.present
          ? data.isCustomer.value
          : this.isCustomer,
      notes: data.notes.present ? data.notes.value : this.notes,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      localUpdatedAt: data.localUpdatedAt.present
          ? data.localUpdatedAt.value
          : this.localUpdatedAt,
      serverUpdatedAt: data.serverUpdatedAt.present
          ? data.serverUpdatedAt.value
          : this.serverUpdatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ContactEntry(')
          ..write('localId: $localId, ')
          ..write('serverId: $serverId, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('firstName: $firstName, ')
          ..write('middleName: $middleName, ')
          ..write('lastName: $lastName, ')
          ..write('email: $email, ')
          ..write('phone: $phone, ')
          ..write('alternatePhone: $alternatePhone, ')
          ..write('tin: $tin, ')
          ..write('vrn: $vrn, ')
          ..write('company: $company, ')
          ..write('title: $title, ')
          ..write('infoSource: $infoSource, ')
          ..write('leadStatus: $leadStatus, ')
          ..write('leadScore: $leadScore, ')
          ..write('isCustomer: $isCustomer, ')
          ..write('notes: $notes, ')
          ..write('isActive: $isActive, ')
          ..write('localUpdatedAt: $localUpdatedAt, ')
          ..write('serverUpdatedAt: $serverUpdatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    localId,
    serverId,
    syncStatus,
    firstName,
    middleName,
    lastName,
    email,
    phone,
    alternatePhone,
    tin,
    vrn,
    company,
    title,
    infoSource,
    leadStatus,
    leadScore,
    isCustomer,
    notes,
    isActive,
    localUpdatedAt,
    serverUpdatedAt,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ContactEntry &&
          other.localId == this.localId &&
          other.serverId == this.serverId &&
          other.syncStatus == this.syncStatus &&
          other.firstName == this.firstName &&
          other.middleName == this.middleName &&
          other.lastName == this.lastName &&
          other.email == this.email &&
          other.phone == this.phone &&
          other.alternatePhone == this.alternatePhone &&
          other.tin == this.tin &&
          other.vrn == this.vrn &&
          other.company == this.company &&
          other.title == this.title &&
          other.infoSource == this.infoSource &&
          other.leadStatus == this.leadStatus &&
          other.leadScore == this.leadScore &&
          other.isCustomer == this.isCustomer &&
          other.notes == this.notes &&
          other.isActive == this.isActive &&
          other.localUpdatedAt == this.localUpdatedAt &&
          other.serverUpdatedAt == this.serverUpdatedAt);
}

class ContactsTableCompanion extends UpdateCompanion<ContactEntry> {
  final Value<int> localId;
  final Value<String?> serverId;
  final Value<String> syncStatus;
  final Value<String> firstName;
  final Value<String?> middleName;
  final Value<String?> lastName;
  final Value<String?> email;
  final Value<String?> phone;
  final Value<String?> alternatePhone;
  final Value<String?> tin;
  final Value<String?> vrn;
  final Value<String?> company;
  final Value<String?> title;
  final Value<String?> infoSource;
  final Value<String?> leadStatus;
  final Value<int> leadScore;
  final Value<bool> isCustomer;
  final Value<String?> notes;
  final Value<bool> isActive;
  final Value<DateTime> localUpdatedAt;
  final Value<DateTime?> serverUpdatedAt;
  const ContactsTableCompanion({
    this.localId = const Value.absent(),
    this.serverId = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.firstName = const Value.absent(),
    this.middleName = const Value.absent(),
    this.lastName = const Value.absent(),
    this.email = const Value.absent(),
    this.phone = const Value.absent(),
    this.alternatePhone = const Value.absent(),
    this.tin = const Value.absent(),
    this.vrn = const Value.absent(),
    this.company = const Value.absent(),
    this.title = const Value.absent(),
    this.infoSource = const Value.absent(),
    this.leadStatus = const Value.absent(),
    this.leadScore = const Value.absent(),
    this.isCustomer = const Value.absent(),
    this.notes = const Value.absent(),
    this.isActive = const Value.absent(),
    this.localUpdatedAt = const Value.absent(),
    this.serverUpdatedAt = const Value.absent(),
  });
  ContactsTableCompanion.insert({
    this.localId = const Value.absent(),
    this.serverId = const Value.absent(),
    this.syncStatus = const Value.absent(),
    required String firstName,
    this.middleName = const Value.absent(),
    this.lastName = const Value.absent(),
    this.email = const Value.absent(),
    this.phone = const Value.absent(),
    this.alternatePhone = const Value.absent(),
    this.tin = const Value.absent(),
    this.vrn = const Value.absent(),
    this.company = const Value.absent(),
    this.title = const Value.absent(),
    this.infoSource = const Value.absent(),
    this.leadStatus = const Value.absent(),
    this.leadScore = const Value.absent(),
    this.isCustomer = const Value.absent(),
    this.notes = const Value.absent(),
    this.isActive = const Value.absent(),
    required DateTime localUpdatedAt,
    this.serverUpdatedAt = const Value.absent(),
  }) : firstName = Value(firstName),
       localUpdatedAt = Value(localUpdatedAt);
  static Insertable<ContactEntry> custom({
    Expression<int>? localId,
    Expression<String>? serverId,
    Expression<String>? syncStatus,
    Expression<String>? firstName,
    Expression<String>? middleName,
    Expression<String>? lastName,
    Expression<String>? email,
    Expression<String>? phone,
    Expression<String>? alternatePhone,
    Expression<String>? tin,
    Expression<String>? vrn,
    Expression<String>? company,
    Expression<String>? title,
    Expression<String>? infoSource,
    Expression<String>? leadStatus,
    Expression<int>? leadScore,
    Expression<bool>? isCustomer,
    Expression<String>? notes,
    Expression<bool>? isActive,
    Expression<DateTime>? localUpdatedAt,
    Expression<DateTime>? serverUpdatedAt,
  }) {
    return RawValuesInsertable({
      if (localId != null) 'local_id': localId,
      if (serverId != null) 'server_id': serverId,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (firstName != null) 'first_name': firstName,
      if (middleName != null) 'middle_name': middleName,
      if (lastName != null) 'last_name': lastName,
      if (email != null) 'email': email,
      if (phone != null) 'phone': phone,
      if (alternatePhone != null) 'alternate_phone': alternatePhone,
      if (tin != null) 'tin': tin,
      if (vrn != null) 'vrn': vrn,
      if (company != null) 'company': company,
      if (title != null) 'title': title,
      if (infoSource != null) 'info_source': infoSource,
      if (leadStatus != null) 'lead_status': leadStatus,
      if (leadScore != null) 'lead_score': leadScore,
      if (isCustomer != null) 'is_customer': isCustomer,
      if (notes != null) 'notes': notes,
      if (isActive != null) 'is_active': isActive,
      if (localUpdatedAt != null) 'local_updated_at': localUpdatedAt,
      if (serverUpdatedAt != null) 'server_updated_at': serverUpdatedAt,
    });
  }

  ContactsTableCompanion copyWith({
    Value<int>? localId,
    Value<String?>? serverId,
    Value<String>? syncStatus,
    Value<String>? firstName,
    Value<String?>? middleName,
    Value<String?>? lastName,
    Value<String?>? email,
    Value<String?>? phone,
    Value<String?>? alternatePhone,
    Value<String?>? tin,
    Value<String?>? vrn,
    Value<String?>? company,
    Value<String?>? title,
    Value<String?>? infoSource,
    Value<String?>? leadStatus,
    Value<int>? leadScore,
    Value<bool>? isCustomer,
    Value<String?>? notes,
    Value<bool>? isActive,
    Value<DateTime>? localUpdatedAt,
    Value<DateTime?>? serverUpdatedAt,
  }) {
    return ContactsTableCompanion(
      localId: localId ?? this.localId,
      serverId: serverId ?? this.serverId,
      syncStatus: syncStatus ?? this.syncStatus,
      firstName: firstName ?? this.firstName,
      middleName: middleName ?? this.middleName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      alternatePhone: alternatePhone ?? this.alternatePhone,
      tin: tin ?? this.tin,
      vrn: vrn ?? this.vrn,
      company: company ?? this.company,
      title: title ?? this.title,
      infoSource: infoSource ?? this.infoSource,
      leadStatus: leadStatus ?? this.leadStatus,
      leadScore: leadScore ?? this.leadScore,
      isCustomer: isCustomer ?? this.isCustomer,
      notes: notes ?? this.notes,
      isActive: isActive ?? this.isActive,
      localUpdatedAt: localUpdatedAt ?? this.localUpdatedAt,
      serverUpdatedAt: serverUpdatedAt ?? this.serverUpdatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (localId.present) {
      map['local_id'] = Variable<int>(localId.value);
    }
    if (serverId.present) {
      map['server_id'] = Variable<String>(serverId.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (firstName.present) {
      map['first_name'] = Variable<String>(firstName.value);
    }
    if (middleName.present) {
      map['middle_name'] = Variable<String>(middleName.value);
    }
    if (lastName.present) {
      map['last_name'] = Variable<String>(lastName.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (alternatePhone.present) {
      map['alternate_phone'] = Variable<String>(alternatePhone.value);
    }
    if (tin.present) {
      map['tin'] = Variable<String>(tin.value);
    }
    if (vrn.present) {
      map['vrn'] = Variable<String>(vrn.value);
    }
    if (company.present) {
      map['company'] = Variable<String>(company.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (infoSource.present) {
      map['info_source'] = Variable<String>(infoSource.value);
    }
    if (leadStatus.present) {
      map['lead_status'] = Variable<String>(leadStatus.value);
    }
    if (leadScore.present) {
      map['lead_score'] = Variable<int>(leadScore.value);
    }
    if (isCustomer.present) {
      map['is_customer'] = Variable<bool>(isCustomer.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (localUpdatedAt.present) {
      map['local_updated_at'] = Variable<DateTime>(localUpdatedAt.value);
    }
    if (serverUpdatedAt.present) {
      map['server_updated_at'] = Variable<DateTime>(serverUpdatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ContactsTableCompanion(')
          ..write('localId: $localId, ')
          ..write('serverId: $serverId, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('firstName: $firstName, ')
          ..write('middleName: $middleName, ')
          ..write('lastName: $lastName, ')
          ..write('email: $email, ')
          ..write('phone: $phone, ')
          ..write('alternatePhone: $alternatePhone, ')
          ..write('tin: $tin, ')
          ..write('vrn: $vrn, ')
          ..write('company: $company, ')
          ..write('title: $title, ')
          ..write('infoSource: $infoSource, ')
          ..write('leadStatus: $leadStatus, ')
          ..write('leadScore: $leadScore, ')
          ..write('isCustomer: $isCustomer, ')
          ..write('notes: $notes, ')
          ..write('isActive: $isActive, ')
          ..write('localUpdatedAt: $localUpdatedAt, ')
          ..write('serverUpdatedAt: $serverUpdatedAt')
          ..write(')'))
        .toString();
  }
}

class $ActivitiesTableTable extends ActivitiesTable
    with TableInfo<$ActivitiesTableTable, ActivityEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ActivitiesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _localIdMeta = const VerificationMeta(
    'localId',
  );
  @override
  late final GeneratedColumn<int> localId = GeneratedColumn<int>(
    'local_id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _serverIdMeta = const VerificationMeta(
    'serverId',
  );
  @override
  late final GeneratedColumn<String> serverId = GeneratedColumn<String>(
    'server_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending_create'),
  );
  static const VerificationMeta _contactLocalIdMeta = const VerificationMeta(
    'contactLocalId',
  );
  @override
  late final GeneratedColumn<int> contactLocalId = GeneratedColumn<int>(
    'contact_local_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
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
  static const VerificationMeta _subjectMeta = const VerificationMeta(
    'subject',
  );
  @override
  late final GeneratedColumn<String> subject = GeneratedColumn<String>(
    'subject',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
  static const VerificationMeta _directionMeta = const VerificationMeta(
    'direction',
  );
  @override
  late final GeneratedColumn<String> direction = GeneratedColumn<String>(
    'direction',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('outbound'),
  );
  static const VerificationMeta _durationMeta = const VerificationMeta(
    'duration',
  );
  @override
  late final GeneratedColumn<int> duration = GeneratedColumn<int>(
    'duration',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _outcomeMeta = const VerificationMeta(
    'outcome',
  );
  @override
  late final GeneratedColumn<String> outcome = GeneratedColumn<String>(
    'outcome',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _scheduledAtMeta = const VerificationMeta(
    'scheduledAt',
  );
  @override
  late final GeneratedColumn<DateTime> scheduledAt = GeneratedColumn<DateTime>(
    'scheduled_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _locationMeta = const VerificationMeta(
    'location',
  );
  @override
  late final GeneratedColumn<String> location = GeneratedColumn<String>(
    'location',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isCompletedMeta = const VerificationMeta(
    'isCompleted',
  );
  @override
  late final GeneratedColumn<bool> isCompleted = GeneratedColumn<bool>(
    'is_completed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_completed" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _localUpdatedAtMeta = const VerificationMeta(
    'localUpdatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> localUpdatedAt =
      GeneratedColumn<DateTime>(
        'local_updated_at',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  @override
  List<GeneratedColumn> get $columns => [
    localId,
    serverId,
    syncStatus,
    contactLocalId,
    type,
    subject,
    description,
    direction,
    duration,
    outcome,
    scheduledAt,
    completedAt,
    location,
    isCompleted,
    localUpdatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'activities_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<ActivityEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('local_id')) {
      context.handle(
        _localIdMeta,
        localId.isAcceptableOrUnknown(data['local_id']!, _localIdMeta),
      );
    }
    if (data.containsKey('server_id')) {
      context.handle(
        _serverIdMeta,
        serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    if (data.containsKey('contact_local_id')) {
      context.handle(
        _contactLocalIdMeta,
        contactLocalId.isAcceptableOrUnknown(
          data['contact_local_id']!,
          _contactLocalIdMeta,
        ),
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
    if (data.containsKey('subject')) {
      context.handle(
        _subjectMeta,
        subject.isAcceptableOrUnknown(data['subject']!, _subjectMeta),
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
    if (data.containsKey('direction')) {
      context.handle(
        _directionMeta,
        direction.isAcceptableOrUnknown(data['direction']!, _directionMeta),
      );
    }
    if (data.containsKey('duration')) {
      context.handle(
        _durationMeta,
        duration.isAcceptableOrUnknown(data['duration']!, _durationMeta),
      );
    }
    if (data.containsKey('outcome')) {
      context.handle(
        _outcomeMeta,
        outcome.isAcceptableOrUnknown(data['outcome']!, _outcomeMeta),
      );
    }
    if (data.containsKey('scheduled_at')) {
      context.handle(
        _scheduledAtMeta,
        scheduledAt.isAcceptableOrUnknown(
          data['scheduled_at']!,
          _scheduledAtMeta,
        ),
      );
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    }
    if (data.containsKey('location')) {
      context.handle(
        _locationMeta,
        location.isAcceptableOrUnknown(data['location']!, _locationMeta),
      );
    }
    if (data.containsKey('is_completed')) {
      context.handle(
        _isCompletedMeta,
        isCompleted.isAcceptableOrUnknown(
          data['is_completed']!,
          _isCompletedMeta,
        ),
      );
    }
    if (data.containsKey('local_updated_at')) {
      context.handle(
        _localUpdatedAtMeta,
        localUpdatedAt.isAcceptableOrUnknown(
          data['local_updated_at']!,
          _localUpdatedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_localUpdatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {localId};
  @override
  ActivityEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ActivityEntry(
      localId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}local_id'],
      )!,
      serverId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}server_id'],
      ),
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
      contactLocalId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}contact_local_id'],
      ),
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      subject: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}subject'],
      ),
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      direction: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}direction'],
      )!,
      duration: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration'],
      )!,
      outcome: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}outcome'],
      ),
      scheduledAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}scheduled_at'],
      ),
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      ),
      location: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}location'],
      ),
      isCompleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_completed'],
      )!,
      localUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}local_updated_at'],
      )!,
    );
  }

  @override
  $ActivitiesTableTable createAlias(String alias) {
    return $ActivitiesTableTable(attachedDatabase, alias);
  }
}

class ActivityEntry extends DataClass implements Insertable<ActivityEntry> {
  final int localId;
  final String? serverId;
  final String syncStatus;
  final int? contactLocalId;
  final String type;
  final String? subject;
  final String? description;
  final String direction;
  final int duration;
  final String? outcome;
  final DateTime? scheduledAt;
  final DateTime? completedAt;
  final String? location;
  final bool isCompleted;
  final DateTime localUpdatedAt;
  const ActivityEntry({
    required this.localId,
    this.serverId,
    required this.syncStatus,
    this.contactLocalId,
    required this.type,
    this.subject,
    this.description,
    required this.direction,
    required this.duration,
    this.outcome,
    this.scheduledAt,
    this.completedAt,
    this.location,
    required this.isCompleted,
    required this.localUpdatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['local_id'] = Variable<int>(localId);
    if (!nullToAbsent || serverId != null) {
      map['server_id'] = Variable<String>(serverId);
    }
    map['sync_status'] = Variable<String>(syncStatus);
    if (!nullToAbsent || contactLocalId != null) {
      map['contact_local_id'] = Variable<int>(contactLocalId);
    }
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || subject != null) {
      map['subject'] = Variable<String>(subject);
    }
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['direction'] = Variable<String>(direction);
    map['duration'] = Variable<int>(duration);
    if (!nullToAbsent || outcome != null) {
      map['outcome'] = Variable<String>(outcome);
    }
    if (!nullToAbsent || scheduledAt != null) {
      map['scheduled_at'] = Variable<DateTime>(scheduledAt);
    }
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    if (!nullToAbsent || location != null) {
      map['location'] = Variable<String>(location);
    }
    map['is_completed'] = Variable<bool>(isCompleted);
    map['local_updated_at'] = Variable<DateTime>(localUpdatedAt);
    return map;
  }

  ActivitiesTableCompanion toCompanion(bool nullToAbsent) {
    return ActivitiesTableCompanion(
      localId: Value(localId),
      serverId: serverId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverId),
      syncStatus: Value(syncStatus),
      contactLocalId: contactLocalId == null && nullToAbsent
          ? const Value.absent()
          : Value(contactLocalId),
      type: Value(type),
      subject: subject == null && nullToAbsent
          ? const Value.absent()
          : Value(subject),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      direction: Value(direction),
      duration: Value(duration),
      outcome: outcome == null && nullToAbsent
          ? const Value.absent()
          : Value(outcome),
      scheduledAt: scheduledAt == null && nullToAbsent
          ? const Value.absent()
          : Value(scheduledAt),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      location: location == null && nullToAbsent
          ? const Value.absent()
          : Value(location),
      isCompleted: Value(isCompleted),
      localUpdatedAt: Value(localUpdatedAt),
    );
  }

  factory ActivityEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ActivityEntry(
      localId: serializer.fromJson<int>(json['localId']),
      serverId: serializer.fromJson<String?>(json['serverId']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      contactLocalId: serializer.fromJson<int?>(json['contactLocalId']),
      type: serializer.fromJson<String>(json['type']),
      subject: serializer.fromJson<String?>(json['subject']),
      description: serializer.fromJson<String?>(json['description']),
      direction: serializer.fromJson<String>(json['direction']),
      duration: serializer.fromJson<int>(json['duration']),
      outcome: serializer.fromJson<String?>(json['outcome']),
      scheduledAt: serializer.fromJson<DateTime?>(json['scheduledAt']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
      location: serializer.fromJson<String?>(json['location']),
      isCompleted: serializer.fromJson<bool>(json['isCompleted']),
      localUpdatedAt: serializer.fromJson<DateTime>(json['localUpdatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'localId': serializer.toJson<int>(localId),
      'serverId': serializer.toJson<String?>(serverId),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'contactLocalId': serializer.toJson<int?>(contactLocalId),
      'type': serializer.toJson<String>(type),
      'subject': serializer.toJson<String?>(subject),
      'description': serializer.toJson<String?>(description),
      'direction': serializer.toJson<String>(direction),
      'duration': serializer.toJson<int>(duration),
      'outcome': serializer.toJson<String?>(outcome),
      'scheduledAt': serializer.toJson<DateTime?>(scheduledAt),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
      'location': serializer.toJson<String?>(location),
      'isCompleted': serializer.toJson<bool>(isCompleted),
      'localUpdatedAt': serializer.toJson<DateTime>(localUpdatedAt),
    };
  }

  ActivityEntry copyWith({
    int? localId,
    Value<String?> serverId = const Value.absent(),
    String? syncStatus,
    Value<int?> contactLocalId = const Value.absent(),
    String? type,
    Value<String?> subject = const Value.absent(),
    Value<String?> description = const Value.absent(),
    String? direction,
    int? duration,
    Value<String?> outcome = const Value.absent(),
    Value<DateTime?> scheduledAt = const Value.absent(),
    Value<DateTime?> completedAt = const Value.absent(),
    Value<String?> location = const Value.absent(),
    bool? isCompleted,
    DateTime? localUpdatedAt,
  }) => ActivityEntry(
    localId: localId ?? this.localId,
    serverId: serverId.present ? serverId.value : this.serverId,
    syncStatus: syncStatus ?? this.syncStatus,
    contactLocalId: contactLocalId.present
        ? contactLocalId.value
        : this.contactLocalId,
    type: type ?? this.type,
    subject: subject.present ? subject.value : this.subject,
    description: description.present ? description.value : this.description,
    direction: direction ?? this.direction,
    duration: duration ?? this.duration,
    outcome: outcome.present ? outcome.value : this.outcome,
    scheduledAt: scheduledAt.present ? scheduledAt.value : this.scheduledAt,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
    location: location.present ? location.value : this.location,
    isCompleted: isCompleted ?? this.isCompleted,
    localUpdatedAt: localUpdatedAt ?? this.localUpdatedAt,
  );
  ActivityEntry copyWithCompanion(ActivitiesTableCompanion data) {
    return ActivityEntry(
      localId: data.localId.present ? data.localId.value : this.localId,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      contactLocalId: data.contactLocalId.present
          ? data.contactLocalId.value
          : this.contactLocalId,
      type: data.type.present ? data.type.value : this.type,
      subject: data.subject.present ? data.subject.value : this.subject,
      description: data.description.present
          ? data.description.value
          : this.description,
      direction: data.direction.present ? data.direction.value : this.direction,
      duration: data.duration.present ? data.duration.value : this.duration,
      outcome: data.outcome.present ? data.outcome.value : this.outcome,
      scheduledAt: data.scheduledAt.present
          ? data.scheduledAt.value
          : this.scheduledAt,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
      location: data.location.present ? data.location.value : this.location,
      isCompleted: data.isCompleted.present
          ? data.isCompleted.value
          : this.isCompleted,
      localUpdatedAt: data.localUpdatedAt.present
          ? data.localUpdatedAt.value
          : this.localUpdatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ActivityEntry(')
          ..write('localId: $localId, ')
          ..write('serverId: $serverId, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('contactLocalId: $contactLocalId, ')
          ..write('type: $type, ')
          ..write('subject: $subject, ')
          ..write('description: $description, ')
          ..write('direction: $direction, ')
          ..write('duration: $duration, ')
          ..write('outcome: $outcome, ')
          ..write('scheduledAt: $scheduledAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('location: $location, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('localUpdatedAt: $localUpdatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    localId,
    serverId,
    syncStatus,
    contactLocalId,
    type,
    subject,
    description,
    direction,
    duration,
    outcome,
    scheduledAt,
    completedAt,
    location,
    isCompleted,
    localUpdatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ActivityEntry &&
          other.localId == this.localId &&
          other.serverId == this.serverId &&
          other.syncStatus == this.syncStatus &&
          other.contactLocalId == this.contactLocalId &&
          other.type == this.type &&
          other.subject == this.subject &&
          other.description == this.description &&
          other.direction == this.direction &&
          other.duration == this.duration &&
          other.outcome == this.outcome &&
          other.scheduledAt == this.scheduledAt &&
          other.completedAt == this.completedAt &&
          other.location == this.location &&
          other.isCompleted == this.isCompleted &&
          other.localUpdatedAt == this.localUpdatedAt);
}

class ActivitiesTableCompanion extends UpdateCompanion<ActivityEntry> {
  final Value<int> localId;
  final Value<String?> serverId;
  final Value<String> syncStatus;
  final Value<int?> contactLocalId;
  final Value<String> type;
  final Value<String?> subject;
  final Value<String?> description;
  final Value<String> direction;
  final Value<int> duration;
  final Value<String?> outcome;
  final Value<DateTime?> scheduledAt;
  final Value<DateTime?> completedAt;
  final Value<String?> location;
  final Value<bool> isCompleted;
  final Value<DateTime> localUpdatedAt;
  const ActivitiesTableCompanion({
    this.localId = const Value.absent(),
    this.serverId = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.contactLocalId = const Value.absent(),
    this.type = const Value.absent(),
    this.subject = const Value.absent(),
    this.description = const Value.absent(),
    this.direction = const Value.absent(),
    this.duration = const Value.absent(),
    this.outcome = const Value.absent(),
    this.scheduledAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.location = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.localUpdatedAt = const Value.absent(),
  });
  ActivitiesTableCompanion.insert({
    this.localId = const Value.absent(),
    this.serverId = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.contactLocalId = const Value.absent(),
    required String type,
    this.subject = const Value.absent(),
    this.description = const Value.absent(),
    this.direction = const Value.absent(),
    this.duration = const Value.absent(),
    this.outcome = const Value.absent(),
    this.scheduledAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.location = const Value.absent(),
    this.isCompleted = const Value.absent(),
    required DateTime localUpdatedAt,
  }) : type = Value(type),
       localUpdatedAt = Value(localUpdatedAt);
  static Insertable<ActivityEntry> custom({
    Expression<int>? localId,
    Expression<String>? serverId,
    Expression<String>? syncStatus,
    Expression<int>? contactLocalId,
    Expression<String>? type,
    Expression<String>? subject,
    Expression<String>? description,
    Expression<String>? direction,
    Expression<int>? duration,
    Expression<String>? outcome,
    Expression<DateTime>? scheduledAt,
    Expression<DateTime>? completedAt,
    Expression<String>? location,
    Expression<bool>? isCompleted,
    Expression<DateTime>? localUpdatedAt,
  }) {
    return RawValuesInsertable({
      if (localId != null) 'local_id': localId,
      if (serverId != null) 'server_id': serverId,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (contactLocalId != null) 'contact_local_id': contactLocalId,
      if (type != null) 'type': type,
      if (subject != null) 'subject': subject,
      if (description != null) 'description': description,
      if (direction != null) 'direction': direction,
      if (duration != null) 'duration': duration,
      if (outcome != null) 'outcome': outcome,
      if (scheduledAt != null) 'scheduled_at': scheduledAt,
      if (completedAt != null) 'completed_at': completedAt,
      if (location != null) 'location': location,
      if (isCompleted != null) 'is_completed': isCompleted,
      if (localUpdatedAt != null) 'local_updated_at': localUpdatedAt,
    });
  }

  ActivitiesTableCompanion copyWith({
    Value<int>? localId,
    Value<String?>? serverId,
    Value<String>? syncStatus,
    Value<int?>? contactLocalId,
    Value<String>? type,
    Value<String?>? subject,
    Value<String?>? description,
    Value<String>? direction,
    Value<int>? duration,
    Value<String?>? outcome,
    Value<DateTime?>? scheduledAt,
    Value<DateTime?>? completedAt,
    Value<String?>? location,
    Value<bool>? isCompleted,
    Value<DateTime>? localUpdatedAt,
  }) {
    return ActivitiesTableCompanion(
      localId: localId ?? this.localId,
      serverId: serverId ?? this.serverId,
      syncStatus: syncStatus ?? this.syncStatus,
      contactLocalId: contactLocalId ?? this.contactLocalId,
      type: type ?? this.type,
      subject: subject ?? this.subject,
      description: description ?? this.description,
      direction: direction ?? this.direction,
      duration: duration ?? this.duration,
      outcome: outcome ?? this.outcome,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      completedAt: completedAt ?? this.completedAt,
      location: location ?? this.location,
      isCompleted: isCompleted ?? this.isCompleted,
      localUpdatedAt: localUpdatedAt ?? this.localUpdatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (localId.present) {
      map['local_id'] = Variable<int>(localId.value);
    }
    if (serverId.present) {
      map['server_id'] = Variable<String>(serverId.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (contactLocalId.present) {
      map['contact_local_id'] = Variable<int>(contactLocalId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (subject.present) {
      map['subject'] = Variable<String>(subject.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (direction.present) {
      map['direction'] = Variable<String>(direction.value);
    }
    if (duration.present) {
      map['duration'] = Variable<int>(duration.value);
    }
    if (outcome.present) {
      map['outcome'] = Variable<String>(outcome.value);
    }
    if (scheduledAt.present) {
      map['scheduled_at'] = Variable<DateTime>(scheduledAt.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (location.present) {
      map['location'] = Variable<String>(location.value);
    }
    if (isCompleted.present) {
      map['is_completed'] = Variable<bool>(isCompleted.value);
    }
    if (localUpdatedAt.present) {
      map['local_updated_at'] = Variable<DateTime>(localUpdatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ActivitiesTableCompanion(')
          ..write('localId: $localId, ')
          ..write('serverId: $serverId, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('contactLocalId: $contactLocalId, ')
          ..write('type: $type, ')
          ..write('subject: $subject, ')
          ..write('description: $description, ')
          ..write('direction: $direction, ')
          ..write('duration: $duration, ')
          ..write('outcome: $outcome, ')
          ..write('scheduledAt: $scheduledAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('location: $location, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('localUpdatedAt: $localUpdatedAt')
          ..write(')'))
        .toString();
  }
}

class $TasksTableTable extends TasksTable
    with TableInfo<$TasksTableTable, TaskEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TasksTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _localIdMeta = const VerificationMeta(
    'localId',
  );
  @override
  late final GeneratedColumn<int> localId = GeneratedColumn<int>(
    'local_id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _serverIdMeta = const VerificationMeta(
    'serverId',
  );
  @override
  late final GeneratedColumn<String> serverId = GeneratedColumn<String>(
    'server_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending_create'),
  );
  static const VerificationMeta _contactLocalIdMeta = const VerificationMeta(
    'contactLocalId',
  );
  @override
  late final GeneratedColumn<int> contactLocalId = GeneratedColumn<int>(
    'contact_local_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
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
  static const VerificationMeta _priorityMeta = const VerificationMeta(
    'priority',
  );
  @override
  late final GeneratedColumn<String> priority = GeneratedColumn<String>(
    'priority',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('medium'),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _dueDateMeta = const VerificationMeta(
    'dueDate',
  );
  @override
  late final GeneratedColumn<DateTime> dueDate = GeneratedColumn<DateTime>(
    'due_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
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
  static const VerificationMeta _reminderScheduledMeta = const VerificationMeta(
    'reminderScheduled',
  );
  @override
  late final GeneratedColumn<bool> reminderScheduled = GeneratedColumn<bool>(
    'reminder_scheduled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("reminder_scheduled" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _localUpdatedAtMeta = const VerificationMeta(
    'localUpdatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> localUpdatedAt =
      GeneratedColumn<DateTime>(
        'local_updated_at',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  @override
  List<GeneratedColumn> get $columns => [
    localId,
    serverId,
    syncStatus,
    contactLocalId,
    title,
    description,
    priority,
    status,
    dueDate,
    completedAt,
    notes,
    reminderScheduled,
    localUpdatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tasks_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<TaskEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('local_id')) {
      context.handle(
        _localIdMeta,
        localId.isAcceptableOrUnknown(data['local_id']!, _localIdMeta),
      );
    }
    if (data.containsKey('server_id')) {
      context.handle(
        _serverIdMeta,
        serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    if (data.containsKey('contact_local_id')) {
      context.handle(
        _contactLocalIdMeta,
        contactLocalId.isAcceptableOrUnknown(
          data['contact_local_id']!,
          _contactLocalIdMeta,
        ),
      );
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
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
    if (data.containsKey('priority')) {
      context.handle(
        _priorityMeta,
        priority.isAcceptableOrUnknown(data['priority']!, _priorityMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('due_date')) {
      context.handle(
        _dueDateMeta,
        dueDate.isAcceptableOrUnknown(data['due_date']!, _dueDateMeta),
      );
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('reminder_scheduled')) {
      context.handle(
        _reminderScheduledMeta,
        reminderScheduled.isAcceptableOrUnknown(
          data['reminder_scheduled']!,
          _reminderScheduledMeta,
        ),
      );
    }
    if (data.containsKey('local_updated_at')) {
      context.handle(
        _localUpdatedAtMeta,
        localUpdatedAt.isAcceptableOrUnknown(
          data['local_updated_at']!,
          _localUpdatedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_localUpdatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {localId};
  @override
  TaskEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TaskEntry(
      localId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}local_id'],
      )!,
      serverId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}server_id'],
      ),
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
      contactLocalId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}contact_local_id'],
      ),
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      priority: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}priority'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      dueDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}due_date'],
      ),
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      reminderScheduled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}reminder_scheduled'],
      )!,
      localUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}local_updated_at'],
      )!,
    );
  }

  @override
  $TasksTableTable createAlias(String alias) {
    return $TasksTableTable(attachedDatabase, alias);
  }
}

class TaskEntry extends DataClass implements Insertable<TaskEntry> {
  final int localId;
  final String? serverId;
  final String syncStatus;
  final int? contactLocalId;
  final String title;
  final String? description;
  final String priority;
  final String status;
  final DateTime? dueDate;
  final DateTime? completedAt;
  final String? notes;
  final bool reminderScheduled;
  final DateTime localUpdatedAt;
  const TaskEntry({
    required this.localId,
    this.serverId,
    required this.syncStatus,
    this.contactLocalId,
    required this.title,
    this.description,
    required this.priority,
    required this.status,
    this.dueDate,
    this.completedAt,
    this.notes,
    required this.reminderScheduled,
    required this.localUpdatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['local_id'] = Variable<int>(localId);
    if (!nullToAbsent || serverId != null) {
      map['server_id'] = Variable<String>(serverId);
    }
    map['sync_status'] = Variable<String>(syncStatus);
    if (!nullToAbsent || contactLocalId != null) {
      map['contact_local_id'] = Variable<int>(contactLocalId);
    }
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['priority'] = Variable<String>(priority);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || dueDate != null) {
      map['due_date'] = Variable<DateTime>(dueDate);
    }
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['reminder_scheduled'] = Variable<bool>(reminderScheduled);
    map['local_updated_at'] = Variable<DateTime>(localUpdatedAt);
    return map;
  }

  TasksTableCompanion toCompanion(bool nullToAbsent) {
    return TasksTableCompanion(
      localId: Value(localId),
      serverId: serverId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverId),
      syncStatus: Value(syncStatus),
      contactLocalId: contactLocalId == null && nullToAbsent
          ? const Value.absent()
          : Value(contactLocalId),
      title: Value(title),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      priority: Value(priority),
      status: Value(status),
      dueDate: dueDate == null && nullToAbsent
          ? const Value.absent()
          : Value(dueDate),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      reminderScheduled: Value(reminderScheduled),
      localUpdatedAt: Value(localUpdatedAt),
    );
  }

  factory TaskEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TaskEntry(
      localId: serializer.fromJson<int>(json['localId']),
      serverId: serializer.fromJson<String?>(json['serverId']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      contactLocalId: serializer.fromJson<int?>(json['contactLocalId']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String?>(json['description']),
      priority: serializer.fromJson<String>(json['priority']),
      status: serializer.fromJson<String>(json['status']),
      dueDate: serializer.fromJson<DateTime?>(json['dueDate']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
      notes: serializer.fromJson<String?>(json['notes']),
      reminderScheduled: serializer.fromJson<bool>(json['reminderScheduled']),
      localUpdatedAt: serializer.fromJson<DateTime>(json['localUpdatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'localId': serializer.toJson<int>(localId),
      'serverId': serializer.toJson<String?>(serverId),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'contactLocalId': serializer.toJson<int?>(contactLocalId),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String?>(description),
      'priority': serializer.toJson<String>(priority),
      'status': serializer.toJson<String>(status),
      'dueDate': serializer.toJson<DateTime?>(dueDate),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
      'notes': serializer.toJson<String?>(notes),
      'reminderScheduled': serializer.toJson<bool>(reminderScheduled),
      'localUpdatedAt': serializer.toJson<DateTime>(localUpdatedAt),
    };
  }

  TaskEntry copyWith({
    int? localId,
    Value<String?> serverId = const Value.absent(),
    String? syncStatus,
    Value<int?> contactLocalId = const Value.absent(),
    String? title,
    Value<String?> description = const Value.absent(),
    String? priority,
    String? status,
    Value<DateTime?> dueDate = const Value.absent(),
    Value<DateTime?> completedAt = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    bool? reminderScheduled,
    DateTime? localUpdatedAt,
  }) => TaskEntry(
    localId: localId ?? this.localId,
    serverId: serverId.present ? serverId.value : this.serverId,
    syncStatus: syncStatus ?? this.syncStatus,
    contactLocalId: contactLocalId.present
        ? contactLocalId.value
        : this.contactLocalId,
    title: title ?? this.title,
    description: description.present ? description.value : this.description,
    priority: priority ?? this.priority,
    status: status ?? this.status,
    dueDate: dueDate.present ? dueDate.value : this.dueDate,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
    notes: notes.present ? notes.value : this.notes,
    reminderScheduled: reminderScheduled ?? this.reminderScheduled,
    localUpdatedAt: localUpdatedAt ?? this.localUpdatedAt,
  );
  TaskEntry copyWithCompanion(TasksTableCompanion data) {
    return TaskEntry(
      localId: data.localId.present ? data.localId.value : this.localId,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      contactLocalId: data.contactLocalId.present
          ? data.contactLocalId.value
          : this.contactLocalId,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      priority: data.priority.present ? data.priority.value : this.priority,
      status: data.status.present ? data.status.value : this.status,
      dueDate: data.dueDate.present ? data.dueDate.value : this.dueDate,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
      notes: data.notes.present ? data.notes.value : this.notes,
      reminderScheduled: data.reminderScheduled.present
          ? data.reminderScheduled.value
          : this.reminderScheduled,
      localUpdatedAt: data.localUpdatedAt.present
          ? data.localUpdatedAt.value
          : this.localUpdatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TaskEntry(')
          ..write('localId: $localId, ')
          ..write('serverId: $serverId, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('contactLocalId: $contactLocalId, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('priority: $priority, ')
          ..write('status: $status, ')
          ..write('dueDate: $dueDate, ')
          ..write('completedAt: $completedAt, ')
          ..write('notes: $notes, ')
          ..write('reminderScheduled: $reminderScheduled, ')
          ..write('localUpdatedAt: $localUpdatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    localId,
    serverId,
    syncStatus,
    contactLocalId,
    title,
    description,
    priority,
    status,
    dueDate,
    completedAt,
    notes,
    reminderScheduled,
    localUpdatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TaskEntry &&
          other.localId == this.localId &&
          other.serverId == this.serverId &&
          other.syncStatus == this.syncStatus &&
          other.contactLocalId == this.contactLocalId &&
          other.title == this.title &&
          other.description == this.description &&
          other.priority == this.priority &&
          other.status == this.status &&
          other.dueDate == this.dueDate &&
          other.completedAt == this.completedAt &&
          other.notes == this.notes &&
          other.reminderScheduled == this.reminderScheduled &&
          other.localUpdatedAt == this.localUpdatedAt);
}

class TasksTableCompanion extends UpdateCompanion<TaskEntry> {
  final Value<int> localId;
  final Value<String?> serverId;
  final Value<String> syncStatus;
  final Value<int?> contactLocalId;
  final Value<String> title;
  final Value<String?> description;
  final Value<String> priority;
  final Value<String> status;
  final Value<DateTime?> dueDate;
  final Value<DateTime?> completedAt;
  final Value<String?> notes;
  final Value<bool> reminderScheduled;
  final Value<DateTime> localUpdatedAt;
  const TasksTableCompanion({
    this.localId = const Value.absent(),
    this.serverId = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.contactLocalId = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.priority = const Value.absent(),
    this.status = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.notes = const Value.absent(),
    this.reminderScheduled = const Value.absent(),
    this.localUpdatedAt = const Value.absent(),
  });
  TasksTableCompanion.insert({
    this.localId = const Value.absent(),
    this.serverId = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.contactLocalId = const Value.absent(),
    required String title,
    this.description = const Value.absent(),
    this.priority = const Value.absent(),
    this.status = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.notes = const Value.absent(),
    this.reminderScheduled = const Value.absent(),
    required DateTime localUpdatedAt,
  }) : title = Value(title),
       localUpdatedAt = Value(localUpdatedAt);
  static Insertable<TaskEntry> custom({
    Expression<int>? localId,
    Expression<String>? serverId,
    Expression<String>? syncStatus,
    Expression<int>? contactLocalId,
    Expression<String>? title,
    Expression<String>? description,
    Expression<String>? priority,
    Expression<String>? status,
    Expression<DateTime>? dueDate,
    Expression<DateTime>? completedAt,
    Expression<String>? notes,
    Expression<bool>? reminderScheduled,
    Expression<DateTime>? localUpdatedAt,
  }) {
    return RawValuesInsertable({
      if (localId != null) 'local_id': localId,
      if (serverId != null) 'server_id': serverId,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (contactLocalId != null) 'contact_local_id': contactLocalId,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (priority != null) 'priority': priority,
      if (status != null) 'status': status,
      if (dueDate != null) 'due_date': dueDate,
      if (completedAt != null) 'completed_at': completedAt,
      if (notes != null) 'notes': notes,
      if (reminderScheduled != null) 'reminder_scheduled': reminderScheduled,
      if (localUpdatedAt != null) 'local_updated_at': localUpdatedAt,
    });
  }

  TasksTableCompanion copyWith({
    Value<int>? localId,
    Value<String?>? serverId,
    Value<String>? syncStatus,
    Value<int?>? contactLocalId,
    Value<String>? title,
    Value<String?>? description,
    Value<String>? priority,
    Value<String>? status,
    Value<DateTime?>? dueDate,
    Value<DateTime?>? completedAt,
    Value<String?>? notes,
    Value<bool>? reminderScheduled,
    Value<DateTime>? localUpdatedAt,
  }) {
    return TasksTableCompanion(
      localId: localId ?? this.localId,
      serverId: serverId ?? this.serverId,
      syncStatus: syncStatus ?? this.syncStatus,
      contactLocalId: contactLocalId ?? this.contactLocalId,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      dueDate: dueDate ?? this.dueDate,
      completedAt: completedAt ?? this.completedAt,
      notes: notes ?? this.notes,
      reminderScheduled: reminderScheduled ?? this.reminderScheduled,
      localUpdatedAt: localUpdatedAt ?? this.localUpdatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (localId.present) {
      map['local_id'] = Variable<int>(localId.value);
    }
    if (serverId.present) {
      map['server_id'] = Variable<String>(serverId.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (contactLocalId.present) {
      map['contact_local_id'] = Variable<int>(contactLocalId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (priority.present) {
      map['priority'] = Variable<String>(priority.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (dueDate.present) {
      map['due_date'] = Variable<DateTime>(dueDate.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (reminderScheduled.present) {
      map['reminder_scheduled'] = Variable<bool>(reminderScheduled.value);
    }
    if (localUpdatedAt.present) {
      map['local_updated_at'] = Variable<DateTime>(localUpdatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TasksTableCompanion(')
          ..write('localId: $localId, ')
          ..write('serverId: $serverId, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('contactLocalId: $contactLocalId, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('priority: $priority, ')
          ..write('status: $status, ')
          ..write('dueDate: $dueDate, ')
          ..write('completedAt: $completedAt, ')
          ..write('notes: $notes, ')
          ..write('reminderScheduled: $reminderScheduled, ')
          ..write('localUpdatedAt: $localUpdatedAt')
          ..write(')'))
        .toString();
  }
}

class $DealsTableTable extends DealsTable
    with TableInfo<$DealsTableTable, DealEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DealsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _localIdMeta = const VerificationMeta(
    'localId',
  );
  @override
  late final GeneratedColumn<int> localId = GeneratedColumn<int>(
    'local_id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _serverIdMeta = const VerificationMeta(
    'serverId',
  );
  @override
  late final GeneratedColumn<String> serverId = GeneratedColumn<String>(
    'server_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending_create'),
  );
  static const VerificationMeta _contactLocalIdMeta = const VerificationMeta(
    'contactLocalId',
  );
  @override
  late final GeneratedColumn<int> contactLocalId = GeneratedColumn<int>(
    'contact_local_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
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
  static const VerificationMeta _stageNameMeta = const VerificationMeta(
    'stageName',
  );
  @override
  late final GeneratedColumn<String> stageName = GeneratedColumn<String>(
    'stage_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Lead'),
  );
  static const VerificationMeta _stageIdMeta = const VerificationMeta(
    'stageId',
  );
  @override
  late final GeneratedColumn<int> stageId = GeneratedColumn<int>(
    'stage_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pipelineIdMeta = const VerificationMeta(
    'pipelineId',
  );
  @override
  late final GeneratedColumn<int> pipelineId = GeneratedColumn<int>(
    'pipeline_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _probabilityMeta = const VerificationMeta(
    'probability',
  );
  @override
  late final GeneratedColumn<double> probability = GeneratedColumn<double>(
    'probability',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(100.0),
  );
  static const VerificationMeta _currencyMeta = const VerificationMeta(
    'currency',
  );
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
    'currency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('USD'),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('open'),
  );
  static const VerificationMeta _lostReasonMeta = const VerificationMeta(
    'lostReason',
  );
  @override
  late final GeneratedColumn<String> lostReason = GeneratedColumn<String>(
    'lost_reason',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
  static const VerificationMeta _expectedCloseDateMeta = const VerificationMeta(
    'expectedCloseDate',
  );
  @override
  late final GeneratedColumn<DateTime> expectedCloseDate =
      GeneratedColumn<DateTime>(
        'expected_close_date',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _localUpdatedAtMeta = const VerificationMeta(
    'localUpdatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> localUpdatedAt =
      GeneratedColumn<DateTime>(
        'local_updated_at',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  @override
  List<GeneratedColumn> get $columns => [
    localId,
    serverId,
    syncStatus,
    contactLocalId,
    title,
    stageName,
    stageId,
    pipelineId,
    amount,
    probability,
    currency,
    status,
    lostReason,
    notes,
    expectedCloseDate,
    localUpdatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'deals_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<DealEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('local_id')) {
      context.handle(
        _localIdMeta,
        localId.isAcceptableOrUnknown(data['local_id']!, _localIdMeta),
      );
    }
    if (data.containsKey('server_id')) {
      context.handle(
        _serverIdMeta,
        serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    if (data.containsKey('contact_local_id')) {
      context.handle(
        _contactLocalIdMeta,
        contactLocalId.isAcceptableOrUnknown(
          data['contact_local_id']!,
          _contactLocalIdMeta,
        ),
      );
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('stage_name')) {
      context.handle(
        _stageNameMeta,
        stageName.isAcceptableOrUnknown(data['stage_name']!, _stageNameMeta),
      );
    }
    if (data.containsKey('stage_id')) {
      context.handle(
        _stageIdMeta,
        stageId.isAcceptableOrUnknown(data['stage_id']!, _stageIdMeta),
      );
    }
    if (data.containsKey('pipeline_id')) {
      context.handle(
        _pipelineIdMeta,
        pipelineId.isAcceptableOrUnknown(data['pipeline_id']!, _pipelineIdMeta),
      );
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    }
    if (data.containsKey('probability')) {
      context.handle(
        _probabilityMeta,
        probability.isAcceptableOrUnknown(
          data['probability']!,
          _probabilityMeta,
        ),
      );
    }
    if (data.containsKey('currency')) {
      context.handle(
        _currencyMeta,
        currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('lost_reason')) {
      context.handle(
        _lostReasonMeta,
        lostReason.isAcceptableOrUnknown(data['lost_reason']!, _lostReasonMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('expected_close_date')) {
      context.handle(
        _expectedCloseDateMeta,
        expectedCloseDate.isAcceptableOrUnknown(
          data['expected_close_date']!,
          _expectedCloseDateMeta,
        ),
      );
    }
    if (data.containsKey('local_updated_at')) {
      context.handle(
        _localUpdatedAtMeta,
        localUpdatedAt.isAcceptableOrUnknown(
          data['local_updated_at']!,
          _localUpdatedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_localUpdatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {localId};
  @override
  DealEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DealEntry(
      localId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}local_id'],
      )!,
      serverId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}server_id'],
      ),
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
      contactLocalId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}contact_local_id'],
      ),
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      stageName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}stage_name'],
      )!,
      stageId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}stage_id'],
      ),
      pipelineId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pipeline_id'],
      ),
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      )!,
      probability: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}probability'],
      )!,
      currency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      lostReason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lost_reason'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      expectedCloseDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}expected_close_date'],
      ),
      localUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}local_updated_at'],
      )!,
    );
  }

  @override
  $DealsTableTable createAlias(String alias) {
    return $DealsTableTable(attachedDatabase, alias);
  }
}

class DealEntry extends DataClass implements Insertable<DealEntry> {
  final int localId;
  final String? serverId;
  final String syncStatus;
  final int? contactLocalId;
  final String title;
  final String stageName;
  final int? stageId;
  final int? pipelineId;
  final double amount;
  final double probability;
  final String currency;
  final String status;
  final String? lostReason;
  final String? notes;
  final DateTime? expectedCloseDate;
  final DateTime localUpdatedAt;
  const DealEntry({
    required this.localId,
    this.serverId,
    required this.syncStatus,
    this.contactLocalId,
    required this.title,
    required this.stageName,
    this.stageId,
    this.pipelineId,
    required this.amount,
    required this.probability,
    required this.currency,
    required this.status,
    this.lostReason,
    this.notes,
    this.expectedCloseDate,
    required this.localUpdatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['local_id'] = Variable<int>(localId);
    if (!nullToAbsent || serverId != null) {
      map['server_id'] = Variable<String>(serverId);
    }
    map['sync_status'] = Variable<String>(syncStatus);
    if (!nullToAbsent || contactLocalId != null) {
      map['contact_local_id'] = Variable<int>(contactLocalId);
    }
    map['title'] = Variable<String>(title);
    map['stage_name'] = Variable<String>(stageName);
    if (!nullToAbsent || stageId != null) {
      map['stage_id'] = Variable<int>(stageId);
    }
    if (!nullToAbsent || pipelineId != null) {
      map['pipeline_id'] = Variable<int>(pipelineId);
    }
    map['amount'] = Variable<double>(amount);
    map['probability'] = Variable<double>(probability);
    map['currency'] = Variable<String>(currency);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || lostReason != null) {
      map['lost_reason'] = Variable<String>(lostReason);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || expectedCloseDate != null) {
      map['expected_close_date'] = Variable<DateTime>(expectedCloseDate);
    }
    map['local_updated_at'] = Variable<DateTime>(localUpdatedAt);
    return map;
  }

  DealsTableCompanion toCompanion(bool nullToAbsent) {
    return DealsTableCompanion(
      localId: Value(localId),
      serverId: serverId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverId),
      syncStatus: Value(syncStatus),
      contactLocalId: contactLocalId == null && nullToAbsent
          ? const Value.absent()
          : Value(contactLocalId),
      title: Value(title),
      stageName: Value(stageName),
      stageId: stageId == null && nullToAbsent
          ? const Value.absent()
          : Value(stageId),
      pipelineId: pipelineId == null && nullToAbsent
          ? const Value.absent()
          : Value(pipelineId),
      amount: Value(amount),
      probability: Value(probability),
      currency: Value(currency),
      status: Value(status),
      lostReason: lostReason == null && nullToAbsent
          ? const Value.absent()
          : Value(lostReason),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      expectedCloseDate: expectedCloseDate == null && nullToAbsent
          ? const Value.absent()
          : Value(expectedCloseDate),
      localUpdatedAt: Value(localUpdatedAt),
    );
  }

  factory DealEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DealEntry(
      localId: serializer.fromJson<int>(json['localId']),
      serverId: serializer.fromJson<String?>(json['serverId']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      contactLocalId: serializer.fromJson<int?>(json['contactLocalId']),
      title: serializer.fromJson<String>(json['title']),
      stageName: serializer.fromJson<String>(json['stageName']),
      stageId: serializer.fromJson<int?>(json['stageId']),
      pipelineId: serializer.fromJson<int?>(json['pipelineId']),
      amount: serializer.fromJson<double>(json['amount']),
      probability: serializer.fromJson<double>(json['probability']),
      currency: serializer.fromJson<String>(json['currency']),
      status: serializer.fromJson<String>(json['status']),
      lostReason: serializer.fromJson<String?>(json['lostReason']),
      notes: serializer.fromJson<String?>(json['notes']),
      expectedCloseDate: serializer.fromJson<DateTime?>(
        json['expectedCloseDate'],
      ),
      localUpdatedAt: serializer.fromJson<DateTime>(json['localUpdatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'localId': serializer.toJson<int>(localId),
      'serverId': serializer.toJson<String?>(serverId),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'contactLocalId': serializer.toJson<int?>(contactLocalId),
      'title': serializer.toJson<String>(title),
      'stageName': serializer.toJson<String>(stageName),
      'stageId': serializer.toJson<int?>(stageId),
      'pipelineId': serializer.toJson<int?>(pipelineId),
      'amount': serializer.toJson<double>(amount),
      'probability': serializer.toJson<double>(probability),
      'currency': serializer.toJson<String>(currency),
      'status': serializer.toJson<String>(status),
      'lostReason': serializer.toJson<String?>(lostReason),
      'notes': serializer.toJson<String?>(notes),
      'expectedCloseDate': serializer.toJson<DateTime?>(expectedCloseDate),
      'localUpdatedAt': serializer.toJson<DateTime>(localUpdatedAt),
    };
  }

  DealEntry copyWith({
    int? localId,
    Value<String?> serverId = const Value.absent(),
    String? syncStatus,
    Value<int?> contactLocalId = const Value.absent(),
    String? title,
    String? stageName,
    Value<int?> stageId = const Value.absent(),
    Value<int?> pipelineId = const Value.absent(),
    double? amount,
    double? probability,
    String? currency,
    String? status,
    Value<String?> lostReason = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    Value<DateTime?> expectedCloseDate = const Value.absent(),
    DateTime? localUpdatedAt,
  }) => DealEntry(
    localId: localId ?? this.localId,
    serverId: serverId.present ? serverId.value : this.serverId,
    syncStatus: syncStatus ?? this.syncStatus,
    contactLocalId: contactLocalId.present
        ? contactLocalId.value
        : this.contactLocalId,
    title: title ?? this.title,
    stageName: stageName ?? this.stageName,
    stageId: stageId.present ? stageId.value : this.stageId,
    pipelineId: pipelineId.present ? pipelineId.value : this.pipelineId,
    amount: amount ?? this.amount,
    probability: probability ?? this.probability,
    currency: currency ?? this.currency,
    status: status ?? this.status,
    lostReason: lostReason.present ? lostReason.value : this.lostReason,
    notes: notes.present ? notes.value : this.notes,
    expectedCloseDate: expectedCloseDate.present
        ? expectedCloseDate.value
        : this.expectedCloseDate,
    localUpdatedAt: localUpdatedAt ?? this.localUpdatedAt,
  );
  DealEntry copyWithCompanion(DealsTableCompanion data) {
    return DealEntry(
      localId: data.localId.present ? data.localId.value : this.localId,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      contactLocalId: data.contactLocalId.present
          ? data.contactLocalId.value
          : this.contactLocalId,
      title: data.title.present ? data.title.value : this.title,
      stageName: data.stageName.present ? data.stageName.value : this.stageName,
      stageId: data.stageId.present ? data.stageId.value : this.stageId,
      pipelineId: data.pipelineId.present
          ? data.pipelineId.value
          : this.pipelineId,
      amount: data.amount.present ? data.amount.value : this.amount,
      probability: data.probability.present
          ? data.probability.value
          : this.probability,
      currency: data.currency.present ? data.currency.value : this.currency,
      status: data.status.present ? data.status.value : this.status,
      lostReason: data.lostReason.present
          ? data.lostReason.value
          : this.lostReason,
      notes: data.notes.present ? data.notes.value : this.notes,
      expectedCloseDate: data.expectedCloseDate.present
          ? data.expectedCloseDate.value
          : this.expectedCloseDate,
      localUpdatedAt: data.localUpdatedAt.present
          ? data.localUpdatedAt.value
          : this.localUpdatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DealEntry(')
          ..write('localId: $localId, ')
          ..write('serverId: $serverId, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('contactLocalId: $contactLocalId, ')
          ..write('title: $title, ')
          ..write('stageName: $stageName, ')
          ..write('stageId: $stageId, ')
          ..write('pipelineId: $pipelineId, ')
          ..write('amount: $amount, ')
          ..write('probability: $probability, ')
          ..write('currency: $currency, ')
          ..write('status: $status, ')
          ..write('lostReason: $lostReason, ')
          ..write('notes: $notes, ')
          ..write('expectedCloseDate: $expectedCloseDate, ')
          ..write('localUpdatedAt: $localUpdatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    localId,
    serverId,
    syncStatus,
    contactLocalId,
    title,
    stageName,
    stageId,
    pipelineId,
    amount,
    probability,
    currency,
    status,
    lostReason,
    notes,
    expectedCloseDate,
    localUpdatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DealEntry &&
          other.localId == this.localId &&
          other.serverId == this.serverId &&
          other.syncStatus == this.syncStatus &&
          other.contactLocalId == this.contactLocalId &&
          other.title == this.title &&
          other.stageName == this.stageName &&
          other.stageId == this.stageId &&
          other.pipelineId == this.pipelineId &&
          other.amount == this.amount &&
          other.probability == this.probability &&
          other.currency == this.currency &&
          other.status == this.status &&
          other.lostReason == this.lostReason &&
          other.notes == this.notes &&
          other.expectedCloseDate == this.expectedCloseDate &&
          other.localUpdatedAt == this.localUpdatedAt);
}

class DealsTableCompanion extends UpdateCompanion<DealEntry> {
  final Value<int> localId;
  final Value<String?> serverId;
  final Value<String> syncStatus;
  final Value<int?> contactLocalId;
  final Value<String> title;
  final Value<String> stageName;
  final Value<int?> stageId;
  final Value<int?> pipelineId;
  final Value<double> amount;
  final Value<double> probability;
  final Value<String> currency;
  final Value<String> status;
  final Value<String?> lostReason;
  final Value<String?> notes;
  final Value<DateTime?> expectedCloseDate;
  final Value<DateTime> localUpdatedAt;
  const DealsTableCompanion({
    this.localId = const Value.absent(),
    this.serverId = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.contactLocalId = const Value.absent(),
    this.title = const Value.absent(),
    this.stageName = const Value.absent(),
    this.stageId = const Value.absent(),
    this.pipelineId = const Value.absent(),
    this.amount = const Value.absent(),
    this.probability = const Value.absent(),
    this.currency = const Value.absent(),
    this.status = const Value.absent(),
    this.lostReason = const Value.absent(),
    this.notes = const Value.absent(),
    this.expectedCloseDate = const Value.absent(),
    this.localUpdatedAt = const Value.absent(),
  });
  DealsTableCompanion.insert({
    this.localId = const Value.absent(),
    this.serverId = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.contactLocalId = const Value.absent(),
    required String title,
    this.stageName = const Value.absent(),
    this.stageId = const Value.absent(),
    this.pipelineId = const Value.absent(),
    this.amount = const Value.absent(),
    this.probability = const Value.absent(),
    this.currency = const Value.absent(),
    this.status = const Value.absent(),
    this.lostReason = const Value.absent(),
    this.notes = const Value.absent(),
    this.expectedCloseDate = const Value.absent(),
    required DateTime localUpdatedAt,
  }) : title = Value(title),
       localUpdatedAt = Value(localUpdatedAt);
  static Insertable<DealEntry> custom({
    Expression<int>? localId,
    Expression<String>? serverId,
    Expression<String>? syncStatus,
    Expression<int>? contactLocalId,
    Expression<String>? title,
    Expression<String>? stageName,
    Expression<int>? stageId,
    Expression<int>? pipelineId,
    Expression<double>? amount,
    Expression<double>? probability,
    Expression<String>? currency,
    Expression<String>? status,
    Expression<String>? lostReason,
    Expression<String>? notes,
    Expression<DateTime>? expectedCloseDate,
    Expression<DateTime>? localUpdatedAt,
  }) {
    return RawValuesInsertable({
      if (localId != null) 'local_id': localId,
      if (serverId != null) 'server_id': serverId,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (contactLocalId != null) 'contact_local_id': contactLocalId,
      if (title != null) 'title': title,
      if (stageName != null) 'stage_name': stageName,
      if (stageId != null) 'stage_id': stageId,
      if (pipelineId != null) 'pipeline_id': pipelineId,
      if (amount != null) 'amount': amount,
      if (probability != null) 'probability': probability,
      if (currency != null) 'currency': currency,
      if (status != null) 'status': status,
      if (lostReason != null) 'lost_reason': lostReason,
      if (notes != null) 'notes': notes,
      if (expectedCloseDate != null) 'expected_close_date': expectedCloseDate,
      if (localUpdatedAt != null) 'local_updated_at': localUpdatedAt,
    });
  }

  DealsTableCompanion copyWith({
    Value<int>? localId,
    Value<String?>? serverId,
    Value<String>? syncStatus,
    Value<int?>? contactLocalId,
    Value<String>? title,
    Value<String>? stageName,
    Value<int?>? stageId,
    Value<int?>? pipelineId,
    Value<double>? amount,
    Value<double>? probability,
    Value<String>? currency,
    Value<String>? status,
    Value<String?>? lostReason,
    Value<String?>? notes,
    Value<DateTime?>? expectedCloseDate,
    Value<DateTime>? localUpdatedAt,
  }) {
    return DealsTableCompanion(
      localId: localId ?? this.localId,
      serverId: serverId ?? this.serverId,
      syncStatus: syncStatus ?? this.syncStatus,
      contactLocalId: contactLocalId ?? this.contactLocalId,
      title: title ?? this.title,
      stageName: stageName ?? this.stageName,
      stageId: stageId ?? this.stageId,
      pipelineId: pipelineId ?? this.pipelineId,
      amount: amount ?? this.amount,
      probability: probability ?? this.probability,
      currency: currency ?? this.currency,
      status: status ?? this.status,
      lostReason: lostReason ?? this.lostReason,
      notes: notes ?? this.notes,
      expectedCloseDate: expectedCloseDate ?? this.expectedCloseDate,
      localUpdatedAt: localUpdatedAt ?? this.localUpdatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (localId.present) {
      map['local_id'] = Variable<int>(localId.value);
    }
    if (serverId.present) {
      map['server_id'] = Variable<String>(serverId.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (contactLocalId.present) {
      map['contact_local_id'] = Variable<int>(contactLocalId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (stageName.present) {
      map['stage_name'] = Variable<String>(stageName.value);
    }
    if (stageId.present) {
      map['stage_id'] = Variable<int>(stageId.value);
    }
    if (pipelineId.present) {
      map['pipeline_id'] = Variable<int>(pipelineId.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (probability.present) {
      map['probability'] = Variable<double>(probability.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (lostReason.present) {
      map['lost_reason'] = Variable<String>(lostReason.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (expectedCloseDate.present) {
      map['expected_close_date'] = Variable<DateTime>(expectedCloseDate.value);
    }
    if (localUpdatedAt.present) {
      map['local_updated_at'] = Variable<DateTime>(localUpdatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DealsTableCompanion(')
          ..write('localId: $localId, ')
          ..write('serverId: $serverId, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('contactLocalId: $contactLocalId, ')
          ..write('title: $title, ')
          ..write('stageName: $stageName, ')
          ..write('stageId: $stageId, ')
          ..write('pipelineId: $pipelineId, ')
          ..write('amount: $amount, ')
          ..write('probability: $probability, ')
          ..write('currency: $currency, ')
          ..write('status: $status, ')
          ..write('lostReason: $lostReason, ')
          ..write('notes: $notes, ')
          ..write('expectedCloseDate: $expectedCloseDate, ')
          ..write('localUpdatedAt: $localUpdatedAt')
          ..write(')'))
        .toString();
  }
}

class $SyncQueueTableTable extends SyncQueueTable
    with TableInfo<$SyncQueueTableTable, SyncQueueEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncQueueTableTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _entityTypeMeta = const VerificationMeta(
    'entityType',
  );
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
    'entity_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityLocalIdMeta = const VerificationMeta(
    'entityLocalId',
  );
  @override
  late final GeneratedColumn<int> entityLocalId = GeneratedColumn<int>(
    'entity_local_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _operationMeta = const VerificationMeta(
    'operation',
  );
  @override
  late final GeneratedColumn<String> operation = GeneratedColumn<String>(
    'operation',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadJsonMeta = const VerificationMeta(
    'payloadJson',
  );
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
    'payload_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  static const VerificationMeta _retryCountMeta = const VerificationMeta(
    'retryCount',
  );
  @override
  late final GeneratedColumn<int> retryCount = GeneratedColumn<int>(
    'retry_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    entityType,
    entityLocalId,
    operation,
    payloadJson,
    createdAt,
    retryCount,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_queue_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncQueueEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('entity_type')) {
      context.handle(
        _entityTypeMeta,
        entityType.isAcceptableOrUnknown(data['entity_type']!, _entityTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('entity_local_id')) {
      context.handle(
        _entityLocalIdMeta,
        entityLocalId.isAcceptableOrUnknown(
          data['entity_local_id']!,
          _entityLocalIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_entityLocalIdMeta);
    }
    if (data.containsKey('operation')) {
      context.handle(
        _operationMeta,
        operation.isAcceptableOrUnknown(data['operation']!, _operationMeta),
      );
    } else if (isInserting) {
      context.missing(_operationMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
        _payloadJsonMeta,
        payloadJson.isAcceptableOrUnknown(
          data['payload_json']!,
          _payloadJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('retry_count')) {
      context.handle(
        _retryCountMeta,
        retryCount.isAcceptableOrUnknown(data['retry_count']!, _retryCountMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncQueueEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncQueueEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      entityType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_type'],
      )!,
      entityLocalId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}entity_local_id'],
      )!,
      operation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}operation'],
      )!,
      payloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_json'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      retryCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}retry_count'],
      )!,
    );
  }

  @override
  $SyncQueueTableTable createAlias(String alias) {
    return $SyncQueueTableTable(attachedDatabase, alias);
  }
}

class SyncQueueEntry extends DataClass implements Insertable<SyncQueueEntry> {
  final int id;
  final String entityType;
  final int entityLocalId;
  final String operation;
  final String payloadJson;
  final DateTime createdAt;
  final int retryCount;
  const SyncQueueEntry({
    required this.id,
    required this.entityType,
    required this.entityLocalId,
    required this.operation,
    required this.payloadJson,
    required this.createdAt,
    required this.retryCount,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['entity_type'] = Variable<String>(entityType);
    map['entity_local_id'] = Variable<int>(entityLocalId);
    map['operation'] = Variable<String>(operation);
    map['payload_json'] = Variable<String>(payloadJson);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['retry_count'] = Variable<int>(retryCount);
    return map;
  }

  SyncQueueTableCompanion toCompanion(bool nullToAbsent) {
    return SyncQueueTableCompanion(
      id: Value(id),
      entityType: Value(entityType),
      entityLocalId: Value(entityLocalId),
      operation: Value(operation),
      payloadJson: Value(payloadJson),
      createdAt: Value(createdAt),
      retryCount: Value(retryCount),
    );
  }

  factory SyncQueueEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncQueueEntry(
      id: serializer.fromJson<int>(json['id']),
      entityType: serializer.fromJson<String>(json['entityType']),
      entityLocalId: serializer.fromJson<int>(json['entityLocalId']),
      operation: serializer.fromJson<String>(json['operation']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      retryCount: serializer.fromJson<int>(json['retryCount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'entityType': serializer.toJson<String>(entityType),
      'entityLocalId': serializer.toJson<int>(entityLocalId),
      'operation': serializer.toJson<String>(operation),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'retryCount': serializer.toJson<int>(retryCount),
    };
  }

  SyncQueueEntry copyWith({
    int? id,
    String? entityType,
    int? entityLocalId,
    String? operation,
    String? payloadJson,
    DateTime? createdAt,
    int? retryCount,
  }) => SyncQueueEntry(
    id: id ?? this.id,
    entityType: entityType ?? this.entityType,
    entityLocalId: entityLocalId ?? this.entityLocalId,
    operation: operation ?? this.operation,
    payloadJson: payloadJson ?? this.payloadJson,
    createdAt: createdAt ?? this.createdAt,
    retryCount: retryCount ?? this.retryCount,
  );
  SyncQueueEntry copyWithCompanion(SyncQueueTableCompanion data) {
    return SyncQueueEntry(
      id: data.id.present ? data.id.value : this.id,
      entityType: data.entityType.present
          ? data.entityType.value
          : this.entityType,
      entityLocalId: data.entityLocalId.present
          ? data.entityLocalId.value
          : this.entityLocalId,
      operation: data.operation.present ? data.operation.value : this.operation,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      retryCount: data.retryCount.present
          ? data.retryCount.value
          : this.retryCount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueEntry(')
          ..write('id: $id, ')
          ..write('entityType: $entityType, ')
          ..write('entityLocalId: $entityLocalId, ')
          ..write('operation: $operation, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('retryCount: $retryCount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    entityType,
    entityLocalId,
    operation,
    payloadJson,
    createdAt,
    retryCount,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncQueueEntry &&
          other.id == this.id &&
          other.entityType == this.entityType &&
          other.entityLocalId == this.entityLocalId &&
          other.operation == this.operation &&
          other.payloadJson == this.payloadJson &&
          other.createdAt == this.createdAt &&
          other.retryCount == this.retryCount);
}

class SyncQueueTableCompanion extends UpdateCompanion<SyncQueueEntry> {
  final Value<int> id;
  final Value<String> entityType;
  final Value<int> entityLocalId;
  final Value<String> operation;
  final Value<String> payloadJson;
  final Value<DateTime> createdAt;
  final Value<int> retryCount;
  const SyncQueueTableCompanion({
    this.id = const Value.absent(),
    this.entityType = const Value.absent(),
    this.entityLocalId = const Value.absent(),
    this.operation = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.retryCount = const Value.absent(),
  });
  SyncQueueTableCompanion.insert({
    this.id = const Value.absent(),
    required String entityType,
    required int entityLocalId,
    required String operation,
    required String payloadJson,
    required DateTime createdAt,
    this.retryCount = const Value.absent(),
  }) : entityType = Value(entityType),
       entityLocalId = Value(entityLocalId),
       operation = Value(operation),
       payloadJson = Value(payloadJson),
       createdAt = Value(createdAt);
  static Insertable<SyncQueueEntry> custom({
    Expression<int>? id,
    Expression<String>? entityType,
    Expression<int>? entityLocalId,
    Expression<String>? operation,
    Expression<String>? payloadJson,
    Expression<DateTime>? createdAt,
    Expression<int>? retryCount,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (entityType != null) 'entity_type': entityType,
      if (entityLocalId != null) 'entity_local_id': entityLocalId,
      if (operation != null) 'operation': operation,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (createdAt != null) 'created_at': createdAt,
      if (retryCount != null) 'retry_count': retryCount,
    });
  }

  SyncQueueTableCompanion copyWith({
    Value<int>? id,
    Value<String>? entityType,
    Value<int>? entityLocalId,
    Value<String>? operation,
    Value<String>? payloadJson,
    Value<DateTime>? createdAt,
    Value<int>? retryCount,
  }) {
    return SyncQueueTableCompanion(
      id: id ?? this.id,
      entityType: entityType ?? this.entityType,
      entityLocalId: entityLocalId ?? this.entityLocalId,
      operation: operation ?? this.operation,
      payloadJson: payloadJson ?? this.payloadJson,
      createdAt: createdAt ?? this.createdAt,
      retryCount: retryCount ?? this.retryCount,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (entityLocalId.present) {
      map['entity_local_id'] = Variable<int>(entityLocalId.value);
    }
    if (operation.present) {
      map['operation'] = Variable<String>(operation.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (retryCount.present) {
      map['retry_count'] = Variable<int>(retryCount.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueTableCompanion(')
          ..write('id: $id, ')
          ..write('entityType: $entityType, ')
          ..write('entityLocalId: $entityLocalId, ')
          ..write('operation: $operation, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('retryCount: $retryCount')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ContactsTableTable contactsTable = $ContactsTableTable(this);
  late final $ActivitiesTableTable activitiesTable = $ActivitiesTableTable(
    this,
  );
  late final $TasksTableTable tasksTable = $TasksTableTable(this);
  late final $DealsTableTable dealsTable = $DealsTableTable(this);
  late final $SyncQueueTableTable syncQueueTable = $SyncQueueTableTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    contactsTable,
    activitiesTable,
    tasksTable,
    dealsTable,
    syncQueueTable,
  ];
}

typedef $$ContactsTableTableCreateCompanionBuilder =
    ContactsTableCompanion Function({
      Value<int> localId,
      Value<String?> serverId,
      Value<String> syncStatus,
      required String firstName,
      Value<String?> middleName,
      Value<String?> lastName,
      Value<String?> email,
      Value<String?> phone,
      Value<String?> alternatePhone,
      Value<String?> tin,
      Value<String?> vrn,
      Value<String?> company,
      Value<String?> title,
      Value<String?> infoSource,
      Value<String?> leadStatus,
      Value<int> leadScore,
      Value<bool> isCustomer,
      Value<String?> notes,
      Value<bool> isActive,
      required DateTime localUpdatedAt,
      Value<DateTime?> serverUpdatedAt,
    });
typedef $$ContactsTableTableUpdateCompanionBuilder =
    ContactsTableCompanion Function({
      Value<int> localId,
      Value<String?> serverId,
      Value<String> syncStatus,
      Value<String> firstName,
      Value<String?> middleName,
      Value<String?> lastName,
      Value<String?> email,
      Value<String?> phone,
      Value<String?> alternatePhone,
      Value<String?> tin,
      Value<String?> vrn,
      Value<String?> company,
      Value<String?> title,
      Value<String?> infoSource,
      Value<String?> leadStatus,
      Value<int> leadScore,
      Value<bool> isCustomer,
      Value<String?> notes,
      Value<bool> isActive,
      Value<DateTime> localUpdatedAt,
      Value<DateTime?> serverUpdatedAt,
    });

class $$ContactsTableTableFilterComposer
    extends Composer<_$AppDatabase, $ContactsTableTable> {
  $$ContactsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get localId => $composableBuilder(
    column: $table.localId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get firstName => $composableBuilder(
    column: $table.firstName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get middleName => $composableBuilder(
    column: $table.middleName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastName => $composableBuilder(
    column: $table.lastName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get alternatePhone => $composableBuilder(
    column: $table.alternatePhone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tin => $composableBuilder(
    column: $table.tin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get vrn => $composableBuilder(
    column: $table.vrn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get company => $composableBuilder(
    column: $table.company,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get infoSource => $composableBuilder(
    column: $table.infoSource,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get leadStatus => $composableBuilder(
    column: $table.leadStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get leadScore => $composableBuilder(
    column: $table.leadScore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCustomer => $composableBuilder(
    column: $table.isCustomer,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get localUpdatedAt => $composableBuilder(
    column: $table.localUpdatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ContactsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $ContactsTableTable> {
  $$ContactsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get localId => $composableBuilder(
    column: $table.localId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get firstName => $composableBuilder(
    column: $table.firstName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get middleName => $composableBuilder(
    column: $table.middleName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastName => $composableBuilder(
    column: $table.lastName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get alternatePhone => $composableBuilder(
    column: $table.alternatePhone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tin => $composableBuilder(
    column: $table.tin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get vrn => $composableBuilder(
    column: $table.vrn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get company => $composableBuilder(
    column: $table.company,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get infoSource => $composableBuilder(
    column: $table.infoSource,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get leadStatus => $composableBuilder(
    column: $table.leadStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get leadScore => $composableBuilder(
    column: $table.leadScore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCustomer => $composableBuilder(
    column: $table.isCustomer,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get localUpdatedAt => $composableBuilder(
    column: $table.localUpdatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ContactsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $ContactsTableTable> {
  $$ContactsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get localId =>
      $composableBuilder(column: $table.localId, builder: (column) => column);

  GeneratedColumn<String> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<String> get firstName =>
      $composableBuilder(column: $table.firstName, builder: (column) => column);

  GeneratedColumn<String> get middleName => $composableBuilder(
    column: $table.middleName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastName =>
      $composableBuilder(column: $table.lastName, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get alternatePhone => $composableBuilder(
    column: $table.alternatePhone,
    builder: (column) => column,
  );

  GeneratedColumn<String> get tin =>
      $composableBuilder(column: $table.tin, builder: (column) => column);

  GeneratedColumn<String> get vrn =>
      $composableBuilder(column: $table.vrn, builder: (column) => column);

  GeneratedColumn<String> get company =>
      $composableBuilder(column: $table.company, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get infoSource => $composableBuilder(
    column: $table.infoSource,
    builder: (column) => column,
  );

  GeneratedColumn<String> get leadStatus => $composableBuilder(
    column: $table.leadStatus,
    builder: (column) => column,
  );

  GeneratedColumn<int> get leadScore =>
      $composableBuilder(column: $table.leadScore, builder: (column) => column);

  GeneratedColumn<bool> get isCustomer => $composableBuilder(
    column: $table.isCustomer,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get localUpdatedAt => $composableBuilder(
    column: $table.localUpdatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => column,
  );
}

class $$ContactsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ContactsTableTable,
          ContactEntry,
          $$ContactsTableTableFilterComposer,
          $$ContactsTableTableOrderingComposer,
          $$ContactsTableTableAnnotationComposer,
          $$ContactsTableTableCreateCompanionBuilder,
          $$ContactsTableTableUpdateCompanionBuilder,
          (
            ContactEntry,
            BaseReferences<_$AppDatabase, $ContactsTableTable, ContactEntry>,
          ),
          ContactEntry,
          PrefetchHooks Function()
        > {
  $$ContactsTableTableTableManager(_$AppDatabase db, $ContactsTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ContactsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ContactsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ContactsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> localId = const Value.absent(),
                Value<String?> serverId = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<String> firstName = const Value.absent(),
                Value<String?> middleName = const Value.absent(),
                Value<String?> lastName = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String?> alternatePhone = const Value.absent(),
                Value<String?> tin = const Value.absent(),
                Value<String?> vrn = const Value.absent(),
                Value<String?> company = const Value.absent(),
                Value<String?> title = const Value.absent(),
                Value<String?> infoSource = const Value.absent(),
                Value<String?> leadStatus = const Value.absent(),
                Value<int> leadScore = const Value.absent(),
                Value<bool> isCustomer = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> localUpdatedAt = const Value.absent(),
                Value<DateTime?> serverUpdatedAt = const Value.absent(),
              }) => ContactsTableCompanion(
                localId: localId,
                serverId: serverId,
                syncStatus: syncStatus,
                firstName: firstName,
                middleName: middleName,
                lastName: lastName,
                email: email,
                phone: phone,
                alternatePhone: alternatePhone,
                tin: tin,
                vrn: vrn,
                company: company,
                title: title,
                infoSource: infoSource,
                leadStatus: leadStatus,
                leadScore: leadScore,
                isCustomer: isCustomer,
                notes: notes,
                isActive: isActive,
                localUpdatedAt: localUpdatedAt,
                serverUpdatedAt: serverUpdatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> localId = const Value.absent(),
                Value<String?> serverId = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                required String firstName,
                Value<String?> middleName = const Value.absent(),
                Value<String?> lastName = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String?> alternatePhone = const Value.absent(),
                Value<String?> tin = const Value.absent(),
                Value<String?> vrn = const Value.absent(),
                Value<String?> company = const Value.absent(),
                Value<String?> title = const Value.absent(),
                Value<String?> infoSource = const Value.absent(),
                Value<String?> leadStatus = const Value.absent(),
                Value<int> leadScore = const Value.absent(),
                Value<bool> isCustomer = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                required DateTime localUpdatedAt,
                Value<DateTime?> serverUpdatedAt = const Value.absent(),
              }) => ContactsTableCompanion.insert(
                localId: localId,
                serverId: serverId,
                syncStatus: syncStatus,
                firstName: firstName,
                middleName: middleName,
                lastName: lastName,
                email: email,
                phone: phone,
                alternatePhone: alternatePhone,
                tin: tin,
                vrn: vrn,
                company: company,
                title: title,
                infoSource: infoSource,
                leadStatus: leadStatus,
                leadScore: leadScore,
                isCustomer: isCustomer,
                notes: notes,
                isActive: isActive,
                localUpdatedAt: localUpdatedAt,
                serverUpdatedAt: serverUpdatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ContactsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ContactsTableTable,
      ContactEntry,
      $$ContactsTableTableFilterComposer,
      $$ContactsTableTableOrderingComposer,
      $$ContactsTableTableAnnotationComposer,
      $$ContactsTableTableCreateCompanionBuilder,
      $$ContactsTableTableUpdateCompanionBuilder,
      (
        ContactEntry,
        BaseReferences<_$AppDatabase, $ContactsTableTable, ContactEntry>,
      ),
      ContactEntry,
      PrefetchHooks Function()
    >;
typedef $$ActivitiesTableTableCreateCompanionBuilder =
    ActivitiesTableCompanion Function({
      Value<int> localId,
      Value<String?> serverId,
      Value<String> syncStatus,
      Value<int?> contactLocalId,
      required String type,
      Value<String?> subject,
      Value<String?> description,
      Value<String> direction,
      Value<int> duration,
      Value<String?> outcome,
      Value<DateTime?> scheduledAt,
      Value<DateTime?> completedAt,
      Value<String?> location,
      Value<bool> isCompleted,
      required DateTime localUpdatedAt,
    });
typedef $$ActivitiesTableTableUpdateCompanionBuilder =
    ActivitiesTableCompanion Function({
      Value<int> localId,
      Value<String?> serverId,
      Value<String> syncStatus,
      Value<int?> contactLocalId,
      Value<String> type,
      Value<String?> subject,
      Value<String?> description,
      Value<String> direction,
      Value<int> duration,
      Value<String?> outcome,
      Value<DateTime?> scheduledAt,
      Value<DateTime?> completedAt,
      Value<String?> location,
      Value<bool> isCompleted,
      Value<DateTime> localUpdatedAt,
    });

class $$ActivitiesTableTableFilterComposer
    extends Composer<_$AppDatabase, $ActivitiesTableTable> {
  $$ActivitiesTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get localId => $composableBuilder(
    column: $table.localId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get contactLocalId => $composableBuilder(
    column: $table.contactLocalId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get subject => $composableBuilder(
    column: $table.subject,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get direction => $composableBuilder(
    column: $table.direction,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get duration => $composableBuilder(
    column: $table.duration,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get outcome => $composableBuilder(
    column: $table.outcome,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get scheduledAt => $composableBuilder(
    column: $table.scheduledAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get localUpdatedAt => $composableBuilder(
    column: $table.localUpdatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ActivitiesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $ActivitiesTableTable> {
  $$ActivitiesTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get localId => $composableBuilder(
    column: $table.localId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get contactLocalId => $composableBuilder(
    column: $table.contactLocalId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get subject => $composableBuilder(
    column: $table.subject,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get direction => $composableBuilder(
    column: $table.direction,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get duration => $composableBuilder(
    column: $table.duration,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get outcome => $composableBuilder(
    column: $table.outcome,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get scheduledAt => $composableBuilder(
    column: $table.scheduledAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get localUpdatedAt => $composableBuilder(
    column: $table.localUpdatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ActivitiesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $ActivitiesTableTable> {
  $$ActivitiesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get localId =>
      $composableBuilder(column: $table.localId, builder: (column) => column);

  GeneratedColumn<String> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<int> get contactLocalId => $composableBuilder(
    column: $table.contactLocalId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get subject =>
      $composableBuilder(column: $table.subject, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get direction =>
      $composableBuilder(column: $table.direction, builder: (column) => column);

  GeneratedColumn<int> get duration =>
      $composableBuilder(column: $table.duration, builder: (column) => column);

  GeneratedColumn<String> get outcome =>
      $composableBuilder(column: $table.outcome, builder: (column) => column);

  GeneratedColumn<DateTime> get scheduledAt => $composableBuilder(
    column: $table.scheduledAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get location =>
      $composableBuilder(column: $table.location, builder: (column) => column);

  GeneratedColumn<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get localUpdatedAt => $composableBuilder(
    column: $table.localUpdatedAt,
    builder: (column) => column,
  );
}

class $$ActivitiesTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ActivitiesTableTable,
          ActivityEntry,
          $$ActivitiesTableTableFilterComposer,
          $$ActivitiesTableTableOrderingComposer,
          $$ActivitiesTableTableAnnotationComposer,
          $$ActivitiesTableTableCreateCompanionBuilder,
          $$ActivitiesTableTableUpdateCompanionBuilder,
          (
            ActivityEntry,
            BaseReferences<_$AppDatabase, $ActivitiesTableTable, ActivityEntry>,
          ),
          ActivityEntry,
          PrefetchHooks Function()
        > {
  $$ActivitiesTableTableTableManager(
    _$AppDatabase db,
    $ActivitiesTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ActivitiesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ActivitiesTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ActivitiesTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> localId = const Value.absent(),
                Value<String?> serverId = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int?> contactLocalId = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String?> subject = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String> direction = const Value.absent(),
                Value<int> duration = const Value.absent(),
                Value<String?> outcome = const Value.absent(),
                Value<DateTime?> scheduledAt = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<String?> location = const Value.absent(),
                Value<bool> isCompleted = const Value.absent(),
                Value<DateTime> localUpdatedAt = const Value.absent(),
              }) => ActivitiesTableCompanion(
                localId: localId,
                serverId: serverId,
                syncStatus: syncStatus,
                contactLocalId: contactLocalId,
                type: type,
                subject: subject,
                description: description,
                direction: direction,
                duration: duration,
                outcome: outcome,
                scheduledAt: scheduledAt,
                completedAt: completedAt,
                location: location,
                isCompleted: isCompleted,
                localUpdatedAt: localUpdatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> localId = const Value.absent(),
                Value<String?> serverId = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int?> contactLocalId = const Value.absent(),
                required String type,
                Value<String?> subject = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String> direction = const Value.absent(),
                Value<int> duration = const Value.absent(),
                Value<String?> outcome = const Value.absent(),
                Value<DateTime?> scheduledAt = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<String?> location = const Value.absent(),
                Value<bool> isCompleted = const Value.absent(),
                required DateTime localUpdatedAt,
              }) => ActivitiesTableCompanion.insert(
                localId: localId,
                serverId: serverId,
                syncStatus: syncStatus,
                contactLocalId: contactLocalId,
                type: type,
                subject: subject,
                description: description,
                direction: direction,
                duration: duration,
                outcome: outcome,
                scheduledAt: scheduledAt,
                completedAt: completedAt,
                location: location,
                isCompleted: isCompleted,
                localUpdatedAt: localUpdatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ActivitiesTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ActivitiesTableTable,
      ActivityEntry,
      $$ActivitiesTableTableFilterComposer,
      $$ActivitiesTableTableOrderingComposer,
      $$ActivitiesTableTableAnnotationComposer,
      $$ActivitiesTableTableCreateCompanionBuilder,
      $$ActivitiesTableTableUpdateCompanionBuilder,
      (
        ActivityEntry,
        BaseReferences<_$AppDatabase, $ActivitiesTableTable, ActivityEntry>,
      ),
      ActivityEntry,
      PrefetchHooks Function()
    >;
typedef $$TasksTableTableCreateCompanionBuilder =
    TasksTableCompanion Function({
      Value<int> localId,
      Value<String?> serverId,
      Value<String> syncStatus,
      Value<int?> contactLocalId,
      required String title,
      Value<String?> description,
      Value<String> priority,
      Value<String> status,
      Value<DateTime?> dueDate,
      Value<DateTime?> completedAt,
      Value<String?> notes,
      Value<bool> reminderScheduled,
      required DateTime localUpdatedAt,
    });
typedef $$TasksTableTableUpdateCompanionBuilder =
    TasksTableCompanion Function({
      Value<int> localId,
      Value<String?> serverId,
      Value<String> syncStatus,
      Value<int?> contactLocalId,
      Value<String> title,
      Value<String?> description,
      Value<String> priority,
      Value<String> status,
      Value<DateTime?> dueDate,
      Value<DateTime?> completedAt,
      Value<String?> notes,
      Value<bool> reminderScheduled,
      Value<DateTime> localUpdatedAt,
    });

class $$TasksTableTableFilterComposer
    extends Composer<_$AppDatabase, $TasksTableTable> {
  $$TasksTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get localId => $composableBuilder(
    column: $table.localId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get contactLocalId => $composableBuilder(
    column: $table.contactLocalId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get reminderScheduled => $composableBuilder(
    column: $table.reminderScheduled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get localUpdatedAt => $composableBuilder(
    column: $table.localUpdatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TasksTableTableOrderingComposer
    extends Composer<_$AppDatabase, $TasksTableTable> {
  $$TasksTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get localId => $composableBuilder(
    column: $table.localId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get contactLocalId => $composableBuilder(
    column: $table.contactLocalId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get reminderScheduled => $composableBuilder(
    column: $table.reminderScheduled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get localUpdatedAt => $composableBuilder(
    column: $table.localUpdatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TasksTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $TasksTableTable> {
  $$TasksTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get localId =>
      $composableBuilder(column: $table.localId, builder: (column) => column);

  GeneratedColumn<String> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<int> get contactLocalId => $composableBuilder(
    column: $table.contactLocalId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get dueDate =>
      $composableBuilder(column: $table.dueDate, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<bool> get reminderScheduled => $composableBuilder(
    column: $table.reminderScheduled,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get localUpdatedAt => $composableBuilder(
    column: $table.localUpdatedAt,
    builder: (column) => column,
  );
}

class $$TasksTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TasksTableTable,
          TaskEntry,
          $$TasksTableTableFilterComposer,
          $$TasksTableTableOrderingComposer,
          $$TasksTableTableAnnotationComposer,
          $$TasksTableTableCreateCompanionBuilder,
          $$TasksTableTableUpdateCompanionBuilder,
          (
            TaskEntry,
            BaseReferences<_$AppDatabase, $TasksTableTable, TaskEntry>,
          ),
          TaskEntry,
          PrefetchHooks Function()
        > {
  $$TasksTableTableTableManager(_$AppDatabase db, $TasksTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TasksTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TasksTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TasksTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> localId = const Value.absent(),
                Value<String?> serverId = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int?> contactLocalId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String> priority = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime?> dueDate = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<bool> reminderScheduled = const Value.absent(),
                Value<DateTime> localUpdatedAt = const Value.absent(),
              }) => TasksTableCompanion(
                localId: localId,
                serverId: serverId,
                syncStatus: syncStatus,
                contactLocalId: contactLocalId,
                title: title,
                description: description,
                priority: priority,
                status: status,
                dueDate: dueDate,
                completedAt: completedAt,
                notes: notes,
                reminderScheduled: reminderScheduled,
                localUpdatedAt: localUpdatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> localId = const Value.absent(),
                Value<String?> serverId = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int?> contactLocalId = const Value.absent(),
                required String title,
                Value<String?> description = const Value.absent(),
                Value<String> priority = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime?> dueDate = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<bool> reminderScheduled = const Value.absent(),
                required DateTime localUpdatedAt,
              }) => TasksTableCompanion.insert(
                localId: localId,
                serverId: serverId,
                syncStatus: syncStatus,
                contactLocalId: contactLocalId,
                title: title,
                description: description,
                priority: priority,
                status: status,
                dueDate: dueDate,
                completedAt: completedAt,
                notes: notes,
                reminderScheduled: reminderScheduled,
                localUpdatedAt: localUpdatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TasksTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TasksTableTable,
      TaskEntry,
      $$TasksTableTableFilterComposer,
      $$TasksTableTableOrderingComposer,
      $$TasksTableTableAnnotationComposer,
      $$TasksTableTableCreateCompanionBuilder,
      $$TasksTableTableUpdateCompanionBuilder,
      (TaskEntry, BaseReferences<_$AppDatabase, $TasksTableTable, TaskEntry>),
      TaskEntry,
      PrefetchHooks Function()
    >;
typedef $$DealsTableTableCreateCompanionBuilder =
    DealsTableCompanion Function({
      Value<int> localId,
      Value<String?> serverId,
      Value<String> syncStatus,
      Value<int?> contactLocalId,
      required String title,
      Value<String> stageName,
      Value<int?> stageId,
      Value<int?> pipelineId,
      Value<double> amount,
      Value<double> probability,
      Value<String> currency,
      Value<String> status,
      Value<String?> lostReason,
      Value<String?> notes,
      Value<DateTime?> expectedCloseDate,
      required DateTime localUpdatedAt,
    });
typedef $$DealsTableTableUpdateCompanionBuilder =
    DealsTableCompanion Function({
      Value<int> localId,
      Value<String?> serverId,
      Value<String> syncStatus,
      Value<int?> contactLocalId,
      Value<String> title,
      Value<String> stageName,
      Value<int?> stageId,
      Value<int?> pipelineId,
      Value<double> amount,
      Value<double> probability,
      Value<String> currency,
      Value<String> status,
      Value<String?> lostReason,
      Value<String?> notes,
      Value<DateTime?> expectedCloseDate,
      Value<DateTime> localUpdatedAt,
    });

class $$DealsTableTableFilterComposer
    extends Composer<_$AppDatabase, $DealsTableTable> {
  $$DealsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get localId => $composableBuilder(
    column: $table.localId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get contactLocalId => $composableBuilder(
    column: $table.contactLocalId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get stageName => $composableBuilder(
    column: $table.stageName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get stageId => $composableBuilder(
    column: $table.stageId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pipelineId => $composableBuilder(
    column: $table.pipelineId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get probability => $composableBuilder(
    column: $table.probability,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lostReason => $composableBuilder(
    column: $table.lostReason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get expectedCloseDate => $composableBuilder(
    column: $table.expectedCloseDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get localUpdatedAt => $composableBuilder(
    column: $table.localUpdatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DealsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $DealsTableTable> {
  $$DealsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get localId => $composableBuilder(
    column: $table.localId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get contactLocalId => $composableBuilder(
    column: $table.contactLocalId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get stageName => $composableBuilder(
    column: $table.stageName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get stageId => $composableBuilder(
    column: $table.stageId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pipelineId => $composableBuilder(
    column: $table.pipelineId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get probability => $composableBuilder(
    column: $table.probability,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lostReason => $composableBuilder(
    column: $table.lostReason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get expectedCloseDate => $composableBuilder(
    column: $table.expectedCloseDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get localUpdatedAt => $composableBuilder(
    column: $table.localUpdatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DealsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $DealsTableTable> {
  $$DealsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get localId =>
      $composableBuilder(column: $table.localId, builder: (column) => column);

  GeneratedColumn<String> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<int> get contactLocalId => $composableBuilder(
    column: $table.contactLocalId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get stageName =>
      $composableBuilder(column: $table.stageName, builder: (column) => column);

  GeneratedColumn<int> get stageId =>
      $composableBuilder(column: $table.stageId, builder: (column) => column);

  GeneratedColumn<int> get pipelineId => $composableBuilder(
    column: $table.pipelineId,
    builder: (column) => column,
  );

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<double> get probability => $composableBuilder(
    column: $table.probability,
    builder: (column) => column,
  );

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get lostReason => $composableBuilder(
    column: $table.lostReason,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get expectedCloseDate => $composableBuilder(
    column: $table.expectedCloseDate,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get localUpdatedAt => $composableBuilder(
    column: $table.localUpdatedAt,
    builder: (column) => column,
  );
}

class $$DealsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DealsTableTable,
          DealEntry,
          $$DealsTableTableFilterComposer,
          $$DealsTableTableOrderingComposer,
          $$DealsTableTableAnnotationComposer,
          $$DealsTableTableCreateCompanionBuilder,
          $$DealsTableTableUpdateCompanionBuilder,
          (
            DealEntry,
            BaseReferences<_$AppDatabase, $DealsTableTable, DealEntry>,
          ),
          DealEntry,
          PrefetchHooks Function()
        > {
  $$DealsTableTableTableManager(_$AppDatabase db, $DealsTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DealsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DealsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DealsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> localId = const Value.absent(),
                Value<String?> serverId = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int?> contactLocalId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> stageName = const Value.absent(),
                Value<int?> stageId = const Value.absent(),
                Value<int?> pipelineId = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<double> probability = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> lostReason = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime?> expectedCloseDate = const Value.absent(),
                Value<DateTime> localUpdatedAt = const Value.absent(),
              }) => DealsTableCompanion(
                localId: localId,
                serverId: serverId,
                syncStatus: syncStatus,
                contactLocalId: contactLocalId,
                title: title,
                stageName: stageName,
                stageId: stageId,
                pipelineId: pipelineId,
                amount: amount,
                probability: probability,
                currency: currency,
                status: status,
                lostReason: lostReason,
                notes: notes,
                expectedCloseDate: expectedCloseDate,
                localUpdatedAt: localUpdatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> localId = const Value.absent(),
                Value<String?> serverId = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int?> contactLocalId = const Value.absent(),
                required String title,
                Value<String> stageName = const Value.absent(),
                Value<int?> stageId = const Value.absent(),
                Value<int?> pipelineId = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<double> probability = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> lostReason = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime?> expectedCloseDate = const Value.absent(),
                required DateTime localUpdatedAt,
              }) => DealsTableCompanion.insert(
                localId: localId,
                serverId: serverId,
                syncStatus: syncStatus,
                contactLocalId: contactLocalId,
                title: title,
                stageName: stageName,
                stageId: stageId,
                pipelineId: pipelineId,
                amount: amount,
                probability: probability,
                currency: currency,
                status: status,
                lostReason: lostReason,
                notes: notes,
                expectedCloseDate: expectedCloseDate,
                localUpdatedAt: localUpdatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DealsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DealsTableTable,
      DealEntry,
      $$DealsTableTableFilterComposer,
      $$DealsTableTableOrderingComposer,
      $$DealsTableTableAnnotationComposer,
      $$DealsTableTableCreateCompanionBuilder,
      $$DealsTableTableUpdateCompanionBuilder,
      (DealEntry, BaseReferences<_$AppDatabase, $DealsTableTable, DealEntry>),
      DealEntry,
      PrefetchHooks Function()
    >;
typedef $$SyncQueueTableTableCreateCompanionBuilder =
    SyncQueueTableCompanion Function({
      Value<int> id,
      required String entityType,
      required int entityLocalId,
      required String operation,
      required String payloadJson,
      required DateTime createdAt,
      Value<int> retryCount,
    });
typedef $$SyncQueueTableTableUpdateCompanionBuilder =
    SyncQueueTableCompanion Function({
      Value<int> id,
      Value<String> entityType,
      Value<int> entityLocalId,
      Value<String> operation,
      Value<String> payloadJson,
      Value<DateTime> createdAt,
      Value<int> retryCount,
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
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get entityLocalId => $composableBuilder(
    column: $table.entityLocalId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get operation => $composableBuilder(
    column: $table.operation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => ColumnFilters(column),
  );
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
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get entityLocalId => $composableBuilder(
    column: $table.entityLocalId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get operation => $composableBuilder(
    column: $table.operation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => ColumnOrderings(column),
  );
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

  GeneratedColumn<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => column,
  );

  GeneratedColumn<int> get entityLocalId => $composableBuilder(
    column: $table.entityLocalId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get operation =>
      $composableBuilder(column: $table.operation, builder: (column) => column);

  GeneratedColumn<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => column,
  );
}

class $$SyncQueueTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncQueueTableTable,
          SyncQueueEntry,
          $$SyncQueueTableTableFilterComposer,
          $$SyncQueueTableTableOrderingComposer,
          $$SyncQueueTableTableAnnotationComposer,
          $$SyncQueueTableTableCreateCompanionBuilder,
          $$SyncQueueTableTableUpdateCompanionBuilder,
          (
            SyncQueueEntry,
            BaseReferences<_$AppDatabase, $SyncQueueTableTable, SyncQueueEntry>,
          ),
          SyncQueueEntry,
          PrefetchHooks Function()
        > {
  $$SyncQueueTableTableTableManager(
    _$AppDatabase db,
    $SyncQueueTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncQueueTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncQueueTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncQueueTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> entityType = const Value.absent(),
                Value<int> entityLocalId = const Value.absent(),
                Value<String> operation = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> retryCount = const Value.absent(),
              }) => SyncQueueTableCompanion(
                id: id,
                entityType: entityType,
                entityLocalId: entityLocalId,
                operation: operation,
                payloadJson: payloadJson,
                createdAt: createdAt,
                retryCount: retryCount,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String entityType,
                required int entityLocalId,
                required String operation,
                required String payloadJson,
                required DateTime createdAt,
                Value<int> retryCount = const Value.absent(),
              }) => SyncQueueTableCompanion.insert(
                id: id,
                entityType: entityType,
                entityLocalId: entityLocalId,
                operation: operation,
                payloadJson: payloadJson,
                createdAt: createdAt,
                retryCount: retryCount,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncQueueTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncQueueTableTable,
      SyncQueueEntry,
      $$SyncQueueTableTableFilterComposer,
      $$SyncQueueTableTableOrderingComposer,
      $$SyncQueueTableTableAnnotationComposer,
      $$SyncQueueTableTableCreateCompanionBuilder,
      $$SyncQueueTableTableUpdateCompanionBuilder,
      (
        SyncQueueEntry,
        BaseReferences<_$AppDatabase, $SyncQueueTableTable, SyncQueueEntry>,
      ),
      SyncQueueEntry,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ContactsTableTableTableManager get contactsTable =>
      $$ContactsTableTableTableManager(_db, _db.contactsTable);
  $$ActivitiesTableTableTableManager get activitiesTable =>
      $$ActivitiesTableTableTableManager(_db, _db.activitiesTable);
  $$TasksTableTableTableManager get tasksTable =>
      $$TasksTableTableTableManager(_db, _db.tasksTable);
  $$DealsTableTableTableManager get dealsTable =>
      $$DealsTableTableTableManager(_db, _db.dealsTable);
  $$SyncQueueTableTableTableManager get syncQueueTable =>
      $$SyncQueueTableTableTableManager(_db, _db.syncQueueTable);
}
