// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg/svg.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:sijj_provinsi_banten/components/layouts/sidebar_layout.dart';
import 'package:sijj_provinsi_banten/functions/auth_function.dart';
import 'package:sijj_provinsi_banten/pages/settings/update_password_page.dart';
import 'package:sijj_provinsi_banten/tabs/absen_tab.dart';
import 'package:sijj_provinsi_banten/tabs/home_tab.dart';
import 'package:sijj_provinsi_banten/tabs/my_profile_tab.dart';
import 'package:sijj_provinsi_banten/themes/color.dart';
import 'package:sijj_provinsi_banten/themes/fonts.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isLoading = true;

  @override
  void initState() {
    initializeAuth(context).then((_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });

    super.initState();
  }

  int currentPageIndex = 0;
  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? Scaffold(
            body: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: Image.asset(
                  'assets/images/banten-logo.png',
                  width: 280,
                ),
              ),
              Text(
                'Loading..',
                style: poppins.copyWith(fontSize: 11),
              )
            ],
          ))
        : Scaffold(
            drawer: const Sidebar(),
            appBar: AppBar(
              iconTheme: const IconThemeData(color: Colors.white),
              backgroundColor: primary,
              title: Text(
                'SIJJ Provinsi Banten',
                style: anton.copyWith(color: Colors.white),
              ),
              actions: <Widget>[
                IconButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const UpdatePasswordPage()));
                    },
                    icon: SvgPicture.asset(
                      'assets/icons/setting.svg',
                      color: white,
                      width: 27,
                    )),
                IconButton(
                  icon: SvgPicture.asset(
                    'assets/icons/logout.svg',
                    width: 25,
                    color: Colors.white,
                  ),
                  tooltip: 'Keluar',
                  onPressed: () {
                    QuickAlert.show(
                      barrierDismissible: false,
                      headerBackgroundColor: primary,
                      onConfirmBtnTap: () async {
                        final authProvider = AuthProvider();
                        await authProvider.logout(context);
                      },
                      context: context,
                      type: QuickAlertType.confirm,
                      text: 'Kamu akan keluar dari aplikasi',
                      confirmBtnText: 'Ya',
                      cancelBtnText: 'Tidak',
                      confirmBtnColor: primary,
                    );
                  },
                )
              ],
            ),
            body: <Widget>[
              /// Home page
              const HomeTab(),

              // Map page
              // const MapTab(),

              /// Absen page
              const AbsenTab(),

              /// Profile page
              const MyProfileTab()
            ][currentPageIndex],
            bottomNavigationBar: NavigationBar(
              animationDuration: const Duration(seconds: 3),
              onDestinationSelected: (int index) {
                setState(() {
                  currentPageIndex = index;
                });
              },
              indicatorColor: primary,
              selectedIndex: currentPageIndex,
              destinations: <Widget>[
                NavigationDestination(
                  selectedIcon: SvgPicture.asset('assets/icons/home.svg',
                      color: Colors.white),
                  icon: SvgPicture.asset('assets/icons/home.svg'),
                  label: 'Beranda',
                ),
                NavigationDestination(
                  selectedIcon: SvgPicture.asset(
                    'assets/icons/absen.svg',
                    color: Colors.white,
                  ),
                  icon: SvgPicture.asset('assets/icons/absen.svg'),
                  label: 'Absen',
                ),
                NavigationDestination(
                  selectedIcon: SvgPicture.asset(
                    'assets/icons/profile.svg',
                    color: Colors.white,
                  ),
                  icon: SvgPicture.asset('assets/icons/profile.svg'),
                  label: 'Profil',
                ),
              ],
            ));
  }
}
