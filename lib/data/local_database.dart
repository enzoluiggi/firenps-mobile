import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/company.dart';
import '../models/user_profile.dart';

class LocalAuthData {
  const LocalAuthData({
    required this.companies,
    required this.users,
    required this.passwordsByEmail,
  });

  final List<Company> companies;
  final List<UserProfile> users;
  final Map<String, String> passwordsByEmail;
}

class LocalDatabase {
  Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    // O SQLite cria um arquivo no aparelho. Tudo que for salvo aqui continua
    // existindo mesmo depois que o aplicativo for fechado.
    final databasesPath = await getDatabasesPath();
    final databasePath = join(databasesPath, 'fire_nps.db');

    _database = await openDatabase(
      databasePath,
      version: 1,
      onCreate: _createDatabase,
    );

    return _database!;
  }

  Future<void> _createDatabase(Database db, int version) async {
    // A tabela companies guarda os dados basicos da empresa vinculada ao usuario.
    await db.execute('''
      CREATE TABLE companies (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        segment TEXT NOT NULL
      )
    ''');

    // A tabela users guarda os dados de acesso e perfil.
    // Em um sistema real, a senha deve ser salva com hash/criptografia, nunca em texto puro.
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        full_name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        company_name TEXT NOT NULL,
        business_segment TEXT NOT NULL,
        company_id TEXT NOT NULL,
        role TEXT NOT NULL
      )
    ''');
  }

  Future<void> bootstrapIfEmpty({
    required List<Company> companies,
    required List<UserProfile> users,
    required String defaultPassword,
  }) async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) AS total FROM users');
    final total = Sqflite.firstIntValue(result) ?? 0;

    if (total > 0) {
      return;
    }

    // Batch executa varios inserts juntos, deixando a carga inicial mais simples.
    final batch = db.batch();
    for (final company in companies) {
      batch.insert(
        'companies',
        _companyToMap(company),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    for (final user in users) {
      batch.insert(
        'users',
        _userToMap(user, defaultPassword),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<LocalAuthData> loadAuthData() async {
    final db = await database;
    final companyRows = await db.query('companies', orderBy: 'name ASC');
    final userRows = await db.query('users', orderBy: 'full_name ASC');

    final users = userRows.map(_userFromMap).toList();
    final passwordsByEmail = <String, String>{};
    for (final row in userRows) {
      passwordsByEmail[(row['email'] as String).toLowerCase()] =
          row['password'] as String;
    }

    return LocalAuthData(
      companies: companyRows.map(_companyFromMap).toList(),
      users: users,
      passwordsByEmail: passwordsByEmail,
    );
  }

  Future<void> saveCompanyAndUser({
    required Company company,
    required UserProfile user,
    required String password,
  }) async {
    final db = await database;

    await db.transaction((transaction) async {
      await transaction.insert(
        'companies',
        _companyToMap(company),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      await transaction.insert(
        'users',
        _userToMap(user, password),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    });
  }

  Future<void> updateCompanyAndUser({
    required Company company,
    required UserProfile user,
  }) async {
    final db = await database;

    await db.transaction((transaction) async {
      await transaction.update(
        'companies',
        _companyToMap(company),
        where: 'id = ?',
        whereArgs: [company.id],
      );
      await transaction.update(
        'users',
        _userProfileToMap(user),
        where: 'id = ?',
        whereArgs: [user.id],
      );
    });
  }

  Map<String, Object?> _companyToMap(Company company) {
    return {'id': company.id, 'name': company.name, 'segment': company.segment};
  }

  Map<String, Object?> _userToMap(UserProfile user, String password) {
    return {..._userProfileToMap(user), 'password': password};
  }

  Map<String, Object?> _userProfileToMap(UserProfile user) {
    return {
      'id': user.id,
      'full_name': user.fullName,
      'email': user.email,
      'company_name': user.companyName,
      'business_segment': user.businessSegment,
      'company_id': user.companyId,
      'role': user.role,
    };
  }

  Company _companyFromMap(Map<String, Object?> map) {
    return Company(
      id: map['id'] as String,
      name: map['name'] as String,
      segment: map['segment'] as String,
    );
  }

  UserProfile _userFromMap(Map<String, Object?> map) {
    return UserProfile(
      id: map['id'] as String,
      fullName: map['full_name'] as String,
      email: map['email'] as String,
      companyName: map['company_name'] as String,
      businessSegment: map['business_segment'] as String,
      companyId: map['company_id'] as String,
      role: map['role'] as String,
    );
  }
}
