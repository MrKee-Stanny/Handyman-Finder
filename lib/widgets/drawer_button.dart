import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DrawerButton extends StatefulWidget {
  GlobalKey<ScaffoldState> sKey;

  bool openNavigationDrawer;

  DrawerButton({required this.openNavigationDrawer, required this.sKey});

  @override
  State<DrawerButton> createState() => _DrawerButtonState();
}

class _DrawerButtonState extends State<DrawerButton> {
  @override
  Widget build(BuildContext context) {
    // Custom hamburger button for drawer
    return Positioned(
      top: 15,
      left: 15,
      child: GestureDetector(
        onTap: () {
          if (widget.openNavigationDrawer) {
            widget.sKey.currentState?.openDrawer();
          } else {
            // Restart/Refresh/Minimize an app programmatically, refresh app states
            SystemNavigator.pop();
          }
        },
        child: CircleAvatar(
          backgroundColor: Colors.black,
          child: Icon(
            widget.openNavigationDrawer ? Icons.menu : Icons.close,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
    );
  }
}
