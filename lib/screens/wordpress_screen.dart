// ===============================================================
//  Vista 7: Noticias WordPress
//  Muestra el logo de una pagina hecha con WordPress y las ultimas
//  3 noticias (titular, resumen y un link para visitarla).
//  Pagina: wordpress.org/news (el blog oficial de WordPress)
//  API que use:  https://wordpress.org/news/wp-json/wp/v2/posts?per_page=3
// ===============================================================

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class WordpressScreen extends StatefulWidget {
  const WordpressScreen({super.key});

  @override
  State<WordpressScreen> createState() => _WordpressScreenState();
}

class _WordpressScreenState extends State<WordpressScreen> {
  // Todas las paginas hechas con WordPress tienen la ruta /wp-json/wp/v2/posts
  // per_page=3 es para que solo me traiga las ultimas 3 noticias
  static const _api = 'https://wordpress.org/news/wp-json/wp/v2/posts?per_page=3';
  static const _logo = 'https://s.w.org/style/images/about/WordPress-logotype-wmark.png';

  List<dynamic> _noticias = [];
  bool _cargando = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargarNoticias(); // cargo las noticias al abrir la vista
  }

  Future<void> _cargarNoticias() async {
    try {
      final respuesta = await http.get(Uri.parse(_api));
      setState(() => _noticias = jsonDecode(respuesta.body));
    } catch (e) {
      setState(() => _error = 'Error de conexión');
    } finally {
      setState(() => _cargando = false);
    }
  }

  // El titulo y el resumen vienen con etiquetas HTML como <p> y simbolos
  // raros como &#8217; (que es un apostrofe). Esta funcion los limpia.
  String _limpiarHtml(String html) {
    return html
        .replaceAll(RegExp(r'<[^>]*>'), '') // quita todo lo que este entre < >
        .replaceAll('&#8217;', "'")
        .replaceAll('&#8220;', '"')
        .replaceAll('&#8221;', '"')
        .replaceAll('&#8211;', '-')
        .replaceAll('&#8230;', '...')
        .replaceAll('[&hellip;]', '...')
        .replaceAll('&amp;', '&')
        .replaceAll('&nbsp;', ' ')
        .trim();
  }

  // Abre la noticia original en el navegador
  Future<void> _visitar(String link) async {
    await launchUrl(Uri.parse(link), mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(15),
      children: [
        // Logo de WordPress
        Center(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Image.network(
              _logo,
              height: 90,
              // Si no carga el logo muestro un icono en su lugar
              errorBuilder: (_, __, ___) =>
              const Icon(Icons.public, size: 90, color: Colors.black),
            ),
          ),
        ),
        const SizedBox(height: 15),

        const Text('Últimas noticias de WordPress.org',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF76FF03))),
        const SizedBox(height: 15),

        if (_cargando) const Center(child: CircularProgressIndicator()),
        if (_error != null) Text(_error!, textAlign: TextAlign.center),

        // Una tarjeta por cada noticia
        for (final n in _noticias)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Titular
                  Text(_limpiarHtml(n['title']['rendered']),
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),

                  // Resumen de 5 lineas, si es mas largo pone ...
                  Text(_limpiarHtml(n['excerpt']['rendered']),
                      maxLines: 5,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white70)),

                  // Boton "Visitar" a la derecha
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () => _visitar(n['link']),
                      icon: const Icon(Icons.open_in_new),
                      label: const Text('Visitar'),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}