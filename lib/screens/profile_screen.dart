import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/weather_service.dart';
import 'login_screen.dart'; // 1. ADDED THIS IMPORT

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final WeatherService _weatherService = WeatherService();
  final TextEditingController _cityController = TextEditingController();
  
  Map<String, dynamic>? weatherData;
  bool isLoading = false;

  void getWeather() async {
    if (_cityController.text.trim().isEmpty) return;
    FocusScope.of(context).unfocus(); 
    setState(() => isLoading = true);
    final data = await _weatherService.fetchWeather(_cityController.text.trim());
    setState(() {
      weatherData = data;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Container(
      color: const Color(0xFFF8FAFF),
      child: SingleChildScrollView(
        padding: EdgeInsets.zero, 
        child: Column(
          children: [
            // --- SECTION 1: HEADER ---
            Stack(
              children: [
                ClipPath(
                  clipper: WaveClipper(),
                  child: Container(
                    height: 280,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/Profile_Image.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                const Positioned(
                  top: 40,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Text(
                      "My Profile",
                      style: TextStyle(
                        color: Colors.white, 
                        fontSize: 24, 
                        fontWeight: FontWeight.bold,
                        shadows: [Shadow(blurRadius: 10, color: Colors.black45)]
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // --- SECTION 2: USER INFO CARD ---
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05), 
                    blurRadius: 10, 
                    offset: const Offset(0, 5)
                  )
                ],
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.blueAccent,
                    child: Icon(Icons.email, color: Colors.white, size: 30),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Logged in as", style: TextStyle(color: Colors.grey)),
                        const Text("Email", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        Text(
                          user?.email ?? "No Email Found", 
                          style: const TextStyle(color: Colors.blueAccent),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),

            const SizedBox(height: 25),

            // --- SECTION 3: WEATHER SECTION ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Check Weather", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const Text("Get real-time weather updates for any city.", style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 15),
                  
                  TextField(
                    controller: _cityController,
                    onSubmitted: (value) => getWeather(), 
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.location_on, color: Colors.blueAccent),
                      hintText: "Search city...", 
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15), 
                        borderSide: BorderSide.none
                      ),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: getWeather,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  if (isLoading)
                    const Center(child: CircularProgressIndicator())
                  else if (weatherData != null)
                    _buildWeatherCard()
                  else
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Text("Search a city to see weather", style: TextStyle(color: Colors.grey)),
                      ),
                    ),
                ],
              ),
            ),

            // --- LOGOUT BUTTON (FIXED LOGIC) ---
            Padding(
              padding: const EdgeInsets.all(25.0),
              child: OutlinedButton.icon(
                onPressed: () async {
                  // A. Sign out from Firebase
                  await FirebaseAuth.instance.signOut();
                  
                  // B. Move back to Login Screen and clear the memory of other pages
                  if (context.mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                      (route) => false, // This makes it impossible to go "back" to profile
                    );
                  }
                },
                icon: const Icon(Icons.logout, color: Colors.redAccent),
                label: const Text("Logout", style: TextStyle(color: Colors.redAccent)),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 55),
                  side: const BorderSide(color: Colors.redAccent),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherCard() {
    final main = weatherData!['main'];
    final wind = weatherData!['wind'];
    final weather = weatherData!['weather'][0];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.blueAccent.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${weatherData!['name']}, ${weatherData!['sys']['country']}", 
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)
                  ),
                  Text(
                    "${main['temp'].round()}°c", 
                    style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.blueAccent)
                  ),
                  Text("Feels like ${main['feels_like'].round()}°c", style: const TextStyle(color: Colors.grey)),
                ],
              ),
              Column(
                children: [
                  const Icon(Icons.wb_cloudy_outlined, size: 60, color: Colors.orangeAccent),
                  Text(weather['main'], style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              )
            ],
          ),
          const Divider(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _weatherDetail(Icons.water_drop, "Humidity", "${main['humidity']}%"),
              _weatherDetail(Icons.air, "Wind", "${wind['speed']} km/h"),
              _weatherDetail(Icons.visibility, "Visibility", "${(weatherData!['visibility'] / 1000).toStringAsFixed(1)} km"),
            ],
          )
        ],
      ),
    );
  }

  Widget _weatherDetail(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: Colors.blueAccent, size: 20),
        const SizedBox(height: 5),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 60);

    var firstControlPoint = Offset(size.width / 4, size.height);
    var firstEndPoint = Offset(size.width / 2, size.height - 30);
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy, firstEndPoint.dx, firstEndPoint.dy);

    var secondControlPoint = Offset(size.width - (size.width / 4), size.height - 80);
    var secondEndPoint = Offset(size.width, size.height - 40);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy, secondEndPoint.dx, secondEndPoint.dy);

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}