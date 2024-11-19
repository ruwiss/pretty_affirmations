import 'package:flutter/material.dart';
import 'package:hayiqu/hayiqu.dart';
import 'package:pretty_affirmations/common/common.dart';
import 'package:pretty_affirmations/generated/l10n.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsViewmodel extends BaseViewModel {
  void onShareTap(BuildContext context) {
    Share.share(S.of(context).shareText(kAppUrl));
  }

  void onLeaveComment() {
    launchUrl(
      Uri.parse("market://details?id=$kPackageName"),
      mode: LaunchMode.externalApplication,
    );
  }
}
