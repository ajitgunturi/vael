// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $FamiliesTable extends Families with TableInfo<$FamiliesTable, Family> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FamiliesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _baseCurrencyMeta = const VerificationMeta(
    'baseCurrency',
  );
  @override
  late final GeneratedColumn<String> baseCurrency = GeneratedColumn<String>(
    'base_currency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('INR'),
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
  List<GeneratedColumn> get $columns => [id, name, baseCurrency, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'families';
  @override
  VerificationContext validateIntegrity(
    Insertable<Family> instance, {
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
    if (data.containsKey('base_currency')) {
      context.handle(
        _baseCurrencyMeta,
        baseCurrency.isAcceptableOrUnknown(
          data['base_currency']!,
          _baseCurrencyMeta,
        ),
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
  Family map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Family(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      baseCurrency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}base_currency'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $FamiliesTable createAlias(String alias) {
    return $FamiliesTable(attachedDatabase, alias);
  }
}

class Family extends DataClass implements Insertable<Family> {
  final String id;
  final String name;
  final String baseCurrency;
  final DateTime createdAt;
  const Family({
    required this.id,
    required this.name,
    required this.baseCurrency,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['base_currency'] = Variable<String>(baseCurrency);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  FamiliesCompanion toCompanion(bool nullToAbsent) {
    return FamiliesCompanion(
      id: Value(id),
      name: Value(name),
      baseCurrency: Value(baseCurrency),
      createdAt: Value(createdAt),
    );
  }

  factory Family.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Family(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      baseCurrency: serializer.fromJson<String>(json['baseCurrency']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'baseCurrency': serializer.toJson<String>(baseCurrency),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Family copyWith({
    String? id,
    String? name,
    String? baseCurrency,
    DateTime? createdAt,
  }) => Family(
    id: id ?? this.id,
    name: name ?? this.name,
    baseCurrency: baseCurrency ?? this.baseCurrency,
    createdAt: createdAt ?? this.createdAt,
  );
  Family copyWithCompanion(FamiliesCompanion data) {
    return Family(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      baseCurrency: data.baseCurrency.present
          ? data.baseCurrency.value
          : this.baseCurrency,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Family(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('baseCurrency: $baseCurrency, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, baseCurrency, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Family &&
          other.id == this.id &&
          other.name == this.name &&
          other.baseCurrency == this.baseCurrency &&
          other.createdAt == this.createdAt);
}

class FamiliesCompanion extends UpdateCompanion<Family> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> baseCurrency;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const FamiliesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.baseCurrency = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FamiliesCompanion.insert({
    required String id,
    required String name,
    this.baseCurrency = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       createdAt = Value(createdAt);
  static Insertable<Family> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? baseCurrency,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (baseCurrency != null) 'base_currency': baseCurrency,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FamiliesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? baseCurrency,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return FamiliesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      baseCurrency: baseCurrency ?? this.baseCurrency,
      createdAt: createdAt ?? this.createdAt,
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
    if (baseCurrency.present) {
      map['base_currency'] = Variable<String>(baseCurrency.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FamiliesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('baseCurrency: $baseCurrency, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UsersTable extends Users with TableInfo<$UsersTable, User> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UsersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _avatarUrlMeta = const VerificationMeta(
    'avatarUrl',
  );
  @override
  late final GeneratedColumn<String> avatarUrl = GeneratedColumn<String>(
    'avatar_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _familyIdMeta = const VerificationMeta(
    'familyId',
  );
  @override
  late final GeneratedColumn<String> familyId = GeneratedColumn<String>(
    'family_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES families (id)',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    email,
    displayName,
    avatarUrl,
    role,
    familyId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'users';
  @override
  VerificationContext validateIntegrity(
    Insertable<User> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    } else if (isInserting) {
      context.missing(_emailMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_displayNameMeta);
    }
    if (data.containsKey('avatar_url')) {
      context.handle(
        _avatarUrlMeta,
        avatarUrl.isAcceptableOrUnknown(data['avatar_url']!, _avatarUrlMeta),
      );
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    if (data.containsKey('family_id')) {
      context.handle(
        _familyIdMeta,
        familyId.isAcceptableOrUnknown(data['family_id']!, _familyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_familyIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  User map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return User(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      )!,
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      )!,
      avatarUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}avatar_url'],
      ),
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      )!,
      familyId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}family_id'],
      )!,
    );
  }

  @override
  $UsersTable createAlias(String alias) {
    return $UsersTable(attachedDatabase, alias);
  }
}

class User extends DataClass implements Insertable<User> {
  final String id;
  final String email;
  final String displayName;
  final String? avatarUrl;
  final String role;
  final String familyId;
  const User({
    required this.id,
    required this.email,
    required this.displayName,
    this.avatarUrl,
    required this.role,
    required this.familyId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['email'] = Variable<String>(email);
    map['display_name'] = Variable<String>(displayName);
    if (!nullToAbsent || avatarUrl != null) {
      map['avatar_url'] = Variable<String>(avatarUrl);
    }
    map['role'] = Variable<String>(role);
    map['family_id'] = Variable<String>(familyId);
    return map;
  }

  UsersCompanion toCompanion(bool nullToAbsent) {
    return UsersCompanion(
      id: Value(id),
      email: Value(email),
      displayName: Value(displayName),
      avatarUrl: avatarUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(avatarUrl),
      role: Value(role),
      familyId: Value(familyId),
    );
  }

  factory User.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return User(
      id: serializer.fromJson<String>(json['id']),
      email: serializer.fromJson<String>(json['email']),
      displayName: serializer.fromJson<String>(json['displayName']),
      avatarUrl: serializer.fromJson<String?>(json['avatarUrl']),
      role: serializer.fromJson<String>(json['role']),
      familyId: serializer.fromJson<String>(json['familyId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'email': serializer.toJson<String>(email),
      'displayName': serializer.toJson<String>(displayName),
      'avatarUrl': serializer.toJson<String?>(avatarUrl),
      'role': serializer.toJson<String>(role),
      'familyId': serializer.toJson<String>(familyId),
    };
  }

  User copyWith({
    String? id,
    String? email,
    String? displayName,
    Value<String?> avatarUrl = const Value.absent(),
    String? role,
    String? familyId,
  }) => User(
    id: id ?? this.id,
    email: email ?? this.email,
    displayName: displayName ?? this.displayName,
    avatarUrl: avatarUrl.present ? avatarUrl.value : this.avatarUrl,
    role: role ?? this.role,
    familyId: familyId ?? this.familyId,
  );
  User copyWithCompanion(UsersCompanion data) {
    return User(
      id: data.id.present ? data.id.value : this.id,
      email: data.email.present ? data.email.value : this.email,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      avatarUrl: data.avatarUrl.present ? data.avatarUrl.value : this.avatarUrl,
      role: data.role.present ? data.role.value : this.role,
      familyId: data.familyId.present ? data.familyId.value : this.familyId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('User(')
          ..write('id: $id, ')
          ..write('email: $email, ')
          ..write('displayName: $displayName, ')
          ..write('avatarUrl: $avatarUrl, ')
          ..write('role: $role, ')
          ..write('familyId: $familyId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, email, displayName, avatarUrl, role, familyId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is User &&
          other.id == this.id &&
          other.email == this.email &&
          other.displayName == this.displayName &&
          other.avatarUrl == this.avatarUrl &&
          other.role == this.role &&
          other.familyId == this.familyId);
}

class UsersCompanion extends UpdateCompanion<User> {
  final Value<String> id;
  final Value<String> email;
  final Value<String> displayName;
  final Value<String?> avatarUrl;
  final Value<String> role;
  final Value<String> familyId;
  final Value<int> rowid;
  const UsersCompanion({
    this.id = const Value.absent(),
    this.email = const Value.absent(),
    this.displayName = const Value.absent(),
    this.avatarUrl = const Value.absent(),
    this.role = const Value.absent(),
    this.familyId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UsersCompanion.insert({
    required String id,
    required String email,
    required String displayName,
    this.avatarUrl = const Value.absent(),
    required String role,
    required String familyId,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       email = Value(email),
       displayName = Value(displayName),
       role = Value(role),
       familyId = Value(familyId);
  static Insertable<User> custom({
    Expression<String>? id,
    Expression<String>? email,
    Expression<String>? displayName,
    Expression<String>? avatarUrl,
    Expression<String>? role,
    Expression<String>? familyId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (email != null) 'email': email,
      if (displayName != null) 'display_name': displayName,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
      if (role != null) 'role': role,
      if (familyId != null) 'family_id': familyId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UsersCompanion copyWith({
    Value<String>? id,
    Value<String>? email,
    Value<String>? displayName,
    Value<String?>? avatarUrl,
    Value<String>? role,
    Value<String>? familyId,
    Value<int>? rowid,
  }) {
    return UsersCompanion(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
      familyId: familyId ?? this.familyId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (avatarUrl.present) {
      map['avatar_url'] = Variable<String>(avatarUrl.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (familyId.present) {
      map['family_id'] = Variable<String>(familyId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UsersCompanion(')
          ..write('id: $id, ')
          ..write('email: $email, ')
          ..write('displayName: $displayName, ')
          ..write('avatarUrl: $avatarUrl, ')
          ..write('role: $role, ')
          ..write('familyId: $familyId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AccountsTable extends Accounts with TableInfo<$AccountsTable, Account> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AccountsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _institutionMeta = const VerificationMeta(
    'institution',
  );
  @override
  late final GeneratedColumn<String> institution = GeneratedColumn<String>(
    'institution',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _balanceMeta = const VerificationMeta(
    'balance',
  );
  @override
  late final GeneratedColumn<int> balance = GeneratedColumn<int>(
    'balance',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
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
    defaultValue: const Constant('INR'),
  );
  static const VerificationMeta _visibilityMeta = const VerificationMeta(
    'visibility',
  );
  @override
  late final GeneratedColumn<String> visibility = GeneratedColumn<String>(
    'visibility',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sharedWithFamilyMeta = const VerificationMeta(
    'sharedWithFamily',
  );
  @override
  late final GeneratedColumn<bool> sharedWithFamily = GeneratedColumn<bool>(
    'shared_with_family',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("shared_with_family" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _familyIdMeta = const VerificationMeta(
    'familyId',
  );
  @override
  late final GeneratedColumn<String> familyId = GeneratedColumn<String>(
    'family_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES families (id)',
    ),
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES users (id)',
    ),
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _liquidityTierMeta = const VerificationMeta(
    'liquidityTier',
  );
  @override
  late final GeneratedColumn<String> liquidityTier = GeneratedColumn<String>(
    'liquidity_tier',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isEmergencyFundMeta = const VerificationMeta(
    'isEmergencyFund',
  );
  @override
  late final GeneratedColumn<bool> isEmergencyFund = GeneratedColumn<bool>(
    'is_emergency_fund',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_emergency_fund" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isOpportunityFundMeta = const VerificationMeta(
    'isOpportunityFund',
  );
  @override
  late final GeneratedColumn<bool> isOpportunityFund = GeneratedColumn<bool>(
    'is_opportunity_fund',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_opportunity_fund" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _opportunityFundTargetPaiseMeta =
      const VerificationMeta('opportunityFundTargetPaise');
  @override
  late final GeneratedColumn<int> opportunityFundTargetPaise =
      GeneratedColumn<int>(
        'opportunity_fund_target_paise',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _minimumBalancePaiseMeta =
      const VerificationMeta('minimumBalancePaise');
  @override
  late final GeneratedColumn<int> minimumBalancePaise = GeneratedColumn<int>(
    'minimum_balance_paise',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    type,
    institution,
    balance,
    currency,
    visibility,
    sharedWithFamily,
    familyId,
    userId,
    deletedAt,
    liquidityTier,
    isEmergencyFund,
    isOpportunityFund,
    opportunityFundTargetPaise,
    minimumBalancePaise,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'accounts';
  @override
  VerificationContext validateIntegrity(
    Insertable<Account> instance, {
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
    if (data.containsKey('institution')) {
      context.handle(
        _institutionMeta,
        institution.isAcceptableOrUnknown(
          data['institution']!,
          _institutionMeta,
        ),
      );
    }
    if (data.containsKey('balance')) {
      context.handle(
        _balanceMeta,
        balance.isAcceptableOrUnknown(data['balance']!, _balanceMeta),
      );
    } else if (isInserting) {
      context.missing(_balanceMeta);
    }
    if (data.containsKey('currency')) {
      context.handle(
        _currencyMeta,
        currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta),
      );
    }
    if (data.containsKey('visibility')) {
      context.handle(
        _visibilityMeta,
        visibility.isAcceptableOrUnknown(data['visibility']!, _visibilityMeta),
      );
    } else if (isInserting) {
      context.missing(_visibilityMeta);
    }
    if (data.containsKey('shared_with_family')) {
      context.handle(
        _sharedWithFamilyMeta,
        sharedWithFamily.isAcceptableOrUnknown(
          data['shared_with_family']!,
          _sharedWithFamilyMeta,
        ),
      );
    }
    if (data.containsKey('family_id')) {
      context.handle(
        _familyIdMeta,
        familyId.isAcceptableOrUnknown(data['family_id']!, _familyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_familyIdMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('liquidity_tier')) {
      context.handle(
        _liquidityTierMeta,
        liquidityTier.isAcceptableOrUnknown(
          data['liquidity_tier']!,
          _liquidityTierMeta,
        ),
      );
    }
    if (data.containsKey('is_emergency_fund')) {
      context.handle(
        _isEmergencyFundMeta,
        isEmergencyFund.isAcceptableOrUnknown(
          data['is_emergency_fund']!,
          _isEmergencyFundMeta,
        ),
      );
    }
    if (data.containsKey('is_opportunity_fund')) {
      context.handle(
        _isOpportunityFundMeta,
        isOpportunityFund.isAcceptableOrUnknown(
          data['is_opportunity_fund']!,
          _isOpportunityFundMeta,
        ),
      );
    }
    if (data.containsKey('opportunity_fund_target_paise')) {
      context.handle(
        _opportunityFundTargetPaiseMeta,
        opportunityFundTargetPaise.isAcceptableOrUnknown(
          data['opportunity_fund_target_paise']!,
          _opportunityFundTargetPaiseMeta,
        ),
      );
    }
    if (data.containsKey('minimum_balance_paise')) {
      context.handle(
        _minimumBalancePaiseMeta,
        minimumBalancePaise.isAcceptableOrUnknown(
          data['minimum_balance_paise']!,
          _minimumBalancePaiseMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Account map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Account(
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
      institution: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}institution'],
      ),
      balance: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}balance'],
      )!,
      currency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency'],
      )!,
      visibility: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}visibility'],
      )!,
      sharedWithFamily: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}shared_with_family'],
      )!,
      familyId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}family_id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      liquidityTier: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}liquidity_tier'],
      ),
      isEmergencyFund: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_emergency_fund'],
      )!,
      isOpportunityFund: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_opportunity_fund'],
      )!,
      opportunityFundTargetPaise: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}opportunity_fund_target_paise'],
      ),
      minimumBalancePaise: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}minimum_balance_paise'],
      ),
    );
  }

  @override
  $AccountsTable createAlias(String alias) {
    return $AccountsTable(attachedDatabase, alias);
  }
}

class Account extends DataClass implements Insertable<Account> {
  final String id;
  final String name;
  final String type;
  final String? institution;
  final int balance;
  final String currency;
  final String visibility;
  final bool sharedWithFamily;
  final String familyId;
  final String userId;
  final DateTime? deletedAt;
  final String? liquidityTier;
  final bool isEmergencyFund;
  final bool isOpportunityFund;
  final int? opportunityFundTargetPaise;
  final int? minimumBalancePaise;
  const Account({
    required this.id,
    required this.name,
    required this.type,
    this.institution,
    required this.balance,
    required this.currency,
    required this.visibility,
    required this.sharedWithFamily,
    required this.familyId,
    required this.userId,
    this.deletedAt,
    this.liquidityTier,
    required this.isEmergencyFund,
    required this.isOpportunityFund,
    this.opportunityFundTargetPaise,
    this.minimumBalancePaise,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || institution != null) {
      map['institution'] = Variable<String>(institution);
    }
    map['balance'] = Variable<int>(balance);
    map['currency'] = Variable<String>(currency);
    map['visibility'] = Variable<String>(visibility);
    map['shared_with_family'] = Variable<bool>(sharedWithFamily);
    map['family_id'] = Variable<String>(familyId);
    map['user_id'] = Variable<String>(userId);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    if (!nullToAbsent || liquidityTier != null) {
      map['liquidity_tier'] = Variable<String>(liquidityTier);
    }
    map['is_emergency_fund'] = Variable<bool>(isEmergencyFund);
    map['is_opportunity_fund'] = Variable<bool>(isOpportunityFund);
    if (!nullToAbsent || opportunityFundTargetPaise != null) {
      map['opportunity_fund_target_paise'] = Variable<int>(
        opportunityFundTargetPaise,
      );
    }
    if (!nullToAbsent || minimumBalancePaise != null) {
      map['minimum_balance_paise'] = Variable<int>(minimumBalancePaise);
    }
    return map;
  }

  AccountsCompanion toCompanion(bool nullToAbsent) {
    return AccountsCompanion(
      id: Value(id),
      name: Value(name),
      type: Value(type),
      institution: institution == null && nullToAbsent
          ? const Value.absent()
          : Value(institution),
      balance: Value(balance),
      currency: Value(currency),
      visibility: Value(visibility),
      sharedWithFamily: Value(sharedWithFamily),
      familyId: Value(familyId),
      userId: Value(userId),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      liquidityTier: liquidityTier == null && nullToAbsent
          ? const Value.absent()
          : Value(liquidityTier),
      isEmergencyFund: Value(isEmergencyFund),
      isOpportunityFund: Value(isOpportunityFund),
      opportunityFundTargetPaise:
          opportunityFundTargetPaise == null && nullToAbsent
          ? const Value.absent()
          : Value(opportunityFundTargetPaise),
      minimumBalancePaise: minimumBalancePaise == null && nullToAbsent
          ? const Value.absent()
          : Value(minimumBalancePaise),
    );
  }

  factory Account.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Account(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      type: serializer.fromJson<String>(json['type']),
      institution: serializer.fromJson<String?>(json['institution']),
      balance: serializer.fromJson<int>(json['balance']),
      currency: serializer.fromJson<String>(json['currency']),
      visibility: serializer.fromJson<String>(json['visibility']),
      sharedWithFamily: serializer.fromJson<bool>(json['sharedWithFamily']),
      familyId: serializer.fromJson<String>(json['familyId']),
      userId: serializer.fromJson<String>(json['userId']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      liquidityTier: serializer.fromJson<String?>(json['liquidityTier']),
      isEmergencyFund: serializer.fromJson<bool>(json['isEmergencyFund']),
      isOpportunityFund: serializer.fromJson<bool>(json['isOpportunityFund']),
      opportunityFundTargetPaise: serializer.fromJson<int?>(
        json['opportunityFundTargetPaise'],
      ),
      minimumBalancePaise: serializer.fromJson<int?>(
        json['minimumBalancePaise'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'type': serializer.toJson<String>(type),
      'institution': serializer.toJson<String?>(institution),
      'balance': serializer.toJson<int>(balance),
      'currency': serializer.toJson<String>(currency),
      'visibility': serializer.toJson<String>(visibility),
      'sharedWithFamily': serializer.toJson<bool>(sharedWithFamily),
      'familyId': serializer.toJson<String>(familyId),
      'userId': serializer.toJson<String>(userId),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'liquidityTier': serializer.toJson<String?>(liquidityTier),
      'isEmergencyFund': serializer.toJson<bool>(isEmergencyFund),
      'isOpportunityFund': serializer.toJson<bool>(isOpportunityFund),
      'opportunityFundTargetPaise': serializer.toJson<int?>(
        opportunityFundTargetPaise,
      ),
      'minimumBalancePaise': serializer.toJson<int?>(minimumBalancePaise),
    };
  }

  Account copyWith({
    String? id,
    String? name,
    String? type,
    Value<String?> institution = const Value.absent(),
    int? balance,
    String? currency,
    String? visibility,
    bool? sharedWithFamily,
    String? familyId,
    String? userId,
    Value<DateTime?> deletedAt = const Value.absent(),
    Value<String?> liquidityTier = const Value.absent(),
    bool? isEmergencyFund,
    bool? isOpportunityFund,
    Value<int?> opportunityFundTargetPaise = const Value.absent(),
    Value<int?> minimumBalancePaise = const Value.absent(),
  }) => Account(
    id: id ?? this.id,
    name: name ?? this.name,
    type: type ?? this.type,
    institution: institution.present ? institution.value : this.institution,
    balance: balance ?? this.balance,
    currency: currency ?? this.currency,
    visibility: visibility ?? this.visibility,
    sharedWithFamily: sharedWithFamily ?? this.sharedWithFamily,
    familyId: familyId ?? this.familyId,
    userId: userId ?? this.userId,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    liquidityTier: liquidityTier.present
        ? liquidityTier.value
        : this.liquidityTier,
    isEmergencyFund: isEmergencyFund ?? this.isEmergencyFund,
    isOpportunityFund: isOpportunityFund ?? this.isOpportunityFund,
    opportunityFundTargetPaise: opportunityFundTargetPaise.present
        ? opportunityFundTargetPaise.value
        : this.opportunityFundTargetPaise,
    minimumBalancePaise: minimumBalancePaise.present
        ? minimumBalancePaise.value
        : this.minimumBalancePaise,
  );
  Account copyWithCompanion(AccountsCompanion data) {
    return Account(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      type: data.type.present ? data.type.value : this.type,
      institution: data.institution.present
          ? data.institution.value
          : this.institution,
      balance: data.balance.present ? data.balance.value : this.balance,
      currency: data.currency.present ? data.currency.value : this.currency,
      visibility: data.visibility.present
          ? data.visibility.value
          : this.visibility,
      sharedWithFamily: data.sharedWithFamily.present
          ? data.sharedWithFamily.value
          : this.sharedWithFamily,
      familyId: data.familyId.present ? data.familyId.value : this.familyId,
      userId: data.userId.present ? data.userId.value : this.userId,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      liquidityTier: data.liquidityTier.present
          ? data.liquidityTier.value
          : this.liquidityTier,
      isEmergencyFund: data.isEmergencyFund.present
          ? data.isEmergencyFund.value
          : this.isEmergencyFund,
      isOpportunityFund: data.isOpportunityFund.present
          ? data.isOpportunityFund.value
          : this.isOpportunityFund,
      opportunityFundTargetPaise: data.opportunityFundTargetPaise.present
          ? data.opportunityFundTargetPaise.value
          : this.opportunityFundTargetPaise,
      minimumBalancePaise: data.minimumBalancePaise.present
          ? data.minimumBalancePaise.value
          : this.minimumBalancePaise,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Account(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('institution: $institution, ')
          ..write('balance: $balance, ')
          ..write('currency: $currency, ')
          ..write('visibility: $visibility, ')
          ..write('sharedWithFamily: $sharedWithFamily, ')
          ..write('familyId: $familyId, ')
          ..write('userId: $userId, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('liquidityTier: $liquidityTier, ')
          ..write('isEmergencyFund: $isEmergencyFund, ')
          ..write('isOpportunityFund: $isOpportunityFund, ')
          ..write('opportunityFundTargetPaise: $opportunityFundTargetPaise, ')
          ..write('minimumBalancePaise: $minimumBalancePaise')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    type,
    institution,
    balance,
    currency,
    visibility,
    sharedWithFamily,
    familyId,
    userId,
    deletedAt,
    liquidityTier,
    isEmergencyFund,
    isOpportunityFund,
    opportunityFundTargetPaise,
    minimumBalancePaise,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Account &&
          other.id == this.id &&
          other.name == this.name &&
          other.type == this.type &&
          other.institution == this.institution &&
          other.balance == this.balance &&
          other.currency == this.currency &&
          other.visibility == this.visibility &&
          other.sharedWithFamily == this.sharedWithFamily &&
          other.familyId == this.familyId &&
          other.userId == this.userId &&
          other.deletedAt == this.deletedAt &&
          other.liquidityTier == this.liquidityTier &&
          other.isEmergencyFund == this.isEmergencyFund &&
          other.isOpportunityFund == this.isOpportunityFund &&
          other.opportunityFundTargetPaise == this.opportunityFundTargetPaise &&
          other.minimumBalancePaise == this.minimumBalancePaise);
}

class AccountsCompanion extends UpdateCompanion<Account> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> type;
  final Value<String?> institution;
  final Value<int> balance;
  final Value<String> currency;
  final Value<String> visibility;
  final Value<bool> sharedWithFamily;
  final Value<String> familyId;
  final Value<String> userId;
  final Value<DateTime?> deletedAt;
  final Value<String?> liquidityTier;
  final Value<bool> isEmergencyFund;
  final Value<bool> isOpportunityFund;
  final Value<int?> opportunityFundTargetPaise;
  final Value<int?> minimumBalancePaise;
  final Value<int> rowid;
  const AccountsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.type = const Value.absent(),
    this.institution = const Value.absent(),
    this.balance = const Value.absent(),
    this.currency = const Value.absent(),
    this.visibility = const Value.absent(),
    this.sharedWithFamily = const Value.absent(),
    this.familyId = const Value.absent(),
    this.userId = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.liquidityTier = const Value.absent(),
    this.isEmergencyFund = const Value.absent(),
    this.isOpportunityFund = const Value.absent(),
    this.opportunityFundTargetPaise = const Value.absent(),
    this.minimumBalancePaise = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AccountsCompanion.insert({
    required String id,
    required String name,
    required String type,
    this.institution = const Value.absent(),
    required int balance,
    this.currency = const Value.absent(),
    required String visibility,
    this.sharedWithFamily = const Value.absent(),
    required String familyId,
    required String userId,
    this.deletedAt = const Value.absent(),
    this.liquidityTier = const Value.absent(),
    this.isEmergencyFund = const Value.absent(),
    this.isOpportunityFund = const Value.absent(),
    this.opportunityFundTargetPaise = const Value.absent(),
    this.minimumBalancePaise = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       type = Value(type),
       balance = Value(balance),
       visibility = Value(visibility),
       familyId = Value(familyId),
       userId = Value(userId);
  static Insertable<Account> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? type,
    Expression<String>? institution,
    Expression<int>? balance,
    Expression<String>? currency,
    Expression<String>? visibility,
    Expression<bool>? sharedWithFamily,
    Expression<String>? familyId,
    Expression<String>? userId,
    Expression<DateTime>? deletedAt,
    Expression<String>? liquidityTier,
    Expression<bool>? isEmergencyFund,
    Expression<bool>? isOpportunityFund,
    Expression<int>? opportunityFundTargetPaise,
    Expression<int>? minimumBalancePaise,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (type != null) 'type': type,
      if (institution != null) 'institution': institution,
      if (balance != null) 'balance': balance,
      if (currency != null) 'currency': currency,
      if (visibility != null) 'visibility': visibility,
      if (sharedWithFamily != null) 'shared_with_family': sharedWithFamily,
      if (familyId != null) 'family_id': familyId,
      if (userId != null) 'user_id': userId,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (liquidityTier != null) 'liquidity_tier': liquidityTier,
      if (isEmergencyFund != null) 'is_emergency_fund': isEmergencyFund,
      if (isOpportunityFund != null) 'is_opportunity_fund': isOpportunityFund,
      if (opportunityFundTargetPaise != null)
        'opportunity_fund_target_paise': opportunityFundTargetPaise,
      if (minimumBalancePaise != null)
        'minimum_balance_paise': minimumBalancePaise,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AccountsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? type,
    Value<String?>? institution,
    Value<int>? balance,
    Value<String>? currency,
    Value<String>? visibility,
    Value<bool>? sharedWithFamily,
    Value<String>? familyId,
    Value<String>? userId,
    Value<DateTime?>? deletedAt,
    Value<String?>? liquidityTier,
    Value<bool>? isEmergencyFund,
    Value<bool>? isOpportunityFund,
    Value<int?>? opportunityFundTargetPaise,
    Value<int?>? minimumBalancePaise,
    Value<int>? rowid,
  }) {
    return AccountsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      institution: institution ?? this.institution,
      balance: balance ?? this.balance,
      currency: currency ?? this.currency,
      visibility: visibility ?? this.visibility,
      sharedWithFamily: sharedWithFamily ?? this.sharedWithFamily,
      familyId: familyId ?? this.familyId,
      userId: userId ?? this.userId,
      deletedAt: deletedAt ?? this.deletedAt,
      liquidityTier: liquidityTier ?? this.liquidityTier,
      isEmergencyFund: isEmergencyFund ?? this.isEmergencyFund,
      isOpportunityFund: isOpportunityFund ?? this.isOpportunityFund,
      opportunityFundTargetPaise:
          opportunityFundTargetPaise ?? this.opportunityFundTargetPaise,
      minimumBalancePaise: minimumBalancePaise ?? this.minimumBalancePaise,
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
    if (institution.present) {
      map['institution'] = Variable<String>(institution.value);
    }
    if (balance.present) {
      map['balance'] = Variable<int>(balance.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (visibility.present) {
      map['visibility'] = Variable<String>(visibility.value);
    }
    if (sharedWithFamily.present) {
      map['shared_with_family'] = Variable<bool>(sharedWithFamily.value);
    }
    if (familyId.present) {
      map['family_id'] = Variable<String>(familyId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (liquidityTier.present) {
      map['liquidity_tier'] = Variable<String>(liquidityTier.value);
    }
    if (isEmergencyFund.present) {
      map['is_emergency_fund'] = Variable<bool>(isEmergencyFund.value);
    }
    if (isOpportunityFund.present) {
      map['is_opportunity_fund'] = Variable<bool>(isOpportunityFund.value);
    }
    if (opportunityFundTargetPaise.present) {
      map['opportunity_fund_target_paise'] = Variable<int>(
        opportunityFundTargetPaise.value,
      );
    }
    if (minimumBalancePaise.present) {
      map['minimum_balance_paise'] = Variable<int>(minimumBalancePaise.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AccountsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('institution: $institution, ')
          ..write('balance: $balance, ')
          ..write('currency: $currency, ')
          ..write('visibility: $visibility, ')
          ..write('sharedWithFamily: $sharedWithFamily, ')
          ..write('familyId: $familyId, ')
          ..write('userId: $userId, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('liquidityTier: $liquidityTier, ')
          ..write('isEmergencyFund: $isEmergencyFund, ')
          ..write('isOpportunityFund: $isOpportunityFund, ')
          ..write('opportunityFundTargetPaise: $opportunityFundTargetPaise, ')
          ..write('minimumBalancePaise: $minimumBalancePaise, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CategoriesTable extends Categories
    with TableInfo<$CategoriesTable, Category> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoriesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _groupNameMeta = const VerificationMeta(
    'groupName',
  );
  @override
  late final GeneratedColumn<String> groupName = GeneratedColumn<String>(
    'group_name',
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
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<String> icon = GeneratedColumn<String>(
    'icon',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _familyIdMeta = const VerificationMeta(
    'familyId',
  );
  @override
  late final GeneratedColumn<String> familyId = GeneratedColumn<String>(
    'family_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES families (id)',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    groupName,
    type,
    icon,
    familyId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<Category> instance, {
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
    if (data.containsKey('group_name')) {
      context.handle(
        _groupNameMeta,
        groupName.isAcceptableOrUnknown(data['group_name']!, _groupNameMeta),
      );
    } else if (isInserting) {
      context.missing(_groupNameMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('icon')) {
      context.handle(
        _iconMeta,
        icon.isAcceptableOrUnknown(data['icon']!, _iconMeta),
      );
    }
    if (data.containsKey('family_id')) {
      context.handle(
        _familyIdMeta,
        familyId.isAcceptableOrUnknown(data['family_id']!, _familyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_familyIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Category map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Category(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      groupName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}group_name'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      icon: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon'],
      ),
      familyId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}family_id'],
      )!,
    );
  }

  @override
  $CategoriesTable createAlias(String alias) {
    return $CategoriesTable(attachedDatabase, alias);
  }
}

class Category extends DataClass implements Insertable<Category> {
  final String id;
  final String name;
  final String groupName;
  final String type;
  final String? icon;
  final String familyId;
  const Category({
    required this.id,
    required this.name,
    required this.groupName,
    required this.type,
    this.icon,
    required this.familyId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['group_name'] = Variable<String>(groupName);
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || icon != null) {
      map['icon'] = Variable<String>(icon);
    }
    map['family_id'] = Variable<String>(familyId);
    return map;
  }

  CategoriesCompanion toCompanion(bool nullToAbsent) {
    return CategoriesCompanion(
      id: Value(id),
      name: Value(name),
      groupName: Value(groupName),
      type: Value(type),
      icon: icon == null && nullToAbsent ? const Value.absent() : Value(icon),
      familyId: Value(familyId),
    );
  }

  factory Category.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Category(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      groupName: serializer.fromJson<String>(json['groupName']),
      type: serializer.fromJson<String>(json['type']),
      icon: serializer.fromJson<String?>(json['icon']),
      familyId: serializer.fromJson<String>(json['familyId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'groupName': serializer.toJson<String>(groupName),
      'type': serializer.toJson<String>(type),
      'icon': serializer.toJson<String?>(icon),
      'familyId': serializer.toJson<String>(familyId),
    };
  }

  Category copyWith({
    String? id,
    String? name,
    String? groupName,
    String? type,
    Value<String?> icon = const Value.absent(),
    String? familyId,
  }) => Category(
    id: id ?? this.id,
    name: name ?? this.name,
    groupName: groupName ?? this.groupName,
    type: type ?? this.type,
    icon: icon.present ? icon.value : this.icon,
    familyId: familyId ?? this.familyId,
  );
  Category copyWithCompanion(CategoriesCompanion data) {
    return Category(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      groupName: data.groupName.present ? data.groupName.value : this.groupName,
      type: data.type.present ? data.type.value : this.type,
      icon: data.icon.present ? data.icon.value : this.icon,
      familyId: data.familyId.present ? data.familyId.value : this.familyId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Category(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('groupName: $groupName, ')
          ..write('type: $type, ')
          ..write('icon: $icon, ')
          ..write('familyId: $familyId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, groupName, type, icon, familyId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Category &&
          other.id == this.id &&
          other.name == this.name &&
          other.groupName == this.groupName &&
          other.type == this.type &&
          other.icon == this.icon &&
          other.familyId == this.familyId);
}

class CategoriesCompanion extends UpdateCompanion<Category> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> groupName;
  final Value<String> type;
  final Value<String?> icon;
  final Value<String> familyId;
  final Value<int> rowid;
  const CategoriesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.groupName = const Value.absent(),
    this.type = const Value.absent(),
    this.icon = const Value.absent(),
    this.familyId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CategoriesCompanion.insert({
    required String id,
    required String name,
    required String groupName,
    required String type,
    this.icon = const Value.absent(),
    required String familyId,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       groupName = Value(groupName),
       type = Value(type),
       familyId = Value(familyId);
  static Insertable<Category> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? groupName,
    Expression<String>? type,
    Expression<String>? icon,
    Expression<String>? familyId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (groupName != null) 'group_name': groupName,
      if (type != null) 'type': type,
      if (icon != null) 'icon': icon,
      if (familyId != null) 'family_id': familyId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CategoriesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? groupName,
    Value<String>? type,
    Value<String?>? icon,
    Value<String>? familyId,
    Value<int>? rowid,
  }) {
    return CategoriesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      groupName: groupName ?? this.groupName,
      type: type ?? this.type,
      icon: icon ?? this.icon,
      familyId: familyId ?? this.familyId,
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
    if (groupName.present) {
      map['group_name'] = Variable<String>(groupName.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (icon.present) {
      map['icon'] = Variable<String>(icon.value);
    }
    if (familyId.present) {
      map['family_id'] = Variable<String>(familyId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoriesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('groupName: $groupName, ')
          ..write('type: $type, ')
          ..write('icon: $icon, ')
          ..write('familyId: $familyId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CategoryGroupsTable extends CategoryGroups
    with TableInfo<$CategoryGroupsTable, CategoryGroup> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoryGroupsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _displayOrderMeta = const VerificationMeta(
    'displayOrder',
  );
  @override
  late final GeneratedColumn<int> displayOrder = GeneratedColumn<int>(
    'display_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _familyIdMeta = const VerificationMeta(
    'familyId',
  );
  @override
  late final GeneratedColumn<String> familyId = GeneratedColumn<String>(
    'family_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES families (id)',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, displayOrder, familyId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'category_groups';
  @override
  VerificationContext validateIntegrity(
    Insertable<CategoryGroup> instance, {
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
    if (data.containsKey('display_order')) {
      context.handle(
        _displayOrderMeta,
        displayOrder.isAcceptableOrUnknown(
          data['display_order']!,
          _displayOrderMeta,
        ),
      );
    }
    if (data.containsKey('family_id')) {
      context.handle(
        _familyIdMeta,
        familyId.isAcceptableOrUnknown(data['family_id']!, _familyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_familyIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id, familyId};
  @override
  CategoryGroup map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CategoryGroup(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      displayOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}display_order'],
      )!,
      familyId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}family_id'],
      )!,
    );
  }

  @override
  $CategoryGroupsTable createAlias(String alias) {
    return $CategoryGroupsTable(attachedDatabase, alias);
  }
}

class CategoryGroup extends DataClass implements Insertable<CategoryGroup> {
  /// Slug identifier, e.g. 'HOME_EXPENSES'.
  final String id;

  /// Human-readable display name, e.g. 'Home Expenses'.
  final String name;

  /// Sort order for UI rendering.
  final int displayOrder;
  final String familyId;
  const CategoryGroup({
    required this.id,
    required this.name,
    required this.displayOrder,
    required this.familyId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['display_order'] = Variable<int>(displayOrder);
    map['family_id'] = Variable<String>(familyId);
    return map;
  }

  CategoryGroupsCompanion toCompanion(bool nullToAbsent) {
    return CategoryGroupsCompanion(
      id: Value(id),
      name: Value(name),
      displayOrder: Value(displayOrder),
      familyId: Value(familyId),
    );
  }

  factory CategoryGroup.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CategoryGroup(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      displayOrder: serializer.fromJson<int>(json['displayOrder']),
      familyId: serializer.fromJson<String>(json['familyId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'displayOrder': serializer.toJson<int>(displayOrder),
      'familyId': serializer.toJson<String>(familyId),
    };
  }

  CategoryGroup copyWith({
    String? id,
    String? name,
    int? displayOrder,
    String? familyId,
  }) => CategoryGroup(
    id: id ?? this.id,
    name: name ?? this.name,
    displayOrder: displayOrder ?? this.displayOrder,
    familyId: familyId ?? this.familyId,
  );
  CategoryGroup copyWithCompanion(CategoryGroupsCompanion data) {
    return CategoryGroup(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      displayOrder: data.displayOrder.present
          ? data.displayOrder.value
          : this.displayOrder,
      familyId: data.familyId.present ? data.familyId.value : this.familyId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CategoryGroup(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('displayOrder: $displayOrder, ')
          ..write('familyId: $familyId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, displayOrder, familyId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CategoryGroup &&
          other.id == this.id &&
          other.name == this.name &&
          other.displayOrder == this.displayOrder &&
          other.familyId == this.familyId);
}

class CategoryGroupsCompanion extends UpdateCompanion<CategoryGroup> {
  final Value<String> id;
  final Value<String> name;
  final Value<int> displayOrder;
  final Value<String> familyId;
  final Value<int> rowid;
  const CategoryGroupsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.displayOrder = const Value.absent(),
    this.familyId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CategoryGroupsCompanion.insert({
    required String id,
    required String name,
    this.displayOrder = const Value.absent(),
    required String familyId,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       familyId = Value(familyId);
  static Insertable<CategoryGroup> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<int>? displayOrder,
    Expression<String>? familyId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (displayOrder != null) 'display_order': displayOrder,
      if (familyId != null) 'family_id': familyId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CategoryGroupsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<int>? displayOrder,
    Value<String>? familyId,
    Value<int>? rowid,
  }) {
    return CategoryGroupsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      displayOrder: displayOrder ?? this.displayOrder,
      familyId: familyId ?? this.familyId,
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
    if (displayOrder.present) {
      map['display_order'] = Variable<int>(displayOrder.value);
    }
    if (familyId.present) {
      map['family_id'] = Variable<String>(familyId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoryGroupsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('displayOrder: $displayOrder, ')
          ..write('familyId: $familyId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TransactionsTable extends Transactions
    with TableInfo<$TransactionsTable, Transaction> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TransactionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<int> amount = GeneratedColumn<int>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
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
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES categories (id)',
    ),
  );
  static const VerificationMeta _accountIdMeta = const VerificationMeta(
    'accountId',
  );
  @override
  late final GeneratedColumn<String> accountId = GeneratedColumn<String>(
    'account_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES accounts (id)',
    ),
  );
  static const VerificationMeta _toAccountIdMeta = const VerificationMeta(
    'toAccountId',
  );
  @override
  late final GeneratedColumn<String> toAccountId = GeneratedColumn<String>(
    'to_account_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES accounts (id)',
    ),
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
  static const VerificationMeta _reconciliationKindMeta =
      const VerificationMeta('reconciliationKind');
  @override
  late final GeneratedColumn<String> reconciliationKind =
      GeneratedColumn<String>(
        'reconciliation_kind',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _metadataMeta = const VerificationMeta(
    'metadata',
  );
  @override
  late final GeneratedColumn<String> metadata = GeneratedColumn<String>(
    'metadata',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _familyIdMeta = const VerificationMeta(
    'familyId',
  );
  @override
  late final GeneratedColumn<String> familyId = GeneratedColumn<String>(
    'family_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES families (id)',
    ),
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    amount,
    date,
    description,
    categoryId,
    accountId,
    toAccountId,
    kind,
    reconciliationKind,
    metadata,
    familyId,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transactions';
  @override
  VerificationContext validateIntegrity(
    Insertable<Transaction> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
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
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    }
    if (data.containsKey('account_id')) {
      context.handle(
        _accountIdMeta,
        accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta),
      );
    } else if (isInserting) {
      context.missing(_accountIdMeta);
    }
    if (data.containsKey('to_account_id')) {
      context.handle(
        _toAccountIdMeta,
        toAccountId.isAcceptableOrUnknown(
          data['to_account_id']!,
          _toAccountIdMeta,
        ),
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
    if (data.containsKey('reconciliation_kind')) {
      context.handle(
        _reconciliationKindMeta,
        reconciliationKind.isAcceptableOrUnknown(
          data['reconciliation_kind']!,
          _reconciliationKindMeta,
        ),
      );
    }
    if (data.containsKey('metadata')) {
      context.handle(
        _metadataMeta,
        metadata.isAcceptableOrUnknown(data['metadata']!, _metadataMeta),
      );
    }
    if (data.containsKey('family_id')) {
      context.handle(
        _familyIdMeta,
        familyId.isAcceptableOrUnknown(data['family_id']!, _familyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_familyIdMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Transaction map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Transaction(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      ),
      accountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_id'],
      )!,
      toAccountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}to_account_id'],
      ),
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      reconciliationKind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reconciliation_kind'],
      ),
      metadata: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}metadata'],
      ),
      familyId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}family_id'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $TransactionsTable createAlias(String alias) {
    return $TransactionsTable(attachedDatabase, alias);
  }
}

class Transaction extends DataClass implements Insertable<Transaction> {
  final String id;
  final int amount;
  final DateTime date;
  final String? description;
  final String? categoryId;
  final String accountId;
  final String? toAccountId;
  final String kind;
  final String? reconciliationKind;
  final String? metadata;
  final String familyId;
  final DateTime? deletedAt;
  const Transaction({
    required this.id,
    required this.amount,
    required this.date,
    this.description,
    this.categoryId,
    required this.accountId,
    this.toAccountId,
    required this.kind,
    this.reconciliationKind,
    this.metadata,
    required this.familyId,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['amount'] = Variable<int>(amount);
    map['date'] = Variable<DateTime>(date);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || categoryId != null) {
      map['category_id'] = Variable<String>(categoryId);
    }
    map['account_id'] = Variable<String>(accountId);
    if (!nullToAbsent || toAccountId != null) {
      map['to_account_id'] = Variable<String>(toAccountId);
    }
    map['kind'] = Variable<String>(kind);
    if (!nullToAbsent || reconciliationKind != null) {
      map['reconciliation_kind'] = Variable<String>(reconciliationKind);
    }
    if (!nullToAbsent || metadata != null) {
      map['metadata'] = Variable<String>(metadata);
    }
    map['family_id'] = Variable<String>(familyId);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  TransactionsCompanion toCompanion(bool nullToAbsent) {
    return TransactionsCompanion(
      id: Value(id),
      amount: Value(amount),
      date: Value(date),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      categoryId: categoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryId),
      accountId: Value(accountId),
      toAccountId: toAccountId == null && nullToAbsent
          ? const Value.absent()
          : Value(toAccountId),
      kind: Value(kind),
      reconciliationKind: reconciliationKind == null && nullToAbsent
          ? const Value.absent()
          : Value(reconciliationKind),
      metadata: metadata == null && nullToAbsent
          ? const Value.absent()
          : Value(metadata),
      familyId: Value(familyId),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory Transaction.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Transaction(
      id: serializer.fromJson<String>(json['id']),
      amount: serializer.fromJson<int>(json['amount']),
      date: serializer.fromJson<DateTime>(json['date']),
      description: serializer.fromJson<String?>(json['description']),
      categoryId: serializer.fromJson<String?>(json['categoryId']),
      accountId: serializer.fromJson<String>(json['accountId']),
      toAccountId: serializer.fromJson<String?>(json['toAccountId']),
      kind: serializer.fromJson<String>(json['kind']),
      reconciliationKind: serializer.fromJson<String?>(
        json['reconciliationKind'],
      ),
      metadata: serializer.fromJson<String?>(json['metadata']),
      familyId: serializer.fromJson<String>(json['familyId']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'amount': serializer.toJson<int>(amount),
      'date': serializer.toJson<DateTime>(date),
      'description': serializer.toJson<String?>(description),
      'categoryId': serializer.toJson<String?>(categoryId),
      'accountId': serializer.toJson<String>(accountId),
      'toAccountId': serializer.toJson<String?>(toAccountId),
      'kind': serializer.toJson<String>(kind),
      'reconciliationKind': serializer.toJson<String?>(reconciliationKind),
      'metadata': serializer.toJson<String?>(metadata),
      'familyId': serializer.toJson<String>(familyId),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  Transaction copyWith({
    String? id,
    int? amount,
    DateTime? date,
    Value<String?> description = const Value.absent(),
    Value<String?> categoryId = const Value.absent(),
    String? accountId,
    Value<String?> toAccountId = const Value.absent(),
    String? kind,
    Value<String?> reconciliationKind = const Value.absent(),
    Value<String?> metadata = const Value.absent(),
    String? familyId,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => Transaction(
    id: id ?? this.id,
    amount: amount ?? this.amount,
    date: date ?? this.date,
    description: description.present ? description.value : this.description,
    categoryId: categoryId.present ? categoryId.value : this.categoryId,
    accountId: accountId ?? this.accountId,
    toAccountId: toAccountId.present ? toAccountId.value : this.toAccountId,
    kind: kind ?? this.kind,
    reconciliationKind: reconciliationKind.present
        ? reconciliationKind.value
        : this.reconciliationKind,
    metadata: metadata.present ? metadata.value : this.metadata,
    familyId: familyId ?? this.familyId,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  Transaction copyWithCompanion(TransactionsCompanion data) {
    return Transaction(
      id: data.id.present ? data.id.value : this.id,
      amount: data.amount.present ? data.amount.value : this.amount,
      date: data.date.present ? data.date.value : this.date,
      description: data.description.present
          ? data.description.value
          : this.description,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      toAccountId: data.toAccountId.present
          ? data.toAccountId.value
          : this.toAccountId,
      kind: data.kind.present ? data.kind.value : this.kind,
      reconciliationKind: data.reconciliationKind.present
          ? data.reconciliationKind.value
          : this.reconciliationKind,
      metadata: data.metadata.present ? data.metadata.value : this.metadata,
      familyId: data.familyId.present ? data.familyId.value : this.familyId,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Transaction(')
          ..write('id: $id, ')
          ..write('amount: $amount, ')
          ..write('date: $date, ')
          ..write('description: $description, ')
          ..write('categoryId: $categoryId, ')
          ..write('accountId: $accountId, ')
          ..write('toAccountId: $toAccountId, ')
          ..write('kind: $kind, ')
          ..write('reconciliationKind: $reconciliationKind, ')
          ..write('metadata: $metadata, ')
          ..write('familyId: $familyId, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    amount,
    date,
    description,
    categoryId,
    accountId,
    toAccountId,
    kind,
    reconciliationKind,
    metadata,
    familyId,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Transaction &&
          other.id == this.id &&
          other.amount == this.amount &&
          other.date == this.date &&
          other.description == this.description &&
          other.categoryId == this.categoryId &&
          other.accountId == this.accountId &&
          other.toAccountId == this.toAccountId &&
          other.kind == this.kind &&
          other.reconciliationKind == this.reconciliationKind &&
          other.metadata == this.metadata &&
          other.familyId == this.familyId &&
          other.deletedAt == this.deletedAt);
}

class TransactionsCompanion extends UpdateCompanion<Transaction> {
  final Value<String> id;
  final Value<int> amount;
  final Value<DateTime> date;
  final Value<String?> description;
  final Value<String?> categoryId;
  final Value<String> accountId;
  final Value<String?> toAccountId;
  final Value<String> kind;
  final Value<String?> reconciliationKind;
  final Value<String?> metadata;
  final Value<String> familyId;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const TransactionsCompanion({
    this.id = const Value.absent(),
    this.amount = const Value.absent(),
    this.date = const Value.absent(),
    this.description = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.accountId = const Value.absent(),
    this.toAccountId = const Value.absent(),
    this.kind = const Value.absent(),
    this.reconciliationKind = const Value.absent(),
    this.metadata = const Value.absent(),
    this.familyId = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TransactionsCompanion.insert({
    required String id,
    required int amount,
    required DateTime date,
    this.description = const Value.absent(),
    this.categoryId = const Value.absent(),
    required String accountId,
    this.toAccountId = const Value.absent(),
    required String kind,
    this.reconciliationKind = const Value.absent(),
    this.metadata = const Value.absent(),
    required String familyId,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       amount = Value(amount),
       date = Value(date),
       accountId = Value(accountId),
       kind = Value(kind),
       familyId = Value(familyId);
  static Insertable<Transaction> custom({
    Expression<String>? id,
    Expression<int>? amount,
    Expression<DateTime>? date,
    Expression<String>? description,
    Expression<String>? categoryId,
    Expression<String>? accountId,
    Expression<String>? toAccountId,
    Expression<String>? kind,
    Expression<String>? reconciliationKind,
    Expression<String>? metadata,
    Expression<String>? familyId,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (amount != null) 'amount': amount,
      if (date != null) 'date': date,
      if (description != null) 'description': description,
      if (categoryId != null) 'category_id': categoryId,
      if (accountId != null) 'account_id': accountId,
      if (toAccountId != null) 'to_account_id': toAccountId,
      if (kind != null) 'kind': kind,
      if (reconciliationKind != null) 'reconciliation_kind': reconciliationKind,
      if (metadata != null) 'metadata': metadata,
      if (familyId != null) 'family_id': familyId,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TransactionsCompanion copyWith({
    Value<String>? id,
    Value<int>? amount,
    Value<DateTime>? date,
    Value<String?>? description,
    Value<String?>? categoryId,
    Value<String>? accountId,
    Value<String?>? toAccountId,
    Value<String>? kind,
    Value<String?>? reconciliationKind,
    Value<String?>? metadata,
    Value<String>? familyId,
    Value<DateTime?>? deletedAt,
    Value<int>? rowid,
  }) {
    return TransactionsCompanion(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      description: description ?? this.description,
      categoryId: categoryId ?? this.categoryId,
      accountId: accountId ?? this.accountId,
      toAccountId: toAccountId ?? this.toAccountId,
      kind: kind ?? this.kind,
      reconciliationKind: reconciliationKind ?? this.reconciliationKind,
      metadata: metadata ?? this.metadata,
      familyId: familyId ?? this.familyId,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (amount.present) {
      map['amount'] = Variable<int>(amount.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<String>(accountId.value);
    }
    if (toAccountId.present) {
      map['to_account_id'] = Variable<String>(toAccountId.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (reconciliationKind.present) {
      map['reconciliation_kind'] = Variable<String>(reconciliationKind.value);
    }
    if (metadata.present) {
      map['metadata'] = Variable<String>(metadata.value);
    }
    if (familyId.present) {
      map['family_id'] = Variable<String>(familyId.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransactionsCompanion(')
          ..write('id: $id, ')
          ..write('amount: $amount, ')
          ..write('date: $date, ')
          ..write('description: $description, ')
          ..write('categoryId: $categoryId, ')
          ..write('accountId: $accountId, ')
          ..write('toAccountId: $toAccountId, ')
          ..write('kind: $kind, ')
          ..write('reconciliationKind: $reconciliationKind, ')
          ..write('metadata: $metadata, ')
          ..write('familyId: $familyId, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BalanceSnapshotsTable extends BalanceSnapshots
    with TableInfo<$BalanceSnapshotsTable, BalanceSnapshot> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BalanceSnapshotsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _accountIdMeta = const VerificationMeta(
    'accountId',
  );
  @override
  late final GeneratedColumn<String> accountId = GeneratedColumn<String>(
    'account_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES accounts (id)',
    ),
  );
  static const VerificationMeta _snapshotDateMeta = const VerificationMeta(
    'snapshotDate',
  );
  @override
  late final GeneratedColumn<DateTime> snapshotDate = GeneratedColumn<DateTime>(
    'snapshot_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _balanceMeta = const VerificationMeta(
    'balance',
  );
  @override
  late final GeneratedColumn<int> balance = GeneratedColumn<int>(
    'balance',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _familyIdMeta = const VerificationMeta(
    'familyId',
  );
  @override
  late final GeneratedColumn<String> familyId = GeneratedColumn<String>(
    'family_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES families (id)',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    accountId,
    snapshotDate,
    balance,
    familyId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'balance_snapshots';
  @override
  VerificationContext validateIntegrity(
    Insertable<BalanceSnapshot> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('account_id')) {
      context.handle(
        _accountIdMeta,
        accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta),
      );
    } else if (isInserting) {
      context.missing(_accountIdMeta);
    }
    if (data.containsKey('snapshot_date')) {
      context.handle(
        _snapshotDateMeta,
        snapshotDate.isAcceptableOrUnknown(
          data['snapshot_date']!,
          _snapshotDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_snapshotDateMeta);
    }
    if (data.containsKey('balance')) {
      context.handle(
        _balanceMeta,
        balance.isAcceptableOrUnknown(data['balance']!, _balanceMeta),
      );
    } else if (isInserting) {
      context.missing(_balanceMeta);
    }
    if (data.containsKey('family_id')) {
      context.handle(
        _familyIdMeta,
        familyId.isAcceptableOrUnknown(data['family_id']!, _familyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_familyIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BalanceSnapshot map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BalanceSnapshot(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      accountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_id'],
      )!,
      snapshotDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}snapshot_date'],
      )!,
      balance: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}balance'],
      )!,
      familyId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}family_id'],
      )!,
    );
  }

  @override
  $BalanceSnapshotsTable createAlias(String alias) {
    return $BalanceSnapshotsTable(attachedDatabase, alias);
  }
}

class BalanceSnapshot extends DataClass implements Insertable<BalanceSnapshot> {
  final String id;
  final String accountId;
  final DateTime snapshotDate;
  final int balance;
  final String familyId;
  const BalanceSnapshot({
    required this.id,
    required this.accountId,
    required this.snapshotDate,
    required this.balance,
    required this.familyId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['account_id'] = Variable<String>(accountId);
    map['snapshot_date'] = Variable<DateTime>(snapshotDate);
    map['balance'] = Variable<int>(balance);
    map['family_id'] = Variable<String>(familyId);
    return map;
  }

  BalanceSnapshotsCompanion toCompanion(bool nullToAbsent) {
    return BalanceSnapshotsCompanion(
      id: Value(id),
      accountId: Value(accountId),
      snapshotDate: Value(snapshotDate),
      balance: Value(balance),
      familyId: Value(familyId),
    );
  }

  factory BalanceSnapshot.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BalanceSnapshot(
      id: serializer.fromJson<String>(json['id']),
      accountId: serializer.fromJson<String>(json['accountId']),
      snapshotDate: serializer.fromJson<DateTime>(json['snapshotDate']),
      balance: serializer.fromJson<int>(json['balance']),
      familyId: serializer.fromJson<String>(json['familyId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'accountId': serializer.toJson<String>(accountId),
      'snapshotDate': serializer.toJson<DateTime>(snapshotDate),
      'balance': serializer.toJson<int>(balance),
      'familyId': serializer.toJson<String>(familyId),
    };
  }

  BalanceSnapshot copyWith({
    String? id,
    String? accountId,
    DateTime? snapshotDate,
    int? balance,
    String? familyId,
  }) => BalanceSnapshot(
    id: id ?? this.id,
    accountId: accountId ?? this.accountId,
    snapshotDate: snapshotDate ?? this.snapshotDate,
    balance: balance ?? this.balance,
    familyId: familyId ?? this.familyId,
  );
  BalanceSnapshot copyWithCompanion(BalanceSnapshotsCompanion data) {
    return BalanceSnapshot(
      id: data.id.present ? data.id.value : this.id,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      snapshotDate: data.snapshotDate.present
          ? data.snapshotDate.value
          : this.snapshotDate,
      balance: data.balance.present ? data.balance.value : this.balance,
      familyId: data.familyId.present ? data.familyId.value : this.familyId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BalanceSnapshot(')
          ..write('id: $id, ')
          ..write('accountId: $accountId, ')
          ..write('snapshotDate: $snapshotDate, ')
          ..write('balance: $balance, ')
          ..write('familyId: $familyId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, accountId, snapshotDate, balance, familyId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BalanceSnapshot &&
          other.id == this.id &&
          other.accountId == this.accountId &&
          other.snapshotDate == this.snapshotDate &&
          other.balance == this.balance &&
          other.familyId == this.familyId);
}

class BalanceSnapshotsCompanion extends UpdateCompanion<BalanceSnapshot> {
  final Value<String> id;
  final Value<String> accountId;
  final Value<DateTime> snapshotDate;
  final Value<int> balance;
  final Value<String> familyId;
  final Value<int> rowid;
  const BalanceSnapshotsCompanion({
    this.id = const Value.absent(),
    this.accountId = const Value.absent(),
    this.snapshotDate = const Value.absent(),
    this.balance = const Value.absent(),
    this.familyId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BalanceSnapshotsCompanion.insert({
    required String id,
    required String accountId,
    required DateTime snapshotDate,
    required int balance,
    required String familyId,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       accountId = Value(accountId),
       snapshotDate = Value(snapshotDate),
       balance = Value(balance),
       familyId = Value(familyId);
  static Insertable<BalanceSnapshot> custom({
    Expression<String>? id,
    Expression<String>? accountId,
    Expression<DateTime>? snapshotDate,
    Expression<int>? balance,
    Expression<String>? familyId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (accountId != null) 'account_id': accountId,
      if (snapshotDate != null) 'snapshot_date': snapshotDate,
      if (balance != null) 'balance': balance,
      if (familyId != null) 'family_id': familyId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BalanceSnapshotsCompanion copyWith({
    Value<String>? id,
    Value<String>? accountId,
    Value<DateTime>? snapshotDate,
    Value<int>? balance,
    Value<String>? familyId,
    Value<int>? rowid,
  }) {
    return BalanceSnapshotsCompanion(
      id: id ?? this.id,
      accountId: accountId ?? this.accountId,
      snapshotDate: snapshotDate ?? this.snapshotDate,
      balance: balance ?? this.balance,
      familyId: familyId ?? this.familyId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<String>(accountId.value);
    }
    if (snapshotDate.present) {
      map['snapshot_date'] = Variable<DateTime>(snapshotDate.value);
    }
    if (balance.present) {
      map['balance'] = Variable<int>(balance.value);
    }
    if (familyId.present) {
      map['family_id'] = Variable<String>(familyId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BalanceSnapshotsCompanion(')
          ..write('id: $id, ')
          ..write('accountId: $accountId, ')
          ..write('snapshotDate: $snapshotDate, ')
          ..write('balance: $balance, ')
          ..write('familyId: $familyId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AuditLogTable extends AuditLog
    with TableInfo<$AuditLogTable, AuditLogData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AuditLogTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  static const VerificationMeta _diffMeta = const VerificationMeta('diff');
  @override
  late final GeneratedColumn<String> diff = GeneratedColumn<String>(
    'diff',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _actorUserIdMeta = const VerificationMeta(
    'actorUserId',
  );
  @override
  late final GeneratedColumn<String> actorUserId = GeneratedColumn<String>(
    'actor_user_id',
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
  static const VerificationMeta _familyIdMeta = const VerificationMeta(
    'familyId',
  );
  @override
  late final GeneratedColumn<String> familyId = GeneratedColumn<String>(
    'family_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES families (id)',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    entityType,
    entityId,
    action,
    diff,
    actorUserId,
    createdAt,
    familyId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'audit_log';
  @override
  VerificationContext validateIntegrity(
    Insertable<AuditLogData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('entity_type')) {
      context.handle(
        _entityTypeMeta,
        entityType.isAcceptableOrUnknown(data['entity_type']!, _entityTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('action')) {
      context.handle(
        _actionMeta,
        action.isAcceptableOrUnknown(data['action']!, _actionMeta),
      );
    } else if (isInserting) {
      context.missing(_actionMeta);
    }
    if (data.containsKey('diff')) {
      context.handle(
        _diffMeta,
        diff.isAcceptableOrUnknown(data['diff']!, _diffMeta),
      );
    }
    if (data.containsKey('actor_user_id')) {
      context.handle(
        _actorUserIdMeta,
        actorUserId.isAcceptableOrUnknown(
          data['actor_user_id']!,
          _actorUserIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_actorUserIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('family_id')) {
      context.handle(
        _familyIdMeta,
        familyId.isAcceptableOrUnknown(data['family_id']!, _familyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_familyIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AuditLogData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AuditLogData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      entityType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_type'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      )!,
      action: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}action'],
      )!,
      diff: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}diff'],
      ),
      actorUserId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}actor_user_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      familyId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}family_id'],
      )!,
    );
  }

  @override
  $AuditLogTable createAlias(String alias) {
    return $AuditLogTable(attachedDatabase, alias);
  }
}

class AuditLogData extends DataClass implements Insertable<AuditLogData> {
  final String id;
  final String entityType;
  final String entityId;
  final String action;
  final String? diff;
  final String actorUserId;
  final DateTime createdAt;
  final String familyId;
  const AuditLogData({
    required this.id,
    required this.entityType,
    required this.entityId,
    required this.action,
    this.diff,
    required this.actorUserId,
    required this.createdAt,
    required this.familyId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['entity_type'] = Variable<String>(entityType);
    map['entity_id'] = Variable<String>(entityId);
    map['action'] = Variable<String>(action);
    if (!nullToAbsent || diff != null) {
      map['diff'] = Variable<String>(diff);
    }
    map['actor_user_id'] = Variable<String>(actorUserId);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['family_id'] = Variable<String>(familyId);
    return map;
  }

  AuditLogCompanion toCompanion(bool nullToAbsent) {
    return AuditLogCompanion(
      id: Value(id),
      entityType: Value(entityType),
      entityId: Value(entityId),
      action: Value(action),
      diff: diff == null && nullToAbsent ? const Value.absent() : Value(diff),
      actorUserId: Value(actorUserId),
      createdAt: Value(createdAt),
      familyId: Value(familyId),
    );
  }

  factory AuditLogData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AuditLogData(
      id: serializer.fromJson<String>(json['id']),
      entityType: serializer.fromJson<String>(json['entityType']),
      entityId: serializer.fromJson<String>(json['entityId']),
      action: serializer.fromJson<String>(json['action']),
      diff: serializer.fromJson<String?>(json['diff']),
      actorUserId: serializer.fromJson<String>(json['actorUserId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      familyId: serializer.fromJson<String>(json['familyId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'entityType': serializer.toJson<String>(entityType),
      'entityId': serializer.toJson<String>(entityId),
      'action': serializer.toJson<String>(action),
      'diff': serializer.toJson<String?>(diff),
      'actorUserId': serializer.toJson<String>(actorUserId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'familyId': serializer.toJson<String>(familyId),
    };
  }

  AuditLogData copyWith({
    String? id,
    String? entityType,
    String? entityId,
    String? action,
    Value<String?> diff = const Value.absent(),
    String? actorUserId,
    DateTime? createdAt,
    String? familyId,
  }) => AuditLogData(
    id: id ?? this.id,
    entityType: entityType ?? this.entityType,
    entityId: entityId ?? this.entityId,
    action: action ?? this.action,
    diff: diff.present ? diff.value : this.diff,
    actorUserId: actorUserId ?? this.actorUserId,
    createdAt: createdAt ?? this.createdAt,
    familyId: familyId ?? this.familyId,
  );
  AuditLogData copyWithCompanion(AuditLogCompanion data) {
    return AuditLogData(
      id: data.id.present ? data.id.value : this.id,
      entityType: data.entityType.present
          ? data.entityType.value
          : this.entityType,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      action: data.action.present ? data.action.value : this.action,
      diff: data.diff.present ? data.diff.value : this.diff,
      actorUserId: data.actorUserId.present
          ? data.actorUserId.value
          : this.actorUserId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      familyId: data.familyId.present ? data.familyId.value : this.familyId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AuditLogData(')
          ..write('id: $id, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('action: $action, ')
          ..write('diff: $diff, ')
          ..write('actorUserId: $actorUserId, ')
          ..write('createdAt: $createdAt, ')
          ..write('familyId: $familyId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    entityType,
    entityId,
    action,
    diff,
    actorUserId,
    createdAt,
    familyId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AuditLogData &&
          other.id == this.id &&
          other.entityType == this.entityType &&
          other.entityId == this.entityId &&
          other.action == this.action &&
          other.diff == this.diff &&
          other.actorUserId == this.actorUserId &&
          other.createdAt == this.createdAt &&
          other.familyId == this.familyId);
}

class AuditLogCompanion extends UpdateCompanion<AuditLogData> {
  final Value<String> id;
  final Value<String> entityType;
  final Value<String> entityId;
  final Value<String> action;
  final Value<String?> diff;
  final Value<String> actorUserId;
  final Value<DateTime> createdAt;
  final Value<String> familyId;
  final Value<int> rowid;
  const AuditLogCompanion({
    this.id = const Value.absent(),
    this.entityType = const Value.absent(),
    this.entityId = const Value.absent(),
    this.action = const Value.absent(),
    this.diff = const Value.absent(),
    this.actorUserId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.familyId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AuditLogCompanion.insert({
    required String id,
    required String entityType,
    required String entityId,
    required String action,
    this.diff = const Value.absent(),
    required String actorUserId,
    required DateTime createdAt,
    required String familyId,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       entityType = Value(entityType),
       entityId = Value(entityId),
       action = Value(action),
       actorUserId = Value(actorUserId),
       createdAt = Value(createdAt),
       familyId = Value(familyId);
  static Insertable<AuditLogData> custom({
    Expression<String>? id,
    Expression<String>? entityType,
    Expression<String>? entityId,
    Expression<String>? action,
    Expression<String>? diff,
    Expression<String>? actorUserId,
    Expression<DateTime>? createdAt,
    Expression<String>? familyId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (entityType != null) 'entity_type': entityType,
      if (entityId != null) 'entity_id': entityId,
      if (action != null) 'action': action,
      if (diff != null) 'diff': diff,
      if (actorUserId != null) 'actor_user_id': actorUserId,
      if (createdAt != null) 'created_at': createdAt,
      if (familyId != null) 'family_id': familyId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AuditLogCompanion copyWith({
    Value<String>? id,
    Value<String>? entityType,
    Value<String>? entityId,
    Value<String>? action,
    Value<String?>? diff,
    Value<String>? actorUserId,
    Value<DateTime>? createdAt,
    Value<String>? familyId,
    Value<int>? rowid,
  }) {
    return AuditLogCompanion(
      id: id ?? this.id,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      action: action ?? this.action,
      diff: diff ?? this.diff,
      actorUserId: actorUserId ?? this.actorUserId,
      createdAt: createdAt ?? this.createdAt,
      familyId: familyId ?? this.familyId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (action.present) {
      map['action'] = Variable<String>(action.value);
    }
    if (diff.present) {
      map['diff'] = Variable<String>(diff.value);
    }
    if (actorUserId.present) {
      map['actor_user_id'] = Variable<String>(actorUserId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (familyId.present) {
      map['family_id'] = Variable<String>(familyId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AuditLogCompanion(')
          ..write('id: $id, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('action: $action, ')
          ..write('diff: $diff, ')
          ..write('actorUserId: $actorUserId, ')
          ..write('createdAt: $createdAt, ')
          ..write('familyId: $familyId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GoalsTable extends Goals with TableInfo<$GoalsTable, Goal> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GoalsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _targetAmountMeta = const VerificationMeta(
    'targetAmount',
  );
  @override
  late final GeneratedColumn<int> targetAmount = GeneratedColumn<int>(
    'target_amount',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetDateMeta = const VerificationMeta(
    'targetDate',
  );
  @override
  late final GeneratedColumn<DateTime> targetDate = GeneratedColumn<DateTime>(
    'target_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currentSavingsMeta = const VerificationMeta(
    'currentSavings',
  );
  @override
  late final GeneratedColumn<int> currentSavings = GeneratedColumn<int>(
    'current_savings',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _inflationRateMeta = const VerificationMeta(
    'inflationRate',
  );
  @override
  late final GeneratedColumn<double> inflationRate = GeneratedColumn<double>(
    'inflation_rate',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.06),
  );
  static const VerificationMeta _priorityMeta = const VerificationMeta(
    'priority',
  );
  @override
  late final GeneratedColumn<int> priority = GeneratedColumn<int>(
    'priority',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('active'),
  );
  static const VerificationMeta _linkedAccountIdMeta = const VerificationMeta(
    'linkedAccountId',
  );
  @override
  late final GeneratedColumn<String> linkedAccountId = GeneratedColumn<String>(
    'linked_account_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES accounts (id)',
    ),
  );
  static const VerificationMeta _familyIdMeta = const VerificationMeta(
    'familyId',
  );
  @override
  late final GeneratedColumn<String> familyId = GeneratedColumn<String>(
    'family_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES families (id)',
    ),
  );
  static const VerificationMeta _goalCategoryMeta = const VerificationMeta(
    'goalCategory',
  );
  @override
  late final GeneratedColumn<String> goalCategory = GeneratedColumn<String>(
    'goal_category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('investmentGoal'),
  );
  static const VerificationMeta _downPaymentPctBpMeta = const VerificationMeta(
    'downPaymentPctBp',
  );
  @override
  late final GeneratedColumn<int> downPaymentPctBp = GeneratedColumn<int>(
    'down_payment_pct_bp',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _educationEscalationRateBpMeta =
      const VerificationMeta('educationEscalationRateBp');
  @override
  late final GeneratedColumn<int> educationEscalationRateBp =
      GeneratedColumn<int>(
        'education_escalation_rate_bp',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _sinkingFundSubTypeMeta =
      const VerificationMeta('sinkingFundSubType');
  @override
  late final GeneratedColumn<String> sinkingFundSubType =
      GeneratedColumn<String>(
        'sinking_fund_sub_type',
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
    name,
    targetAmount,
    targetDate,
    currentSavings,
    inflationRate,
    priority,
    status,
    linkedAccountId,
    familyId,
    goalCategory,
    downPaymentPctBp,
    educationEscalationRateBp,
    sinkingFundSubType,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'goals';
  @override
  VerificationContext validateIntegrity(
    Insertable<Goal> instance, {
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
    if (data.containsKey('target_amount')) {
      context.handle(
        _targetAmountMeta,
        targetAmount.isAcceptableOrUnknown(
          data['target_amount']!,
          _targetAmountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_targetAmountMeta);
    }
    if (data.containsKey('target_date')) {
      context.handle(
        _targetDateMeta,
        targetDate.isAcceptableOrUnknown(data['target_date']!, _targetDateMeta),
      );
    } else if (isInserting) {
      context.missing(_targetDateMeta);
    }
    if (data.containsKey('current_savings')) {
      context.handle(
        _currentSavingsMeta,
        currentSavings.isAcceptableOrUnknown(
          data['current_savings']!,
          _currentSavingsMeta,
        ),
      );
    }
    if (data.containsKey('inflation_rate')) {
      context.handle(
        _inflationRateMeta,
        inflationRate.isAcceptableOrUnknown(
          data['inflation_rate']!,
          _inflationRateMeta,
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
    if (data.containsKey('linked_account_id')) {
      context.handle(
        _linkedAccountIdMeta,
        linkedAccountId.isAcceptableOrUnknown(
          data['linked_account_id']!,
          _linkedAccountIdMeta,
        ),
      );
    }
    if (data.containsKey('family_id')) {
      context.handle(
        _familyIdMeta,
        familyId.isAcceptableOrUnknown(data['family_id']!, _familyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_familyIdMeta);
    }
    if (data.containsKey('goal_category')) {
      context.handle(
        _goalCategoryMeta,
        goalCategory.isAcceptableOrUnknown(
          data['goal_category']!,
          _goalCategoryMeta,
        ),
      );
    }
    if (data.containsKey('down_payment_pct_bp')) {
      context.handle(
        _downPaymentPctBpMeta,
        downPaymentPctBp.isAcceptableOrUnknown(
          data['down_payment_pct_bp']!,
          _downPaymentPctBpMeta,
        ),
      );
    }
    if (data.containsKey('education_escalation_rate_bp')) {
      context.handle(
        _educationEscalationRateBpMeta,
        educationEscalationRateBp.isAcceptableOrUnknown(
          data['education_escalation_rate_bp']!,
          _educationEscalationRateBpMeta,
        ),
      );
    }
    if (data.containsKey('sinking_fund_sub_type')) {
      context.handle(
        _sinkingFundSubTypeMeta,
        sinkingFundSubType.isAcceptableOrUnknown(
          data['sinking_fund_sub_type']!,
          _sinkingFundSubTypeMeta,
        ),
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
  Goal map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Goal(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      targetAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target_amount'],
      )!,
      targetDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}target_date'],
      )!,
      currentSavings: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}current_savings'],
      )!,
      inflationRate: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}inflation_rate'],
      )!,
      priority: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}priority'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      linkedAccountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}linked_account_id'],
      ),
      familyId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}family_id'],
      )!,
      goalCategory: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}goal_category'],
      )!,
      downPaymentPctBp: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}down_payment_pct_bp'],
      ),
      educationEscalationRateBp: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}education_escalation_rate_bp'],
      ),
      sinkingFundSubType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sinking_fund_sub_type'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $GoalsTable createAlias(String alias) {
    return $GoalsTable(attachedDatabase, alias);
  }
}

class Goal extends DataClass implements Insertable<Goal> {
  final String id;
  final String name;
  final int targetAmount;
  final DateTime targetDate;
  final int currentSavings;
  final double inflationRate;
  final int priority;
  final String status;
  final String? linkedAccountId;
  final String familyId;
  final String goalCategory;
  final int? downPaymentPctBp;
  final int? educationEscalationRateBp;
  final String? sinkingFundSubType;
  final DateTime createdAt;
  const Goal({
    required this.id,
    required this.name,
    required this.targetAmount,
    required this.targetDate,
    required this.currentSavings,
    required this.inflationRate,
    required this.priority,
    required this.status,
    this.linkedAccountId,
    required this.familyId,
    required this.goalCategory,
    this.downPaymentPctBp,
    this.educationEscalationRateBp,
    this.sinkingFundSubType,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['target_amount'] = Variable<int>(targetAmount);
    map['target_date'] = Variable<DateTime>(targetDate);
    map['current_savings'] = Variable<int>(currentSavings);
    map['inflation_rate'] = Variable<double>(inflationRate);
    map['priority'] = Variable<int>(priority);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || linkedAccountId != null) {
      map['linked_account_id'] = Variable<String>(linkedAccountId);
    }
    map['family_id'] = Variable<String>(familyId);
    map['goal_category'] = Variable<String>(goalCategory);
    if (!nullToAbsent || downPaymentPctBp != null) {
      map['down_payment_pct_bp'] = Variable<int>(downPaymentPctBp);
    }
    if (!nullToAbsent || educationEscalationRateBp != null) {
      map['education_escalation_rate_bp'] = Variable<int>(
        educationEscalationRateBp,
      );
    }
    if (!nullToAbsent || sinkingFundSubType != null) {
      map['sinking_fund_sub_type'] = Variable<String>(sinkingFundSubType);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  GoalsCompanion toCompanion(bool nullToAbsent) {
    return GoalsCompanion(
      id: Value(id),
      name: Value(name),
      targetAmount: Value(targetAmount),
      targetDate: Value(targetDate),
      currentSavings: Value(currentSavings),
      inflationRate: Value(inflationRate),
      priority: Value(priority),
      status: Value(status),
      linkedAccountId: linkedAccountId == null && nullToAbsent
          ? const Value.absent()
          : Value(linkedAccountId),
      familyId: Value(familyId),
      goalCategory: Value(goalCategory),
      downPaymentPctBp: downPaymentPctBp == null && nullToAbsent
          ? const Value.absent()
          : Value(downPaymentPctBp),
      educationEscalationRateBp:
          educationEscalationRateBp == null && nullToAbsent
          ? const Value.absent()
          : Value(educationEscalationRateBp),
      sinkingFundSubType: sinkingFundSubType == null && nullToAbsent
          ? const Value.absent()
          : Value(sinkingFundSubType),
      createdAt: Value(createdAt),
    );
  }

  factory Goal.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Goal(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      targetAmount: serializer.fromJson<int>(json['targetAmount']),
      targetDate: serializer.fromJson<DateTime>(json['targetDate']),
      currentSavings: serializer.fromJson<int>(json['currentSavings']),
      inflationRate: serializer.fromJson<double>(json['inflationRate']),
      priority: serializer.fromJson<int>(json['priority']),
      status: serializer.fromJson<String>(json['status']),
      linkedAccountId: serializer.fromJson<String?>(json['linkedAccountId']),
      familyId: serializer.fromJson<String>(json['familyId']),
      goalCategory: serializer.fromJson<String>(json['goalCategory']),
      downPaymentPctBp: serializer.fromJson<int?>(json['downPaymentPctBp']),
      educationEscalationRateBp: serializer.fromJson<int?>(
        json['educationEscalationRateBp'],
      ),
      sinkingFundSubType: serializer.fromJson<String?>(
        json['sinkingFundSubType'],
      ),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'targetAmount': serializer.toJson<int>(targetAmount),
      'targetDate': serializer.toJson<DateTime>(targetDate),
      'currentSavings': serializer.toJson<int>(currentSavings),
      'inflationRate': serializer.toJson<double>(inflationRate),
      'priority': serializer.toJson<int>(priority),
      'status': serializer.toJson<String>(status),
      'linkedAccountId': serializer.toJson<String?>(linkedAccountId),
      'familyId': serializer.toJson<String>(familyId),
      'goalCategory': serializer.toJson<String>(goalCategory),
      'downPaymentPctBp': serializer.toJson<int?>(downPaymentPctBp),
      'educationEscalationRateBp': serializer.toJson<int?>(
        educationEscalationRateBp,
      ),
      'sinkingFundSubType': serializer.toJson<String?>(sinkingFundSubType),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Goal copyWith({
    String? id,
    String? name,
    int? targetAmount,
    DateTime? targetDate,
    int? currentSavings,
    double? inflationRate,
    int? priority,
    String? status,
    Value<String?> linkedAccountId = const Value.absent(),
    String? familyId,
    String? goalCategory,
    Value<int?> downPaymentPctBp = const Value.absent(),
    Value<int?> educationEscalationRateBp = const Value.absent(),
    Value<String?> sinkingFundSubType = const Value.absent(),
    DateTime? createdAt,
  }) => Goal(
    id: id ?? this.id,
    name: name ?? this.name,
    targetAmount: targetAmount ?? this.targetAmount,
    targetDate: targetDate ?? this.targetDate,
    currentSavings: currentSavings ?? this.currentSavings,
    inflationRate: inflationRate ?? this.inflationRate,
    priority: priority ?? this.priority,
    status: status ?? this.status,
    linkedAccountId: linkedAccountId.present
        ? linkedAccountId.value
        : this.linkedAccountId,
    familyId: familyId ?? this.familyId,
    goalCategory: goalCategory ?? this.goalCategory,
    downPaymentPctBp: downPaymentPctBp.present
        ? downPaymentPctBp.value
        : this.downPaymentPctBp,
    educationEscalationRateBp: educationEscalationRateBp.present
        ? educationEscalationRateBp.value
        : this.educationEscalationRateBp,
    sinkingFundSubType: sinkingFundSubType.present
        ? sinkingFundSubType.value
        : this.sinkingFundSubType,
    createdAt: createdAt ?? this.createdAt,
  );
  Goal copyWithCompanion(GoalsCompanion data) {
    return Goal(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      targetAmount: data.targetAmount.present
          ? data.targetAmount.value
          : this.targetAmount,
      targetDate: data.targetDate.present
          ? data.targetDate.value
          : this.targetDate,
      currentSavings: data.currentSavings.present
          ? data.currentSavings.value
          : this.currentSavings,
      inflationRate: data.inflationRate.present
          ? data.inflationRate.value
          : this.inflationRate,
      priority: data.priority.present ? data.priority.value : this.priority,
      status: data.status.present ? data.status.value : this.status,
      linkedAccountId: data.linkedAccountId.present
          ? data.linkedAccountId.value
          : this.linkedAccountId,
      familyId: data.familyId.present ? data.familyId.value : this.familyId,
      goalCategory: data.goalCategory.present
          ? data.goalCategory.value
          : this.goalCategory,
      downPaymentPctBp: data.downPaymentPctBp.present
          ? data.downPaymentPctBp.value
          : this.downPaymentPctBp,
      educationEscalationRateBp: data.educationEscalationRateBp.present
          ? data.educationEscalationRateBp.value
          : this.educationEscalationRateBp,
      sinkingFundSubType: data.sinkingFundSubType.present
          ? data.sinkingFundSubType.value
          : this.sinkingFundSubType,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Goal(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('targetAmount: $targetAmount, ')
          ..write('targetDate: $targetDate, ')
          ..write('currentSavings: $currentSavings, ')
          ..write('inflationRate: $inflationRate, ')
          ..write('priority: $priority, ')
          ..write('status: $status, ')
          ..write('linkedAccountId: $linkedAccountId, ')
          ..write('familyId: $familyId, ')
          ..write('goalCategory: $goalCategory, ')
          ..write('downPaymentPctBp: $downPaymentPctBp, ')
          ..write('educationEscalationRateBp: $educationEscalationRateBp, ')
          ..write('sinkingFundSubType: $sinkingFundSubType, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    targetAmount,
    targetDate,
    currentSavings,
    inflationRate,
    priority,
    status,
    linkedAccountId,
    familyId,
    goalCategory,
    downPaymentPctBp,
    educationEscalationRateBp,
    sinkingFundSubType,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Goal &&
          other.id == this.id &&
          other.name == this.name &&
          other.targetAmount == this.targetAmount &&
          other.targetDate == this.targetDate &&
          other.currentSavings == this.currentSavings &&
          other.inflationRate == this.inflationRate &&
          other.priority == this.priority &&
          other.status == this.status &&
          other.linkedAccountId == this.linkedAccountId &&
          other.familyId == this.familyId &&
          other.goalCategory == this.goalCategory &&
          other.downPaymentPctBp == this.downPaymentPctBp &&
          other.educationEscalationRateBp == this.educationEscalationRateBp &&
          other.sinkingFundSubType == this.sinkingFundSubType &&
          other.createdAt == this.createdAt);
}

class GoalsCompanion extends UpdateCompanion<Goal> {
  final Value<String> id;
  final Value<String> name;
  final Value<int> targetAmount;
  final Value<DateTime> targetDate;
  final Value<int> currentSavings;
  final Value<double> inflationRate;
  final Value<int> priority;
  final Value<String> status;
  final Value<String?> linkedAccountId;
  final Value<String> familyId;
  final Value<String> goalCategory;
  final Value<int?> downPaymentPctBp;
  final Value<int?> educationEscalationRateBp;
  final Value<String?> sinkingFundSubType;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const GoalsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.targetAmount = const Value.absent(),
    this.targetDate = const Value.absent(),
    this.currentSavings = const Value.absent(),
    this.inflationRate = const Value.absent(),
    this.priority = const Value.absent(),
    this.status = const Value.absent(),
    this.linkedAccountId = const Value.absent(),
    this.familyId = const Value.absent(),
    this.goalCategory = const Value.absent(),
    this.downPaymentPctBp = const Value.absent(),
    this.educationEscalationRateBp = const Value.absent(),
    this.sinkingFundSubType = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GoalsCompanion.insert({
    required String id,
    required String name,
    required int targetAmount,
    required DateTime targetDate,
    this.currentSavings = const Value.absent(),
    this.inflationRate = const Value.absent(),
    this.priority = const Value.absent(),
    this.status = const Value.absent(),
    this.linkedAccountId = const Value.absent(),
    required String familyId,
    this.goalCategory = const Value.absent(),
    this.downPaymentPctBp = const Value.absent(),
    this.educationEscalationRateBp = const Value.absent(),
    this.sinkingFundSubType = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       targetAmount = Value(targetAmount),
       targetDate = Value(targetDate),
       familyId = Value(familyId),
       createdAt = Value(createdAt);
  static Insertable<Goal> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<int>? targetAmount,
    Expression<DateTime>? targetDate,
    Expression<int>? currentSavings,
    Expression<double>? inflationRate,
    Expression<int>? priority,
    Expression<String>? status,
    Expression<String>? linkedAccountId,
    Expression<String>? familyId,
    Expression<String>? goalCategory,
    Expression<int>? downPaymentPctBp,
    Expression<int>? educationEscalationRateBp,
    Expression<String>? sinkingFundSubType,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (targetAmount != null) 'target_amount': targetAmount,
      if (targetDate != null) 'target_date': targetDate,
      if (currentSavings != null) 'current_savings': currentSavings,
      if (inflationRate != null) 'inflation_rate': inflationRate,
      if (priority != null) 'priority': priority,
      if (status != null) 'status': status,
      if (linkedAccountId != null) 'linked_account_id': linkedAccountId,
      if (familyId != null) 'family_id': familyId,
      if (goalCategory != null) 'goal_category': goalCategory,
      if (downPaymentPctBp != null) 'down_payment_pct_bp': downPaymentPctBp,
      if (educationEscalationRateBp != null)
        'education_escalation_rate_bp': educationEscalationRateBp,
      if (sinkingFundSubType != null)
        'sinking_fund_sub_type': sinkingFundSubType,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GoalsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<int>? targetAmount,
    Value<DateTime>? targetDate,
    Value<int>? currentSavings,
    Value<double>? inflationRate,
    Value<int>? priority,
    Value<String>? status,
    Value<String?>? linkedAccountId,
    Value<String>? familyId,
    Value<String>? goalCategory,
    Value<int?>? downPaymentPctBp,
    Value<int?>? educationEscalationRateBp,
    Value<String?>? sinkingFundSubType,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return GoalsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      targetAmount: targetAmount ?? this.targetAmount,
      targetDate: targetDate ?? this.targetDate,
      currentSavings: currentSavings ?? this.currentSavings,
      inflationRate: inflationRate ?? this.inflationRate,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      linkedAccountId: linkedAccountId ?? this.linkedAccountId,
      familyId: familyId ?? this.familyId,
      goalCategory: goalCategory ?? this.goalCategory,
      downPaymentPctBp: downPaymentPctBp ?? this.downPaymentPctBp,
      educationEscalationRateBp:
          educationEscalationRateBp ?? this.educationEscalationRateBp,
      sinkingFundSubType: sinkingFundSubType ?? this.sinkingFundSubType,
      createdAt: createdAt ?? this.createdAt,
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
    if (targetAmount.present) {
      map['target_amount'] = Variable<int>(targetAmount.value);
    }
    if (targetDate.present) {
      map['target_date'] = Variable<DateTime>(targetDate.value);
    }
    if (currentSavings.present) {
      map['current_savings'] = Variable<int>(currentSavings.value);
    }
    if (inflationRate.present) {
      map['inflation_rate'] = Variable<double>(inflationRate.value);
    }
    if (priority.present) {
      map['priority'] = Variable<int>(priority.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (linkedAccountId.present) {
      map['linked_account_id'] = Variable<String>(linkedAccountId.value);
    }
    if (familyId.present) {
      map['family_id'] = Variable<String>(familyId.value);
    }
    if (goalCategory.present) {
      map['goal_category'] = Variable<String>(goalCategory.value);
    }
    if (downPaymentPctBp.present) {
      map['down_payment_pct_bp'] = Variable<int>(downPaymentPctBp.value);
    }
    if (educationEscalationRateBp.present) {
      map['education_escalation_rate_bp'] = Variable<int>(
        educationEscalationRateBp.value,
      );
    }
    if (sinkingFundSubType.present) {
      map['sinking_fund_sub_type'] = Variable<String>(sinkingFundSubType.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GoalsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('targetAmount: $targetAmount, ')
          ..write('targetDate: $targetDate, ')
          ..write('currentSavings: $currentSavings, ')
          ..write('inflationRate: $inflationRate, ')
          ..write('priority: $priority, ')
          ..write('status: $status, ')
          ..write('linkedAccountId: $linkedAccountId, ')
          ..write('familyId: $familyId, ')
          ..write('goalCategory: $goalCategory, ')
          ..write('downPaymentPctBp: $downPaymentPctBp, ')
          ..write('educationEscalationRateBp: $educationEscalationRateBp, ')
          ..write('sinkingFundSubType: $sinkingFundSubType, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BudgetsTable extends Budgets with TableInfo<$BudgetsTable, Budget> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BudgetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _familyIdMeta = const VerificationMeta(
    'familyId',
  );
  @override
  late final GeneratedColumn<String> familyId = GeneratedColumn<String>(
    'family_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES families (id)',
    ),
  );
  static const VerificationMeta _yearMeta = const VerificationMeta('year');
  @override
  late final GeneratedColumn<int> year = GeneratedColumn<int>(
    'year',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _monthMeta = const VerificationMeta('month');
  @override
  late final GeneratedColumn<int> month = GeneratedColumn<int>(
    'month',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryGroupMeta = const VerificationMeta(
    'categoryGroup',
  );
  @override
  late final GeneratedColumn<String> categoryGroup = GeneratedColumn<String>(
    'category_group',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _limitAmountMeta = const VerificationMeta(
    'limitAmount',
  );
  @override
  late final GeneratedColumn<int> limitAmount = GeneratedColumn<int>(
    'limit_amount',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    familyId,
    year,
    month,
    categoryGroup,
    limitAmount,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'budgets';
  @override
  VerificationContext validateIntegrity(
    Insertable<Budget> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('family_id')) {
      context.handle(
        _familyIdMeta,
        familyId.isAcceptableOrUnknown(data['family_id']!, _familyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_familyIdMeta);
    }
    if (data.containsKey('year')) {
      context.handle(
        _yearMeta,
        year.isAcceptableOrUnknown(data['year']!, _yearMeta),
      );
    } else if (isInserting) {
      context.missing(_yearMeta);
    }
    if (data.containsKey('month')) {
      context.handle(
        _monthMeta,
        month.isAcceptableOrUnknown(data['month']!, _monthMeta),
      );
    } else if (isInserting) {
      context.missing(_monthMeta);
    }
    if (data.containsKey('category_group')) {
      context.handle(
        _categoryGroupMeta,
        categoryGroup.isAcceptableOrUnknown(
          data['category_group']!,
          _categoryGroupMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_categoryGroupMeta);
    }
    if (data.containsKey('limit_amount')) {
      context.handle(
        _limitAmountMeta,
        limitAmount.isAcceptableOrUnknown(
          data['limit_amount']!,
          _limitAmountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_limitAmountMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Budget map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Budget(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      familyId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}family_id'],
      )!,
      year: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}year'],
      )!,
      month: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}month'],
      )!,
      categoryGroup: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_group'],
      )!,
      limitAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}limit_amount'],
      )!,
    );
  }

  @override
  $BudgetsTable createAlias(String alias) {
    return $BudgetsTable(attachedDatabase, alias);
  }
}

class Budget extends DataClass implements Insertable<Budget> {
  final String id;
  final String familyId;
  final int year;
  final int month;
  final String categoryGroup;
  final int limitAmount;
  const Budget({
    required this.id,
    required this.familyId,
    required this.year,
    required this.month,
    required this.categoryGroup,
    required this.limitAmount,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['family_id'] = Variable<String>(familyId);
    map['year'] = Variable<int>(year);
    map['month'] = Variable<int>(month);
    map['category_group'] = Variable<String>(categoryGroup);
    map['limit_amount'] = Variable<int>(limitAmount);
    return map;
  }

  BudgetsCompanion toCompanion(bool nullToAbsent) {
    return BudgetsCompanion(
      id: Value(id),
      familyId: Value(familyId),
      year: Value(year),
      month: Value(month),
      categoryGroup: Value(categoryGroup),
      limitAmount: Value(limitAmount),
    );
  }

  factory Budget.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Budget(
      id: serializer.fromJson<String>(json['id']),
      familyId: serializer.fromJson<String>(json['familyId']),
      year: serializer.fromJson<int>(json['year']),
      month: serializer.fromJson<int>(json['month']),
      categoryGroup: serializer.fromJson<String>(json['categoryGroup']),
      limitAmount: serializer.fromJson<int>(json['limitAmount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'familyId': serializer.toJson<String>(familyId),
      'year': serializer.toJson<int>(year),
      'month': serializer.toJson<int>(month),
      'categoryGroup': serializer.toJson<String>(categoryGroup),
      'limitAmount': serializer.toJson<int>(limitAmount),
    };
  }

  Budget copyWith({
    String? id,
    String? familyId,
    int? year,
    int? month,
    String? categoryGroup,
    int? limitAmount,
  }) => Budget(
    id: id ?? this.id,
    familyId: familyId ?? this.familyId,
    year: year ?? this.year,
    month: month ?? this.month,
    categoryGroup: categoryGroup ?? this.categoryGroup,
    limitAmount: limitAmount ?? this.limitAmount,
  );
  Budget copyWithCompanion(BudgetsCompanion data) {
    return Budget(
      id: data.id.present ? data.id.value : this.id,
      familyId: data.familyId.present ? data.familyId.value : this.familyId,
      year: data.year.present ? data.year.value : this.year,
      month: data.month.present ? data.month.value : this.month,
      categoryGroup: data.categoryGroup.present
          ? data.categoryGroup.value
          : this.categoryGroup,
      limitAmount: data.limitAmount.present
          ? data.limitAmount.value
          : this.limitAmount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Budget(')
          ..write('id: $id, ')
          ..write('familyId: $familyId, ')
          ..write('year: $year, ')
          ..write('month: $month, ')
          ..write('categoryGroup: $categoryGroup, ')
          ..write('limitAmount: $limitAmount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, familyId, year, month, categoryGroup, limitAmount);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Budget &&
          other.id == this.id &&
          other.familyId == this.familyId &&
          other.year == this.year &&
          other.month == this.month &&
          other.categoryGroup == this.categoryGroup &&
          other.limitAmount == this.limitAmount);
}

class BudgetsCompanion extends UpdateCompanion<Budget> {
  final Value<String> id;
  final Value<String> familyId;
  final Value<int> year;
  final Value<int> month;
  final Value<String> categoryGroup;
  final Value<int> limitAmount;
  final Value<int> rowid;
  const BudgetsCompanion({
    this.id = const Value.absent(),
    this.familyId = const Value.absent(),
    this.year = const Value.absent(),
    this.month = const Value.absent(),
    this.categoryGroup = const Value.absent(),
    this.limitAmount = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BudgetsCompanion.insert({
    required String id,
    required String familyId,
    required int year,
    required int month,
    required String categoryGroup,
    required int limitAmount,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       familyId = Value(familyId),
       year = Value(year),
       month = Value(month),
       categoryGroup = Value(categoryGroup),
       limitAmount = Value(limitAmount);
  static Insertable<Budget> custom({
    Expression<String>? id,
    Expression<String>? familyId,
    Expression<int>? year,
    Expression<int>? month,
    Expression<String>? categoryGroup,
    Expression<int>? limitAmount,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (familyId != null) 'family_id': familyId,
      if (year != null) 'year': year,
      if (month != null) 'month': month,
      if (categoryGroup != null) 'category_group': categoryGroup,
      if (limitAmount != null) 'limit_amount': limitAmount,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BudgetsCompanion copyWith({
    Value<String>? id,
    Value<String>? familyId,
    Value<int>? year,
    Value<int>? month,
    Value<String>? categoryGroup,
    Value<int>? limitAmount,
    Value<int>? rowid,
  }) {
    return BudgetsCompanion(
      id: id ?? this.id,
      familyId: familyId ?? this.familyId,
      year: year ?? this.year,
      month: month ?? this.month,
      categoryGroup: categoryGroup ?? this.categoryGroup,
      limitAmount: limitAmount ?? this.limitAmount,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (familyId.present) {
      map['family_id'] = Variable<String>(familyId.value);
    }
    if (year.present) {
      map['year'] = Variable<int>(year.value);
    }
    if (month.present) {
      map['month'] = Variable<int>(month.value);
    }
    if (categoryGroup.present) {
      map['category_group'] = Variable<String>(categoryGroup.value);
    }
    if (limitAmount.present) {
      map['limit_amount'] = Variable<int>(limitAmount.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BudgetsCompanion(')
          ..write('id: $id, ')
          ..write('familyId: $familyId, ')
          ..write('year: $year, ')
          ..write('month: $month, ')
          ..write('categoryGroup: $categoryGroup, ')
          ..write('limitAmount: $limitAmount, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LoanDetailsTable extends LoanDetails
    with TableInfo<$LoanDetailsTable, LoanDetail> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LoanDetailsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _accountIdMeta = const VerificationMeta(
    'accountId',
  );
  @override
  late final GeneratedColumn<String> accountId = GeneratedColumn<String>(
    'account_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES accounts (id)',
    ),
  );
  static const VerificationMeta _principalMeta = const VerificationMeta(
    'principal',
  );
  @override
  late final GeneratedColumn<int> principal = GeneratedColumn<int>(
    'principal',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _annualRateMeta = const VerificationMeta(
    'annualRate',
  );
  @override
  late final GeneratedColumn<double> annualRate = GeneratedColumn<double>(
    'annual_rate',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tenureMonthsMeta = const VerificationMeta(
    'tenureMonths',
  );
  @override
  late final GeneratedColumn<int> tenureMonths = GeneratedColumn<int>(
    'tenure_months',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _outstandingPrincipalMeta =
      const VerificationMeta('outstandingPrincipal');
  @override
  late final GeneratedColumn<int> outstandingPrincipal = GeneratedColumn<int>(
    'outstanding_principal',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _emiAmountMeta = const VerificationMeta(
    'emiAmount',
  );
  @override
  late final GeneratedColumn<int> emiAmount = GeneratedColumn<int>(
    'emi_amount',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startDateMeta = const VerificationMeta(
    'startDate',
  );
  @override
  late final GeneratedColumn<DateTime> startDate = GeneratedColumn<DateTime>(
    'start_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _disbursementDateMeta = const VerificationMeta(
    'disbursementDate',
  );
  @override
  late final GeneratedColumn<DateTime> disbursementDate =
      GeneratedColumn<DateTime>(
        'disbursement_date',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _familyIdMeta = const VerificationMeta(
    'familyId',
  );
  @override
  late final GeneratedColumn<String> familyId = GeneratedColumn<String>(
    'family_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES families (id)',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    accountId,
    principal,
    annualRate,
    tenureMonths,
    outstandingPrincipal,
    emiAmount,
    startDate,
    disbursementDate,
    familyId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'loan_details';
  @override
  VerificationContext validateIntegrity(
    Insertable<LoanDetail> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('account_id')) {
      context.handle(
        _accountIdMeta,
        accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta),
      );
    } else if (isInserting) {
      context.missing(_accountIdMeta);
    }
    if (data.containsKey('principal')) {
      context.handle(
        _principalMeta,
        principal.isAcceptableOrUnknown(data['principal']!, _principalMeta),
      );
    } else if (isInserting) {
      context.missing(_principalMeta);
    }
    if (data.containsKey('annual_rate')) {
      context.handle(
        _annualRateMeta,
        annualRate.isAcceptableOrUnknown(data['annual_rate']!, _annualRateMeta),
      );
    } else if (isInserting) {
      context.missing(_annualRateMeta);
    }
    if (data.containsKey('tenure_months')) {
      context.handle(
        _tenureMonthsMeta,
        tenureMonths.isAcceptableOrUnknown(
          data['tenure_months']!,
          _tenureMonthsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_tenureMonthsMeta);
    }
    if (data.containsKey('outstanding_principal')) {
      context.handle(
        _outstandingPrincipalMeta,
        outstandingPrincipal.isAcceptableOrUnknown(
          data['outstanding_principal']!,
          _outstandingPrincipalMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_outstandingPrincipalMeta);
    }
    if (data.containsKey('emi_amount')) {
      context.handle(
        _emiAmountMeta,
        emiAmount.isAcceptableOrUnknown(data['emi_amount']!, _emiAmountMeta),
      );
    } else if (isInserting) {
      context.missing(_emiAmountMeta);
    }
    if (data.containsKey('start_date')) {
      context.handle(
        _startDateMeta,
        startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta),
      );
    } else if (isInserting) {
      context.missing(_startDateMeta);
    }
    if (data.containsKey('disbursement_date')) {
      context.handle(
        _disbursementDateMeta,
        disbursementDate.isAcceptableOrUnknown(
          data['disbursement_date']!,
          _disbursementDateMeta,
        ),
      );
    }
    if (data.containsKey('family_id')) {
      context.handle(
        _familyIdMeta,
        familyId.isAcceptableOrUnknown(data['family_id']!, _familyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_familyIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LoanDetail map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LoanDetail(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      accountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_id'],
      )!,
      principal: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}principal'],
      )!,
      annualRate: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}annual_rate'],
      )!,
      tenureMonths: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}tenure_months'],
      )!,
      outstandingPrincipal: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}outstanding_principal'],
      )!,
      emiAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}emi_amount'],
      )!,
      startDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}start_date'],
      )!,
      disbursementDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}disbursement_date'],
      ),
      familyId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}family_id'],
      )!,
    );
  }

  @override
  $LoanDetailsTable createAlias(String alias) {
    return $LoanDetailsTable(attachedDatabase, alias);
  }
}

class LoanDetail extends DataClass implements Insertable<LoanDetail> {
  final String id;
  final String accountId;
  final int principal;
  final double annualRate;
  final int tenureMonths;
  final int outstandingPrincipal;
  final int emiAmount;
  final DateTime startDate;
  final DateTime? disbursementDate;
  final String familyId;
  const LoanDetail({
    required this.id,
    required this.accountId,
    required this.principal,
    required this.annualRate,
    required this.tenureMonths,
    required this.outstandingPrincipal,
    required this.emiAmount,
    required this.startDate,
    this.disbursementDate,
    required this.familyId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['account_id'] = Variable<String>(accountId);
    map['principal'] = Variable<int>(principal);
    map['annual_rate'] = Variable<double>(annualRate);
    map['tenure_months'] = Variable<int>(tenureMonths);
    map['outstanding_principal'] = Variable<int>(outstandingPrincipal);
    map['emi_amount'] = Variable<int>(emiAmount);
    map['start_date'] = Variable<DateTime>(startDate);
    if (!nullToAbsent || disbursementDate != null) {
      map['disbursement_date'] = Variable<DateTime>(disbursementDate);
    }
    map['family_id'] = Variable<String>(familyId);
    return map;
  }

  LoanDetailsCompanion toCompanion(bool nullToAbsent) {
    return LoanDetailsCompanion(
      id: Value(id),
      accountId: Value(accountId),
      principal: Value(principal),
      annualRate: Value(annualRate),
      tenureMonths: Value(tenureMonths),
      outstandingPrincipal: Value(outstandingPrincipal),
      emiAmount: Value(emiAmount),
      startDate: Value(startDate),
      disbursementDate: disbursementDate == null && nullToAbsent
          ? const Value.absent()
          : Value(disbursementDate),
      familyId: Value(familyId),
    );
  }

  factory LoanDetail.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LoanDetail(
      id: serializer.fromJson<String>(json['id']),
      accountId: serializer.fromJson<String>(json['accountId']),
      principal: serializer.fromJson<int>(json['principal']),
      annualRate: serializer.fromJson<double>(json['annualRate']),
      tenureMonths: serializer.fromJson<int>(json['tenureMonths']),
      outstandingPrincipal: serializer.fromJson<int>(
        json['outstandingPrincipal'],
      ),
      emiAmount: serializer.fromJson<int>(json['emiAmount']),
      startDate: serializer.fromJson<DateTime>(json['startDate']),
      disbursementDate: serializer.fromJson<DateTime?>(
        json['disbursementDate'],
      ),
      familyId: serializer.fromJson<String>(json['familyId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'accountId': serializer.toJson<String>(accountId),
      'principal': serializer.toJson<int>(principal),
      'annualRate': serializer.toJson<double>(annualRate),
      'tenureMonths': serializer.toJson<int>(tenureMonths),
      'outstandingPrincipal': serializer.toJson<int>(outstandingPrincipal),
      'emiAmount': serializer.toJson<int>(emiAmount),
      'startDate': serializer.toJson<DateTime>(startDate),
      'disbursementDate': serializer.toJson<DateTime?>(disbursementDate),
      'familyId': serializer.toJson<String>(familyId),
    };
  }

  LoanDetail copyWith({
    String? id,
    String? accountId,
    int? principal,
    double? annualRate,
    int? tenureMonths,
    int? outstandingPrincipal,
    int? emiAmount,
    DateTime? startDate,
    Value<DateTime?> disbursementDate = const Value.absent(),
    String? familyId,
  }) => LoanDetail(
    id: id ?? this.id,
    accountId: accountId ?? this.accountId,
    principal: principal ?? this.principal,
    annualRate: annualRate ?? this.annualRate,
    tenureMonths: tenureMonths ?? this.tenureMonths,
    outstandingPrincipal: outstandingPrincipal ?? this.outstandingPrincipal,
    emiAmount: emiAmount ?? this.emiAmount,
    startDate: startDate ?? this.startDate,
    disbursementDate: disbursementDate.present
        ? disbursementDate.value
        : this.disbursementDate,
    familyId: familyId ?? this.familyId,
  );
  LoanDetail copyWithCompanion(LoanDetailsCompanion data) {
    return LoanDetail(
      id: data.id.present ? data.id.value : this.id,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      principal: data.principal.present ? data.principal.value : this.principal,
      annualRate: data.annualRate.present
          ? data.annualRate.value
          : this.annualRate,
      tenureMonths: data.tenureMonths.present
          ? data.tenureMonths.value
          : this.tenureMonths,
      outstandingPrincipal: data.outstandingPrincipal.present
          ? data.outstandingPrincipal.value
          : this.outstandingPrincipal,
      emiAmount: data.emiAmount.present ? data.emiAmount.value : this.emiAmount,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      disbursementDate: data.disbursementDate.present
          ? data.disbursementDate.value
          : this.disbursementDate,
      familyId: data.familyId.present ? data.familyId.value : this.familyId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LoanDetail(')
          ..write('id: $id, ')
          ..write('accountId: $accountId, ')
          ..write('principal: $principal, ')
          ..write('annualRate: $annualRate, ')
          ..write('tenureMonths: $tenureMonths, ')
          ..write('outstandingPrincipal: $outstandingPrincipal, ')
          ..write('emiAmount: $emiAmount, ')
          ..write('startDate: $startDate, ')
          ..write('disbursementDate: $disbursementDate, ')
          ..write('familyId: $familyId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    accountId,
    principal,
    annualRate,
    tenureMonths,
    outstandingPrincipal,
    emiAmount,
    startDate,
    disbursementDate,
    familyId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LoanDetail &&
          other.id == this.id &&
          other.accountId == this.accountId &&
          other.principal == this.principal &&
          other.annualRate == this.annualRate &&
          other.tenureMonths == this.tenureMonths &&
          other.outstandingPrincipal == this.outstandingPrincipal &&
          other.emiAmount == this.emiAmount &&
          other.startDate == this.startDate &&
          other.disbursementDate == this.disbursementDate &&
          other.familyId == this.familyId);
}

class LoanDetailsCompanion extends UpdateCompanion<LoanDetail> {
  final Value<String> id;
  final Value<String> accountId;
  final Value<int> principal;
  final Value<double> annualRate;
  final Value<int> tenureMonths;
  final Value<int> outstandingPrincipal;
  final Value<int> emiAmount;
  final Value<DateTime> startDate;
  final Value<DateTime?> disbursementDate;
  final Value<String> familyId;
  final Value<int> rowid;
  const LoanDetailsCompanion({
    this.id = const Value.absent(),
    this.accountId = const Value.absent(),
    this.principal = const Value.absent(),
    this.annualRate = const Value.absent(),
    this.tenureMonths = const Value.absent(),
    this.outstandingPrincipal = const Value.absent(),
    this.emiAmount = const Value.absent(),
    this.startDate = const Value.absent(),
    this.disbursementDate = const Value.absent(),
    this.familyId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LoanDetailsCompanion.insert({
    required String id,
    required String accountId,
    required int principal,
    required double annualRate,
    required int tenureMonths,
    required int outstandingPrincipal,
    required int emiAmount,
    required DateTime startDate,
    this.disbursementDate = const Value.absent(),
    required String familyId,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       accountId = Value(accountId),
       principal = Value(principal),
       annualRate = Value(annualRate),
       tenureMonths = Value(tenureMonths),
       outstandingPrincipal = Value(outstandingPrincipal),
       emiAmount = Value(emiAmount),
       startDate = Value(startDate),
       familyId = Value(familyId);
  static Insertable<LoanDetail> custom({
    Expression<String>? id,
    Expression<String>? accountId,
    Expression<int>? principal,
    Expression<double>? annualRate,
    Expression<int>? tenureMonths,
    Expression<int>? outstandingPrincipal,
    Expression<int>? emiAmount,
    Expression<DateTime>? startDate,
    Expression<DateTime>? disbursementDate,
    Expression<String>? familyId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (accountId != null) 'account_id': accountId,
      if (principal != null) 'principal': principal,
      if (annualRate != null) 'annual_rate': annualRate,
      if (tenureMonths != null) 'tenure_months': tenureMonths,
      if (outstandingPrincipal != null)
        'outstanding_principal': outstandingPrincipal,
      if (emiAmount != null) 'emi_amount': emiAmount,
      if (startDate != null) 'start_date': startDate,
      if (disbursementDate != null) 'disbursement_date': disbursementDate,
      if (familyId != null) 'family_id': familyId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LoanDetailsCompanion copyWith({
    Value<String>? id,
    Value<String>? accountId,
    Value<int>? principal,
    Value<double>? annualRate,
    Value<int>? tenureMonths,
    Value<int>? outstandingPrincipal,
    Value<int>? emiAmount,
    Value<DateTime>? startDate,
    Value<DateTime?>? disbursementDate,
    Value<String>? familyId,
    Value<int>? rowid,
  }) {
    return LoanDetailsCompanion(
      id: id ?? this.id,
      accountId: accountId ?? this.accountId,
      principal: principal ?? this.principal,
      annualRate: annualRate ?? this.annualRate,
      tenureMonths: tenureMonths ?? this.tenureMonths,
      outstandingPrincipal: outstandingPrincipal ?? this.outstandingPrincipal,
      emiAmount: emiAmount ?? this.emiAmount,
      startDate: startDate ?? this.startDate,
      disbursementDate: disbursementDate ?? this.disbursementDate,
      familyId: familyId ?? this.familyId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<String>(accountId.value);
    }
    if (principal.present) {
      map['principal'] = Variable<int>(principal.value);
    }
    if (annualRate.present) {
      map['annual_rate'] = Variable<double>(annualRate.value);
    }
    if (tenureMonths.present) {
      map['tenure_months'] = Variable<int>(tenureMonths.value);
    }
    if (outstandingPrincipal.present) {
      map['outstanding_principal'] = Variable<int>(outstandingPrincipal.value);
    }
    if (emiAmount.present) {
      map['emi_amount'] = Variable<int>(emiAmount.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<DateTime>(startDate.value);
    }
    if (disbursementDate.present) {
      map['disbursement_date'] = Variable<DateTime>(disbursementDate.value);
    }
    if (familyId.present) {
      map['family_id'] = Variable<String>(familyId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LoanDetailsCompanion(')
          ..write('id: $id, ')
          ..write('accountId: $accountId, ')
          ..write('principal: $principal, ')
          ..write('annualRate: $annualRate, ')
          ..write('tenureMonths: $tenureMonths, ')
          ..write('outstandingPrincipal: $outstandingPrincipal, ')
          ..write('emiAmount: $emiAmount, ')
          ..write('startDate: $startDate, ')
          ..write('disbursementDate: $disbursementDate, ')
          ..write('familyId: $familyId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $InvestmentHoldingsTable extends InvestmentHoldings
    with TableInfo<$InvestmentHoldingsTable, InvestmentHolding> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InvestmentHoldingsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _bucketTypeMeta = const VerificationMeta(
    'bucketType',
  );
  @override
  late final GeneratedColumn<String> bucketType = GeneratedColumn<String>(
    'bucket_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _investedAmountMeta = const VerificationMeta(
    'investedAmount',
  );
  @override
  late final GeneratedColumn<int> investedAmount = GeneratedColumn<int>(
    'invested_amount',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currentValueMeta = const VerificationMeta(
    'currentValue',
  );
  @override
  late final GeneratedColumn<int> currentValue = GeneratedColumn<int>(
    'current_value',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _expectedReturnRateMeta =
      const VerificationMeta('expectedReturnRate');
  @override
  late final GeneratedColumn<double> expectedReturnRate =
      GeneratedColumn<double>(
        'expected_return_rate',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
        defaultValue: const Constant(0.10),
      );
  static const VerificationMeta _monthlyContributionMeta =
      const VerificationMeta('monthlyContribution');
  @override
  late final GeneratedColumn<int> monthlyContribution = GeneratedColumn<int>(
    'monthly_contribution',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _linkedAccountIdMeta = const VerificationMeta(
    'linkedAccountId',
  );
  @override
  late final GeneratedColumn<String> linkedAccountId = GeneratedColumn<String>(
    'linked_account_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES accounts (id)',
    ),
  );
  static const VerificationMeta _linkedGoalIdMeta = const VerificationMeta(
    'linkedGoalId',
  );
  @override
  late final GeneratedColumn<String> linkedGoalId = GeneratedColumn<String>(
    'linked_goal_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES goals (id)',
    ),
  );
  static const VerificationMeta _familyIdMeta = const VerificationMeta(
    'familyId',
  );
  @override
  late final GeneratedColumn<String> familyId = GeneratedColumn<String>(
    'family_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES families (id)',
    ),
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _visibilityMeta = const VerificationMeta(
    'visibility',
  );
  @override
  late final GeneratedColumn<String> visibility = GeneratedColumn<String>(
    'visibility',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('shared'),
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
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    bucketType,
    investedAmount,
    currentValue,
    expectedReturnRate,
    monthlyContribution,
    linkedAccountId,
    linkedGoalId,
    familyId,
    userId,
    visibility,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'investment_holdings';
  @override
  VerificationContext validateIntegrity(
    Insertable<InvestmentHolding> instance, {
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
    if (data.containsKey('bucket_type')) {
      context.handle(
        _bucketTypeMeta,
        bucketType.isAcceptableOrUnknown(data['bucket_type']!, _bucketTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_bucketTypeMeta);
    }
    if (data.containsKey('invested_amount')) {
      context.handle(
        _investedAmountMeta,
        investedAmount.isAcceptableOrUnknown(
          data['invested_amount']!,
          _investedAmountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_investedAmountMeta);
    }
    if (data.containsKey('current_value')) {
      context.handle(
        _currentValueMeta,
        currentValue.isAcceptableOrUnknown(
          data['current_value']!,
          _currentValueMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_currentValueMeta);
    }
    if (data.containsKey('expected_return_rate')) {
      context.handle(
        _expectedReturnRateMeta,
        expectedReturnRate.isAcceptableOrUnknown(
          data['expected_return_rate']!,
          _expectedReturnRateMeta,
        ),
      );
    }
    if (data.containsKey('monthly_contribution')) {
      context.handle(
        _monthlyContributionMeta,
        monthlyContribution.isAcceptableOrUnknown(
          data['monthly_contribution']!,
          _monthlyContributionMeta,
        ),
      );
    }
    if (data.containsKey('linked_account_id')) {
      context.handle(
        _linkedAccountIdMeta,
        linkedAccountId.isAcceptableOrUnknown(
          data['linked_account_id']!,
          _linkedAccountIdMeta,
        ),
      );
    }
    if (data.containsKey('linked_goal_id')) {
      context.handle(
        _linkedGoalIdMeta,
        linkedGoalId.isAcceptableOrUnknown(
          data['linked_goal_id']!,
          _linkedGoalIdMeta,
        ),
      );
    }
    if (data.containsKey('family_id')) {
      context.handle(
        _familyIdMeta,
        familyId.isAcceptableOrUnknown(data['family_id']!, _familyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_familyIdMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('visibility')) {
      context.handle(
        _visibilityMeta,
        visibility.isAcceptableOrUnknown(data['visibility']!, _visibilityMeta),
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
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  InvestmentHolding map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return InvestmentHolding(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      bucketType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bucket_type'],
      )!,
      investedAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}invested_amount'],
      )!,
      currentValue: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}current_value'],
      )!,
      expectedReturnRate: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}expected_return_rate'],
      )!,
      monthlyContribution: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}monthly_contribution'],
      )!,
      linkedAccountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}linked_account_id'],
      ),
      linkedGoalId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}linked_goal_id'],
      ),
      familyId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}family_id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      visibility: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}visibility'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      ),
    );
  }

  @override
  $InvestmentHoldingsTable createAlias(String alias) {
    return $InvestmentHoldingsTable(attachedDatabase, alias);
  }
}

class InvestmentHolding extends DataClass
    implements Insertable<InvestmentHolding> {
  final String id;
  final String name;
  final String bucketType;
  final int investedAmount;
  final int currentValue;
  final double expectedReturnRate;
  final int monthlyContribution;
  final String? linkedAccountId;
  final String? linkedGoalId;
  final String familyId;
  final String userId;
  final String visibility;
  final DateTime createdAt;
  final DateTime? updatedAt;
  const InvestmentHolding({
    required this.id,
    required this.name,
    required this.bucketType,
    required this.investedAmount,
    required this.currentValue,
    required this.expectedReturnRate,
    required this.monthlyContribution,
    this.linkedAccountId,
    this.linkedGoalId,
    required this.familyId,
    required this.userId,
    required this.visibility,
    required this.createdAt,
    this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['bucket_type'] = Variable<String>(bucketType);
    map['invested_amount'] = Variable<int>(investedAmount);
    map['current_value'] = Variable<int>(currentValue);
    map['expected_return_rate'] = Variable<double>(expectedReturnRate);
    map['monthly_contribution'] = Variable<int>(monthlyContribution);
    if (!nullToAbsent || linkedAccountId != null) {
      map['linked_account_id'] = Variable<String>(linkedAccountId);
    }
    if (!nullToAbsent || linkedGoalId != null) {
      map['linked_goal_id'] = Variable<String>(linkedGoalId);
    }
    map['family_id'] = Variable<String>(familyId);
    map['user_id'] = Variable<String>(userId);
    map['visibility'] = Variable<String>(visibility);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    return map;
  }

  InvestmentHoldingsCompanion toCompanion(bool nullToAbsent) {
    return InvestmentHoldingsCompanion(
      id: Value(id),
      name: Value(name),
      bucketType: Value(bucketType),
      investedAmount: Value(investedAmount),
      currentValue: Value(currentValue),
      expectedReturnRate: Value(expectedReturnRate),
      monthlyContribution: Value(monthlyContribution),
      linkedAccountId: linkedAccountId == null && nullToAbsent
          ? const Value.absent()
          : Value(linkedAccountId),
      linkedGoalId: linkedGoalId == null && nullToAbsent
          ? const Value.absent()
          : Value(linkedGoalId),
      familyId: Value(familyId),
      userId: Value(userId),
      visibility: Value(visibility),
      createdAt: Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory InvestmentHolding.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return InvestmentHolding(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      bucketType: serializer.fromJson<String>(json['bucketType']),
      investedAmount: serializer.fromJson<int>(json['investedAmount']),
      currentValue: serializer.fromJson<int>(json['currentValue']),
      expectedReturnRate: serializer.fromJson<double>(
        json['expectedReturnRate'],
      ),
      monthlyContribution: serializer.fromJson<int>(
        json['monthlyContribution'],
      ),
      linkedAccountId: serializer.fromJson<String?>(json['linkedAccountId']),
      linkedGoalId: serializer.fromJson<String?>(json['linkedGoalId']),
      familyId: serializer.fromJson<String>(json['familyId']),
      userId: serializer.fromJson<String>(json['userId']),
      visibility: serializer.fromJson<String>(json['visibility']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'bucketType': serializer.toJson<String>(bucketType),
      'investedAmount': serializer.toJson<int>(investedAmount),
      'currentValue': serializer.toJson<int>(currentValue),
      'expectedReturnRate': serializer.toJson<double>(expectedReturnRate),
      'monthlyContribution': serializer.toJson<int>(monthlyContribution),
      'linkedAccountId': serializer.toJson<String?>(linkedAccountId),
      'linkedGoalId': serializer.toJson<String?>(linkedGoalId),
      'familyId': serializer.toJson<String>(familyId),
      'userId': serializer.toJson<String>(userId),
      'visibility': serializer.toJson<String>(visibility),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
    };
  }

  InvestmentHolding copyWith({
    String? id,
    String? name,
    String? bucketType,
    int? investedAmount,
    int? currentValue,
    double? expectedReturnRate,
    int? monthlyContribution,
    Value<String?> linkedAccountId = const Value.absent(),
    Value<String?> linkedGoalId = const Value.absent(),
    String? familyId,
    String? userId,
    String? visibility,
    DateTime? createdAt,
    Value<DateTime?> updatedAt = const Value.absent(),
  }) => InvestmentHolding(
    id: id ?? this.id,
    name: name ?? this.name,
    bucketType: bucketType ?? this.bucketType,
    investedAmount: investedAmount ?? this.investedAmount,
    currentValue: currentValue ?? this.currentValue,
    expectedReturnRate: expectedReturnRate ?? this.expectedReturnRate,
    monthlyContribution: monthlyContribution ?? this.monthlyContribution,
    linkedAccountId: linkedAccountId.present
        ? linkedAccountId.value
        : this.linkedAccountId,
    linkedGoalId: linkedGoalId.present ? linkedGoalId.value : this.linkedGoalId,
    familyId: familyId ?? this.familyId,
    userId: userId ?? this.userId,
    visibility: visibility ?? this.visibility,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
  );
  InvestmentHolding copyWithCompanion(InvestmentHoldingsCompanion data) {
    return InvestmentHolding(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      bucketType: data.bucketType.present
          ? data.bucketType.value
          : this.bucketType,
      investedAmount: data.investedAmount.present
          ? data.investedAmount.value
          : this.investedAmount,
      currentValue: data.currentValue.present
          ? data.currentValue.value
          : this.currentValue,
      expectedReturnRate: data.expectedReturnRate.present
          ? data.expectedReturnRate.value
          : this.expectedReturnRate,
      monthlyContribution: data.monthlyContribution.present
          ? data.monthlyContribution.value
          : this.monthlyContribution,
      linkedAccountId: data.linkedAccountId.present
          ? data.linkedAccountId.value
          : this.linkedAccountId,
      linkedGoalId: data.linkedGoalId.present
          ? data.linkedGoalId.value
          : this.linkedGoalId,
      familyId: data.familyId.present ? data.familyId.value : this.familyId,
      userId: data.userId.present ? data.userId.value : this.userId,
      visibility: data.visibility.present
          ? data.visibility.value
          : this.visibility,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('InvestmentHolding(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('bucketType: $bucketType, ')
          ..write('investedAmount: $investedAmount, ')
          ..write('currentValue: $currentValue, ')
          ..write('expectedReturnRate: $expectedReturnRate, ')
          ..write('monthlyContribution: $monthlyContribution, ')
          ..write('linkedAccountId: $linkedAccountId, ')
          ..write('linkedGoalId: $linkedGoalId, ')
          ..write('familyId: $familyId, ')
          ..write('userId: $userId, ')
          ..write('visibility: $visibility, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    bucketType,
    investedAmount,
    currentValue,
    expectedReturnRate,
    monthlyContribution,
    linkedAccountId,
    linkedGoalId,
    familyId,
    userId,
    visibility,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InvestmentHolding &&
          other.id == this.id &&
          other.name == this.name &&
          other.bucketType == this.bucketType &&
          other.investedAmount == this.investedAmount &&
          other.currentValue == this.currentValue &&
          other.expectedReturnRate == this.expectedReturnRate &&
          other.monthlyContribution == this.monthlyContribution &&
          other.linkedAccountId == this.linkedAccountId &&
          other.linkedGoalId == this.linkedGoalId &&
          other.familyId == this.familyId &&
          other.userId == this.userId &&
          other.visibility == this.visibility &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class InvestmentHoldingsCompanion extends UpdateCompanion<InvestmentHolding> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> bucketType;
  final Value<int> investedAmount;
  final Value<int> currentValue;
  final Value<double> expectedReturnRate;
  final Value<int> monthlyContribution;
  final Value<String?> linkedAccountId;
  final Value<String?> linkedGoalId;
  final Value<String> familyId;
  final Value<String> userId;
  final Value<String> visibility;
  final Value<DateTime> createdAt;
  final Value<DateTime?> updatedAt;
  final Value<int> rowid;
  const InvestmentHoldingsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.bucketType = const Value.absent(),
    this.investedAmount = const Value.absent(),
    this.currentValue = const Value.absent(),
    this.expectedReturnRate = const Value.absent(),
    this.monthlyContribution = const Value.absent(),
    this.linkedAccountId = const Value.absent(),
    this.linkedGoalId = const Value.absent(),
    this.familyId = const Value.absent(),
    this.userId = const Value.absent(),
    this.visibility = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  InvestmentHoldingsCompanion.insert({
    required String id,
    required String name,
    required String bucketType,
    required int investedAmount,
    required int currentValue,
    this.expectedReturnRate = const Value.absent(),
    this.monthlyContribution = const Value.absent(),
    this.linkedAccountId = const Value.absent(),
    this.linkedGoalId = const Value.absent(),
    required String familyId,
    required String userId,
    this.visibility = const Value.absent(),
    required DateTime createdAt,
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       bucketType = Value(bucketType),
       investedAmount = Value(investedAmount),
       currentValue = Value(currentValue),
       familyId = Value(familyId),
       userId = Value(userId),
       createdAt = Value(createdAt);
  static Insertable<InvestmentHolding> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? bucketType,
    Expression<int>? investedAmount,
    Expression<int>? currentValue,
    Expression<double>? expectedReturnRate,
    Expression<int>? monthlyContribution,
    Expression<String>? linkedAccountId,
    Expression<String>? linkedGoalId,
    Expression<String>? familyId,
    Expression<String>? userId,
    Expression<String>? visibility,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (bucketType != null) 'bucket_type': bucketType,
      if (investedAmount != null) 'invested_amount': investedAmount,
      if (currentValue != null) 'current_value': currentValue,
      if (expectedReturnRate != null)
        'expected_return_rate': expectedReturnRate,
      if (monthlyContribution != null)
        'monthly_contribution': monthlyContribution,
      if (linkedAccountId != null) 'linked_account_id': linkedAccountId,
      if (linkedGoalId != null) 'linked_goal_id': linkedGoalId,
      if (familyId != null) 'family_id': familyId,
      if (userId != null) 'user_id': userId,
      if (visibility != null) 'visibility': visibility,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  InvestmentHoldingsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? bucketType,
    Value<int>? investedAmount,
    Value<int>? currentValue,
    Value<double>? expectedReturnRate,
    Value<int>? monthlyContribution,
    Value<String?>? linkedAccountId,
    Value<String?>? linkedGoalId,
    Value<String>? familyId,
    Value<String>? userId,
    Value<String>? visibility,
    Value<DateTime>? createdAt,
    Value<DateTime?>? updatedAt,
    Value<int>? rowid,
  }) {
    return InvestmentHoldingsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      bucketType: bucketType ?? this.bucketType,
      investedAmount: investedAmount ?? this.investedAmount,
      currentValue: currentValue ?? this.currentValue,
      expectedReturnRate: expectedReturnRate ?? this.expectedReturnRate,
      monthlyContribution: monthlyContribution ?? this.monthlyContribution,
      linkedAccountId: linkedAccountId ?? this.linkedAccountId,
      linkedGoalId: linkedGoalId ?? this.linkedGoalId,
      familyId: familyId ?? this.familyId,
      userId: userId ?? this.userId,
      visibility: visibility ?? this.visibility,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
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
    if (bucketType.present) {
      map['bucket_type'] = Variable<String>(bucketType.value);
    }
    if (investedAmount.present) {
      map['invested_amount'] = Variable<int>(investedAmount.value);
    }
    if (currentValue.present) {
      map['current_value'] = Variable<int>(currentValue.value);
    }
    if (expectedReturnRate.present) {
      map['expected_return_rate'] = Variable<double>(expectedReturnRate.value);
    }
    if (monthlyContribution.present) {
      map['monthly_contribution'] = Variable<int>(monthlyContribution.value);
    }
    if (linkedAccountId.present) {
      map['linked_account_id'] = Variable<String>(linkedAccountId.value);
    }
    if (linkedGoalId.present) {
      map['linked_goal_id'] = Variable<String>(linkedGoalId.value);
    }
    if (familyId.present) {
      map['family_id'] = Variable<String>(familyId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (visibility.present) {
      map['visibility'] = Variable<String>(visibility.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
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
    return (StringBuffer('InvestmentHoldingsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('bucketType: $bucketType, ')
          ..write('investedAmount: $investedAmount, ')
          ..write('currentValue: $currentValue, ')
          ..write('expectedReturnRate: $expectedReturnRate, ')
          ..write('monthlyContribution: $monthlyContribution, ')
          ..write('linkedAccountId: $linkedAccountId, ')
          ..write('linkedGoalId: $linkedGoalId, ')
          ..write('familyId: $familyId, ')
          ..write('userId: $userId, ')
          ..write('visibility: $visibility, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LifeProfilesTable extends LifeProfiles
    with TableInfo<$LifeProfilesTable, LifeProfile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LifeProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _familyIdMeta = const VerificationMeta(
    'familyId',
  );
  @override
  late final GeneratedColumn<String> familyId = GeneratedColumn<String>(
    'family_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES families (id)',
    ),
  );
  static const VerificationMeta _dateOfBirthMeta = const VerificationMeta(
    'dateOfBirth',
  );
  @override
  late final GeneratedColumn<DateTime> dateOfBirth = GeneratedColumn<DateTime>(
    'date_of_birth',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _plannedRetirementAgeMeta =
      const VerificationMeta('plannedRetirementAge');
  @override
  late final GeneratedColumn<int> plannedRetirementAge = GeneratedColumn<int>(
    'planned_retirement_age',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(60),
  );
  static const VerificationMeta _riskProfileMeta = const VerificationMeta(
    'riskProfile',
  );
  @override
  late final GeneratedColumn<String> riskProfile = GeneratedColumn<String>(
    'risk_profile',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('MODERATE'),
  );
  static const VerificationMeta _annualIncomeGrowthBpMeta =
      const VerificationMeta('annualIncomeGrowthBp');
  @override
  late final GeneratedColumn<int> annualIncomeGrowthBp = GeneratedColumn<int>(
    'annual_income_growth_bp',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(800),
  );
  static const VerificationMeta _expectedInflationBpMeta =
      const VerificationMeta('expectedInflationBp');
  @override
  late final GeneratedColumn<int> expectedInflationBp = GeneratedColumn<int>(
    'expected_inflation_bp',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(600),
  );
  static const VerificationMeta _safeWithdrawalRateBpMeta =
      const VerificationMeta('safeWithdrawalRateBp');
  @override
  late final GeneratedColumn<int> safeWithdrawalRateBp = GeneratedColumn<int>(
    'safe_withdrawal_rate_bp',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(300),
  );
  static const VerificationMeta _hikeMonthMeta = const VerificationMeta(
    'hikeMonth',
  );
  @override
  late final GeneratedColumn<int> hikeMonth = GeneratedColumn<int>(
    'hike_month',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(4),
  );
  static const VerificationMeta _incomeStabilityMeta = const VerificationMeta(
    'incomeStability',
  );
  @override
  late final GeneratedColumn<String> incomeStability = GeneratedColumn<String>(
    'income_stability',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _efTargetMonthsOverrideMeta =
      const VerificationMeta('efTargetMonthsOverride');
  @override
  late final GeneratedColumn<int> efTargetMonthsOverride = GeneratedColumn<int>(
    'ef_target_months_override',
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
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    familyId,
    dateOfBirth,
    plannedRetirementAge,
    riskProfile,
    annualIncomeGrowthBp,
    expectedInflationBp,
    safeWithdrawalRateBp,
    hikeMonth,
    incomeStability,
    efTargetMonthsOverride,
    createdAt,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'life_profiles';
  @override
  VerificationContext validateIntegrity(
    Insertable<LifeProfile> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('family_id')) {
      context.handle(
        _familyIdMeta,
        familyId.isAcceptableOrUnknown(data['family_id']!, _familyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_familyIdMeta);
    }
    if (data.containsKey('date_of_birth')) {
      context.handle(
        _dateOfBirthMeta,
        dateOfBirth.isAcceptableOrUnknown(
          data['date_of_birth']!,
          _dateOfBirthMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_dateOfBirthMeta);
    }
    if (data.containsKey('planned_retirement_age')) {
      context.handle(
        _plannedRetirementAgeMeta,
        plannedRetirementAge.isAcceptableOrUnknown(
          data['planned_retirement_age']!,
          _plannedRetirementAgeMeta,
        ),
      );
    }
    if (data.containsKey('risk_profile')) {
      context.handle(
        _riskProfileMeta,
        riskProfile.isAcceptableOrUnknown(
          data['risk_profile']!,
          _riskProfileMeta,
        ),
      );
    }
    if (data.containsKey('annual_income_growth_bp')) {
      context.handle(
        _annualIncomeGrowthBpMeta,
        annualIncomeGrowthBp.isAcceptableOrUnknown(
          data['annual_income_growth_bp']!,
          _annualIncomeGrowthBpMeta,
        ),
      );
    }
    if (data.containsKey('expected_inflation_bp')) {
      context.handle(
        _expectedInflationBpMeta,
        expectedInflationBp.isAcceptableOrUnknown(
          data['expected_inflation_bp']!,
          _expectedInflationBpMeta,
        ),
      );
    }
    if (data.containsKey('safe_withdrawal_rate_bp')) {
      context.handle(
        _safeWithdrawalRateBpMeta,
        safeWithdrawalRateBp.isAcceptableOrUnknown(
          data['safe_withdrawal_rate_bp']!,
          _safeWithdrawalRateBpMeta,
        ),
      );
    }
    if (data.containsKey('hike_month')) {
      context.handle(
        _hikeMonthMeta,
        hikeMonth.isAcceptableOrUnknown(data['hike_month']!, _hikeMonthMeta),
      );
    }
    if (data.containsKey('income_stability')) {
      context.handle(
        _incomeStabilityMeta,
        incomeStability.isAcceptableOrUnknown(
          data['income_stability']!,
          _incomeStabilityMeta,
        ),
      );
    }
    if (data.containsKey('ef_target_months_override')) {
      context.handle(
        _efTargetMonthsOverrideMeta,
        efTargetMonthsOverride.isAcceptableOrUnknown(
          data['ef_target_months_override']!,
          _efTargetMonthsOverrideMeta,
        ),
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
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LifeProfile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LifeProfile(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      familyId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}family_id'],
      )!,
      dateOfBirth: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date_of_birth'],
      )!,
      plannedRetirementAge: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}planned_retirement_age'],
      )!,
      riskProfile: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}risk_profile'],
      )!,
      annualIncomeGrowthBp: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}annual_income_growth_bp'],
      )!,
      expectedInflationBp: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}expected_inflation_bp'],
      )!,
      safeWithdrawalRateBp: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}safe_withdrawal_rate_bp'],
      )!,
      hikeMonth: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}hike_month'],
      )!,
      incomeStability: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}income_stability'],
      ),
      efTargetMonthsOverride: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ef_target_months_override'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $LifeProfilesTable createAlias(String alias) {
    return $LifeProfilesTable(attachedDatabase, alias);
  }
}

class LifeProfile extends DataClass implements Insertable<LifeProfile> {
  final String id;
  final String userId;
  final String familyId;
  final DateTime dateOfBirth;
  final int plannedRetirementAge;
  final String riskProfile;
  final int annualIncomeGrowthBp;
  final int expectedInflationBp;
  final int safeWithdrawalRateBp;
  final int hikeMonth;
  final String? incomeStability;
  final int? efTargetMonthsOverride;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  const LifeProfile({
    required this.id,
    required this.userId,
    required this.familyId,
    required this.dateOfBirth,
    required this.plannedRetirementAge,
    required this.riskProfile,
    required this.annualIncomeGrowthBp,
    required this.expectedInflationBp,
    required this.safeWithdrawalRateBp,
    required this.hikeMonth,
    this.incomeStability,
    this.efTargetMonthsOverride,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['family_id'] = Variable<String>(familyId);
    map['date_of_birth'] = Variable<DateTime>(dateOfBirth);
    map['planned_retirement_age'] = Variable<int>(plannedRetirementAge);
    map['risk_profile'] = Variable<String>(riskProfile);
    map['annual_income_growth_bp'] = Variable<int>(annualIncomeGrowthBp);
    map['expected_inflation_bp'] = Variable<int>(expectedInflationBp);
    map['safe_withdrawal_rate_bp'] = Variable<int>(safeWithdrawalRateBp);
    map['hike_month'] = Variable<int>(hikeMonth);
    if (!nullToAbsent || incomeStability != null) {
      map['income_stability'] = Variable<String>(incomeStability);
    }
    if (!nullToAbsent || efTargetMonthsOverride != null) {
      map['ef_target_months_override'] = Variable<int>(efTargetMonthsOverride);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  LifeProfilesCompanion toCompanion(bool nullToAbsent) {
    return LifeProfilesCompanion(
      id: Value(id),
      userId: Value(userId),
      familyId: Value(familyId),
      dateOfBirth: Value(dateOfBirth),
      plannedRetirementAge: Value(plannedRetirementAge),
      riskProfile: Value(riskProfile),
      annualIncomeGrowthBp: Value(annualIncomeGrowthBp),
      expectedInflationBp: Value(expectedInflationBp),
      safeWithdrawalRateBp: Value(safeWithdrawalRateBp),
      hikeMonth: Value(hikeMonth),
      incomeStability: incomeStability == null && nullToAbsent
          ? const Value.absent()
          : Value(incomeStability),
      efTargetMonthsOverride: efTargetMonthsOverride == null && nullToAbsent
          ? const Value.absent()
          : Value(efTargetMonthsOverride),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory LifeProfile.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LifeProfile(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      familyId: serializer.fromJson<String>(json['familyId']),
      dateOfBirth: serializer.fromJson<DateTime>(json['dateOfBirth']),
      plannedRetirementAge: serializer.fromJson<int>(
        json['plannedRetirementAge'],
      ),
      riskProfile: serializer.fromJson<String>(json['riskProfile']),
      annualIncomeGrowthBp: serializer.fromJson<int>(
        json['annualIncomeGrowthBp'],
      ),
      expectedInflationBp: serializer.fromJson<int>(
        json['expectedInflationBp'],
      ),
      safeWithdrawalRateBp: serializer.fromJson<int>(
        json['safeWithdrawalRateBp'],
      ),
      hikeMonth: serializer.fromJson<int>(json['hikeMonth']),
      incomeStability: serializer.fromJson<String?>(json['incomeStability']),
      efTargetMonthsOverride: serializer.fromJson<int?>(
        json['efTargetMonthsOverride'],
      ),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'familyId': serializer.toJson<String>(familyId),
      'dateOfBirth': serializer.toJson<DateTime>(dateOfBirth),
      'plannedRetirementAge': serializer.toJson<int>(plannedRetirementAge),
      'riskProfile': serializer.toJson<String>(riskProfile),
      'annualIncomeGrowthBp': serializer.toJson<int>(annualIncomeGrowthBp),
      'expectedInflationBp': serializer.toJson<int>(expectedInflationBp),
      'safeWithdrawalRateBp': serializer.toJson<int>(safeWithdrawalRateBp),
      'hikeMonth': serializer.toJson<int>(hikeMonth),
      'incomeStability': serializer.toJson<String?>(incomeStability),
      'efTargetMonthsOverride': serializer.toJson<int?>(efTargetMonthsOverride),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  LifeProfile copyWith({
    String? id,
    String? userId,
    String? familyId,
    DateTime? dateOfBirth,
    int? plannedRetirementAge,
    String? riskProfile,
    int? annualIncomeGrowthBp,
    int? expectedInflationBp,
    int? safeWithdrawalRateBp,
    int? hikeMonth,
    Value<String?> incomeStability = const Value.absent(),
    Value<int?> efTargetMonthsOverride = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => LifeProfile(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    familyId: familyId ?? this.familyId,
    dateOfBirth: dateOfBirth ?? this.dateOfBirth,
    plannedRetirementAge: plannedRetirementAge ?? this.plannedRetirementAge,
    riskProfile: riskProfile ?? this.riskProfile,
    annualIncomeGrowthBp: annualIncomeGrowthBp ?? this.annualIncomeGrowthBp,
    expectedInflationBp: expectedInflationBp ?? this.expectedInflationBp,
    safeWithdrawalRateBp: safeWithdrawalRateBp ?? this.safeWithdrawalRateBp,
    hikeMonth: hikeMonth ?? this.hikeMonth,
    incomeStability: incomeStability.present
        ? incomeStability.value
        : this.incomeStability,
    efTargetMonthsOverride: efTargetMonthsOverride.present
        ? efTargetMonthsOverride.value
        : this.efTargetMonthsOverride,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  LifeProfile copyWithCompanion(LifeProfilesCompanion data) {
    return LifeProfile(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      familyId: data.familyId.present ? data.familyId.value : this.familyId,
      dateOfBirth: data.dateOfBirth.present
          ? data.dateOfBirth.value
          : this.dateOfBirth,
      plannedRetirementAge: data.plannedRetirementAge.present
          ? data.plannedRetirementAge.value
          : this.plannedRetirementAge,
      riskProfile: data.riskProfile.present
          ? data.riskProfile.value
          : this.riskProfile,
      annualIncomeGrowthBp: data.annualIncomeGrowthBp.present
          ? data.annualIncomeGrowthBp.value
          : this.annualIncomeGrowthBp,
      expectedInflationBp: data.expectedInflationBp.present
          ? data.expectedInflationBp.value
          : this.expectedInflationBp,
      safeWithdrawalRateBp: data.safeWithdrawalRateBp.present
          ? data.safeWithdrawalRateBp.value
          : this.safeWithdrawalRateBp,
      hikeMonth: data.hikeMonth.present ? data.hikeMonth.value : this.hikeMonth,
      incomeStability: data.incomeStability.present
          ? data.incomeStability.value
          : this.incomeStability,
      efTargetMonthsOverride: data.efTargetMonthsOverride.present
          ? data.efTargetMonthsOverride.value
          : this.efTargetMonthsOverride,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LifeProfile(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('familyId: $familyId, ')
          ..write('dateOfBirth: $dateOfBirth, ')
          ..write('plannedRetirementAge: $plannedRetirementAge, ')
          ..write('riskProfile: $riskProfile, ')
          ..write('annualIncomeGrowthBp: $annualIncomeGrowthBp, ')
          ..write('expectedInflationBp: $expectedInflationBp, ')
          ..write('safeWithdrawalRateBp: $safeWithdrawalRateBp, ')
          ..write('hikeMonth: $hikeMonth, ')
          ..write('incomeStability: $incomeStability, ')
          ..write('efTargetMonthsOverride: $efTargetMonthsOverride, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    familyId,
    dateOfBirth,
    plannedRetirementAge,
    riskProfile,
    annualIncomeGrowthBp,
    expectedInflationBp,
    safeWithdrawalRateBp,
    hikeMonth,
    incomeStability,
    efTargetMonthsOverride,
    createdAt,
    updatedAt,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LifeProfile &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.familyId == this.familyId &&
          other.dateOfBirth == this.dateOfBirth &&
          other.plannedRetirementAge == this.plannedRetirementAge &&
          other.riskProfile == this.riskProfile &&
          other.annualIncomeGrowthBp == this.annualIncomeGrowthBp &&
          other.expectedInflationBp == this.expectedInflationBp &&
          other.safeWithdrawalRateBp == this.safeWithdrawalRateBp &&
          other.hikeMonth == this.hikeMonth &&
          other.incomeStability == this.incomeStability &&
          other.efTargetMonthsOverride == this.efTargetMonthsOverride &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class LifeProfilesCompanion extends UpdateCompanion<LifeProfile> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> familyId;
  final Value<DateTime> dateOfBirth;
  final Value<int> plannedRetirementAge;
  final Value<String> riskProfile;
  final Value<int> annualIncomeGrowthBp;
  final Value<int> expectedInflationBp;
  final Value<int> safeWithdrawalRateBp;
  final Value<int> hikeMonth;
  final Value<String?> incomeStability;
  final Value<int?> efTargetMonthsOverride;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const LifeProfilesCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.familyId = const Value.absent(),
    this.dateOfBirth = const Value.absent(),
    this.plannedRetirementAge = const Value.absent(),
    this.riskProfile = const Value.absent(),
    this.annualIncomeGrowthBp = const Value.absent(),
    this.expectedInflationBp = const Value.absent(),
    this.safeWithdrawalRateBp = const Value.absent(),
    this.hikeMonth = const Value.absent(),
    this.incomeStability = const Value.absent(),
    this.efTargetMonthsOverride = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LifeProfilesCompanion.insert({
    required String id,
    required String userId,
    required String familyId,
    required DateTime dateOfBirth,
    this.plannedRetirementAge = const Value.absent(),
    this.riskProfile = const Value.absent(),
    this.annualIncomeGrowthBp = const Value.absent(),
    this.expectedInflationBp = const Value.absent(),
    this.safeWithdrawalRateBp = const Value.absent(),
    this.hikeMonth = const Value.absent(),
    this.incomeStability = const Value.absent(),
    this.efTargetMonthsOverride = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       familyId = Value(familyId),
       dateOfBirth = Value(dateOfBirth),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<LifeProfile> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? familyId,
    Expression<DateTime>? dateOfBirth,
    Expression<int>? plannedRetirementAge,
    Expression<String>? riskProfile,
    Expression<int>? annualIncomeGrowthBp,
    Expression<int>? expectedInflationBp,
    Expression<int>? safeWithdrawalRateBp,
    Expression<int>? hikeMonth,
    Expression<String>? incomeStability,
    Expression<int>? efTargetMonthsOverride,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (familyId != null) 'family_id': familyId,
      if (dateOfBirth != null) 'date_of_birth': dateOfBirth,
      if (plannedRetirementAge != null)
        'planned_retirement_age': plannedRetirementAge,
      if (riskProfile != null) 'risk_profile': riskProfile,
      if (annualIncomeGrowthBp != null)
        'annual_income_growth_bp': annualIncomeGrowthBp,
      if (expectedInflationBp != null)
        'expected_inflation_bp': expectedInflationBp,
      if (safeWithdrawalRateBp != null)
        'safe_withdrawal_rate_bp': safeWithdrawalRateBp,
      if (hikeMonth != null) 'hike_month': hikeMonth,
      if (incomeStability != null) 'income_stability': incomeStability,
      if (efTargetMonthsOverride != null)
        'ef_target_months_override': efTargetMonthsOverride,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LifeProfilesCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<String>? familyId,
    Value<DateTime>? dateOfBirth,
    Value<int>? plannedRetirementAge,
    Value<String>? riskProfile,
    Value<int>? annualIncomeGrowthBp,
    Value<int>? expectedInflationBp,
    Value<int>? safeWithdrawalRateBp,
    Value<int>? hikeMonth,
    Value<String?>? incomeStability,
    Value<int?>? efTargetMonthsOverride,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? rowid,
  }) {
    return LifeProfilesCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      familyId: familyId ?? this.familyId,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      plannedRetirementAge: plannedRetirementAge ?? this.plannedRetirementAge,
      riskProfile: riskProfile ?? this.riskProfile,
      annualIncomeGrowthBp: annualIncomeGrowthBp ?? this.annualIncomeGrowthBp,
      expectedInflationBp: expectedInflationBp ?? this.expectedInflationBp,
      safeWithdrawalRateBp: safeWithdrawalRateBp ?? this.safeWithdrawalRateBp,
      hikeMonth: hikeMonth ?? this.hikeMonth,
      incomeStability: incomeStability ?? this.incomeStability,
      efTargetMonthsOverride:
          efTargetMonthsOverride ?? this.efTargetMonthsOverride,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (familyId.present) {
      map['family_id'] = Variable<String>(familyId.value);
    }
    if (dateOfBirth.present) {
      map['date_of_birth'] = Variable<DateTime>(dateOfBirth.value);
    }
    if (plannedRetirementAge.present) {
      map['planned_retirement_age'] = Variable<int>(plannedRetirementAge.value);
    }
    if (riskProfile.present) {
      map['risk_profile'] = Variable<String>(riskProfile.value);
    }
    if (annualIncomeGrowthBp.present) {
      map['annual_income_growth_bp'] = Variable<int>(
        annualIncomeGrowthBp.value,
      );
    }
    if (expectedInflationBp.present) {
      map['expected_inflation_bp'] = Variable<int>(expectedInflationBp.value);
    }
    if (safeWithdrawalRateBp.present) {
      map['safe_withdrawal_rate_bp'] = Variable<int>(
        safeWithdrawalRateBp.value,
      );
    }
    if (hikeMonth.present) {
      map['hike_month'] = Variable<int>(hikeMonth.value);
    }
    if (incomeStability.present) {
      map['income_stability'] = Variable<String>(incomeStability.value);
    }
    if (efTargetMonthsOverride.present) {
      map['ef_target_months_override'] = Variable<int>(
        efTargetMonthsOverride.value,
      );
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
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LifeProfilesCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('familyId: $familyId, ')
          ..write('dateOfBirth: $dateOfBirth, ')
          ..write('plannedRetirementAge: $plannedRetirementAge, ')
          ..write('riskProfile: $riskProfile, ')
          ..write('annualIncomeGrowthBp: $annualIncomeGrowthBp, ')
          ..write('expectedInflationBp: $expectedInflationBp, ')
          ..write('safeWithdrawalRateBp: $safeWithdrawalRateBp, ')
          ..write('hikeMonth: $hikeMonth, ')
          ..write('incomeStability: $incomeStability, ')
          ..write('efTargetMonthsOverride: $efTargetMonthsOverride, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $NetWorthMilestonesTable extends NetWorthMilestones
    with TableInfo<$NetWorthMilestonesTable, NetWorthMilestone> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NetWorthMilestonesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _familyIdMeta = const VerificationMeta(
    'familyId',
  );
  @override
  late final GeneratedColumn<String> familyId = GeneratedColumn<String>(
    'family_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES families (id)',
    ),
  );
  static const VerificationMeta _lifeProfileIdMeta = const VerificationMeta(
    'lifeProfileId',
  );
  @override
  late final GeneratedColumn<String> lifeProfileId = GeneratedColumn<String>(
    'life_profile_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES life_profiles (id)',
    ),
  );
  static const VerificationMeta _targetAgeMeta = const VerificationMeta(
    'targetAge',
  );
  @override
  late final GeneratedColumn<int> targetAge = GeneratedColumn<int>(
    'target_age',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetAmountPaiseMeta = const VerificationMeta(
    'targetAmountPaise',
  );
  @override
  late final GeneratedColumn<int> targetAmountPaise = GeneratedColumn<int>(
    'target_amount_paise',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isCustomTargetMeta = const VerificationMeta(
    'isCustomTarget',
  );
  @override
  late final GeneratedColumn<bool> isCustomTarget = GeneratedColumn<bool>(
    'is_custom_target',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_custom_target" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
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
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    familyId,
    lifeProfileId,
    targetAge,
    targetAmountPaise,
    isCustomTarget,
    createdAt,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'net_worth_milestones';
  @override
  VerificationContext validateIntegrity(
    Insertable<NetWorthMilestone> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('family_id')) {
      context.handle(
        _familyIdMeta,
        familyId.isAcceptableOrUnknown(data['family_id']!, _familyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_familyIdMeta);
    }
    if (data.containsKey('life_profile_id')) {
      context.handle(
        _lifeProfileIdMeta,
        lifeProfileId.isAcceptableOrUnknown(
          data['life_profile_id']!,
          _lifeProfileIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lifeProfileIdMeta);
    }
    if (data.containsKey('target_age')) {
      context.handle(
        _targetAgeMeta,
        targetAge.isAcceptableOrUnknown(data['target_age']!, _targetAgeMeta),
      );
    } else if (isInserting) {
      context.missing(_targetAgeMeta);
    }
    if (data.containsKey('target_amount_paise')) {
      context.handle(
        _targetAmountPaiseMeta,
        targetAmountPaise.isAcceptableOrUnknown(
          data['target_amount_paise']!,
          _targetAmountPaiseMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_targetAmountPaiseMeta);
    }
    if (data.containsKey('is_custom_target')) {
      context.handle(
        _isCustomTargetMeta,
        isCustomTarget.isAcceptableOrUnknown(
          data['is_custom_target']!,
          _isCustomTargetMeta,
        ),
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
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  NetWorthMilestone map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NetWorthMilestone(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      familyId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}family_id'],
      )!,
      lifeProfileId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}life_profile_id'],
      )!,
      targetAge: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target_age'],
      )!,
      targetAmountPaise: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target_amount_paise'],
      )!,
      isCustomTarget: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_custom_target'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $NetWorthMilestonesTable createAlias(String alias) {
    return $NetWorthMilestonesTable(attachedDatabase, alias);
  }
}

class NetWorthMilestone extends DataClass
    implements Insertable<NetWorthMilestone> {
  final String id;
  final String userId;
  final String familyId;
  final String lifeProfileId;
  final int targetAge;
  final int targetAmountPaise;
  final bool isCustomTarget;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  const NetWorthMilestone({
    required this.id,
    required this.userId,
    required this.familyId,
    required this.lifeProfileId,
    required this.targetAge,
    required this.targetAmountPaise,
    required this.isCustomTarget,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['family_id'] = Variable<String>(familyId);
    map['life_profile_id'] = Variable<String>(lifeProfileId);
    map['target_age'] = Variable<int>(targetAge);
    map['target_amount_paise'] = Variable<int>(targetAmountPaise);
    map['is_custom_target'] = Variable<bool>(isCustomTarget);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  NetWorthMilestonesCompanion toCompanion(bool nullToAbsent) {
    return NetWorthMilestonesCompanion(
      id: Value(id),
      userId: Value(userId),
      familyId: Value(familyId),
      lifeProfileId: Value(lifeProfileId),
      targetAge: Value(targetAge),
      targetAmountPaise: Value(targetAmountPaise),
      isCustomTarget: Value(isCustomTarget),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory NetWorthMilestone.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NetWorthMilestone(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      familyId: serializer.fromJson<String>(json['familyId']),
      lifeProfileId: serializer.fromJson<String>(json['lifeProfileId']),
      targetAge: serializer.fromJson<int>(json['targetAge']),
      targetAmountPaise: serializer.fromJson<int>(json['targetAmountPaise']),
      isCustomTarget: serializer.fromJson<bool>(json['isCustomTarget']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'familyId': serializer.toJson<String>(familyId),
      'lifeProfileId': serializer.toJson<String>(lifeProfileId),
      'targetAge': serializer.toJson<int>(targetAge),
      'targetAmountPaise': serializer.toJson<int>(targetAmountPaise),
      'isCustomTarget': serializer.toJson<bool>(isCustomTarget),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  NetWorthMilestone copyWith({
    String? id,
    String? userId,
    String? familyId,
    String? lifeProfileId,
    int? targetAge,
    int? targetAmountPaise,
    bool? isCustomTarget,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => NetWorthMilestone(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    familyId: familyId ?? this.familyId,
    lifeProfileId: lifeProfileId ?? this.lifeProfileId,
    targetAge: targetAge ?? this.targetAge,
    targetAmountPaise: targetAmountPaise ?? this.targetAmountPaise,
    isCustomTarget: isCustomTarget ?? this.isCustomTarget,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  NetWorthMilestone copyWithCompanion(NetWorthMilestonesCompanion data) {
    return NetWorthMilestone(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      familyId: data.familyId.present ? data.familyId.value : this.familyId,
      lifeProfileId: data.lifeProfileId.present
          ? data.lifeProfileId.value
          : this.lifeProfileId,
      targetAge: data.targetAge.present ? data.targetAge.value : this.targetAge,
      targetAmountPaise: data.targetAmountPaise.present
          ? data.targetAmountPaise.value
          : this.targetAmountPaise,
      isCustomTarget: data.isCustomTarget.present
          ? data.isCustomTarget.value
          : this.isCustomTarget,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NetWorthMilestone(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('familyId: $familyId, ')
          ..write('lifeProfileId: $lifeProfileId, ')
          ..write('targetAge: $targetAge, ')
          ..write('targetAmountPaise: $targetAmountPaise, ')
          ..write('isCustomTarget: $isCustomTarget, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    familyId,
    lifeProfileId,
    targetAge,
    targetAmountPaise,
    isCustomTarget,
    createdAt,
    updatedAt,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NetWorthMilestone &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.familyId == this.familyId &&
          other.lifeProfileId == this.lifeProfileId &&
          other.targetAge == this.targetAge &&
          other.targetAmountPaise == this.targetAmountPaise &&
          other.isCustomTarget == this.isCustomTarget &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class NetWorthMilestonesCompanion extends UpdateCompanion<NetWorthMilestone> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> familyId;
  final Value<String> lifeProfileId;
  final Value<int> targetAge;
  final Value<int> targetAmountPaise;
  final Value<bool> isCustomTarget;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const NetWorthMilestonesCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.familyId = const Value.absent(),
    this.lifeProfileId = const Value.absent(),
    this.targetAge = const Value.absent(),
    this.targetAmountPaise = const Value.absent(),
    this.isCustomTarget = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  NetWorthMilestonesCompanion.insert({
    required String id,
    required String userId,
    required String familyId,
    required String lifeProfileId,
    required int targetAge,
    required int targetAmountPaise,
    this.isCustomTarget = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       familyId = Value(familyId),
       lifeProfileId = Value(lifeProfileId),
       targetAge = Value(targetAge),
       targetAmountPaise = Value(targetAmountPaise),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<NetWorthMilestone> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? familyId,
    Expression<String>? lifeProfileId,
    Expression<int>? targetAge,
    Expression<int>? targetAmountPaise,
    Expression<bool>? isCustomTarget,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (familyId != null) 'family_id': familyId,
      if (lifeProfileId != null) 'life_profile_id': lifeProfileId,
      if (targetAge != null) 'target_age': targetAge,
      if (targetAmountPaise != null) 'target_amount_paise': targetAmountPaise,
      if (isCustomTarget != null) 'is_custom_target': isCustomTarget,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  NetWorthMilestonesCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<String>? familyId,
    Value<String>? lifeProfileId,
    Value<int>? targetAge,
    Value<int>? targetAmountPaise,
    Value<bool>? isCustomTarget,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? rowid,
  }) {
    return NetWorthMilestonesCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      familyId: familyId ?? this.familyId,
      lifeProfileId: lifeProfileId ?? this.lifeProfileId,
      targetAge: targetAge ?? this.targetAge,
      targetAmountPaise: targetAmountPaise ?? this.targetAmountPaise,
      isCustomTarget: isCustomTarget ?? this.isCustomTarget,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (familyId.present) {
      map['family_id'] = Variable<String>(familyId.value);
    }
    if (lifeProfileId.present) {
      map['life_profile_id'] = Variable<String>(lifeProfileId.value);
    }
    if (targetAge.present) {
      map['target_age'] = Variable<int>(targetAge.value);
    }
    if (targetAmountPaise.present) {
      map['target_amount_paise'] = Variable<int>(targetAmountPaise.value);
    }
    if (isCustomTarget.present) {
      map['is_custom_target'] = Variable<bool>(isCustomTarget.value);
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
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NetWorthMilestonesCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('familyId: $familyId, ')
          ..write('lifeProfileId: $lifeProfileId, ')
          ..write('targetAge: $targetAge, ')
          ..write('targetAmountPaise: $targetAmountPaise, ')
          ..write('isCustomTarget: $isCustomTarget, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RecurringRulesTable extends RecurringRules
    with TableInfo<$RecurringRulesTable, RecurringRule> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecurringRulesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<int> amount = GeneratedColumn<int>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _accountIdMeta = const VerificationMeta(
    'accountId',
  );
  @override
  late final GeneratedColumn<String> accountId = GeneratedColumn<String>(
    'account_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES accounts (id)',
    ),
  );
  static const VerificationMeta _toAccountIdMeta = const VerificationMeta(
    'toAccountId',
  );
  @override
  late final GeneratedColumn<String> toAccountId = GeneratedColumn<String>(
    'to_account_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES accounts (id)',
    ),
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES categories (id)',
    ),
  );
  static const VerificationMeta _frequencyMonthsMeta = const VerificationMeta(
    'frequencyMonths',
  );
  @override
  late final GeneratedColumn<double> frequencyMonths = GeneratedColumn<double>(
    'frequency_months',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startDateMeta = const VerificationMeta(
    'startDate',
  );
  @override
  late final GeneratedColumn<DateTime> startDate = GeneratedColumn<DateTime>(
    'start_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endDateMeta = const VerificationMeta(
    'endDate',
  );
  @override
  late final GeneratedColumn<DateTime> endDate = GeneratedColumn<DateTime>(
    'end_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isPausedMeta = const VerificationMeta(
    'isPaused',
  );
  @override
  late final GeneratedColumn<bool> isPaused = GeneratedColumn<bool>(
    'is_paused',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_paused" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _pausedAtMeta = const VerificationMeta(
    'pausedAt',
  );
  @override
  late final GeneratedColumn<DateTime> pausedAt = GeneratedColumn<DateTime>(
    'paused_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastExecutedDateMeta = const VerificationMeta(
    'lastExecutedDate',
  );
  @override
  late final GeneratedColumn<DateTime> lastExecutedDate =
      GeneratedColumn<DateTime>(
        'last_executed_date',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _annualEscalationRateMeta =
      const VerificationMeta('annualEscalationRate');
  @override
  late final GeneratedColumn<double> annualEscalationRate =
      GeneratedColumn<double>(
        'annual_escalation_rate',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
        defaultValue: const Constant(0),
      );
  static const VerificationMeta _familyIdMeta = const VerificationMeta(
    'familyId',
  );
  @override
  late final GeneratedColumn<String> familyId = GeneratedColumn<String>(
    'family_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES families (id)',
    ),
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
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
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isSecondaryIncomeMeta = const VerificationMeta(
    'isSecondaryIncome',
  );
  @override
  late final GeneratedColumn<bool> isSecondaryIncome = GeneratedColumn<bool>(
    'is_secondary_income',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_secondary_income" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _decisionIdMeta = const VerificationMeta(
    'decisionId',
  );
  @override
  late final GeneratedColumn<String> decisionId = GeneratedColumn<String>(
    'decision_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    kind,
    amount,
    accountId,
    toAccountId,
    categoryId,
    frequencyMonths,
    startDate,
    endDate,
    isPaused,
    pausedAt,
    lastExecutedDate,
    annualEscalationRate,
    familyId,
    userId,
    createdAt,
    deletedAt,
    isSecondaryIncome,
    decisionId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recurring_rules';
  @override
  VerificationContext validateIntegrity(
    Insertable<RecurringRule> instance, {
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
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('account_id')) {
      context.handle(
        _accountIdMeta,
        accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta),
      );
    } else if (isInserting) {
      context.missing(_accountIdMeta);
    }
    if (data.containsKey('to_account_id')) {
      context.handle(
        _toAccountIdMeta,
        toAccountId.isAcceptableOrUnknown(
          data['to_account_id']!,
          _toAccountIdMeta,
        ),
      );
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    }
    if (data.containsKey('frequency_months')) {
      context.handle(
        _frequencyMonthsMeta,
        frequencyMonths.isAcceptableOrUnknown(
          data['frequency_months']!,
          _frequencyMonthsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_frequencyMonthsMeta);
    }
    if (data.containsKey('start_date')) {
      context.handle(
        _startDateMeta,
        startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta),
      );
    } else if (isInserting) {
      context.missing(_startDateMeta);
    }
    if (data.containsKey('end_date')) {
      context.handle(
        _endDateMeta,
        endDate.isAcceptableOrUnknown(data['end_date']!, _endDateMeta),
      );
    }
    if (data.containsKey('is_paused')) {
      context.handle(
        _isPausedMeta,
        isPaused.isAcceptableOrUnknown(data['is_paused']!, _isPausedMeta),
      );
    }
    if (data.containsKey('paused_at')) {
      context.handle(
        _pausedAtMeta,
        pausedAt.isAcceptableOrUnknown(data['paused_at']!, _pausedAtMeta),
      );
    }
    if (data.containsKey('last_executed_date')) {
      context.handle(
        _lastExecutedDateMeta,
        lastExecutedDate.isAcceptableOrUnknown(
          data['last_executed_date']!,
          _lastExecutedDateMeta,
        ),
      );
    }
    if (data.containsKey('annual_escalation_rate')) {
      context.handle(
        _annualEscalationRateMeta,
        annualEscalationRate.isAcceptableOrUnknown(
          data['annual_escalation_rate']!,
          _annualEscalationRateMeta,
        ),
      );
    }
    if (data.containsKey('family_id')) {
      context.handle(
        _familyIdMeta,
        familyId.isAcceptableOrUnknown(data['family_id']!, _familyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_familyIdMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('is_secondary_income')) {
      context.handle(
        _isSecondaryIncomeMeta,
        isSecondaryIncome.isAcceptableOrUnknown(
          data['is_secondary_income']!,
          _isSecondaryIncomeMeta,
        ),
      );
    }
    if (data.containsKey('decision_id')) {
      context.handle(
        _decisionIdMeta,
        decisionId.isAcceptableOrUnknown(data['decision_id']!, _decisionIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RecurringRule map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RecurringRule(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount'],
      )!,
      accountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_id'],
      )!,
      toAccountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}to_account_id'],
      ),
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      ),
      frequencyMonths: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}frequency_months'],
      )!,
      startDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}start_date'],
      )!,
      endDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}end_date'],
      ),
      isPaused: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_paused'],
      )!,
      pausedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}paused_at'],
      ),
      lastExecutedDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_executed_date'],
      ),
      annualEscalationRate: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}annual_escalation_rate'],
      )!,
      familyId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}family_id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      isSecondaryIncome: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_secondary_income'],
      )!,
      decisionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}decision_id'],
      ),
    );
  }

  @override
  $RecurringRulesTable createAlias(String alias) {
    return $RecurringRulesTable(attachedDatabase, alias);
  }
}

class RecurringRule extends DataClass implements Insertable<RecurringRule> {
  final String id;
  final String name;
  final String kind;
  final int amount;
  final String accountId;
  final String? toAccountId;
  final String? categoryId;
  final double frequencyMonths;
  final DateTime startDate;
  final DateTime? endDate;
  final bool isPaused;
  final DateTime? pausedAt;
  final DateTime? lastExecutedDate;
  final double annualEscalationRate;
  final String familyId;
  final String userId;
  final DateTime createdAt;
  final DateTime? deletedAt;
  final bool isSecondaryIncome;
  final String? decisionId;
  const RecurringRule({
    required this.id,
    required this.name,
    required this.kind,
    required this.amount,
    required this.accountId,
    this.toAccountId,
    this.categoryId,
    required this.frequencyMonths,
    required this.startDate,
    this.endDate,
    required this.isPaused,
    this.pausedAt,
    this.lastExecutedDate,
    required this.annualEscalationRate,
    required this.familyId,
    required this.userId,
    required this.createdAt,
    this.deletedAt,
    required this.isSecondaryIncome,
    this.decisionId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['kind'] = Variable<String>(kind);
    map['amount'] = Variable<int>(amount);
    map['account_id'] = Variable<String>(accountId);
    if (!nullToAbsent || toAccountId != null) {
      map['to_account_id'] = Variable<String>(toAccountId);
    }
    if (!nullToAbsent || categoryId != null) {
      map['category_id'] = Variable<String>(categoryId);
    }
    map['frequency_months'] = Variable<double>(frequencyMonths);
    map['start_date'] = Variable<DateTime>(startDate);
    if (!nullToAbsent || endDate != null) {
      map['end_date'] = Variable<DateTime>(endDate);
    }
    map['is_paused'] = Variable<bool>(isPaused);
    if (!nullToAbsent || pausedAt != null) {
      map['paused_at'] = Variable<DateTime>(pausedAt);
    }
    if (!nullToAbsent || lastExecutedDate != null) {
      map['last_executed_date'] = Variable<DateTime>(lastExecutedDate);
    }
    map['annual_escalation_rate'] = Variable<double>(annualEscalationRate);
    map['family_id'] = Variable<String>(familyId);
    map['user_id'] = Variable<String>(userId);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['is_secondary_income'] = Variable<bool>(isSecondaryIncome);
    if (!nullToAbsent || decisionId != null) {
      map['decision_id'] = Variable<String>(decisionId);
    }
    return map;
  }

  RecurringRulesCompanion toCompanion(bool nullToAbsent) {
    return RecurringRulesCompanion(
      id: Value(id),
      name: Value(name),
      kind: Value(kind),
      amount: Value(amount),
      accountId: Value(accountId),
      toAccountId: toAccountId == null && nullToAbsent
          ? const Value.absent()
          : Value(toAccountId),
      categoryId: categoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryId),
      frequencyMonths: Value(frequencyMonths),
      startDate: Value(startDate),
      endDate: endDate == null && nullToAbsent
          ? const Value.absent()
          : Value(endDate),
      isPaused: Value(isPaused),
      pausedAt: pausedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(pausedAt),
      lastExecutedDate: lastExecutedDate == null && nullToAbsent
          ? const Value.absent()
          : Value(lastExecutedDate),
      annualEscalationRate: Value(annualEscalationRate),
      familyId: Value(familyId),
      userId: Value(userId),
      createdAt: Value(createdAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      isSecondaryIncome: Value(isSecondaryIncome),
      decisionId: decisionId == null && nullToAbsent
          ? const Value.absent()
          : Value(decisionId),
    );
  }

  factory RecurringRule.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RecurringRule(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      kind: serializer.fromJson<String>(json['kind']),
      amount: serializer.fromJson<int>(json['amount']),
      accountId: serializer.fromJson<String>(json['accountId']),
      toAccountId: serializer.fromJson<String?>(json['toAccountId']),
      categoryId: serializer.fromJson<String?>(json['categoryId']),
      frequencyMonths: serializer.fromJson<double>(json['frequencyMonths']),
      startDate: serializer.fromJson<DateTime>(json['startDate']),
      endDate: serializer.fromJson<DateTime?>(json['endDate']),
      isPaused: serializer.fromJson<bool>(json['isPaused']),
      pausedAt: serializer.fromJson<DateTime?>(json['pausedAt']),
      lastExecutedDate: serializer.fromJson<DateTime?>(
        json['lastExecutedDate'],
      ),
      annualEscalationRate: serializer.fromJson<double>(
        json['annualEscalationRate'],
      ),
      familyId: serializer.fromJson<String>(json['familyId']),
      userId: serializer.fromJson<String>(json['userId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      isSecondaryIncome: serializer.fromJson<bool>(json['isSecondaryIncome']),
      decisionId: serializer.fromJson<String?>(json['decisionId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'kind': serializer.toJson<String>(kind),
      'amount': serializer.toJson<int>(amount),
      'accountId': serializer.toJson<String>(accountId),
      'toAccountId': serializer.toJson<String?>(toAccountId),
      'categoryId': serializer.toJson<String?>(categoryId),
      'frequencyMonths': serializer.toJson<double>(frequencyMonths),
      'startDate': serializer.toJson<DateTime>(startDate),
      'endDate': serializer.toJson<DateTime?>(endDate),
      'isPaused': serializer.toJson<bool>(isPaused),
      'pausedAt': serializer.toJson<DateTime?>(pausedAt),
      'lastExecutedDate': serializer.toJson<DateTime?>(lastExecutedDate),
      'annualEscalationRate': serializer.toJson<double>(annualEscalationRate),
      'familyId': serializer.toJson<String>(familyId),
      'userId': serializer.toJson<String>(userId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'isSecondaryIncome': serializer.toJson<bool>(isSecondaryIncome),
      'decisionId': serializer.toJson<String?>(decisionId),
    };
  }

  RecurringRule copyWith({
    String? id,
    String? name,
    String? kind,
    int? amount,
    String? accountId,
    Value<String?> toAccountId = const Value.absent(),
    Value<String?> categoryId = const Value.absent(),
    double? frequencyMonths,
    DateTime? startDate,
    Value<DateTime?> endDate = const Value.absent(),
    bool? isPaused,
    Value<DateTime?> pausedAt = const Value.absent(),
    Value<DateTime?> lastExecutedDate = const Value.absent(),
    double? annualEscalationRate,
    String? familyId,
    String? userId,
    DateTime? createdAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    bool? isSecondaryIncome,
    Value<String?> decisionId = const Value.absent(),
  }) => RecurringRule(
    id: id ?? this.id,
    name: name ?? this.name,
    kind: kind ?? this.kind,
    amount: amount ?? this.amount,
    accountId: accountId ?? this.accountId,
    toAccountId: toAccountId.present ? toAccountId.value : this.toAccountId,
    categoryId: categoryId.present ? categoryId.value : this.categoryId,
    frequencyMonths: frequencyMonths ?? this.frequencyMonths,
    startDate: startDate ?? this.startDate,
    endDate: endDate.present ? endDate.value : this.endDate,
    isPaused: isPaused ?? this.isPaused,
    pausedAt: pausedAt.present ? pausedAt.value : this.pausedAt,
    lastExecutedDate: lastExecutedDate.present
        ? lastExecutedDate.value
        : this.lastExecutedDate,
    annualEscalationRate: annualEscalationRate ?? this.annualEscalationRate,
    familyId: familyId ?? this.familyId,
    userId: userId ?? this.userId,
    createdAt: createdAt ?? this.createdAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    isSecondaryIncome: isSecondaryIncome ?? this.isSecondaryIncome,
    decisionId: decisionId.present ? decisionId.value : this.decisionId,
  );
  RecurringRule copyWithCompanion(RecurringRulesCompanion data) {
    return RecurringRule(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      kind: data.kind.present ? data.kind.value : this.kind,
      amount: data.amount.present ? data.amount.value : this.amount,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      toAccountId: data.toAccountId.present
          ? data.toAccountId.value
          : this.toAccountId,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      frequencyMonths: data.frequencyMonths.present
          ? data.frequencyMonths.value
          : this.frequencyMonths,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      endDate: data.endDate.present ? data.endDate.value : this.endDate,
      isPaused: data.isPaused.present ? data.isPaused.value : this.isPaused,
      pausedAt: data.pausedAt.present ? data.pausedAt.value : this.pausedAt,
      lastExecutedDate: data.lastExecutedDate.present
          ? data.lastExecutedDate.value
          : this.lastExecutedDate,
      annualEscalationRate: data.annualEscalationRate.present
          ? data.annualEscalationRate.value
          : this.annualEscalationRate,
      familyId: data.familyId.present ? data.familyId.value : this.familyId,
      userId: data.userId.present ? data.userId.value : this.userId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      isSecondaryIncome: data.isSecondaryIncome.present
          ? data.isSecondaryIncome.value
          : this.isSecondaryIncome,
      decisionId: data.decisionId.present
          ? data.decisionId.value
          : this.decisionId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RecurringRule(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('kind: $kind, ')
          ..write('amount: $amount, ')
          ..write('accountId: $accountId, ')
          ..write('toAccountId: $toAccountId, ')
          ..write('categoryId: $categoryId, ')
          ..write('frequencyMonths: $frequencyMonths, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('isPaused: $isPaused, ')
          ..write('pausedAt: $pausedAt, ')
          ..write('lastExecutedDate: $lastExecutedDate, ')
          ..write('annualEscalationRate: $annualEscalationRate, ')
          ..write('familyId: $familyId, ')
          ..write('userId: $userId, ')
          ..write('createdAt: $createdAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('isSecondaryIncome: $isSecondaryIncome, ')
          ..write('decisionId: $decisionId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    kind,
    amount,
    accountId,
    toAccountId,
    categoryId,
    frequencyMonths,
    startDate,
    endDate,
    isPaused,
    pausedAt,
    lastExecutedDate,
    annualEscalationRate,
    familyId,
    userId,
    createdAt,
    deletedAt,
    isSecondaryIncome,
    decisionId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RecurringRule &&
          other.id == this.id &&
          other.name == this.name &&
          other.kind == this.kind &&
          other.amount == this.amount &&
          other.accountId == this.accountId &&
          other.toAccountId == this.toAccountId &&
          other.categoryId == this.categoryId &&
          other.frequencyMonths == this.frequencyMonths &&
          other.startDate == this.startDate &&
          other.endDate == this.endDate &&
          other.isPaused == this.isPaused &&
          other.pausedAt == this.pausedAt &&
          other.lastExecutedDate == this.lastExecutedDate &&
          other.annualEscalationRate == this.annualEscalationRate &&
          other.familyId == this.familyId &&
          other.userId == this.userId &&
          other.createdAt == this.createdAt &&
          other.deletedAt == this.deletedAt &&
          other.isSecondaryIncome == this.isSecondaryIncome &&
          other.decisionId == this.decisionId);
}

class RecurringRulesCompanion extends UpdateCompanion<RecurringRule> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> kind;
  final Value<int> amount;
  final Value<String> accountId;
  final Value<String?> toAccountId;
  final Value<String?> categoryId;
  final Value<double> frequencyMonths;
  final Value<DateTime> startDate;
  final Value<DateTime?> endDate;
  final Value<bool> isPaused;
  final Value<DateTime?> pausedAt;
  final Value<DateTime?> lastExecutedDate;
  final Value<double> annualEscalationRate;
  final Value<String> familyId;
  final Value<String> userId;
  final Value<DateTime> createdAt;
  final Value<DateTime?> deletedAt;
  final Value<bool> isSecondaryIncome;
  final Value<String?> decisionId;
  final Value<int> rowid;
  const RecurringRulesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.kind = const Value.absent(),
    this.amount = const Value.absent(),
    this.accountId = const Value.absent(),
    this.toAccountId = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.frequencyMonths = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.isPaused = const Value.absent(),
    this.pausedAt = const Value.absent(),
    this.lastExecutedDate = const Value.absent(),
    this.annualEscalationRate = const Value.absent(),
    this.familyId = const Value.absent(),
    this.userId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.isSecondaryIncome = const Value.absent(),
    this.decisionId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RecurringRulesCompanion.insert({
    required String id,
    required String name,
    required String kind,
    required int amount,
    required String accountId,
    this.toAccountId = const Value.absent(),
    this.categoryId = const Value.absent(),
    required double frequencyMonths,
    required DateTime startDate,
    this.endDate = const Value.absent(),
    this.isPaused = const Value.absent(),
    this.pausedAt = const Value.absent(),
    this.lastExecutedDate = const Value.absent(),
    this.annualEscalationRate = const Value.absent(),
    required String familyId,
    required String userId,
    required DateTime createdAt,
    this.deletedAt = const Value.absent(),
    this.isSecondaryIncome = const Value.absent(),
    this.decisionId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       kind = Value(kind),
       amount = Value(amount),
       accountId = Value(accountId),
       frequencyMonths = Value(frequencyMonths),
       startDate = Value(startDate),
       familyId = Value(familyId),
       userId = Value(userId),
       createdAt = Value(createdAt);
  static Insertable<RecurringRule> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? kind,
    Expression<int>? amount,
    Expression<String>? accountId,
    Expression<String>? toAccountId,
    Expression<String>? categoryId,
    Expression<double>? frequencyMonths,
    Expression<DateTime>? startDate,
    Expression<DateTime>? endDate,
    Expression<bool>? isPaused,
    Expression<DateTime>? pausedAt,
    Expression<DateTime>? lastExecutedDate,
    Expression<double>? annualEscalationRate,
    Expression<String>? familyId,
    Expression<String>? userId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? deletedAt,
    Expression<bool>? isSecondaryIncome,
    Expression<String>? decisionId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (kind != null) 'kind': kind,
      if (amount != null) 'amount': amount,
      if (accountId != null) 'account_id': accountId,
      if (toAccountId != null) 'to_account_id': toAccountId,
      if (categoryId != null) 'category_id': categoryId,
      if (frequencyMonths != null) 'frequency_months': frequencyMonths,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      if (isPaused != null) 'is_paused': isPaused,
      if (pausedAt != null) 'paused_at': pausedAt,
      if (lastExecutedDate != null) 'last_executed_date': lastExecutedDate,
      if (annualEscalationRate != null)
        'annual_escalation_rate': annualEscalationRate,
      if (familyId != null) 'family_id': familyId,
      if (userId != null) 'user_id': userId,
      if (createdAt != null) 'created_at': createdAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (isSecondaryIncome != null) 'is_secondary_income': isSecondaryIncome,
      if (decisionId != null) 'decision_id': decisionId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RecurringRulesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? kind,
    Value<int>? amount,
    Value<String>? accountId,
    Value<String?>? toAccountId,
    Value<String?>? categoryId,
    Value<double>? frequencyMonths,
    Value<DateTime>? startDate,
    Value<DateTime?>? endDate,
    Value<bool>? isPaused,
    Value<DateTime?>? pausedAt,
    Value<DateTime?>? lastExecutedDate,
    Value<double>? annualEscalationRate,
    Value<String>? familyId,
    Value<String>? userId,
    Value<DateTime>? createdAt,
    Value<DateTime?>? deletedAt,
    Value<bool>? isSecondaryIncome,
    Value<String?>? decisionId,
    Value<int>? rowid,
  }) {
    return RecurringRulesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      kind: kind ?? this.kind,
      amount: amount ?? this.amount,
      accountId: accountId ?? this.accountId,
      toAccountId: toAccountId ?? this.toAccountId,
      categoryId: categoryId ?? this.categoryId,
      frequencyMonths: frequencyMonths ?? this.frequencyMonths,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isPaused: isPaused ?? this.isPaused,
      pausedAt: pausedAt ?? this.pausedAt,
      lastExecutedDate: lastExecutedDate ?? this.lastExecutedDate,
      annualEscalationRate: annualEscalationRate ?? this.annualEscalationRate,
      familyId: familyId ?? this.familyId,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      deletedAt: deletedAt ?? this.deletedAt,
      isSecondaryIncome: isSecondaryIncome ?? this.isSecondaryIncome,
      decisionId: decisionId ?? this.decisionId,
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
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (amount.present) {
      map['amount'] = Variable<int>(amount.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<String>(accountId.value);
    }
    if (toAccountId.present) {
      map['to_account_id'] = Variable<String>(toAccountId.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (frequencyMonths.present) {
      map['frequency_months'] = Variable<double>(frequencyMonths.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<DateTime>(startDate.value);
    }
    if (endDate.present) {
      map['end_date'] = Variable<DateTime>(endDate.value);
    }
    if (isPaused.present) {
      map['is_paused'] = Variable<bool>(isPaused.value);
    }
    if (pausedAt.present) {
      map['paused_at'] = Variable<DateTime>(pausedAt.value);
    }
    if (lastExecutedDate.present) {
      map['last_executed_date'] = Variable<DateTime>(lastExecutedDate.value);
    }
    if (annualEscalationRate.present) {
      map['annual_escalation_rate'] = Variable<double>(
        annualEscalationRate.value,
      );
    }
    if (familyId.present) {
      map['family_id'] = Variable<String>(familyId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (isSecondaryIncome.present) {
      map['is_secondary_income'] = Variable<bool>(isSecondaryIncome.value);
    }
    if (decisionId.present) {
      map['decision_id'] = Variable<String>(decisionId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecurringRulesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('kind: $kind, ')
          ..write('amount: $amount, ')
          ..write('accountId: $accountId, ')
          ..write('toAccountId: $toAccountId, ')
          ..write('categoryId: $categoryId, ')
          ..write('frequencyMonths: $frequencyMonths, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('isPaused: $isPaused, ')
          ..write('pausedAt: $pausedAt, ')
          ..write('lastExecutedDate: $lastExecutedDate, ')
          ..write('annualEscalationRate: $annualEscalationRate, ')
          ..write('familyId: $familyId, ')
          ..write('userId: $userId, ')
          ..write('createdAt: $createdAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('isSecondaryIncome: $isSecondaryIncome, ')
          ..write('decisionId: $decisionId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AllocationTargetsTable extends AllocationTargets
    with TableInfo<$AllocationTargetsTable, AllocationTarget> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AllocationTargetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lifeProfileIdMeta = const VerificationMeta(
    'lifeProfileId',
  );
  @override
  late final GeneratedColumn<String> lifeProfileId = GeneratedColumn<String>(
    'life_profile_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES life_profiles (id)',
    ),
  );
  static const VerificationMeta _ageBandStartMeta = const VerificationMeta(
    'ageBandStart',
  );
  @override
  late final GeneratedColumn<int> ageBandStart = GeneratedColumn<int>(
    'age_band_start',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ageBandEndMeta = const VerificationMeta(
    'ageBandEnd',
  );
  @override
  late final GeneratedColumn<int> ageBandEnd = GeneratedColumn<int>(
    'age_band_end',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _equityBpMeta = const VerificationMeta(
    'equityBp',
  );
  @override
  late final GeneratedColumn<int> equityBp = GeneratedColumn<int>(
    'equity_bp',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _debtBpMeta = const VerificationMeta('debtBp');
  @override
  late final GeneratedColumn<int> debtBp = GeneratedColumn<int>(
    'debt_bp',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _goldBpMeta = const VerificationMeta('goldBp');
  @override
  late final GeneratedColumn<int> goldBp = GeneratedColumn<int>(
    'gold_bp',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cashBpMeta = const VerificationMeta('cashBp');
  @override
  late final GeneratedColumn<int> cashBp = GeneratedColumn<int>(
    'cash_bp',
    aliasedName,
    false,
    type: DriftSqlType.int,
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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    lifeProfileId,
    ageBandStart,
    ageBandEnd,
    equityBp,
    debtBp,
    goldBp,
    cashBp,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'allocation_targets';
  @override
  VerificationContext validateIntegrity(
    Insertable<AllocationTarget> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('life_profile_id')) {
      context.handle(
        _lifeProfileIdMeta,
        lifeProfileId.isAcceptableOrUnknown(
          data['life_profile_id']!,
          _lifeProfileIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lifeProfileIdMeta);
    }
    if (data.containsKey('age_band_start')) {
      context.handle(
        _ageBandStartMeta,
        ageBandStart.isAcceptableOrUnknown(
          data['age_band_start']!,
          _ageBandStartMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_ageBandStartMeta);
    }
    if (data.containsKey('age_band_end')) {
      context.handle(
        _ageBandEndMeta,
        ageBandEnd.isAcceptableOrUnknown(
          data['age_band_end']!,
          _ageBandEndMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_ageBandEndMeta);
    }
    if (data.containsKey('equity_bp')) {
      context.handle(
        _equityBpMeta,
        equityBp.isAcceptableOrUnknown(data['equity_bp']!, _equityBpMeta),
      );
    } else if (isInserting) {
      context.missing(_equityBpMeta);
    }
    if (data.containsKey('debt_bp')) {
      context.handle(
        _debtBpMeta,
        debtBp.isAcceptableOrUnknown(data['debt_bp']!, _debtBpMeta),
      );
    } else if (isInserting) {
      context.missing(_debtBpMeta);
    }
    if (data.containsKey('gold_bp')) {
      context.handle(
        _goldBpMeta,
        goldBp.isAcceptableOrUnknown(data['gold_bp']!, _goldBpMeta),
      );
    } else if (isInserting) {
      context.missing(_goldBpMeta);
    }
    if (data.containsKey('cash_bp')) {
      context.handle(
        _cashBpMeta,
        cashBp.isAcceptableOrUnknown(data['cash_bp']!, _cashBpMeta),
      );
    } else if (isInserting) {
      context.missing(_cashBpMeta);
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
  AllocationTarget map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AllocationTarget(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      lifeProfileId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}life_profile_id'],
      )!,
      ageBandStart: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}age_band_start'],
      )!,
      ageBandEnd: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}age_band_end'],
      )!,
      equityBp: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}equity_bp'],
      )!,
      debtBp: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}debt_bp'],
      )!,
      goldBp: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}gold_bp'],
      )!,
      cashBp: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cash_bp'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $AllocationTargetsTable createAlias(String alias) {
    return $AllocationTargetsTable(attachedDatabase, alias);
  }
}

class AllocationTarget extends DataClass
    implements Insertable<AllocationTarget> {
  final String id;
  final String lifeProfileId;
  final int ageBandStart;
  final int ageBandEnd;
  final int equityBp;
  final int debtBp;
  final int goldBp;
  final int cashBp;
  final DateTime createdAt;
  const AllocationTarget({
    required this.id,
    required this.lifeProfileId,
    required this.ageBandStart,
    required this.ageBandEnd,
    required this.equityBp,
    required this.debtBp,
    required this.goldBp,
    required this.cashBp,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['life_profile_id'] = Variable<String>(lifeProfileId);
    map['age_band_start'] = Variable<int>(ageBandStart);
    map['age_band_end'] = Variable<int>(ageBandEnd);
    map['equity_bp'] = Variable<int>(equityBp);
    map['debt_bp'] = Variable<int>(debtBp);
    map['gold_bp'] = Variable<int>(goldBp);
    map['cash_bp'] = Variable<int>(cashBp);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  AllocationTargetsCompanion toCompanion(bool nullToAbsent) {
    return AllocationTargetsCompanion(
      id: Value(id),
      lifeProfileId: Value(lifeProfileId),
      ageBandStart: Value(ageBandStart),
      ageBandEnd: Value(ageBandEnd),
      equityBp: Value(equityBp),
      debtBp: Value(debtBp),
      goldBp: Value(goldBp),
      cashBp: Value(cashBp),
      createdAt: Value(createdAt),
    );
  }

  factory AllocationTarget.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AllocationTarget(
      id: serializer.fromJson<String>(json['id']),
      lifeProfileId: serializer.fromJson<String>(json['lifeProfileId']),
      ageBandStart: serializer.fromJson<int>(json['ageBandStart']),
      ageBandEnd: serializer.fromJson<int>(json['ageBandEnd']),
      equityBp: serializer.fromJson<int>(json['equityBp']),
      debtBp: serializer.fromJson<int>(json['debtBp']),
      goldBp: serializer.fromJson<int>(json['goldBp']),
      cashBp: serializer.fromJson<int>(json['cashBp']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'lifeProfileId': serializer.toJson<String>(lifeProfileId),
      'ageBandStart': serializer.toJson<int>(ageBandStart),
      'ageBandEnd': serializer.toJson<int>(ageBandEnd),
      'equityBp': serializer.toJson<int>(equityBp),
      'debtBp': serializer.toJson<int>(debtBp),
      'goldBp': serializer.toJson<int>(goldBp),
      'cashBp': serializer.toJson<int>(cashBp),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  AllocationTarget copyWith({
    String? id,
    String? lifeProfileId,
    int? ageBandStart,
    int? ageBandEnd,
    int? equityBp,
    int? debtBp,
    int? goldBp,
    int? cashBp,
    DateTime? createdAt,
  }) => AllocationTarget(
    id: id ?? this.id,
    lifeProfileId: lifeProfileId ?? this.lifeProfileId,
    ageBandStart: ageBandStart ?? this.ageBandStart,
    ageBandEnd: ageBandEnd ?? this.ageBandEnd,
    equityBp: equityBp ?? this.equityBp,
    debtBp: debtBp ?? this.debtBp,
    goldBp: goldBp ?? this.goldBp,
    cashBp: cashBp ?? this.cashBp,
    createdAt: createdAt ?? this.createdAt,
  );
  AllocationTarget copyWithCompanion(AllocationTargetsCompanion data) {
    return AllocationTarget(
      id: data.id.present ? data.id.value : this.id,
      lifeProfileId: data.lifeProfileId.present
          ? data.lifeProfileId.value
          : this.lifeProfileId,
      ageBandStart: data.ageBandStart.present
          ? data.ageBandStart.value
          : this.ageBandStart,
      ageBandEnd: data.ageBandEnd.present
          ? data.ageBandEnd.value
          : this.ageBandEnd,
      equityBp: data.equityBp.present ? data.equityBp.value : this.equityBp,
      debtBp: data.debtBp.present ? data.debtBp.value : this.debtBp,
      goldBp: data.goldBp.present ? data.goldBp.value : this.goldBp,
      cashBp: data.cashBp.present ? data.cashBp.value : this.cashBp,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AllocationTarget(')
          ..write('id: $id, ')
          ..write('lifeProfileId: $lifeProfileId, ')
          ..write('ageBandStart: $ageBandStart, ')
          ..write('ageBandEnd: $ageBandEnd, ')
          ..write('equityBp: $equityBp, ')
          ..write('debtBp: $debtBp, ')
          ..write('goldBp: $goldBp, ')
          ..write('cashBp: $cashBp, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    lifeProfileId,
    ageBandStart,
    ageBandEnd,
    equityBp,
    debtBp,
    goldBp,
    cashBp,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AllocationTarget &&
          other.id == this.id &&
          other.lifeProfileId == this.lifeProfileId &&
          other.ageBandStart == this.ageBandStart &&
          other.ageBandEnd == this.ageBandEnd &&
          other.equityBp == this.equityBp &&
          other.debtBp == this.debtBp &&
          other.goldBp == this.goldBp &&
          other.cashBp == this.cashBp &&
          other.createdAt == this.createdAt);
}

class AllocationTargetsCompanion extends UpdateCompanion<AllocationTarget> {
  final Value<String> id;
  final Value<String> lifeProfileId;
  final Value<int> ageBandStart;
  final Value<int> ageBandEnd;
  final Value<int> equityBp;
  final Value<int> debtBp;
  final Value<int> goldBp;
  final Value<int> cashBp;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const AllocationTargetsCompanion({
    this.id = const Value.absent(),
    this.lifeProfileId = const Value.absent(),
    this.ageBandStart = const Value.absent(),
    this.ageBandEnd = const Value.absent(),
    this.equityBp = const Value.absent(),
    this.debtBp = const Value.absent(),
    this.goldBp = const Value.absent(),
    this.cashBp = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AllocationTargetsCompanion.insert({
    required String id,
    required String lifeProfileId,
    required int ageBandStart,
    required int ageBandEnd,
    required int equityBp,
    required int debtBp,
    required int goldBp,
    required int cashBp,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       lifeProfileId = Value(lifeProfileId),
       ageBandStart = Value(ageBandStart),
       ageBandEnd = Value(ageBandEnd),
       equityBp = Value(equityBp),
       debtBp = Value(debtBp),
       goldBp = Value(goldBp),
       cashBp = Value(cashBp),
       createdAt = Value(createdAt);
  static Insertable<AllocationTarget> custom({
    Expression<String>? id,
    Expression<String>? lifeProfileId,
    Expression<int>? ageBandStart,
    Expression<int>? ageBandEnd,
    Expression<int>? equityBp,
    Expression<int>? debtBp,
    Expression<int>? goldBp,
    Expression<int>? cashBp,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (lifeProfileId != null) 'life_profile_id': lifeProfileId,
      if (ageBandStart != null) 'age_band_start': ageBandStart,
      if (ageBandEnd != null) 'age_band_end': ageBandEnd,
      if (equityBp != null) 'equity_bp': equityBp,
      if (debtBp != null) 'debt_bp': debtBp,
      if (goldBp != null) 'gold_bp': goldBp,
      if (cashBp != null) 'cash_bp': cashBp,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AllocationTargetsCompanion copyWith({
    Value<String>? id,
    Value<String>? lifeProfileId,
    Value<int>? ageBandStart,
    Value<int>? ageBandEnd,
    Value<int>? equityBp,
    Value<int>? debtBp,
    Value<int>? goldBp,
    Value<int>? cashBp,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return AllocationTargetsCompanion(
      id: id ?? this.id,
      lifeProfileId: lifeProfileId ?? this.lifeProfileId,
      ageBandStart: ageBandStart ?? this.ageBandStart,
      ageBandEnd: ageBandEnd ?? this.ageBandEnd,
      equityBp: equityBp ?? this.equityBp,
      debtBp: debtBp ?? this.debtBp,
      goldBp: goldBp ?? this.goldBp,
      cashBp: cashBp ?? this.cashBp,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (lifeProfileId.present) {
      map['life_profile_id'] = Variable<String>(lifeProfileId.value);
    }
    if (ageBandStart.present) {
      map['age_band_start'] = Variable<int>(ageBandStart.value);
    }
    if (ageBandEnd.present) {
      map['age_band_end'] = Variable<int>(ageBandEnd.value);
    }
    if (equityBp.present) {
      map['equity_bp'] = Variable<int>(equityBp.value);
    }
    if (debtBp.present) {
      map['debt_bp'] = Variable<int>(debtBp.value);
    }
    if (goldBp.present) {
      map['gold_bp'] = Variable<int>(goldBp.value);
    }
    if (cashBp.present) {
      map['cash_bp'] = Variable<int>(cashBp.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AllocationTargetsCompanion(')
          ..write('id: $id, ')
          ..write('lifeProfileId: $lifeProfileId, ')
          ..write('ageBandStart: $ageBandStart, ')
          ..write('ageBandEnd: $ageBandEnd, ')
          ..write('equityBp: $equityBp, ')
          ..write('debtBp: $debtBp, ')
          ..write('goldBp: $goldBp, ')
          ..write('cashBp: $cashBp, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DecisionsTable extends Decisions
    with TableInfo<$DecisionsTable, Decision> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DecisionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _familyIdMeta = const VerificationMeta(
    'familyId',
  );
  @override
  late final GeneratedColumn<String> familyId = GeneratedColumn<String>(
    'family_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES families (id)',
    ),
  );
  static const VerificationMeta _decisionTypeMeta = const VerificationMeta(
    'decisionType',
  );
  @override
  late final GeneratedColumn<String> decisionType = GeneratedColumn<String>(
    'decision_type',
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
  static const VerificationMeta _parametersMeta = const VerificationMeta(
    'parameters',
  );
  @override
  late final GeneratedColumn<String> parameters = GeneratedColumn<String>(
    'parameters',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('preview'),
  );
  static const VerificationMeta _fiDelayYearsMeta = const VerificationMeta(
    'fiDelayYears',
  );
  @override
  late final GeneratedColumn<int> fiDelayYears = GeneratedColumn<int>(
    'fi_delay_years',
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
  static const VerificationMeta _implementedAtMeta = const VerificationMeta(
    'implementedAt',
  );
  @override
  late final GeneratedColumn<DateTime> implementedAt =
      GeneratedColumn<DateTime>(
        'implemented_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    familyId,
    decisionType,
    name,
    parameters,
    status,
    fiDelayYears,
    createdAt,
    implementedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'decisions';
  @override
  VerificationContext validateIntegrity(
    Insertable<Decision> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('family_id')) {
      context.handle(
        _familyIdMeta,
        familyId.isAcceptableOrUnknown(data['family_id']!, _familyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_familyIdMeta);
    }
    if (data.containsKey('decision_type')) {
      context.handle(
        _decisionTypeMeta,
        decisionType.isAcceptableOrUnknown(
          data['decision_type']!,
          _decisionTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_decisionTypeMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('parameters')) {
      context.handle(
        _parametersMeta,
        parameters.isAcceptableOrUnknown(data['parameters']!, _parametersMeta),
      );
    } else if (isInserting) {
      context.missing(_parametersMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('fi_delay_years')) {
      context.handle(
        _fiDelayYearsMeta,
        fiDelayYears.isAcceptableOrUnknown(
          data['fi_delay_years']!,
          _fiDelayYearsMeta,
        ),
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
    if (data.containsKey('implemented_at')) {
      context.handle(
        _implementedAtMeta,
        implementedAt.isAcceptableOrUnknown(
          data['implemented_at']!,
          _implementedAtMeta,
        ),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Decision map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Decision(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      familyId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}family_id'],
      )!,
      decisionType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}decision_type'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      parameters: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}parameters'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      fiDelayYears: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fi_delay_years'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      implementedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}implemented_at'],
      ),
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $DecisionsTable createAlias(String alias) {
    return $DecisionsTable(attachedDatabase, alias);
  }
}

class Decision extends DataClass implements Insertable<Decision> {
  final String id;
  final String userId;
  final String familyId;
  final String decisionType;
  final String name;
  final String parameters;
  final String status;
  final int? fiDelayYears;
  final DateTime createdAt;
  final DateTime? implementedAt;
  final DateTime? deletedAt;
  const Decision({
    required this.id,
    required this.userId,
    required this.familyId,
    required this.decisionType,
    required this.name,
    required this.parameters,
    required this.status,
    this.fiDelayYears,
    required this.createdAt,
    this.implementedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['family_id'] = Variable<String>(familyId);
    map['decision_type'] = Variable<String>(decisionType);
    map['name'] = Variable<String>(name);
    map['parameters'] = Variable<String>(parameters);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || fiDelayYears != null) {
      map['fi_delay_years'] = Variable<int>(fiDelayYears);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || implementedAt != null) {
      map['implemented_at'] = Variable<DateTime>(implementedAt);
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  DecisionsCompanion toCompanion(bool nullToAbsent) {
    return DecisionsCompanion(
      id: Value(id),
      userId: Value(userId),
      familyId: Value(familyId),
      decisionType: Value(decisionType),
      name: Value(name),
      parameters: Value(parameters),
      status: Value(status),
      fiDelayYears: fiDelayYears == null && nullToAbsent
          ? const Value.absent()
          : Value(fiDelayYears),
      createdAt: Value(createdAt),
      implementedAt: implementedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(implementedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory Decision.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Decision(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      familyId: serializer.fromJson<String>(json['familyId']),
      decisionType: serializer.fromJson<String>(json['decisionType']),
      name: serializer.fromJson<String>(json['name']),
      parameters: serializer.fromJson<String>(json['parameters']),
      status: serializer.fromJson<String>(json['status']),
      fiDelayYears: serializer.fromJson<int?>(json['fiDelayYears']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      implementedAt: serializer.fromJson<DateTime?>(json['implementedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'familyId': serializer.toJson<String>(familyId),
      'decisionType': serializer.toJson<String>(decisionType),
      'name': serializer.toJson<String>(name),
      'parameters': serializer.toJson<String>(parameters),
      'status': serializer.toJson<String>(status),
      'fiDelayYears': serializer.toJson<int?>(fiDelayYears),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'implementedAt': serializer.toJson<DateTime?>(implementedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  Decision copyWith({
    String? id,
    String? userId,
    String? familyId,
    String? decisionType,
    String? name,
    String? parameters,
    String? status,
    Value<int?> fiDelayYears = const Value.absent(),
    DateTime? createdAt,
    Value<DateTime?> implementedAt = const Value.absent(),
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => Decision(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    familyId: familyId ?? this.familyId,
    decisionType: decisionType ?? this.decisionType,
    name: name ?? this.name,
    parameters: parameters ?? this.parameters,
    status: status ?? this.status,
    fiDelayYears: fiDelayYears.present ? fiDelayYears.value : this.fiDelayYears,
    createdAt: createdAt ?? this.createdAt,
    implementedAt: implementedAt.present
        ? implementedAt.value
        : this.implementedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  Decision copyWithCompanion(DecisionsCompanion data) {
    return Decision(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      familyId: data.familyId.present ? data.familyId.value : this.familyId,
      decisionType: data.decisionType.present
          ? data.decisionType.value
          : this.decisionType,
      name: data.name.present ? data.name.value : this.name,
      parameters: data.parameters.present
          ? data.parameters.value
          : this.parameters,
      status: data.status.present ? data.status.value : this.status,
      fiDelayYears: data.fiDelayYears.present
          ? data.fiDelayYears.value
          : this.fiDelayYears,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      implementedAt: data.implementedAt.present
          ? data.implementedAt.value
          : this.implementedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Decision(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('familyId: $familyId, ')
          ..write('decisionType: $decisionType, ')
          ..write('name: $name, ')
          ..write('parameters: $parameters, ')
          ..write('status: $status, ')
          ..write('fiDelayYears: $fiDelayYears, ')
          ..write('createdAt: $createdAt, ')
          ..write('implementedAt: $implementedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    familyId,
    decisionType,
    name,
    parameters,
    status,
    fiDelayYears,
    createdAt,
    implementedAt,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Decision &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.familyId == this.familyId &&
          other.decisionType == this.decisionType &&
          other.name == this.name &&
          other.parameters == this.parameters &&
          other.status == this.status &&
          other.fiDelayYears == this.fiDelayYears &&
          other.createdAt == this.createdAt &&
          other.implementedAt == this.implementedAt &&
          other.deletedAt == this.deletedAt);
}

class DecisionsCompanion extends UpdateCompanion<Decision> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> familyId;
  final Value<String> decisionType;
  final Value<String> name;
  final Value<String> parameters;
  final Value<String> status;
  final Value<int?> fiDelayYears;
  final Value<DateTime> createdAt;
  final Value<DateTime?> implementedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const DecisionsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.familyId = const Value.absent(),
    this.decisionType = const Value.absent(),
    this.name = const Value.absent(),
    this.parameters = const Value.absent(),
    this.status = const Value.absent(),
    this.fiDelayYears = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.implementedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DecisionsCompanion.insert({
    required String id,
    required String userId,
    required String familyId,
    required String decisionType,
    required String name,
    required String parameters,
    this.status = const Value.absent(),
    this.fiDelayYears = const Value.absent(),
    required DateTime createdAt,
    this.implementedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       familyId = Value(familyId),
       decisionType = Value(decisionType),
       name = Value(name),
       parameters = Value(parameters),
       createdAt = Value(createdAt);
  static Insertable<Decision> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? familyId,
    Expression<String>? decisionType,
    Expression<String>? name,
    Expression<String>? parameters,
    Expression<String>? status,
    Expression<int>? fiDelayYears,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? implementedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (familyId != null) 'family_id': familyId,
      if (decisionType != null) 'decision_type': decisionType,
      if (name != null) 'name': name,
      if (parameters != null) 'parameters': parameters,
      if (status != null) 'status': status,
      if (fiDelayYears != null) 'fi_delay_years': fiDelayYears,
      if (createdAt != null) 'created_at': createdAt,
      if (implementedAt != null) 'implemented_at': implementedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DecisionsCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<String>? familyId,
    Value<String>? decisionType,
    Value<String>? name,
    Value<String>? parameters,
    Value<String>? status,
    Value<int?>? fiDelayYears,
    Value<DateTime>? createdAt,
    Value<DateTime?>? implementedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? rowid,
  }) {
    return DecisionsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      familyId: familyId ?? this.familyId,
      decisionType: decisionType ?? this.decisionType,
      name: name ?? this.name,
      parameters: parameters ?? this.parameters,
      status: status ?? this.status,
      fiDelayYears: fiDelayYears ?? this.fiDelayYears,
      createdAt: createdAt ?? this.createdAt,
      implementedAt: implementedAt ?? this.implementedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (familyId.present) {
      map['family_id'] = Variable<String>(familyId.value);
    }
    if (decisionType.present) {
      map['decision_type'] = Variable<String>(decisionType.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (parameters.present) {
      map['parameters'] = Variable<String>(parameters.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (fiDelayYears.present) {
      map['fi_delay_years'] = Variable<int>(fiDelayYears.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (implementedAt.present) {
      map['implemented_at'] = Variable<DateTime>(implementedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DecisionsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('familyId: $familyId, ')
          ..write('decisionType: $decisionType, ')
          ..write('name: $name, ')
          ..write('parameters: $parameters, ')
          ..write('status: $status, ')
          ..write('fiDelayYears: $fiDelayYears, ')
          ..write('createdAt: $createdAt, ')
          ..write('implementedAt: $implementedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MonthlyMetricsTable extends MonthlyMetrics
    with TableInfo<$MonthlyMetricsTable, MonthlyMetric> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MonthlyMetricsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _familyIdMeta = const VerificationMeta(
    'familyId',
  );
  @override
  late final GeneratedColumn<String> familyId = GeneratedColumn<String>(
    'family_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES families (id)',
    ),
  );
  static const VerificationMeta _monthMeta = const VerificationMeta('month');
  @override
  late final GeneratedColumn<String> month = GeneratedColumn<String>(
    'month',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _totalIncomePaiseMeta = const VerificationMeta(
    'totalIncomePaise',
  );
  @override
  late final GeneratedColumn<int> totalIncomePaise = GeneratedColumn<int>(
    'total_income_paise',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _totalExpensesPaiseMeta =
      const VerificationMeta('totalExpensesPaise');
  @override
  late final GeneratedColumn<int> totalExpensesPaise = GeneratedColumn<int>(
    'total_expenses_paise',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _savingsRateBpMeta = const VerificationMeta(
    'savingsRateBp',
  );
  @override
  late final GeneratedColumn<int> savingsRateBp = GeneratedColumn<int>(
    'savings_rate_bp',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _netWorthPaiseMeta = const VerificationMeta(
    'netWorthPaise',
  );
  @override
  late final GeneratedColumn<int> netWorthPaise = GeneratedColumn<int>(
    'net_worth_paise',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _yearsToFiMeta = const VerificationMeta(
    'yearsToFi',
  );
  @override
  late final GeneratedColumn<int> yearsToFi = GeneratedColumn<int>(
    'years_to_fi',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _computedAtMeta = const VerificationMeta(
    'computedAt',
  );
  @override
  late final GeneratedColumn<DateTime> computedAt = GeneratedColumn<DateTime>(
    'computed_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    familyId,
    month,
    totalIncomePaise,
    totalExpensesPaise,
    savingsRateBp,
    netWorthPaise,
    yearsToFi,
    computedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'monthly_metrics';
  @override
  VerificationContext validateIntegrity(
    Insertable<MonthlyMetric> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('family_id')) {
      context.handle(
        _familyIdMeta,
        familyId.isAcceptableOrUnknown(data['family_id']!, _familyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_familyIdMeta);
    }
    if (data.containsKey('month')) {
      context.handle(
        _monthMeta,
        month.isAcceptableOrUnknown(data['month']!, _monthMeta),
      );
    } else if (isInserting) {
      context.missing(_monthMeta);
    }
    if (data.containsKey('total_income_paise')) {
      context.handle(
        _totalIncomePaiseMeta,
        totalIncomePaise.isAcceptableOrUnknown(
          data['total_income_paise']!,
          _totalIncomePaiseMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_totalIncomePaiseMeta);
    }
    if (data.containsKey('total_expenses_paise')) {
      context.handle(
        _totalExpensesPaiseMeta,
        totalExpensesPaise.isAcceptableOrUnknown(
          data['total_expenses_paise']!,
          _totalExpensesPaiseMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_totalExpensesPaiseMeta);
    }
    if (data.containsKey('savings_rate_bp')) {
      context.handle(
        _savingsRateBpMeta,
        savingsRateBp.isAcceptableOrUnknown(
          data['savings_rate_bp']!,
          _savingsRateBpMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_savingsRateBpMeta);
    }
    if (data.containsKey('net_worth_paise')) {
      context.handle(
        _netWorthPaiseMeta,
        netWorthPaise.isAcceptableOrUnknown(
          data['net_worth_paise']!,
          _netWorthPaiseMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_netWorthPaiseMeta);
    }
    if (data.containsKey('years_to_fi')) {
      context.handle(
        _yearsToFiMeta,
        yearsToFi.isAcceptableOrUnknown(data['years_to_fi']!, _yearsToFiMeta),
      );
    }
    if (data.containsKey('computed_at')) {
      context.handle(
        _computedAtMeta,
        computedAt.isAcceptableOrUnknown(data['computed_at']!, _computedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_computedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MonthlyMetric map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MonthlyMetric(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      familyId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}family_id'],
      )!,
      month: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}month'],
      )!,
      totalIncomePaise: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_income_paise'],
      )!,
      totalExpensesPaise: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_expenses_paise'],
      )!,
      savingsRateBp: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}savings_rate_bp'],
      )!,
      netWorthPaise: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}net_worth_paise'],
      )!,
      yearsToFi: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}years_to_fi'],
      ),
      computedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}computed_at'],
      )!,
    );
  }

  @override
  $MonthlyMetricsTable createAlias(String alias) {
    return $MonthlyMetricsTable(attachedDatabase, alias);
  }
}

class MonthlyMetric extends DataClass implements Insertable<MonthlyMetric> {
  final String id;
  final String familyId;
  final String month;
  final int totalIncomePaise;
  final int totalExpensesPaise;
  final int savingsRateBp;
  final int netWorthPaise;
  final int? yearsToFi;
  final DateTime computedAt;
  const MonthlyMetric({
    required this.id,
    required this.familyId,
    required this.month,
    required this.totalIncomePaise,
    required this.totalExpensesPaise,
    required this.savingsRateBp,
    required this.netWorthPaise,
    this.yearsToFi,
    required this.computedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['family_id'] = Variable<String>(familyId);
    map['month'] = Variable<String>(month);
    map['total_income_paise'] = Variable<int>(totalIncomePaise);
    map['total_expenses_paise'] = Variable<int>(totalExpensesPaise);
    map['savings_rate_bp'] = Variable<int>(savingsRateBp);
    map['net_worth_paise'] = Variable<int>(netWorthPaise);
    if (!nullToAbsent || yearsToFi != null) {
      map['years_to_fi'] = Variable<int>(yearsToFi);
    }
    map['computed_at'] = Variable<DateTime>(computedAt);
    return map;
  }

  MonthlyMetricsCompanion toCompanion(bool nullToAbsent) {
    return MonthlyMetricsCompanion(
      id: Value(id),
      familyId: Value(familyId),
      month: Value(month),
      totalIncomePaise: Value(totalIncomePaise),
      totalExpensesPaise: Value(totalExpensesPaise),
      savingsRateBp: Value(savingsRateBp),
      netWorthPaise: Value(netWorthPaise),
      yearsToFi: yearsToFi == null && nullToAbsent
          ? const Value.absent()
          : Value(yearsToFi),
      computedAt: Value(computedAt),
    );
  }

  factory MonthlyMetric.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MonthlyMetric(
      id: serializer.fromJson<String>(json['id']),
      familyId: serializer.fromJson<String>(json['familyId']),
      month: serializer.fromJson<String>(json['month']),
      totalIncomePaise: serializer.fromJson<int>(json['totalIncomePaise']),
      totalExpensesPaise: serializer.fromJson<int>(json['totalExpensesPaise']),
      savingsRateBp: serializer.fromJson<int>(json['savingsRateBp']),
      netWorthPaise: serializer.fromJson<int>(json['netWorthPaise']),
      yearsToFi: serializer.fromJson<int?>(json['yearsToFi']),
      computedAt: serializer.fromJson<DateTime>(json['computedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'familyId': serializer.toJson<String>(familyId),
      'month': serializer.toJson<String>(month),
      'totalIncomePaise': serializer.toJson<int>(totalIncomePaise),
      'totalExpensesPaise': serializer.toJson<int>(totalExpensesPaise),
      'savingsRateBp': serializer.toJson<int>(savingsRateBp),
      'netWorthPaise': serializer.toJson<int>(netWorthPaise),
      'yearsToFi': serializer.toJson<int?>(yearsToFi),
      'computedAt': serializer.toJson<DateTime>(computedAt),
    };
  }

  MonthlyMetric copyWith({
    String? id,
    String? familyId,
    String? month,
    int? totalIncomePaise,
    int? totalExpensesPaise,
    int? savingsRateBp,
    int? netWorthPaise,
    Value<int?> yearsToFi = const Value.absent(),
    DateTime? computedAt,
  }) => MonthlyMetric(
    id: id ?? this.id,
    familyId: familyId ?? this.familyId,
    month: month ?? this.month,
    totalIncomePaise: totalIncomePaise ?? this.totalIncomePaise,
    totalExpensesPaise: totalExpensesPaise ?? this.totalExpensesPaise,
    savingsRateBp: savingsRateBp ?? this.savingsRateBp,
    netWorthPaise: netWorthPaise ?? this.netWorthPaise,
    yearsToFi: yearsToFi.present ? yearsToFi.value : this.yearsToFi,
    computedAt: computedAt ?? this.computedAt,
  );
  MonthlyMetric copyWithCompanion(MonthlyMetricsCompanion data) {
    return MonthlyMetric(
      id: data.id.present ? data.id.value : this.id,
      familyId: data.familyId.present ? data.familyId.value : this.familyId,
      month: data.month.present ? data.month.value : this.month,
      totalIncomePaise: data.totalIncomePaise.present
          ? data.totalIncomePaise.value
          : this.totalIncomePaise,
      totalExpensesPaise: data.totalExpensesPaise.present
          ? data.totalExpensesPaise.value
          : this.totalExpensesPaise,
      savingsRateBp: data.savingsRateBp.present
          ? data.savingsRateBp.value
          : this.savingsRateBp,
      netWorthPaise: data.netWorthPaise.present
          ? data.netWorthPaise.value
          : this.netWorthPaise,
      yearsToFi: data.yearsToFi.present ? data.yearsToFi.value : this.yearsToFi,
      computedAt: data.computedAt.present
          ? data.computedAt.value
          : this.computedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MonthlyMetric(')
          ..write('id: $id, ')
          ..write('familyId: $familyId, ')
          ..write('month: $month, ')
          ..write('totalIncomePaise: $totalIncomePaise, ')
          ..write('totalExpensesPaise: $totalExpensesPaise, ')
          ..write('savingsRateBp: $savingsRateBp, ')
          ..write('netWorthPaise: $netWorthPaise, ')
          ..write('yearsToFi: $yearsToFi, ')
          ..write('computedAt: $computedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    familyId,
    month,
    totalIncomePaise,
    totalExpensesPaise,
    savingsRateBp,
    netWorthPaise,
    yearsToFi,
    computedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MonthlyMetric &&
          other.id == this.id &&
          other.familyId == this.familyId &&
          other.month == this.month &&
          other.totalIncomePaise == this.totalIncomePaise &&
          other.totalExpensesPaise == this.totalExpensesPaise &&
          other.savingsRateBp == this.savingsRateBp &&
          other.netWorthPaise == this.netWorthPaise &&
          other.yearsToFi == this.yearsToFi &&
          other.computedAt == this.computedAt);
}

class MonthlyMetricsCompanion extends UpdateCompanion<MonthlyMetric> {
  final Value<String> id;
  final Value<String> familyId;
  final Value<String> month;
  final Value<int> totalIncomePaise;
  final Value<int> totalExpensesPaise;
  final Value<int> savingsRateBp;
  final Value<int> netWorthPaise;
  final Value<int?> yearsToFi;
  final Value<DateTime> computedAt;
  final Value<int> rowid;
  const MonthlyMetricsCompanion({
    this.id = const Value.absent(),
    this.familyId = const Value.absent(),
    this.month = const Value.absent(),
    this.totalIncomePaise = const Value.absent(),
    this.totalExpensesPaise = const Value.absent(),
    this.savingsRateBp = const Value.absent(),
    this.netWorthPaise = const Value.absent(),
    this.yearsToFi = const Value.absent(),
    this.computedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MonthlyMetricsCompanion.insert({
    required String id,
    required String familyId,
    required String month,
    required int totalIncomePaise,
    required int totalExpensesPaise,
    required int savingsRateBp,
    required int netWorthPaise,
    this.yearsToFi = const Value.absent(),
    required DateTime computedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       familyId = Value(familyId),
       month = Value(month),
       totalIncomePaise = Value(totalIncomePaise),
       totalExpensesPaise = Value(totalExpensesPaise),
       savingsRateBp = Value(savingsRateBp),
       netWorthPaise = Value(netWorthPaise),
       computedAt = Value(computedAt);
  static Insertable<MonthlyMetric> custom({
    Expression<String>? id,
    Expression<String>? familyId,
    Expression<String>? month,
    Expression<int>? totalIncomePaise,
    Expression<int>? totalExpensesPaise,
    Expression<int>? savingsRateBp,
    Expression<int>? netWorthPaise,
    Expression<int>? yearsToFi,
    Expression<DateTime>? computedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (familyId != null) 'family_id': familyId,
      if (month != null) 'month': month,
      if (totalIncomePaise != null) 'total_income_paise': totalIncomePaise,
      if (totalExpensesPaise != null)
        'total_expenses_paise': totalExpensesPaise,
      if (savingsRateBp != null) 'savings_rate_bp': savingsRateBp,
      if (netWorthPaise != null) 'net_worth_paise': netWorthPaise,
      if (yearsToFi != null) 'years_to_fi': yearsToFi,
      if (computedAt != null) 'computed_at': computedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MonthlyMetricsCompanion copyWith({
    Value<String>? id,
    Value<String>? familyId,
    Value<String>? month,
    Value<int>? totalIncomePaise,
    Value<int>? totalExpensesPaise,
    Value<int>? savingsRateBp,
    Value<int>? netWorthPaise,
    Value<int?>? yearsToFi,
    Value<DateTime>? computedAt,
    Value<int>? rowid,
  }) {
    return MonthlyMetricsCompanion(
      id: id ?? this.id,
      familyId: familyId ?? this.familyId,
      month: month ?? this.month,
      totalIncomePaise: totalIncomePaise ?? this.totalIncomePaise,
      totalExpensesPaise: totalExpensesPaise ?? this.totalExpensesPaise,
      savingsRateBp: savingsRateBp ?? this.savingsRateBp,
      netWorthPaise: netWorthPaise ?? this.netWorthPaise,
      yearsToFi: yearsToFi ?? this.yearsToFi,
      computedAt: computedAt ?? this.computedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (familyId.present) {
      map['family_id'] = Variable<String>(familyId.value);
    }
    if (month.present) {
      map['month'] = Variable<String>(month.value);
    }
    if (totalIncomePaise.present) {
      map['total_income_paise'] = Variable<int>(totalIncomePaise.value);
    }
    if (totalExpensesPaise.present) {
      map['total_expenses_paise'] = Variable<int>(totalExpensesPaise.value);
    }
    if (savingsRateBp.present) {
      map['savings_rate_bp'] = Variable<int>(savingsRateBp.value);
    }
    if (netWorthPaise.present) {
      map['net_worth_paise'] = Variable<int>(netWorthPaise.value);
    }
    if (yearsToFi.present) {
      map['years_to_fi'] = Variable<int>(yearsToFi.value);
    }
    if (computedAt.present) {
      map['computed_at'] = Variable<DateTime>(computedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MonthlyMetricsCompanion(')
          ..write('id: $id, ')
          ..write('familyId: $familyId, ')
          ..write('month: $month, ')
          ..write('totalIncomePaise: $totalIncomePaise, ')
          ..write('totalExpensesPaise: $totalExpensesPaise, ')
          ..write('savingsRateBp: $savingsRateBp, ')
          ..write('netWorthPaise: $netWorthPaise, ')
          ..write('yearsToFi: $yearsToFi, ')
          ..write('computedAt: $computedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SavingsAllocationRulesTable extends SavingsAllocationRules
    with TableInfo<$SavingsAllocationRulesTable, SavingsAllocationRule> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SavingsAllocationRulesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _familyIdMeta = const VerificationMeta(
    'familyId',
  );
  @override
  late final GeneratedColumn<String> familyId = GeneratedColumn<String>(
    'family_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES families (id)',
    ),
  );
  static const VerificationMeta _priorityMeta = const VerificationMeta(
    'priority',
  );
  @override
  late final GeneratedColumn<int> priority = GeneratedColumn<int>(
    'priority',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetTypeMeta = const VerificationMeta(
    'targetType',
  );
  @override
  late final GeneratedColumn<String> targetType = GeneratedColumn<String>(
    'target_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetIdMeta = const VerificationMeta(
    'targetId',
  );
  @override
  late final GeneratedColumn<String> targetId = GeneratedColumn<String>(
    'target_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _allocationTypeMeta = const VerificationMeta(
    'allocationType',
  );
  @override
  late final GeneratedColumn<String> allocationType = GeneratedColumn<String>(
    'allocation_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountPaiseMeta = const VerificationMeta(
    'amountPaise',
  );
  @override
  late final GeneratedColumn<int> amountPaise = GeneratedColumn<int>(
    'amount_paise',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _percentageBpMeta = const VerificationMeta(
    'percentageBp',
  );
  @override
  late final GeneratedColumn<int> percentageBp = GeneratedColumn<int>(
    'percentage_bp',
    aliasedName,
    true,
    type: DriftSqlType.int,
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
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    familyId,
    priority,
    targetType,
    targetId,
    allocationType,
    amountPaise,
    percentageBp,
    isActive,
    createdAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'savings_allocation_rules';
  @override
  VerificationContext validateIntegrity(
    Insertable<SavingsAllocationRule> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('family_id')) {
      context.handle(
        _familyIdMeta,
        familyId.isAcceptableOrUnknown(data['family_id']!, _familyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_familyIdMeta);
    }
    if (data.containsKey('priority')) {
      context.handle(
        _priorityMeta,
        priority.isAcceptableOrUnknown(data['priority']!, _priorityMeta),
      );
    } else if (isInserting) {
      context.missing(_priorityMeta);
    }
    if (data.containsKey('target_type')) {
      context.handle(
        _targetTypeMeta,
        targetType.isAcceptableOrUnknown(data['target_type']!, _targetTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_targetTypeMeta);
    }
    if (data.containsKey('target_id')) {
      context.handle(
        _targetIdMeta,
        targetId.isAcceptableOrUnknown(data['target_id']!, _targetIdMeta),
      );
    }
    if (data.containsKey('allocation_type')) {
      context.handle(
        _allocationTypeMeta,
        allocationType.isAcceptableOrUnknown(
          data['allocation_type']!,
          _allocationTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_allocationTypeMeta);
    }
    if (data.containsKey('amount_paise')) {
      context.handle(
        _amountPaiseMeta,
        amountPaise.isAcceptableOrUnknown(
          data['amount_paise']!,
          _amountPaiseMeta,
        ),
      );
    }
    if (data.containsKey('percentage_bp')) {
      context.handle(
        _percentageBpMeta,
        percentageBp.isAcceptableOrUnknown(
          data['percentage_bp']!,
          _percentageBpMeta,
        ),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
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
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SavingsAllocationRule map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SavingsAllocationRule(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      familyId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}family_id'],
      )!,
      priority: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}priority'],
      )!,
      targetType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target_type'],
      )!,
      targetId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target_id'],
      ),
      allocationType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}allocation_type'],
      )!,
      amountPaise: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_paise'],
      ),
      percentageBp: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}percentage_bp'],
      ),
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $SavingsAllocationRulesTable createAlias(String alias) {
    return $SavingsAllocationRulesTable(attachedDatabase, alias);
  }
}

class SavingsAllocationRule extends DataClass
    implements Insertable<SavingsAllocationRule> {
  final String id;
  final String familyId;
  final int priority;
  final String targetType;
  final String? targetId;
  final String allocationType;
  final int? amountPaise;
  final int? percentageBp;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? deletedAt;
  const SavingsAllocationRule({
    required this.id,
    required this.familyId,
    required this.priority,
    required this.targetType,
    this.targetId,
    required this.allocationType,
    this.amountPaise,
    this.percentageBp,
    required this.isActive,
    required this.createdAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['family_id'] = Variable<String>(familyId);
    map['priority'] = Variable<int>(priority);
    map['target_type'] = Variable<String>(targetType);
    if (!nullToAbsent || targetId != null) {
      map['target_id'] = Variable<String>(targetId);
    }
    map['allocation_type'] = Variable<String>(allocationType);
    if (!nullToAbsent || amountPaise != null) {
      map['amount_paise'] = Variable<int>(amountPaise);
    }
    if (!nullToAbsent || percentageBp != null) {
      map['percentage_bp'] = Variable<int>(percentageBp);
    }
    map['is_active'] = Variable<bool>(isActive);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  SavingsAllocationRulesCompanion toCompanion(bool nullToAbsent) {
    return SavingsAllocationRulesCompanion(
      id: Value(id),
      familyId: Value(familyId),
      priority: Value(priority),
      targetType: Value(targetType),
      targetId: targetId == null && nullToAbsent
          ? const Value.absent()
          : Value(targetId),
      allocationType: Value(allocationType),
      amountPaise: amountPaise == null && nullToAbsent
          ? const Value.absent()
          : Value(amountPaise),
      percentageBp: percentageBp == null && nullToAbsent
          ? const Value.absent()
          : Value(percentageBp),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory SavingsAllocationRule.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SavingsAllocationRule(
      id: serializer.fromJson<String>(json['id']),
      familyId: serializer.fromJson<String>(json['familyId']),
      priority: serializer.fromJson<int>(json['priority']),
      targetType: serializer.fromJson<String>(json['targetType']),
      targetId: serializer.fromJson<String?>(json['targetId']),
      allocationType: serializer.fromJson<String>(json['allocationType']),
      amountPaise: serializer.fromJson<int?>(json['amountPaise']),
      percentageBp: serializer.fromJson<int?>(json['percentageBp']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'familyId': serializer.toJson<String>(familyId),
      'priority': serializer.toJson<int>(priority),
      'targetType': serializer.toJson<String>(targetType),
      'targetId': serializer.toJson<String?>(targetId),
      'allocationType': serializer.toJson<String>(allocationType),
      'amountPaise': serializer.toJson<int?>(amountPaise),
      'percentageBp': serializer.toJson<int?>(percentageBp),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  SavingsAllocationRule copyWith({
    String? id,
    String? familyId,
    int? priority,
    String? targetType,
    Value<String?> targetId = const Value.absent(),
    String? allocationType,
    Value<int?> amountPaise = const Value.absent(),
    Value<int?> percentageBp = const Value.absent(),
    bool? isActive,
    DateTime? createdAt,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => SavingsAllocationRule(
    id: id ?? this.id,
    familyId: familyId ?? this.familyId,
    priority: priority ?? this.priority,
    targetType: targetType ?? this.targetType,
    targetId: targetId.present ? targetId.value : this.targetId,
    allocationType: allocationType ?? this.allocationType,
    amountPaise: amountPaise.present ? amountPaise.value : this.amountPaise,
    percentageBp: percentageBp.present ? percentageBp.value : this.percentageBp,
    isActive: isActive ?? this.isActive,
    createdAt: createdAt ?? this.createdAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  SavingsAllocationRule copyWithCompanion(
    SavingsAllocationRulesCompanion data,
  ) {
    return SavingsAllocationRule(
      id: data.id.present ? data.id.value : this.id,
      familyId: data.familyId.present ? data.familyId.value : this.familyId,
      priority: data.priority.present ? data.priority.value : this.priority,
      targetType: data.targetType.present
          ? data.targetType.value
          : this.targetType,
      targetId: data.targetId.present ? data.targetId.value : this.targetId,
      allocationType: data.allocationType.present
          ? data.allocationType.value
          : this.allocationType,
      amountPaise: data.amountPaise.present
          ? data.amountPaise.value
          : this.amountPaise,
      percentageBp: data.percentageBp.present
          ? data.percentageBp.value
          : this.percentageBp,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SavingsAllocationRule(')
          ..write('id: $id, ')
          ..write('familyId: $familyId, ')
          ..write('priority: $priority, ')
          ..write('targetType: $targetType, ')
          ..write('targetId: $targetId, ')
          ..write('allocationType: $allocationType, ')
          ..write('amountPaise: $amountPaise, ')
          ..write('percentageBp: $percentageBp, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    familyId,
    priority,
    targetType,
    targetId,
    allocationType,
    amountPaise,
    percentageBp,
    isActive,
    createdAt,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SavingsAllocationRule &&
          other.id == this.id &&
          other.familyId == this.familyId &&
          other.priority == this.priority &&
          other.targetType == this.targetType &&
          other.targetId == this.targetId &&
          other.allocationType == this.allocationType &&
          other.amountPaise == this.amountPaise &&
          other.percentageBp == this.percentageBp &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt &&
          other.deletedAt == this.deletedAt);
}

class SavingsAllocationRulesCompanion
    extends UpdateCompanion<SavingsAllocationRule> {
  final Value<String> id;
  final Value<String> familyId;
  final Value<int> priority;
  final Value<String> targetType;
  final Value<String?> targetId;
  final Value<String> allocationType;
  final Value<int?> amountPaise;
  final Value<int?> percentageBp;
  final Value<bool> isActive;
  final Value<DateTime> createdAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const SavingsAllocationRulesCompanion({
    this.id = const Value.absent(),
    this.familyId = const Value.absent(),
    this.priority = const Value.absent(),
    this.targetType = const Value.absent(),
    this.targetId = const Value.absent(),
    this.allocationType = const Value.absent(),
    this.amountPaise = const Value.absent(),
    this.percentageBp = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SavingsAllocationRulesCompanion.insert({
    required String id,
    required String familyId,
    required int priority,
    required String targetType,
    this.targetId = const Value.absent(),
    required String allocationType,
    this.amountPaise = const Value.absent(),
    this.percentageBp = const Value.absent(),
    this.isActive = const Value.absent(),
    required DateTime createdAt,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       familyId = Value(familyId),
       priority = Value(priority),
       targetType = Value(targetType),
       allocationType = Value(allocationType),
       createdAt = Value(createdAt);
  static Insertable<SavingsAllocationRule> custom({
    Expression<String>? id,
    Expression<String>? familyId,
    Expression<int>? priority,
    Expression<String>? targetType,
    Expression<String>? targetId,
    Expression<String>? allocationType,
    Expression<int>? amountPaise,
    Expression<int>? percentageBp,
    Expression<bool>? isActive,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (familyId != null) 'family_id': familyId,
      if (priority != null) 'priority': priority,
      if (targetType != null) 'target_type': targetType,
      if (targetId != null) 'target_id': targetId,
      if (allocationType != null) 'allocation_type': allocationType,
      if (amountPaise != null) 'amount_paise': amountPaise,
      if (percentageBp != null) 'percentage_bp': percentageBp,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SavingsAllocationRulesCompanion copyWith({
    Value<String>? id,
    Value<String>? familyId,
    Value<int>? priority,
    Value<String>? targetType,
    Value<String?>? targetId,
    Value<String>? allocationType,
    Value<int?>? amountPaise,
    Value<int?>? percentageBp,
    Value<bool>? isActive,
    Value<DateTime>? createdAt,
    Value<DateTime?>? deletedAt,
    Value<int>? rowid,
  }) {
    return SavingsAllocationRulesCompanion(
      id: id ?? this.id,
      familyId: familyId ?? this.familyId,
      priority: priority ?? this.priority,
      targetType: targetType ?? this.targetType,
      targetId: targetId ?? this.targetId,
      allocationType: allocationType ?? this.allocationType,
      amountPaise: amountPaise ?? this.amountPaise,
      percentageBp: percentageBp ?? this.percentageBp,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (familyId.present) {
      map['family_id'] = Variable<String>(familyId.value);
    }
    if (priority.present) {
      map['priority'] = Variable<int>(priority.value);
    }
    if (targetType.present) {
      map['target_type'] = Variable<String>(targetType.value);
    }
    if (targetId.present) {
      map['target_id'] = Variable<String>(targetId.value);
    }
    if (allocationType.present) {
      map['allocation_type'] = Variable<String>(allocationType.value);
    }
    if (amountPaise.present) {
      map['amount_paise'] = Variable<int>(amountPaise.value);
    }
    if (percentageBp.present) {
      map['percentage_bp'] = Variable<int>(percentageBp.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SavingsAllocationRulesCompanion(')
          ..write('id: $id, ')
          ..write('familyId: $familyId, ')
          ..write('priority: $priority, ')
          ..write('targetType: $targetType, ')
          ..write('targetId: $targetId, ')
          ..write('allocationType: $allocationType, ')
          ..write('amountPaise: $amountPaise, ')
          ..write('percentageBp: $percentageBp, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncChangelogTable extends SyncChangelog
    with TableInfo<$SyncChangelogTable, SyncChangelogData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncChangelogTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
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
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timestampMeta = const VerificationMeta(
    'timestamp',
  );
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
    'timestamp',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncedMeta = const VerificationMeta('synced');
  @override
  late final GeneratedColumn<bool> synced = GeneratedColumn<bool>(
    'synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _changesetIdMeta = const VerificationMeta(
    'changesetId',
  );
  @override
  late final GeneratedColumn<String> changesetId = GeneratedColumn<String>(
    'changeset_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    entityType,
    entityId,
    operation,
    payload,
    timestamp,
    synced,
    changesetId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_changelog';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncChangelogData> instance, {
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
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('operation')) {
      context.handle(
        _operationMeta,
        operation.isAcceptableOrUnknown(data['operation']!, _operationMeta),
      );
    } else if (isInserting) {
      context.missing(_operationMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('timestamp')) {
      context.handle(
        _timestampMeta,
        timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta),
      );
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    if (data.containsKey('synced')) {
      context.handle(
        _syncedMeta,
        synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta),
      );
    }
    if (data.containsKey('changeset_id')) {
      context.handle(
        _changesetIdMeta,
        changesetId.isAcceptableOrUnknown(
          data['changeset_id']!,
          _changesetIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncChangelogData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncChangelogData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      entityType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_type'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      )!,
      operation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}operation'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
      timestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}timestamp'],
      )!,
      synced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}synced'],
      )!,
      changesetId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}changeset_id'],
      ),
    );
  }

  @override
  $SyncChangelogTable createAlias(String alias) {
    return $SyncChangelogTable(attachedDatabase, alias);
  }
}

class SyncChangelogData extends DataClass
    implements Insertable<SyncChangelogData> {
  final int id;
  final String entityType;
  final String entityId;
  final String operation;
  final String payload;
  final DateTime timestamp;
  final bool synced;
  final String? changesetId;
  const SyncChangelogData({
    required this.id,
    required this.entityType,
    required this.entityId,
    required this.operation,
    required this.payload,
    required this.timestamp,
    required this.synced,
    this.changesetId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['entity_type'] = Variable<String>(entityType);
    map['entity_id'] = Variable<String>(entityId);
    map['operation'] = Variable<String>(operation);
    map['payload'] = Variable<String>(payload);
    map['timestamp'] = Variable<DateTime>(timestamp);
    map['synced'] = Variable<bool>(synced);
    if (!nullToAbsent || changesetId != null) {
      map['changeset_id'] = Variable<String>(changesetId);
    }
    return map;
  }

  SyncChangelogCompanion toCompanion(bool nullToAbsent) {
    return SyncChangelogCompanion(
      id: Value(id),
      entityType: Value(entityType),
      entityId: Value(entityId),
      operation: Value(operation),
      payload: Value(payload),
      timestamp: Value(timestamp),
      synced: Value(synced),
      changesetId: changesetId == null && nullToAbsent
          ? const Value.absent()
          : Value(changesetId),
    );
  }

  factory SyncChangelogData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncChangelogData(
      id: serializer.fromJson<int>(json['id']),
      entityType: serializer.fromJson<String>(json['entityType']),
      entityId: serializer.fromJson<String>(json['entityId']),
      operation: serializer.fromJson<String>(json['operation']),
      payload: serializer.fromJson<String>(json['payload']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
      synced: serializer.fromJson<bool>(json['synced']),
      changesetId: serializer.fromJson<String?>(json['changesetId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'entityType': serializer.toJson<String>(entityType),
      'entityId': serializer.toJson<String>(entityId),
      'operation': serializer.toJson<String>(operation),
      'payload': serializer.toJson<String>(payload),
      'timestamp': serializer.toJson<DateTime>(timestamp),
      'synced': serializer.toJson<bool>(synced),
      'changesetId': serializer.toJson<String?>(changesetId),
    };
  }

  SyncChangelogData copyWith({
    int? id,
    String? entityType,
    String? entityId,
    String? operation,
    String? payload,
    DateTime? timestamp,
    bool? synced,
    Value<String?> changesetId = const Value.absent(),
  }) => SyncChangelogData(
    id: id ?? this.id,
    entityType: entityType ?? this.entityType,
    entityId: entityId ?? this.entityId,
    operation: operation ?? this.operation,
    payload: payload ?? this.payload,
    timestamp: timestamp ?? this.timestamp,
    synced: synced ?? this.synced,
    changesetId: changesetId.present ? changesetId.value : this.changesetId,
  );
  SyncChangelogData copyWithCompanion(SyncChangelogCompanion data) {
    return SyncChangelogData(
      id: data.id.present ? data.id.value : this.id,
      entityType: data.entityType.present
          ? data.entityType.value
          : this.entityType,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      operation: data.operation.present ? data.operation.value : this.operation,
      payload: data.payload.present ? data.payload.value : this.payload,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      synced: data.synced.present ? data.synced.value : this.synced,
      changesetId: data.changesetId.present
          ? data.changesetId.value
          : this.changesetId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncChangelogData(')
          ..write('id: $id, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('operation: $operation, ')
          ..write('payload: $payload, ')
          ..write('timestamp: $timestamp, ')
          ..write('synced: $synced, ')
          ..write('changesetId: $changesetId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    entityType,
    entityId,
    operation,
    payload,
    timestamp,
    synced,
    changesetId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncChangelogData &&
          other.id == this.id &&
          other.entityType == this.entityType &&
          other.entityId == this.entityId &&
          other.operation == this.operation &&
          other.payload == this.payload &&
          other.timestamp == this.timestamp &&
          other.synced == this.synced &&
          other.changesetId == this.changesetId);
}

class SyncChangelogCompanion extends UpdateCompanion<SyncChangelogData> {
  final Value<int> id;
  final Value<String> entityType;
  final Value<String> entityId;
  final Value<String> operation;
  final Value<String> payload;
  final Value<DateTime> timestamp;
  final Value<bool> synced;
  final Value<String?> changesetId;
  const SyncChangelogCompanion({
    this.id = const Value.absent(),
    this.entityType = const Value.absent(),
    this.entityId = const Value.absent(),
    this.operation = const Value.absent(),
    this.payload = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.synced = const Value.absent(),
    this.changesetId = const Value.absent(),
  });
  SyncChangelogCompanion.insert({
    this.id = const Value.absent(),
    required String entityType,
    required String entityId,
    required String operation,
    required String payload,
    required DateTime timestamp,
    this.synced = const Value.absent(),
    this.changesetId = const Value.absent(),
  }) : entityType = Value(entityType),
       entityId = Value(entityId),
       operation = Value(operation),
       payload = Value(payload),
       timestamp = Value(timestamp);
  static Insertable<SyncChangelogData> custom({
    Expression<int>? id,
    Expression<String>? entityType,
    Expression<String>? entityId,
    Expression<String>? operation,
    Expression<String>? payload,
    Expression<DateTime>? timestamp,
    Expression<bool>? synced,
    Expression<String>? changesetId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (entityType != null) 'entity_type': entityType,
      if (entityId != null) 'entity_id': entityId,
      if (operation != null) 'operation': operation,
      if (payload != null) 'payload': payload,
      if (timestamp != null) 'timestamp': timestamp,
      if (synced != null) 'synced': synced,
      if (changesetId != null) 'changeset_id': changesetId,
    });
  }

  SyncChangelogCompanion copyWith({
    Value<int>? id,
    Value<String>? entityType,
    Value<String>? entityId,
    Value<String>? operation,
    Value<String>? payload,
    Value<DateTime>? timestamp,
    Value<bool>? synced,
    Value<String?>? changesetId,
  }) {
    return SyncChangelogCompanion(
      id: id ?? this.id,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      operation: operation ?? this.operation,
      payload: payload ?? this.payload,
      timestamp: timestamp ?? this.timestamp,
      synced: synced ?? this.synced,
      changesetId: changesetId ?? this.changesetId,
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
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (operation.present) {
      map['operation'] = Variable<String>(operation.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    if (synced.present) {
      map['synced'] = Variable<bool>(synced.value);
    }
    if (changesetId.present) {
      map['changeset_id'] = Variable<String>(changesetId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncChangelogCompanion(')
          ..write('id: $id, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('operation: $operation, ')
          ..write('payload: $payload, ')
          ..write('timestamp: $timestamp, ')
          ..write('synced: $synced, ')
          ..write('changesetId: $changesetId')
          ..write(')'))
        .toString();
  }
}

class $SyncStateTableTable extends SyncStateTable
    with TableInfo<$SyncStateTableTable, SyncStateTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncStateTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastPushAtMeta = const VerificationMeta(
    'lastPushAt',
  );
  @override
  late final GeneratedColumn<int> lastPushAt = GeneratedColumn<int>(
    'last_push_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastPullAtMeta = const VerificationMeta(
    'lastPullAt',
  );
  @override
  late final GeneratedColumn<int> lastPullAt = GeneratedColumn<int>(
    'last_pull_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastSnapshotAtMeta = const VerificationMeta(
    'lastSnapshotAt',
  );
  @override
  late final GeneratedColumn<int> lastSnapshotAt = GeneratedColumn<int>(
    'last_snapshot_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pushSequenceMeta = const VerificationMeta(
    'pushSequence',
  );
  @override
  late final GeneratedColumn<int> pushSequence = GeneratedColumn<int>(
    'push_sequence',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    deviceId,
    lastPushAt,
    lastPullAt,
    lastSnapshotAt,
    pushSequence,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_state';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncStateTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('last_push_at')) {
      context.handle(
        _lastPushAtMeta,
        lastPushAt.isAcceptableOrUnknown(
          data['last_push_at']!,
          _lastPushAtMeta,
        ),
      );
    }
    if (data.containsKey('last_pull_at')) {
      context.handle(
        _lastPullAtMeta,
        lastPullAt.isAcceptableOrUnknown(
          data['last_pull_at']!,
          _lastPullAtMeta,
        ),
      );
    }
    if (data.containsKey('last_snapshot_at')) {
      context.handle(
        _lastSnapshotAtMeta,
        lastSnapshotAt.isAcceptableOrUnknown(
          data['last_snapshot_at']!,
          _lastSnapshotAtMeta,
        ),
      );
    }
    if (data.containsKey('push_sequence')) {
      context.handle(
        _pushSequenceMeta,
        pushSequence.isAcceptableOrUnknown(
          data['push_sequence']!,
          _pushSequenceMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {deviceId};
  @override
  SyncStateTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncStateTableData(
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      lastPushAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_push_at'],
      ),
      lastPullAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_pull_at'],
      ),
      lastSnapshotAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_snapshot_at'],
      ),
      pushSequence: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}push_sequence'],
      )!,
    );
  }

  @override
  $SyncStateTableTable createAlias(String alias) {
    return $SyncStateTableTable(attachedDatabase, alias);
  }
}

class SyncStateTableData extends DataClass
    implements Insertable<SyncStateTableData> {
  final String deviceId;
  final int? lastPushAt;
  final int? lastPullAt;
  final int? lastSnapshotAt;
  final int pushSequence;
  const SyncStateTableData({
    required this.deviceId,
    this.lastPushAt,
    this.lastPullAt,
    this.lastSnapshotAt,
    required this.pushSequence,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['device_id'] = Variable<String>(deviceId);
    if (!nullToAbsent || lastPushAt != null) {
      map['last_push_at'] = Variable<int>(lastPushAt);
    }
    if (!nullToAbsent || lastPullAt != null) {
      map['last_pull_at'] = Variable<int>(lastPullAt);
    }
    if (!nullToAbsent || lastSnapshotAt != null) {
      map['last_snapshot_at'] = Variable<int>(lastSnapshotAt);
    }
    map['push_sequence'] = Variable<int>(pushSequence);
    return map;
  }

  SyncStateTableCompanion toCompanion(bool nullToAbsent) {
    return SyncStateTableCompanion(
      deviceId: Value(deviceId),
      lastPushAt: lastPushAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastPushAt),
      lastPullAt: lastPullAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastPullAt),
      lastSnapshotAt: lastSnapshotAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSnapshotAt),
      pushSequence: Value(pushSequence),
    );
  }

  factory SyncStateTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncStateTableData(
      deviceId: serializer.fromJson<String>(json['deviceId']),
      lastPushAt: serializer.fromJson<int?>(json['lastPushAt']),
      lastPullAt: serializer.fromJson<int?>(json['lastPullAt']),
      lastSnapshotAt: serializer.fromJson<int?>(json['lastSnapshotAt']),
      pushSequence: serializer.fromJson<int>(json['pushSequence']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'deviceId': serializer.toJson<String>(deviceId),
      'lastPushAt': serializer.toJson<int?>(lastPushAt),
      'lastPullAt': serializer.toJson<int?>(lastPullAt),
      'lastSnapshotAt': serializer.toJson<int?>(lastSnapshotAt),
      'pushSequence': serializer.toJson<int>(pushSequence),
    };
  }

  SyncStateTableData copyWith({
    String? deviceId,
    Value<int?> lastPushAt = const Value.absent(),
    Value<int?> lastPullAt = const Value.absent(),
    Value<int?> lastSnapshotAt = const Value.absent(),
    int? pushSequence,
  }) => SyncStateTableData(
    deviceId: deviceId ?? this.deviceId,
    lastPushAt: lastPushAt.present ? lastPushAt.value : this.lastPushAt,
    lastPullAt: lastPullAt.present ? lastPullAt.value : this.lastPullAt,
    lastSnapshotAt: lastSnapshotAt.present
        ? lastSnapshotAt.value
        : this.lastSnapshotAt,
    pushSequence: pushSequence ?? this.pushSequence,
  );
  SyncStateTableData copyWithCompanion(SyncStateTableCompanion data) {
    return SyncStateTableData(
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      lastPushAt: data.lastPushAt.present
          ? data.lastPushAt.value
          : this.lastPushAt,
      lastPullAt: data.lastPullAt.present
          ? data.lastPullAt.value
          : this.lastPullAt,
      lastSnapshotAt: data.lastSnapshotAt.present
          ? data.lastSnapshotAt.value
          : this.lastSnapshotAt,
      pushSequence: data.pushSequence.present
          ? data.pushSequence.value
          : this.pushSequence,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncStateTableData(')
          ..write('deviceId: $deviceId, ')
          ..write('lastPushAt: $lastPushAt, ')
          ..write('lastPullAt: $lastPullAt, ')
          ..write('lastSnapshotAt: $lastSnapshotAt, ')
          ..write('pushSequence: $pushSequence')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    deviceId,
    lastPushAt,
    lastPullAt,
    lastSnapshotAt,
    pushSequence,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncStateTableData &&
          other.deviceId == this.deviceId &&
          other.lastPushAt == this.lastPushAt &&
          other.lastPullAt == this.lastPullAt &&
          other.lastSnapshotAt == this.lastSnapshotAt &&
          other.pushSequence == this.pushSequence);
}

class SyncStateTableCompanion extends UpdateCompanion<SyncStateTableData> {
  final Value<String> deviceId;
  final Value<int?> lastPushAt;
  final Value<int?> lastPullAt;
  final Value<int?> lastSnapshotAt;
  final Value<int> pushSequence;
  final Value<int> rowid;
  const SyncStateTableCompanion({
    this.deviceId = const Value.absent(),
    this.lastPushAt = const Value.absent(),
    this.lastPullAt = const Value.absent(),
    this.lastSnapshotAt = const Value.absent(),
    this.pushSequence = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncStateTableCompanion.insert({
    required String deviceId,
    this.lastPushAt = const Value.absent(),
    this.lastPullAt = const Value.absent(),
    this.lastSnapshotAt = const Value.absent(),
    this.pushSequence = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : deviceId = Value(deviceId);
  static Insertable<SyncStateTableData> custom({
    Expression<String>? deviceId,
    Expression<int>? lastPushAt,
    Expression<int>? lastPullAt,
    Expression<int>? lastSnapshotAt,
    Expression<int>? pushSequence,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (deviceId != null) 'device_id': deviceId,
      if (lastPushAt != null) 'last_push_at': lastPushAt,
      if (lastPullAt != null) 'last_pull_at': lastPullAt,
      if (lastSnapshotAt != null) 'last_snapshot_at': lastSnapshotAt,
      if (pushSequence != null) 'push_sequence': pushSequence,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncStateTableCompanion copyWith({
    Value<String>? deviceId,
    Value<int?>? lastPushAt,
    Value<int?>? lastPullAt,
    Value<int?>? lastSnapshotAt,
    Value<int>? pushSequence,
    Value<int>? rowid,
  }) {
    return SyncStateTableCompanion(
      deviceId: deviceId ?? this.deviceId,
      lastPushAt: lastPushAt ?? this.lastPushAt,
      lastPullAt: lastPullAt ?? this.lastPullAt,
      lastSnapshotAt: lastSnapshotAt ?? this.lastSnapshotAt,
      pushSequence: pushSequence ?? this.pushSequence,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (lastPushAt.present) {
      map['last_push_at'] = Variable<int>(lastPushAt.value);
    }
    if (lastPullAt.present) {
      map['last_pull_at'] = Variable<int>(lastPullAt.value);
    }
    if (lastSnapshotAt.present) {
      map['last_snapshot_at'] = Variable<int>(lastSnapshotAt.value);
    }
    if (pushSequence.present) {
      map['push_sequence'] = Variable<int>(pushSequence.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncStateTableCompanion(')
          ..write('deviceId: $deviceId, ')
          ..write('lastPushAt: $lastPushAt, ')
          ..write('lastPullAt: $lastPullAt, ')
          ..write('lastSnapshotAt: $lastSnapshotAt, ')
          ..write('pushSequence: $pushSequence, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $FamiliesTable families = $FamiliesTable(this);
  late final $UsersTable users = $UsersTable(this);
  late final $AccountsTable accounts = $AccountsTable(this);
  late final $CategoriesTable categories = $CategoriesTable(this);
  late final $CategoryGroupsTable categoryGroups = $CategoryGroupsTable(this);
  late final $TransactionsTable transactions = $TransactionsTable(this);
  late final $BalanceSnapshotsTable balanceSnapshots = $BalanceSnapshotsTable(
    this,
  );
  late final $AuditLogTable auditLog = $AuditLogTable(this);
  late final $GoalsTable goals = $GoalsTable(this);
  late final $BudgetsTable budgets = $BudgetsTable(this);
  late final $LoanDetailsTable loanDetails = $LoanDetailsTable(this);
  late final $InvestmentHoldingsTable investmentHoldings =
      $InvestmentHoldingsTable(this);
  late final $LifeProfilesTable lifeProfiles = $LifeProfilesTable(this);
  late final $NetWorthMilestonesTable netWorthMilestones =
      $NetWorthMilestonesTable(this);
  late final $RecurringRulesTable recurringRules = $RecurringRulesTable(this);
  late final $AllocationTargetsTable allocationTargets =
      $AllocationTargetsTable(this);
  late final $DecisionsTable decisions = $DecisionsTable(this);
  late final $MonthlyMetricsTable monthlyMetrics = $MonthlyMetricsTable(this);
  late final $SavingsAllocationRulesTable savingsAllocationRules =
      $SavingsAllocationRulesTable(this);
  late final $SyncChangelogTable syncChangelog = $SyncChangelogTable(this);
  late final $SyncStateTableTable syncStateTable = $SyncStateTableTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    families,
    users,
    accounts,
    categories,
    categoryGroups,
    transactions,
    balanceSnapshots,
    auditLog,
    goals,
    budgets,
    loanDetails,
    investmentHoldings,
    lifeProfiles,
    netWorthMilestones,
    recurringRules,
    allocationTargets,
    decisions,
    monthlyMetrics,
    savingsAllocationRules,
    syncChangelog,
    syncStateTable,
  ];
}

typedef $$FamiliesTableCreateCompanionBuilder =
    FamiliesCompanion Function({
      required String id,
      required String name,
      Value<String> baseCurrency,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$FamiliesTableUpdateCompanionBuilder =
    FamiliesCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> baseCurrency,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$FamiliesTableReferences
    extends BaseReferences<_$AppDatabase, $FamiliesTable, Family> {
  $$FamiliesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$UsersTable, List<User>> _usersRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.users,
    aliasName: $_aliasNameGenerator(db.families.id, db.users.familyId),
  );

  $$UsersTableProcessedTableManager get usersRefs {
    final manager = $$UsersTableTableManager(
      $_db,
      $_db.users,
    ).filter((f) => f.familyId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_usersRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$AccountsTable, List<Account>> _accountsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.accounts,
    aliasName: $_aliasNameGenerator(db.families.id, db.accounts.familyId),
  );

  $$AccountsTableProcessedTableManager get accountsRefs {
    final manager = $$AccountsTableTableManager(
      $_db,
      $_db.accounts,
    ).filter((f) => f.familyId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_accountsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$CategoriesTable, List<Category>>
  _categoriesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.categories,
    aliasName: $_aliasNameGenerator(db.families.id, db.categories.familyId),
  );

  $$CategoriesTableProcessedTableManager get categoriesRefs {
    final manager = $$CategoriesTableTableManager(
      $_db,
      $_db.categories,
    ).filter((f) => f.familyId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_categoriesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$CategoryGroupsTable, List<CategoryGroup>>
  _categoryGroupsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.categoryGroups,
    aliasName: $_aliasNameGenerator(db.families.id, db.categoryGroups.familyId),
  );

  $$CategoryGroupsTableProcessedTableManager get categoryGroupsRefs {
    final manager = $$CategoryGroupsTableTableManager(
      $_db,
      $_db.categoryGroups,
    ).filter((f) => f.familyId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_categoryGroupsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$TransactionsTable, List<Transaction>>
  _transactionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.transactions,
    aliasName: $_aliasNameGenerator(db.families.id, db.transactions.familyId),
  );

  $$TransactionsTableProcessedTableManager get transactionsRefs {
    final manager = $$TransactionsTableTableManager(
      $_db,
      $_db.transactions,
    ).filter((f) => f.familyId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_transactionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$BalanceSnapshotsTable, List<BalanceSnapshot>>
  _balanceSnapshotsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.balanceSnapshots,
    aliasName: $_aliasNameGenerator(
      db.families.id,
      db.balanceSnapshots.familyId,
    ),
  );

  $$BalanceSnapshotsTableProcessedTableManager get balanceSnapshotsRefs {
    final manager = $$BalanceSnapshotsTableTableManager(
      $_db,
      $_db.balanceSnapshots,
    ).filter((f) => f.familyId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _balanceSnapshotsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$AuditLogTable, List<AuditLogData>>
  _auditLogRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.auditLog,
    aliasName: $_aliasNameGenerator(db.families.id, db.auditLog.familyId),
  );

  $$AuditLogTableProcessedTableManager get auditLogRefs {
    final manager = $$AuditLogTableTableManager(
      $_db,
      $_db.auditLog,
    ).filter((f) => f.familyId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_auditLogRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$GoalsTable, List<Goal>> _goalsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.goals,
    aliasName: $_aliasNameGenerator(db.families.id, db.goals.familyId),
  );

  $$GoalsTableProcessedTableManager get goalsRefs {
    final manager = $$GoalsTableTableManager(
      $_db,
      $_db.goals,
    ).filter((f) => f.familyId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_goalsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$BudgetsTable, List<Budget>> _budgetsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.budgets,
    aliasName: $_aliasNameGenerator(db.families.id, db.budgets.familyId),
  );

  $$BudgetsTableProcessedTableManager get budgetsRefs {
    final manager = $$BudgetsTableTableManager(
      $_db,
      $_db.budgets,
    ).filter((f) => f.familyId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_budgetsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$LoanDetailsTable, List<LoanDetail>>
  _loanDetailsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.loanDetails,
    aliasName: $_aliasNameGenerator(db.families.id, db.loanDetails.familyId),
  );

  $$LoanDetailsTableProcessedTableManager get loanDetailsRefs {
    final manager = $$LoanDetailsTableTableManager(
      $_db,
      $_db.loanDetails,
    ).filter((f) => f.familyId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_loanDetailsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$InvestmentHoldingsTable, List<InvestmentHolding>>
  _investmentHoldingsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.investmentHoldings,
        aliasName: $_aliasNameGenerator(
          db.families.id,
          db.investmentHoldings.familyId,
        ),
      );

  $$InvestmentHoldingsTableProcessedTableManager get investmentHoldingsRefs {
    final manager = $$InvestmentHoldingsTableTableManager(
      $_db,
      $_db.investmentHoldings,
    ).filter((f) => f.familyId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _investmentHoldingsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$LifeProfilesTable, List<LifeProfile>>
  _lifeProfilesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.lifeProfiles,
    aliasName: $_aliasNameGenerator(db.families.id, db.lifeProfiles.familyId),
  );

  $$LifeProfilesTableProcessedTableManager get lifeProfilesRefs {
    final manager = $$LifeProfilesTableTableManager(
      $_db,
      $_db.lifeProfiles,
    ).filter((f) => f.familyId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_lifeProfilesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$NetWorthMilestonesTable, List<NetWorthMilestone>>
  _netWorthMilestonesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.netWorthMilestones,
        aliasName: $_aliasNameGenerator(
          db.families.id,
          db.netWorthMilestones.familyId,
        ),
      );

  $$NetWorthMilestonesTableProcessedTableManager get netWorthMilestonesRefs {
    final manager = $$NetWorthMilestonesTableTableManager(
      $_db,
      $_db.netWorthMilestones,
    ).filter((f) => f.familyId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _netWorthMilestonesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$RecurringRulesTable, List<RecurringRule>>
  _recurringRulesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.recurringRules,
    aliasName: $_aliasNameGenerator(db.families.id, db.recurringRules.familyId),
  );

  $$RecurringRulesTableProcessedTableManager get recurringRulesRefs {
    final manager = $$RecurringRulesTableTableManager(
      $_db,
      $_db.recurringRules,
    ).filter((f) => f.familyId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_recurringRulesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$DecisionsTable, List<Decision>>
  _decisionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.decisions,
    aliasName: $_aliasNameGenerator(db.families.id, db.decisions.familyId),
  );

  $$DecisionsTableProcessedTableManager get decisionsRefs {
    final manager = $$DecisionsTableTableManager(
      $_db,
      $_db.decisions,
    ).filter((f) => f.familyId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_decisionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$MonthlyMetricsTable, List<MonthlyMetric>>
  _monthlyMetricsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.monthlyMetrics,
    aliasName: $_aliasNameGenerator(db.families.id, db.monthlyMetrics.familyId),
  );

  $$MonthlyMetricsTableProcessedTableManager get monthlyMetricsRefs {
    final manager = $$MonthlyMetricsTableTableManager(
      $_db,
      $_db.monthlyMetrics,
    ).filter((f) => f.familyId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_monthlyMetricsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $SavingsAllocationRulesTable,
    List<SavingsAllocationRule>
  >
  _savingsAllocationRulesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.savingsAllocationRules,
        aliasName: $_aliasNameGenerator(
          db.families.id,
          db.savingsAllocationRules.familyId,
        ),
      );

  $$SavingsAllocationRulesTableProcessedTableManager
  get savingsAllocationRulesRefs {
    final manager = $$SavingsAllocationRulesTableTableManager(
      $_db,
      $_db.savingsAllocationRules,
    ).filter((f) => f.familyId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _savingsAllocationRulesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$FamiliesTableFilterComposer
    extends Composer<_$AppDatabase, $FamiliesTable> {
  $$FamiliesTableFilterComposer({
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

  ColumnFilters<String> get baseCurrency => $composableBuilder(
    column: $table.baseCurrency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> usersRefs(
    Expression<bool> Function($$UsersTableFilterComposer f) f,
  ) {
    final $$UsersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.familyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableFilterComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> accountsRefs(
    Expression<bool> Function($$AccountsTableFilterComposer f) f,
  ) {
    final $$AccountsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.familyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableFilterComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> categoriesRefs(
    Expression<bool> Function($$CategoriesTableFilterComposer f) f,
  ) {
    final $$CategoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.familyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableFilterComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> categoryGroupsRefs(
    Expression<bool> Function($$CategoryGroupsTableFilterComposer f) f,
  ) {
    final $$CategoryGroupsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.categoryGroups,
      getReferencedColumn: (t) => t.familyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoryGroupsTableFilterComposer(
            $db: $db,
            $table: $db.categoryGroups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> transactionsRefs(
    Expression<bool> Function($$TransactionsTableFilterComposer f) f,
  ) {
    final $$TransactionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.familyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionsTableFilterComposer(
            $db: $db,
            $table: $db.transactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> balanceSnapshotsRefs(
    Expression<bool> Function($$BalanceSnapshotsTableFilterComposer f) f,
  ) {
    final $$BalanceSnapshotsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.balanceSnapshots,
      getReferencedColumn: (t) => t.familyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BalanceSnapshotsTableFilterComposer(
            $db: $db,
            $table: $db.balanceSnapshots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> auditLogRefs(
    Expression<bool> Function($$AuditLogTableFilterComposer f) f,
  ) {
    final $$AuditLogTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.auditLog,
      getReferencedColumn: (t) => t.familyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AuditLogTableFilterComposer(
            $db: $db,
            $table: $db.auditLog,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> goalsRefs(
    Expression<bool> Function($$GoalsTableFilterComposer f) f,
  ) {
    final $$GoalsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.goals,
      getReferencedColumn: (t) => t.familyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GoalsTableFilterComposer(
            $db: $db,
            $table: $db.goals,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> budgetsRefs(
    Expression<bool> Function($$BudgetsTableFilterComposer f) f,
  ) {
    final $$BudgetsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.budgets,
      getReferencedColumn: (t) => t.familyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BudgetsTableFilterComposer(
            $db: $db,
            $table: $db.budgets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> loanDetailsRefs(
    Expression<bool> Function($$LoanDetailsTableFilterComposer f) f,
  ) {
    final $$LoanDetailsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.loanDetails,
      getReferencedColumn: (t) => t.familyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LoanDetailsTableFilterComposer(
            $db: $db,
            $table: $db.loanDetails,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> investmentHoldingsRefs(
    Expression<bool> Function($$InvestmentHoldingsTableFilterComposer f) f,
  ) {
    final $$InvestmentHoldingsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.investmentHoldings,
      getReferencedColumn: (t) => t.familyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InvestmentHoldingsTableFilterComposer(
            $db: $db,
            $table: $db.investmentHoldings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> lifeProfilesRefs(
    Expression<bool> Function($$LifeProfilesTableFilterComposer f) f,
  ) {
    final $$LifeProfilesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.lifeProfiles,
      getReferencedColumn: (t) => t.familyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LifeProfilesTableFilterComposer(
            $db: $db,
            $table: $db.lifeProfiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> netWorthMilestonesRefs(
    Expression<bool> Function($$NetWorthMilestonesTableFilterComposer f) f,
  ) {
    final $$NetWorthMilestonesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.netWorthMilestones,
      getReferencedColumn: (t) => t.familyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NetWorthMilestonesTableFilterComposer(
            $db: $db,
            $table: $db.netWorthMilestones,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> recurringRulesRefs(
    Expression<bool> Function($$RecurringRulesTableFilterComposer f) f,
  ) {
    final $$RecurringRulesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.recurringRules,
      getReferencedColumn: (t) => t.familyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecurringRulesTableFilterComposer(
            $db: $db,
            $table: $db.recurringRules,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> decisionsRefs(
    Expression<bool> Function($$DecisionsTableFilterComposer f) f,
  ) {
    final $$DecisionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.decisions,
      getReferencedColumn: (t) => t.familyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DecisionsTableFilterComposer(
            $db: $db,
            $table: $db.decisions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> monthlyMetricsRefs(
    Expression<bool> Function($$MonthlyMetricsTableFilterComposer f) f,
  ) {
    final $$MonthlyMetricsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.monthlyMetrics,
      getReferencedColumn: (t) => t.familyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MonthlyMetricsTableFilterComposer(
            $db: $db,
            $table: $db.monthlyMetrics,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> savingsAllocationRulesRefs(
    Expression<bool> Function($$SavingsAllocationRulesTableFilterComposer f) f,
  ) {
    final $$SavingsAllocationRulesTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.savingsAllocationRules,
          getReferencedColumn: (t) => t.familyId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$SavingsAllocationRulesTableFilterComposer(
                $db: $db,
                $table: $db.savingsAllocationRules,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$FamiliesTableOrderingComposer
    extends Composer<_$AppDatabase, $FamiliesTable> {
  $$FamiliesTableOrderingComposer({
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

  ColumnOrderings<String> get baseCurrency => $composableBuilder(
    column: $table.baseCurrency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FamiliesTableAnnotationComposer
    extends Composer<_$AppDatabase, $FamiliesTable> {
  $$FamiliesTableAnnotationComposer({
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

  GeneratedColumn<String> get baseCurrency => $composableBuilder(
    column: $table.baseCurrency,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> usersRefs<T extends Object>(
    Expression<T> Function($$UsersTableAnnotationComposer a) f,
  ) {
    final $$UsersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.familyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableAnnotationComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> accountsRefs<T extends Object>(
    Expression<T> Function($$AccountsTableAnnotationComposer a) f,
  ) {
    final $$AccountsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.familyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableAnnotationComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> categoriesRefs<T extends Object>(
    Expression<T> Function($$CategoriesTableAnnotationComposer a) f,
  ) {
    final $$CategoriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.familyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableAnnotationComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> categoryGroupsRefs<T extends Object>(
    Expression<T> Function($$CategoryGroupsTableAnnotationComposer a) f,
  ) {
    final $$CategoryGroupsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.categoryGroups,
      getReferencedColumn: (t) => t.familyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoryGroupsTableAnnotationComposer(
            $db: $db,
            $table: $db.categoryGroups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> transactionsRefs<T extends Object>(
    Expression<T> Function($$TransactionsTableAnnotationComposer a) f,
  ) {
    final $$TransactionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.familyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionsTableAnnotationComposer(
            $db: $db,
            $table: $db.transactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> balanceSnapshotsRefs<T extends Object>(
    Expression<T> Function($$BalanceSnapshotsTableAnnotationComposer a) f,
  ) {
    final $$BalanceSnapshotsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.balanceSnapshots,
      getReferencedColumn: (t) => t.familyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BalanceSnapshotsTableAnnotationComposer(
            $db: $db,
            $table: $db.balanceSnapshots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> auditLogRefs<T extends Object>(
    Expression<T> Function($$AuditLogTableAnnotationComposer a) f,
  ) {
    final $$AuditLogTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.auditLog,
      getReferencedColumn: (t) => t.familyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AuditLogTableAnnotationComposer(
            $db: $db,
            $table: $db.auditLog,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> goalsRefs<T extends Object>(
    Expression<T> Function($$GoalsTableAnnotationComposer a) f,
  ) {
    final $$GoalsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.goals,
      getReferencedColumn: (t) => t.familyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GoalsTableAnnotationComposer(
            $db: $db,
            $table: $db.goals,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> budgetsRefs<T extends Object>(
    Expression<T> Function($$BudgetsTableAnnotationComposer a) f,
  ) {
    final $$BudgetsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.budgets,
      getReferencedColumn: (t) => t.familyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BudgetsTableAnnotationComposer(
            $db: $db,
            $table: $db.budgets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> loanDetailsRefs<T extends Object>(
    Expression<T> Function($$LoanDetailsTableAnnotationComposer a) f,
  ) {
    final $$LoanDetailsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.loanDetails,
      getReferencedColumn: (t) => t.familyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LoanDetailsTableAnnotationComposer(
            $db: $db,
            $table: $db.loanDetails,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> investmentHoldingsRefs<T extends Object>(
    Expression<T> Function($$InvestmentHoldingsTableAnnotationComposer a) f,
  ) {
    final $$InvestmentHoldingsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.investmentHoldings,
          getReferencedColumn: (t) => t.familyId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$InvestmentHoldingsTableAnnotationComposer(
                $db: $db,
                $table: $db.investmentHoldings,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> lifeProfilesRefs<T extends Object>(
    Expression<T> Function($$LifeProfilesTableAnnotationComposer a) f,
  ) {
    final $$LifeProfilesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.lifeProfiles,
      getReferencedColumn: (t) => t.familyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LifeProfilesTableAnnotationComposer(
            $db: $db,
            $table: $db.lifeProfiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> netWorthMilestonesRefs<T extends Object>(
    Expression<T> Function($$NetWorthMilestonesTableAnnotationComposer a) f,
  ) {
    final $$NetWorthMilestonesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.netWorthMilestones,
          getReferencedColumn: (t) => t.familyId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$NetWorthMilestonesTableAnnotationComposer(
                $db: $db,
                $table: $db.netWorthMilestones,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> recurringRulesRefs<T extends Object>(
    Expression<T> Function($$RecurringRulesTableAnnotationComposer a) f,
  ) {
    final $$RecurringRulesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.recurringRules,
      getReferencedColumn: (t) => t.familyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecurringRulesTableAnnotationComposer(
            $db: $db,
            $table: $db.recurringRules,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> decisionsRefs<T extends Object>(
    Expression<T> Function($$DecisionsTableAnnotationComposer a) f,
  ) {
    final $$DecisionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.decisions,
      getReferencedColumn: (t) => t.familyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DecisionsTableAnnotationComposer(
            $db: $db,
            $table: $db.decisions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> monthlyMetricsRefs<T extends Object>(
    Expression<T> Function($$MonthlyMetricsTableAnnotationComposer a) f,
  ) {
    final $$MonthlyMetricsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.monthlyMetrics,
      getReferencedColumn: (t) => t.familyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MonthlyMetricsTableAnnotationComposer(
            $db: $db,
            $table: $db.monthlyMetrics,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> savingsAllocationRulesRefs<T extends Object>(
    Expression<T> Function($$SavingsAllocationRulesTableAnnotationComposer a) f,
  ) {
    final $$SavingsAllocationRulesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.savingsAllocationRules,
          getReferencedColumn: (t) => t.familyId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$SavingsAllocationRulesTableAnnotationComposer(
                $db: $db,
                $table: $db.savingsAllocationRules,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$FamiliesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FamiliesTable,
          Family,
          $$FamiliesTableFilterComposer,
          $$FamiliesTableOrderingComposer,
          $$FamiliesTableAnnotationComposer,
          $$FamiliesTableCreateCompanionBuilder,
          $$FamiliesTableUpdateCompanionBuilder,
          (Family, $$FamiliesTableReferences),
          Family,
          PrefetchHooks Function({
            bool usersRefs,
            bool accountsRefs,
            bool categoriesRefs,
            bool categoryGroupsRefs,
            bool transactionsRefs,
            bool balanceSnapshotsRefs,
            bool auditLogRefs,
            bool goalsRefs,
            bool budgetsRefs,
            bool loanDetailsRefs,
            bool investmentHoldingsRefs,
            bool lifeProfilesRefs,
            bool netWorthMilestonesRefs,
            bool recurringRulesRefs,
            bool decisionsRefs,
            bool monthlyMetricsRefs,
            bool savingsAllocationRulesRefs,
          })
        > {
  $$FamiliesTableTableManager(_$AppDatabase db, $FamiliesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FamiliesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FamiliesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FamiliesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> baseCurrency = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FamiliesCompanion(
                id: id,
                name: name,
                baseCurrency: baseCurrency,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String> baseCurrency = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => FamiliesCompanion.insert(
                id: id,
                name: name,
                baseCurrency: baseCurrency,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$FamiliesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                usersRefs = false,
                accountsRefs = false,
                categoriesRefs = false,
                categoryGroupsRefs = false,
                transactionsRefs = false,
                balanceSnapshotsRefs = false,
                auditLogRefs = false,
                goalsRefs = false,
                budgetsRefs = false,
                loanDetailsRefs = false,
                investmentHoldingsRefs = false,
                lifeProfilesRefs = false,
                netWorthMilestonesRefs = false,
                recurringRulesRefs = false,
                decisionsRefs = false,
                monthlyMetricsRefs = false,
                savingsAllocationRulesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (usersRefs) db.users,
                    if (accountsRefs) db.accounts,
                    if (categoriesRefs) db.categories,
                    if (categoryGroupsRefs) db.categoryGroups,
                    if (transactionsRefs) db.transactions,
                    if (balanceSnapshotsRefs) db.balanceSnapshots,
                    if (auditLogRefs) db.auditLog,
                    if (goalsRefs) db.goals,
                    if (budgetsRefs) db.budgets,
                    if (loanDetailsRefs) db.loanDetails,
                    if (investmentHoldingsRefs) db.investmentHoldings,
                    if (lifeProfilesRefs) db.lifeProfiles,
                    if (netWorthMilestonesRefs) db.netWorthMilestones,
                    if (recurringRulesRefs) db.recurringRules,
                    if (decisionsRefs) db.decisions,
                    if (monthlyMetricsRefs) db.monthlyMetrics,
                    if (savingsAllocationRulesRefs) db.savingsAllocationRules,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (usersRefs)
                        await $_getPrefetchedData<Family, $FamiliesTable, User>(
                          currentTable: table,
                          referencedTable: $$FamiliesTableReferences
                              ._usersRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$FamiliesTableReferences(
                                db,
                                table,
                                p0,
                              ).usersRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.familyId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (accountsRefs)
                        await $_getPrefetchedData<
                          Family,
                          $FamiliesTable,
                          Account
                        >(
                          currentTable: table,
                          referencedTable: $$FamiliesTableReferences
                              ._accountsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$FamiliesTableReferences(
                                db,
                                table,
                                p0,
                              ).accountsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.familyId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (categoriesRefs)
                        await $_getPrefetchedData<
                          Family,
                          $FamiliesTable,
                          Category
                        >(
                          currentTable: table,
                          referencedTable: $$FamiliesTableReferences
                              ._categoriesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$FamiliesTableReferences(
                                db,
                                table,
                                p0,
                              ).categoriesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.familyId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (categoryGroupsRefs)
                        await $_getPrefetchedData<
                          Family,
                          $FamiliesTable,
                          CategoryGroup
                        >(
                          currentTable: table,
                          referencedTable: $$FamiliesTableReferences
                              ._categoryGroupsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$FamiliesTableReferences(
                                db,
                                table,
                                p0,
                              ).categoryGroupsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.familyId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (transactionsRefs)
                        await $_getPrefetchedData<
                          Family,
                          $FamiliesTable,
                          Transaction
                        >(
                          currentTable: table,
                          referencedTable: $$FamiliesTableReferences
                              ._transactionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$FamiliesTableReferences(
                                db,
                                table,
                                p0,
                              ).transactionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.familyId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (balanceSnapshotsRefs)
                        await $_getPrefetchedData<
                          Family,
                          $FamiliesTable,
                          BalanceSnapshot
                        >(
                          currentTable: table,
                          referencedTable: $$FamiliesTableReferences
                              ._balanceSnapshotsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$FamiliesTableReferences(
                                db,
                                table,
                                p0,
                              ).balanceSnapshotsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.familyId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (auditLogRefs)
                        await $_getPrefetchedData<
                          Family,
                          $FamiliesTable,
                          AuditLogData
                        >(
                          currentTable: table,
                          referencedTable: $$FamiliesTableReferences
                              ._auditLogRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$FamiliesTableReferences(
                                db,
                                table,
                                p0,
                              ).auditLogRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.familyId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (goalsRefs)
                        await $_getPrefetchedData<Family, $FamiliesTable, Goal>(
                          currentTable: table,
                          referencedTable: $$FamiliesTableReferences
                              ._goalsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$FamiliesTableReferences(
                                db,
                                table,
                                p0,
                              ).goalsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.familyId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (budgetsRefs)
                        await $_getPrefetchedData<
                          Family,
                          $FamiliesTable,
                          Budget
                        >(
                          currentTable: table,
                          referencedTable: $$FamiliesTableReferences
                              ._budgetsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$FamiliesTableReferences(
                                db,
                                table,
                                p0,
                              ).budgetsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.familyId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (loanDetailsRefs)
                        await $_getPrefetchedData<
                          Family,
                          $FamiliesTable,
                          LoanDetail
                        >(
                          currentTable: table,
                          referencedTable: $$FamiliesTableReferences
                              ._loanDetailsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$FamiliesTableReferences(
                                db,
                                table,
                                p0,
                              ).loanDetailsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.familyId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (investmentHoldingsRefs)
                        await $_getPrefetchedData<
                          Family,
                          $FamiliesTable,
                          InvestmentHolding
                        >(
                          currentTable: table,
                          referencedTable: $$FamiliesTableReferences
                              ._investmentHoldingsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$FamiliesTableReferences(
                                db,
                                table,
                                p0,
                              ).investmentHoldingsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.familyId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (lifeProfilesRefs)
                        await $_getPrefetchedData<
                          Family,
                          $FamiliesTable,
                          LifeProfile
                        >(
                          currentTable: table,
                          referencedTable: $$FamiliesTableReferences
                              ._lifeProfilesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$FamiliesTableReferences(
                                db,
                                table,
                                p0,
                              ).lifeProfilesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.familyId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (netWorthMilestonesRefs)
                        await $_getPrefetchedData<
                          Family,
                          $FamiliesTable,
                          NetWorthMilestone
                        >(
                          currentTable: table,
                          referencedTable: $$FamiliesTableReferences
                              ._netWorthMilestonesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$FamiliesTableReferences(
                                db,
                                table,
                                p0,
                              ).netWorthMilestonesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.familyId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (recurringRulesRefs)
                        await $_getPrefetchedData<
                          Family,
                          $FamiliesTable,
                          RecurringRule
                        >(
                          currentTable: table,
                          referencedTable: $$FamiliesTableReferences
                              ._recurringRulesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$FamiliesTableReferences(
                                db,
                                table,
                                p0,
                              ).recurringRulesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.familyId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (decisionsRefs)
                        await $_getPrefetchedData<
                          Family,
                          $FamiliesTable,
                          Decision
                        >(
                          currentTable: table,
                          referencedTable: $$FamiliesTableReferences
                              ._decisionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$FamiliesTableReferences(
                                db,
                                table,
                                p0,
                              ).decisionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.familyId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (monthlyMetricsRefs)
                        await $_getPrefetchedData<
                          Family,
                          $FamiliesTable,
                          MonthlyMetric
                        >(
                          currentTable: table,
                          referencedTable: $$FamiliesTableReferences
                              ._monthlyMetricsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$FamiliesTableReferences(
                                db,
                                table,
                                p0,
                              ).monthlyMetricsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.familyId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (savingsAllocationRulesRefs)
                        await $_getPrefetchedData<
                          Family,
                          $FamiliesTable,
                          SavingsAllocationRule
                        >(
                          currentTable: table,
                          referencedTable: $$FamiliesTableReferences
                              ._savingsAllocationRulesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$FamiliesTableReferences(
                                db,
                                table,
                                p0,
                              ).savingsAllocationRulesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.familyId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$FamiliesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FamiliesTable,
      Family,
      $$FamiliesTableFilterComposer,
      $$FamiliesTableOrderingComposer,
      $$FamiliesTableAnnotationComposer,
      $$FamiliesTableCreateCompanionBuilder,
      $$FamiliesTableUpdateCompanionBuilder,
      (Family, $$FamiliesTableReferences),
      Family,
      PrefetchHooks Function({
        bool usersRefs,
        bool accountsRefs,
        bool categoriesRefs,
        bool categoryGroupsRefs,
        bool transactionsRefs,
        bool balanceSnapshotsRefs,
        bool auditLogRefs,
        bool goalsRefs,
        bool budgetsRefs,
        bool loanDetailsRefs,
        bool investmentHoldingsRefs,
        bool lifeProfilesRefs,
        bool netWorthMilestonesRefs,
        bool recurringRulesRefs,
        bool decisionsRefs,
        bool monthlyMetricsRefs,
        bool savingsAllocationRulesRefs,
      })
    >;
typedef $$UsersTableCreateCompanionBuilder =
    UsersCompanion Function({
      required String id,
      required String email,
      required String displayName,
      Value<String?> avatarUrl,
      required String role,
      required String familyId,
      Value<int> rowid,
    });
typedef $$UsersTableUpdateCompanionBuilder =
    UsersCompanion Function({
      Value<String> id,
      Value<String> email,
      Value<String> displayName,
      Value<String?> avatarUrl,
      Value<String> role,
      Value<String> familyId,
      Value<int> rowid,
    });

final class $$UsersTableReferences
    extends BaseReferences<_$AppDatabase, $UsersTable, User> {
  $$UsersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $FamiliesTable _familyIdTable(_$AppDatabase db) => db.families
      .createAlias($_aliasNameGenerator(db.users.familyId, db.families.id));

  $$FamiliesTableProcessedTableManager get familyId {
    final $_column = $_itemColumn<String>('family_id')!;

    final manager = $$FamiliesTableTableManager(
      $_db,
      $_db.families,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_familyIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$AccountsTable, List<Account>> _accountsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.accounts,
    aliasName: $_aliasNameGenerator(db.users.id, db.accounts.userId),
  );

  $$AccountsTableProcessedTableManager get accountsRefs {
    final manager = $$AccountsTableTableManager(
      $_db,
      $_db.accounts,
    ).filter((f) => f.userId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_accountsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$UsersTableFilterComposer extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableFilterComposer({
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

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get avatarUrl => $composableBuilder(
    column: $table.avatarUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  $$FamiliesTableFilterComposer get familyId {
    final $$FamiliesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.familyId,
      referencedTable: $db.families,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FamiliesTableFilterComposer(
            $db: $db,
            $table: $db.families,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> accountsRefs(
    Expression<bool> Function($$AccountsTableFilterComposer f) f,
  ) {
    final $$AccountsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.userId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableFilterComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$UsersTableOrderingComposer
    extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableOrderingComposer({
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

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get avatarUrl => $composableBuilder(
    column: $table.avatarUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  $$FamiliesTableOrderingComposer get familyId {
    final $$FamiliesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.familyId,
      referencedTable: $db.families,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FamiliesTableOrderingComposer(
            $db: $db,
            $table: $db.families,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$UsersTableAnnotationComposer
    extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get avatarUrl =>
      $composableBuilder(column: $table.avatarUrl, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  $$FamiliesTableAnnotationComposer get familyId {
    final $$FamiliesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.familyId,
      referencedTable: $db.families,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FamiliesTableAnnotationComposer(
            $db: $db,
            $table: $db.families,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> accountsRefs<T extends Object>(
    Expression<T> Function($$AccountsTableAnnotationComposer a) f,
  ) {
    final $$AccountsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.userId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableAnnotationComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$UsersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UsersTable,
          User,
          $$UsersTableFilterComposer,
          $$UsersTableOrderingComposer,
          $$UsersTableAnnotationComposer,
          $$UsersTableCreateCompanionBuilder,
          $$UsersTableUpdateCompanionBuilder,
          (User, $$UsersTableReferences),
          User,
          PrefetchHooks Function({bool familyId, bool accountsRefs})
        > {
  $$UsersTableTableManager(_$AppDatabase db, $UsersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UsersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UsersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UsersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> email = const Value.absent(),
                Value<String> displayName = const Value.absent(),
                Value<String?> avatarUrl = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<String> familyId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UsersCompanion(
                id: id,
                email: email,
                displayName: displayName,
                avatarUrl: avatarUrl,
                role: role,
                familyId: familyId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String email,
                required String displayName,
                Value<String?> avatarUrl = const Value.absent(),
                required String role,
                required String familyId,
                Value<int> rowid = const Value.absent(),
              }) => UsersCompanion.insert(
                id: id,
                email: email,
                displayName: displayName,
                avatarUrl: avatarUrl,
                role: role,
                familyId: familyId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$UsersTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({familyId = false, accountsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (accountsRefs) db.accounts],
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
                    if (familyId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.familyId,
                                referencedTable: $$UsersTableReferences
                                    ._familyIdTable(db),
                                referencedColumn: $$UsersTableReferences
                                    ._familyIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (accountsRefs)
                    await $_getPrefetchedData<User, $UsersTable, Account>(
                      currentTable: table,
                      referencedTable: $$UsersTableReferences
                          ._accountsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$UsersTableReferences(db, table, p0).accountsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.userId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$UsersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UsersTable,
      User,
      $$UsersTableFilterComposer,
      $$UsersTableOrderingComposer,
      $$UsersTableAnnotationComposer,
      $$UsersTableCreateCompanionBuilder,
      $$UsersTableUpdateCompanionBuilder,
      (User, $$UsersTableReferences),
      User,
      PrefetchHooks Function({bool familyId, bool accountsRefs})
    >;
typedef $$AccountsTableCreateCompanionBuilder =
    AccountsCompanion Function({
      required String id,
      required String name,
      required String type,
      Value<String?> institution,
      required int balance,
      Value<String> currency,
      required String visibility,
      Value<bool> sharedWithFamily,
      required String familyId,
      required String userId,
      Value<DateTime?> deletedAt,
      Value<String?> liquidityTier,
      Value<bool> isEmergencyFund,
      Value<bool> isOpportunityFund,
      Value<int?> opportunityFundTargetPaise,
      Value<int?> minimumBalancePaise,
      Value<int> rowid,
    });
typedef $$AccountsTableUpdateCompanionBuilder =
    AccountsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> type,
      Value<String?> institution,
      Value<int> balance,
      Value<String> currency,
      Value<String> visibility,
      Value<bool> sharedWithFamily,
      Value<String> familyId,
      Value<String> userId,
      Value<DateTime?> deletedAt,
      Value<String?> liquidityTier,
      Value<bool> isEmergencyFund,
      Value<bool> isOpportunityFund,
      Value<int?> opportunityFundTargetPaise,
      Value<int?> minimumBalancePaise,
      Value<int> rowid,
    });

final class $$AccountsTableReferences
    extends BaseReferences<_$AppDatabase, $AccountsTable, Account> {
  $$AccountsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $FamiliesTable _familyIdTable(_$AppDatabase db) => db.families
      .createAlias($_aliasNameGenerator(db.accounts.familyId, db.families.id));

  $$FamiliesTableProcessedTableManager get familyId {
    final $_column = $_itemColumn<String>('family_id')!;

    final manager = $$FamiliesTableTableManager(
      $_db,
      $_db.families,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_familyIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $UsersTable _userIdTable(_$AppDatabase db) => db.users.createAlias(
    $_aliasNameGenerator(db.accounts.userId, db.users.id),
  );

  $$UsersTableProcessedTableManager get userId {
    final $_column = $_itemColumn<String>('user_id')!;

    final manager = $$UsersTableTableManager(
      $_db,
      $_db.users,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_userIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$BalanceSnapshotsTable, List<BalanceSnapshot>>
  _balanceSnapshotsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.balanceSnapshots,
    aliasName: $_aliasNameGenerator(
      db.accounts.id,
      db.balanceSnapshots.accountId,
    ),
  );

  $$BalanceSnapshotsTableProcessedTableManager get balanceSnapshotsRefs {
    final manager = $$BalanceSnapshotsTableTableManager(
      $_db,
      $_db.balanceSnapshots,
    ).filter((f) => f.accountId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _balanceSnapshotsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$GoalsTable, List<Goal>> _goalsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.goals,
    aliasName: $_aliasNameGenerator(db.accounts.id, db.goals.linkedAccountId),
  );

  $$GoalsTableProcessedTableManager get goalsRefs {
    final manager = $$GoalsTableTableManager($_db, $_db.goals).filter(
      (f) => f.linkedAccountId.id.sqlEquals($_itemColumn<String>('id')!),
    );

    final cache = $_typedResult.readTableOrNull(_goalsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$LoanDetailsTable, List<LoanDetail>>
  _loanDetailsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.loanDetails,
    aliasName: $_aliasNameGenerator(db.accounts.id, db.loanDetails.accountId),
  );

  $$LoanDetailsTableProcessedTableManager get loanDetailsRefs {
    final manager = $$LoanDetailsTableTableManager(
      $_db,
      $_db.loanDetails,
    ).filter((f) => f.accountId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_loanDetailsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$InvestmentHoldingsTable, List<InvestmentHolding>>
  _investmentHoldingsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.investmentHoldings,
        aliasName: $_aliasNameGenerator(
          db.accounts.id,
          db.investmentHoldings.linkedAccountId,
        ),
      );

  $$InvestmentHoldingsTableProcessedTableManager get investmentHoldingsRefs {
    final manager =
        $$InvestmentHoldingsTableTableManager(
          $_db,
          $_db.investmentHoldings,
        ).filter(
          (f) => f.linkedAccountId.id.sqlEquals($_itemColumn<String>('id')!),
        );

    final cache = $_typedResult.readTableOrNull(
      _investmentHoldingsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$AccountsTableFilterComposer
    extends Composer<_$AppDatabase, $AccountsTable> {
  $$AccountsTableFilterComposer({
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

  ColumnFilters<String> get institution => $composableBuilder(
    column: $table.institution,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get balance => $composableBuilder(
    column: $table.balance,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get visibility => $composableBuilder(
    column: $table.visibility,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get sharedWithFamily => $composableBuilder(
    column: $table.sharedWithFamily,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get liquidityTier => $composableBuilder(
    column: $table.liquidityTier,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isEmergencyFund => $composableBuilder(
    column: $table.isEmergencyFund,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isOpportunityFund => $composableBuilder(
    column: $table.isOpportunityFund,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get opportunityFundTargetPaise => $composableBuilder(
    column: $table.opportunityFundTargetPaise,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get minimumBalancePaise => $composableBuilder(
    column: $table.minimumBalancePaise,
    builder: (column) => ColumnFilters(column),
  );

  $$FamiliesTableFilterComposer get familyId {
    final $$FamiliesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.familyId,
      referencedTable: $db.families,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FamiliesTableFilterComposer(
            $db: $db,
            $table: $db.families,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$UsersTableFilterComposer get userId {
    final $$UsersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableFilterComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> balanceSnapshotsRefs(
    Expression<bool> Function($$BalanceSnapshotsTableFilterComposer f) f,
  ) {
    final $$BalanceSnapshotsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.balanceSnapshots,
      getReferencedColumn: (t) => t.accountId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BalanceSnapshotsTableFilterComposer(
            $db: $db,
            $table: $db.balanceSnapshots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> goalsRefs(
    Expression<bool> Function($$GoalsTableFilterComposer f) f,
  ) {
    final $$GoalsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.goals,
      getReferencedColumn: (t) => t.linkedAccountId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GoalsTableFilterComposer(
            $db: $db,
            $table: $db.goals,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> loanDetailsRefs(
    Expression<bool> Function($$LoanDetailsTableFilterComposer f) f,
  ) {
    final $$LoanDetailsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.loanDetails,
      getReferencedColumn: (t) => t.accountId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LoanDetailsTableFilterComposer(
            $db: $db,
            $table: $db.loanDetails,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> investmentHoldingsRefs(
    Expression<bool> Function($$InvestmentHoldingsTableFilterComposer f) f,
  ) {
    final $$InvestmentHoldingsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.investmentHoldings,
      getReferencedColumn: (t) => t.linkedAccountId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InvestmentHoldingsTableFilterComposer(
            $db: $db,
            $table: $db.investmentHoldings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AccountsTableOrderingComposer
    extends Composer<_$AppDatabase, $AccountsTable> {
  $$AccountsTableOrderingComposer({
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

  ColumnOrderings<String> get institution => $composableBuilder(
    column: $table.institution,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get balance => $composableBuilder(
    column: $table.balance,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get visibility => $composableBuilder(
    column: $table.visibility,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get sharedWithFamily => $composableBuilder(
    column: $table.sharedWithFamily,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get liquidityTier => $composableBuilder(
    column: $table.liquidityTier,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isEmergencyFund => $composableBuilder(
    column: $table.isEmergencyFund,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isOpportunityFund => $composableBuilder(
    column: $table.isOpportunityFund,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get opportunityFundTargetPaise => $composableBuilder(
    column: $table.opportunityFundTargetPaise,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get minimumBalancePaise => $composableBuilder(
    column: $table.minimumBalancePaise,
    builder: (column) => ColumnOrderings(column),
  );

  $$FamiliesTableOrderingComposer get familyId {
    final $$FamiliesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.familyId,
      referencedTable: $db.families,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FamiliesTableOrderingComposer(
            $db: $db,
            $table: $db.families,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$UsersTableOrderingComposer get userId {
    final $$UsersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableOrderingComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AccountsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AccountsTable> {
  $$AccountsTableAnnotationComposer({
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

  GeneratedColumn<String> get institution => $composableBuilder(
    column: $table.institution,
    builder: (column) => column,
  );

  GeneratedColumn<int> get balance =>
      $composableBuilder(column: $table.balance, builder: (column) => column);

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<String> get visibility => $composableBuilder(
    column: $table.visibility,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get sharedWithFamily => $composableBuilder(
    column: $table.sharedWithFamily,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get liquidityTier => $composableBuilder(
    column: $table.liquidityTier,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isEmergencyFund => $composableBuilder(
    column: $table.isEmergencyFund,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isOpportunityFund => $composableBuilder(
    column: $table.isOpportunityFund,
    builder: (column) => column,
  );

  GeneratedColumn<int> get opportunityFundTargetPaise => $composableBuilder(
    column: $table.opportunityFundTargetPaise,
    builder: (column) => column,
  );

  GeneratedColumn<int> get minimumBalancePaise => $composableBuilder(
    column: $table.minimumBalancePaise,
    builder: (column) => column,
  );

  $$FamiliesTableAnnotationComposer get familyId {
    final $$FamiliesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.familyId,
      referencedTable: $db.families,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FamiliesTableAnnotationComposer(
            $db: $db,
            $table: $db.families,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$UsersTableAnnotationComposer get userId {
    final $$UsersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableAnnotationComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> balanceSnapshotsRefs<T extends Object>(
    Expression<T> Function($$BalanceSnapshotsTableAnnotationComposer a) f,
  ) {
    final $$BalanceSnapshotsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.balanceSnapshots,
      getReferencedColumn: (t) => t.accountId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BalanceSnapshotsTableAnnotationComposer(
            $db: $db,
            $table: $db.balanceSnapshots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> goalsRefs<T extends Object>(
    Expression<T> Function($$GoalsTableAnnotationComposer a) f,
  ) {
    final $$GoalsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.goals,
      getReferencedColumn: (t) => t.linkedAccountId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GoalsTableAnnotationComposer(
            $db: $db,
            $table: $db.goals,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> loanDetailsRefs<T extends Object>(
    Expression<T> Function($$LoanDetailsTableAnnotationComposer a) f,
  ) {
    final $$LoanDetailsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.loanDetails,
      getReferencedColumn: (t) => t.accountId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LoanDetailsTableAnnotationComposer(
            $db: $db,
            $table: $db.loanDetails,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> investmentHoldingsRefs<T extends Object>(
    Expression<T> Function($$InvestmentHoldingsTableAnnotationComposer a) f,
  ) {
    final $$InvestmentHoldingsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.investmentHoldings,
          getReferencedColumn: (t) => t.linkedAccountId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$InvestmentHoldingsTableAnnotationComposer(
                $db: $db,
                $table: $db.investmentHoldings,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$AccountsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AccountsTable,
          Account,
          $$AccountsTableFilterComposer,
          $$AccountsTableOrderingComposer,
          $$AccountsTableAnnotationComposer,
          $$AccountsTableCreateCompanionBuilder,
          $$AccountsTableUpdateCompanionBuilder,
          (Account, $$AccountsTableReferences),
          Account,
          PrefetchHooks Function({
            bool familyId,
            bool userId,
            bool balanceSnapshotsRefs,
            bool goalsRefs,
            bool loanDetailsRefs,
            bool investmentHoldingsRefs,
          })
        > {
  $$AccountsTableTableManager(_$AppDatabase db, $AccountsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AccountsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AccountsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AccountsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String?> institution = const Value.absent(),
                Value<int> balance = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<String> visibility = const Value.absent(),
                Value<bool> sharedWithFamily = const Value.absent(),
                Value<String> familyId = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String?> liquidityTier = const Value.absent(),
                Value<bool> isEmergencyFund = const Value.absent(),
                Value<bool> isOpportunityFund = const Value.absent(),
                Value<int?> opportunityFundTargetPaise = const Value.absent(),
                Value<int?> minimumBalancePaise = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AccountsCompanion(
                id: id,
                name: name,
                type: type,
                institution: institution,
                balance: balance,
                currency: currency,
                visibility: visibility,
                sharedWithFamily: sharedWithFamily,
                familyId: familyId,
                userId: userId,
                deletedAt: deletedAt,
                liquidityTier: liquidityTier,
                isEmergencyFund: isEmergencyFund,
                isOpportunityFund: isOpportunityFund,
                opportunityFundTargetPaise: opportunityFundTargetPaise,
                minimumBalancePaise: minimumBalancePaise,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String type,
                Value<String?> institution = const Value.absent(),
                required int balance,
                Value<String> currency = const Value.absent(),
                required String visibility,
                Value<bool> sharedWithFamily = const Value.absent(),
                required String familyId,
                required String userId,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String?> liquidityTier = const Value.absent(),
                Value<bool> isEmergencyFund = const Value.absent(),
                Value<bool> isOpportunityFund = const Value.absent(),
                Value<int?> opportunityFundTargetPaise = const Value.absent(),
                Value<int?> minimumBalancePaise = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AccountsCompanion.insert(
                id: id,
                name: name,
                type: type,
                institution: institution,
                balance: balance,
                currency: currency,
                visibility: visibility,
                sharedWithFamily: sharedWithFamily,
                familyId: familyId,
                userId: userId,
                deletedAt: deletedAt,
                liquidityTier: liquidityTier,
                isEmergencyFund: isEmergencyFund,
                isOpportunityFund: isOpportunityFund,
                opportunityFundTargetPaise: opportunityFundTargetPaise,
                minimumBalancePaise: minimumBalancePaise,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$AccountsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                familyId = false,
                userId = false,
                balanceSnapshotsRefs = false,
                goalsRefs = false,
                loanDetailsRefs = false,
                investmentHoldingsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (balanceSnapshotsRefs) db.balanceSnapshots,
                    if (goalsRefs) db.goals,
                    if (loanDetailsRefs) db.loanDetails,
                    if (investmentHoldingsRefs) db.investmentHoldings,
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
                        if (familyId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.familyId,
                                    referencedTable: $$AccountsTableReferences
                                        ._familyIdTable(db),
                                    referencedColumn: $$AccountsTableReferences
                                        ._familyIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }
                        if (userId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.userId,
                                    referencedTable: $$AccountsTableReferences
                                        ._userIdTable(db),
                                    referencedColumn: $$AccountsTableReferences
                                        ._userIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (balanceSnapshotsRefs)
                        await $_getPrefetchedData<
                          Account,
                          $AccountsTable,
                          BalanceSnapshot
                        >(
                          currentTable: table,
                          referencedTable: $$AccountsTableReferences
                              ._balanceSnapshotsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$AccountsTableReferences(
                                db,
                                table,
                                p0,
                              ).balanceSnapshotsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.accountId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (goalsRefs)
                        await $_getPrefetchedData<
                          Account,
                          $AccountsTable,
                          Goal
                        >(
                          currentTable: table,
                          referencedTable: $$AccountsTableReferences
                              ._goalsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$AccountsTableReferences(
                                db,
                                table,
                                p0,
                              ).goalsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.linkedAccountId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (loanDetailsRefs)
                        await $_getPrefetchedData<
                          Account,
                          $AccountsTable,
                          LoanDetail
                        >(
                          currentTable: table,
                          referencedTable: $$AccountsTableReferences
                              ._loanDetailsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$AccountsTableReferences(
                                db,
                                table,
                                p0,
                              ).loanDetailsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.accountId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (investmentHoldingsRefs)
                        await $_getPrefetchedData<
                          Account,
                          $AccountsTable,
                          InvestmentHolding
                        >(
                          currentTable: table,
                          referencedTable: $$AccountsTableReferences
                              ._investmentHoldingsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$AccountsTableReferences(
                                db,
                                table,
                                p0,
                              ).investmentHoldingsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.linkedAccountId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$AccountsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AccountsTable,
      Account,
      $$AccountsTableFilterComposer,
      $$AccountsTableOrderingComposer,
      $$AccountsTableAnnotationComposer,
      $$AccountsTableCreateCompanionBuilder,
      $$AccountsTableUpdateCompanionBuilder,
      (Account, $$AccountsTableReferences),
      Account,
      PrefetchHooks Function({
        bool familyId,
        bool userId,
        bool balanceSnapshotsRefs,
        bool goalsRefs,
        bool loanDetailsRefs,
        bool investmentHoldingsRefs,
      })
    >;
typedef $$CategoriesTableCreateCompanionBuilder =
    CategoriesCompanion Function({
      required String id,
      required String name,
      required String groupName,
      required String type,
      Value<String?> icon,
      required String familyId,
      Value<int> rowid,
    });
typedef $$CategoriesTableUpdateCompanionBuilder =
    CategoriesCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> groupName,
      Value<String> type,
      Value<String?> icon,
      Value<String> familyId,
      Value<int> rowid,
    });

final class $$CategoriesTableReferences
    extends BaseReferences<_$AppDatabase, $CategoriesTable, Category> {
  $$CategoriesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $FamiliesTable _familyIdTable(_$AppDatabase db) =>
      db.families.createAlias(
        $_aliasNameGenerator(db.categories.familyId, db.families.id),
      );

  $$FamiliesTableProcessedTableManager get familyId {
    final $_column = $_itemColumn<String>('family_id')!;

    final manager = $$FamiliesTableTableManager(
      $_db,
      $_db.families,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_familyIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$TransactionsTable, List<Transaction>>
  _transactionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.transactions,
    aliasName: $_aliasNameGenerator(
      db.categories.id,
      db.transactions.categoryId,
    ),
  );

  $$TransactionsTableProcessedTableManager get transactionsRefs {
    final manager = $$TransactionsTableTableManager(
      $_db,
      $_db.transactions,
    ).filter((f) => f.categoryId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_transactionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$RecurringRulesTable, List<RecurringRule>>
  _recurringRulesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.recurringRules,
    aliasName: $_aliasNameGenerator(
      db.categories.id,
      db.recurringRules.categoryId,
    ),
  );

  $$RecurringRulesTableProcessedTableManager get recurringRulesRefs {
    final manager = $$RecurringRulesTableTableManager(
      $_db,
      $_db.recurringRules,
    ).filter((f) => f.categoryId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_recurringRulesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableFilterComposer({
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

  ColumnFilters<String> get groupName => $composableBuilder(
    column: $table.groupName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnFilters(column),
  );

  $$FamiliesTableFilterComposer get familyId {
    final $$FamiliesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.familyId,
      referencedTable: $db.families,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FamiliesTableFilterComposer(
            $db: $db,
            $table: $db.families,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> transactionsRefs(
    Expression<bool> Function($$TransactionsTableFilterComposer f) f,
  ) {
    final $$TransactionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionsTableFilterComposer(
            $db: $db,
            $table: $db.transactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> recurringRulesRefs(
    Expression<bool> Function($$RecurringRulesTableFilterComposer f) f,
  ) {
    final $$RecurringRulesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.recurringRules,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecurringRulesTableFilterComposer(
            $db: $db,
            $table: $db.recurringRules,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableOrderingComposer({
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

  ColumnOrderings<String> get groupName => $composableBuilder(
    column: $table.groupName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnOrderings(column),
  );

  $$FamiliesTableOrderingComposer get familyId {
    final $$FamiliesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.familyId,
      referencedTable: $db.families,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FamiliesTableOrderingComposer(
            $db: $db,
            $table: $db.families,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableAnnotationComposer({
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

  GeneratedColumn<String> get groupName =>
      $composableBuilder(column: $table.groupName, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);

  $$FamiliesTableAnnotationComposer get familyId {
    final $$FamiliesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.familyId,
      referencedTable: $db.families,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FamiliesTableAnnotationComposer(
            $db: $db,
            $table: $db.families,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> transactionsRefs<T extends Object>(
    Expression<T> Function($$TransactionsTableAnnotationComposer a) f,
  ) {
    final $$TransactionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionsTableAnnotationComposer(
            $db: $db,
            $table: $db.transactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> recurringRulesRefs<T extends Object>(
    Expression<T> Function($$RecurringRulesTableAnnotationComposer a) f,
  ) {
    final $$RecurringRulesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.recurringRules,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecurringRulesTableAnnotationComposer(
            $db: $db,
            $table: $db.recurringRules,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CategoriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CategoriesTable,
          Category,
          $$CategoriesTableFilterComposer,
          $$CategoriesTableOrderingComposer,
          $$CategoriesTableAnnotationComposer,
          $$CategoriesTableCreateCompanionBuilder,
          $$CategoriesTableUpdateCompanionBuilder,
          (Category, $$CategoriesTableReferences),
          Category,
          PrefetchHooks Function({
            bool familyId,
            bool transactionsRefs,
            bool recurringRulesRefs,
          })
        > {
  $$CategoriesTableTableManager(_$AppDatabase db, $CategoriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> groupName = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String?> icon = const Value.absent(),
                Value<String> familyId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CategoriesCompanion(
                id: id,
                name: name,
                groupName: groupName,
                type: type,
                icon: icon,
                familyId: familyId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String groupName,
                required String type,
                Value<String?> icon = const Value.absent(),
                required String familyId,
                Value<int> rowid = const Value.absent(),
              }) => CategoriesCompanion.insert(
                id: id,
                name: name,
                groupName: groupName,
                type: type,
                icon: icon,
                familyId: familyId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CategoriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                familyId = false,
                transactionsRefs = false,
                recurringRulesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (transactionsRefs) db.transactions,
                    if (recurringRulesRefs) db.recurringRules,
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
                        if (familyId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.familyId,
                                    referencedTable: $$CategoriesTableReferences
                                        ._familyIdTable(db),
                                    referencedColumn:
                                        $$CategoriesTableReferences
                                            ._familyIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (transactionsRefs)
                        await $_getPrefetchedData<
                          Category,
                          $CategoriesTable,
                          Transaction
                        >(
                          currentTable: table,
                          referencedTable: $$CategoriesTableReferences
                              ._transactionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CategoriesTableReferences(
                                db,
                                table,
                                p0,
                              ).transactionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.categoryId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (recurringRulesRefs)
                        await $_getPrefetchedData<
                          Category,
                          $CategoriesTable,
                          RecurringRule
                        >(
                          currentTable: table,
                          referencedTable: $$CategoriesTableReferences
                              ._recurringRulesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CategoriesTableReferences(
                                db,
                                table,
                                p0,
                              ).recurringRulesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.categoryId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$CategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CategoriesTable,
      Category,
      $$CategoriesTableFilterComposer,
      $$CategoriesTableOrderingComposer,
      $$CategoriesTableAnnotationComposer,
      $$CategoriesTableCreateCompanionBuilder,
      $$CategoriesTableUpdateCompanionBuilder,
      (Category, $$CategoriesTableReferences),
      Category,
      PrefetchHooks Function({
        bool familyId,
        bool transactionsRefs,
        bool recurringRulesRefs,
      })
    >;
typedef $$CategoryGroupsTableCreateCompanionBuilder =
    CategoryGroupsCompanion Function({
      required String id,
      required String name,
      Value<int> displayOrder,
      required String familyId,
      Value<int> rowid,
    });
typedef $$CategoryGroupsTableUpdateCompanionBuilder =
    CategoryGroupsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<int> displayOrder,
      Value<String> familyId,
      Value<int> rowid,
    });

final class $$CategoryGroupsTableReferences
    extends BaseReferences<_$AppDatabase, $CategoryGroupsTable, CategoryGroup> {
  $$CategoryGroupsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $FamiliesTable _familyIdTable(_$AppDatabase db) =>
      db.families.createAlias(
        $_aliasNameGenerator(db.categoryGroups.familyId, db.families.id),
      );

  $$FamiliesTableProcessedTableManager get familyId {
    final $_column = $_itemColumn<String>('family_id')!;

    final manager = $$FamiliesTableTableManager(
      $_db,
      $_db.families,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_familyIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$CategoryGroupsTableFilterComposer
    extends Composer<_$AppDatabase, $CategoryGroupsTable> {
  $$CategoryGroupsTableFilterComposer({
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

  ColumnFilters<int> get displayOrder => $composableBuilder(
    column: $table.displayOrder,
    builder: (column) => ColumnFilters(column),
  );

  $$FamiliesTableFilterComposer get familyId {
    final $$FamiliesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.familyId,
      referencedTable: $db.families,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FamiliesTableFilterComposer(
            $db: $db,
            $table: $db.families,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CategoryGroupsTableOrderingComposer
    extends Composer<_$AppDatabase, $CategoryGroupsTable> {
  $$CategoryGroupsTableOrderingComposer({
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

  ColumnOrderings<int> get displayOrder => $composableBuilder(
    column: $table.displayOrder,
    builder: (column) => ColumnOrderings(column),
  );

  $$FamiliesTableOrderingComposer get familyId {
    final $$FamiliesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.familyId,
      referencedTable: $db.families,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FamiliesTableOrderingComposer(
            $db: $db,
            $table: $db.families,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CategoryGroupsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CategoryGroupsTable> {
  $$CategoryGroupsTableAnnotationComposer({
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

  GeneratedColumn<int> get displayOrder => $composableBuilder(
    column: $table.displayOrder,
    builder: (column) => column,
  );

  $$FamiliesTableAnnotationComposer get familyId {
    final $$FamiliesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.familyId,
      referencedTable: $db.families,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FamiliesTableAnnotationComposer(
            $db: $db,
            $table: $db.families,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CategoryGroupsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CategoryGroupsTable,
          CategoryGroup,
          $$CategoryGroupsTableFilterComposer,
          $$CategoryGroupsTableOrderingComposer,
          $$CategoryGroupsTableAnnotationComposer,
          $$CategoryGroupsTableCreateCompanionBuilder,
          $$CategoryGroupsTableUpdateCompanionBuilder,
          (CategoryGroup, $$CategoryGroupsTableReferences),
          CategoryGroup,
          PrefetchHooks Function({bool familyId})
        > {
  $$CategoryGroupsTableTableManager(
    _$AppDatabase db,
    $CategoryGroupsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoryGroupsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoryGroupsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoryGroupsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> displayOrder = const Value.absent(),
                Value<String> familyId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CategoryGroupsCompanion(
                id: id,
                name: name,
                displayOrder: displayOrder,
                familyId: familyId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<int> displayOrder = const Value.absent(),
                required String familyId,
                Value<int> rowid = const Value.absent(),
              }) => CategoryGroupsCompanion.insert(
                id: id,
                name: name,
                displayOrder: displayOrder,
                familyId: familyId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CategoryGroupsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({familyId = false}) {
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
                    if (familyId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.familyId,
                                referencedTable: $$CategoryGroupsTableReferences
                                    ._familyIdTable(db),
                                referencedColumn:
                                    $$CategoryGroupsTableReferences
                                        ._familyIdTable(db)
                                        .id,
                              )
                              as T;
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

typedef $$CategoryGroupsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CategoryGroupsTable,
      CategoryGroup,
      $$CategoryGroupsTableFilterComposer,
      $$CategoryGroupsTableOrderingComposer,
      $$CategoryGroupsTableAnnotationComposer,
      $$CategoryGroupsTableCreateCompanionBuilder,
      $$CategoryGroupsTableUpdateCompanionBuilder,
      (CategoryGroup, $$CategoryGroupsTableReferences),
      CategoryGroup,
      PrefetchHooks Function({bool familyId})
    >;
typedef $$TransactionsTableCreateCompanionBuilder =
    TransactionsCompanion Function({
      required String id,
      required int amount,
      required DateTime date,
      Value<String?> description,
      Value<String?> categoryId,
      required String accountId,
      Value<String?> toAccountId,
      required String kind,
      Value<String?> reconciliationKind,
      Value<String?> metadata,
      required String familyId,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });
typedef $$TransactionsTableUpdateCompanionBuilder =
    TransactionsCompanion Function({
      Value<String> id,
      Value<int> amount,
      Value<DateTime> date,
      Value<String?> description,
      Value<String?> categoryId,
      Value<String> accountId,
      Value<String?> toAccountId,
      Value<String> kind,
      Value<String?> reconciliationKind,
      Value<String?> metadata,
      Value<String> familyId,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });

final class $$TransactionsTableReferences
    extends BaseReferences<_$AppDatabase, $TransactionsTable, Transaction> {
  $$TransactionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CategoriesTable _categoryIdTable(_$AppDatabase db) =>
      db.categories.createAlias(
        $_aliasNameGenerator(db.transactions.categoryId, db.categories.id),
      );

  $$CategoriesTableProcessedTableManager? get categoryId {
    final $_column = $_itemColumn<String>('category_id');
    if ($_column == null) return null;
    final manager = $$CategoriesTableTableManager(
      $_db,
      $_db.categories,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $AccountsTable _accountIdTable(_$AppDatabase db) =>
      db.accounts.createAlias(
        $_aliasNameGenerator(db.transactions.accountId, db.accounts.id),
      );

  $$AccountsTableProcessedTableManager get accountId {
    final $_column = $_itemColumn<String>('account_id')!;

    final manager = $$AccountsTableTableManager(
      $_db,
      $_db.accounts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_accountIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $AccountsTable _toAccountIdTable(_$AppDatabase db) =>
      db.accounts.createAlias(
        $_aliasNameGenerator(db.transactions.toAccountId, db.accounts.id),
      );

  $$AccountsTableProcessedTableManager? get toAccountId {
    final $_column = $_itemColumn<String>('to_account_id');
    if ($_column == null) return null;
    final manager = $$AccountsTableTableManager(
      $_db,
      $_db.accounts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_toAccountIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $FamiliesTable _familyIdTable(_$AppDatabase db) =>
      db.families.createAlias(
        $_aliasNameGenerator(db.transactions.familyId, db.families.id),
      );

  $$FamiliesTableProcessedTableManager get familyId {
    final $_column = $_itemColumn<String>('family_id')!;

    final manager = $$FamiliesTableTableManager(
      $_db,
      $_db.families,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_familyIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TransactionsTableFilterComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableFilterComposer({
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

  ColumnFilters<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
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

  ColumnFilters<String> get reconciliationKind => $composableBuilder(
    column: $table.reconciliationKind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get metadata => $composableBuilder(
    column: $table.metadata,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$CategoriesTableFilterComposer get categoryId {
    final $$CategoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableFilterComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AccountsTableFilterComposer get accountId {
    final $$AccountsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableFilterComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AccountsTableFilterComposer get toAccountId {
    final $$AccountsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.toAccountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableFilterComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$FamiliesTableFilterComposer get familyId {
    final $$FamiliesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.familyId,
      referencedTable: $db.families,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FamiliesTableFilterComposer(
            $db: $db,
            $table: $db.families,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TransactionsTableOrderingComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableOrderingComposer({
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

  ColumnOrderings<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
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

  ColumnOrderings<String> get reconciliationKind => $composableBuilder(
    column: $table.reconciliationKind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get metadata => $composableBuilder(
    column: $table.metadata,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$CategoriesTableOrderingComposer get categoryId {
    final $$CategoriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableOrderingComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AccountsTableOrderingComposer get accountId {
    final $$AccountsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableOrderingComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AccountsTableOrderingComposer get toAccountId {
    final $$AccountsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.toAccountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableOrderingComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$FamiliesTableOrderingComposer get familyId {
    final $$FamiliesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.familyId,
      referencedTable: $db.families,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FamiliesTableOrderingComposer(
            $db: $db,
            $table: $db.families,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TransactionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get reconciliationKind => $composableBuilder(
    column: $table.reconciliationKind,
    builder: (column) => column,
  );

  GeneratedColumn<String> get metadata =>
      $composableBuilder(column: $table.metadata, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  $$CategoriesTableAnnotationComposer get categoryId {
    final $$CategoriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableAnnotationComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AccountsTableAnnotationComposer get accountId {
    final $$AccountsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableAnnotationComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AccountsTableAnnotationComposer get toAccountId {
    final $$AccountsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.toAccountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableAnnotationComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$FamiliesTableAnnotationComposer get familyId {
    final $$FamiliesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.familyId,
      referencedTable: $db.families,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FamiliesTableAnnotationComposer(
            $db: $db,
            $table: $db.families,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TransactionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TransactionsTable,
          Transaction,
          $$TransactionsTableFilterComposer,
          $$TransactionsTableOrderingComposer,
          $$TransactionsTableAnnotationComposer,
          $$TransactionsTableCreateCompanionBuilder,
          $$TransactionsTableUpdateCompanionBuilder,
          (Transaction, $$TransactionsTableReferences),
          Transaction,
          PrefetchHooks Function({
            bool categoryId,
            bool accountId,
            bool toAccountId,
            bool familyId,
          })
        > {
  $$TransactionsTableTableManager(_$AppDatabase db, $TransactionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TransactionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TransactionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TransactionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> amount = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String?> categoryId = const Value.absent(),
                Value<String> accountId = const Value.absent(),
                Value<String?> toAccountId = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String?> reconciliationKind = const Value.absent(),
                Value<String?> metadata = const Value.absent(),
                Value<String> familyId = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TransactionsCompanion(
                id: id,
                amount: amount,
                date: date,
                description: description,
                categoryId: categoryId,
                accountId: accountId,
                toAccountId: toAccountId,
                kind: kind,
                reconciliationKind: reconciliationKind,
                metadata: metadata,
                familyId: familyId,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int amount,
                required DateTime date,
                Value<String?> description = const Value.absent(),
                Value<String?> categoryId = const Value.absent(),
                required String accountId,
                Value<String?> toAccountId = const Value.absent(),
                required String kind,
                Value<String?> reconciliationKind = const Value.absent(),
                Value<String?> metadata = const Value.absent(),
                required String familyId,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TransactionsCompanion.insert(
                id: id,
                amount: amount,
                date: date,
                description: description,
                categoryId: categoryId,
                accountId: accountId,
                toAccountId: toAccountId,
                kind: kind,
                reconciliationKind: reconciliationKind,
                metadata: metadata,
                familyId: familyId,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TransactionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                categoryId = false,
                accountId = false,
                toAccountId = false,
                familyId = false,
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
                        if (categoryId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.categoryId,
                                    referencedTable:
                                        $$TransactionsTableReferences
                                            ._categoryIdTable(db),
                                    referencedColumn:
                                        $$TransactionsTableReferences
                                            ._categoryIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (accountId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.accountId,
                                    referencedTable:
                                        $$TransactionsTableReferences
                                            ._accountIdTable(db),
                                    referencedColumn:
                                        $$TransactionsTableReferences
                                            ._accountIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (toAccountId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.toAccountId,
                                    referencedTable:
                                        $$TransactionsTableReferences
                                            ._toAccountIdTable(db),
                                    referencedColumn:
                                        $$TransactionsTableReferences
                                            ._toAccountIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (familyId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.familyId,
                                    referencedTable:
                                        $$TransactionsTableReferences
                                            ._familyIdTable(db),
                                    referencedColumn:
                                        $$TransactionsTableReferences
                                            ._familyIdTable(db)
                                            .id,
                                  )
                                  as T;
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

typedef $$TransactionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TransactionsTable,
      Transaction,
      $$TransactionsTableFilterComposer,
      $$TransactionsTableOrderingComposer,
      $$TransactionsTableAnnotationComposer,
      $$TransactionsTableCreateCompanionBuilder,
      $$TransactionsTableUpdateCompanionBuilder,
      (Transaction, $$TransactionsTableReferences),
      Transaction,
      PrefetchHooks Function({
        bool categoryId,
        bool accountId,
        bool toAccountId,
        bool familyId,
      })
    >;
typedef $$BalanceSnapshotsTableCreateCompanionBuilder =
    BalanceSnapshotsCompanion Function({
      required String id,
      required String accountId,
      required DateTime snapshotDate,
      required int balance,
      required String familyId,
      Value<int> rowid,
    });
typedef $$BalanceSnapshotsTableUpdateCompanionBuilder =
    BalanceSnapshotsCompanion Function({
      Value<String> id,
      Value<String> accountId,
      Value<DateTime> snapshotDate,
      Value<int> balance,
      Value<String> familyId,
      Value<int> rowid,
    });

final class $$BalanceSnapshotsTableReferences
    extends
        BaseReferences<_$AppDatabase, $BalanceSnapshotsTable, BalanceSnapshot> {
  $$BalanceSnapshotsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $AccountsTable _accountIdTable(_$AppDatabase db) =>
      db.accounts.createAlias(
        $_aliasNameGenerator(db.balanceSnapshots.accountId, db.accounts.id),
      );

  $$AccountsTableProcessedTableManager get accountId {
    final $_column = $_itemColumn<String>('account_id')!;

    final manager = $$AccountsTableTableManager(
      $_db,
      $_db.accounts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_accountIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $FamiliesTable _familyIdTable(_$AppDatabase db) =>
      db.families.createAlias(
        $_aliasNameGenerator(db.balanceSnapshots.familyId, db.families.id),
      );

  $$FamiliesTableProcessedTableManager get familyId {
    final $_column = $_itemColumn<String>('family_id')!;

    final manager = $$FamiliesTableTableManager(
      $_db,
      $_db.families,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_familyIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$BalanceSnapshotsTableFilterComposer
    extends Composer<_$AppDatabase, $BalanceSnapshotsTable> {
  $$BalanceSnapshotsTableFilterComposer({
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

  ColumnFilters<DateTime> get snapshotDate => $composableBuilder(
    column: $table.snapshotDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get balance => $composableBuilder(
    column: $table.balance,
    builder: (column) => ColumnFilters(column),
  );

  $$AccountsTableFilterComposer get accountId {
    final $$AccountsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableFilterComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$FamiliesTableFilterComposer get familyId {
    final $$FamiliesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.familyId,
      referencedTable: $db.families,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FamiliesTableFilterComposer(
            $db: $db,
            $table: $db.families,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BalanceSnapshotsTableOrderingComposer
    extends Composer<_$AppDatabase, $BalanceSnapshotsTable> {
  $$BalanceSnapshotsTableOrderingComposer({
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

  ColumnOrderings<DateTime> get snapshotDate => $composableBuilder(
    column: $table.snapshotDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get balance => $composableBuilder(
    column: $table.balance,
    builder: (column) => ColumnOrderings(column),
  );

  $$AccountsTableOrderingComposer get accountId {
    final $$AccountsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableOrderingComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$FamiliesTableOrderingComposer get familyId {
    final $$FamiliesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.familyId,
      referencedTable: $db.families,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FamiliesTableOrderingComposer(
            $db: $db,
            $table: $db.families,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BalanceSnapshotsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BalanceSnapshotsTable> {
  $$BalanceSnapshotsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get snapshotDate => $composableBuilder(
    column: $table.snapshotDate,
    builder: (column) => column,
  );

  GeneratedColumn<int> get balance =>
      $composableBuilder(column: $table.balance, builder: (column) => column);

  $$AccountsTableAnnotationComposer get accountId {
    final $$AccountsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableAnnotationComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$FamiliesTableAnnotationComposer get familyId {
    final $$FamiliesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.familyId,
      referencedTable: $db.families,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FamiliesTableAnnotationComposer(
            $db: $db,
            $table: $db.families,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BalanceSnapshotsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BalanceSnapshotsTable,
          BalanceSnapshot,
          $$BalanceSnapshotsTableFilterComposer,
          $$BalanceSnapshotsTableOrderingComposer,
          $$BalanceSnapshotsTableAnnotationComposer,
          $$BalanceSnapshotsTableCreateCompanionBuilder,
          $$BalanceSnapshotsTableUpdateCompanionBuilder,
          (BalanceSnapshot, $$BalanceSnapshotsTableReferences),
          BalanceSnapshot,
          PrefetchHooks Function({bool accountId, bool familyId})
        > {
  $$BalanceSnapshotsTableTableManager(
    _$AppDatabase db,
    $BalanceSnapshotsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BalanceSnapshotsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BalanceSnapshotsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BalanceSnapshotsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> accountId = const Value.absent(),
                Value<DateTime> snapshotDate = const Value.absent(),
                Value<int> balance = const Value.absent(),
                Value<String> familyId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BalanceSnapshotsCompanion(
                id: id,
                accountId: accountId,
                snapshotDate: snapshotDate,
                balance: balance,
                familyId: familyId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String accountId,
                required DateTime snapshotDate,
                required int balance,
                required String familyId,
                Value<int> rowid = const Value.absent(),
              }) => BalanceSnapshotsCompanion.insert(
                id: id,
                accountId: accountId,
                snapshotDate: snapshotDate,
                balance: balance,
                familyId: familyId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$BalanceSnapshotsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({accountId = false, familyId = false}) {
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
                    if (accountId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.accountId,
                                referencedTable:
                                    $$BalanceSnapshotsTableReferences
                                        ._accountIdTable(db),
                                referencedColumn:
                                    $$BalanceSnapshotsTableReferences
                                        ._accountIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (familyId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.familyId,
                                referencedTable:
                                    $$BalanceSnapshotsTableReferences
                                        ._familyIdTable(db),
                                referencedColumn:
                                    $$BalanceSnapshotsTableReferences
                                        ._familyIdTable(db)
                                        .id,
                              )
                              as T;
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

typedef $$BalanceSnapshotsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BalanceSnapshotsTable,
      BalanceSnapshot,
      $$BalanceSnapshotsTableFilterComposer,
      $$BalanceSnapshotsTableOrderingComposer,
      $$BalanceSnapshotsTableAnnotationComposer,
      $$BalanceSnapshotsTableCreateCompanionBuilder,
      $$BalanceSnapshotsTableUpdateCompanionBuilder,
      (BalanceSnapshot, $$BalanceSnapshotsTableReferences),
      BalanceSnapshot,
      PrefetchHooks Function({bool accountId, bool familyId})
    >;
typedef $$AuditLogTableCreateCompanionBuilder =
    AuditLogCompanion Function({
      required String id,
      required String entityType,
      required String entityId,
      required String action,
      Value<String?> diff,
      required String actorUserId,
      required DateTime createdAt,
      required String familyId,
      Value<int> rowid,
    });
typedef $$AuditLogTableUpdateCompanionBuilder =
    AuditLogCompanion Function({
      Value<String> id,
      Value<String> entityType,
      Value<String> entityId,
      Value<String> action,
      Value<String?> diff,
      Value<String> actorUserId,
      Value<DateTime> createdAt,
      Value<String> familyId,
      Value<int> rowid,
    });

final class $$AuditLogTableReferences
    extends BaseReferences<_$AppDatabase, $AuditLogTable, AuditLogData> {
  $$AuditLogTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $FamiliesTable _familyIdTable(_$AppDatabase db) => db.families
      .createAlias($_aliasNameGenerator(db.auditLog.familyId, db.families.id));

  $$FamiliesTableProcessedTableManager get familyId {
    final $_column = $_itemColumn<String>('family_id')!;

    final manager = $$FamiliesTableTableManager(
      $_db,
      $_db.families,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_familyIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$AuditLogTableFilterComposer
    extends Composer<_$AppDatabase, $AuditLogTable> {
  $$AuditLogTableFilterComposer({
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

  ColumnFilters<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get action => $composableBuilder(
    column: $table.action,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get diff => $composableBuilder(
    column: $table.diff,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get actorUserId => $composableBuilder(
    column: $table.actorUserId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$FamiliesTableFilterComposer get familyId {
    final $$FamiliesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.familyId,
      referencedTable: $db.families,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FamiliesTableFilterComposer(
            $db: $db,
            $table: $db.families,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AuditLogTableOrderingComposer
    extends Composer<_$AppDatabase, $AuditLogTable> {
  $$AuditLogTableOrderingComposer({
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

  ColumnOrderings<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get action => $composableBuilder(
    column: $table.action,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get diff => $composableBuilder(
    column: $table.diff,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get actorUserId => $composableBuilder(
    column: $table.actorUserId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$FamiliesTableOrderingComposer get familyId {
    final $$FamiliesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.familyId,
      referencedTable: $db.families,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FamiliesTableOrderingComposer(
            $db: $db,
            $table: $db.families,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AuditLogTableAnnotationComposer
    extends Composer<_$AppDatabase, $AuditLogTable> {
  $$AuditLogTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get action =>
      $composableBuilder(column: $table.action, builder: (column) => column);

  GeneratedColumn<String> get diff =>
      $composableBuilder(column: $table.diff, builder: (column) => column);

  GeneratedColumn<String> get actorUserId => $composableBuilder(
    column: $table.actorUserId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$FamiliesTableAnnotationComposer get familyId {
    final $$FamiliesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.familyId,
      referencedTable: $db.families,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FamiliesTableAnnotationComposer(
            $db: $db,
            $table: $db.families,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AuditLogTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AuditLogTable,
          AuditLogData,
          $$AuditLogTableFilterComposer,
          $$AuditLogTableOrderingComposer,
          $$AuditLogTableAnnotationComposer,
          $$AuditLogTableCreateCompanionBuilder,
          $$AuditLogTableUpdateCompanionBuilder,
          (AuditLogData, $$AuditLogTableReferences),
          AuditLogData,
          PrefetchHooks Function({bool familyId})
        > {
  $$AuditLogTableTableManager(_$AppDatabase db, $AuditLogTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AuditLogTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AuditLogTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AuditLogTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> entityType = const Value.absent(),
                Value<String> entityId = const Value.absent(),
                Value<String> action = const Value.absent(),
                Value<String?> diff = const Value.absent(),
                Value<String> actorUserId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String> familyId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AuditLogCompanion(
                id: id,
                entityType: entityType,
                entityId: entityId,
                action: action,
                diff: diff,
                actorUserId: actorUserId,
                createdAt: createdAt,
                familyId: familyId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String entityType,
                required String entityId,
                required String action,
                Value<String?> diff = const Value.absent(),
                required String actorUserId,
                required DateTime createdAt,
                required String familyId,
                Value<int> rowid = const Value.absent(),
              }) => AuditLogCompanion.insert(
                id: id,
                entityType: entityType,
                entityId: entityId,
                action: action,
                diff: diff,
                actorUserId: actorUserId,
                createdAt: createdAt,
                familyId: familyId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$AuditLogTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({familyId = false}) {
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
                    if (familyId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.familyId,
                                referencedTable: $$AuditLogTableReferences
                                    ._familyIdTable(db),
                                referencedColumn: $$AuditLogTableReferences
                                    ._familyIdTable(db)
                                    .id,
                              )
                              as T;
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

typedef $$AuditLogTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AuditLogTable,
      AuditLogData,
      $$AuditLogTableFilterComposer,
      $$AuditLogTableOrderingComposer,
      $$AuditLogTableAnnotationComposer,
      $$AuditLogTableCreateCompanionBuilder,
      $$AuditLogTableUpdateCompanionBuilder,
      (AuditLogData, $$AuditLogTableReferences),
      AuditLogData,
      PrefetchHooks Function({bool familyId})
    >;
typedef $$GoalsTableCreateCompanionBuilder =
    GoalsCompanion Function({
      required String id,
      required String name,
      required int targetAmount,
      required DateTime targetDate,
      Value<int> currentSavings,
      Value<double> inflationRate,
      Value<int> priority,
      Value<String> status,
      Value<String?> linkedAccountId,
      required String familyId,
      Value<String> goalCategory,
      Value<int?> downPaymentPctBp,
      Value<int?> educationEscalationRateBp,
      Value<String?> sinkingFundSubType,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$GoalsTableUpdateCompanionBuilder =
    GoalsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<int> targetAmount,
      Value<DateTime> targetDate,
      Value<int> currentSavings,
      Value<double> inflationRate,
      Value<int> priority,
      Value<String> status,
      Value<String?> linkedAccountId,
      Value<String> familyId,
      Value<String> goalCategory,
      Value<int?> downPaymentPctBp,
      Value<int?> educationEscalationRateBp,
      Value<String?> sinkingFundSubType,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$GoalsTableReferences
    extends BaseReferences<_$AppDatabase, $GoalsTable, Goal> {
  $$GoalsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $AccountsTable _linkedAccountIdTable(_$AppDatabase db) =>
      db.accounts.createAlias(
        $_aliasNameGenerator(db.goals.linkedAccountId, db.accounts.id),
      );

  $$AccountsTableProcessedTableManager? get linkedAccountId {
    final $_column = $_itemColumn<String>('linked_account_id');
    if ($_column == null) return null;
    final manager = $$AccountsTableTableManager(
      $_db,
      $_db.accounts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_linkedAccountIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $FamiliesTable _familyIdTable(_$AppDatabase db) => db.families
      .createAlias($_aliasNameGenerator(db.goals.familyId, db.families.id));

  $$FamiliesTableProcessedTableManager get familyId {
    final $_column = $_itemColumn<String>('family_id')!;

    final manager = $$FamiliesTableTableManager(
      $_db,
      $_db.families,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_familyIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$InvestmentHoldingsTable, List<InvestmentHolding>>
  _investmentHoldingsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.investmentHoldings,
        aliasName: $_aliasNameGenerator(
          db.goals.id,
          db.investmentHoldings.linkedGoalId,
        ),
      );

  $$InvestmentHoldingsTableProcessedTableManager get investmentHoldingsRefs {
    final manager = $$InvestmentHoldingsTableTableManager(
      $_db,
      $_db.investmentHoldings,
    ).filter((f) => f.linkedGoalId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _investmentHoldingsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$GoalsTableFilterComposer extends Composer<_$AppDatabase, $GoalsTable> {
  $$GoalsTableFilterComposer({
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

  ColumnFilters<int> get targetAmount => $composableBuilder(
    column: $table.targetAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get targetDate => $composableBuilder(
    column: $table.targetDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get currentSavings => $composableBuilder(
    column: $table.currentSavings,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get inflationRate => $composableBuilder(
    column: $table.inflationRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get goalCategory => $composableBuilder(
    column: $table.goalCategory,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get downPaymentPctBp => $composableBuilder(
    column: $table.downPaymentPctBp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get educationEscalationRateBp => $composableBuilder(
    column: $table.educationEscalationRateBp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sinkingFundSubType => $composableBuilder(
    column: $table.sinkingFundSubType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$AccountsTableFilterComposer get linkedAccountId {
    final $$AccountsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.linkedAccountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableFilterComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$FamiliesTableFilterComposer get familyId {
    final $$FamiliesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.familyId,
      referencedTable: $db.families,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FamiliesTableFilterComposer(
            $db: $db,
            $table: $db.families,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> investmentHoldingsRefs(
    Expression<bool> Function($$InvestmentHoldingsTableFilterComposer f) f,
  ) {
    final $$InvestmentHoldingsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.investmentHoldings,
      getReferencedColumn: (t) => t.linkedGoalId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InvestmentHoldingsTableFilterComposer(
            $db: $db,
            $table: $db.investmentHoldings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$GoalsTableOrderingComposer
    extends Composer<_$AppDatabase, $GoalsTable> {
  $$GoalsTableOrderingComposer({
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

  ColumnOrderings<int> get targetAmount => $composableBuilder(
    column: $table.targetAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get targetDate => $composableBuilder(
    column: $table.targetDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get currentSavings => $composableBuilder(
    column: $table.currentSavings,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get inflationRate => $composableBuilder(
    column: $table.inflationRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get goalCategory => $composableBuilder(
    column: $table.goalCategory,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get downPaymentPctBp => $composableBuilder(
    column: $table.downPaymentPctBp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get educationEscalationRateBp => $composableBuilder(
    column: $table.educationEscalationRateBp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sinkingFundSubType => $composableBuilder(
    column: $table.sinkingFundSubType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$AccountsTableOrderingComposer get linkedAccountId {
    final $$AccountsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.linkedAccountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableOrderingComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$FamiliesTableOrderingComposer get familyId {
    final $$FamiliesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.familyId,
      referencedTable: $db.families,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FamiliesTableOrderingComposer(
            $db: $db,
            $table: $db.families,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GoalsTableAnnotationComposer
    extends Composer<_$AppDatabase, $GoalsTable> {
  $$GoalsTableAnnotationComposer({
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

  GeneratedColumn<int> get targetAmount => $composableBuilder(
    column: $table.targetAmount,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get targetDate => $composableBuilder(
    column: $table.targetDate,
    builder: (column) => column,
  );

  GeneratedColumn<int> get currentSavings => $composableBuilder(
    column: $table.currentSavings,
    builder: (column) => column,
  );

  GeneratedColumn<double> get inflationRate => $composableBuilder(
    column: $table.inflationRate,
    builder: (column) => column,
  );

  GeneratedColumn<int> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get goalCategory => $composableBuilder(
    column: $table.goalCategory,
    builder: (column) => column,
  );

  GeneratedColumn<int> get downPaymentPctBp => $composableBuilder(
    column: $table.downPaymentPctBp,
    builder: (column) => column,
  );

  GeneratedColumn<int> get educationEscalationRateBp => $composableBuilder(
    column: $table.educationEscalationRateBp,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sinkingFundSubType => $composableBuilder(
    column: $table.sinkingFundSubType,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$AccountsTableAnnotationComposer get linkedAccountId {
    final $$AccountsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.linkedAccountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableAnnotationComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$FamiliesTableAnnotationComposer get familyId {
    final $$FamiliesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.familyId,
      referencedTable: $db.families,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FamiliesTableAnnotationComposer(
            $db: $db,
            $table: $db.families,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> investmentHoldingsRefs<T extends Object>(
    Expression<T> Function($$InvestmentHoldingsTableAnnotationComposer a) f,
  ) {
    final $$InvestmentHoldingsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.investmentHoldings,
          getReferencedColumn: (t) => t.linkedGoalId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$InvestmentHoldingsTableAnnotationComposer(
                $db: $db,
                $table: $db.investmentHoldings,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$GoalsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GoalsTable,
          Goal,
          $$GoalsTableFilterComposer,
          $$GoalsTableOrderingComposer,
          $$GoalsTableAnnotationComposer,
          $$GoalsTableCreateCompanionBuilder,
          $$GoalsTableUpdateCompanionBuilder,
          (Goal, $$GoalsTableReferences),
          Goal,
          PrefetchHooks Function({
            bool linkedAccountId,
            bool familyId,
            bool investmentHoldingsRefs,
          })
        > {
  $$GoalsTableTableManager(_$AppDatabase db, $GoalsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GoalsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GoalsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GoalsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> targetAmount = const Value.absent(),
                Value<DateTime> targetDate = const Value.absent(),
                Value<int> currentSavings = const Value.absent(),
                Value<double> inflationRate = const Value.absent(),
                Value<int> priority = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> linkedAccountId = const Value.absent(),
                Value<String> familyId = const Value.absent(),
                Value<String> goalCategory = const Value.absent(),
                Value<int?> downPaymentPctBp = const Value.absent(),
                Value<int?> educationEscalationRateBp = const Value.absent(),
                Value<String?> sinkingFundSubType = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GoalsCompanion(
                id: id,
                name: name,
                targetAmount: targetAmount,
                targetDate: targetDate,
                currentSavings: currentSavings,
                inflationRate: inflationRate,
                priority: priority,
                status: status,
                linkedAccountId: linkedAccountId,
                familyId: familyId,
                goalCategory: goalCategory,
                downPaymentPctBp: downPaymentPctBp,
                educationEscalationRateBp: educationEscalationRateBp,
                sinkingFundSubType: sinkingFundSubType,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required int targetAmount,
                required DateTime targetDate,
                Value<int> currentSavings = const Value.absent(),
                Value<double> inflationRate = const Value.absent(),
                Value<int> priority = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> linkedAccountId = const Value.absent(),
                required String familyId,
                Value<String> goalCategory = const Value.absent(),
                Value<int?> downPaymentPctBp = const Value.absent(),
                Value<int?> educationEscalationRateBp = const Value.absent(),
                Value<String?> sinkingFundSubType = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => GoalsCompanion.insert(
                id: id,
                name: name,
                targetAmount: targetAmount,
                targetDate: targetDate,
                currentSavings: currentSavings,
                inflationRate: inflationRate,
                priority: priority,
                status: status,
                linkedAccountId: linkedAccountId,
                familyId: familyId,
                goalCategory: goalCategory,
                downPaymentPctBp: downPaymentPctBp,
                educationEscalationRateBp: educationEscalationRateBp,
                sinkingFundSubType: sinkingFundSubType,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$GoalsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                linkedAccountId = false,
                familyId = false,
                investmentHoldingsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (investmentHoldingsRefs) db.investmentHoldings,
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
                        if (linkedAccountId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.linkedAccountId,
                                    referencedTable: $$GoalsTableReferences
                                        ._linkedAccountIdTable(db),
                                    referencedColumn: $$GoalsTableReferences
                                        ._linkedAccountIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }
                        if (familyId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.familyId,
                                    referencedTable: $$GoalsTableReferences
                                        ._familyIdTable(db),
                                    referencedColumn: $$GoalsTableReferences
                                        ._familyIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (investmentHoldingsRefs)
                        await $_getPrefetchedData<
                          Goal,
                          $GoalsTable,
                          InvestmentHolding
                        >(
                          currentTable: table,
                          referencedTable: $$GoalsTableReferences
                              ._investmentHoldingsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$GoalsTableReferences(
                                db,
                                table,
                                p0,
                              ).investmentHoldingsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.linkedGoalId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$GoalsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GoalsTable,
      Goal,
      $$GoalsTableFilterComposer,
      $$GoalsTableOrderingComposer,
      $$GoalsTableAnnotationComposer,
      $$GoalsTableCreateCompanionBuilder,
      $$GoalsTableUpdateCompanionBuilder,
      (Goal, $$GoalsTableReferences),
      Goal,
      PrefetchHooks Function({
        bool linkedAccountId,
        bool familyId,
        bool investmentHoldingsRefs,
      })
    >;
typedef $$BudgetsTableCreateCompanionBuilder =
    BudgetsCompanion Function({
      required String id,
      required String familyId,
      required int year,
      required int month,
      required String categoryGroup,
      required int limitAmount,
      Value<int> rowid,
    });
typedef $$BudgetsTableUpdateCompanionBuilder =
    BudgetsCompanion Function({
      Value<String> id,
      Value<String> familyId,
      Value<int> year,
      Value<int> month,
      Value<String> categoryGroup,
      Value<int> limitAmount,
      Value<int> rowid,
    });

final class $$BudgetsTableReferences
    extends BaseReferences<_$AppDatabase, $BudgetsTable, Budget> {
  $$BudgetsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $FamiliesTable _familyIdTable(_$AppDatabase db) => db.families
      .createAlias($_aliasNameGenerator(db.budgets.familyId, db.families.id));

  $$FamiliesTableProcessedTableManager get familyId {
    final $_column = $_itemColumn<String>('family_id')!;

    final manager = $$FamiliesTableTableManager(
      $_db,
      $_db.families,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_familyIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$BudgetsTableFilterComposer
    extends Composer<_$AppDatabase, $BudgetsTable> {
  $$BudgetsTableFilterComposer({
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

  ColumnFilters<int> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get month => $composableBuilder(
    column: $table.month,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoryGroup => $composableBuilder(
    column: $table.categoryGroup,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get limitAmount => $composableBuilder(
    column: $table.limitAmount,
    builder: (column) => ColumnFilters(column),
  );

  $$FamiliesTableFilterComposer get familyId {
    final $$FamiliesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.familyId,
      referencedTable: $db.families,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FamiliesTableFilterComposer(
            $db: $db,
            $table: $db.families,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BudgetsTableOrderingComposer
    extends Composer<_$AppDatabase, $BudgetsTable> {
  $$BudgetsTableOrderingComposer({
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

  ColumnOrderings<int> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get month => $composableBuilder(
    column: $table.month,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoryGroup => $composableBuilder(
    column: $table.categoryGroup,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get limitAmount => $composableBuilder(
    column: $table.limitAmount,
    builder: (column) => ColumnOrderings(column),
  );

  $$FamiliesTableOrderingComposer get familyId {
    final $$FamiliesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.familyId,
      referencedTable: $db.families,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FamiliesTableOrderingComposer(
            $db: $db,
            $table: $db.families,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BudgetsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BudgetsTable> {
  $$BudgetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get year =>
      $composableBuilder(column: $table.year, builder: (column) => column);

  GeneratedColumn<int> get month =>
      $composableBuilder(column: $table.month, builder: (column) => column);

  GeneratedColumn<String> get categoryGroup => $composableBuilder(
    column: $table.categoryGroup,
    builder: (column) => column,
  );

  GeneratedColumn<int> get limitAmount => $composableBuilder(
    column: $table.limitAmount,
    builder: (column) => column,
  );

  $$FamiliesTableAnnotationComposer get familyId {
    final $$FamiliesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.familyId,
      referencedTable: $db.families,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FamiliesTableAnnotationComposer(
            $db: $db,
            $table: $db.families,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BudgetsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BudgetsTable,
          Budget,
          $$BudgetsTableFilterComposer,
          $$BudgetsTableOrderingComposer,
          $$BudgetsTableAnnotationComposer,
          $$BudgetsTableCreateCompanionBuilder,
          $$BudgetsTableUpdateCompanionBuilder,
          (Budget, $$BudgetsTableReferences),
          Budget,
          PrefetchHooks Function({bool familyId})
        > {
  $$BudgetsTableTableManager(_$AppDatabase db, $BudgetsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BudgetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BudgetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BudgetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> familyId = const Value.absent(),
                Value<int> year = const Value.absent(),
                Value<int> month = const Value.absent(),
                Value<String> categoryGroup = const Value.absent(),
                Value<int> limitAmount = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BudgetsCompanion(
                id: id,
                familyId: familyId,
                year: year,
                month: month,
                categoryGroup: categoryGroup,
                limitAmount: limitAmount,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String familyId,
                required int year,
                required int month,
                required String categoryGroup,
                required int limitAmount,
                Value<int> rowid = const Value.absent(),
              }) => BudgetsCompanion.insert(
                id: id,
                familyId: familyId,
                year: year,
                month: month,
                categoryGroup: categoryGroup,
                limitAmount: limitAmount,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$BudgetsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({familyId = false}) {
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
                    if (familyId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.familyId,
                                referencedTable: $$BudgetsTableReferences
                                    ._familyIdTable(db),
                                referencedColumn: $$BudgetsTableReferences
                                    ._familyIdTable(db)
                                    .id,
                              )
                              as T;
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

typedef $$BudgetsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BudgetsTable,
      Budget,
      $$BudgetsTableFilterComposer,
      $$BudgetsTableOrderingComposer,
      $$BudgetsTableAnnotationComposer,
      $$BudgetsTableCreateCompanionBuilder,
      $$BudgetsTableUpdateCompanionBuilder,
      (Budget, $$BudgetsTableReferences),
      Budget,
      PrefetchHooks Function({bool familyId})
    >;
typedef $$LoanDetailsTableCreateCompanionBuilder =
    LoanDetailsCompanion Function({
      required String id,
      required String accountId,
      required int principal,
      required double annualRate,
      required int tenureMonths,
      required int outstandingPrincipal,
      required int emiAmount,
      required DateTime startDate,
      Value<DateTime?> disbursementDate,
      required String familyId,
      Value<int> rowid,
    });
typedef $$LoanDetailsTableUpdateCompanionBuilder =
    LoanDetailsCompanion Function({
      Value<String> id,
      Value<String> accountId,
      Value<int> principal,
      Value<double> annualRate,
      Value<int> tenureMonths,
      Value<int> outstandingPrincipal,
      Value<int> emiAmount,
      Value<DateTime> startDate,
      Value<DateTime?> disbursementDate,
      Value<String> familyId,
      Value<int> rowid,
    });

final class $$LoanDetailsTableReferences
    extends BaseReferences<_$AppDatabase, $LoanDetailsTable, LoanDetail> {
  $$LoanDetailsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $AccountsTable _accountIdTable(_$AppDatabase db) =>
      db.accounts.createAlias(
        $_aliasNameGenerator(db.loanDetails.accountId, db.accounts.id),
      );

  $$AccountsTableProcessedTableManager get accountId {
    final $_column = $_itemColumn<String>('account_id')!;

    final manager = $$AccountsTableTableManager(
      $_db,
      $_db.accounts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_accountIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $FamiliesTable _familyIdTable(_$AppDatabase db) =>
      db.families.createAlias(
        $_aliasNameGenerator(db.loanDetails.familyId, db.families.id),
      );

  $$FamiliesTableProcessedTableManager get familyId {
    final $_column = $_itemColumn<String>('family_id')!;

    final manager = $$FamiliesTableTableManager(
      $_db,
      $_db.families,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_familyIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$LoanDetailsTableFilterComposer
    extends Composer<_$AppDatabase, $LoanDetailsTable> {
  $$LoanDetailsTableFilterComposer({
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

  ColumnFilters<int> get principal => $composableBuilder(
    column: $table.principal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get annualRate => $composableBuilder(
    column: $table.annualRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get tenureMonths => $composableBuilder(
    column: $table.tenureMonths,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get outstandingPrincipal => $composableBuilder(
    column: $table.outstandingPrincipal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get emiAmount => $composableBuilder(
    column: $table.emiAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get disbursementDate => $composableBuilder(
    column: $table.disbursementDate,
    builder: (column) => ColumnFilters(column),
  );

  $$AccountsTableFilterComposer get accountId {
    final $$AccountsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableFilterComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$FamiliesTableFilterComposer get familyId {
    final $$FamiliesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.familyId,
      referencedTable: $db.families,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FamiliesTableFilterComposer(
            $db: $db,
            $table: $db.families,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LoanDetailsTableOrderingComposer
    extends Composer<_$AppDatabase, $LoanDetailsTable> {
  $$LoanDetailsTableOrderingComposer({
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

  ColumnOrderings<int> get principal => $composableBuilder(
    column: $table.principal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get annualRate => $composableBuilder(
    column: $table.annualRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get tenureMonths => $composableBuilder(
    column: $table.tenureMonths,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get outstandingPrincipal => $composableBuilder(
    column: $table.outstandingPrincipal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get emiAmount => $composableBuilder(
    column: $table.emiAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get disbursementDate => $composableBuilder(
    column: $table.disbursementDate,
    builder: (column) => ColumnOrderings(column),
  );

  $$AccountsTableOrderingComposer get accountId {
    final $$AccountsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableOrderingComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$FamiliesTableOrderingComposer get familyId {
    final $$FamiliesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.familyId,
      referencedTable: $db.families,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FamiliesTableOrderingComposer(
            $db: $db,
            $table: $db.families,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LoanDetailsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LoanDetailsTable> {
  $$LoanDetailsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get principal =>
      $composableBuilder(column: $table.principal, builder: (column) => column);

  GeneratedColumn<double> get annualRate => $composableBuilder(
    column: $table.annualRate,
    builder: (column) => column,
  );

  GeneratedColumn<int> get tenureMonths => $composableBuilder(
    column: $table.tenureMonths,
    builder: (column) => column,
  );

  GeneratedColumn<int> get outstandingPrincipal => $composableBuilder(
    column: $table.outstandingPrincipal,
    builder: (column) => column,
  );

  GeneratedColumn<int> get emiAmount =>
      $composableBuilder(column: $table.emiAmount, builder: (column) => column);

  GeneratedColumn<DateTime> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<DateTime> get disbursementDate => $composableBuilder(
    column: $table.disbursementDate,
    builder: (column) => column,
  );

  $$AccountsTableAnnotationComposer get accountId {
    final $$AccountsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableAnnotationComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$FamiliesTableAnnotationComposer get familyId {
    final $$FamiliesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.familyId,
      referencedTable: $db.families,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FamiliesTableAnnotationComposer(
            $db: $db,
            $table: $db.families,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LoanDetailsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LoanDetailsTable,
          LoanDetail,
          $$LoanDetailsTableFilterComposer,
          $$LoanDetailsTableOrderingComposer,
          $$LoanDetailsTableAnnotationComposer,
          $$LoanDetailsTableCreateCompanionBuilder,
          $$LoanDetailsTableUpdateCompanionBuilder,
          (LoanDetail, $$LoanDetailsTableReferences),
          LoanDetail,
          PrefetchHooks Function({bool accountId, bool familyId})
        > {
  $$LoanDetailsTableTableManager(_$AppDatabase db, $LoanDetailsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LoanDetailsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LoanDetailsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LoanDetailsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> accountId = const Value.absent(),
                Value<int> principal = const Value.absent(),
                Value<double> annualRate = const Value.absent(),
                Value<int> tenureMonths = const Value.absent(),
                Value<int> outstandingPrincipal = const Value.absent(),
                Value<int> emiAmount = const Value.absent(),
                Value<DateTime> startDate = const Value.absent(),
                Value<DateTime?> disbursementDate = const Value.absent(),
                Value<String> familyId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LoanDetailsCompanion(
                id: id,
                accountId: accountId,
                principal: principal,
                annualRate: annualRate,
                tenureMonths: tenureMonths,
                outstandingPrincipal: outstandingPrincipal,
                emiAmount: emiAmount,
                startDate: startDate,
                disbursementDate: disbursementDate,
                familyId: familyId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String accountId,
                required int principal,
                required double annualRate,
                required int tenureMonths,
                required int outstandingPrincipal,
                required int emiAmount,
                required DateTime startDate,
                Value<DateTime?> disbursementDate = const Value.absent(),
                required String familyId,
                Value<int> rowid = const Value.absent(),
              }) => LoanDetailsCompanion.insert(
                id: id,
                accountId: accountId,
                principal: principal,
                annualRate: annualRate,
                tenureMonths: tenureMonths,
                outstandingPrincipal: outstandingPrincipal,
                emiAmount: emiAmount,
                startDate: startDate,
                disbursementDate: disbursementDate,
                familyId: familyId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$LoanDetailsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({accountId = false, familyId = false}) {
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
                    if (accountId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.accountId,
                                referencedTable: $$LoanDetailsTableReferences
                                    ._accountIdTable(db),
                                referencedColumn: $$LoanDetailsTableReferences
                                    ._accountIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (familyId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.familyId,
                                referencedTable: $$LoanDetailsTableReferences
                                    ._familyIdTable(db),
                                referencedColumn: $$LoanDetailsTableReferences
                                    ._familyIdTable(db)
                                    .id,
                              )
                              as T;
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

typedef $$LoanDetailsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LoanDetailsTable,
      LoanDetail,
      $$LoanDetailsTableFilterComposer,
      $$LoanDetailsTableOrderingComposer,
      $$LoanDetailsTableAnnotationComposer,
      $$LoanDetailsTableCreateCompanionBuilder,
      $$LoanDetailsTableUpdateCompanionBuilder,
      (LoanDetail, $$LoanDetailsTableReferences),
      LoanDetail,
      PrefetchHooks Function({bool accountId, bool familyId})
    >;
typedef $$InvestmentHoldingsTableCreateCompanionBuilder =
    InvestmentHoldingsCompanion Function({
      required String id,
      required String name,
      required String bucketType,
      required int investedAmount,
      required int currentValue,
      Value<double> expectedReturnRate,
      Value<int> monthlyContribution,
      Value<String?> linkedAccountId,
      Value<String?> linkedGoalId,
      required String familyId,
      required String userId,
      Value<String> visibility,
      required DateTime createdAt,
      Value<DateTime?> updatedAt,
      Value<int> rowid,
    });
typedef $$InvestmentHoldingsTableUpdateCompanionBuilder =
    InvestmentHoldingsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> bucketType,
      Value<int> investedAmount,
      Value<int> currentValue,
      Value<double> expectedReturnRate,
      Value<int> monthlyContribution,
      Value<String?> linkedAccountId,
      Value<String?> linkedGoalId,
      Value<String> familyId,
      Value<String> userId,
      Value<String> visibility,
      Value<DateTime> createdAt,
      Value<DateTime?> updatedAt,
      Value<int> rowid,
    });

final class $$InvestmentHoldingsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $InvestmentHoldingsTable,
          InvestmentHolding
        > {
  $$InvestmentHoldingsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $AccountsTable _linkedAccountIdTable(_$AppDatabase db) =>
      db.accounts.createAlias(
        $_aliasNameGenerator(
          db.investmentHoldings.linkedAccountId,
          db.accounts.id,
        ),
      );

  $$AccountsTableProcessedTableManager? get linkedAccountId {
    final $_column = $_itemColumn<String>('linked_account_id');
    if ($_column == null) return null;
    final manager = $$AccountsTableTableManager(
      $_db,
      $_db.accounts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_linkedAccountIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $GoalsTable _linkedGoalIdTable(_$AppDatabase db) =>
      db.goals.createAlias(
        $_aliasNameGenerator(db.investmentHoldings.linkedGoalId, db.goals.id),
      );

  $$GoalsTableProcessedTableManager? get linkedGoalId {
    final $_column = $_itemColumn<String>('linked_goal_id');
    if ($_column == null) return null;
    final manager = $$GoalsTableTableManager(
      $_db,
      $_db.goals,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_linkedGoalIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $FamiliesTable _familyIdTable(_$AppDatabase db) =>
      db.families.createAlias(
        $_aliasNameGenerator(db.investmentHoldings.familyId, db.families.id),
      );

  $$FamiliesTableProcessedTableManager get familyId {
    final $_column = $_itemColumn<String>('family_id')!;

    final manager = $$FamiliesTableTableManager(
      $_db,
      $_db.families,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_familyIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$InvestmentHoldingsTableFilterComposer
    extends Composer<_$AppDatabase, $InvestmentHoldingsTable> {
  $$InvestmentHoldingsTableFilterComposer({
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

  ColumnFilters<String> get bucketType => $composableBuilder(
    column: $table.bucketType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get investedAmount => $composableBuilder(
    column: $table.investedAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get currentValue => $composableBuilder(
    column: $table.currentValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get expectedReturnRate => $composableBuilder(
    column: $table.expectedReturnRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get monthlyContribution => $composableBuilder(
    column: $table.monthlyContribution,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get visibility => $composableBuilder(
    column: $table.visibility,
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

  $$AccountsTableFilterComposer get linkedAccountId {
    final $$AccountsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.linkedAccountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableFilterComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$GoalsTableFilterComposer get linkedGoalId {
    final $$GoalsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.linkedGoalId,
      referencedTable: $db.goals,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GoalsTableFilterComposer(
            $db: $db,
            $table: $db.goals,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$FamiliesTableFilterComposer get familyId {
    final $$FamiliesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.familyId,
      referencedTable: $db.families,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FamiliesTableFilterComposer(
            $db: $db,
            $table: $db.families,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$InvestmentHoldingsTableOrderingComposer
    extends Composer<_$AppDatabase, $InvestmentHoldingsTable> {
  $$InvestmentHoldingsTableOrderingComposer({
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

  ColumnOrderings<String> get bucketType => $composableBuilder(
    column: $table.bucketType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get investedAmount => $composableBuilder(
    column: $table.investedAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get currentValue => $composableBuilder(
    column: $table.currentValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get expectedReturnRate => $composableBuilder(
    column: $table.expectedReturnRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get monthlyContribution => $composableBuilder(
    column: $table.monthlyContribution,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get visibility => $composableBuilder(
    column: $table.visibility,
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

  $$AccountsTableOrderingComposer get linkedAccountId {
    final $$AccountsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.linkedAccountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableOrderingComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$GoalsTableOrderingComposer get linkedGoalId {
    final $$GoalsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.linkedGoalId,
      referencedTable: $db.goals,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GoalsTableOrderingComposer(
            $db: $db,
            $table: $db.goals,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$FamiliesTableOrderingComposer get familyId {
    final $$FamiliesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.familyId,
      referencedTable: $db.families,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FamiliesTableOrderingComposer(
            $db: $db,
            $table: $db.families,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$InvestmentHoldingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $InvestmentHoldingsTable> {
  $$InvestmentHoldingsTableAnnotationComposer({
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

  GeneratedColumn<String> get bucketType => $composableBuilder(
    column: $table.bucketType,
    builder: (column) => column,
  );

  GeneratedColumn<int> get investedAmount => $composableBuilder(
    column: $table.investedAmount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get currentValue => $composableBuilder(
    column: $table.currentValue,
    builder: (column) => column,
  );

  GeneratedColumn<double> get expectedReturnRate => $composableBuilder(
    column: $table.expectedReturnRate,
    builder: (column) => column,
  );

  GeneratedColumn<int> get monthlyContribution => $composableBuilder(
    column: $table.monthlyContribution,
    builder: (column) => column,
  );

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get visibility => $composableBuilder(
    column: $table.visibility,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$AccountsTableAnnotationComposer get linkedAccountId {
    final $$AccountsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.linkedAccountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableAnnotationComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$GoalsTableAnnotationComposer get linkedGoalId {
    final $$GoalsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.linkedGoalId,
      referencedTable: $db.goals,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GoalsTableAnnotationComposer(
            $db: $db,
            $table: $db.goals,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$FamiliesTableAnnotationComposer get familyId {
    final $$FamiliesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.familyId,
      referencedTable: $db.families,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FamiliesTableAnnotationComposer(
            $db: $db,
            $table: $db.families,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$InvestmentHoldingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $InvestmentHoldingsTable,
          InvestmentHolding,
          $$InvestmentHoldingsTableFilterComposer,
          $$InvestmentHoldingsTableOrderingComposer,
          $$InvestmentHoldingsTableAnnotationComposer,
          $$InvestmentHoldingsTableCreateCompanionBuilder,
          $$InvestmentHoldingsTableUpdateCompanionBuilder,
          (InvestmentHolding, $$InvestmentHoldingsTableReferences),
          InvestmentHolding,
          PrefetchHooks Function({
            bool linkedAccountId,
            bool linkedGoalId,
            bool familyId,
          })
        > {
  $$InvestmentHoldingsTableTableManager(
    _$AppDatabase db,
    $InvestmentHoldingsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InvestmentHoldingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InvestmentHoldingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InvestmentHoldingsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> bucketType = const Value.absent(),
                Value<int> investedAmount = const Value.absent(),
                Value<int> currentValue = const Value.absent(),
                Value<double> expectedReturnRate = const Value.absent(),
                Value<int> monthlyContribution = const Value.absent(),
                Value<String?> linkedAccountId = const Value.absent(),
                Value<String?> linkedGoalId = const Value.absent(),
                Value<String> familyId = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> visibility = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InvestmentHoldingsCompanion(
                id: id,
                name: name,
                bucketType: bucketType,
                investedAmount: investedAmount,
                currentValue: currentValue,
                expectedReturnRate: expectedReturnRate,
                monthlyContribution: monthlyContribution,
                linkedAccountId: linkedAccountId,
                linkedGoalId: linkedGoalId,
                familyId: familyId,
                userId: userId,
                visibility: visibility,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String bucketType,
                required int investedAmount,
                required int currentValue,
                Value<double> expectedReturnRate = const Value.absent(),
                Value<int> monthlyContribution = const Value.absent(),
                Value<String?> linkedAccountId = const Value.absent(),
                Value<String?> linkedGoalId = const Value.absent(),
                required String familyId,
                required String userId,
                Value<String> visibility = const Value.absent(),
                required DateTime createdAt,
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InvestmentHoldingsCompanion.insert(
                id: id,
                name: name,
                bucketType: bucketType,
                investedAmount: investedAmount,
                currentValue: currentValue,
                expectedReturnRate: expectedReturnRate,
                monthlyContribution: monthlyContribution,
                linkedAccountId: linkedAccountId,
                linkedGoalId: linkedGoalId,
                familyId: familyId,
                userId: userId,
                visibility: visibility,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$InvestmentHoldingsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                linkedAccountId = false,
                linkedGoalId = false,
                familyId = false,
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
                        if (linkedAccountId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.linkedAccountId,
                                    referencedTable:
                                        $$InvestmentHoldingsTableReferences
                                            ._linkedAccountIdTable(db),
                                    referencedColumn:
                                        $$InvestmentHoldingsTableReferences
                                            ._linkedAccountIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (linkedGoalId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.linkedGoalId,
                                    referencedTable:
                                        $$InvestmentHoldingsTableReferences
                                            ._linkedGoalIdTable(db),
                                    referencedColumn:
                                        $$InvestmentHoldingsTableReferences
                                            ._linkedGoalIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (familyId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.familyId,
                                    referencedTable:
                                        $$InvestmentHoldingsTableReferences
                                            ._familyIdTable(db),
                                    referencedColumn:
                                        $$InvestmentHoldingsTableReferences
                                            ._familyIdTable(db)
                                            .id,
                                  )
                                  as T;
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

typedef $$InvestmentHoldingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $InvestmentHoldingsTable,
      InvestmentHolding,
      $$InvestmentHoldingsTableFilterComposer,
      $$InvestmentHoldingsTableOrderingComposer,
      $$InvestmentHoldingsTableAnnotationComposer,
      $$InvestmentHoldingsTableCreateCompanionBuilder,
      $$InvestmentHoldingsTableUpdateCompanionBuilder,
      (InvestmentHolding, $$InvestmentHoldingsTableReferences),
      InvestmentHolding,
      PrefetchHooks Function({
        bool linkedAccountId,
        bool linkedGoalId,
        bool familyId,
      })
    >;
typedef $$LifeProfilesTableCreateCompanionBuilder =
    LifeProfilesCompanion Function({
      required String id,
      required String userId,
      required String familyId,
      required DateTime dateOfBirth,
      Value<int> plannedRetirementAge,
      Value<String> riskProfile,
      Value<int> annualIncomeGrowthBp,
      Value<int> expectedInflationBp,
      Value<int> safeWithdrawalRateBp,
      Value<int> hikeMonth,
      Value<String?> incomeStability,
      Value<int?> efTargetMonthsOverride,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });
typedef $$LifeProfilesTableUpdateCompanionBuilder =
    LifeProfilesCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<String> familyId,
      Value<DateTime> dateOfBirth,
      Value<int> plannedRetirementAge,
      Value<String> riskProfile,
      Value<int> annualIncomeGrowthBp,
      Value<int> expectedInflationBp,
      Value<int> safeWithdrawalRateBp,
      Value<int> hikeMonth,
      Value<String?> incomeStability,
      Value<int?> efTargetMonthsOverride,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });

final class $$LifeProfilesTableReferences
    extends BaseReferences<_$AppDatabase, $LifeProfilesTable, LifeProfile> {
  $$LifeProfilesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $FamiliesTable _familyIdTable(_$AppDatabase db) =>
      db.families.createAlias(
        $_aliasNameGenerator(db.lifeProfiles.familyId, db.families.id),
      );

  $$FamiliesTableProcessedTableManager get familyId {
    final $_column = $_itemColumn<String>('family_id')!;

    final manager = $$FamiliesTableTableManager(
      $_db,
      $_db.families,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_familyIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$NetWorthMilestonesTable, List<NetWorthMilestone>>
  _netWorthMilestonesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.netWorthMilestones,
        aliasName: $_aliasNameGenerator(
          db.lifeProfiles.id,
          db.netWorthMilestones.lifeProfileId,
        ),
      );

  $$NetWorthMilestonesTableProcessedTableManager get netWorthMilestonesRefs {
    final manager = $$NetWorthMilestonesTableTableManager(
      $_db,
      $_db.netWorthMilestones,
    ).filter((f) => f.lifeProfileId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _netWorthMilestonesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$AllocationTargetsTable, List<AllocationTarget>>
  _allocationTargetsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.allocationTargets,
        aliasName: $_aliasNameGenerator(
          db.lifeProfiles.id,
          db.allocationTargets.lifeProfileId,
        ),
      );

  $$AllocationTargetsTableProcessedTableManager get allocationTargetsRefs {
    final manager = $$AllocationTargetsTableTableManager(
      $_db,
      $_db.allocationTargets,
    ).filter((f) => f.lifeProfileId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _allocationTargetsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$LifeProfilesTableFilterComposer
    extends Composer<_$AppDatabase, $LifeProfilesTable> {
  $$LifeProfilesTableFilterComposer({
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

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dateOfBirth => $composableBuilder(
    column: $table.dateOfBirth,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get plannedRetirementAge => $composableBuilder(
    column: $table.plannedRetirementAge,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get riskProfile => $composableBuilder(
    column: $table.riskProfile,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get annualIncomeGrowthBp => $composableBuilder(
    column: $table.annualIncomeGrowthBp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get expectedInflationBp => $composableBuilder(
    column: $table.expectedInflationBp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get safeWithdrawalRateBp => $composableBuilder(
    column: $table.safeWithdrawalRateBp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get hikeMonth => $composableBuilder(
    column: $table.hikeMonth,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get incomeStability => $composableBuilder(
    column: $table.incomeStability,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get efTargetMonthsOverride => $composableBuilder(
    column: $table.efTargetMonthsOverride,
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

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$FamiliesTableFilterComposer get familyId {
    final $$FamiliesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.familyId,
      referencedTable: $db.families,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FamiliesTableFilterComposer(
            $db: $db,
            $table: $db.families,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> netWorthMilestonesRefs(
    Expression<bool> Function($$NetWorthMilestonesTableFilterComposer f) f,
  ) {
    final $$NetWorthMilestonesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.netWorthMilestones,
      getReferencedColumn: (t) => t.lifeProfileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NetWorthMilestonesTableFilterComposer(
            $db: $db,
            $table: $db.netWorthMilestones,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> allocationTargetsRefs(
    Expression<bool> Function($$AllocationTargetsTableFilterComposer f) f,
  ) {
    final $$AllocationTargetsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.allocationTargets,
      getReferencedColumn: (t) => t.lifeProfileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AllocationTargetsTableFilterComposer(
            $db: $db,
            $table: $db.allocationTargets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$LifeProfilesTableOrderingComposer
    extends Composer<_$AppDatabase, $LifeProfilesTable> {
  $$LifeProfilesTableOrderingComposer({
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

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dateOfBirth => $composableBuilder(
    column: $table.dateOfBirth,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get plannedRetirementAge => $composableBuilder(
    column: $table.plannedRetirementAge,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get riskProfile => $composableBuilder(
    column: $table.riskProfile,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get annualIncomeGrowthBp => $composableBuilder(
    column: $table.annualIncomeGrowthBp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get expectedInflationBp => $composableBuilder(
    column: $table.expectedInflationBp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get safeWithdrawalRateBp => $composableBuilder(
    column: $table.safeWithdrawalRateBp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get hikeMonth => $composableBuilder(
    column: $table.hikeMonth,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get incomeStability => $composableBuilder(
    column: $table.incomeStability,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get efTargetMonthsOverride => $composableBuilder(
    column: $table.efTargetMonthsOverride,
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

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$FamiliesTableOrderingComposer get familyId {
    final $$FamiliesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.familyId,
      referencedTable: $db.families,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FamiliesTableOrderingComposer(
            $db: $db,
            $table: $db.families,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LifeProfilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LifeProfilesTable> {
  $$LifeProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<DateTime> get dateOfBirth => $composableBuilder(
    column: $table.dateOfBirth,
    builder: (column) => column,
  );

  GeneratedColumn<int> get plannedRetirementAge => $composableBuilder(
    column: $table.plannedRetirementAge,
    builder: (column) => column,
  );

  GeneratedColumn<String> get riskProfile => $composableBuilder(
    column: $table.riskProfile,
    builder: (column) => column,
  );

  GeneratedColumn<int> get annualIncomeGrowthBp => $composableBuilder(
    column: $table.annualIncomeGrowthBp,
    builder: (column) => column,
  );

  GeneratedColumn<int> get expectedInflationBp => $composableBuilder(
    column: $table.expectedInflationBp,
    builder: (column) => column,
  );

  GeneratedColumn<int> get safeWithdrawalRateBp => $composableBuilder(
    column: $table.safeWithdrawalRateBp,
    builder: (column) => column,
  );

  GeneratedColumn<int> get hikeMonth =>
      $composableBuilder(column: $table.hikeMonth, builder: (column) => column);

  GeneratedColumn<String> get incomeStability => $composableBuilder(
    column: $table.incomeStability,
    builder: (column) => column,
  );

  GeneratedColumn<int> get efTargetMonthsOverride => $composableBuilder(
    column: $table.efTargetMonthsOverride,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  $$FamiliesTableAnnotationComposer get familyId {
    final $$FamiliesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.familyId,
      referencedTable: $db.families,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FamiliesTableAnnotationComposer(
            $db: $db,
            $table: $db.families,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> netWorthMilestonesRefs<T extends Object>(
    Expression<T> Function($$NetWorthMilestonesTableAnnotationComposer a) f,
  ) {
    final $$NetWorthMilestonesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.netWorthMilestones,
          getReferencedColumn: (t) => t.lifeProfileId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$NetWorthMilestonesTableAnnotationComposer(
                $db: $db,
                $table: $db.netWorthMilestones,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> allocationTargetsRefs<T extends Object>(
    Expression<T> Function($$AllocationTargetsTableAnnotationComposer a) f,
  ) {
    final $$AllocationTargetsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.allocationTargets,
          getReferencedColumn: (t) => t.lifeProfileId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$AllocationTargetsTableAnnotationComposer(
                $db: $db,
                $table: $db.allocationTargets,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$LifeProfilesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LifeProfilesTable,
          LifeProfile,
          $$LifeProfilesTableFilterComposer,
          $$LifeProfilesTableOrderingComposer,
          $$LifeProfilesTableAnnotationComposer,
          $$LifeProfilesTableCreateCompanionBuilder,
          $$LifeProfilesTableUpdateCompanionBuilder,
          (LifeProfile, $$LifeProfilesTableReferences),
          LifeProfile,
          PrefetchHooks Function({
            bool familyId,
            bool netWorthMilestonesRefs,
            bool allocationTargetsRefs,
          })
        > {
  $$LifeProfilesTableTableManager(_$AppDatabase db, $LifeProfilesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LifeProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LifeProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LifeProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> familyId = const Value.absent(),
                Value<DateTime> dateOfBirth = const Value.absent(),
                Value<int> plannedRetirementAge = const Value.absent(),
                Value<String> riskProfile = const Value.absent(),
                Value<int> annualIncomeGrowthBp = const Value.absent(),
                Value<int> expectedInflationBp = const Value.absent(),
                Value<int> safeWithdrawalRateBp = const Value.absent(),
                Value<int> hikeMonth = const Value.absent(),
                Value<String?> incomeStability = const Value.absent(),
                Value<int?> efTargetMonthsOverride = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LifeProfilesCompanion(
                id: id,
                userId: userId,
                familyId: familyId,
                dateOfBirth: dateOfBirth,
                plannedRetirementAge: plannedRetirementAge,
                riskProfile: riskProfile,
                annualIncomeGrowthBp: annualIncomeGrowthBp,
                expectedInflationBp: expectedInflationBp,
                safeWithdrawalRateBp: safeWithdrawalRateBp,
                hikeMonth: hikeMonth,
                incomeStability: incomeStability,
                efTargetMonthsOverride: efTargetMonthsOverride,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                required String familyId,
                required DateTime dateOfBirth,
                Value<int> plannedRetirementAge = const Value.absent(),
                Value<String> riskProfile = const Value.absent(),
                Value<int> annualIncomeGrowthBp = const Value.absent(),
                Value<int> expectedInflationBp = const Value.absent(),
                Value<int> safeWithdrawalRateBp = const Value.absent(),
                Value<int> hikeMonth = const Value.absent(),
                Value<String?> incomeStability = const Value.absent(),
                Value<int?> efTargetMonthsOverride = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LifeProfilesCompanion.insert(
                id: id,
                userId: userId,
                familyId: familyId,
                dateOfBirth: dateOfBirth,
                plannedRetirementAge: plannedRetirementAge,
                riskProfile: riskProfile,
                annualIncomeGrowthBp: annualIncomeGrowthBp,
                expectedInflationBp: expectedInflationBp,
                safeWithdrawalRateBp: safeWithdrawalRateBp,
                hikeMonth: hikeMonth,
                incomeStability: incomeStability,
                efTargetMonthsOverride: efTargetMonthsOverride,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$LifeProfilesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                familyId = false,
                netWorthMilestonesRefs = false,
                allocationTargetsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (netWorthMilestonesRefs) db.netWorthMilestones,
                    if (allocationTargetsRefs) db.allocationTargets,
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
                        if (familyId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.familyId,
                                    referencedTable:
                                        $$LifeProfilesTableReferences
                                            ._familyIdTable(db),
                                    referencedColumn:
                                        $$LifeProfilesTableReferences
                                            ._familyIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (netWorthMilestonesRefs)
                        await $_getPrefetchedData<
                          LifeProfile,
                          $LifeProfilesTable,
                          NetWorthMilestone
                        >(
                          currentTable: table,
                          referencedTable: $$LifeProfilesTableReferences
                              ._netWorthMilestonesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$LifeProfilesTableReferences(
                                db,
                                table,
                                p0,
                              ).netWorthMilestonesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.lifeProfileId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (allocationTargetsRefs)
                        await $_getPrefetchedData<
                          LifeProfile,
                          $LifeProfilesTable,
                          AllocationTarget
                        >(
                          currentTable: table,
                          referencedTable: $$LifeProfilesTableReferences
                              ._allocationTargetsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$LifeProfilesTableReferences(
                                db,
                                table,
                                p0,
                              ).allocationTargetsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.lifeProfileId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$LifeProfilesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LifeProfilesTable,
      LifeProfile,
      $$LifeProfilesTableFilterComposer,
      $$LifeProfilesTableOrderingComposer,
      $$LifeProfilesTableAnnotationComposer,
      $$LifeProfilesTableCreateCompanionBuilder,
      $$LifeProfilesTableUpdateCompanionBuilder,
      (LifeProfile, $$LifeProfilesTableReferences),
      LifeProfile,
      PrefetchHooks Function({
        bool familyId,
        bool netWorthMilestonesRefs,
        bool allocationTargetsRefs,
      })
    >;
typedef $$NetWorthMilestonesTableCreateCompanionBuilder =
    NetWorthMilestonesCompanion Function({
      required String id,
      required String userId,
      required String familyId,
      required String lifeProfileId,
      required int targetAge,
      required int targetAmountPaise,
      Value<bool> isCustomTarget,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });
typedef $$NetWorthMilestonesTableUpdateCompanionBuilder =
    NetWorthMilestonesCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<String> familyId,
      Value<String> lifeProfileId,
      Value<int> targetAge,
      Value<int> targetAmountPaise,
      Value<bool> isCustomTarget,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });

final class $$NetWorthMilestonesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $NetWorthMilestonesTable,
          NetWorthMilestone
        > {
  $$NetWorthMilestonesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $FamiliesTable _familyIdTable(_$AppDatabase db) =>
      db.families.createAlias(
        $_aliasNameGenerator(db.netWorthMilestones.familyId, db.families.id),
      );

  $$FamiliesTableProcessedTableManager get familyId {
    final $_column = $_itemColumn<String>('family_id')!;

    final manager = $$FamiliesTableTableManager(
      $_db,
      $_db.families,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_familyIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $LifeProfilesTable _lifeProfileIdTable(_$AppDatabase db) =>
      db.lifeProfiles.createAlias(
        $_aliasNameGenerator(
          db.netWorthMilestones.lifeProfileId,
          db.lifeProfiles.id,
        ),
      );

  $$LifeProfilesTableProcessedTableManager get lifeProfileId {
    final $_column = $_itemColumn<String>('life_profile_id')!;

    final manager = $$LifeProfilesTableTableManager(
      $_db,
      $_db.lifeProfiles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_lifeProfileIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$NetWorthMilestonesTableFilterComposer
    extends Composer<_$AppDatabase, $NetWorthMilestonesTable> {
  $$NetWorthMilestonesTableFilterComposer({
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

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get targetAge => $composableBuilder(
    column: $table.targetAge,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get targetAmountPaise => $composableBuilder(
    column: $table.targetAmountPaise,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCustomTarget => $composableBuilder(
    column: $table.isCustomTarget,
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

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$FamiliesTableFilterComposer get familyId {
    final $$FamiliesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.familyId,
      referencedTable: $db.families,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FamiliesTableFilterComposer(
            $db: $db,
            $table: $db.families,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$LifeProfilesTableFilterComposer get lifeProfileId {
    final $$LifeProfilesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.lifeProfileId,
      referencedTable: $db.lifeProfiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LifeProfilesTableFilterComposer(
            $db: $db,
            $table: $db.lifeProfiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$NetWorthMilestonesTableOrderingComposer
    extends Composer<_$AppDatabase, $NetWorthMilestonesTable> {
  $$NetWorthMilestonesTableOrderingComposer({
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

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get targetAge => $composableBuilder(
    column: $table.targetAge,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get targetAmountPaise => $composableBuilder(
    column: $table.targetAmountPaise,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCustomTarget => $composableBuilder(
    column: $table.isCustomTarget,
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

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$FamiliesTableOrderingComposer get familyId {
    final $$FamiliesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.familyId,
      referencedTable: $db.families,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FamiliesTableOrderingComposer(
            $db: $db,
            $table: $db.families,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$LifeProfilesTableOrderingComposer get lifeProfileId {
    final $$LifeProfilesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.lifeProfileId,
      referencedTable: $db.lifeProfiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LifeProfilesTableOrderingComposer(
            $db: $db,
            $table: $db.lifeProfiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$NetWorthMilestonesTableAnnotationComposer
    extends Composer<_$AppDatabase, $NetWorthMilestonesTable> {
  $$NetWorthMilestonesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<int> get targetAge =>
      $composableBuilder(column: $table.targetAge, builder: (column) => column);

  GeneratedColumn<int> get targetAmountPaise => $composableBuilder(
    column: $table.targetAmountPaise,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isCustomTarget => $composableBuilder(
    column: $table.isCustomTarget,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  $$FamiliesTableAnnotationComposer get familyId {
    final $$FamiliesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.familyId,
      referencedTable: $db.families,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FamiliesTableAnnotationComposer(
            $db: $db,
            $table: $db.families,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$LifeProfilesTableAnnotationComposer get lifeProfileId {
    final $$LifeProfilesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.lifeProfileId,
      referencedTable: $db.lifeProfiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LifeProfilesTableAnnotationComposer(
            $db: $db,
            $table: $db.lifeProfiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$NetWorthMilestonesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $NetWorthMilestonesTable,
          NetWorthMilestone,
          $$NetWorthMilestonesTableFilterComposer,
          $$NetWorthMilestonesTableOrderingComposer,
          $$NetWorthMilestonesTableAnnotationComposer,
          $$NetWorthMilestonesTableCreateCompanionBuilder,
          $$NetWorthMilestonesTableUpdateCompanionBuilder,
          (NetWorthMilestone, $$NetWorthMilestonesTableReferences),
          NetWorthMilestone,
          PrefetchHooks Function({bool familyId, bool lifeProfileId})
        > {
  $$NetWorthMilestonesTableTableManager(
    _$AppDatabase db,
    $NetWorthMilestonesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NetWorthMilestonesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NetWorthMilestonesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NetWorthMilestonesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> familyId = const Value.absent(),
                Value<String> lifeProfileId = const Value.absent(),
                Value<int> targetAge = const Value.absent(),
                Value<int> targetAmountPaise = const Value.absent(),
                Value<bool> isCustomTarget = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => NetWorthMilestonesCompanion(
                id: id,
                userId: userId,
                familyId: familyId,
                lifeProfileId: lifeProfileId,
                targetAge: targetAge,
                targetAmountPaise: targetAmountPaise,
                isCustomTarget: isCustomTarget,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                required String familyId,
                required String lifeProfileId,
                required int targetAge,
                required int targetAmountPaise,
                Value<bool> isCustomTarget = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => NetWorthMilestonesCompanion.insert(
                id: id,
                userId: userId,
                familyId: familyId,
                lifeProfileId: lifeProfileId,
                targetAge: targetAge,
                targetAmountPaise: targetAmountPaise,
                isCustomTarget: isCustomTarget,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$NetWorthMilestonesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({familyId = false, lifeProfileId = false}) {
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
                    if (familyId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.familyId,
                                referencedTable:
                                    $$NetWorthMilestonesTableReferences
                                        ._familyIdTable(db),
                                referencedColumn:
                                    $$NetWorthMilestonesTableReferences
                                        ._familyIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (lifeProfileId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.lifeProfileId,
                                referencedTable:
                                    $$NetWorthMilestonesTableReferences
                                        ._lifeProfileIdTable(db),
                                referencedColumn:
                                    $$NetWorthMilestonesTableReferences
                                        ._lifeProfileIdTable(db)
                                        .id,
                              )
                              as T;
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

typedef $$NetWorthMilestonesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $NetWorthMilestonesTable,
      NetWorthMilestone,
      $$NetWorthMilestonesTableFilterComposer,
      $$NetWorthMilestonesTableOrderingComposer,
      $$NetWorthMilestonesTableAnnotationComposer,
      $$NetWorthMilestonesTableCreateCompanionBuilder,
      $$NetWorthMilestonesTableUpdateCompanionBuilder,
      (NetWorthMilestone, $$NetWorthMilestonesTableReferences),
      NetWorthMilestone,
      PrefetchHooks Function({bool familyId, bool lifeProfileId})
    >;
typedef $$RecurringRulesTableCreateCompanionBuilder =
    RecurringRulesCompanion Function({
      required String id,
      required String name,
      required String kind,
      required int amount,
      required String accountId,
      Value<String?> toAccountId,
      Value<String?> categoryId,
      required double frequencyMonths,
      required DateTime startDate,
      Value<DateTime?> endDate,
      Value<bool> isPaused,
      Value<DateTime?> pausedAt,
      Value<DateTime?> lastExecutedDate,
      Value<double> annualEscalationRate,
      required String familyId,
      required String userId,
      required DateTime createdAt,
      Value<DateTime?> deletedAt,
      Value<bool> isSecondaryIncome,
      Value<String?> decisionId,
      Value<int> rowid,
    });
typedef $$RecurringRulesTableUpdateCompanionBuilder =
    RecurringRulesCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> kind,
      Value<int> amount,
      Value<String> accountId,
      Value<String?> toAccountId,
      Value<String?> categoryId,
      Value<double> frequencyMonths,
      Value<DateTime> startDate,
      Value<DateTime?> endDate,
      Value<bool> isPaused,
      Value<DateTime?> pausedAt,
      Value<DateTime?> lastExecutedDate,
      Value<double> annualEscalationRate,
      Value<String> familyId,
      Value<String> userId,
      Value<DateTime> createdAt,
      Value<DateTime?> deletedAt,
      Value<bool> isSecondaryIncome,
      Value<String?> decisionId,
      Value<int> rowid,
    });

final class $$RecurringRulesTableReferences
    extends BaseReferences<_$AppDatabase, $RecurringRulesTable, RecurringRule> {
  $$RecurringRulesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $AccountsTable _accountIdTable(_$AppDatabase db) =>
      db.accounts.createAlias(
        $_aliasNameGenerator(db.recurringRules.accountId, db.accounts.id),
      );

  $$AccountsTableProcessedTableManager get accountId {
    final $_column = $_itemColumn<String>('account_id')!;

    final manager = $$AccountsTableTableManager(
      $_db,
      $_db.accounts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_accountIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $AccountsTable _toAccountIdTable(_$AppDatabase db) =>
      db.accounts.createAlias(
        $_aliasNameGenerator(db.recurringRules.toAccountId, db.accounts.id),
      );

  $$AccountsTableProcessedTableManager? get toAccountId {
    final $_column = $_itemColumn<String>('to_account_id');
    if ($_column == null) return null;
    final manager = $$AccountsTableTableManager(
      $_db,
      $_db.accounts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_toAccountIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $CategoriesTable _categoryIdTable(_$AppDatabase db) =>
      db.categories.createAlias(
        $_aliasNameGenerator(db.recurringRules.categoryId, db.categories.id),
      );

  $$CategoriesTableProcessedTableManager? get categoryId {
    final $_column = $_itemColumn<String>('category_id');
    if ($_column == null) return null;
    final manager = $$CategoriesTableTableManager(
      $_db,
      $_db.categories,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $FamiliesTable _familyIdTable(_$AppDatabase db) =>
      db.families.createAlias(
        $_aliasNameGenerator(db.recurringRules.familyId, db.families.id),
      );

  $$FamiliesTableProcessedTableManager get familyId {
    final $_column = $_itemColumn<String>('family_id')!;

    final manager = $$FamiliesTableTableManager(
      $_db,
      $_db.families,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_familyIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$RecurringRulesTableFilterComposer
    extends Composer<_$AppDatabase, $RecurringRulesTable> {
  $$RecurringRulesTableFilterComposer({
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

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get frequencyMonths => $composableBuilder(
    column: $table.frequencyMonths,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isPaused => $composableBuilder(
    column: $table.isPaused,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get pausedAt => $composableBuilder(
    column: $table.pausedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastExecutedDate => $composableBuilder(
    column: $table.lastExecutedDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get annualEscalationRate => $composableBuilder(
    column: $table.annualEscalationRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSecondaryIncome => $composableBuilder(
    column: $table.isSecondaryIncome,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get decisionId => $composableBuilder(
    column: $table.decisionId,
    builder: (column) => ColumnFilters(column),
  );

  $$AccountsTableFilterComposer get accountId {
    final $$AccountsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableFilterComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AccountsTableFilterComposer get toAccountId {
    final $$AccountsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.toAccountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableFilterComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CategoriesTableFilterComposer get categoryId {
    final $$CategoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableFilterComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$FamiliesTableFilterComposer get familyId {
    final $$FamiliesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.familyId,
      referencedTable: $db.families,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FamiliesTableFilterComposer(
            $db: $db,
            $table: $db.families,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RecurringRulesTableOrderingComposer
    extends Composer<_$AppDatabase, $RecurringRulesTable> {
  $$RecurringRulesTableOrderingComposer({
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

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get frequencyMonths => $composableBuilder(
    column: $table.frequencyMonths,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isPaused => $composableBuilder(
    column: $table.isPaused,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get pausedAt => $composableBuilder(
    column: $table.pausedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastExecutedDate => $composableBuilder(
    column: $table.lastExecutedDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get annualEscalationRate => $composableBuilder(
    column: $table.annualEscalationRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSecondaryIncome => $composableBuilder(
    column: $table.isSecondaryIncome,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get decisionId => $composableBuilder(
    column: $table.decisionId,
    builder: (column) => ColumnOrderings(column),
  );

  $$AccountsTableOrderingComposer get accountId {
    final $$AccountsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableOrderingComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AccountsTableOrderingComposer get toAccountId {
    final $$AccountsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.toAccountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableOrderingComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CategoriesTableOrderingComposer get categoryId {
    final $$CategoriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableOrderingComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$FamiliesTableOrderingComposer get familyId {
    final $$FamiliesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.familyId,
      referencedTable: $db.families,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FamiliesTableOrderingComposer(
            $db: $db,
            $table: $db.families,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RecurringRulesTableAnnotationComposer
    extends Composer<_$AppDatabase, $RecurringRulesTable> {
  $$RecurringRulesTableAnnotationComposer({
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

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<int> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<double> get frequencyMonths => $composableBuilder(
    column: $table.frequencyMonths,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<DateTime> get endDate =>
      $composableBuilder(column: $table.endDate, builder: (column) => column);

  GeneratedColumn<bool> get isPaused =>
      $composableBuilder(column: $table.isPaused, builder: (column) => column);

  GeneratedColumn<DateTime> get pausedAt =>
      $composableBuilder(column: $table.pausedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastExecutedDate => $composableBuilder(
    column: $table.lastExecutedDate,
    builder: (column) => column,
  );

  GeneratedColumn<double> get annualEscalationRate => $composableBuilder(
    column: $table.annualEscalationRate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<bool> get isSecondaryIncome => $composableBuilder(
    column: $table.isSecondaryIncome,
    builder: (column) => column,
  );

  GeneratedColumn<String> get decisionId => $composableBuilder(
    column: $table.decisionId,
    builder: (column) => column,
  );

  $$AccountsTableAnnotationComposer get accountId {
    final $$AccountsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableAnnotationComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AccountsTableAnnotationComposer get toAccountId {
    final $$AccountsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.toAccountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableAnnotationComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CategoriesTableAnnotationComposer get categoryId {
    final $$CategoriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableAnnotationComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$FamiliesTableAnnotationComposer get familyId {
    final $$FamiliesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.familyId,
      referencedTable: $db.families,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FamiliesTableAnnotationComposer(
            $db: $db,
            $table: $db.families,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RecurringRulesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RecurringRulesTable,
          RecurringRule,
          $$RecurringRulesTableFilterComposer,
          $$RecurringRulesTableOrderingComposer,
          $$RecurringRulesTableAnnotationComposer,
          $$RecurringRulesTableCreateCompanionBuilder,
          $$RecurringRulesTableUpdateCompanionBuilder,
          (RecurringRule, $$RecurringRulesTableReferences),
          RecurringRule,
          PrefetchHooks Function({
            bool accountId,
            bool toAccountId,
            bool categoryId,
            bool familyId,
          })
        > {
  $$RecurringRulesTableTableManager(
    _$AppDatabase db,
    $RecurringRulesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecurringRulesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RecurringRulesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RecurringRulesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<int> amount = const Value.absent(),
                Value<String> accountId = const Value.absent(),
                Value<String?> toAccountId = const Value.absent(),
                Value<String?> categoryId = const Value.absent(),
                Value<double> frequencyMonths = const Value.absent(),
                Value<DateTime> startDate = const Value.absent(),
                Value<DateTime?> endDate = const Value.absent(),
                Value<bool> isPaused = const Value.absent(),
                Value<DateTime?> pausedAt = const Value.absent(),
                Value<DateTime?> lastExecutedDate = const Value.absent(),
                Value<double> annualEscalationRate = const Value.absent(),
                Value<String> familyId = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<bool> isSecondaryIncome = const Value.absent(),
                Value<String?> decisionId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RecurringRulesCompanion(
                id: id,
                name: name,
                kind: kind,
                amount: amount,
                accountId: accountId,
                toAccountId: toAccountId,
                categoryId: categoryId,
                frequencyMonths: frequencyMonths,
                startDate: startDate,
                endDate: endDate,
                isPaused: isPaused,
                pausedAt: pausedAt,
                lastExecutedDate: lastExecutedDate,
                annualEscalationRate: annualEscalationRate,
                familyId: familyId,
                userId: userId,
                createdAt: createdAt,
                deletedAt: deletedAt,
                isSecondaryIncome: isSecondaryIncome,
                decisionId: decisionId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String kind,
                required int amount,
                required String accountId,
                Value<String?> toAccountId = const Value.absent(),
                Value<String?> categoryId = const Value.absent(),
                required double frequencyMonths,
                required DateTime startDate,
                Value<DateTime?> endDate = const Value.absent(),
                Value<bool> isPaused = const Value.absent(),
                Value<DateTime?> pausedAt = const Value.absent(),
                Value<DateTime?> lastExecutedDate = const Value.absent(),
                Value<double> annualEscalationRate = const Value.absent(),
                required String familyId,
                required String userId,
                required DateTime createdAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<bool> isSecondaryIncome = const Value.absent(),
                Value<String?> decisionId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RecurringRulesCompanion.insert(
                id: id,
                name: name,
                kind: kind,
                amount: amount,
                accountId: accountId,
                toAccountId: toAccountId,
                categoryId: categoryId,
                frequencyMonths: frequencyMonths,
                startDate: startDate,
                endDate: endDate,
                isPaused: isPaused,
                pausedAt: pausedAt,
                lastExecutedDate: lastExecutedDate,
                annualEscalationRate: annualEscalationRate,
                familyId: familyId,
                userId: userId,
                createdAt: createdAt,
                deletedAt: deletedAt,
                isSecondaryIncome: isSecondaryIncome,
                decisionId: decisionId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$RecurringRulesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                accountId = false,
                toAccountId = false,
                categoryId = false,
                familyId = false,
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
                        if (accountId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.accountId,
                                    referencedTable:
                                        $$RecurringRulesTableReferences
                                            ._accountIdTable(db),
                                    referencedColumn:
                                        $$RecurringRulesTableReferences
                                            ._accountIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (toAccountId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.toAccountId,
                                    referencedTable:
                                        $$RecurringRulesTableReferences
                                            ._toAccountIdTable(db),
                                    referencedColumn:
                                        $$RecurringRulesTableReferences
                                            ._toAccountIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (categoryId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.categoryId,
                                    referencedTable:
                                        $$RecurringRulesTableReferences
                                            ._categoryIdTable(db),
                                    referencedColumn:
                                        $$RecurringRulesTableReferences
                                            ._categoryIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (familyId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.familyId,
                                    referencedTable:
                                        $$RecurringRulesTableReferences
                                            ._familyIdTable(db),
                                    referencedColumn:
                                        $$RecurringRulesTableReferences
                                            ._familyIdTable(db)
                                            .id,
                                  )
                                  as T;
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

typedef $$RecurringRulesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RecurringRulesTable,
      RecurringRule,
      $$RecurringRulesTableFilterComposer,
      $$RecurringRulesTableOrderingComposer,
      $$RecurringRulesTableAnnotationComposer,
      $$RecurringRulesTableCreateCompanionBuilder,
      $$RecurringRulesTableUpdateCompanionBuilder,
      (RecurringRule, $$RecurringRulesTableReferences),
      RecurringRule,
      PrefetchHooks Function({
        bool accountId,
        bool toAccountId,
        bool categoryId,
        bool familyId,
      })
    >;
typedef $$AllocationTargetsTableCreateCompanionBuilder =
    AllocationTargetsCompanion Function({
      required String id,
      required String lifeProfileId,
      required int ageBandStart,
      required int ageBandEnd,
      required int equityBp,
      required int debtBp,
      required int goldBp,
      required int cashBp,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$AllocationTargetsTableUpdateCompanionBuilder =
    AllocationTargetsCompanion Function({
      Value<String> id,
      Value<String> lifeProfileId,
      Value<int> ageBandStart,
      Value<int> ageBandEnd,
      Value<int> equityBp,
      Value<int> debtBp,
      Value<int> goldBp,
      Value<int> cashBp,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$AllocationTargetsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $AllocationTargetsTable,
          AllocationTarget
        > {
  $$AllocationTargetsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $LifeProfilesTable _lifeProfileIdTable(_$AppDatabase db) =>
      db.lifeProfiles.createAlias(
        $_aliasNameGenerator(
          db.allocationTargets.lifeProfileId,
          db.lifeProfiles.id,
        ),
      );

  $$LifeProfilesTableProcessedTableManager get lifeProfileId {
    final $_column = $_itemColumn<String>('life_profile_id')!;

    final manager = $$LifeProfilesTableTableManager(
      $_db,
      $_db.lifeProfiles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_lifeProfileIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$AllocationTargetsTableFilterComposer
    extends Composer<_$AppDatabase, $AllocationTargetsTable> {
  $$AllocationTargetsTableFilterComposer({
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

  ColumnFilters<int> get ageBandStart => $composableBuilder(
    column: $table.ageBandStart,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ageBandEnd => $composableBuilder(
    column: $table.ageBandEnd,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get equityBp => $composableBuilder(
    column: $table.equityBp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get debtBp => $composableBuilder(
    column: $table.debtBp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get goldBp => $composableBuilder(
    column: $table.goldBp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cashBp => $composableBuilder(
    column: $table.cashBp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$LifeProfilesTableFilterComposer get lifeProfileId {
    final $$LifeProfilesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.lifeProfileId,
      referencedTable: $db.lifeProfiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LifeProfilesTableFilterComposer(
            $db: $db,
            $table: $db.lifeProfiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AllocationTargetsTableOrderingComposer
    extends Composer<_$AppDatabase, $AllocationTargetsTable> {
  $$AllocationTargetsTableOrderingComposer({
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

  ColumnOrderings<int> get ageBandStart => $composableBuilder(
    column: $table.ageBandStart,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ageBandEnd => $composableBuilder(
    column: $table.ageBandEnd,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get equityBp => $composableBuilder(
    column: $table.equityBp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get debtBp => $composableBuilder(
    column: $table.debtBp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get goldBp => $composableBuilder(
    column: $table.goldBp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cashBp => $composableBuilder(
    column: $table.cashBp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$LifeProfilesTableOrderingComposer get lifeProfileId {
    final $$LifeProfilesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.lifeProfileId,
      referencedTable: $db.lifeProfiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LifeProfilesTableOrderingComposer(
            $db: $db,
            $table: $db.lifeProfiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AllocationTargetsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AllocationTargetsTable> {
  $$AllocationTargetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get ageBandStart => $composableBuilder(
    column: $table.ageBandStart,
    builder: (column) => column,
  );

  GeneratedColumn<int> get ageBandEnd => $composableBuilder(
    column: $table.ageBandEnd,
    builder: (column) => column,
  );

  GeneratedColumn<int> get equityBp =>
      $composableBuilder(column: $table.equityBp, builder: (column) => column);

  GeneratedColumn<int> get debtBp =>
      $composableBuilder(column: $table.debtBp, builder: (column) => column);

  GeneratedColumn<int> get goldBp =>
      $composableBuilder(column: $table.goldBp, builder: (column) => column);

  GeneratedColumn<int> get cashBp =>
      $composableBuilder(column: $table.cashBp, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$LifeProfilesTableAnnotationComposer get lifeProfileId {
    final $$LifeProfilesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.lifeProfileId,
      referencedTable: $db.lifeProfiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LifeProfilesTableAnnotationComposer(
            $db: $db,
            $table: $db.lifeProfiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AllocationTargetsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AllocationTargetsTable,
          AllocationTarget,
          $$AllocationTargetsTableFilterComposer,
          $$AllocationTargetsTableOrderingComposer,
          $$AllocationTargetsTableAnnotationComposer,
          $$AllocationTargetsTableCreateCompanionBuilder,
          $$AllocationTargetsTableUpdateCompanionBuilder,
          (AllocationTarget, $$AllocationTargetsTableReferences),
          AllocationTarget,
          PrefetchHooks Function({bool lifeProfileId})
        > {
  $$AllocationTargetsTableTableManager(
    _$AppDatabase db,
    $AllocationTargetsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AllocationTargetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AllocationTargetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AllocationTargetsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> lifeProfileId = const Value.absent(),
                Value<int> ageBandStart = const Value.absent(),
                Value<int> ageBandEnd = const Value.absent(),
                Value<int> equityBp = const Value.absent(),
                Value<int> debtBp = const Value.absent(),
                Value<int> goldBp = const Value.absent(),
                Value<int> cashBp = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AllocationTargetsCompanion(
                id: id,
                lifeProfileId: lifeProfileId,
                ageBandStart: ageBandStart,
                ageBandEnd: ageBandEnd,
                equityBp: equityBp,
                debtBp: debtBp,
                goldBp: goldBp,
                cashBp: cashBp,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String lifeProfileId,
                required int ageBandStart,
                required int ageBandEnd,
                required int equityBp,
                required int debtBp,
                required int goldBp,
                required int cashBp,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => AllocationTargetsCompanion.insert(
                id: id,
                lifeProfileId: lifeProfileId,
                ageBandStart: ageBandStart,
                ageBandEnd: ageBandEnd,
                equityBp: equityBp,
                debtBp: debtBp,
                goldBp: goldBp,
                cashBp: cashBp,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$AllocationTargetsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({lifeProfileId = false}) {
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
                    if (lifeProfileId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.lifeProfileId,
                                referencedTable:
                                    $$AllocationTargetsTableReferences
                                        ._lifeProfileIdTable(db),
                                referencedColumn:
                                    $$AllocationTargetsTableReferences
                                        ._lifeProfileIdTable(db)
                                        .id,
                              )
                              as T;
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

typedef $$AllocationTargetsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AllocationTargetsTable,
      AllocationTarget,
      $$AllocationTargetsTableFilterComposer,
      $$AllocationTargetsTableOrderingComposer,
      $$AllocationTargetsTableAnnotationComposer,
      $$AllocationTargetsTableCreateCompanionBuilder,
      $$AllocationTargetsTableUpdateCompanionBuilder,
      (AllocationTarget, $$AllocationTargetsTableReferences),
      AllocationTarget,
      PrefetchHooks Function({bool lifeProfileId})
    >;
typedef $$DecisionsTableCreateCompanionBuilder =
    DecisionsCompanion Function({
      required String id,
      required String userId,
      required String familyId,
      required String decisionType,
      required String name,
      required String parameters,
      Value<String> status,
      Value<int?> fiDelayYears,
      required DateTime createdAt,
      Value<DateTime?> implementedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });
typedef $$DecisionsTableUpdateCompanionBuilder =
    DecisionsCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<String> familyId,
      Value<String> decisionType,
      Value<String> name,
      Value<String> parameters,
      Value<String> status,
      Value<int?> fiDelayYears,
      Value<DateTime> createdAt,
      Value<DateTime?> implementedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });

final class $$DecisionsTableReferences
    extends BaseReferences<_$AppDatabase, $DecisionsTable, Decision> {
  $$DecisionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $FamiliesTable _familyIdTable(_$AppDatabase db) => db.families
      .createAlias($_aliasNameGenerator(db.decisions.familyId, db.families.id));

  $$FamiliesTableProcessedTableManager get familyId {
    final $_column = $_itemColumn<String>('family_id')!;

    final manager = $$FamiliesTableTableManager(
      $_db,
      $_db.families,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_familyIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$DecisionsTableFilterComposer
    extends Composer<_$AppDatabase, $DecisionsTable> {
  $$DecisionsTableFilterComposer({
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

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get decisionType => $composableBuilder(
    column: $table.decisionType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get parameters => $composableBuilder(
    column: $table.parameters,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fiDelayYears => $composableBuilder(
    column: $table.fiDelayYears,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get implementedAt => $composableBuilder(
    column: $table.implementedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$FamiliesTableFilterComposer get familyId {
    final $$FamiliesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.familyId,
      referencedTable: $db.families,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FamiliesTableFilterComposer(
            $db: $db,
            $table: $db.families,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DecisionsTableOrderingComposer
    extends Composer<_$AppDatabase, $DecisionsTable> {
  $$DecisionsTableOrderingComposer({
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

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get decisionType => $composableBuilder(
    column: $table.decisionType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get parameters => $composableBuilder(
    column: $table.parameters,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fiDelayYears => $composableBuilder(
    column: $table.fiDelayYears,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get implementedAt => $composableBuilder(
    column: $table.implementedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$FamiliesTableOrderingComposer get familyId {
    final $$FamiliesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.familyId,
      referencedTable: $db.families,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FamiliesTableOrderingComposer(
            $db: $db,
            $table: $db.families,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DecisionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DecisionsTable> {
  $$DecisionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get decisionType => $composableBuilder(
    column: $table.decisionType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get parameters => $composableBuilder(
    column: $table.parameters,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get fiDelayYears => $composableBuilder(
    column: $table.fiDelayYears,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get implementedAt => $composableBuilder(
    column: $table.implementedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  $$FamiliesTableAnnotationComposer get familyId {
    final $$FamiliesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.familyId,
      referencedTable: $db.families,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FamiliesTableAnnotationComposer(
            $db: $db,
            $table: $db.families,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DecisionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DecisionsTable,
          Decision,
          $$DecisionsTableFilterComposer,
          $$DecisionsTableOrderingComposer,
          $$DecisionsTableAnnotationComposer,
          $$DecisionsTableCreateCompanionBuilder,
          $$DecisionsTableUpdateCompanionBuilder,
          (Decision, $$DecisionsTableReferences),
          Decision,
          PrefetchHooks Function({bool familyId})
        > {
  $$DecisionsTableTableManager(_$AppDatabase db, $DecisionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DecisionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DecisionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DecisionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> familyId = const Value.absent(),
                Value<String> decisionType = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> parameters = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int?> fiDelayYears = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> implementedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DecisionsCompanion(
                id: id,
                userId: userId,
                familyId: familyId,
                decisionType: decisionType,
                name: name,
                parameters: parameters,
                status: status,
                fiDelayYears: fiDelayYears,
                createdAt: createdAt,
                implementedAt: implementedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                required String familyId,
                required String decisionType,
                required String name,
                required String parameters,
                Value<String> status = const Value.absent(),
                Value<int?> fiDelayYears = const Value.absent(),
                required DateTime createdAt,
                Value<DateTime?> implementedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DecisionsCompanion.insert(
                id: id,
                userId: userId,
                familyId: familyId,
                decisionType: decisionType,
                name: name,
                parameters: parameters,
                status: status,
                fiDelayYears: fiDelayYears,
                createdAt: createdAt,
                implementedAt: implementedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$DecisionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({familyId = false}) {
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
                    if (familyId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.familyId,
                                referencedTable: $$DecisionsTableReferences
                                    ._familyIdTable(db),
                                referencedColumn: $$DecisionsTableReferences
                                    ._familyIdTable(db)
                                    .id,
                              )
                              as T;
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

typedef $$DecisionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DecisionsTable,
      Decision,
      $$DecisionsTableFilterComposer,
      $$DecisionsTableOrderingComposer,
      $$DecisionsTableAnnotationComposer,
      $$DecisionsTableCreateCompanionBuilder,
      $$DecisionsTableUpdateCompanionBuilder,
      (Decision, $$DecisionsTableReferences),
      Decision,
      PrefetchHooks Function({bool familyId})
    >;
typedef $$MonthlyMetricsTableCreateCompanionBuilder =
    MonthlyMetricsCompanion Function({
      required String id,
      required String familyId,
      required String month,
      required int totalIncomePaise,
      required int totalExpensesPaise,
      required int savingsRateBp,
      required int netWorthPaise,
      Value<int?> yearsToFi,
      required DateTime computedAt,
      Value<int> rowid,
    });
typedef $$MonthlyMetricsTableUpdateCompanionBuilder =
    MonthlyMetricsCompanion Function({
      Value<String> id,
      Value<String> familyId,
      Value<String> month,
      Value<int> totalIncomePaise,
      Value<int> totalExpensesPaise,
      Value<int> savingsRateBp,
      Value<int> netWorthPaise,
      Value<int?> yearsToFi,
      Value<DateTime> computedAt,
      Value<int> rowid,
    });

final class $$MonthlyMetricsTableReferences
    extends BaseReferences<_$AppDatabase, $MonthlyMetricsTable, MonthlyMetric> {
  $$MonthlyMetricsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $FamiliesTable _familyIdTable(_$AppDatabase db) =>
      db.families.createAlias(
        $_aliasNameGenerator(db.monthlyMetrics.familyId, db.families.id),
      );

  $$FamiliesTableProcessedTableManager get familyId {
    final $_column = $_itemColumn<String>('family_id')!;

    final manager = $$FamiliesTableTableManager(
      $_db,
      $_db.families,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_familyIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$MonthlyMetricsTableFilterComposer
    extends Composer<_$AppDatabase, $MonthlyMetricsTable> {
  $$MonthlyMetricsTableFilterComposer({
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

  ColumnFilters<String> get month => $composableBuilder(
    column: $table.month,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalIncomePaise => $composableBuilder(
    column: $table.totalIncomePaise,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalExpensesPaise => $composableBuilder(
    column: $table.totalExpensesPaise,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get savingsRateBp => $composableBuilder(
    column: $table.savingsRateBp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get netWorthPaise => $composableBuilder(
    column: $table.netWorthPaise,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get yearsToFi => $composableBuilder(
    column: $table.yearsToFi,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get computedAt => $composableBuilder(
    column: $table.computedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$FamiliesTableFilterComposer get familyId {
    final $$FamiliesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.familyId,
      referencedTable: $db.families,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FamiliesTableFilterComposer(
            $db: $db,
            $table: $db.families,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MonthlyMetricsTableOrderingComposer
    extends Composer<_$AppDatabase, $MonthlyMetricsTable> {
  $$MonthlyMetricsTableOrderingComposer({
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

  ColumnOrderings<String> get month => $composableBuilder(
    column: $table.month,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalIncomePaise => $composableBuilder(
    column: $table.totalIncomePaise,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalExpensesPaise => $composableBuilder(
    column: $table.totalExpensesPaise,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get savingsRateBp => $composableBuilder(
    column: $table.savingsRateBp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get netWorthPaise => $composableBuilder(
    column: $table.netWorthPaise,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get yearsToFi => $composableBuilder(
    column: $table.yearsToFi,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get computedAt => $composableBuilder(
    column: $table.computedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$FamiliesTableOrderingComposer get familyId {
    final $$FamiliesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.familyId,
      referencedTable: $db.families,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FamiliesTableOrderingComposer(
            $db: $db,
            $table: $db.families,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MonthlyMetricsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MonthlyMetricsTable> {
  $$MonthlyMetricsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get month =>
      $composableBuilder(column: $table.month, builder: (column) => column);

  GeneratedColumn<int> get totalIncomePaise => $composableBuilder(
    column: $table.totalIncomePaise,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalExpensesPaise => $composableBuilder(
    column: $table.totalExpensesPaise,
    builder: (column) => column,
  );

  GeneratedColumn<int> get savingsRateBp => $composableBuilder(
    column: $table.savingsRateBp,
    builder: (column) => column,
  );

  GeneratedColumn<int> get netWorthPaise => $composableBuilder(
    column: $table.netWorthPaise,
    builder: (column) => column,
  );

  GeneratedColumn<int> get yearsToFi =>
      $composableBuilder(column: $table.yearsToFi, builder: (column) => column);

  GeneratedColumn<DateTime> get computedAt => $composableBuilder(
    column: $table.computedAt,
    builder: (column) => column,
  );

  $$FamiliesTableAnnotationComposer get familyId {
    final $$FamiliesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.familyId,
      referencedTable: $db.families,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FamiliesTableAnnotationComposer(
            $db: $db,
            $table: $db.families,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MonthlyMetricsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MonthlyMetricsTable,
          MonthlyMetric,
          $$MonthlyMetricsTableFilterComposer,
          $$MonthlyMetricsTableOrderingComposer,
          $$MonthlyMetricsTableAnnotationComposer,
          $$MonthlyMetricsTableCreateCompanionBuilder,
          $$MonthlyMetricsTableUpdateCompanionBuilder,
          (MonthlyMetric, $$MonthlyMetricsTableReferences),
          MonthlyMetric,
          PrefetchHooks Function({bool familyId})
        > {
  $$MonthlyMetricsTableTableManager(
    _$AppDatabase db,
    $MonthlyMetricsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MonthlyMetricsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MonthlyMetricsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MonthlyMetricsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> familyId = const Value.absent(),
                Value<String> month = const Value.absent(),
                Value<int> totalIncomePaise = const Value.absent(),
                Value<int> totalExpensesPaise = const Value.absent(),
                Value<int> savingsRateBp = const Value.absent(),
                Value<int> netWorthPaise = const Value.absent(),
                Value<int?> yearsToFi = const Value.absent(),
                Value<DateTime> computedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MonthlyMetricsCompanion(
                id: id,
                familyId: familyId,
                month: month,
                totalIncomePaise: totalIncomePaise,
                totalExpensesPaise: totalExpensesPaise,
                savingsRateBp: savingsRateBp,
                netWorthPaise: netWorthPaise,
                yearsToFi: yearsToFi,
                computedAt: computedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String familyId,
                required String month,
                required int totalIncomePaise,
                required int totalExpensesPaise,
                required int savingsRateBp,
                required int netWorthPaise,
                Value<int?> yearsToFi = const Value.absent(),
                required DateTime computedAt,
                Value<int> rowid = const Value.absent(),
              }) => MonthlyMetricsCompanion.insert(
                id: id,
                familyId: familyId,
                month: month,
                totalIncomePaise: totalIncomePaise,
                totalExpensesPaise: totalExpensesPaise,
                savingsRateBp: savingsRateBp,
                netWorthPaise: netWorthPaise,
                yearsToFi: yearsToFi,
                computedAt: computedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$MonthlyMetricsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({familyId = false}) {
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
                    if (familyId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.familyId,
                                referencedTable: $$MonthlyMetricsTableReferences
                                    ._familyIdTable(db),
                                referencedColumn:
                                    $$MonthlyMetricsTableReferences
                                        ._familyIdTable(db)
                                        .id,
                              )
                              as T;
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

typedef $$MonthlyMetricsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MonthlyMetricsTable,
      MonthlyMetric,
      $$MonthlyMetricsTableFilterComposer,
      $$MonthlyMetricsTableOrderingComposer,
      $$MonthlyMetricsTableAnnotationComposer,
      $$MonthlyMetricsTableCreateCompanionBuilder,
      $$MonthlyMetricsTableUpdateCompanionBuilder,
      (MonthlyMetric, $$MonthlyMetricsTableReferences),
      MonthlyMetric,
      PrefetchHooks Function({bool familyId})
    >;
typedef $$SavingsAllocationRulesTableCreateCompanionBuilder =
    SavingsAllocationRulesCompanion Function({
      required String id,
      required String familyId,
      required int priority,
      required String targetType,
      Value<String?> targetId,
      required String allocationType,
      Value<int?> amountPaise,
      Value<int?> percentageBp,
      Value<bool> isActive,
      required DateTime createdAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });
typedef $$SavingsAllocationRulesTableUpdateCompanionBuilder =
    SavingsAllocationRulesCompanion Function({
      Value<String> id,
      Value<String> familyId,
      Value<int> priority,
      Value<String> targetType,
      Value<String?> targetId,
      Value<String> allocationType,
      Value<int?> amountPaise,
      Value<int?> percentageBp,
      Value<bool> isActive,
      Value<DateTime> createdAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });

final class $$SavingsAllocationRulesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $SavingsAllocationRulesTable,
          SavingsAllocationRule
        > {
  $$SavingsAllocationRulesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $FamiliesTable _familyIdTable(_$AppDatabase db) =>
      db.families.createAlias(
        $_aliasNameGenerator(
          db.savingsAllocationRules.familyId,
          db.families.id,
        ),
      );

  $$FamiliesTableProcessedTableManager get familyId {
    final $_column = $_itemColumn<String>('family_id')!;

    final manager = $$FamiliesTableTableManager(
      $_db,
      $_db.families,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_familyIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SavingsAllocationRulesTableFilterComposer
    extends Composer<_$AppDatabase, $SavingsAllocationRulesTable> {
  $$SavingsAllocationRulesTableFilterComposer({
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

  ColumnFilters<int> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get targetType => $composableBuilder(
    column: $table.targetType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get targetId => $composableBuilder(
    column: $table.targetId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get allocationType => $composableBuilder(
    column: $table.allocationType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountPaise => $composableBuilder(
    column: $table.amountPaise,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get percentageBp => $composableBuilder(
    column: $table.percentageBp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$FamiliesTableFilterComposer get familyId {
    final $$FamiliesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.familyId,
      referencedTable: $db.families,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FamiliesTableFilterComposer(
            $db: $db,
            $table: $db.families,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SavingsAllocationRulesTableOrderingComposer
    extends Composer<_$AppDatabase, $SavingsAllocationRulesTable> {
  $$SavingsAllocationRulesTableOrderingComposer({
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

  ColumnOrderings<int> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get targetType => $composableBuilder(
    column: $table.targetType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get targetId => $composableBuilder(
    column: $table.targetId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get allocationType => $composableBuilder(
    column: $table.allocationType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountPaise => $composableBuilder(
    column: $table.amountPaise,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get percentageBp => $composableBuilder(
    column: $table.percentageBp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$FamiliesTableOrderingComposer get familyId {
    final $$FamiliesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.familyId,
      referencedTable: $db.families,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FamiliesTableOrderingComposer(
            $db: $db,
            $table: $db.families,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SavingsAllocationRulesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SavingsAllocationRulesTable> {
  $$SavingsAllocationRulesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => column);

  GeneratedColumn<String> get targetType => $composableBuilder(
    column: $table.targetType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get targetId =>
      $composableBuilder(column: $table.targetId, builder: (column) => column);

  GeneratedColumn<String> get allocationType => $composableBuilder(
    column: $table.allocationType,
    builder: (column) => column,
  );

  GeneratedColumn<int> get amountPaise => $composableBuilder(
    column: $table.amountPaise,
    builder: (column) => column,
  );

  GeneratedColumn<int> get percentageBp => $composableBuilder(
    column: $table.percentageBp,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  $$FamiliesTableAnnotationComposer get familyId {
    final $$FamiliesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.familyId,
      referencedTable: $db.families,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FamiliesTableAnnotationComposer(
            $db: $db,
            $table: $db.families,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SavingsAllocationRulesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SavingsAllocationRulesTable,
          SavingsAllocationRule,
          $$SavingsAllocationRulesTableFilterComposer,
          $$SavingsAllocationRulesTableOrderingComposer,
          $$SavingsAllocationRulesTableAnnotationComposer,
          $$SavingsAllocationRulesTableCreateCompanionBuilder,
          $$SavingsAllocationRulesTableUpdateCompanionBuilder,
          (SavingsAllocationRule, $$SavingsAllocationRulesTableReferences),
          SavingsAllocationRule,
          PrefetchHooks Function({bool familyId})
        > {
  $$SavingsAllocationRulesTableTableManager(
    _$AppDatabase db,
    $SavingsAllocationRulesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SavingsAllocationRulesTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$SavingsAllocationRulesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$SavingsAllocationRulesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> familyId = const Value.absent(),
                Value<int> priority = const Value.absent(),
                Value<String> targetType = const Value.absent(),
                Value<String?> targetId = const Value.absent(),
                Value<String> allocationType = const Value.absent(),
                Value<int?> amountPaise = const Value.absent(),
                Value<int?> percentageBp = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SavingsAllocationRulesCompanion(
                id: id,
                familyId: familyId,
                priority: priority,
                targetType: targetType,
                targetId: targetId,
                allocationType: allocationType,
                amountPaise: amountPaise,
                percentageBp: percentageBp,
                isActive: isActive,
                createdAt: createdAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String familyId,
                required int priority,
                required String targetType,
                Value<String?> targetId = const Value.absent(),
                required String allocationType,
                Value<int?> amountPaise = const Value.absent(),
                Value<int?> percentageBp = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                required DateTime createdAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SavingsAllocationRulesCompanion.insert(
                id: id,
                familyId: familyId,
                priority: priority,
                targetType: targetType,
                targetId: targetId,
                allocationType: allocationType,
                amountPaise: amountPaise,
                percentageBp: percentageBp,
                isActive: isActive,
                createdAt: createdAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SavingsAllocationRulesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({familyId = false}) {
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
                    if (familyId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.familyId,
                                referencedTable:
                                    $$SavingsAllocationRulesTableReferences
                                        ._familyIdTable(db),
                                referencedColumn:
                                    $$SavingsAllocationRulesTableReferences
                                        ._familyIdTable(db)
                                        .id,
                              )
                              as T;
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

typedef $$SavingsAllocationRulesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SavingsAllocationRulesTable,
      SavingsAllocationRule,
      $$SavingsAllocationRulesTableFilterComposer,
      $$SavingsAllocationRulesTableOrderingComposer,
      $$SavingsAllocationRulesTableAnnotationComposer,
      $$SavingsAllocationRulesTableCreateCompanionBuilder,
      $$SavingsAllocationRulesTableUpdateCompanionBuilder,
      (SavingsAllocationRule, $$SavingsAllocationRulesTableReferences),
      SavingsAllocationRule,
      PrefetchHooks Function({bool familyId})
    >;
typedef $$SyncChangelogTableCreateCompanionBuilder =
    SyncChangelogCompanion Function({
      Value<int> id,
      required String entityType,
      required String entityId,
      required String operation,
      required String payload,
      required DateTime timestamp,
      Value<bool> synced,
      Value<String?> changesetId,
    });
typedef $$SyncChangelogTableUpdateCompanionBuilder =
    SyncChangelogCompanion Function({
      Value<int> id,
      Value<String> entityType,
      Value<String> entityId,
      Value<String> operation,
      Value<String> payload,
      Value<DateTime> timestamp,
      Value<bool> synced,
      Value<String?> changesetId,
    });

class $$SyncChangelogTableFilterComposer
    extends Composer<_$AppDatabase, $SyncChangelogTable> {
  $$SyncChangelogTableFilterComposer({
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

  ColumnFilters<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get operation => $composableBuilder(
    column: $table.operation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get changesetId => $composableBuilder(
    column: $table.changesetId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncChangelogTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncChangelogTable> {
  $$SyncChangelogTableOrderingComposer({
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

  ColumnOrderings<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get operation => $composableBuilder(
    column: $table.operation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get changesetId => $composableBuilder(
    column: $table.changesetId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncChangelogTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncChangelogTable> {
  $$SyncChangelogTableAnnotationComposer({
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

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get operation =>
      $composableBuilder(column: $table.operation, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumn<bool> get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);

  GeneratedColumn<String> get changesetId => $composableBuilder(
    column: $table.changesetId,
    builder: (column) => column,
  );
}

class $$SyncChangelogTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncChangelogTable,
          SyncChangelogData,
          $$SyncChangelogTableFilterComposer,
          $$SyncChangelogTableOrderingComposer,
          $$SyncChangelogTableAnnotationComposer,
          $$SyncChangelogTableCreateCompanionBuilder,
          $$SyncChangelogTableUpdateCompanionBuilder,
          (
            SyncChangelogData,
            BaseReferences<
              _$AppDatabase,
              $SyncChangelogTable,
              SyncChangelogData
            >,
          ),
          SyncChangelogData,
          PrefetchHooks Function()
        > {
  $$SyncChangelogTableTableManager(_$AppDatabase db, $SyncChangelogTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncChangelogTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncChangelogTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncChangelogTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> entityType = const Value.absent(),
                Value<String> entityId = const Value.absent(),
                Value<String> operation = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<DateTime> timestamp = const Value.absent(),
                Value<bool> synced = const Value.absent(),
                Value<String?> changesetId = const Value.absent(),
              }) => SyncChangelogCompanion(
                id: id,
                entityType: entityType,
                entityId: entityId,
                operation: operation,
                payload: payload,
                timestamp: timestamp,
                synced: synced,
                changesetId: changesetId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String entityType,
                required String entityId,
                required String operation,
                required String payload,
                required DateTime timestamp,
                Value<bool> synced = const Value.absent(),
                Value<String?> changesetId = const Value.absent(),
              }) => SyncChangelogCompanion.insert(
                id: id,
                entityType: entityType,
                entityId: entityId,
                operation: operation,
                payload: payload,
                timestamp: timestamp,
                synced: synced,
                changesetId: changesetId,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncChangelogTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncChangelogTable,
      SyncChangelogData,
      $$SyncChangelogTableFilterComposer,
      $$SyncChangelogTableOrderingComposer,
      $$SyncChangelogTableAnnotationComposer,
      $$SyncChangelogTableCreateCompanionBuilder,
      $$SyncChangelogTableUpdateCompanionBuilder,
      (
        SyncChangelogData,
        BaseReferences<_$AppDatabase, $SyncChangelogTable, SyncChangelogData>,
      ),
      SyncChangelogData,
      PrefetchHooks Function()
    >;
typedef $$SyncStateTableTableCreateCompanionBuilder =
    SyncStateTableCompanion Function({
      required String deviceId,
      Value<int?> lastPushAt,
      Value<int?> lastPullAt,
      Value<int?> lastSnapshotAt,
      Value<int> pushSequence,
      Value<int> rowid,
    });
typedef $$SyncStateTableTableUpdateCompanionBuilder =
    SyncStateTableCompanion Function({
      Value<String> deviceId,
      Value<int?> lastPushAt,
      Value<int?> lastPullAt,
      Value<int?> lastSnapshotAt,
      Value<int> pushSequence,
      Value<int> rowid,
    });

class $$SyncStateTableTableFilterComposer
    extends Composer<_$AppDatabase, $SyncStateTableTable> {
  $$SyncStateTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastPushAt => $composableBuilder(
    column: $table.lastPushAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastPullAt => $composableBuilder(
    column: $table.lastPullAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastSnapshotAt => $composableBuilder(
    column: $table.lastSnapshotAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pushSequence => $composableBuilder(
    column: $table.pushSequence,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncStateTableTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncStateTableTable> {
  $$SyncStateTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastPushAt => $composableBuilder(
    column: $table.lastPushAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastPullAt => $composableBuilder(
    column: $table.lastPullAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastSnapshotAt => $composableBuilder(
    column: $table.lastSnapshotAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pushSequence => $composableBuilder(
    column: $table.pushSequence,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncStateTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncStateTableTable> {
  $$SyncStateTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<int> get lastPushAt => $composableBuilder(
    column: $table.lastPushAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastPullAt => $composableBuilder(
    column: $table.lastPullAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastSnapshotAt => $composableBuilder(
    column: $table.lastSnapshotAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get pushSequence => $composableBuilder(
    column: $table.pushSequence,
    builder: (column) => column,
  );
}

class $$SyncStateTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncStateTableTable,
          SyncStateTableData,
          $$SyncStateTableTableFilterComposer,
          $$SyncStateTableTableOrderingComposer,
          $$SyncStateTableTableAnnotationComposer,
          $$SyncStateTableTableCreateCompanionBuilder,
          $$SyncStateTableTableUpdateCompanionBuilder,
          (
            SyncStateTableData,
            BaseReferences<
              _$AppDatabase,
              $SyncStateTableTable,
              SyncStateTableData
            >,
          ),
          SyncStateTableData,
          PrefetchHooks Function()
        > {
  $$SyncStateTableTableTableManager(
    _$AppDatabase db,
    $SyncStateTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncStateTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncStateTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncStateTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> deviceId = const Value.absent(),
                Value<int?> lastPushAt = const Value.absent(),
                Value<int?> lastPullAt = const Value.absent(),
                Value<int?> lastSnapshotAt = const Value.absent(),
                Value<int> pushSequence = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncStateTableCompanion(
                deviceId: deviceId,
                lastPushAt: lastPushAt,
                lastPullAt: lastPullAt,
                lastSnapshotAt: lastSnapshotAt,
                pushSequence: pushSequence,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String deviceId,
                Value<int?> lastPushAt = const Value.absent(),
                Value<int?> lastPullAt = const Value.absent(),
                Value<int?> lastSnapshotAt = const Value.absent(),
                Value<int> pushSequence = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncStateTableCompanion.insert(
                deviceId: deviceId,
                lastPushAt: lastPushAt,
                lastPullAt: lastPullAt,
                lastSnapshotAt: lastSnapshotAt,
                pushSequence: pushSequence,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncStateTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncStateTableTable,
      SyncStateTableData,
      $$SyncStateTableTableFilterComposer,
      $$SyncStateTableTableOrderingComposer,
      $$SyncStateTableTableAnnotationComposer,
      $$SyncStateTableTableCreateCompanionBuilder,
      $$SyncStateTableTableUpdateCompanionBuilder,
      (
        SyncStateTableData,
        BaseReferences<_$AppDatabase, $SyncStateTableTable, SyncStateTableData>,
      ),
      SyncStateTableData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$FamiliesTableTableManager get families =>
      $$FamiliesTableTableManager(_db, _db.families);
  $$UsersTableTableManager get users =>
      $$UsersTableTableManager(_db, _db.users);
  $$AccountsTableTableManager get accounts =>
      $$AccountsTableTableManager(_db, _db.accounts);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db, _db.categories);
  $$CategoryGroupsTableTableManager get categoryGroups =>
      $$CategoryGroupsTableTableManager(_db, _db.categoryGroups);
  $$TransactionsTableTableManager get transactions =>
      $$TransactionsTableTableManager(_db, _db.transactions);
  $$BalanceSnapshotsTableTableManager get balanceSnapshots =>
      $$BalanceSnapshotsTableTableManager(_db, _db.balanceSnapshots);
  $$AuditLogTableTableManager get auditLog =>
      $$AuditLogTableTableManager(_db, _db.auditLog);
  $$GoalsTableTableManager get goals =>
      $$GoalsTableTableManager(_db, _db.goals);
  $$BudgetsTableTableManager get budgets =>
      $$BudgetsTableTableManager(_db, _db.budgets);
  $$LoanDetailsTableTableManager get loanDetails =>
      $$LoanDetailsTableTableManager(_db, _db.loanDetails);
  $$InvestmentHoldingsTableTableManager get investmentHoldings =>
      $$InvestmentHoldingsTableTableManager(_db, _db.investmentHoldings);
  $$LifeProfilesTableTableManager get lifeProfiles =>
      $$LifeProfilesTableTableManager(_db, _db.lifeProfiles);
  $$NetWorthMilestonesTableTableManager get netWorthMilestones =>
      $$NetWorthMilestonesTableTableManager(_db, _db.netWorthMilestones);
  $$RecurringRulesTableTableManager get recurringRules =>
      $$RecurringRulesTableTableManager(_db, _db.recurringRules);
  $$AllocationTargetsTableTableManager get allocationTargets =>
      $$AllocationTargetsTableTableManager(_db, _db.allocationTargets);
  $$DecisionsTableTableManager get decisions =>
      $$DecisionsTableTableManager(_db, _db.decisions);
  $$MonthlyMetricsTableTableManager get monthlyMetrics =>
      $$MonthlyMetricsTableTableManager(_db, _db.monthlyMetrics);
  $$SavingsAllocationRulesTableTableManager get savingsAllocationRules =>
      $$SavingsAllocationRulesTableTableManager(
        _db,
        _db.savingsAllocationRules,
      );
  $$SyncChangelogTableTableManager get syncChangelog =>
      $$SyncChangelogTableTableManager(_db, _db.syncChangelog);
  $$SyncStateTableTableTableManager get syncStateTable =>
      $$SyncStateTableTableTableManager(_db, _db.syncStateTable);
}
