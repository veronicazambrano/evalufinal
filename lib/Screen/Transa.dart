import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseReference dbRef = FirebaseDatabase.instance.ref();
  double saldo = 0.0;
  List<Map<String, dynamic>> transacciones = [];

  @override
  void initState() {
    super.initState();
    final userId = FirebaseAuth.instance.currentUser!.uid;
    dbRef.child('usuarios/$userId/saldo').onValue.listen((event) {
      setState(() {
        saldo = double.parse(event.snapshot.value.toString());
      });
    });
    dbRef.child('usuarios/$userId/transacciones').onChildAdded.listen((event) {
      setState(() {
        transacciones.add(Map<String, dynamic>.from(event.snapshot.value as Map));
      });
    });
  }

  void crearTransaccion(String id, String beneficiario, double monto) {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final nuevaTransaccion = {
      'id': id,
      'beneficiario': beneficiario,
      'monto': monto,
      'fecha': DateTime.now().toString(),
    };
    dbRef.child('usuarios/$userId/transacciones').push().set(nuevaTransaccion);
    dbRef.child('usuarios/$userId/saldo').set(saldo - monto);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Cuenta Bancaria')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Saldo Total: \$${saldo.toStringAsFixed(2)}', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            Text('Transacciones Recientes:', style: TextStyle(fontSize: 18)),
            Expanded(
              child: ListView.builder(
                itemCount: transacciones.length,
                itemBuilder: (context, index) {
                  final trans = transacciones[index];
                  return ListTile(
                    title: Text('Beneficiario: ${trans['beneficiario']}'),
                    subtitle: Text('Monto: \$${trans['monto']} - Fecha: ${trans['fecha']}'),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: () => crearTransaccion('T001', 'Juan Pérez', 100.0),
              child: Text('Nueva Transacción'),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeScreen {
}
