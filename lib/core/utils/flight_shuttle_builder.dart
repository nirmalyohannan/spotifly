import 'package:flutter/material.dart';

class FlightShuttleBuilders {
  static Widget fadeTransition(
    BuildContext flightContext,
    Animation<double> animation,
    HeroFlightDirection flightDirection,
    BuildContext fromHeroContext,
    BuildContext toHeroContext,
  ) {
    return DefaultTextStyle(
      style: DefaultTextStyle.of(toHeroContext).style,
      child: Stack(
        children: [
          FadeTransition(
            opacity: Tween<double>(begin: 1.0, end: 0.0).animate(animation),
            child: fromHeroContext.widget,
          ),

          FadeTransition(
            opacity: Tween<double>(begin: 0.0, end: 1.0).animate(animation),
            child: toHeroContext.widget,
          ),
        ],
      ),
    );
  }

  static Widget scaleTransition(
    BuildContext flightContext,
    Animation<double> animation,
    HeroFlightDirection flightDirection,
    BuildContext fromHeroContext,
    BuildContext toHeroContext,
  ) {
    return DefaultTextStyle(
      style: DefaultTextStyle.of(toHeroContext).style,
      child: ScaleTransition(
        scale: animation.drive(
          Tween<double>(
            begin: 0,
            end: 1.0,
          ).chain(CurveTween(curve: Curves.fastOutSlowIn)),
        ),
        child: toHeroContext.widget,
      ),
    );
  }

  static Widget rotationTransition(
    BuildContext flightContext,
    Animation<double> animation,
    HeroFlightDirection flightDirection,
    BuildContext fromHeroContext,
    BuildContext toHeroContext,
  ) {
    return DefaultTextStyle(
      style: DefaultTextStyle.of(toHeroContext).style,
      child: RotationTransition(turns: animation, child: toHeroContext.widget),
    );
  }
}
