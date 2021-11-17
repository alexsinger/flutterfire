import 'package:firebase_ui/i10n.dart';
import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth;
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../auth_controller.dart';
import '../auth_flow_builder.dart';
import '../../auth_state.dart';
import '../../flows/oauth_flow.dart';
import '../../configs/oauth_provider_configuration.dart';
import 'oauth_provider_button_style.dart';

typedef ErrorCallback = void Function(Exception e);

enum ButtonVariant {
  icon_and_text,
  icon,
}

class LoadingIndicator extends StatelessWidget {
  final double size;
  final double borderWidth;
  final OAuthProviderButtonStyle style;

  const LoadingIndicator({
    Key? key,
    required this.size,
    required this.borderWidth,
    required this.style,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: CircularProgressIndicator(
          strokeWidth: borderWidth * 2,
          valueColor: AlwaysStoppedAnimation<Color>(style.color),
        ),
      ),
    );
  }
}

class OAuthProviderButtonContent extends StatelessWidget {
  final String label;
  final OAuthProviderButtonStyle style;
  final double size;
  const OAuthProviderButtonContent({
    Key? key,
    required this.label,
    required this.style,
    required this.size,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isLoading = AuthState.of(context) is SigningIn;
    late Widget content;

    if (isLoading) {
      content = const SizedBox.shrink();
    } else {
      content = Text(
        label,
        textAlign: TextAlign.center,
        style: TextStyle(
          height: 1.1,
          color: style.color,
          fontSize: size,
        ),
      );
    }

    return content;
  }
}

class OAuthProviderButtonTapHandler extends StatelessWidget {
  final double borderRadius;
  final Function(BuildContext context) onTap;

  const OAuthProviderButtonTapHandler({
    Key? key,
    required this.borderRadius,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isLoading = AuthState.of(context) is SigningIn;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(borderRadius),
        onTap: () {
          if (isLoading) return;
          onTap(context);
        },
      ),
    );
  }
}

mixin SignInWithOAuthProviderMixin {
  void signIn(BuildContext context) {
    final ctrl = AuthController.ofType<OAuthController>(context);
    final targetPlatform = Theme.of(context).platform;
    ctrl.signInWithProvider(targetPlatform);
  }
}

class OAuthProviderButton extends StatelessWidget
    with SignInWithOAuthProviderMixin {
  final double size;
  final AuthAction? action;
  final FirebaseAuth? auth;
  final double _padding;
  final OAuthProviderConfiguration providerConfig;

  const OAuthProviderButton({
    Key? key,
    required this.providerConfig,
    this.action,
    this.auth,
    this.size = 19,
  })  : _padding = size * 1.33 / 2,
        super(key: key);

  double get _height => size + _padding * 2;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final style = providerConfig.style.withBrightness(brightness);
    final l = FirebaseUILocalizations.labelsOf(context);

    final margin = (size + _padding * 2) / 10;
    final borderRadius = size / 3;
    const borderWidth = 1.0;
    final iconBorderRadius = borderRadius - borderWidth;

    return AuthFlowBuilder<OAuthController>(
      action: action,
      auth: auth,
      config: providerConfig,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: margin),
        child: Stack(
          children: [
            Material(
              elevation: 1,
              color: style.backgroundColor,
              borderRadius: BorderRadius.circular(borderRadius),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: style.backgroundColor),
                  borderRadius: BorderRadius.circular(borderRadius),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(iconBorderRadius),
                  child: SizedBox(
                    height: _height,
                    child: Row(
                      children: [
                        SizedBox(
                          width: _height,
                          height: _height,
                          child: SvgPicture.asset(
                            style.iconSrc,
                            package: 'firebase_ui',
                            width: size,
                            height: size,
                          ),
                        ),
                        Expanded(
                          child: OAuthProviderButtonContent(
                            label: providerConfig.getLabel(l),
                            style: style,
                            size: size,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: OAuthProviderButtonTapHandler(
                borderRadius: borderRadius,
                onTap: signIn,
              ),
            ),
            Builder(
              builder: (context) {
                bool isLoading = AuthState.of(context) is SigningIn;

                if (isLoading) {
                  return Positioned.fill(
                    child: LoadingIndicator(
                      size: size,
                      borderWidth: borderWidth,
                      style: style,
                    ),
                  );
                } else {
                  return const SizedBox.shrink();
                }
              },
            )
          ],
        ),
      ),
    );
  }
}

abstract class OAuthProviderButtonWidget extends StatelessWidget {
  const OAuthProviderButtonWidget({Key? key}) : super(key: key);

  OAuthProviderConfiguration get providerConfig;
  AuthAction? get action;
  FirebaseAuth? get auth;
  double? get size;

  @override
  Widget build(BuildContext context) {
    return OAuthProviderButton(
      providerConfig: providerConfig,
      action: action,
      auth: auth,
      size: size ?? 19,
    );
  }
}

class OAuthProviderIconButton extends StatelessWidget
    with SignInWithOAuthProviderMixin {
  final double size;
  final FirebaseAuth? auth;
  final AuthAction? action;
  final OAuthProviderConfiguration providerConfig;

  const OAuthProviderIconButton({
    Key? key,
    required this.providerConfig,
    this.size = 44,
    this.auth,
    this.action,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final style = providerConfig.style.withBrightness(brightness);
    final borderRadius = BorderRadius.circular(size / 6);

    return AuthFlowBuilder(
      auth: auth,
      action: action,
      config: providerConfig,
      child: Container(
        width: size,
        height: size,
        margin: EdgeInsets.all(size / 10),
        decoration: BoxDecoration(
          color: style.backgroundColor,
          borderRadius: BorderRadius.circular(size / 6),
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: borderRadius,
              child: Builder(
                builder: (context) {
                  bool isLoading = AuthState.of(context) is SigningIn;

                  if (isLoading) {
                    return LoadingIndicator(
                      borderWidth: 1,
                      size: size / 2,
                      style: style,
                    );
                  }
                  return SvgPicture.asset(
                    style.iconSrc,
                    package: 'firebase_ui',
                    width: size,
                    height: size,
                  );
                },
              ),
            ),
            Positioned.fill(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    signIn(context);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

abstract class OAuthProviderIconButtonWidget extends StatelessWidget {
  const OAuthProviderIconButtonWidget({Key? key}) : super(key: key);

  OAuthProviderConfiguration get providerConfig;
  FirebaseAuth? get auth;
  AuthAction? get action;
  double? get size;

  @override
  Widget build(BuildContext context) {
    return OAuthProviderIconButton(
      auth: auth,
      action: action,
      size: size ?? 44,
      providerConfig: providerConfig,
    );
  }
}
