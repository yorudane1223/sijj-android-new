import 'package:flutter/material.dart';
import 'package:sijj_provinsi_banten/themes/color.dart';
import 'package:sijj_provinsi_banten/themes/fonts.dart';

class ForgotPasswordPage extends StatelessWidget {
  const ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/bg-batik.jpeg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Content
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(25),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    // logo
                    Container(
                      height: 195,
                      width: 195,
                      decoration: const BoxDecoration(
                        color: Color.fromARGB(45, 127, 127, 127),
                        borderRadius: BorderRadius.all(Radius.circular(100)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/images/banten-logo.png',
                            height: 150,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 25,
                    ),
                    // welcome text
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 0),
                      title: Text('Verifikasi Email.',
                          style: poppinsBold.copyWith(color: Colors.black)),
                      subtitle: Text(
                        'Silahkan masukkan email Anda untuk melakukan proses selanjutnya.',
                        style: poppins.copyWith(color: Colors.black),
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    // form input
                    const TextField(
                      decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Email',
                          labelStyle: TextStyle(fontFamily: 'Poppins')),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    // button
                    ElevatedButton(
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return const AlertDialog(
                                content: ListTile(
                                  leading: Icon(Icons.info),
                                  title: Text('Berhasil terkirim'),
                                  subtitle: Text(
                                      'Email verifikasi berhasil terkirim, Silahkan cek Email Anda'),
                                ),
                              );
                            });
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        minimumSize: const Size(double.infinity, 60),
                        backgroundColor: primary,
                      ),
                      child: Text('Verfifikasi',
                          style: poppins.copyWith(
                              fontSize: 17, color: Colors.white)),
                    ),

                    // forgot password
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Kembali Login',
                        style: poppins.copyWith(
                            fontWeight: FontWeight.bold, color: primary),
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
