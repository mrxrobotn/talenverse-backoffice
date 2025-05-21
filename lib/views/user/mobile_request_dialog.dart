import 'package:Netinfo_Metaverse/controllers/mailer_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import '../../constants.dart';

Future<Object?> RequestDialog(BuildContext context,
    {required ValueChanged onClosed}) {
  return showGeneralDialog(
      barrierDismissible: true,
      barrierLabel: "Request",
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
              height: 350,
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
                    SingleChildScrollView(
                      child: Column(children: [
                        Text(
                          "Request Access",
                          style: TextStyle(fontSize: 34, fontFamily: "Poppins"),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Text(
                            "Request access to enter and join the experience in the TalentVerse.",
                            textAlign: TextAlign.center,
                          ),
                        ),
                        RequestForm()
                      ]),
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: -62,
                      child: CircleAvatar(
                        radius: 16,
                        backgroundColor: chartColor2,
                        child: Icon(Icons.close, color: Colors.black),
                      ),
                    )
                  ],
                ),
              ),
            ),
          )).then(onClosed);
}

class RequestForm extends StatefulWidget {
  const RequestForm({
    super.key,
  });

  @override
  State<RequestForm> createState() => _RequestFormState();
}

class _RequestFormState extends State<RequestForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool isShowLoading = false;
  bool isShowConfetti = false;

  late SMITrigger check;
  late SMITrigger error;
  late SMITrigger reset;
  late SMITrigger confetti;

  TextEditingController email = TextEditingController();

  StateMachineController getRiveController(Artboard artboard) {
    StateMachineController? controller =
        StateMachineController.fromArtboard(artboard, "State Machine 1");
    artboard.addController(controller!);
    return controller;
  }

  Future<void> checkEmailAndSendRequest() async {
    try {
      setState(() {
        isShowLoading = true;
        isShowConfetti = true;
      });
      sendEmail(
          toEmail: email.text,
          toName: "TalentVerse",
          subject: "TalentVerse Platform: Download Link",
          htmlContent: htmlFirstContent
      );
      Future.delayed(const Duration(seconds: 1), () {
        if (_formKey.currentState!.validate()) {
          check.fire();
          Future.delayed(const Duration(seconds: 2), () {
            setState(() {
              isShowLoading = false;
            });
            email.text = "";
            showDialog<void>(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Thank You'),
                  content: const SingleChildScrollView(
                    child: ListBody(
                      children: <Widget>[
                        Text(
                            'Your request has been successfully sent. Please monitor your email inbox for the download link.'),
                      ],
                    ),
                  ),
                  actions: <Widget>[
                    TextButton(
                      child: const Text('OK'),
                      onPressed: () {
                        Navigator.of(context).pop();
                        confetti.fire();
                      },
                    ),
                  ],
                );
              },
            );
          });
        } else {
          error.fire();
          Future.delayed(const Duration(seconds: 2), () {
            setState(() {
              isShowLoading = false;
            });
          });
        }
      });
    } catch (e) {
      print('Failed to check user existence: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, bottom: 16),
                    child: TextFormField(
                      controller: email,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Please enter an email address";
                        } else if (!value.contains('@')) {
                          return "Please enter a valid email address";
                        }
                        return null;
                      },
                      decoration: const InputDecoration(
                        labelText: 'Email*',
                        hintText: 'email',
                        prefixIcon: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                          child: Icon(Icons.email_rounded),
                        ),
                        errorStyle: TextStyle(
                          color: chartColor2,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, bottom: 24),
                    child: ElevatedButton.icon(
                        onPressed: () {
                          checkEmailAndSendRequest();
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
                        label: const Text("Request",
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
                  check = controller.findSMI("Check") as SMITrigger;
                  error = controller.findSMI("Error") as SMITrigger;
                  reset = controller.findSMI("Reset") as SMITrigger;
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
                    confetti =
                        controller.findSMI("Trigger explosion") as SMITrigger;
                  },
                ),
              ))
            : const SizedBox()
      ],
    );
  }
}
