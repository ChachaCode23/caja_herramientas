// ===============================================================
//  Vista 6: Pokemon
//  El usuario escribe el nombre de un pokemon y la app muestra:
//  foto, experiencia base, habilidades y su sonido (latest).
//  API: https://pokeapi.co/api/v2/pokemon/pikachu
// ===============================================================

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart'; // para reproducir el sonido

class PokemonScreen extends StatefulWidget {
  const PokemonScreen({super.key});

  @override
  State<PokemonScreen> createState() => _PokemonScreenState();
}

class _PokemonScreenState extends State<PokemonScreen> {
  // Pikachu por defecto para probar rapido
  final _nombreCtrl = TextEditingController(text: 'pikachu');
  final _reproductor = AudioPlayer(); // reproductor de audio

  Map<String, dynamic>? _pokemon; // datos del pokemon
  bool _cargando = false;
  String? _error;

  // Busca el pokemon en la API
  Future<void> _buscar() async {
    // La API solo acepta minusculas, por eso uso toLowerCase()
    final nombre = _nombreCtrl.text.trim().toLowerCase();
    if (nombre.isEmpty) return;

    setState(() {
      _cargando = true;
      _error = null;
      _pokemon = null;
    });

    try {
      final url = Uri.parse('https://pokeapi.co/api/v2/pokemon/$nombre');
      final respuesta = await http.get(url);

      // Si el pokemon no existe la API devuelve error 404
      if (respuesta.statusCode == 404) {
        setState(() => _error = 'Ese Pokémon no existe');
      } else {
        setState(() => _pokemon = jsonDecode(respuesta.body));
      }
    } catch (e) {
      setState(() => _error = 'Error de conexión');
    } finally {
      setState(() => _cargando = false);
    }
  }

  // Reproduce el sonido del pokemon (el "latest" que pidio el profesor)
  Future<void> _sonar() async {
    // Los ?. es por si algun dato viene vacio, que no explote la app
    final sonido = _pokemon?['cries']?['latest'];
    if (sonido != null) {
      await _reproductor.play(UrlSource(sonido));
    }
  }

  // dispose se ejecuta al salir de la pantalla
  // Aqui libero el reproductor para que no se quede gastando memoria
  @override
  void dispose() {
    _reproductor.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = _pokemon;

    // Uso la imagen oficial (mas bonita), y si no existe uso la normal
    // El ?? significa "si lo de la izquierda es null, usa lo de la derecha"
    final foto = p?['sprites']['other']['official-artwork']['front_default'] ??
        p?['sprites']['front_default'];

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Caja de texto para el nombre del pokemon
        TextField(
          controller: _nombreCtrl,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'Nombre del Pokémon',
            labelStyle: const TextStyle(color: Colors.white70),
            filled: true,
            fillColor: const Color(0xFF2B2B2B),
            border: const OutlineInputBorder(),
            enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF556B2F)),
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF76FF03), width: 2),
            ),
            suffixIcon: IconButton(
              icon: const Icon(Icons.search, color: Color(0xFF76FF03)),
              onPressed: _buscar,
            ),
          ),
          onSubmitted: (_) => _buscar(),
        ),
        const SizedBox(height: 20),

        if (_cargando) const Center(child: CircularProgressIndicator()),
        if (_error != null)
          Text(_error!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18)),

        // Si ya tengo el pokemon, muestro toda su info
        if (p != null) ...[
          // Foto
          if (foto != null) Image.network(foto, height: 220),

          // Nombre en mayusculas
          Text(
            p['name'].toString().toUpperCase(),
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF76FF03)),
          ),
          const SizedBox(height: 10),

          // Experiencia base
          Card(
            child: ListTile(
              leading: const Icon(Icons.star, color: Colors.amber),
              title: const Text('Experiencia base'),
              trailing: Text('${p['base_experience'] ?? '-'}',
                  style: const TextStyle(fontSize: 20)),
            ),
          ),

          // Habilidades
          Card(
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Habilidades',
                      style:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  // Wrap acomoda las habilidades y si no caben pasa a otra linea
                  Wrap(
                    spacing: 8,
                    children: [
                      // Recorro la lista de habilidades y creo un Chip por cada una
                      for (final h in p['abilities'])
                        Chip(
                          label: Text(h['ability']['name']),
                          backgroundColor: const Color(0xFF556B2F),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Boton para escuchar el sonido
          ElevatedButton.icon(
            onPressed: _sonar,
            icon: const Icon(Icons.volume_up),
            label: const Text('Reproducir sonido'),
          ),
        ],
      ],
    );
  }
}