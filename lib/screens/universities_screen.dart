import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../widgets/common_widgets.dart';

/// VISTA 4
/// Acepta el nombre de un pais en ingles y muestra sus universidades usando
/// https://adamix.net/proxy.php?country=NOMBRE_PAIS
/// Se muestra: nombre, dominio y link a la pagina web de cada universidad.
class UniversitiesScreen extends StatefulWidget {
  const UniversitiesScreen({super.key});

  @override
  State<UniversitiesScreen> createState() => _UniversitiesScreenState();
}

class _UniversitiesScreenState extends State<UniversitiesScreen> {
  final _controller = TextEditingController(text: 'Dominican Republic');
  bool _loading = false;
  String? _error;
  List<_University> _universities = [];

  Future<void> _search() async {
    final country = _controller.text.trim();
    if (country.isEmpty) {
      setState(() => _error = 'Escribe el nombre de un país en inglés.');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
      _universities = [];
    });
    try {
      final uri = Uri.parse('https://adamix.net/proxy.php?country=${Uri.encodeComponent(country)}');
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
        final list = data
            .map((e) => _University.fromJson(e as Map<String, dynamic>))
            .toList();
        setState(() {
          _universities = list;
          _loading = false;
          if (list.isEmpty) {
            _error = 'No se encontraron universidades para "$country".';
          }
        });
      } else {
        setState(() {
          _error = 'Error del servidor (${response.statusCode}). Intenta de nuevo.';
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'No se pudo conectar. Verifica tu conexión a internet.';
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
    _search();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Universidades por País')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SectionHeader(
                  title: 'Buscar universidades',
                  subtitle: 'API: adamix.net/proxy.php — escribe el país en inglés',
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _controller,
                  textInputAction: TextInputAction.search,
                  decoration: const InputDecoration(
                    labelText: 'País (en inglés)',
                    hintText: 'Ej: Dominican Republic, Spain, Mexico...',
                    prefixIcon: Icon(Icons.public),
                  ),
                  onSubmitted: (_) => _search(),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: _loading ? null : _search,
                  icon: const Icon(Icons.search),
                  label: const Text('Buscar universidades'),
                ),
              ],
            ),
          ),
          Expanded(
            child: _loading
                ? const LoadingView(message: 'Buscando universidades...')
                : _error != null
                    ? ErrorView(message: _error!, onRetry: _search)
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                        itemCount: _universities.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final u = _universities[index];
                          return Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const CircleAvatar(
                                        backgroundColor: Color(0x1A009688),
                                        child: Icon(Icons.school, color: Colors.teal),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          u.name,
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      const Icon(Icons.dns, size: 16, color: Colors.grey),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text('Dominio: ${u.domain}',
                                            style: const TextStyle(color: Colors.grey, fontSize: 13)),
                                      ),
                                    ],
                                  ),
                                  if (u.webPage != null) ...[
                                    const SizedBox(height: 8),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: TextButton.icon(
                                        onPressed: () => _openUrl(u.webPage!),
                                        icon: const Icon(Icons.open_in_new, size: 16),
                                        label: const Text('Visitar sitio web'),
                                      ),
                                    ),
                                  ],
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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class _University {
  final String name;
  final String domain;
  final String? webPage;

  _University({required this.name, required this.domain, this.webPage});

  factory _University.fromJson(Map<String, dynamic> json) {
    // La API puede devolver 'domains' y 'web_pages' como listas.
    final domains = (json['domains'] as List?)?.cast<dynamic>();
    final pages = (json['web_pages'] as List?)?.cast<dynamic>();
    return _University(
      name: json['name']?.toString() ?? 'Sin nombre',
      domain: domains != null && domains.isNotEmpty
          ? domains.first.toString()
          : (json['domain']?.toString() ?? 'N/A'),
      webPage: pages != null && pages.isNotEmpty
          ? pages.first.toString()
          : json['web_page']?.toString(),
    );
  }
}
