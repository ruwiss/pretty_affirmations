part of '../common.dart';

const String kBaseUrl = "https://api.caltikoc.com.tr/affirmations/";
const String kApiUrl = "https://api.caltikoc.com.tr/affirmations/api";
const String kPackageName = "com.prettycat.affirmations";
const String kAppUrl =
    "https://play.google.com/store/apps/details?id=$kPackageName";
const int kLocalDbSchemaVersion = 8;

final AdIds kAdIds = true
    ? AdIds.test()
    : const AdIds(
        bannerId: "",
        interstitialId: "",
        rewardedId: "",
        nativeId: "",
        appOpenId: "ca-app-pub-1923752572867502/7608509858",
      );
