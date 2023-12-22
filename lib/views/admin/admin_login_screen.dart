import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import '../../components/animated_btn.dart';
import 'components/admin_login_dialog.dart';


class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  bool isSignInDialogShown = false;

  late RiveAnimationController _btnAnimationController;

  @override
  void initState() {
    _btnAnimationController = OneShotAnimation("active", autoplay: false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SelectionArea(
      child: Scaffold(
        body: Stack(
          children: [
            Positioned(
                width: MediaQuery.of(context).size.width * 1.7,
                bottom: 200,
                left: 100,
                child: Image.asset('assets/Backgrounds/Spline.png')),
            Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 10),
                )),
            const RiveAnimation.asset('assets/RiveAssets/shapes.riv'),
            Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 10),
                  child: const SizedBox(),
                )),
            AnimatedPositioned(
              duration: const Duration(milliseconds: 240),
              top: isSignInDialogShown ? -50 : 0,
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Spacer(),
                        Image.asset('assets/Backgrounds/logo_metaverse.png'),
                        const SizedBox(
                          child: Column(children: [
                            Text(
                              "Welcome to the admin page",
                              style: TextStyle(
                                  fontSize: 60, fontFamily: "Poppins", height: 1.2),
                            ),
                            SizedBox(
                              height: 16,
                            ),
                            Text(
                                "Don't skip design. Learn design and code, by builder real apps with Flutter and Swift. Complete courses about best tools.")
                          ]),
                        ),
                        const Spacer(
                          flex: 2,
                        ),
                        Column(
                          children: [
                            AnimatedBtn(
                              btnAnimationController: _btnAnimationController,
                              press: () {
                                _btnAnimationController.isActive = true;
                                Future.delayed(const Duration(milliseconds: 800), () {
                                  setState(() {
                                    isSignInDialogShown = true;
                                  });
                                  AdminSigninDialog(context, onClosed: (_) {
                                    setState(() {
                                      isSignInDialogShown = false;
                                    });
                                  });
                                });
                              },
                              label: 'Sign In',
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                          ],
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 40.0),
                        )
                      ]),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
