import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:frontend/models/currency.dart';
import 'package:frontend/services/api_service.dart';
import 'login_screen.dart';

Future<List<Currency>> loadCurrencies() async {
  final jsonString = await rootBundle.loadString("assets/data/c.json");
  final List<dynamic> data = json.decode(jsonString);
  return data.map((e) => Currency.fromJson(e)).toList();
}

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});
  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  List<Currency> currencies = [];
  Currency? selectedCurrency;

  @override
  void initState() {
    super.initState();
    loadCurrencies().then((data) {
      setState(() {
        currencies = data;
        selectedCurrency = currencies.first;
      });
    });
  }

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool loading = false;
  String error = "";

  @override
  Widget build(BuildContext context) {
    // final passwordController = TextEditingController();
    // final _formKey = GlobalKey<FormState>();
    return Scaffold(
      // backgroundColor: const Color(0xFF3BC1A8),
      backgroundColor: const Color(0xFF008080),

      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.fromLTRB(32, 100, 32, 50),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "FinGuide",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 1),

              const Text(
                "Think Smart, Spend Smart",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),

              const SizedBox(height: 100),

              const Text(
                "Welcome To FinGuide",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.w400,
                ),
              ),

              const SizedBox(height: 1),

              const Text(
                "Create an account to get started",
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),

              const SizedBox(height: 30),

              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: "Full Name",
                        labelStyle: TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: Colors.white.withAlpha(30),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Name is required";
                        }
                        return null;
                      },
                      controller: nameController,
                    ),

                    const SizedBox(height: 16),

                    TextFormField(
                      style: TextStyle(color: Colors.white),
                      controller: emailController,
                      decoration: InputDecoration(
                        labelText: "Email",
                        labelStyle: TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: Colors.white.withAlpha(30),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Email is required";
                        }
                        final emailRegex = RegExp(
                          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                        );

                        if (!emailRegex.hasMatch(value)) {
                          return "Enter a valid email";
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    Align(
                      alignment: Alignment.centerLeft,
                      child: SizedBox(
                        width: 200,
                        child: DropdownButtonFormField<Currency>(
                          // initialValue: selectedCurrency,
                          initialValue: selectedCurrency,
                          isExpanded: true,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: "Currency Code",
                            labelStyle: const TextStyle(color: Colors.white70),
                            filled: true,
                            fillColor: Colors.white.withAlpha(30),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                          ),
                          dropdownColor: const Color(0xFF008080),
                          items: currencies.map((currency) {
                            return DropdownMenuItem<Currency>(
                              value: currency,
                              child: Text(
                                currency.code,
                                style: const TextStyle(color: Colors.white),
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedCurrency = value;
                            });
                          },
                          validator: (value) {
                            if (value == null) {
                              return "Currency Code is Required";
                            }
                            return null;
                          },
                        ),
                      ),
                    ),

                    // const SizedBox(height: 16),

                    // DropdownButtonFormField<Currency>(
                    //   initialValue: selectedCurrency,
                    //   style: const TextStyle(color: Colors.white),
                    //   isExpanded: true,
                    //   decoration: InputDecoration(
                    //     labelText: "Currency Code",
                    //     labelStyle: TextStyle(color: Colors.white70),
                    //     filled: true,
                    //     fillColor: Colors.white.withAlpha(30),
                    //     border: OutlineInputBorder(
                    //       borderRadius: BorderRadius.circular(12),
                    //       borderSide: BorderSide.none,
                    //     ),
                    //     focusedBorder: OutlineInputBorder(
                    //       borderRadius: BorderRadius.circular(12),
                    //       borderSide: BorderSide.none,
                    //     ),
                    //     contentPadding: const EdgeInsets.symmetric(
                    //       horizontal: 16,
                    //       vertical: 14,
                    //     ),
                    //   ),
                    //   dropdownColor: const Color(0xFF008080),
                    //   items: currencies.map((currency) {
                    //     return DropdownMenuItem<Currency>(
                    //       value: currency,
                    //       child: Text(
                    //         currency.code,
                    //         style: const TextStyle(color: Colors.white),
                    //       ),
                    //     );
                    //   }).toList(),
                    //   onChanged: (value) {
                    //     setState(() {
                    //       selectedCurrency = value;
                    //     });
                    //   },
                    //   validator: (value) {
                    //     if (value == null) {
                    //       return "Currency Code is Required";
                    //     }
                    //     return null;
                    //   },
                    // ),
                    const SizedBox(height: 16),

                    TextFormField(
                      obscureText: true,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: "Password",
                        labelStyle: TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: Colors.white.withAlpha(30),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                      controller: passwordController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Password is required";
                        }
                        if (value.length < 6) {
                          return "Min 6 characters required";
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 24),

                    TextFormField(
                      obscureText: true,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: "Confirm Password",
                        labelStyle: TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: Colors.white.withAlpha(30),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Confirm Password is Required";
                        }
                        if (value != passwordController.text) {
                          return "Passwords do not match";
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: loading
                            ? null
                            : () async {
                                if (!_formKey.currentState!.validate()) return;

                                setState(() {
                                  loading = true;
                                  error = "";
                                });

                                try {
                                  final res = await ApiService.register(
                                    name: nameController.text.trim(),
                                    email: emailController.text.trim(),
                                    password: passwordController.text,
                                    currencyCode: selectedCurrency!.code,
                                  );

                                  setState(() => loading = false);

                                  if (res["success"] == true) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          "Account created! Please login.",
                                        ),
                                        duration: Duration(seconds: 2),
                                      ),
                                    );

                                    await Future.delayed(
                                      const Duration(seconds: 2),
                                    );

                                    if (mounted) {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => const LoginScreen(),
                                        ),
                                      );
                                    }
                                  } else {
                                    setState(() {
                                      error =
                                          res["message"] ??
                                          "Registration failed";
                                    });
                                  }
                                } catch (e) {
                                  setState(() {
                                    loading = false;
                                    error =
                                        "Something went wrong. Please try again.";
                                  });
                                  print("Signup error: $e");
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF008080),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: loading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Color(0xFF008080),
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                "Sign Up",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),

                    if (error.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          error,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 14,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
