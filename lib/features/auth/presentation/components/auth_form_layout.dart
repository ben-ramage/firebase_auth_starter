import 'package:flutter/material.dart';
import 'package:firebase_auth_starter/responsive/constrained_scaffold.dart';

class AuthFormLayout extends StatelessWidget {
  final List<Widget> children;
  final PreferredSizeWidget? appBar;
  final Widget? bottomContent;

  const AuthFormLayout({
    super.key,
    required this.children,
    this.appBar,
    this.bottomContent,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedScaffold(
      resizeToAvoidBottomInset: true,
      appBar: appBar,
      body: SafeArea(
        top: appBar == null,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: (constraints.maxHeight - 40).clamp(
                    0.0,
                    double.infinity,
                  ),
                ),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      const SizedBox(height: 35),
                      Center(
                        child: Image.asset(
                          'images/avataar_ben.png',
                          width: 350,
                        ),
                      ),
                      const SizedBox(height: 35),
                      ...children,
                      if (bottomContent != null) ...[
                        const Spacer(),
                        const SizedBox(height: 24),
                        bottomContent!,
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
