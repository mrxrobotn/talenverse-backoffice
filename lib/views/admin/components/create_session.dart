import 'package:Netinfo_Metaverse/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import '../../../controllers/session_controller.dart';

Future<Object?> CreateSession(BuildContext context, {required ValueChanged onClosed}) {
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
                        "New Session",
                        style: TextStyle(fontSize: 34, fontFamily: "Poppins"),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Text(
                          "Please fill this form with the right informations.",
                          textAlign: TextAlign.center,
                        ),
                      ),
                      NewSessionForm(),
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

class NewSessionForm extends StatefulWidget {
  const NewSessionForm({super.key});

  @override
  _NewSessionFormState createState() => _NewSessionFormState();
}

class _NewSessionFormState extends State<NewSessionForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool isShowLoading = false;
  bool isShowConfetti = false;

  late SMITrigger check;
  late SMITrigger error;
  late SMITrigger reset;
  late SMITrigger confetti;

  TextEditingController name = TextEditingController();
  TextEditingController date = TextEditingController();
  int slotTal = 12;
  int slotEnt = 8;
  bool isActive = false;
  List<Map<String, String>> users = [];

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
    Future.delayed(const Duration(seconds: 1), () {
      if (_formKey.currentState!.validate()) {
        // show success
        check.fire();
        Future.delayed(const Duration(seconds: 2), () {
          setState(() {
            isShowLoading = false;
          });
          createSession(name.text, date.text, slotTal, slotEnt, isActive, users);
          name.text = "";
          date.text = "";
          isActive = true;
          Navigator.of(context).pop();
          const snackBar = SnackBar(
            content:
            Text('Session created'),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
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
                    "Session Name*",
                    style: TextStyle(color: Colors.black54),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, bottom: 16),
                    child: TextFormField(
                      controller: name,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Please enter a name";
                        }
                        return null;
                      },
                      decoration: const InputDecoration(
                        labelText: 'name',
                        prefixIcon: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                          child: Icon(Icons.event),
                        ),
                        errorStyle: TextStyle(
                          color: chartColor2,
                        ),
                      ),
                    ),
                  ),
                  const Text(
                    "Session Date*",
                    style: TextStyle(color: Colors.black54),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, bottom: 16),
                    child: TextFormField(
                      controller: date,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Please enter a date";
                        }
                        return null;
                      },
                      decoration: const InputDecoration(
                        labelText: 'date',
                        prefixIcon: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                          child: Icon(Icons.calendar_month),
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
                          CupertinoIcons.add,
                          color: backgroundColorDark,
                        ),
                        label: const Text("ADD", style: TextStyle(color: backgroundColorDark))),
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
