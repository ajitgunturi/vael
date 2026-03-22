import 'dart:typed_data';

/// Schema version for the manifest format.
const int manifestSchemaVersion = 2;

/// Status of a family member in the manifest.
enum MemberStatus { active, revoked, pendingSetup }

/// Per-member key wrapping entry in the manifest.
class MemberEntry {
  final String userId;
  final String email;
  final String role; // 'admin' or 'member'
  final Uint8List wrappedFek;
  final Uint8List fekSalt;
  final DateTime addedAt;
  final String addedBy;
  final DateTime? lastSyncAt;
  final MemberStatus status;

  MemberEntry({
    required this.userId,
    required this.email,
    required this.role,
    required this.wrappedFek,
    required this.fekSalt,
    required this.addedAt,
    required this.addedBy,
    this.lastSyncAt,
    this.status = MemberStatus.active,
  });

  Map<String, dynamic> toJson() => {
    'user_id': userId,
    'email': email,
    'role': role,
    'wrapped_fek': wrappedFek.toList(),
    'fek_salt': fekSalt.toList(),
    'added_at': addedAt.toIso8601String(),
    'added_by': addedBy,
    'last_sync_at': lastSyncAt?.toIso8601String(),
    'status': status.name,
  };

  factory MemberEntry.fromJson(Map<String, dynamic> json) => MemberEntry(
    userId: json['user_id'] as String,
    email: json['email'] as String,
    role: json['role'] as String,
    wrappedFek: Uint8List.fromList((json['wrapped_fek'] as List).cast<int>()),
    fekSalt: Uint8List.fromList((json['fek_salt'] as List).cast<int>()),
    addedAt: DateTime.parse(json['added_at'] as String),
    addedBy: json['added_by'] as String,
    lastSyncAt: json['last_sync_at'] != null
        ? DateTime.parse(json['last_sync_at'] as String)
        : null,
    status: MemberStatus.values.firstWhere(
      (s) => s.name == json['status'],
      orElse: () => MemberStatus.active,
    ),
  );

  MemberEntry copyWith({
    Uint8List? wrappedFek,
    Uint8List? fekSalt,
    DateTime? lastSyncAt,
    MemberStatus? status,
    String? role,
  }) => MemberEntry(
    userId: userId,
    email: email,
    role: role ?? this.role,
    wrappedFek: wrappedFek ?? this.wrappedFek,
    fekSalt: fekSalt ?? this.fekSalt,
    addedAt: addedAt,
    addedBy: addedBy,
    lastSyncAt: lastSyncAt ?? this.lastSyncAt,
    status: status ?? this.status,
  );
}

/// Owner metadata in the manifest.
class ManifestOwner {
  final String userId;
  final String email;
  final String? driveFolderId;

  ManifestOwner({
    required this.userId,
    required this.email,
    this.driveFolderId,
  });

  Map<String, dynamic> toJson() => {
    'user_id': userId,
    'email': email,
    if (driveFolderId != null) 'drive_folder_id': driveFolderId,
  };

  factory ManifestOwner.fromJson(Map<String, dynamic> json) => ManifestOwner(
    userId: json['user_id'] as String,
    email: json['email'] as String,
    driveFolderId: json['drive_folder_id'] as String?,
  );
}

/// V2 manifest with per-member FEK wrapping and explicit ownership.
class ManifestV2 {
  final String familyId;
  final ManifestOwner owner;
  final Map<String, MemberEntry> members;
  final int fekGeneration;
  final DateTime lastUpdated;
  final String? provider; // 'googleDrive' or 'iCloudDrive'

  ManifestV2({
    required this.familyId,
    required this.owner,
    required this.members,
    this.fekGeneration = 1,
    this.provider,
    DateTime? lastUpdated,
  }) : lastUpdated = lastUpdated ?? DateTime.now().toUtc();

  Map<String, dynamic> toJson() => {
    'schema_version': manifestSchemaVersion,
    'family_id': familyId,
    'owner': owner.toJson(),
    'members': members.map((k, v) => MapEntry(k, v.toJson())),
    'fek_generation': fekGeneration,
    'last_updated': lastUpdated.toIso8601String(),
    if (provider != null) 'provider': provider,
  };

