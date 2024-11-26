// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(_current != null,
        'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(instance != null,
        'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?');
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Flow`
  String get flow {
    return Intl.message(
      'Flow',
      name: 'flow',
      desc: 'Home Page Title',
      args: [],
    );
  }

  /// `Favourites`
  String get favourites {
    return Intl.message(
      'Favourites',
      name: 'favourites',
      desc: 'Favourites Page Title',
      args: [],
    );
  }

  /// `Settings`
  String get settings {
    return Intl.message(
      'Settings',
      name: 'settings',
      desc: 'Settings Page Title',
      args: [],
    );
  }

  /// `Categories`
  String get topics {
    return Intl.message(
      'Categories',
      name: 'topics',
      desc: 'Categories Page Title',
      args: [],
    );
  }

  /// `Story of the day`
  String get stories {
    return Intl.message(
      'Story of the day',
      name: 'stories',
      desc: 'Stories Page Title',
      args: [],
    );
  }

  /// `Coming Soon...`
  String get comingSoon {
    return Intl.message(
      'Coming Soon...',
      name: 'comingSoon',
      desc: '',
      args: [],
    );
  }

  /// `Language`
  String get language {
    return Intl.message(
      'Language',
      name: 'language',
      desc: '',
      args: [],
    );
  }

  /// `Change the application language, see affirmations in the language you want`
  String get languageOption {
    return Intl.message(
      'Change the application language, see affirmations in the language you want',
      name: 'languageOption',
      desc: '',
      args: [],
    );
  }

  /// `Reminders`
  String get reminders {
    return Intl.message(
      'Reminders',
      name: 'reminders',
      desc: '',
      args: [],
    );
  }

  /// `Set your reminders for the most suitable time slot to fit affirmations into your routine`
  String get remindersOption {
    return Intl.message(
      'Set your reminders for the most suitable time slot to fit affirmations into your routine',
      name: 'remindersOption',
      desc: '',
      args: [],
    );
  }

  /// `Leave a Comment`
  String get leaveComment {
    return Intl.message(
      'Leave a Comment',
      name: 'leaveComment',
      desc: '',
      args: [],
    );
  }

  /// `Leave a comment about the app for us developers and contribute to the improvement of our application`
  String get leaveCommentOption {
    return Intl.message(
      'Leave a comment about the app for us developers and contribute to the improvement of our application',
      name: 'leaveCommentOption',
      desc: '',
      args: [],
    );
  }

  /// `Share`
  String get share {
    return Intl.message(
      'Share',
      name: 'share',
      desc: '',
      args: [],
    );
  }

  /// `Delete`
  String get delete {
    return Intl.message(
      'Delete',
      name: 'delete',
      desc: '',
      args: [],
    );
  }

  /// `Share our app with your friends and close ones and make a positive impact on their lives`
  String get shareOption {
    return Intl.message(
      'Share our app with your friends and close ones and make a positive impact on their lives',
      name: 'shareOption',
      desc: '',
      args: [],
    );
  }

  /// `Privacy Policy`
  String get privacyPolicy {
    return Intl.message(
      'Privacy Policy',
      name: 'privacyPolicy',
      desc: '',
      args: [],
    );
  }

  /// `Get detailed information about our app’s data security and privacy policy`
  String get privacyPolicyOption {
    return Intl.message(
      'Get detailed information about our app’s data security and privacy policy',
      name: 'privacyPolicyOption',
      desc: '',
      args: [],
    );
  }

  /// `Terms and Conditions`
  String get termsOfUse {
    return Intl.message(
      'Terms and Conditions',
      name: 'termsOfUse',
      desc: '',
      args: [],
    );
  }

  /// `Read the terms and conditions you must follow to use our app`
  String get termsOfUseOption {
    return Intl.message(
      'Read the terms and conditions you must follow to use our app',
      name: 'termsOfUseOption',
      desc: '',
      args: [],
    );
  }

  /// `Select Language`
  String get selectLanguage {
    return Intl.message(
      'Select Language',
      name: 'selectLanguage',
      desc: '',
      args: [],
    );
  }

  /// `Categories`
  String get selectCategory {
    return Intl.message(
      'Categories',
      name: 'selectCategory',
      desc: '',
      args: [],
    );
  }

  /// `Select the categories you'd like to see in the app. We'll show you content tailored to your preferences`
  String get selectCategoryOption {
    return Intl.message(
      'Select the categories you\'d like to see in the app. We\'ll show you content tailored to your preferences',
      name: 'selectCategoryOption',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get cancel {
    return Intl.message(
      'Cancel',
      name: 'cancel',
      desc: '',
      args: [],
    );
  }

  /// `Apply`
  String get ok {
    return Intl.message(
      'Apply',
      name: 'ok',
      desc: '',
      args: [],
    );
  }

  /// `Please restart the application for the changes to take effect`
  String get applyInfo {
    return Intl.message(
      'Please restart the application for the changes to take effect',
      name: 'applyInfo',
      desc: '',
      args: [],
    );
  }

  /// `You have no favourites`
  String get noFavourites {
    return Intl.message(
      'You have no favourites',
      name: 'noFavourites',
      desc: '',
      args: [],
    );
  }

  /// `There are no affirmations in this category yet`
  String get noAffirmations {
    return Intl.message(
      'There are no affirmations in this category yet',
      name: 'noAffirmations',
      desc: '',
      args: [],
    );
  }

  /// `Check out this app: {appUrl}\n\nIt provides affirmations to stick to your goals and stay motivated.`
  String shareText(String appUrl) {
    return Intl.message(
      'Check out this app: $appUrl\n\nIt provides affirmations to stick to your goals and stay motivated.',
      name: 'shareText',
      desc: '',
      args: [appUrl],
    );
  }

  /// `Daily Notification Count`
  String get dailyNotificationSetting {
    return Intl.message(
      'Daily Notification Count',
      name: 'dailyNotificationSetting',
      desc: '',
      args: [],
    );
  }

  /// `One Moment!`
  String get notificationTitle1 {
    return Intl.message(
      'One Moment!',
      name: 'notificationTitle1',
      desc: '',
      args: [],
    );
  }

  /// `Starting Now`
  String get notificationTitle2 {
    return Intl.message(
      'Starting Now',
      name: 'notificationTitle2',
      desc: '',
      args: [],
    );
  }

  /// `My True Self`
  String get notificationTitle3 {
    return Intl.message(
      'My True Self',
      name: 'notificationTitle3',
      desc: '',
      args: [],
    );
  }

  /// `Centered in Me`
  String get notificationTitle4 {
    return Intl.message(
      'Centered in Me',
      name: 'notificationTitle4',
      desc: '',
      args: [],
    );
  }

  /// `Time to Rest`
  String get notificationTitle5 {
    return Intl.message(
      'Time to Rest',
      name: 'notificationTitle5',
      desc: '',
      args: [],
    );
  }

  /// `Make a Difference`
  String get notificationTitle6 {
    return Intl.message(
      'Make a Difference',
      name: 'notificationTitle6',
      desc: '',
      args: [],
    );
  }

  /// `Affirmation of the Day`
  String get notificationTitle7 {
    return Intl.message(
      'Affirmation of the Day',
      name: 'notificationTitle7',
      desc: '',
      args: [],
    );
  }

  /// `An Affirmation for You`
  String get notificationTitle8 {
    return Intl.message(
      'An Affirmation for You',
      name: 'notificationTitle8',
      desc: '',
      args: [],
    );
  }

  /// `I'm Ready!`
  String get notificationTitle9 {
    return Intl.message(
      'I\'m Ready!',
      name: 'notificationTitle9',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'ru'),
      Locale.fromSubtags(languageCode: 'tr', countryCode: 'TR'),
      Locale.fromSubtags(languageCode: 'zh'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
