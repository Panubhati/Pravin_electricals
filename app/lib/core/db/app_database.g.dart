// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ShopsTable extends Shops with TableInfo<$ShopsTable, Shop> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ShopsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _shopIdMeta = const VerificationMeta('shopId');
  @override
  late final GeneratedColumn<String> shopId = GeneratedColumn<String>(
    'shop_id',
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
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _gstinMeta = const VerificationMeta('gstin');
  @override
  late final GeneratedColumn<String> gstin = GeneratedColumn<String>(
    'gstin',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _addressMeta = const VerificationMeta(
    'address',
  );
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
    'address',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _stateCodeMeta = const VerificationMeta(
    'stateCode',
  );
  @override
  late final GeneratedColumn<String> stateCode = GeneratedColumn<String>(
    'state_code',
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
  static const VerificationMeta _termsMeta = const VerificationMeta('terms');
  @override
  late final GeneratedColumn<String> terms = GeneratedColumn<String>(
    'terms',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    shopId,
    createdAt,
    updatedAt,
    deletedAt,
    name,
    gstin,
    address,
    stateCode,
    phone,
    terms,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'shops';
  @override
  VerificationContext validateIntegrity(
    Insertable<Shop> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('shop_id')) {
      context.handle(
        _shopIdMeta,
        shopId.isAcceptableOrUnknown(data['shop_id']!, _shopIdMeta),
      );
    } else if (isInserting) {
      context.missing(_shopIdMeta);
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
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('gstin')) {
      context.handle(
        _gstinMeta,
        gstin.isAcceptableOrUnknown(data['gstin']!, _gstinMeta),
      );
    }
    if (data.containsKey('address')) {
      context.handle(
        _addressMeta,
        address.isAcceptableOrUnknown(data['address']!, _addressMeta),
      );
    }
    if (data.containsKey('state_code')) {
      context.handle(
        _stateCodeMeta,
        stateCode.isAcceptableOrUnknown(data['state_code']!, _stateCodeMeta),
      );
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    }
    if (data.containsKey('terms')) {
      context.handle(
        _termsMeta,
        terms.isAcceptableOrUnknown(data['terms']!, _termsMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Shop map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Shop(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}id'],
          )!,
      shopId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}shop_id'],
          )!,
      createdAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}created_at'],
          )!,
      updatedAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}updated_at'],
          )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      name:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}name'],
          )!,
      gstin: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}gstin'],
      ),
      address: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}address'],
      ),
      stateCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}state_code'],
      ),
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      ),
      terms: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}terms'],
      ),
    );
  }

  @override
  $ShopsTable createAlias(String alias) {
    return $ShopsTable(attachedDatabase, alias);
  }
}

class Shop extends DataClass implements Insertable<Shop> {
  final String id;
  final String shopId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String name;
  final String? gstin;
  final String? address;
  final String? stateCode;
  final String? phone;
  final String? terms;
  const Shop({
    required this.id,
    required this.shopId,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.name,
    this.gstin,
    this.address,
    this.stateCode,
    this.phone,
    this.terms,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['shop_id'] = Variable<String>(shopId);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || gstin != null) {
      map['gstin'] = Variable<String>(gstin);
    }
    if (!nullToAbsent || address != null) {
      map['address'] = Variable<String>(address);
    }
    if (!nullToAbsent || stateCode != null) {
      map['state_code'] = Variable<String>(stateCode);
    }
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    if (!nullToAbsent || terms != null) {
      map['terms'] = Variable<String>(terms);
    }
    return map;
  }

  ShopsCompanion toCompanion(bool nullToAbsent) {
    return ShopsCompanion(
      id: Value(id),
      shopId: Value(shopId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt:
          deletedAt == null && nullToAbsent
              ? const Value.absent()
              : Value(deletedAt),
      name: Value(name),
      gstin:
          gstin == null && nullToAbsent ? const Value.absent() : Value(gstin),
      address:
          address == null && nullToAbsent
              ? const Value.absent()
              : Value(address),
      stateCode:
          stateCode == null && nullToAbsent
              ? const Value.absent()
              : Value(stateCode),
      phone:
          phone == null && nullToAbsent ? const Value.absent() : Value(phone),
      terms:
          terms == null && nullToAbsent ? const Value.absent() : Value(terms),
    );
  }

  factory Shop.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Shop(
      id: serializer.fromJson<String>(json['id']),
      shopId: serializer.fromJson<String>(json['shopId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      name: serializer.fromJson<String>(json['name']),
      gstin: serializer.fromJson<String?>(json['gstin']),
      address: serializer.fromJson<String?>(json['address']),
      stateCode: serializer.fromJson<String?>(json['stateCode']),
      phone: serializer.fromJson<String?>(json['phone']),
      terms: serializer.fromJson<String?>(json['terms']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'shopId': serializer.toJson<String>(shopId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'name': serializer.toJson<String>(name),
      'gstin': serializer.toJson<String?>(gstin),
      'address': serializer.toJson<String?>(address),
      'stateCode': serializer.toJson<String?>(stateCode),
      'phone': serializer.toJson<String?>(phone),
      'terms': serializer.toJson<String?>(terms),
    };
  }

  Shop copyWith({
    String? id,
    String? shopId,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? name,
    Value<String?> gstin = const Value.absent(),
    Value<String?> address = const Value.absent(),
    Value<String?> stateCode = const Value.absent(),
    Value<String?> phone = const Value.absent(),
    Value<String?> terms = const Value.absent(),
  }) => Shop(
    id: id ?? this.id,
    shopId: shopId ?? this.shopId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    name: name ?? this.name,
    gstin: gstin.present ? gstin.value : this.gstin,
    address: address.present ? address.value : this.address,
    stateCode: stateCode.present ? stateCode.value : this.stateCode,
    phone: phone.present ? phone.value : this.phone,
    terms: terms.present ? terms.value : this.terms,
  );
  Shop copyWithCompanion(ShopsCompanion data) {
    return Shop(
      id: data.id.present ? data.id.value : this.id,
      shopId: data.shopId.present ? data.shopId.value : this.shopId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      name: data.name.present ? data.name.value : this.name,
      gstin: data.gstin.present ? data.gstin.value : this.gstin,
      address: data.address.present ? data.address.value : this.address,
      stateCode: data.stateCode.present ? data.stateCode.value : this.stateCode,
      phone: data.phone.present ? data.phone.value : this.phone,
      terms: data.terms.present ? data.terms.value : this.terms,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Shop(')
          ..write('id: $id, ')
          ..write('shopId: $shopId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('name: $name, ')
          ..write('gstin: $gstin, ')
          ..write('address: $address, ')
          ..write('stateCode: $stateCode, ')
          ..write('phone: $phone, ')
          ..write('terms: $terms')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    shopId,
    createdAt,
    updatedAt,
    deletedAt,
    name,
    gstin,
    address,
    stateCode,
    phone,
    terms,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Shop &&
          other.id == this.id &&
          other.shopId == this.shopId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.name == this.name &&
          other.gstin == this.gstin &&
          other.address == this.address &&
          other.stateCode == this.stateCode &&
          other.phone == this.phone &&
          other.terms == this.terms);
}

class ShopsCompanion extends UpdateCompanion<Shop> {
  final Value<String> id;
  final Value<String> shopId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> name;
  final Value<String?> gstin;
  final Value<String?> address;
  final Value<String?> stateCode;
  final Value<String?> phone;
  final Value<String?> terms;
  final Value<int> rowid;
  const ShopsCompanion({
    this.id = const Value.absent(),
    this.shopId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.name = const Value.absent(),
    this.gstin = const Value.absent(),
    this.address = const Value.absent(),
    this.stateCode = const Value.absent(),
    this.phone = const Value.absent(),
    this.terms = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ShopsCompanion.insert({
    required String id,
    required String shopId,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    required String name,
    this.gstin = const Value.absent(),
    this.address = const Value.absent(),
    this.stateCode = const Value.absent(),
    this.phone = const Value.absent(),
    this.terms = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       shopId = Value(shopId),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       name = Value(name);
  static Insertable<Shop> custom({
    Expression<String>? id,
    Expression<String>? shopId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? name,
    Expression<String>? gstin,
    Expression<String>? address,
    Expression<String>? stateCode,
    Expression<String>? phone,
    Expression<String>? terms,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (shopId != null) 'shop_id': shopId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (name != null) 'name': name,
      if (gstin != null) 'gstin': gstin,
      if (address != null) 'address': address,
      if (stateCode != null) 'state_code': stateCode,
      if (phone != null) 'phone': phone,
      if (terms != null) 'terms': terms,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ShopsCompanion copyWith({
    Value<String>? id,
    Value<String>? shopId,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? name,
    Value<String?>? gstin,
    Value<String?>? address,
    Value<String?>? stateCode,
    Value<String?>? phone,
    Value<String?>? terms,
    Value<int>? rowid,
  }) {
    return ShopsCompanion(
      id: id ?? this.id,
      shopId: shopId ?? this.shopId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      name: name ?? this.name,
      gstin: gstin ?? this.gstin,
      address: address ?? this.address,
      stateCode: stateCode ?? this.stateCode,
      phone: phone ?? this.phone,
      terms: terms ?? this.terms,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (shopId.present) {
      map['shop_id'] = Variable<String>(shopId.value);
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
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (gstin.present) {
      map['gstin'] = Variable<String>(gstin.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (stateCode.present) {
      map['state_code'] = Variable<String>(stateCode.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (terms.present) {
      map['terms'] = Variable<String>(terms.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ShopsCompanion(')
          ..write('id: $id, ')
          ..write('shopId: $shopId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('name: $name, ')
          ..write('gstin: $gstin, ')
          ..write('address: $address, ')
          ..write('stateCode: $stateCode, ')
          ..write('phone: $phone, ')
          ..write('terms: $terms, ')
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
  static const VerificationMeta _shopIdMeta = const VerificationMeta('shopId');
  @override
  late final GeneratedColumn<String> shopId = GeneratedColumn<String>(
    'shop_id',
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
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pinHashMeta = const VerificationMeta(
    'pinHash',
  );
  @override
  late final GeneratedColumn<String> pinHash = GeneratedColumn<String>(
    'pin_hash',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _activeMeta = const VerificationMeta('active');
  @override
  late final GeneratedColumn<bool> active = GeneratedColumn<bool>(
    'active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    shopId,
    createdAt,
    updatedAt,
    deletedAt,
    name,
    phone,
    role,
    pinHash,
    active,
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
    if (data.containsKey('shop_id')) {
      context.handle(
        _shopIdMeta,
        shopId.isAcceptableOrUnknown(data['shop_id']!, _shopIdMeta),
      );
    } else if (isInserting) {
      context.missing(_shopIdMeta);
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
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
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
    if (data.containsKey('pin_hash')) {
      context.handle(
        _pinHashMeta,
        pinHash.isAcceptableOrUnknown(data['pin_hash']!, _pinHashMeta),
      );
    }
    if (data.containsKey('active')) {
      context.handle(
        _activeMeta,
        active.isAcceptableOrUnknown(data['active']!, _activeMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  User map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return User(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}id'],
          )!,
      shopId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}shop_id'],
          )!,
      createdAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}created_at'],
          )!,
      updatedAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}updated_at'],
          )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      name:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}name'],
          )!,
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      ),
      role:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}role'],
          )!,
      pinHash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pin_hash'],
      ),
      active:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}active'],
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
  final String shopId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String name;
  final String? phone;

  /// owner | counter | godown
  final String role;
  final String? pinHash;
  final bool active;
  const User({
    required this.id,
    required this.shopId,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.name,
    this.phone,
    required this.role,
    this.pinHash,
    required this.active,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['shop_id'] = Variable<String>(shopId);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    map['role'] = Variable<String>(role);
    if (!nullToAbsent || pinHash != null) {
      map['pin_hash'] = Variable<String>(pinHash);
    }
    map['active'] = Variable<bool>(active);
    return map;
  }

  UsersCompanion toCompanion(bool nullToAbsent) {
    return UsersCompanion(
      id: Value(id),
      shopId: Value(shopId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt:
          deletedAt == null && nullToAbsent
              ? const Value.absent()
              : Value(deletedAt),
      name: Value(name),
      phone:
          phone == null && nullToAbsent ? const Value.absent() : Value(phone),
      role: Value(role),
      pinHash:
          pinHash == null && nullToAbsent
              ? const Value.absent()
              : Value(pinHash),
      active: Value(active),
    );
  }

  factory User.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return User(
      id: serializer.fromJson<String>(json['id']),
      shopId: serializer.fromJson<String>(json['shopId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      name: serializer.fromJson<String>(json['name']),
      phone: serializer.fromJson<String?>(json['phone']),
      role: serializer.fromJson<String>(json['role']),
      pinHash: serializer.fromJson<String?>(json['pinHash']),
      active: serializer.fromJson<bool>(json['active']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'shopId': serializer.toJson<String>(shopId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'name': serializer.toJson<String>(name),
      'phone': serializer.toJson<String?>(phone),
      'role': serializer.toJson<String>(role),
      'pinHash': serializer.toJson<String?>(pinHash),
      'active': serializer.toJson<bool>(active),
    };
  }

  User copyWith({
    String? id,
    String? shopId,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? name,
    Value<String?> phone = const Value.absent(),
    String? role,
    Value<String?> pinHash = const Value.absent(),
    bool? active,
  }) => User(
    id: id ?? this.id,
    shopId: shopId ?? this.shopId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    name: name ?? this.name,
    phone: phone.present ? phone.value : this.phone,
    role: role ?? this.role,
    pinHash: pinHash.present ? pinHash.value : this.pinHash,
    active: active ?? this.active,
  );
  User copyWithCompanion(UsersCompanion data) {
    return User(
      id: data.id.present ? data.id.value : this.id,
      shopId: data.shopId.present ? data.shopId.value : this.shopId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      name: data.name.present ? data.name.value : this.name,
      phone: data.phone.present ? data.phone.value : this.phone,
      role: data.role.present ? data.role.value : this.role,
      pinHash: data.pinHash.present ? data.pinHash.value : this.pinHash,
      active: data.active.present ? data.active.value : this.active,
    );
  }

  @override
  String toString() {
    return (StringBuffer('User(')
          ..write('id: $id, ')
          ..write('shopId: $shopId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('name: $name, ')
          ..write('phone: $phone, ')
          ..write('role: $role, ')
          ..write('pinHash: $pinHash, ')
          ..write('active: $active')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    shopId,
    createdAt,
    updatedAt,
    deletedAt,
    name,
    phone,
    role,
    pinHash,
    active,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is User &&
          other.id == this.id &&
          other.shopId == this.shopId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.name == this.name &&
          other.phone == this.phone &&
          other.role == this.role &&
          other.pinHash == this.pinHash &&
          other.active == this.active);
}

class UsersCompanion extends UpdateCompanion<User> {
  final Value<String> id;
  final Value<String> shopId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> name;
  final Value<String?> phone;
  final Value<String> role;
  final Value<String?> pinHash;
  final Value<bool> active;
  final Value<int> rowid;
  const UsersCompanion({
    this.id = const Value.absent(),
    this.shopId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.name = const Value.absent(),
    this.phone = const Value.absent(),
    this.role = const Value.absent(),
    this.pinHash = const Value.absent(),
    this.active = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UsersCompanion.insert({
    required String id,
    required String shopId,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    required String name,
    this.phone = const Value.absent(),
    required String role,
    this.pinHash = const Value.absent(),
    this.active = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       shopId = Value(shopId),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       name = Value(name),
       role = Value(role);
  static Insertable<User> custom({
    Expression<String>? id,
    Expression<String>? shopId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? name,
    Expression<String>? phone,
    Expression<String>? role,
    Expression<String>? pinHash,
    Expression<bool>? active,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (shopId != null) 'shop_id': shopId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (name != null) 'name': name,
      if (phone != null) 'phone': phone,
      if (role != null) 'role': role,
      if (pinHash != null) 'pin_hash': pinHash,
      if (active != null) 'active': active,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UsersCompanion copyWith({
    Value<String>? id,
    Value<String>? shopId,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? name,
    Value<String?>? phone,
    Value<String>? role,
    Value<String?>? pinHash,
    Value<bool>? active,
    Value<int>? rowid,
  }) {
    return UsersCompanion(
      id: id ?? this.id,
      shopId: shopId ?? this.shopId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      pinHash: pinHash ?? this.pinHash,
      active: active ?? this.active,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (shopId.present) {
      map['shop_id'] = Variable<String>(shopId.value);
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
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (pinHash.present) {
      map['pin_hash'] = Variable<String>(pinHash.value);
    }
    if (active.present) {
      map['active'] = Variable<bool>(active.value);
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
          ..write('shopId: $shopId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('name: $name, ')
          ..write('phone: $phone, ')
          ..write('role: $role, ')
          ..write('pinHash: $pinHash, ')
          ..write('active: $active, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DevicesTable extends Devices with TableInfo<$DevicesTable, Device> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DevicesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _shopIdMeta = const VerificationMeta('shopId');
  @override
  late final GeneratedColumn<String> shopId = GeneratedColumn<String>(
    'shop_id',
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
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _invoiceSeriesPrefixMeta =
      const VerificationMeta('invoiceSeriesPrefix');
  @override
  late final GeneratedColumn<String> invoiceSeriesPrefix =
      GeneratedColumn<String>(
        'invoice_series_prefix',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    shopId,
    createdAt,
    updatedAt,
    deletedAt,
    userId,
    label,
    invoiceSeriesPrefix,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'devices';
  @override
  VerificationContext validateIntegrity(
    Insertable<Device> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('shop_id')) {
      context.handle(
        _shopIdMeta,
        shopId.isAcceptableOrUnknown(data['shop_id']!, _shopIdMeta),
      );
    } else if (isInserting) {
      context.missing(_shopIdMeta);
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
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    if (data.containsKey('invoice_series_prefix')) {
      context.handle(
        _invoiceSeriesPrefixMeta,
        invoiceSeriesPrefix.isAcceptableOrUnknown(
          data['invoice_series_prefix']!,
          _invoiceSeriesPrefixMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_invoiceSeriesPrefixMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Device map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Device(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}id'],
          )!,
      shopId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}shop_id'],
          )!,
      createdAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}created_at'],
          )!,
      updatedAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}updated_at'],
          )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      ),
      label:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}label'],
          )!,
      invoiceSeriesPrefix:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}invoice_series_prefix'],
          )!,
    );
  }

  @override
  $DevicesTable createAlias(String alias) {
    return $DevicesTable(attachedDatabase, alias);
  }
}

class Device extends DataClass implements Insertable<Device> {
  final String id;
  final String shopId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String? userId;
  final String label;

  /// Per-device invoice series prefix, e.g. "A".
  final String invoiceSeriesPrefix;
  const Device({
    required this.id,
    required this.shopId,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.userId,
    required this.label,
    required this.invoiceSeriesPrefix,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['shop_id'] = Variable<String>(shopId);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    if (!nullToAbsent || userId != null) {
      map['user_id'] = Variable<String>(userId);
    }
    map['label'] = Variable<String>(label);
    map['invoice_series_prefix'] = Variable<String>(invoiceSeriesPrefix);
    return map;
  }

  DevicesCompanion toCompanion(bool nullToAbsent) {
    return DevicesCompanion(
      id: Value(id),
      shopId: Value(shopId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt:
          deletedAt == null && nullToAbsent
              ? const Value.absent()
              : Value(deletedAt),
      userId:
          userId == null && nullToAbsent ? const Value.absent() : Value(userId),
      label: Value(label),
      invoiceSeriesPrefix: Value(invoiceSeriesPrefix),
    );
  }

  factory Device.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Device(
      id: serializer.fromJson<String>(json['id']),
      shopId: serializer.fromJson<String>(json['shopId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      userId: serializer.fromJson<String?>(json['userId']),
      label: serializer.fromJson<String>(json['label']),
      invoiceSeriesPrefix: serializer.fromJson<String>(
        json['invoiceSeriesPrefix'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'shopId': serializer.toJson<String>(shopId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'userId': serializer.toJson<String?>(userId),
      'label': serializer.toJson<String>(label),
      'invoiceSeriesPrefix': serializer.toJson<String>(invoiceSeriesPrefix),
    };
  }

  Device copyWith({
    String? id,
    String? shopId,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    Value<String?> userId = const Value.absent(),
    String? label,
    String? invoiceSeriesPrefix,
  }) => Device(
    id: id ?? this.id,
    shopId: shopId ?? this.shopId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    userId: userId.present ? userId.value : this.userId,
    label: label ?? this.label,
    invoiceSeriesPrefix: invoiceSeriesPrefix ?? this.invoiceSeriesPrefix,
  );
  Device copyWithCompanion(DevicesCompanion data) {
    return Device(
      id: data.id.present ? data.id.value : this.id,
      shopId: data.shopId.present ? data.shopId.value : this.shopId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      userId: data.userId.present ? data.userId.value : this.userId,
      label: data.label.present ? data.label.value : this.label,
      invoiceSeriesPrefix:
          data.invoiceSeriesPrefix.present
              ? data.invoiceSeriesPrefix.value
              : this.invoiceSeriesPrefix,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Device(')
          ..write('id: $id, ')
          ..write('shopId: $shopId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('userId: $userId, ')
          ..write('label: $label, ')
          ..write('invoiceSeriesPrefix: $invoiceSeriesPrefix')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    shopId,
    createdAt,
    updatedAt,
    deletedAt,
    userId,
    label,
    invoiceSeriesPrefix,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Device &&
          other.id == this.id &&
          other.shopId == this.shopId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.userId == this.userId &&
          other.label == this.label &&
          other.invoiceSeriesPrefix == this.invoiceSeriesPrefix);
}

class DevicesCompanion extends UpdateCompanion<Device> {
  final Value<String> id;
  final Value<String> shopId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String?> userId;
  final Value<String> label;
  final Value<String> invoiceSeriesPrefix;
  final Value<int> rowid;
  const DevicesCompanion({
    this.id = const Value.absent(),
    this.shopId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.userId = const Value.absent(),
    this.label = const Value.absent(),
    this.invoiceSeriesPrefix = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DevicesCompanion.insert({
    required String id,
    required String shopId,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.userId = const Value.absent(),
    required String label,
    required String invoiceSeriesPrefix,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       shopId = Value(shopId),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       label = Value(label),
       invoiceSeriesPrefix = Value(invoiceSeriesPrefix);
  static Insertable<Device> custom({
    Expression<String>? id,
    Expression<String>? shopId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? userId,
    Expression<String>? label,
    Expression<String>? invoiceSeriesPrefix,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (shopId != null) 'shop_id': shopId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (userId != null) 'user_id': userId,
      if (label != null) 'label': label,
      if (invoiceSeriesPrefix != null)
        'invoice_series_prefix': invoiceSeriesPrefix,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DevicesCompanion copyWith({
    Value<String>? id,
    Value<String>? shopId,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String?>? userId,
    Value<String>? label,
    Value<String>? invoiceSeriesPrefix,
    Value<int>? rowid,
  }) {
    return DevicesCompanion(
      id: id ?? this.id,
      shopId: shopId ?? this.shopId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      userId: userId ?? this.userId,
      label: label ?? this.label,
      invoiceSeriesPrefix: invoiceSeriesPrefix ?? this.invoiceSeriesPrefix,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (shopId.present) {
      map['shop_id'] = Variable<String>(shopId.value);
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
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (invoiceSeriesPrefix.present) {
      map['invoice_series_prefix'] = Variable<String>(
        invoiceSeriesPrefix.value,
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DevicesCompanion(')
          ..write('id: $id, ')
          ..write('shopId: $shopId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('userId: $userId, ')
          ..write('label: $label, ')
          ..write('invoiceSeriesPrefix: $invoiceSeriesPrefix, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocationsTable extends Locations
    with TableInfo<$LocationsTable, Location> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _shopIdMeta = const VerificationMeta('shopId');
  @override
  late final GeneratedColumn<String> shopId = GeneratedColumn<String>(
    'shop_id',
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
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    shopId,
    createdAt,
    updatedAt,
    deletedAt,
    name,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'locations';
  @override
  VerificationContext validateIntegrity(
    Insertable<Location> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('shop_id')) {
      context.handle(
        _shopIdMeta,
        shopId.isAcceptableOrUnknown(data['shop_id']!, _shopIdMeta),
      );
    } else if (isInserting) {
      context.missing(_shopIdMeta);
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
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Location map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Location(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}id'],
          )!,
      shopId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}shop_id'],
          )!,
      createdAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}created_at'],
          )!,
      updatedAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}updated_at'],
          )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      name:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}name'],
          )!,
    );
  }

  @override
  $LocationsTable createAlias(String alias) {
    return $LocationsTable(attachedDatabase, alias);
  }
}

class Location extends DataClass implements Insertable<Location> {
  final String id;
  final String shopId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  /// shop | godown | vehicle
  final String name;
  const Location({
    required this.id,
    required this.shopId,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.name,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['shop_id'] = Variable<String>(shopId);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['name'] = Variable<String>(name);
    return map;
  }

  LocationsCompanion toCompanion(bool nullToAbsent) {
    return LocationsCompanion(
      id: Value(id),
      shopId: Value(shopId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt:
          deletedAt == null && nullToAbsent
              ? const Value.absent()
              : Value(deletedAt),
      name: Value(name),
    );
  }

  factory Location.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Location(
      id: serializer.fromJson<String>(json['id']),
      shopId: serializer.fromJson<String>(json['shopId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      name: serializer.fromJson<String>(json['name']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'shopId': serializer.toJson<String>(shopId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'name': serializer.toJson<String>(name),
    };
  }

  Location copyWith({
    String? id,
    String? shopId,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? name,
  }) => Location(
    id: id ?? this.id,
    shopId: shopId ?? this.shopId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    name: name ?? this.name,
  );
  Location copyWithCompanion(LocationsCompanion data) {
    return Location(
      id: data.id.present ? data.id.value : this.id,
      shopId: data.shopId.present ? data.shopId.value : this.shopId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      name: data.name.present ? data.name.value : this.name,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Location(')
          ..write('id: $id, ')
          ..write('shopId: $shopId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, shopId, createdAt, updatedAt, deletedAt, name);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Location &&
          other.id == this.id &&
          other.shopId == this.shopId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.name == this.name);
}

class LocationsCompanion extends UpdateCompanion<Location> {
  final Value<String> id;
  final Value<String> shopId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> name;
  final Value<int> rowid;
  const LocationsCompanion({
    this.id = const Value.absent(),
    this.shopId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.name = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocationsCompanion.insert({
    required String id,
    required String shopId,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    required String name,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       shopId = Value(shopId),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       name = Value(name);
  static Insertable<Location> custom({
    Expression<String>? id,
    Expression<String>? shopId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? name,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (shopId != null) 'shop_id': shopId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (name != null) 'name': name,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocationsCompanion copyWith({
    Value<String>? id,
    Value<String>? shopId,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? name,
    Value<int>? rowid,
  }) {
    return LocationsCompanion(
      id: id ?? this.id,
      shopId: shopId ?? this.shopId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      name: name ?? this.name,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (shopId.present) {
      map['shop_id'] = Variable<String>(shopId.value);
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
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocationsCompanion(')
          ..write('id: $id, ')
          ..write('shopId: $shopId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('name: $name, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $OutboxTable extends Outbox with TableInfo<$OutboxTable, OutboxData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OutboxTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _shopIdMeta = const VerificationMeta('shopId');
  @override
  late final GeneratedColumn<String> shopId = GeneratedColumn<String>(
    'shop_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityMeta = const VerificationMeta('entity');
  @override
  late final GeneratedColumn<String> entity = GeneratedColumn<String>(
    'entity',
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
  static const VerificationMeta _opMeta = const VerificationMeta('op');
  @override
  late final GeneratedColumn<String> op = GeneratedColumn<String>(
    'op',
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
  static const VerificationMeta _attemptCountMeta = const VerificationMeta(
    'attemptCount',
  );
  @override
  late final GeneratedColumn<int> attemptCount = GeneratedColumn<int>(
    'attempt_count',
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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    shopId,
    entity,
    entityId,
    op,
    payloadJson,
    attemptCount,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'outbox';
  @override
  VerificationContext validateIntegrity(
    Insertable<OutboxData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('shop_id')) {
      context.handle(
        _shopIdMeta,
        shopId.isAcceptableOrUnknown(data['shop_id']!, _shopIdMeta),
      );
    } else if (isInserting) {
      context.missing(_shopIdMeta);
    }
    if (data.containsKey('entity')) {
      context.handle(
        _entityMeta,
        entity.isAcceptableOrUnknown(data['entity']!, _entityMeta),
      );
    } else if (isInserting) {
      context.missing(_entityMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('op')) {
      context.handle(_opMeta, op.isAcceptableOrUnknown(data['op']!, _opMeta));
    } else if (isInserting) {
      context.missing(_opMeta);
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
    if (data.containsKey('attempt_count')) {
      context.handle(
        _attemptCountMeta,
        attemptCount.isAcceptableOrUnknown(
          data['attempt_count']!,
          _attemptCountMeta,
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
  OutboxData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OutboxData(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}id'],
          )!,
      shopId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}shop_id'],
          )!,
      entity:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}entity'],
          )!,
      entityId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}entity_id'],
          )!,
      op:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}op'],
          )!,
      payloadJson:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}payload_json'],
          )!,
      attemptCount:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}attempt_count'],
          )!,
      createdAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}created_at'],
          )!,
    );
  }

  @override
  $OutboxTable createAlias(String alias) {
    return $OutboxTable(attachedDatabase, alias);
  }
}

class OutboxData extends DataClass implements Insertable<OutboxData> {
  final String id;
  final String shopId;
  final String entity;
  final String entityId;

  /// upsert | delete
  final String op;
  final String payloadJson;
  final int attemptCount;
  final DateTime createdAt;
  const OutboxData({
    required this.id,
    required this.shopId,
    required this.entity,
    required this.entityId,
    required this.op,
    required this.payloadJson,
    required this.attemptCount,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['shop_id'] = Variable<String>(shopId);
    map['entity'] = Variable<String>(entity);
    map['entity_id'] = Variable<String>(entityId);
    map['op'] = Variable<String>(op);
    map['payload_json'] = Variable<String>(payloadJson);
    map['attempt_count'] = Variable<int>(attemptCount);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  OutboxCompanion toCompanion(bool nullToAbsent) {
    return OutboxCompanion(
      id: Value(id),
      shopId: Value(shopId),
      entity: Value(entity),
      entityId: Value(entityId),
      op: Value(op),
      payloadJson: Value(payloadJson),
      attemptCount: Value(attemptCount),
      createdAt: Value(createdAt),
    );
  }

  factory OutboxData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OutboxData(
      id: serializer.fromJson<String>(json['id']),
      shopId: serializer.fromJson<String>(json['shopId']),
      entity: serializer.fromJson<String>(json['entity']),
      entityId: serializer.fromJson<String>(json['entityId']),
      op: serializer.fromJson<String>(json['op']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      attemptCount: serializer.fromJson<int>(json['attemptCount']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'shopId': serializer.toJson<String>(shopId),
      'entity': serializer.toJson<String>(entity),
      'entityId': serializer.toJson<String>(entityId),
      'op': serializer.toJson<String>(op),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'attemptCount': serializer.toJson<int>(attemptCount),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  OutboxData copyWith({
    String? id,
    String? shopId,
    String? entity,
    String? entityId,
    String? op,
    String? payloadJson,
    int? attemptCount,
    DateTime? createdAt,
  }) => OutboxData(
    id: id ?? this.id,
    shopId: shopId ?? this.shopId,
    entity: entity ?? this.entity,
    entityId: entityId ?? this.entityId,
    op: op ?? this.op,
    payloadJson: payloadJson ?? this.payloadJson,
    attemptCount: attemptCount ?? this.attemptCount,
    createdAt: createdAt ?? this.createdAt,
  );
  OutboxData copyWithCompanion(OutboxCompanion data) {
    return OutboxData(
      id: data.id.present ? data.id.value : this.id,
      shopId: data.shopId.present ? data.shopId.value : this.shopId,
      entity: data.entity.present ? data.entity.value : this.entity,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      op: data.op.present ? data.op.value : this.op,
      payloadJson:
          data.payloadJson.present ? data.payloadJson.value : this.payloadJson,
      attemptCount:
          data.attemptCount.present
              ? data.attemptCount.value
              : this.attemptCount,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OutboxData(')
          ..write('id: $id, ')
          ..write('shopId: $shopId, ')
          ..write('entity: $entity, ')
          ..write('entityId: $entityId, ')
          ..write('op: $op, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('attemptCount: $attemptCount, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    shopId,
    entity,
    entityId,
    op,
    payloadJson,
    attemptCount,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OutboxData &&
          other.id == this.id &&
          other.shopId == this.shopId &&
          other.entity == this.entity &&
          other.entityId == this.entityId &&
          other.op == this.op &&
          other.payloadJson == this.payloadJson &&
          other.attemptCount == this.attemptCount &&
          other.createdAt == this.createdAt);
}

class OutboxCompanion extends UpdateCompanion<OutboxData> {
  final Value<String> id;
  final Value<String> shopId;
  final Value<String> entity;
  final Value<String> entityId;
  final Value<String> op;
  final Value<String> payloadJson;
  final Value<int> attemptCount;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const OutboxCompanion({
    this.id = const Value.absent(),
    this.shopId = const Value.absent(),
    this.entity = const Value.absent(),
    this.entityId = const Value.absent(),
    this.op = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.attemptCount = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  OutboxCompanion.insert({
    required String id,
    required String shopId,
    required String entity,
    required String entityId,
    required String op,
    required String payloadJson,
    this.attemptCount = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       shopId = Value(shopId),
       entity = Value(entity),
       entityId = Value(entityId),
       op = Value(op),
       payloadJson = Value(payloadJson),
       createdAt = Value(createdAt);
  static Insertable<OutboxData> custom({
    Expression<String>? id,
    Expression<String>? shopId,
    Expression<String>? entity,
    Expression<String>? entityId,
    Expression<String>? op,
    Expression<String>? payloadJson,
    Expression<int>? attemptCount,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (shopId != null) 'shop_id': shopId,
      if (entity != null) 'entity': entity,
      if (entityId != null) 'entity_id': entityId,
      if (op != null) 'op': op,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (attemptCount != null) 'attempt_count': attemptCount,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  OutboxCompanion copyWith({
    Value<String>? id,
    Value<String>? shopId,
    Value<String>? entity,
    Value<String>? entityId,
    Value<String>? op,
    Value<String>? payloadJson,
    Value<int>? attemptCount,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return OutboxCompanion(
      id: id ?? this.id,
      shopId: shopId ?? this.shopId,
      entity: entity ?? this.entity,
      entityId: entityId ?? this.entityId,
      op: op ?? this.op,
      payloadJson: payloadJson ?? this.payloadJson,
      attemptCount: attemptCount ?? this.attemptCount,
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
    if (shopId.present) {
      map['shop_id'] = Variable<String>(shopId.value);
    }
    if (entity.present) {
      map['entity'] = Variable<String>(entity.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (op.present) {
      map['op'] = Variable<String>(op.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (attemptCount.present) {
      map['attempt_count'] = Variable<int>(attemptCount.value);
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
    return (StringBuffer('OutboxCompanion(')
          ..write('id: $id, ')
          ..write('shopId: $shopId, ')
          ..write('entity: $entity, ')
          ..write('entityId: $entityId, ')
          ..write('op: $op, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('attemptCount: $attemptCount, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ItemsTable extends Items with TableInfo<$ItemsTable, Item> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _shopIdMeta = const VerificationMeta('shopId');
  @override
  late final GeneratedColumn<String> shopId = GeneratedColumn<String>(
    'shop_id',
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
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _brandMeta = const VerificationMeta('brand');
  @override
  late final GeneratedColumn<String> brand = GeneratedColumn<String>(
    'brand',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
  static const VerificationMeta _hsnMeta = const VerificationMeta('hsn');
  @override
  late final GeneratedColumn<String> hsn = GeneratedColumn<String>(
    'hsn',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _gstRateBpMeta = const VerificationMeta(
    'gstRateBp',
  );
  @override
  late final GeneratedColumn<int> gstRateBp = GeneratedColumn<int>(
    'gst_rate_bp',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _baseUnitMeta = const VerificationMeta(
    'baseUnit',
  );
  @override
  late final GeneratedColumn<String> baseUnit = GeneratedColumn<String>(
    'base_unit',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _priceUnitFactorMeta = const VerificationMeta(
    'priceUnitFactor',
  );
  @override
  late final GeneratedColumn<int> priceUnitFactor = GeneratedColumn<int>(
    'price_unit_factor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _trackSerialMeta = const VerificationMeta(
    'trackSerial',
  );
  @override
  late final GeneratedColumn<bool> trackSerial = GeneratedColumn<bool>(
    'track_serial',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("track_serial" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _trackCoilMeta = const VerificationMeta(
    'trackCoil',
  );
  @override
  late final GeneratedColumn<bool> trackCoil = GeneratedColumn<bool>(
    'track_coil',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("track_coil" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _minStockBaseMeta = const VerificationMeta(
    'minStockBase',
  );
  @override
  late final GeneratedColumn<int> minStockBase = GeneratedColumn<int>(
    'min_stock_base',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _activeMeta = const VerificationMeta('active');
  @override
  late final GeneratedColumn<bool> active = GeneratedColumn<bool>(
    'active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    shopId,
    createdAt,
    updatedAt,
    deletedAt,
    name,
    brand,
    category,
    hsn,
    gstRateBp,
    baseUnit,
    priceUnitFactor,
    trackSerial,
    trackCoil,
    minStockBase,
    active,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'items';
  @override
  VerificationContext validateIntegrity(
    Insertable<Item> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('shop_id')) {
      context.handle(
        _shopIdMeta,
        shopId.isAcceptableOrUnknown(data['shop_id']!, _shopIdMeta),
      );
    } else if (isInserting) {
      context.missing(_shopIdMeta);
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
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('brand')) {
      context.handle(
        _brandMeta,
        brand.isAcceptableOrUnknown(data['brand']!, _brandMeta),
      );
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    }
    if (data.containsKey('hsn')) {
      context.handle(
        _hsnMeta,
        hsn.isAcceptableOrUnknown(data['hsn']!, _hsnMeta),
      );
    }
    if (data.containsKey('gst_rate_bp')) {
      context.handle(
        _gstRateBpMeta,
        gstRateBp.isAcceptableOrUnknown(data['gst_rate_bp']!, _gstRateBpMeta),
      );
    }
    if (data.containsKey('base_unit')) {
      context.handle(
        _baseUnitMeta,
        baseUnit.isAcceptableOrUnknown(data['base_unit']!, _baseUnitMeta),
      );
    } else if (isInserting) {
      context.missing(_baseUnitMeta);
    }
    if (data.containsKey('price_unit_factor')) {
      context.handle(
        _priceUnitFactorMeta,
        priceUnitFactor.isAcceptableOrUnknown(
          data['price_unit_factor']!,
          _priceUnitFactorMeta,
        ),
      );
    }
    if (data.containsKey('track_serial')) {
      context.handle(
        _trackSerialMeta,
        trackSerial.isAcceptableOrUnknown(
          data['track_serial']!,
          _trackSerialMeta,
        ),
      );
    }
    if (data.containsKey('track_coil')) {
      context.handle(
        _trackCoilMeta,
        trackCoil.isAcceptableOrUnknown(data['track_coil']!, _trackCoilMeta),
      );
    }
    if (data.containsKey('min_stock_base')) {
      context.handle(
        _minStockBaseMeta,
        minStockBase.isAcceptableOrUnknown(
          data['min_stock_base']!,
          _minStockBaseMeta,
        ),
      );
    }
    if (data.containsKey('active')) {
      context.handle(
        _activeMeta,
        active.isAcceptableOrUnknown(data['active']!, _activeMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Item map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Item(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}id'],
          )!,
      shopId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}shop_id'],
          )!,
      createdAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}created_at'],
          )!,
      updatedAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}updated_at'],
          )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      name:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}name'],
          )!,
      brand: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}brand'],
      ),
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      ),
      hsn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hsn'],
      ),
      gstRateBp:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}gst_rate_bp'],
          )!,
      baseUnit:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}base_unit'],
          )!,
      priceUnitFactor:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}price_unit_factor'],
          )!,
      trackSerial:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}track_serial'],
          )!,
      trackCoil:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}track_coil'],
          )!,
      minStockBase:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}min_stock_base'],
          )!,
      active:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}active'],
          )!,
    );
  }

  @override
  $ItemsTable createAlias(String alias) {
    return $ItemsTable(attachedDatabase, alias);
  }
}

class Item extends DataClass implements Insertable<Item> {
  final String id;
  final String shopId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String name;
  final String? brand;
  final String? category;
  final String? hsn;
  final int gstRateBp;

  /// Smallest sold unit name, e.g. "mm" for cable, "pcs" for countable items.
  final String baseUnit;

  /// Base units per pricing unit (1000 for cable priced per metre, 1 for pieces).
  /// Prices are paise per pricing unit; see docs/decisions.md.
  final int priceUnitFactor;
  final bool trackSerial;
  final bool trackCoil;
  final int minStockBase;
  final bool active;
  const Item({
    required this.id,
    required this.shopId,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.name,
    this.brand,
    this.category,
    this.hsn,
    required this.gstRateBp,
    required this.baseUnit,
    required this.priceUnitFactor,
    required this.trackSerial,
    required this.trackCoil,
    required this.minStockBase,
    required this.active,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['shop_id'] = Variable<String>(shopId);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || brand != null) {
      map['brand'] = Variable<String>(brand);
    }
    if (!nullToAbsent || category != null) {
      map['category'] = Variable<String>(category);
    }
    if (!nullToAbsent || hsn != null) {
      map['hsn'] = Variable<String>(hsn);
    }
    map['gst_rate_bp'] = Variable<int>(gstRateBp);
    map['base_unit'] = Variable<String>(baseUnit);
    map['price_unit_factor'] = Variable<int>(priceUnitFactor);
    map['track_serial'] = Variable<bool>(trackSerial);
    map['track_coil'] = Variable<bool>(trackCoil);
    map['min_stock_base'] = Variable<int>(minStockBase);
    map['active'] = Variable<bool>(active);
    return map;
  }

  ItemsCompanion toCompanion(bool nullToAbsent) {
    return ItemsCompanion(
      id: Value(id),
      shopId: Value(shopId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt:
          deletedAt == null && nullToAbsent
              ? const Value.absent()
              : Value(deletedAt),
      name: Value(name),
      brand:
          brand == null && nullToAbsent ? const Value.absent() : Value(brand),
      category:
          category == null && nullToAbsent
              ? const Value.absent()
              : Value(category),
      hsn: hsn == null && nullToAbsent ? const Value.absent() : Value(hsn),
      gstRateBp: Value(gstRateBp),
      baseUnit: Value(baseUnit),
      priceUnitFactor: Value(priceUnitFactor),
      trackSerial: Value(trackSerial),
      trackCoil: Value(trackCoil),
      minStockBase: Value(minStockBase),
      active: Value(active),
    );
  }

  factory Item.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Item(
      id: serializer.fromJson<String>(json['id']),
      shopId: serializer.fromJson<String>(json['shopId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      name: serializer.fromJson<String>(json['name']),
      brand: serializer.fromJson<String?>(json['brand']),
      category: serializer.fromJson<String?>(json['category']),
      hsn: serializer.fromJson<String?>(json['hsn']),
      gstRateBp: serializer.fromJson<int>(json['gstRateBp']),
      baseUnit: serializer.fromJson<String>(json['baseUnit']),
      priceUnitFactor: serializer.fromJson<int>(json['priceUnitFactor']),
      trackSerial: serializer.fromJson<bool>(json['trackSerial']),
      trackCoil: serializer.fromJson<bool>(json['trackCoil']),
      minStockBase: serializer.fromJson<int>(json['minStockBase']),
      active: serializer.fromJson<bool>(json['active']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'shopId': serializer.toJson<String>(shopId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'name': serializer.toJson<String>(name),
      'brand': serializer.toJson<String?>(brand),
      'category': serializer.toJson<String?>(category),
      'hsn': serializer.toJson<String?>(hsn),
      'gstRateBp': serializer.toJson<int>(gstRateBp),
      'baseUnit': serializer.toJson<String>(baseUnit),
      'priceUnitFactor': serializer.toJson<int>(priceUnitFactor),
      'trackSerial': serializer.toJson<bool>(trackSerial),
      'trackCoil': serializer.toJson<bool>(trackCoil),
      'minStockBase': serializer.toJson<int>(minStockBase),
      'active': serializer.toJson<bool>(active),
    };
  }

  Item copyWith({
    String? id,
    String? shopId,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? name,
    Value<String?> brand = const Value.absent(),
    Value<String?> category = const Value.absent(),
    Value<String?> hsn = const Value.absent(),
    int? gstRateBp,
    String? baseUnit,
    int? priceUnitFactor,
    bool? trackSerial,
    bool? trackCoil,
    int? minStockBase,
    bool? active,
  }) => Item(
    id: id ?? this.id,
    shopId: shopId ?? this.shopId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    name: name ?? this.name,
    brand: brand.present ? brand.value : this.brand,
    category: category.present ? category.value : this.category,
    hsn: hsn.present ? hsn.value : this.hsn,
    gstRateBp: gstRateBp ?? this.gstRateBp,
    baseUnit: baseUnit ?? this.baseUnit,
    priceUnitFactor: priceUnitFactor ?? this.priceUnitFactor,
    trackSerial: trackSerial ?? this.trackSerial,
    trackCoil: trackCoil ?? this.trackCoil,
    minStockBase: minStockBase ?? this.minStockBase,
    active: active ?? this.active,
  );
  Item copyWithCompanion(ItemsCompanion data) {
    return Item(
      id: data.id.present ? data.id.value : this.id,
      shopId: data.shopId.present ? data.shopId.value : this.shopId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      name: data.name.present ? data.name.value : this.name,
      brand: data.brand.present ? data.brand.value : this.brand,
      category: data.category.present ? data.category.value : this.category,
      hsn: data.hsn.present ? data.hsn.value : this.hsn,
      gstRateBp: data.gstRateBp.present ? data.gstRateBp.value : this.gstRateBp,
      baseUnit: data.baseUnit.present ? data.baseUnit.value : this.baseUnit,
      priceUnitFactor:
          data.priceUnitFactor.present
              ? data.priceUnitFactor.value
              : this.priceUnitFactor,
      trackSerial:
          data.trackSerial.present ? data.trackSerial.value : this.trackSerial,
      trackCoil: data.trackCoil.present ? data.trackCoil.value : this.trackCoil,
      minStockBase:
          data.minStockBase.present
              ? data.minStockBase.value
              : this.minStockBase,
      active: data.active.present ? data.active.value : this.active,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Item(')
          ..write('id: $id, ')
          ..write('shopId: $shopId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('name: $name, ')
          ..write('brand: $brand, ')
          ..write('category: $category, ')
          ..write('hsn: $hsn, ')
          ..write('gstRateBp: $gstRateBp, ')
          ..write('baseUnit: $baseUnit, ')
          ..write('priceUnitFactor: $priceUnitFactor, ')
          ..write('trackSerial: $trackSerial, ')
          ..write('trackCoil: $trackCoil, ')
          ..write('minStockBase: $minStockBase, ')
          ..write('active: $active')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    shopId,
    createdAt,
    updatedAt,
    deletedAt,
    name,
    brand,
    category,
    hsn,
    gstRateBp,
    baseUnit,
    priceUnitFactor,
    trackSerial,
    trackCoil,
    minStockBase,
    active,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Item &&
          other.id == this.id &&
          other.shopId == this.shopId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.name == this.name &&
          other.brand == this.brand &&
          other.category == this.category &&
          other.hsn == this.hsn &&
          other.gstRateBp == this.gstRateBp &&
          other.baseUnit == this.baseUnit &&
          other.priceUnitFactor == this.priceUnitFactor &&
          other.trackSerial == this.trackSerial &&
          other.trackCoil == this.trackCoil &&
          other.minStockBase == this.minStockBase &&
          other.active == this.active);
}

class ItemsCompanion extends UpdateCompanion<Item> {
  final Value<String> id;
  final Value<String> shopId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> name;
  final Value<String?> brand;
  final Value<String?> category;
  final Value<String?> hsn;
  final Value<int> gstRateBp;
  final Value<String> baseUnit;
  final Value<int> priceUnitFactor;
  final Value<bool> trackSerial;
  final Value<bool> trackCoil;
  final Value<int> minStockBase;
  final Value<bool> active;
  final Value<int> rowid;
  const ItemsCompanion({
    this.id = const Value.absent(),
    this.shopId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.name = const Value.absent(),
    this.brand = const Value.absent(),
    this.category = const Value.absent(),
    this.hsn = const Value.absent(),
    this.gstRateBp = const Value.absent(),
    this.baseUnit = const Value.absent(),
    this.priceUnitFactor = const Value.absent(),
    this.trackSerial = const Value.absent(),
    this.trackCoil = const Value.absent(),
    this.minStockBase = const Value.absent(),
    this.active = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ItemsCompanion.insert({
    required String id,
    required String shopId,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    required String name,
    this.brand = const Value.absent(),
    this.category = const Value.absent(),
    this.hsn = const Value.absent(),
    this.gstRateBp = const Value.absent(),
    required String baseUnit,
    this.priceUnitFactor = const Value.absent(),
    this.trackSerial = const Value.absent(),
    this.trackCoil = const Value.absent(),
    this.minStockBase = const Value.absent(),
    this.active = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       shopId = Value(shopId),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       name = Value(name),
       baseUnit = Value(baseUnit);
  static Insertable<Item> custom({
    Expression<String>? id,
    Expression<String>? shopId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? name,
    Expression<String>? brand,
    Expression<String>? category,
    Expression<String>? hsn,
    Expression<int>? gstRateBp,
    Expression<String>? baseUnit,
    Expression<int>? priceUnitFactor,
    Expression<bool>? trackSerial,
    Expression<bool>? trackCoil,
    Expression<int>? minStockBase,
    Expression<bool>? active,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (shopId != null) 'shop_id': shopId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (name != null) 'name': name,
      if (brand != null) 'brand': brand,
      if (category != null) 'category': category,
      if (hsn != null) 'hsn': hsn,
      if (gstRateBp != null) 'gst_rate_bp': gstRateBp,
      if (baseUnit != null) 'base_unit': baseUnit,
      if (priceUnitFactor != null) 'price_unit_factor': priceUnitFactor,
      if (trackSerial != null) 'track_serial': trackSerial,
      if (trackCoil != null) 'track_coil': trackCoil,
      if (minStockBase != null) 'min_stock_base': minStockBase,
      if (active != null) 'active': active,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ItemsCompanion copyWith({
    Value<String>? id,
    Value<String>? shopId,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? name,
    Value<String?>? brand,
    Value<String?>? category,
    Value<String?>? hsn,
    Value<int>? gstRateBp,
    Value<String>? baseUnit,
    Value<int>? priceUnitFactor,
    Value<bool>? trackSerial,
    Value<bool>? trackCoil,
    Value<int>? minStockBase,
    Value<bool>? active,
    Value<int>? rowid,
  }) {
    return ItemsCompanion(
      id: id ?? this.id,
      shopId: shopId ?? this.shopId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      category: category ?? this.category,
      hsn: hsn ?? this.hsn,
      gstRateBp: gstRateBp ?? this.gstRateBp,
      baseUnit: baseUnit ?? this.baseUnit,
      priceUnitFactor: priceUnitFactor ?? this.priceUnitFactor,
      trackSerial: trackSerial ?? this.trackSerial,
      trackCoil: trackCoil ?? this.trackCoil,
      minStockBase: minStockBase ?? this.minStockBase,
      active: active ?? this.active,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (shopId.present) {
      map['shop_id'] = Variable<String>(shopId.value);
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
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (brand.present) {
      map['brand'] = Variable<String>(brand.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (hsn.present) {
      map['hsn'] = Variable<String>(hsn.value);
    }
    if (gstRateBp.present) {
      map['gst_rate_bp'] = Variable<int>(gstRateBp.value);
    }
    if (baseUnit.present) {
      map['base_unit'] = Variable<String>(baseUnit.value);
    }
    if (priceUnitFactor.present) {
      map['price_unit_factor'] = Variable<int>(priceUnitFactor.value);
    }
    if (trackSerial.present) {
      map['track_serial'] = Variable<bool>(trackSerial.value);
    }
    if (trackCoil.present) {
      map['track_coil'] = Variable<bool>(trackCoil.value);
    }
    if (minStockBase.present) {
      map['min_stock_base'] = Variable<int>(minStockBase.value);
    }
    if (active.present) {
      map['active'] = Variable<bool>(active.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ItemsCompanion(')
          ..write('id: $id, ')
          ..write('shopId: $shopId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('name: $name, ')
          ..write('brand: $brand, ')
          ..write('category: $category, ')
          ..write('hsn: $hsn, ')
          ..write('gstRateBp: $gstRateBp, ')
          ..write('baseUnit: $baseUnit, ')
          ..write('priceUnitFactor: $priceUnitFactor, ')
          ..write('trackSerial: $trackSerial, ')
          ..write('trackCoil: $trackCoil, ')
          ..write('minStockBase: $minStockBase, ')
          ..write('active: $active, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ItemUnitsTable extends ItemUnits
    with TableInfo<$ItemUnitsTable, ItemUnit> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ItemUnitsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _shopIdMeta = const VerificationMeta('shopId');
  @override
  late final GeneratedColumn<String> shopId = GeneratedColumn<String>(
    'shop_id',
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
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<String> itemId = GeneratedColumn<String>(
    'item_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES items (id)',
    ),
  );
  static const VerificationMeta _unitNameMeta = const VerificationMeta(
    'unitName',
  );
  @override
  late final GeneratedColumn<String> unitName = GeneratedColumn<String>(
    'unit_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _factorToBaseMeta = const VerificationMeta(
    'factorToBase',
  );
  @override
  late final GeneratedColumn<int> factorToBase = GeneratedColumn<int>(
    'factor_to_base',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    shopId,
    createdAt,
    updatedAt,
    deletedAt,
    itemId,
    unitName,
    factorToBase,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'item_units';
  @override
  VerificationContext validateIntegrity(
    Insertable<ItemUnit> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('shop_id')) {
      context.handle(
        _shopIdMeta,
        shopId.isAcceptableOrUnknown(data['shop_id']!, _shopIdMeta),
      );
    } else if (isInserting) {
      context.missing(_shopIdMeta);
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
    if (data.containsKey('item_id')) {
      context.handle(
        _itemIdMeta,
        itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta),
      );
    } else if (isInserting) {
      context.missing(_itemIdMeta);
    }
    if (data.containsKey('unit_name')) {
      context.handle(
        _unitNameMeta,
        unitName.isAcceptableOrUnknown(data['unit_name']!, _unitNameMeta),
      );
    } else if (isInserting) {
      context.missing(_unitNameMeta);
    }
    if (data.containsKey('factor_to_base')) {
      context.handle(
        _factorToBaseMeta,
        factorToBase.isAcceptableOrUnknown(
          data['factor_to_base']!,
          _factorToBaseMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_factorToBaseMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ItemUnit map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ItemUnit(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}id'],
          )!,
      shopId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}shop_id'],
          )!,
      createdAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}created_at'],
          )!,
      updatedAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}updated_at'],
          )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      itemId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}item_id'],
          )!,
      unitName:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}unit_name'],
          )!,
      factorToBase:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}factor_to_base'],
          )!,
    );
  }

  @override
  $ItemUnitsTable createAlias(String alias) {
    return $ItemUnitsTable(attachedDatabase, alias);
  }
}

class ItemUnit extends DataClass implements Insertable<ItemUnit> {
  final String id;
  final String shopId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String itemId;
  final String unitName;

  /// Integer base units in one of this unit (roll of 90 m = 90000 mm).
  final int factorToBase;
  const ItemUnit({
    required this.id,
    required this.shopId,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.itemId,
    required this.unitName,
    required this.factorToBase,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['shop_id'] = Variable<String>(shopId);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['item_id'] = Variable<String>(itemId);
    map['unit_name'] = Variable<String>(unitName);
    map['factor_to_base'] = Variable<int>(factorToBase);
    return map;
  }

  ItemUnitsCompanion toCompanion(bool nullToAbsent) {
    return ItemUnitsCompanion(
      id: Value(id),
      shopId: Value(shopId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt:
          deletedAt == null && nullToAbsent
              ? const Value.absent()
              : Value(deletedAt),
      itemId: Value(itemId),
      unitName: Value(unitName),
      factorToBase: Value(factorToBase),
    );
  }

  factory ItemUnit.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ItemUnit(
      id: serializer.fromJson<String>(json['id']),
      shopId: serializer.fromJson<String>(json['shopId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      itemId: serializer.fromJson<String>(json['itemId']),
      unitName: serializer.fromJson<String>(json['unitName']),
      factorToBase: serializer.fromJson<int>(json['factorToBase']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'shopId': serializer.toJson<String>(shopId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'itemId': serializer.toJson<String>(itemId),
      'unitName': serializer.toJson<String>(unitName),
      'factorToBase': serializer.toJson<int>(factorToBase),
    };
  }

  ItemUnit copyWith({
    String? id,
    String? shopId,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? itemId,
    String? unitName,
    int? factorToBase,
  }) => ItemUnit(
    id: id ?? this.id,
    shopId: shopId ?? this.shopId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    itemId: itemId ?? this.itemId,
    unitName: unitName ?? this.unitName,
    factorToBase: factorToBase ?? this.factorToBase,
  );
  ItemUnit copyWithCompanion(ItemUnitsCompanion data) {
    return ItemUnit(
      id: data.id.present ? data.id.value : this.id,
      shopId: data.shopId.present ? data.shopId.value : this.shopId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      unitName: data.unitName.present ? data.unitName.value : this.unitName,
      factorToBase:
          data.factorToBase.present
              ? data.factorToBase.value
              : this.factorToBase,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ItemUnit(')
          ..write('id: $id, ')
          ..write('shopId: $shopId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('itemId: $itemId, ')
          ..write('unitName: $unitName, ')
          ..write('factorToBase: $factorToBase')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    shopId,
    createdAt,
    updatedAt,
    deletedAt,
    itemId,
    unitName,
    factorToBase,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ItemUnit &&
          other.id == this.id &&
          other.shopId == this.shopId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.itemId == this.itemId &&
          other.unitName == this.unitName &&
          other.factorToBase == this.factorToBase);
}

class ItemUnitsCompanion extends UpdateCompanion<ItemUnit> {
  final Value<String> id;
  final Value<String> shopId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> itemId;
  final Value<String> unitName;
  final Value<int> factorToBase;
  final Value<int> rowid;
  const ItemUnitsCompanion({
    this.id = const Value.absent(),
    this.shopId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.itemId = const Value.absent(),
    this.unitName = const Value.absent(),
    this.factorToBase = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ItemUnitsCompanion.insert({
    required String id,
    required String shopId,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    required String itemId,
    required String unitName,
    required int factorToBase,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       shopId = Value(shopId),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       itemId = Value(itemId),
       unitName = Value(unitName),
       factorToBase = Value(factorToBase);
  static Insertable<ItemUnit> custom({
    Expression<String>? id,
    Expression<String>? shopId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? itemId,
    Expression<String>? unitName,
    Expression<int>? factorToBase,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (shopId != null) 'shop_id': shopId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (itemId != null) 'item_id': itemId,
      if (unitName != null) 'unit_name': unitName,
      if (factorToBase != null) 'factor_to_base': factorToBase,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ItemUnitsCompanion copyWith({
    Value<String>? id,
    Value<String>? shopId,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? itemId,
    Value<String>? unitName,
    Value<int>? factorToBase,
    Value<int>? rowid,
  }) {
    return ItemUnitsCompanion(
      id: id ?? this.id,
      shopId: shopId ?? this.shopId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      itemId: itemId ?? this.itemId,
      unitName: unitName ?? this.unitName,
      factorToBase: factorToBase ?? this.factorToBase,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (shopId.present) {
      map['shop_id'] = Variable<String>(shopId.value);
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
    if (itemId.present) {
      map['item_id'] = Variable<String>(itemId.value);
    }
    if (unitName.present) {
      map['unit_name'] = Variable<String>(unitName.value);
    }
    if (factorToBase.present) {
      map['factor_to_base'] = Variable<int>(factorToBase.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ItemUnitsCompanion(')
          ..write('id: $id, ')
          ..write('shopId: $shopId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('itemId: $itemId, ')
          ..write('unitName: $unitName, ')
          ..write('factorToBase: $factorToBase, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ItemVariantsTable extends ItemVariants
    with TableInfo<$ItemVariantsTable, ItemVariant> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ItemVariantsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _shopIdMeta = const VerificationMeta('shopId');
  @override
  late final GeneratedColumn<String> shopId = GeneratedColumn<String>(
    'shop_id',
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
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<String> itemId = GeneratedColumn<String>(
    'item_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES items (id)',
    ),
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sizeMeta = const VerificationMeta('size');
  @override
  late final GeneratedColumn<String> size = GeneratedColumn<String>(
    'size',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ratingMeta = const VerificationMeta('rating');
  @override
  late final GeneratedColumn<String> rating = GeneratedColumn<String>(
    'rating',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _colourMeta = const VerificationMeta('colour');
  @override
  late final GeneratedColumn<String> colour = GeneratedColumn<String>(
    'colour',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _barcodeMeta = const VerificationMeta(
    'barcode',
  );
  @override
  late final GeneratedColumn<String> barcode = GeneratedColumn<String>(
    'barcode',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _skuMeta = const VerificationMeta('sku');
  @override
  late final GeneratedColumn<String> sku = GeneratedColumn<String>(
    'sku',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    shopId,
    createdAt,
    updatedAt,
    deletedAt,
    itemId,
    label,
    size,
    rating,
    colour,
    barcode,
    sku,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'item_variants';
  @override
  VerificationContext validateIntegrity(
    Insertable<ItemVariant> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('shop_id')) {
      context.handle(
        _shopIdMeta,
        shopId.isAcceptableOrUnknown(data['shop_id']!, _shopIdMeta),
      );
    } else if (isInserting) {
      context.missing(_shopIdMeta);
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
    if (data.containsKey('item_id')) {
      context.handle(
        _itemIdMeta,
        itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta),
      );
    } else if (isInserting) {
      context.missing(_itemIdMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    if (data.containsKey('size')) {
      context.handle(
        _sizeMeta,
        size.isAcceptableOrUnknown(data['size']!, _sizeMeta),
      );
    }
    if (data.containsKey('rating')) {
      context.handle(
        _ratingMeta,
        rating.isAcceptableOrUnknown(data['rating']!, _ratingMeta),
      );
    }
    if (data.containsKey('colour')) {
      context.handle(
        _colourMeta,
        colour.isAcceptableOrUnknown(data['colour']!, _colourMeta),
      );
    }
    if (data.containsKey('barcode')) {
      context.handle(
        _barcodeMeta,
        barcode.isAcceptableOrUnknown(data['barcode']!, _barcodeMeta),
      );
    }
    if (data.containsKey('sku')) {
      context.handle(
        _skuMeta,
        sku.isAcceptableOrUnknown(data['sku']!, _skuMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ItemVariant map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ItemVariant(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}id'],
          )!,
      shopId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}shop_id'],
          )!,
      createdAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}created_at'],
          )!,
      updatedAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}updated_at'],
          )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      itemId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}item_id'],
          )!,
      label:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}label'],
          )!,
      size: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}size'],
      ),
      rating: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rating'],
      ),
      colour: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}colour'],
      ),
      barcode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}barcode'],
      ),
      sku: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sku'],
      ),
    );
  }

  @override
  $ItemVariantsTable createAlias(String alias) {
    return $ItemVariantsTable(attachedDatabase, alias);
  }
}

class ItemVariant extends DataClass implements Insertable<ItemVariant> {
  final String id;
  final String shopId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String itemId;
  final String label;
  final String? size;
  final String? rating;
  final String? colour;
  final String? barcode;
  final String? sku;
  const ItemVariant({
    required this.id,
    required this.shopId,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.itemId,
    required this.label,
    this.size,
    this.rating,
    this.colour,
    this.barcode,
    this.sku,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['shop_id'] = Variable<String>(shopId);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['item_id'] = Variable<String>(itemId);
    map['label'] = Variable<String>(label);
    if (!nullToAbsent || size != null) {
      map['size'] = Variable<String>(size);
    }
    if (!nullToAbsent || rating != null) {
      map['rating'] = Variable<String>(rating);
    }
    if (!nullToAbsent || colour != null) {
      map['colour'] = Variable<String>(colour);
    }
    if (!nullToAbsent || barcode != null) {
      map['barcode'] = Variable<String>(barcode);
    }
    if (!nullToAbsent || sku != null) {
      map['sku'] = Variable<String>(sku);
    }
    return map;
  }

  ItemVariantsCompanion toCompanion(bool nullToAbsent) {
    return ItemVariantsCompanion(
      id: Value(id),
      shopId: Value(shopId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt:
          deletedAt == null && nullToAbsent
              ? const Value.absent()
              : Value(deletedAt),
      itemId: Value(itemId),
      label: Value(label),
      size: size == null && nullToAbsent ? const Value.absent() : Value(size),
      rating:
          rating == null && nullToAbsent ? const Value.absent() : Value(rating),
      colour:
          colour == null && nullToAbsent ? const Value.absent() : Value(colour),
      barcode:
          barcode == null && nullToAbsent
              ? const Value.absent()
              : Value(barcode),
      sku: sku == null && nullToAbsent ? const Value.absent() : Value(sku),
    );
  }

  factory ItemVariant.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ItemVariant(
      id: serializer.fromJson<String>(json['id']),
      shopId: serializer.fromJson<String>(json['shopId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      itemId: serializer.fromJson<String>(json['itemId']),
      label: serializer.fromJson<String>(json['label']),
      size: serializer.fromJson<String?>(json['size']),
      rating: serializer.fromJson<String?>(json['rating']),
      colour: serializer.fromJson<String?>(json['colour']),
      barcode: serializer.fromJson<String?>(json['barcode']),
      sku: serializer.fromJson<String?>(json['sku']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'shopId': serializer.toJson<String>(shopId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'itemId': serializer.toJson<String>(itemId),
      'label': serializer.toJson<String>(label),
      'size': serializer.toJson<String?>(size),
      'rating': serializer.toJson<String?>(rating),
      'colour': serializer.toJson<String?>(colour),
      'barcode': serializer.toJson<String?>(barcode),
      'sku': serializer.toJson<String?>(sku),
    };
  }

  ItemVariant copyWith({
    String? id,
    String? shopId,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? itemId,
    String? label,
    Value<String?> size = const Value.absent(),
    Value<String?> rating = const Value.absent(),
    Value<String?> colour = const Value.absent(),
    Value<String?> barcode = const Value.absent(),
    Value<String?> sku = const Value.absent(),
  }) => ItemVariant(
    id: id ?? this.id,
    shopId: shopId ?? this.shopId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    itemId: itemId ?? this.itemId,
    label: label ?? this.label,
    size: size.present ? size.value : this.size,
    rating: rating.present ? rating.value : this.rating,
    colour: colour.present ? colour.value : this.colour,
    barcode: barcode.present ? barcode.value : this.barcode,
    sku: sku.present ? sku.value : this.sku,
  );
  ItemVariant copyWithCompanion(ItemVariantsCompanion data) {
    return ItemVariant(
      id: data.id.present ? data.id.value : this.id,
      shopId: data.shopId.present ? data.shopId.value : this.shopId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      label: data.label.present ? data.label.value : this.label,
      size: data.size.present ? data.size.value : this.size,
      rating: data.rating.present ? data.rating.value : this.rating,
      colour: data.colour.present ? data.colour.value : this.colour,
      barcode: data.barcode.present ? data.barcode.value : this.barcode,
      sku: data.sku.present ? data.sku.value : this.sku,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ItemVariant(')
          ..write('id: $id, ')
          ..write('shopId: $shopId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('itemId: $itemId, ')
          ..write('label: $label, ')
          ..write('size: $size, ')
          ..write('rating: $rating, ')
          ..write('colour: $colour, ')
          ..write('barcode: $barcode, ')
          ..write('sku: $sku')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    shopId,
    createdAt,
    updatedAt,
    deletedAt,
    itemId,
    label,
    size,
    rating,
    colour,
    barcode,
    sku,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ItemVariant &&
          other.id == this.id &&
          other.shopId == this.shopId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.itemId == this.itemId &&
          other.label == this.label &&
          other.size == this.size &&
          other.rating == this.rating &&
          other.colour == this.colour &&
          other.barcode == this.barcode &&
          other.sku == this.sku);
}

class ItemVariantsCompanion extends UpdateCompanion<ItemVariant> {
  final Value<String> id;
  final Value<String> shopId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> itemId;
  final Value<String> label;
  final Value<String?> size;
  final Value<String?> rating;
  final Value<String?> colour;
  final Value<String?> barcode;
  final Value<String?> sku;
  final Value<int> rowid;
  const ItemVariantsCompanion({
    this.id = const Value.absent(),
    this.shopId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.itemId = const Value.absent(),
    this.label = const Value.absent(),
    this.size = const Value.absent(),
    this.rating = const Value.absent(),
    this.colour = const Value.absent(),
    this.barcode = const Value.absent(),
    this.sku = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ItemVariantsCompanion.insert({
    required String id,
    required String shopId,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    required String itemId,
    required String label,
    this.size = const Value.absent(),
    this.rating = const Value.absent(),
    this.colour = const Value.absent(),
    this.barcode = const Value.absent(),
    this.sku = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       shopId = Value(shopId),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       itemId = Value(itemId),
       label = Value(label);
  static Insertable<ItemVariant> custom({
    Expression<String>? id,
    Expression<String>? shopId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? itemId,
    Expression<String>? label,
    Expression<String>? size,
    Expression<String>? rating,
    Expression<String>? colour,
    Expression<String>? barcode,
    Expression<String>? sku,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (shopId != null) 'shop_id': shopId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (itemId != null) 'item_id': itemId,
      if (label != null) 'label': label,
      if (size != null) 'size': size,
      if (rating != null) 'rating': rating,
      if (colour != null) 'colour': colour,
      if (barcode != null) 'barcode': barcode,
      if (sku != null) 'sku': sku,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ItemVariantsCompanion copyWith({
    Value<String>? id,
    Value<String>? shopId,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? itemId,
    Value<String>? label,
    Value<String?>? size,
    Value<String?>? rating,
    Value<String?>? colour,
    Value<String?>? barcode,
    Value<String?>? sku,
    Value<int>? rowid,
  }) {
    return ItemVariantsCompanion(
      id: id ?? this.id,
      shopId: shopId ?? this.shopId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      itemId: itemId ?? this.itemId,
      label: label ?? this.label,
      size: size ?? this.size,
      rating: rating ?? this.rating,
      colour: colour ?? this.colour,
      barcode: barcode ?? this.barcode,
      sku: sku ?? this.sku,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (shopId.present) {
      map['shop_id'] = Variable<String>(shopId.value);
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
    if (itemId.present) {
      map['item_id'] = Variable<String>(itemId.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (size.present) {
      map['size'] = Variable<String>(size.value);
    }
    if (rating.present) {
      map['rating'] = Variable<String>(rating.value);
    }
    if (colour.present) {
      map['colour'] = Variable<String>(colour.value);
    }
    if (barcode.present) {
      map['barcode'] = Variable<String>(barcode.value);
    }
    if (sku.present) {
      map['sku'] = Variable<String>(sku.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ItemVariantsCompanion(')
          ..write('id: $id, ')
          ..write('shopId: $shopId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('itemId: $itemId, ')
          ..write('label: $label, ')
          ..write('size: $size, ')
          ..write('rating: $rating, ')
          ..write('colour: $colour, ')
          ..write('barcode: $barcode, ')
          ..write('sku: $sku, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ItemPricesTable extends ItemPrices
    with TableInfo<$ItemPricesTable, ItemPrice> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ItemPricesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _shopIdMeta = const VerificationMeta('shopId');
  @override
  late final GeneratedColumn<String> shopId = GeneratedColumn<String>(
    'shop_id',
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
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<String> itemId = GeneratedColumn<String>(
    'item_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES items (id)',
    ),
  );
  static const VerificationMeta _variantIdMeta = const VerificationMeta(
    'variantId',
  );
  @override
  late final GeneratedColumn<String> variantId = GeneratedColumn<String>(
    'variant_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES item_variants (id)',
    ),
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
  static const VerificationMeta _ratePaiseMeta = const VerificationMeta(
    'ratePaise',
  );
  @override
  late final GeneratedColumn<int> ratePaise = GeneratedColumn<int>(
    'rate_paise',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    shopId,
    createdAt,
    updatedAt,
    deletedAt,
    itemId,
    variantId,
    tier,
    ratePaise,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'item_prices';
  @override
  VerificationContext validateIntegrity(
    Insertable<ItemPrice> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('shop_id')) {
      context.handle(
        _shopIdMeta,
        shopId.isAcceptableOrUnknown(data['shop_id']!, _shopIdMeta),
      );
    } else if (isInserting) {
      context.missing(_shopIdMeta);
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
    if (data.containsKey('item_id')) {
      context.handle(
        _itemIdMeta,
        itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta),
      );
    } else if (isInserting) {
      context.missing(_itemIdMeta);
    }
    if (data.containsKey('variant_id')) {
      context.handle(
        _variantIdMeta,
        variantId.isAcceptableOrUnknown(data['variant_id']!, _variantIdMeta),
      );
    }
    if (data.containsKey('tier')) {
      context.handle(
        _tierMeta,
        tier.isAcceptableOrUnknown(data['tier']!, _tierMeta),
      );
    } else if (isInserting) {
      context.missing(_tierMeta);
    }
    if (data.containsKey('rate_paise')) {
      context.handle(
        _ratePaiseMeta,
        ratePaise.isAcceptableOrUnknown(data['rate_paise']!, _ratePaiseMeta),
      );
    } else if (isInserting) {
      context.missing(_ratePaiseMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ItemPrice map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ItemPrice(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}id'],
          )!,
      shopId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}shop_id'],
          )!,
      createdAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}created_at'],
          )!,
      updatedAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}updated_at'],
          )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      itemId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}item_id'],
          )!,
      variantId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}variant_id'],
      ),
      tier:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}tier'],
          )!,
      ratePaise:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}rate_paise'],
          )!,
    );
  }

  @override
  $ItemPricesTable createAlias(String alias) {
    return $ItemPricesTable(attachedDatabase, alias);
  }
}

class ItemPrice extends DataClass implements Insertable<ItemPrice> {
  final String id;
  final String shopId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String itemId;
  final String? variantId;

  /// retail | contractor | dealer
  final String tier;

  /// Paise per pricing unit (per metre for cable, per piece otherwise).
  final int ratePaise;
  const ItemPrice({
    required this.id,
    required this.shopId,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.itemId,
    this.variantId,
    required this.tier,
    required this.ratePaise,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['shop_id'] = Variable<String>(shopId);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['item_id'] = Variable<String>(itemId);
    if (!nullToAbsent || variantId != null) {
      map['variant_id'] = Variable<String>(variantId);
    }
    map['tier'] = Variable<String>(tier);
    map['rate_paise'] = Variable<int>(ratePaise);
    return map;
  }

  ItemPricesCompanion toCompanion(bool nullToAbsent) {
    return ItemPricesCompanion(
      id: Value(id),
      shopId: Value(shopId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt:
          deletedAt == null && nullToAbsent
              ? const Value.absent()
              : Value(deletedAt),
      itemId: Value(itemId),
      variantId:
          variantId == null && nullToAbsent
              ? const Value.absent()
              : Value(variantId),
      tier: Value(tier),
      ratePaise: Value(ratePaise),
    );
  }

  factory ItemPrice.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ItemPrice(
      id: serializer.fromJson<String>(json['id']),
      shopId: serializer.fromJson<String>(json['shopId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      itemId: serializer.fromJson<String>(json['itemId']),
      variantId: serializer.fromJson<String?>(json['variantId']),
      tier: serializer.fromJson<String>(json['tier']),
      ratePaise: serializer.fromJson<int>(json['ratePaise']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'shopId': serializer.toJson<String>(shopId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'itemId': serializer.toJson<String>(itemId),
      'variantId': serializer.toJson<String?>(variantId),
      'tier': serializer.toJson<String>(tier),
      'ratePaise': serializer.toJson<int>(ratePaise),
    };
  }

  ItemPrice copyWith({
    String? id,
    String? shopId,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? itemId,
    Value<String?> variantId = const Value.absent(),
    String? tier,
    int? ratePaise,
  }) => ItemPrice(
    id: id ?? this.id,
    shopId: shopId ?? this.shopId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    itemId: itemId ?? this.itemId,
    variantId: variantId.present ? variantId.value : this.variantId,
    tier: tier ?? this.tier,
    ratePaise: ratePaise ?? this.ratePaise,
  );
  ItemPrice copyWithCompanion(ItemPricesCompanion data) {
    return ItemPrice(
      id: data.id.present ? data.id.value : this.id,
      shopId: data.shopId.present ? data.shopId.value : this.shopId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      variantId: data.variantId.present ? data.variantId.value : this.variantId,
      tier: data.tier.present ? data.tier.value : this.tier,
      ratePaise: data.ratePaise.present ? data.ratePaise.value : this.ratePaise,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ItemPrice(')
          ..write('id: $id, ')
          ..write('shopId: $shopId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('itemId: $itemId, ')
          ..write('variantId: $variantId, ')
          ..write('tier: $tier, ')
          ..write('ratePaise: $ratePaise')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    shopId,
    createdAt,
    updatedAt,
    deletedAt,
    itemId,
    variantId,
    tier,
    ratePaise,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ItemPrice &&
          other.id == this.id &&
          other.shopId == this.shopId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.itemId == this.itemId &&
          other.variantId == this.variantId &&
          other.tier == this.tier &&
          other.ratePaise == this.ratePaise);
}

class ItemPricesCompanion extends UpdateCompanion<ItemPrice> {
  final Value<String> id;
  final Value<String> shopId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> itemId;
  final Value<String?> variantId;
  final Value<String> tier;
  final Value<int> ratePaise;
  final Value<int> rowid;
  const ItemPricesCompanion({
    this.id = const Value.absent(),
    this.shopId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.itemId = const Value.absent(),
    this.variantId = const Value.absent(),
    this.tier = const Value.absent(),
    this.ratePaise = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ItemPricesCompanion.insert({
    required String id,
    required String shopId,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    required String itemId,
    this.variantId = const Value.absent(),
    required String tier,
    required int ratePaise,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       shopId = Value(shopId),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       itemId = Value(itemId),
       tier = Value(tier),
       ratePaise = Value(ratePaise);
  static Insertable<ItemPrice> custom({
    Expression<String>? id,
    Expression<String>? shopId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? itemId,
    Expression<String>? variantId,
    Expression<String>? tier,
    Expression<int>? ratePaise,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (shopId != null) 'shop_id': shopId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (itemId != null) 'item_id': itemId,
      if (variantId != null) 'variant_id': variantId,
      if (tier != null) 'tier': tier,
      if (ratePaise != null) 'rate_paise': ratePaise,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ItemPricesCompanion copyWith({
    Value<String>? id,
    Value<String>? shopId,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? itemId,
    Value<String?>? variantId,
    Value<String>? tier,
    Value<int>? ratePaise,
    Value<int>? rowid,
  }) {
    return ItemPricesCompanion(
      id: id ?? this.id,
      shopId: shopId ?? this.shopId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      itemId: itemId ?? this.itemId,
      variantId: variantId ?? this.variantId,
      tier: tier ?? this.tier,
      ratePaise: ratePaise ?? this.ratePaise,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (shopId.present) {
      map['shop_id'] = Variable<String>(shopId.value);
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
    if (itemId.present) {
      map['item_id'] = Variable<String>(itemId.value);
    }
    if (variantId.present) {
      map['variant_id'] = Variable<String>(variantId.value);
    }
    if (tier.present) {
      map['tier'] = Variable<String>(tier.value);
    }
    if (ratePaise.present) {
      map['rate_paise'] = Variable<int>(ratePaise.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ItemPricesCompanion(')
          ..write('id: $id, ')
          ..write('shopId: $shopId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('itemId: $itemId, ')
          ..write('variantId: $variantId, ')
          ..write('tier: $tier, ')
          ..write('ratePaise: $ratePaise, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ItemCostsTable extends ItemCosts
    with TableInfo<$ItemCostsTable, ItemCost> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ItemCostsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _shopIdMeta = const VerificationMeta('shopId');
  @override
  late final GeneratedColumn<String> shopId = GeneratedColumn<String>(
    'shop_id',
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
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<String> itemId = GeneratedColumn<String>(
    'item_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES items (id)',
    ),
  );
  static const VerificationMeta _variantIdMeta = const VerificationMeta(
    'variantId',
  );
  @override
  late final GeneratedColumn<String> variantId = GeneratedColumn<String>(
    'variant_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES item_variants (id)',
    ),
  );
  static const VerificationMeta _costPaiseMeta = const VerificationMeta(
    'costPaise',
  );
  @override
  late final GeneratedColumn<int> costPaise = GeneratedColumn<int>(
    'cost_paise',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _effectiveFromMeta = const VerificationMeta(
    'effectiveFrom',
  );
  @override
  late final GeneratedColumn<DateTime> effectiveFrom =
      GeneratedColumn<DateTime>(
        'effective_from',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    shopId,
    createdAt,
    updatedAt,
    deletedAt,
    itemId,
    variantId,
    costPaise,
    effectiveFrom,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'item_costs';
  @override
  VerificationContext validateIntegrity(
    Insertable<ItemCost> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('shop_id')) {
      context.handle(
        _shopIdMeta,
        shopId.isAcceptableOrUnknown(data['shop_id']!, _shopIdMeta),
      );
    } else if (isInserting) {
      context.missing(_shopIdMeta);
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
    if (data.containsKey('item_id')) {
      context.handle(
        _itemIdMeta,
        itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta),
      );
    } else if (isInserting) {
      context.missing(_itemIdMeta);
    }
    if (data.containsKey('variant_id')) {
      context.handle(
        _variantIdMeta,
        variantId.isAcceptableOrUnknown(data['variant_id']!, _variantIdMeta),
      );
    }
    if (data.containsKey('cost_paise')) {
      context.handle(
        _costPaiseMeta,
        costPaise.isAcceptableOrUnknown(data['cost_paise']!, _costPaiseMeta),
      );
    } else if (isInserting) {
      context.missing(_costPaiseMeta);
    }
    if (data.containsKey('effective_from')) {
      context.handle(
        _effectiveFromMeta,
        effectiveFrom.isAcceptableOrUnknown(
          data['effective_from']!,
          _effectiveFromMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_effectiveFromMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ItemCost map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ItemCost(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}id'],
          )!,
      shopId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}shop_id'],
          )!,
      createdAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}created_at'],
          )!,
      updatedAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}updated_at'],
          )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      itemId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}item_id'],
          )!,
      variantId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}variant_id'],
      ),
      costPaise:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}cost_paise'],
          )!,
      effectiveFrom:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}effective_from'],
          )!,
    );
  }

  @override
  $ItemCostsTable createAlias(String alias) {
    return $ItemCostsTable(attachedDatabase, alias);
  }
}

class ItemCost extends DataClass implements Insertable<ItemCost> {
  final String id;
  final String shopId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String itemId;
  final String? variantId;

  /// Paise per pricing unit.
  final int costPaise;
  final DateTime effectiveFrom;
  const ItemCost({
    required this.id,
    required this.shopId,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.itemId,
    this.variantId,
    required this.costPaise,
    required this.effectiveFrom,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['shop_id'] = Variable<String>(shopId);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['item_id'] = Variable<String>(itemId);
    if (!nullToAbsent || variantId != null) {
      map['variant_id'] = Variable<String>(variantId);
    }
    map['cost_paise'] = Variable<int>(costPaise);
    map['effective_from'] = Variable<DateTime>(effectiveFrom);
    return map;
  }

  ItemCostsCompanion toCompanion(bool nullToAbsent) {
    return ItemCostsCompanion(
      id: Value(id),
      shopId: Value(shopId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt:
          deletedAt == null && nullToAbsent
              ? const Value.absent()
              : Value(deletedAt),
      itemId: Value(itemId),
      variantId:
          variantId == null && nullToAbsent
              ? const Value.absent()
              : Value(variantId),
      costPaise: Value(costPaise),
      effectiveFrom: Value(effectiveFrom),
    );
  }

  factory ItemCost.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ItemCost(
      id: serializer.fromJson<String>(json['id']),
      shopId: serializer.fromJson<String>(json['shopId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      itemId: serializer.fromJson<String>(json['itemId']),
      variantId: serializer.fromJson<String?>(json['variantId']),
      costPaise: serializer.fromJson<int>(json['costPaise']),
      effectiveFrom: serializer.fromJson<DateTime>(json['effectiveFrom']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'shopId': serializer.toJson<String>(shopId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'itemId': serializer.toJson<String>(itemId),
      'variantId': serializer.toJson<String?>(variantId),
      'costPaise': serializer.toJson<int>(costPaise),
      'effectiveFrom': serializer.toJson<DateTime>(effectiveFrom),
    };
  }

  ItemCost copyWith({
    String? id,
    String? shopId,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? itemId,
    Value<String?> variantId = const Value.absent(),
    int? costPaise,
    DateTime? effectiveFrom,
  }) => ItemCost(
    id: id ?? this.id,
    shopId: shopId ?? this.shopId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    itemId: itemId ?? this.itemId,
    variantId: variantId.present ? variantId.value : this.variantId,
    costPaise: costPaise ?? this.costPaise,
    effectiveFrom: effectiveFrom ?? this.effectiveFrom,
  );
  ItemCost copyWithCompanion(ItemCostsCompanion data) {
    return ItemCost(
      id: data.id.present ? data.id.value : this.id,
      shopId: data.shopId.present ? data.shopId.value : this.shopId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      variantId: data.variantId.present ? data.variantId.value : this.variantId,
      costPaise: data.costPaise.present ? data.costPaise.value : this.costPaise,
      effectiveFrom:
          data.effectiveFrom.present
              ? data.effectiveFrom.value
              : this.effectiveFrom,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ItemCost(')
          ..write('id: $id, ')
          ..write('shopId: $shopId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('itemId: $itemId, ')
          ..write('variantId: $variantId, ')
          ..write('costPaise: $costPaise, ')
          ..write('effectiveFrom: $effectiveFrom')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    shopId,
    createdAt,
    updatedAt,
    deletedAt,
    itemId,
    variantId,
    costPaise,
    effectiveFrom,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ItemCost &&
          other.id == this.id &&
          other.shopId == this.shopId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.itemId == this.itemId &&
          other.variantId == this.variantId &&
          other.costPaise == this.costPaise &&
          other.effectiveFrom == this.effectiveFrom);
}

class ItemCostsCompanion extends UpdateCompanion<ItemCost> {
  final Value<String> id;
  final Value<String> shopId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> itemId;
  final Value<String?> variantId;
  final Value<int> costPaise;
  final Value<DateTime> effectiveFrom;
  final Value<int> rowid;
  const ItemCostsCompanion({
    this.id = const Value.absent(),
    this.shopId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.itemId = const Value.absent(),
    this.variantId = const Value.absent(),
    this.costPaise = const Value.absent(),
    this.effectiveFrom = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ItemCostsCompanion.insert({
    required String id,
    required String shopId,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    required String itemId,
    this.variantId = const Value.absent(),
    required int costPaise,
    required DateTime effectiveFrom,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       shopId = Value(shopId),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       itemId = Value(itemId),
       costPaise = Value(costPaise),
       effectiveFrom = Value(effectiveFrom);
  static Insertable<ItemCost> custom({
    Expression<String>? id,
    Expression<String>? shopId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? itemId,
    Expression<String>? variantId,
    Expression<int>? costPaise,
    Expression<DateTime>? effectiveFrom,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (shopId != null) 'shop_id': shopId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (itemId != null) 'item_id': itemId,
      if (variantId != null) 'variant_id': variantId,
      if (costPaise != null) 'cost_paise': costPaise,
      if (effectiveFrom != null) 'effective_from': effectiveFrom,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ItemCostsCompanion copyWith({
    Value<String>? id,
    Value<String>? shopId,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? itemId,
    Value<String?>? variantId,
    Value<int>? costPaise,
    Value<DateTime>? effectiveFrom,
    Value<int>? rowid,
  }) {
    return ItemCostsCompanion(
      id: id ?? this.id,
      shopId: shopId ?? this.shopId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      itemId: itemId ?? this.itemId,
      variantId: variantId ?? this.variantId,
      costPaise: costPaise ?? this.costPaise,
      effectiveFrom: effectiveFrom ?? this.effectiveFrom,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (shopId.present) {
      map['shop_id'] = Variable<String>(shopId.value);
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
    if (itemId.present) {
      map['item_id'] = Variable<String>(itemId.value);
    }
    if (variantId.present) {
      map['variant_id'] = Variable<String>(variantId.value);
    }
    if (costPaise.present) {
      map['cost_paise'] = Variable<int>(costPaise.value);
    }
    if (effectiveFrom.present) {
      map['effective_from'] = Variable<DateTime>(effectiveFrom.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ItemCostsCompanion(')
          ..write('id: $id, ')
          ..write('shopId: $shopId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('itemId: $itemId, ')
          ..write('variantId: $variantId, ')
          ..write('costPaise: $costPaise, ')
          ..write('effectiveFrom: $effectiveFrom, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PartiesTable extends Parties with TableInfo<$PartiesTable, Party> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PartiesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _shopIdMeta = const VerificationMeta('shopId');
  @override
  late final GeneratedColumn<String> shopId = GeneratedColumn<String>(
    'shop_id',
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
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
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
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _gstinMeta = const VerificationMeta('gstin');
  @override
  late final GeneratedColumn<String> gstin = GeneratedColumn<String>(
    'gstin',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _addressMeta = const VerificationMeta(
    'address',
  );
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
    'address',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _stateCodeMeta = const VerificationMeta(
    'stateCode',
  );
  @override
  late final GeneratedColumn<String> stateCode = GeneratedColumn<String>(
    'state_code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tierMeta = const VerificationMeta('tier');
  @override
  late final GeneratedColumn<String> tier = GeneratedColumn<String>(
    'tier',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('retail'),
  );
  static const VerificationMeta _creditLimitPaiseMeta = const VerificationMeta(
    'creditLimitPaise',
  );
  @override
  late final GeneratedColumn<int> creditLimitPaise = GeneratedColumn<int>(
    'credit_limit_paise',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    shopId,
    createdAt,
    updatedAt,
    deletedAt,
    kind,
    name,
    phone,
    gstin,
    address,
    stateCode,
    tier,
    creditLimitPaise,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'parties';
  @override
  VerificationContext validateIntegrity(
    Insertable<Party> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('shop_id')) {
      context.handle(
        _shopIdMeta,
        shopId.isAcceptableOrUnknown(data['shop_id']!, _shopIdMeta),
      );
    } else if (isInserting) {
      context.missing(_shopIdMeta);
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
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    }
    if (data.containsKey('gstin')) {
      context.handle(
        _gstinMeta,
        gstin.isAcceptableOrUnknown(data['gstin']!, _gstinMeta),
      );
    }
    if (data.containsKey('address')) {
      context.handle(
        _addressMeta,
        address.isAcceptableOrUnknown(data['address']!, _addressMeta),
      );
    }
    if (data.containsKey('state_code')) {
      context.handle(
        _stateCodeMeta,
        stateCode.isAcceptableOrUnknown(data['state_code']!, _stateCodeMeta),
      );
    }
    if (data.containsKey('tier')) {
      context.handle(
        _tierMeta,
        tier.isAcceptableOrUnknown(data['tier']!, _tierMeta),
      );
    }
    if (data.containsKey('credit_limit_paise')) {
      context.handle(
        _creditLimitPaiseMeta,
        creditLimitPaise.isAcceptableOrUnknown(
          data['credit_limit_paise']!,
          _creditLimitPaiseMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Party map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Party(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}id'],
          )!,
      shopId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}shop_id'],
          )!,
      createdAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}created_at'],
          )!,
      updatedAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}updated_at'],
          )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      kind:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}kind'],
          )!,
      name:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}name'],
          )!,
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      ),
      gstin: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}gstin'],
      ),
      address: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}address'],
      ),
      stateCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}state_code'],
      ),
      tier:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}tier'],
          )!,
      creditLimitPaise:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}credit_limit_paise'],
          )!,
    );
  }

  @override
  $PartiesTable createAlias(String alias) {
    return $PartiesTable(attachedDatabase, alias);
  }
}

class Party extends DataClass implements Insertable<Party> {
  final String id;
  final String shopId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  /// customer | supplier | both
  final String kind;
  final String name;
  final String? phone;
  final String? gstin;
  final String? address;
  final String? stateCode;

  /// retail | contractor | dealer
  final String tier;
  final int creditLimitPaise;
  const Party({
    required this.id,
    required this.shopId,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.kind,
    required this.name,
    this.phone,
    this.gstin,
    this.address,
    this.stateCode,
    required this.tier,
    required this.creditLimitPaise,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['shop_id'] = Variable<String>(shopId);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['kind'] = Variable<String>(kind);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    if (!nullToAbsent || gstin != null) {
      map['gstin'] = Variable<String>(gstin);
    }
    if (!nullToAbsent || address != null) {
      map['address'] = Variable<String>(address);
    }
    if (!nullToAbsent || stateCode != null) {
      map['state_code'] = Variable<String>(stateCode);
    }
    map['tier'] = Variable<String>(tier);
    map['credit_limit_paise'] = Variable<int>(creditLimitPaise);
    return map;
  }

  PartiesCompanion toCompanion(bool nullToAbsent) {
    return PartiesCompanion(
      id: Value(id),
      shopId: Value(shopId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt:
          deletedAt == null && nullToAbsent
              ? const Value.absent()
              : Value(deletedAt),
      kind: Value(kind),
      name: Value(name),
      phone:
          phone == null && nullToAbsent ? const Value.absent() : Value(phone),
      gstin:
          gstin == null && nullToAbsent ? const Value.absent() : Value(gstin),
      address:
          address == null && nullToAbsent
              ? const Value.absent()
              : Value(address),
      stateCode:
          stateCode == null && nullToAbsent
              ? const Value.absent()
              : Value(stateCode),
      tier: Value(tier),
      creditLimitPaise: Value(creditLimitPaise),
    );
  }

  factory Party.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Party(
      id: serializer.fromJson<String>(json['id']),
      shopId: serializer.fromJson<String>(json['shopId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      kind: serializer.fromJson<String>(json['kind']),
      name: serializer.fromJson<String>(json['name']),
      phone: serializer.fromJson<String?>(json['phone']),
      gstin: serializer.fromJson<String?>(json['gstin']),
      address: serializer.fromJson<String?>(json['address']),
      stateCode: serializer.fromJson<String?>(json['stateCode']),
      tier: serializer.fromJson<String>(json['tier']),
      creditLimitPaise: serializer.fromJson<int>(json['creditLimitPaise']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'shopId': serializer.toJson<String>(shopId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'kind': serializer.toJson<String>(kind),
      'name': serializer.toJson<String>(name),
      'phone': serializer.toJson<String?>(phone),
      'gstin': serializer.toJson<String?>(gstin),
      'address': serializer.toJson<String?>(address),
      'stateCode': serializer.toJson<String?>(stateCode),
      'tier': serializer.toJson<String>(tier),
      'creditLimitPaise': serializer.toJson<int>(creditLimitPaise),
    };
  }

  Party copyWith({
    String? id,
    String? shopId,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? kind,
    String? name,
    Value<String?> phone = const Value.absent(),
    Value<String?> gstin = const Value.absent(),
    Value<String?> address = const Value.absent(),
    Value<String?> stateCode = const Value.absent(),
    String? tier,
    int? creditLimitPaise,
  }) => Party(
    id: id ?? this.id,
    shopId: shopId ?? this.shopId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    kind: kind ?? this.kind,
    name: name ?? this.name,
    phone: phone.present ? phone.value : this.phone,
    gstin: gstin.present ? gstin.value : this.gstin,
    address: address.present ? address.value : this.address,
    stateCode: stateCode.present ? stateCode.value : this.stateCode,
    tier: tier ?? this.tier,
    creditLimitPaise: creditLimitPaise ?? this.creditLimitPaise,
  );
  Party copyWithCompanion(PartiesCompanion data) {
    return Party(
      id: data.id.present ? data.id.value : this.id,
      shopId: data.shopId.present ? data.shopId.value : this.shopId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      kind: data.kind.present ? data.kind.value : this.kind,
      name: data.name.present ? data.name.value : this.name,
      phone: data.phone.present ? data.phone.value : this.phone,
      gstin: data.gstin.present ? data.gstin.value : this.gstin,
      address: data.address.present ? data.address.value : this.address,
      stateCode: data.stateCode.present ? data.stateCode.value : this.stateCode,
      tier: data.tier.present ? data.tier.value : this.tier,
      creditLimitPaise:
          data.creditLimitPaise.present
              ? data.creditLimitPaise.value
              : this.creditLimitPaise,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Party(')
          ..write('id: $id, ')
          ..write('shopId: $shopId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('kind: $kind, ')
          ..write('name: $name, ')
          ..write('phone: $phone, ')
          ..write('gstin: $gstin, ')
          ..write('address: $address, ')
          ..write('stateCode: $stateCode, ')
          ..write('tier: $tier, ')
          ..write('creditLimitPaise: $creditLimitPaise')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    shopId,
    createdAt,
    updatedAt,
    deletedAt,
    kind,
    name,
    phone,
    gstin,
    address,
    stateCode,
    tier,
    creditLimitPaise,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Party &&
          other.id == this.id &&
          other.shopId == this.shopId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.kind == this.kind &&
          other.name == this.name &&
          other.phone == this.phone &&
          other.gstin == this.gstin &&
          other.address == this.address &&
          other.stateCode == this.stateCode &&
          other.tier == this.tier &&
          other.creditLimitPaise == this.creditLimitPaise);
}

class PartiesCompanion extends UpdateCompanion<Party> {
  final Value<String> id;
  final Value<String> shopId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> kind;
  final Value<String> name;
  final Value<String?> phone;
  final Value<String?> gstin;
  final Value<String?> address;
  final Value<String?> stateCode;
  final Value<String> tier;
  final Value<int> creditLimitPaise;
  final Value<int> rowid;
  const PartiesCompanion({
    this.id = const Value.absent(),
    this.shopId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.kind = const Value.absent(),
    this.name = const Value.absent(),
    this.phone = const Value.absent(),
    this.gstin = const Value.absent(),
    this.address = const Value.absent(),
    this.stateCode = const Value.absent(),
    this.tier = const Value.absent(),
    this.creditLimitPaise = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PartiesCompanion.insert({
    required String id,
    required String shopId,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    required String kind,
    required String name,
    this.phone = const Value.absent(),
    this.gstin = const Value.absent(),
    this.address = const Value.absent(),
    this.stateCode = const Value.absent(),
    this.tier = const Value.absent(),
    this.creditLimitPaise = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       shopId = Value(shopId),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       kind = Value(kind),
       name = Value(name);
  static Insertable<Party> custom({
    Expression<String>? id,
    Expression<String>? shopId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? kind,
    Expression<String>? name,
    Expression<String>? phone,
    Expression<String>? gstin,
    Expression<String>? address,
    Expression<String>? stateCode,
    Expression<String>? tier,
    Expression<int>? creditLimitPaise,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (shopId != null) 'shop_id': shopId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (kind != null) 'kind': kind,
      if (name != null) 'name': name,
      if (phone != null) 'phone': phone,
      if (gstin != null) 'gstin': gstin,
      if (address != null) 'address': address,
      if (stateCode != null) 'state_code': stateCode,
      if (tier != null) 'tier': tier,
      if (creditLimitPaise != null) 'credit_limit_paise': creditLimitPaise,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PartiesCompanion copyWith({
    Value<String>? id,
    Value<String>? shopId,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? kind,
    Value<String>? name,
    Value<String?>? phone,
    Value<String?>? gstin,
    Value<String?>? address,
    Value<String?>? stateCode,
    Value<String>? tier,
    Value<int>? creditLimitPaise,
    Value<int>? rowid,
  }) {
    return PartiesCompanion(
      id: id ?? this.id,
      shopId: shopId ?? this.shopId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      kind: kind ?? this.kind,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      gstin: gstin ?? this.gstin,
      address: address ?? this.address,
      stateCode: stateCode ?? this.stateCode,
      tier: tier ?? this.tier,
      creditLimitPaise: creditLimitPaise ?? this.creditLimitPaise,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (shopId.present) {
      map['shop_id'] = Variable<String>(shopId.value);
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
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (gstin.present) {
      map['gstin'] = Variable<String>(gstin.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (stateCode.present) {
      map['state_code'] = Variable<String>(stateCode.value);
    }
    if (tier.present) {
      map['tier'] = Variable<String>(tier.value);
    }
    if (creditLimitPaise.present) {
      map['credit_limit_paise'] = Variable<int>(creditLimitPaise.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PartiesCompanion(')
          ..write('id: $id, ')
          ..write('shopId: $shopId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('kind: $kind, ')
          ..write('name: $name, ')
          ..write('phone: $phone, ')
          ..write('gstin: $gstin, ')
          ..write('address: $address, ')
          ..write('stateCode: $stateCode, ')
          ..write('tier: $tier, ')
          ..write('creditLimitPaise: $creditLimitPaise, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LedgerEntriesTable extends LedgerEntries
    with TableInfo<$LedgerEntriesTable, LedgerEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LedgerEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _shopIdMeta = const VerificationMeta('shopId');
  @override
  late final GeneratedColumn<String> shopId = GeneratedColumn<String>(
    'shop_id',
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
  static const VerificationMeta _partyIdMeta = const VerificationMeta(
    'partyId',
  );
  @override
  late final GeneratedColumn<String> partyId = GeneratedColumn<String>(
    'party_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES parties (id)',
    ),
  );
  static const VerificationMeta _entryTypeMeta = const VerificationMeta(
    'entryType',
  );
  @override
  late final GeneratedColumn<String> entryType = GeneratedColumn<String>(
    'entry_type',
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
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _refTypeMeta = const VerificationMeta(
    'refType',
  );
  @override
  late final GeneratedColumn<String> refType = GeneratedColumn<String>(
    'ref_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _refIdMeta = const VerificationMeta('refId');
  @override
  late final GeneratedColumn<String> refId = GeneratedColumn<String>(
    'ref_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
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
  static const VerificationMeta _paymentModeMeta = const VerificationMeta(
    'paymentMode',
  );
  @override
  late final GeneratedColumn<String> paymentMode = GeneratedColumn<String>(
    'payment_mode',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tsMeta = const VerificationMeta('ts');
  @override
  late final GeneratedColumn<DateTime> ts = GeneratedColumn<DateTime>(
    'ts',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    shopId,
    createdAt,
    updatedAt,
    deletedAt,
    partyId,
    entryType,
    amountPaise,
    refType,
    refId,
    note,
    paymentMode,
    ts,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ledger_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<LedgerEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('shop_id')) {
      context.handle(
        _shopIdMeta,
        shopId.isAcceptableOrUnknown(data['shop_id']!, _shopIdMeta),
      );
    } else if (isInserting) {
      context.missing(_shopIdMeta);
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
    if (data.containsKey('party_id')) {
      context.handle(
        _partyIdMeta,
        partyId.isAcceptableOrUnknown(data['party_id']!, _partyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_partyIdMeta);
    }
    if (data.containsKey('entry_type')) {
      context.handle(
        _entryTypeMeta,
        entryType.isAcceptableOrUnknown(data['entry_type']!, _entryTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_entryTypeMeta);
    }
    if (data.containsKey('amount_paise')) {
      context.handle(
        _amountPaiseMeta,
        amountPaise.isAcceptableOrUnknown(
          data['amount_paise']!,
          _amountPaiseMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountPaiseMeta);
    }
    if (data.containsKey('ref_type')) {
      context.handle(
        _refTypeMeta,
        refType.isAcceptableOrUnknown(data['ref_type']!, _refTypeMeta),
      );
    }
    if (data.containsKey('ref_id')) {
      context.handle(
        _refIdMeta,
        refId.isAcceptableOrUnknown(data['ref_id']!, _refIdMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('payment_mode')) {
      context.handle(
        _paymentModeMeta,
        paymentMode.isAcceptableOrUnknown(
          data['payment_mode']!,
          _paymentModeMeta,
        ),
      );
    }
    if (data.containsKey('ts')) {
      context.handle(_tsMeta, ts.isAcceptableOrUnknown(data['ts']!, _tsMeta));
    } else if (isInserting) {
      context.missing(_tsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LedgerEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LedgerEntry(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}id'],
          )!,
      shopId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}shop_id'],
          )!,
      createdAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}created_at'],
          )!,
      updatedAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}updated_at'],
          )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      partyId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}party_id'],
          )!,
      entryType:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}entry_type'],
          )!,
      amountPaise:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}amount_paise'],
          )!,
      refType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ref_type'],
      ),
      refId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ref_id'],
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      paymentMode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payment_mode'],
      ),
      ts:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}ts'],
          )!,
    );
  }

  @override
  $LedgerEntriesTable createAlias(String alias) {
    return $LedgerEntriesTable(attachedDatabase, alias);
  }
}

class LedgerEntry extends DataClass implements Insertable<LedgerEntry> {
  final String id;
  final String shopId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String partyId;

  /// invoice | payment | return | opening | adjustment | purchase | supplier_payment
  final String entryType;

  /// Signed: receivable from customer positive, payment negative.
  final int amountPaise;
  final String? refType;
  final String? refId;
  final String? note;

  /// cash | upi | bank, for payments (added in schema v2). Null for other entries.
  final String? paymentMode;
  final DateTime ts;
  const LedgerEntry({
    required this.id,
    required this.shopId,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.partyId,
    required this.entryType,
    required this.amountPaise,
    this.refType,
    this.refId,
    this.note,
    this.paymentMode,
    required this.ts,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['shop_id'] = Variable<String>(shopId);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['party_id'] = Variable<String>(partyId);
    map['entry_type'] = Variable<String>(entryType);
    map['amount_paise'] = Variable<int>(amountPaise);
    if (!nullToAbsent || refType != null) {
      map['ref_type'] = Variable<String>(refType);
    }
    if (!nullToAbsent || refId != null) {
      map['ref_id'] = Variable<String>(refId);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    if (!nullToAbsent || paymentMode != null) {
      map['payment_mode'] = Variable<String>(paymentMode);
    }
    map['ts'] = Variable<DateTime>(ts);
    return map;
  }

  LedgerEntriesCompanion toCompanion(bool nullToAbsent) {
    return LedgerEntriesCompanion(
      id: Value(id),
      shopId: Value(shopId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt:
          deletedAt == null && nullToAbsent
              ? const Value.absent()
              : Value(deletedAt),
      partyId: Value(partyId),
      entryType: Value(entryType),
      amountPaise: Value(amountPaise),
      refType:
          refType == null && nullToAbsent
              ? const Value.absent()
              : Value(refType),
      refId:
          refId == null && nullToAbsent ? const Value.absent() : Value(refId),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      paymentMode:
          paymentMode == null && nullToAbsent
              ? const Value.absent()
              : Value(paymentMode),
      ts: Value(ts),
    );
  }

  factory LedgerEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LedgerEntry(
      id: serializer.fromJson<String>(json['id']),
      shopId: serializer.fromJson<String>(json['shopId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      partyId: serializer.fromJson<String>(json['partyId']),
      entryType: serializer.fromJson<String>(json['entryType']),
      amountPaise: serializer.fromJson<int>(json['amountPaise']),
      refType: serializer.fromJson<String?>(json['refType']),
      refId: serializer.fromJson<String?>(json['refId']),
      note: serializer.fromJson<String?>(json['note']),
      paymentMode: serializer.fromJson<String?>(json['paymentMode']),
      ts: serializer.fromJson<DateTime>(json['ts']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'shopId': serializer.toJson<String>(shopId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'partyId': serializer.toJson<String>(partyId),
      'entryType': serializer.toJson<String>(entryType),
      'amountPaise': serializer.toJson<int>(amountPaise),
      'refType': serializer.toJson<String?>(refType),
      'refId': serializer.toJson<String?>(refId),
      'note': serializer.toJson<String?>(note),
      'paymentMode': serializer.toJson<String?>(paymentMode),
      'ts': serializer.toJson<DateTime>(ts),
    };
  }

  LedgerEntry copyWith({
    String? id,
    String? shopId,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? partyId,
    String? entryType,
    int? amountPaise,
    Value<String?> refType = const Value.absent(),
    Value<String?> refId = const Value.absent(),
    Value<String?> note = const Value.absent(),
    Value<String?> paymentMode = const Value.absent(),
    DateTime? ts,
  }) => LedgerEntry(
    id: id ?? this.id,
    shopId: shopId ?? this.shopId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    partyId: partyId ?? this.partyId,
    entryType: entryType ?? this.entryType,
    amountPaise: amountPaise ?? this.amountPaise,
    refType: refType.present ? refType.value : this.refType,
    refId: refId.present ? refId.value : this.refId,
    note: note.present ? note.value : this.note,
    paymentMode: paymentMode.present ? paymentMode.value : this.paymentMode,
    ts: ts ?? this.ts,
  );
  LedgerEntry copyWithCompanion(LedgerEntriesCompanion data) {
    return LedgerEntry(
      id: data.id.present ? data.id.value : this.id,
      shopId: data.shopId.present ? data.shopId.value : this.shopId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      partyId: data.partyId.present ? data.partyId.value : this.partyId,
      entryType: data.entryType.present ? data.entryType.value : this.entryType,
      amountPaise:
          data.amountPaise.present ? data.amountPaise.value : this.amountPaise,
      refType: data.refType.present ? data.refType.value : this.refType,
      refId: data.refId.present ? data.refId.value : this.refId,
      note: data.note.present ? data.note.value : this.note,
      paymentMode:
          data.paymentMode.present ? data.paymentMode.value : this.paymentMode,
      ts: data.ts.present ? data.ts.value : this.ts,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LedgerEntry(')
          ..write('id: $id, ')
          ..write('shopId: $shopId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('partyId: $partyId, ')
          ..write('entryType: $entryType, ')
          ..write('amountPaise: $amountPaise, ')
          ..write('refType: $refType, ')
          ..write('refId: $refId, ')
          ..write('note: $note, ')
          ..write('paymentMode: $paymentMode, ')
          ..write('ts: $ts')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    shopId,
    createdAt,
    updatedAt,
    deletedAt,
    partyId,
    entryType,
    amountPaise,
    refType,
    refId,
    note,
    paymentMode,
    ts,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LedgerEntry &&
          other.id == this.id &&
          other.shopId == this.shopId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.partyId == this.partyId &&
          other.entryType == this.entryType &&
          other.amountPaise == this.amountPaise &&
          other.refType == this.refType &&
          other.refId == this.refId &&
          other.note == this.note &&
          other.paymentMode == this.paymentMode &&
          other.ts == this.ts);
}

class LedgerEntriesCompanion extends UpdateCompanion<LedgerEntry> {
  final Value<String> id;
  final Value<String> shopId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> partyId;
  final Value<String> entryType;
  final Value<int> amountPaise;
  final Value<String?> refType;
  final Value<String?> refId;
  final Value<String?> note;
  final Value<String?> paymentMode;
  final Value<DateTime> ts;
  final Value<int> rowid;
  const LedgerEntriesCompanion({
    this.id = const Value.absent(),
    this.shopId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.partyId = const Value.absent(),
    this.entryType = const Value.absent(),
    this.amountPaise = const Value.absent(),
    this.refType = const Value.absent(),
    this.refId = const Value.absent(),
    this.note = const Value.absent(),
    this.paymentMode = const Value.absent(),
    this.ts = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LedgerEntriesCompanion.insert({
    required String id,
    required String shopId,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    required String partyId,
    required String entryType,
    required int amountPaise,
    this.refType = const Value.absent(),
    this.refId = const Value.absent(),
    this.note = const Value.absent(),
    this.paymentMode = const Value.absent(),
    required DateTime ts,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       shopId = Value(shopId),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       partyId = Value(partyId),
       entryType = Value(entryType),
       amountPaise = Value(amountPaise),
       ts = Value(ts);
  static Insertable<LedgerEntry> custom({
    Expression<String>? id,
    Expression<String>? shopId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? partyId,
    Expression<String>? entryType,
    Expression<int>? amountPaise,
    Expression<String>? refType,
    Expression<String>? refId,
    Expression<String>? note,
    Expression<String>? paymentMode,
    Expression<DateTime>? ts,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (shopId != null) 'shop_id': shopId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (partyId != null) 'party_id': partyId,
      if (entryType != null) 'entry_type': entryType,
      if (amountPaise != null) 'amount_paise': amountPaise,
      if (refType != null) 'ref_type': refType,
      if (refId != null) 'ref_id': refId,
      if (note != null) 'note': note,
      if (paymentMode != null) 'payment_mode': paymentMode,
      if (ts != null) 'ts': ts,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LedgerEntriesCompanion copyWith({
    Value<String>? id,
    Value<String>? shopId,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? partyId,
    Value<String>? entryType,
    Value<int>? amountPaise,
    Value<String?>? refType,
    Value<String?>? refId,
    Value<String?>? note,
    Value<String?>? paymentMode,
    Value<DateTime>? ts,
    Value<int>? rowid,
  }) {
    return LedgerEntriesCompanion(
      id: id ?? this.id,
      shopId: shopId ?? this.shopId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      partyId: partyId ?? this.partyId,
      entryType: entryType ?? this.entryType,
      amountPaise: amountPaise ?? this.amountPaise,
      refType: refType ?? this.refType,
      refId: refId ?? this.refId,
      note: note ?? this.note,
      paymentMode: paymentMode ?? this.paymentMode,
      ts: ts ?? this.ts,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (shopId.present) {
      map['shop_id'] = Variable<String>(shopId.value);
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
    if (partyId.present) {
      map['party_id'] = Variable<String>(partyId.value);
    }
    if (entryType.present) {
      map['entry_type'] = Variable<String>(entryType.value);
    }
    if (amountPaise.present) {
      map['amount_paise'] = Variable<int>(amountPaise.value);
    }
    if (refType.present) {
      map['ref_type'] = Variable<String>(refType.value);
    }
    if (refId.present) {
      map['ref_id'] = Variable<String>(refId.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (paymentMode.present) {
      map['payment_mode'] = Variable<String>(paymentMode.value);
    }
    if (ts.present) {
      map['ts'] = Variable<DateTime>(ts.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LedgerEntriesCompanion(')
          ..write('id: $id, ')
          ..write('shopId: $shopId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('partyId: $partyId, ')
          ..write('entryType: $entryType, ')
          ..write('amountPaise: $amountPaise, ')
          ..write('refType: $refType, ')
          ..write('refId: $refId, ')
          ..write('note: $note, ')
          ..write('paymentMode: $paymentMode, ')
          ..write('ts: $ts, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $InvoicesTable extends Invoices with TableInfo<$InvoicesTable, Invoice> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InvoicesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _shopIdMeta = const VerificationMeta('shopId');
  @override
  late final GeneratedColumn<String> shopId = GeneratedColumn<String>(
    'shop_id',
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
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES devices (id)',
    ),
  );
  static const VerificationMeta _seriesMeta = const VerificationMeta('series');
  @override
  late final GeneratedColumn<String> series = GeneratedColumn<String>(
    'series',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _numberMeta = const VerificationMeta('number');
  @override
  late final GeneratedColumn<int> number = GeneratedColumn<int>(
    'number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _invoiceNoTextMeta = const VerificationMeta(
    'invoiceNoText',
  );
  @override
  late final GeneratedColumn<String> invoiceNoText = GeneratedColumn<String>(
    'invoice_no_text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _partyIdMeta = const VerificationMeta(
    'partyId',
  );
  @override
  late final GeneratedColumn<String> partyId = GeneratedColumn<String>(
    'party_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES parties (id)',
    ),
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
  static const VerificationMeta _subtotalPaiseMeta = const VerificationMeta(
    'subtotalPaise',
  );
  @override
  late final GeneratedColumn<int> subtotalPaise = GeneratedColumn<int>(
    'subtotal_paise',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _discountPaiseMeta = const VerificationMeta(
    'discountPaise',
  );
  @override
  late final GeneratedColumn<int> discountPaise = GeneratedColumn<int>(
    'discount_paise',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _taxPaiseMeta = const VerificationMeta(
    'taxPaise',
  );
  @override
  late final GeneratedColumn<int> taxPaise = GeneratedColumn<int>(
    'tax_paise',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _roundOffPaiseMeta = const VerificationMeta(
    'roundOffPaise',
  );
  @override
  late final GeneratedColumn<int> roundOffPaise = GeneratedColumn<int>(
    'round_off_paise',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _totalPaiseMeta = const VerificationMeta(
    'totalPaise',
  );
  @override
  late final GeneratedColumn<int> totalPaise = GeneratedColumn<int>(
    'total_paise',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _paidPaiseMeta = const VerificationMeta(
    'paidPaise',
  );
  @override
  late final GeneratedColumn<int> paidPaise = GeneratedColumn<int>(
    'paid_paise',
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
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('posted'),
  );
  static const VerificationMeta _shopSnapshotJsonMeta = const VerificationMeta(
    'shopSnapshotJson',
  );
  @override
  late final GeneratedColumn<String> shopSnapshotJson = GeneratedColumn<String>(
    'shop_snapshot_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdByMeta = const VerificationMeta(
    'createdBy',
  );
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
    'created_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    shopId,
    createdAt,
    updatedAt,
    deletedAt,
    deviceId,
    series,
    number,
    invoiceNoText,
    partyId,
    date,
    subtotalPaise,
    discountPaise,
    taxPaise,
    roundOffPaise,
    totalPaise,
    paidPaise,
    status,
    shopSnapshotJson,
    createdBy,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'invoices';
  @override
  VerificationContext validateIntegrity(
    Insertable<Invoice> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('shop_id')) {
      context.handle(
        _shopIdMeta,
        shopId.isAcceptableOrUnknown(data['shop_id']!, _shopIdMeta),
      );
    } else if (isInserting) {
      context.missing(_shopIdMeta);
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
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('series')) {
      context.handle(
        _seriesMeta,
        series.isAcceptableOrUnknown(data['series']!, _seriesMeta),
      );
    } else if (isInserting) {
      context.missing(_seriesMeta);
    }
    if (data.containsKey('number')) {
      context.handle(
        _numberMeta,
        number.isAcceptableOrUnknown(data['number']!, _numberMeta),
      );
    } else if (isInserting) {
      context.missing(_numberMeta);
    }
    if (data.containsKey('invoice_no_text')) {
      context.handle(
        _invoiceNoTextMeta,
        invoiceNoText.isAcceptableOrUnknown(
          data['invoice_no_text']!,
          _invoiceNoTextMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_invoiceNoTextMeta);
    }
    if (data.containsKey('party_id')) {
      context.handle(
        _partyIdMeta,
        partyId.isAcceptableOrUnknown(data['party_id']!, _partyIdMeta),
      );
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('subtotal_paise')) {
      context.handle(
        _subtotalPaiseMeta,
        subtotalPaise.isAcceptableOrUnknown(
          data['subtotal_paise']!,
          _subtotalPaiseMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_subtotalPaiseMeta);
    }
    if (data.containsKey('discount_paise')) {
      context.handle(
        _discountPaiseMeta,
        discountPaise.isAcceptableOrUnknown(
          data['discount_paise']!,
          _discountPaiseMeta,
        ),
      );
    }
    if (data.containsKey('tax_paise')) {
      context.handle(
        _taxPaiseMeta,
        taxPaise.isAcceptableOrUnknown(data['tax_paise']!, _taxPaiseMeta),
      );
    } else if (isInserting) {
      context.missing(_taxPaiseMeta);
    }
    if (data.containsKey('round_off_paise')) {
      context.handle(
        _roundOffPaiseMeta,
        roundOffPaise.isAcceptableOrUnknown(
          data['round_off_paise']!,
          _roundOffPaiseMeta,
        ),
      );
    }
    if (data.containsKey('total_paise')) {
      context.handle(
        _totalPaiseMeta,
        totalPaise.isAcceptableOrUnknown(data['total_paise']!, _totalPaiseMeta),
      );
    } else if (isInserting) {
      context.missing(_totalPaiseMeta);
    }
    if (data.containsKey('paid_paise')) {
      context.handle(
        _paidPaiseMeta,
        paidPaise.isAcceptableOrUnknown(data['paid_paise']!, _paidPaiseMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('shop_snapshot_json')) {
      context.handle(
        _shopSnapshotJsonMeta,
        shopSnapshotJson.isAcceptableOrUnknown(
          data['shop_snapshot_json']!,
          _shopSnapshotJsonMeta,
        ),
      );
    }
    if (data.containsKey('created_by')) {
      context.handle(
        _createdByMeta,
        createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {deviceId, series, number},
  ];
  @override
  Invoice map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Invoice(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}id'],
          )!,
      shopId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}shop_id'],
          )!,
      createdAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}created_at'],
          )!,
      updatedAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}updated_at'],
          )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      deviceId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}device_id'],
          )!,
      series:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}series'],
          )!,
      number:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}number'],
          )!,
      invoiceNoText:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}invoice_no_text'],
          )!,
      partyId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}party_id'],
      ),
      date:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}date'],
          )!,
      subtotalPaise:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}subtotal_paise'],
          )!,
      discountPaise:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}discount_paise'],
          )!,
      taxPaise:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}tax_paise'],
          )!,
      roundOffPaise:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}round_off_paise'],
          )!,
      totalPaise:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}total_paise'],
          )!,
      paidPaise:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}paid_paise'],
          )!,
      status:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}status'],
          )!,
      shopSnapshotJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}shop_snapshot_json'],
      ),
      createdBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_by'],
      ),
    );
  }

  @override
  $InvoicesTable createAlias(String alias) {
    return $InvoicesTable(attachedDatabase, alias);
  }
}

class Invoice extends DataClass implements Insertable<Invoice> {
  final String id;
  final String shopId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String deviceId;
  final String series;
  final int number;
  final String invoiceNoText;
  final String? partyId;
  final DateTime date;
  final int subtotalPaise;
  final int discountPaise;
  final int taxPaise;
  final int roundOffPaise;
  final int totalPaise;
  final int paidPaise;

  /// posted | cancelled
  final String status;
  final String? shopSnapshotJson;
  final String? createdBy;
  const Invoice({
    required this.id,
    required this.shopId,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.deviceId,
    required this.series,
    required this.number,
    required this.invoiceNoText,
    this.partyId,
    required this.date,
    required this.subtotalPaise,
    required this.discountPaise,
    required this.taxPaise,
    required this.roundOffPaise,
    required this.totalPaise,
    required this.paidPaise,
    required this.status,
    this.shopSnapshotJson,
    this.createdBy,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['shop_id'] = Variable<String>(shopId);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['device_id'] = Variable<String>(deviceId);
    map['series'] = Variable<String>(series);
    map['number'] = Variable<int>(number);
    map['invoice_no_text'] = Variable<String>(invoiceNoText);
    if (!nullToAbsent || partyId != null) {
      map['party_id'] = Variable<String>(partyId);
    }
    map['date'] = Variable<DateTime>(date);
    map['subtotal_paise'] = Variable<int>(subtotalPaise);
    map['discount_paise'] = Variable<int>(discountPaise);
    map['tax_paise'] = Variable<int>(taxPaise);
    map['round_off_paise'] = Variable<int>(roundOffPaise);
    map['total_paise'] = Variable<int>(totalPaise);
    map['paid_paise'] = Variable<int>(paidPaise);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || shopSnapshotJson != null) {
      map['shop_snapshot_json'] = Variable<String>(shopSnapshotJson);
    }
    if (!nullToAbsent || createdBy != null) {
      map['created_by'] = Variable<String>(createdBy);
    }
    return map;
  }

  InvoicesCompanion toCompanion(bool nullToAbsent) {
    return InvoicesCompanion(
      id: Value(id),
      shopId: Value(shopId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt:
          deletedAt == null && nullToAbsent
              ? const Value.absent()
              : Value(deletedAt),
      deviceId: Value(deviceId),
      series: Value(series),
      number: Value(number),
      invoiceNoText: Value(invoiceNoText),
      partyId:
          partyId == null && nullToAbsent
              ? const Value.absent()
              : Value(partyId),
      date: Value(date),
      subtotalPaise: Value(subtotalPaise),
      discountPaise: Value(discountPaise),
      taxPaise: Value(taxPaise),
      roundOffPaise: Value(roundOffPaise),
      totalPaise: Value(totalPaise),
      paidPaise: Value(paidPaise),
      status: Value(status),
      shopSnapshotJson:
          shopSnapshotJson == null && nullToAbsent
              ? const Value.absent()
              : Value(shopSnapshotJson),
      createdBy:
          createdBy == null && nullToAbsent
              ? const Value.absent()
              : Value(createdBy),
    );
  }

  factory Invoice.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Invoice(
      id: serializer.fromJson<String>(json['id']),
      shopId: serializer.fromJson<String>(json['shopId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      series: serializer.fromJson<String>(json['series']),
      number: serializer.fromJson<int>(json['number']),
      invoiceNoText: serializer.fromJson<String>(json['invoiceNoText']),
      partyId: serializer.fromJson<String?>(json['partyId']),
      date: serializer.fromJson<DateTime>(json['date']),
      subtotalPaise: serializer.fromJson<int>(json['subtotalPaise']),
      discountPaise: serializer.fromJson<int>(json['discountPaise']),
      taxPaise: serializer.fromJson<int>(json['taxPaise']),
      roundOffPaise: serializer.fromJson<int>(json['roundOffPaise']),
      totalPaise: serializer.fromJson<int>(json['totalPaise']),
      paidPaise: serializer.fromJson<int>(json['paidPaise']),
      status: serializer.fromJson<String>(json['status']),
      shopSnapshotJson: serializer.fromJson<String?>(json['shopSnapshotJson']),
      createdBy: serializer.fromJson<String?>(json['createdBy']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'shopId': serializer.toJson<String>(shopId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'deviceId': serializer.toJson<String>(deviceId),
      'series': serializer.toJson<String>(series),
      'number': serializer.toJson<int>(number),
      'invoiceNoText': serializer.toJson<String>(invoiceNoText),
      'partyId': serializer.toJson<String?>(partyId),
      'date': serializer.toJson<DateTime>(date),
      'subtotalPaise': serializer.toJson<int>(subtotalPaise),
      'discountPaise': serializer.toJson<int>(discountPaise),
      'taxPaise': serializer.toJson<int>(taxPaise),
      'roundOffPaise': serializer.toJson<int>(roundOffPaise),
      'totalPaise': serializer.toJson<int>(totalPaise),
      'paidPaise': serializer.toJson<int>(paidPaise),
      'status': serializer.toJson<String>(status),
      'shopSnapshotJson': serializer.toJson<String?>(shopSnapshotJson),
      'createdBy': serializer.toJson<String?>(createdBy),
    };
  }

  Invoice copyWith({
    String? id,
    String? shopId,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? deviceId,
    String? series,
    int? number,
    String? invoiceNoText,
    Value<String?> partyId = const Value.absent(),
    DateTime? date,
    int? subtotalPaise,
    int? discountPaise,
    int? taxPaise,
    int? roundOffPaise,
    int? totalPaise,
    int? paidPaise,
    String? status,
    Value<String?> shopSnapshotJson = const Value.absent(),
    Value<String?> createdBy = const Value.absent(),
  }) => Invoice(
    id: id ?? this.id,
    shopId: shopId ?? this.shopId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    deviceId: deviceId ?? this.deviceId,
    series: series ?? this.series,
    number: number ?? this.number,
    invoiceNoText: invoiceNoText ?? this.invoiceNoText,
    partyId: partyId.present ? partyId.value : this.partyId,
    date: date ?? this.date,
    subtotalPaise: subtotalPaise ?? this.subtotalPaise,
    discountPaise: discountPaise ?? this.discountPaise,
    taxPaise: taxPaise ?? this.taxPaise,
    roundOffPaise: roundOffPaise ?? this.roundOffPaise,
    totalPaise: totalPaise ?? this.totalPaise,
    paidPaise: paidPaise ?? this.paidPaise,
    status: status ?? this.status,
    shopSnapshotJson:
        shopSnapshotJson.present
            ? shopSnapshotJson.value
            : this.shopSnapshotJson,
    createdBy: createdBy.present ? createdBy.value : this.createdBy,
  );
  Invoice copyWithCompanion(InvoicesCompanion data) {
    return Invoice(
      id: data.id.present ? data.id.value : this.id,
      shopId: data.shopId.present ? data.shopId.value : this.shopId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      series: data.series.present ? data.series.value : this.series,
      number: data.number.present ? data.number.value : this.number,
      invoiceNoText:
          data.invoiceNoText.present
              ? data.invoiceNoText.value
              : this.invoiceNoText,
      partyId: data.partyId.present ? data.partyId.value : this.partyId,
      date: data.date.present ? data.date.value : this.date,
      subtotalPaise:
          data.subtotalPaise.present
              ? data.subtotalPaise.value
              : this.subtotalPaise,
      discountPaise:
          data.discountPaise.present
              ? data.discountPaise.value
              : this.discountPaise,
      taxPaise: data.taxPaise.present ? data.taxPaise.value : this.taxPaise,
      roundOffPaise:
          data.roundOffPaise.present
              ? data.roundOffPaise.value
              : this.roundOffPaise,
      totalPaise:
          data.totalPaise.present ? data.totalPaise.value : this.totalPaise,
      paidPaise: data.paidPaise.present ? data.paidPaise.value : this.paidPaise,
      status: data.status.present ? data.status.value : this.status,
      shopSnapshotJson:
          data.shopSnapshotJson.present
              ? data.shopSnapshotJson.value
              : this.shopSnapshotJson,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Invoice(')
          ..write('id: $id, ')
          ..write('shopId: $shopId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('deviceId: $deviceId, ')
          ..write('series: $series, ')
          ..write('number: $number, ')
          ..write('invoiceNoText: $invoiceNoText, ')
          ..write('partyId: $partyId, ')
          ..write('date: $date, ')
          ..write('subtotalPaise: $subtotalPaise, ')
          ..write('discountPaise: $discountPaise, ')
          ..write('taxPaise: $taxPaise, ')
          ..write('roundOffPaise: $roundOffPaise, ')
          ..write('totalPaise: $totalPaise, ')
          ..write('paidPaise: $paidPaise, ')
          ..write('status: $status, ')
          ..write('shopSnapshotJson: $shopSnapshotJson, ')
          ..write('createdBy: $createdBy')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    shopId,
    createdAt,
    updatedAt,
    deletedAt,
    deviceId,
    series,
    number,
    invoiceNoText,
    partyId,
    date,
    subtotalPaise,
    discountPaise,
    taxPaise,
    roundOffPaise,
    totalPaise,
    paidPaise,
    status,
    shopSnapshotJson,
    createdBy,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Invoice &&
          other.id == this.id &&
          other.shopId == this.shopId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.deviceId == this.deviceId &&
          other.series == this.series &&
          other.number == this.number &&
          other.invoiceNoText == this.invoiceNoText &&
          other.partyId == this.partyId &&
          other.date == this.date &&
          other.subtotalPaise == this.subtotalPaise &&
          other.discountPaise == this.discountPaise &&
          other.taxPaise == this.taxPaise &&
          other.roundOffPaise == this.roundOffPaise &&
          other.totalPaise == this.totalPaise &&
          other.paidPaise == this.paidPaise &&
          other.status == this.status &&
          other.shopSnapshotJson == this.shopSnapshotJson &&
          other.createdBy == this.createdBy);
}

class InvoicesCompanion extends UpdateCompanion<Invoice> {
  final Value<String> id;
  final Value<String> shopId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> deviceId;
  final Value<String> series;
  final Value<int> number;
  final Value<String> invoiceNoText;
  final Value<String?> partyId;
  final Value<DateTime> date;
  final Value<int> subtotalPaise;
  final Value<int> discountPaise;
  final Value<int> taxPaise;
  final Value<int> roundOffPaise;
  final Value<int> totalPaise;
  final Value<int> paidPaise;
  final Value<String> status;
  final Value<String?> shopSnapshotJson;
  final Value<String?> createdBy;
  final Value<int> rowid;
  const InvoicesCompanion({
    this.id = const Value.absent(),
    this.shopId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.series = const Value.absent(),
    this.number = const Value.absent(),
    this.invoiceNoText = const Value.absent(),
    this.partyId = const Value.absent(),
    this.date = const Value.absent(),
    this.subtotalPaise = const Value.absent(),
    this.discountPaise = const Value.absent(),
    this.taxPaise = const Value.absent(),
    this.roundOffPaise = const Value.absent(),
    this.totalPaise = const Value.absent(),
    this.paidPaise = const Value.absent(),
    this.status = const Value.absent(),
    this.shopSnapshotJson = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  InvoicesCompanion.insert({
    required String id,
    required String shopId,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    required String deviceId,
    required String series,
    required int number,
    required String invoiceNoText,
    this.partyId = const Value.absent(),
    required DateTime date,
    required int subtotalPaise,
    this.discountPaise = const Value.absent(),
    required int taxPaise,
    this.roundOffPaise = const Value.absent(),
    required int totalPaise,
    this.paidPaise = const Value.absent(),
    this.status = const Value.absent(),
    this.shopSnapshotJson = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       shopId = Value(shopId),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       deviceId = Value(deviceId),
       series = Value(series),
       number = Value(number),
       invoiceNoText = Value(invoiceNoText),
       date = Value(date),
       subtotalPaise = Value(subtotalPaise),
       taxPaise = Value(taxPaise),
       totalPaise = Value(totalPaise);
  static Insertable<Invoice> custom({
    Expression<String>? id,
    Expression<String>? shopId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? deviceId,
    Expression<String>? series,
    Expression<int>? number,
    Expression<String>? invoiceNoText,
    Expression<String>? partyId,
    Expression<DateTime>? date,
    Expression<int>? subtotalPaise,
    Expression<int>? discountPaise,
    Expression<int>? taxPaise,
    Expression<int>? roundOffPaise,
    Expression<int>? totalPaise,
    Expression<int>? paidPaise,
    Expression<String>? status,
    Expression<String>? shopSnapshotJson,
    Expression<String>? createdBy,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (shopId != null) 'shop_id': shopId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (deviceId != null) 'device_id': deviceId,
      if (series != null) 'series': series,
      if (number != null) 'number': number,
      if (invoiceNoText != null) 'invoice_no_text': invoiceNoText,
      if (partyId != null) 'party_id': partyId,
      if (date != null) 'date': date,
      if (subtotalPaise != null) 'subtotal_paise': subtotalPaise,
      if (discountPaise != null) 'discount_paise': discountPaise,
      if (taxPaise != null) 'tax_paise': taxPaise,
      if (roundOffPaise != null) 'round_off_paise': roundOffPaise,
      if (totalPaise != null) 'total_paise': totalPaise,
      if (paidPaise != null) 'paid_paise': paidPaise,
      if (status != null) 'status': status,
      if (shopSnapshotJson != null) 'shop_snapshot_json': shopSnapshotJson,
      if (createdBy != null) 'created_by': createdBy,
      if (rowid != null) 'rowid': rowid,
    });
  }

  InvoicesCompanion copyWith({
    Value<String>? id,
    Value<String>? shopId,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? deviceId,
    Value<String>? series,
    Value<int>? number,
    Value<String>? invoiceNoText,
    Value<String?>? partyId,
    Value<DateTime>? date,
    Value<int>? subtotalPaise,
    Value<int>? discountPaise,
    Value<int>? taxPaise,
    Value<int>? roundOffPaise,
    Value<int>? totalPaise,
    Value<int>? paidPaise,
    Value<String>? status,
    Value<String?>? shopSnapshotJson,
    Value<String?>? createdBy,
    Value<int>? rowid,
  }) {
    return InvoicesCompanion(
      id: id ?? this.id,
      shopId: shopId ?? this.shopId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      deviceId: deviceId ?? this.deviceId,
      series: series ?? this.series,
      number: number ?? this.number,
      invoiceNoText: invoiceNoText ?? this.invoiceNoText,
      partyId: partyId ?? this.partyId,
      date: date ?? this.date,
      subtotalPaise: subtotalPaise ?? this.subtotalPaise,
      discountPaise: discountPaise ?? this.discountPaise,
      taxPaise: taxPaise ?? this.taxPaise,
      roundOffPaise: roundOffPaise ?? this.roundOffPaise,
      totalPaise: totalPaise ?? this.totalPaise,
      paidPaise: paidPaise ?? this.paidPaise,
      status: status ?? this.status,
      shopSnapshotJson: shopSnapshotJson ?? this.shopSnapshotJson,
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
    if (shopId.present) {
      map['shop_id'] = Variable<String>(shopId.value);
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
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (series.present) {
      map['series'] = Variable<String>(series.value);
    }
    if (number.present) {
      map['number'] = Variable<int>(number.value);
    }
    if (invoiceNoText.present) {
      map['invoice_no_text'] = Variable<String>(invoiceNoText.value);
    }
    if (partyId.present) {
      map['party_id'] = Variable<String>(partyId.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (subtotalPaise.present) {
      map['subtotal_paise'] = Variable<int>(subtotalPaise.value);
    }
    if (discountPaise.present) {
      map['discount_paise'] = Variable<int>(discountPaise.value);
    }
    if (taxPaise.present) {
      map['tax_paise'] = Variable<int>(taxPaise.value);
    }
    if (roundOffPaise.present) {
      map['round_off_paise'] = Variable<int>(roundOffPaise.value);
    }
    if (totalPaise.present) {
      map['total_paise'] = Variable<int>(totalPaise.value);
    }
    if (paidPaise.present) {
      map['paid_paise'] = Variable<int>(paidPaise.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (shopSnapshotJson.present) {
      map['shop_snapshot_json'] = Variable<String>(shopSnapshotJson.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InvoicesCompanion(')
          ..write('id: $id, ')
          ..write('shopId: $shopId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('deviceId: $deviceId, ')
          ..write('series: $series, ')
          ..write('number: $number, ')
          ..write('invoiceNoText: $invoiceNoText, ')
          ..write('partyId: $partyId, ')
          ..write('date: $date, ')
          ..write('subtotalPaise: $subtotalPaise, ')
          ..write('discountPaise: $discountPaise, ')
          ..write('taxPaise: $taxPaise, ')
          ..write('roundOffPaise: $roundOffPaise, ')
          ..write('totalPaise: $totalPaise, ')
          ..write('paidPaise: $paidPaise, ')
          ..write('status: $status, ')
          ..write('shopSnapshotJson: $shopSnapshotJson, ')
          ..write('createdBy: $createdBy, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $InvoiceLinesTable extends InvoiceLines
    with TableInfo<$InvoiceLinesTable, InvoiceLine> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InvoiceLinesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _shopIdMeta = const VerificationMeta('shopId');
  @override
  late final GeneratedColumn<String> shopId = GeneratedColumn<String>(
    'shop_id',
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
  static const VerificationMeta _invoiceIdMeta = const VerificationMeta(
    'invoiceId',
  );
  @override
  late final GeneratedColumn<String> invoiceId = GeneratedColumn<String>(
    'invoice_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES invoices (id)',
    ),
  );
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<String> itemId = GeneratedColumn<String>(
    'item_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES items (id)',
    ),
  );
  static const VerificationMeta _variantIdMeta = const VerificationMeta(
    'variantId',
  );
  @override
  late final GeneratedColumn<String> variantId = GeneratedColumn<String>(
    'variant_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES item_variants (id)',
    ),
  );
  static const VerificationMeta _unitNameMeta = const VerificationMeta(
    'unitName',
  );
  @override
  late final GeneratedColumn<String> unitName = GeneratedColumn<String>(
    'unit_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _qtyEnteredMeta = const VerificationMeta(
    'qtyEntered',
  );
  @override
  late final GeneratedColumn<String> qtyEntered = GeneratedColumn<String>(
    'qty_entered',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _qtyBaseMeta = const VerificationMeta(
    'qtyBase',
  );
  @override
  late final GeneratedColumn<int> qtyBase = GeneratedColumn<int>(
    'qty_base',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ratePaiseMeta = const VerificationMeta(
    'ratePaise',
  );
  @override
  late final GeneratedColumn<int> ratePaise = GeneratedColumn<int>(
    'rate_paise',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _priceUnitFactorMeta = const VerificationMeta(
    'priceUnitFactor',
  );
  @override
  late final GeneratedColumn<int> priceUnitFactor = GeneratedColumn<int>(
    'price_unit_factor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _discountPaiseMeta = const VerificationMeta(
    'discountPaise',
  );
  @override
  late final GeneratedColumn<int> discountPaise = GeneratedColumn<int>(
    'discount_paise',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _gstRateBpMeta = const VerificationMeta(
    'gstRateBp',
  );
  @override
  late final GeneratedColumn<int> gstRateBp = GeneratedColumn<int>(
    'gst_rate_bp',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _taxPaiseMeta = const VerificationMeta(
    'taxPaise',
  );
  @override
  late final GeneratedColumn<int> taxPaise = GeneratedColumn<int>(
    'tax_paise',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lineTotalPaiseMeta = const VerificationMeta(
    'lineTotalPaise',
  );
  @override
  late final GeneratedColumn<int> lineTotalPaise = GeneratedColumn<int>(
    'line_total_paise',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _coilIdMeta = const VerificationMeta('coilId');
  @override
  late final GeneratedColumn<String> coilId = GeneratedColumn<String>(
    'coil_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _serialMeta = const VerificationMeta('serial');
  @override
  late final GeneratedColumn<String> serial = GeneratedColumn<String>(
    'serial',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    shopId,
    createdAt,
    updatedAt,
    deletedAt,
    invoiceId,
    itemId,
    variantId,
    unitName,
    qtyEntered,
    qtyBase,
    ratePaise,
    priceUnitFactor,
    discountPaise,
    gstRateBp,
    taxPaise,
    lineTotalPaise,
    coilId,
    serial,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'invoice_lines';
  @override
  VerificationContext validateIntegrity(
    Insertable<InvoiceLine> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('shop_id')) {
      context.handle(
        _shopIdMeta,
        shopId.isAcceptableOrUnknown(data['shop_id']!, _shopIdMeta),
      );
    } else if (isInserting) {
      context.missing(_shopIdMeta);
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
    if (data.containsKey('invoice_id')) {
      context.handle(
        _invoiceIdMeta,
        invoiceId.isAcceptableOrUnknown(data['invoice_id']!, _invoiceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_invoiceIdMeta);
    }
    if (data.containsKey('item_id')) {
      context.handle(
        _itemIdMeta,
        itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta),
      );
    } else if (isInserting) {
      context.missing(_itemIdMeta);
    }
    if (data.containsKey('variant_id')) {
      context.handle(
        _variantIdMeta,
        variantId.isAcceptableOrUnknown(data['variant_id']!, _variantIdMeta),
      );
    }
    if (data.containsKey('unit_name')) {
      context.handle(
        _unitNameMeta,
        unitName.isAcceptableOrUnknown(data['unit_name']!, _unitNameMeta),
      );
    } else if (isInserting) {
      context.missing(_unitNameMeta);
    }
    if (data.containsKey('qty_entered')) {
      context.handle(
        _qtyEnteredMeta,
        qtyEntered.isAcceptableOrUnknown(data['qty_entered']!, _qtyEnteredMeta),
      );
    } else if (isInserting) {
      context.missing(_qtyEnteredMeta);
    }
    if (data.containsKey('qty_base')) {
      context.handle(
        _qtyBaseMeta,
        qtyBase.isAcceptableOrUnknown(data['qty_base']!, _qtyBaseMeta),
      );
    } else if (isInserting) {
      context.missing(_qtyBaseMeta);
    }
    if (data.containsKey('rate_paise')) {
      context.handle(
        _ratePaiseMeta,
        ratePaise.isAcceptableOrUnknown(data['rate_paise']!, _ratePaiseMeta),
      );
    } else if (isInserting) {
      context.missing(_ratePaiseMeta);
    }
    if (data.containsKey('price_unit_factor')) {
      context.handle(
        _priceUnitFactorMeta,
        priceUnitFactor.isAcceptableOrUnknown(
          data['price_unit_factor']!,
          _priceUnitFactorMeta,
        ),
      );
    }
    if (data.containsKey('discount_paise')) {
      context.handle(
        _discountPaiseMeta,
        discountPaise.isAcceptableOrUnknown(
          data['discount_paise']!,
          _discountPaiseMeta,
        ),
      );
    }
    if (data.containsKey('gst_rate_bp')) {
      context.handle(
        _gstRateBpMeta,
        gstRateBp.isAcceptableOrUnknown(data['gst_rate_bp']!, _gstRateBpMeta),
      );
    }
    if (data.containsKey('tax_paise')) {
      context.handle(
        _taxPaiseMeta,
        taxPaise.isAcceptableOrUnknown(data['tax_paise']!, _taxPaiseMeta),
      );
    } else if (isInserting) {
      context.missing(_taxPaiseMeta);
    }
    if (data.containsKey('line_total_paise')) {
      context.handle(
        _lineTotalPaiseMeta,
        lineTotalPaise.isAcceptableOrUnknown(
          data['line_total_paise']!,
          _lineTotalPaiseMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lineTotalPaiseMeta);
    }
    if (data.containsKey('coil_id')) {
      context.handle(
        _coilIdMeta,
        coilId.isAcceptableOrUnknown(data['coil_id']!, _coilIdMeta),
      );
    }
    if (data.containsKey('serial')) {
      context.handle(
        _serialMeta,
        serial.isAcceptableOrUnknown(data['serial']!, _serialMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  InvoiceLine map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return InvoiceLine(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}id'],
          )!,
      shopId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}shop_id'],
          )!,
      createdAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}created_at'],
          )!,
      updatedAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}updated_at'],
          )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      invoiceId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}invoice_id'],
          )!,
      itemId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}item_id'],
          )!,
      variantId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}variant_id'],
      ),
      unitName:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}unit_name'],
          )!,
      qtyEntered:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}qty_entered'],
          )!,
      qtyBase:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}qty_base'],
          )!,
      ratePaise:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}rate_paise'],
          )!,
      priceUnitFactor:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}price_unit_factor'],
          )!,
      discountPaise:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}discount_paise'],
          )!,
      gstRateBp:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}gst_rate_bp'],
          )!,
      taxPaise:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}tax_paise'],
          )!,
      lineTotalPaise:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}line_total_paise'],
          )!,
      coilId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}coil_id'],
      ),
      serial: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}serial'],
      ),
    );
  }

  @override
  $InvoiceLinesTable createAlias(String alias) {
    return $InvoiceLinesTable(attachedDatabase, alias);
  }
}

class InvoiceLine extends DataClass implements Insertable<InvoiceLine> {
  final String id;
  final String shopId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String invoiceId;
  final String itemId;
  final String? variantId;
  final String unitName;

  /// Quantity exactly as staff entered it, as decimal text (e.g. "2.5").
  final String qtyEntered;
  final int qtyBase;

  /// Paise per pricing unit.
  final int ratePaise;
  final int priceUnitFactor;
  final int discountPaise;
  final int gstRateBp;
  final int taxPaise;
  final int lineTotalPaise;
  final String? coilId;
  final String? serial;
  const InvoiceLine({
    required this.id,
    required this.shopId,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.invoiceId,
    required this.itemId,
    this.variantId,
    required this.unitName,
    required this.qtyEntered,
    required this.qtyBase,
    required this.ratePaise,
    required this.priceUnitFactor,
    required this.discountPaise,
    required this.gstRateBp,
    required this.taxPaise,
    required this.lineTotalPaise,
    this.coilId,
    this.serial,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['shop_id'] = Variable<String>(shopId);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['invoice_id'] = Variable<String>(invoiceId);
    map['item_id'] = Variable<String>(itemId);
    if (!nullToAbsent || variantId != null) {
      map['variant_id'] = Variable<String>(variantId);
    }
    map['unit_name'] = Variable<String>(unitName);
    map['qty_entered'] = Variable<String>(qtyEntered);
    map['qty_base'] = Variable<int>(qtyBase);
    map['rate_paise'] = Variable<int>(ratePaise);
    map['price_unit_factor'] = Variable<int>(priceUnitFactor);
    map['discount_paise'] = Variable<int>(discountPaise);
    map['gst_rate_bp'] = Variable<int>(gstRateBp);
    map['tax_paise'] = Variable<int>(taxPaise);
    map['line_total_paise'] = Variable<int>(lineTotalPaise);
    if (!nullToAbsent || coilId != null) {
      map['coil_id'] = Variable<String>(coilId);
    }
    if (!nullToAbsent || serial != null) {
      map['serial'] = Variable<String>(serial);
    }
    return map;
  }

  InvoiceLinesCompanion toCompanion(bool nullToAbsent) {
    return InvoiceLinesCompanion(
      id: Value(id),
      shopId: Value(shopId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt:
          deletedAt == null && nullToAbsent
              ? const Value.absent()
              : Value(deletedAt),
      invoiceId: Value(invoiceId),
      itemId: Value(itemId),
      variantId:
          variantId == null && nullToAbsent
              ? const Value.absent()
              : Value(variantId),
      unitName: Value(unitName),
      qtyEntered: Value(qtyEntered),
      qtyBase: Value(qtyBase),
      ratePaise: Value(ratePaise),
      priceUnitFactor: Value(priceUnitFactor),
      discountPaise: Value(discountPaise),
      gstRateBp: Value(gstRateBp),
      taxPaise: Value(taxPaise),
      lineTotalPaise: Value(lineTotalPaise),
      coilId:
          coilId == null && nullToAbsent ? const Value.absent() : Value(coilId),
      serial:
          serial == null && nullToAbsent ? const Value.absent() : Value(serial),
    );
  }

  factory InvoiceLine.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return InvoiceLine(
      id: serializer.fromJson<String>(json['id']),
      shopId: serializer.fromJson<String>(json['shopId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      invoiceId: serializer.fromJson<String>(json['invoiceId']),
      itemId: serializer.fromJson<String>(json['itemId']),
      variantId: serializer.fromJson<String?>(json['variantId']),
      unitName: serializer.fromJson<String>(json['unitName']),
      qtyEntered: serializer.fromJson<String>(json['qtyEntered']),
      qtyBase: serializer.fromJson<int>(json['qtyBase']),
      ratePaise: serializer.fromJson<int>(json['ratePaise']),
      priceUnitFactor: serializer.fromJson<int>(json['priceUnitFactor']),
      discountPaise: serializer.fromJson<int>(json['discountPaise']),
      gstRateBp: serializer.fromJson<int>(json['gstRateBp']),
      taxPaise: serializer.fromJson<int>(json['taxPaise']),
      lineTotalPaise: serializer.fromJson<int>(json['lineTotalPaise']),
      coilId: serializer.fromJson<String?>(json['coilId']),
      serial: serializer.fromJson<String?>(json['serial']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'shopId': serializer.toJson<String>(shopId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'invoiceId': serializer.toJson<String>(invoiceId),
      'itemId': serializer.toJson<String>(itemId),
      'variantId': serializer.toJson<String?>(variantId),
      'unitName': serializer.toJson<String>(unitName),
      'qtyEntered': serializer.toJson<String>(qtyEntered),
      'qtyBase': serializer.toJson<int>(qtyBase),
      'ratePaise': serializer.toJson<int>(ratePaise),
      'priceUnitFactor': serializer.toJson<int>(priceUnitFactor),
      'discountPaise': serializer.toJson<int>(discountPaise),
      'gstRateBp': serializer.toJson<int>(gstRateBp),
      'taxPaise': serializer.toJson<int>(taxPaise),
      'lineTotalPaise': serializer.toJson<int>(lineTotalPaise),
      'coilId': serializer.toJson<String?>(coilId),
      'serial': serializer.toJson<String?>(serial),
    };
  }

  InvoiceLine copyWith({
    String? id,
    String? shopId,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? invoiceId,
    String? itemId,
    Value<String?> variantId = const Value.absent(),
    String? unitName,
    String? qtyEntered,
    int? qtyBase,
    int? ratePaise,
    int? priceUnitFactor,
    int? discountPaise,
    int? gstRateBp,
    int? taxPaise,
    int? lineTotalPaise,
    Value<String?> coilId = const Value.absent(),
    Value<String?> serial = const Value.absent(),
  }) => InvoiceLine(
    id: id ?? this.id,
    shopId: shopId ?? this.shopId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    invoiceId: invoiceId ?? this.invoiceId,
    itemId: itemId ?? this.itemId,
    variantId: variantId.present ? variantId.value : this.variantId,
    unitName: unitName ?? this.unitName,
    qtyEntered: qtyEntered ?? this.qtyEntered,
    qtyBase: qtyBase ?? this.qtyBase,
    ratePaise: ratePaise ?? this.ratePaise,
    priceUnitFactor: priceUnitFactor ?? this.priceUnitFactor,
    discountPaise: discountPaise ?? this.discountPaise,
    gstRateBp: gstRateBp ?? this.gstRateBp,
    taxPaise: taxPaise ?? this.taxPaise,
    lineTotalPaise: lineTotalPaise ?? this.lineTotalPaise,
    coilId: coilId.present ? coilId.value : this.coilId,
    serial: serial.present ? serial.value : this.serial,
  );
  InvoiceLine copyWithCompanion(InvoiceLinesCompanion data) {
    return InvoiceLine(
      id: data.id.present ? data.id.value : this.id,
      shopId: data.shopId.present ? data.shopId.value : this.shopId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      invoiceId: data.invoiceId.present ? data.invoiceId.value : this.invoiceId,
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      variantId: data.variantId.present ? data.variantId.value : this.variantId,
      unitName: data.unitName.present ? data.unitName.value : this.unitName,
      qtyEntered:
          data.qtyEntered.present ? data.qtyEntered.value : this.qtyEntered,
      qtyBase: data.qtyBase.present ? data.qtyBase.value : this.qtyBase,
      ratePaise: data.ratePaise.present ? data.ratePaise.value : this.ratePaise,
      priceUnitFactor:
          data.priceUnitFactor.present
              ? data.priceUnitFactor.value
              : this.priceUnitFactor,
      discountPaise:
          data.discountPaise.present
              ? data.discountPaise.value
              : this.discountPaise,
      gstRateBp: data.gstRateBp.present ? data.gstRateBp.value : this.gstRateBp,
      taxPaise: data.taxPaise.present ? data.taxPaise.value : this.taxPaise,
      lineTotalPaise:
          data.lineTotalPaise.present
              ? data.lineTotalPaise.value
              : this.lineTotalPaise,
      coilId: data.coilId.present ? data.coilId.value : this.coilId,
      serial: data.serial.present ? data.serial.value : this.serial,
    );
  }

  @override
  String toString() {
    return (StringBuffer('InvoiceLine(')
          ..write('id: $id, ')
          ..write('shopId: $shopId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('invoiceId: $invoiceId, ')
          ..write('itemId: $itemId, ')
          ..write('variantId: $variantId, ')
          ..write('unitName: $unitName, ')
          ..write('qtyEntered: $qtyEntered, ')
          ..write('qtyBase: $qtyBase, ')
          ..write('ratePaise: $ratePaise, ')
          ..write('priceUnitFactor: $priceUnitFactor, ')
          ..write('discountPaise: $discountPaise, ')
          ..write('gstRateBp: $gstRateBp, ')
          ..write('taxPaise: $taxPaise, ')
          ..write('lineTotalPaise: $lineTotalPaise, ')
          ..write('coilId: $coilId, ')
          ..write('serial: $serial')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    shopId,
    createdAt,
    updatedAt,
    deletedAt,
    invoiceId,
    itemId,
    variantId,
    unitName,
    qtyEntered,
    qtyBase,
    ratePaise,
    priceUnitFactor,
    discountPaise,
    gstRateBp,
    taxPaise,
    lineTotalPaise,
    coilId,
    serial,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InvoiceLine &&
          other.id == this.id &&
          other.shopId == this.shopId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.invoiceId == this.invoiceId &&
          other.itemId == this.itemId &&
          other.variantId == this.variantId &&
          other.unitName == this.unitName &&
          other.qtyEntered == this.qtyEntered &&
          other.qtyBase == this.qtyBase &&
          other.ratePaise == this.ratePaise &&
          other.priceUnitFactor == this.priceUnitFactor &&
          other.discountPaise == this.discountPaise &&
          other.gstRateBp == this.gstRateBp &&
          other.taxPaise == this.taxPaise &&
          other.lineTotalPaise == this.lineTotalPaise &&
          other.coilId == this.coilId &&
          other.serial == this.serial);
}

class InvoiceLinesCompanion extends UpdateCompanion<InvoiceLine> {
  final Value<String> id;
  final Value<String> shopId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> invoiceId;
  final Value<String> itemId;
  final Value<String?> variantId;
  final Value<String> unitName;
  final Value<String> qtyEntered;
  final Value<int> qtyBase;
  final Value<int> ratePaise;
  final Value<int> priceUnitFactor;
  final Value<int> discountPaise;
  final Value<int> gstRateBp;
  final Value<int> taxPaise;
  final Value<int> lineTotalPaise;
  final Value<String?> coilId;
  final Value<String?> serial;
  final Value<int> rowid;
  const InvoiceLinesCompanion({
    this.id = const Value.absent(),
    this.shopId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.invoiceId = const Value.absent(),
    this.itemId = const Value.absent(),
    this.variantId = const Value.absent(),
    this.unitName = const Value.absent(),
    this.qtyEntered = const Value.absent(),
    this.qtyBase = const Value.absent(),
    this.ratePaise = const Value.absent(),
    this.priceUnitFactor = const Value.absent(),
    this.discountPaise = const Value.absent(),
    this.gstRateBp = const Value.absent(),
    this.taxPaise = const Value.absent(),
    this.lineTotalPaise = const Value.absent(),
    this.coilId = const Value.absent(),
    this.serial = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  InvoiceLinesCompanion.insert({
    required String id,
    required String shopId,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    required String invoiceId,
    required String itemId,
    this.variantId = const Value.absent(),
    required String unitName,
    required String qtyEntered,
    required int qtyBase,
    required int ratePaise,
    this.priceUnitFactor = const Value.absent(),
    this.discountPaise = const Value.absent(),
    this.gstRateBp = const Value.absent(),
    required int taxPaise,
    required int lineTotalPaise,
    this.coilId = const Value.absent(),
    this.serial = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       shopId = Value(shopId),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       invoiceId = Value(invoiceId),
       itemId = Value(itemId),
       unitName = Value(unitName),
       qtyEntered = Value(qtyEntered),
       qtyBase = Value(qtyBase),
       ratePaise = Value(ratePaise),
       taxPaise = Value(taxPaise),
       lineTotalPaise = Value(lineTotalPaise);
  static Insertable<InvoiceLine> custom({
    Expression<String>? id,
    Expression<String>? shopId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? invoiceId,
    Expression<String>? itemId,
    Expression<String>? variantId,
    Expression<String>? unitName,
    Expression<String>? qtyEntered,
    Expression<int>? qtyBase,
    Expression<int>? ratePaise,
    Expression<int>? priceUnitFactor,
    Expression<int>? discountPaise,
    Expression<int>? gstRateBp,
    Expression<int>? taxPaise,
    Expression<int>? lineTotalPaise,
    Expression<String>? coilId,
    Expression<String>? serial,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (shopId != null) 'shop_id': shopId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (invoiceId != null) 'invoice_id': invoiceId,
      if (itemId != null) 'item_id': itemId,
      if (variantId != null) 'variant_id': variantId,
      if (unitName != null) 'unit_name': unitName,
      if (qtyEntered != null) 'qty_entered': qtyEntered,
      if (qtyBase != null) 'qty_base': qtyBase,
      if (ratePaise != null) 'rate_paise': ratePaise,
      if (priceUnitFactor != null) 'price_unit_factor': priceUnitFactor,
      if (discountPaise != null) 'discount_paise': discountPaise,
      if (gstRateBp != null) 'gst_rate_bp': gstRateBp,
      if (taxPaise != null) 'tax_paise': taxPaise,
      if (lineTotalPaise != null) 'line_total_paise': lineTotalPaise,
      if (coilId != null) 'coil_id': coilId,
      if (serial != null) 'serial': serial,
      if (rowid != null) 'rowid': rowid,
    });
  }

  InvoiceLinesCompanion copyWith({
    Value<String>? id,
    Value<String>? shopId,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? invoiceId,
    Value<String>? itemId,
    Value<String?>? variantId,
    Value<String>? unitName,
    Value<String>? qtyEntered,
    Value<int>? qtyBase,
    Value<int>? ratePaise,
    Value<int>? priceUnitFactor,
    Value<int>? discountPaise,
    Value<int>? gstRateBp,
    Value<int>? taxPaise,
    Value<int>? lineTotalPaise,
    Value<String?>? coilId,
    Value<String?>? serial,
    Value<int>? rowid,
  }) {
    return InvoiceLinesCompanion(
      id: id ?? this.id,
      shopId: shopId ?? this.shopId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      invoiceId: invoiceId ?? this.invoiceId,
      itemId: itemId ?? this.itemId,
      variantId: variantId ?? this.variantId,
      unitName: unitName ?? this.unitName,
      qtyEntered: qtyEntered ?? this.qtyEntered,
      qtyBase: qtyBase ?? this.qtyBase,
      ratePaise: ratePaise ?? this.ratePaise,
      priceUnitFactor: priceUnitFactor ?? this.priceUnitFactor,
      discountPaise: discountPaise ?? this.discountPaise,
      gstRateBp: gstRateBp ?? this.gstRateBp,
      taxPaise: taxPaise ?? this.taxPaise,
      lineTotalPaise: lineTotalPaise ?? this.lineTotalPaise,
      coilId: coilId ?? this.coilId,
      serial: serial ?? this.serial,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (shopId.present) {
      map['shop_id'] = Variable<String>(shopId.value);
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
    if (invoiceId.present) {
      map['invoice_id'] = Variable<String>(invoiceId.value);
    }
    if (itemId.present) {
      map['item_id'] = Variable<String>(itemId.value);
    }
    if (variantId.present) {
      map['variant_id'] = Variable<String>(variantId.value);
    }
    if (unitName.present) {
      map['unit_name'] = Variable<String>(unitName.value);
    }
    if (qtyEntered.present) {
      map['qty_entered'] = Variable<String>(qtyEntered.value);
    }
    if (qtyBase.present) {
      map['qty_base'] = Variable<int>(qtyBase.value);
    }
    if (ratePaise.present) {
      map['rate_paise'] = Variable<int>(ratePaise.value);
    }
    if (priceUnitFactor.present) {
      map['price_unit_factor'] = Variable<int>(priceUnitFactor.value);
    }
    if (discountPaise.present) {
      map['discount_paise'] = Variable<int>(discountPaise.value);
    }
    if (gstRateBp.present) {
      map['gst_rate_bp'] = Variable<int>(gstRateBp.value);
    }
    if (taxPaise.present) {
      map['tax_paise'] = Variable<int>(taxPaise.value);
    }
    if (lineTotalPaise.present) {
      map['line_total_paise'] = Variable<int>(lineTotalPaise.value);
    }
    if (coilId.present) {
      map['coil_id'] = Variable<String>(coilId.value);
    }
    if (serial.present) {
      map['serial'] = Variable<String>(serial.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InvoiceLinesCompanion(')
          ..write('id: $id, ')
          ..write('shopId: $shopId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('invoiceId: $invoiceId, ')
          ..write('itemId: $itemId, ')
          ..write('variantId: $variantId, ')
          ..write('unitName: $unitName, ')
          ..write('qtyEntered: $qtyEntered, ')
          ..write('qtyBase: $qtyBase, ')
          ..write('ratePaise: $ratePaise, ')
          ..write('priceUnitFactor: $priceUnitFactor, ')
          ..write('discountPaise: $discountPaise, ')
          ..write('gstRateBp: $gstRateBp, ')
          ..write('taxPaise: $taxPaise, ')
          ..write('lineTotalPaise: $lineTotalPaise, ')
          ..write('coilId: $coilId, ')
          ..write('serial: $serial, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $InvoicePaymentsTable extends InvoicePayments
    with TableInfo<$InvoicePaymentsTable, InvoicePayment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InvoicePaymentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _shopIdMeta = const VerificationMeta('shopId');
  @override
  late final GeneratedColumn<String> shopId = GeneratedColumn<String>(
    'shop_id',
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
  static const VerificationMeta _invoiceIdMeta = const VerificationMeta(
    'invoiceId',
  );
  @override
  late final GeneratedColumn<String> invoiceId = GeneratedColumn<String>(
    'invoice_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES invoices (id)',
    ),
  );
  static const VerificationMeta _modeMeta = const VerificationMeta('mode');
  @override
  late final GeneratedColumn<String> mode = GeneratedColumn<String>(
    'mode',
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
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _refMeta = const VerificationMeta('ref');
  @override
  late final GeneratedColumn<String> ref = GeneratedColumn<String>(
    'ref',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    shopId,
    createdAt,
    updatedAt,
    deletedAt,
    invoiceId,
    mode,
    amountPaise,
    ref,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'invoice_payments';
  @override
  VerificationContext validateIntegrity(
    Insertable<InvoicePayment> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('shop_id')) {
      context.handle(
        _shopIdMeta,
        shopId.isAcceptableOrUnknown(data['shop_id']!, _shopIdMeta),
      );
    } else if (isInserting) {
      context.missing(_shopIdMeta);
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
    if (data.containsKey('invoice_id')) {
      context.handle(
        _invoiceIdMeta,
        invoiceId.isAcceptableOrUnknown(data['invoice_id']!, _invoiceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_invoiceIdMeta);
    }
    if (data.containsKey('mode')) {
      context.handle(
        _modeMeta,
        mode.isAcceptableOrUnknown(data['mode']!, _modeMeta),
      );
    } else if (isInserting) {
      context.missing(_modeMeta);
    }
    if (data.containsKey('amount_paise')) {
      context.handle(
        _amountPaiseMeta,
        amountPaise.isAcceptableOrUnknown(
          data['amount_paise']!,
          _amountPaiseMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountPaiseMeta);
    }
    if (data.containsKey('ref')) {
      context.handle(
        _refMeta,
        ref.isAcceptableOrUnknown(data['ref']!, _refMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  InvoicePayment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return InvoicePayment(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}id'],
          )!,
      shopId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}shop_id'],
          )!,
      createdAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}created_at'],
          )!,
      updatedAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}updated_at'],
          )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      invoiceId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}invoice_id'],
          )!,
      mode:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}mode'],
          )!,
      amountPaise:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}amount_paise'],
          )!,
      ref: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ref'],
      ),
    );
  }

  @override
  $InvoicePaymentsTable createAlias(String alias) {
    return $InvoicePaymentsTable(attachedDatabase, alias);
  }
}

class InvoicePayment extends DataClass implements Insertable<InvoicePayment> {
  final String id;
  final String shopId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String invoiceId;

  /// cash | upi | credit | card
  final String mode;
  final int amountPaise;
  final String? ref;
  const InvoicePayment({
    required this.id,
    required this.shopId,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.invoiceId,
    required this.mode,
    required this.amountPaise,
    this.ref,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['shop_id'] = Variable<String>(shopId);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['invoice_id'] = Variable<String>(invoiceId);
    map['mode'] = Variable<String>(mode);
    map['amount_paise'] = Variable<int>(amountPaise);
    if (!nullToAbsent || ref != null) {
      map['ref'] = Variable<String>(ref);
    }
    return map;
  }

  InvoicePaymentsCompanion toCompanion(bool nullToAbsent) {
    return InvoicePaymentsCompanion(
      id: Value(id),
      shopId: Value(shopId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt:
          deletedAt == null && nullToAbsent
              ? const Value.absent()
              : Value(deletedAt),
      invoiceId: Value(invoiceId),
      mode: Value(mode),
      amountPaise: Value(amountPaise),
      ref: ref == null && nullToAbsent ? const Value.absent() : Value(ref),
    );
  }

  factory InvoicePayment.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return InvoicePayment(
      id: serializer.fromJson<String>(json['id']),
      shopId: serializer.fromJson<String>(json['shopId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      invoiceId: serializer.fromJson<String>(json['invoiceId']),
      mode: serializer.fromJson<String>(json['mode']),
      amountPaise: serializer.fromJson<int>(json['amountPaise']),
      ref: serializer.fromJson<String?>(json['ref']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'shopId': serializer.toJson<String>(shopId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'invoiceId': serializer.toJson<String>(invoiceId),
      'mode': serializer.toJson<String>(mode),
      'amountPaise': serializer.toJson<int>(amountPaise),
      'ref': serializer.toJson<String?>(ref),
    };
  }

  InvoicePayment copyWith({
    String? id,
    String? shopId,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? invoiceId,
    String? mode,
    int? amountPaise,
    Value<String?> ref = const Value.absent(),
  }) => InvoicePayment(
    id: id ?? this.id,
    shopId: shopId ?? this.shopId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    invoiceId: invoiceId ?? this.invoiceId,
    mode: mode ?? this.mode,
    amountPaise: amountPaise ?? this.amountPaise,
    ref: ref.present ? ref.value : this.ref,
  );
  InvoicePayment copyWithCompanion(InvoicePaymentsCompanion data) {
    return InvoicePayment(
      id: data.id.present ? data.id.value : this.id,
      shopId: data.shopId.present ? data.shopId.value : this.shopId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      invoiceId: data.invoiceId.present ? data.invoiceId.value : this.invoiceId,
      mode: data.mode.present ? data.mode.value : this.mode,
      amountPaise:
          data.amountPaise.present ? data.amountPaise.value : this.amountPaise,
      ref: data.ref.present ? data.ref.value : this.ref,
    );
  }

  @override
  String toString() {
    return (StringBuffer('InvoicePayment(')
          ..write('id: $id, ')
          ..write('shopId: $shopId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('invoiceId: $invoiceId, ')
          ..write('mode: $mode, ')
          ..write('amountPaise: $amountPaise, ')
          ..write('ref: $ref')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    shopId,
    createdAt,
    updatedAt,
    deletedAt,
    invoiceId,
    mode,
    amountPaise,
    ref,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InvoicePayment &&
          other.id == this.id &&
          other.shopId == this.shopId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.invoiceId == this.invoiceId &&
          other.mode == this.mode &&
          other.amountPaise == this.amountPaise &&
          other.ref == this.ref);
}

class InvoicePaymentsCompanion extends UpdateCompanion<InvoicePayment> {
  final Value<String> id;
  final Value<String> shopId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> invoiceId;
  final Value<String> mode;
  final Value<int> amountPaise;
  final Value<String?> ref;
  final Value<int> rowid;
  const InvoicePaymentsCompanion({
    this.id = const Value.absent(),
    this.shopId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.invoiceId = const Value.absent(),
    this.mode = const Value.absent(),
    this.amountPaise = const Value.absent(),
    this.ref = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  InvoicePaymentsCompanion.insert({
    required String id,
    required String shopId,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    required String invoiceId,
    required String mode,
    required int amountPaise,
    this.ref = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       shopId = Value(shopId),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       invoiceId = Value(invoiceId),
       mode = Value(mode),
       amountPaise = Value(amountPaise);
  static Insertable<InvoicePayment> custom({
    Expression<String>? id,
    Expression<String>? shopId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? invoiceId,
    Expression<String>? mode,
    Expression<int>? amountPaise,
    Expression<String>? ref,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (shopId != null) 'shop_id': shopId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (invoiceId != null) 'invoice_id': invoiceId,
      if (mode != null) 'mode': mode,
      if (amountPaise != null) 'amount_paise': amountPaise,
      if (ref != null) 'ref': ref,
      if (rowid != null) 'rowid': rowid,
    });
  }

  InvoicePaymentsCompanion copyWith({
    Value<String>? id,
    Value<String>? shopId,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? invoiceId,
    Value<String>? mode,
    Value<int>? amountPaise,
    Value<String?>? ref,
    Value<int>? rowid,
  }) {
    return InvoicePaymentsCompanion(
      id: id ?? this.id,
      shopId: shopId ?? this.shopId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      invoiceId: invoiceId ?? this.invoiceId,
      mode: mode ?? this.mode,
      amountPaise: amountPaise ?? this.amountPaise,
      ref: ref ?? this.ref,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (shopId.present) {
      map['shop_id'] = Variable<String>(shopId.value);
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
    if (invoiceId.present) {
      map['invoice_id'] = Variable<String>(invoiceId.value);
    }
    if (mode.present) {
      map['mode'] = Variable<String>(mode.value);
    }
    if (amountPaise.present) {
      map['amount_paise'] = Variable<int>(amountPaise.value);
    }
    if (ref.present) {
      map['ref'] = Variable<String>(ref.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InvoicePaymentsCompanion(')
          ..write('id: $id, ')
          ..write('shopId: $shopId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('invoiceId: $invoiceId, ')
          ..write('mode: $mode, ')
          ..write('amountPaise: $amountPaise, ')
          ..write('ref: $ref, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SalesReturnsTable extends SalesReturns
    with TableInfo<$SalesReturnsTable, SalesReturn> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SalesReturnsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _shopIdMeta = const VerificationMeta('shopId');
  @override
  late final GeneratedColumn<String> shopId = GeneratedColumn<String>(
    'shop_id',
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
  static const VerificationMeta _invoiceIdMeta = const VerificationMeta(
    'invoiceId',
  );
  @override
  late final GeneratedColumn<String> invoiceId = GeneratedColumn<String>(
    'invoice_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES invoices (id)',
    ),
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
  static const VerificationMeta _totalPaiseMeta = const VerificationMeta(
    'totalPaise',
  );
  @override
  late final GeneratedColumn<int> totalPaise = GeneratedColumn<int>(
    'total_paise',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
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
  static const VerificationMeta _createdByMeta = const VerificationMeta(
    'createdBy',
  );
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
    'created_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    shopId,
    createdAt,
    updatedAt,
    deletedAt,
    invoiceId,
    date,
    totalPaise,
    note,
    createdBy,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sales_returns';
  @override
  VerificationContext validateIntegrity(
    Insertable<SalesReturn> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('shop_id')) {
      context.handle(
        _shopIdMeta,
        shopId.isAcceptableOrUnknown(data['shop_id']!, _shopIdMeta),
      );
    } else if (isInserting) {
      context.missing(_shopIdMeta);
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
    if (data.containsKey('invoice_id')) {
      context.handle(
        _invoiceIdMeta,
        invoiceId.isAcceptableOrUnknown(data['invoice_id']!, _invoiceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_invoiceIdMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('total_paise')) {
      context.handle(
        _totalPaiseMeta,
        totalPaise.isAcceptableOrUnknown(data['total_paise']!, _totalPaiseMeta),
      );
    } else if (isInserting) {
      context.missing(_totalPaiseMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('created_by')) {
      context.handle(
        _createdByMeta,
        createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SalesReturn map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SalesReturn(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}id'],
          )!,
      shopId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}shop_id'],
          )!,
      createdAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}created_at'],
          )!,
      updatedAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}updated_at'],
          )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      invoiceId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}invoice_id'],
          )!,
      date:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}date'],
          )!,
      totalPaise:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}total_paise'],
          )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      createdBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_by'],
      ),
    );
  }

  @override
  $SalesReturnsTable createAlias(String alias) {
    return $SalesReturnsTable(attachedDatabase, alias);
  }
}

class SalesReturn extends DataClass implements Insertable<SalesReturn> {
  final String id;
  final String shopId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String invoiceId;
  final DateTime date;
  final int totalPaise;
  final String? note;
  final String? createdBy;
  const SalesReturn({
    required this.id,
    required this.shopId,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.invoiceId,
    required this.date,
    required this.totalPaise,
    this.note,
    this.createdBy,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['shop_id'] = Variable<String>(shopId);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['invoice_id'] = Variable<String>(invoiceId);
    map['date'] = Variable<DateTime>(date);
    map['total_paise'] = Variable<int>(totalPaise);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    if (!nullToAbsent || createdBy != null) {
      map['created_by'] = Variable<String>(createdBy);
    }
    return map;
  }

  SalesReturnsCompanion toCompanion(bool nullToAbsent) {
    return SalesReturnsCompanion(
      id: Value(id),
      shopId: Value(shopId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt:
          deletedAt == null && nullToAbsent
              ? const Value.absent()
              : Value(deletedAt),
      invoiceId: Value(invoiceId),
      date: Value(date),
      totalPaise: Value(totalPaise),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      createdBy:
          createdBy == null && nullToAbsent
              ? const Value.absent()
              : Value(createdBy),
    );
  }

  factory SalesReturn.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SalesReturn(
      id: serializer.fromJson<String>(json['id']),
      shopId: serializer.fromJson<String>(json['shopId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      invoiceId: serializer.fromJson<String>(json['invoiceId']),
      date: serializer.fromJson<DateTime>(json['date']),
      totalPaise: serializer.fromJson<int>(json['totalPaise']),
      note: serializer.fromJson<String?>(json['note']),
      createdBy: serializer.fromJson<String?>(json['createdBy']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'shopId': serializer.toJson<String>(shopId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'invoiceId': serializer.toJson<String>(invoiceId),
      'date': serializer.toJson<DateTime>(date),
      'totalPaise': serializer.toJson<int>(totalPaise),
      'note': serializer.toJson<String?>(note),
      'createdBy': serializer.toJson<String?>(createdBy),
    };
  }

  SalesReturn copyWith({
    String? id,
    String? shopId,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? invoiceId,
    DateTime? date,
    int? totalPaise,
    Value<String?> note = const Value.absent(),
    Value<String?> createdBy = const Value.absent(),
  }) => SalesReturn(
    id: id ?? this.id,
    shopId: shopId ?? this.shopId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    invoiceId: invoiceId ?? this.invoiceId,
    date: date ?? this.date,
    totalPaise: totalPaise ?? this.totalPaise,
    note: note.present ? note.value : this.note,
    createdBy: createdBy.present ? createdBy.value : this.createdBy,
  );
  SalesReturn copyWithCompanion(SalesReturnsCompanion data) {
    return SalesReturn(
      id: data.id.present ? data.id.value : this.id,
      shopId: data.shopId.present ? data.shopId.value : this.shopId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      invoiceId: data.invoiceId.present ? data.invoiceId.value : this.invoiceId,
      date: data.date.present ? data.date.value : this.date,
      totalPaise:
          data.totalPaise.present ? data.totalPaise.value : this.totalPaise,
      note: data.note.present ? data.note.value : this.note,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SalesReturn(')
          ..write('id: $id, ')
          ..write('shopId: $shopId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('invoiceId: $invoiceId, ')
          ..write('date: $date, ')
          ..write('totalPaise: $totalPaise, ')
          ..write('note: $note, ')
          ..write('createdBy: $createdBy')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    shopId,
    createdAt,
    updatedAt,
    deletedAt,
    invoiceId,
    date,
    totalPaise,
    note,
    createdBy,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SalesReturn &&
          other.id == this.id &&
          other.shopId == this.shopId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.invoiceId == this.invoiceId &&
          other.date == this.date &&
          other.totalPaise == this.totalPaise &&
          other.note == this.note &&
          other.createdBy == this.createdBy);
}

class SalesReturnsCompanion extends UpdateCompanion<SalesReturn> {
  final Value<String> id;
  final Value<String> shopId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> invoiceId;
  final Value<DateTime> date;
  final Value<int> totalPaise;
  final Value<String?> note;
  final Value<String?> createdBy;
  final Value<int> rowid;
  const SalesReturnsCompanion({
    this.id = const Value.absent(),
    this.shopId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.invoiceId = const Value.absent(),
    this.date = const Value.absent(),
    this.totalPaise = const Value.absent(),
    this.note = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SalesReturnsCompanion.insert({
    required String id,
    required String shopId,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    required String invoiceId,
    required DateTime date,
    required int totalPaise,
    this.note = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       shopId = Value(shopId),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       invoiceId = Value(invoiceId),
       date = Value(date),
       totalPaise = Value(totalPaise);
  static Insertable<SalesReturn> custom({
    Expression<String>? id,
    Expression<String>? shopId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? invoiceId,
    Expression<DateTime>? date,
    Expression<int>? totalPaise,
    Expression<String>? note,
    Expression<String>? createdBy,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (shopId != null) 'shop_id': shopId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (invoiceId != null) 'invoice_id': invoiceId,
      if (date != null) 'date': date,
      if (totalPaise != null) 'total_paise': totalPaise,
      if (note != null) 'note': note,
      if (createdBy != null) 'created_by': createdBy,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SalesReturnsCompanion copyWith({
    Value<String>? id,
    Value<String>? shopId,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? invoiceId,
    Value<DateTime>? date,
    Value<int>? totalPaise,
    Value<String?>? note,
    Value<String?>? createdBy,
    Value<int>? rowid,
  }) {
    return SalesReturnsCompanion(
      id: id ?? this.id,
      shopId: shopId ?? this.shopId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      invoiceId: invoiceId ?? this.invoiceId,
      date: date ?? this.date,
      totalPaise: totalPaise ?? this.totalPaise,
      note: note ?? this.note,
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
    if (shopId.present) {
      map['shop_id'] = Variable<String>(shopId.value);
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
    if (invoiceId.present) {
      map['invoice_id'] = Variable<String>(invoiceId.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (totalPaise.present) {
      map['total_paise'] = Variable<int>(totalPaise.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SalesReturnsCompanion(')
          ..write('id: $id, ')
          ..write('shopId: $shopId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('invoiceId: $invoiceId, ')
          ..write('date: $date, ')
          ..write('totalPaise: $totalPaise, ')
          ..write('note: $note, ')
          ..write('createdBy: $createdBy, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SalesReturnLinesTable extends SalesReturnLines
    with TableInfo<$SalesReturnLinesTable, SalesReturnLine> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SalesReturnLinesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _shopIdMeta = const VerificationMeta('shopId');
  @override
  late final GeneratedColumn<String> shopId = GeneratedColumn<String>(
    'shop_id',
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
  static const VerificationMeta _returnIdMeta = const VerificationMeta(
    'returnId',
  );
  @override
  late final GeneratedColumn<String> returnId = GeneratedColumn<String>(
    'return_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES sales_returns (id)',
    ),
  );
  static const VerificationMeta _invoiceLineIdMeta = const VerificationMeta(
    'invoiceLineId',
  );
  @override
  late final GeneratedColumn<String> invoiceLineId = GeneratedColumn<String>(
    'invoice_line_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES invoice_lines (id)',
    ),
  );
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<String> itemId = GeneratedColumn<String>(
    'item_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES items (id)',
    ),
  );
  static const VerificationMeta _qtyBaseMeta = const VerificationMeta(
    'qtyBase',
  );
  @override
  late final GeneratedColumn<int> qtyBase = GeneratedColumn<int>(
    'qty_base',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lineTotalPaiseMeta = const VerificationMeta(
    'lineTotalPaise',
  );
  @override
  late final GeneratedColumn<int> lineTotalPaise = GeneratedColumn<int>(
    'line_total_paise',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    shopId,
    createdAt,
    updatedAt,
    deletedAt,
    returnId,
    invoiceLineId,
    itemId,
    qtyBase,
    lineTotalPaise,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sales_return_lines';
  @override
  VerificationContext validateIntegrity(
    Insertable<SalesReturnLine> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('shop_id')) {
      context.handle(
        _shopIdMeta,
        shopId.isAcceptableOrUnknown(data['shop_id']!, _shopIdMeta),
      );
    } else if (isInserting) {
      context.missing(_shopIdMeta);
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
    if (data.containsKey('return_id')) {
      context.handle(
        _returnIdMeta,
        returnId.isAcceptableOrUnknown(data['return_id']!, _returnIdMeta),
      );
    } else if (isInserting) {
      context.missing(_returnIdMeta);
    }
    if (data.containsKey('invoice_line_id')) {
      context.handle(
        _invoiceLineIdMeta,
        invoiceLineId.isAcceptableOrUnknown(
          data['invoice_line_id']!,
          _invoiceLineIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_invoiceLineIdMeta);
    }
    if (data.containsKey('item_id')) {
      context.handle(
        _itemIdMeta,
        itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta),
      );
    } else if (isInserting) {
      context.missing(_itemIdMeta);
    }
    if (data.containsKey('qty_base')) {
      context.handle(
        _qtyBaseMeta,
        qtyBase.isAcceptableOrUnknown(data['qty_base']!, _qtyBaseMeta),
      );
    } else if (isInserting) {
      context.missing(_qtyBaseMeta);
    }
    if (data.containsKey('line_total_paise')) {
      context.handle(
        _lineTotalPaiseMeta,
        lineTotalPaise.isAcceptableOrUnknown(
          data['line_total_paise']!,
          _lineTotalPaiseMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lineTotalPaiseMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SalesReturnLine map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SalesReturnLine(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}id'],
          )!,
      shopId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}shop_id'],
          )!,
      createdAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}created_at'],
          )!,
      updatedAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}updated_at'],
          )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      returnId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}return_id'],
          )!,
      invoiceLineId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}invoice_line_id'],
          )!,
      itemId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}item_id'],
          )!,
      qtyBase:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}qty_base'],
          )!,
      lineTotalPaise:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}line_total_paise'],
          )!,
    );
  }

  @override
  $SalesReturnLinesTable createAlias(String alias) {
    return $SalesReturnLinesTable(attachedDatabase, alias);
  }
}

class SalesReturnLine extends DataClass implements Insertable<SalesReturnLine> {
  final String id;
  final String shopId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String returnId;
  final String invoiceLineId;
  final String itemId;
  final int qtyBase;
  final int lineTotalPaise;
  const SalesReturnLine({
    required this.id,
    required this.shopId,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.returnId,
    required this.invoiceLineId,
    required this.itemId,
    required this.qtyBase,
    required this.lineTotalPaise,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['shop_id'] = Variable<String>(shopId);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['return_id'] = Variable<String>(returnId);
    map['invoice_line_id'] = Variable<String>(invoiceLineId);
    map['item_id'] = Variable<String>(itemId);
    map['qty_base'] = Variable<int>(qtyBase);
    map['line_total_paise'] = Variable<int>(lineTotalPaise);
    return map;
  }

  SalesReturnLinesCompanion toCompanion(bool nullToAbsent) {
    return SalesReturnLinesCompanion(
      id: Value(id),
      shopId: Value(shopId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt:
          deletedAt == null && nullToAbsent
              ? const Value.absent()
              : Value(deletedAt),
      returnId: Value(returnId),
      invoiceLineId: Value(invoiceLineId),
      itemId: Value(itemId),
      qtyBase: Value(qtyBase),
      lineTotalPaise: Value(lineTotalPaise),
    );
  }

  factory SalesReturnLine.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SalesReturnLine(
      id: serializer.fromJson<String>(json['id']),
      shopId: serializer.fromJson<String>(json['shopId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      returnId: serializer.fromJson<String>(json['returnId']),
      invoiceLineId: serializer.fromJson<String>(json['invoiceLineId']),
      itemId: serializer.fromJson<String>(json['itemId']),
      qtyBase: serializer.fromJson<int>(json['qtyBase']),
      lineTotalPaise: serializer.fromJson<int>(json['lineTotalPaise']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'shopId': serializer.toJson<String>(shopId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'returnId': serializer.toJson<String>(returnId),
      'invoiceLineId': serializer.toJson<String>(invoiceLineId),
      'itemId': serializer.toJson<String>(itemId),
      'qtyBase': serializer.toJson<int>(qtyBase),
      'lineTotalPaise': serializer.toJson<int>(lineTotalPaise),
    };
  }

  SalesReturnLine copyWith({
    String? id,
    String? shopId,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? returnId,
    String? invoiceLineId,
    String? itemId,
    int? qtyBase,
    int? lineTotalPaise,
  }) => SalesReturnLine(
    id: id ?? this.id,
    shopId: shopId ?? this.shopId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    returnId: returnId ?? this.returnId,
    invoiceLineId: invoiceLineId ?? this.invoiceLineId,
    itemId: itemId ?? this.itemId,
    qtyBase: qtyBase ?? this.qtyBase,
    lineTotalPaise: lineTotalPaise ?? this.lineTotalPaise,
  );
  SalesReturnLine copyWithCompanion(SalesReturnLinesCompanion data) {
    return SalesReturnLine(
      id: data.id.present ? data.id.value : this.id,
      shopId: data.shopId.present ? data.shopId.value : this.shopId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      returnId: data.returnId.present ? data.returnId.value : this.returnId,
      invoiceLineId:
          data.invoiceLineId.present
              ? data.invoiceLineId.value
              : this.invoiceLineId,
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      qtyBase: data.qtyBase.present ? data.qtyBase.value : this.qtyBase,
      lineTotalPaise:
          data.lineTotalPaise.present
              ? data.lineTotalPaise.value
              : this.lineTotalPaise,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SalesReturnLine(')
          ..write('id: $id, ')
          ..write('shopId: $shopId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('returnId: $returnId, ')
          ..write('invoiceLineId: $invoiceLineId, ')
          ..write('itemId: $itemId, ')
          ..write('qtyBase: $qtyBase, ')
          ..write('lineTotalPaise: $lineTotalPaise')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    shopId,
    createdAt,
    updatedAt,
    deletedAt,
    returnId,
    invoiceLineId,
    itemId,
    qtyBase,
    lineTotalPaise,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SalesReturnLine &&
          other.id == this.id &&
          other.shopId == this.shopId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.returnId == this.returnId &&
          other.invoiceLineId == this.invoiceLineId &&
          other.itemId == this.itemId &&
          other.qtyBase == this.qtyBase &&
          other.lineTotalPaise == this.lineTotalPaise);
}

class SalesReturnLinesCompanion extends UpdateCompanion<SalesReturnLine> {
  final Value<String> id;
  final Value<String> shopId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> returnId;
  final Value<String> invoiceLineId;
  final Value<String> itemId;
  final Value<int> qtyBase;
  final Value<int> lineTotalPaise;
  final Value<int> rowid;
  const SalesReturnLinesCompanion({
    this.id = const Value.absent(),
    this.shopId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.returnId = const Value.absent(),
    this.invoiceLineId = const Value.absent(),
    this.itemId = const Value.absent(),
    this.qtyBase = const Value.absent(),
    this.lineTotalPaise = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SalesReturnLinesCompanion.insert({
    required String id,
    required String shopId,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    required String returnId,
    required String invoiceLineId,
    required String itemId,
    required int qtyBase,
    required int lineTotalPaise,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       shopId = Value(shopId),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       returnId = Value(returnId),
       invoiceLineId = Value(invoiceLineId),
       itemId = Value(itemId),
       qtyBase = Value(qtyBase),
       lineTotalPaise = Value(lineTotalPaise);
  static Insertable<SalesReturnLine> custom({
    Expression<String>? id,
    Expression<String>? shopId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? returnId,
    Expression<String>? invoiceLineId,
    Expression<String>? itemId,
    Expression<int>? qtyBase,
    Expression<int>? lineTotalPaise,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (shopId != null) 'shop_id': shopId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (returnId != null) 'return_id': returnId,
      if (invoiceLineId != null) 'invoice_line_id': invoiceLineId,
      if (itemId != null) 'item_id': itemId,
      if (qtyBase != null) 'qty_base': qtyBase,
      if (lineTotalPaise != null) 'line_total_paise': lineTotalPaise,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SalesReturnLinesCompanion copyWith({
    Value<String>? id,
    Value<String>? shopId,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? returnId,
    Value<String>? invoiceLineId,
    Value<String>? itemId,
    Value<int>? qtyBase,
    Value<int>? lineTotalPaise,
    Value<int>? rowid,
  }) {
    return SalesReturnLinesCompanion(
      id: id ?? this.id,
      shopId: shopId ?? this.shopId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      returnId: returnId ?? this.returnId,
      invoiceLineId: invoiceLineId ?? this.invoiceLineId,
      itemId: itemId ?? this.itemId,
      qtyBase: qtyBase ?? this.qtyBase,
      lineTotalPaise: lineTotalPaise ?? this.lineTotalPaise,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (shopId.present) {
      map['shop_id'] = Variable<String>(shopId.value);
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
    if (returnId.present) {
      map['return_id'] = Variable<String>(returnId.value);
    }
    if (invoiceLineId.present) {
      map['invoice_line_id'] = Variable<String>(invoiceLineId.value);
    }
    if (itemId.present) {
      map['item_id'] = Variable<String>(itemId.value);
    }
    if (qtyBase.present) {
      map['qty_base'] = Variable<int>(qtyBase.value);
    }
    if (lineTotalPaise.present) {
      map['line_total_paise'] = Variable<int>(lineTotalPaise.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SalesReturnLinesCompanion(')
          ..write('id: $id, ')
          ..write('shopId: $shopId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('returnId: $returnId, ')
          ..write('invoiceLineId: $invoiceLineId, ')
          ..write('itemId: $itemId, ')
          ..write('qtyBase: $qtyBase, ')
          ..write('lineTotalPaise: $lineTotalPaise, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PurchasesTable extends Purchases
    with TableInfo<$PurchasesTable, Purchase> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PurchasesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _shopIdMeta = const VerificationMeta('shopId');
  @override
  late final GeneratedColumn<String> shopId = GeneratedColumn<String>(
    'shop_id',
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
  static const VerificationMeta _supplierIdMeta = const VerificationMeta(
    'supplierId',
  );
  @override
  late final GeneratedColumn<String> supplierId = GeneratedColumn<String>(
    'supplier_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES parties (id)',
    ),
  );
  static const VerificationMeta _supplierInvoiceNoMeta = const VerificationMeta(
    'supplierInvoiceNo',
  );
  @override
  late final GeneratedColumn<String> supplierInvoiceNo =
      GeneratedColumn<String>(
        'supplier_invoice_no',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _supplierInvoiceDateMeta =
      const VerificationMeta('supplierInvoiceDate');
  @override
  late final GeneratedColumn<DateTime> supplierInvoiceDate =
      GeneratedColumn<DateTime>(
        'supplier_invoice_date',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _subtotalPaiseMeta = const VerificationMeta(
    'subtotalPaise',
  );
  @override
  late final GeneratedColumn<int> subtotalPaise = GeneratedColumn<int>(
    'subtotal_paise',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _taxPaiseMeta = const VerificationMeta(
    'taxPaise',
  );
  @override
  late final GeneratedColumn<int> taxPaise = GeneratedColumn<int>(
    'tax_paise',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _totalPaiseMeta = const VerificationMeta(
    'totalPaise',
  );
  @override
  late final GeneratedColumn<int> totalPaise = GeneratedColumn<int>(
    'total_paise',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('manual'),
  );
  static const VerificationMeta _photoIdMeta = const VerificationMeta(
    'photoId',
  );
  @override
  late final GeneratedColumn<String> photoId = GeneratedColumn<String>(
    'photo_id',
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
    requiredDuringInsert: false,
    defaultValue: const Constant('posted'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    shopId,
    createdAt,
    updatedAt,
    deletedAt,
    supplierId,
    supplierInvoiceNo,
    supplierInvoiceDate,
    subtotalPaise,
    taxPaise,
    totalPaise,
    source,
    photoId,
    status,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'purchases';
  @override
  VerificationContext validateIntegrity(
    Insertable<Purchase> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('shop_id')) {
      context.handle(
        _shopIdMeta,
        shopId.isAcceptableOrUnknown(data['shop_id']!, _shopIdMeta),
      );
    } else if (isInserting) {
      context.missing(_shopIdMeta);
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
    if (data.containsKey('supplier_id')) {
      context.handle(
        _supplierIdMeta,
        supplierId.isAcceptableOrUnknown(data['supplier_id']!, _supplierIdMeta),
      );
    } else if (isInserting) {
      context.missing(_supplierIdMeta);
    }
    if (data.containsKey('supplier_invoice_no')) {
      context.handle(
        _supplierInvoiceNoMeta,
        supplierInvoiceNo.isAcceptableOrUnknown(
          data['supplier_invoice_no']!,
          _supplierInvoiceNoMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_supplierInvoiceNoMeta);
    }
    if (data.containsKey('supplier_invoice_date')) {
      context.handle(
        _supplierInvoiceDateMeta,
        supplierInvoiceDate.isAcceptableOrUnknown(
          data['supplier_invoice_date']!,
          _supplierInvoiceDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_supplierInvoiceDateMeta);
    }
    if (data.containsKey('subtotal_paise')) {
      context.handle(
        _subtotalPaiseMeta,
        subtotalPaise.isAcceptableOrUnknown(
          data['subtotal_paise']!,
          _subtotalPaiseMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_subtotalPaiseMeta);
    }
    if (data.containsKey('tax_paise')) {
      context.handle(
        _taxPaiseMeta,
        taxPaise.isAcceptableOrUnknown(data['tax_paise']!, _taxPaiseMeta),
      );
    } else if (isInserting) {
      context.missing(_taxPaiseMeta);
    }
    if (data.containsKey('total_paise')) {
      context.handle(
        _totalPaiseMeta,
        totalPaise.isAcceptableOrUnknown(data['total_paise']!, _totalPaiseMeta),
      );
    } else if (isInserting) {
      context.missing(_totalPaiseMeta);
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    }
    if (data.containsKey('photo_id')) {
      context.handle(
        _photoIdMeta,
        photoId.isAcceptableOrUnknown(data['photo_id']!, _photoIdMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {shopId, supplierId, supplierInvoiceNo},
  ];
  @override
  Purchase map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Purchase(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}id'],
          )!,
      shopId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}shop_id'],
          )!,
      createdAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}created_at'],
          )!,
      updatedAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}updated_at'],
          )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      supplierId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}supplier_id'],
          )!,
      supplierInvoiceNo:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}supplier_invoice_no'],
          )!,
      supplierInvoiceDate:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}supplier_invoice_date'],
          )!,
      subtotalPaise:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}subtotal_paise'],
          )!,
      taxPaise:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}tax_paise'],
          )!,
      totalPaise:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}total_paise'],
          )!,
      source:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}source'],
          )!,
      photoId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}photo_id'],
      ),
      status:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}status'],
          )!,
    );
  }

  @override
  $PurchasesTable createAlias(String alias) {
    return $PurchasesTable(attachedDatabase, alias);
  }
}

class Purchase extends DataClass implements Insertable<Purchase> {
  final String id;
  final String shopId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String supplierId;
  final String supplierInvoiceNo;
  final DateTime supplierInvoiceDate;
  final int subtotalPaise;
  final int taxPaise;
  final int totalPaise;

  /// manual | photo
  final String source;
  final String? photoId;

  /// posted | cancelled
  final String status;
  const Purchase({
    required this.id,
    required this.shopId,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.supplierId,
    required this.supplierInvoiceNo,
    required this.supplierInvoiceDate,
    required this.subtotalPaise,
    required this.taxPaise,
    required this.totalPaise,
    required this.source,
    this.photoId,
    required this.status,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['shop_id'] = Variable<String>(shopId);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['supplier_id'] = Variable<String>(supplierId);
    map['supplier_invoice_no'] = Variable<String>(supplierInvoiceNo);
    map['supplier_invoice_date'] = Variable<DateTime>(supplierInvoiceDate);
    map['subtotal_paise'] = Variable<int>(subtotalPaise);
    map['tax_paise'] = Variable<int>(taxPaise);
    map['total_paise'] = Variable<int>(totalPaise);
    map['source'] = Variable<String>(source);
    if (!nullToAbsent || photoId != null) {
      map['photo_id'] = Variable<String>(photoId);
    }
    map['status'] = Variable<String>(status);
    return map;
  }

  PurchasesCompanion toCompanion(bool nullToAbsent) {
    return PurchasesCompanion(
      id: Value(id),
      shopId: Value(shopId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt:
          deletedAt == null && nullToAbsent
              ? const Value.absent()
              : Value(deletedAt),
      supplierId: Value(supplierId),
      supplierInvoiceNo: Value(supplierInvoiceNo),
      supplierInvoiceDate: Value(supplierInvoiceDate),
      subtotalPaise: Value(subtotalPaise),
      taxPaise: Value(taxPaise),
      totalPaise: Value(totalPaise),
      source: Value(source),
      photoId:
          photoId == null && nullToAbsent
              ? const Value.absent()
              : Value(photoId),
      status: Value(status),
    );
  }

  factory Purchase.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Purchase(
      id: serializer.fromJson<String>(json['id']),
      shopId: serializer.fromJson<String>(json['shopId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      supplierId: serializer.fromJson<String>(json['supplierId']),
      supplierInvoiceNo: serializer.fromJson<String>(json['supplierInvoiceNo']),
      supplierInvoiceDate: serializer.fromJson<DateTime>(
        json['supplierInvoiceDate'],
      ),
      subtotalPaise: serializer.fromJson<int>(json['subtotalPaise']),
      taxPaise: serializer.fromJson<int>(json['taxPaise']),
      totalPaise: serializer.fromJson<int>(json['totalPaise']),
      source: serializer.fromJson<String>(json['source']),
      photoId: serializer.fromJson<String?>(json['photoId']),
      status: serializer.fromJson<String>(json['status']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'shopId': serializer.toJson<String>(shopId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'supplierId': serializer.toJson<String>(supplierId),
      'supplierInvoiceNo': serializer.toJson<String>(supplierInvoiceNo),
      'supplierInvoiceDate': serializer.toJson<DateTime>(supplierInvoiceDate),
      'subtotalPaise': serializer.toJson<int>(subtotalPaise),
      'taxPaise': serializer.toJson<int>(taxPaise),
      'totalPaise': serializer.toJson<int>(totalPaise),
      'source': serializer.toJson<String>(source),
      'photoId': serializer.toJson<String?>(photoId),
      'status': serializer.toJson<String>(status),
    };
  }

  Purchase copyWith({
    String? id,
    String? shopId,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? supplierId,
    String? supplierInvoiceNo,
    DateTime? supplierInvoiceDate,
    int? subtotalPaise,
    int? taxPaise,
    int? totalPaise,
    String? source,
    Value<String?> photoId = const Value.absent(),
    String? status,
  }) => Purchase(
    id: id ?? this.id,
    shopId: shopId ?? this.shopId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    supplierId: supplierId ?? this.supplierId,
    supplierInvoiceNo: supplierInvoiceNo ?? this.supplierInvoiceNo,
    supplierInvoiceDate: supplierInvoiceDate ?? this.supplierInvoiceDate,
    subtotalPaise: subtotalPaise ?? this.subtotalPaise,
    taxPaise: taxPaise ?? this.taxPaise,
    totalPaise: totalPaise ?? this.totalPaise,
    source: source ?? this.source,
    photoId: photoId.present ? photoId.value : this.photoId,
    status: status ?? this.status,
  );
  Purchase copyWithCompanion(PurchasesCompanion data) {
    return Purchase(
      id: data.id.present ? data.id.value : this.id,
      shopId: data.shopId.present ? data.shopId.value : this.shopId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      supplierId:
          data.supplierId.present ? data.supplierId.value : this.supplierId,
      supplierInvoiceNo:
          data.supplierInvoiceNo.present
              ? data.supplierInvoiceNo.value
              : this.supplierInvoiceNo,
      supplierInvoiceDate:
          data.supplierInvoiceDate.present
              ? data.supplierInvoiceDate.value
              : this.supplierInvoiceDate,
      subtotalPaise:
          data.subtotalPaise.present
              ? data.subtotalPaise.value
              : this.subtotalPaise,
      taxPaise: data.taxPaise.present ? data.taxPaise.value : this.taxPaise,
      totalPaise:
          data.totalPaise.present ? data.totalPaise.value : this.totalPaise,
      source: data.source.present ? data.source.value : this.source,
      photoId: data.photoId.present ? data.photoId.value : this.photoId,
      status: data.status.present ? data.status.value : this.status,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Purchase(')
          ..write('id: $id, ')
          ..write('shopId: $shopId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('supplierId: $supplierId, ')
          ..write('supplierInvoiceNo: $supplierInvoiceNo, ')
          ..write('supplierInvoiceDate: $supplierInvoiceDate, ')
          ..write('subtotalPaise: $subtotalPaise, ')
          ..write('taxPaise: $taxPaise, ')
          ..write('totalPaise: $totalPaise, ')
          ..write('source: $source, ')
          ..write('photoId: $photoId, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    shopId,
    createdAt,
    updatedAt,
    deletedAt,
    supplierId,
    supplierInvoiceNo,
    supplierInvoiceDate,
    subtotalPaise,
    taxPaise,
    totalPaise,
    source,
    photoId,
    status,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Purchase &&
          other.id == this.id &&
          other.shopId == this.shopId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.supplierId == this.supplierId &&
          other.supplierInvoiceNo == this.supplierInvoiceNo &&
          other.supplierInvoiceDate == this.supplierInvoiceDate &&
          other.subtotalPaise == this.subtotalPaise &&
          other.taxPaise == this.taxPaise &&
          other.totalPaise == this.totalPaise &&
          other.source == this.source &&
          other.photoId == this.photoId &&
          other.status == this.status);
}

class PurchasesCompanion extends UpdateCompanion<Purchase> {
  final Value<String> id;
  final Value<String> shopId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> supplierId;
  final Value<String> supplierInvoiceNo;
  final Value<DateTime> supplierInvoiceDate;
  final Value<int> subtotalPaise;
  final Value<int> taxPaise;
  final Value<int> totalPaise;
  final Value<String> source;
  final Value<String?> photoId;
  final Value<String> status;
  final Value<int> rowid;
  const PurchasesCompanion({
    this.id = const Value.absent(),
    this.shopId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.supplierId = const Value.absent(),
    this.supplierInvoiceNo = const Value.absent(),
    this.supplierInvoiceDate = const Value.absent(),
    this.subtotalPaise = const Value.absent(),
    this.taxPaise = const Value.absent(),
    this.totalPaise = const Value.absent(),
    this.source = const Value.absent(),
    this.photoId = const Value.absent(),
    this.status = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PurchasesCompanion.insert({
    required String id,
    required String shopId,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    required String supplierId,
    required String supplierInvoiceNo,
    required DateTime supplierInvoiceDate,
    required int subtotalPaise,
    required int taxPaise,
    required int totalPaise,
    this.source = const Value.absent(),
    this.photoId = const Value.absent(),
    this.status = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       shopId = Value(shopId),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       supplierId = Value(supplierId),
       supplierInvoiceNo = Value(supplierInvoiceNo),
       supplierInvoiceDate = Value(supplierInvoiceDate),
       subtotalPaise = Value(subtotalPaise),
       taxPaise = Value(taxPaise),
       totalPaise = Value(totalPaise);
  static Insertable<Purchase> custom({
    Expression<String>? id,
    Expression<String>? shopId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? supplierId,
    Expression<String>? supplierInvoiceNo,
    Expression<DateTime>? supplierInvoiceDate,
    Expression<int>? subtotalPaise,
    Expression<int>? taxPaise,
    Expression<int>? totalPaise,
    Expression<String>? source,
    Expression<String>? photoId,
    Expression<String>? status,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (shopId != null) 'shop_id': shopId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (supplierId != null) 'supplier_id': supplierId,
      if (supplierInvoiceNo != null) 'supplier_invoice_no': supplierInvoiceNo,
      if (supplierInvoiceDate != null)
        'supplier_invoice_date': supplierInvoiceDate,
      if (subtotalPaise != null) 'subtotal_paise': subtotalPaise,
      if (taxPaise != null) 'tax_paise': taxPaise,
      if (totalPaise != null) 'total_paise': totalPaise,
      if (source != null) 'source': source,
      if (photoId != null) 'photo_id': photoId,
      if (status != null) 'status': status,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PurchasesCompanion copyWith({
    Value<String>? id,
    Value<String>? shopId,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? supplierId,
    Value<String>? supplierInvoiceNo,
    Value<DateTime>? supplierInvoiceDate,
    Value<int>? subtotalPaise,
    Value<int>? taxPaise,
    Value<int>? totalPaise,
    Value<String>? source,
    Value<String?>? photoId,
    Value<String>? status,
    Value<int>? rowid,
  }) {
    return PurchasesCompanion(
      id: id ?? this.id,
      shopId: shopId ?? this.shopId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      supplierId: supplierId ?? this.supplierId,
      supplierInvoiceNo: supplierInvoiceNo ?? this.supplierInvoiceNo,
      supplierInvoiceDate: supplierInvoiceDate ?? this.supplierInvoiceDate,
      subtotalPaise: subtotalPaise ?? this.subtotalPaise,
      taxPaise: taxPaise ?? this.taxPaise,
      totalPaise: totalPaise ?? this.totalPaise,
      source: source ?? this.source,
      photoId: photoId ?? this.photoId,
      status: status ?? this.status,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (shopId.present) {
      map['shop_id'] = Variable<String>(shopId.value);
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
    if (supplierId.present) {
      map['supplier_id'] = Variable<String>(supplierId.value);
    }
    if (supplierInvoiceNo.present) {
      map['supplier_invoice_no'] = Variable<String>(supplierInvoiceNo.value);
    }
    if (supplierInvoiceDate.present) {
      map['supplier_invoice_date'] = Variable<DateTime>(
        supplierInvoiceDate.value,
      );
    }
    if (subtotalPaise.present) {
      map['subtotal_paise'] = Variable<int>(subtotalPaise.value);
    }
    if (taxPaise.present) {
      map['tax_paise'] = Variable<int>(taxPaise.value);
    }
    if (totalPaise.present) {
      map['total_paise'] = Variable<int>(totalPaise.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (photoId.present) {
      map['photo_id'] = Variable<String>(photoId.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PurchasesCompanion(')
          ..write('id: $id, ')
          ..write('shopId: $shopId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('supplierId: $supplierId, ')
          ..write('supplierInvoiceNo: $supplierInvoiceNo, ')
          ..write('supplierInvoiceDate: $supplierInvoiceDate, ')
          ..write('subtotalPaise: $subtotalPaise, ')
          ..write('taxPaise: $taxPaise, ')
          ..write('totalPaise: $totalPaise, ')
          ..write('source: $source, ')
          ..write('photoId: $photoId, ')
          ..write('status: $status, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PurchaseLinesTable extends PurchaseLines
    with TableInfo<$PurchaseLinesTable, PurchaseLine> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PurchaseLinesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _shopIdMeta = const VerificationMeta('shopId');
  @override
  late final GeneratedColumn<String> shopId = GeneratedColumn<String>(
    'shop_id',
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
  static const VerificationMeta _purchaseIdMeta = const VerificationMeta(
    'purchaseId',
  );
  @override
  late final GeneratedColumn<String> purchaseId = GeneratedColumn<String>(
    'purchase_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES purchases (id)',
    ),
  );
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<String> itemId = GeneratedColumn<String>(
    'item_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES items (id)',
    ),
  );
  static const VerificationMeta _variantIdMeta = const VerificationMeta(
    'variantId',
  );
  @override
  late final GeneratedColumn<String> variantId = GeneratedColumn<String>(
    'variant_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES item_variants (id)',
    ),
  );
  static const VerificationMeta _unitNameMeta = const VerificationMeta(
    'unitName',
  );
  @override
  late final GeneratedColumn<String> unitName = GeneratedColumn<String>(
    'unit_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _qtyEnteredMeta = const VerificationMeta(
    'qtyEntered',
  );
  @override
  late final GeneratedColumn<String> qtyEntered = GeneratedColumn<String>(
    'qty_entered',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _qtyBaseMeta = const VerificationMeta(
    'qtyBase',
  );
  @override
  late final GeneratedColumn<int> qtyBase = GeneratedColumn<int>(
    'qty_base',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ratePaiseMeta = const VerificationMeta(
    'ratePaise',
  );
  @override
  late final GeneratedColumn<int> ratePaise = GeneratedColumn<int>(
    'rate_paise',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _priceUnitFactorMeta = const VerificationMeta(
    'priceUnitFactor',
  );
  @override
  late final GeneratedColumn<int> priceUnitFactor = GeneratedColumn<int>(
    'price_unit_factor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _gstRateBpMeta = const VerificationMeta(
    'gstRateBp',
  );
  @override
  late final GeneratedColumn<int> gstRateBp = GeneratedColumn<int>(
    'gst_rate_bp',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lineTotalPaiseMeta = const VerificationMeta(
    'lineTotalPaise',
  );
  @override
  late final GeneratedColumn<int> lineTotalPaise = GeneratedColumn<int>(
    'line_total_paise',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    shopId,
    createdAt,
    updatedAt,
    deletedAt,
    purchaseId,
    itemId,
    variantId,
    unitName,
    qtyEntered,
    qtyBase,
    ratePaise,
    priceUnitFactor,
    gstRateBp,
    lineTotalPaise,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'purchase_lines';
  @override
  VerificationContext validateIntegrity(
    Insertable<PurchaseLine> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('shop_id')) {
      context.handle(
        _shopIdMeta,
        shopId.isAcceptableOrUnknown(data['shop_id']!, _shopIdMeta),
      );
    } else if (isInserting) {
      context.missing(_shopIdMeta);
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
    if (data.containsKey('purchase_id')) {
      context.handle(
        _purchaseIdMeta,
        purchaseId.isAcceptableOrUnknown(data['purchase_id']!, _purchaseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_purchaseIdMeta);
    }
    if (data.containsKey('item_id')) {
      context.handle(
        _itemIdMeta,
        itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta),
      );
    } else if (isInserting) {
      context.missing(_itemIdMeta);
    }
    if (data.containsKey('variant_id')) {
      context.handle(
        _variantIdMeta,
        variantId.isAcceptableOrUnknown(data['variant_id']!, _variantIdMeta),
      );
    }
    if (data.containsKey('unit_name')) {
      context.handle(
        _unitNameMeta,
        unitName.isAcceptableOrUnknown(data['unit_name']!, _unitNameMeta),
      );
    } else if (isInserting) {
      context.missing(_unitNameMeta);
    }
    if (data.containsKey('qty_entered')) {
      context.handle(
        _qtyEnteredMeta,
        qtyEntered.isAcceptableOrUnknown(data['qty_entered']!, _qtyEnteredMeta),
      );
    } else if (isInserting) {
      context.missing(_qtyEnteredMeta);
    }
    if (data.containsKey('qty_base')) {
      context.handle(
        _qtyBaseMeta,
        qtyBase.isAcceptableOrUnknown(data['qty_base']!, _qtyBaseMeta),
      );
    } else if (isInserting) {
      context.missing(_qtyBaseMeta);
    }
    if (data.containsKey('rate_paise')) {
      context.handle(
        _ratePaiseMeta,
        ratePaise.isAcceptableOrUnknown(data['rate_paise']!, _ratePaiseMeta),
      );
    } else if (isInserting) {
      context.missing(_ratePaiseMeta);
    }
    if (data.containsKey('price_unit_factor')) {
      context.handle(
        _priceUnitFactorMeta,
        priceUnitFactor.isAcceptableOrUnknown(
          data['price_unit_factor']!,
          _priceUnitFactorMeta,
        ),
      );
    }
    if (data.containsKey('gst_rate_bp')) {
      context.handle(
        _gstRateBpMeta,
        gstRateBp.isAcceptableOrUnknown(data['gst_rate_bp']!, _gstRateBpMeta),
      );
    }
    if (data.containsKey('line_total_paise')) {
      context.handle(
        _lineTotalPaiseMeta,
        lineTotalPaise.isAcceptableOrUnknown(
          data['line_total_paise']!,
          _lineTotalPaiseMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lineTotalPaiseMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PurchaseLine map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PurchaseLine(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}id'],
          )!,
      shopId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}shop_id'],
          )!,
      createdAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}created_at'],
          )!,
      updatedAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}updated_at'],
          )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      purchaseId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}purchase_id'],
          )!,
      itemId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}item_id'],
          )!,
      variantId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}variant_id'],
      ),
      unitName:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}unit_name'],
          )!,
      qtyEntered:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}qty_entered'],
          )!,
      qtyBase:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}qty_base'],
          )!,
      ratePaise:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}rate_paise'],
          )!,
      priceUnitFactor:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}price_unit_factor'],
          )!,
      gstRateBp:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}gst_rate_bp'],
          )!,
      lineTotalPaise:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}line_total_paise'],
          )!,
    );
  }

  @override
  $PurchaseLinesTable createAlias(String alias) {
    return $PurchaseLinesTable(attachedDatabase, alias);
  }
}

class PurchaseLine extends DataClass implements Insertable<PurchaseLine> {
  final String id;
  final String shopId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String purchaseId;
  final String itemId;
  final String? variantId;
  final String unitName;
  final String qtyEntered;
  final int qtyBase;

  /// Paise per pricing unit.
  final int ratePaise;
  final int priceUnitFactor;
  final int gstRateBp;
  final int lineTotalPaise;
  const PurchaseLine({
    required this.id,
    required this.shopId,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.purchaseId,
    required this.itemId,
    this.variantId,
    required this.unitName,
    required this.qtyEntered,
    required this.qtyBase,
    required this.ratePaise,
    required this.priceUnitFactor,
    required this.gstRateBp,
    required this.lineTotalPaise,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['shop_id'] = Variable<String>(shopId);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['purchase_id'] = Variable<String>(purchaseId);
    map['item_id'] = Variable<String>(itemId);
    if (!nullToAbsent || variantId != null) {
      map['variant_id'] = Variable<String>(variantId);
    }
    map['unit_name'] = Variable<String>(unitName);
    map['qty_entered'] = Variable<String>(qtyEntered);
    map['qty_base'] = Variable<int>(qtyBase);
    map['rate_paise'] = Variable<int>(ratePaise);
    map['price_unit_factor'] = Variable<int>(priceUnitFactor);
    map['gst_rate_bp'] = Variable<int>(gstRateBp);
    map['line_total_paise'] = Variable<int>(lineTotalPaise);
    return map;
  }

  PurchaseLinesCompanion toCompanion(bool nullToAbsent) {
    return PurchaseLinesCompanion(
      id: Value(id),
      shopId: Value(shopId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt:
          deletedAt == null && nullToAbsent
              ? const Value.absent()
              : Value(deletedAt),
      purchaseId: Value(purchaseId),
      itemId: Value(itemId),
      variantId:
          variantId == null && nullToAbsent
              ? const Value.absent()
              : Value(variantId),
      unitName: Value(unitName),
      qtyEntered: Value(qtyEntered),
      qtyBase: Value(qtyBase),
      ratePaise: Value(ratePaise),
      priceUnitFactor: Value(priceUnitFactor),
      gstRateBp: Value(gstRateBp),
      lineTotalPaise: Value(lineTotalPaise),
    );
  }

  factory PurchaseLine.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PurchaseLine(
      id: serializer.fromJson<String>(json['id']),
      shopId: serializer.fromJson<String>(json['shopId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      purchaseId: serializer.fromJson<String>(json['purchaseId']),
      itemId: serializer.fromJson<String>(json['itemId']),
      variantId: serializer.fromJson<String?>(json['variantId']),
      unitName: serializer.fromJson<String>(json['unitName']),
      qtyEntered: serializer.fromJson<String>(json['qtyEntered']),
      qtyBase: serializer.fromJson<int>(json['qtyBase']),
      ratePaise: serializer.fromJson<int>(json['ratePaise']),
      priceUnitFactor: serializer.fromJson<int>(json['priceUnitFactor']),
      gstRateBp: serializer.fromJson<int>(json['gstRateBp']),
      lineTotalPaise: serializer.fromJson<int>(json['lineTotalPaise']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'shopId': serializer.toJson<String>(shopId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'purchaseId': serializer.toJson<String>(purchaseId),
      'itemId': serializer.toJson<String>(itemId),
      'variantId': serializer.toJson<String?>(variantId),
      'unitName': serializer.toJson<String>(unitName),
      'qtyEntered': serializer.toJson<String>(qtyEntered),
      'qtyBase': serializer.toJson<int>(qtyBase),
      'ratePaise': serializer.toJson<int>(ratePaise),
      'priceUnitFactor': serializer.toJson<int>(priceUnitFactor),
      'gstRateBp': serializer.toJson<int>(gstRateBp),
      'lineTotalPaise': serializer.toJson<int>(lineTotalPaise),
    };
  }

  PurchaseLine copyWith({
    String? id,
    String? shopId,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? purchaseId,
    String? itemId,
    Value<String?> variantId = const Value.absent(),
    String? unitName,
    String? qtyEntered,
    int? qtyBase,
    int? ratePaise,
    int? priceUnitFactor,
    int? gstRateBp,
    int? lineTotalPaise,
  }) => PurchaseLine(
    id: id ?? this.id,
    shopId: shopId ?? this.shopId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    purchaseId: purchaseId ?? this.purchaseId,
    itemId: itemId ?? this.itemId,
    variantId: variantId.present ? variantId.value : this.variantId,
    unitName: unitName ?? this.unitName,
    qtyEntered: qtyEntered ?? this.qtyEntered,
    qtyBase: qtyBase ?? this.qtyBase,
    ratePaise: ratePaise ?? this.ratePaise,
    priceUnitFactor: priceUnitFactor ?? this.priceUnitFactor,
    gstRateBp: gstRateBp ?? this.gstRateBp,
    lineTotalPaise: lineTotalPaise ?? this.lineTotalPaise,
  );
  PurchaseLine copyWithCompanion(PurchaseLinesCompanion data) {
    return PurchaseLine(
      id: data.id.present ? data.id.value : this.id,
      shopId: data.shopId.present ? data.shopId.value : this.shopId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      purchaseId:
          data.purchaseId.present ? data.purchaseId.value : this.purchaseId,
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      variantId: data.variantId.present ? data.variantId.value : this.variantId,
      unitName: data.unitName.present ? data.unitName.value : this.unitName,
      qtyEntered:
          data.qtyEntered.present ? data.qtyEntered.value : this.qtyEntered,
      qtyBase: data.qtyBase.present ? data.qtyBase.value : this.qtyBase,
      ratePaise: data.ratePaise.present ? data.ratePaise.value : this.ratePaise,
      priceUnitFactor:
          data.priceUnitFactor.present
              ? data.priceUnitFactor.value
              : this.priceUnitFactor,
      gstRateBp: data.gstRateBp.present ? data.gstRateBp.value : this.gstRateBp,
      lineTotalPaise:
          data.lineTotalPaise.present
              ? data.lineTotalPaise.value
              : this.lineTotalPaise,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PurchaseLine(')
          ..write('id: $id, ')
          ..write('shopId: $shopId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('purchaseId: $purchaseId, ')
          ..write('itemId: $itemId, ')
          ..write('variantId: $variantId, ')
          ..write('unitName: $unitName, ')
          ..write('qtyEntered: $qtyEntered, ')
          ..write('qtyBase: $qtyBase, ')
          ..write('ratePaise: $ratePaise, ')
          ..write('priceUnitFactor: $priceUnitFactor, ')
          ..write('gstRateBp: $gstRateBp, ')
          ..write('lineTotalPaise: $lineTotalPaise')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    shopId,
    createdAt,
    updatedAt,
    deletedAt,
    purchaseId,
    itemId,
    variantId,
    unitName,
    qtyEntered,
    qtyBase,
    ratePaise,
    priceUnitFactor,
    gstRateBp,
    lineTotalPaise,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PurchaseLine &&
          other.id == this.id &&
          other.shopId == this.shopId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.purchaseId == this.purchaseId &&
          other.itemId == this.itemId &&
          other.variantId == this.variantId &&
          other.unitName == this.unitName &&
          other.qtyEntered == this.qtyEntered &&
          other.qtyBase == this.qtyBase &&
          other.ratePaise == this.ratePaise &&
          other.priceUnitFactor == this.priceUnitFactor &&
          other.gstRateBp == this.gstRateBp &&
          other.lineTotalPaise == this.lineTotalPaise);
}

class PurchaseLinesCompanion extends UpdateCompanion<PurchaseLine> {
  final Value<String> id;
  final Value<String> shopId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> purchaseId;
  final Value<String> itemId;
  final Value<String?> variantId;
  final Value<String> unitName;
  final Value<String> qtyEntered;
  final Value<int> qtyBase;
  final Value<int> ratePaise;
  final Value<int> priceUnitFactor;
  final Value<int> gstRateBp;
  final Value<int> lineTotalPaise;
  final Value<int> rowid;
  const PurchaseLinesCompanion({
    this.id = const Value.absent(),
    this.shopId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.purchaseId = const Value.absent(),
    this.itemId = const Value.absent(),
    this.variantId = const Value.absent(),
    this.unitName = const Value.absent(),
    this.qtyEntered = const Value.absent(),
    this.qtyBase = const Value.absent(),
    this.ratePaise = const Value.absent(),
    this.priceUnitFactor = const Value.absent(),
    this.gstRateBp = const Value.absent(),
    this.lineTotalPaise = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PurchaseLinesCompanion.insert({
    required String id,
    required String shopId,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    required String purchaseId,
    required String itemId,
    this.variantId = const Value.absent(),
    required String unitName,
    required String qtyEntered,
    required int qtyBase,
    required int ratePaise,
    this.priceUnitFactor = const Value.absent(),
    this.gstRateBp = const Value.absent(),
    required int lineTotalPaise,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       shopId = Value(shopId),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       purchaseId = Value(purchaseId),
       itemId = Value(itemId),
       unitName = Value(unitName),
       qtyEntered = Value(qtyEntered),
       qtyBase = Value(qtyBase),
       ratePaise = Value(ratePaise),
       lineTotalPaise = Value(lineTotalPaise);
  static Insertable<PurchaseLine> custom({
    Expression<String>? id,
    Expression<String>? shopId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? purchaseId,
    Expression<String>? itemId,
    Expression<String>? variantId,
    Expression<String>? unitName,
    Expression<String>? qtyEntered,
    Expression<int>? qtyBase,
    Expression<int>? ratePaise,
    Expression<int>? priceUnitFactor,
    Expression<int>? gstRateBp,
    Expression<int>? lineTotalPaise,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (shopId != null) 'shop_id': shopId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (purchaseId != null) 'purchase_id': purchaseId,
      if (itemId != null) 'item_id': itemId,
      if (variantId != null) 'variant_id': variantId,
      if (unitName != null) 'unit_name': unitName,
      if (qtyEntered != null) 'qty_entered': qtyEntered,
      if (qtyBase != null) 'qty_base': qtyBase,
      if (ratePaise != null) 'rate_paise': ratePaise,
      if (priceUnitFactor != null) 'price_unit_factor': priceUnitFactor,
      if (gstRateBp != null) 'gst_rate_bp': gstRateBp,
      if (lineTotalPaise != null) 'line_total_paise': lineTotalPaise,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PurchaseLinesCompanion copyWith({
    Value<String>? id,
    Value<String>? shopId,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? purchaseId,
    Value<String>? itemId,
    Value<String?>? variantId,
    Value<String>? unitName,
    Value<String>? qtyEntered,
    Value<int>? qtyBase,
    Value<int>? ratePaise,
    Value<int>? priceUnitFactor,
    Value<int>? gstRateBp,
    Value<int>? lineTotalPaise,
    Value<int>? rowid,
  }) {
    return PurchaseLinesCompanion(
      id: id ?? this.id,
      shopId: shopId ?? this.shopId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      purchaseId: purchaseId ?? this.purchaseId,
      itemId: itemId ?? this.itemId,
      variantId: variantId ?? this.variantId,
      unitName: unitName ?? this.unitName,
      qtyEntered: qtyEntered ?? this.qtyEntered,
      qtyBase: qtyBase ?? this.qtyBase,
      ratePaise: ratePaise ?? this.ratePaise,
      priceUnitFactor: priceUnitFactor ?? this.priceUnitFactor,
      gstRateBp: gstRateBp ?? this.gstRateBp,
      lineTotalPaise: lineTotalPaise ?? this.lineTotalPaise,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (shopId.present) {
      map['shop_id'] = Variable<String>(shopId.value);
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
    if (purchaseId.present) {
      map['purchase_id'] = Variable<String>(purchaseId.value);
    }
    if (itemId.present) {
      map['item_id'] = Variable<String>(itemId.value);
    }
    if (variantId.present) {
      map['variant_id'] = Variable<String>(variantId.value);
    }
    if (unitName.present) {
      map['unit_name'] = Variable<String>(unitName.value);
    }
    if (qtyEntered.present) {
      map['qty_entered'] = Variable<String>(qtyEntered.value);
    }
    if (qtyBase.present) {
      map['qty_base'] = Variable<int>(qtyBase.value);
    }
    if (ratePaise.present) {
      map['rate_paise'] = Variable<int>(ratePaise.value);
    }
    if (priceUnitFactor.present) {
      map['price_unit_factor'] = Variable<int>(priceUnitFactor.value);
    }
    if (gstRateBp.present) {
      map['gst_rate_bp'] = Variable<int>(gstRateBp.value);
    }
    if (lineTotalPaise.present) {
      map['line_total_paise'] = Variable<int>(lineTotalPaise.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PurchaseLinesCompanion(')
          ..write('id: $id, ')
          ..write('shopId: $shopId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('purchaseId: $purchaseId, ')
          ..write('itemId: $itemId, ')
          ..write('variantId: $variantId, ')
          ..write('unitName: $unitName, ')
          ..write('qtyEntered: $qtyEntered, ')
          ..write('qtyBase: $qtyBase, ')
          ..write('ratePaise: $ratePaise, ')
          ..write('priceUnitFactor: $priceUnitFactor, ')
          ..write('gstRateBp: $gstRateBp, ')
          ..write('lineTotalPaise: $lineTotalPaise, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StockMovementsTable extends StockMovements
    with TableInfo<$StockMovementsTable, StockMovement> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StockMovementsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _shopIdMeta = const VerificationMeta('shopId');
  @override
  late final GeneratedColumn<String> shopId = GeneratedColumn<String>(
    'shop_id',
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
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<String> itemId = GeneratedColumn<String>(
    'item_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES items (id)',
    ),
  );
  static const VerificationMeta _variantIdMeta = const VerificationMeta(
    'variantId',
  );
  @override
  late final GeneratedColumn<String> variantId = GeneratedColumn<String>(
    'variant_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES item_variants (id)',
    ),
  );
  static const VerificationMeta _locationIdMeta = const VerificationMeta(
    'locationId',
  );
  @override
  late final GeneratedColumn<String> locationId = GeneratedColumn<String>(
    'location_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES locations (id)',
    ),
  );
  static const VerificationMeta _qtyBaseMeta = const VerificationMeta(
    'qtyBase',
  );
  @override
  late final GeneratedColumn<int> qtyBase = GeneratedColumn<int>(
    'qty_base',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _movementTypeMeta = const VerificationMeta(
    'movementType',
  );
  @override
  late final GeneratedColumn<String> movementType = GeneratedColumn<String>(
    'movement_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _refTypeMeta = const VerificationMeta(
    'refType',
  );
  @override
  late final GeneratedColumn<String> refType = GeneratedColumn<String>(
    'ref_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _refIdMeta = const VerificationMeta('refId');
  @override
  late final GeneratedColumn<String> refId = GeneratedColumn<String>(
    'ref_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tsMeta = const VerificationMeta('ts');
  @override
  late final GeneratedColumn<DateTime> ts = GeneratedColumn<DateTime>(
    'ts',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdByMeta = const VerificationMeta(
    'createdBy',
  );
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
    'created_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    shopId,
    createdAt,
    updatedAt,
    deletedAt,
    itemId,
    variantId,
    locationId,
    qtyBase,
    movementType,
    refType,
    refId,
    ts,
    createdBy,
    note,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'stock_movements';
  @override
  VerificationContext validateIntegrity(
    Insertable<StockMovement> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('shop_id')) {
      context.handle(
        _shopIdMeta,
        shopId.isAcceptableOrUnknown(data['shop_id']!, _shopIdMeta),
      );
    } else if (isInserting) {
      context.missing(_shopIdMeta);
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
    if (data.containsKey('item_id')) {
      context.handle(
        _itemIdMeta,
        itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta),
      );
    } else if (isInserting) {
      context.missing(_itemIdMeta);
    }
    if (data.containsKey('variant_id')) {
      context.handle(
        _variantIdMeta,
        variantId.isAcceptableOrUnknown(data['variant_id']!, _variantIdMeta),
      );
    }
    if (data.containsKey('location_id')) {
      context.handle(
        _locationIdMeta,
        locationId.isAcceptableOrUnknown(data['location_id']!, _locationIdMeta),
      );
    } else if (isInserting) {
      context.missing(_locationIdMeta);
    }
    if (data.containsKey('qty_base')) {
      context.handle(
        _qtyBaseMeta,
        qtyBase.isAcceptableOrUnknown(data['qty_base']!, _qtyBaseMeta),
      );
    } else if (isInserting) {
      context.missing(_qtyBaseMeta);
    }
    if (data.containsKey('movement_type')) {
      context.handle(
        _movementTypeMeta,
        movementType.isAcceptableOrUnknown(
          data['movement_type']!,
          _movementTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_movementTypeMeta);
    }
    if (data.containsKey('ref_type')) {
      context.handle(
        _refTypeMeta,
        refType.isAcceptableOrUnknown(data['ref_type']!, _refTypeMeta),
      );
    }
    if (data.containsKey('ref_id')) {
      context.handle(
        _refIdMeta,
        refId.isAcceptableOrUnknown(data['ref_id']!, _refIdMeta),
      );
    }
    if (data.containsKey('ts')) {
      context.handle(_tsMeta, ts.isAcceptableOrUnknown(data['ts']!, _tsMeta));
    } else if (isInserting) {
      context.missing(_tsMeta);
    }
    if (data.containsKey('created_by')) {
      context.handle(
        _createdByMeta,
        createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StockMovement map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StockMovement(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}id'],
          )!,
      shopId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}shop_id'],
          )!,
      createdAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}created_at'],
          )!,
      updatedAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}updated_at'],
          )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      itemId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}item_id'],
          )!,
      variantId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}variant_id'],
      ),
      locationId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}location_id'],
          )!,
      qtyBase:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}qty_base'],
          )!,
      movementType:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}movement_type'],
          )!,
      refType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ref_type'],
      ),
      refId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ref_id'],
      ),
      ts:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}ts'],
          )!,
      createdBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_by'],
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
    );
  }

  @override
  $StockMovementsTable createAlias(String alias) {
    return $StockMovementsTable(attachedDatabase, alias);
  }
}

class StockMovement extends DataClass implements Insertable<StockMovement> {
  final String id;
  final String shopId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String itemId;
  final String? variantId;
  final String locationId;

  /// Signed, in base units.
  final int qtyBase;

  /// purchase | sale | sale_return | purchase_return | transfer_in |
  /// transfer_out | adjustment | count
  final String movementType;
  final String? refType;
  final String? refId;
  final DateTime ts;
  final String? createdBy;

  /// Reason or remark, e.g. "Damaged", "Opening stock" (added in schema v2).
  final String? note;
  const StockMovement({
    required this.id,
    required this.shopId,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.itemId,
    this.variantId,
    required this.locationId,
    required this.qtyBase,
    required this.movementType,
    this.refType,
    this.refId,
    required this.ts,
    this.createdBy,
    this.note,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['shop_id'] = Variable<String>(shopId);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['item_id'] = Variable<String>(itemId);
    if (!nullToAbsent || variantId != null) {
      map['variant_id'] = Variable<String>(variantId);
    }
    map['location_id'] = Variable<String>(locationId);
    map['qty_base'] = Variable<int>(qtyBase);
    map['movement_type'] = Variable<String>(movementType);
    if (!nullToAbsent || refType != null) {
      map['ref_type'] = Variable<String>(refType);
    }
    if (!nullToAbsent || refId != null) {
      map['ref_id'] = Variable<String>(refId);
    }
    map['ts'] = Variable<DateTime>(ts);
    if (!nullToAbsent || createdBy != null) {
      map['created_by'] = Variable<String>(createdBy);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    return map;
  }

  StockMovementsCompanion toCompanion(bool nullToAbsent) {
    return StockMovementsCompanion(
      id: Value(id),
      shopId: Value(shopId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt:
          deletedAt == null && nullToAbsent
              ? const Value.absent()
              : Value(deletedAt),
      itemId: Value(itemId),
      variantId:
          variantId == null && nullToAbsent
              ? const Value.absent()
              : Value(variantId),
      locationId: Value(locationId),
      qtyBase: Value(qtyBase),
      movementType: Value(movementType),
      refType:
          refType == null && nullToAbsent
              ? const Value.absent()
              : Value(refType),
      refId:
          refId == null && nullToAbsent ? const Value.absent() : Value(refId),
      ts: Value(ts),
      createdBy:
          createdBy == null && nullToAbsent
              ? const Value.absent()
              : Value(createdBy),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
    );
  }

  factory StockMovement.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StockMovement(
      id: serializer.fromJson<String>(json['id']),
      shopId: serializer.fromJson<String>(json['shopId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      itemId: serializer.fromJson<String>(json['itemId']),
      variantId: serializer.fromJson<String?>(json['variantId']),
      locationId: serializer.fromJson<String>(json['locationId']),
      qtyBase: serializer.fromJson<int>(json['qtyBase']),
      movementType: serializer.fromJson<String>(json['movementType']),
      refType: serializer.fromJson<String?>(json['refType']),
      refId: serializer.fromJson<String?>(json['refId']),
      ts: serializer.fromJson<DateTime>(json['ts']),
      createdBy: serializer.fromJson<String?>(json['createdBy']),
      note: serializer.fromJson<String?>(json['note']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'shopId': serializer.toJson<String>(shopId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'itemId': serializer.toJson<String>(itemId),
      'variantId': serializer.toJson<String?>(variantId),
      'locationId': serializer.toJson<String>(locationId),
      'qtyBase': serializer.toJson<int>(qtyBase),
      'movementType': serializer.toJson<String>(movementType),
      'refType': serializer.toJson<String?>(refType),
      'refId': serializer.toJson<String?>(refId),
      'ts': serializer.toJson<DateTime>(ts),
      'createdBy': serializer.toJson<String?>(createdBy),
      'note': serializer.toJson<String?>(note),
    };
  }

  StockMovement copyWith({
    String? id,
    String? shopId,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? itemId,
    Value<String?> variantId = const Value.absent(),
    String? locationId,
    int? qtyBase,
    String? movementType,
    Value<String?> refType = const Value.absent(),
    Value<String?> refId = const Value.absent(),
    DateTime? ts,
    Value<String?> createdBy = const Value.absent(),
    Value<String?> note = const Value.absent(),
  }) => StockMovement(
    id: id ?? this.id,
    shopId: shopId ?? this.shopId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    itemId: itemId ?? this.itemId,
    variantId: variantId.present ? variantId.value : this.variantId,
    locationId: locationId ?? this.locationId,
    qtyBase: qtyBase ?? this.qtyBase,
    movementType: movementType ?? this.movementType,
    refType: refType.present ? refType.value : this.refType,
    refId: refId.present ? refId.value : this.refId,
    ts: ts ?? this.ts,
    createdBy: createdBy.present ? createdBy.value : this.createdBy,
    note: note.present ? note.value : this.note,
  );
  StockMovement copyWithCompanion(StockMovementsCompanion data) {
    return StockMovement(
      id: data.id.present ? data.id.value : this.id,
      shopId: data.shopId.present ? data.shopId.value : this.shopId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      variantId: data.variantId.present ? data.variantId.value : this.variantId,
      locationId:
          data.locationId.present ? data.locationId.value : this.locationId,
      qtyBase: data.qtyBase.present ? data.qtyBase.value : this.qtyBase,
      movementType:
          data.movementType.present
              ? data.movementType.value
              : this.movementType,
      refType: data.refType.present ? data.refType.value : this.refType,
      refId: data.refId.present ? data.refId.value : this.refId,
      ts: data.ts.present ? data.ts.value : this.ts,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      note: data.note.present ? data.note.value : this.note,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StockMovement(')
          ..write('id: $id, ')
          ..write('shopId: $shopId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('itemId: $itemId, ')
          ..write('variantId: $variantId, ')
          ..write('locationId: $locationId, ')
          ..write('qtyBase: $qtyBase, ')
          ..write('movementType: $movementType, ')
          ..write('refType: $refType, ')
          ..write('refId: $refId, ')
          ..write('ts: $ts, ')
          ..write('createdBy: $createdBy, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    shopId,
    createdAt,
    updatedAt,
    deletedAt,
    itemId,
    variantId,
    locationId,
    qtyBase,
    movementType,
    refType,
    refId,
    ts,
    createdBy,
    note,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StockMovement &&
          other.id == this.id &&
          other.shopId == this.shopId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.itemId == this.itemId &&
          other.variantId == this.variantId &&
          other.locationId == this.locationId &&
          other.qtyBase == this.qtyBase &&
          other.movementType == this.movementType &&
          other.refType == this.refType &&
          other.refId == this.refId &&
          other.ts == this.ts &&
          other.createdBy == this.createdBy &&
          other.note == this.note);
}

class StockMovementsCompanion extends UpdateCompanion<StockMovement> {
  final Value<String> id;
  final Value<String> shopId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> itemId;
  final Value<String?> variantId;
  final Value<String> locationId;
  final Value<int> qtyBase;
  final Value<String> movementType;
  final Value<String?> refType;
  final Value<String?> refId;
  final Value<DateTime> ts;
  final Value<String?> createdBy;
  final Value<String?> note;
  final Value<int> rowid;
  const StockMovementsCompanion({
    this.id = const Value.absent(),
    this.shopId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.itemId = const Value.absent(),
    this.variantId = const Value.absent(),
    this.locationId = const Value.absent(),
    this.qtyBase = const Value.absent(),
    this.movementType = const Value.absent(),
    this.refType = const Value.absent(),
    this.refId = const Value.absent(),
    this.ts = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StockMovementsCompanion.insert({
    required String id,
    required String shopId,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    required String itemId,
    this.variantId = const Value.absent(),
    required String locationId,
    required int qtyBase,
    required String movementType,
    this.refType = const Value.absent(),
    this.refId = const Value.absent(),
    required DateTime ts,
    this.createdBy = const Value.absent(),
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       shopId = Value(shopId),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       itemId = Value(itemId),
       locationId = Value(locationId),
       qtyBase = Value(qtyBase),
       movementType = Value(movementType),
       ts = Value(ts);
  static Insertable<StockMovement> custom({
    Expression<String>? id,
    Expression<String>? shopId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? itemId,
    Expression<String>? variantId,
    Expression<String>? locationId,
    Expression<int>? qtyBase,
    Expression<String>? movementType,
    Expression<String>? refType,
    Expression<String>? refId,
    Expression<DateTime>? ts,
    Expression<String>? createdBy,
    Expression<String>? note,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (shopId != null) 'shop_id': shopId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (itemId != null) 'item_id': itemId,
      if (variantId != null) 'variant_id': variantId,
      if (locationId != null) 'location_id': locationId,
      if (qtyBase != null) 'qty_base': qtyBase,
      if (movementType != null) 'movement_type': movementType,
      if (refType != null) 'ref_type': refType,
      if (refId != null) 'ref_id': refId,
      if (ts != null) 'ts': ts,
      if (createdBy != null) 'created_by': createdBy,
      if (note != null) 'note': note,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StockMovementsCompanion copyWith({
    Value<String>? id,
    Value<String>? shopId,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? itemId,
    Value<String?>? variantId,
    Value<String>? locationId,
    Value<int>? qtyBase,
    Value<String>? movementType,
    Value<String?>? refType,
    Value<String?>? refId,
    Value<DateTime>? ts,
    Value<String?>? createdBy,
    Value<String?>? note,
    Value<int>? rowid,
  }) {
    return StockMovementsCompanion(
      id: id ?? this.id,
      shopId: shopId ?? this.shopId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      itemId: itemId ?? this.itemId,
      variantId: variantId ?? this.variantId,
      locationId: locationId ?? this.locationId,
      qtyBase: qtyBase ?? this.qtyBase,
      movementType: movementType ?? this.movementType,
      refType: refType ?? this.refType,
      refId: refId ?? this.refId,
      ts: ts ?? this.ts,
      createdBy: createdBy ?? this.createdBy,
      note: note ?? this.note,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (shopId.present) {
      map['shop_id'] = Variable<String>(shopId.value);
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
    if (itemId.present) {
      map['item_id'] = Variable<String>(itemId.value);
    }
    if (variantId.present) {
      map['variant_id'] = Variable<String>(variantId.value);
    }
    if (locationId.present) {
      map['location_id'] = Variable<String>(locationId.value);
    }
    if (qtyBase.present) {
      map['qty_base'] = Variable<int>(qtyBase.value);
    }
    if (movementType.present) {
      map['movement_type'] = Variable<String>(movementType.value);
    }
    if (refType.present) {
      map['ref_type'] = Variable<String>(refType.value);
    }
    if (refId.present) {
      map['ref_id'] = Variable<String>(refId.value);
    }
    if (ts.present) {
      map['ts'] = Variable<DateTime>(ts.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StockMovementsCompanion(')
          ..write('id: $id, ')
          ..write('shopId: $shopId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('itemId: $itemId, ')
          ..write('variantId: $variantId, ')
          ..write('locationId: $locationId, ')
          ..write('qtyBase: $qtyBase, ')
          ..write('movementType: $movementType, ')
          ..write('refType: $refType, ')
          ..write('refId: $refId, ')
          ..write('ts: $ts, ')
          ..write('createdBy: $createdBy, ')
          ..write('note: $note, ')
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
  static const VerificationMeta _shopIdMeta = const VerificationMeta('shopId');
  @override
  late final GeneratedColumn<String> shopId = GeneratedColumn<String>(
    'shop_id',
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
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
  static const VerificationMeta _entityMeta = const VerificationMeta('entity');
  @override
  late final GeneratedColumn<String> entity = GeneratedColumn<String>(
    'entity',
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
  static const VerificationMeta _beforeJsonMeta = const VerificationMeta(
    'beforeJson',
  );
  @override
  late final GeneratedColumn<String> beforeJson = GeneratedColumn<String>(
    'before_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _afterJsonMeta = const VerificationMeta(
    'afterJson',
  );
  @override
  late final GeneratedColumn<String> afterJson = GeneratedColumn<String>(
    'after_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tsMeta = const VerificationMeta('ts');
  @override
  late final GeneratedColumn<DateTime> ts = GeneratedColumn<DateTime>(
    'ts',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    shopId,
    createdAt,
    updatedAt,
    deletedAt,
    userId,
    action,
    entity,
    entityId,
    beforeJson,
    afterJson,
    ts,
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
    if (data.containsKey('shop_id')) {
      context.handle(
        _shopIdMeta,
        shopId.isAcceptableOrUnknown(data['shop_id']!, _shopIdMeta),
      );
    } else if (isInserting) {
      context.missing(_shopIdMeta);
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
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    }
    if (data.containsKey('action')) {
      context.handle(
        _actionMeta,
        action.isAcceptableOrUnknown(data['action']!, _actionMeta),
      );
    } else if (isInserting) {
      context.missing(_actionMeta);
    }
    if (data.containsKey('entity')) {
      context.handle(
        _entityMeta,
        entity.isAcceptableOrUnknown(data['entity']!, _entityMeta),
      );
    } else if (isInserting) {
      context.missing(_entityMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('before_json')) {
      context.handle(
        _beforeJsonMeta,
        beforeJson.isAcceptableOrUnknown(data['before_json']!, _beforeJsonMeta),
      );
    }
    if (data.containsKey('after_json')) {
      context.handle(
        _afterJsonMeta,
        afterJson.isAcceptableOrUnknown(data['after_json']!, _afterJsonMeta),
      );
    }
    if (data.containsKey('ts')) {
      context.handle(_tsMeta, ts.isAcceptableOrUnknown(data['ts']!, _tsMeta));
    } else if (isInserting) {
      context.missing(_tsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AuditLogData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AuditLogData(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}id'],
          )!,
      shopId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}shop_id'],
          )!,
      createdAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}created_at'],
          )!,
      updatedAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}updated_at'],
          )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      ),
      action:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}action'],
          )!,
      entity:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}entity'],
          )!,
      entityId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}entity_id'],
          )!,
      beforeJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}before_json'],
      ),
      afterJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}after_json'],
      ),
      ts:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}ts'],
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
  final String shopId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String? userId;

  /// e.g. discount | price_override | edit | delete
  final String action;
  final String entity;
  final String entityId;
  final String? beforeJson;
  final String? afterJson;
  final DateTime ts;
  const AuditLogData({
    required this.id,
    required this.shopId,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.userId,
    required this.action,
    required this.entity,
    required this.entityId,
    this.beforeJson,
    this.afterJson,
    required this.ts,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['shop_id'] = Variable<String>(shopId);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    if (!nullToAbsent || userId != null) {
      map['user_id'] = Variable<String>(userId);
    }
    map['action'] = Variable<String>(action);
    map['entity'] = Variable<String>(entity);
    map['entity_id'] = Variable<String>(entityId);
    if (!nullToAbsent || beforeJson != null) {
      map['before_json'] = Variable<String>(beforeJson);
    }
    if (!nullToAbsent || afterJson != null) {
      map['after_json'] = Variable<String>(afterJson);
    }
    map['ts'] = Variable<DateTime>(ts);
    return map;
  }

  AuditLogCompanion toCompanion(bool nullToAbsent) {
    return AuditLogCompanion(
      id: Value(id),
      shopId: Value(shopId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt:
          deletedAt == null && nullToAbsent
              ? const Value.absent()
              : Value(deletedAt),
      userId:
          userId == null && nullToAbsent ? const Value.absent() : Value(userId),
      action: Value(action),
      entity: Value(entity),
      entityId: Value(entityId),
      beforeJson:
          beforeJson == null && nullToAbsent
              ? const Value.absent()
              : Value(beforeJson),
      afterJson:
          afterJson == null && nullToAbsent
              ? const Value.absent()
              : Value(afterJson),
      ts: Value(ts),
    );
  }

  factory AuditLogData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AuditLogData(
      id: serializer.fromJson<String>(json['id']),
      shopId: serializer.fromJson<String>(json['shopId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      userId: serializer.fromJson<String?>(json['userId']),
      action: serializer.fromJson<String>(json['action']),
      entity: serializer.fromJson<String>(json['entity']),
      entityId: serializer.fromJson<String>(json['entityId']),
      beforeJson: serializer.fromJson<String?>(json['beforeJson']),
      afterJson: serializer.fromJson<String?>(json['afterJson']),
      ts: serializer.fromJson<DateTime>(json['ts']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'shopId': serializer.toJson<String>(shopId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'userId': serializer.toJson<String?>(userId),
      'action': serializer.toJson<String>(action),
      'entity': serializer.toJson<String>(entity),
      'entityId': serializer.toJson<String>(entityId),
      'beforeJson': serializer.toJson<String?>(beforeJson),
      'afterJson': serializer.toJson<String?>(afterJson),
      'ts': serializer.toJson<DateTime>(ts),
    };
  }

  AuditLogData copyWith({
    String? id,
    String? shopId,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    Value<String?> userId = const Value.absent(),
    String? action,
    String? entity,
    String? entityId,
    Value<String?> beforeJson = const Value.absent(),
    Value<String?> afterJson = const Value.absent(),
    DateTime? ts,
  }) => AuditLogData(
    id: id ?? this.id,
    shopId: shopId ?? this.shopId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    userId: userId.present ? userId.value : this.userId,
    action: action ?? this.action,
    entity: entity ?? this.entity,
    entityId: entityId ?? this.entityId,
    beforeJson: beforeJson.present ? beforeJson.value : this.beforeJson,
    afterJson: afterJson.present ? afterJson.value : this.afterJson,
    ts: ts ?? this.ts,
  );
  AuditLogData copyWithCompanion(AuditLogCompanion data) {
    return AuditLogData(
      id: data.id.present ? data.id.value : this.id,
      shopId: data.shopId.present ? data.shopId.value : this.shopId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      userId: data.userId.present ? data.userId.value : this.userId,
      action: data.action.present ? data.action.value : this.action,
      entity: data.entity.present ? data.entity.value : this.entity,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      beforeJson:
          data.beforeJson.present ? data.beforeJson.value : this.beforeJson,
      afterJson: data.afterJson.present ? data.afterJson.value : this.afterJson,
      ts: data.ts.present ? data.ts.value : this.ts,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AuditLogData(')
          ..write('id: $id, ')
          ..write('shopId: $shopId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('userId: $userId, ')
          ..write('action: $action, ')
          ..write('entity: $entity, ')
          ..write('entityId: $entityId, ')
          ..write('beforeJson: $beforeJson, ')
          ..write('afterJson: $afterJson, ')
          ..write('ts: $ts')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    shopId,
    createdAt,
    updatedAt,
    deletedAt,
    userId,
    action,
    entity,
    entityId,
    beforeJson,
    afterJson,
    ts,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AuditLogData &&
          other.id == this.id &&
          other.shopId == this.shopId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.userId == this.userId &&
          other.action == this.action &&
          other.entity == this.entity &&
          other.entityId == this.entityId &&
          other.beforeJson == this.beforeJson &&
          other.afterJson == this.afterJson &&
          other.ts == this.ts);
}

class AuditLogCompanion extends UpdateCompanion<AuditLogData> {
  final Value<String> id;
  final Value<String> shopId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String?> userId;
  final Value<String> action;
  final Value<String> entity;
  final Value<String> entityId;
  final Value<String?> beforeJson;
  final Value<String?> afterJson;
  final Value<DateTime> ts;
  final Value<int> rowid;
  const AuditLogCompanion({
    this.id = const Value.absent(),
    this.shopId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.userId = const Value.absent(),
    this.action = const Value.absent(),
    this.entity = const Value.absent(),
    this.entityId = const Value.absent(),
    this.beforeJson = const Value.absent(),
    this.afterJson = const Value.absent(),
    this.ts = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AuditLogCompanion.insert({
    required String id,
    required String shopId,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.userId = const Value.absent(),
    required String action,
    required String entity,
    required String entityId,
    this.beforeJson = const Value.absent(),
    this.afterJson = const Value.absent(),
    required DateTime ts,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       shopId = Value(shopId),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       action = Value(action),
       entity = Value(entity),
       entityId = Value(entityId),
       ts = Value(ts);
  static Insertable<AuditLogData> custom({
    Expression<String>? id,
    Expression<String>? shopId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? userId,
    Expression<String>? action,
    Expression<String>? entity,
    Expression<String>? entityId,
    Expression<String>? beforeJson,
    Expression<String>? afterJson,
    Expression<DateTime>? ts,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (shopId != null) 'shop_id': shopId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (userId != null) 'user_id': userId,
      if (action != null) 'action': action,
      if (entity != null) 'entity': entity,
      if (entityId != null) 'entity_id': entityId,
      if (beforeJson != null) 'before_json': beforeJson,
      if (afterJson != null) 'after_json': afterJson,
      if (ts != null) 'ts': ts,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AuditLogCompanion copyWith({
    Value<String>? id,
    Value<String>? shopId,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String?>? userId,
    Value<String>? action,
    Value<String>? entity,
    Value<String>? entityId,
    Value<String?>? beforeJson,
    Value<String?>? afterJson,
    Value<DateTime>? ts,
    Value<int>? rowid,
  }) {
    return AuditLogCompanion(
      id: id ?? this.id,
      shopId: shopId ?? this.shopId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      userId: userId ?? this.userId,
      action: action ?? this.action,
      entity: entity ?? this.entity,
      entityId: entityId ?? this.entityId,
      beforeJson: beforeJson ?? this.beforeJson,
      afterJson: afterJson ?? this.afterJson,
      ts: ts ?? this.ts,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (shopId.present) {
      map['shop_id'] = Variable<String>(shopId.value);
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
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (action.present) {
      map['action'] = Variable<String>(action.value);
    }
    if (entity.present) {
      map['entity'] = Variable<String>(entity.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (beforeJson.present) {
      map['before_json'] = Variable<String>(beforeJson.value);
    }
    if (afterJson.present) {
      map['after_json'] = Variable<String>(afterJson.value);
    }
    if (ts.present) {
      map['ts'] = Variable<DateTime>(ts.value);
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
          ..write('shopId: $shopId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('userId: $userId, ')
          ..write('action: $action, ')
          ..write('entity: $entity, ')
          ..write('entityId: $entityId, ')
          ..write('beforeJson: $beforeJson, ')
          ..write('afterJson: $afterJson, ')
          ..write('ts: $ts, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppSettingsTable extends AppSettings
    with TableInfo<$AppSettingsTable, AppSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _shopIdMeta = const VerificationMeta('shopId');
  @override
  late final GeneratedColumn<String> shopId = GeneratedColumn<String>(
    'shop_id',
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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    shopId,
    createdAt,
    updatedAt,
    deletedAt,
    key,
    value,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppSetting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('shop_id')) {
      context.handle(
        _shopIdMeta,
        shopId.isAcceptableOrUnknown(data['shop_id']!, _shopIdMeta),
      );
    } else if (isInserting) {
      context.missing(_shopIdMeta);
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {shopId, key},
  ];
  @override
  AppSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSetting(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}id'],
          )!,
      shopId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}shop_id'],
          )!,
      createdAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}created_at'],
          )!,
      updatedAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}updated_at'],
          )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      key:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}key'],
          )!,
      value:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}value'],
          )!,
    );
  }

  @override
  $AppSettingsTable createAlias(String alias) {
    return $AppSettingsTable(attachedDatabase, alias);
  }
}

class AppSetting extends DataClass implements Insertable<AppSetting> {
  final String id;
  final String shopId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String key;
  final String value;
  const AppSetting({
    required this.id,
    required this.shopId,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.key,
    required this.value,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['shop_id'] = Variable<String>(shopId);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  AppSettingsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsCompanion(
      id: Value(id),
      shopId: Value(shopId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt:
          deletedAt == null && nullToAbsent
              ? const Value.absent()
              : Value(deletedAt),
      key: Value(key),
      value: Value(value),
    );
  }

  factory AppSetting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSetting(
      id: serializer.fromJson<String>(json['id']),
      shopId: serializer.fromJson<String>(json['shopId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'shopId': serializer.toJson<String>(shopId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  AppSetting copyWith({
    String? id,
    String? shopId,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? key,
    String? value,
  }) => AppSetting(
    id: id ?? this.id,
    shopId: shopId ?? this.shopId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    key: key ?? this.key,
    value: value ?? this.value,
  );
  AppSetting copyWithCompanion(AppSettingsCompanion data) {
    return AppSetting(
      id: data.id.present ? data.id.value : this.id,
      shopId: data.shopId.present ? data.shopId.value : this.shopId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSetting(')
          ..write('id: $id, ')
          ..write('shopId: $shopId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, shopId, createdAt, updatedAt, deletedAt, key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSetting &&
          other.id == this.id &&
          other.shopId == this.shopId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.key == this.key &&
          other.value == this.value);
}

class AppSettingsCompanion extends UpdateCompanion<AppSetting> {
  final Value<String> id;
  final Value<String> shopId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const AppSettingsCompanion({
    this.id = const Value.absent(),
    this.shopId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    required String id,
    required String shopId,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       shopId = Value(shopId),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       key = Value(key),
       value = Value(value);
  static Insertable<AppSetting> custom({
    Expression<String>? id,
    Expression<String>? shopId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (shopId != null) 'shop_id': shopId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppSettingsCompanion copyWith({
    Value<String>? id,
    Value<String>? shopId,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return AppSettingsCompanion(
      id: id ?? this.id,
      shopId: shopId ?? this.shopId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (shopId.present) {
      map['shop_id'] = Variable<String>(shopId.value);
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
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsCompanion(')
          ..write('id: $id, ')
          ..write('shopId: $shopId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ShopsTable shops = $ShopsTable(this);
  late final $UsersTable users = $UsersTable(this);
  late final $DevicesTable devices = $DevicesTable(this);
  late final $LocationsTable locations = $LocationsTable(this);
  late final $OutboxTable outbox = $OutboxTable(this);
  late final $ItemsTable items = $ItemsTable(this);
  late final $ItemUnitsTable itemUnits = $ItemUnitsTable(this);
  late final $ItemVariantsTable itemVariants = $ItemVariantsTable(this);
  late final $ItemPricesTable itemPrices = $ItemPricesTable(this);
  late final $ItemCostsTable itemCosts = $ItemCostsTable(this);
  late final $PartiesTable parties = $PartiesTable(this);
  late final $LedgerEntriesTable ledgerEntries = $LedgerEntriesTable(this);
  late final $InvoicesTable invoices = $InvoicesTable(this);
  late final $InvoiceLinesTable invoiceLines = $InvoiceLinesTable(this);
  late final $InvoicePaymentsTable invoicePayments = $InvoicePaymentsTable(
    this,
  );
  late final $SalesReturnsTable salesReturns = $SalesReturnsTable(this);
  late final $SalesReturnLinesTable salesReturnLines = $SalesReturnLinesTable(
    this,
  );
  late final $PurchasesTable purchases = $PurchasesTable(this);
  late final $PurchaseLinesTable purchaseLines = $PurchaseLinesTable(this);
  late final $StockMovementsTable stockMovements = $StockMovementsTable(this);
  late final $AuditLogTable auditLog = $AuditLogTable(this);
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  late final Index itemsName = Index(
    'items_name',
    'CREATE INDEX items_name ON items (name)',
  );
  late final Index itemVariantsBarcode = Index(
    'item_variants_barcode',
    'CREATE INDEX item_variants_barcode ON item_variants (barcode)',
  );
  late final Index ledgerEntriesParty = Index(
    'ledger_entries_party',
    'CREATE INDEX ledger_entries_party ON ledger_entries (party_id)',
  );
  late final Index invoicesDate = Index(
    'invoices_date',
    'CREATE INDEX invoices_date ON invoices (date)',
  );
  late final Index stockMovementsItem = Index(
    'stock_movements_item',
    'CREATE INDEX stock_movements_item ON stock_movements (item_id)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    shops,
    users,
    devices,
    locations,
    outbox,
    items,
    itemUnits,
    itemVariants,
    itemPrices,
    itemCosts,
    parties,
    ledgerEntries,
    invoices,
    invoiceLines,
    invoicePayments,
    salesReturns,
    salesReturnLines,
    purchases,
    purchaseLines,
    stockMovements,
    auditLog,
    appSettings,
    itemsName,
    itemVariantsBarcode,
    ledgerEntriesParty,
    invoicesDate,
    stockMovementsItem,
  ];
}

typedef $$ShopsTableCreateCompanionBuilder =
    ShopsCompanion Function({
      required String id,
      required String shopId,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      required String name,
      Value<String?> gstin,
      Value<String?> address,
      Value<String?> stateCode,
      Value<String?> phone,
      Value<String?> terms,
      Value<int> rowid,
    });
typedef $$ShopsTableUpdateCompanionBuilder =
    ShopsCompanion Function({
      Value<String> id,
      Value<String> shopId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String> name,
      Value<String?> gstin,
      Value<String?> address,
      Value<String?> stateCode,
      Value<String?> phone,
      Value<String?> terms,
      Value<int> rowid,
    });

class $$ShopsTableFilterComposer extends Composer<_$AppDatabase, $ShopsTable> {
  $$ShopsTableFilterComposer({
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

  ColumnFilters<String> get shopId => $composableBuilder(
    column: $table.shopId,
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get gstin => $composableBuilder(
    column: $table.gstin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get stateCode => $composableBuilder(
    column: $table.stateCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get terms => $composableBuilder(
    column: $table.terms,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ShopsTableOrderingComposer
    extends Composer<_$AppDatabase, $ShopsTable> {
  $$ShopsTableOrderingComposer({
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

  ColumnOrderings<String> get shopId => $composableBuilder(
    column: $table.shopId,
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get gstin => $composableBuilder(
    column: $table.gstin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get stateCode => $composableBuilder(
    column: $table.stateCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get terms => $composableBuilder(
    column: $table.terms,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ShopsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ShopsTable> {
  $$ShopsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get shopId =>
      $composableBuilder(column: $table.shopId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get gstin =>
      $composableBuilder(column: $table.gstin, builder: (column) => column);

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<String> get stateCode =>
      $composableBuilder(column: $table.stateCode, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get terms =>
      $composableBuilder(column: $table.terms, builder: (column) => column);
}

class $$ShopsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ShopsTable,
          Shop,
          $$ShopsTableFilterComposer,
          $$ShopsTableOrderingComposer,
          $$ShopsTableAnnotationComposer,
          $$ShopsTableCreateCompanionBuilder,
          $$ShopsTableUpdateCompanionBuilder,
          (Shop, BaseReferences<_$AppDatabase, $ShopsTable, Shop>),
          Shop,
          PrefetchHooks Function()
        > {
  $$ShopsTableTableManager(_$AppDatabase db, $ShopsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$ShopsTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$ShopsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$ShopsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> shopId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> gstin = const Value.absent(),
                Value<String?> address = const Value.absent(),
                Value<String?> stateCode = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String?> terms = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ShopsCompanion(
                id: id,
                shopId: shopId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                name: name,
                gstin: gstin,
                address: address,
                stateCode: stateCode,
                phone: phone,
                terms: terms,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String shopId,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                required String name,
                Value<String?> gstin = const Value.absent(),
                Value<String?> address = const Value.absent(),
                Value<String?> stateCode = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String?> terms = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ShopsCompanion.insert(
                id: id,
                shopId: shopId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                name: name,
                gstin: gstin,
                address: address,
                stateCode: stateCode,
                phone: phone,
                terms: terms,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ShopsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ShopsTable,
      Shop,
      $$ShopsTableFilterComposer,
      $$ShopsTableOrderingComposer,
      $$ShopsTableAnnotationComposer,
      $$ShopsTableCreateCompanionBuilder,
      $$ShopsTableUpdateCompanionBuilder,
      (Shop, BaseReferences<_$AppDatabase, $ShopsTable, Shop>),
      Shop,
      PrefetchHooks Function()
    >;
typedef $$UsersTableCreateCompanionBuilder =
    UsersCompanion Function({
      required String id,
      required String shopId,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      required String name,
      Value<String?> phone,
      required String role,
      Value<String?> pinHash,
      Value<bool> active,
      Value<int> rowid,
    });
typedef $$UsersTableUpdateCompanionBuilder =
    UsersCompanion Function({
      Value<String> id,
      Value<String> shopId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String> name,
      Value<String?> phone,
      Value<String> role,
      Value<String?> pinHash,
      Value<bool> active,
      Value<int> rowid,
    });

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

  ColumnFilters<String> get shopId => $composableBuilder(
    column: $table.shopId,
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pinHash => $composableBuilder(
    column: $table.pinHash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get active => $composableBuilder(
    column: $table.active,
    builder: (column) => ColumnFilters(column),
  );
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

  ColumnOrderings<String> get shopId => $composableBuilder(
    column: $table.shopId,
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pinHash => $composableBuilder(
    column: $table.pinHash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get active => $composableBuilder(
    column: $table.active,
    builder: (column) => ColumnOrderings(column),
  );
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

  GeneratedColumn<String> get shopId =>
      $composableBuilder(column: $table.shopId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<String> get pinHash =>
      $composableBuilder(column: $table.pinHash, builder: (column) => column);

  GeneratedColumn<bool> get active =>
      $composableBuilder(column: $table.active, builder: (column) => column);
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
          (User, BaseReferences<_$AppDatabase, $UsersTable, User>),
          User,
          PrefetchHooks Function()
        > {
  $$UsersTableTableManager(_$AppDatabase db, $UsersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$UsersTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$UsersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$UsersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> shopId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<String?> pinHash = const Value.absent(),
                Value<bool> active = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UsersCompanion(
                id: id,
                shopId: shopId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                name: name,
                phone: phone,
                role: role,
                pinHash: pinHash,
                active: active,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String shopId,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                required String name,
                Value<String?> phone = const Value.absent(),
                required String role,
                Value<String?> pinHash = const Value.absent(),
                Value<bool> active = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UsersCompanion.insert(
                id: id,
                shopId: shopId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                name: name,
                phone: phone,
                role: role,
                pinHash: pinHash,
                active: active,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
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
      (User, BaseReferences<_$AppDatabase, $UsersTable, User>),
      User,
      PrefetchHooks Function()
    >;
typedef $$DevicesTableCreateCompanionBuilder =
    DevicesCompanion Function({
      required String id,
      required String shopId,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<String?> userId,
      required String label,
      required String invoiceSeriesPrefix,
      Value<int> rowid,
    });
typedef $$DevicesTableUpdateCompanionBuilder =
    DevicesCompanion Function({
      Value<String> id,
      Value<String> shopId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String?> userId,
      Value<String> label,
      Value<String> invoiceSeriesPrefix,
      Value<int> rowid,
    });

final class $$DevicesTableReferences
    extends BaseReferences<_$AppDatabase, $DevicesTable, Device> {
  $$DevicesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$InvoicesTable, List<Invoice>> _invoicesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.invoices,
    aliasName: $_aliasNameGenerator(db.devices.id, db.invoices.deviceId),
  );

  $$InvoicesTableProcessedTableManager get invoicesRefs {
    final manager = $$InvoicesTableTableManager(
      $_db,
      $_db.invoices,
    ).filter((f) => f.deviceId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_invoicesRefsTable($_db));
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
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get shopId => $composableBuilder(
    column: $table.shopId,
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

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get invoiceSeriesPrefix => $composableBuilder(
    column: $table.invoiceSeriesPrefix,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> invoicesRefs(
    Expression<bool> Function($$InvoicesTableFilterComposer f) f,
  ) {
    final $$InvoicesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.invoices,
      getReferencedColumn: (t) => t.deviceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InvoicesTableFilterComposer(
            $db: $db,
            $table: $db.invoices,
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
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get shopId => $composableBuilder(
    column: $table.shopId,
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

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get invoiceSeriesPrefix => $composableBuilder(
    column: $table.invoiceSeriesPrefix,
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
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get shopId =>
      $composableBuilder(column: $table.shopId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<String> get invoiceSeriesPrefix => $composableBuilder(
    column: $table.invoiceSeriesPrefix,
    builder: (column) => column,
  );

  Expression<T> invoicesRefs<T extends Object>(
    Expression<T> Function($$InvoicesTableAnnotationComposer a) f,
  ) {
    final $$InvoicesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.invoices,
      getReferencedColumn: (t) => t.deviceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InvoicesTableAnnotationComposer(
            $db: $db,
            $table: $db.invoices,
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
          Device,
          $$DevicesTableFilterComposer,
          $$DevicesTableOrderingComposer,
          $$DevicesTableAnnotationComposer,
          $$DevicesTableCreateCompanionBuilder,
          $$DevicesTableUpdateCompanionBuilder,
          (Device, $$DevicesTableReferences),
          Device,
          PrefetchHooks Function({bool invoicesRefs})
        > {
  $$DevicesTableTableManager(_$AppDatabase db, $DevicesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$DevicesTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$DevicesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$DevicesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> shopId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String?> userId = const Value.absent(),
                Value<String> label = const Value.absent(),
                Value<String> invoiceSeriesPrefix = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DevicesCompanion(
                id: id,
                shopId: shopId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                userId: userId,
                label: label,
                invoiceSeriesPrefix: invoiceSeriesPrefix,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String shopId,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String?> userId = const Value.absent(),
                required String label,
                required String invoiceSeriesPrefix,
                Value<int> rowid = const Value.absent(),
              }) => DevicesCompanion.insert(
                id: id,
                shopId: shopId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                userId: userId,
                label: label,
                invoiceSeriesPrefix: invoiceSeriesPrefix,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          $$DevicesTableReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: ({invoicesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (invoicesRefs) db.invoices],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (invoicesRefs)
                    await $_getPrefetchedData<Device, $DevicesTable, Invoice>(
                      currentTable: table,
                      referencedTable: $$DevicesTableReferences
                          ._invoicesRefsTable(db),
                      managerFromTypedResult:
                          (p0) =>
                              $$DevicesTableReferences(
                                db,
                                table,
                                p0,
                              ).invoicesRefs,
                      referencedItemsForCurrentItem:
                          (item, referencedItems) => referencedItems.where(
                            (e) => e.deviceId == item.id,
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

typedef $$DevicesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DevicesTable,
      Device,
      $$DevicesTableFilterComposer,
      $$DevicesTableOrderingComposer,
      $$DevicesTableAnnotationComposer,
      $$DevicesTableCreateCompanionBuilder,
      $$DevicesTableUpdateCompanionBuilder,
      (Device, $$DevicesTableReferences),
      Device,
      PrefetchHooks Function({bool invoicesRefs})
    >;
typedef $$LocationsTableCreateCompanionBuilder =
    LocationsCompanion Function({
      required String id,
      required String shopId,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      required String name,
      Value<int> rowid,
    });
typedef $$LocationsTableUpdateCompanionBuilder =
    LocationsCompanion Function({
      Value<String> id,
      Value<String> shopId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String> name,
      Value<int> rowid,
    });

final class $$LocationsTableReferences
    extends BaseReferences<_$AppDatabase, $LocationsTable, Location> {
  $$LocationsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$StockMovementsTable, List<StockMovement>>
  _stockMovementsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.stockMovements,
    aliasName: $_aliasNameGenerator(
      db.locations.id,
      db.stockMovements.locationId,
    ),
  );

  $$StockMovementsTableProcessedTableManager get stockMovementsRefs {
    final manager = $$StockMovementsTableTableManager(
      $_db,
      $_db.stockMovements,
    ).filter((f) => f.locationId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_stockMovementsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$LocationsTableFilterComposer
    extends Composer<_$AppDatabase, $LocationsTable> {
  $$LocationsTableFilterComposer({
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

  ColumnFilters<String> get shopId => $composableBuilder(
    column: $table.shopId,
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> stockMovementsRefs(
    Expression<bool> Function($$StockMovementsTableFilterComposer f) f,
  ) {
    final $$StockMovementsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.stockMovements,
      getReferencedColumn: (t) => t.locationId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StockMovementsTableFilterComposer(
            $db: $db,
            $table: $db.stockMovements,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$LocationsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocationsTable> {
  $$LocationsTableOrderingComposer({
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

  ColumnOrderings<String> get shopId => $composableBuilder(
    column: $table.shopId,
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocationsTable> {
  $$LocationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get shopId =>
      $composableBuilder(column: $table.shopId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  Expression<T> stockMovementsRefs<T extends Object>(
    Expression<T> Function($$StockMovementsTableAnnotationComposer a) f,
  ) {
    final $$StockMovementsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.stockMovements,
      getReferencedColumn: (t) => t.locationId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StockMovementsTableAnnotationComposer(
            $db: $db,
            $table: $db.stockMovements,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$LocationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocationsTable,
          Location,
          $$LocationsTableFilterComposer,
          $$LocationsTableOrderingComposer,
          $$LocationsTableAnnotationComposer,
          $$LocationsTableCreateCompanionBuilder,
          $$LocationsTableUpdateCompanionBuilder,
          (Location, $$LocationsTableReferences),
          Location,
          PrefetchHooks Function({bool stockMovementsRefs})
        > {
  $$LocationsTableTableManager(_$AppDatabase db, $LocationsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$LocationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$LocationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$LocationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> shopId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocationsCompanion(
                id: id,
                shopId: shopId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                name: name,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String shopId,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                required String name,
                Value<int> rowid = const Value.absent(),
              }) => LocationsCompanion.insert(
                id: id,
                shopId: shopId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                name: name,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          $$LocationsTableReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: ({stockMovementsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (stockMovementsRefs) db.stockMovements,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (stockMovementsRefs)
                    await $_getPrefetchedData<
                      Location,
                      $LocationsTable,
                      StockMovement
                    >(
                      currentTable: table,
                      referencedTable: $$LocationsTableReferences
                          ._stockMovementsRefsTable(db),
                      managerFromTypedResult:
                          (p0) =>
                              $$LocationsTableReferences(
                                db,
                                table,
                                p0,
                              ).stockMovementsRefs,
                      referencedItemsForCurrentItem:
                          (item, referencedItems) => referencedItems.where(
                            (e) => e.locationId == item.id,
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

typedef $$LocationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocationsTable,
      Location,
      $$LocationsTableFilterComposer,
      $$LocationsTableOrderingComposer,
      $$LocationsTableAnnotationComposer,
      $$LocationsTableCreateCompanionBuilder,
      $$LocationsTableUpdateCompanionBuilder,
      (Location, $$LocationsTableReferences),
      Location,
      PrefetchHooks Function({bool stockMovementsRefs})
    >;
typedef $$OutboxTableCreateCompanionBuilder =
    OutboxCompanion Function({
      required String id,
      required String shopId,
      required String entity,
      required String entityId,
      required String op,
      required String payloadJson,
      Value<int> attemptCount,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$OutboxTableUpdateCompanionBuilder =
    OutboxCompanion Function({
      Value<String> id,
      Value<String> shopId,
      Value<String> entity,
      Value<String> entityId,
      Value<String> op,
      Value<String> payloadJson,
      Value<int> attemptCount,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$OutboxTableFilterComposer
    extends Composer<_$AppDatabase, $OutboxTable> {
  $$OutboxTableFilterComposer({
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

  ColumnFilters<String> get shopId => $composableBuilder(
    column: $table.shopId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entity => $composableBuilder(
    column: $table.entity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get op => $composableBuilder(
    column: $table.op,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get attemptCount => $composableBuilder(
    column: $table.attemptCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$OutboxTableOrderingComposer
    extends Composer<_$AppDatabase, $OutboxTable> {
  $$OutboxTableOrderingComposer({
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

  ColumnOrderings<String> get shopId => $composableBuilder(
    column: $table.shopId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entity => $composableBuilder(
    column: $table.entity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get op => $composableBuilder(
    column: $table.op,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attemptCount => $composableBuilder(
    column: $table.attemptCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$OutboxTableAnnotationComposer
    extends Composer<_$AppDatabase, $OutboxTable> {
  $$OutboxTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get shopId =>
      $composableBuilder(column: $table.shopId, builder: (column) => column);

  GeneratedColumn<String> get entity =>
      $composableBuilder(column: $table.entity, builder: (column) => column);

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get op =>
      $composableBuilder(column: $table.op, builder: (column) => column);

  GeneratedColumn<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get attemptCount => $composableBuilder(
    column: $table.attemptCount,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$OutboxTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $OutboxTable,
          OutboxData,
          $$OutboxTableFilterComposer,
          $$OutboxTableOrderingComposer,
          $$OutboxTableAnnotationComposer,
          $$OutboxTableCreateCompanionBuilder,
          $$OutboxTableUpdateCompanionBuilder,
          (OutboxData, BaseReferences<_$AppDatabase, $OutboxTable, OutboxData>),
          OutboxData,
          PrefetchHooks Function()
        > {
  $$OutboxTableTableManager(_$AppDatabase db, $OutboxTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$OutboxTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$OutboxTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$OutboxTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> shopId = const Value.absent(),
                Value<String> entity = const Value.absent(),
                Value<String> entityId = const Value.absent(),
                Value<String> op = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<int> attemptCount = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OutboxCompanion(
                id: id,
                shopId: shopId,
                entity: entity,
                entityId: entityId,
                op: op,
                payloadJson: payloadJson,
                attemptCount: attemptCount,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String shopId,
                required String entity,
                required String entityId,
                required String op,
                required String payloadJson,
                Value<int> attemptCount = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => OutboxCompanion.insert(
                id: id,
                shopId: shopId,
                entity: entity,
                entityId: entityId,
                op: op,
                payloadJson: payloadJson,
                attemptCount: attemptCount,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$OutboxTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $OutboxTable,
      OutboxData,
      $$OutboxTableFilterComposer,
      $$OutboxTableOrderingComposer,
      $$OutboxTableAnnotationComposer,
      $$OutboxTableCreateCompanionBuilder,
      $$OutboxTableUpdateCompanionBuilder,
      (OutboxData, BaseReferences<_$AppDatabase, $OutboxTable, OutboxData>),
      OutboxData,
      PrefetchHooks Function()
    >;
typedef $$ItemsTableCreateCompanionBuilder =
    ItemsCompanion Function({
      required String id,
      required String shopId,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      required String name,
      Value<String?> brand,
      Value<String?> category,
      Value<String?> hsn,
      Value<int> gstRateBp,
      required String baseUnit,
      Value<int> priceUnitFactor,
      Value<bool> trackSerial,
      Value<bool> trackCoil,
      Value<int> minStockBase,
      Value<bool> active,
      Value<int> rowid,
    });
typedef $$ItemsTableUpdateCompanionBuilder =
    ItemsCompanion Function({
      Value<String> id,
      Value<String> shopId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String> name,
      Value<String?> brand,
      Value<String?> category,
      Value<String?> hsn,
      Value<int> gstRateBp,
      Value<String> baseUnit,
      Value<int> priceUnitFactor,
      Value<bool> trackSerial,
      Value<bool> trackCoil,
      Value<int> minStockBase,
      Value<bool> active,
      Value<int> rowid,
    });

final class $$ItemsTableReferences
    extends BaseReferences<_$AppDatabase, $ItemsTable, Item> {
  $$ItemsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ItemUnitsTable, List<ItemUnit>>
  _itemUnitsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.itemUnits,
    aliasName: $_aliasNameGenerator(db.items.id, db.itemUnits.itemId),
  );

  $$ItemUnitsTableProcessedTableManager get itemUnitsRefs {
    final manager = $$ItemUnitsTableTableManager(
      $_db,
      $_db.itemUnits,
    ).filter((f) => f.itemId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_itemUnitsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ItemVariantsTable, List<ItemVariant>>
  _itemVariantsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.itemVariants,
    aliasName: $_aliasNameGenerator(db.items.id, db.itemVariants.itemId),
  );

  $$ItemVariantsTableProcessedTableManager get itemVariantsRefs {
    final manager = $$ItemVariantsTableTableManager(
      $_db,
      $_db.itemVariants,
    ).filter((f) => f.itemId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_itemVariantsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ItemPricesTable, List<ItemPrice>>
  _itemPricesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.itemPrices,
    aliasName: $_aliasNameGenerator(db.items.id, db.itemPrices.itemId),
  );

  $$ItemPricesTableProcessedTableManager get itemPricesRefs {
    final manager = $$ItemPricesTableTableManager(
      $_db,
      $_db.itemPrices,
    ).filter((f) => f.itemId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_itemPricesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ItemCostsTable, List<ItemCost>>
  _itemCostsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.itemCosts,
    aliasName: $_aliasNameGenerator(db.items.id, db.itemCosts.itemId),
  );

  $$ItemCostsTableProcessedTableManager get itemCostsRefs {
    final manager = $$ItemCostsTableTableManager(
      $_db,
      $_db.itemCosts,
    ).filter((f) => f.itemId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_itemCostsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$InvoiceLinesTable, List<InvoiceLine>>
  _invoiceLinesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.invoiceLines,
    aliasName: $_aliasNameGenerator(db.items.id, db.invoiceLines.itemId),
  );

  $$InvoiceLinesTableProcessedTableManager get invoiceLinesRefs {
    final manager = $$InvoiceLinesTableTableManager(
      $_db,
      $_db.invoiceLines,
    ).filter((f) => f.itemId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_invoiceLinesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$SalesReturnLinesTable, List<SalesReturnLine>>
  _salesReturnLinesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.salesReturnLines,
    aliasName: $_aliasNameGenerator(db.items.id, db.salesReturnLines.itemId),
  );

  $$SalesReturnLinesTableProcessedTableManager get salesReturnLinesRefs {
    final manager = $$SalesReturnLinesTableTableManager(
      $_db,
      $_db.salesReturnLines,
    ).filter((f) => f.itemId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _salesReturnLinesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$PurchaseLinesTable, List<PurchaseLine>>
  _purchaseLinesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.purchaseLines,
    aliasName: $_aliasNameGenerator(db.items.id, db.purchaseLines.itemId),
  );

  $$PurchaseLinesTableProcessedTableManager get purchaseLinesRefs {
    final manager = $$PurchaseLinesTableTableManager(
      $_db,
      $_db.purchaseLines,
    ).filter((f) => f.itemId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_purchaseLinesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$StockMovementsTable, List<StockMovement>>
  _stockMovementsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.stockMovements,
    aliasName: $_aliasNameGenerator(db.items.id, db.stockMovements.itemId),
  );

  $$StockMovementsTableProcessedTableManager get stockMovementsRefs {
    final manager = $$StockMovementsTableTableManager(
      $_db,
      $_db.stockMovements,
    ).filter((f) => f.itemId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_stockMovementsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ItemsTableFilterComposer extends Composer<_$AppDatabase, $ItemsTable> {
  $$ItemsTableFilterComposer({
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

  ColumnFilters<String> get shopId => $composableBuilder(
    column: $table.shopId,
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get brand => $composableBuilder(
    column: $table.brand,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get hsn => $composableBuilder(
    column: $table.hsn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get gstRateBp => $composableBuilder(
    column: $table.gstRateBp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get baseUnit => $composableBuilder(
    column: $table.baseUnit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get priceUnitFactor => $composableBuilder(
    column: $table.priceUnitFactor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get trackSerial => $composableBuilder(
    column: $table.trackSerial,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get trackCoil => $composableBuilder(
    column: $table.trackCoil,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get minStockBase => $composableBuilder(
    column: $table.minStockBase,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get active => $composableBuilder(
    column: $table.active,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> itemUnitsRefs(
    Expression<bool> Function($$ItemUnitsTableFilterComposer f) f,
  ) {
    final $$ItemUnitsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.itemUnits,
      getReferencedColumn: (t) => t.itemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ItemUnitsTableFilterComposer(
            $db: $db,
            $table: $db.itemUnits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> itemVariantsRefs(
    Expression<bool> Function($$ItemVariantsTableFilterComposer f) f,
  ) {
    final $$ItemVariantsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.itemVariants,
      getReferencedColumn: (t) => t.itemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ItemVariantsTableFilterComposer(
            $db: $db,
            $table: $db.itemVariants,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> itemPricesRefs(
    Expression<bool> Function($$ItemPricesTableFilterComposer f) f,
  ) {
    final $$ItemPricesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.itemPrices,
      getReferencedColumn: (t) => t.itemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ItemPricesTableFilterComposer(
            $db: $db,
            $table: $db.itemPrices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> itemCostsRefs(
    Expression<bool> Function($$ItemCostsTableFilterComposer f) f,
  ) {
    final $$ItemCostsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.itemCosts,
      getReferencedColumn: (t) => t.itemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ItemCostsTableFilterComposer(
            $db: $db,
            $table: $db.itemCosts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> invoiceLinesRefs(
    Expression<bool> Function($$InvoiceLinesTableFilterComposer f) f,
  ) {
    final $$InvoiceLinesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.invoiceLines,
      getReferencedColumn: (t) => t.itemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InvoiceLinesTableFilterComposer(
            $db: $db,
            $table: $db.invoiceLines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> salesReturnLinesRefs(
    Expression<bool> Function($$SalesReturnLinesTableFilterComposer f) f,
  ) {
    final $$SalesReturnLinesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.salesReturnLines,
      getReferencedColumn: (t) => t.itemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SalesReturnLinesTableFilterComposer(
            $db: $db,
            $table: $db.salesReturnLines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> purchaseLinesRefs(
    Expression<bool> Function($$PurchaseLinesTableFilterComposer f) f,
  ) {
    final $$PurchaseLinesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.purchaseLines,
      getReferencedColumn: (t) => t.itemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PurchaseLinesTableFilterComposer(
            $db: $db,
            $table: $db.purchaseLines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> stockMovementsRefs(
    Expression<bool> Function($$StockMovementsTableFilterComposer f) f,
  ) {
    final $$StockMovementsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.stockMovements,
      getReferencedColumn: (t) => t.itemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StockMovementsTableFilterComposer(
            $db: $db,
            $table: $db.stockMovements,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $ItemsTable> {
  $$ItemsTableOrderingComposer({
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

  ColumnOrderings<String> get shopId => $composableBuilder(
    column: $table.shopId,
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get brand => $composableBuilder(
    column: $table.brand,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get hsn => $composableBuilder(
    column: $table.hsn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get gstRateBp => $composableBuilder(
    column: $table.gstRateBp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get baseUnit => $composableBuilder(
    column: $table.baseUnit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get priceUnitFactor => $composableBuilder(
    column: $table.priceUnitFactor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get trackSerial => $composableBuilder(
    column: $table.trackSerial,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get trackCoil => $composableBuilder(
    column: $table.trackCoil,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get minStockBase => $composableBuilder(
    column: $table.minStockBase,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get active => $composableBuilder(
    column: $table.active,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ItemsTable> {
  $$ItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get shopId =>
      $composableBuilder(column: $table.shopId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get brand =>
      $composableBuilder(column: $table.brand, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get hsn =>
      $composableBuilder(column: $table.hsn, builder: (column) => column);

  GeneratedColumn<int> get gstRateBp =>
      $composableBuilder(column: $table.gstRateBp, builder: (column) => column);

  GeneratedColumn<String> get baseUnit =>
      $composableBuilder(column: $table.baseUnit, builder: (column) => column);

  GeneratedColumn<int> get priceUnitFactor => $composableBuilder(
    column: $table.priceUnitFactor,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get trackSerial => $composableBuilder(
    column: $table.trackSerial,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get trackCoil =>
      $composableBuilder(column: $table.trackCoil, builder: (column) => column);

  GeneratedColumn<int> get minStockBase => $composableBuilder(
    column: $table.minStockBase,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get active =>
      $composableBuilder(column: $table.active, builder: (column) => column);

  Expression<T> itemUnitsRefs<T extends Object>(
    Expression<T> Function($$ItemUnitsTableAnnotationComposer a) f,
  ) {
    final $$ItemUnitsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.itemUnits,
      getReferencedColumn: (t) => t.itemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ItemUnitsTableAnnotationComposer(
            $db: $db,
            $table: $db.itemUnits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> itemVariantsRefs<T extends Object>(
    Expression<T> Function($$ItemVariantsTableAnnotationComposer a) f,
  ) {
    final $$ItemVariantsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.itemVariants,
      getReferencedColumn: (t) => t.itemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ItemVariantsTableAnnotationComposer(
            $db: $db,
            $table: $db.itemVariants,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> itemPricesRefs<T extends Object>(
    Expression<T> Function($$ItemPricesTableAnnotationComposer a) f,
  ) {
    final $$ItemPricesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.itemPrices,
      getReferencedColumn: (t) => t.itemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ItemPricesTableAnnotationComposer(
            $db: $db,
            $table: $db.itemPrices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> itemCostsRefs<T extends Object>(
    Expression<T> Function($$ItemCostsTableAnnotationComposer a) f,
  ) {
    final $$ItemCostsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.itemCosts,
      getReferencedColumn: (t) => t.itemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ItemCostsTableAnnotationComposer(
            $db: $db,
            $table: $db.itemCosts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> invoiceLinesRefs<T extends Object>(
    Expression<T> Function($$InvoiceLinesTableAnnotationComposer a) f,
  ) {
    final $$InvoiceLinesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.invoiceLines,
      getReferencedColumn: (t) => t.itemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InvoiceLinesTableAnnotationComposer(
            $db: $db,
            $table: $db.invoiceLines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> salesReturnLinesRefs<T extends Object>(
    Expression<T> Function($$SalesReturnLinesTableAnnotationComposer a) f,
  ) {
    final $$SalesReturnLinesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.salesReturnLines,
      getReferencedColumn: (t) => t.itemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SalesReturnLinesTableAnnotationComposer(
            $db: $db,
            $table: $db.salesReturnLines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> purchaseLinesRefs<T extends Object>(
    Expression<T> Function($$PurchaseLinesTableAnnotationComposer a) f,
  ) {
    final $$PurchaseLinesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.purchaseLines,
      getReferencedColumn: (t) => t.itemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PurchaseLinesTableAnnotationComposer(
            $db: $db,
            $table: $db.purchaseLines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> stockMovementsRefs<T extends Object>(
    Expression<T> Function($$StockMovementsTableAnnotationComposer a) f,
  ) {
    final $$StockMovementsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.stockMovements,
      getReferencedColumn: (t) => t.itemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StockMovementsTableAnnotationComposer(
            $db: $db,
            $table: $db.stockMovements,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ItemsTable,
          Item,
          $$ItemsTableFilterComposer,
          $$ItemsTableOrderingComposer,
          $$ItemsTableAnnotationComposer,
          $$ItemsTableCreateCompanionBuilder,
          $$ItemsTableUpdateCompanionBuilder,
          (Item, $$ItemsTableReferences),
          Item,
          PrefetchHooks Function({
            bool itemUnitsRefs,
            bool itemVariantsRefs,
            bool itemPricesRefs,
            bool itemCostsRefs,
            bool invoiceLinesRefs,
            bool salesReturnLinesRefs,
            bool purchaseLinesRefs,
            bool stockMovementsRefs,
          })
        > {
  $$ItemsTableTableManager(_$AppDatabase db, $ItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$ItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$ItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$ItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> shopId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> brand = const Value.absent(),
                Value<String?> category = const Value.absent(),
                Value<String?> hsn = const Value.absent(),
                Value<int> gstRateBp = const Value.absent(),
                Value<String> baseUnit = const Value.absent(),
                Value<int> priceUnitFactor = const Value.absent(),
                Value<bool> trackSerial = const Value.absent(),
                Value<bool> trackCoil = const Value.absent(),
                Value<int> minStockBase = const Value.absent(),
                Value<bool> active = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ItemsCompanion(
                id: id,
                shopId: shopId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                name: name,
                brand: brand,
                category: category,
                hsn: hsn,
                gstRateBp: gstRateBp,
                baseUnit: baseUnit,
                priceUnitFactor: priceUnitFactor,
                trackSerial: trackSerial,
                trackCoil: trackCoil,
                minStockBase: minStockBase,
                active: active,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String shopId,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                required String name,
                Value<String?> brand = const Value.absent(),
                Value<String?> category = const Value.absent(),
                Value<String?> hsn = const Value.absent(),
                Value<int> gstRateBp = const Value.absent(),
                required String baseUnit,
                Value<int> priceUnitFactor = const Value.absent(),
                Value<bool> trackSerial = const Value.absent(),
                Value<bool> trackCoil = const Value.absent(),
                Value<int> minStockBase = const Value.absent(),
                Value<bool> active = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ItemsCompanion.insert(
                id: id,
                shopId: shopId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                name: name,
                brand: brand,
                category: category,
                hsn: hsn,
                gstRateBp: gstRateBp,
                baseUnit: baseUnit,
                priceUnitFactor: priceUnitFactor,
                trackSerial: trackSerial,
                trackCoil: trackCoil,
                minStockBase: minStockBase,
                active: active,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          $$ItemsTableReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: ({
            itemUnitsRefs = false,
            itemVariantsRefs = false,
            itemPricesRefs = false,
            itemCostsRefs = false,
            invoiceLinesRefs = false,
            salesReturnLinesRefs = false,
            purchaseLinesRefs = false,
            stockMovementsRefs = false,
          }) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (itemUnitsRefs) db.itemUnits,
                if (itemVariantsRefs) db.itemVariants,
                if (itemPricesRefs) db.itemPrices,
                if (itemCostsRefs) db.itemCosts,
                if (invoiceLinesRefs) db.invoiceLines,
                if (salesReturnLinesRefs) db.salesReturnLines,
                if (purchaseLinesRefs) db.purchaseLines,
                if (stockMovementsRefs) db.stockMovements,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (itemUnitsRefs)
                    await $_getPrefetchedData<Item, $ItemsTable, ItemUnit>(
                      currentTable: table,
                      referencedTable: $$ItemsTableReferences
                          ._itemUnitsRefsTable(db),
                      managerFromTypedResult:
                          (p0) =>
                              $$ItemsTableReferences(
                                db,
                                table,
                                p0,
                              ).itemUnitsRefs,
                      referencedItemsForCurrentItem:
                          (item, referencedItems) =>
                              referencedItems.where((e) => e.itemId == item.id),
                      typedResults: items,
                    ),
                  if (itemVariantsRefs)
                    await $_getPrefetchedData<Item, $ItemsTable, ItemVariant>(
                      currentTable: table,
                      referencedTable: $$ItemsTableReferences
                          ._itemVariantsRefsTable(db),
                      managerFromTypedResult:
                          (p0) =>
                              $$ItemsTableReferences(
                                db,
                                table,
                                p0,
                              ).itemVariantsRefs,
                      referencedItemsForCurrentItem:
                          (item, referencedItems) =>
                              referencedItems.where((e) => e.itemId == item.id),
                      typedResults: items,
                    ),
                  if (itemPricesRefs)
                    await $_getPrefetchedData<Item, $ItemsTable, ItemPrice>(
                      currentTable: table,
                      referencedTable: $$ItemsTableReferences
                          ._itemPricesRefsTable(db),
                      managerFromTypedResult:
                          (p0) =>
                              $$ItemsTableReferences(
                                db,
                                table,
                                p0,
                              ).itemPricesRefs,
                      referencedItemsForCurrentItem:
                          (item, referencedItems) =>
                              referencedItems.where((e) => e.itemId == item.id),
                      typedResults: items,
                    ),
                  if (itemCostsRefs)
                    await $_getPrefetchedData<Item, $ItemsTable, ItemCost>(
                      currentTable: table,
                      referencedTable: $$ItemsTableReferences
                          ._itemCostsRefsTable(db),
                      managerFromTypedResult:
                          (p0) =>
                              $$ItemsTableReferences(
                                db,
                                table,
                                p0,
                              ).itemCostsRefs,
                      referencedItemsForCurrentItem:
                          (item, referencedItems) =>
                              referencedItems.where((e) => e.itemId == item.id),
                      typedResults: items,
                    ),
                  if (invoiceLinesRefs)
                    await $_getPrefetchedData<Item, $ItemsTable, InvoiceLine>(
                      currentTable: table,
                      referencedTable: $$ItemsTableReferences
                          ._invoiceLinesRefsTable(db),
                      managerFromTypedResult:
                          (p0) =>
                              $$ItemsTableReferences(
                                db,
                                table,
                                p0,
                              ).invoiceLinesRefs,
                      referencedItemsForCurrentItem:
                          (item, referencedItems) =>
                              referencedItems.where((e) => e.itemId == item.id),
                      typedResults: items,
                    ),
                  if (salesReturnLinesRefs)
                    await $_getPrefetchedData<
                      Item,
                      $ItemsTable,
                      SalesReturnLine
                    >(
                      currentTable: table,
                      referencedTable: $$ItemsTableReferences
                          ._salesReturnLinesRefsTable(db),
                      managerFromTypedResult:
                          (p0) =>
                              $$ItemsTableReferences(
                                db,
                                table,
                                p0,
                              ).salesReturnLinesRefs,
                      referencedItemsForCurrentItem:
                          (item, referencedItems) =>
                              referencedItems.where((e) => e.itemId == item.id),
                      typedResults: items,
                    ),
                  if (purchaseLinesRefs)
                    await $_getPrefetchedData<Item, $ItemsTable, PurchaseLine>(
                      currentTable: table,
                      referencedTable: $$ItemsTableReferences
                          ._purchaseLinesRefsTable(db),
                      managerFromTypedResult:
                          (p0) =>
                              $$ItemsTableReferences(
                                db,
                                table,
                                p0,
                              ).purchaseLinesRefs,
                      referencedItemsForCurrentItem:
                          (item, referencedItems) =>
                              referencedItems.where((e) => e.itemId == item.id),
                      typedResults: items,
                    ),
                  if (stockMovementsRefs)
                    await $_getPrefetchedData<Item, $ItemsTable, StockMovement>(
                      currentTable: table,
                      referencedTable: $$ItemsTableReferences
                          ._stockMovementsRefsTable(db),
                      managerFromTypedResult:
                          (p0) =>
                              $$ItemsTableReferences(
                                db,
                                table,
                                p0,
                              ).stockMovementsRefs,
                      referencedItemsForCurrentItem:
                          (item, referencedItems) =>
                              referencedItems.where((e) => e.itemId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$ItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ItemsTable,
      Item,
      $$ItemsTableFilterComposer,
      $$ItemsTableOrderingComposer,
      $$ItemsTableAnnotationComposer,
      $$ItemsTableCreateCompanionBuilder,
      $$ItemsTableUpdateCompanionBuilder,
      (Item, $$ItemsTableReferences),
      Item,
      PrefetchHooks Function({
        bool itemUnitsRefs,
        bool itemVariantsRefs,
        bool itemPricesRefs,
        bool itemCostsRefs,
        bool invoiceLinesRefs,
        bool salesReturnLinesRefs,
        bool purchaseLinesRefs,
        bool stockMovementsRefs,
      })
    >;
typedef $$ItemUnitsTableCreateCompanionBuilder =
    ItemUnitsCompanion Function({
      required String id,
      required String shopId,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      required String itemId,
      required String unitName,
      required int factorToBase,
      Value<int> rowid,
    });
typedef $$ItemUnitsTableUpdateCompanionBuilder =
    ItemUnitsCompanion Function({
      Value<String> id,
      Value<String> shopId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String> itemId,
      Value<String> unitName,
      Value<int> factorToBase,
      Value<int> rowid,
    });

final class $$ItemUnitsTableReferences
    extends BaseReferences<_$AppDatabase, $ItemUnitsTable, ItemUnit> {
  $$ItemUnitsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ItemsTable _itemIdTable(_$AppDatabase db) => db.items.createAlias(
    $_aliasNameGenerator(db.itemUnits.itemId, db.items.id),
  );

  $$ItemsTableProcessedTableManager get itemId {
    final $_column = $_itemColumn<String>('item_id')!;

    final manager = $$ItemsTableTableManager(
      $_db,
      $_db.items,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_itemIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ItemUnitsTableFilterComposer
    extends Composer<_$AppDatabase, $ItemUnitsTable> {
  $$ItemUnitsTableFilterComposer({
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

  ColumnFilters<String> get shopId => $composableBuilder(
    column: $table.shopId,
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

  ColumnFilters<String> get unitName => $composableBuilder(
    column: $table.unitName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get factorToBase => $composableBuilder(
    column: $table.factorToBase,
    builder: (column) => ColumnFilters(column),
  );

  $$ItemsTableFilterComposer get itemId {
    final $$ItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.itemId,
      referencedTable: $db.items,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ItemsTableFilterComposer(
            $db: $db,
            $table: $db.items,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ItemUnitsTableOrderingComposer
    extends Composer<_$AppDatabase, $ItemUnitsTable> {
  $$ItemUnitsTableOrderingComposer({
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

  ColumnOrderings<String> get shopId => $composableBuilder(
    column: $table.shopId,
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

  ColumnOrderings<String> get unitName => $composableBuilder(
    column: $table.unitName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get factorToBase => $composableBuilder(
    column: $table.factorToBase,
    builder: (column) => ColumnOrderings(column),
  );

  $$ItemsTableOrderingComposer get itemId {
    final $$ItemsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.itemId,
      referencedTable: $db.items,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ItemsTableOrderingComposer(
            $db: $db,
            $table: $db.items,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ItemUnitsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ItemUnitsTable> {
  $$ItemUnitsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get shopId =>
      $composableBuilder(column: $table.shopId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get unitName =>
      $composableBuilder(column: $table.unitName, builder: (column) => column);

  GeneratedColumn<int> get factorToBase => $composableBuilder(
    column: $table.factorToBase,
    builder: (column) => column,
  );

  $$ItemsTableAnnotationComposer get itemId {
    final $$ItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.itemId,
      referencedTable: $db.items,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.items,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ItemUnitsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ItemUnitsTable,
          ItemUnit,
          $$ItemUnitsTableFilterComposer,
          $$ItemUnitsTableOrderingComposer,
          $$ItemUnitsTableAnnotationComposer,
          $$ItemUnitsTableCreateCompanionBuilder,
          $$ItemUnitsTableUpdateCompanionBuilder,
          (ItemUnit, $$ItemUnitsTableReferences),
          ItemUnit,
          PrefetchHooks Function({bool itemId})
        > {
  $$ItemUnitsTableTableManager(_$AppDatabase db, $ItemUnitsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$ItemUnitsTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$ItemUnitsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$ItemUnitsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> shopId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> itemId = const Value.absent(),
                Value<String> unitName = const Value.absent(),
                Value<int> factorToBase = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ItemUnitsCompanion(
                id: id,
                shopId: shopId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                itemId: itemId,
                unitName: unitName,
                factorToBase: factorToBase,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String shopId,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                required String itemId,
                required String unitName,
                required int factorToBase,
                Value<int> rowid = const Value.absent(),
              }) => ItemUnitsCompanion.insert(
                id: id,
                shopId: shopId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                itemId: itemId,
                unitName: unitName,
                factorToBase: factorToBase,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          $$ItemUnitsTableReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: ({itemId = false}) {
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
                  dynamic
                >
              >(state) {
                if (itemId) {
                  state =
                      state.withJoin(
                            currentTable: table,
                            currentColumn: table.itemId,
                            referencedTable: $$ItemUnitsTableReferences
                                ._itemIdTable(db),
                            referencedColumn:
                                $$ItemUnitsTableReferences._itemIdTable(db).id,
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

typedef $$ItemUnitsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ItemUnitsTable,
      ItemUnit,
      $$ItemUnitsTableFilterComposer,
      $$ItemUnitsTableOrderingComposer,
      $$ItemUnitsTableAnnotationComposer,
      $$ItemUnitsTableCreateCompanionBuilder,
      $$ItemUnitsTableUpdateCompanionBuilder,
      (ItemUnit, $$ItemUnitsTableReferences),
      ItemUnit,
      PrefetchHooks Function({bool itemId})
    >;
typedef $$ItemVariantsTableCreateCompanionBuilder =
    ItemVariantsCompanion Function({
      required String id,
      required String shopId,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      required String itemId,
      required String label,
      Value<String?> size,
      Value<String?> rating,
      Value<String?> colour,
      Value<String?> barcode,
      Value<String?> sku,
      Value<int> rowid,
    });
typedef $$ItemVariantsTableUpdateCompanionBuilder =
    ItemVariantsCompanion Function({
      Value<String> id,
      Value<String> shopId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String> itemId,
      Value<String> label,
      Value<String?> size,
      Value<String?> rating,
      Value<String?> colour,
      Value<String?> barcode,
      Value<String?> sku,
      Value<int> rowid,
    });

final class $$ItemVariantsTableReferences
    extends BaseReferences<_$AppDatabase, $ItemVariantsTable, ItemVariant> {
  $$ItemVariantsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ItemsTable _itemIdTable(_$AppDatabase db) => db.items.createAlias(
    $_aliasNameGenerator(db.itemVariants.itemId, db.items.id),
  );

  $$ItemsTableProcessedTableManager get itemId {
    final $_column = $_itemColumn<String>('item_id')!;

    final manager = $$ItemsTableTableManager(
      $_db,
      $_db.items,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_itemIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$ItemPricesTable, List<ItemPrice>>
  _itemPricesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.itemPrices,
    aliasName: $_aliasNameGenerator(
      db.itemVariants.id,
      db.itemPrices.variantId,
    ),
  );

  $$ItemPricesTableProcessedTableManager get itemPricesRefs {
    final manager = $$ItemPricesTableTableManager(
      $_db,
      $_db.itemPrices,
    ).filter((f) => f.variantId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_itemPricesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ItemCostsTable, List<ItemCost>>
  _itemCostsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.itemCosts,
    aliasName: $_aliasNameGenerator(db.itemVariants.id, db.itemCosts.variantId),
  );

  $$ItemCostsTableProcessedTableManager get itemCostsRefs {
    final manager = $$ItemCostsTableTableManager(
      $_db,
      $_db.itemCosts,
    ).filter((f) => f.variantId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_itemCostsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$InvoiceLinesTable, List<InvoiceLine>>
  _invoiceLinesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.invoiceLines,
    aliasName: $_aliasNameGenerator(
      db.itemVariants.id,
      db.invoiceLines.variantId,
    ),
  );

  $$InvoiceLinesTableProcessedTableManager get invoiceLinesRefs {
    final manager = $$InvoiceLinesTableTableManager(
      $_db,
      $_db.invoiceLines,
    ).filter((f) => f.variantId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_invoiceLinesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$PurchaseLinesTable, List<PurchaseLine>>
  _purchaseLinesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.purchaseLines,
    aliasName: $_aliasNameGenerator(
      db.itemVariants.id,
      db.purchaseLines.variantId,
    ),
  );

  $$PurchaseLinesTableProcessedTableManager get purchaseLinesRefs {
    final manager = $$PurchaseLinesTableTableManager(
      $_db,
      $_db.purchaseLines,
    ).filter((f) => f.variantId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_purchaseLinesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$StockMovementsTable, List<StockMovement>>
  _stockMovementsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.stockMovements,
    aliasName: $_aliasNameGenerator(
      db.itemVariants.id,
      db.stockMovements.variantId,
    ),
  );

  $$StockMovementsTableProcessedTableManager get stockMovementsRefs {
    final manager = $$StockMovementsTableTableManager(
      $_db,
      $_db.stockMovements,
    ).filter((f) => f.variantId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_stockMovementsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ItemVariantsTableFilterComposer
    extends Composer<_$AppDatabase, $ItemVariantsTable> {
  $$ItemVariantsTableFilterComposer({
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

  ColumnFilters<String> get shopId => $composableBuilder(
    column: $table.shopId,
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

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get size => $composableBuilder(
    column: $table.size,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rating => $composableBuilder(
    column: $table.rating,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get colour => $composableBuilder(
    column: $table.colour,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get barcode => $composableBuilder(
    column: $table.barcode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sku => $composableBuilder(
    column: $table.sku,
    builder: (column) => ColumnFilters(column),
  );

  $$ItemsTableFilterComposer get itemId {
    final $$ItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.itemId,
      referencedTable: $db.items,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ItemsTableFilterComposer(
            $db: $db,
            $table: $db.items,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> itemPricesRefs(
    Expression<bool> Function($$ItemPricesTableFilterComposer f) f,
  ) {
    final $$ItemPricesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.itemPrices,
      getReferencedColumn: (t) => t.variantId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ItemPricesTableFilterComposer(
            $db: $db,
            $table: $db.itemPrices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> itemCostsRefs(
    Expression<bool> Function($$ItemCostsTableFilterComposer f) f,
  ) {
    final $$ItemCostsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.itemCosts,
      getReferencedColumn: (t) => t.variantId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ItemCostsTableFilterComposer(
            $db: $db,
            $table: $db.itemCosts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> invoiceLinesRefs(
    Expression<bool> Function($$InvoiceLinesTableFilterComposer f) f,
  ) {
    final $$InvoiceLinesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.invoiceLines,
      getReferencedColumn: (t) => t.variantId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InvoiceLinesTableFilterComposer(
            $db: $db,
            $table: $db.invoiceLines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> purchaseLinesRefs(
    Expression<bool> Function($$PurchaseLinesTableFilterComposer f) f,
  ) {
    final $$PurchaseLinesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.purchaseLines,
      getReferencedColumn: (t) => t.variantId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PurchaseLinesTableFilterComposer(
            $db: $db,
            $table: $db.purchaseLines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> stockMovementsRefs(
    Expression<bool> Function($$StockMovementsTableFilterComposer f) f,
  ) {
    final $$StockMovementsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.stockMovements,
      getReferencedColumn: (t) => t.variantId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StockMovementsTableFilterComposer(
            $db: $db,
            $table: $db.stockMovements,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ItemVariantsTableOrderingComposer
    extends Composer<_$AppDatabase, $ItemVariantsTable> {
  $$ItemVariantsTableOrderingComposer({
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

  ColumnOrderings<String> get shopId => $composableBuilder(
    column: $table.shopId,
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

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get size => $composableBuilder(
    column: $table.size,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rating => $composableBuilder(
    column: $table.rating,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get colour => $composableBuilder(
    column: $table.colour,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get barcode => $composableBuilder(
    column: $table.barcode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sku => $composableBuilder(
    column: $table.sku,
    builder: (column) => ColumnOrderings(column),
  );

  $$ItemsTableOrderingComposer get itemId {
    final $$ItemsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.itemId,
      referencedTable: $db.items,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ItemsTableOrderingComposer(
            $db: $db,
            $table: $db.items,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ItemVariantsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ItemVariantsTable> {
  $$ItemVariantsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get shopId =>
      $composableBuilder(column: $table.shopId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<String> get size =>
      $composableBuilder(column: $table.size, builder: (column) => column);

  GeneratedColumn<String> get rating =>
      $composableBuilder(column: $table.rating, builder: (column) => column);

  GeneratedColumn<String> get colour =>
      $composableBuilder(column: $table.colour, builder: (column) => column);

  GeneratedColumn<String> get barcode =>
      $composableBuilder(column: $table.barcode, builder: (column) => column);

  GeneratedColumn<String> get sku =>
      $composableBuilder(column: $table.sku, builder: (column) => column);

  $$ItemsTableAnnotationComposer get itemId {
    final $$ItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.itemId,
      referencedTable: $db.items,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.items,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> itemPricesRefs<T extends Object>(
    Expression<T> Function($$ItemPricesTableAnnotationComposer a) f,
  ) {
    final $$ItemPricesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.itemPrices,
      getReferencedColumn: (t) => t.variantId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ItemPricesTableAnnotationComposer(
            $db: $db,
            $table: $db.itemPrices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> itemCostsRefs<T extends Object>(
    Expression<T> Function($$ItemCostsTableAnnotationComposer a) f,
  ) {
    final $$ItemCostsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.itemCosts,
      getReferencedColumn: (t) => t.variantId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ItemCostsTableAnnotationComposer(
            $db: $db,
            $table: $db.itemCosts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> invoiceLinesRefs<T extends Object>(
    Expression<T> Function($$InvoiceLinesTableAnnotationComposer a) f,
  ) {
    final $$InvoiceLinesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.invoiceLines,
      getReferencedColumn: (t) => t.variantId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InvoiceLinesTableAnnotationComposer(
            $db: $db,
            $table: $db.invoiceLines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> purchaseLinesRefs<T extends Object>(
    Expression<T> Function($$PurchaseLinesTableAnnotationComposer a) f,
  ) {
    final $$PurchaseLinesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.purchaseLines,
      getReferencedColumn: (t) => t.variantId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PurchaseLinesTableAnnotationComposer(
            $db: $db,
            $table: $db.purchaseLines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> stockMovementsRefs<T extends Object>(
    Expression<T> Function($$StockMovementsTableAnnotationComposer a) f,
  ) {
    final $$StockMovementsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.stockMovements,
      getReferencedColumn: (t) => t.variantId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StockMovementsTableAnnotationComposer(
            $db: $db,
            $table: $db.stockMovements,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ItemVariantsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ItemVariantsTable,
          ItemVariant,
          $$ItemVariantsTableFilterComposer,
          $$ItemVariantsTableOrderingComposer,
          $$ItemVariantsTableAnnotationComposer,
          $$ItemVariantsTableCreateCompanionBuilder,
          $$ItemVariantsTableUpdateCompanionBuilder,
          (ItemVariant, $$ItemVariantsTableReferences),
          ItemVariant,
          PrefetchHooks Function({
            bool itemId,
            bool itemPricesRefs,
            bool itemCostsRefs,
            bool invoiceLinesRefs,
            bool purchaseLinesRefs,
            bool stockMovementsRefs,
          })
        > {
  $$ItemVariantsTableTableManager(_$AppDatabase db, $ItemVariantsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$ItemVariantsTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$ItemVariantsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () =>
                  $$ItemVariantsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> shopId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> itemId = const Value.absent(),
                Value<String> label = const Value.absent(),
                Value<String?> size = const Value.absent(),
                Value<String?> rating = const Value.absent(),
                Value<String?> colour = const Value.absent(),
                Value<String?> barcode = const Value.absent(),
                Value<String?> sku = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ItemVariantsCompanion(
                id: id,
                shopId: shopId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                itemId: itemId,
                label: label,
                size: size,
                rating: rating,
                colour: colour,
                barcode: barcode,
                sku: sku,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String shopId,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                required String itemId,
                required String label,
                Value<String?> size = const Value.absent(),
                Value<String?> rating = const Value.absent(),
                Value<String?> colour = const Value.absent(),
                Value<String?> barcode = const Value.absent(),
                Value<String?> sku = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ItemVariantsCompanion.insert(
                id: id,
                shopId: shopId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                itemId: itemId,
                label: label,
                size: size,
                rating: rating,
                colour: colour,
                barcode: barcode,
                sku: sku,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          $$ItemVariantsTableReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: ({
            itemId = false,
            itemPricesRefs = false,
            itemCostsRefs = false,
            invoiceLinesRefs = false,
            purchaseLinesRefs = false,
            stockMovementsRefs = false,
          }) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (itemPricesRefs) db.itemPrices,
                if (itemCostsRefs) db.itemCosts,
                if (invoiceLinesRefs) db.invoiceLines,
                if (purchaseLinesRefs) db.purchaseLines,
                if (stockMovementsRefs) db.stockMovements,
              ],
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
                  dynamic
                >
              >(state) {
                if (itemId) {
                  state =
                      state.withJoin(
                            currentTable: table,
                            currentColumn: table.itemId,
                            referencedTable: $$ItemVariantsTableReferences
                                ._itemIdTable(db),
                            referencedColumn:
                                $$ItemVariantsTableReferences
                                    ._itemIdTable(db)
                                    .id,
                          )
                          as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (itemPricesRefs)
                    await $_getPrefetchedData<
                      ItemVariant,
                      $ItemVariantsTable,
                      ItemPrice
                    >(
                      currentTable: table,
                      referencedTable: $$ItemVariantsTableReferences
                          ._itemPricesRefsTable(db),
                      managerFromTypedResult:
                          (p0) =>
                              $$ItemVariantsTableReferences(
                                db,
                                table,
                                p0,
                              ).itemPricesRefs,
                      referencedItemsForCurrentItem:
                          (item, referencedItems) => referencedItems.where(
                            (e) => e.variantId == item.id,
                          ),
                      typedResults: items,
                    ),
                  if (itemCostsRefs)
                    await $_getPrefetchedData<
                      ItemVariant,
                      $ItemVariantsTable,
                      ItemCost
                    >(
                      currentTable: table,
                      referencedTable: $$ItemVariantsTableReferences
                          ._itemCostsRefsTable(db),
                      managerFromTypedResult:
                          (p0) =>
                              $$ItemVariantsTableReferences(
                                db,
                                table,
                                p0,
                              ).itemCostsRefs,
                      referencedItemsForCurrentItem:
                          (item, referencedItems) => referencedItems.where(
                            (e) => e.variantId == item.id,
                          ),
                      typedResults: items,
                    ),
                  if (invoiceLinesRefs)
                    await $_getPrefetchedData<
                      ItemVariant,
                      $ItemVariantsTable,
                      InvoiceLine
                    >(
                      currentTable: table,
                      referencedTable: $$ItemVariantsTableReferences
                          ._invoiceLinesRefsTable(db),
                      managerFromTypedResult:
                          (p0) =>
                              $$ItemVariantsTableReferences(
                                db,
                                table,
                                p0,
                              ).invoiceLinesRefs,
                      referencedItemsForCurrentItem:
                          (item, referencedItems) => referencedItems.where(
                            (e) => e.variantId == item.id,
                          ),
                      typedResults: items,
                    ),
                  if (purchaseLinesRefs)
                    await $_getPrefetchedData<
                      ItemVariant,
                      $ItemVariantsTable,
                      PurchaseLine
                    >(
                      currentTable: table,
                      referencedTable: $$ItemVariantsTableReferences
                          ._purchaseLinesRefsTable(db),
                      managerFromTypedResult:
                          (p0) =>
                              $$ItemVariantsTableReferences(
                                db,
                                table,
                                p0,
                              ).purchaseLinesRefs,
                      referencedItemsForCurrentItem:
                          (item, referencedItems) => referencedItems.where(
                            (e) => e.variantId == item.id,
                          ),
                      typedResults: items,
                    ),
                  if (stockMovementsRefs)
                    await $_getPrefetchedData<
                      ItemVariant,
                      $ItemVariantsTable,
                      StockMovement
                    >(
                      currentTable: table,
                      referencedTable: $$ItemVariantsTableReferences
                          ._stockMovementsRefsTable(db),
                      managerFromTypedResult:
                          (p0) =>
                              $$ItemVariantsTableReferences(
                                db,
                                table,
                                p0,
                              ).stockMovementsRefs,
                      referencedItemsForCurrentItem:
                          (item, referencedItems) => referencedItems.where(
                            (e) => e.variantId == item.id,
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

typedef $$ItemVariantsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ItemVariantsTable,
      ItemVariant,
      $$ItemVariantsTableFilterComposer,
      $$ItemVariantsTableOrderingComposer,
      $$ItemVariantsTableAnnotationComposer,
      $$ItemVariantsTableCreateCompanionBuilder,
      $$ItemVariantsTableUpdateCompanionBuilder,
      (ItemVariant, $$ItemVariantsTableReferences),
      ItemVariant,
      PrefetchHooks Function({
        bool itemId,
        bool itemPricesRefs,
        bool itemCostsRefs,
        bool invoiceLinesRefs,
        bool purchaseLinesRefs,
        bool stockMovementsRefs,
      })
    >;
typedef $$ItemPricesTableCreateCompanionBuilder =
    ItemPricesCompanion Function({
      required String id,
      required String shopId,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      required String itemId,
      Value<String?> variantId,
      required String tier,
      required int ratePaise,
      Value<int> rowid,
    });
typedef $$ItemPricesTableUpdateCompanionBuilder =
    ItemPricesCompanion Function({
      Value<String> id,
      Value<String> shopId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String> itemId,
      Value<String?> variantId,
      Value<String> tier,
      Value<int> ratePaise,
      Value<int> rowid,
    });

final class $$ItemPricesTableReferences
    extends BaseReferences<_$AppDatabase, $ItemPricesTable, ItemPrice> {
  $$ItemPricesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ItemsTable _itemIdTable(_$AppDatabase db) => db.items.createAlias(
    $_aliasNameGenerator(db.itemPrices.itemId, db.items.id),
  );

  $$ItemsTableProcessedTableManager get itemId {
    final $_column = $_itemColumn<String>('item_id')!;

    final manager = $$ItemsTableTableManager(
      $_db,
      $_db.items,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_itemIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ItemVariantsTable _variantIdTable(_$AppDatabase db) =>
      db.itemVariants.createAlias(
        $_aliasNameGenerator(db.itemPrices.variantId, db.itemVariants.id),
      );

  $$ItemVariantsTableProcessedTableManager? get variantId {
    final $_column = $_itemColumn<String>('variant_id');
    if ($_column == null) return null;
    final manager = $$ItemVariantsTableTableManager(
      $_db,
      $_db.itemVariants,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_variantIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ItemPricesTableFilterComposer
    extends Composer<_$AppDatabase, $ItemPricesTable> {
  $$ItemPricesTableFilterComposer({
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

  ColumnFilters<String> get shopId => $composableBuilder(
    column: $table.shopId,
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

  ColumnFilters<String> get tier => $composableBuilder(
    column: $table.tier,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ratePaise => $composableBuilder(
    column: $table.ratePaise,
    builder: (column) => ColumnFilters(column),
  );

  $$ItemsTableFilterComposer get itemId {
    final $$ItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.itemId,
      referencedTable: $db.items,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ItemsTableFilterComposer(
            $db: $db,
            $table: $db.items,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ItemVariantsTableFilterComposer get variantId {
    final $$ItemVariantsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.variantId,
      referencedTable: $db.itemVariants,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ItemVariantsTableFilterComposer(
            $db: $db,
            $table: $db.itemVariants,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ItemPricesTableOrderingComposer
    extends Composer<_$AppDatabase, $ItemPricesTable> {
  $$ItemPricesTableOrderingComposer({
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

  ColumnOrderings<String> get shopId => $composableBuilder(
    column: $table.shopId,
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

  ColumnOrderings<String> get tier => $composableBuilder(
    column: $table.tier,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ratePaise => $composableBuilder(
    column: $table.ratePaise,
    builder: (column) => ColumnOrderings(column),
  );

  $$ItemsTableOrderingComposer get itemId {
    final $$ItemsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.itemId,
      referencedTable: $db.items,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ItemsTableOrderingComposer(
            $db: $db,
            $table: $db.items,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ItemVariantsTableOrderingComposer get variantId {
    final $$ItemVariantsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.variantId,
      referencedTable: $db.itemVariants,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ItemVariantsTableOrderingComposer(
            $db: $db,
            $table: $db.itemVariants,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ItemPricesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ItemPricesTable> {
  $$ItemPricesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get shopId =>
      $composableBuilder(column: $table.shopId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get tier =>
      $composableBuilder(column: $table.tier, builder: (column) => column);

  GeneratedColumn<int> get ratePaise =>
      $composableBuilder(column: $table.ratePaise, builder: (column) => column);

  $$ItemsTableAnnotationComposer get itemId {
    final $$ItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.itemId,
      referencedTable: $db.items,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.items,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ItemVariantsTableAnnotationComposer get variantId {
    final $$ItemVariantsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.variantId,
      referencedTable: $db.itemVariants,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ItemVariantsTableAnnotationComposer(
            $db: $db,
            $table: $db.itemVariants,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ItemPricesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ItemPricesTable,
          ItemPrice,
          $$ItemPricesTableFilterComposer,
          $$ItemPricesTableOrderingComposer,
          $$ItemPricesTableAnnotationComposer,
          $$ItemPricesTableCreateCompanionBuilder,
          $$ItemPricesTableUpdateCompanionBuilder,
          (ItemPrice, $$ItemPricesTableReferences),
          ItemPrice,
          PrefetchHooks Function({bool itemId, bool variantId})
        > {
  $$ItemPricesTableTableManager(_$AppDatabase db, $ItemPricesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$ItemPricesTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$ItemPricesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$ItemPricesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> shopId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> itemId = const Value.absent(),
                Value<String?> variantId = const Value.absent(),
                Value<String> tier = const Value.absent(),
                Value<int> ratePaise = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ItemPricesCompanion(
                id: id,
                shopId: shopId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                itemId: itemId,
                variantId: variantId,
                tier: tier,
                ratePaise: ratePaise,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String shopId,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                required String itemId,
                Value<String?> variantId = const Value.absent(),
                required String tier,
                required int ratePaise,
                Value<int> rowid = const Value.absent(),
              }) => ItemPricesCompanion.insert(
                id: id,
                shopId: shopId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                itemId: itemId,
                variantId: variantId,
                tier: tier,
                ratePaise: ratePaise,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          $$ItemPricesTableReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: ({itemId = false, variantId = false}) {
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
                  dynamic
                >
              >(state) {
                if (itemId) {
                  state =
                      state.withJoin(
                            currentTable: table,
                            currentColumn: table.itemId,
                            referencedTable: $$ItemPricesTableReferences
                                ._itemIdTable(db),
                            referencedColumn:
                                $$ItemPricesTableReferences._itemIdTable(db).id,
                          )
                          as T;
                }
                if (variantId) {
                  state =
                      state.withJoin(
                            currentTable: table,
                            currentColumn: table.variantId,
                            referencedTable: $$ItemPricesTableReferences
                                ._variantIdTable(db),
                            referencedColumn:
                                $$ItemPricesTableReferences
                                    ._variantIdTable(db)
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

typedef $$ItemPricesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ItemPricesTable,
      ItemPrice,
      $$ItemPricesTableFilterComposer,
      $$ItemPricesTableOrderingComposer,
      $$ItemPricesTableAnnotationComposer,
      $$ItemPricesTableCreateCompanionBuilder,
      $$ItemPricesTableUpdateCompanionBuilder,
      (ItemPrice, $$ItemPricesTableReferences),
      ItemPrice,
      PrefetchHooks Function({bool itemId, bool variantId})
    >;
typedef $$ItemCostsTableCreateCompanionBuilder =
    ItemCostsCompanion Function({
      required String id,
      required String shopId,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      required String itemId,
      Value<String?> variantId,
      required int costPaise,
      required DateTime effectiveFrom,
      Value<int> rowid,
    });
typedef $$ItemCostsTableUpdateCompanionBuilder =
    ItemCostsCompanion Function({
      Value<String> id,
      Value<String> shopId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String> itemId,
      Value<String?> variantId,
      Value<int> costPaise,
      Value<DateTime> effectiveFrom,
      Value<int> rowid,
    });

final class $$ItemCostsTableReferences
    extends BaseReferences<_$AppDatabase, $ItemCostsTable, ItemCost> {
  $$ItemCostsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ItemsTable _itemIdTable(_$AppDatabase db) => db.items.createAlias(
    $_aliasNameGenerator(db.itemCosts.itemId, db.items.id),
  );

  $$ItemsTableProcessedTableManager get itemId {
    final $_column = $_itemColumn<String>('item_id')!;

    final manager = $$ItemsTableTableManager(
      $_db,
      $_db.items,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_itemIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ItemVariantsTable _variantIdTable(_$AppDatabase db) =>
      db.itemVariants.createAlias(
        $_aliasNameGenerator(db.itemCosts.variantId, db.itemVariants.id),
      );

  $$ItemVariantsTableProcessedTableManager? get variantId {
    final $_column = $_itemColumn<String>('variant_id');
    if ($_column == null) return null;
    final manager = $$ItemVariantsTableTableManager(
      $_db,
      $_db.itemVariants,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_variantIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ItemCostsTableFilterComposer
    extends Composer<_$AppDatabase, $ItemCostsTable> {
  $$ItemCostsTableFilterComposer({
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

  ColumnFilters<String> get shopId => $composableBuilder(
    column: $table.shopId,
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

  ColumnFilters<int> get costPaise => $composableBuilder(
    column: $table.costPaise,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get effectiveFrom => $composableBuilder(
    column: $table.effectiveFrom,
    builder: (column) => ColumnFilters(column),
  );

  $$ItemsTableFilterComposer get itemId {
    final $$ItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.itemId,
      referencedTable: $db.items,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ItemsTableFilterComposer(
            $db: $db,
            $table: $db.items,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ItemVariantsTableFilterComposer get variantId {
    final $$ItemVariantsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.variantId,
      referencedTable: $db.itemVariants,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ItemVariantsTableFilterComposer(
            $db: $db,
            $table: $db.itemVariants,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ItemCostsTableOrderingComposer
    extends Composer<_$AppDatabase, $ItemCostsTable> {
  $$ItemCostsTableOrderingComposer({
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

  ColumnOrderings<String> get shopId => $composableBuilder(
    column: $table.shopId,
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

  ColumnOrderings<int> get costPaise => $composableBuilder(
    column: $table.costPaise,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get effectiveFrom => $composableBuilder(
    column: $table.effectiveFrom,
    builder: (column) => ColumnOrderings(column),
  );

  $$ItemsTableOrderingComposer get itemId {
    final $$ItemsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.itemId,
      referencedTable: $db.items,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ItemsTableOrderingComposer(
            $db: $db,
            $table: $db.items,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ItemVariantsTableOrderingComposer get variantId {
    final $$ItemVariantsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.variantId,
      referencedTable: $db.itemVariants,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ItemVariantsTableOrderingComposer(
            $db: $db,
            $table: $db.itemVariants,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ItemCostsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ItemCostsTable> {
  $$ItemCostsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get shopId =>
      $composableBuilder(column: $table.shopId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get costPaise =>
      $composableBuilder(column: $table.costPaise, builder: (column) => column);

  GeneratedColumn<DateTime> get effectiveFrom => $composableBuilder(
    column: $table.effectiveFrom,
    builder: (column) => column,
  );

  $$ItemsTableAnnotationComposer get itemId {
    final $$ItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.itemId,
      referencedTable: $db.items,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.items,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ItemVariantsTableAnnotationComposer get variantId {
    final $$ItemVariantsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.variantId,
      referencedTable: $db.itemVariants,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ItemVariantsTableAnnotationComposer(
            $db: $db,
            $table: $db.itemVariants,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ItemCostsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ItemCostsTable,
          ItemCost,
          $$ItemCostsTableFilterComposer,
          $$ItemCostsTableOrderingComposer,
          $$ItemCostsTableAnnotationComposer,
          $$ItemCostsTableCreateCompanionBuilder,
          $$ItemCostsTableUpdateCompanionBuilder,
          (ItemCost, $$ItemCostsTableReferences),
          ItemCost,
          PrefetchHooks Function({bool itemId, bool variantId})
        > {
  $$ItemCostsTableTableManager(_$AppDatabase db, $ItemCostsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$ItemCostsTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$ItemCostsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$ItemCostsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> shopId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> itemId = const Value.absent(),
                Value<String?> variantId = const Value.absent(),
                Value<int> costPaise = const Value.absent(),
                Value<DateTime> effectiveFrom = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ItemCostsCompanion(
                id: id,
                shopId: shopId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                itemId: itemId,
                variantId: variantId,
                costPaise: costPaise,
                effectiveFrom: effectiveFrom,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String shopId,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                required String itemId,
                Value<String?> variantId = const Value.absent(),
                required int costPaise,
                required DateTime effectiveFrom,
                Value<int> rowid = const Value.absent(),
              }) => ItemCostsCompanion.insert(
                id: id,
                shopId: shopId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                itemId: itemId,
                variantId: variantId,
                costPaise: costPaise,
                effectiveFrom: effectiveFrom,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          $$ItemCostsTableReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: ({itemId = false, variantId = false}) {
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
                  dynamic
                >
              >(state) {
                if (itemId) {
                  state =
                      state.withJoin(
                            currentTable: table,
                            currentColumn: table.itemId,
                            referencedTable: $$ItemCostsTableReferences
                                ._itemIdTable(db),
                            referencedColumn:
                                $$ItemCostsTableReferences._itemIdTable(db).id,
                          )
                          as T;
                }
                if (variantId) {
                  state =
                      state.withJoin(
                            currentTable: table,
                            currentColumn: table.variantId,
                            referencedTable: $$ItemCostsTableReferences
                                ._variantIdTable(db),
                            referencedColumn:
                                $$ItemCostsTableReferences
                                    ._variantIdTable(db)
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

typedef $$ItemCostsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ItemCostsTable,
      ItemCost,
      $$ItemCostsTableFilterComposer,
      $$ItemCostsTableOrderingComposer,
      $$ItemCostsTableAnnotationComposer,
      $$ItemCostsTableCreateCompanionBuilder,
      $$ItemCostsTableUpdateCompanionBuilder,
      (ItemCost, $$ItemCostsTableReferences),
      ItemCost,
      PrefetchHooks Function({bool itemId, bool variantId})
    >;
typedef $$PartiesTableCreateCompanionBuilder =
    PartiesCompanion Function({
      required String id,
      required String shopId,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      required String kind,
      required String name,
      Value<String?> phone,
      Value<String?> gstin,
      Value<String?> address,
      Value<String?> stateCode,
      Value<String> tier,
      Value<int> creditLimitPaise,
      Value<int> rowid,
    });
typedef $$PartiesTableUpdateCompanionBuilder =
    PartiesCompanion Function({
      Value<String> id,
      Value<String> shopId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String> kind,
      Value<String> name,
      Value<String?> phone,
      Value<String?> gstin,
      Value<String?> address,
      Value<String?> stateCode,
      Value<String> tier,
      Value<int> creditLimitPaise,
      Value<int> rowid,
    });

final class $$PartiesTableReferences
    extends BaseReferences<_$AppDatabase, $PartiesTable, Party> {
  $$PartiesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$LedgerEntriesTable, List<LedgerEntry>>
  _ledgerEntriesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.ledgerEntries,
    aliasName: $_aliasNameGenerator(db.parties.id, db.ledgerEntries.partyId),
  );

  $$LedgerEntriesTableProcessedTableManager get ledgerEntriesRefs {
    final manager = $$LedgerEntriesTableTableManager(
      $_db,
      $_db.ledgerEntries,
    ).filter((f) => f.partyId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_ledgerEntriesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$InvoicesTable, List<Invoice>> _invoicesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.invoices,
    aliasName: $_aliasNameGenerator(db.parties.id, db.invoices.partyId),
  );

  $$InvoicesTableProcessedTableManager get invoicesRefs {
    final manager = $$InvoicesTableTableManager(
      $_db,
      $_db.invoices,
    ).filter((f) => f.partyId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_invoicesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$PurchasesTable, List<Purchase>>
  _purchasesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.purchases,
    aliasName: $_aliasNameGenerator(db.parties.id, db.purchases.supplierId),
  );

  $$PurchasesTableProcessedTableManager get purchasesRefs {
    final manager = $$PurchasesTableTableManager(
      $_db,
      $_db.purchases,
    ).filter((f) => f.supplierId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_purchasesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PartiesTableFilterComposer
    extends Composer<_$AppDatabase, $PartiesTable> {
  $$PartiesTableFilterComposer({
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

  ColumnFilters<String> get shopId => $composableBuilder(
    column: $table.shopId,
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

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get gstin => $composableBuilder(
    column: $table.gstin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get stateCode => $composableBuilder(
    column: $table.stateCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tier => $composableBuilder(
    column: $table.tier,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get creditLimitPaise => $composableBuilder(
    column: $table.creditLimitPaise,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> ledgerEntriesRefs(
    Expression<bool> Function($$LedgerEntriesTableFilterComposer f) f,
  ) {
    final $$LedgerEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.ledgerEntries,
      getReferencedColumn: (t) => t.partyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LedgerEntriesTableFilterComposer(
            $db: $db,
            $table: $db.ledgerEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> invoicesRefs(
    Expression<bool> Function($$InvoicesTableFilterComposer f) f,
  ) {
    final $$InvoicesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.invoices,
      getReferencedColumn: (t) => t.partyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InvoicesTableFilterComposer(
            $db: $db,
            $table: $db.invoices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> purchasesRefs(
    Expression<bool> Function($$PurchasesTableFilterComposer f) f,
  ) {
    final $$PurchasesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.purchases,
      getReferencedColumn: (t) => t.supplierId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PurchasesTableFilterComposer(
            $db: $db,
            $table: $db.purchases,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PartiesTableOrderingComposer
    extends Composer<_$AppDatabase, $PartiesTable> {
  $$PartiesTableOrderingComposer({
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

  ColumnOrderings<String> get shopId => $composableBuilder(
    column: $table.shopId,
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

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get gstin => $composableBuilder(
    column: $table.gstin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get stateCode => $composableBuilder(
    column: $table.stateCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tier => $composableBuilder(
    column: $table.tier,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get creditLimitPaise => $composableBuilder(
    column: $table.creditLimitPaise,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PartiesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PartiesTable> {
  $$PartiesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get shopId =>
      $composableBuilder(column: $table.shopId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get gstin =>
      $composableBuilder(column: $table.gstin, builder: (column) => column);

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<String> get stateCode =>
      $composableBuilder(column: $table.stateCode, builder: (column) => column);

  GeneratedColumn<String> get tier =>
      $composableBuilder(column: $table.tier, builder: (column) => column);

  GeneratedColumn<int> get creditLimitPaise => $composableBuilder(
    column: $table.creditLimitPaise,
    builder: (column) => column,
  );

  Expression<T> ledgerEntriesRefs<T extends Object>(
    Expression<T> Function($$LedgerEntriesTableAnnotationComposer a) f,
  ) {
    final $$LedgerEntriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.ledgerEntries,
      getReferencedColumn: (t) => t.partyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LedgerEntriesTableAnnotationComposer(
            $db: $db,
            $table: $db.ledgerEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> invoicesRefs<T extends Object>(
    Expression<T> Function($$InvoicesTableAnnotationComposer a) f,
  ) {
    final $$InvoicesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.invoices,
      getReferencedColumn: (t) => t.partyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InvoicesTableAnnotationComposer(
            $db: $db,
            $table: $db.invoices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> purchasesRefs<T extends Object>(
    Expression<T> Function($$PurchasesTableAnnotationComposer a) f,
  ) {
    final $$PurchasesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.purchases,
      getReferencedColumn: (t) => t.supplierId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PurchasesTableAnnotationComposer(
            $db: $db,
            $table: $db.purchases,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PartiesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PartiesTable,
          Party,
          $$PartiesTableFilterComposer,
          $$PartiesTableOrderingComposer,
          $$PartiesTableAnnotationComposer,
          $$PartiesTableCreateCompanionBuilder,
          $$PartiesTableUpdateCompanionBuilder,
          (Party, $$PartiesTableReferences),
          Party,
          PrefetchHooks Function({
            bool ledgerEntriesRefs,
            bool invoicesRefs,
            bool purchasesRefs,
          })
        > {
  $$PartiesTableTableManager(_$AppDatabase db, $PartiesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$PartiesTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$PartiesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$PartiesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> shopId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String?> gstin = const Value.absent(),
                Value<String?> address = const Value.absent(),
                Value<String?> stateCode = const Value.absent(),
                Value<String> tier = const Value.absent(),
                Value<int> creditLimitPaise = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PartiesCompanion(
                id: id,
                shopId: shopId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                kind: kind,
                name: name,
                phone: phone,
                gstin: gstin,
                address: address,
                stateCode: stateCode,
                tier: tier,
                creditLimitPaise: creditLimitPaise,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String shopId,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                required String kind,
                required String name,
                Value<String?> phone = const Value.absent(),
                Value<String?> gstin = const Value.absent(),
                Value<String?> address = const Value.absent(),
                Value<String?> stateCode = const Value.absent(),
                Value<String> tier = const Value.absent(),
                Value<int> creditLimitPaise = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PartiesCompanion.insert(
                id: id,
                shopId: shopId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                kind: kind,
                name: name,
                phone: phone,
                gstin: gstin,
                address: address,
                stateCode: stateCode,
                tier: tier,
                creditLimitPaise: creditLimitPaise,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          $$PartiesTableReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: ({
            ledgerEntriesRefs = false,
            invoicesRefs = false,
            purchasesRefs = false,
          }) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (ledgerEntriesRefs) db.ledgerEntries,
                if (invoicesRefs) db.invoices,
                if (purchasesRefs) db.purchases,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (ledgerEntriesRefs)
                    await $_getPrefetchedData<
                      Party,
                      $PartiesTable,
                      LedgerEntry
                    >(
                      currentTable: table,
                      referencedTable: $$PartiesTableReferences
                          ._ledgerEntriesRefsTable(db),
                      managerFromTypedResult:
                          (p0) =>
                              $$PartiesTableReferences(
                                db,
                                table,
                                p0,
                              ).ledgerEntriesRefs,
                      referencedItemsForCurrentItem:
                          (item, referencedItems) => referencedItems.where(
                            (e) => e.partyId == item.id,
                          ),
                      typedResults: items,
                    ),
                  if (invoicesRefs)
                    await $_getPrefetchedData<Party, $PartiesTable, Invoice>(
                      currentTable: table,
                      referencedTable: $$PartiesTableReferences
                          ._invoicesRefsTable(db),
                      managerFromTypedResult:
                          (p0) =>
                              $$PartiesTableReferences(
                                db,
                                table,
                                p0,
                              ).invoicesRefs,
                      referencedItemsForCurrentItem:
                          (item, referencedItems) => referencedItems.where(
                            (e) => e.partyId == item.id,
                          ),
                      typedResults: items,
                    ),
                  if (purchasesRefs)
                    await $_getPrefetchedData<Party, $PartiesTable, Purchase>(
                      currentTable: table,
                      referencedTable: $$PartiesTableReferences
                          ._purchasesRefsTable(db),
                      managerFromTypedResult:
                          (p0) =>
                              $$PartiesTableReferences(
                                db,
                                table,
                                p0,
                              ).purchasesRefs,
                      referencedItemsForCurrentItem:
                          (item, referencedItems) => referencedItems.where(
                            (e) => e.supplierId == item.id,
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

typedef $$PartiesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PartiesTable,
      Party,
      $$PartiesTableFilterComposer,
      $$PartiesTableOrderingComposer,
      $$PartiesTableAnnotationComposer,
      $$PartiesTableCreateCompanionBuilder,
      $$PartiesTableUpdateCompanionBuilder,
      (Party, $$PartiesTableReferences),
      Party,
      PrefetchHooks Function({
        bool ledgerEntriesRefs,
        bool invoicesRefs,
        bool purchasesRefs,
      })
    >;
typedef $$LedgerEntriesTableCreateCompanionBuilder =
    LedgerEntriesCompanion Function({
      required String id,
      required String shopId,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      required String partyId,
      required String entryType,
      required int amountPaise,
      Value<String?> refType,
      Value<String?> refId,
      Value<String?> note,
      Value<String?> paymentMode,
      required DateTime ts,
      Value<int> rowid,
    });
typedef $$LedgerEntriesTableUpdateCompanionBuilder =
    LedgerEntriesCompanion Function({
      Value<String> id,
      Value<String> shopId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String> partyId,
      Value<String> entryType,
      Value<int> amountPaise,
      Value<String?> refType,
      Value<String?> refId,
      Value<String?> note,
      Value<String?> paymentMode,
      Value<DateTime> ts,
      Value<int> rowid,
    });

final class $$LedgerEntriesTableReferences
    extends BaseReferences<_$AppDatabase, $LedgerEntriesTable, LedgerEntry> {
  $$LedgerEntriesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $PartiesTable _partyIdTable(_$AppDatabase db) =>
      db.parties.createAlias(
        $_aliasNameGenerator(db.ledgerEntries.partyId, db.parties.id),
      );

  $$PartiesTableProcessedTableManager get partyId {
    final $_column = $_itemColumn<String>('party_id')!;

    final manager = $$PartiesTableTableManager(
      $_db,
      $_db.parties,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_partyIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$LedgerEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $LedgerEntriesTable> {
  $$LedgerEntriesTableFilterComposer({
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

  ColumnFilters<String> get shopId => $composableBuilder(
    column: $table.shopId,
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

  ColumnFilters<String> get entryType => $composableBuilder(
    column: $table.entryType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountPaise => $composableBuilder(
    column: $table.amountPaise,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get refType => $composableBuilder(
    column: $table.refType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get refId => $composableBuilder(
    column: $table.refId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get paymentMode => $composableBuilder(
    column: $table.paymentMode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get ts => $composableBuilder(
    column: $table.ts,
    builder: (column) => ColumnFilters(column),
  );

  $$PartiesTableFilterComposer get partyId {
    final $$PartiesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.partyId,
      referencedTable: $db.parties,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PartiesTableFilterComposer(
            $db: $db,
            $table: $db.parties,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LedgerEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $LedgerEntriesTable> {
  $$LedgerEntriesTableOrderingComposer({
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

  ColumnOrderings<String> get shopId => $composableBuilder(
    column: $table.shopId,
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

  ColumnOrderings<String> get entryType => $composableBuilder(
    column: $table.entryType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountPaise => $composableBuilder(
    column: $table.amountPaise,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get refType => $composableBuilder(
    column: $table.refType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get refId => $composableBuilder(
    column: $table.refId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get paymentMode => $composableBuilder(
    column: $table.paymentMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get ts => $composableBuilder(
    column: $table.ts,
    builder: (column) => ColumnOrderings(column),
  );

  $$PartiesTableOrderingComposer get partyId {
    final $$PartiesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.partyId,
      referencedTable: $db.parties,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PartiesTableOrderingComposer(
            $db: $db,
            $table: $db.parties,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LedgerEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LedgerEntriesTable> {
  $$LedgerEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get shopId =>
      $composableBuilder(column: $table.shopId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get entryType =>
      $composableBuilder(column: $table.entryType, builder: (column) => column);

  GeneratedColumn<int> get amountPaise => $composableBuilder(
    column: $table.amountPaise,
    builder: (column) => column,
  );

  GeneratedColumn<String> get refType =>
      $composableBuilder(column: $table.refType, builder: (column) => column);

  GeneratedColumn<String> get refId =>
      $composableBuilder(column: $table.refId, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<String> get paymentMode => $composableBuilder(
    column: $table.paymentMode,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get ts =>
      $composableBuilder(column: $table.ts, builder: (column) => column);

  $$PartiesTableAnnotationComposer get partyId {
    final $$PartiesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.partyId,
      referencedTable: $db.parties,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PartiesTableAnnotationComposer(
            $db: $db,
            $table: $db.parties,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LedgerEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LedgerEntriesTable,
          LedgerEntry,
          $$LedgerEntriesTableFilterComposer,
          $$LedgerEntriesTableOrderingComposer,
          $$LedgerEntriesTableAnnotationComposer,
          $$LedgerEntriesTableCreateCompanionBuilder,
          $$LedgerEntriesTableUpdateCompanionBuilder,
          (LedgerEntry, $$LedgerEntriesTableReferences),
          LedgerEntry,
          PrefetchHooks Function({bool partyId})
        > {
  $$LedgerEntriesTableTableManager(_$AppDatabase db, $LedgerEntriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$LedgerEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () =>
                  $$LedgerEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$LedgerEntriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> shopId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> partyId = const Value.absent(),
                Value<String> entryType = const Value.absent(),
                Value<int> amountPaise = const Value.absent(),
                Value<String?> refType = const Value.absent(),
                Value<String?> refId = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<String?> paymentMode = const Value.absent(),
                Value<DateTime> ts = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LedgerEntriesCompanion(
                id: id,
                shopId: shopId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                partyId: partyId,
                entryType: entryType,
                amountPaise: amountPaise,
                refType: refType,
                refId: refId,
                note: note,
                paymentMode: paymentMode,
                ts: ts,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String shopId,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                required String partyId,
                required String entryType,
                required int amountPaise,
                Value<String?> refType = const Value.absent(),
                Value<String?> refId = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<String?> paymentMode = const Value.absent(),
                required DateTime ts,
                Value<int> rowid = const Value.absent(),
              }) => LedgerEntriesCompanion.insert(
                id: id,
                shopId: shopId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                partyId: partyId,
                entryType: entryType,
                amountPaise: amountPaise,
                refType: refType,
                refId: refId,
                note: note,
                paymentMode: paymentMode,
                ts: ts,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          $$LedgerEntriesTableReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: ({partyId = false}) {
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
                  dynamic
                >
              >(state) {
                if (partyId) {
                  state =
                      state.withJoin(
                            currentTable: table,
                            currentColumn: table.partyId,
                            referencedTable: $$LedgerEntriesTableReferences
                                ._partyIdTable(db),
                            referencedColumn:
                                $$LedgerEntriesTableReferences
                                    ._partyIdTable(db)
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

typedef $$LedgerEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LedgerEntriesTable,
      LedgerEntry,
      $$LedgerEntriesTableFilterComposer,
      $$LedgerEntriesTableOrderingComposer,
      $$LedgerEntriesTableAnnotationComposer,
      $$LedgerEntriesTableCreateCompanionBuilder,
      $$LedgerEntriesTableUpdateCompanionBuilder,
      (LedgerEntry, $$LedgerEntriesTableReferences),
      LedgerEntry,
      PrefetchHooks Function({bool partyId})
    >;
typedef $$InvoicesTableCreateCompanionBuilder =
    InvoicesCompanion Function({
      required String id,
      required String shopId,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      required String deviceId,
      required String series,
      required int number,
      required String invoiceNoText,
      Value<String?> partyId,
      required DateTime date,
      required int subtotalPaise,
      Value<int> discountPaise,
      required int taxPaise,
      Value<int> roundOffPaise,
      required int totalPaise,
      Value<int> paidPaise,
      Value<String> status,
      Value<String?> shopSnapshotJson,
      Value<String?> createdBy,
      Value<int> rowid,
    });
typedef $$InvoicesTableUpdateCompanionBuilder =
    InvoicesCompanion Function({
      Value<String> id,
      Value<String> shopId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String> deviceId,
      Value<String> series,
      Value<int> number,
      Value<String> invoiceNoText,
      Value<String?> partyId,
      Value<DateTime> date,
      Value<int> subtotalPaise,
      Value<int> discountPaise,
      Value<int> taxPaise,
      Value<int> roundOffPaise,
      Value<int> totalPaise,
      Value<int> paidPaise,
      Value<String> status,
      Value<String?> shopSnapshotJson,
      Value<String?> createdBy,
      Value<int> rowid,
    });

final class $$InvoicesTableReferences
    extends BaseReferences<_$AppDatabase, $InvoicesTable, Invoice> {
  $$InvoicesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $DevicesTable _deviceIdTable(_$AppDatabase db) => db.devices
      .createAlias($_aliasNameGenerator(db.invoices.deviceId, db.devices.id));

  $$DevicesTableProcessedTableManager get deviceId {
    final $_column = $_itemColumn<String>('device_id')!;

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

  static $PartiesTable _partyIdTable(_$AppDatabase db) => db.parties
      .createAlias($_aliasNameGenerator(db.invoices.partyId, db.parties.id));

  $$PartiesTableProcessedTableManager? get partyId {
    final $_column = $_itemColumn<String>('party_id');
    if ($_column == null) return null;
    final manager = $$PartiesTableTableManager(
      $_db,
      $_db.parties,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_partyIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$InvoiceLinesTable, List<InvoiceLine>>
  _invoiceLinesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.invoiceLines,
    aliasName: $_aliasNameGenerator(db.invoices.id, db.invoiceLines.invoiceId),
  );

  $$InvoiceLinesTableProcessedTableManager get invoiceLinesRefs {
    final manager = $$InvoiceLinesTableTableManager(
      $_db,
      $_db.invoiceLines,
    ).filter((f) => f.invoiceId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_invoiceLinesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$InvoicePaymentsTable, List<InvoicePayment>>
  _invoicePaymentsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.invoicePayments,
    aliasName: $_aliasNameGenerator(
      db.invoices.id,
      db.invoicePayments.invoiceId,
    ),
  );

  $$InvoicePaymentsTableProcessedTableManager get invoicePaymentsRefs {
    final manager = $$InvoicePaymentsTableTableManager(
      $_db,
      $_db.invoicePayments,
    ).filter((f) => f.invoiceId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _invoicePaymentsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$SalesReturnsTable, List<SalesReturn>>
  _salesReturnsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.salesReturns,
    aliasName: $_aliasNameGenerator(db.invoices.id, db.salesReturns.invoiceId),
  );

  $$SalesReturnsTableProcessedTableManager get salesReturnsRefs {
    final manager = $$SalesReturnsTableTableManager(
      $_db,
      $_db.salesReturns,
    ).filter((f) => f.invoiceId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_salesReturnsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$InvoicesTableFilterComposer
    extends Composer<_$AppDatabase, $InvoicesTable> {
  $$InvoicesTableFilterComposer({
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

  ColumnFilters<String> get shopId => $composableBuilder(
    column: $table.shopId,
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

  ColumnFilters<String> get series => $composableBuilder(
    column: $table.series,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get number => $composableBuilder(
    column: $table.number,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get invoiceNoText => $composableBuilder(
    column: $table.invoiceNoText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get subtotalPaise => $composableBuilder(
    column: $table.subtotalPaise,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get discountPaise => $composableBuilder(
    column: $table.discountPaise,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get taxPaise => $composableBuilder(
    column: $table.taxPaise,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get roundOffPaise => $composableBuilder(
    column: $table.roundOffPaise,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalPaise => $composableBuilder(
    column: $table.totalPaise,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get paidPaise => $composableBuilder(
    column: $table.paidPaise,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get shopSnapshotJson => $composableBuilder(
    column: $table.shopSnapshotJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
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

  $$PartiesTableFilterComposer get partyId {
    final $$PartiesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.partyId,
      referencedTable: $db.parties,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PartiesTableFilterComposer(
            $db: $db,
            $table: $db.parties,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> invoiceLinesRefs(
    Expression<bool> Function($$InvoiceLinesTableFilterComposer f) f,
  ) {
    final $$InvoiceLinesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.invoiceLines,
      getReferencedColumn: (t) => t.invoiceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InvoiceLinesTableFilterComposer(
            $db: $db,
            $table: $db.invoiceLines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> invoicePaymentsRefs(
    Expression<bool> Function($$InvoicePaymentsTableFilterComposer f) f,
  ) {
    final $$InvoicePaymentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.invoicePayments,
      getReferencedColumn: (t) => t.invoiceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InvoicePaymentsTableFilterComposer(
            $db: $db,
            $table: $db.invoicePayments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> salesReturnsRefs(
    Expression<bool> Function($$SalesReturnsTableFilterComposer f) f,
  ) {
    final $$SalesReturnsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.salesReturns,
      getReferencedColumn: (t) => t.invoiceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SalesReturnsTableFilterComposer(
            $db: $db,
            $table: $db.salesReturns,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$InvoicesTableOrderingComposer
    extends Composer<_$AppDatabase, $InvoicesTable> {
  $$InvoicesTableOrderingComposer({
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

  ColumnOrderings<String> get shopId => $composableBuilder(
    column: $table.shopId,
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

  ColumnOrderings<String> get series => $composableBuilder(
    column: $table.series,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get number => $composableBuilder(
    column: $table.number,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get invoiceNoText => $composableBuilder(
    column: $table.invoiceNoText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get subtotalPaise => $composableBuilder(
    column: $table.subtotalPaise,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get discountPaise => $composableBuilder(
    column: $table.discountPaise,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get taxPaise => $composableBuilder(
    column: $table.taxPaise,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get roundOffPaise => $composableBuilder(
    column: $table.roundOffPaise,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalPaise => $composableBuilder(
    column: $table.totalPaise,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get paidPaise => $composableBuilder(
    column: $table.paidPaise,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get shopSnapshotJson => $composableBuilder(
    column: $table.shopSnapshotJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
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

  $$PartiesTableOrderingComposer get partyId {
    final $$PartiesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.partyId,
      referencedTable: $db.parties,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PartiesTableOrderingComposer(
            $db: $db,
            $table: $db.parties,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$InvoicesTableAnnotationComposer
    extends Composer<_$AppDatabase, $InvoicesTable> {
  $$InvoicesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get shopId =>
      $composableBuilder(column: $table.shopId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get series =>
      $composableBuilder(column: $table.series, builder: (column) => column);

  GeneratedColumn<int> get number =>
      $composableBuilder(column: $table.number, builder: (column) => column);

  GeneratedColumn<String> get invoiceNoText => $composableBuilder(
    column: $table.invoiceNoText,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<int> get subtotalPaise => $composableBuilder(
    column: $table.subtotalPaise,
    builder: (column) => column,
  );

  GeneratedColumn<int> get discountPaise => $composableBuilder(
    column: $table.discountPaise,
    builder: (column) => column,
  );

  GeneratedColumn<int> get taxPaise =>
      $composableBuilder(column: $table.taxPaise, builder: (column) => column);

  GeneratedColumn<int> get roundOffPaise => $composableBuilder(
    column: $table.roundOffPaise,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalPaise => $composableBuilder(
    column: $table.totalPaise,
    builder: (column) => column,
  );

  GeneratedColumn<int> get paidPaise =>
      $composableBuilder(column: $table.paidPaise, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get shopSnapshotJson => $composableBuilder(
    column: $table.shopSnapshotJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => column);

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

  $$PartiesTableAnnotationComposer get partyId {
    final $$PartiesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.partyId,
      referencedTable: $db.parties,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PartiesTableAnnotationComposer(
            $db: $db,
            $table: $db.parties,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> invoiceLinesRefs<T extends Object>(
    Expression<T> Function($$InvoiceLinesTableAnnotationComposer a) f,
  ) {
    final $$InvoiceLinesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.invoiceLines,
      getReferencedColumn: (t) => t.invoiceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InvoiceLinesTableAnnotationComposer(
            $db: $db,
            $table: $db.invoiceLines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> invoicePaymentsRefs<T extends Object>(
    Expression<T> Function($$InvoicePaymentsTableAnnotationComposer a) f,
  ) {
    final $$InvoicePaymentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.invoicePayments,
      getReferencedColumn: (t) => t.invoiceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InvoicePaymentsTableAnnotationComposer(
            $db: $db,
            $table: $db.invoicePayments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> salesReturnsRefs<T extends Object>(
    Expression<T> Function($$SalesReturnsTableAnnotationComposer a) f,
  ) {
    final $$SalesReturnsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.salesReturns,
      getReferencedColumn: (t) => t.invoiceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SalesReturnsTableAnnotationComposer(
            $db: $db,
            $table: $db.salesReturns,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$InvoicesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $InvoicesTable,
          Invoice,
          $$InvoicesTableFilterComposer,
          $$InvoicesTableOrderingComposer,
          $$InvoicesTableAnnotationComposer,
          $$InvoicesTableCreateCompanionBuilder,
          $$InvoicesTableUpdateCompanionBuilder,
          (Invoice, $$InvoicesTableReferences),
          Invoice,
          PrefetchHooks Function({
            bool deviceId,
            bool partyId,
            bool invoiceLinesRefs,
            bool invoicePaymentsRefs,
            bool salesReturnsRefs,
          })
        > {
  $$InvoicesTableTableManager(_$AppDatabase db, $InvoicesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$InvoicesTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$InvoicesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$InvoicesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> shopId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<String> series = const Value.absent(),
                Value<int> number = const Value.absent(),
                Value<String> invoiceNoText = const Value.absent(),
                Value<String?> partyId = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<int> subtotalPaise = const Value.absent(),
                Value<int> discountPaise = const Value.absent(),
                Value<int> taxPaise = const Value.absent(),
                Value<int> roundOffPaise = const Value.absent(),
                Value<int> totalPaise = const Value.absent(),
                Value<int> paidPaise = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> shopSnapshotJson = const Value.absent(),
                Value<String?> createdBy = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InvoicesCompanion(
                id: id,
                shopId: shopId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                deviceId: deviceId,
                series: series,
                number: number,
                invoiceNoText: invoiceNoText,
                partyId: partyId,
                date: date,
                subtotalPaise: subtotalPaise,
                discountPaise: discountPaise,
                taxPaise: taxPaise,
                roundOffPaise: roundOffPaise,
                totalPaise: totalPaise,
                paidPaise: paidPaise,
                status: status,
                shopSnapshotJson: shopSnapshotJson,
                createdBy: createdBy,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String shopId,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                required String deviceId,
                required String series,
                required int number,
                required String invoiceNoText,
                Value<String?> partyId = const Value.absent(),
                required DateTime date,
                required int subtotalPaise,
                Value<int> discountPaise = const Value.absent(),
                required int taxPaise,
                Value<int> roundOffPaise = const Value.absent(),
                required int totalPaise,
                Value<int> paidPaise = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> shopSnapshotJson = const Value.absent(),
                Value<String?> createdBy = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InvoicesCompanion.insert(
                id: id,
                shopId: shopId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                deviceId: deviceId,
                series: series,
                number: number,
                invoiceNoText: invoiceNoText,
                partyId: partyId,
                date: date,
                subtotalPaise: subtotalPaise,
                discountPaise: discountPaise,
                taxPaise: taxPaise,
                roundOffPaise: roundOffPaise,
                totalPaise: totalPaise,
                paidPaise: paidPaise,
                status: status,
                shopSnapshotJson: shopSnapshotJson,
                createdBy: createdBy,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          $$InvoicesTableReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: ({
            deviceId = false,
            partyId = false,
            invoiceLinesRefs = false,
            invoicePaymentsRefs = false,
            salesReturnsRefs = false,
          }) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (invoiceLinesRefs) db.invoiceLines,
                if (invoicePaymentsRefs) db.invoicePayments,
                if (salesReturnsRefs) db.salesReturns,
              ],
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
                  dynamic
                >
              >(state) {
                if (deviceId) {
                  state =
                      state.withJoin(
                            currentTable: table,
                            currentColumn: table.deviceId,
                            referencedTable: $$InvoicesTableReferences
                                ._deviceIdTable(db),
                            referencedColumn:
                                $$InvoicesTableReferences._deviceIdTable(db).id,
                          )
                          as T;
                }
                if (partyId) {
                  state =
                      state.withJoin(
                            currentTable: table,
                            currentColumn: table.partyId,
                            referencedTable: $$InvoicesTableReferences
                                ._partyIdTable(db),
                            referencedColumn:
                                $$InvoicesTableReferences._partyIdTable(db).id,
                          )
                          as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (invoiceLinesRefs)
                    await $_getPrefetchedData<
                      Invoice,
                      $InvoicesTable,
                      InvoiceLine
                    >(
                      currentTable: table,
                      referencedTable: $$InvoicesTableReferences
                          ._invoiceLinesRefsTable(db),
                      managerFromTypedResult:
                          (p0) =>
                              $$InvoicesTableReferences(
                                db,
                                table,
                                p0,
                              ).invoiceLinesRefs,
                      referencedItemsForCurrentItem:
                          (item, referencedItems) => referencedItems.where(
                            (e) => e.invoiceId == item.id,
                          ),
                      typedResults: items,
                    ),
                  if (invoicePaymentsRefs)
                    await $_getPrefetchedData<
                      Invoice,
                      $InvoicesTable,
                      InvoicePayment
                    >(
                      currentTable: table,
                      referencedTable: $$InvoicesTableReferences
                          ._invoicePaymentsRefsTable(db),
                      managerFromTypedResult:
                          (p0) =>
                              $$InvoicesTableReferences(
                                db,
                                table,
                                p0,
                              ).invoicePaymentsRefs,
                      referencedItemsForCurrentItem:
                          (item, referencedItems) => referencedItems.where(
                            (e) => e.invoiceId == item.id,
                          ),
                      typedResults: items,
                    ),
                  if (salesReturnsRefs)
                    await $_getPrefetchedData<
                      Invoice,
                      $InvoicesTable,
                      SalesReturn
                    >(
                      currentTable: table,
                      referencedTable: $$InvoicesTableReferences
                          ._salesReturnsRefsTable(db),
                      managerFromTypedResult:
                          (p0) =>
                              $$InvoicesTableReferences(
                                db,
                                table,
                                p0,
                              ).salesReturnsRefs,
                      referencedItemsForCurrentItem:
                          (item, referencedItems) => referencedItems.where(
                            (e) => e.invoiceId == item.id,
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

typedef $$InvoicesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $InvoicesTable,
      Invoice,
      $$InvoicesTableFilterComposer,
      $$InvoicesTableOrderingComposer,
      $$InvoicesTableAnnotationComposer,
      $$InvoicesTableCreateCompanionBuilder,
      $$InvoicesTableUpdateCompanionBuilder,
      (Invoice, $$InvoicesTableReferences),
      Invoice,
      PrefetchHooks Function({
        bool deviceId,
        bool partyId,
        bool invoiceLinesRefs,
        bool invoicePaymentsRefs,
        bool salesReturnsRefs,
      })
    >;
typedef $$InvoiceLinesTableCreateCompanionBuilder =
    InvoiceLinesCompanion Function({
      required String id,
      required String shopId,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      required String invoiceId,
      required String itemId,
      Value<String?> variantId,
      required String unitName,
      required String qtyEntered,
      required int qtyBase,
      required int ratePaise,
      Value<int> priceUnitFactor,
      Value<int> discountPaise,
      Value<int> gstRateBp,
      required int taxPaise,
      required int lineTotalPaise,
      Value<String?> coilId,
      Value<String?> serial,
      Value<int> rowid,
    });
typedef $$InvoiceLinesTableUpdateCompanionBuilder =
    InvoiceLinesCompanion Function({
      Value<String> id,
      Value<String> shopId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String> invoiceId,
      Value<String> itemId,
      Value<String?> variantId,
      Value<String> unitName,
      Value<String> qtyEntered,
      Value<int> qtyBase,
      Value<int> ratePaise,
      Value<int> priceUnitFactor,
      Value<int> discountPaise,
      Value<int> gstRateBp,
      Value<int> taxPaise,
      Value<int> lineTotalPaise,
      Value<String?> coilId,
      Value<String?> serial,
      Value<int> rowid,
    });

final class $$InvoiceLinesTableReferences
    extends BaseReferences<_$AppDatabase, $InvoiceLinesTable, InvoiceLine> {
  $$InvoiceLinesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $InvoicesTable _invoiceIdTable(_$AppDatabase db) =>
      db.invoices.createAlias(
        $_aliasNameGenerator(db.invoiceLines.invoiceId, db.invoices.id),
      );

  $$InvoicesTableProcessedTableManager get invoiceId {
    final $_column = $_itemColumn<String>('invoice_id')!;

    final manager = $$InvoicesTableTableManager(
      $_db,
      $_db.invoices,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_invoiceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ItemsTable _itemIdTable(_$AppDatabase db) => db.items.createAlias(
    $_aliasNameGenerator(db.invoiceLines.itemId, db.items.id),
  );

  $$ItemsTableProcessedTableManager get itemId {
    final $_column = $_itemColumn<String>('item_id')!;

    final manager = $$ItemsTableTableManager(
      $_db,
      $_db.items,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_itemIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ItemVariantsTable _variantIdTable(_$AppDatabase db) =>
      db.itemVariants.createAlias(
        $_aliasNameGenerator(db.invoiceLines.variantId, db.itemVariants.id),
      );

  $$ItemVariantsTableProcessedTableManager? get variantId {
    final $_column = $_itemColumn<String>('variant_id');
    if ($_column == null) return null;
    final manager = $$ItemVariantsTableTableManager(
      $_db,
      $_db.itemVariants,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_variantIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$SalesReturnLinesTable, List<SalesReturnLine>>
  _salesReturnLinesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.salesReturnLines,
    aliasName: $_aliasNameGenerator(
      db.invoiceLines.id,
      db.salesReturnLines.invoiceLineId,
    ),
  );

  $$SalesReturnLinesTableProcessedTableManager get salesReturnLinesRefs {
    final manager = $$SalesReturnLinesTableTableManager(
      $_db,
      $_db.salesReturnLines,
    ).filter((f) => f.invoiceLineId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _salesReturnLinesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$InvoiceLinesTableFilterComposer
    extends Composer<_$AppDatabase, $InvoiceLinesTable> {
  $$InvoiceLinesTableFilterComposer({
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

  ColumnFilters<String> get shopId => $composableBuilder(
    column: $table.shopId,
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

  ColumnFilters<String> get unitName => $composableBuilder(
    column: $table.unitName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get qtyEntered => $composableBuilder(
    column: $table.qtyEntered,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get qtyBase => $composableBuilder(
    column: $table.qtyBase,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ratePaise => $composableBuilder(
    column: $table.ratePaise,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get priceUnitFactor => $composableBuilder(
    column: $table.priceUnitFactor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get discountPaise => $composableBuilder(
    column: $table.discountPaise,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get gstRateBp => $composableBuilder(
    column: $table.gstRateBp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get taxPaise => $composableBuilder(
    column: $table.taxPaise,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lineTotalPaise => $composableBuilder(
    column: $table.lineTotalPaise,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get coilId => $composableBuilder(
    column: $table.coilId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get serial => $composableBuilder(
    column: $table.serial,
    builder: (column) => ColumnFilters(column),
  );

  $$InvoicesTableFilterComposer get invoiceId {
    final $$InvoicesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.invoiceId,
      referencedTable: $db.invoices,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InvoicesTableFilterComposer(
            $db: $db,
            $table: $db.invoices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ItemsTableFilterComposer get itemId {
    final $$ItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.itemId,
      referencedTable: $db.items,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ItemsTableFilterComposer(
            $db: $db,
            $table: $db.items,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ItemVariantsTableFilterComposer get variantId {
    final $$ItemVariantsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.variantId,
      referencedTable: $db.itemVariants,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ItemVariantsTableFilterComposer(
            $db: $db,
            $table: $db.itemVariants,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> salesReturnLinesRefs(
    Expression<bool> Function($$SalesReturnLinesTableFilterComposer f) f,
  ) {
    final $$SalesReturnLinesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.salesReturnLines,
      getReferencedColumn: (t) => t.invoiceLineId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SalesReturnLinesTableFilterComposer(
            $db: $db,
            $table: $db.salesReturnLines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$InvoiceLinesTableOrderingComposer
    extends Composer<_$AppDatabase, $InvoiceLinesTable> {
  $$InvoiceLinesTableOrderingComposer({
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

  ColumnOrderings<String> get shopId => $composableBuilder(
    column: $table.shopId,
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

  ColumnOrderings<String> get unitName => $composableBuilder(
    column: $table.unitName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get qtyEntered => $composableBuilder(
    column: $table.qtyEntered,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get qtyBase => $composableBuilder(
    column: $table.qtyBase,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ratePaise => $composableBuilder(
    column: $table.ratePaise,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get priceUnitFactor => $composableBuilder(
    column: $table.priceUnitFactor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get discountPaise => $composableBuilder(
    column: $table.discountPaise,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get gstRateBp => $composableBuilder(
    column: $table.gstRateBp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get taxPaise => $composableBuilder(
    column: $table.taxPaise,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lineTotalPaise => $composableBuilder(
    column: $table.lineTotalPaise,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get coilId => $composableBuilder(
    column: $table.coilId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get serial => $composableBuilder(
    column: $table.serial,
    builder: (column) => ColumnOrderings(column),
  );

  $$InvoicesTableOrderingComposer get invoiceId {
    final $$InvoicesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.invoiceId,
      referencedTable: $db.invoices,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InvoicesTableOrderingComposer(
            $db: $db,
            $table: $db.invoices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ItemsTableOrderingComposer get itemId {
    final $$ItemsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.itemId,
      referencedTable: $db.items,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ItemsTableOrderingComposer(
            $db: $db,
            $table: $db.items,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ItemVariantsTableOrderingComposer get variantId {
    final $$ItemVariantsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.variantId,
      referencedTable: $db.itemVariants,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ItemVariantsTableOrderingComposer(
            $db: $db,
            $table: $db.itemVariants,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$InvoiceLinesTableAnnotationComposer
    extends Composer<_$AppDatabase, $InvoiceLinesTable> {
  $$InvoiceLinesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get shopId =>
      $composableBuilder(column: $table.shopId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get unitName =>
      $composableBuilder(column: $table.unitName, builder: (column) => column);

  GeneratedColumn<String> get qtyEntered => $composableBuilder(
    column: $table.qtyEntered,
    builder: (column) => column,
  );

  GeneratedColumn<int> get qtyBase =>
      $composableBuilder(column: $table.qtyBase, builder: (column) => column);

  GeneratedColumn<int> get ratePaise =>
      $composableBuilder(column: $table.ratePaise, builder: (column) => column);

  GeneratedColumn<int> get priceUnitFactor => $composableBuilder(
    column: $table.priceUnitFactor,
    builder: (column) => column,
  );

  GeneratedColumn<int> get discountPaise => $composableBuilder(
    column: $table.discountPaise,
    builder: (column) => column,
  );

  GeneratedColumn<int> get gstRateBp =>
      $composableBuilder(column: $table.gstRateBp, builder: (column) => column);

  GeneratedColumn<int> get taxPaise =>
      $composableBuilder(column: $table.taxPaise, builder: (column) => column);

  GeneratedColumn<int> get lineTotalPaise => $composableBuilder(
    column: $table.lineTotalPaise,
    builder: (column) => column,
  );

  GeneratedColumn<String> get coilId =>
      $composableBuilder(column: $table.coilId, builder: (column) => column);

  GeneratedColumn<String> get serial =>
      $composableBuilder(column: $table.serial, builder: (column) => column);

  $$InvoicesTableAnnotationComposer get invoiceId {
    final $$InvoicesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.invoiceId,
      referencedTable: $db.invoices,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InvoicesTableAnnotationComposer(
            $db: $db,
            $table: $db.invoices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ItemsTableAnnotationComposer get itemId {
    final $$ItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.itemId,
      referencedTable: $db.items,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.items,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ItemVariantsTableAnnotationComposer get variantId {
    final $$ItemVariantsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.variantId,
      referencedTable: $db.itemVariants,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ItemVariantsTableAnnotationComposer(
            $db: $db,
            $table: $db.itemVariants,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> salesReturnLinesRefs<T extends Object>(
    Expression<T> Function($$SalesReturnLinesTableAnnotationComposer a) f,
  ) {
    final $$SalesReturnLinesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.salesReturnLines,
      getReferencedColumn: (t) => t.invoiceLineId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SalesReturnLinesTableAnnotationComposer(
            $db: $db,
            $table: $db.salesReturnLines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$InvoiceLinesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $InvoiceLinesTable,
          InvoiceLine,
          $$InvoiceLinesTableFilterComposer,
          $$InvoiceLinesTableOrderingComposer,
          $$InvoiceLinesTableAnnotationComposer,
          $$InvoiceLinesTableCreateCompanionBuilder,
          $$InvoiceLinesTableUpdateCompanionBuilder,
          (InvoiceLine, $$InvoiceLinesTableReferences),
          InvoiceLine,
          PrefetchHooks Function({
            bool invoiceId,
            bool itemId,
            bool variantId,
            bool salesReturnLinesRefs,
          })
        > {
  $$InvoiceLinesTableTableManager(_$AppDatabase db, $InvoiceLinesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$InvoiceLinesTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$InvoiceLinesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () =>
                  $$InvoiceLinesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> shopId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> invoiceId = const Value.absent(),
                Value<String> itemId = const Value.absent(),
                Value<String?> variantId = const Value.absent(),
                Value<String> unitName = const Value.absent(),
                Value<String> qtyEntered = const Value.absent(),
                Value<int> qtyBase = const Value.absent(),
                Value<int> ratePaise = const Value.absent(),
                Value<int> priceUnitFactor = const Value.absent(),
                Value<int> discountPaise = const Value.absent(),
                Value<int> gstRateBp = const Value.absent(),
                Value<int> taxPaise = const Value.absent(),
                Value<int> lineTotalPaise = const Value.absent(),
                Value<String?> coilId = const Value.absent(),
                Value<String?> serial = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InvoiceLinesCompanion(
                id: id,
                shopId: shopId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                invoiceId: invoiceId,
                itemId: itemId,
                variantId: variantId,
                unitName: unitName,
                qtyEntered: qtyEntered,
                qtyBase: qtyBase,
                ratePaise: ratePaise,
                priceUnitFactor: priceUnitFactor,
                discountPaise: discountPaise,
                gstRateBp: gstRateBp,
                taxPaise: taxPaise,
                lineTotalPaise: lineTotalPaise,
                coilId: coilId,
                serial: serial,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String shopId,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                required String invoiceId,
                required String itemId,
                Value<String?> variantId = const Value.absent(),
                required String unitName,
                required String qtyEntered,
                required int qtyBase,
                required int ratePaise,
                Value<int> priceUnitFactor = const Value.absent(),
                Value<int> discountPaise = const Value.absent(),
                Value<int> gstRateBp = const Value.absent(),
                required int taxPaise,
                required int lineTotalPaise,
                Value<String?> coilId = const Value.absent(),
                Value<String?> serial = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InvoiceLinesCompanion.insert(
                id: id,
                shopId: shopId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                invoiceId: invoiceId,
                itemId: itemId,
                variantId: variantId,
                unitName: unitName,
                qtyEntered: qtyEntered,
                qtyBase: qtyBase,
                ratePaise: ratePaise,
                priceUnitFactor: priceUnitFactor,
                discountPaise: discountPaise,
                gstRateBp: gstRateBp,
                taxPaise: taxPaise,
                lineTotalPaise: lineTotalPaise,
                coilId: coilId,
                serial: serial,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          $$InvoiceLinesTableReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: ({
            invoiceId = false,
            itemId = false,
            variantId = false,
            salesReturnLinesRefs = false,
          }) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (salesReturnLinesRefs) db.salesReturnLines,
              ],
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
                  dynamic
                >
              >(state) {
                if (invoiceId) {
                  state =
                      state.withJoin(
                            currentTable: table,
                            currentColumn: table.invoiceId,
                            referencedTable: $$InvoiceLinesTableReferences
                                ._invoiceIdTable(db),
                            referencedColumn:
                                $$InvoiceLinesTableReferences
                                    ._invoiceIdTable(db)
                                    .id,
                          )
                          as T;
                }
                if (itemId) {
                  state =
                      state.withJoin(
                            currentTable: table,
                            currentColumn: table.itemId,
                            referencedTable: $$InvoiceLinesTableReferences
                                ._itemIdTable(db),
                            referencedColumn:
                                $$InvoiceLinesTableReferences
                                    ._itemIdTable(db)
                                    .id,
                          )
                          as T;
                }
                if (variantId) {
                  state =
                      state.withJoin(
                            currentTable: table,
                            currentColumn: table.variantId,
                            referencedTable: $$InvoiceLinesTableReferences
                                ._variantIdTable(db),
                            referencedColumn:
                                $$InvoiceLinesTableReferences
                                    ._variantIdTable(db)
                                    .id,
                          )
                          as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (salesReturnLinesRefs)
                    await $_getPrefetchedData<
                      InvoiceLine,
                      $InvoiceLinesTable,
                      SalesReturnLine
                    >(
                      currentTable: table,
                      referencedTable: $$InvoiceLinesTableReferences
                          ._salesReturnLinesRefsTable(db),
                      managerFromTypedResult:
                          (p0) =>
                              $$InvoiceLinesTableReferences(
                                db,
                                table,
                                p0,
                              ).salesReturnLinesRefs,
                      referencedItemsForCurrentItem:
                          (item, referencedItems) => referencedItems.where(
                            (e) => e.invoiceLineId == item.id,
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

typedef $$InvoiceLinesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $InvoiceLinesTable,
      InvoiceLine,
      $$InvoiceLinesTableFilterComposer,
      $$InvoiceLinesTableOrderingComposer,
      $$InvoiceLinesTableAnnotationComposer,
      $$InvoiceLinesTableCreateCompanionBuilder,
      $$InvoiceLinesTableUpdateCompanionBuilder,
      (InvoiceLine, $$InvoiceLinesTableReferences),
      InvoiceLine,
      PrefetchHooks Function({
        bool invoiceId,
        bool itemId,
        bool variantId,
        bool salesReturnLinesRefs,
      })
    >;
typedef $$InvoicePaymentsTableCreateCompanionBuilder =
    InvoicePaymentsCompanion Function({
      required String id,
      required String shopId,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      required String invoiceId,
      required String mode,
      required int amountPaise,
      Value<String?> ref,
      Value<int> rowid,
    });
typedef $$InvoicePaymentsTableUpdateCompanionBuilder =
    InvoicePaymentsCompanion Function({
      Value<String> id,
      Value<String> shopId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String> invoiceId,
      Value<String> mode,
      Value<int> amountPaise,
      Value<String?> ref,
      Value<int> rowid,
    });

final class $$InvoicePaymentsTableReferences
    extends
        BaseReferences<_$AppDatabase, $InvoicePaymentsTable, InvoicePayment> {
  $$InvoicePaymentsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $InvoicesTable _invoiceIdTable(_$AppDatabase db) =>
      db.invoices.createAlias(
        $_aliasNameGenerator(db.invoicePayments.invoiceId, db.invoices.id),
      );

  $$InvoicesTableProcessedTableManager get invoiceId {
    final $_column = $_itemColumn<String>('invoice_id')!;

    final manager = $$InvoicesTableTableManager(
      $_db,
      $_db.invoices,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_invoiceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$InvoicePaymentsTableFilterComposer
    extends Composer<_$AppDatabase, $InvoicePaymentsTable> {
  $$InvoicePaymentsTableFilterComposer({
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

  ColumnFilters<String> get shopId => $composableBuilder(
    column: $table.shopId,
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

  ColumnFilters<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountPaise => $composableBuilder(
    column: $table.amountPaise,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ref => $composableBuilder(
    column: $table.ref,
    builder: (column) => ColumnFilters(column),
  );

  $$InvoicesTableFilterComposer get invoiceId {
    final $$InvoicesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.invoiceId,
      referencedTable: $db.invoices,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InvoicesTableFilterComposer(
            $db: $db,
            $table: $db.invoices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$InvoicePaymentsTableOrderingComposer
    extends Composer<_$AppDatabase, $InvoicePaymentsTable> {
  $$InvoicePaymentsTableOrderingComposer({
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

  ColumnOrderings<String> get shopId => $composableBuilder(
    column: $table.shopId,
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

  ColumnOrderings<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountPaise => $composableBuilder(
    column: $table.amountPaise,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ref => $composableBuilder(
    column: $table.ref,
    builder: (column) => ColumnOrderings(column),
  );

  $$InvoicesTableOrderingComposer get invoiceId {
    final $$InvoicesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.invoiceId,
      referencedTable: $db.invoices,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InvoicesTableOrderingComposer(
            $db: $db,
            $table: $db.invoices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$InvoicePaymentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $InvoicePaymentsTable> {
  $$InvoicePaymentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get shopId =>
      $composableBuilder(column: $table.shopId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get mode =>
      $composableBuilder(column: $table.mode, builder: (column) => column);

  GeneratedColumn<int> get amountPaise => $composableBuilder(
    column: $table.amountPaise,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ref =>
      $composableBuilder(column: $table.ref, builder: (column) => column);

  $$InvoicesTableAnnotationComposer get invoiceId {
    final $$InvoicesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.invoiceId,
      referencedTable: $db.invoices,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InvoicesTableAnnotationComposer(
            $db: $db,
            $table: $db.invoices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$InvoicePaymentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $InvoicePaymentsTable,
          InvoicePayment,
          $$InvoicePaymentsTableFilterComposer,
          $$InvoicePaymentsTableOrderingComposer,
          $$InvoicePaymentsTableAnnotationComposer,
          $$InvoicePaymentsTableCreateCompanionBuilder,
          $$InvoicePaymentsTableUpdateCompanionBuilder,
          (InvoicePayment, $$InvoicePaymentsTableReferences),
          InvoicePayment,
          PrefetchHooks Function({bool invoiceId})
        > {
  $$InvoicePaymentsTableTableManager(
    _$AppDatabase db,
    $InvoicePaymentsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () =>
                  $$InvoicePaymentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$InvoicePaymentsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer:
              () => $$InvoicePaymentsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> shopId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> invoiceId = const Value.absent(),
                Value<String> mode = const Value.absent(),
                Value<int> amountPaise = const Value.absent(),
                Value<String?> ref = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InvoicePaymentsCompanion(
                id: id,
                shopId: shopId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                invoiceId: invoiceId,
                mode: mode,
                amountPaise: amountPaise,
                ref: ref,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String shopId,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                required String invoiceId,
                required String mode,
                required int amountPaise,
                Value<String?> ref = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InvoicePaymentsCompanion.insert(
                id: id,
                shopId: shopId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                invoiceId: invoiceId,
                mode: mode,
                amountPaise: amountPaise,
                ref: ref,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          $$InvoicePaymentsTableReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: ({invoiceId = false}) {
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
                  dynamic
                >
              >(state) {
                if (invoiceId) {
                  state =
                      state.withJoin(
                            currentTable: table,
                            currentColumn: table.invoiceId,
                            referencedTable: $$InvoicePaymentsTableReferences
                                ._invoiceIdTable(db),
                            referencedColumn:
                                $$InvoicePaymentsTableReferences
                                    ._invoiceIdTable(db)
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

typedef $$InvoicePaymentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $InvoicePaymentsTable,
      InvoicePayment,
      $$InvoicePaymentsTableFilterComposer,
      $$InvoicePaymentsTableOrderingComposer,
      $$InvoicePaymentsTableAnnotationComposer,
      $$InvoicePaymentsTableCreateCompanionBuilder,
      $$InvoicePaymentsTableUpdateCompanionBuilder,
      (InvoicePayment, $$InvoicePaymentsTableReferences),
      InvoicePayment,
      PrefetchHooks Function({bool invoiceId})
    >;
typedef $$SalesReturnsTableCreateCompanionBuilder =
    SalesReturnsCompanion Function({
      required String id,
      required String shopId,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      required String invoiceId,
      required DateTime date,
      required int totalPaise,
      Value<String?> note,
      Value<String?> createdBy,
      Value<int> rowid,
    });
typedef $$SalesReturnsTableUpdateCompanionBuilder =
    SalesReturnsCompanion Function({
      Value<String> id,
      Value<String> shopId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String> invoiceId,
      Value<DateTime> date,
      Value<int> totalPaise,
      Value<String?> note,
      Value<String?> createdBy,
      Value<int> rowid,
    });

final class $$SalesReturnsTableReferences
    extends BaseReferences<_$AppDatabase, $SalesReturnsTable, SalesReturn> {
  $$SalesReturnsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $InvoicesTable _invoiceIdTable(_$AppDatabase db) =>
      db.invoices.createAlias(
        $_aliasNameGenerator(db.salesReturns.invoiceId, db.invoices.id),
      );

  $$InvoicesTableProcessedTableManager get invoiceId {
    final $_column = $_itemColumn<String>('invoice_id')!;

    final manager = $$InvoicesTableTableManager(
      $_db,
      $_db.invoices,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_invoiceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$SalesReturnLinesTable, List<SalesReturnLine>>
  _salesReturnLinesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.salesReturnLines,
    aliasName: $_aliasNameGenerator(
      db.salesReturns.id,
      db.salesReturnLines.returnId,
    ),
  );

  $$SalesReturnLinesTableProcessedTableManager get salesReturnLinesRefs {
    final manager = $$SalesReturnLinesTableTableManager(
      $_db,
      $_db.salesReturnLines,
    ).filter((f) => f.returnId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _salesReturnLinesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SalesReturnsTableFilterComposer
    extends Composer<_$AppDatabase, $SalesReturnsTable> {
  $$SalesReturnsTableFilterComposer({
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

  ColumnFilters<String> get shopId => $composableBuilder(
    column: $table.shopId,
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

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalPaise => $composableBuilder(
    column: $table.totalPaise,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnFilters(column),
  );

  $$InvoicesTableFilterComposer get invoiceId {
    final $$InvoicesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.invoiceId,
      referencedTable: $db.invoices,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InvoicesTableFilterComposer(
            $db: $db,
            $table: $db.invoices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> salesReturnLinesRefs(
    Expression<bool> Function($$SalesReturnLinesTableFilterComposer f) f,
  ) {
    final $$SalesReturnLinesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.salesReturnLines,
      getReferencedColumn: (t) => t.returnId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SalesReturnLinesTableFilterComposer(
            $db: $db,
            $table: $db.salesReturnLines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SalesReturnsTableOrderingComposer
    extends Composer<_$AppDatabase, $SalesReturnsTable> {
  $$SalesReturnsTableOrderingComposer({
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

  ColumnOrderings<String> get shopId => $composableBuilder(
    column: $table.shopId,
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

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalPaise => $composableBuilder(
    column: $table.totalPaise,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnOrderings(column),
  );

  $$InvoicesTableOrderingComposer get invoiceId {
    final $$InvoicesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.invoiceId,
      referencedTable: $db.invoices,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InvoicesTableOrderingComposer(
            $db: $db,
            $table: $db.invoices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SalesReturnsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SalesReturnsTable> {
  $$SalesReturnsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get shopId =>
      $composableBuilder(column: $table.shopId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<int> get totalPaise => $composableBuilder(
    column: $table.totalPaise,
    builder: (column) => column,
  );

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<String> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => column);

  $$InvoicesTableAnnotationComposer get invoiceId {
    final $$InvoicesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.invoiceId,
      referencedTable: $db.invoices,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InvoicesTableAnnotationComposer(
            $db: $db,
            $table: $db.invoices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> salesReturnLinesRefs<T extends Object>(
    Expression<T> Function($$SalesReturnLinesTableAnnotationComposer a) f,
  ) {
    final $$SalesReturnLinesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.salesReturnLines,
      getReferencedColumn: (t) => t.returnId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SalesReturnLinesTableAnnotationComposer(
            $db: $db,
            $table: $db.salesReturnLines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SalesReturnsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SalesReturnsTable,
          SalesReturn,
          $$SalesReturnsTableFilterComposer,
          $$SalesReturnsTableOrderingComposer,
          $$SalesReturnsTableAnnotationComposer,
          $$SalesReturnsTableCreateCompanionBuilder,
          $$SalesReturnsTableUpdateCompanionBuilder,
          (SalesReturn, $$SalesReturnsTableReferences),
          SalesReturn,
          PrefetchHooks Function({bool invoiceId, bool salesReturnLinesRefs})
        > {
  $$SalesReturnsTableTableManager(_$AppDatabase db, $SalesReturnsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$SalesReturnsTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$SalesReturnsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () =>
                  $$SalesReturnsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> shopId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> invoiceId = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<int> totalPaise = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<String?> createdBy = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SalesReturnsCompanion(
                id: id,
                shopId: shopId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                invoiceId: invoiceId,
                date: date,
                totalPaise: totalPaise,
                note: note,
                createdBy: createdBy,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String shopId,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                required String invoiceId,
                required DateTime date,
                required int totalPaise,
                Value<String?> note = const Value.absent(),
                Value<String?> createdBy = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SalesReturnsCompanion.insert(
                id: id,
                shopId: shopId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                invoiceId: invoiceId,
                date: date,
                totalPaise: totalPaise,
                note: note,
                createdBy: createdBy,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          $$SalesReturnsTableReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: ({
            invoiceId = false,
            salesReturnLinesRefs = false,
          }) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (salesReturnLinesRefs) db.salesReturnLines,
              ],
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
                  dynamic
                >
              >(state) {
                if (invoiceId) {
                  state =
                      state.withJoin(
                            currentTable: table,
                            currentColumn: table.invoiceId,
                            referencedTable: $$SalesReturnsTableReferences
                                ._invoiceIdTable(db),
                            referencedColumn:
                                $$SalesReturnsTableReferences
                                    ._invoiceIdTable(db)
                                    .id,
                          )
                          as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (salesReturnLinesRefs)
                    await $_getPrefetchedData<
                      SalesReturn,
                      $SalesReturnsTable,
                      SalesReturnLine
                    >(
                      currentTable: table,
                      referencedTable: $$SalesReturnsTableReferences
                          ._salesReturnLinesRefsTable(db),
                      managerFromTypedResult:
                          (p0) =>
                              $$SalesReturnsTableReferences(
                                db,
                                table,
                                p0,
                              ).salesReturnLinesRefs,
                      referencedItemsForCurrentItem:
                          (item, referencedItems) => referencedItems.where(
                            (e) => e.returnId == item.id,
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

typedef $$SalesReturnsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SalesReturnsTable,
      SalesReturn,
      $$SalesReturnsTableFilterComposer,
      $$SalesReturnsTableOrderingComposer,
      $$SalesReturnsTableAnnotationComposer,
      $$SalesReturnsTableCreateCompanionBuilder,
      $$SalesReturnsTableUpdateCompanionBuilder,
      (SalesReturn, $$SalesReturnsTableReferences),
      SalesReturn,
      PrefetchHooks Function({bool invoiceId, bool salesReturnLinesRefs})
    >;
typedef $$SalesReturnLinesTableCreateCompanionBuilder =
    SalesReturnLinesCompanion Function({
      required String id,
      required String shopId,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      required String returnId,
      required String invoiceLineId,
      required String itemId,
      required int qtyBase,
      required int lineTotalPaise,
      Value<int> rowid,
    });
typedef $$SalesReturnLinesTableUpdateCompanionBuilder =
    SalesReturnLinesCompanion Function({
      Value<String> id,
      Value<String> shopId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String> returnId,
      Value<String> invoiceLineId,
      Value<String> itemId,
      Value<int> qtyBase,
      Value<int> lineTotalPaise,
      Value<int> rowid,
    });

final class $$SalesReturnLinesTableReferences
    extends
        BaseReferences<_$AppDatabase, $SalesReturnLinesTable, SalesReturnLine> {
  $$SalesReturnLinesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $SalesReturnsTable _returnIdTable(_$AppDatabase db) =>
      db.salesReturns.createAlias(
        $_aliasNameGenerator(db.salesReturnLines.returnId, db.salesReturns.id),
      );

  $$SalesReturnsTableProcessedTableManager get returnId {
    final $_column = $_itemColumn<String>('return_id')!;

    final manager = $$SalesReturnsTableTableManager(
      $_db,
      $_db.salesReturns,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_returnIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $InvoiceLinesTable _invoiceLineIdTable(_$AppDatabase db) =>
      db.invoiceLines.createAlias(
        $_aliasNameGenerator(
          db.salesReturnLines.invoiceLineId,
          db.invoiceLines.id,
        ),
      );

  $$InvoiceLinesTableProcessedTableManager get invoiceLineId {
    final $_column = $_itemColumn<String>('invoice_line_id')!;

    final manager = $$InvoiceLinesTableTableManager(
      $_db,
      $_db.invoiceLines,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_invoiceLineIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ItemsTable _itemIdTable(_$AppDatabase db) => db.items.createAlias(
    $_aliasNameGenerator(db.salesReturnLines.itemId, db.items.id),
  );

  $$ItemsTableProcessedTableManager get itemId {
    final $_column = $_itemColumn<String>('item_id')!;

    final manager = $$ItemsTableTableManager(
      $_db,
      $_db.items,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_itemIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SalesReturnLinesTableFilterComposer
    extends Composer<_$AppDatabase, $SalesReturnLinesTable> {
  $$SalesReturnLinesTableFilterComposer({
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

  ColumnFilters<String> get shopId => $composableBuilder(
    column: $table.shopId,
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

  ColumnFilters<int> get qtyBase => $composableBuilder(
    column: $table.qtyBase,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lineTotalPaise => $composableBuilder(
    column: $table.lineTotalPaise,
    builder: (column) => ColumnFilters(column),
  );

  $$SalesReturnsTableFilterComposer get returnId {
    final $$SalesReturnsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.returnId,
      referencedTable: $db.salesReturns,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SalesReturnsTableFilterComposer(
            $db: $db,
            $table: $db.salesReturns,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$InvoiceLinesTableFilterComposer get invoiceLineId {
    final $$InvoiceLinesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.invoiceLineId,
      referencedTable: $db.invoiceLines,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InvoiceLinesTableFilterComposer(
            $db: $db,
            $table: $db.invoiceLines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ItemsTableFilterComposer get itemId {
    final $$ItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.itemId,
      referencedTable: $db.items,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ItemsTableFilterComposer(
            $db: $db,
            $table: $db.items,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SalesReturnLinesTableOrderingComposer
    extends Composer<_$AppDatabase, $SalesReturnLinesTable> {
  $$SalesReturnLinesTableOrderingComposer({
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

  ColumnOrderings<String> get shopId => $composableBuilder(
    column: $table.shopId,
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

  ColumnOrderings<int> get qtyBase => $composableBuilder(
    column: $table.qtyBase,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lineTotalPaise => $composableBuilder(
    column: $table.lineTotalPaise,
    builder: (column) => ColumnOrderings(column),
  );

  $$SalesReturnsTableOrderingComposer get returnId {
    final $$SalesReturnsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.returnId,
      referencedTable: $db.salesReturns,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SalesReturnsTableOrderingComposer(
            $db: $db,
            $table: $db.salesReturns,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$InvoiceLinesTableOrderingComposer get invoiceLineId {
    final $$InvoiceLinesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.invoiceLineId,
      referencedTable: $db.invoiceLines,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InvoiceLinesTableOrderingComposer(
            $db: $db,
            $table: $db.invoiceLines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ItemsTableOrderingComposer get itemId {
    final $$ItemsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.itemId,
      referencedTable: $db.items,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ItemsTableOrderingComposer(
            $db: $db,
            $table: $db.items,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SalesReturnLinesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SalesReturnLinesTable> {
  $$SalesReturnLinesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get shopId =>
      $composableBuilder(column: $table.shopId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get qtyBase =>
      $composableBuilder(column: $table.qtyBase, builder: (column) => column);

  GeneratedColumn<int> get lineTotalPaise => $composableBuilder(
    column: $table.lineTotalPaise,
    builder: (column) => column,
  );

  $$SalesReturnsTableAnnotationComposer get returnId {
    final $$SalesReturnsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.returnId,
      referencedTable: $db.salesReturns,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SalesReturnsTableAnnotationComposer(
            $db: $db,
            $table: $db.salesReturns,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$InvoiceLinesTableAnnotationComposer get invoiceLineId {
    final $$InvoiceLinesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.invoiceLineId,
      referencedTable: $db.invoiceLines,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InvoiceLinesTableAnnotationComposer(
            $db: $db,
            $table: $db.invoiceLines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ItemsTableAnnotationComposer get itemId {
    final $$ItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.itemId,
      referencedTable: $db.items,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.items,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SalesReturnLinesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SalesReturnLinesTable,
          SalesReturnLine,
          $$SalesReturnLinesTableFilterComposer,
          $$SalesReturnLinesTableOrderingComposer,
          $$SalesReturnLinesTableAnnotationComposer,
          $$SalesReturnLinesTableCreateCompanionBuilder,
          $$SalesReturnLinesTableUpdateCompanionBuilder,
          (SalesReturnLine, $$SalesReturnLinesTableReferences),
          SalesReturnLine,
          PrefetchHooks Function({
            bool returnId,
            bool invoiceLineId,
            bool itemId,
          })
        > {
  $$SalesReturnLinesTableTableManager(
    _$AppDatabase db,
    $SalesReturnLinesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () =>
                  $$SalesReturnLinesTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$SalesReturnLinesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer:
              () => $$SalesReturnLinesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> shopId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> returnId = const Value.absent(),
                Value<String> invoiceLineId = const Value.absent(),
                Value<String> itemId = const Value.absent(),
                Value<int> qtyBase = const Value.absent(),
                Value<int> lineTotalPaise = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SalesReturnLinesCompanion(
                id: id,
                shopId: shopId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                returnId: returnId,
                invoiceLineId: invoiceLineId,
                itemId: itemId,
                qtyBase: qtyBase,
                lineTotalPaise: lineTotalPaise,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String shopId,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                required String returnId,
                required String invoiceLineId,
                required String itemId,
                required int qtyBase,
                required int lineTotalPaise,
                Value<int> rowid = const Value.absent(),
              }) => SalesReturnLinesCompanion.insert(
                id: id,
                shopId: shopId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                returnId: returnId,
                invoiceLineId: invoiceLineId,
                itemId: itemId,
                qtyBase: qtyBase,
                lineTotalPaise: lineTotalPaise,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          $$SalesReturnLinesTableReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: ({
            returnId = false,
            invoiceLineId = false,
            itemId = false,
          }) {
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
                  dynamic
                >
              >(state) {
                if (returnId) {
                  state =
                      state.withJoin(
                            currentTable: table,
                            currentColumn: table.returnId,
                            referencedTable: $$SalesReturnLinesTableReferences
                                ._returnIdTable(db),
                            referencedColumn:
                                $$SalesReturnLinesTableReferences
                                    ._returnIdTable(db)
                                    .id,
                          )
                          as T;
                }
                if (invoiceLineId) {
                  state =
                      state.withJoin(
                            currentTable: table,
                            currentColumn: table.invoiceLineId,
                            referencedTable: $$SalesReturnLinesTableReferences
                                ._invoiceLineIdTable(db),
                            referencedColumn:
                                $$SalesReturnLinesTableReferences
                                    ._invoiceLineIdTable(db)
                                    .id,
                          )
                          as T;
                }
                if (itemId) {
                  state =
                      state.withJoin(
                            currentTable: table,
                            currentColumn: table.itemId,
                            referencedTable: $$SalesReturnLinesTableReferences
                                ._itemIdTable(db),
                            referencedColumn:
                                $$SalesReturnLinesTableReferences
                                    ._itemIdTable(db)
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

typedef $$SalesReturnLinesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SalesReturnLinesTable,
      SalesReturnLine,
      $$SalesReturnLinesTableFilterComposer,
      $$SalesReturnLinesTableOrderingComposer,
      $$SalesReturnLinesTableAnnotationComposer,
      $$SalesReturnLinesTableCreateCompanionBuilder,
      $$SalesReturnLinesTableUpdateCompanionBuilder,
      (SalesReturnLine, $$SalesReturnLinesTableReferences),
      SalesReturnLine,
      PrefetchHooks Function({bool returnId, bool invoiceLineId, bool itemId})
    >;
typedef $$PurchasesTableCreateCompanionBuilder =
    PurchasesCompanion Function({
      required String id,
      required String shopId,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      required String supplierId,
      required String supplierInvoiceNo,
      required DateTime supplierInvoiceDate,
      required int subtotalPaise,
      required int taxPaise,
      required int totalPaise,
      Value<String> source,
      Value<String?> photoId,
      Value<String> status,
      Value<int> rowid,
    });
typedef $$PurchasesTableUpdateCompanionBuilder =
    PurchasesCompanion Function({
      Value<String> id,
      Value<String> shopId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String> supplierId,
      Value<String> supplierInvoiceNo,
      Value<DateTime> supplierInvoiceDate,
      Value<int> subtotalPaise,
      Value<int> taxPaise,
      Value<int> totalPaise,
      Value<String> source,
      Value<String?> photoId,
      Value<String> status,
      Value<int> rowid,
    });

final class $$PurchasesTableReferences
    extends BaseReferences<_$AppDatabase, $PurchasesTable, Purchase> {
  $$PurchasesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $PartiesTable _supplierIdTable(_$AppDatabase db) =>
      db.parties.createAlias(
        $_aliasNameGenerator(db.purchases.supplierId, db.parties.id),
      );

  $$PartiesTableProcessedTableManager get supplierId {
    final $_column = $_itemColumn<String>('supplier_id')!;

    final manager = $$PartiesTableTableManager(
      $_db,
      $_db.parties,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_supplierIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$PurchaseLinesTable, List<PurchaseLine>>
  _purchaseLinesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.purchaseLines,
    aliasName: $_aliasNameGenerator(
      db.purchases.id,
      db.purchaseLines.purchaseId,
    ),
  );

  $$PurchaseLinesTableProcessedTableManager get purchaseLinesRefs {
    final manager = $$PurchaseLinesTableTableManager(
      $_db,
      $_db.purchaseLines,
    ).filter((f) => f.purchaseId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_purchaseLinesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PurchasesTableFilterComposer
    extends Composer<_$AppDatabase, $PurchasesTable> {
  $$PurchasesTableFilterComposer({
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

  ColumnFilters<String> get shopId => $composableBuilder(
    column: $table.shopId,
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

  ColumnFilters<String> get supplierInvoiceNo => $composableBuilder(
    column: $table.supplierInvoiceNo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get supplierInvoiceDate => $composableBuilder(
    column: $table.supplierInvoiceDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get subtotalPaise => $composableBuilder(
    column: $table.subtotalPaise,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get taxPaise => $composableBuilder(
    column: $table.taxPaise,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalPaise => $composableBuilder(
    column: $table.totalPaise,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get photoId => $composableBuilder(
    column: $table.photoId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  $$PartiesTableFilterComposer get supplierId {
    final $$PartiesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.supplierId,
      referencedTable: $db.parties,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PartiesTableFilterComposer(
            $db: $db,
            $table: $db.parties,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> purchaseLinesRefs(
    Expression<bool> Function($$PurchaseLinesTableFilterComposer f) f,
  ) {
    final $$PurchaseLinesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.purchaseLines,
      getReferencedColumn: (t) => t.purchaseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PurchaseLinesTableFilterComposer(
            $db: $db,
            $table: $db.purchaseLines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PurchasesTableOrderingComposer
    extends Composer<_$AppDatabase, $PurchasesTable> {
  $$PurchasesTableOrderingComposer({
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

  ColumnOrderings<String> get shopId => $composableBuilder(
    column: $table.shopId,
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

  ColumnOrderings<String> get supplierInvoiceNo => $composableBuilder(
    column: $table.supplierInvoiceNo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get supplierInvoiceDate => $composableBuilder(
    column: $table.supplierInvoiceDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get subtotalPaise => $composableBuilder(
    column: $table.subtotalPaise,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get taxPaise => $composableBuilder(
    column: $table.taxPaise,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalPaise => $composableBuilder(
    column: $table.totalPaise,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get photoId => $composableBuilder(
    column: $table.photoId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  $$PartiesTableOrderingComposer get supplierId {
    final $$PartiesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.supplierId,
      referencedTable: $db.parties,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PartiesTableOrderingComposer(
            $db: $db,
            $table: $db.parties,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PurchasesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PurchasesTable> {
  $$PurchasesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get shopId =>
      $composableBuilder(column: $table.shopId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get supplierInvoiceNo => $composableBuilder(
    column: $table.supplierInvoiceNo,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get supplierInvoiceDate => $composableBuilder(
    column: $table.supplierInvoiceDate,
    builder: (column) => column,
  );

  GeneratedColumn<int> get subtotalPaise => $composableBuilder(
    column: $table.subtotalPaise,
    builder: (column) => column,
  );

  GeneratedColumn<int> get taxPaise =>
      $composableBuilder(column: $table.taxPaise, builder: (column) => column);

  GeneratedColumn<int> get totalPaise => $composableBuilder(
    column: $table.totalPaise,
    builder: (column) => column,
  );

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get photoId =>
      $composableBuilder(column: $table.photoId, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  $$PartiesTableAnnotationComposer get supplierId {
    final $$PartiesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.supplierId,
      referencedTable: $db.parties,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PartiesTableAnnotationComposer(
            $db: $db,
            $table: $db.parties,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> purchaseLinesRefs<T extends Object>(
    Expression<T> Function($$PurchaseLinesTableAnnotationComposer a) f,
  ) {
    final $$PurchaseLinesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.purchaseLines,
      getReferencedColumn: (t) => t.purchaseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PurchaseLinesTableAnnotationComposer(
            $db: $db,
            $table: $db.purchaseLines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PurchasesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PurchasesTable,
          Purchase,
          $$PurchasesTableFilterComposer,
          $$PurchasesTableOrderingComposer,
          $$PurchasesTableAnnotationComposer,
          $$PurchasesTableCreateCompanionBuilder,
          $$PurchasesTableUpdateCompanionBuilder,
          (Purchase, $$PurchasesTableReferences),
          Purchase,
          PrefetchHooks Function({bool supplierId, bool purchaseLinesRefs})
        > {
  $$PurchasesTableTableManager(_$AppDatabase db, $PurchasesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$PurchasesTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$PurchasesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$PurchasesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> shopId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> supplierId = const Value.absent(),
                Value<String> supplierInvoiceNo = const Value.absent(),
                Value<DateTime> supplierInvoiceDate = const Value.absent(),
                Value<int> subtotalPaise = const Value.absent(),
                Value<int> taxPaise = const Value.absent(),
                Value<int> totalPaise = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<String?> photoId = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PurchasesCompanion(
                id: id,
                shopId: shopId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                supplierId: supplierId,
                supplierInvoiceNo: supplierInvoiceNo,
                supplierInvoiceDate: supplierInvoiceDate,
                subtotalPaise: subtotalPaise,
                taxPaise: taxPaise,
                totalPaise: totalPaise,
                source: source,
                photoId: photoId,
                status: status,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String shopId,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                required String supplierId,
                required String supplierInvoiceNo,
                required DateTime supplierInvoiceDate,
                required int subtotalPaise,
                required int taxPaise,
                required int totalPaise,
                Value<String> source = const Value.absent(),
                Value<String?> photoId = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PurchasesCompanion.insert(
                id: id,
                shopId: shopId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                supplierId: supplierId,
                supplierInvoiceNo: supplierInvoiceNo,
                supplierInvoiceDate: supplierInvoiceDate,
                subtotalPaise: subtotalPaise,
                taxPaise: taxPaise,
                totalPaise: totalPaise,
                source: source,
                photoId: photoId,
                status: status,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          $$PurchasesTableReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: ({
            supplierId = false,
            purchaseLinesRefs = false,
          }) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (purchaseLinesRefs) db.purchaseLines,
              ],
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
                  dynamic
                >
              >(state) {
                if (supplierId) {
                  state =
                      state.withJoin(
                            currentTable: table,
                            currentColumn: table.supplierId,
                            referencedTable: $$PurchasesTableReferences
                                ._supplierIdTable(db),
                            referencedColumn:
                                $$PurchasesTableReferences
                                    ._supplierIdTable(db)
                                    .id,
                          )
                          as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (purchaseLinesRefs)
                    await $_getPrefetchedData<
                      Purchase,
                      $PurchasesTable,
                      PurchaseLine
                    >(
                      currentTable: table,
                      referencedTable: $$PurchasesTableReferences
                          ._purchaseLinesRefsTable(db),
                      managerFromTypedResult:
                          (p0) =>
                              $$PurchasesTableReferences(
                                db,
                                table,
                                p0,
                              ).purchaseLinesRefs,
                      referencedItemsForCurrentItem:
                          (item, referencedItems) => referencedItems.where(
                            (e) => e.purchaseId == item.id,
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

typedef $$PurchasesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PurchasesTable,
      Purchase,
      $$PurchasesTableFilterComposer,
      $$PurchasesTableOrderingComposer,
      $$PurchasesTableAnnotationComposer,
      $$PurchasesTableCreateCompanionBuilder,
      $$PurchasesTableUpdateCompanionBuilder,
      (Purchase, $$PurchasesTableReferences),
      Purchase,
      PrefetchHooks Function({bool supplierId, bool purchaseLinesRefs})
    >;
typedef $$PurchaseLinesTableCreateCompanionBuilder =
    PurchaseLinesCompanion Function({
      required String id,
      required String shopId,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      required String purchaseId,
      required String itemId,
      Value<String?> variantId,
      required String unitName,
      required String qtyEntered,
      required int qtyBase,
      required int ratePaise,
      Value<int> priceUnitFactor,
      Value<int> gstRateBp,
      required int lineTotalPaise,
      Value<int> rowid,
    });
typedef $$PurchaseLinesTableUpdateCompanionBuilder =
    PurchaseLinesCompanion Function({
      Value<String> id,
      Value<String> shopId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String> purchaseId,
      Value<String> itemId,
      Value<String?> variantId,
      Value<String> unitName,
      Value<String> qtyEntered,
      Value<int> qtyBase,
      Value<int> ratePaise,
      Value<int> priceUnitFactor,
      Value<int> gstRateBp,
      Value<int> lineTotalPaise,
      Value<int> rowid,
    });

final class $$PurchaseLinesTableReferences
    extends BaseReferences<_$AppDatabase, $PurchaseLinesTable, PurchaseLine> {
  $$PurchaseLinesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $PurchasesTable _purchaseIdTable(_$AppDatabase db) =>
      db.purchases.createAlias(
        $_aliasNameGenerator(db.purchaseLines.purchaseId, db.purchases.id),
      );

  $$PurchasesTableProcessedTableManager get purchaseId {
    final $_column = $_itemColumn<String>('purchase_id')!;

    final manager = $$PurchasesTableTableManager(
      $_db,
      $_db.purchases,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_purchaseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ItemsTable _itemIdTable(_$AppDatabase db) => db.items.createAlias(
    $_aliasNameGenerator(db.purchaseLines.itemId, db.items.id),
  );

  $$ItemsTableProcessedTableManager get itemId {
    final $_column = $_itemColumn<String>('item_id')!;

    final manager = $$ItemsTableTableManager(
      $_db,
      $_db.items,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_itemIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ItemVariantsTable _variantIdTable(_$AppDatabase db) =>
      db.itemVariants.createAlias(
        $_aliasNameGenerator(db.purchaseLines.variantId, db.itemVariants.id),
      );

  $$ItemVariantsTableProcessedTableManager? get variantId {
    final $_column = $_itemColumn<String>('variant_id');
    if ($_column == null) return null;
    final manager = $$ItemVariantsTableTableManager(
      $_db,
      $_db.itemVariants,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_variantIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PurchaseLinesTableFilterComposer
    extends Composer<_$AppDatabase, $PurchaseLinesTable> {
  $$PurchaseLinesTableFilterComposer({
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

  ColumnFilters<String> get shopId => $composableBuilder(
    column: $table.shopId,
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

  ColumnFilters<String> get unitName => $composableBuilder(
    column: $table.unitName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get qtyEntered => $composableBuilder(
    column: $table.qtyEntered,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get qtyBase => $composableBuilder(
    column: $table.qtyBase,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ratePaise => $composableBuilder(
    column: $table.ratePaise,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get priceUnitFactor => $composableBuilder(
    column: $table.priceUnitFactor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get gstRateBp => $composableBuilder(
    column: $table.gstRateBp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lineTotalPaise => $composableBuilder(
    column: $table.lineTotalPaise,
    builder: (column) => ColumnFilters(column),
  );

  $$PurchasesTableFilterComposer get purchaseId {
    final $$PurchasesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.purchaseId,
      referencedTable: $db.purchases,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PurchasesTableFilterComposer(
            $db: $db,
            $table: $db.purchases,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ItemsTableFilterComposer get itemId {
    final $$ItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.itemId,
      referencedTable: $db.items,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ItemsTableFilterComposer(
            $db: $db,
            $table: $db.items,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ItemVariantsTableFilterComposer get variantId {
    final $$ItemVariantsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.variantId,
      referencedTable: $db.itemVariants,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ItemVariantsTableFilterComposer(
            $db: $db,
            $table: $db.itemVariants,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PurchaseLinesTableOrderingComposer
    extends Composer<_$AppDatabase, $PurchaseLinesTable> {
  $$PurchaseLinesTableOrderingComposer({
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

  ColumnOrderings<String> get shopId => $composableBuilder(
    column: $table.shopId,
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

  ColumnOrderings<String> get unitName => $composableBuilder(
    column: $table.unitName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get qtyEntered => $composableBuilder(
    column: $table.qtyEntered,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get qtyBase => $composableBuilder(
    column: $table.qtyBase,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ratePaise => $composableBuilder(
    column: $table.ratePaise,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get priceUnitFactor => $composableBuilder(
    column: $table.priceUnitFactor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get gstRateBp => $composableBuilder(
    column: $table.gstRateBp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lineTotalPaise => $composableBuilder(
    column: $table.lineTotalPaise,
    builder: (column) => ColumnOrderings(column),
  );

  $$PurchasesTableOrderingComposer get purchaseId {
    final $$PurchasesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.purchaseId,
      referencedTable: $db.purchases,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PurchasesTableOrderingComposer(
            $db: $db,
            $table: $db.purchases,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ItemsTableOrderingComposer get itemId {
    final $$ItemsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.itemId,
      referencedTable: $db.items,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ItemsTableOrderingComposer(
            $db: $db,
            $table: $db.items,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ItemVariantsTableOrderingComposer get variantId {
    final $$ItemVariantsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.variantId,
      referencedTable: $db.itemVariants,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ItemVariantsTableOrderingComposer(
            $db: $db,
            $table: $db.itemVariants,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PurchaseLinesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PurchaseLinesTable> {
  $$PurchaseLinesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get shopId =>
      $composableBuilder(column: $table.shopId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get unitName =>
      $composableBuilder(column: $table.unitName, builder: (column) => column);

  GeneratedColumn<String> get qtyEntered => $composableBuilder(
    column: $table.qtyEntered,
    builder: (column) => column,
  );

  GeneratedColumn<int> get qtyBase =>
      $composableBuilder(column: $table.qtyBase, builder: (column) => column);

  GeneratedColumn<int> get ratePaise =>
      $composableBuilder(column: $table.ratePaise, builder: (column) => column);

  GeneratedColumn<int> get priceUnitFactor => $composableBuilder(
    column: $table.priceUnitFactor,
    builder: (column) => column,
  );

  GeneratedColumn<int> get gstRateBp =>
      $composableBuilder(column: $table.gstRateBp, builder: (column) => column);

  GeneratedColumn<int> get lineTotalPaise => $composableBuilder(
    column: $table.lineTotalPaise,
    builder: (column) => column,
  );

  $$PurchasesTableAnnotationComposer get purchaseId {
    final $$PurchasesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.purchaseId,
      referencedTable: $db.purchases,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PurchasesTableAnnotationComposer(
            $db: $db,
            $table: $db.purchases,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ItemsTableAnnotationComposer get itemId {
    final $$ItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.itemId,
      referencedTable: $db.items,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.items,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ItemVariantsTableAnnotationComposer get variantId {
    final $$ItemVariantsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.variantId,
      referencedTable: $db.itemVariants,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ItemVariantsTableAnnotationComposer(
            $db: $db,
            $table: $db.itemVariants,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PurchaseLinesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PurchaseLinesTable,
          PurchaseLine,
          $$PurchaseLinesTableFilterComposer,
          $$PurchaseLinesTableOrderingComposer,
          $$PurchaseLinesTableAnnotationComposer,
          $$PurchaseLinesTableCreateCompanionBuilder,
          $$PurchaseLinesTableUpdateCompanionBuilder,
          (PurchaseLine, $$PurchaseLinesTableReferences),
          PurchaseLine,
          PrefetchHooks Function({bool purchaseId, bool itemId, bool variantId})
        > {
  $$PurchaseLinesTableTableManager(_$AppDatabase db, $PurchaseLinesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$PurchaseLinesTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () =>
                  $$PurchaseLinesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$PurchaseLinesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> shopId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> purchaseId = const Value.absent(),
                Value<String> itemId = const Value.absent(),
                Value<String?> variantId = const Value.absent(),
                Value<String> unitName = const Value.absent(),
                Value<String> qtyEntered = const Value.absent(),
                Value<int> qtyBase = const Value.absent(),
                Value<int> ratePaise = const Value.absent(),
                Value<int> priceUnitFactor = const Value.absent(),
                Value<int> gstRateBp = const Value.absent(),
                Value<int> lineTotalPaise = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PurchaseLinesCompanion(
                id: id,
                shopId: shopId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                purchaseId: purchaseId,
                itemId: itemId,
                variantId: variantId,
                unitName: unitName,
                qtyEntered: qtyEntered,
                qtyBase: qtyBase,
                ratePaise: ratePaise,
                priceUnitFactor: priceUnitFactor,
                gstRateBp: gstRateBp,
                lineTotalPaise: lineTotalPaise,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String shopId,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                required String purchaseId,
                required String itemId,
                Value<String?> variantId = const Value.absent(),
                required String unitName,
                required String qtyEntered,
                required int qtyBase,
                required int ratePaise,
                Value<int> priceUnitFactor = const Value.absent(),
                Value<int> gstRateBp = const Value.absent(),
                required int lineTotalPaise,
                Value<int> rowid = const Value.absent(),
              }) => PurchaseLinesCompanion.insert(
                id: id,
                shopId: shopId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                purchaseId: purchaseId,
                itemId: itemId,
                variantId: variantId,
                unitName: unitName,
                qtyEntered: qtyEntered,
                qtyBase: qtyBase,
                ratePaise: ratePaise,
                priceUnitFactor: priceUnitFactor,
                gstRateBp: gstRateBp,
                lineTotalPaise: lineTotalPaise,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          $$PurchaseLinesTableReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: ({
            purchaseId = false,
            itemId = false,
            variantId = false,
          }) {
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
                  dynamic
                >
              >(state) {
                if (purchaseId) {
                  state =
                      state.withJoin(
                            currentTable: table,
                            currentColumn: table.purchaseId,
                            referencedTable: $$PurchaseLinesTableReferences
                                ._purchaseIdTable(db),
                            referencedColumn:
                                $$PurchaseLinesTableReferences
                                    ._purchaseIdTable(db)
                                    .id,
                          )
                          as T;
                }
                if (itemId) {
                  state =
                      state.withJoin(
                            currentTable: table,
                            currentColumn: table.itemId,
                            referencedTable: $$PurchaseLinesTableReferences
                                ._itemIdTable(db),
                            referencedColumn:
                                $$PurchaseLinesTableReferences
                                    ._itemIdTable(db)
                                    .id,
                          )
                          as T;
                }
                if (variantId) {
                  state =
                      state.withJoin(
                            currentTable: table,
                            currentColumn: table.variantId,
                            referencedTable: $$PurchaseLinesTableReferences
                                ._variantIdTable(db),
                            referencedColumn:
                                $$PurchaseLinesTableReferences
                                    ._variantIdTable(db)
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

typedef $$PurchaseLinesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PurchaseLinesTable,
      PurchaseLine,
      $$PurchaseLinesTableFilterComposer,
      $$PurchaseLinesTableOrderingComposer,
      $$PurchaseLinesTableAnnotationComposer,
      $$PurchaseLinesTableCreateCompanionBuilder,
      $$PurchaseLinesTableUpdateCompanionBuilder,
      (PurchaseLine, $$PurchaseLinesTableReferences),
      PurchaseLine,
      PrefetchHooks Function({bool purchaseId, bool itemId, bool variantId})
    >;
typedef $$StockMovementsTableCreateCompanionBuilder =
    StockMovementsCompanion Function({
      required String id,
      required String shopId,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      required String itemId,
      Value<String?> variantId,
      required String locationId,
      required int qtyBase,
      required String movementType,
      Value<String?> refType,
      Value<String?> refId,
      required DateTime ts,
      Value<String?> createdBy,
      Value<String?> note,
      Value<int> rowid,
    });
typedef $$StockMovementsTableUpdateCompanionBuilder =
    StockMovementsCompanion Function({
      Value<String> id,
      Value<String> shopId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String> itemId,
      Value<String?> variantId,
      Value<String> locationId,
      Value<int> qtyBase,
      Value<String> movementType,
      Value<String?> refType,
      Value<String?> refId,
      Value<DateTime> ts,
      Value<String?> createdBy,
      Value<String?> note,
      Value<int> rowid,
    });

final class $$StockMovementsTableReferences
    extends BaseReferences<_$AppDatabase, $StockMovementsTable, StockMovement> {
  $$StockMovementsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ItemsTable _itemIdTable(_$AppDatabase db) => db.items.createAlias(
    $_aliasNameGenerator(db.stockMovements.itemId, db.items.id),
  );

  $$ItemsTableProcessedTableManager get itemId {
    final $_column = $_itemColumn<String>('item_id')!;

    final manager = $$ItemsTableTableManager(
      $_db,
      $_db.items,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_itemIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ItemVariantsTable _variantIdTable(_$AppDatabase db) =>
      db.itemVariants.createAlias(
        $_aliasNameGenerator(db.stockMovements.variantId, db.itemVariants.id),
      );

  $$ItemVariantsTableProcessedTableManager? get variantId {
    final $_column = $_itemColumn<String>('variant_id');
    if ($_column == null) return null;
    final manager = $$ItemVariantsTableTableManager(
      $_db,
      $_db.itemVariants,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_variantIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $LocationsTable _locationIdTable(_$AppDatabase db) =>
      db.locations.createAlias(
        $_aliasNameGenerator(db.stockMovements.locationId, db.locations.id),
      );

  $$LocationsTableProcessedTableManager get locationId {
    final $_column = $_itemColumn<String>('location_id')!;

    final manager = $$LocationsTableTableManager(
      $_db,
      $_db.locations,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_locationIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$StockMovementsTableFilterComposer
    extends Composer<_$AppDatabase, $StockMovementsTable> {
  $$StockMovementsTableFilterComposer({
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

  ColumnFilters<String> get shopId => $composableBuilder(
    column: $table.shopId,
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

  ColumnFilters<int> get qtyBase => $composableBuilder(
    column: $table.qtyBase,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get movementType => $composableBuilder(
    column: $table.movementType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get refType => $composableBuilder(
    column: $table.refType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get refId => $composableBuilder(
    column: $table.refId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get ts => $composableBuilder(
    column: $table.ts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  $$ItemsTableFilterComposer get itemId {
    final $$ItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.itemId,
      referencedTable: $db.items,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ItemsTableFilterComposer(
            $db: $db,
            $table: $db.items,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ItemVariantsTableFilterComposer get variantId {
    final $$ItemVariantsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.variantId,
      referencedTable: $db.itemVariants,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ItemVariantsTableFilterComposer(
            $db: $db,
            $table: $db.itemVariants,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$LocationsTableFilterComposer get locationId {
    final $$LocationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.locationId,
      referencedTable: $db.locations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocationsTableFilterComposer(
            $db: $db,
            $table: $db.locations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$StockMovementsTableOrderingComposer
    extends Composer<_$AppDatabase, $StockMovementsTable> {
  $$StockMovementsTableOrderingComposer({
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

  ColumnOrderings<String> get shopId => $composableBuilder(
    column: $table.shopId,
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

  ColumnOrderings<int> get qtyBase => $composableBuilder(
    column: $table.qtyBase,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get movementType => $composableBuilder(
    column: $table.movementType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get refType => $composableBuilder(
    column: $table.refType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get refId => $composableBuilder(
    column: $table.refId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get ts => $composableBuilder(
    column: $table.ts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  $$ItemsTableOrderingComposer get itemId {
    final $$ItemsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.itemId,
      referencedTable: $db.items,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ItemsTableOrderingComposer(
            $db: $db,
            $table: $db.items,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ItemVariantsTableOrderingComposer get variantId {
    final $$ItemVariantsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.variantId,
      referencedTable: $db.itemVariants,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ItemVariantsTableOrderingComposer(
            $db: $db,
            $table: $db.itemVariants,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$LocationsTableOrderingComposer get locationId {
    final $$LocationsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.locationId,
      referencedTable: $db.locations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocationsTableOrderingComposer(
            $db: $db,
            $table: $db.locations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$StockMovementsTableAnnotationComposer
    extends Composer<_$AppDatabase, $StockMovementsTable> {
  $$StockMovementsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get shopId =>
      $composableBuilder(column: $table.shopId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get qtyBase =>
      $composableBuilder(column: $table.qtyBase, builder: (column) => column);

  GeneratedColumn<String> get movementType => $composableBuilder(
    column: $table.movementType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get refType =>
      $composableBuilder(column: $table.refType, builder: (column) => column);

  GeneratedColumn<String> get refId =>
      $composableBuilder(column: $table.refId, builder: (column) => column);

  GeneratedColumn<DateTime> get ts =>
      $composableBuilder(column: $table.ts, builder: (column) => column);

  GeneratedColumn<String> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  $$ItemsTableAnnotationComposer get itemId {
    final $$ItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.itemId,
      referencedTable: $db.items,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.items,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ItemVariantsTableAnnotationComposer get variantId {
    final $$ItemVariantsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.variantId,
      referencedTable: $db.itemVariants,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ItemVariantsTableAnnotationComposer(
            $db: $db,
            $table: $db.itemVariants,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$LocationsTableAnnotationComposer get locationId {
    final $$LocationsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.locationId,
      referencedTable: $db.locations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocationsTableAnnotationComposer(
            $db: $db,
            $table: $db.locations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$StockMovementsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StockMovementsTable,
          StockMovement,
          $$StockMovementsTableFilterComposer,
          $$StockMovementsTableOrderingComposer,
          $$StockMovementsTableAnnotationComposer,
          $$StockMovementsTableCreateCompanionBuilder,
          $$StockMovementsTableUpdateCompanionBuilder,
          (StockMovement, $$StockMovementsTableReferences),
          StockMovement,
          PrefetchHooks Function({bool itemId, bool variantId, bool locationId})
        > {
  $$StockMovementsTableTableManager(
    _$AppDatabase db,
    $StockMovementsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$StockMovementsTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () =>
                  $$StockMovementsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$StockMovementsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> shopId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> itemId = const Value.absent(),
                Value<String?> variantId = const Value.absent(),
                Value<String> locationId = const Value.absent(),
                Value<int> qtyBase = const Value.absent(),
                Value<String> movementType = const Value.absent(),
                Value<String?> refType = const Value.absent(),
                Value<String?> refId = const Value.absent(),
                Value<DateTime> ts = const Value.absent(),
                Value<String?> createdBy = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StockMovementsCompanion(
                id: id,
                shopId: shopId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                itemId: itemId,
                variantId: variantId,
                locationId: locationId,
                qtyBase: qtyBase,
                movementType: movementType,
                refType: refType,
                refId: refId,
                ts: ts,
                createdBy: createdBy,
                note: note,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String shopId,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                required String itemId,
                Value<String?> variantId = const Value.absent(),
                required String locationId,
                required int qtyBase,
                required String movementType,
                Value<String?> refType = const Value.absent(),
                Value<String?> refId = const Value.absent(),
                required DateTime ts,
                Value<String?> createdBy = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StockMovementsCompanion.insert(
                id: id,
                shopId: shopId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                itemId: itemId,
                variantId: variantId,
                locationId: locationId,
                qtyBase: qtyBase,
                movementType: movementType,
                refType: refType,
                refId: refId,
                ts: ts,
                createdBy: createdBy,
                note: note,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          $$StockMovementsTableReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: ({
            itemId = false,
            variantId = false,
            locationId = false,
          }) {
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
                  dynamic
                >
              >(state) {
                if (itemId) {
                  state =
                      state.withJoin(
                            currentTable: table,
                            currentColumn: table.itemId,
                            referencedTable: $$StockMovementsTableReferences
                                ._itemIdTable(db),
                            referencedColumn:
                                $$StockMovementsTableReferences
                                    ._itemIdTable(db)
                                    .id,
                          )
                          as T;
                }
                if (variantId) {
                  state =
                      state.withJoin(
                            currentTable: table,
                            currentColumn: table.variantId,
                            referencedTable: $$StockMovementsTableReferences
                                ._variantIdTable(db),
                            referencedColumn:
                                $$StockMovementsTableReferences
                                    ._variantIdTable(db)
                                    .id,
                          )
                          as T;
                }
                if (locationId) {
                  state =
                      state.withJoin(
                            currentTable: table,
                            currentColumn: table.locationId,
                            referencedTable: $$StockMovementsTableReferences
                                ._locationIdTable(db),
                            referencedColumn:
                                $$StockMovementsTableReferences
                                    ._locationIdTable(db)
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

typedef $$StockMovementsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StockMovementsTable,
      StockMovement,
      $$StockMovementsTableFilterComposer,
      $$StockMovementsTableOrderingComposer,
      $$StockMovementsTableAnnotationComposer,
      $$StockMovementsTableCreateCompanionBuilder,
      $$StockMovementsTableUpdateCompanionBuilder,
      (StockMovement, $$StockMovementsTableReferences),
      StockMovement,
      PrefetchHooks Function({bool itemId, bool variantId, bool locationId})
    >;
typedef $$AuditLogTableCreateCompanionBuilder =
    AuditLogCompanion Function({
      required String id,
      required String shopId,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<String?> userId,
      required String action,
      required String entity,
      required String entityId,
      Value<String?> beforeJson,
      Value<String?> afterJson,
      required DateTime ts,
      Value<int> rowid,
    });
typedef $$AuditLogTableUpdateCompanionBuilder =
    AuditLogCompanion Function({
      Value<String> id,
      Value<String> shopId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String?> userId,
      Value<String> action,
      Value<String> entity,
      Value<String> entityId,
      Value<String?> beforeJson,
      Value<String?> afterJson,
      Value<DateTime> ts,
      Value<int> rowid,
    });

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

  ColumnFilters<String> get shopId => $composableBuilder(
    column: $table.shopId,
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

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get action => $composableBuilder(
    column: $table.action,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entity => $composableBuilder(
    column: $table.entity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get beforeJson => $composableBuilder(
    column: $table.beforeJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get afterJson => $composableBuilder(
    column: $table.afterJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get ts => $composableBuilder(
    column: $table.ts,
    builder: (column) => ColumnFilters(column),
  );
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

  ColumnOrderings<String> get shopId => $composableBuilder(
    column: $table.shopId,
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

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get action => $composableBuilder(
    column: $table.action,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entity => $composableBuilder(
    column: $table.entity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get beforeJson => $composableBuilder(
    column: $table.beforeJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get afterJson => $composableBuilder(
    column: $table.afterJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get ts => $composableBuilder(
    column: $table.ts,
    builder: (column) => ColumnOrderings(column),
  );
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

  GeneratedColumn<String> get shopId =>
      $composableBuilder(column: $table.shopId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get action =>
      $composableBuilder(column: $table.action, builder: (column) => column);

  GeneratedColumn<String> get entity =>
      $composableBuilder(column: $table.entity, builder: (column) => column);

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get beforeJson => $composableBuilder(
    column: $table.beforeJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get afterJson =>
      $composableBuilder(column: $table.afterJson, builder: (column) => column);

  GeneratedColumn<DateTime> get ts =>
      $composableBuilder(column: $table.ts, builder: (column) => column);
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
          (
            AuditLogData,
            BaseReferences<_$AppDatabase, $AuditLogTable, AuditLogData>,
          ),
          AuditLogData,
          PrefetchHooks Function()
        > {
  $$AuditLogTableTableManager(_$AppDatabase db, $AuditLogTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$AuditLogTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$AuditLogTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$AuditLogTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> shopId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String?> userId = const Value.absent(),
                Value<String> action = const Value.absent(),
                Value<String> entity = const Value.absent(),
                Value<String> entityId = const Value.absent(),
                Value<String?> beforeJson = const Value.absent(),
                Value<String?> afterJson = const Value.absent(),
                Value<DateTime> ts = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AuditLogCompanion(
                id: id,
                shopId: shopId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                userId: userId,
                action: action,
                entity: entity,
                entityId: entityId,
                beforeJson: beforeJson,
                afterJson: afterJson,
                ts: ts,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String shopId,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String?> userId = const Value.absent(),
                required String action,
                required String entity,
                required String entityId,
                Value<String?> beforeJson = const Value.absent(),
                Value<String?> afterJson = const Value.absent(),
                required DateTime ts,
                Value<int> rowid = const Value.absent(),
              }) => AuditLogCompanion.insert(
                id: id,
                shopId: shopId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                userId: userId,
                action: action,
                entity: entity,
                entityId: entityId,
                beforeJson: beforeJson,
                afterJson: afterJson,
                ts: ts,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
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
      (
        AuditLogData,
        BaseReferences<_$AppDatabase, $AuditLogTable, AuditLogData>,
      ),
      AuditLogData,
      PrefetchHooks Function()
    >;
typedef $$AppSettingsTableCreateCompanionBuilder =
    AppSettingsCompanion Function({
      required String id,
      required String shopId,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$AppSettingsTableUpdateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<String> id,
      Value<String> shopId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String> key,
      Value<String> value,
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
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get shopId => $composableBuilder(
    column: $table.shopId,
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

  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
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
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get shopId => $composableBuilder(
    column: $table.shopId,
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

  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
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
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get shopId =>
      $composableBuilder(column: $table.shopId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$AppSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppSettingsTable,
          AppSetting,
          $$AppSettingsTableFilterComposer,
          $$AppSettingsTableOrderingComposer,
          $$AppSettingsTableAnnotationComposer,
          $$AppSettingsTableCreateCompanionBuilder,
          $$AppSettingsTableUpdateCompanionBuilder,
          (
            AppSetting,
            BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
          ),
          AppSetting,
          PrefetchHooks Function()
        > {
  $$AppSettingsTableTableManager(_$AppDatabase db, $AppSettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$AppSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$AppSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () =>
                  $$AppSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> shopId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion(
                id: id,
                shopId: shopId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                key: key,
                value: value,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String shopId,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion.insert(
                id: id,
                shopId: shopId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
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
      AppSetting,
      $$AppSettingsTableFilterComposer,
      $$AppSettingsTableOrderingComposer,
      $$AppSettingsTableAnnotationComposer,
      $$AppSettingsTableCreateCompanionBuilder,
      $$AppSettingsTableUpdateCompanionBuilder,
      (
        AppSetting,
        BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
      ),
      AppSetting,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ShopsTableTableManager get shops =>
      $$ShopsTableTableManager(_db, _db.shops);
  $$UsersTableTableManager get users =>
      $$UsersTableTableManager(_db, _db.users);
  $$DevicesTableTableManager get devices =>
      $$DevicesTableTableManager(_db, _db.devices);
  $$LocationsTableTableManager get locations =>
      $$LocationsTableTableManager(_db, _db.locations);
  $$OutboxTableTableManager get outbox =>
      $$OutboxTableTableManager(_db, _db.outbox);
  $$ItemsTableTableManager get items =>
      $$ItemsTableTableManager(_db, _db.items);
  $$ItemUnitsTableTableManager get itemUnits =>
      $$ItemUnitsTableTableManager(_db, _db.itemUnits);
  $$ItemVariantsTableTableManager get itemVariants =>
      $$ItemVariantsTableTableManager(_db, _db.itemVariants);
  $$ItemPricesTableTableManager get itemPrices =>
      $$ItemPricesTableTableManager(_db, _db.itemPrices);
  $$ItemCostsTableTableManager get itemCosts =>
      $$ItemCostsTableTableManager(_db, _db.itemCosts);
  $$PartiesTableTableManager get parties =>
      $$PartiesTableTableManager(_db, _db.parties);
  $$LedgerEntriesTableTableManager get ledgerEntries =>
      $$LedgerEntriesTableTableManager(_db, _db.ledgerEntries);
  $$InvoicesTableTableManager get invoices =>
      $$InvoicesTableTableManager(_db, _db.invoices);
  $$InvoiceLinesTableTableManager get invoiceLines =>
      $$InvoiceLinesTableTableManager(_db, _db.invoiceLines);
  $$InvoicePaymentsTableTableManager get invoicePayments =>
      $$InvoicePaymentsTableTableManager(_db, _db.invoicePayments);
  $$SalesReturnsTableTableManager get salesReturns =>
      $$SalesReturnsTableTableManager(_db, _db.salesReturns);
  $$SalesReturnLinesTableTableManager get salesReturnLines =>
      $$SalesReturnLinesTableTableManager(_db, _db.salesReturnLines);
  $$PurchasesTableTableManager get purchases =>
      $$PurchasesTableTableManager(_db, _db.purchases);
  $$PurchaseLinesTableTableManager get purchaseLines =>
      $$PurchaseLinesTableTableManager(_db, _db.purchaseLines);
  $$StockMovementsTableTableManager get stockMovements =>
      $$StockMovementsTableTableManager(_db, _db.stockMovements);
  $$AuditLogTableTableManager get auditLog =>
      $$AuditLogTableTableManager(_db, _db.auditLog);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
}
