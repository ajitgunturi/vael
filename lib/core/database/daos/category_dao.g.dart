// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_dao.dart';

// ignore_for_file: type=lint
mixin _$CategoryDaoMixin on DatabaseAccessor<AppDatabase> {
  $FamiliesTable get families => attachedDatabase.families;
  $CategoriesTable get categories => attachedDatabase.categories;
  CategoryDaoManager get managers => CategoryDaoManager(this);
}

class CategoryDaoManager {
  final _$CategoryDaoMixin _db;
  CategoryDaoManager(this._db);
  $$FamiliesTableTableManager get families =>
      $$FamiliesTableTableManager(_db.attachedDatabase, _db.families);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db.attachedDatabase, _db.categories);
}
