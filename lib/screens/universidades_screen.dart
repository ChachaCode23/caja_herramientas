// ===============================================================
//  Vista 4: Universidades
//  El usuario escribe el nombre de un pais en ingles y la app
//  muestra sus universidades: nombre, dominio y link a la pagina web.
//  API: https://adamix.net/proxy.php?country=Dominican+Republic
// ===============================================================

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart'; // para abrir links en el navegador

class UniversidadesScreen extends StatefulWidget {
  const UniversidadesScreen({super.key});

  @override
  State<UniversidadesScreen> createState() => _UniversidadesScreenState();
}

class _UniversidadesScreenState extends State<UniversidadesScreen> {
  // Le pongo "Dominican Republic" por defecto para probar rapido
  final _paisCtrl = TextEditingController(text: 'Dominican Republic');

  List<dynamic> _universidades = []; // lista de universidades que llegan de la API
  bool _cargando = false;
  String? _mensaje; // para errores o "no se encontro nada"

  // Busca las universidades del pais escrito
  Future<void> _buscar() async {
    final pais = _paisCtrl.text.trim();
    if (pais.isEmpty) return;

    setState(() {
      _cargando = true;
      _mensaje = null;
      _universidades = [];
    });

    try {
      // Uso Uri.https para que los espacios se cambien solos a "+"
      // Queda asi: https://adamix.net/proxy.php?country=Dominican+Republic
      final url = Uri.https('adamix.net', '/proxy.php', {'country': pais});
      final respuesta = await http.get(url);
      final datos = jsonDecode(respuesta.body) as List;

      setState(() {
        _universidades = datos;
        if (datos.isEmpty) _mensaje = 'No se encontraron universidades';
      });
    } catch (e) {
      setState(() => _mensaje = 'Error de conexión');
    } finally {
      setState(() => _cargando = false);
    }
  }

  // Abre la pagina web de la universidad en el navegador del celular
  Future<void> _abrirPagina(String link) async {
    final ok = await launchUrl(Uri.parse(link),
        mode: LaunchMode.externalApplication);
    // Si no se pudo abrir, muestro un mensajito abajo
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo abrir la página')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: Column(
        children: [
          // Caja de texto para el pais
          TextField(
            controller: _paisCtrl,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'País en inglés',
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
          const SizedBox(height: 10),

          if (_cargando) const CircularProgressIndicator(),
          if (_mensaje != null) Text(_mensaje!),

          // Cantidad de universidades encontradas
          if (_universidades.isNotEmpty)
            Text('${_universidades.length} universidades encontradas',
                style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 5),

          // Expanded para que la lista ocupe el resto de la pantalla
          Expanded(
            // ListView.builder crea los elementos a medida que se ven
            child: ListView.builder(
              itemCount: _universidades.length,
              itemBuilder: (context, i) {
                final u = _universidades[i];

                // domains y web_pages son listas, tomo el primero de cada una
                final dominio =
                (u['domains'] as List).isNotEmpty ? u['domains'][0] : '-';
                final web =
                (u['web_pages'] as List).isNotEmpty ? u['web_pages'][0] : '';

                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.school, color: Color(0xFF76FF03)),
                    // Nombre de la universidad
                    title: Text(u['name'],
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Dominio
                        Text('Dominio: $dominio'),
                        // Link a la pagina web
                        if (web.isNotEmpty)
                          InkWell(
                            onTap: () => _abrirPagina(web),
                            child: Text(
                              web,
                              style: const TextStyle(
                                color: Colors.lightBlueAccent,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}