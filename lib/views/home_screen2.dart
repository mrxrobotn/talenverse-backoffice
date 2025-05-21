import 'dart:ui';
import 'package:Netinfo_Metaverse/responsive_layout.dart';
import 'package:Netinfo_Metaverse/views/user/mobile_request_dialog.dart';
import 'package:Netinfo_Metaverse/views/user/request_screen2.dart';
import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../components/animated_btn.dart';

class HomeScreen2 extends StatefulWidget {
  const HomeScreen2({super.key});

  @override
  State<HomeScreen2> createState() => _HomeScreen2State();
}

class _HomeScreen2State extends State<HomeScreen2> {
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
                filter: ImageFilter.blur(sigmaX: 60, sigmaY: 20),
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
                    phone: Column(
                      children: [
                        const Spacer(),
                        Image.asset('assets/Backgrounds/logo_metaverse.png',
                            width: 192, height: 192),
                        const SizedBox(
                          width: 300,
                          child: Column(
                              children: [
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
                                    "Talent Verse is an innovative project that creates global virtual job opportunities for art students. "
                                        "Tailored to the needs of concept artists, animators, 3D artists, and other creative professionals, this project envisions a dynamic virtual environment, where students can connect with companies in an immersive and interactive manner. "
                                        "The project facilitates one-on-one interviews between companies and prospective students. "
                                        "This interactive element ensures meaningful engagements, allowing companies to assess the skills and potential of art students while providing students with direct insights into career opportunities. "
                                        "The overarching goal of Netinfo Metaverse is to make the evaluation of artists’ work open and accessible at all times."
                                ),
                              ]
                          ),
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
                          label: 'Download TalentVerse',
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
                          width: 300,
                          child: Column(
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
                                    "Talent Verse is an innovative project that creates global virtual job opportunities for art students. "
                                        "Tailored to the needs of concept artists, animators, 3D artists, and other creative professionals, this project envisions a dynamic virtual environment, where students can connect with companies in an immersive and interactive manner. "
                                        "The project facilitates one-on-one interviews between companies and prospective students. "
                                        "This interactive element ensures meaningful engagements, allowing companies to assess the skills and potential of art students while providing students with direct insights into career opportunities. "
                                        "The overarching goal of Netinfo Metaverse is to make the evaluation of artists’ work open and accessible at all times."
                                    ),
                                ]
                            ),
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
                    computer: SingleChildScrollView(
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 40, left: 150, right: 150),
                            child: Row(
                              children: [
                                Column(
                                  children: [
                                    Image.asset('assets/Backgrounds/logo_metaverse.png', width: 192, height: 192),
                                    const SizedBox(
                                      width: 600,
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
                                              "Talent Verse is an innovative project that creates global virtual job opportunities for art students. "
                                                  "Tailored to the needs of concept artists, animators, 3D artists, and other creative professionals, this project envisions a dynamic virtual environment, where students can connect with companies in an immersive and interactive manner. "
                                                  "The project facilitates one-on-one interviews between companies and prospective students. "
                                                  "This interactive element ensures meaningful engagements, allowing companies to assess the skills and potential of art students while providing students with direct insights into career opportunities. "
                                                  "The overarching goal of Netinfo Metaverse is to make the evaluation of artists’ work open and accessible at all times."
                                          ),
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
                                const RequestPage2()
                              ],
                            ),
                          ),
                          const SizedBox(height: 30),
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
