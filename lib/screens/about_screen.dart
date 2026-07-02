import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';


class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

 
  static const String name = 'ismael Tejeda garcia';
  static const String role = 'Estudiante de Desarrollo de Software · ITLA';
  static const String bio =
      'Apasionado(a) por el desarrollo móvil y el consumo de APIs. '
      'Disponible para prácticas, pasantías y proyectos freelance.';
  static const String email = 'ismaeltejeda2611@gmail.com';
  static const String phone = '+1 (809) 413-6615';
  static const String location = 'Santo Domingo, República Dominicana';
  static const String github = 'https://github.com/IsmaelTejed';
  static const String linkedin = 'https://www.linkedin.com/in/ismael-tejeda-a25733309/';

  // Puedes reemplazar por la URL de tu propia foto de perfil.
  static const String photoUrl = '';

  Future<void> _open(String url) async {
    final uri = Uri.tryParse(url.startsWith('http') ? url : 'https://$url');
    if (uri != null) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Acerca de mí')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            CircleAvatar(
              radius: 64,
              backgroundColor: AppTheme.primary.withValues(alpha: 0.15),
              backgroundImage: photoUrl.isNotEmpty ? const NetworkImage(photoUrl) : null,
              child: photoUrl.isEmpty
                  ? const Icon(Icons.person, size: 72, color: AppTheme.primary)
                  : null,
            ),
            const SizedBox(height: 18),
            const Text(name, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            const Text(role, style: TextStyle(color: Colors.grey, fontSize: 14)),
            const SizedBox(height: 18),
            const Card(
              child: Padding(
                padding: EdgeInsets.all(18),
                child: Text(
                  bio,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, height: 1.4),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  children: [
                    _ContactTile(
                      icon: Icons.email_outlined,
                      title: 'Correo',
                      value: email,
                      onTap: () => _open('mailto:$email'),
                    ),
                    const Divider(height: 1),
                    _ContactTile(
                      icon: Icons.phone_outlined,
                      title: 'Teléfono',
                      value: phone,
                      onTap: () => _open('tel:${phone.replaceAll(RegExp(r'[^0-9+]'), '')}'),
                    ),
                    const Divider(height: 1),
                    const _ContactTile(
                      icon: Icons.location_on_outlined,
                      title: 'Ubicación',
                      value: location,
                      onTap: null,
                    ),
                    const Divider(height: 1),
                    _ContactTile(
                      icon: Icons.code,
                      title: 'GitHub',
                      value: github,
                      onTap: () => _open(github),
                    ),
                    const Divider(height: 1),
                    _ContactTile(
                      icon: Icons.business_center_outlined,
                      title: 'LinkedIn',
                      value: linkedin,
                      onTap: () => _open(linkedin),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              '¿Buscas un/a desarrollador/a para tu equipo? ¡Contáctame! 🚀',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final VoidCallback? onTap;

  const _ContactTile({required this.icon, required this.title, required this.value, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primary),
      title: Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      subtitle: Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
      trailing: onTap != null ? const Icon(Icons.chevron_right, color: Colors.grey) : null,
      onTap: onTap,
    );
  }
}
