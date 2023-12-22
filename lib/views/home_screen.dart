import 'dart:ui';
import 'package:Netinfo_Metaverse/responsive_layout.dart';
import 'package:Netinfo_Metaverse/views/user/mobile_request_dialog.dart';
import 'package:Netinfo_Metaverse/views/user/request_screen.dart';
import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../components/animated_btn.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isSignInDialogShown = false;
  late RiveAnimationController _btnAnimationController;
  late RiveAnimationController _websiteAnimationController;

  @override
  void initState() {
    _btnAnimationController = OneShotAnimation("active", autoplay: false);
    _websiteAnimationController = OneShotAnimation("active", autoplay: false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SelectionArea(
      child: Scaffold(
        body: Stack(
          children: [
            Positioned(
                width: MediaQuery.of(context).size.width * 1.3,
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
              )
            ),
            AnimatedPositioned(
              duration: const Duration(milliseconds: 240),
              top: isSignInDialogShown ? -50 : 0,
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 50),
                  child: ResponsiveLayout(
                    tiny: Column(
                      children: [
                        const Spacer(),
                        Image.asset('assets/Backgrounds/logo_metaverse.png',
                            width: 192, height: 192),
                        const SizedBox(
                          width: 340,
                          child: Column(children: [
                            Text(
                              "Welcome To TalentVerse",
                              style: TextStyle(
                                  fontSize: 60,
                                  fontFamily: "Poppins",
                                  height: 1.2),
                            ),
                            SizedBox(
                              height: 16,
                            ),
                            Text(
                                "Where boundless creativity converges with unparalleled opportunity. Immerse yourself in a digital realm where visionary 3D artists showcase their extraordinary projects, each a testament to innovation and artistic brilliance. Navigate through a virtual world where talent knows no bounds.")
                          ]),
                        ),
                        const Spacer(
                          flex: 2,
                        ),
                        AnimatedBtn(
                          btnAnimationController: _btnAnimationController,
                          press: () {
                            _btnAnimationController.isActive = true;
                            Future.delayed(const Duration(milliseconds: 800), () {
                              setState(() {
                                isSignInDialogShown = true;
                              });
                              RequestDialog(context, onClosed: (_) {
                                setState(() {
                                  isSignInDialogShown = false;
                                });
                              });
                            });
                          },
                          label: 'Request Access',
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        AnimatedBtn(
                          btnAnimationController: _websiteAnimationController,
                          press: () async {
                            _websiteAnimationController.isActive = true;
                            await Future.delayed(
                                const Duration(milliseconds: 800));

                            const url = 'https://africxrjob.org/';

                            if (await canLaunchUrlString(url)) {
                              await launchUrlString(url);
                            } else {
                              throw 'Could not launch $url';
                            }
                          },
                          label: 'More infos',
                        ),
                        const Spacer(
                          flex: 2,
                        ),
                      ],
                    ),
                    phone: Column(
                      children: [
                        const Spacer(),
                        Image.asset('assets/Backgrounds/logo_metaverse.png',
                            width: 192, height: 192),
                        const SizedBox(
                          width: 340,
                          child: Column(children: [
                            Text(
                              "Welcome To TalentVerse",
                              style: TextStyle(
                                  fontSize: 40,
                                  fontFamily: "Poppins",
                                  height: 1.2),
                            ),
                            SizedBox(
                              height: 16,
                            ),
                            Text(
                                "Where boundless creativity converges with unparalleled opportunity. Immerse yourself in a digital realm where visionary 3D artists showcase their extraordinary projects, each a testament to innovation and artistic brilliance. Navigate through a virtual world where talent knows no bounds.")
                          ]),
                        ),
                        const Spacer(
                          flex: 2,
                        ),
                        AnimatedBtn(
                          btnAnimationController: _btnAnimationController,
                          press: () {
                            _btnAnimationController.isActive = true;
                            Future.delayed(const Duration(milliseconds: 800), () {
                              setState(() {
                                isSignInDialogShown = true;
                              });
                              RequestDialog(context, onClosed: (_) {
                                setState(() {
                                  isSignInDialogShown = false;
                                });
                              });
                            });
                          },
                          label: 'Request Access',
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        AnimatedBtn(
                          btnAnimationController: _websiteAnimationController,
                          press: () async {
                            _websiteAnimationController.isActive = true;
                            await Future.delayed(
                                const Duration(milliseconds: 800));

                            const url = 'https://africxrjob.org/';

                            if (await canLaunchUrlString(url)) {
                              await launchUrlString(url);
                            } else {
                              throw 'Could not launch $url';
                            }
                          },
                          label: 'More infos',
                        ),
                        const Spacer(
                          flex: 2,
                        ),
                      ],
                    ),
                    tablet: Column(
                      children: [
                        const Spacer(),
                        Image.asset('assets/Backgrounds/logo_metaverse.png',
                            width: 192, height: 192),
                        const SizedBox(
                          width: 340,
                          child: Column(children: [
                            Text(
                              "Welcome To TalentVerse",
                              style: TextStyle(
                                  fontSize: 60,
                                  fontFamily: "Poppins",
                                  height: 1.2),
                            ),
                            SizedBox(
                              height: 16,
                            ),
                            Text(
                                "Where boundless creativity converges with unparalleled opportunity. Immerse yourself in a digital realm where visionary 3D artists showcase their extraordinary projects, each a testament to innovation and artistic brilliance. Navigate through a virtual world where talent knows no bounds.")
                          ]),
                        ),
                        const Spacer(
                          flex: 2,
                        ),
                        AnimatedBtn(
                          btnAnimationController: _btnAnimationController,
                          press: () {
                            _btnAnimationController.isActive = true;
                            Future.delayed(const Duration(milliseconds: 800), () {
                              setState(() {
                                isSignInDialogShown = true;
                              });
                              RequestDialog(context, onClosed: (_) {
                                setState(() {
                                  isSignInDialogShown = false;
                                });
                              });
                            });
                          },
                          label: 'Request Access',
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        AnimatedBtn(
                          btnAnimationController: _websiteAnimationController,
                          press: () async {
                            _websiteAnimationController.isActive = true;
                            await Future.delayed(
                                const Duration(milliseconds: 800));

                            const url = 'https://africxrjob.org/';

                            if (await canLaunchUrlString(url)) {
                              await launchUrlString(url);
                            } else {
                              throw 'Could not launch $url';
                            }
                          },
                          label: 'More infos',
                        ),
                        const Spacer(
                          flex: 2,
                        ),
                      ],
                    ),
                    largeTablet: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 50),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Column(
                                  children: [
                                    const Padding(
                                      padding: EdgeInsets.symmetric(vertical: 60.0),
                                    ),
                                    Image.asset('assets/Backgrounds/logo_metaverse.png',
                                        width: 192, height: 192),
                                    const SizedBox(
                                      width: 500,
                                      child: Column(children: [
                                        Wrap(
                                          children: [
                                            Text(
                                              "Welcome To TalentVerse",
                                              style: TextStyle(
                                                  fontSize: 60,
                                                  fontFamily: "Poppins",
                                                  height: 1.2),
                                            ),
                                            SizedBox(
                                              height: 16,
                                            ),
                                            Text(
                                                "Where boundless creativity converges with unparalleled opportunity. Immerse yourself in a digital realm where visionary 3D artists showcase their extraordinary projects, each a testament to innovation and artistic brilliance. Navigate through a virtual world where talent knows no bounds."),
                                          ],
                                        )
                                      ]),
                                    ),
                                    const SizedBox(
                                      height: 100,
                                    ),
                                    AnimatedBtn(
                                      btnAnimationController: _websiteAnimationController,
                                      press: () async {
                                        _websiteAnimationController.isActive = true;
                                        await Future.delayed(
                                            const Duration(milliseconds: 800));

                                        const url = 'https://africxrjob.org/';

                                        if (await canLaunchUrlString(url)) {
                                          await launchUrlString(url);
                                        } else {
                                          throw 'Could not launch $url';
                                        }
                                      },
                                      label: 'More infos',
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 200,),
                                const RequestPage()
                              ],
                            ),
                            const SizedBox(height: 50),
                            Row(
                              children: [
                                Image.asset('assets/Backgrounds/LOGO-netinfo_blanc.png', width: 350, height: 150),
                                const Spacer(),
                                Image.asset('assets/Backgrounds/LOGO-DALL-white.png', width: 150, height: 150),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                    computer: SingleChildScrollView(
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 50, left: 150, right: 150),
                            child: Row(
                              children: [
                                Column(
                                  children: [
                                    Image.asset('assets/Backgrounds/logo_metaverse.png', width: 192, height: 192),
                                    const SizedBox(
                                      width: 500,
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            "Welcome To TalentVerse",
                                            style: TextStyle(
                                                fontSize: 60,
                                                fontFamily: "Poppins",
                                                height: 1.2),
                                          ),
                                          SizedBox(
                                            height: 16,
                                          ),
                                          Text(
                                              "Where boundless creativity converges with unparalleled opportunity. Immerse yourself in a digital realm where visionary 3D artists showcase their extraordinary projects, each a testament to innovation and artistic brilliance. Navigate through a virtual world where talent knows no bounds."),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 100,
                                    ),
                                    AnimatedBtn(
                                      btnAnimationController: _websiteAnimationController,
                                      press: () async {
                                        _websiteAnimationController.isActive = true;
                                        await Future.delayed(
                                            const Duration(milliseconds: 800));

                                        const url = 'https://africxrjob.org/';

                                        if (await canLaunchUrlString(url)) {
                                          await launchUrlString(url);
                                        } else {
                                          throw 'Could not launch $url';
                                        }
                                      },
                                      label: 'More infos',
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 200,),
                                const RequestPage()
                              ],
                            ),
                          ),
                          const SizedBox(height: 50),
                          Row(
                            children: [
                              Image.asset('assets/Backgrounds/LOGO-netinfo_blanc.png', width: 350, height: 150),
                              const Spacer(),
                              Image.asset('assets/Backgrounds/LOGO-DALL-white.png', width: 150, height: 150),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
