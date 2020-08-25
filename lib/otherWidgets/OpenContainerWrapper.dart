import 'package:Vertretung/provider/providerData.dart';
import 'package:animations/animations.dart';
import "package:flutter/material.dart";
import 'package:provider/provider.dart';

class OpenContainerWrapper extends StatelessWidget {
  final Function openBuilder;
  final Function closedBuilder;
  final Function onClosed;
  final bool tappable;

  const OpenContainerWrapper({
    Key key,
    this.openBuilder(
      BuildContext context,
      void Function({Object returnValue}) action,
    ),
    this.closedBuilder(BuildContext context, Function action),
    this.onClosed,
    this.tappable = true,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return OpenContainer(
        tappable: tappable,
        closedColor:
            Provider.of<ProviderData>(context).getUsedTheme() == Brightness.dark
                ? Colors.grey[900]
                : Colors.white,
        closedElevation: 0,
        transitionType: ContainerTransitionType.fade,
        onClosed: onClosed,
        openBuilder: openBuilder,
        closedBuilder: closedBuilder);
  }
}