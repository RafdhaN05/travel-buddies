// import 'package:flutter/material.dart';
// import '../services/auth_service.dart';
// import 'signup_screen.dart';

// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});

//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen> {
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   final AuthService _auth = AuthService();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white, // FIX 1: Ensures the screen is solid, not transparent
//       body: SafeArea( // FIX 2: Keeps content away from the top notch/status bar
//         child: SingleChildScrollView( // FIX 3: Prevents keyboard overlap issues
//           child: Padding(
//             padding: const EdgeInsets.all(20.0),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 const SizedBox(height: 50), // Spacing to look better
//                 const Icon(Icons.lock_outline, size: 80, color: Colors.blueAccent),
//                 const SizedBox(height: 20),
//                 const Text("Welcome Back!", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
//                 const SizedBox(height: 30),
                
//                 TextField(
//                   controller: _emailController,
//                   decoration: const InputDecoration(labelText: "Email", border: OutlineInputBorder()),
//                 ),
//                 const SizedBox(height: 20),
//                 TextField(
//                   controller: _passwordController,
//                   obscureText: true,
//                   decoration: const InputDecoration(labelText: "Password", border: OutlineInputBorder()),
//                 ),
//                 const SizedBox(height: 30),
                
//                 ElevatedButton(
//                   style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
//                   onPressed: () async {
//                     var user = await _auth.login(_emailController.text.trim(), _passwordController.text);
//                     if (user != null) {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         const SnackBar(content: Text("Login Successful! ✨")),
//                       );
//                     } else {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         const SnackBar(content: Text("Invalid Email or Password")),
//                       );
//                     }
//                   },
//                   child: const Text("Login"),
//                 ),
                
//                 TextButton(
//                   onPressed: () {
//                     Navigator.push(context, MaterialPageRoute(builder: (context) => const SignUpScreen()));
//                   },
//                   child: const Text("Don't have an account? Sign Up"),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // 1. CONTROLLERS: These capture the text the user types
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  // 2. DEPENDENCIES & STATE
  final AuthService _auth = AuthService();
  bool _isObscured = true; // For toggling password eye icon
  bool _isLoading = false; // To show a loading spinner when button is clicked

  // 3. LOGIN LOGIC FUNCTION (Study this to understand Error Handling)
  Future<void> _handleLogin() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    // --- STEP A: FIELD VALIDATION ---
    if (email.isEmpty || password.isEmpty) {
      _showSnackBar("Please fill in all fields", Colors.redAccent);
      return;
    }

    // --- STEP B: START LOADING ---
    setState(() => _isLoading = true);

    try {
      // --- STEP C: CALL AUTH SERVICE ---
      var user = await _auth.login(email, password);

      if (user != null) {
        // SUCCESS MESSAGE
        _showSnackBar("Welcome back! Login Successful ✨", Colors.green);
        
        // NOTE: Here you would navigate to your Home Screen
        // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen()));
      } else {
        // FAILURE MESSAGE (Wrong credentials)
        _showSnackBar("Invalid Email or Password. Please try again.", Colors.orange);
      }
    } catch (e) {
      // ERROR MESSAGE (Connection issues or system errors)
      _showSnackBar("An error occurred: ${e.toString()}", Colors.red);
    } finally {
      // --- STEP D: STOP LOADING ---
      setState(() => _isLoading = false);
    }
  }

  // 4. SNACKBAR HELPER (Reusable pop-up message)
  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating, // Makes it look modern
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF), // Soft background color
      body: SingleChildScrollView( // PREVENTS: Keyboard overlapping UI
        child: Column(
          children: [
            // --- UI SECTION 1: HEADER WITH IMAGE & WAVE ---
            ClipPath(
              clipper: WaveClipper(),
              child: Stack(
                children: [
                  // The Background Image from your assets
                  Container(
                    height: 380,
                    width: double.infinity,
                    child: Image.asset(
                      'assets/TB_Login.png', // MAKE SURE THIS EXISTS IN ASSETS
                      fit: BoxFit.cover,
                    ),
                  ),
                  // Dark overlay to make the white text readable
                  Container(
                    height: 380,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.black.withOpacity(0.3), Colors.transparent],
                      ),
                    ),
                  ),
                  // The Text Overlay
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const CircleAvatar(
                            backgroundColor: Colors.white24,
                            child: Icon(Icons.airplanemode_active, color: Colors.white),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            "Travel Buddies",
                            style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                          ),
                          const Text(
                            "Explore Together,\nCreate Memories",
                            style: TextStyle(color: Colors.white70, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // --- UI SECTION 2: THE FORM ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Welcome Back!",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1A237E)),
                  ),
                  const Text("Login to continue your journey", style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 30),

                  // EMAIL FIELD
                  _buildInputContainer(
                    child: TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.email_outlined, color: Color(0xFF0D47A1)),
                        labelText: "Email",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // PASSWORD FIELD
                  _buildInputContainer(
                    child: TextField(
                      controller: _passwordController,
                      obscureText: _isObscured,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF0D47A1)),
                        suffixIcon: IconButton(
                          icon: Icon(_isObscured ? Icons.visibility_off : Icons.visibility),
                          onPressed: () => setState(() => _isObscured = !_isObscured),
                        ),
                        labelText: "Password",
                        border: InputBorder.none,
                      ),
                    ),
                  ),

                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {}, // Handle forgot password
                      child: const Text("Forgot Password?", style: TextStyle(color: Color(0xFF1976D2))),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // LOGIN BUTTON
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D47A1),
                      minimumSize: const Size(double.infinity, 55),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      elevation: 4,
                    ),
                    onPressed: _isLoading ? null : _handleLogin, // Disable button if loading
                    child: _isLoading 
                      ? const CircularProgressIndicator(color: Colors.white) // Show spinner
                      : const Text("Login", style: TextStyle(fontSize: 18, color: Colors.white)),
                  ),

                  const SizedBox(height: 30),

                  // OR DIVIDER
                  Row(
                    children: const [
                      Expanded(child: Divider()),
                      Padding(padding: EdgeInsets.symmetric(horizontal: 10), child: Text("or", style: TextStyle(color: Colors.grey))),
                      Expanded(child: Divider()),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // SIGN UP NAVIGATION
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don't have an account? "),
                      GestureDetector(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SignUpScreen())),
                        child: const Text("Sign Up", style: TextStyle(color: Color(0xFF1976D2), fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // HELPER UI: Creates the white card look for input fields
  Widget _buildInputContainer({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5)),
        ],
      ),
      child: child,
    );
  }
}

// --- UI SECTION 3: THE WAVE CLIPPER (The Shape at the top) ---
class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 80); 

    var firstControlPoint = Offset(size.width / 4, size.height);
    var firstEndPoint = Offset(size.width / 2.25, size.height - 50);
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy, firstEndPoint.dx, firstEndPoint.dy);

    var secondControlPoint = Offset(size.width - (size.width / 3.25), size.height - 120);
    var secondEndPoint = Offset(size.width, size.height - 80);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy, secondEndPoint.dx, secondEndPoint.dy);

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}