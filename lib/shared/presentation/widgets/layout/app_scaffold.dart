import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:template/core/utils/colors.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    this.appBar,
    required this.body,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.backgroundColor,
    this.useGradient = false,
    this.resizeToAvoidBottomInset = true,
    this.padding,
  });

  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final Color? backgroundColor;
  final bool useGradient;
  final bool resizeToAvoidBottomInset;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: backgroundColor ?? AppColor.background,
        appBar: appBar,
        bottomNavigationBar: bottomNavigationBar,
        floatingActionButton: floatingActionButton,
        resizeToAvoidBottomInset: resizeToAvoidBottomInset,
        body: useGradient
            ? Container(
                decoration: const BoxDecoration(
                  gradient: AppColor.backgroundGradient,
                ),
                child: _buildBody(),
              )
            : _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (padding != null) {
      return Padding(padding: padding!, child: body);
    }
    return body;
  }
}

class AppSliverScaffold extends StatelessWidget {
  const AppSliverScaffold({
    super.key,
    required this.slivers,
    this.backgroundColor,
  });

  final List<Widget> slivers;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: backgroundColor ?? AppColor.background,
        body: CustomScrollView(slivers: slivers),
      ),
    );
  }
}
