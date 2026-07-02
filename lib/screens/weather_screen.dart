import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

/// VISTA 5
/// Muestra el clima del dia actual para Republica Dominicana (Santo Domingo)
/// usando la API gratuita y sin api-key de Open-Meteo.
/// https://api.open-meteo.com/v1/forecast?latitude=18.4861&longitude=-69.9312...
class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  bool _loading = true;
  String? _error;

  double? _currentTemp;
  double? _feelsLike;
  int? _weatherCode;
  double? _windSpeed;
  double? _tempMax;
  double? _tempMin;
  double? _precipProb;
  int? _humidity;

  static const double _lat = 18.4861; // Santo Domingo
  static const double _lon = -69.9312;

  @override
  void initState() {
    super.initState();
    _loadWeather();
  }

  Future<void> _loadWeather() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final uri = Uri.parse(
        'https://api.open-meteo.com/v1/forecast'
        '?latitude=$_lat&longitude=$_lon'
        '&current=temperature_2m,apparent_temperature,weather_code,wind_speed_10m,relative_humidity_2m'
        '&daily=temperature_2m_max,temperature_2m_min,precipitation_probability_max'
        '&timezone=America%2FSanto_Domingo',
      );
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final current = data['current'] as Map<String, dynamic>;
        final daily = data['daily'] as Map<String, dynamic>;
        setState(() {
          _currentTemp = (current['temperature_2m'] as num?)?.toDouble();
          _feelsLike = (current['apparent_temperature'] as num?)?.toDouble();
          _weatherCode = (current['weather_code'] as num?)?.toInt();
          _windSpeed = (current['wind_speed_10m'] as num?)?.toDouble();
          _humidity = (current['relative_humidity_2m'] as num?)?.toInt();
          _tempMax = (daily['temperature_2m_max'] as List).isNotEmpty
              ? (daily['temperature_2m_max'][0] as num?)?.toDouble()
              : null;
          _tempMin = (daily['temperature_2m_min'] as List).isNotEmpty
              ? (daily['temperature_2m_min'][0] as num?)?.toDouble()
              : null;
          _precipProb = (daily['precipitation_probability_max'] as List).isNotEmpty
              ? (daily['precipitation_probability_max'][0] as num?)?.toDouble()
              : null;
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

  _WeatherInfo get _info => _codeToInfo(_weatherCode);

  static _WeatherInfo _codeToInfo(int? code) {
    if (code == null) return _WeatherInfo('Desconocido', Icons.help_outline, Colors.grey);
    if (code == 0) return _WeatherInfo('Cielo despejado', Icons.wb_sunny, Colors.orange);
    if (code == 1 || code == 2) return _WeatherInfo('Parcialmente nublado', Icons.wb_cloudy, Colors.orangeAccent);
    if (code == 3) return _WeatherInfo('Nublado', Icons.cloud, Colors.blueGrey);
    if (code == 45 || code == 48) return _WeatherInfo('Neblina', Icons.foggy, Colors.grey);
    if (code >= 51 && code <= 57) return _WeatherInfo('Llovizna', Icons.grain, Colors.lightBlue);
    if (code >= 61 && code <= 67) return _WeatherInfo('Lluvia', Icons.water_drop, Colors.blue);
    if (code >= 80 && code <= 82) return _WeatherInfo('Aguaceros', Icons.beach_access, Colors.indigo);
    if (code >= 95) return _WeatherInfo('Tormenta eléctrica', Icons.thunderstorm, Colors.deepPurple);
    return _WeatherInfo('Variable', Icons.cloud_queue, Colors.blueGrey);
  }

  @override
  Widget build(BuildContext context) {
    final today = DateFormat("EEEE d 'de' MMMM 'de' y", 'es').format(DateTime.now());

    return Scaffold(
      appBar: AppBar(title: const Text('Clima en RD')),
      body: RefreshIndicator(
        onRefresh: _loadWeather,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SectionHeader(
                title: 'Clima de hoy en Santo Domingo, RD',
                subtitle: 'Fuente: Open-Meteo (API gratuita, sin key)',
              ),
              const SizedBox(height: 20),
              if (_loading) const LoadingView(message: 'Consultando el clima...'),
              if (_error != null) ErrorView(message: _error!, onRetry: _loadWeather),
              if (!_loading && _error == null) _buildWeatherCard(today),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeatherCard(String today) {
    final info = _info;
    return Card(
      color: info.color.withValues(alpha: 0.12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: info.color.withValues(alpha: 0.4)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.location_on, size: 18, color: Colors.grey),
                SizedBox(width: 4),
                Text('Santo Domingo, República Dominicana',
                    style: TextStyle(color: Colors.grey, fontSize: 13)),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              today[0].toUpperCase() + today.substring(1),
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 16),
            Icon(info.icon, size: 90, color: info.color),
            const SizedBox(height: 10),
            Text(
              _currentTemp != null ? '${_currentTemp!.toStringAsFixed(0)}°C' : '--°C',
              style: TextStyle(fontSize: 54, fontWeight: FontWeight.w900, color: info.color),
            ),
            Text(info.description, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 20),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: [
                _StatChip(icon: Icons.thermostat, label: 'Sensación', value: _feelsLike != null ? '${_feelsLike!.toStringAsFixed(0)}°C' : '—'),
                _StatChip(icon: Icons.arrow_upward, label: 'Máxima', value: _tempMax != null ? '${_tempMax!.toStringAsFixed(0)}°C' : '—'),
                _StatChip(icon: Icons.arrow_downward, label: 'Mínima', value: _tempMin != null ? '${_tempMin!.toStringAsFixed(0)}°C' : '—'),
                _StatChip(icon: Icons.air, label: 'Viento', value: _windSpeed != null ? '${_windSpeed!.toStringAsFixed(0)} km/h' : '—'),
                _StatChip(icon: Icons.water_drop_outlined, label: 'Humedad', value: _humidity != null ? '$_humidity%' : '—'),
                _StatChip(icon: Icons.umbrella, label: 'Prob. lluvia', value: _precipProb != null ? '${_precipProb!.toStringAsFixed(0)}%' : '—'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _WeatherInfo {
  final String description;
  final IconData icon;
  final Color color;
  _WeatherInfo(this.description, this.icon, this.color);
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _StatChip({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 6)],
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: AppTheme.secondary),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        ],
      ),
    );
  }
}
