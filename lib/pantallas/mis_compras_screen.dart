import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MisComprasScreen extends StatelessWidget {
  const MisComprasScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String? correoUsuario = FirebaseAuth.instance.currentUser?.email;

    if (correoUsuario == null) {
      return const Scaffold(
        body: Center(
          child: Text('Usuario no autenticado.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Compras'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('pedidos')
            .where('correo', isEqualTo: correoUsuario)
            .orderBy('fecha', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No tienes compras registradas.'));
          }

          final compras = snapshot.data!.docs;

          return ListView.builder(
            itemCount: compras.length,
            itemBuilder: (context, index) {
              final compra = compras[index];
              final productos = compra['productos'] as List<dynamic>? ?? [];
              final fecha = compra['fecha']?.toDate();
              final total = compra['total'] ?? 0;

              return Card(
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  title: Text(
                    'Compra del ${fecha != null ? fecha.toString().substring(0, 16) : 'sin fecha'}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (var p in productos)
                        Text(
                            '${p['nombre'] ?? 'Producto'} x${p['cantidad'] ?? 1}'),
                      const SizedBox(height: 5),
                      Text('Total: \$${total.toStringAsFixed(2)}'),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
