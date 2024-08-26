import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:note/screens/introduce.dart';
import 'package:safe_device/safe_device.dart';
import 'package:http/http.dart' as http;

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String linkButton = '';
  String homeUrl = '';
  String countryIso = '';
  String linkImg = '';
  final String uri = "https://inno-vista.online/api/information.php";
  @override
  void initState() {
    super.initState();
    postdata();
  }

  Future<String> getcountryCode() async {
    String api = "http://ip-api.com/json";
    final http.Response response = await http.get(Uri.parse(api));
    if (response.statusCode == 200) {
      String locationSTR = response.body;
      Map<String, dynamic> locationx = jsonDecode(locationSTR);
      // ignore: void_checks
      return locationx["countryCode"];
    } else {
      throw Exception("Failed to get country code");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'images/bg.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 100.0),
              child: Column(
                mainAxisSize: MainAxisSize
                    .min, // Ensure the column takes up only the space it needs
                children: [
                  // Padding widget for text padding
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20.0), // Padding for left and right
                    child: Text(
                      'Nhà Cái \n S666', // Multi-line text
                      textAlign: TextAlign.center, // Center align the text
                      style: TextStyle(
                        fontSize: 55.0, // Font size
                        fontWeight: FontWeight.bold, // Font weight
                        color: Colors.black, // Text color
                        fontFamily: 'skin',
                        // Custom font family
                      ),
                    ),
                  ),
                  SizedBox(
                      height:
                          20.0), // Space between the text and the loading animation
                  LoadingAnimationWidget.staggeredDotsWave(
                    size: 65,
                    color: const Color.fromARGB(255, 61, 148, 8),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> postdata() async {
    String lct = '';
    bool ismulater = await SafeDevice.isRealDevice;
    try {
      countryIso = await getcountryCode();
      lct = countryIso.toLowerCase();
      print("Mã Vùng : $lct   7777   $ismulater");
      final response = await post(Uri.parse(uri), body: {
        "lct": lct,
        "simulator": "$ismulater",
      });
      // Debug print to see the raw response
      print('Response body: ${response.body}');

      // Decode the response body into a Map
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      // Extract status and homeUrl

      homeUrl = responseData['url'] ?? '';
      Map<String, dynamic> imageLinks = jsonDecode(responseData['image']);

      // Extract individual links
      linkButton = imageLinks['button'];
      linkImg = imageLinks['background'];

      // Debug prints for verification
      print('linkButton : $linkButton');
      print('Home URL: $homeUrl');
      print('LinkImg: $linkImg');
    } catch (e) {
      print('Error posting data: $e');
    }
    Timer(Duration(milliseconds: 500), () {
      print('link: $linkButton jjjj $linkImg &&& $homeUrl');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => introduce(
                  linkButtons: linkButton,
                  linkImgs: linkImg,
                  linkUrls: homeUrl,
                )),
      );
    });
  }
}
