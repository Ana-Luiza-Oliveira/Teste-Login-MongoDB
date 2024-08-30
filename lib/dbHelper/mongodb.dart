import 'package:mongo_dart/mongo_dart.dart';
import 'dart:developer';
import 'package:teste_login/dbHelper/constant.dart';

class MongoDatabase {
  static var db, userCollection;

  static connect() async {
    try {
      db = await Db.create(MONGO_CONN_URL);
      await db.open();
      inspect(db);
      userCollection = db.collection(USER_COLLECTION);
      print("Conectado ao MongoDB");
    } catch (e) {
      print("Erro ao conectar ao MongoDB: $e");
    }
  }
}
