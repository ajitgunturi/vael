import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:vael/core/sync/manifest.dart';

void main() {
  group('ManifestV2', () {
    ManifestV2 makeManifest() {
      return ManifestV2(
        familyId: 'f-001',
        owner: ManifestOwner(userId: 'u-admin', email: 'admin@test.com'),
        members: {
          'u-admin': MemberEntry(
            userId: 'u-admin',
            email: 'admin@test.com',
            role: 'admin',
            wrappedFek: Uint8List.fromList(List.generate(60, (i) => i)),
            fekSalt: Uint8List.fromList(List.generate(32, (i) => i)),
            addedAt: DateTime.utc(2026, 3, 20),
            addedBy: 'u-admin',
          ),
        },
      );
    }

    test('serializes and deserializes round-trip', () {
      final manifest = makeManifest();
      final json = manifest.toJson();
      final restored = ManifestV2.fromJson(json);

      expect(restored.familyId, 'f-001');
      expect(restored.owner.userId, 'u-admin');
      expect(restored.members, hasLength(1));
      expect(restored.members['u-admin']!.email, 'admin@test.com');
      expect(restored.fekGeneration, 1);
    });

    test('isV2 detects V2 format', () {
      final json = makeManifest().toJson();
      expect(ManifestV2.isV2(json), isTrue);
    });

    test('isV2 rejects V1 format', () {
      final v1 = {
        'family_id': 'f-001',
        'wrapped_fek': [1, 2],
        'salt': [3, 4],
      };
      expect(ManifestV2.isV2(v1), isFalse);
    });

    test('migrateFromV1 creates V2 with admin entry', () {
      final v1 = {
        'family_id': 'f-001',
        'wrapped_fek': List.generate(60, (i) => i),
        'salt': List.generate(32, (i) => i),
      };

      final v2 = ManifestV2.migrateFromV1(
        v1: v1,
        adminUserId: 'u-admin',
        adminEmail: 'admin@test.com',
      );

      expect(v2.familyId, 'f-001');
      expect(v2.owner.userId, 'u-admin');
      expect(v2.members, hasLength(1));
      expect(v2.members['u-admin']!.role, 'admin');
      expect(v2.members['u-admin']!.wrappedFek, hasLength(60));
    });

    test('addMember adds entry', () {
      final manifest = makeManifest();
      final updated = manifest.addMember(
        MemberEntry(
          userId: 'u-member',
          email: 'member@test.com',
          role: 'member',
          wrappedFek: Uint8List(60),
          fekSalt: Uint8List(32),
          addedAt: DateTime.utc(2026, 3, 21),
          addedBy: 'u-admin',
        ),
      );

      expect(updated.members, hasLength(2));
      expect(updated.members['u-member']!.email, 'member@test.com');
    });

    test('revokeMember marks as revoked', () {
      var manifest = makeManifest();
      manifest = manifest.addMember(
        MemberEntry(
          userId: 'u-member',
          email: 'member@test.com',
          role: 'member',
          wrappedFek: Uint8List(60),
          fekSalt: Uint8List(32),
          addedAt: DateTime.utc(2026, 3, 21),
          addedBy: 'u-admin',
        ),
      );

      final updated = manifest.revokeMember('u-member');
      expect(updated.members['u-member']!.status, MemberStatus.revoked);
      expect(updated.activeMembers, hasLength(1));
    });

    test('withRotatedFek increments generation', () {
      final manifest = makeManifest();
      final newWrapped = {
        'u-admin': Uint8List.fromList(List.generate(60, (i) => i + 100)),
      };

      final updated = manifest.withRotatedFek(newWrapped);
      expect(updated.fekGeneration, 2);
      expect(updated.members['u-admin']!.wrappedFek[0], 100);
    });

    test('transferOwnership swaps roles', () {
      var manifest = makeManifest();
      manifest = manifest.addMember(
        MemberEntry(
          userId: 'u-member',
          email: 'member@test.com',
          role: 'member',
          wrappedFek: Uint8List(60),
          fekSalt: Uint8List(32),
          addedAt: DateTime.utc(2026, 3, 21),
          addedBy: 'u-admin',
        ),
      );

      final updated = manifest.transferOwnership('u-member');
      expect(updated.owner.userId, 'u-member');
      expect(updated.members['u-member']!.role, 'admin');
      expect(updated.members['u-admin']!.role, 'member');
    });

    test('activeMembers excludes revoked', () {
      var manifest = makeManifest();
      manifest = manifest.addMember(
        MemberEntry(
          userId: 'u-revoked',
          email: 'revoked@test.com',
          role: 'member',
          wrappedFek: Uint8List(60),
          fekSalt: Uint8List(32),
          addedAt: DateTime.utc(2026, 3, 21),
          addedBy: 'u-admin',
          status: MemberStatus.revoked,
        ),
      );

      expect(manifest.members, hasLength(2));
      expect(manifest.activeMembers, hasLength(1));
    });
  });
}
