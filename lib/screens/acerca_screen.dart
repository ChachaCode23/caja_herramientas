// ===============================================================
//  Vista 8: Acerca de mi
//  Muestra mi foto y mis datos de contacto para posibles trabajos.
//  Cada contacto se puede tocar: abre el correo, llama, abre whatsApp o mi GitHub.
// ===============================================================

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // para abrir correo, telefono, links

// StatelessWidget porque esta pantalla no cambia
class AcercaScreen extends StatelessWidget {
  const AcercaScreen({super.key});

  // ----- Mis datos -----
  static const nombre = 'Yassil Del Orbe';
  static const descripcion = 'Estudiante de Desarrollo de Software - ITLA';
  static const correo = 'yassildelorbe18@gmail.com';
  static const telefono = '8293973679';
  static const github = 'https://github.com/ChachaCode23';

  // Abre el link con la app que corresponda (correo, telefono, navegador)
  Future<void> _abrir(String link) async {
    await launchUrl(Uri.parse(link), mode: LaunchMode.externalApplication);
  }

  // Funcion para crear cada tarjeta de contacto y no repetir codigo
  Widget _contacto(IconData icono, String texto, String link) {
    return Card(
      child: ListTile(
        leading: Icon(icono, color: const Color(0xFF76FF03)),
        title: Text(texto),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => _abrir(link),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Mi foto
        Center(
          child: Container(
            padding: const EdgeInsets.all(5),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF556B2F), Color(0xFF76FF03)],
              ),
            ),
            child: const CircleAvatar(
              radius: 90,
              backgroundImage: AssetImage('assets/images/foto.jpg'),
            ),
          ),
        ),
        const SizedBox(height: 15),

        // Nombre y descripcion
        const Text(nombre,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Color(0xFF76FF03))),
        const Text(descripcion,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.white70)),
        const SizedBox(height: 10),
        const Text('Disponible para trabajos y proyectos',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15)),
        const SizedBox(height: 20),

        // Contactos
        // mailto: abre la app de correo
        _contacto(Icons.email, correo, 'mailto:$correo'),
        // tel: abre el marcador del telefono
        _contacto(Icons.phone, '829-397-3679', 'tel:$telefono'),
        // wa.me abre WhatsApp (el 1 es el codigo de pais de RD)
        _contacto(Icons.chat, 'WhatsApp', 'https://wa.me/1$telefono'),
        // Mi perfil de GitHub
        _contacto(Icons.code, 'GitHub', github),
      ],
    );
  }
}