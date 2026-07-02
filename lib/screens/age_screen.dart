import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../widgets/common_widgets.dart';

enum _AgeCategory { joven, adulto, anciano, desconocido }

/// VISTA 3
/// Acepta el nombre de una persona y determina su edad probable usando
/// https://api.agify.io/?name=NOMBRE
/// Segun el rango de edad muestra un mensaje (joven / adulto / anciano),
/// una imagen ilustrativa y el numero de la edad.
class AgeScreen extends StatefulWidget {
  const AgeScreen({super.key});

  @override
  State<AgeScreen> createState() => _AgeScreenState();
}

class _AgeScreenState extends State<AgeScreen> {
  final _controller = TextEditingController();
  bool _loading = false;
  String? _error;

  String? _name;
  int? _age;
  int? _count;

  Future<void> _predictAge() async {
    final name = _controller.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Por favor escribe un nombre.');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final uri = Uri.parse('https://api.agify.io/?name=${Uri.encodeComponent(name)}');
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        setState(() {
          _name = data['name'] as String?;
          _age = data['age'] as int?;
          _count = data['count'] as int?;
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

  _AgeCategory get _category {
    if (_age == null) return _AgeCategory.desconocido;
    if (_age! <= 25) return _AgeCategory.joven;
    if (_age! <= 59) return _AgeCategory.adulto;
    return _AgeCategory.anciano;
  }

  _CategoryInfo get _categoryInfo {
    switch (_category) {
      case _AgeCategory.joven:
        return _CategoryInfo(
          label: 'Joven',
          message: 'según la predicción, esta persona es joven 🧑',
          icon: Icons.emoji_people,
          color: Colors.green,
        );
      case _AgeCategory.adulto:
        return _CategoryInfo(
          label: 'Adulto',
          message: 'según la predicción, esta persona es adulta 👩‍💼',
          icon: Icons.person,
          color: Colors.blueGrey,
        );
      case _AgeCategory.anciano:
        return _CategoryInfo(
          label: 'Anciano',
          message: 'según la predicción, esta persona es anciana 👴',
          icon: Icons.elderly,
          color: Colors.deepOrange,
        );
      case _AgeCategory.desconocido:
        return _CategoryInfo(
          label: '—',
          message: '',
          icon: Icons.help_outline,
          color: Colors.grey,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Predecir Edad')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SectionHeader(
              title: 'Predicción de edad',
              subtitle: 'API pública: api.agify.io — según estadísticas de nombres',
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _controller,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(
                labelText: 'Nombre de la persona',
                hintText: 'Ej: Meelad, Rosa, Fernando...',
                prefixIcon: Icon(Icons.person_outline),
              ),
              onSubmitted: (_) => _predictAge(),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loading ? null : _predictAge,
              icon: const Icon(Icons.search),
              label: const Text('Predecir edad'),
            ),
            const SizedBox(height: 28),
            if (_loading) const LoadingView(message: 'Consultando agify.io...'),
            if (_error != null) ErrorView(message: _error!, onRetry: _predictAge),
            if (!_loading && _error == null && _name != null) _buildResult(),
          ],
        ),
      ),
    );
  }

  Widget _buildResult() {
    if (_age == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Icon(Icons.help_outline, size: 56, color: Colors.grey),
              const SizedBox(height: 12),
              Text('No se pudo estimar la edad de "$_name".', textAlign: TextAlign.center),
            ],
          ),
        ),
      );
    }

    final info = _categoryInfo;
    return Card(
      color: info.color.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: info.color.withValues(alpha: 0.4), width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            CircleAvatar(
              radius: 48,
              backgroundColor: info.color.withValues(alpha: 0.15),
              child: Icon(info.icon, size: 56, color: info.color),
            ),
            const SizedBox(height: 16),
            Text(_name ?? '',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(
              '$_age años',
              style: TextStyle(fontSize: 40, fontWeight: FontWeight.w900, color: info.color),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: info.color,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Text(
                info.label,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            const SizedBox(height: 10),
            Text(info.message, textAlign: TextAlign.center, style: const TextStyle(color: Colors.black54)),
            const SizedBox(height: 6),
            Text('Basado en ${_count ?? 0} registros', style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class _CategoryInfo {
  final String label;
  final String message;
  final IconData icon;
  final Color color;
  _CategoryInfo({required this.label, required this.message, required this.icon, required this.color});
}
