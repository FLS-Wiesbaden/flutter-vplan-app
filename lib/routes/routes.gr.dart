// dart format width=80
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

/// generated route for
/// [_i1.AboutUi]
class AboutUiRoute extends _i6.PageRouteInfo<void> {
  const AboutUiRoute({List<_i6.PageRouteInfo>? children})
      : super(AboutUiRoute.name, initialChildren: children);

  static const String name = 'AboutUiRoute';

  static _i6.PageInfo page = _i6.PageInfo(
    name,
    builder: (data) {
      return const _i1.AboutUi();
    },
  );
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
          args: AuthScanUiRouteArgs(key: key, onScanCompleted: onScanCompleted),
          initialChildren: children,
        );

  static const String name = 'AuthScanUiRoute';

  static _i6.PageInfo page = _i6.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<AuthScanUiRouteArgs>(
        orElse: () => const AuthScanUiRouteArgs(),
      );
      return _i2.AuthScanUi(
        key: args.key,
        onScanCompleted: args.onScanCompleted,
      );
    },
  );
}

class AuthScanUiRouteArgs {
  const AuthScanUiRouteArgs({this.key, this.onScanCompleted});

  final _i7.Key? key;

  final void Function(_i8.AuthLoginResult)? onScanCompleted;

  @override
  String toString() {
    return 'AuthScanUiRouteArgs{key: $key, onScanCompleted: $onScanCompleted}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! AuthScanUiRouteArgs) return false;
    return key == other.key;
  }

  @override
  int get hashCode => key.hashCode;
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
          args: AuthUiRouteArgs(key: key, errorMessage: errorMessage),
          initialChildren: children,
        );

  static const String name = 'AuthUiRoute';

  static _i6.PageInfo page = _i6.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<AuthUiRouteArgs>(
        orElse: () => const AuthUiRouteArgs(),
      );
      return _i3.AuthUi(key: args.key, errorMessage: args.errorMessage);
    },
  );
}

class AuthUiRouteArgs {
  const AuthUiRouteArgs({this.key, this.errorMessage});

  final _i7.Key? key;

  final String? errorMessage;

  @override
  String toString() {
    return 'AuthUiRouteArgs{key: $key, errorMessage: $errorMessage}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! AuthUiRouteArgs) return false;
    return key == other.key && errorMessage == other.errorMessage;
  }

  @override
  int get hashCode => key.hashCode ^ errorMessage.hashCode;
}

/// generated route for
/// [_i4.FlsVplanMainUi]
class FlsVplanMainUiRoute extends _i6.PageRouteInfo<void> {
  const FlsVplanMainUiRoute({List<_i6.PageRouteInfo>? children})
      : super(FlsVplanMainUiRoute.name, initialChildren: children);

  static const String name = 'FlsVplanMainUiRoute';

  static _i6.PageInfo page = _i6.PageInfo(
    name,
    builder: (data) {
      return const _i4.FlsVplanMainUi();
    },
  );
}

/// generated route for
/// [_i5.Wizard]
class WizardRoute extends _i6.PageRouteInfo<void> {
  const WizardRoute({List<_i6.PageRouteInfo>? children})
      : super(WizardRoute.name, initialChildren: children);

  static const String name = 'WizardRoute';

  static _i6.PageInfo page = _i6.PageInfo(
    name,
    builder: (data) {
      return const _i5.Wizard();
    },
  );
}
