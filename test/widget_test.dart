import 'package:flutter_test/flutter_test.dart';
import 'package:smart_campus/screens/home_screen.dart';

void main() {
  test('parses current weather values from API response', () {
    final weather = Weather.fromJson({'current': {'temperature_2m': 24.5, 'wind_speed_10m': 12}});
    expect(weather.temperature, 24.5);
    expect(weather.wind, 12.0);
  });
}
