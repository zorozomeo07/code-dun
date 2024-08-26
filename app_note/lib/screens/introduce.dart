import 'package:flutter/material.dart';
import 'package:note/home_page.dart';
import 'package:url_launcher/url_launcher.dart';

class introduce extends StatefulWidget {
  String linkButtons;
  String linkUrls;
  String linkImgs;
  introduce(
      {required this.linkButtons,
      required this.linkUrls,
      required this.linkImgs});
  @override
  State<introduce> createState() => _Introduce();
}

class _Introduce extends State<introduce> {
  String a = '';
  String b = '';
  String c = '';
  @override
  void initState() {
    super.initState();
    a = widget.linkButtons;
    b = widget.linkImgs;
    c = widget.linkUrls;
    print('check link : $a hbn f  $b  jdcn  $c');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.network(
              widget.linkImgs,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: EdgeInsets.only(
                top: 40,
                right: 15,
              ),
              child: IconButton(
                  onPressed: () async {
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (context) => HomePage()));
                  },
                  icon: SizedBox(
                    width: 50.0,
                    height: 50.0,
                    child: Image.asset('images/next.png'),
                  )),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.only(bottom: 45),
              child: IconButton(
                  onPressed: () async {
                    launchURL(widget.linkUrls);
                  },
                  icon: SizedBox(
                    width: 300.0,
                    height: 80.0,
                    child: Image.network(widget.linkButtons),
                  )),
            ),
          ),
        ],
      ),
    );
  }

  // Sửa hàm launchURL để sử dụng Uri
  void launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $url';
    }
  }
}
