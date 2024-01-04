import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import '../../components/animated_btn.dart';
import '../../constants.dart';
import '../../controllers/mailer_api.dart';
import '../../controllers/user_controller.dart';
import 'components/sessions_list.dart';

class GetAccess extends StatefulWidget {
  const GetAccess({super.key});

  @override
  State<GetAccess> createState() => _GetAccessState();
}

class _GetAccessState extends State<GetAccess> {
  bool isSignInDialogShown = false;


  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool isShowLoading = false;
  bool isShowConfetti = false;

  late SMITrigger check;
  late SMITrigger error;
  late SMITrigger reset;
  late SMITrigger confetti;

  TextEditingController epicGamesId = TextEditingController();

  StateMachineController getRiveController(Artboard artboard) {
    StateMachineController? controller =
        StateMachineController.fromArtboard(artboard, "State Machine 1");
    artboard.addController(controller!);
    return controller;
  }

  Future<void> checkUserAndSendRequest(String epicGamesId) async {
    try {
      final userExists = await checkUser(epicGamesId);
      if (_formKey.currentState!.validate() && userExists) {
        print('User exists.');
        final userData = await getUserData(epicGamesId);
        if (userData != null && userData['canAccess'] == true && userData['isAuthorized'] == true) {
          print('You are authorized and have access');
          showDialog<void>(
            context: context,
            builder: (BuildContext context) {
              return WelcomeBackDialog(room: userData['room']);
            },
          );
        }
        else {
          if (userData != null && userData['isAuthorized'] == true) {
            // User is authorized
            print('You are authorized.');
            showDialog<void>(
              context: context,
              builder: (BuildContext context) {
                return SessionsList(role: userData['role'], userId: userData['_id'], name: userData['name'], room: userData['room']);
              },
            );
          }
          else {
            // User is not authorized
            print('User is not authorized.');
            showDialog<void>(
              context: context,
              builder: (BuildContext context) {
                return NotAuthorizedDialog();
              },
            );
          }
        }
      }
      else {
        print('User does not exist.');
        showDialog<void>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Ooops..'),
              content: Text('User is not registered'),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('Close')
                )
              ],
            );
          },
        );
      }
    } catch (e) {
      print('Failed to check user existence: $e');
    }
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
                        Image.asset('assets/Backgrounds/logo_metaverse.png', width: 300, height: 300,),
                        const SizedBox(
                          child: Column(
                            children: [
                              Text(
                                "Welcome back",
                                style: TextStyle(
                                    fontSize: 60,
                                    fontFamily: "Poppins",
                                    height: 1.2),
                              ),
                              SizedBox(
                                height: 16,
                              ),
                              Text(
                                  "Please enter your EpicGames ID to search / join a live session in the metaverse.")
                            ]
                          ),
                        ),
                        const SizedBox(
                          height: 50,
                        ),
                        Stack(
                          children: [
                            Form(
                                key: _formKey,
                                child: SingleChildScrollView(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      const Text(
                                        "Epic Games ID*",
                                        style: TextStyle(color: Colors.black54),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      SizedBox(
                                        width: 500,
                                        child: TextFormField(
                                          controller: epicGamesId,
                                          validator: (value) {
                                            if (value!.isEmpty) {
                                              return "Required";
                                            }
                                            return null;
                                          },
                                          decoration: const InputDecoration(
                                            prefixIcon: Padding(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 8.0),
                                              child: Icon(Icons.computer),
                                            ),
                                            errorStyle: TextStyle(
                                              color: chartColor2,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      SizedBox(
                                        width: 500,
                                        child: ElevatedButton.icon(
                                            onPressed: () {
                                             checkUserAndSendRequest(epicGamesId.text);
                                            },
                                            style: ElevatedButton.styleFrom(
                                                backgroundColor: chartColor1,
                                                minimumSize: const Size(double.infinity, 56),
                                                shape: const RoundedRectangleBorder(
                                                    borderRadius:
                                                    BorderRadius.all(Radius.circular(10)))),
                                            icon: const Icon(
                                              CupertinoIcons.arrow_right,
                                              color: backgroundColorDark,
                                            ),
                                            label: const Text("Check",
                                                style: TextStyle(color: backgroundColorDark))),
                                      ),
                                    ],
                                  ),
                                )),
                            isShowLoading
                                ? CustomPositioned(
                                    child: RiveAnimation.asset(
                                    "assets/RiveAssets/check.riv",
                                    onInit: (artboard) {
                                      StateMachineController controller =
                                          getRiveController(artboard);
                                      check = controller.findSMI("Check")
                                          as SMITrigger;
                                      error = controller.findSMI("Error")
                                          as SMITrigger;
                                      reset = controller.findSMI("Reset")
                                          as SMITrigger;
                                    },
                                  ))
                                : const SizedBox(),
                            isShowConfetti
                                ? CustomPositioned(
                                    child: Transform.scale(
                                    scale: 6,
                                    child: RiveAnimation.asset(
                                      "assets/RiveAssets/confetti.riv",
                                      onInit: (artboard) {
                                        StateMachineController controller =
                                            getRiveController(artboard);
                                        confetti = controller.findSMI(
                                            "Trigger explosion") as SMITrigger;
                                      },
                                    ),
                                  ))
                                : const SizedBox()
                          ],
                        ),
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


class WelcomeBackDialog extends StatelessWidget {
  final String room;

  WelcomeBackDialog({Key? key, required this.room}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Welcome back!'),
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            const Text(
              'Your request to join a session has been accepted. Enjoy the experience',
            ),
            Text(
              'Your room number is : $room',
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('OK'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}

class NotAuthorizedDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('You are not authorized.'),
      content: const SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            Text(
              'You already have a request sent with this EpicGames ID. Please wait for the admin approval.',
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('OK'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
