import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../constants.dart';

class ProfileMenu extends StatelessWidget {
  const ProfileMenu({
    required this.text,
    required this.icon,
    required this.press,
    required this.image,
  });

  final String text, icon, image;
  final VoidCallback press;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
          // image: DecorationImage(
          //   image: NetworkImage(image),
          //   fit: BoxFit.cover,
          //   alignment: Alignment.center,
          // ),
          ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        child: MaterialButton(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
            color: Colors.grey[700],
            onPressed: press,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 15.0),
              child: Column(
                children: <Widget>[
                  Row(
                    children: [
                      SvgPicture.asset(
                        icon,
                        color: Color(0xff939FD8),
                        width: 22,
                      ),
                      SizedBox(width: 20),
                      Expanded(
                          child: Text(
                        text,
                        style: TextStyle(color: Colors.white),
                      )),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.amber[700],
                      ),
                    ],
                  ),
                ],
              ),
            )),
      ),
    );
  }
}
