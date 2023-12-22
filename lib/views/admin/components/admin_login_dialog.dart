import 'package:Netinfo_Metaverse/constants.dart';
import 'package:flutter/material.dart';
import 'admin_login_form.dart';

Future<Object?> AdminSigninDialog(BuildContext context, {required ValueChanged onClosed}) {
  return showGeneralDialog(
      barrierDismissible: true,
      barrierLabel: "Login",
      context: context,
      transitionDuration: const Duration(milliseconds: 400),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        Tween<Offset> tween =
        Tween(begin: const Offset(0, -1), end: Offset.zero);
        return SlideTransition(
            position: tween.animate(
                CurvedAnimation(parent: animation, curve: Curves.easeInOut)),
            child: child);
      },
      pageBuilder: (context, _, __) => Center(
        child: Container(
          height: 520,
          width: 520,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
          decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.95),
              borderRadius: const BorderRadius.all(Radius.circular(40))),
          child: const Scaffold(
            backgroundColor: Colors.transparent,
            resizeToAvoidBottomInset:
            false, // avoid overflow error when keyboard shows up
            body: Stack(
              clipBehavior: Clip.none,
              children: [
                Column(
                    children: [
                      Text(
                        "Welcome Admin",
                        style: TextStyle(fontSize: 34, fontFamily: "Poppins"),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Text(
                          "Please login to manage all the incoming requests to the Netinfo Metaverse.",
                          textAlign: TextAlign.center,
                        ),
                      ),
                      AdminLoginForm(),
                    ]
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: -48,
                  child: CircleAvatar(
                    radius: 16,
                    backgroundColor: chartColor2,
                    child: Icon(Icons.close, color: Colors.white),
                  ),
                )
              ],
            ),
          ),
        ),
      )).then(onClosed);
}