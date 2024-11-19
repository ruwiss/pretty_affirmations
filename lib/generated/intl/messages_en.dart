// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'en';

  static String m0(appUrl) =>
      "Check out this app: ${appUrl}\n\nIt provides affirmations to stick to your goals and stay motivated.";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "applyInfo": MessageLookupByLibrary.simpleMessage(
            "Please restart the application for the changes to take effect"),
        "cancel": MessageLookupByLibrary.simpleMessage("Cancel"),
        "comingSoon": MessageLookupByLibrary.simpleMessage("Coming Soon..."),
        "favourites": MessageLookupByLibrary.simpleMessage("Favourites"),
        "flow": MessageLookupByLibrary.simpleMessage("Flow"),
        "language": MessageLookupByLibrary.simpleMessage("Language"),
        "languageOption": MessageLookupByLibrary.simpleMessage(
            "Change the application language, see affirmations in the language you want"),
        "leaveComment": MessageLookupByLibrary.simpleMessage("Leave a Comment"),
        "leaveCommentOption": MessageLookupByLibrary.simpleMessage(
            "Leave a comment about the app for us developers and contribute to the improvement of our application"),
        "noAffirmations": MessageLookupByLibrary.simpleMessage(
            "There are no affirmations in this category yet"),
        "noFavourites":
            MessageLookupByLibrary.simpleMessage("You have no favourites"),
        "ok": MessageLookupByLibrary.simpleMessage("Apply"),
        "privacyPolicy": MessageLookupByLibrary.simpleMessage("Privacy Policy"),
        "privacyPolicyOption": MessageLookupByLibrary.simpleMessage(
            "Get detailed information about our app’s data security and privacy policy"),
        "reminders": MessageLookupByLibrary.simpleMessage("Reminders"),
        "remindersOption": MessageLookupByLibrary.simpleMessage(
            "Set your reminders for the most suitable time slot to fit affirmations into your routine"),
        "selectCategory": MessageLookupByLibrary.simpleMessage("Categories"),
        "selectCategoryOption": MessageLookupByLibrary.simpleMessage(
            "Select the categories you\'d like to see in the app. We\'ll show you content tailored to your preferences"),
        "selectLanguage":
            MessageLookupByLibrary.simpleMessage("Select Language"),
        "settings": MessageLookupByLibrary.simpleMessage("Settings"),
        "share": MessageLookupByLibrary.simpleMessage("Share"),
        "shareOption": MessageLookupByLibrary.simpleMessage(
            "Share our app with your friends and close ones and make a positive impact on their lives"),
        "shareText": m0,
        "stories": MessageLookupByLibrary.simpleMessage("Story of the day"),
        "termsOfUse":
            MessageLookupByLibrary.simpleMessage("Terms and Conditions"),
        "termsOfUseOption": MessageLookupByLibrary.simpleMessage(
            "Read the terms and conditions you must follow to use our app"),
        "topics": MessageLookupByLibrary.simpleMessage("Categories")
      };
}
