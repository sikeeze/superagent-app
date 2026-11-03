// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ConversationsTable extends Conversations
    with TableInfo<$ConversationsTable, Conversation> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ConversationsTable(this.attachedDatabase, [this._alias]);
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
    requiredDuringInsert: false,
    defaultValue: const Constant('Percakapan baru'),
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
  static const VerificationMeta _modelMeta = const VerificationMeta('model');
  @override
  late final GeneratedColumn<String> model = GeneratedColumn<String>(
    'model',
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _tokenEstimateMeta = const VerificationMeta(
    'tokenEstimate',
  );
  @override
  late final GeneratedColumn<int> tokenEstimate = GeneratedColumn<int>(
    'token_estimate',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _pinnedMeta = const VerificationMeta('pinned');
  @override
  late final GeneratedColumn<bool> pinned = GeneratedColumn<bool>(
    'pinned',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("pinned" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    providerId,
    model,
    createdAt,
    updatedAt,
    tokenEstimate,
    pinned,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'conversations';
  @override
  VerificationContext validateIntegrity(
    Insertable<Conversation> instance, {
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
    }
    if (data.containsKey('provider_id')) {
      context.handle(
        _providerIdMeta,
        providerId.isAcceptableOrUnknown(data['provider_id']!, _providerIdMeta),
      );
    }
    if (data.containsKey('model')) {
      context.handle(
        _modelMeta,
        model.isAcceptableOrUnknown(data['model']!, _modelMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('token_estimate')) {
      context.handle(
        _tokenEstimateMeta,
        tokenEstimate.isAcceptableOrUnknown(
          data['token_estimate']!,
          _tokenEstimateMeta,
        ),
      );
    }
    if (data.containsKey('pinned')) {
      context.handle(
        _pinnedMeta,
        pinned.isAcceptableOrUnknown(data['pinned']!, _pinnedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Conversation map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Conversation(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      providerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}provider_id'],
      ),
      model: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}model'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      tokenEstimate: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}token_estimate'],
      )!,
      pinned: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}pinned'],
      )!,
    );
  }

  @override
  $ConversationsTable createAlias(String alias) {
    return $ConversationsTable(attachedDatabase, alias);
  }
}

class Conversation extends DataClass implements Insertable<Conversation> {
  final int id;
  final String title;
  final String? providerId;
  final String? model;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Total token perkiraan untuk pemangkasan konteks (sliding window).
  final int tokenEstimate;
  final bool pinned;
  const Conversation({
    required this.id,
    required this.title,
    this.providerId,
    this.model,
    required this.createdAt,
    required this.updatedAt,
    required this.tokenEstimate,
    required this.pinned,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || providerId != null) {
      map['provider_id'] = Variable<String>(providerId);
    }
    if (!nullToAbsent || model != null) {
      map['model'] = Variable<String>(model);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['token_estimate'] = Variable<int>(tokenEstimate);
    map['pinned'] = Variable<bool>(pinned);
    return map;
  }

  ConversationsCompanion toCompanion(bool nullToAbsent) {
    return ConversationsCompanion(
      id: Value(id),
      title: Value(title),
      providerId: providerId == null && nullToAbsent
          ? const Value.absent()
          : Value(providerId),
      model: model == null && nullToAbsent
          ? const Value.absent()
          : Value(model),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      tokenEstimate: Value(tokenEstimate),
      pinned: Value(pinned),
    );
  }

  factory Conversation.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Conversation(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      providerId: serializer.fromJson<String?>(json['providerId']),
      model: serializer.fromJson<String?>(json['model']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      tokenEstimate: serializer.fromJson<int>(json['tokenEstimate']),
      pinned: serializer.fromJson<bool>(json['pinned']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'providerId': serializer.toJson<String?>(providerId),
      'model': serializer.toJson<String?>(model),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'tokenEstimate': serializer.toJson<int>(tokenEstimate),
      'pinned': serializer.toJson<bool>(pinned),
    };
  }

  Conversation copyWith({
    int? id,
    String? title,
    Value<String?> providerId = const Value.absent(),
    Value<String?> model = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    int? tokenEstimate,
    bool? pinned,
  }) => Conversation(
    id: id ?? this.id,
    title: title ?? this.title,
    providerId: providerId.present ? providerId.value : this.providerId,
    model: model.present ? model.value : this.model,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    tokenEstimate: tokenEstimate ?? this.tokenEstimate,
    pinned: pinned ?? this.pinned,
  );
  Conversation copyWithCompanion(ConversationsCompanion data) {
    return Conversation(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      providerId: data.providerId.present
          ? data.providerId.value
          : this.providerId,
      model: data.model.present ? data.model.value : this.model,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      tokenEstimate: data.tokenEstimate.present
          ? data.tokenEstimate.value
          : this.tokenEstimate,
      pinned: data.pinned.present ? data.pinned.value : this.pinned,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Conversation(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('providerId: $providerId, ')
          ..write('model: $model, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('tokenEstimate: $tokenEstimate, ')
          ..write('pinned: $pinned')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    providerId,
    model,
    createdAt,
    updatedAt,
    tokenEstimate,
    pinned,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Conversation &&
          other.id == this.id &&
          other.title == this.title &&
          other.providerId == this.providerId &&
          other.model == this.model &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.tokenEstimate == this.tokenEstimate &&
          other.pinned == this.pinned);
}

class ConversationsCompanion extends UpdateCompanion<Conversation> {
  final Value<int> id;
  final Value<String> title;
  final Value<String?> providerId;
  final Value<String?> model;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> tokenEstimate;
  final Value<bool> pinned;
  const ConversationsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.providerId = const Value.absent(),
    this.model = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.tokenEstimate = const Value.absent(),
    this.pinned = const Value.absent(),
  });
  ConversationsCompanion.insert({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.providerId = const Value.absent(),
    this.model = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.tokenEstimate = const Value.absent(),
    this.pinned = const Value.absent(),
  });
  static Insertable<Conversation> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<String>? providerId,
    Expression<String>? model,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? tokenEstimate,
    Expression<bool>? pinned,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (providerId != null) 'provider_id': providerId,
      if (model != null) 'model': model,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (tokenEstimate != null) 'token_estimate': tokenEstimate,
      if (pinned != null) 'pinned': pinned,
    });
  }

  ConversationsCompanion copyWith({
    Value<int>? id,
    Value<String>? title,
    Value<String?>? providerId,
    Value<String?>? model,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? tokenEstimate,
    Value<bool>? pinned,
  }) {
    return ConversationsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      providerId: providerId ?? this.providerId,
      model: model ?? this.model,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      tokenEstimate: tokenEstimate ?? this.tokenEstimate,
      pinned: pinned ?? this.pinned,
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
    if (providerId.present) {
      map['provider_id'] = Variable<String>(providerId.value);
    }
    if (model.present) {
      map['model'] = Variable<String>(model.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (tokenEstimate.present) {
      map['token_estimate'] = Variable<int>(tokenEstimate.value);
    }
    if (pinned.present) {
      map['pinned'] = Variable<bool>(pinned.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ConversationsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('providerId: $providerId, ')
          ..write('model: $model, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('tokenEstimate: $tokenEstimate, ')
          ..write('pinned: $pinned')
          ..write(')'))
        .toString();
  }
}

class $MessagesTable extends Messages with TableInfo<$MessagesTable, Message> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MessagesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _conversationIdMeta = const VerificationMeta(
    'conversationId',
  );
  @override
  late final GeneratedColumn<int> conversationId = GeneratedColumn<int>(
    'conversation_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES conversations (id) ON DELETE CASCADE',
    ),
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
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _toolNameMeta = const VerificationMeta(
    'toolName',
  );
  @override
  late final GeneratedColumn<String> toolName = GeneratedColumn<String>(
    'tool_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _toolStatusMeta = const VerificationMeta(
    'toolStatus',
  );
  @override
  late final GeneratedColumn<String> toolStatus = GeneratedColumn<String>(
    'tool_status',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _toolDurationMsMeta = const VerificationMeta(
    'toolDurationMs',
  );
  @override
  late final GeneratedColumn<int> toolDurationMs = GeneratedColumn<int>(
    'tool_duration_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _toolArgsJsonMeta = const VerificationMeta(
    'toolArgsJson',
  );
  @override
  late final GeneratedColumn<String> toolArgsJson = GeneratedColumn<String>(
    'tool_args_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    conversationId,
    role,
    content,
    createdAt,
    toolName,
    toolStatus,
    toolDurationMs,
    toolArgsJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'messages';
  @override
  VerificationContext validateIntegrity(
    Insertable<Message> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('conversation_id')) {
      context.handle(
        _conversationIdMeta,
        conversationId.isAcceptableOrUnknown(
          data['conversation_id']!,
          _conversationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_conversationIdMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('tool_name')) {
      context.handle(
        _toolNameMeta,
        toolName.isAcceptableOrUnknown(data['tool_name']!, _toolNameMeta),
      );
    }
    if (data.containsKey('tool_status')) {
      context.handle(
        _toolStatusMeta,
        toolStatus.isAcceptableOrUnknown(data['tool_status']!, _toolStatusMeta),
      );
    }
    if (data.containsKey('tool_duration_ms')) {
      context.handle(
        _toolDurationMsMeta,
        toolDurationMs.isAcceptableOrUnknown(
          data['tool_duration_ms']!,
          _toolDurationMsMeta,
        ),
      );
    }
    if (data.containsKey('tool_args_json')) {
      context.handle(
        _toolArgsJsonMeta,
        toolArgsJson.isAcceptableOrUnknown(
          data['tool_args_json']!,
          _toolArgsJsonMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Message map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Message(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      conversationId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}conversation_id'],
      )!,
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      )!,
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      toolName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tool_name'],
      ),
      toolStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tool_status'],
      ),
      toolDurationMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}tool_duration_ms'],
      ),
      toolArgsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tool_args_json'],
      ),
    );
  }

  @override
  $MessagesTable createAlias(String alias) {
    return $MessagesTable(attachedDatabase, alias);
  }
}

class Message extends DataClass implements Insertable<Message> {
  final int id;
  final int conversationId;
  final String role;
  final String content;
  final DateTime createdAt;

  /// Meta untuk pesan tool: nama tool, status, durasi (ditampilkan sebagai
  /// kartu tool di UI, wireframe A).
  final String? toolName;
  final String? toolStatus;
  final int? toolDurationMs;
  final String? toolArgsJson;
  const Message({
    required this.id,
    required this.conversationId,
    required this.role,
    required this.content,
    required this.createdAt,
    this.toolName,
    this.toolStatus,
    this.toolDurationMs,
    this.toolArgsJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['conversation_id'] = Variable<int>(conversationId);
    map['role'] = Variable<String>(role);
    map['content'] = Variable<String>(content);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || toolName != null) {
      map['tool_name'] = Variable<String>(toolName);
    }
    if (!nullToAbsent || toolStatus != null) {
      map['tool_status'] = Variable<String>(toolStatus);
    }
    if (!nullToAbsent || toolDurationMs != null) {
      map['tool_duration_ms'] = Variable<int>(toolDurationMs);
    }
    if (!nullToAbsent || toolArgsJson != null) {
      map['tool_args_json'] = Variable<String>(toolArgsJson);
    }
    return map;
  }

  MessagesCompanion toCompanion(bool nullToAbsent) {
    return MessagesCompanion(
      id: Value(id),
      conversationId: Value(conversationId),
      role: Value(role),
      content: Value(content),
      createdAt: Value(createdAt),
      toolName: toolName == null && nullToAbsent
          ? const Value.absent()
          : Value(toolName),
      toolStatus: toolStatus == null && nullToAbsent
          ? const Value.absent()
          : Value(toolStatus),
      toolDurationMs: toolDurationMs == null && nullToAbsent
          ? const Value.absent()
          : Value(toolDurationMs),
      toolArgsJson: toolArgsJson == null && nullToAbsent
          ? const Value.absent()
          : Value(toolArgsJson),
    );
  }

  factory Message.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Message(
      id: serializer.fromJson<int>(json['id']),
      conversationId: serializer.fromJson<int>(json['conversationId']),
      role: serializer.fromJson<String>(json['role']),
      content: serializer.fromJson<String>(json['content']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      toolName: serializer.fromJson<String?>(json['toolName']),
      toolStatus: serializer.fromJson<String?>(json['toolStatus']),
      toolDurationMs: serializer.fromJson<int?>(json['toolDurationMs']),
      toolArgsJson: serializer.fromJson<String?>(json['toolArgsJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'conversationId': serializer.toJson<int>(conversationId),
      'role': serializer.toJson<String>(role),
      'content': serializer.toJson<String>(content),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'toolName': serializer.toJson<String?>(toolName),
      'toolStatus': serializer.toJson<String?>(toolStatus),
      'toolDurationMs': serializer.toJson<int?>(toolDurationMs),
      'toolArgsJson': serializer.toJson<String?>(toolArgsJson),
    };
  }

  Message copyWith({
    int? id,
    int? conversationId,
    String? role,
    String? content,
    DateTime? createdAt,
    Value<String?> toolName = const Value.absent(),
    Value<String?> toolStatus = const Value.absent(),
    Value<int?> toolDurationMs = const Value.absent(),
    Value<String?> toolArgsJson = const Value.absent(),
  }) => Message(
    id: id ?? this.id,
    conversationId: conversationId ?? this.conversationId,
    role: role ?? this.role,
    content: content ?? this.content,
    createdAt: createdAt ?? this.createdAt,
    toolName: toolName.present ? toolName.value : this.toolName,
    toolStatus: toolStatus.present ? toolStatus.value : this.toolStatus,
    toolDurationMs: toolDurationMs.present
        ? toolDurationMs.value
        : this.toolDurationMs,
    toolArgsJson: toolArgsJson.present ? toolArgsJson.value : this.toolArgsJson,
  );
  Message copyWithCompanion(MessagesCompanion data) {
    return Message(
      id: data.id.present ? data.id.value : this.id,
      conversationId: data.conversationId.present
          ? data.conversationId.value
          : this.conversationId,
      role: data.role.present ? data.role.value : this.role,
      content: data.content.present ? data.content.value : this.content,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      toolName: data.toolName.present ? data.toolName.value : this.toolName,
      toolStatus: data.toolStatus.present
          ? data.toolStatus.value
          : this.toolStatus,
      toolDurationMs: data.toolDurationMs.present
          ? data.toolDurationMs.value
          : this.toolDurationMs,
      toolArgsJson: data.toolArgsJson.present
          ? data.toolArgsJson.value
          : this.toolArgsJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Message(')
          ..write('id: $id, ')
          ..write('conversationId: $conversationId, ')
          ..write('role: $role, ')
          ..write('content: $content, ')
          ..write('createdAt: $createdAt, ')
          ..write('toolName: $toolName, ')
          ..write('toolStatus: $toolStatus, ')
          ..write('toolDurationMs: $toolDurationMs, ')
          ..write('toolArgsJson: $toolArgsJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    conversationId,
    role,
    content,
    createdAt,
    toolName,
    toolStatus,
    toolDurationMs,
    toolArgsJson,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Message &&
          other.id == this.id &&
          other.conversationId == this.conversationId &&
          other.role == this.role &&
          other.content == this.content &&
          other.createdAt == this.createdAt &&
          other.toolName == this.toolName &&
          other.toolStatus == this.toolStatus &&
          other.toolDurationMs == this.toolDurationMs &&
          other.toolArgsJson == this.toolArgsJson);
}

class MessagesCompanion extends UpdateCompanion<Message> {
  final Value<int> id;
  final Value<int> conversationId;
  final Value<String> role;
  final Value<String> content;
  final Value<DateTime> createdAt;
  final Value<String?> toolName;
  final Value<String?> toolStatus;
  final Value<int?> toolDurationMs;
  final Value<String?> toolArgsJson;
  const MessagesCompanion({
    this.id = const Value.absent(),
    this.conversationId = const Value.absent(),
    this.role = const Value.absent(),
    this.content = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.toolName = const Value.absent(),
    this.toolStatus = const Value.absent(),
    this.toolDurationMs = const Value.absent(),
    this.toolArgsJson = const Value.absent(),
  });
  MessagesCompanion.insert({
    this.id = const Value.absent(),
    required int conversationId,
    required String role,
    required String content,
    this.createdAt = const Value.absent(),
    this.toolName = const Value.absent(),
    this.toolStatus = const Value.absent(),
    this.toolDurationMs = const Value.absent(),
    this.toolArgsJson = const Value.absent(),
  }) : conversationId = Value(conversationId),
       role = Value(role),
       content = Value(content);
  static Insertable<Message> custom({
    Expression<int>? id,
    Expression<int>? conversationId,
    Expression<String>? role,
    Expression<String>? content,
    Expression<DateTime>? createdAt,
    Expression<String>? toolName,
    Expression<String>? toolStatus,
    Expression<int>? toolDurationMs,
    Expression<String>? toolArgsJson,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (conversationId != null) 'conversation_id': conversationId,
      if (role != null) 'role': role,
      if (content != null) 'content': content,
      if (createdAt != null) 'created_at': createdAt,
      if (toolName != null) 'tool_name': toolName,
      if (toolStatus != null) 'tool_status': toolStatus,
      if (toolDurationMs != null) 'tool_duration_ms': toolDurationMs,
      if (toolArgsJson != null) 'tool_args_json': toolArgsJson,
    });
  }

  MessagesCompanion copyWith({
    Value<int>? id,
    Value<int>? conversationId,
    Value<String>? role,
    Value<String>? content,
    Value<DateTime>? createdAt,
    Value<String?>? toolName,
    Value<String?>? toolStatus,
    Value<int?>? toolDurationMs,
    Value<String?>? toolArgsJson,
  }) {
    return MessagesCompanion(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      role: role ?? this.role,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      toolName: toolName ?? this.toolName,
      toolStatus: toolStatus ?? this.toolStatus,
      toolDurationMs: toolDurationMs ?? this.toolDurationMs,
      toolArgsJson: toolArgsJson ?? this.toolArgsJson,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (conversationId.present) {
      map['conversation_id'] = Variable<int>(conversationId.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (toolName.present) {
      map['tool_name'] = Variable<String>(toolName.value);
    }
    if (toolStatus.present) {
      map['tool_status'] = Variable<String>(toolStatus.value);
    }
    if (toolDurationMs.present) {
      map['tool_duration_ms'] = Variable<int>(toolDurationMs.value);
    }
    if (toolArgsJson.present) {
      map['tool_args_json'] = Variable<String>(toolArgsJson.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MessagesCompanion(')
          ..write('id: $id, ')
          ..write('conversationId: $conversationId, ')
          ..write('role: $role, ')
          ..write('content: $content, ')
          ..write('createdAt: $createdAt, ')
          ..write('toolName: $toolName, ')
          ..write('toolStatus: $toolStatus, ')
          ..write('toolDurationMs: $toolDurationMs, ')
          ..write('toolArgsJson: $toolArgsJson')
          ..write(')'))
        .toString();
  }
}

class $TasksTable extends Tasks with TableInfo<$TasksTable, Task> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TasksTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _promptMeta = const VerificationMeta('prompt');
  @override
  late final GeneratedColumn<String> prompt = GeneratedColumn<String>(
    'prompt',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _skillMeta = const VerificationMeta('skill');
  @override
  late final GeneratedColumn<String> skill = GeneratedColumn<String>(
    'skill',
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
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('once'),
  );
  static const VerificationMeta _intervalSecMeta = const VerificationMeta(
    'intervalSec',
  );
  @override
  late final GeneratedColumn<int> intervalSec = GeneratedColumn<int>(
    'interval_sec',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cronExprMeta = const VerificationMeta(
    'cronExpr',
  );
  @override
  late final GeneratedColumn<String> cronExpr = GeneratedColumn<String>(
    'cron_expr',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nextRunAtMeta = const VerificationMeta(
    'nextRunAt',
  );
  @override
  late final GeneratedColumn<DateTime> nextRunAt = GeneratedColumn<DateTime>(
    'next_run_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastRunAtMeta = const VerificationMeta(
    'lastRunAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastRunAt = GeneratedColumn<DateTime>(
    'last_run_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
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
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _failCountMeta = const VerificationMeta(
    'failCount',
  );
  @override
  late final GeneratedColumn<int> failCount = GeneratedColumn<int>(
    'fail_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastErrorMeta = const VerificationMeta(
    'lastError',
  );
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
    'last_error',
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    prompt,
    skill,
    kind,
    intervalSec,
    cronExpr,
    nextRunAt,
    lastRunAt,
    status,
    failCount,
    lastError,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tasks';
  @override
  VerificationContext validateIntegrity(
    Insertable<Task> instance, {
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
    if (data.containsKey('prompt')) {
      context.handle(
        _promptMeta,
        prompt.isAcceptableOrUnknown(data['prompt']!, _promptMeta),
      );
    } else if (isInserting) {
      context.missing(_promptMeta);
    }
    if (data.containsKey('skill')) {
      context.handle(
        _skillMeta,
        skill.isAcceptableOrUnknown(data['skill']!, _skillMeta),
      );
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    }
    if (data.containsKey('interval_sec')) {
      context.handle(
        _intervalSecMeta,
        intervalSec.isAcceptableOrUnknown(
          data['interval_sec']!,
          _intervalSecMeta,
        ),
      );
    }
    if (data.containsKey('cron_expr')) {
      context.handle(
        _cronExprMeta,
        cronExpr.isAcceptableOrUnknown(data['cron_expr']!, _cronExprMeta),
      );
    }
    if (data.containsKey('next_run_at')) {
      context.handle(
        _nextRunAtMeta,
        nextRunAt.isAcceptableOrUnknown(data['next_run_at']!, _nextRunAtMeta),
      );
    }
    if (data.containsKey('last_run_at')) {
      context.handle(
        _lastRunAtMeta,
        lastRunAt.isAcceptableOrUnknown(data['last_run_at']!, _lastRunAtMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('fail_count')) {
      context.handle(
        _failCountMeta,
        failCount.isAcceptableOrUnknown(data['fail_count']!, _failCountMeta),
      );
    }
    if (data.containsKey('last_error')) {
      context.handle(
        _lastErrorMeta,
        lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Task map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Task(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      prompt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}prompt'],
      )!,
      skill: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}skill'],
      ),
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      intervalSec: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}interval_sec'],
      ),
      cronExpr: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cron_expr'],
      ),
      nextRunAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}next_run_at'],
      ),
      lastRunAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_run_at'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      failCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fail_count'],
      )!,
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $TasksTable createAlias(String alias) {
    return $TasksTable(attachedDatabase, alias);
  }
}

class Task extends DataClass implements Insertable<Task> {
  final int id;
  final String title;
  final String prompt;
  final String? skill;
  final String kind;
  final int? intervalSec;
  final String? cronExpr;
  final DateTime? nextRunAt;
  final DateTime? lastRunAt;
  final String status;
  final int failCount;
  final String? lastError;
  final DateTime createdAt;
  const Task({
    required this.id,
    required this.title,
    required this.prompt,
    this.skill,
    required this.kind,
    this.intervalSec,
    this.cronExpr,
    this.nextRunAt,
    this.lastRunAt,
    required this.status,
    required this.failCount,
    this.lastError,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    map['prompt'] = Variable<String>(prompt);
    if (!nullToAbsent || skill != null) {
      map['skill'] = Variable<String>(skill);
    }
    map['kind'] = Variable<String>(kind);
    if (!nullToAbsent || intervalSec != null) {
      map['interval_sec'] = Variable<int>(intervalSec);
    }
    if (!nullToAbsent || cronExpr != null) {
      map['cron_expr'] = Variable<String>(cronExpr);
    }
    if (!nullToAbsent || nextRunAt != null) {
      map['next_run_at'] = Variable<DateTime>(nextRunAt);
    }
    if (!nullToAbsent || lastRunAt != null) {
      map['last_run_at'] = Variable<DateTime>(lastRunAt);
    }
    map['status'] = Variable<String>(status);
    map['fail_count'] = Variable<int>(failCount);
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  TasksCompanion toCompanion(bool nullToAbsent) {
    return TasksCompanion(
      id: Value(id),
      title: Value(title),
      prompt: Value(prompt),
      skill: skill == null && nullToAbsent
          ? const Value.absent()
          : Value(skill),
      kind: Value(kind),
      intervalSec: intervalSec == null && nullToAbsent
          ? const Value.absent()
          : Value(intervalSec),
      cronExpr: cronExpr == null && nullToAbsent
          ? const Value.absent()
          : Value(cronExpr),
      nextRunAt: nextRunAt == null && nullToAbsent
          ? const Value.absent()
          : Value(nextRunAt),
      lastRunAt: lastRunAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastRunAt),
      status: Value(status),
      failCount: Value(failCount),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
      createdAt: Value(createdAt),
    );
  }

  factory Task.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Task(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      prompt: serializer.fromJson<String>(json['prompt']),
      skill: serializer.fromJson<String?>(json['skill']),
      kind: serializer.fromJson<String>(json['kind']),
      intervalSec: serializer.fromJson<int?>(json['intervalSec']),
      cronExpr: serializer.fromJson<String?>(json['cronExpr']),
      nextRunAt: serializer.fromJson<DateTime?>(json['nextRunAt']),
      lastRunAt: serializer.fromJson<DateTime?>(json['lastRunAt']),
      status: serializer.fromJson<String>(json['status']),
      failCount: serializer.fromJson<int>(json['failCount']),
      lastError: serializer.fromJson<String?>(json['lastError']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'prompt': serializer.toJson<String>(prompt),
      'skill': serializer.toJson<String?>(skill),
      'kind': serializer.toJson<String>(kind),
      'intervalSec': serializer.toJson<int?>(intervalSec),
      'cronExpr': serializer.toJson<String?>(cronExpr),
      'nextRunAt': serializer.toJson<DateTime?>(nextRunAt),
      'lastRunAt': serializer.toJson<DateTime?>(lastRunAt),
      'status': serializer.toJson<String>(status),
      'failCount': serializer.toJson<int>(failCount),
      'lastError': serializer.toJson<String?>(lastError),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Task copyWith({
    int? id,
    String? title,
    String? prompt,
    Value<String?> skill = const Value.absent(),
    String? kind,
    Value<int?> intervalSec = const Value.absent(),
    Value<String?> cronExpr = const Value.absent(),
    Value<DateTime?> nextRunAt = const Value.absent(),
    Value<DateTime?> lastRunAt = const Value.absent(),
    String? status,
    int? failCount,
    Value<String?> lastError = const Value.absent(),
    DateTime? createdAt,
  }) => Task(
    id: id ?? this.id,
    title: title ?? this.title,
    prompt: prompt ?? this.prompt,
    skill: skill.present ? skill.value : this.skill,
    kind: kind ?? this.kind,
    intervalSec: intervalSec.present ? intervalSec.value : this.intervalSec,
    cronExpr: cronExpr.present ? cronExpr.value : this.cronExpr,
    nextRunAt: nextRunAt.present ? nextRunAt.value : this.nextRunAt,
    lastRunAt: lastRunAt.present ? lastRunAt.value : this.lastRunAt,
    status: status ?? this.status,
    failCount: failCount ?? this.failCount,
    lastError: lastError.present ? lastError.value : this.lastError,
    createdAt: createdAt ?? this.createdAt,
  );
  Task copyWithCompanion(TasksCompanion data) {
    return Task(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      prompt: data.prompt.present ? data.prompt.value : this.prompt,
      skill: data.skill.present ? data.skill.value : this.skill,
      kind: data.kind.present ? data.kind.value : this.kind,
      intervalSec: data.intervalSec.present
          ? data.intervalSec.value
          : this.intervalSec,
      cronExpr: data.cronExpr.present ? data.cronExpr.value : this.cronExpr,
      nextRunAt: data.nextRunAt.present ? data.nextRunAt.value : this.nextRunAt,
      lastRunAt: data.lastRunAt.present ? data.lastRunAt.value : this.lastRunAt,
      status: data.status.present ? data.status.value : this.status,
      failCount: data.failCount.present ? data.failCount.value : this.failCount,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Task(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('prompt: $prompt, ')
          ..write('skill: $skill, ')
          ..write('kind: $kind, ')
          ..write('intervalSec: $intervalSec, ')
          ..write('cronExpr: $cronExpr, ')
          ..write('nextRunAt: $nextRunAt, ')
          ..write('lastRunAt: $lastRunAt, ')
          ..write('status: $status, ')
          ..write('failCount: $failCount, ')
          ..write('lastError: $lastError, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    prompt,
    skill,
    kind,
    intervalSec,
    cronExpr,
    nextRunAt,
    lastRunAt,
    status,
    failCount,
    lastError,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Task &&
          other.id == this.id &&
          other.title == this.title &&
          other.prompt == this.prompt &&
          other.skill == this.skill &&
          other.kind == this.kind &&
          other.intervalSec == this.intervalSec &&
          other.cronExpr == this.cronExpr &&
          other.nextRunAt == this.nextRunAt &&
          other.lastRunAt == this.lastRunAt &&
          other.status == this.status &&
          other.failCount == this.failCount &&
          other.lastError == this.lastError &&
          other.createdAt == this.createdAt);
}

class TasksCompanion extends UpdateCompanion<Task> {
  final Value<int> id;
  final Value<String> title;
  final Value<String> prompt;
  final Value<String?> skill;
  final Value<String> kind;
  final Value<int?> intervalSec;
  final Value<String?> cronExpr;
  final Value<DateTime?> nextRunAt;
  final Value<DateTime?> lastRunAt;
  final Value<String> status;
  final Value<int> failCount;
  final Value<String?> lastError;
  final Value<DateTime> createdAt;
  const TasksCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.prompt = const Value.absent(),
    this.skill = const Value.absent(),
    this.kind = const Value.absent(),
    this.intervalSec = const Value.absent(),
    this.cronExpr = const Value.absent(),
    this.nextRunAt = const Value.absent(),
    this.lastRunAt = const Value.absent(),
    this.status = const Value.absent(),
    this.failCount = const Value.absent(),
    this.lastError = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  TasksCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    required String prompt,
    this.skill = const Value.absent(),
    this.kind = const Value.absent(),
    this.intervalSec = const Value.absent(),
    this.cronExpr = const Value.absent(),
    this.nextRunAt = const Value.absent(),
    this.lastRunAt = const Value.absent(),
    this.status = const Value.absent(),
    this.failCount = const Value.absent(),
    this.lastError = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : title = Value(title),
       prompt = Value(prompt);
  static Insertable<Task> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<String>? prompt,
    Expression<String>? skill,
    Expression<String>? kind,
    Expression<int>? intervalSec,
    Expression<String>? cronExpr,
    Expression<DateTime>? nextRunAt,
    Expression<DateTime>? lastRunAt,
    Expression<String>? status,
    Expression<int>? failCount,
    Expression<String>? lastError,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (prompt != null) 'prompt': prompt,
      if (skill != null) 'skill': skill,
      if (kind != null) 'kind': kind,
      if (intervalSec != null) 'interval_sec': intervalSec,
      if (cronExpr != null) 'cron_expr': cronExpr,
      if (nextRunAt != null) 'next_run_at': nextRunAt,
      if (lastRunAt != null) 'last_run_at': lastRunAt,
      if (status != null) 'status': status,
      if (failCount != null) 'fail_count': failCount,
      if (lastError != null) 'last_error': lastError,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  TasksCompanion copyWith({
    Value<int>? id,
    Value<String>? title,
    Value<String>? prompt,
    Value<String?>? skill,
    Value<String>? kind,
    Value<int?>? intervalSec,
    Value<String?>? cronExpr,
    Value<DateTime?>? nextRunAt,
    Value<DateTime?>? lastRunAt,
    Value<String>? status,
    Value<int>? failCount,
    Value<String?>? lastError,
    Value<DateTime>? createdAt,
  }) {
    return TasksCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      prompt: prompt ?? this.prompt,
      skill: skill ?? this.skill,
      kind: kind ?? this.kind,
      intervalSec: intervalSec ?? this.intervalSec,
      cronExpr: cronExpr ?? this.cronExpr,
      nextRunAt: nextRunAt ?? this.nextRunAt,
      lastRunAt: lastRunAt ?? this.lastRunAt,
      status: status ?? this.status,
      failCount: failCount ?? this.failCount,
      lastError: lastError ?? this.lastError,
      createdAt: createdAt ?? this.createdAt,
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
    if (prompt.present) {
      map['prompt'] = Variable<String>(prompt.value);
    }
    if (skill.present) {
      map['skill'] = Variable<String>(skill.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (intervalSec.present) {
      map['interval_sec'] = Variable<int>(intervalSec.value);
    }
    if (cronExpr.present) {
      map['cron_expr'] = Variable<String>(cronExpr.value);
    }
    if (nextRunAt.present) {
      map['next_run_at'] = Variable<DateTime>(nextRunAt.value);
    }
    if (lastRunAt.present) {
      map['last_run_at'] = Variable<DateTime>(lastRunAt.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (failCount.present) {
      map['fail_count'] = Variable<int>(failCount.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TasksCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('prompt: $prompt, ')
          ..write('skill: $skill, ')
          ..write('kind: $kind, ')
          ..write('intervalSec: $intervalSec, ')
          ..write('cronExpr: $cronExpr, ')
          ..write('nextRunAt: $nextRunAt, ')
          ..write('lastRunAt: $lastRunAt, ')
          ..write('status: $status, ')
          ..write('failCount: $failCount, ')
          ..write('lastError: $lastError, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $WatchWalletsTable extends WatchWallets
    with TableInfo<$WatchWalletsTable, WatchWallet> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WatchWalletsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _addressMeta = const VerificationMeta(
    'address',
  );
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
    'address',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _chainIdMeta = const VerificationMeta(
    'chainId',
  );
  @override
  late final GeneratedColumn<int> chainId = GeneratedColumn<int>(
    'chain_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(56),
  );
  static const VerificationMeta _rpcUrlMeta = const VerificationMeta('rpcUrl');
  @override
  late final GeneratedColumn<String> rpcUrl = GeneratedColumn<String>(
    'rpc_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _alertThresholdMeta = const VerificationMeta(
    'alertThreshold',
  );
  @override
  late final GeneratedColumn<double> alertThreshold = GeneratedColumn<double>(
    'alert_threshold',
    aliasedName,
    true,
    type: DriftSqlType.double,
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    label,
    address,
    chainId,
    rpcUrl,
    alertThreshold,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'watch_wallets';
  @override
  VerificationContext validateIntegrity(
    Insertable<WatchWallet> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    if (data.containsKey('address')) {
      context.handle(
        _addressMeta,
        address.isAcceptableOrUnknown(data['address']!, _addressMeta),
      );
    } else if (isInserting) {
      context.missing(_addressMeta);
    }
    if (data.containsKey('chain_id')) {
      context.handle(
        _chainIdMeta,
        chainId.isAcceptableOrUnknown(data['chain_id']!, _chainIdMeta),
      );
    }
    if (data.containsKey('rpc_url')) {
      context.handle(
        _rpcUrlMeta,
        rpcUrl.isAcceptableOrUnknown(data['rpc_url']!, _rpcUrlMeta),
      );
    }
    if (data.containsKey('alert_threshold')) {
      context.handle(
        _alertThresholdMeta,
        alertThreshold.isAcceptableOrUnknown(
          data['alert_threshold']!,
          _alertThresholdMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WatchWallet map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WatchWallet(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      )!,
      address: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}address'],
      )!,
      chainId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}chain_id'],
      )!,
      rpcUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rpc_url'],
      ),
      alertThreshold: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}alert_threshold'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $WatchWalletsTable createAlias(String alias) {
    return $WatchWalletsTable(attachedDatabase, alias);
  }
}

class WatchWallet extends DataClass implements Insertable<WatchWallet> {
  final int id;
  final String label;
  final String address;
  final int chainId;
  final String? rpcUrl;

  /// Ambang saldo (V-08). Null = tanpa peringatan.
  final double? alertThreshold;
  final DateTime createdAt;
  const WatchWallet({
    required this.id,
    required this.label,
    required this.address,
    required this.chainId,
    this.rpcUrl,
    this.alertThreshold,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['label'] = Variable<String>(label);
    map['address'] = Variable<String>(address);
    map['chain_id'] = Variable<int>(chainId);
    if (!nullToAbsent || rpcUrl != null) {
      map['rpc_url'] = Variable<String>(rpcUrl);
    }
    if (!nullToAbsent || alertThreshold != null) {
      map['alert_threshold'] = Variable<double>(alertThreshold);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  WatchWalletsCompanion toCompanion(bool nullToAbsent) {
    return WatchWalletsCompanion(
      id: Value(id),
      label: Value(label),
      address: Value(address),
      chainId: Value(chainId),
      rpcUrl: rpcUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(rpcUrl),
      alertThreshold: alertThreshold == null && nullToAbsent
          ? const Value.absent()
          : Value(alertThreshold),
      createdAt: Value(createdAt),
    );
  }

  factory WatchWallet.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WatchWallet(
      id: serializer.fromJson<int>(json['id']),
      label: serializer.fromJson<String>(json['label']),
      address: serializer.fromJson<String>(json['address']),
      chainId: serializer.fromJson<int>(json['chainId']),
      rpcUrl: serializer.fromJson<String?>(json['rpcUrl']),
      alertThreshold: serializer.fromJson<double?>(json['alertThreshold']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'label': serializer.toJson<String>(label),
      'address': serializer.toJson<String>(address),
      'chainId': serializer.toJson<int>(chainId),
      'rpcUrl': serializer.toJson<String?>(rpcUrl),
      'alertThreshold': serializer.toJson<double?>(alertThreshold),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  WatchWallet copyWith({
    int? id,
    String? label,
    String? address,
    int? chainId,
    Value<String?> rpcUrl = const Value.absent(),
    Value<double?> alertThreshold = const Value.absent(),
    DateTime? createdAt,
  }) => WatchWallet(
    id: id ?? this.id,
    label: label ?? this.label,
    address: address ?? this.address,
    chainId: chainId ?? this.chainId,
    rpcUrl: rpcUrl.present ? rpcUrl.value : this.rpcUrl,
    alertThreshold: alertThreshold.present
        ? alertThreshold.value
        : this.alertThreshold,
    createdAt: createdAt ?? this.createdAt,
  );
  WatchWallet copyWithCompanion(WatchWalletsCompanion data) {
    return WatchWallet(
      id: data.id.present ? data.id.value : this.id,
      label: data.label.present ? data.label.value : this.label,
      address: data.address.present ? data.address.value : this.address,
      chainId: data.chainId.present ? data.chainId.value : this.chainId,
      rpcUrl: data.rpcUrl.present ? data.rpcUrl.value : this.rpcUrl,
      alertThreshold: data.alertThreshold.present
          ? data.alertThreshold.value
          : this.alertThreshold,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WatchWallet(')
          ..write('id: $id, ')
          ..write('label: $label, ')
          ..write('address: $address, ')
          ..write('chainId: $chainId, ')
          ..write('rpcUrl: $rpcUrl, ')
          ..write('alertThreshold: $alertThreshold, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    label,
    address,
    chainId,
    rpcUrl,
    alertThreshold,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WatchWallet &&
          other.id == this.id &&
          other.label == this.label &&
          other.address == this.address &&
          other.chainId == this.chainId &&
          other.rpcUrl == this.rpcUrl &&
          other.alertThreshold == this.alertThreshold &&
          other.createdAt == this.createdAt);
}

class WatchWalletsCompanion extends UpdateCompanion<WatchWallet> {
  final Value<int> id;
  final Value<String> label;
  final Value<String> address;
  final Value<int> chainId;
  final Value<String?> rpcUrl;
  final Value<double?> alertThreshold;
  final Value<DateTime> createdAt;
  const WatchWalletsCompanion({
    this.id = const Value.absent(),
    this.label = const Value.absent(),
    this.address = const Value.absent(),
    this.chainId = const Value.absent(),
    this.rpcUrl = const Value.absent(),
    this.alertThreshold = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  WatchWalletsCompanion.insert({
    this.id = const Value.absent(),
    required String label,
    required String address,
    this.chainId = const Value.absent(),
    this.rpcUrl = const Value.absent(),
    this.alertThreshold = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : label = Value(label),
       address = Value(address);
  static Insertable<WatchWallet> custom({
    Expression<int>? id,
    Expression<String>? label,
    Expression<String>? address,
    Expression<int>? chainId,
    Expression<String>? rpcUrl,
    Expression<double>? alertThreshold,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (label != null) 'label': label,
      if (address != null) 'address': address,
      if (chainId != null) 'chain_id': chainId,
      if (rpcUrl != null) 'rpc_url': rpcUrl,
      if (alertThreshold != null) 'alert_threshold': alertThreshold,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  WatchWalletsCompanion copyWith({
    Value<int>? id,
    Value<String>? label,
    Value<String>? address,
    Value<int>? chainId,
    Value<String?>? rpcUrl,
    Value<double?>? alertThreshold,
    Value<DateTime>? createdAt,
  }) {
    return WatchWalletsCompanion(
      id: id ?? this.id,
      label: label ?? this.label,
      address: address ?? this.address,
      chainId: chainId ?? this.chainId,
      rpcUrl: rpcUrl ?? this.rpcUrl,
      alertThreshold: alertThreshold ?? this.alertThreshold,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (chainId.present) {
      map['chain_id'] = Variable<int>(chainId.value);
    }
    if (rpcUrl.present) {
      map['rpc_url'] = Variable<String>(rpcUrl.value);
    }
    if (alertThreshold.present) {
      map['alert_threshold'] = Variable<double>(alertThreshold.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WatchWalletsCompanion(')
          ..write('id: $id, ')
          ..write('label: $label, ')
          ..write('address: $address, ')
          ..write('chainId: $chainId, ')
          ..write('rpcUrl: $rpcUrl, ')
          ..write('alertThreshold: $alertThreshold, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $OnchainSettingsTable extends OnchainSettings
    with TableInfo<$OnchainSettingsTable, OnchainSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OnchainSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _modeMeta = const VerificationMeta('mode');
  @override
  late final GeneratedColumn<String> mode = GeneratedColumn<String>(
    'mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('manual'),
  );
  static const VerificationMeta _limitPerTxMeta = const VerificationMeta(
    'limitPerTx',
  );
  @override
  late final GeneratedColumn<double> limitPerTx = GeneratedColumn<double>(
    'limit_per_tx',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.01),
  );
  static const VerificationMeta _limitPerDayMeta = const VerificationMeta(
    'limitPerDay',
  );
  @override
  late final GeneratedColumn<double> limitPerDay = GeneratedColumn<double>(
    'limit_per_day',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.05),
  );
  static const VerificationMeta _maxGasGweiMeta = const VerificationMeta(
    'maxGasGwei',
  );
  @override
  late final GeneratedColumn<double> maxGasGwei = GeneratedColumn<double>(
    'max_gas_gwei',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(5),
  );
  static const VerificationMeta _autoRevertDaysMeta = const VerificationMeta(
    'autoRevertDays',
  );
  @override
  late final GeneratedColumn<int> autoRevertDays = GeneratedColumn<int>(
    'auto_revert_days',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(7),
  );
  static const VerificationMeta _autoActivatedAtMeta = const VerificationMeta(
    'autoActivatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> autoActivatedAt =
      GeneratedColumn<DateTime>(
        'auto_activated_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    mode,
    limitPerTx,
    limitPerDay,
    maxGasGwei,
    autoRevertDays,
    autoActivatedAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'onchain_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<OnchainSetting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('mode')) {
      context.handle(
        _modeMeta,
        mode.isAcceptableOrUnknown(data['mode']!, _modeMeta),
      );
    }
    if (data.containsKey('limit_per_tx')) {
      context.handle(
        _limitPerTxMeta,
        limitPerTx.isAcceptableOrUnknown(
          data['limit_per_tx']!,
          _limitPerTxMeta,
        ),
      );
    }
    if (data.containsKey('limit_per_day')) {
      context.handle(
        _limitPerDayMeta,
        limitPerDay.isAcceptableOrUnknown(
          data['limit_per_day']!,
          _limitPerDayMeta,
        ),
      );
    }
    if (data.containsKey('max_gas_gwei')) {
      context.handle(
        _maxGasGweiMeta,
        maxGasGwei.isAcceptableOrUnknown(
          data['max_gas_gwei']!,
          _maxGasGweiMeta,
        ),
      );
    }
    if (data.containsKey('auto_revert_days')) {
      context.handle(
        _autoRevertDaysMeta,
        autoRevertDays.isAcceptableOrUnknown(
          data['auto_revert_days']!,
          _autoRevertDaysMeta,
        ),
      );
    }
    if (data.containsKey('auto_activated_at')) {
      context.handle(
        _autoActivatedAtMeta,
        autoActivatedAt.isAcceptableOrUnknown(
          data['auto_activated_at']!,
          _autoActivatedAtMeta,
        ),
      );
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
  OnchainSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OnchainSetting(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      mode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mode'],
      )!,
      limitPerTx: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}limit_per_tx'],
      )!,
      limitPerDay: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}limit_per_day'],
      )!,
      maxGasGwei: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}max_gas_gwei'],
      )!,
      autoRevertDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}auto_revert_days'],
      )!,
      autoActivatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}auto_activated_at'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $OnchainSettingsTable createAlias(String alias) {
    return $OnchainSettingsTable(attachedDatabase, alias);
  }
}

class OnchainSetting extends DataClass implements Insertable<OnchainSetting> {
  final int id;

  /// 'manual' | 'auto_limited' | 'auto_full'
  final String mode;
  final double limitPerTx;
  final double limitPerDay;
  final double maxGasGwei;
  final int autoRevertDays;
  final DateTime? autoActivatedAt;
  final DateTime updatedAt;
  const OnchainSetting({
    required this.id,
    required this.mode,
    required this.limitPerTx,
    required this.limitPerDay,
    required this.maxGasGwei,
    required this.autoRevertDays,
    this.autoActivatedAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['mode'] = Variable<String>(mode);
    map['limit_per_tx'] = Variable<double>(limitPerTx);
    map['limit_per_day'] = Variable<double>(limitPerDay);
    map['max_gas_gwei'] = Variable<double>(maxGasGwei);
    map['auto_revert_days'] = Variable<int>(autoRevertDays);
    if (!nullToAbsent || autoActivatedAt != null) {
      map['auto_activated_at'] = Variable<DateTime>(autoActivatedAt);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  OnchainSettingsCompanion toCompanion(bool nullToAbsent) {
    return OnchainSettingsCompanion(
      id: Value(id),
      mode: Value(mode),
      limitPerTx: Value(limitPerTx),
      limitPerDay: Value(limitPerDay),
      maxGasGwei: Value(maxGasGwei),
      autoRevertDays: Value(autoRevertDays),
      autoActivatedAt: autoActivatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(autoActivatedAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory OnchainSetting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OnchainSetting(
      id: serializer.fromJson<int>(json['id']),
      mode: serializer.fromJson<String>(json['mode']),
      limitPerTx: serializer.fromJson<double>(json['limitPerTx']),
      limitPerDay: serializer.fromJson<double>(json['limitPerDay']),
      maxGasGwei: serializer.fromJson<double>(json['maxGasGwei']),
      autoRevertDays: serializer.fromJson<int>(json['autoRevertDays']),
      autoActivatedAt: serializer.fromJson<DateTime?>(json['autoActivatedAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'mode': serializer.toJson<String>(mode),
      'limitPerTx': serializer.toJson<double>(limitPerTx),
      'limitPerDay': serializer.toJson<double>(limitPerDay),
      'maxGasGwei': serializer.toJson<double>(maxGasGwei),
      'autoRevertDays': serializer.toJson<int>(autoRevertDays),
      'autoActivatedAt': serializer.toJson<DateTime?>(autoActivatedAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  OnchainSetting copyWith({
    int? id,
    String? mode,
    double? limitPerTx,
    double? limitPerDay,
    double? maxGasGwei,
    int? autoRevertDays,
    Value<DateTime?> autoActivatedAt = const Value.absent(),
    DateTime? updatedAt,
  }) => OnchainSetting(
    id: id ?? this.id,
    mode: mode ?? this.mode,
    limitPerTx: limitPerTx ?? this.limitPerTx,
    limitPerDay: limitPerDay ?? this.limitPerDay,
    maxGasGwei: maxGasGwei ?? this.maxGasGwei,
    autoRevertDays: autoRevertDays ?? this.autoRevertDays,
    autoActivatedAt: autoActivatedAt.present
        ? autoActivatedAt.value
        : this.autoActivatedAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  OnchainSetting copyWithCompanion(OnchainSettingsCompanion data) {
    return OnchainSetting(
      id: data.id.present ? data.id.value : this.id,
      mode: data.mode.present ? data.mode.value : this.mode,
      limitPerTx: data.limitPerTx.present
          ? data.limitPerTx.value
          : this.limitPerTx,
      limitPerDay: data.limitPerDay.present
          ? data.limitPerDay.value
          : this.limitPerDay,
      maxGasGwei: data.maxGasGwei.present
          ? data.maxGasGwei.value
          : this.maxGasGwei,
      autoRevertDays: data.autoRevertDays.present
          ? data.autoRevertDays.value
          : this.autoRevertDays,
      autoActivatedAt: data.autoActivatedAt.present
          ? data.autoActivatedAt.value
          : this.autoActivatedAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OnchainSetting(')
          ..write('id: $id, ')
          ..write('mode: $mode, ')
          ..write('limitPerTx: $limitPerTx, ')
          ..write('limitPerDay: $limitPerDay, ')
          ..write('maxGasGwei: $maxGasGwei, ')
          ..write('autoRevertDays: $autoRevertDays, ')
          ..write('autoActivatedAt: $autoActivatedAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    mode,
    limitPerTx,
    limitPerDay,
    maxGasGwei,
    autoRevertDays,
    autoActivatedAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OnchainSetting &&
          other.id == this.id &&
          other.mode == this.mode &&
          other.limitPerTx == this.limitPerTx &&
          other.limitPerDay == this.limitPerDay &&
          other.maxGasGwei == this.maxGasGwei &&
          other.autoRevertDays == this.autoRevertDays &&
          other.autoActivatedAt == this.autoActivatedAt &&
          other.updatedAt == this.updatedAt);
}

class OnchainSettingsCompanion extends UpdateCompanion<OnchainSetting> {
  final Value<int> id;
  final Value<String> mode;
  final Value<double> limitPerTx;
  final Value<double> limitPerDay;
  final Value<double> maxGasGwei;
  final Value<int> autoRevertDays;
  final Value<DateTime?> autoActivatedAt;
  final Value<DateTime> updatedAt;
  const OnchainSettingsCompanion({
    this.id = const Value.absent(),
    this.mode = const Value.absent(),
    this.limitPerTx = const Value.absent(),
    this.limitPerDay = const Value.absent(),
    this.maxGasGwei = const Value.absent(),
    this.autoRevertDays = const Value.absent(),
    this.autoActivatedAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  OnchainSettingsCompanion.insert({
    this.id = const Value.absent(),
    this.mode = const Value.absent(),
    this.limitPerTx = const Value.absent(),
    this.limitPerDay = const Value.absent(),
    this.maxGasGwei = const Value.absent(),
    this.autoRevertDays = const Value.absent(),
    this.autoActivatedAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  static Insertable<OnchainSetting> custom({
    Expression<int>? id,
    Expression<String>? mode,
    Expression<double>? limitPerTx,
    Expression<double>? limitPerDay,
    Expression<double>? maxGasGwei,
    Expression<int>? autoRevertDays,
    Expression<DateTime>? autoActivatedAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (mode != null) 'mode': mode,
      if (limitPerTx != null) 'limit_per_tx': limitPerTx,
      if (limitPerDay != null) 'limit_per_day': limitPerDay,
      if (maxGasGwei != null) 'max_gas_gwei': maxGasGwei,
      if (autoRevertDays != null) 'auto_revert_days': autoRevertDays,
      if (autoActivatedAt != null) 'auto_activated_at': autoActivatedAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  OnchainSettingsCompanion copyWith({
    Value<int>? id,
    Value<String>? mode,
    Value<double>? limitPerTx,
    Value<double>? limitPerDay,
    Value<double>? maxGasGwei,
    Value<int>? autoRevertDays,
    Value<DateTime?>? autoActivatedAt,
    Value<DateTime>? updatedAt,
  }) {
    return OnchainSettingsCompanion(
      id: id ?? this.id,
      mode: mode ?? this.mode,
      limitPerTx: limitPerTx ?? this.limitPerTx,
      limitPerDay: limitPerDay ?? this.limitPerDay,
      maxGasGwei: maxGasGwei ?? this.maxGasGwei,
      autoRevertDays: autoRevertDays ?? this.autoRevertDays,
      autoActivatedAt: autoActivatedAt ?? this.autoActivatedAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (mode.present) {
      map['mode'] = Variable<String>(mode.value);
    }
    if (limitPerTx.present) {
      map['limit_per_tx'] = Variable<double>(limitPerTx.value);
    }
    if (limitPerDay.present) {
      map['limit_per_day'] = Variable<double>(limitPerDay.value);
    }
    if (maxGasGwei.present) {
      map['max_gas_gwei'] = Variable<double>(maxGasGwei.value);
    }
    if (autoRevertDays.present) {
      map['auto_revert_days'] = Variable<int>(autoRevertDays.value);
    }
    if (autoActivatedAt.present) {
      map['auto_activated_at'] = Variable<DateTime>(autoActivatedAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OnchainSettingsCompanion(')
          ..write('id: $id, ')
          ..write('mode: $mode, ')
          ..write('limitPerTx: $limitPerTx, ')
          ..write('limitPerDay: $limitPerDay, ')
          ..write('maxGasGwei: $maxGasGwei, ')
          ..write('autoRevertDays: $autoRevertDays, ')
          ..write('autoActivatedAt: $autoActivatedAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $ContractAllowlistTable extends ContractAllowlist
    with TableInfo<$ContractAllowlistTable, ContractAllowlistData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ContractAllowlistTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _addressMeta = const VerificationMeta(
    'address',
  );
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
    'address',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _functionsMeta = const VerificationMeta(
    'functions',
  );
  @override
  late final GeneratedColumn<String> functions = GeneratedColumn<String>(
    'functions',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('*'),
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    address,
    label,
    functions,
    addedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'contract_allowlist';
  @override
  VerificationContext validateIntegrity(
    Insertable<ContractAllowlistData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('address')) {
      context.handle(
        _addressMeta,
        address.isAcceptableOrUnknown(data['address']!, _addressMeta),
      );
    } else if (isInserting) {
      context.missing(_addressMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    }
    if (data.containsKey('functions')) {
      context.handle(
        _functionsMeta,
        functions.isAcceptableOrUnknown(data['functions']!, _functionsMeta),
      );
    }
    if (data.containsKey('added_at')) {
      context.handle(
        _addedAtMeta,
        addedAt.isAcceptableOrUnknown(data['added_at']!, _addedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ContractAllowlistData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ContractAllowlistData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      address: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}address'],
      )!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      ),
      functions: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}functions'],
      )!,
      addedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}added_at'],
      )!,
    );
  }

  @override
  $ContractAllowlistTable createAlias(String alias) {
    return $ContractAllowlistTable(attachedDatabase, alias);
  }
}

class ContractAllowlistData extends DataClass
    implements Insertable<ContractAllowlistData> {
  final int id;
  final String address;
  final String? label;

  /// Fungsi yang diizinkan dipanggil di kontrak ini (mis. 'claim', 'mint').
  /// Disimpan sebagai list yang dipisah koma; '*' = semua fungsi.
  final String functions;
  final DateTime addedAt;
  const ContractAllowlistData({
    required this.id,
    required this.address,
    this.label,
    required this.functions,
    required this.addedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['address'] = Variable<String>(address);
    if (!nullToAbsent || label != null) {
      map['label'] = Variable<String>(label);
    }
    map['functions'] = Variable<String>(functions);
    map['added_at'] = Variable<DateTime>(addedAt);
    return map;
  }

  ContractAllowlistCompanion toCompanion(bool nullToAbsent) {
    return ContractAllowlistCompanion(
      id: Value(id),
      address: Value(address),
      label: label == null && nullToAbsent
          ? const Value.absent()
          : Value(label),
      functions: Value(functions),
      addedAt: Value(addedAt),
    );
  }

  factory ContractAllowlistData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ContractAllowlistData(
      id: serializer.fromJson<int>(json['id']),
      address: serializer.fromJson<String>(json['address']),
      label: serializer.fromJson<String?>(json['label']),
      functions: serializer.fromJson<String>(json['functions']),
      addedAt: serializer.fromJson<DateTime>(json['addedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'address': serializer.toJson<String>(address),
      'label': serializer.toJson<String?>(label),
      'functions': serializer.toJson<String>(functions),
      'addedAt': serializer.toJson<DateTime>(addedAt),
    };
  }

  ContractAllowlistData copyWith({
    int? id,
    String? address,
    Value<String?> label = const Value.absent(),
    String? functions,
    DateTime? addedAt,
  }) => ContractAllowlistData(
    id: id ?? this.id,
    address: address ?? this.address,
    label: label.present ? label.value : this.label,
    functions: functions ?? this.functions,
    addedAt: addedAt ?? this.addedAt,
  );
  ContractAllowlistData copyWithCompanion(ContractAllowlistCompanion data) {
    return ContractAllowlistData(
      id: data.id.present ? data.id.value : this.id,
      address: data.address.present ? data.address.value : this.address,
      label: data.label.present ? data.label.value : this.label,
      functions: data.functions.present ? data.functions.value : this.functions,
      addedAt: data.addedAt.present ? data.addedAt.value : this.addedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ContractAllowlistData(')
          ..write('id: $id, ')
          ..write('address: $address, ')
          ..write('label: $label, ')
          ..write('functions: $functions, ')
          ..write('addedAt: $addedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, address, label, functions, addedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ContractAllowlistData &&
          other.id == this.id &&
          other.address == this.address &&
          other.label == this.label &&
          other.functions == this.functions &&
          other.addedAt == this.addedAt);
}

class ContractAllowlistCompanion
    extends UpdateCompanion<ContractAllowlistData> {
  final Value<int> id;
  final Value<String> address;
  final Value<String?> label;
  final Value<String> functions;
  final Value<DateTime> addedAt;
  const ContractAllowlistCompanion({
    this.id = const Value.absent(),
    this.address = const Value.absent(),
    this.label = const Value.absent(),
    this.functions = const Value.absent(),
    this.addedAt = const Value.absent(),
  });
  ContractAllowlistCompanion.insert({
    this.id = const Value.absent(),
    required String address,
    this.label = const Value.absent(),
    this.functions = const Value.absent(),
    this.addedAt = const Value.absent(),
  }) : address = Value(address);
  static Insertable<ContractAllowlistData> custom({
    Expression<int>? id,
    Expression<String>? address,
    Expression<String>? label,
    Expression<String>? functions,
    Expression<DateTime>? addedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (address != null) 'address': address,
      if (label != null) 'label': label,
      if (functions != null) 'functions': functions,
      if (addedAt != null) 'added_at': addedAt,
    });
  }

  ContractAllowlistCompanion copyWith({
    Value<int>? id,
    Value<String>? address,
    Value<String?>? label,
    Value<String>? functions,
    Value<DateTime>? addedAt,
  }) {
    return ContractAllowlistCompanion(
      id: id ?? this.id,
      address: address ?? this.address,
      label: label ?? this.label,
      functions: functions ?? this.functions,
      addedAt: addedAt ?? this.addedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (functions.present) {
      map['functions'] = Variable<String>(functions.value);
    }
    if (addedAt.present) {
      map['added_at'] = Variable<DateTime>(addedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ContractAllowlistCompanion(')
          ..write('id: $id, ')
          ..write('address: $address, ')
          ..write('label: $label, ')
          ..write('functions: $functions, ')
          ..write('addedAt: $addedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ConversationsTable conversations = $ConversationsTable(this);
  late final $MessagesTable messages = $MessagesTable(this);
  late final $TasksTable tasks = $TasksTable(this);
  late final $WatchWalletsTable watchWallets = $WatchWalletsTable(this);
  late final $OnchainSettingsTable onchainSettings = $OnchainSettingsTable(
    this,
  );
  late final $ContractAllowlistTable contractAllowlist =
      $ContractAllowlistTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    conversations,
    messages,
    tasks,
    watchWallets,
    onchainSettings,
    contractAllowlist,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'conversations',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('messages', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$ConversationsTableCreateCompanionBuilder =
    ConversationsCompanion Function({
      Value<int> id,
      Value<String> title,
      Value<String?> providerId,
      Value<String?> model,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> tokenEstimate,
      Value<bool> pinned,
    });
typedef $$ConversationsTableUpdateCompanionBuilder =
    ConversationsCompanion Function({
      Value<int> id,
      Value<String> title,
      Value<String?> providerId,
      Value<String?> model,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> tokenEstimate,
      Value<bool> pinned,
    });

final class $$ConversationsTableReferences
    extends BaseReferences<_$AppDatabase, $ConversationsTable, Conversation> {
  $$ConversationsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$MessagesTable, List<Message>> _messagesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.messages,
    aliasName: $_aliasNameGenerator(
      db.conversations.id,
      db.messages.conversationId,
    ),
  );

  $$MessagesTableProcessedTableManager get messagesRefs {
    final manager = $$MessagesTableTableManager(
      $_db,
      $_db.messages,
    ).filter((f) => f.conversationId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_messagesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ConversationsTableFilterComposer
    extends Composer<_$AppDatabase, $ConversationsTable> {
  $$ConversationsTableFilterComposer({
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

  ColumnFilters<String> get providerId => $composableBuilder(
    column: $table.providerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get model => $composableBuilder(
    column: $table.model,
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

  ColumnFilters<int> get tokenEstimate => $composableBuilder(
    column: $table.tokenEstimate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get pinned => $composableBuilder(
    column: $table.pinned,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> messagesRefs(
    Expression<bool> Function($$MessagesTableFilterComposer f) f,
  ) {
    final $$MessagesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.messages,
      getReferencedColumn: (t) => t.conversationId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MessagesTableFilterComposer(
            $db: $db,
            $table: $db.messages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ConversationsTableOrderingComposer
    extends Composer<_$AppDatabase, $ConversationsTable> {
  $$ConversationsTableOrderingComposer({
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

  ColumnOrderings<String> get providerId => $composableBuilder(
    column: $table.providerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get model => $composableBuilder(
    column: $table.model,
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

  ColumnOrderings<int> get tokenEstimate => $composableBuilder(
    column: $table.tokenEstimate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get pinned => $composableBuilder(
    column: $table.pinned,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ConversationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ConversationsTable> {
  $$ConversationsTableAnnotationComposer({
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

  GeneratedColumn<String> get providerId => $composableBuilder(
    column: $table.providerId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get model =>
      $composableBuilder(column: $table.model, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get tokenEstimate => $composableBuilder(
    column: $table.tokenEstimate,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get pinned =>
      $composableBuilder(column: $table.pinned, builder: (column) => column);

  Expression<T> messagesRefs<T extends Object>(
    Expression<T> Function($$MessagesTableAnnotationComposer a) f,
  ) {
    final $$MessagesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.messages,
      getReferencedColumn: (t) => t.conversationId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MessagesTableAnnotationComposer(
            $db: $db,
            $table: $db.messages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ConversationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ConversationsTable,
          Conversation,
          $$ConversationsTableFilterComposer,
          $$ConversationsTableOrderingComposer,
          $$ConversationsTableAnnotationComposer,
          $$ConversationsTableCreateCompanionBuilder,
          $$ConversationsTableUpdateCompanionBuilder,
          (Conversation, $$ConversationsTableReferences),
          Conversation,
          PrefetchHooks Function({bool messagesRefs})
        > {
  $$ConversationsTableTableManager(_$AppDatabase db, $ConversationsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ConversationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ConversationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ConversationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> providerId = const Value.absent(),
                Value<String?> model = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> tokenEstimate = const Value.absent(),
                Value<bool> pinned = const Value.absent(),
              }) => ConversationsCompanion(
                id: id,
                title: title,
                providerId: providerId,
                model: model,
                createdAt: createdAt,
                updatedAt: updatedAt,
                tokenEstimate: tokenEstimate,
                pinned: pinned,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> providerId = const Value.absent(),
                Value<String?> model = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> tokenEstimate = const Value.absent(),
                Value<bool> pinned = const Value.absent(),
              }) => ConversationsCompanion.insert(
                id: id,
                title: title,
                providerId: providerId,
                model: model,
                createdAt: createdAt,
                updatedAt: updatedAt,
                tokenEstimate: tokenEstimate,
                pinned: pinned,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ConversationsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({messagesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (messagesRefs) db.messages],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (messagesRefs)
                    await $_getPrefetchedData<
                      Conversation,
                      $ConversationsTable,
                      Message
                    >(
                      currentTable: table,
                      referencedTable: $$ConversationsTableReferences
                          ._messagesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$ConversationsTableReferences(
                            db,
                            table,
                            p0,
                          ).messagesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.conversationId == item.id,
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

typedef $$ConversationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ConversationsTable,
      Conversation,
      $$ConversationsTableFilterComposer,
      $$ConversationsTableOrderingComposer,
      $$ConversationsTableAnnotationComposer,
      $$ConversationsTableCreateCompanionBuilder,
      $$ConversationsTableUpdateCompanionBuilder,
      (Conversation, $$ConversationsTableReferences),
      Conversation,
      PrefetchHooks Function({bool messagesRefs})
    >;
typedef $$MessagesTableCreateCompanionBuilder =
    MessagesCompanion Function({
      Value<int> id,
      required int conversationId,
      required String role,
      required String content,
      Value<DateTime> createdAt,
      Value<String?> toolName,
      Value<String?> toolStatus,
      Value<int?> toolDurationMs,
      Value<String?> toolArgsJson,
    });
typedef $$MessagesTableUpdateCompanionBuilder =
    MessagesCompanion Function({
      Value<int> id,
      Value<int> conversationId,
      Value<String> role,
      Value<String> content,
      Value<DateTime> createdAt,
      Value<String?> toolName,
      Value<String?> toolStatus,
      Value<int?> toolDurationMs,
      Value<String?> toolArgsJson,
    });

final class $$MessagesTableReferences
    extends BaseReferences<_$AppDatabase, $MessagesTable, Message> {
  $$MessagesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ConversationsTable _conversationIdTable(_$AppDatabase db) =>
      db.conversations.createAlias(
        $_aliasNameGenerator(db.messages.conversationId, db.conversations.id),
      );

  $$ConversationsTableProcessedTableManager get conversationId {
    final $_column = $_itemColumn<int>('conversation_id')!;

    final manager = $$ConversationsTableTableManager(
      $_db,
      $_db.conversations,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_conversationIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$MessagesTableFilterComposer
    extends Composer<_$AppDatabase, $MessagesTable> {
  $$MessagesTableFilterComposer({
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

  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get toolName => $composableBuilder(
    column: $table.toolName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get toolStatus => $composableBuilder(
    column: $table.toolStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get toolDurationMs => $composableBuilder(
    column: $table.toolDurationMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get toolArgsJson => $composableBuilder(
    column: $table.toolArgsJson,
    builder: (column) => ColumnFilters(column),
  );

  $$ConversationsTableFilterComposer get conversationId {
    final $$ConversationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.conversationId,
      referencedTable: $db.conversations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ConversationsTableFilterComposer(
            $db: $db,
            $table: $db.conversations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MessagesTableOrderingComposer
    extends Composer<_$AppDatabase, $MessagesTable> {
  $$MessagesTableOrderingComposer({
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

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get toolName => $composableBuilder(
    column: $table.toolName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get toolStatus => $composableBuilder(
    column: $table.toolStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get toolDurationMs => $composableBuilder(
    column: $table.toolDurationMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get toolArgsJson => $composableBuilder(
    column: $table.toolArgsJson,
    builder: (column) => ColumnOrderings(column),
  );

  $$ConversationsTableOrderingComposer get conversationId {
    final $$ConversationsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.conversationId,
      referencedTable: $db.conversations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ConversationsTableOrderingComposer(
            $db: $db,
            $table: $db.conversations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MessagesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MessagesTable> {
  $$MessagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get toolName =>
      $composableBuilder(column: $table.toolName, builder: (column) => column);

  GeneratedColumn<String> get toolStatus => $composableBuilder(
    column: $table.toolStatus,
    builder: (column) => column,
  );

  GeneratedColumn<int> get toolDurationMs => $composableBuilder(
    column: $table.toolDurationMs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get toolArgsJson => $composableBuilder(
    column: $table.toolArgsJson,
    builder: (column) => column,
  );

  $$ConversationsTableAnnotationComposer get conversationId {
    final $$ConversationsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.conversationId,
      referencedTable: $db.conversations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ConversationsTableAnnotationComposer(
            $db: $db,
            $table: $db.conversations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MessagesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MessagesTable,
          Message,
          $$MessagesTableFilterComposer,
          $$MessagesTableOrderingComposer,
          $$MessagesTableAnnotationComposer,
          $$MessagesTableCreateCompanionBuilder,
          $$MessagesTableUpdateCompanionBuilder,
          (Message, $$MessagesTableReferences),
          Message,
          PrefetchHooks Function({bool conversationId})
        > {
  $$MessagesTableTableManager(_$AppDatabase db, $MessagesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MessagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MessagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MessagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> conversationId = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String?> toolName = const Value.absent(),
                Value<String?> toolStatus = const Value.absent(),
                Value<int?> toolDurationMs = const Value.absent(),
                Value<String?> toolArgsJson = const Value.absent(),
              }) => MessagesCompanion(
                id: id,
                conversationId: conversationId,
                role: role,
                content: content,
                createdAt: createdAt,
                toolName: toolName,
                toolStatus: toolStatus,
                toolDurationMs: toolDurationMs,
                toolArgsJson: toolArgsJson,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int conversationId,
                required String role,
                required String content,
                Value<DateTime> createdAt = const Value.absent(),
                Value<String?> toolName = const Value.absent(),
                Value<String?> toolStatus = const Value.absent(),
                Value<int?> toolDurationMs = const Value.absent(),
                Value<String?> toolArgsJson = const Value.absent(),
              }) => MessagesCompanion.insert(
                id: id,
                conversationId: conversationId,
                role: role,
                content: content,
                createdAt: createdAt,
                toolName: toolName,
                toolStatus: toolStatus,
                toolDurationMs: toolDurationMs,
                toolArgsJson: toolArgsJson,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$MessagesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({conversationId = false}) {
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
                    if (conversationId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.conversationId,
                                referencedTable: $$MessagesTableReferences
                                    ._conversationIdTable(db),
                                referencedColumn: $$MessagesTableReferences
                                    ._conversationIdTable(db)
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

typedef $$MessagesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MessagesTable,
      Message,
      $$MessagesTableFilterComposer,
      $$MessagesTableOrderingComposer,
      $$MessagesTableAnnotationComposer,
      $$MessagesTableCreateCompanionBuilder,
      $$MessagesTableUpdateCompanionBuilder,
      (Message, $$MessagesTableReferences),
      Message,
      PrefetchHooks Function({bool conversationId})
    >;
typedef $$TasksTableCreateCompanionBuilder =
    TasksCompanion Function({
      Value<int> id,
      required String title,
      required String prompt,
      Value<String?> skill,
      Value<String> kind,
      Value<int?> intervalSec,
      Value<String?> cronExpr,
      Value<DateTime?> nextRunAt,
      Value<DateTime?> lastRunAt,
      Value<String> status,
      Value<int> failCount,
      Value<String?> lastError,
      Value<DateTime> createdAt,
    });
typedef $$TasksTableUpdateCompanionBuilder =
    TasksCompanion Function({
      Value<int> id,
      Value<String> title,
      Value<String> prompt,
      Value<String?> skill,
      Value<String> kind,
      Value<int?> intervalSec,
      Value<String?> cronExpr,
      Value<DateTime?> nextRunAt,
      Value<DateTime?> lastRunAt,
      Value<String> status,
      Value<int> failCount,
      Value<String?> lastError,
      Value<DateTime> createdAt,
    });

class $$TasksTableFilterComposer extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableFilterComposer({
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

  ColumnFilters<String> get prompt => $composableBuilder(
    column: $table.prompt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get skill => $composableBuilder(
    column: $table.skill,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get intervalSec => $composableBuilder(
    column: $table.intervalSec,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cronExpr => $composableBuilder(
    column: $table.cronExpr,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get nextRunAt => $composableBuilder(
    column: $table.nextRunAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastRunAt => $composableBuilder(
    column: $table.lastRunAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get failCount => $composableBuilder(
    column: $table.failCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TasksTableOrderingComposer
    extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableOrderingComposer({
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

  ColumnOrderings<String> get prompt => $composableBuilder(
    column: $table.prompt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get skill => $composableBuilder(
    column: $table.skill,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get intervalSec => $composableBuilder(
    column: $table.intervalSec,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cronExpr => $composableBuilder(
    column: $table.cronExpr,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get nextRunAt => $composableBuilder(
    column: $table.nextRunAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastRunAt => $composableBuilder(
    column: $table.lastRunAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get failCount => $composableBuilder(
    column: $table.failCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TasksTableAnnotationComposer
    extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableAnnotationComposer({
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

  GeneratedColumn<String> get prompt =>
      $composableBuilder(column: $table.prompt, builder: (column) => column);

  GeneratedColumn<String> get skill =>
      $composableBuilder(column: $table.skill, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<int> get intervalSec => $composableBuilder(
    column: $table.intervalSec,
    builder: (column) => column,
  );

  GeneratedColumn<String> get cronExpr =>
      $composableBuilder(column: $table.cronExpr, builder: (column) => column);

  GeneratedColumn<DateTime> get nextRunAt =>
      $composableBuilder(column: $table.nextRunAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastRunAt =>
      $composableBuilder(column: $table.lastRunAt, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get failCount =>
      $composableBuilder(column: $table.failCount, builder: (column) => column);

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$TasksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TasksTable,
          Task,
          $$TasksTableFilterComposer,
          $$TasksTableOrderingComposer,
          $$TasksTableAnnotationComposer,
          $$TasksTableCreateCompanionBuilder,
          $$TasksTableUpdateCompanionBuilder,
          (Task, BaseReferences<_$AppDatabase, $TasksTable, Task>),
          Task,
          PrefetchHooks Function()
        > {
  $$TasksTableTableManager(_$AppDatabase db, $TasksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TasksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TasksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TasksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> prompt = const Value.absent(),
                Value<String?> skill = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<int?> intervalSec = const Value.absent(),
                Value<String?> cronExpr = const Value.absent(),
                Value<DateTime?> nextRunAt = const Value.absent(),
                Value<DateTime?> lastRunAt = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> failCount = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => TasksCompanion(
                id: id,
                title: title,
                prompt: prompt,
                skill: skill,
                kind: kind,
                intervalSec: intervalSec,
                cronExpr: cronExpr,
                nextRunAt: nextRunAt,
                lastRunAt: lastRunAt,
                status: status,
                failCount: failCount,
                lastError: lastError,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String title,
                required String prompt,
                Value<String?> skill = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<int?> intervalSec = const Value.absent(),
                Value<String?> cronExpr = const Value.absent(),
                Value<DateTime?> nextRunAt = const Value.absent(),
                Value<DateTime?> lastRunAt = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> failCount = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => TasksCompanion.insert(
                id: id,
                title: title,
                prompt: prompt,
                skill: skill,
                kind: kind,
                intervalSec: intervalSec,
                cronExpr: cronExpr,
                nextRunAt: nextRunAt,
                lastRunAt: lastRunAt,
                status: status,
                failCount: failCount,
                lastError: lastError,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TasksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TasksTable,
      Task,
      $$TasksTableFilterComposer,
      $$TasksTableOrderingComposer,
      $$TasksTableAnnotationComposer,
      $$TasksTableCreateCompanionBuilder,
      $$TasksTableUpdateCompanionBuilder,
      (Task, BaseReferences<_$AppDatabase, $TasksTable, Task>),
      Task,
      PrefetchHooks Function()
    >;
typedef $$WatchWalletsTableCreateCompanionBuilder =
    WatchWalletsCompanion Function({
      Value<int> id,
      required String label,
      required String address,
      Value<int> chainId,
      Value<String?> rpcUrl,
      Value<double?> alertThreshold,
      Value<DateTime> createdAt,
    });
typedef $$WatchWalletsTableUpdateCompanionBuilder =
    WatchWalletsCompanion Function({
      Value<int> id,
      Value<String> label,
      Value<String> address,
      Value<int> chainId,
      Value<String?> rpcUrl,
      Value<double?> alertThreshold,
      Value<DateTime> createdAt,
    });

class $$WatchWalletsTableFilterComposer
    extends Composer<_$AppDatabase, $WatchWalletsTable> {
  $$WatchWalletsTableFilterComposer({
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

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get chainId => $composableBuilder(
    column: $table.chainId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rpcUrl => $composableBuilder(
    column: $table.rpcUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get alertThreshold => $composableBuilder(
    column: $table.alertThreshold,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WatchWalletsTableOrderingComposer
    extends Composer<_$AppDatabase, $WatchWalletsTable> {
  $$WatchWalletsTableOrderingComposer({
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

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get chainId => $composableBuilder(
    column: $table.chainId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rpcUrl => $composableBuilder(
    column: $table.rpcUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get alertThreshold => $composableBuilder(
    column: $table.alertThreshold,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WatchWalletsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WatchWalletsTable> {
  $$WatchWalletsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<int> get chainId =>
      $composableBuilder(column: $table.chainId, builder: (column) => column);

  GeneratedColumn<String> get rpcUrl =>
      $composableBuilder(column: $table.rpcUrl, builder: (column) => column);

  GeneratedColumn<double> get alertThreshold => $composableBuilder(
    column: $table.alertThreshold,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$WatchWalletsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WatchWalletsTable,
          WatchWallet,
          $$WatchWalletsTableFilterComposer,
          $$WatchWalletsTableOrderingComposer,
          $$WatchWalletsTableAnnotationComposer,
          $$WatchWalletsTableCreateCompanionBuilder,
          $$WatchWalletsTableUpdateCompanionBuilder,
          (
            WatchWallet,
            BaseReferences<_$AppDatabase, $WatchWalletsTable, WatchWallet>,
          ),
          WatchWallet,
          PrefetchHooks Function()
        > {
  $$WatchWalletsTableTableManager(_$AppDatabase db, $WatchWalletsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WatchWalletsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WatchWalletsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WatchWalletsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> label = const Value.absent(),
                Value<String> address = const Value.absent(),
                Value<int> chainId = const Value.absent(),
                Value<String?> rpcUrl = const Value.absent(),
                Value<double?> alertThreshold = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => WatchWalletsCompanion(
                id: id,
                label: label,
                address: address,
                chainId: chainId,
                rpcUrl: rpcUrl,
                alertThreshold: alertThreshold,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String label,
                required String address,
                Value<int> chainId = const Value.absent(),
                Value<String?> rpcUrl = const Value.absent(),
                Value<double?> alertThreshold = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => WatchWalletsCompanion.insert(
                id: id,
                label: label,
                address: address,
                chainId: chainId,
                rpcUrl: rpcUrl,
                alertThreshold: alertThreshold,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WatchWalletsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WatchWalletsTable,
      WatchWallet,
      $$WatchWalletsTableFilterComposer,
      $$WatchWalletsTableOrderingComposer,
      $$WatchWalletsTableAnnotationComposer,
      $$WatchWalletsTableCreateCompanionBuilder,
      $$WatchWalletsTableUpdateCompanionBuilder,
      (
        WatchWallet,
        BaseReferences<_$AppDatabase, $WatchWalletsTable, WatchWallet>,
      ),
      WatchWallet,
      PrefetchHooks Function()
    >;
typedef $$OnchainSettingsTableCreateCompanionBuilder =
    OnchainSettingsCompanion Function({
      Value<int> id,
      Value<String> mode,
      Value<double> limitPerTx,
      Value<double> limitPerDay,
      Value<double> maxGasGwei,
      Value<int> autoRevertDays,
      Value<DateTime?> autoActivatedAt,
      Value<DateTime> updatedAt,
    });
typedef $$OnchainSettingsTableUpdateCompanionBuilder =
    OnchainSettingsCompanion Function({
      Value<int> id,
      Value<String> mode,
      Value<double> limitPerTx,
      Value<double> limitPerDay,
      Value<double> maxGasGwei,
      Value<int> autoRevertDays,
      Value<DateTime?> autoActivatedAt,
      Value<DateTime> updatedAt,
    });

class $$OnchainSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $OnchainSettingsTable> {
  $$OnchainSettingsTableFilterComposer({
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

  ColumnFilters<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get limitPerTx => $composableBuilder(
    column: $table.limitPerTx,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get limitPerDay => $composableBuilder(
    column: $table.limitPerDay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get maxGasGwei => $composableBuilder(
    column: $table.maxGasGwei,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get autoRevertDays => $composableBuilder(
    column: $table.autoRevertDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get autoActivatedAt => $composableBuilder(
    column: $table.autoActivatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$OnchainSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $OnchainSettingsTable> {
  $$OnchainSettingsTableOrderingComposer({
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

  ColumnOrderings<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get limitPerTx => $composableBuilder(
    column: $table.limitPerTx,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get limitPerDay => $composableBuilder(
    column: $table.limitPerDay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get maxGasGwei => $composableBuilder(
    column: $table.maxGasGwei,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get autoRevertDays => $composableBuilder(
    column: $table.autoRevertDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get autoActivatedAt => $composableBuilder(
    column: $table.autoActivatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$OnchainSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $OnchainSettingsTable> {
  $$OnchainSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get mode =>
      $composableBuilder(column: $table.mode, builder: (column) => column);

  GeneratedColumn<double> get limitPerTx => $composableBuilder(
    column: $table.limitPerTx,
    builder: (column) => column,
  );

  GeneratedColumn<double> get limitPerDay => $composableBuilder(
    column: $table.limitPerDay,
    builder: (column) => column,
  );

  GeneratedColumn<double> get maxGasGwei => $composableBuilder(
    column: $table.maxGasGwei,
    builder: (column) => column,
  );

  GeneratedColumn<int> get autoRevertDays => $composableBuilder(
    column: $table.autoRevertDays,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get autoActivatedAt => $composableBuilder(
    column: $table.autoActivatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$OnchainSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $OnchainSettingsTable,
          OnchainSetting,
          $$OnchainSettingsTableFilterComposer,
          $$OnchainSettingsTableOrderingComposer,
          $$OnchainSettingsTableAnnotationComposer,
          $$OnchainSettingsTableCreateCompanionBuilder,
          $$OnchainSettingsTableUpdateCompanionBuilder,
          (
            OnchainSetting,
            BaseReferences<
              _$AppDatabase,
              $OnchainSettingsTable,
              OnchainSetting
            >,
          ),
          OnchainSetting,
          PrefetchHooks Function()
        > {
  $$OnchainSettingsTableTableManager(
    _$AppDatabase db,
    $OnchainSettingsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OnchainSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OnchainSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OnchainSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> mode = const Value.absent(),
                Value<double> limitPerTx = const Value.absent(),
                Value<double> limitPerDay = const Value.absent(),
                Value<double> maxGasGwei = const Value.absent(),
                Value<int> autoRevertDays = const Value.absent(),
                Value<DateTime?> autoActivatedAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => OnchainSettingsCompanion(
                id: id,
                mode: mode,
                limitPerTx: limitPerTx,
                limitPerDay: limitPerDay,
                maxGasGwei: maxGasGwei,
                autoRevertDays: autoRevertDays,
                autoActivatedAt: autoActivatedAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> mode = const Value.absent(),
                Value<double> limitPerTx = const Value.absent(),
                Value<double> limitPerDay = const Value.absent(),
                Value<double> maxGasGwei = const Value.absent(),
                Value<int> autoRevertDays = const Value.absent(),
                Value<DateTime?> autoActivatedAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => OnchainSettingsCompanion.insert(
                id: id,
                mode: mode,
                limitPerTx: limitPerTx,
                limitPerDay: limitPerDay,
                maxGasGwei: maxGasGwei,
                autoRevertDays: autoRevertDays,
                autoActivatedAt: autoActivatedAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$OnchainSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $OnchainSettingsTable,
      OnchainSetting,
      $$OnchainSettingsTableFilterComposer,
      $$OnchainSettingsTableOrderingComposer,
      $$OnchainSettingsTableAnnotationComposer,
      $$OnchainSettingsTableCreateCompanionBuilder,
      $$OnchainSettingsTableUpdateCompanionBuilder,
      (
        OnchainSetting,
        BaseReferences<_$AppDatabase, $OnchainSettingsTable, OnchainSetting>,
      ),
      OnchainSetting,
      PrefetchHooks Function()
    >;
typedef $$ContractAllowlistTableCreateCompanionBuilder =
    ContractAllowlistCompanion Function({
      Value<int> id,
      required String address,
      Value<String?> label,
      Value<String> functions,
      Value<DateTime> addedAt,
    });
typedef $$ContractAllowlistTableUpdateCompanionBuilder =
    ContractAllowlistCompanion Function({
      Value<int> id,
      Value<String> address,
      Value<String?> label,
      Value<String> functions,
      Value<DateTime> addedAt,
    });

class $$ContractAllowlistTableFilterComposer
    extends Composer<_$AppDatabase, $ContractAllowlistTable> {
  $$ContractAllowlistTableFilterComposer({
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

  ColumnFilters<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get functions => $composableBuilder(
    column: $table.functions,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ContractAllowlistTableOrderingComposer
    extends Composer<_$AppDatabase, $ContractAllowlistTable> {
  $$ContractAllowlistTableOrderingComposer({
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

  ColumnOrderings<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get functions => $composableBuilder(
    column: $table.functions,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ContractAllowlistTableAnnotationComposer
    extends Composer<_$AppDatabase, $ContractAllowlistTable> {
  $$ContractAllowlistTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<String> get functions =>
      $composableBuilder(column: $table.functions, builder: (column) => column);

  GeneratedColumn<DateTime> get addedAt =>
      $composableBuilder(column: $table.addedAt, builder: (column) => column);
}

class $$ContractAllowlistTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ContractAllowlistTable,
          ContractAllowlistData,
          $$ContractAllowlistTableFilterComposer,
          $$ContractAllowlistTableOrderingComposer,
          $$ContractAllowlistTableAnnotationComposer,
          $$ContractAllowlistTableCreateCompanionBuilder,
          $$ContractAllowlistTableUpdateCompanionBuilder,
          (
            ContractAllowlistData,
            BaseReferences<
              _$AppDatabase,
              $ContractAllowlistTable,
              ContractAllowlistData
            >,
          ),
          ContractAllowlistData,
          PrefetchHooks Function()
        > {
  $$ContractAllowlistTableTableManager(
    _$AppDatabase db,
    $ContractAllowlistTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ContractAllowlistTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ContractAllowlistTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ContractAllowlistTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> address = const Value.absent(),
                Value<String?> label = const Value.absent(),
                Value<String> functions = const Value.absent(),
                Value<DateTime> addedAt = const Value.absent(),
              }) => ContractAllowlistCompanion(
                id: id,
                address: address,
                label: label,
                functions: functions,
                addedAt: addedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String address,
                Value<String?> label = const Value.absent(),
                Value<String> functions = const Value.absent(),
                Value<DateTime> addedAt = const Value.absent(),
              }) => ContractAllowlistCompanion.insert(
                id: id,
                address: address,
                label: label,
                functions: functions,
                addedAt: addedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ContractAllowlistTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ContractAllowlistTable,
      ContractAllowlistData,
      $$ContractAllowlistTableFilterComposer,
      $$ContractAllowlistTableOrderingComposer,
      $$ContractAllowlistTableAnnotationComposer,
      $$ContractAllowlistTableCreateCompanionBuilder,
      $$ContractAllowlistTableUpdateCompanionBuilder,
      (
        ContractAllowlistData,
        BaseReferences<
          _$AppDatabase,
          $ContractAllowlistTable,
          ContractAllowlistData
        >,
      ),
      ContractAllowlistData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ConversationsTableTableManager get conversations =>
      $$ConversationsTableTableManager(_db, _db.conversations);
  $$MessagesTableTableManager get messages =>
      $$MessagesTableTableManager(_db, _db.messages);
  $$TasksTableTableManager get tasks =>
      $$TasksTableTableManager(_db, _db.tasks);
  $$WatchWalletsTableTableManager get watchWallets =>
      $$WatchWalletsTableTableManager(_db, _db.watchWallets);
  $$OnchainSettingsTableTableManager get onchainSettings =>
      $$OnchainSettingsTableTableManager(_db, _db.onchainSettings);
  $$ContractAllowlistTableTableManager get contractAllowlist =>
      $$ContractAllowlistTableTableManager(_db, _db.contractAllowlist);
}
