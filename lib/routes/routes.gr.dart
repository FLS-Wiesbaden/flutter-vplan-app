// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i6;
import 'package:de_fls_wiesbaden_vplan/ui/aboutui.dart' as _i1;
import 'package:de_fls_wiesbaden_vplan/ui/authscanui.dart' as _i2;
import 'package:de_fls_wiesbaden_vplan/ui/authui.dart' as _i3;
import 'package:de_fls_wiesbaden_vplan/ui/flsvplanmainui.dart' as _i4;
import 'package:de_fls_wiesbaden_vplan/ui/helper/types.dart' as _i8;
import 'package:de_fls_wiesbaden_vplan/ui/wizard.dart' as _i5;
import 'package:flutter/material.dart' as _i7;

abstract class $AppRouter extends _i6.RootStackRouter {
  $AppRouter({super.navigatorKey});

  @override
  final Map<String, _i6.PageFactory> pagesMap = {
    AboutUiRoute.name: (routeData) {
      return _i6.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i1.AboutUi(),
      );
    },
    AuthScanUiRoute.name: (routeData) {
      final args = routeData.argsAs<AuthScanUiRouteArgs>(
          orElse: () => const AuthScanUiRouteArgs());
      return _i6.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i2.AuthScanUi(
          key: args.key,
          onScanCompleted: args.onScanCompleted,
        ),
      );
    },
    AuthUiRoute.name: (routeData) {
      final args = routeData.argsAs<AuthUiRouteArgs>(
          orElse: () => const AuthUiRouteArgs());
      return _i6.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i3.AuthUi(
          key: args.key,
          errorMessage: args.errorMessage,
        ),
      );
    },
    FlsVplanMainUiRoute.name: (routeData) {
      return _i6.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i4.FlsVplanMainUi(),
      );
    },
    WizardRoute.name: (routeData) {
      return _i6.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i5.Wizard(),
      );
    },
  };
}

/// generated route for
/// [_i1.AboutUi]
class AboutUiRoute extends _i6.PageRouteInfo<void> {
  const AboutUiRoute({List<_i6.PageRouteInfo>? children})
      : super(
          AboutUiRoute.name,
          initialChildren: children,
        );

  static const String name = 'AboutUiRoute';

  static const _i6.PageInfo<void> page = _i6.PageInfo<void>(name);
}

/// generated route for
/// [_i2.AuthScanUi]
class AuthScanUiRoute extends _i6.PageRouteInfo<AuthScanUiRouteArgs> {
  AuthScanUiRoute({
    _i7.Key? key,
    void Function(_i8.AuthLoginResult)? onScanCompleted,
    List<_i6.PageRouteInfo>? children,
  }) : super(
          AuthScanUiRoute.name,
          args: AuthScanUiRouteArgs(
            key: key,
            onScanCompleted: onScanCompleted,
          ),
          initialChildren: children,
        );

  static const String name = 'AuthScanUiRoute';

  static const _i6.PageInfo<AuthScanUiRouteArgs> page =
      _i6.PageInfo<AuthScanUiRouteArgs>(name);
}

class AuthScanUiRouteArgs {
  const AuthScanUiRouteArgs({
    this.key,
    this.onScanCompleted,
  });

  final _i7.Key? key;

  final void Function(_i8.AuthLoginResult)? onScanCompleted;

  @override
  String toString() {
    return 'AuthScanUiRouteArgs{key: $key, onScanCompleted: $onScanCompleted}';
  }
}

/// generated route for
/// [_i3.AuthUi]
class AuthUiRoute extends _i6.PageRouteInfo<AuthUiRouteArgs> {
  AuthUiRoute({
    _i7.Key? key,
    String? errorMessage,
    List<_i6.PageRouteInfo>? children,
  }) : super(
          AuthUiRoute.name,
          args: AuthUiRouteArgs(
            key: key,
            errorMessage: errorMessage,
          ),
          initialChildren: children,
        );

  static const String name = 'AuthUiRoute';

  static const _i6.PageInfo<AuthUiRouteArgs> page =
      _i6.PageInfo<AuthUiRouteArgs>(name);
}

class AuthUiRouteArgs {
  const AuthUiRouteArgs({
    this.key,
    this.errorMessage,
  });

  final _i7.Key? key;

  final String? errorMessage;

  @override
  String toString() {
    return 'AuthUiRouteArgs{key: $key, errorMessage: $errorMessage}';
  }
}

/// generated route for
/// [_i4.FlsVplanMainUi]
class FlsVplanMainUiRoute extends _i6.PageRouteInfo<void> {
  const FlsVplanMainUiRoute({List<_i6.PageRouteInfo>? children})
      : super(
          FlsVplanMainUiRoute.name,
          initialChildren: children,
        );

  static const String name = 'FlsVplanMainUiRoute';

  static const _i6.PageInfo<void> page = _i6.PageInfo<void>(name);
}

/// generated route for
/// [_i5.Wizard]
class WizardRoute extends _i6.PageRouteInfo<void> {
  const WizardRoute({List<_i6.PageRouteInfo>? children})
      : super(
          WizardRoute.name,
          initialChildren: children,
        );

  static const String name = 'WizardRoute';

  static const _i6.PageInfo<void> page = _i6.PageInfo<void>(name);
}
