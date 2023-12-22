import 'package:Netinfo_Metaverse/constants.dart';
import 'package:flutter/material.dart';

import '../responsive_layout.dart';

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MyAppBar({super.key});


  @override
  // TODO: implement preferredSize
  Size get preferredSize => throw UnimplementedError();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Row(
        children: [
          if (ResponsiveLayout.isComputer(context))
            Container(
              margin: const EdgeInsets.all(10.0),
              height: double.infinity,
              decoration: const BoxDecoration(boxShadow: [
                BoxShadow(
                  color: Colors.black45,
                  offset: Offset(0, 0),
                  spreadRadius: 1,
                  blurRadius: 10,
                )
              ], shape: BoxShape.circle),
            )
          else
            IconButton(
              color: Colors.black,
              iconSize: 30,
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
              icon: const Icon(Icons.menu),
            ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(10.0 * 2),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  "Dashboard",
                  style: TextStyle(
                    color: 0 == 0 ? Colors.black : Colors.black54,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.all(10.0 / 2),
                  width: 60,
                  height: 2,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        chartColor2,
                        chartColor1,
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
