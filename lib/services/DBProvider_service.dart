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

// class DatabaseHelper {
//   final databaseName = "notes.db";
//   final databaseVersion = 1;

//   String tableName = "notes_table";
//   String colId = "id";
//   String colTitle = "title";
//   String colContent = "content";
//   String colDate = "date";

//   static DatabaseHelper _databaseHelper;
//   static Database _database;

//   DatabaseHelper._createInstance();

//   factory DatabaseHelper() {
//     if (_databaseHelper == null) {
//       _databaseHelper = DatabaseHelper._createInstance();
//     }
//     return _databaseHelper;
//   }

//   Future<Database> get database async {
//     if (_database == null) {
//       _database = await initializeDatabase();
//     }
//     return _database;
//   }

//   Future<Database> initializeDatabase() async {
//     Directory directory = await getApplicationDocumentsDirectory();
//     String path = directory.path + databaseName;

//     var notesDatabase =
//         openDatabase(path, version: databaseVersion, onCreate: _createDb);

//     return notesDatabase;
//   }

//   void _createDb(Database db, int version) async {
//     await db.execute(
//         ("CREATE TABLE $tableName($colId INTEGER PRIMARY KEY AUTOINCREMENT, "
//             "$colTitle TEXT, $colContent TEXT, $colDate TEXT)"));
//   }

//   Future<List<Map<String, dynamic>>> getNotesListMap() async {
//     Database db = await this.database;
//     var response = db.query(tableName);
//     return response;
//   }

//   Future<int> insert(Note note) async {
//     Database db = await this.database;
//     print(note.objToMap());
//     int response = await db.insert(tableName, note.objToMap());
//     return response;
//   }

//   Future<int> update(Note note) async {
//     Database db = await this.database;
//     int response = await db.update(tableName, note.objToMap(),
//         where: '$colId = ?', whereArgs: [note.id]);
//     return response;
//   }

//   Future<int> delete(int noteId) async {
//     Database db = await this.database;
//     int response = await db.rawDelete('DELETE FROM $tableName WHERE $colId == $noteId');
//     return response;
//   }

//   Future<List<Note>> getNoteList() async {
//     var noteMapList = await getNotesListMap();
//     int count = noteMapList.length;

//     List<Note> noteList = List<Note>();
//     for(int i = 0 ; i < count ; i++) {
//       noteList.add(Note.mapToObj(noteMapList[i]));
//     }
//     return noteList;
//   }

//   Future<Note> getNoteById(int noteId) async {
//     Database db = await this.database;
//     List<Map<String, dynamic>> noteMap = await db.query(tableName, where: '$colId = ?', whereArgs: [noteId]);
//     Note note = Note.mapToObj(noteMap[0]);
//     return note;
//   }
// }
