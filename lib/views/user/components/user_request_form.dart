import 'package:Netinfo_Metaverse/views/user/components/sessions_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import '../../../../../constants.dart';
import '../../../controllers/user_controller.dart';

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

  String role = 'Entrepreneur';
  TextEditingController epicGamesId = TextEditingController();
  TextEditingController name = TextEditingController();
  TextEditingController email = TextEditingController();
  bool canAccess = false;
  bool isAuthorized = false;

  StateMachineController getRiveController(Artboard artboard) {
    StateMachineController? controller =
        StateMachineController.fromArtboard(artboard, "State Machine 1");
    artboard.addController(controller!);
    return controller;
  }

  Future<void> checkUserAndSendRequest(String epicGamesId) async {
    try {
      final userExists = await checkUser(epicGamesId);
      if (_formKey.currentState!.validate()) {
        Future.delayed(const Duration(seconds: 2), () async {
          if (userExists) {
            print('User exists.');
            final userData = await getUserData(epicGamesId);
            if (userData != null && userData['canAccess'] == true && userData['isAuthorized'] == true) {
              print('You are authorized and have access');
              showDialog<void>(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Welcome back!'),
                    content: const SingleChildScrollView(
                      child: ListBody(
                        children: <Widget>[
                          Text(
                              'Your request to join a session has been accepted. Enjoy the experience'),
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
                },
              );
            }
            else if (userData != null && userData['isAuthorized'] == true) {

              // User is authorized
              print('You are authorized.');
              showDialog<void>(
                context: context,
                builder: (BuildContext context) {
                  return SessionsList(role: userData['role'], userId: userData['epicGamesId']);
                },
              );
            }
            else {
              // User is not authorized
              print('User is not authorized.');
              showDialog<void>(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('you are not authorized.'),
                    content: const SingleChildScrollView(
                      child: ListBody(
                        children: <Widget>[
                          Text(
                              'You already have a request sent with this EpicGames ID. Please wait for the admin approval.'),
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
                },
              );
            }
          }
          else {
            SendResquestData(context);
            print('User does not exist.');
          }
        });
      }
    } catch (e) {
      print('Failed to check user existence: $e');
    }
  }

  void SendResquestData(BuildContext context) {
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
          createUser(epicGamesId.text, name.text, email.text, canAccess, isAuthorized, role);
          epicGamesId.text = "";
          name.text = "";
          email.text = "";
          role = "Entrepreneur";
          canAccess = false;
          isAuthorized = false;
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
                          'Your request has been succesfully registered. Please monitor your email inbox for additional information.'),
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
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
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
                        labelText: 'NAME*',
                        hintText: 'name',
                        prefixIcon: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                          child: Icon(Icons.account_circle),
                        ),
                        errorStyle: TextStyle(
                          color: chartColor2,
                        ),
                      ),
                    ),
                  ),
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
                        labelText: 'EMAIL*',
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
                    padding: const EdgeInsets.only(top: 8.0, bottom: 16),
                    child: TextFormField(
                      controller: epicGamesId,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Please enter an ID";
                        } else if (value.length < 8) {
                          return "Please enter a valid ID";
                        }
                        return null;
                      },
                      decoration: const InputDecoration(
                        labelText: 'EPIC GAMES ID*',
                        hintText: 'id',
                        prefixIcon: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                          child: Icon(Icons.computer),
                        ),
                        errorStyle: TextStyle(
                          color: chartColor2,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, bottom: 16),
                    child: DropdownButtonFormField<String>(
                      value: role,
                      onChanged: (String? newValue) {
                        setState(() {
                          role = newValue!;
                        });
                      },
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.all(27),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            width: 3,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            width: 3,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        hintText: 'Select an option',
                      ),
                      items: <String>['Entrepreneur', 'Talent', 'Visitor']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, bottom: 24),
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


