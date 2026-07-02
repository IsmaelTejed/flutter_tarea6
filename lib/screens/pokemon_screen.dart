import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

/// VISTA 6
/// Acepta el nombre de un pokemon y muestra su foto, experiencia base,
/// habilidades y reproduce su sonido (cry) usando PokeAPI:
/// https://pokeapi.co/api/v2/pokemon/{nombre}
class PokemonScreen extends StatefulWidget {
  const PokemonScreen({super.key});

  @override
  State<PokemonScreen> createState() => _PokemonScreenState();
}

class _PokemonScreenState extends State<PokemonScreen> {
  final _controller = TextEditingController(text: 'pikachu');
  final _player = AudioPlayer();

  bool _loading = false;
  bool _playingCry = false;
  String? _error;

  String? _name;
  String? _imageUrl;
  int? _baseExperience;
  int? _idNumber;
  List<String> _abilities = [];
  List<String> _types = [];
  String? _cryUrl;
  double? _height;
  double? _weight;

  Future<void> _searchPokemon() async {
    final name = _controller.text.trim().toLowerCase();
    if (name.isEmpty) {
      setState(() => _error = 'Escribe el nombre de un Pokémon.');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final uri = Uri.parse('https://pokeapi.co/api/v2/pokemon/$name');
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final sprites = data['sprites'] as Map<String, dynamic>;
        final officialArtwork = (sprites['other'] as Map<String, dynamic>?)?['official-artwork']
            as Map<String, dynamic>?;
        final abilitiesList = (data['abilities'] as List)
            .map((a) => (a['ability'] as Map<String, dynamic>)['name'].toString())
            .toList();
        final typesList = (data['types'] as List)
            .map((t) => (t['type'] as Map<String, dynamic>)['name'].toString())
            .toList();
        final cries = data['cries'] as Map<String, dynamic>?;

        setState(() {
          _name = data['name'] as String?;
          _idNumber = data['id'] as int?;
          _baseExperience = data['base_experience'] as int?;
          _imageUrl = officialArtwork?['front_default'] as String? ?? sprites['front_default'] as String?;
          _abilities = abilitiesList;
          _types = typesList;
          _cryUrl = cries?['latest'] as String? ?? cries?['legacy'] as String?;
          _height = ((data['height'] as num?)?.toDouble() ?? 0) / 10; // decimetros -> metros
          _weight = ((data['weight'] as num?)?.toDouble() ?? 0) / 10; // hectogramos -> kg
          _loading = false;
        });
      } else if (response.statusCode == 404) {
        setState(() {
          _error = 'No se encontró ningún Pokémon llamado "$name".';
          _loading = false;
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

  Future<void> _playCry() async {
    if (_cryUrl == null) return;
    setState(() => _playingCry = true);
    try {
      await _player.play(UrlSource(_cryUrl!));
    } catch (_) {
      // Ignorar errores de reproduccion silenciosamente
    } finally {
      if (mounted) setState(() => _playingCry = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _searchPokemon();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pokédex')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SectionHeader(
              title: 'Buscar Pokémon',
              subtitle: 'API: pokeapi.co/api/v2/pokemon',
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _controller,
              textInputAction: TextInputAction.search,
              decoration: const InputDecoration(
                labelText: 'Nombre del Pokémon',
                hintText: 'Ej: pikachu, charizard, snorlax...',
                prefixIcon: Icon(Icons.catching_pokemon),
              ),
              onSubmitted: (_) => _searchPokemon(),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loading ? null : _searchPokemon,
              icon: const Icon(Icons.search),
              label: const Text('Buscar'),
            ),
            const SizedBox(height: 28),
            if (_loading) const LoadingView(message: 'Consultando PokeAPI...'),
            if (_error != null) ErrorView(message: _error!, onRetry: _searchPokemon),
            if (!_loading && _error == null && _name != null) _buildPokemonCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildPokemonCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              '#${_idNumber.toString().padLeft(3, '0')}',
              style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              _capitalize(_name ?? ''),
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (_imageUrl != null)
              Image.network(
                _imageUrl!,
                height: 180,
                errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported, size: 100, color: Colors.grey),
              )
            else
              const Icon(Icons.image_not_supported, size: 100, color: Colors.grey),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              alignment: WrapAlignment.center,
              children: _types
                  .map((t) => Chip(
                        label: Text(_capitalize(t)),
                        backgroundColor: AppTheme.primary.withValues(alpha: 0.15),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _InfoTile(
                    icon: Icons.bolt,
                    label: 'Exp. base',
                    value: '${_baseExperience ?? '—'}',
                  ),
                ),
                Expanded(
                  child: _InfoTile(
                    icon: Icons.height,
                    label: 'Altura',
                    value: '${_height?.toStringAsFixed(1) ?? '—'} m',
                  ),
                ),
                Expanded(
                  child: _InfoTile(
                    icon: Icons.fitness_center,
                    label: 'Peso',
                    value: '${_weight?.toStringAsFixed(1) ?? '—'} kg',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Habilidades', style: Theme.of(context).textTheme.titleMedium),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _abilities
                  .map((a) => Chip(
                        avatar: const Icon(Icons.auto_awesome, size: 16),
                        label: Text(_capitalize(a.replaceAll('-', ' '))),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: (_cryUrl == null || _playingCry) ? null : _playCry,
              icon: Icon(_playingCry ? Icons.volume_up : Icons.play_arrow),
              label: Text(_cryUrl == null ? 'Sonido no disponible' : 'Reproducir sonido'),
            ),
          ],
        ),
      ),
    );
  }

  static String _capitalize(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  @override
  void dispose() {
    _controller.dispose();
    _player.dispose();
    super.dispose();
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoTile({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.primary),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }
}
