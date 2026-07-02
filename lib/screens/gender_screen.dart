import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

/// VISTA 2
/// Acepta el nombre de una persona y predice su genero usando
/// https://api.genderize.io/?name=NOMBRE
/// Si es masculino se muestra un fondo/tema azul, si es femenino (o
/// indeterminado) se muestra rosa.
class GenderScreen extends StatefulWidget {
  const GenderScreen({super.key});

  @override
  State<GenderScreen> createState() => _GenderScreenState();
}

class _GenderScreenState extends State<GenderScreen> {
  final _controller = TextEditingController();
  bool _loading = false;
  String? _error;

  String? _name;
  String? _gender; // "male" | "female" | null
  double? _probability;
  int? _count;

  Future<void> _predictGender() async {
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
      final uri = Uri.parse('https://api.genderize.io/?name=${Uri.encodeComponent(name)}');
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        setState(() {
          _name = data['name'] as String?;
          _gender = data['gender'] as String?; // puede ser null
          _probability = (data['probability'] as num?)?.toDouble();
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

  bool get _isMale => _gender == 'male';
  Color get _themeColor {
    if (_gender == null) return Colors.grey.shade300;
    return _isMale ? AppTheme.maleBlue : AppTheme.femalePink;
  }

  @override
  Widget build(BuildContext context) {
    final hasResult = _gender != null || (_name != null && _gender == null);

    return Scaffold(
      appBar: AppBar(title: const Text('Predecir Género')),
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        color: hasResult ? _themeColor.withValues(alpha: 0.12) : AppTheme.background,
        width: double.infinity,
        height: double.infinity,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SectionHeader(
                title: 'Predicción de género',
                subtitle: 'API pública: api.genderize.io — según estadísticas de nombres',
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _controller,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  labelText: 'Nombre de la persona',
                  hintText: 'Ej: Irma, Carlos, Fabiola...',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                onSubmitted: (_) => _predictGender(),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _loading ? null : _predictGender,
                icon: const Icon(Icons.search),
                label: const Text('Predecir género'),
              ),
              const SizedBox(height: 28),
              if (_loading) const LoadingView(message: 'Consultando genderize.io...'),
              if (_error != null) ErrorView(message: _error!, onRetry: _predictGender),
              if (!_loading && _error == null && hasResult) _buildResult(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResult() {
    if (_gender == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Icon(Icons.help_outline, size: 56, color: Colors.grey),
              const SizedBox(height: 12),
              Text(
                'No se pudo determinar el género de "$_name".',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    final percent = _probability != null ? '${(_probability! * 100).toStringAsFixed(0)}%' : '—';

    return Card(
      color: _themeColor.withValues(alpha: 0.9),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              _isMale ? Icons.male : Icons.female,
              size: 90,
              color: Colors.white,
            ),
            const SizedBox(height: 12),
            Text(
              _name ?? '',
              style: const TextStyle(
                  color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              _isMale ? 'Masculino' : 'Femenino',
              style: const TextStyle(
                  color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Probabilidad: $percent  •  Muestras: ${_count ?? 0}',
                style: const TextStyle(color: Colors.white, fontSize: 13),
              ),
            ),
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
