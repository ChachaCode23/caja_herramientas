// ===============================================================
//  Vista 2: Genero
//  El usuario escribe un nombre y la app predice si es masculino o femenino
//  Si es masculino se pone azul y si es femenino se pone rosado.
// ===============================================================

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// StatefulWidget porque la pantalla cambia segun el resultado
class GeneroScreen extends StatefulWidget {
  const GeneroScreen({super.key});

  @override
  State<GeneroScreen> createState() => _GeneroScreenState();
}

class _GeneroScreenState extends State<GeneroScreen> {
  // Controlador para leer lo que se escribe en la caja de texto
  final _nombreCtrl = TextEditingController();

  String? _genero;        // aqui guardo si es masculino o femenino o null
  bool _cargando = false;
  String? _error;

  // Funcion que consulta la API con el nombre escrito
  Future<void> _predecir() async {
    final nombre = _nombreCtrl.text.trim(); // trim quita espacios de mas
    if (nombre.isEmpty) return;             // si esta vacio no hago nada

    // Limpio el resultado anterior
    setState(() {
      _cargando = true;
      _error = null;
      _genero = null;
    });

    try {
      // Ejemplo: https://api.genderize.io/?name=irma
      final url = Uri.parse('https://api.genderize.io/?name=$nombre');
      final respuesta = await http.get(url);
      final datos = jsonDecode(respuesta.body); // convierto el JSON a Map

      setState(() {
        _genero = datos['gender'];
        // Si la API no reconoce el nombre, gender viene en null
        if (_genero == null) _error = 'No se pudo predecir ese nombre';
      });
    } catch (e) {
      // Si no hay internet o falla la API
      setState(() => _error = 'Error de conexión');
    } finally {
      // finally se ejecuta siempre, haya error o no
      setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Elijo el color de fondo segun el genero
    Color fondo = Colors.transparent;
    if (_genero == 'male') fondo = Colors.blue.shade400;    // azul
    if (_genero == 'female') fondo = Colors.pink.shade300;  // rosa

    return Container(
      color: fondo,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Caja de texto para escribir el nombre
          TextField(
            controller: _nombreCtrl,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              labelText: 'Escribe un nombre',
              labelStyle: TextStyle(color: Colors.white70),
              filled: true,
              fillColor: Color(0xFF2B2B2B),
              border: OutlineInputBorder(),
              // Borde verde olivo
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF556B2F)),
              ),
              // Borde verde luminico
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF76FF03), width: 2),
              ),
            ),
            onSubmitted: (_) => _predecir(), // al darle Enter tambien busca
          ),
          const SizedBox(height: 15),


          ElevatedButton.icon(
            onPressed: _cargando ? null : _predecir,
            icon: const Icon(Icons.search),
            label: const Text('Predecir'),
          ),
          const SizedBox(height: 40),


          if (_cargando) const CircularProgressIndicator(),

          // Mensaje de error
          if (_error != null)
            Text(_error!, style: const TextStyle(fontSize: 18)),

          // Resultado: icono y texto del genero
          if (_genero != null) ...[
            Icon(
              _genero == 'male' ? Icons.male : Icons.female,
              size: 150,
              color: Colors.white,
            ),
            Text(
              _genero == 'male' ? 'Masculino' : 'Femenino',
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ],
      ),
    );
  }
}