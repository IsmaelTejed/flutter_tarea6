import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

/// VISTA 7
/// Muestra el logo/favicon de un sitio hecho en WordPress y el titular +
/// resumen de sus 3 últimas noticias, usando la WordPress REST API nativa:
/// https://TU_SITIO/wp-json/wp/v2/posts?per_page=3&_embed
///
/// IMPORTANTE: el sitio por defecto es solo un ejemplo verificado que
/// expone su REST API públicamente. Reemplaza [_defaultSite] por el sitio
/// deportivo de WordPress que publicarás en el foro de la asignación.
class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
 
  // deportivas que publicarás en el foro de la actividad.
  static const String _defaultSite = 'otesports.com';

  final _controller = TextEditingController(text: _defaultSite);
  bool _loading = false;
  String? _error;

  String _siteName = '';
  String? _logoUrl;
  List<_NewsItem> _news = [];

  Future<void> _loadNews() async {
    var site = _controller.text.trim();
    site = site.replaceAll(RegExp(r'^https?://'), '').replaceAll(RegExp(r'/$'), '');
    if (site.isEmpty) {
      setState(() => _error = 'Escribe el dominio de un sitio WordPress. Ej: otesports.com');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
      _news = [];
    });
    try {
      // 1) Info general del sitio (nombre) desde la raiz de wp-json
      final rootUri = Uri.parse('https://$site/wp-json/');
      final rootResp = await http.get(rootUri);
      if (rootResp.statusCode == 200) {
        final rootData = jsonDecode(rootResp.body) as Map<String, dynamic>;
        _siteName = rootData['name']?.toString() ?? site;
      } else {
        _siteName = site;
      }

      // 2) Ultimos 3 posts, con datos embebidos (imagen destacada, autor)
      final postsUri = Uri.parse('https://$site/wp-json/wp/v2/posts?per_page=3&_embed');
      final postsResp = await http.get(postsUri);

      if (postsResp.statusCode == 200) {
        final List<dynamic> data = jsonDecode(postsResp.body) as List<dynamic>;
        final items = data.map((e) => _NewsItem.fromJson(e as Map<String, dynamic>)).toList();
        setState(() {
          _news = items;
          _logoUrl = 'https://www.google.com/s2/favicons?domain=$site&sz=128';
          _loading = false;
          if (items.isEmpty) {
            _error = 'El sitio no tiene publicaciones disponibles vía REST API.';
          }
        });
      } else {
        setState(() {
          _error = 'No se pudo leer wp-json en "$site" (código ${postsResp.statusCode}). '
              '¿Es un sitio WordPress con REST API habilitada?';
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'No se pudo conectar con "$site". Verifica el dominio e internet.';
        _loading = false;
      });
    }
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  void initState() {
    super.initState();
    _loadNews();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Noticias Deportivas (WordPress)')),
      body: RefreshIndicator(
        onRefresh: _loadNews,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SectionHeader(
                title: 'Últimas noticias',
                subtitle: 'Consume la REST API nativa de un sitio WordPress (wp-json)',
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  labelText: 'Dominio del sitio WordPress',
                  hintText: 'Ej: otesports.com',
                  prefixIcon: Icon(Icons.language),
                ),
                onSubmitted: (_) => _loadNews(),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: _loading ? null : _loadNews,
                icon: const Icon(Icons.refresh),
                label: const Text('Cargar noticias'),
              ),
              const SizedBox(height: 24),
              if (_loading) const LoadingView(message: 'Consultando wp-json...'),
              if (_error != null) ErrorView(message: _error!, onRetry: _loadNews),
              if (!_loading && _error == null && _news.isNotEmpty) ...[
                _buildSiteHeader(),
                const SizedBox(height: 20),
                ..._news.map((n) => _buildNewsCard(n)),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSiteHeader() {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: _logoUrl != null
              ? Image.network(
                  _logoUrl!,
                  width: 56,
                  height: 56,
                  errorBuilder: (_, __, ___) => const Icon(Icons.public, size: 40, color: AppTheme.secondary),
                )
              : const Icon(Icons.public, size: 40, color: AppTheme.secondary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            _siteName,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildNewsCard(_NewsItem n) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (n.imageUrl != null)
            Image.network(
              n.imageUrl!,
              height: 160,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                height: 100,
                color: Colors.grey.shade200,
                child: const Icon(Icons.image_not_supported, color: Colors.grey),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(n.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                Text(
                  n.excerpt,
                  style: const TextStyle(color: Colors.black54, fontSize: 13),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton.icon(
                    onPressed: () => _openUrl(n.link),
                    icon: const Icon(Icons.open_in_new, size: 16),
                    label: const Text('Visitar'),
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class _NewsItem {
  final String title;
  final String excerpt;
  final String link;
  final String? imageUrl;

  _NewsItem({required this.title, required this.excerpt, required this.link, this.imageUrl});

  factory _NewsItem.fromJson(Map<String, dynamic> json) {
    String stripHtml(String html) => html.replaceAll(RegExp(r'<[^>]*>'), '').trim();

    String? image;
    try {
      final embedded = json['_embedded'] as Map<String, dynamic>?;
      final media = (embedded?['wp:featuredmedia'] as List?)?.cast<dynamic>();
      if (media != null && media.isNotEmpty) {
        image = (media.first as Map<String, dynamic>)['source_url'] as String?;
      }
    } catch (_) {
      image = null;
    }

    return _NewsItem(
      title: stripHtml((json['title'] as Map<String, dynamic>)['rendered']?.toString() ?? ''),
      excerpt: stripHtml((json['excerpt'] as Map<String, dynamic>)['rendered']?.toString() ?? ''),
      link: json['link']?.toString() ?? '',
      imageUrl: image,
    );
  }
}
