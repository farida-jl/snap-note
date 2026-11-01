// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $SavedItemsTable extends SavedItems
    with TableInfo<$SavedItemsTable, SavedItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SavedItemsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _displayTimeMeta = const VerificationMeta(
    'displayTime',
  );
  @override
  late final GeneratedColumn<String> displayTime = GeneratedColumn<String>(
    'display_time',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _durationMeta = const VerificationMeta(
    'duration',
  );
  @override
  late final GeneratedColumn<String> duration = GeneratedColumn<String>(
    'duration',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _imageAssetMeta = const VerificationMeta(
    'imageAsset',
  );
  @override
  late final GeneratedColumn<String> imageAsset = GeneratedColumn<String>(
    'image_asset',
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
    type,
    title,
    description,
    source,
    displayTime,
    duration,
    imageAsset,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'saved_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<SavedItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
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
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    }
    if (data.containsKey('display_time')) {
      context.handle(
        _displayTimeMeta,
        displayTime.isAcceptableOrUnknown(
          data['display_time']!,
          _displayTimeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_displayTimeMeta);
    }
    if (data.containsKey('duration')) {
      context.handle(
        _durationMeta,
        duration.isAcceptableOrUnknown(data['duration']!, _durationMeta),
      );
    }
    if (data.containsKey('image_asset')) {
      context.handle(
        _imageAssetMeta,
        imageAsset.isAcceptableOrUnknown(data['image_asset']!, _imageAssetMeta),
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
  SavedItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SavedItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      ),
      displayTime: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_time'],
      )!,
      duration: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}duration'],
      ),
      imageAsset: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_asset'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $SavedItemsTable createAlias(String alias) {
    return $SavedItemsTable(attachedDatabase, alias);
  }
}

