import 'package:flutter/material.dart';

/// Reusable scaffold widget with common ADHD-friendly styling
/// Provides consistent structure across all screens
class BaseScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final FloatingActionButton? floatingActionButton;
  final PreferredSizeWidget? appBar;
  final bool showAppBar;
  final Color? backgroundColor;
  final List<Widget>? actions;

  const BaseScaffold({
    Key? key,
    required this.title,
    required this.body,
    this.floatingActionButton,
    this.appBar,
    this.showAppBar = true,
    this.backgroundColor,
    this.actions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor ?? Theme.of(context).scaffoldBackgroundColor,
      appBar: showAppBar
          ? appBar ??
              AppBar(
                title: Text(title),
                elevation: 0,
                actions: actions,
              )
          : null,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: body,
          ),
        ),
      ),
      floatingActionButton: floatingActionButton,
    );
  }
}