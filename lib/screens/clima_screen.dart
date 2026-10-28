// ===============================================================
//  Vista 5: Clima en RD
//  Muestra como esta el clima hoy en Santo Domingo.
//  Uso la API de Open-Meteo porque es gratis y no pide API key.
// ===============================================================

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ClimaScreen extends StatefulWidget {
  const ClimaScreen({super.key});

  @override
  State<ClimaScreen> createState() => _ClimaScreenState();
}

class _ClimaScreenState extends State<ClimaScreen> {
  Map<String, dynamic>? _datos; // respuesta completa de la API
  bool _cargando = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargarClima(); // cargo el clima apenas abro la vista
  }

  // Pide el clima de hoy a la API
  Future<void> _cargarClima() async {
    setState(() {
      _cargando = true;
      _error = null;
    });

    try {
      // latitude y longitude son las coordenadas de Santo Domingo
      // current = datos de ahora mismo, daily = datos del dia completo
      // forecast_days=1 para que solo me de el dia de hoy
      final url = Uri.parse(
        'https://api.open-meteo.com/v1/forecast'
            '?latitude=18.4861&longitude=-69.9312'
            '&current=temperature_2m,relative_humidity_2m,weather_code,wind_speed_10m'
            '&daily=temperature_2m_max,temperature_2m_min,precipitation_probability_max'
            '&timezone=America/Santo_Domingo&forecast_days=1',
      );
      final respuesta = await http.get(url);
      setState(() => _datos = jsonDecode(respuesta.body));
    } catch (e) {
      setState(() => _error = 'Error de conexión');
    } finally {
      setState(() => _cargando = false);
    }
  }

  // La API me da un numero (weather_code) en vez de texto.
  // Con esta funcion lo convierto a una descripcion y un icono.
  (String, IconData) _descripcion(int codigo) {
    if (codigo == 0) return ('Despejado', Icons.wb_sunny);
    if (codigo <= 3) return ('Parcialmente nublado', Icons.wb_cloudy);
    if (codigo <= 48) return ('Neblina', Icons.foggy);
    if (codigo <= 67) return ('Lluvia', Icons.water_drop);
    if (codigo <= 82) return ('Aguaceros', Icons.umbrella);
    return ('Tormenta', Icons.thunderstorm);
  }

  // Devuelve la fecha de hoy en español, ej: "Martes, 27 de octubre de 2026"
  String _fechaHoy() {
    const dias = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'];
    const meses = ['enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio', 'julio',
      'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'];
    final h = DateTime.now();
    // weekday va de 1 a 7 y month de 1 a 12, por eso le resto 1
    return '${dias[h.weekday - 1]}, ${h.day} de ${meses[h.month - 1]} de ${h.year}';
  }

  // Tarjeta reutilizable para cada dato (maxima, minima, humedad, etc.)
  Widget _tarjeta(IconData icono, String titulo, String valor) {
    return Card(
      child: ListTile(
        leading: Icon(icono, color: const Color(0xFF76FF03)),
        title: Text(titulo),
        trailing: Text(valor,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) return const Center(child: CircularProgressIndicator());

    // Si hubo error, boton para reintentar
    if (_error != null || _datos == null) {
      return Center(
        child: ElevatedButton(
            onPressed: _cargarClima, child: Text('${_error ?? ''} - Reintentar')),
      );
    }

    final actual = _datos!['current']; // datos de este momento
    final diario = _datos!['daily'];   // datos del dia (vienen en listas)
    final (texto, icono) = _descripcion(actual['weather_code']);

    // RefreshIndicator: si deslizo hacia abajo se vuelve a cargar el clima
    return RefreshIndicator(
      onRefresh: _cargarClima,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Ciudad y fecha de hoy
          const Text('Santo Domingo, RD',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF76FF03))),
          Text(_fechaHoy(),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.white70)),
          const SizedBox(height: 20),

          // Icono grande del clima y temperatura actual
          Icon(icono, size: 120, color: Colors.orange),
          Text('${actual['temperature_2m'].round()}°C', // round() quita los decimales
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 60, fontWeight: FontWeight.bold)),
          Text(texto,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 20),

          // Los datos del dia ([0] porque es el primer y unico dia)
          _tarjeta(Icons.arrow_upward, 'Máxima',
              '${diario['temperature_2m_max'][0].round()}°C'),
          _tarjeta(Icons.arrow_downward, 'Mínima',
              '${diario['temperature_2m_min'][0].round()}°C'),
          _tarjeta(Icons.water_drop, 'Humedad',
              '${actual['relative_humidity_2m']}%'),
          _tarjeta(Icons.air, 'Viento',
              '${actual['wind_speed_10m']} km/h'),
          _tarjeta(Icons.umbrella, 'Prob. de lluvia',
              '${diario['precipitation_probability_max'][0]}%'),
        ],
      ),
    );
  }
}