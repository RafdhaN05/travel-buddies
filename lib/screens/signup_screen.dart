// import 'package:flutter/material.dart';
// import '../services/auth_service.dart';
// import 'login_screen.dart';

// class SignUpScreen extends StatefulWidget {
//   const SignUpScreen({super.key});

//   @override
//   State<SignUpScreen> createState() => _SignUpScreenState();
// }

// class _SignUpScreenState extends State<SignUpScreen> {
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   final AuthService _auth = AuthService();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white, // FIX 1: Solid background
//       appBar: AppBar(
//         title: const Text("Create Account"),
//       ),
//       body: SingleChildScrollView( // FIX 3: Prevents layout breaking when keyboard appears
//         child: Padding(
//           padding: const EdgeInsets.all(20.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               const SizedBox(height: 20),
//               const Text(
//                 "Join Travel Buddies 🌍",
//                 style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//               ),
//               const SizedBox(height: 30),

//               TextField(
//                 controller: _emailController,
//                 decoration: const InputDecoration(labelText: "Email", border: OutlineInputBorder()),
//               ),
//               const SizedBox(height: 20),

//               TextField(
//                 controller: _passwordController,
//                 obscureText: true,
//                 decoration: const InputDecoration(labelText: "Password", border: OutlineInputBorder()),
//               ),
//               const SizedBox(height: 30),

//               ElevatedButton(
//                 style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
//                 onPressed: () async {
//                   var user = await _auth.signUp(
//                     _emailController.text.trim(),
//                     _passwordController.text.trim(),
//                   );

//                   if (user != null) {
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       const SnackBar(content: Text("Success! Welcome Buddy!")),
//                     );
//                   } else {
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       const SnackBar(content: Text("Registration Failed. Try again.")),
//                     );
//                   }
//                 },
//                 child: const Text("Sign Up"),
//               ),

//               TextButton(
//                 onPressed: () {
//                   Navigator.pop(context);
//                 },
//                 child: const Text("Already have an account? Login"),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  // Controllers for all fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  
  final AuthService _auth = AuthService();
  bool _isObscured = true;
  bool _isConfirmObscured = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF), // Light background
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. TOP BLUE SECTION (The Curve)
            Container(
              width: double.infinity,
              height: 280,
              decoration: const BoxDecoration(
                color: Color(0xFF0D47A1), // Solid Deep Blue
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(50),
                  bottomRight: Radius.circular(50),
                ),
              ),
              child: SafeArea(
                child: Stack(
                  children: [
                    // Back Button
                    Positioned(
                      top: 10,
                      left: 10,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    // Header Text & Plane Icon
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Create Account",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 5),
                          const Text(
                            "Start your adventure with Travel Buddies",
                            style: TextStyle(color: Colors.white70, fontSize: 14),
                          ),
                          const SizedBox(height: 20),
                          // Decorative Plane Icon (matching your image)
                          const Icon(Icons.airplanemode_active, color: Colors.white, size: 40),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 2. FORM FIELDS
            Padding(
              padding: const EdgeInsets.all(25.0),
              child: Column(
                children: [
                  // Full Name Field
                  _buildTextField(
                    controller: _nameController,
                    label: "Full Name",
                    icon: Icons.person_outline,
                  ),
                  const SizedBox(height: 20),

                  // Email Field
                  _buildTextField(
                    controller: _emailController,
                    label: "Email",
                    icon: Icons.email_outlined,
                  ),
                  const SizedBox(height: 20),

                  // Password Field
                  _buildTextField(
                    controller: _passwordController,
                    label: "Password",
                    icon: Icons.lock_outline,
                    isPassword: true,
                    isObscured: _isObscured,
                    onToggle: () => setState(() => _isObscured = !_isObscured),
                  ),
                  const SizedBox(height: 20),

                  // Confirm Password Field
                  _buildTextField(
                    controller: _confirmPasswordController,
                    label: "Confirm Password",
                    icon: Icons.lock_outline,
                    isPassword: true,
                    isObscured: _isConfirmObscured,
                    onToggle: () => setState(() => _isConfirmObscured = !_isConfirmObscured),
                  ),
                  const SizedBox(height: 30),

                  // Sign Up Button
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D47A1),
                      minimumSize: const Size(double.infinity, 55),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      elevation: 2,
                    ),
                    onPressed: () async {
                      if (_passwordController.text != _confirmPasswordController.text) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Passwords do not match!")),
                        );
                        return;
                      }
                      
                      var user = await _auth.signUp(
                        _emailController.text.trim(),
                        _passwordController.text.trim(),
                      );

                      if (user != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Success! Welcome Buddy!")),
                        );
                      }
                    },
                    child: const Text("Sign Up", style: TextStyle(fontSize: 18, color: Colors.white)),
                  ),

                  const SizedBox(height: 25),

                  // Divider
                  Row(
                    children: const [
                      Expanded(child: Divider()),
                      Padding(padding: EdgeInsets.symmetric(horizontal: 10), child: Text("or", style: TextStyle(color: Colors.grey))),
                      Expanded(child: Divider()),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Already have account?
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Already have an account? ", style: TextStyle(color: Colors.grey)),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Text(
                          "Login",
                          style: TextStyle(color: Color(0xFF0D47A1), fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // HELPER WIDGET TO KEEP CODE CLEAN
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    bool isObscured = false,
    VoidCallback? onToggle,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5)),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: isObscured,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: const Color(0xFF0D47A1)),
          suffixIcon: isPassword 
            ? IconButton(icon: Icon(isObscured ? Icons.visibility_off : Icons.visibility), onPressed: onToggle)
            : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
        ),
      ),
    );
  }
}