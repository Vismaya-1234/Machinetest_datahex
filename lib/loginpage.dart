import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final Dio _dio = Dio();
  final TextEditingController emailcntrl = TextEditingController();
  final TextEditingController pswdcntrl = TextEditingController();
  bool _isLoading = false;

  Future<void> loginPost() async {
    final trimmedEmail = emailcntrl.text.trim();
    final trimmedPass = pswdcntrl.text.trim();

    if (trimmedEmail.isEmpty || trimmedPass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter both email and password.")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // ✅ Admin credentials check before API call
      if (trimmedEmail == "mfaris2k18@gmail.com" && trimmedPass == "111") {
        await showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text('Login Successful'),
            content: Text('Welcome Admin!'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('OK'),
              ),
            ],
          ),
        );

        // TODO: Navigate to admin home page if needed
        // Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => AdminHomePage()));

        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Enable Dio logging
      _dio.interceptors.clear();
      _dio.interceptors
          .add(LogInterceptor(responseBody: true, requestBody: true));

      final response = await _dio.post(
        'https://entrance-test-api.datahex.co/api/v1/auth/login/',
        data: {
          "email": trimmedEmail,
          "password": trimmedPass,
        },
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      print("Status code: ${response.statusCode}");
      print("Response data: ${response.data}");

      if (response.statusCode == 200) {
        final data = response.data;

        if (data['success'] == true) {
          final userName = data['user']?['name'] ?? 'User';

          await showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: Text('Login Successful'),
              content: Text('Welcome $userName!'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('OK'),
                ),
              ],
            ),
          );

          // TODO: Navigate to regular user home
          // Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => Myhome()));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['message'] ?? "Login failed.")),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Unexpected server response.")),
        );
      }
    } catch (e) {
      print("API call error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Something went wrong. Please try again.")),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final height = size.height;
    final width = size.width;

    return Scaffold(
      backgroundColor: const Color(0xFF00C896),
      body: Stack(
        children: [
          Positioned(
            top: height * 0.15,
            left: width * 0.05,
            right: width * 0.05,
            child: SizedBox(
              height: height * 0.45,
              child: Center(
                child: Transform.translate(
                  offset: Offset(0, height * 0.04),
                  child: Transform.scale(
                    scale: 2.1,
                    child: Image.asset(
                      'assets/image.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: height * 0.42,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: width * 0.06,
                vertical: height * 0.03,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(width * 0.08),
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Sign in",
                      style: TextStyle(
                        fontSize: height * 0.035,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: height * 0.01),
                    Text(
                      "Please enter the details\nbelow to continue",
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: height * 0.021,
                      ),
                    ),
                    SizedBox(height: height * 0.025),
                    TextField(
                      controller: emailcntrl,
                      decoration: InputDecoration(
                        hintText: 'Email ID',
                        hintStyle: TextStyle(
                          color: Colors.grey[600],
                          fontSize: height * 0.02,
                        ),
                        prefixIcon:
                            Icon(Icons.email_outlined, color: Colors.grey[600]),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Color(0xFFC2C2C2)),
                        ),
                      ),
                    ),
                    SizedBox(height: height * 0.02),
                    TextField(
                      controller: pswdcntrl,
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: 'Password',
                        hintStyle: TextStyle(
                          color: Colors.grey[600],
                          fontSize: height * 0.02,
                        ),
                        prefixIcon:
                            Icon(Icons.lock_outline, color: Colors.grey[600]),
                        suffixIcon:
                            Icon(Icons.visibility_off, color: Colors.grey[600]),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Color(0xFFC2C2C2)),
                        ),
                      ),
                    ),
                    SizedBox(height: height * 0.05),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : loginPost,
                        child: _isLoading
                            ? CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              )
                            : Text(
                                "Sign in",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: height * 0.025,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF00C896),
                          padding: EdgeInsets.symmetric(
                            vertical: height * 0.018,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: height * 0.04),
                    Center(
                      child: RichText(
                        text: TextSpan(
                          text: "Don't have an account? ",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: height * 0.021,
                            fontWeight: FontWeight.bold,
                          ),
                          children: [
                            TextSpan(
                              text: "Sign up",
                              style: TextStyle(color: Colors.blue),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
