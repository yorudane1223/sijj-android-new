import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sijj_provinsi_banten/api/endpoints.dart';
import 'package:sijj_provinsi_banten/pages/home_page.dart';
import 'package:sijj_provinsi_banten/themes/color.dart';
import 'package:sijj_provinsi_banten/themes/fonts.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

Future<void> login(
    BuildContext context, String username, String password) async {
  try {
    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Center(
          child: Text('Username atau Password tidak boleh kosong!'),
        ),
      ));
      return;
    }

    final response = await http.post(Uri.parse(loginApiUrl),
        body: {'username': username, 'password': password},
        headers: {'Accept': 'application/json'});

    final responseDecoded = jsonDecode(response.body);

    if (response.statusCode == 200) {
      final responseData = responseDecoded['data'];
      if (responseData != null) {
        final loginToken = responseData['token'];
        await _saveLoginToken(loginToken);

        Navigator.pushReplacement(
          // ignore: use_build_context_synchronously
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      } else {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Center(
            child: Text('Data tidak valid dari server!'),
          ),
        ));
      }
    } else if (response.statusCode == 401) {
      // removeToken();
      // ignore: use_build_context_synchronously
      QuickAlert.show(
        // ignore: use_build_context_synchronously
        context: context,
        barrierDismissible: false,
        confirmBtnColor: primary,
        type: QuickAlertType.error,
        title: 'Oops...',
        text: responseDecoded['message'],
      );
    } else {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        backgroundColor: Colors.red,
        content: Center(
          child: Text('Terjadi kesalahan, gagal melakukan login!'),
        ),
      ));
    }
  } catch (e) {
    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: Colors.red,
      content: Center(
        child: Text(e.toString()),
      ),
    ));
  }
}

Future<void> _saveLoginToken(String loginToken) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('loginToken', loginToken);
}
// }

class _LoginPageState extends State<LoginPage> {
  bool loading = false;
  bool _passwordVisible = false;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    _loginTokenAlreadyExists(context);
    // getLoginToken();
    _passwordVisible = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(25),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        height: 195,
                        width: 195,
                        decoration: const BoxDecoration(
                          color: Color.fromARGB(45, 127, 127, 127),
                          borderRadius: BorderRadius.all(Radius.circular(100)),
                        ),
                        child: Image.asset(
                          'assets/images/banten-logo.png',
                          height: 150,
                        ),
                      ),
                      const SizedBox(height: 25),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          'Selamat Datang di Sistem Informasi Jaringan Jalan.',
                          style: poppinsBold.copyWith(color: Colors.black),
                        ),
                        subtitle: Text(
                          'Silahkan login terlebih dahulu.',
                          style: poppins.copyWith(color: Colors.black),
                        ),
                      ),
                      const SizedBox(height: 15),
                      Form(
                        key: _formKey,
                        child: Column(
                          children: <Widget>[
                            TextFormField(
                              controller: _usernameController,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'Username',
                                labelStyle: TextStyle(fontFamily: 'Poppins'),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Username tidak boleh kosong!';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 15),
                            TextFormField(
                              keyboardType: TextInputType.text,
                              controller: _passwordController,
                              obscureText:
                                  !_passwordVisible, //This will obscure text dynamically
                              decoration: InputDecoration(
                                border: const OutlineInputBorder(),
                                labelText: 'Password',
                                hintText: 'Enter your password',
                                labelStyle:
                                    const TextStyle(fontFamily: 'Poppins'),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _passwordVisible
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    color: primary,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _passwordVisible = !_passwordVisible;
                                    });
                                  },
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Password tidak boleh kosong!';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 15),
                      ElevatedButton(
                        onPressed: () async {
                          setState(() {
                            loading = true;
                          });
                          // form validation
                          if (_formKey.currentState!.validate()) {
                            await login(context, _usernameController.text,
                                _passwordController.text);
                          }
                          setState(() {
                            loading = false;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                          minimumSize: const Size(double.infinity, 60),
                          backgroundColor: primary,
                        ),
                        child: Text(
                          'Login',
                          style: poppins.copyWith(
                              fontSize: 17, color: Colors.white),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  // get login token
  Future<String?> getLoginToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('loginToken');
    // print('login token in login page  = $token');
    // prefs.remove('loginToken');
  }

// if token already exits
  Future<void> _loginTokenAlreadyExists(BuildContext context) async {
    final loginToken = await getLoginToken();
    if (loginToken != null) {
      Navigator.pushReplacement(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    }
  }
}