class SavedItem extends DataClass implements Insertable<SavedItem> {
  final int id;
  final String type;
  final String title;
  final String? description;
  final String? source;
  final String displayTime;
  final String? duration;
  final String? imageAsset;
  final DateTime createdAt;
  const SavedItem({
    required this.id,
    required this.type,
    required this.title,
    this.description,
    this.source,
    required this.displayTime,
    this.duration,
    this.imageAsset,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['type'] = Variable<String>(type);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || source != null) {
      map['source'] = Variable<String>(source);
    }
    map['display_time'] = Variable<String>(displayTime);
    if (!nullToAbsent || duration != null) {
      map['duration'] = Variable<String>(duration);
    }
    if (!nullToAbsent || imageAsset != null) {
      map['image_asset'] = Variable<String>(imageAsset);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  SavedItemsCompanion toCompanion(bool nullToAbsent) {
    return SavedItemsCompanion(
      id: Value(id),
      type: Value(type),
      title: Value(title),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      source: source == null && nullToAbsent
          ? const Value.absent()
          : Value(source),
      displayTime: Value(displayTime),
      duration: duration == null && nullToAbsent
          ? const Value.absent()
          : Value(duration),
      imageAsset: imageAsset == null && nullToAbsent
          ? const Value.absent()
          : Value(imageAsset),
      createdAt: Value(createdAt),
    );
  }

  factory SavedItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SavedItem(
      id: serializer.fromJson<int>(json['id']),
      type: serializer.fromJson<String>(json['type']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String?>(json['description']),
      source: serializer.fromJson<String?>(json['source']),
      displayTime: serializer.fromJson<String>(json['displayTime']),
      duration: serializer.fromJson<String?>(json['duration']),
      imageAsset: serializer.fromJson<String?>(json['imageAsset']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'type': serializer.toJson<String>(type),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String?>(description),
      'source': serializer.toJson<String?>(source),
      'displayTime': serializer.toJson<String>(displayTime),
      'duration': serializer.toJson<String?>(duration),
      'imageAsset': serializer.toJson<String?>(imageAsset),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  SavedItem copyWith({
    int? id,
    String? type,
    String? title,
    Value<String?> description = const Value.absent(),
    Value<String?> source = const Value.absent(),
    String? displayTime,
    Value<String?> duration = const Value.absent(),
    Value<String?> imageAsset = const Value.absent(),
    DateTime? createdAt,
  }) => SavedItem(
    id: id ?? this.id,
    type: type ?? this.type,
    title: title ?? this.title,
    description: description.present ? description.value : this.description,
    source: source.present ? source.value : this.source,
    displayTime: displayTime ?? this.displayTime,
    duration: duration.present ? duration.value : this.duration,
    imageAsset: imageAsset.present ? imageAsset.value : this.imageAsset,
    createdAt: createdAt ?? this.createdAt,
  );
  SavedItem copyWithCompanion(SavedItemsCompanion data) {
    return SavedItem(
      id: data.id.present ? data.id.value : this.id,
      type: data.type.present ? data.type.value : this.type,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      source: data.source.present ? data.source.value : this.source,
      displayTime: data.displayTime.present
          ? data.displayTime.value
          : this.displayTime,
      duration: data.duration.present ? data.duration.value : this.duration,
      imageAsset: data.imageAsset.present
          ? data.imageAsset.value
          : this.imageAsset,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SavedItem(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('source: $source, ')
          ..write('displayTime: $displayTime, ')
          ..write('duration: $duration, ')
          ..write('imageAsset: $imageAsset, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    type,
    title,
    description,
    source,
    displayTime,
    duration,
    imageAsset,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SavedItem &&
          other.id == this.id &&
          other.type == this.type &&
          other.title == this.title &&
          other.description == this.description &&
          other.source == this.source &&
          other.displayTime == this.displayTime &&
          other.duration == this.duration &&
          other.imageAsset == this.imageAsset &&
          other.createdAt == this.createdAt);
}

class SavedItemsCompanion extends UpdateCompanion<SavedItem> {
  final Value<int> id;
  final Value<String> type;
  final Value<String> title;
  final Value<String?> description;
  final Value<String?> source;
  final Value<String> displayTime;
  final Value<String?> duration;
  final Value<String?> imageAsset;
  final Value<DateTime> createdAt;
  const SavedItemsCompanion({
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.source = const Value.absent(),
    this.displayTime = const Value.absent(),
    this.duration = const Value.absent(),
    this.imageAsset = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  SavedItemsCompanion.insert({
    this.id = const Value.absent(),
    required String type,
    required String title,
    this.description = const Value.absent(),
    this.source = const Value.absent(),
    required String displayTime,
    this.duration = const Value.absent(),
    this.imageAsset = const Value.absent(),
    required DateTime createdAt,
  }) : type = Value(type),
       title = Value(title),
       displayTime = Value(displayTime),
       createdAt = Value(createdAt);
  static Insertable<SavedItem> custom({
    Expression<int>? id,
    Expression<String>? type,
    Expression<String>? title,
    Expression<String>? description,
    Expression<String>? source,
    Expression<String>? displayTime,
    Expression<String>? duration,
    Expression<String>? imageAsset,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (source != null) 'source': source,
      if (displayTime != null) 'display_time': displayTime,
      if (duration != null) 'duration': duration,
      if (imageAsset != null) 'image_asset': imageAsset,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  SavedItemsCompanion copyWith({
    Value<int>? id,
    Value<String>? type,
    Value<String>? title,
    Value<String?>? description,
    Value<String?>? source,
    Value<String>? displayTime,
    Value<String?>? duration,
    Value<String?>? imageAsset,
    Value<DateTime>? createdAt,
  }) {
    return SavedItemsCompanion(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      source: source ?? this.source,
      displayTime: displayTime ?? this.displayTime,
      duration: duration ?? this.duration,
      imageAsset: imageAsset ?? this.imageAsset,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (displayTime.present) {
      map['display_time'] = Variable<String>(displayTime.value);
    }
    if (duration.present) {
      map['duration'] = Variable<String>(duration.value);
    }
    if (imageAsset.present) {
      map['image_asset'] = Variable<String>(imageAsset.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SavedItemsCompanion(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('source: $source, ')
          ..write('displayTime: $displayTime, ')
          ..write('duration: $duration, ')
          ..write('imageAsset: $imageAsset, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $CollectionsTable extends Collections
    with TableInfo<$CollectionsTable, CollectionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CollectionsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _itemCountMeta = const VerificationMeta(
    'itemCount',
  );
  @override
  late final GeneratedColumn<int> itemCount = GeneratedColumn<int>(
    'item_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _colorValueMeta = const VerificationMeta(
    'colorValue',
  );
  @override
  late final GeneratedColumn<int> colorValue = GeneratedColumn<int>(
    'color_value',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _symbolMeta = const VerificationMeta('symbol');
  @override
  late final GeneratedColumn<String> symbol = GeneratedColumn<String>(
    'symbol',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedLabelMeta = const VerificationMeta(
    'updatedLabel',
  );
  @override
  late final GeneratedColumn<String> updatedLabel = GeneratedColumn<String>(
    'updated_label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isPinnedMeta = const VerificationMeta(
    'isPinned',
  );
  @override
  late final GeneratedColumn<bool> isPinned = GeneratedColumn<bool>(
    'is_pinned',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_pinned" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
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
  List<GeneratedColumn> get $columns => [
    id,
    title,
    description,
    itemCount,
    colorValue,
    symbol,
    updatedLabel,
    isPinned,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'collections';
  @override
  VerificationContext validateIntegrity(
    Insertable<CollectionRow> instance, {
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
    if (data.containsKey('item_count')) {
      context.handle(
        _itemCountMeta,
        itemCount.isAcceptableOrUnknown(data['item_count']!, _itemCountMeta),
      );
    } else if (isInserting) {
      context.missing(_itemCountMeta);
    }
    if (data.containsKey('color_value')) {
      context.handle(
        _colorValueMeta,
        colorValue.isAcceptableOrUnknown(data['color_value']!, _colorValueMeta),
      );
    } else if (isInserting) {
      context.missing(_colorValueMeta);
    }
    if (data.containsKey('symbol')) {
      context.handle(
        _symbolMeta,
        symbol.isAcceptableOrUnknown(data['symbol']!, _symbolMeta),
      );
    } else if (isInserting) {
      context.missing(_symbolMeta);
    }
    if (data.containsKey('updated_label')) {
      context.handle(
        _updatedLabelMeta,
        updatedLabel.isAcceptableOrUnknown(
          data['updated_label']!,
          _updatedLabelMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedLabelMeta);
    }
    if (data.containsKey('is_pinned')) {
      context.handle(
        _isPinnedMeta,
        isPinned.isAcceptableOrUnknown(data['is_pinned']!, _isPinnedMeta),
      );
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
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CollectionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CollectionRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      itemCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}item_count'],
      )!,
      colorValue: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}color_value'],
      )!,
      symbol: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}symbol'],
      )!,
      updatedLabel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_label'],
      )!,
      isPinned: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_pinned'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $CollectionsTable createAlias(String alias) {
    return $CollectionsTable(attachedDatabase, alias);
  }
}

class CollectionRow extends DataClass implements Insertable<CollectionRow> {
  final int id;
  final String title;
  final String description;
  final int itemCount;
  final int colorValue;
  final String symbol;
  final String updatedLabel;
  final bool isPinned;
  final DateTime updatedAt;
  const CollectionRow({
    required this.id,
    required this.title,
    required this.description,
    required this.itemCount,
    required this.colorValue,
    required this.symbol,
    required this.updatedLabel,
    required this.isPinned,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    map['description'] = Variable<String>(description);
    map['item_count'] = Variable<int>(itemCount);
    map['color_value'] = Variable<int>(colorValue);
    map['symbol'] = Variable<String>(symbol);
    map['updated_label'] = Variable<String>(updatedLabel);
    map['is_pinned'] = Variable<bool>(isPinned);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  CollectionsCompanion toCompanion(bool nullToAbsent) {
    return CollectionsCompanion(
      id: Value(id),
      title: Value(title),
      description: Value(description),
      itemCount: Value(itemCount),
      colorValue: Value(colorValue),
      symbol: Value(symbol),
      updatedLabel: Value(updatedLabel),
      isPinned: Value(isPinned),
      updatedAt: Value(updatedAt),
    );
  }

  factory CollectionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CollectionRow(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String>(json['description']),
      itemCount: serializer.fromJson<int>(json['itemCount']),
      colorValue: serializer.fromJson<int>(json['colorValue']),
      symbol: serializer.fromJson<String>(json['symbol']),
      updatedLabel: serializer.fromJson<String>(json['updatedLabel']),
      isPinned: serializer.fromJson<bool>(json['isPinned']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String>(description),
      'itemCount': serializer.toJson<int>(itemCount),
      'colorValue': serializer.toJson<int>(colorValue),
      'symbol': serializer.toJson<String>(symbol),
      'updatedLabel': serializer.toJson<String>(updatedLabel),
      'isPinned': serializer.toJson<bool>(isPinned),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  CollectionRow copyWith({
    int? id,
    String? title,
    String? description,
    int? itemCount,
    int? colorValue,
    String? symbol,
    String? updatedLabel,
    bool? isPinned,
    DateTime? updatedAt,
  }) => CollectionRow(
    id: id ?? this.id,
    title: title ?? this.title,
    description: description ?? this.description,
    itemCount: itemCount ?? this.itemCount,
    colorValue: colorValue ?? this.colorValue,
    symbol: symbol ?? this.symbol,
    updatedLabel: updatedLabel ?? this.updatedLabel,
    isPinned: isPinned ?? this.isPinned,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  CollectionRow copyWithCompanion(CollectionsCompanion data) {
    return CollectionRow(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      itemCount: data.itemCount.present ? data.itemCount.value : this.itemCount,
      colorValue: data.colorValue.present
          ? data.colorValue.value
          : this.colorValue,
      symbol: data.symbol.present ? data.symbol.value : this.symbol,
      updatedLabel: data.updatedLabel.present
          ? data.updatedLabel.value
          : this.updatedLabel,
      isPinned: data.isPinned.present ? data.isPinned.value : this.isPinned,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CollectionRow(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('itemCount: $itemCount, ')
          ..write('colorValue: $colorValue, ')
          ..write('symbol: $symbol, ')
          ..write('updatedLabel: $updatedLabel, ')
          ..write('isPinned: $isPinned, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    description,
    itemCount,
    colorValue,
    symbol,
    updatedLabel,
    isPinned,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CollectionRow &&
          other.id == this.id &&
          other.title == this.title &&
          other.description == this.description &&
          other.itemCount == this.itemCount &&
          other.colorValue == this.colorValue &&
          other.symbol == this.symbol &&
          other.updatedLabel == this.updatedLabel &&
          other.isPinned == this.isPinned &&
          other.updatedAt == this.updatedAt);
}

class CollectionsCompanion extends UpdateCompanion<CollectionRow> {
  final Value<int> id;
  final Value<String> title;
  final Value<String> description;
  final Value<int> itemCount;
  final Value<int> colorValue;
  final Value<String> symbol;
  final Value<String> updatedLabel;
  final Value<bool> isPinned;
  final Value<DateTime> updatedAt;
  const CollectionsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.itemCount = const Value.absent(),
    this.colorValue = const Value.absent(),
    this.symbol = const Value.absent(),
    this.updatedLabel = const Value.absent(),
    this.isPinned = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  CollectionsCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    required String description,
    required int itemCount,
    required int colorValue,
    required String symbol,
    required String updatedLabel,
    this.isPinned = const Value.absent(),
    required DateTime updatedAt,
  }) : title = Value(title),
       description = Value(description),
       itemCount = Value(itemCount),
       colorValue = Value(colorValue),
       symbol = Value(symbol),
       updatedLabel = Value(updatedLabel),
       updatedAt = Value(updatedAt);
  static Insertable<CollectionRow> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<String>? description,
    Expression<int>? itemCount,
    Expression<int>? colorValue,
    Expression<String>? symbol,
    Expression<String>? updatedLabel,
    Expression<bool>? isPinned,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (itemCount != null) 'item_count': itemCount,
      if (colorValue != null) 'color_value': colorValue,
      if (symbol != null) 'symbol': symbol,
      if (updatedLabel != null) 'updated_label': updatedLabel,
      if (isPinned != null) 'is_pinned': isPinned,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  CollectionsCompanion copyWith({
    Value<int>? id,
    Value<String>? title,
    Value<String>? description,
    Value<int>? itemCount,
    Value<int>? colorValue,
    Value<String>? symbol,
    Value<String>? updatedLabel,
    Value<bool>? isPinned,
    Value<DateTime>? updatedAt,
  }) {
    return CollectionsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      itemCount: itemCount ?? this.itemCount,
      colorValue: colorValue ?? this.colorValue,
      symbol: symbol ?? this.symbol,
      updatedLabel: updatedLabel ?? this.updatedLabel,
      isPinned: isPinned ?? this.isPinned,
      updatedAt: updatedAt ?? this.updatedAt,
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
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (itemCount.present) {
      map['item_count'] = Variable<int>(itemCount.value);
    }
    if (colorValue.present) {
      map['color_value'] = Variable<int>(colorValue.value);
    }
    if (symbol.present) {
      map['symbol'] = Variable<String>(symbol.value);
    }
    if (updatedLabel.present) {
      map['updated_label'] = Variable<String>(updatedLabel.value);
    }
    if (isPinned.present) {
      map['is_pinned'] = Variable<bool>(isPinned.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CollectionsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('itemCount: $itemCount, ')
          ..write('colorValue: $colorValue, ')
          ..write('symbol: $symbol, ')
          ..write('updatedLabel: $updatedLabel, ')
          ..write('isPinned: $isPinned, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $SavedItemsTable savedItems = $SavedItemsTable(this);
  late final $CollectionsTable collections = $CollectionsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [savedItems, collections];
}

typedef $$SavedItemsTableCreateCompanionBuilder =
    SavedItemsCompanion Function({
      Value<int> id,
      required String type,
      required String title,
      Value<String?> description,
      Value<String?> source,
      required String displayTime,
      Value<String?> duration,
      Value<String?> imageAsset,
      required DateTime createdAt,
    });
typedef $$SavedItemsTableUpdateCompanionBuilder =
    SavedItemsCompanion Function({
      Value<int> id,
      Value<String> type,
      Value<String> title,
      Value<String?> description,
      Value<String?> source,
      Value<String> displayTime,
      Value<String?> duration,
      Value<String?> imageAsset,
      Value<DateTime> createdAt,
    });

class $$SavedItemsTableFilterComposer
    extends Composer<_$AppDatabase, $SavedItemsTable> {
  $$SavedItemsTableFilterComposer({
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

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayTime => $composableBuilder(
    column: $table.displayTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get duration => $composableBuilder(
    column: $table.duration,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imageAsset => $composableBuilder(
    column: $table.imageAsset,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SavedItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $SavedItemsTable> {
  $$SavedItemsTableOrderingComposer({
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

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayTime => $composableBuilder(
    column: $table.displayTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get duration => $composableBuilder(
    column: $table.duration,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imageAsset => $composableBuilder(
    column: $table.imageAsset,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SavedItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SavedItemsTable> {
  $$SavedItemsTableAnnotationComposer({
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

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get displayTime => $composableBuilder(
    column: $table.displayTime,
    builder: (column) => column,
  );

  GeneratedColumn<String> get duration =>
      $composableBuilder(column: $table.duration, builder: (column) => column);

  GeneratedColumn<String> get imageAsset => $composableBuilder(
    column: $table.imageAsset,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$SavedItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SavedItemsTable,
          SavedItem,
          $$SavedItemsTableFilterComposer,
          $$SavedItemsTableOrderingComposer,
          $$SavedItemsTableAnnotationComposer,
          $$SavedItemsTableCreateCompanionBuilder,
          $$SavedItemsTableUpdateCompanionBuilder,
          (
            SavedItem,
            BaseReferences<_$AppDatabase, $SavedItemsTable, SavedItem>,
          ),
          SavedItem,
          PrefetchHooks Function()
        > {
  $$SavedItemsTableTableManager(_$AppDatabase db, $SavedItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SavedItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SavedItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SavedItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String?> source = const Value.absent(),
                Value<String> displayTime = const Value.absent(),
                Value<String?> duration = const Value.absent(),
                Value<String?> imageAsset = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => SavedItemsCompanion(
                id: id,
                type: type,
                title: title,
                description: description,
                source: source,
                displayTime: displayTime,
                duration: duration,
                imageAsset: imageAsset,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String type,
                required String title,
                Value<String?> description = const Value.absent(),
                Value<String?> source = const Value.absent(),
                required String displayTime,
                Value<String?> duration = const Value.absent(),
                Value<String?> imageAsset = const Value.absent(),
                required DateTime createdAt,
              }) => SavedItemsCompanion.insert(
                id: id,
                type: type,
                title: title,
                description: description,
                source: source,
                displayTime: displayTime,
                duration: duration,
                imageAsset: imageAsset,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SavedItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SavedItemsTable,
      SavedItem,
      $$SavedItemsTableFilterComposer,
      $$SavedItemsTableOrderingComposer,
      $$SavedItemsTableAnnotationComposer,
      $$SavedItemsTableCreateCompanionBuilder,
      $$SavedItemsTableUpdateCompanionBuilder,
      (SavedItem, BaseReferences<_$AppDatabase, $SavedItemsTable, SavedItem>),
      SavedItem,
      PrefetchHooks Function()
    >;
typedef $$CollectionsTableCreateCompanionBuilder =
    CollectionsCompanion Function({
      Value<int> id,
      required String title,
      required String description,
      required int itemCount,
      required int colorValue,
      required String symbol,
      required String updatedLabel,
      Value<bool> isPinned,
      required DateTime updatedAt,
    });
typedef $$CollectionsTableUpdateCompanionBuilder =
    CollectionsCompanion Function({
      Value<int> id,
      Value<String> title,
      Value<String> description,
      Value<int> itemCount,
      Value<int> colorValue,
      Value<String> symbol,
      Value<String> updatedLabel,
      Value<bool> isPinned,
      Value<DateTime> updatedAt,
    });

class $$CollectionsTableFilterComposer
    extends Composer<_$AppDatabase, $CollectionsTable> {
  $$CollectionsTableFilterComposer({
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

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get itemCount => $composableBuilder(
    column: $table.itemCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get colorValue => $composableBuilder(
    column: $table.colorValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get symbol => $composableBuilder(
    column: $table.symbol,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedLabel => $composableBuilder(
    column: $table.updatedLabel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isPinned => $composableBuilder(
    column: $table.isPinned,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CollectionsTableOrderingComposer
    extends Composer<_$AppDatabase, $CollectionsTable> {
  $$CollectionsTableOrderingComposer({
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

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get itemCount => $composableBuilder(
    column: $table.itemCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get colorValue => $composableBuilder(
    column: $table.colorValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get symbol => $composableBuilder(
    column: $table.symbol,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedLabel => $composableBuilder(
    column: $table.updatedLabel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isPinned => $composableBuilder(
    column: $table.isPinned,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CollectionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CollectionsTable> {
  $$CollectionsTableAnnotationComposer({
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

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<int> get itemCount =>
      $composableBuilder(column: $table.itemCount, builder: (column) => column);

  GeneratedColumn<int> get colorValue => $composableBuilder(
    column: $table.colorValue,
    builder: (column) => column,
  );

  GeneratedColumn<String> get symbol =>
      $composableBuilder(column: $table.symbol, builder: (column) => column);

  GeneratedColumn<String> get updatedLabel => $composableBuilder(
    column: $table.updatedLabel,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isPinned =>
      $composableBuilder(column: $table.isPinned, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$CollectionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CollectionsTable,
          CollectionRow,
          $$CollectionsTableFilterComposer,
          $$CollectionsTableOrderingComposer,
          $$CollectionsTableAnnotationComposer,
          $$CollectionsTableCreateCompanionBuilder,
          $$CollectionsTableUpdateCompanionBuilder,
          (
            CollectionRow,
            BaseReferences<_$AppDatabase, $CollectionsTable, CollectionRow>,
          ),
          CollectionRow,
          PrefetchHooks Function()
        > {
  $$CollectionsTableTableManager(_$AppDatabase db, $CollectionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CollectionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CollectionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CollectionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<int> itemCount = const Value.absent(),
                Value<int> colorValue = const Value.absent(),
                Value<String> symbol = const Value.absent(),
                Value<String> updatedLabel = const Value.absent(),
                Value<bool> isPinned = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => CollectionsCompanion(
                id: id,
                title: title,
                description: description,
                itemCount: itemCount,
                colorValue: colorValue,
                symbol: symbol,
                updatedLabel: updatedLabel,
                isPinned: isPinned,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String title,
                required String description,
                required int itemCount,
                required int colorValue,
                required String symbol,
                required String updatedLabel,
                Value<bool> isPinned = const Value.absent(),
                required DateTime updatedAt,
              }) => CollectionsCompanion.insert(
                id: id,
                title: title,
                description: description,
                itemCount: itemCount,
                colorValue: colorValue,
                symbol: symbol,
                updatedLabel: updatedLabel,
                isPinned: isPinned,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CollectionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CollectionsTable,
      CollectionRow,
      $$CollectionsTableFilterComposer,
      $$CollectionsTableOrderingComposer,
      $$CollectionsTableAnnotationComposer,
      $$CollectionsTableCreateCompanionBuilder,
      $$CollectionsTableUpdateCompanionBuilder,
      (
        CollectionRow,
        BaseReferences<_$AppDatabase, $CollectionsTable, CollectionRow>,
      ),
      CollectionRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$SavedItemsTableTableManager get savedItems =>
      $$SavedItemsTableTableManager(_db, _db.savedItems);
  $$CollectionsTableTableManager get collections =>
      $$CollectionsTableTableManager(_db, _db.collections);
}
