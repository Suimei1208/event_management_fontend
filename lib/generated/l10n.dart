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

  /// `Event Management`
  String get management {
    return Intl.message(
      'Event Management',
      name: 'management',
      desc: '',
      args: [],
    );
  }

  /// `Manage`
  String get manage_event {
    return Intl.message(
      'Manage',
      name: 'manage_event',
      desc: '',
      args: [],
    );
  }

  /// `Register`
  String get register_event {
    return Intl.message(
      'Register',
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

  /// `View Ticket`
  String get view_ticket {
    return Intl.message(
      'View Ticket',
      name: 'view_ticket',
      desc: '',
      args: [],
    );
  }

  /// `Add Participant via Excel`
  String get add_via_excel {
    return Intl.message(
      'Add Participant via Excel',
      name: 'add_via_excel',
      desc: '',
      args: [],
    );
  }

  /// `Registration List`
  String get registration_list {
    return Intl.message(
      'Registration List',
      name: 'registration_list',
      desc: '',
      args: [],
    );
  }

  /// `Edit Special Participants`
  String get edit_special_participants {
    return Intl.message(
      'Edit Special Participants',
      name: 'edit_special_participants',
      desc: '',
      args: [],
    );
  }

  /// `Participant List`
  String get participant_list {
    return Intl.message(
      'Participant List',
      name: 'participant_list',
      desc: '',
      args: [],
    );
  }

  /// `Document`
  String get document {
    return Intl.message(
      'Document',
      name: 'document',
      desc: '',
      args: [],
    );
  }

  /// `Spending`
  String get spending {
    return Intl.message(
      'Spending',
      name: 'spending',
      desc: '',
      args: [],
    );
  }

  /// `Statistics`
  String get stat {
    return Intl.message(
      'Statistics',
      name: 'stat',
      desc: '',
      args: [],
    );
  }

  /// `Cancel List`
  String get cancel_list {
    return Intl.message(
      'Cancel List',
      name: 'cancel_list',
      desc: '',
      args: [],
    );
  }

  /// `Edit Event`
  String get edit_event {
    return Intl.message(
      'Edit Event',
      name: 'edit_event',
      desc: '',
      args: [],
    );
  }

  /// `Re-open Event`
  String get reopen {
    return Intl.message(
      'Re-open Event',
      name: 'reopen',
      desc: '',
      args: [],
    );
  }

  /// `Cancel Event`
  String get cancel_event {
    return Intl.message(
      'Cancel Event',
      name: 'cancel_event',
      desc: '',
      args: [],
    );
  }

  /// `Toggle View`
  String get toggle_view {
    return Intl.message(
      'Toggle View',
      name: 'toggle_view',
      desc: '',
      args: [],
    );
  }

  /// `No upcoming event`
  String get no_upcoming_event {
    return Intl.message(
      'No upcoming event',
      name: 'no_upcoming_event',
      desc: '',
      args: [],
    );
  }

  /// `Select Start or After Date`
  String get select_start_end_date {
    return Intl.message(
      'Select Start or After Date',
      name: 'select_start_end_date',
      desc: '',
      args: [],
    );
  }

  /// `Start or After Date`
  String get start_or_after_date {
    return Intl.message(
      'Start or After Date',
      name: 'start_or_after_date',
      desc: '',
      args: [],
    );
  }

  /// `minutes ago`
  String get minutes_ago {
    return Intl.message(
      'minutes ago',
      name: 'minutes_ago',
      desc: '',
      args: [],
    );
  }

  /// `hours ago`
  String get hours_ago {
    return Intl.message(
      'hours ago',
      name: 'hours_ago',
      desc: '',
      args: [],
    );
  }

  /// `Detail post`
  String get detail_post {
    return Intl.message(
      'Detail post',
      name: 'detail_post',
      desc: '',
      args: [],
    );
  }

  /// `Edit Guest`
  String get edit_guest {
    return Intl.message(
      'Edit Guest',
      name: 'edit_guest',
      desc: '',
      args: [],
    );
  }

  /// `Participation list`
  String get list_participants {
    return Intl.message(
      'Participation list',
      name: 'list_participants',
      desc: '',
      args: [],
    );
  }

  /// `Documents`
  String get documents {
    return Intl.message(
      'Documents',
      name: 'documents',
      desc: '',
      args: [],
    );
  }

  /// `Reopen the event`
  String get reopen_event {
    return Intl.message(
      'Reopen the event',
      name: 'reopen_event',
      desc: '',
      args: [],
    );
  }

  /// `Decentralization`
  String get decentralization {
    return Intl.message(
      'Decentralization',
      name: 'decentralization',
      desc: '',
      args: [],
    );
  }

  /// `Opt-out data`
  String get data_cancel {
    return Intl.message(
      'Opt-out data',
      name: 'data_cancel',
      desc: '',
      args: [],
    );
  }

  /// `Statistics`
  String get statistics {
    return Intl.message(
      'Statistics',
      name: 'statistics',
      desc: '',
      args: [],
    );
  }

  /// `Accessibility`
  String get accessibility {
    return Intl.message(
      'Accessibility',
      name: 'accessibility',
      desc: '',
      args: [],
    );
  }

  /// `Register Schedule`
  String get register_schedule {
    return Intl.message(
      'Register Schedule',
      name: 'register_schedule',
      desc: '',
      args: [],
    );
  }

  /// `Review Events`
  String get review_event {
    return Intl.message(
      'Review Events',
      name: 'review_event',
      desc: '',
      args: [],
    );
  }

  /// `Rate Your Experience`
  String get rate {
    return Intl.message(
      'Rate Your Experience',
      name: 'rate',
      desc: '',
      args: [],
    );
  }

  /// `Write Your Review (Optional)`
  String get content_review {
    return Intl.message(
      'Write Your Review (Optional)',
      name: 'content_review',
      desc: '',
      args: [],
    );
  }

  /// `Would you recommend this event?`
  String get like_event_review {
    return Intl.message(
      'Would you recommend this event?',
      name: 'like_event_review',
      desc: '',
      args: [],
    );
  }

  /// `Submit Review`
  String get submit_review {
    return Intl.message(
      'Submit Review',
      name: 'submit_review',
      desc: '',
      args: [],
    );
  }

  /// `Pending review`
  String get not_yet_review {
    return Intl.message(
      'Pending review',
      name: 'not_yet_review',
      desc: '',
      args: [],
    );
  }

  /// `Reviewed`
  String get reviewed {
    return Intl.message(
      'Reviewed',
      name: 'reviewed',
      desc: '',
      args: [],
    );
  }

  /// `Add event to phone calendar`
  String get add_phone {
    return Intl.message(
      'Add event to phone calendar',
      name: 'add_phone',
      desc: '',
      args: [],
    );
  }

  /// `Add event to Google Calendar`
  String get add_gg_cal {
    return Intl.message(
      'Add event to Google Calendar',
      name: 'add_gg_cal',
      desc: '',
      args: [],
    );
  }

  /// `Awaiting approval`
  String get await_appro {
    return Intl.message(
      'Awaiting approval',
      name: 'await_appro',
      desc: '',
      args: [],
    );
  }

  /// `Accepted`
  String get accepted {
    return Intl.message(
      'Accepted',
      name: 'accepted',
      desc: '',
      args: [],
    );
  }

  /// `Spending management`
  String get spending_mana {
    return Intl.message(
      'Spending management',
      name: 'spending_mana',
      desc: '',
      args: [],
    );
  }

  /// `Income`
  String get income {
    return Intl.message(
      'Income',
      name: 'income',
      desc: '',
      args: [],
    );
  }

  /// `General overview`
  String get overview {
    return Intl.message(
      'General overview',
      name: 'overview',
      desc: '',
      args: [],
    );
  }

  /// `Total income`
  String get total_income {
    return Intl.message(
      'Total income',
      name: 'total_income',
      desc: '',
      args: [],
    );
  }

  /// `Total spending`
  String get total_spending {
    return Intl.message(
      'Total spending',
      name: 'total_spending',
      desc: '',
      args: [],
    );
  }

  /// `Balance remaining`
  String get remain {
    return Intl.message(
      'Balance remaining',
      name: 'remain',
      desc: '',
      args: [],
    );
  }

  /// `No transactions available`
  String get no_transactions {
    return Intl.message(
      'No transactions available',
      name: 'no_transactions',
      desc: '',
      args: [],
    );
  }

  /// `Add income/spending`
  String get add_income_spending {
    return Intl.message(
      'Add income/spending',
      name: 'add_income_spending',
      desc: '',
      args: [],
    );
  }

  /// `Spending categories`
  String get spe_cate {
    return Intl.message(
      'Spending categories',
      name: 'spe_cate',
      desc: '',
      args: [],
    );
  }

  /// `Source of money`
  String get source {
    return Intl.message(
      'Source of money',
      name: 'source',
      desc: '',
      args: [],
    );
  }

  /// `Amount of money (VND)`
  String get amount {
    return Intl.message(
      'Amount of money (VND)',
      name: 'amount',
      desc: '',
      args: [],
    );
  }

  /// `Category must not be empty and amount must be greater than 0.`
  String get spending_warning {
    return Intl.message(
      'Category must not be empty and amount must be greater than 0.',
      name: 'spending_warning',
      desc: '',
      args: [],
    );
  }

  /// `Cancelled Users`
  String get cancel_user {
    return Intl.message(
      'Cancelled Users',
      name: 'cancel_user',
      desc: '',
      args: [],
    );
  }

  /// `Setting cancel`
  String get setting_cancel {
    return Intl.message(
      'Setting cancel',
      name: 'setting_cancel',
      desc: '',
      args: [],
    );
  }

  /// `Select Reason`
  String get reason {
    return Intl.message(
      'Select Reason',
      name: 'reason',
      desc: '',
      args: [],
    );
  }

  /// `Add Image Evidence`
  String get add_image_cancel {
    return Intl.message(
      'Add Image Evidence',
      name: 'add_image_cancel',
      desc: '',
      args: [],
    );
  }

  /// `Select start date`
  String get select_start_date {
    return Intl.message(
      'Select start date',
      name: 'select_start_date',
      desc: '',
      args: [],
    );
  }

  /// `Select end date`
  String get select_end_date {
    return Intl.message(
      'Select end date',
      name: 'select_end_date',
      desc: '',
      args: [],
    );
  }

  /// `Add External Link`
  String get add_link_cancel {
    return Intl.message(
      'Add External Link',
      name: 'add_link_cancel',
      desc: '',
      args: [],
    );
  }

  /// `Enter External Link`
  String get enter_link {
    return Intl.message(
      'Enter External Link',
      name: 'enter_link',
      desc: '',
      args: [],
    );
  }

  /// `Explore Events`
  String get explore_events {
    return Intl.message(
      'Explore Events',
      name: 'explore_events',
      desc: '',
      args: [],
    );
  }

  /// `likes`
  String get likes {
    return Intl.message(
      'likes',
      name: 'likes',
      desc: '',
      args: [],
    );
  }

  /// `comments`
  String get comments {
    return Intl.message(
      'comments',
      name: 'comments',
      desc: '',
      args: [],
    );
  }

  /// `Comment`
  String get comment {
    return Intl.message(
      'Comment',
      name: 'comment',
      desc: '',
      args: [],
    );
  }

  /// `Write a comment...`
  String get write_comment {
    return Intl.message(
      'Write a comment...',
      name: 'write_comment',
      desc: '',
      args: [],
    );
  }

  /// `Reply`
  String get reply {
    return Intl.message(
      'Reply',
      name: 'reply',
      desc: '',
      args: [],
    );
  }

  /// `Update Event`
  String get update_event {
    return Intl.message(
      'Update Event',
      name: 'update_event',
      desc: '',
      args: [],
    );
  }

  /// `Pick an image`
  String get pick_image {
    return Intl.message(
      'Pick an image',
      name: 'pick_image',
      desc: '',
      args: [],
    );
  }

  /// `Upcoming Events`
  String get upcomingEvents {
    return Intl.message(
      'Upcoming Events',
      name: 'upcomingEvents',
      desc: '',
      args: [],
    );
  }

  /// `Past Events`
  String get pastEvents {
    return Intl.message(
      'Past Events',
      name: 'pastEvents',
      desc: '',
      args: [],
    );
  }

  /// `Ticket Status:`
  String get ticketStatus {
    return Intl.message(
      'Ticket Status:',
      name: 'ticketStatus',
      desc: '',
      args: [],
    );
  }

  /// `Ticket #:`
  String get ticketNumber {
    return Intl.message(
      'Ticket #:',
      name: 'ticketNumber',
      desc: '',
      args: [],
    );
  }

  /// `Cancel Ticket`
  String get cancelTicket {
    return Intl.message(
      'Cancel Ticket',
      name: 'cancelTicket',
      desc: '',
      args: [],
    );
  }

  /// `Expired`
  String get expired {
    return Intl.message(
      'Expired',
      name: 'expired',
      desc: '',
      args: [],
    );
  }

  /// `No tickets available.`
  String get noTicketsAvailable {
    return Intl.message(
      'No tickets available.',
      name: 'noTicketsAvailable',
      desc: '',
      args: [],
    );
  }

  /// `Event Status`
  String get eventStatus {
    return Intl.message(
      'Event Status',
      name: 'eventStatus',
      desc: '',
      args: [],
    );
  }

  /// `Ticket Cancellation`
  String get ticketCancellation {
    return Intl.message(
      'Ticket Cancellation',
      name: 'ticketCancellation',
      desc: '',
      args: [],
    );
  }

  /// `Notification`
  String get notification {
    return Intl.message(
      'Notification',
      name: 'notification',
      desc: '',
      args: [],
    );
  }

  /// `Ticket canceled successfully`
  String get cancellationSuccess {
    return Intl.message(
      'Ticket canceled successfully',
      name: 'cancellationSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Unable to cancel ticket`
  String get cancellationFailed {
    return Intl.message(
      'Unable to cancel ticket',
      name: 'cancellationFailed',
      desc: '',
      args: [],
    );
  }

  /// `Error`
  String get error {
    return Intl.message(
      'Error',
      name: 'error',
      desc: '',
      args: [],
    );
  }

  /// `Outdated to cancel ticket`
  String get outdated_cancel {
    return Intl.message(
      'Outdated to cancel ticket',
      name: 'outdated_cancel',
      desc: '',
      args: [],
    );
  }

  /// `Please contact admin`
  String get please_contact_admin {
    return Intl.message(
      'Please contact admin',
      name: 'please_contact_admin',
      desc: '',
      args: [],
    );
  }

  /// `Pending`
  String get pending {
    return Intl.message(
      'Pending',
      name: 'pending',
      desc: '',
      args: [],
    );
  }

  /// `Rejected`
  String get rejected {
    return Intl.message(
      'Rejected',
      name: 'rejected',
      desc: '',
      args: [],
    );
  }

  /// `Your Event`
  String get ur_event {
    return Intl.message(
      'Your Event',
      name: 'ur_event',
      desc: '',
      args: [],
    );
  }

  /// `Edit Post`
  String get edit_post {
    return Intl.message(
      'Edit Post',
      name: 'edit_post',
      desc: '',
      args: [],
    );
  }

  /// `Delete Confirmation`
  String get confirm_del {
    return Intl.message(
      'Delete Confirmation',
      name: 'confirm_del',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to delete this post?`
  String get quest_del {
    return Intl.message(
      'Are you sure you want to delete this post?',
      name: 'quest_del',
      desc: '',
      args: [],
    );
  }

  /// `Edit post successfully`
  String get edit_post_ans {
    return Intl.message(
      'Edit post successfully',
      name: 'edit_post_ans',
      desc: '',
      args: [],
    );
  }

  /// `Delete Post`
  String get del_post {
    return Intl.message(
      'Delete Post',
      name: 'del_post',
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
