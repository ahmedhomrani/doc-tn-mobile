import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('fr'),
  ];

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @choosePreferredLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose your preferred language'**
  String get choosePreferredLanguage;

  /// No description provided for @french.
  ///
  /// In en, this message translates to:
  /// **'Français'**
  String get french;

  /// No description provided for @frenchLanguage.
  ///
  /// In en, this message translates to:
  /// **'French language'**
  String get frenchLanguage;

  /// No description provided for @arabic.
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get arabic;

  /// No description provided for @arabicLanguage.
  ///
  /// In en, this message translates to:
  /// **'Arabic language'**
  String get arabicLanguage;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @englishLanguage.
  ///
  /// In en, this message translates to:
  /// **'English language'**
  String get englishLanguage;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'MediCare'**
  String get appName;

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'Your personal health companion.\nConsult doctors, track your health,\nmanage your prescriptions.'**
  String get appTagline;

  /// No description provided for @featureDoctors.
  ///
  /// In en, this message translates to:
  /// **'Top\nDoctors'**
  String get featureDoctors;

  /// No description provided for @featureBooking.
  ///
  /// In en, this message translates to:
  /// **'Easy\nBooking'**
  String get featureBooking;

  /// No description provided for @featureRx.
  ///
  /// In en, this message translates to:
  /// **'Rx\nTracking'**
  String get featureRx;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started — It\'s Free'**
  String get getStarted;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'I already have an account'**
  String get alreadyHaveAccount;

  /// No description provided for @termsPrefix.
  ///
  /// In en, this message translates to:
  /// **'By continuing, you agree to our '**
  String get termsPrefix;

  /// No description provided for @termsOfUse.
  ///
  /// In en, this message translates to:
  /// **'Terms of Use'**
  String get termsOfUse;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @and.
  ///
  /// In en, this message translates to:
  /// **'and'**
  String get and;

  /// No description provided for @createAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Create an account ✨'**
  String get createAccountTitle;

  /// No description provided for @createAccountSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Join MediCare and take control of your health'**
  String get createAccountSubtitle;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get email;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phone;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @acceptTermsError.
  ///
  /// In en, this message translates to:
  /// **'Please accept the terms to continue'**
  String get acceptTermsError;

  /// No description provided for @createAccountBtn.
  ///
  /// In en, this message translates to:
  /// **'Create Account ✨'**
  String get createAccountBtn;

  /// No description provided for @alreadyAccountPrefix.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get alreadyAccountPrefix;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome back 👋'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to your MediCare account'**
  String get loginSubtitle;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @loginBtn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get loginBtn;

  /// No description provided for @orContinueWith.
  ///
  /// In en, this message translates to:
  /// **'or continue with'**
  String get orContinueWith;

  /// No description provided for @noAccountPrefix.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? '**
  String get noAccountPrefix;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back,'**
  String get welcomeBack;

  /// No description provided for @userName.
  ///
  /// In en, this message translates to:
  /// **'Sarah Jenkins'**
  String get userName;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Find doctors, clinics, drugs...'**
  String get searchHint;

  /// No description provided for @upcoming.
  ///
  /// In en, this message translates to:
  /// **'UPCOMING'**
  String get upcoming;

  /// No description provided for @doctorName.
  ///
  /// In en, this message translates to:
  /// **'Dr. Alisha P.'**
  String get doctorName;

  /// No description provided for @doctorSpecialty.
  ///
  /// In en, this message translates to:
  /// **'Cardiologist • Heart Center'**
  String get doctorSpecialty;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @appointmentTime.
  ///
  /// In en, this message translates to:
  /// **'10:30 AM'**
  String get appointmentTime;

  /// No description provided for @doctors.
  ///
  /// In en, this message translates to:
  /// **'Doctors'**
  String get doctors;

  /// No description provided for @meds.
  ///
  /// In en, this message translates to:
  /// **'Meds'**
  String get meds;

  /// No description provided for @records.
  ///
  /// In en, this message translates to:
  /// **'Records'**
  String get records;

  /// No description provided for @chat.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get chat;

  /// No description provided for @todaysMeds.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Meds'**
  String get todaysMeds;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See All'**
  String get seeAll;

  /// No description provided for @vitaminD3.
  ///
  /// In en, this message translates to:
  /// **'Vitamin D3'**
  String get vitaminD3;

  /// No description provided for @vitaminSubtitle.
  ///
  /// In en, this message translates to:
  /// **'1 pill • After meal'**
  String get vitaminSubtitle;

  /// No description provided for @amoxicillin.
  ///
  /// In en, this message translates to:
  /// **'Amoxicillin'**
  String get amoxicillin;

  /// No description provided for @amoxicillinSubtitle.
  ///
  /// In en, this message translates to:
  /// **'500mg • Before meal'**
  String get amoxicillinSubtitle;

  /// No description provided for @myVitals.
  ///
  /// In en, this message translates to:
  /// **'My Vitals'**
  String get myVitals;

  /// No description provided for @heartRate.
  ///
  /// In en, this message translates to:
  /// **'Heart Rate'**
  String get heartRate;

  /// No description provided for @sleep.
  ///
  /// In en, this message translates to:
  /// **'Sleep'**
  String get sleep;

  /// No description provided for @now.
  ///
  /// In en, this message translates to:
  /// **'Now'**
  String get now;

  /// No description provided for @avg.
  ///
  /// In en, this message translates to:
  /// **'Avg'**
  String get avg;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @appts.
  ///
  /// In en, this message translates to:
  /// **'Appts'**
  String get appts;

  /// No description provided for @bpm.
  ///
  /// In en, this message translates to:
  /// **'bpm'**
  String get bpm;

  /// No description provided for @hrs.
  ///
  /// In en, this message translates to:
  /// **'hrs'**
  String get hrs;

  /// No description provided for @errorNetwork.
  ///
  /// In en, this message translates to:
  /// **'Network error. Please check your connection.'**
  String get errorNetwork;

  /// No description provided for @errorInvalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Invalid username or password.'**
  String get errorInvalidCredentials;

  /// No description provided for @errorServer.
  ///
  /// In en, this message translates to:
  /// **'Server error. Please try again.'**
  String get errorServer;

  /// No description provided for @errorPasswordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match.'**
  String get errorPasswordMismatch;

  /// No description provided for @errorEmptyFields.
  ///
  /// In en, this message translates to:
  /// **'Please fill in all fields.'**
  String get errorEmptyFields;

  /// No description provided for @firstNameLabel.
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get firstNameLabel;

  /// No description provided for @lastNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get lastNameLabel;

  /// No description provided for @usernameLabel.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get usernameLabel;

  /// No description provided for @findDoctors.
  ///
  /// In en, this message translates to:
  /// **'Find Doctors'**
  String get findDoctors;

  /// No description provided for @bookBestSpecialists.
  ///
  /// In en, this message translates to:
  /// **'Book the best specialists'**
  String get bookBestSpecialists;

  /// No description provided for @searchDoctor.
  ///
  /// In en, this message translates to:
  /// **'Search doctor, specialty...'**
  String get searchDoctor;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @cardiologist.
  ///
  /// In en, this message translates to:
  /// **'Cardiologist'**
  String get cardiologist;

  /// No description provided for @generalPhysician.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get generalPhysician;

  /// No description provided for @dermatologist.
  ///
  /// In en, this message translates to:
  /// **'Dermatologist'**
  String get dermatologist;

  /// No description provided for @dentist.
  ///
  /// In en, this message translates to:
  /// **'Dentist'**
  String get dentist;

  /// No description provided for @availableToday.
  ///
  /// In en, this message translates to:
  /// **'Available Today'**
  String get availableToday;

  /// No description provided for @tomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get tomorrow;

  /// No description provided for @nextSlot.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get nextSlot;

  /// No description provided for @agenda.
  ///
  /// In en, this message translates to:
  /// **'Agenda'**
  String get agenda;

  /// No description provided for @appointments.
  ///
  /// In en, this message translates to:
  /// **'Appointments'**
  String get appointments;

  /// No description provided for @manageVisits.
  ///
  /// In en, this message translates to:
  /// **'Manage your medical visits'**
  String get manageVisits;

  /// No description provided for @past.
  ///
  /// In en, this message translates to:
  /// **'Past'**
  String get past;

  /// No description provided for @confirmed.
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get confirmed;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @videoCall.
  ///
  /// In en, this message translates to:
  /// **'Video Call'**
  String get videoCall;

  /// No description provided for @inPerson.
  ///
  /// In en, this message translates to:
  /// **'In-Person'**
  String get inPerson;

  /// No description provided for @reminder.
  ///
  /// In en, this message translates to:
  /// **'Reminder'**
  String get reminder;

  /// No description provided for @join.
  ///
  /// In en, this message translates to:
  /// **'Join'**
  String get join;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @newAppointment.
  ///
  /// In en, this message translates to:
  /// **'+ New Appointment'**
  String get newAppointment;

  /// No description provided for @rappels.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get rappels;

  /// No description provided for @reminders.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get reminders;

  /// No description provided for @stayOnTrack.
  ///
  /// In en, this message translates to:
  /// **'Stay on track'**
  String get stayOnTrack;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'+ Add'**
  String get add;

  /// No description provided for @activeMeds.
  ///
  /// In en, this message translates to:
  /// **'Active\nMeds'**
  String get activeMeds;

  /// No description provided for @activeAppts.
  ///
  /// In en, this message translates to:
  /// **'Active\nAppts'**
  String get activeAppts;

  /// No description provided for @totalActive.
  ///
  /// In en, this message translates to:
  /// **'Total\nActive'**
  String get totalActive;

  /// No description provided for @visits.
  ///
  /// In en, this message translates to:
  /// **'Visits'**
  String get visits;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @bloodPressure.
  ///
  /// In en, this message translates to:
  /// **'Blood Pressure'**
  String get bloodPressure;

  /// No description provided for @bloodSugar.
  ///
  /// In en, this message translates to:
  /// **'Blood Sugar'**
  String get bloodSugar;

  /// No description provided for @cholesterol.
  ///
  /// In en, this message translates to:
  /// **'Cholesterol'**
  String get cholesterol;

  /// No description provided for @onceDaily.
  ///
  /// In en, this message translates to:
  /// **'Once daily'**
  String get onceDaily;

  /// No description provided for @twiceDaily.
  ///
  /// In en, this message translates to:
  /// **'Twice daily'**
  String get twiceDaily;

  /// No description provided for @messages.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get messages;

  /// No description provided for @searchMessages.
  ///
  /// In en, this message translates to:
  /// **'Search messages...'**
  String get searchMessages;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @languageLabel.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageLabel;

  /// No description provided for @health.
  ///
  /// In en, this message translates to:
  /// **'HEALTH'**
  String get health;

  /// No description provided for @healthGoals.
  ///
  /// In en, this message translates to:
  /// **'Health Goals'**
  String get healthGoals;

  /// No description provided for @healthIndicators.
  ///
  /// In en, this message translates to:
  /// **'Health Indicators'**
  String get healthIndicators;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'ACCOUNT'**
  String get account;

  /// No description provided for @personalInfo.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get personalInfo;

  /// No description provided for @emergencyContact.
  ///
  /// In en, this message translates to:
  /// **'Emergency Contact'**
  String get emergencyContact;

  /// No description provided for @insurance.
  ///
  /// In en, this message translates to:
  /// **'Insurance'**
  String get insurance;

  /// No description provided for @preferences.
  ///
  /// In en, this message translates to:
  /// **'PREFERENCES'**
  String get preferences;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @helpSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpSupport;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Soon'**
  String get comingSoon;

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'MediCare App v1.0.0'**
  String get appVersion;

  /// No description provided for @doctorsNavLabel.
  ///
  /// In en, this message translates to:
  /// **'Doctors'**
  String get doctorsNavLabel;

  /// No description provided for @piSaved.
  ///
  /// In en, this message translates to:
  /// **'Changes saved successfully'**
  String get piSaved;

  /// No description provided for @piErrorSave.
  ///
  /// In en, this message translates to:
  /// **'Failed to save changes'**
  String get piErrorSave;

  /// No description provided for @piTitle.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get piTitle;

  /// No description provided for @piSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Update your profile details'**
  String get piSubtitle;

  /// No description provided for @piSectionBasic.
  ///
  /// In en, this message translates to:
  /// **'Basic Information'**
  String get piSectionBasic;

  /// No description provided for @piFirstName.
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get piFirstName;

  /// No description provided for @piLastName.
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get piLastName;

  /// No description provided for @piEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get piEmail;

  /// No description provided for @piPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get piPhone;

  /// No description provided for @piAddress.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get piAddress;

  /// No description provided for @piCity.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get piCity;

  /// No description provided for @piPostalCode.
  ///
  /// In en, this message translates to:
  /// **'Postal Code'**
  String get piPostalCode;

  /// No description provided for @piSectionHealth.
  ///
  /// In en, this message translates to:
  /// **'Health Information'**
  String get piSectionHealth;

  /// No description provided for @piAge.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get piAge;

  /// No description provided for @piYears.
  ///
  /// In en, this message translates to:
  /// **'years'**
  String get piYears;

  /// No description provided for @piWeight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get piWeight;

  /// No description provided for @piKg.
  ///
  /// In en, this message translates to:
  /// **'kg'**
  String get piKg;

  /// No description provided for @piHeight.
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get piHeight;

  /// No description provided for @piCm.
  ///
  /// In en, this message translates to:
  /// **'cm'**
  String get piCm;

  /// No description provided for @piSectionMedical.
  ///
  /// In en, this message translates to:
  /// **'Medical History'**
  String get piSectionMedical;

  /// No description provided for @piMedicalHistory.
  ///
  /// In en, this message translates to:
  /// **'Medical History'**
  String get piMedicalHistory;

  /// No description provided for @piAllergies.
  ///
  /// In en, this message translates to:
  /// **'Allergies'**
  String get piAllergies;

  /// No description provided for @piSectionEmergency.
  ///
  /// In en, this message translates to:
  /// **'Emergency Contact'**
  String get piSectionEmergency;

  /// No description provided for @piEmergencyName.
  ///
  /// In en, this message translates to:
  /// **'Contact Name'**
  String get piEmergencyName;

  /// No description provided for @piEmergencyPhone.
  ///
  /// In en, this message translates to:
  /// **'Contact Phone'**
  String get piEmergencyPhone;

  /// No description provided for @piDob.
  ///
  /// In en, this message translates to:
  /// **'Date of Birth'**
  String get piDob;

  /// No description provided for @piGender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get piGender;

  /// No description provided for @piGenderMale.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get piGenderMale;

  /// No description provided for @piGenderFemale.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get piGenderFemale;

  /// No description provided for @piBloodType.
  ///
  /// In en, this message translates to:
  /// **'Blood Type'**
  String get piBloodType;

  /// No description provided for @piSaving.
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get piSaving;

  /// No description provided for @piSave.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get piSave;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
