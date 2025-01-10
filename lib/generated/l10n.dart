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

  /// `Language`
  String get language {
    return Intl.message(
      'Language',
      name: 'language',
      desc: '',
      args: [],
    );
  }

  /// `English`
  String get english {
    return Intl.message(
      'English',
      name: 'english',
      desc: '',
      args: [],
    );
  }

  /// `Vietnamese`
  String get vietnamese {
    return Intl.message(
      'Vietnamese',
      name: 'vietnamese',
      desc: '',
      args: [],
    );
  }

  /// `Event Management`
  String get title {
    return Intl.message(
      'Event Management',
      name: 'title',
      desc: '',
      args: [],
    );
  }

  /// `Welcome to the Event Management app!`
  String get welcome {
    return Intl.message(
      'Welcome to the Event Management app!',
      name: 'welcome',
      desc: '',
      args: [],
    );
  }

  /// `Sign in with Facebook`
  String get facebook_sign_in {
    return Intl.message(
      'Sign in with Facebook',
      name: 'facebook_sign_in',
      desc: '',
      args: [],
    );
  }

  /// `Sign in with Gmail`
  String get gmail_sign_in {
    return Intl.message(
      'Sign in with Gmail',
      name: 'gmail_sign_in',
      desc: '',
      args: [],
    );
  }

  /// `Login`
  String get login {
    return Intl.message(
      'Login',
      name: 'login',
      desc: '',
      args: [],
    );
  }

  /// `Register Account`
  String get register_account {
    return Intl.message(
      'Register Account',
      name: 'register_account',
      desc: '',
      args: [],
    );
  }

  /// `Edit Profile`
  String get editProfile {
    return Intl.message(
      'Edit Profile',
      name: 'editProfile',
      desc: '',
      args: [],
    );
  }

  /// `My Ticket`
  String get myTicket {
    return Intl.message(
      'My Ticket',
      name: 'myTicket',
      desc: '',
      args: [],
    );
  }

  /// `General`
  String get general {
    return Intl.message(
      'General',
      name: 'general',
      desc: '',
      args: [],
    );
  }

  /// `Setting`
  String get setting {
    return Intl.message(
      'Setting',
      name: 'setting',
      desc: '',
      args: [],
    );
  }

  /// `Logout`
  String get logout {
    return Intl.message(
      'Logout',
      name: 'logout',
      desc: '',
      args: [],
    );
  }

  /// `Account`
  String get account {
    return Intl.message(
      'Account',
      name: 'account',
      desc: '',
      args: [],
    );
  }

  /// `Profile`
  String get profile {
    return Intl.message(
      'Profile',
      name: 'profile',
      desc: '',
      args: [],
    );
  }

  /// `Welcome Back`
  String get welcome_back {
    return Intl.message(
      'Welcome Back',
      name: 'welcome_back',
      desc: '',
      args: [],
    );
  }

  /// `Next Event`
  String get next_event {
    return Intl.message(
      'Next Event',
      name: 'next_event',
      desc: '',
      args: [],
    );
  }

  /// `Next Events`
  String get next_events {
    return Intl.message(
      'Next Events',
      name: 'next_events',
      desc: '',
      args: [],
    );
  }

  /// `Home`
  String get home {
    return Intl.message(
      'Home',
      name: 'home',
      desc: '',
      args: [],
    );
  }

  /// `Management Event`
  String get manage_event {
    return Intl.message(
      'Management Event',
      name: 'manage_event',
      desc: '',
      args: [],
    );
  }

  /// `Register Event`
  String get register_event {
    return Intl.message(
      'Register Event',
      name: 'register_event',
      desc: '',
      args: [],
    );
  }

  /// `Forum`
  String get forum {
    return Intl.message(
      'Forum',
      name: 'forum',
      desc: '',
      args: [],
    );
  }

  /// `Event Name`
  String get event_name {
    return Intl.message(
      'Event Name',
      name: 'event_name',
      desc: '',
      args: [],
    );
  }

  /// `Description`
  String get desc {
    return Intl.message(
      'Description',
      name: 'desc',
      desc: '',
      args: [],
    );
  }

  /// `Event Objectives`
  String get obj {
    return Intl.message(
      'Event Objectives',
      name: 'obj',
      desc: '',
      args: [],
    );
  }

  /// `Location`
  String get location {
    return Intl.message(
      'Location',
      name: 'location',
      desc: '',
      args: [],
    );
  }

  /// `Start Date`
  String get start_date {
    return Intl.message(
      'Start Date',
      name: 'start_date',
      desc: '',
      args: [],
    );
  }

  /// `End Date`
  String get end_date {
    return Intl.message(
      'End Date',
      name: 'end_date',
      desc: '',
      args: [],
    );
  }

  /// `Speaker`
  String get speaker {
    return Intl.message(
      'Speaker',
      name: 'speaker',
      desc: '',
      args: [],
    );
  }

  /// `Special Guest`
  String get special_guest {
    return Intl.message(
      'Special Guest',
      name: 'special_guest',
      desc: '',
      args: [],
    );
  }

  /// `View Schedule`
  String get view_schedule {
    return Intl.message(
      'View Schedule',
      name: 'view_schedule',
      desc: '',
      args: [],
    );
  }

  /// `Add Speaker`
  String get add_speaker {
    return Intl.message(
      'Add Speaker',
      name: 'add_speaker',
      desc: '',
      args: [],
    );
  }

  /// `Add Special Guest`
  String get add_special_guest {
    return Intl.message(
      'Add Special Guest',
      name: 'add_special_guest',
      desc: '',
      args: [],
    );
  }

  /// `Remove Speaker`
  String get remove_speaker {
    return Intl.message(
      'Remove Speaker',
      name: 'remove_speaker',
      desc: '',
      args: [],
    );
  }

  /// `Remove Special Guest`
  String get remove_special_guest {
    return Intl.message(
      'Remove Special Guest',
      name: 'remove_special_guest',
      desc: '',
      args: [],
    );
  }

  /// `Share Role`
  String get share_role {
    return Intl.message(
      'Share Role',
      name: 'share_role',
      desc: '',
      args: [],
    );
  }

  /// `Add member`
  String get add_member {
    return Intl.message(
      'Add member',
      name: 'add_member',
      desc: '',
      args: [],
    );
  }

  /// `Pending Request`
  String get pending_request {
    return Intl.message(
      'Pending Request',
      name: 'pending_request',
      desc: '',
      args: [],
    );
  }

  /// `Existed Participant`
  String get existed_participant {
    return Intl.message(
      'Existed Participant',
      name: 'existed_participant',
      desc: '',
      args: [],
    );
  }

  /// `Approved Participants`
  String get approved_participants {
    return Intl.message(
      'Approved Participants',
      name: 'approved_participants',
      desc: '',
      args: [],
    );
  }

  /// `Added Participants`
  String get added_participants {
    return Intl.message(
      'Added Participants',
      name: 'added_participants',
      desc: '',
      args: [],
    );
  }

  /// `View Detail`
  String get view_detail {
    return Intl.message(
      'View Detail',
      name: 'view_detail',
      desc: '',
      args: [],
    );
  }

  /// `Search Event...`
  String get search_event {
    return Intl.message(
      'Search Event...',
      name: 'search_event',
      desc: '',
      args: [],
    );
  }

  /// `Event Type`
  String get event_type {
    return Intl.message(
      'Event Type',
      name: 'event_type',
      desc: '',
      args: [],
    );
  }

  /// `Approved`
  String get approved {
    return Intl.message(
      'Approved',
      name: 'approved',
      desc: '',
      args: [],
    );
  }

  /// `Register`
  String get register {
    return Intl.message(
      'Register',
      name: 'register',
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

  /// `Fill in the details below to create your new event`
  String get guide_create_event {
    return Intl.message(
      'Fill in the details below to create your new event',
      name: 'guide_create_event',
      desc: '',
      args: [],
    );
  }

  /// `Create Event`
  String get create_event {
    return Intl.message(
      'Create Event',
      name: 'create_event',
      desc: '',
      args: [],
    );
  }

  /// `Enter`
  String get enter {
    return Intl.message(
      'Enter',
      name: 'enter',
      desc: '',
      args: [],
    );
  }

  /// `Describe`
  String get describe {
    return Intl.message(
      'Describe',
      name: 'describe',
      desc: '',
      args: [],
    );
  }

  /// `Select Date`
  String get select_date {
    return Intl.message(
      'Select Date',
      name: 'select_date',
      desc: '',
      args: [],
    );
  }

  /// `Selelct Time`
  String get select_time {
    return Intl.message(
      'Selelct Time',
      name: 'select_time',
      desc: '',
      args: [],
    );
  }

  /// `Rate Event`
  String get rate_event {
    return Intl.message(
      'Rate Event',
      name: 'rate_event',
      desc: '',
      args: [],
    );
  }

  /// `On-going Event`
  String get ongoing_event {
    return Intl.message(
      'On-going Event',
      name: 'ongoing_event',
      desc: '',
      args: [],
    );
  }

  /// `Ongoing`
  String get Ongoing {
    return Intl.message(
      'Ongoing',
      name: 'Ongoing',
      desc: '',
      args: [],
    );
  }

  /// `No Event Available`
  String get no_events_available {
    return Intl.message(
      'No Event Available',
      name: 'no_events_available',
      desc: '',
      args: [],
    );
  }

  /// `Welcome to the Community`
  String get welcome_forum {
    return Intl.message(
      'Welcome to the Community',
      name: 'welcome_forum',
      desc: '',
      args: [],
    );
  }

  /// `Create Post`
  String get create_post {
    return Intl.message(
      'Create Post',
      name: 'create_post',
      desc: '',
      args: [],
    );
  }

  /// `All`
  String get all {
    return Intl.message(
      'All',
      name: 'all',
      desc: '',
      args: [],
    );
  }

  /// `Popular`
  String get popular {
    return Intl.message(
      'Popular',
      name: 'popular',
      desc: '',
      args: [],
    );
  }

  /// `latest`
  String get latest {
    return Intl.message(
      'latest',
      name: 'latest',
      desc: '',
      args: [],
    );
  }

  /// `Unanswered`
  String get unanswered {
    return Intl.message(
      'Unanswered',
      name: 'unanswered',
      desc: '',
      args: [],
    );
  }

  /// `Join discussions, share informations, and connect with others`
  String get guide_forum {
    return Intl.message(
      'Join discussions, share informations, and connect with others',
      name: 'guide_forum',
      desc: '',
      args: [],
    );
  }

  /// `Post Title`
  String get post_title {
    return Intl.message(
      'Post Title',
      name: 'post_title',
      desc: '',
      args: [],
    );
  }

  /// `Share Your Thoughts...`
  String get share_thought {
    return Intl.message(
      'Share Your Thoughts...',
      name: 'share_thought',
      desc: '',
      args: [],
    );
  }

  /// `Category`
  String get category {
    return Intl.message(
      'Category',
      name: 'category',
      desc: '',
      args: [],
    );
  }

  /// `Discussion`
  String get discussion {
    return Intl.message(
      'Discussion',
      name: 'discussion',
      desc: '',
      args: [],
    );
  }

  /// `Questions`
  String get questions {
    return Intl.message(
      'Questions',
      name: 'questions',
      desc: '',
      args: [],
    );
  }

  /// `Tips & Tricks`
  String get tips_tricks {
    return Intl.message(
      'Tips & Tricks',
      name: 'tips_tricks',
      desc: '',
      args: [],
    );
  }

  /// `Feedback`
  String get feedback {
    return Intl.message(
      'Feedback',
      name: 'feedback',
      desc: '',
      args: [],
    );
  }

  /// `Attachments`
  String get attachments {
    return Intl.message(
      'Attachments',
      name: 'attachments',
      desc: '',
      args: [],
    );
  }

  /// `Add Photo`
  String get add_photo {
    return Intl.message(
      'Add Photo',
      name: 'add_photo',
      desc: '',
      args: [],
    );
  }

  /// `Post`
  String get post {
    return Intl.message(
      'Post',
      name: 'post',
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
      Locale.fromSubtags(languageCode: 'vi'),
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
