// ===============================================================
//  Vista 3: Persona
//  Muestra los datos de una persona aleatoria usando la API
//  randomuser.me: nombre, apellido, foto, fecha de nacimiento y edad.
// ===============================================================

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PersonaScreen extends StatefulWidget {
  const PersonaScreen({super.key});

  @override
  State<PersonaScreen> createState() => _PersonaScreenState();
}

class _PersonaScreenState extends State<PersonaScreen> {
  Map<String, dynamic>? _persona; // aqui guardo los datos de la persona
  bool _cargando = false;
  String? _error;

  // initState se ejecuta una sola vez cuando se abre la pantalla
  @override
  void initState() {
    super.initState();
    _cargarPersona(); // asi sale una persona apenas entro a la vista
  }

  // Pide una persona aleatoria a la API
  Future<void> _cargarPersona() async {
    setState(() {
      _cargando = true;
      _error = null;
    });

    try {
      final url = Uri.parse('https://randomuser.me/api/?results=1');
      final respuesta = await http.get(url);
      final datos = jsonDecode(respuesta.body);
      // La API devuelve una lista "results", tomo la primera persona
      setState(() => _persona = datos['results'][0]);
    } catch (e) {
      setState(() => _error = 'Error de conexión');
    } finally {
      setState(() => _cargando = false);
    }
  }

  // La API me da la fecha asi: "1993-07-20T09:44:18.674Z"
  // Esta funcion la convierte a formato normal: "20/07/1993"
  String _formatearFecha(String fecha) {
    final f = DateTime.parse(fecha);
    final dia = f.day.toString().padLeft(2, '0');   // 5 -> "05"
    final mes = f.month.toString().padLeft(2, '0');
    return '$dia/$mes/${f.year}';
  }

  // Funcion para crear cada tarjeta de dato y no repetir codigo
  Widget _dato(String titulo, String valor) {
    return Card(
      child: ListTile(
        title: Text(titulo,
            style: const TextStyle(color: Color(0xFF76FF03), fontSize: 14)),
        subtitle: Text(valor,
            style: const TextStyle(fontSize: 20, color: Colors.white)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Mientras carga muestro la ruedita
    if (_cargando) {
      return const Center(child: CircularProgressIndicator());
    }

    // Si hubo error muestro un boton para intentar otra vez
    if (_error != null || _persona == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error ?? 'Sin datos'),
            ElevatedButton(
                onPressed: _cargarPersona, child: const Text('Reintentar')),
          ],
        ),
      );
    }

    final p = _persona!; // el ! es porque ya se que no es null

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Foto de la persona con un borde verde
        // (es un circulo verde un poco mas grande detras de la foto)
        Center(
          child: CircleAvatar(
            radius: 84,
            backgroundColor: const Color(0xFF76FF03),
            child: CircleAvatar(
              radius: 80,
              backgroundImage: NetworkImage(p['picture']['large']),
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Los datos que pidio el profesor
        _dato('Nombre', p['name']['first']),
        _dato('Apellido', p['name']['last']),
        _dato('Fecha de nacimiento', _formatearFecha(p['dob']['date'])),
        _dato('Edad', '${p['dob']['age']} años'),
        const SizedBox(height: 20),

        // Boton para cargar otra persona
        ElevatedButton.icon(
          onPressed: _cargarPersona,
          icon: const Icon(Icons.refresh),
          label: const Text('Otra persona'),
        ),
      ],
    );
  }
}