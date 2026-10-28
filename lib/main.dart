// ===============================================================
//  Tarea: Caja de Herramientas
//  Estudiante: Yassil Del Orbe - 2024-2536
//  Archivo principal de la app. Aqui se configuran los colores,
//  el menu lateral y las 8 vistas que pidio el profesor.
// ===============================================================

import 'package:flutter/material.dart';

// Importo cada una de las pantallas (vistas) de la app
import 'screens/inicio_screen.dart';
import 'screens/genero_screen.dart';
import 'screens/persona_screen.dart';
import 'screens/universidades_screen.dart';
import 'screens/clima_screen.dart';
import 'screens/pokemon_screen.dart';
import 'screens/wordpress_screen.dart';
import 'screens/acerca_screen.dart';

// ----- Mis colores -----
// Los pongo aqui arriba para usarlos en toda la app y no repetirlos
const verdeOlivo = Color(0xFF556B2F);
const verdeLuminico = Color(0xFF76FF03);
const grisOscuro = Color(0xFF1E1E1E);
const gris = Color(0xFF3A3A3A);

// Degradado que va del verde olivo al verde luminico (para la barra de arriba)
const degradadoVerde = LinearGradient(
  colors: [verdeOlivo, verdeLuminico],
);

// Aqui empieza la app
void main() {
  runApp(const MiApp());
}

// Widget principal: configura los colores de toda la app
class MiApp extends StatelessWidget {
  const MiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Caja de Herramientas',
      debugShowCheckedModeBanner: false, // quita la etiqueta de "DEBUG"
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: const ColorScheme.dark(
          primary: verdeLuminico,
          onPrimary: Colors.black,
          secondary: verdeOlivo,
          onSecondary: Colors.white,
          surface: Color(0xFF2B2B2B),
          onSurface: Colors.white,
        ),

        // Color de las tarjetas (Card)
        cardTheme: const CardThemeData(color: Color(0xFF333333)),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: verdeLuminico,
            foregroundColor: Colors.black,
          ),
        ),
      ),
      home: const PantallaPrincipal(),
    );
  }
}

// Pantalla principal: tiene la barra de arriba, el menu y la vista actual.
// Es StatefulWidget porque cambia cuando elijo otra opcion del menu.
class PantallaPrincipal extends StatefulWidget {
  const PantallaPrincipal({super.key});

  @override
  State<PantallaPrincipal> createState() => _PantallaPrincipalState();
}

class _PantallaPrincipalState extends State<PantallaPrincipal> {
  // Guarda cual vista se esta mostrando (0 = Inicio)
  int _indice = 0;

  // Lista de vistas. Cada una tiene: (titulo, icono, pantalla)
  final List<(String, IconData, Widget)> _vistas = [
    ('Inicio', Icons.home, const InicioScreen()),
    ('Género', Icons.wc, const GeneroScreen()),
    ('Persona', Icons.person, const PersonaScreen()),
    ('Universidades', Icons.school, const UniversidadesScreen()),
    ('Clima', Icons.wb_sunny, const ClimaScreen()),
    ('Pokémon', Icons.catching_pokemon, const PokemonScreen()),
    ('Noticias', Icons.newspaper, const WordpressScreen()),
    ('Acerca de', Icons.info, const AcercaScreen()),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        // El titulo cambia segun la vista seleccionada
        title: Text(_vistas[_indice].$1,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        foregroundColor: Colors.white,
        // flexibleSpace me deja ponerle el degradado de fondo a la barra
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: degradadoVerde),
        ),
      ),

      // ----- Menu lateral -----
      drawer: Drawer(
        backgroundColor: const Color(0xFF2B2B2B),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // Cabecera del menu con degradado en diagonal y mi foto
            DrawerHeader(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [verdeOlivo, verdeLuminico],
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  CircleAvatar(
                    radius: 38,
                    backgroundImage: AssetImage('assets/images/foto.jpg'),
                  ),
                  SizedBox(height: 10),
                  Text('Caja de Herramientas',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                  Text('Yassil Del Orbe',
                      style: TextStyle(color: Colors.white70)),
                ],
              ),
            ),

            // Con un for creo una opcion del menu por cada vista de la lista
            for (int i = 0; i < _vistas.length; i++)
              ListTile(
                leading: Icon(_vistas[i].$2),
                title: Text(_vistas[i].$1),
                selected: i == _indice, // resalta la opcion actual
                selectedTileColor: verdeOlivo.withValues(alpha: 0.3),
                onTap: () {
                  setState(() => _indice = i); // cambio de vista
                  Navigator.pop(context);      // cierro el menu
                },
              ),
          ],
        ),
      ),

      // ----- Contenido -----
      body: SizedBox.expand(
        child: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [grisOscuro, gris],
            ),
          ),
          child: _vistas[_indice].$3,
        ),
      ),
    );
  }
}