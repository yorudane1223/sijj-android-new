import 'package:flutter/material.dart';
import 'package:sijj_provinsi_banten/themes/color.dart';
import 'package:sijj_provinsi_banten/themes/fonts.dart';

class ReportDetailTab extends StatelessWidget {
  final String latitude;
  final String longitude;
  final String kondisi;
  final String imageUrl;


  const ReportDetailTab({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.kondisi,
    required this.imageUrl,

  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start, // Ensure alignment to the left
          children: [
            Align(
              alignment: Alignment.centerLeft, // Align text to the left
              child: Text(
                'Detail Pengaduan',
                style: poppins.copyWith(fontSize: 21),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Card(
              elevation: 4.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.network(
                      imageUrl,
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                    const SizedBox(height: 16.0),
                    Text(
                      'Latitude: $latitude',
                      style: poppins.copyWith(fontSize: 15),
                    ),
                    Text(
                      'Longitude: $longitude',
                      style: poppins.copyWith(fontSize: 15),
                    ),
                    Text(
                      'Kondisi: $kondisi',
                      style: poppins.copyWith(fontSize: 15),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    // ElevatedButton(
                    //   onPressed: () {
                    //     // action
                    //     print('goto');
                    //   },
                    //   style: ElevatedButton.styleFrom(
                    //     shape: RoundedRectangleBorder(
                    //       borderRadius: BorderRadius.circular(5),
                    //     ),
                    //     minimumSize: const Size(double.infinity, 40),
                    //     backgroundColor: primary,
                    //   ),
                    //   child: Text(
                    //     'Lihat Lokasi',
                    //     style:
                    //         poppins.copyWith(fontSize: 13, color: Colors.white),
                    //   ),
                    // ),
                    ElevatedButton(
                      onPressed: () {
                        // action
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        minimumSize: const Size(double.infinity, 40),
                        backgroundColor: primary,
                      ),
                      child: Text(
                        'Kembali',
                        style:
                            poppins.copyWith(fontSize: 13, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
