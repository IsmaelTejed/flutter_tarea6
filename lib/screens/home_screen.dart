import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'gender_screen.dart';
import 'age_screen.dart';
import 'universities_screen.dart';
import 'weather_screen.dart';
import 'pokemon_screen.dart';
import 'news_screen.dart';
import 'about_screen.dart';

/// VISTA 1
/// Pantalla principal: muestra una "foto" de caja de herramientas (con
/// fallback a una ilustracion vectorial si no hay internet) y el menu
/// de acceso a las demas 7 utilidades de la app.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // Imagen real de una caja de herramientas (Wikimedia Commons, dominio libre).
  static const String _toolboxImageUrl =
      'https://upload.wikimedia.org/wikipedia/commons/thumb/6/6c/Toolbox_with_tools.jpg/640px-Toolbox_with_tools.jpg';

  @override
  Widget build(BuildContext context) {
    final items = <_MenuItem>[
      _MenuItem('Predecir Género', 'Ingresa un nombre y descubre su género probable',
          Icons.wc, AppTheme.maleBlue, (ctx) => const GenderScreen()),
      _MenuItem('Predecir Edad', 'Ingresa un nombre y estima la edad de la persona',
          Icons.cake, Colors.deepPurple, (ctx) => const AgeScreen()),
      _MenuItem('Universidades', 'Busca universidades por país',
          Icons.school, Colors.teal, (ctx) => const UniversitiesScreen()),
      _MenuItem('Clima en RD', 'Consulta el clima de hoy en Santo Domingo',
          Icons.wb_sunny, Colors.orange, (ctx) => const WeatherScreen()),
      _MenuItem('Pokédex', 'Busca un Pokémon: foto, habilidades y sonido',
          Icons.catching_pokemon, Colors.redAccent, (ctx) => const PokemonScreen()),
      _MenuItem('Noticias Deportivas', 'Últimas noticias de un sitio WordPress',
          Icons.newspaper, Colors.indigo, (ctx) => const NewsScreen()),
      _MenuItem('Acerca de mí', 'Foto y datos de contacto',
          Icons.badge, Colors.brown, (ctx) => const AboutScreen()),
    ];

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            backgroundColor: AppTheme.secondary,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('Caja de Herramientas'),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    _toolboxImageUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (ctx, child, progress) {
                      if (progress == null) return child;
                      return Container(
                        color: AppTheme.secondary,
                        child: const Center(
                          child: CircularProgressIndicator(color: Colors.white70),
                        ),
                      );
                    },
                    errorBuilder: (ctx, error, stack) => _ToolboxFallback(),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.05),
                          Colors.black.withValues(alpha: 0.55),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SliverPadding(
            padding: EdgeInsets.all(16),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Esta aplicación reúne varias herramientas útiles en un solo lugar 🧰',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  SizedBox(height: 16),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 0.95,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final item = items[index];
                  return MenuCard(
                    icon: item.icon,
                    title: item.title,
                    subtitle: item.subtitle,
                    color: item.color,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: item.builder),
                    ),
                  );
                },
                childCount: items.length,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }
}

class _ToolboxFallback extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.secondary,
      child: const Center(
        child: Icon(Icons.construction, size: 96, color: Colors.white70),
      ),
    );
  }
}

class _MenuItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final WidgetBuilder builder;
  _MenuItem(this.title, this.subtitle, this.icon, this.color, this.builder);
}
