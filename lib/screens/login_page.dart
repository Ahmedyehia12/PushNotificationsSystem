import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:push_chat_notifications/auth.dart';
import 'package:push_chat_notifications/screens/home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  String? errorMessage = '';
  bool isLogin = true;
  String verificationId = '';

  Future<void> signInWithEmailAndPassword() async {
    try {
      await Auth().signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
      _navigateToHomePage();
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message;
      });
    }
  }

  Future<void> createUserWithEmailAndPassword() async {
    try {
      await Auth().createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
      _navigateToHomePage();
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message;
      });
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      final user = await Auth().signInWithGoogle();
      if (user != null) {
        _navigateToHomePage();
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message;
      });
    }
  }

  Future<void> verifyPhoneNumber() async {
    await Auth().verifyPhoneNumber(
      phoneNumber: phoneController.text.trim(),
      codeSent: (verificationId) {
        setState(() {
          this.verificationId = verificationId;
        });
      },
      verificationFailed: (e) {
        setState(() {
          errorMessage = e.message;
        });
      },
    );
  }

  Future<void> signInWithPhoneNumber(String smsCode) async {
    try {
      await Auth().signInWithPhoneNumber(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      _navigateToHomePage();
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message;
      });
    }
  }

  void _navigateToHomePage() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => HomePage(userId: Auth().currentUser!.uid),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login or Sign Up")),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              TextField(
                controller: passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: isLogin
                    ? signInWithEmailAndPassword
                    : createUserWithEmailAndPassword,
                child: Text(isLogin ? 'Login' : 'Sign Up'),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    isLogin = !isLogin;
                  });
                },
                child: Text(isLogin
                    ? "Don't have an account? Sign Up"
                    : "Already have an account? Login"),
              ),
              const Divider(height: 40),
              ElevatedButton.icon(
                onPressed: signInWithGoogle,
                icon: const Icon(Icons.login),
                label: const Text("Continue with Google"),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  hintText: '+1234567890',
                ),
                keyboardType: TextInputType.phone,
              ),
              ElevatedButton(
                onPressed: verifyPhoneNumber,
                child: const Text("Verify Phone Number"),
              ),
              if (verificationId.isNotEmpty)
                TextField(
                  onSubmitted: signInWithPhoneNumber,
                  decoration: const InputDecoration(
                    labelText: 'Enter SMS Code',
                  ),
                  keyboardType: TextInputType.number,
                ),
              if (errorMessage != null) ...[
                const SizedBox(height: 10),
                Text(
                  errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
