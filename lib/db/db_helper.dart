import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:wallet/utils/log_utils.dart';

///
/// local db
///

class DbHelper {
  final String _dbName = 'wallet.db';
  final String _tableWallet = 'wallet'; // 钱包表
  final String _tableContact = 'contact'; //联系人表
  final int _dbVersion = 1;

  static Database _db;

  static DbHelper _instance;

  static DbHelper get instance => DbHelper();

  DbHelper._internal() {
    initDb();
  }

  factory DbHelper() {
    if (_instance == null) {
      _instance = DbHelper._internal();
    }
    return _instance;
  }

  Future<Database> get db async {
    if (_db != null) {
      return _db;
    }
    _db = await initDb();

    return _db;
  }

  initDb() async {
    String databasePath = await getDatabasesPath();
    String path = join(databasePath, _dbName);

    var db = await openDatabase(path,
        version: _dbVersion, onCreate: _onCreate, onUpgrade: _onUpgrade);
    _db = db;
    return db;
  }

  void _onCreate(Database db, int newVersion) async {
    StringBuffer sqlOfWallet = StringBuffer('create table $_tableWallet');
    sqlOfWallet
      ..write('(id INTEGER PRIMARY KEY AUTOINCREMENT,')
      ..write('name TEXT,')
      ..write('address TEXT UNIQUE,')
      ..write('mnemonic TEXT UNIQUE,')
      ..write('password TEXT,')
      ..write('selected INTEGER,')
      ..write('createTime INTEGER)');

    log('sqlOfWallet = $sqlOfWallet');

    StringBuffer sqlOfContact = new StringBuffer("create table $_tableContact");
    sqlOfContact
      ..write("(id INTEGER PRIMARY KEY AUTOINCREMENT,")
      ..write("name TEXT,")
      ..write("address TEXT,")
      ..write("remark TEXT)");

    log('sqlOfContact = $sqlOfContact');

    var batch = db.batch();

    batch.execute(sqlOfWallet.toString());
    batch.execute(sqlOfContact.toString());
    await batch.commit();
  }

  void _onUpgrade(Database db, int oldVersion, int newVersion) async {}

  Future<Map<String, dynamic>> insertWallet(Map<String, dynamic> json) async {
    var dbClient = await db;
    var id = await dbClient.insert(_tableWallet, json);
    json['id'] = id;
    return json;
  }

  Future<int> updateSelectedWallet(String address) async {
    var dbClient = await db;
    String sql1 =
        'update $_tableWallet set selected = 1 where address=?';
    String sql2 =
        'update $_tableWallet set selected = 0 where address<>?';
    var id1 = await dbClient.rawUpdate(sql1, [address]);
    var id2 = await dbClient.rawUpdate(sql2, [address]);

    return id1 + id2;
  }

  Future<Map<String, dynamic>> queryWalletByAddress(
      String walletAddress) async {
    var dbClient = await db;
    log('dbClient = $dbClient');
    List<dynamic> list =
    await dbClient.query(_tableWallet, where: 'address=?', whereArgs: [walletAddress]);

    if (list.isNotEmpty) {
      return list[0];
    }
    return null;
  }

  Future<List<dynamic>> queryWalletList() async {
    var dbClient = await db;
    String sql = 'select * from $_tableWallet order by createTime desc';
    return await dbClient.rawQuery(sql);
  }

  Future<List<dynamic>> queryWalletByName(String walletName) async {
    var dbClient = await db;
    String sql = 'select * from $_tableWallet where name=?';
    return await dbClient.rawQuery(sql, [walletName]);
  }

  Future<int> updateWalletNameByAddress(
      String address, String walletName) async {
    var dbClient = await db;
    String sql =
        'update $_tableWallet set name=? where address=?';
    return await dbClient.rawUpdate(sql, [walletName, address]);
  }

  Future<int> updateWalletPasswordByAddress(
      String address, String walletPassword) async {
    var dbClient = await db;
    String sql =
        'update $_tableWallet set password=? where address=?';
    return await dbClient.rawUpdate(sql, [walletPassword, address]);
  }

  Future<int> deleteWalletByAddress(String address) async {
    var dbClient = await db;
    String sql = "delete from $_tableWallet where address=?";
    return await dbClient.rawDelete(sql, [address]);
  }

  ///--------- 操作联系人 ----------
  Future<int> insertContact(Map<String, dynamic> json) async {
    var dbClient = await db;
    var id = await dbClient.insert(_tableContact, json);
    json['id'] = id;
    return id;
  }

  Future<int> updateContact(String address, String oldName, String newName, String remark) async {
    var dbClient = await db;
    String sql = 'update $_tableContact set name=?, remark=? where address=? and name=?';
    var id = await dbClient.rawUpdate(sql, [newName, remark, address, oldName]);
    return id;
  }

  Future<int> deleteContact(String name, String address) async {
    var dbClient = await db;
    String sql = 'delete from $_tableContact where name=? and address=?';
    return await dbClient.rawDelete(sql, [name, address]);
  }

  Future<List<dynamic>> queryContactByName(String name) async {
    var dbClient = await db;
    String sql = 'select * from $_tableContact where name=? order by id desc';
    return await dbClient.rawQuery(sql, [name]);
  }

  Future<List<dynamic>> queryContactByAddress(String address) async {
    var dbClient = await db;
    String sql = 'select * from $_tableContact where address=? order by id desc';
    return await dbClient.rawQuery(sql, [address]);
  }

  Future<List<dynamic>> queryContactList() async {
    var dbClient = await db;
    String sql = 'select * from $_tableContact order by id desc';
    return await dbClient.rawQuery(sql);
  }

}
