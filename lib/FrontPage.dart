import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:url_launcher/url_launcher.dart';

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
  String? errorMessage;

  TextEditingController _searchController = TextEditingController();

  Future<void> _fetchWeatherByCity(String cityName) async {
    try {
      final response = await http.get(Uri.parse(
          'https://api.openweathermap.org/data/2.5/weather?q=$cityName&appid=$apiKey'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Reset any previous error message
        setState(() {
          errorMessage = null;
          currentLocation = cityName;
        });

        double latitude = data['coord']['lat'];
        double longitude = data['coord']['lon'];

        await _fetchDetailedWeatherData(latitude, longitude);
      } else if (response.statusCode == 404) {
        setState(() {
          errorMessage = 'City not found';
          _weatherData = null;
        });
      } else {
        print('Error fetching city data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _fetchDetailedWeatherData(double lat, double lon) async {
    try {
      final response = await http.get(Uri.parse(
          'https://api.openweathermap.org/data/3.0/onecall?lat=$lat&lon=$lon&exclude=minutely,hourly,daily&appid=$apiKey&units=metric'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        setState(() {
          _weatherData = WeatherData(
            temperature: data['current']['temp'].toDouble(),
            humidity: data['current']['humidity'].toDouble(),
            conditionText: data['current']['weather'][0]['description'],
            iconUrl:
                'https://openweathermap.org/img/wn/${data['current']['weather'][0]['icon']}@2x.png',
          );
        });
      } else {
        print('Failed to fetch detailed weather data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching detailed weather data: $e');
    }
  }

  void _handleSearchSubmit(String input) {
    setState(() {
      _isSearchMode = false;
    });
    _fetchWeatherByCity(input);
  }

  final Icon searchIcon = Icon(Icons.search);
  final Icon submitIcon = Icon(Icons.check);

  String apiKey = 'Your API Key'; // OpenWeather API
  String cityName = 'Karachi';

  @override
  void initState() {
    super.initState();
    _fetchWeatherByCity(cityName);
    _fetchUserLocation();
  }

  void _fetchUserLocation() async {
    try {
      LocationPermission permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        print('Location permission denied.');
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      );

      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);

      if (placemarks.isNotEmpty) {
        String locationName =
            '${placemarks.first.locality}, ${placemarks.first.country}';
        setState(() {
          currentLocation = locationName;
        });

        _fetchWeatherByCity(locationName);
      }
    } catch (e) {
      print('Error getting user location: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        drawer: Drawer(
          child: Column(
            children: [
              GestureDetector(
                onTap: () => launchUrl(
                  Uri.parse('https://sajidnoor.com'),
                ),
                child: const UserAccountsDrawerHeader(
                  accountName: Text('Sajid Noor'),
                  accountEmail: Text('sajidnoor.com'),
                  currentAccountPicture: CircleAvatar(
                    backgroundImage: NetworkImage(
                        'https://sajidnoor.com/wp-content/uploads/2024/06/profileDEV.jpg'),
                  ),
                ),
              ),
            ],
          ),
        ),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: _isSearchMode
              ? TextField(
                  controller: _searchController,
                  onSubmitted: _handleSearchSubmit,
                  decoration: InputDecoration(
                    hintText: 'Enter city name',
                    errorText: errorMessage,
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
                    _handleSearchSubmit(_searchController.text);
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
          child: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/bg-weather.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: Center(
              child: _weatherData != null
                  ? SingleChildScrollView(
                      child: Column(
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
                      ),
                    )
                  : errorMessage != null
                      ? Text(
                          errorMessage!,
                          style: const TextStyle(
                              color: Colors.red, fontWeight: FontWeight.bold),
                        )
                      : const CircularProgressIndicator(),
            ),
          ),
        ),
      ),
    );
  }
}