  factory ManifestV2.fromJson(Map<String, dynamic> json) {
    final membersJson = json['members'] as Map<String, dynamic>;
    return ManifestV2(
      familyId: json['family_id'] as String,
      owner: ManifestOwner.fromJson(json['owner'] as Map<String, dynamic>),
      members: membersJson.map(
        (k, v) => MapEntry(k, MemberEntry.fromJson(v as Map<String, dynamic>)),
      ),
      fekGeneration: json['fek_generation'] as int? ?? 1,
      provider: json['provider'] as String?,
      lastUpdated: DateTime.parse(json['last_updated'] as String),
    );
  }

  /// Migrate a V1 manifest to V2.
  ///
  /// Takes the single shared wrapped FEK/salt and creates a per-member
  /// entry for the admin who initiates the migration.
  static ManifestV2 migrateFromV1({
    required Map<String, dynamic> v1,
    required String adminUserId,
    required String adminEmail,
  }) {
    final familyId = v1['family_id'] as String;
    final wrappedFek = Uint8List.fromList(
      (v1['wrapped_fek'] as List).cast<int>(),
    );
    final salt = Uint8List.fromList((v1['salt'] as List).cast<int>());

    final adminEntry = MemberEntry(
      userId: adminUserId,
      email: adminEmail,
      role: 'admin',
      wrappedFek: wrappedFek,
      fekSalt: salt,
      addedAt: DateTime.now().toUtc(),
      addedBy: adminUserId,
    );

    return ManifestV2(
      familyId: familyId,
      owner: ManifestOwner(userId: adminUserId, email: adminEmail),
      members: {adminUserId: adminEntry},
    );
  }

  /// Whether the given manifest JSON is V2 format.
  static bool isV2(Map<String, dynamic> json) =>
      json['schema_version'] == manifestSchemaVersion &&
      json.containsKey('owner') &&
      json.containsKey('members');

  /// Get active members only.
  List<MemberEntry> get activeMembers =>
      members.values.where((m) => m.status == MemberStatus.active).toList();

  /// Add a new member with their own wrapped FEK.
  ManifestV2 addMember(MemberEntry entry) => ManifestV2(
    familyId: familyId,
    owner: owner,
    members: {...members, entry.userId: entry},
    fekGeneration: fekGeneration,
  );

  /// Revoke a member (mark as revoked, don't remove — audit trail).
  ManifestV2 revokeMember(String userId) => ManifestV2(
    familyId: familyId,
    owner: owner,
    members: {
      ...members,
      userId: members[userId]!.copyWith(status: MemberStatus.revoked),
    },
    fekGeneration: fekGeneration,
  );

  /// Update all active members' wrapped FEKs after FEK rotation.
  ManifestV2 withRotatedFek(Map<String, Uint8List> newWrappedFeks) {
    final updated = Map<String, MemberEntry>.from(members);
    for (final entry in newWrappedFeks.entries) {
      if (updated.containsKey(entry.key)) {
        updated[entry.key] = updated[entry.key]!.copyWith(
          wrappedFek: entry.value,
        );
      }
    }
    return ManifestV2(
      familyId: familyId,
      owner: owner,
      members: updated,
      fekGeneration: fekGeneration + 1,
    );
  }

  /// Transfer ownership to another member.
  ManifestV2 transferOwnership(String newOwnerId) {
    final newOwnerEntry = members[newOwnerId]!;
    final oldOwnerEntry = members[owner.userId]!;
    return ManifestV2(
      familyId: familyId,
      owner: ManifestOwner(userId: newOwnerId, email: newOwnerEntry.email),
      members: {
        ...members,
        newOwnerId: newOwnerEntry.copyWith(role: 'admin'),
        owner.userId: oldOwnerEntry.copyWith(role: 'member'),
      },
      fekGeneration: fekGeneration,
    );
  }
}
