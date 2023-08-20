import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class WeatherPage extends StatefulWidget {
  @override
  _WeatherPageState createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  final String apiKey = 'fa21ee4e50c8492887425852231408';
  String location = 'Chittagong'; // Default location is Chittagong
  late Weather _weather;

  @override
  void initState() {
    super.initState();
    _weather = Weather(location: '', temperatureC: 0, condition: '');
    fetchWeather();
  }

  Future<void> fetchWeather() async {
    final apiUrl = 'https://api.weatherapi.com/v1/current.json?key=$apiKey&q=$location';
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _weather = Weather.fromJson(data);
      });
    } else {
      throw Exception('Failed to fetch weather data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Weather Forecast'),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                onChanged: (value) {
                  setState(() {
                    location = value;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Enter City Name',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: fetchWeather,
                child: Text('Get Weather'),
              ),
              SizedBox(height: 16),
              _weather.location.isNotEmpty
                  ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Location: ${_weather.location}'),
                  Text('Temperature: ${_weather.temperatureC}°C'),
                  Text('Condition: ${_weather.condition}'),
                ],
              )
                  : SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
  }
}

class Weather {
  final String location;
  final double temperatureC;
  final String condition;

  Weather({
    required this.location,
    required this.temperatureC,
    required this.condition,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      location: json['location']['name'],
      temperatureC: json['current']['temp_c'],
      condition: json['current']['condition']['text'],
    );
  }
}