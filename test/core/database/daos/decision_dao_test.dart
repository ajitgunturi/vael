import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vael/core/database/database.dart';
import 'package:vael/core/database/daos/decision_dao.dart';

void main() {
  late AppDatabase db;
  late DecisionDao dao;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    dao = DecisionDao(db);
  });

  tearDown(() async {
    await db.close();
  });

  Future<void> _seedFamily(String familyId) async {
    await db
        .into(db.families)
        .insert(
          FamiliesCompanion.insert(
            id: familyId,
            name: 'Family $familyId',
            createdAt: DateTime(2025),
          ),
        );
  }

  DecisionsCompanion _makeDecision({
    required String id,
    String userId = 'user_a',
    String familyId = 'fam_a',
    String decisionType = 'purchaseGoal',
    String name = 'Test Decision',
    String parameters = '{}',
    String status = 'preview',
  }) {
    return DecisionsCompanion(
      id: Value(id),
      userId: Value(userId),
      familyId: Value(familyId),
      decisionType: Value(decisionType),
      name: Value(name),
      parameters: Value(parameters),
      status: Value(status),
      createdAt: Value(DateTime(2025)),
    );
  }

  group('DecisionDao', () {
    test('insertDecision + getById round-trip', () async {
      await _seedFamily('fam_a');

      await dao.insertDecision(_makeDecision(id: 'd1', name: 'Buy Car'));

      final decision = await dao.getById('d1');
      expect(decision, isNotNull);
      expect(decision!.id, 'd1');
      expect(decision.name, 'Buy Car');
      expect(decision.status, 'preview');
      expect(decision.implementedAt, isNull);
      expect(decision.deletedAt, isNull);
    });

    test('watchForUser excludes soft-deleted decisions', () async {
      await _seedFamily('fam_a');

      await dao.insertDecision(_makeDecision(id: 'd1', name: 'Active'));
      await dao.insertDecision(_makeDecision(id: 'd2', name: 'Deleted'));
      await dao.softDelete('d2');

      final emissions = <List<Decision>>[];
      dao.watchForUser('user_a', 'fam_a').listen(emissions.add);

      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(emissions.last, hasLength(1));
      expect(emissions.last.first.name, 'Active');
    });

    test('markImplemented updates status and implementedAt', () async {
      await _seedFamily('fam_a');

      await dao.insertDecision(_makeDecision(id: 'd1'));

      var decision = await dao.getById('d1');
      expect(decision!.status, 'preview');
      expect(decision.implementedAt, isNull);

      await dao.markImplemented('d1');

      decision = await dao.getById('d1');
      expect(decision!.status, 'implemented');
      expect(decision.implementedAt, isNotNull);
    });

    test('softDelete sets deletedAt', () async {
      await _seedFamily('fam_a');

      await dao.insertDecision(_makeDecision(id: 'd1'));

      var decision = await dao.getById('d1');
      expect(decision!.deletedAt, isNull);

      await dao.softDelete('d1');

      decision = await dao.getById('d1');
      expect(decision!.deletedAt, isNotNull);
    });
  });
}
