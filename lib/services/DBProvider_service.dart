import 'dart:convert';
import 'dart:io';
import 'package:first_test_for_flutter/model/client_model.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DBProvider {
  DBProvider._();
  static Database? _database;
  static final DBProvider db = DBProvider._();

  Future<Database> get database async => _database ??= await initDB();

  Future<Database> initDB() async {
    String databasePath = await getDatabasesPath();
    String path = join(databasePath, "TestDB.db");
    return await openDatabase(
      path,
      version: 1,
      onOpen: (db) {},
      onCreate: (Database db, int version) async {
        await db.execute("CREATE TABLE Client ("
            "id INTEGER PRIMARY KEY,"
            "first_name TEXT,"
            "last_name TEXT,"
            "blocked BIT"
            ")");
      },
    );
  }

  //accepted as insert method

  insert(String table, Map<String, dynamic> data) async {
    final db = await database;
    var raw = await db.insert(table, data);
    //return id
    return raw;
  }

  getClient(int id) async {
    final db = await database;

    var res = await db.query("Client", where: "id = ?", whereArgs: [id]);
    return res.isNotEmpty ? Client.fromMap(res.first) : Null;
  }

  Future<List<Client>> getAllClients() async {
    final db = await database;
    var res = await db.rawQuery("SELECT * FROM Client"); // db.query("Client");
    //this also work
    // List<Client> mylist = [];
    // res.forEach((element) {
    //   mylist.add(Client.fromMap(element));
    // });
    List<Client> list =
        res.isNotEmpty ? res.map((c) => Client.fromMap(c)).toList() : [];
    return list;
  }

  getBlockedClients() async {
    final db = await database;
    var res = await db.rawQuery("SELECT * FROM Client WHERE blocked=1");
    List<Client> list =
        res.isNotEmpty ? res.map((c) => Client.fromMap(c)).toList() : [];
    return list;
  }

  updateClient(Client newClient) async {
    final db = await database;
    var res = await db.update("Client", newClient.toMap(),
        where: "id = ?", whereArgs: [newClient.id]);
    return res;
  }

  blockOrUnblock(Client client) async {
    final db = await database;
    Client blocked = Client(
        id: client.id,
        firstName: client.firstName,
        lastName: client.lastName,
        blocked: !client.blocked);
    var res = await db.update("Client", blocked.toMap(),
        where: "id = ?", whereArgs: [client.id]);
    return res;
  }

  deleteClient(int id) async {
    final db = await database;
    db.delete("Client", where: "id = ?", whereArgs: [id]);
  }

  deleteAll() async {
    final db = await database;
    db.rawDelete("Delete from Client");
  }
  // newClient(Client newClient) async {
  //   final db = await database;
  //   var res = await db.insert("Client", newClient.toMap());
  //   return res;
  // }

  // newClient(Client newClient) async {
  //   final db = await database;
  //   //get the biggest id in the table
  //   var table = await db.rawQuery("SELECT MAX(id)+1 as id FROM Client");
  //   int id = table.first["id"];
  //   //insert to the table using the new id
  //   var raw = await db.rawInsert(
  //       "INSERT Into Client (id,first_name,last_name,blocked)"
  //       " VALUES (?,?,?,?)",
  //       [id, newClient.firstName, newClient.lastName, newClient.blocked]);
  //   return raw;
  // }
  // newClient(Client newClient) async {
  //   final db = await database;
  //   var res = await db.rawInsert(
  //       "INSERT Into Client (id, first_name, last_name, blocked)"
  //       " VALUES (${newClient.id},'${newClient.firstName}', '${newClient.lastName}', ${newClient.blocked})");
  //   return res;
  // }

  // "INSERT Into Client (id,first_name,last_name,blocked)"
  // " VALUES (?,?,?,?)"
  // newClients(String query, List parameter) async {
  //   final db = await database;
  //   var raw = await db.rawInsert(query, parameter);
  //   return raw;
  // }

}
