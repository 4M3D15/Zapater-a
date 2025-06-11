import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:zapato/modelos/cart_model.dart';
import 'package:zapato/modelos/producto_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:shared_preferences/shared_preferences.dart';


class operaciones_db {
  final user_id = FirebaseAuth.instance.currentUser?.uid;
  //final user_id = _auth.currentUser?.uid;

  static Database? _sqlite_db;

  Future<Database> get sqlite_db async {
    if (_sqlite_db != null) return _sqlite_db!;
    _sqlite_db = await initDB();
    print("Base local creada");
    return _sqlite_db!;
  }

  Future<Database> initDB() async {
    final path = join(await getDatabasesPath(), 'Local.db');
    //print('data: $data');
    return await openDatabase(path, version: 1, onCreate: (db, version) async {
      await db.execute('''
          CREATE TABLE carrito (
            id_carrito INTEGER PRIMARY KEY AUTOINCREMENT,
            id_user TEXT,
            id_producto TEXT,
            nombre TEXT,
            imagen TEXT,
            precio REAL,
            talla TEXT,
            cantidad INTEGER
          )
        ''');
      await db.execute('''
          CREATE TABLE favoritos (
            id_favorito INTEGER PRIMARY KEY AUTOINCREMENT,
            id_user TEXT,
            id_producto TEXT,
            nombre TEXT,
            categoria TEXT,
            descripcion TEXT,
            precio REAL,
            imagen TEXT,
            sexo TEXT,
            talla TEXT,
            color INTEGER
          )
        ''');
      await db.execute('''
          CREATE TABLE usuario (
            id_user INTEGER PRIMARY KEY,
            user_uid TEXT,
            nombre TEXT,
            apellido TEXT,
            correo TEXT,
            avatar TEXT,
            password TEXT
          )
        ''');
      //userData();
    });
  }


  Future<void> eliminarUsuario(String id_user) async{
    final local = await sqlite_db;
    await local.delete('usuario', where: 'user_uid = ?', whereArgs: [id_user]);
  }
  Future<List<Map<String, dynamic>>> mostrarUsuarios() async{
    final local = await sqlite_db;
    return await local.query('usuario', columns: ['user_uid', 'nombre', 'correo', 'avatar', 'password']);
  }

  Future<void> setUsuarioLocal(Map<String, dynamic>? data, String password) async{
    //final user_id = _auth.currentUser?.uid;
    final local = await sqlite_db;
    final existencia = await local.query('usuario',
        columns: ['user_uid'],
        where: 'user_uid = ?',
        whereArgs: [user_id]
    );
    //print('Existe? $existencia');

    if(existencia.isEmpty){
      await local.insert(
          'usuario',
          {
            'user_uid': user_id,
            'nombre': data?['nombre'],
            'apellido': data?['apellido'],
            'correo': data?['correo'],
            'avatar': null,
            'password': password
          },
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }
  Future<Map<String, dynamic>> getUsuario() async {
    //final user_id = _auth.currentUser?.uid;
    final local = await sqlite_db;
    final query = await local.query(
      'usuario',
      columns: ['nombre', 'apellido', 'avatar'], // evita avatarBase64
    where: 'user_uid = ?', whereArgs: [user_id]);
    if (query.isNotEmpty) {
      return query.first;
    } else {
      return {};
    }
  }

  Future<void> actualizarUsuario(Map<String, dynamic> data) async {
    //final user_id = _auth.currentUser?.uid;

    final local = await sqlite_db;
    await local.update('usuario', {
      'nombre': data['nombre'],
      'apellido': data['apellido'],
      'avatar': data['avatar']
    }, where: 'user_uid = ?', whereArgs: [user_id]);
    //print('Usuario: $user_id');
    //print('Informacion: $data');
  }

  Future<List<Producto>> getFavoritos() async{
    //final user_id = _auth.currentUser?.uid;
    final local = await sqlite_db;

    print('Usuario: $user_id');

    final query = await local.query('favoritos', where: 'id_user = ?', whereArgs: [user_id]);
    return (query as List).map((item){
      return Producto(
        id: item['id_producto'],
        nombre: item['nombre'],
        categoria: item['categoria'],
        descripcion: item['descripcion'],
        precio: (item['precio'] as num?)?.toDouble() ?? 0.0,
        imagen: item['imagen'],
        sexo: item['sexo'],
        talla: item['talla'],
        color: item['color']
      );
    }).toList();
  }

  //Aun falta subir los favoritos a firebase
  Future<void> addFavorito(Producto producto) async{
    //final user_id = _auth.currentUser?.uid;
    final local = await sqlite_db;

    await local.insert('favoritos', {
      'id_producto': producto.id,
      'id_user': user_id,
      'nombre': producto.nombre,
      'categoria': producto.categoria,
      'descripcion': producto.descripcion,
      'precio': producto.precio,
      'imagen': producto.imagen,
      'sexo': producto.sexo,
      'talla': producto.talla,
      'color': producto.color
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> deleteFavorito(Producto producto) async{
    //final user_id = _auth.currentUser?.uid;
    final local = await sqlite_db;
    await local.delete('favoritos',
        where: 'id_producto = ? and id_user = ?',
        whereArgs: [producto.id, user_id]
    );
  }
  Future<void> limpiarFavoritos() async{
    //final user_id = _auth.currentUser?.uid;
    final local = await sqlite_db;
    await local.delete('favoritos', where: 'id_user = ?', whereArgs: [user_id]);
  }

  Future<List<CartItem>> getCarrito() async{
    final local = await sqlite_db;
    try{
      final query = await local.query(
          'carrito', where: 'id_user = ?', whereArgs: [user_id]);

      return (query as List).map((item) {
        return CartItem(
            id: item['id_producto'],
            nombre: item['nombre'],
            imagen: item['imagen'],
            precio: (item['precio'] as num?)?.toDouble() ?? 0.0,
            talla: item['talla'],
            cantidad: (item['cantidad'] as num?)?.toInt() ?? 0
        );
      }).toList();
    }catch(e){
      print('Error con el carrito: $e');
      return [];
    }
  }

  //Aun falta subir el carrito a firebase (opcional)
  Future<void> addProducto(CartItem producto) async{
    final local = await sqlite_db;

    await local.insert('carrito', {
      'id_producto': producto.id,
      'id_user': user_id,
      'nombre': producto.nombre,
      'imagen': producto.imagen,
      'precio': producto.precio,
      'talla': producto.talla,
      'cantidad': producto.cantidad
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> deleteProducto(CartItem producto) async{
    final local = await sqlite_db;
    await local.delete('carrito',
        where: 'id_producto = ? and talla = ? and id_user = ?',
        whereArgs: [producto.id, producto.talla, user_id]
    );
  }
  Future<void> limpiarCarrito() async{
    final local = await sqlite_db;
    await local.delete('carrito', where: 'id_user = ?', whereArgs: [user_id]);
  }
  Future<void> actualizarCantidad(CartItem producto, int cantidad) async{
    final local = await sqlite_db;
    
    await local.update('carrito', {
      'cantidad': cantidad
    }, where: 'id_producto = ? and talla = ? and id_user = ?', whereArgs: [producto.id, producto.talla, user_id]);
  }
}

