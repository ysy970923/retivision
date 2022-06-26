import 'package:flutter/material.dart';

abstract class PlatformWidget extends StatefulWidget {
  Widget buildMaterialWidget(BuildContext context);
  @override
  _PlatformWidgetState createState() => _PlatformWidgetState();
}

class _PlatformWidgetState extends State<PlatformWidget> {
  @override
  Widget build(BuildContext context) {
    return widget.buildMaterialWidget(context);
  }
}
