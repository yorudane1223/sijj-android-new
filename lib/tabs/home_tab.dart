import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sijj_provinsi_banten/functions/auth_function.dart';
import 'package:sijj_provinsi_banten/themes/color.dart';
import 'package:sijj_provinsi_banten/themes/fonts.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.user;
    return SingleChildScrollView(
      child: Container(
        height: 80,
        decoration: BoxDecoration(
            boxShadow: const [
              BoxShadow(
                  color: Color.fromARGB(207, 0, 127, 201),
                  spreadRadius: 2,
                  blurRadius: 9,
                  offset: Offset(0, 5))
            ],
            color: primary,
            borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(48),
                bottomRight: Radius.circular(48)),
            gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: <Color>[
                  Color.fromARGB(255, 31, 88, 121),
                  Color.fromARGB(255, 0, 128, 202)
                ])),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Hallo👋🏻,',
              style: poppins.copyWith(color: white, fontSize: 15),
            ),
            const SizedBox(
              width: 10,
            ),
            Text(
              user!.nama,
              softWrap: true,
              style: poppins.copyWith(
                  fontWeight: FontWeight.bold, color: white, fontSize: 15),
            )
          ],
        ),
      ),
    );
  }
}
