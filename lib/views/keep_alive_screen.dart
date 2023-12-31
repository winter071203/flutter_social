import 'package:flutter/material.dart';

class KeepAlivePage extends StatefulWidget {
  const KeepAlivePage({Key? key, required this.child}) : super(key: key);
  final Widget child;

  @override
  State<KeepAlivePage> createState() => _KeepAlivePageState();
}

class _KeepAlivePageState extends State<KeepAlivePage>
    with AutomaticKeepAliveClientMixin<KeepAlivePage> {
  @override
  Widget build(BuildContext context) {
    /// Dont't forget this
    super.build(context);
    return widget.child;
  }

  @override
  bool get wantKeepAlive => true;
}
