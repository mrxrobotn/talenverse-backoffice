import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rive/rive.dart';
import '../../../constants.dart';
import '../../../controllers/admin_controller.dart';
import 'admin_provider.dart';


class AdminLoginForm extends StatefulWidget {
  const AdminLoginForm({super.key});

  @override
  _AdminLoginFormState createState() => _AdminLoginFormState();
}

class _AdminLoginFormState extends State<AdminLoginForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool isShowLoading = false;
  bool isShowConfetti = false;

  late SMITrigger check;
  late SMITrigger error;
  late SMITrigger reset;
  late SMITrigger confetti;

  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();

  StateMachineController getRiveController(Artboard artboard) {
    StateMachineController? controller =
    StateMachineController.fromArtboard(artboard, "State Machine 1");
    artboard.addController(controller!);
    return controller;
  }

  void CheckLoginStatus(BuildContext context) async {
    setState(() {
      isShowLoading = true;
      isShowConfetti = true;
    });
    Future.delayed(const Duration(seconds: 1), () async {
      if (_formKey.currentState!.validate()) {
        validateCredentials(email.text, password.text).then((result) {
          print(result ? "Credentials are valid" : "Credentials are not valid");
          if (result == true) {
            // show success
            check.fire();
            Future.delayed(const Duration(seconds: 2), () {
              setState(() {
                isShowLoading = false;
              });
              confetti.fire();
              Provider.of<AdminProvider>(context, listen: false).login(context);
            });
          }
          else {
              error.fire();
              Future.delayed(const Duration(seconds: 2), () {
                setState(() {
                  isShowLoading = false;
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Error'),
                        content: const Text('Invalid credentials'),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                });
              });
            }
        });
      }
      else {
        error.fire();
        Future.delayed(const Duration(seconds: 2), () {
          setState(() {
            isShowLoading = false;
          });
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "EMAIL*",
                    style: TextStyle(color: Colors.black54),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, bottom: 16),
                    child: TextFormField(
                      controller: email,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Please enter the admin email";
                        } else if (!value.contains('@')) {
                          return "Please enter a valid email address";
                        }
                        return null;
                      },
                      decoration: const InputDecoration(
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
                  const Text(
                    "PASSWORD*",
                    style: TextStyle(color: Colors.black54),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, bottom: 16),
                    child: TextFormField(
                      controller: password,
                      obscureText: true,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Please enter the admin password";
                        } else if (value.length < 8) {
                          return "Password should be 8 characters or more";
                        }
                        return null;
                      },
                      decoration: const InputDecoration(
                        prefixIcon: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                          child: Icon(Icons.password_rounded),
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
                        onPressed: () async {
                          CheckLoginStatus(context);
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: chartColor1,
                            minimumSize: const Size(double.infinity, 56),
                            shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(Radius.circular(10)))),
                        icon: const Icon(
                          CupertinoIcons.arrow_right,
                          color: backgroundColorDark,
                        ),
                        label: const Text("Login", style: TextStyle(color: backgroundColorDark))),
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
