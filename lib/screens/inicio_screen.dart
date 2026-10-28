// ===============================================================
//  Vista 1: Inicio
//  Muestra la foto de una caja de herramientas, porque esta app
//  tiene varias vistas en una sola.
// ===============================================================

import 'package:flutter/material.dart';

// Es StatelessWidget porque esta pantalla no cambia, solo muestra info
class InicioScreen extends StatelessWidget {
  const InicioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // todo centrado
          children: [
            // Imagen de la caja de herramientas como lo pidio el profesor
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset('assets/images/caja.png', height: 250),
            ),
            const SizedBox(height: 20), // espacio entre la imagen y el titulo

            // Titulo en verde luminico para que combine con el tema
            const Text(
              'Caja de Herramientas',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF76FF03),
              ),
            ),
            const SizedBox(height: 10),

            // Pequena descripcion de la app
            const Text(
              'Una app con varias herramientas útiles.\nAbre el menú para elegir una.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}