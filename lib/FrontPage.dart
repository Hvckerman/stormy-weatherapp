import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart'; // Add this import for geocoding

class FrontPage extends StatefulWidget {
  const FrontPage({Key? key}) : super(key: key);

  @override
  State createState() => FrontPageState();
}

class WeatherData {
  final double temperature;
  final double humidity;
  final String conditionText;
  final String iconUrl;

  WeatherData({
    required this.temperature,
    required this.humidity,
    required this.conditionText,
    required this.iconUrl,
  });
}

class FrontPageState extends State<FrontPage> {
  bool _isSearchMode = false;
  WeatherData? _weatherData;
  String? currentLocation;

  TextEditingController _searchController = TextEditingController();

  Future<void> _fetchWeatherData() async {
    try {
      final response = await http.get(Uri.parse(
          'http://api.weatherapi.com/v1/current.json?key=$apiKey&q=$cityName&aqi=no'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        setState(() {
          _weatherData = WeatherData(
            temperature: data['current']['temp_c'].toDouble(),
            humidity: data['current']['humidity'].toDouble(),
            conditionText: data['current']['condition']['text'],
            iconUrl: 'http:${data['current']['condition']['icon']}',
          );
        });
      } else {
        // Handle API error
        print('Failed to fetch weather data: ${response.statusCode}');
      }
    } catch (e) {
      // Handle other errors
      print('Error: $e');
    }
  }

  void _handleSearchSubmit(String input) {
    _updateCityName(input);

    setState(() {
      _isSearchMode = false;
    });
  }

  void _updateCityName(String input) {
    setState(() {
      cityName = input;
      currentLocation = cityName;
    });
    _fetchWeatherData(); // Fetch weather data for the new city name
  }

  final Icon searchIcon = Icon(Icons.search);
  final Icon submitIcon = Icon(Icons.check);

  String apiKey =
      '36e59374a03c4a1d9fd141844232807'; // Replace with your actual API key
  String cityName = 'Karachi';

  @override
  void initState() {
    super.initState();
    _fetchWeatherData();
    _fetchUserLocation(); // Fetch user's current location
  }

  void _fetchUserLocation() async {
    try {
      LocationPermission permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        // Handle if the user denies location permission
        print('Location permission denied.');
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      );

      // Use Geocoding to get the location name from latitude and longitude
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);

      if (placemarks.isNotEmpty) {
        String locationName =
            '${placemarks.first.locality}, ${placemarks.first.country}';
        setState(() {
          currentLocation = locationName;
          if (cityName == 'Karachi') {
            cityName = locationName;
          }
        });
        _fetchWeatherData(); // Fetch weather data for the user's location
      }
    } catch (e) {
      print('Error getting user location: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      drawer: const Drawer(),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: _isSearchMode
            ? TextField(
                controller: _searchController,
                onSubmitted: _handleSearchSubmit,
                decoration: const InputDecoration(
                  hintText: 'Enter city name',
                ),
              )
            : const Text('Stormy'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: _isSearchMode ? submitIcon : searchIcon,
            onPressed: () {
              setState(() {
                _isSearchMode = !_isSearchMode;
                if (!_isSearchMode) {
                  _updateCityName(_searchController.text);
                }
              });
            },
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () {
          if (_isSearchMode) {
            setState(() {
              _isSearchMode = false;
            });
          }
        },
        child: Column(
          children: [
            Container(
              height: MediaQuery.of(context).size.height / 1.5,
              width: MediaQuery.of(context).size.width * 1,
              color: Colors.grey,
              child: Center(
                child: _weatherData != null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (currentLocation != null)
                            Text(
                              'Current Location: $currentLocation',
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          Text('Temperature: ${_weatherData!.temperature} °C'),
                          Text('Humidity: ${_weatherData!.humidity}%'),
                          Text('Condition: ${_weatherData!.conditionText}'),
                          Image.network(_weatherData!.iconUrl),
                        ],
                      )
                    : const CircularProgressIndicator(),
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width * 1,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}
