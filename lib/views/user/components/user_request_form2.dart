import 'package:Netinfo_Metaverse/controllers/mailer_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import '../../../../../constants.dart';

class RequestForm2 extends StatefulWidget {
  const RequestForm2({
    super.key,
  });

  @override
  State<RequestForm2> createState() => _RequestForm2State();
}

class _RequestForm2State extends State<RequestForm2> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool isShowLoading = false;
  bool isShowConfetti = false;

  late SMITrigger check;
  late SMITrigger error;
  late SMITrigger reset;
  late SMITrigger confetti;

  TextEditingController email = TextEditingController();
  bool _isButtonDisabled = false;

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
      alignment: Alignment.center,
      children: [
        IgnorePointer(
          ignoring: isShowLoading,
          child: Opacity(
            opacity: isShowLoading ? 0.5 : 1.0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: email,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Please enter an email address";
                        } else if (!RegExp(
                            r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$')
                            .hasMatch(value)) {
                          return "Please enter a valid email address";
                        }
                        return null;
                      },
                      decoration: const InputDecoration(
                        labelText: 'Email*',
                        hintText: 'email@example.com',
                        prefixIcon: Icon(Icons.email_outlined),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: _isButtonDisabled
                            ? null
                            : checkEmailAndSendRequest,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: chartColor1,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        icon: const Icon(
                          CupertinoIcons.arrow_right,
                          color: backgroundColorDark,
                        ),
                        label: const Text(
                          "Request",
                          style: TextStyle(color: backgroundColorDark),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        /// ✅ Loading Animation
        Visibility(
          visible: isShowLoading,
          child: CustomPositioned(
            child: RiveAnimation.asset(
              "assets/RiveAssets/check.riv",
              onInit: (artboard) {
                final controller = getRiveController(artboard);
                check = controller.findSMI("Check") as SMITrigger;
                error = controller.findSMI("Error") as SMITrigger;
                reset = controller.findSMI("Reset") as SMITrigger;
              },
            ),
          ),
        ),

        /// ✅ Confetti Animation
        Visibility(
          visible: isShowConfetti,
          child: CustomPositioned(
            child: Transform.scale(
              scale: 6,
              child: RiveAnimation.asset(
                "assets/RiveAssets/confetti.riv",
                onInit: (artboard) {
                  final controller = getRiveController(artboard);
                  confetti = controller.findSMI("Trigger explosion") as SMITrigger;
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

}
