import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of S
/// returned by `S.of(context)`.
///
/// Applications need to include `S.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: S.localizationsDelegates,
///   supportedLocales: S.supportedLocales,
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
/// be consistent with the languages listed in the S.supportedLocales
/// property.
abstract class S {
  S(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static S of(BuildContext context) {
    return Localizations.of<S>(context, S)!;
  }

  static const LocalizationsDelegate<S> delegate = _SDelegate();

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
  ];

  /// App display name
  ///
  /// In en, this message translates to:
  /// **'Fahis'**
  String get appName;

  /// No description provided for @cancelBtn.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelBtn;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'skip'**
  String get skip;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @submitBtn.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submitBtn;

  /// No description provided for @nextBtn.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get nextBtn;

  /// No description provided for @backBtn.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get backBtn;

  /// No description provided for @requestId.
  ///
  /// In en, this message translates to:
  /// **'Request ID'**
  String get requestId;

  /// No description provided for @deleteBtn.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteBtn;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// No description provided for @updateAssets.
  ///
  /// In en, this message translates to:
  /// **'Assets Upgrade'**
  String get updateAssets;

  /// No description provided for @offlineMode.
  ///
  /// In en, this message translates to:
  /// **'Offline Mode'**
  String get offlineMode;

  /// No description provided for @allItems.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get allItems;

  /// No description provided for @sessionExpired.
  ///
  /// In en, this message translates to:
  /// **'Session Expired'**
  String get sessionExpired;

  /// No description provided for @sessionExpiredMsg.
  ///
  /// In en, this message translates to:
  /// **'You signed in elsewhere. Please log in again.'**
  String get sessionExpiredMsg;

  /// No description provided for @fieldRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required.'**
  String get fieldRequired;

  /// No description provided for @vinMustBe17.
  ///
  /// In en, this message translates to:
  /// **'Must be 17 characters.'**
  String get vinMustBe17;

  /// No description provided for @ccNumbersOnly.
  ///
  /// In en, this message translates to:
  /// **'Only digits allowed.'**
  String get ccNumbersOnly;

  /// No description provided for @colorNoNumbers.
  ///
  /// In en, this message translates to:
  /// **'Color cannot contain numbers.'**
  String get colorNoNumbers;

  /// No description provided for @milageNumbersOnly.
  ///
  /// In en, this message translates to:
  /// **'Must be a number.'**
  String get milageNumbersOnly;

  /// No description provided for @pendingStatus.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pendingStatus;

  /// No description provided for @acceptedStatus.
  ///
  /// In en, this message translates to:
  /// **'Accepted'**
  String get acceptedStatus;

  /// No description provided for @inProgressStatus.
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get inProgressStatus;

  /// No description provided for @finishedStatus.
  ///
  /// In en, this message translates to:
  /// **'Finished'**
  String get finishedStatus;

  /// No description provided for @rejectedStatus.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get rejectedStatus;

  /// No description provided for @reviewedStatus.
  ///
  /// In en, this message translates to:
  /// **'Reviewed'**
  String get reviewedStatus;

  /// No description provided for @settingsAndSupport.
  ///
  /// In en, this message translates to:
  /// **'Settings & Support'**
  String get settingsAndSupport;

  /// No description provided for @helpAndSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpAndSupport;

  /// No description provided for @unSelected.
  ///
  /// In en, this message translates to:
  /// **'Not Selected'**
  String get unSelected;

  /// No description provided for @more.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get more;

  /// No description provided for @forgetSubTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your mobile number and we will send you a verification code'**
  String get forgetSubTitle;

  /// No description provided for @saveBtn.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveBtn;

  /// No description provided for @editBtn.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get editBtn;

  /// No description provided for @reviewBtn.
  ///
  /// In en, this message translates to:
  /// **'Review Inspection'**
  String get reviewBtn;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @skipBtn.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skipBtn;

  /// No description provided for @reload.
  ///
  /// In en, this message translates to:
  /// **'Reload'**
  String get reload;

  /// No description provided for @goToSettings.
  ///
  /// In en, this message translates to:
  /// **'Go to settings'**
  String get goToSettings;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get welcomeBack;

  /// No description provided for @automatic.
  ///
  /// In en, this message translates to:
  /// **'Automatic'**
  String get automatic;

  /// No description provided for @manual.
  ///
  /// In en, this message translates to:
  /// **'Manual'**
  String get manual;

  /// No description provided for @fabric.
  ///
  /// In en, this message translates to:
  /// **'Fabric'**
  String get fabric;

  /// No description provided for @leather.
  ///
  /// In en, this message translates to:
  /// **'Leather'**
  String get leather;

  /// No description provided for @inProgress.
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get inProgress;

  /// No description provided for @pended.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pended;

  /// No description provided for @approved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get approved;

  /// No description provided for @finished.
  ///
  /// In en, this message translates to:
  /// **'Finished'**
  String get finished;

  /// No description provided for @good.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get good;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get notes;

  /// No description provided for @na.
  ///
  /// In en, this message translates to:
  /// **'N/A'**
  String get na;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Inspection Center App'**
  String get loginTitle;

  /// No description provided for @loginSubTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get loginSubTitle;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @phoneNumberValidation.
  ///
  /// In en, this message translates to:
  /// **'Phone Number must be a correct'**
  String get phoneNumberValidation;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email or mobile'**
  String get email;

  /// No description provided for @emailValidation.
  ///
  /// In en, this message translates to:
  /// **'Password must be bigger than 8 characters'**
  String get emailValidation;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @passwordValidation.
  ///
  /// In en, this message translates to:
  /// **'Password Validation'**
  String get passwordValidation;

  /// No description provided for @rememberMe.
  ///
  /// In en, this message translates to:
  /// **'Remember me'**
  String get rememberMe;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @verifyOTP.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verifyOTP;

  /// No description provided for @resetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPassword;

  /// No description provided for @resetPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your new password below.'**
  String get resetPasswordSubtitle;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @passwordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordMismatch;

  /// No description provided for @forgetBTN.
  ///
  /// In en, this message translates to:
  /// **'Forget password?'**
  String get forgetBTN;

  /// No description provided for @loginWithEmail.
  ///
  /// In en, this message translates to:
  /// **'Login using email address'**
  String get loginWithEmail;

  /// No description provided for @otpTitle.
  ///
  /// In en, this message translates to:
  /// **'One-Time Password'**
  String get otpTitle;

  /// No description provided for @resendBtnWithTime.
  ///
  /// In en, this message translates to:
  /// **'Resend (after {s} \'s)'**
  String resendBtnWithTime(int s);

  /// No description provided for @resendBtn.
  ///
  /// In en, this message translates to:
  /// **'Resend'**
  String get resendBtn;

  /// No description provided for @editPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Edit phone number'**
  String get editPhoneNumber;

  /// No description provided for @processingTitle.
  ///
  /// In en, this message translates to:
  /// **'Logging in and processing data ...'**
  String get processingTitle;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search for a plate number....'**
  String get searchHint;

  /// No description provided for @request.
  ///
  /// In en, this message translates to:
  /// **'Requests'**
  String get request;

  /// No description provided for @searchPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Search...'**
  String get searchPlaceholder;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @homePageOnEmpty.
  ///
  /// In en, this message translates to:
  /// **'There is no request yet'**
  String get homePageOnEmpty;

  /// No description provided for @homePageOnError.
  ///
  /// In en, this message translates to:
  /// **'There is an error occurred'**
  String get homePageOnError;

  /// No description provided for @homePageNoMore.
  ///
  /// In en, this message translates to:
  /// **'There is no request yet'**
  String get homePageNoMore;

  /// No description provided for @generalInfo.
  ///
  /// In en, this message translates to:
  /// **'General Information'**
  String get generalInfo;

  /// No description provided for @vehicleInfo.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Information'**
  String get vehicleInfo;

  /// No description provided for @connectPersonInfo.
  ///
  /// In en, this message translates to:
  /// **'Connect Person Information'**
  String get connectPersonInfo;

  /// No description provided for @inspectionPointReview.
  ///
  /// In en, this message translates to:
  /// **'Inspection Point Review'**
  String get inspectionPointReview;

  /// No description provided for @inspectionType.
  ///
  /// In en, this message translates to:
  /// **'Inspection Type'**
  String get inspectionType;

  /// No description provided for @inspectionCenter.
  ///
  /// In en, this message translates to:
  /// **'Inspection Center'**
  String get inspectionCenter;

  /// No description provided for @centerBranch.
  ///
  /// In en, this message translates to:
  /// **'Center Branch'**
  String get centerBranch;

  /// No description provided for @inspectionCity.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get inspectionCity;

  /// No description provided for @bookingDate.
  ///
  /// In en, this message translates to:
  /// **'Booking Date'**
  String get bookingDate;

  /// No description provided for @assignedTo.
  ///
  /// In en, this message translates to:
  /// **'Assigned To'**
  String get assignedTo;

  /// No description provided for @inspector.
  ///
  /// In en, this message translates to:
  /// **'Inspector'**
  String get inspector;

  /// No description provided for @inspectedAt.
  ///
  /// In en, this message translates to:
  /// **'Inspected At'**
  String get inspectedAt;

  /// No description provided for @reviewedAt.
  ///
  /// In en, this message translates to:
  /// **'Reviewed At'**
  String get reviewedAt;

  /// No description provided for @createdAt.
  ///
  /// In en, this message translates to:
  /// **'Created At'**
  String get createdAt;

  /// No description provided for @inspectorNote.
  ///
  /// In en, this message translates to:
  /// **'Inspector Note'**
  String get inspectorNote;

  /// No description provided for @reviewerNote.
  ///
  /// In en, this message translates to:
  /// **'Reviewer Note'**
  String get reviewerNote;

  /// No description provided for @notYet.
  ///
  /// In en, this message translates to:
  /// **'Not Set Yet'**
  String get notYet;

  /// No description provided for @anyInspector.
  ///
  /// In en, this message translates to:
  /// **'All Inspectors'**
  String get anyInspector;

  /// No description provided for @vin.
  ///
  /// In en, this message translates to:
  /// **'VIN'**
  String get vin;

  /// No description provided for @serialNo.
  ///
  /// In en, this message translates to:
  /// **'Serial No'**
  String get serialNo;

  /// No description provided for @make.
  ///
  /// In en, this message translates to:
  /// **'Make'**
  String get make;

  /// No description provided for @model.
  ///
  /// In en, this message translates to:
  /// **'Model'**
  String get model;

  /// No description provided for @storageSize.
  ///
  /// In en, this message translates to:
  /// **'Storage Size'**
  String get storageSize;

  /// No description provided for @vehicleShape.
  ///
  /// In en, this message translates to:
  /// **'vehicle Shape'**
  String get vehicleShape;

  /// No description provided for @yearModel.
  ///
  /// In en, this message translates to:
  /// **'Year Model'**
  String get yearModel;

  /// No description provided for @plate.
  ///
  /// In en, this message translates to:
  /// **'Plate'**
  String get plate;

  /// No description provided for @contactName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get contactName;

  /// No description provided for @contactEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get contactEmail;

  /// No description provided for @contactPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get contactPhone;

  /// No description provided for @contactCity.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get contactCity;

  /// No description provided for @inspectionPhotos.
  ///
  /// In en, this message translates to:
  /// **'Inspection Photos'**
  String get inspectionPhotos;

  /// No description provided for @inspectionBodyNotes.
  ///
  /// In en, this message translates to:
  /// **'Inspection Body Notes'**
  String get inspectionBodyNotes;

  /// No description provided for @inspectionOBDCodes.
  ///
  /// In en, this message translates to:
  /// **'Inspection OBD Codes'**
  String get inspectionOBDCodes;

  /// No description provided for @loadingInspectionDetails.
  ///
  /// In en, this message translates to:
  /// **'Loading inspection details...'**
  String get loadingInspectionDetails;

  /// No description provided for @noteLabel.
  ///
  /// In en, this message translates to:
  /// **'Note {index}'**
  String noteLabel(int index);

  /// No description provided for @positionLabel.
  ///
  /// In en, this message translates to:
  /// **'Position: ({dx}, {dy})'**
  String positionLabel(String dx, String dy);

  /// No description provided for @notesCount.
  ///
  /// In en, this message translates to:
  /// **'{count} notes'**
  String notesCount(int count);

  /// No description provided for @pointsReview.
  ///
  /// In en, this message translates to:
  /// **'Points Review'**
  String get pointsReview;

  /// No description provided for @inspectionDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Inspection Details'**
  String get inspectionDetailsTitle;

  /// No description provided for @doneBtn.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get doneBtn;

  /// No description provided for @remaining.
  ///
  /// In en, this message translates to:
  /// **'remaining'**
  String get remaining;

  /// No description provided for @imageRequired.
  ///
  /// In en, this message translates to:
  /// **'Image Required'**
  String get imageRequired;

  /// No description provided for @imageRequiredMsg.
  ///
  /// In en, this message translates to:
  /// **'You should document the note with an image that describes the status'**
  String get imageRequiredMsg;

  /// No description provided for @noteRequired.
  ///
  /// In en, this message translates to:
  /// **'Note Required'**
  String get noteRequired;

  /// No description provided for @noteRequiredMsg.
  ///
  /// In en, this message translates to:
  /// **'You should describe the status'**
  String get noteRequiredMsg;

  /// No description provided for @resetPointsTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset Points'**
  String get resetPointsTitle;

  /// No description provided for @resetPointsContent.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to reset all points? This will delete all changes on the current points.'**
  String get resetPointsContent;

  /// No description provided for @resetPointsConfirm.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get resetPointsConfirm;

  /// No description provided for @selectStatus.
  ///
  /// In en, this message translates to:
  /// **'Select Status'**
  String get selectStatus;

  /// No description provided for @addNoteTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Note'**
  String get addNoteTitle;

  /// No description provided for @noteSavedSuccessMsg.
  ///
  /// In en, this message translates to:
  /// **'The note has been saved successfully'**
  String get noteSavedSuccessMsg;

  /// No description provided for @noteHint.
  ///
  /// In en, this message translates to:
  /// **'Type your note here...'**
  String get noteHint;

  /// No description provided for @noteFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get noteFieldLabel;

  /// No description provided for @noteValidation.
  ///
  /// In en, this message translates to:
  /// **'Note is required'**
  String get noteValidation;

  /// No description provided for @photosTitle.
  ///
  /// In en, this message translates to:
  /// **'Photos'**
  String get photosTitle;

  /// No description provided for @uploadedPhotos.
  ///
  /// In en, this message translates to:
  /// **'Uploaded'**
  String get uploadedPhotos;

  /// No description provided for @availablePhotos.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get availablePhotos;

  /// No description provided for @photoUploaded.
  ///
  /// In en, this message translates to:
  /// **'Uploaded'**
  String get photoUploaded;

  /// No description provided for @addPhoto.
  ///
  /// In en, this message translates to:
  /// **'Add Photo'**
  String get addPhoto;

  /// No description provided for @selectPhotoTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Photo to Capture'**
  String get selectPhotoTitle;

  /// No description provided for @noPhotosYet.
  ///
  /// In en, this message translates to:
  /// **'No photos yet'**
  String get noPhotosYet;

  /// No description provided for @photosProgress.
  ///
  /// In en, this message translates to:
  /// **'{uploaded} / {total} photos'**
  String photosProgress(int uploaded, int total);

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take Photo'**
  String get takePhoto;

  /// No description provided for @deletePhoto.
  ///
  /// In en, this message translates to:
  /// **'Delete Photo'**
  String get deletePhoto;

  /// No description provided for @deletePhotoConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this photo?'**
  String get deletePhotoConfirm;

  /// No description provided for @photoDeletedSuccess.
  ///
  /// In en, this message translates to:
  /// **'The photo was removed successfully.'**
  String get photoDeletedSuccess;

  /// No description provided for @deleteAllPhotos.
  ///
  /// In en, this message translates to:
  /// **'Delete All Photos'**
  String get deleteAllPhotos;

  /// No description provided for @deleteAllPhotosConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure? All uploaded photos will be deleted and reset.'**
  String get deleteAllPhotosConfirm;

  /// No description provided for @deleteAllPhotosSuccess.
  ///
  /// In en, this message translates to:
  /// **'All photos have been deleted successfully.'**
  String get deleteAllPhotosSuccess;

  /// No description provided for @deleteObdCode.
  ///
  /// In en, this message translates to:
  /// **'Delete Code'**
  String get deleteObdCode;

  /// No description provided for @deleteObdCodeConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this OBD code?'**
  String get deleteObdCodeConfirm;

  /// No description provided for @deleteBodyNote.
  ///
  /// In en, this message translates to:
  /// **'Delete Note'**
  String get deleteBodyNote;

  /// No description provided for @deleteBodyNoteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this note?'**
  String get deleteBodyNoteConfirm;

  /// No description provided for @photoCategoryExterior.
  ///
  /// In en, this message translates to:
  /// **'Exterior'**
  String get photoCategoryExterior;

  /// No description provided for @photoCategoryInterior.
  ///
  /// In en, this message translates to:
  /// **'Interior'**
  String get photoCategoryInterior;

  /// No description provided for @startInspection.
  ///
  /// In en, this message translates to:
  /// **'Start Inspection'**
  String get startInspection;

  /// No description provided for @generalNoteTitle.
  ///
  /// In en, this message translates to:
  /// **'Submit Inspection'**
  String get generalNoteTitle;

  /// No description provided for @rejectionNoteTitle.
  ///
  /// In en, this message translates to:
  /// **'Reject Inspection'**
  String get rejectionNoteTitle;

  /// No description provided for @noteOptionalHint.
  ///
  /// In en, this message translates to:
  /// **'Add a note (optional)...'**
  String get noteOptionalHint;

  /// No description provided for @confirmSubmit.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirmSubmit;

  /// No description provided for @inspectionCancelBtn.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get inspectionCancelBtn;

  /// No description provided for @submitConfirmSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to submit this inspection?'**
  String get submitConfirmSubtitle;

  /// No description provided for @rejectConfirmSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to reject this inspection?'**
  String get rejectConfirmSubtitle;

  /// No description provided for @addNoteLabel.
  ///
  /// In en, this message translates to:
  /// **'Add Note'**
  String get addNoteLabel;

  /// No description provided for @optionalTag.
  ///
  /// In en, this message translates to:
  /// **'optional'**
  String get optionalTag;

  /// No description provided for @obdFileName.
  ///
  /// In en, this message translates to:
  /// **'OBD Report'**
  String get obdFileName;

  /// No description provided for @uploadObdReport.
  ///
  /// In en, this message translates to:
  /// **'Upload OBD Report'**
  String get uploadObdReport;

  /// No description provided for @obdCodesTitle.
  ///
  /// In en, this message translates to:
  /// **'OBD Codes'**
  String get obdCodesTitle;

  /// No description provided for @obdCodeRequired.
  ///
  /// In en, this message translates to:
  /// **'Code Required'**
  String get obdCodeRequired;

  /// No description provided for @obdCodeRequiredMsg.
  ///
  /// In en, this message translates to:
  /// **'Please enter the OBD code'**
  String get obdCodeRequiredMsg;

  /// No description provided for @obdDescRequired.
  ///
  /// In en, this message translates to:
  /// **'Description Required'**
  String get obdDescRequired;

  /// No description provided for @obdDescRequiredMsg.
  ///
  /// In en, this message translates to:
  /// **'Please enter the code description'**
  String get obdDescRequiredMsg;

  /// No description provided for @finishOnlineRequired.
  ///
  /// In en, this message translates to:
  /// **'Connection Required'**
  String get finishOnlineRequired;

  /// No description provided for @finishOnlineRequiredMsg.
  ///
  /// In en, this message translates to:
  /// **'Finishing the inspection requires an internet connection. Please reconnect and try again.'**
  String get finishOnlineRequiredMsg;

  /// No description provided for @finishObdIncomplete.
  ///
  /// In en, this message translates to:
  /// **'OBD Codes Incomplete'**
  String get finishObdIncomplete;

  /// No description provided for @finishObdIncompleteMsg.
  ///
  /// In en, this message translates to:
  /// **'Some OBD codes are missing a description or are still pending sync. Tap each pending code to complete it before finishing the inspection.'**
  String get finishObdIncompleteMsg;

  /// No description provided for @obdDataRequired.
  ///
  /// In en, this message translates to:
  /// **'OBD Data Required'**
  String get obdDataRequired;

  /// No description provided for @obdDataRequiredMsg.
  ///
  /// In en, this message translates to:
  /// **'Please upload a report file or add at least one OBD code before proceeding'**
  String get obdDataRequiredMsg;

  /// No description provided for @obdFileTooLarge.
  ///
  /// In en, this message translates to:
  /// **'File Too Large'**
  String get obdFileTooLarge;

  /// No description provided for @obdFileTooLargeMsg.
  ///
  /// In en, this message translates to:
  /// **'File must be less than 1 MB'**
  String get obdFileTooLargeMsg;

  /// No description provided for @obdUploadSuccess.
  ///
  /// In en, this message translates to:
  /// **'Report uploaded successfully'**
  String get obdUploadSuccess;

  /// No description provided for @obdUploadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to upload report'**
  String get obdUploadFailed;

  /// No description provided for @obdDeleteSuccess.
  ///
  /// In en, this message translates to:
  /// **'Report deleted'**
  String get obdDeleteSuccess;

  /// No description provided for @obdDeleteReportTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Report'**
  String get obdDeleteReportTitle;

  /// No description provided for @obdDeleteReportConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete the OBD report?'**
  String get obdDeleteReportConfirm;

  /// No description provided for @obdCodeDeletedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Code Deleted'**
  String get obdCodeDeletedSuccess;

  /// No description provided for @obdCodeDeletedSuccessMsg.
  ///
  /// In en, this message translates to:
  /// **'OBD code has been deleted successfully'**
  String get obdCodeDeletedSuccessMsg;

  /// No description provided for @obdCodeAddSuccess.
  ///
  /// In en, this message translates to:
  /// **'Code Added'**
  String get obdCodeAddSuccess;

  /// No description provided for @obdCodeAddSuccessMsg.
  ///
  /// In en, this message translates to:
  /// **'OBD code has been added successfully'**
  String get obdCodeAddSuccessMsg;

  /// No description provided for @obdCodeEditSuccess.
  ///
  /// In en, this message translates to:
  /// **'Code Updated'**
  String get obdCodeEditSuccess;

  /// No description provided for @obdCodeEditSuccessMsg.
  ///
  /// In en, this message translates to:
  /// **'OBD code has been updated successfully'**
  String get obdCodeEditSuccessMsg;

  /// No description provided for @obdActionError.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong, please try again'**
  String get obdActionError;

  /// No description provided for @obdAddCode.
  ///
  /// In en, this message translates to:
  /// **'Add OBD Code'**
  String get obdAddCode;

  /// No description provided for @obdEditCode.
  ///
  /// In en, this message translates to:
  /// **'Edit OBD Code'**
  String get obdEditCode;

  /// No description provided for @obdCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'OBD Code'**
  String get obdCodeLabel;

  /// No description provided for @obdCodeHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. P0300'**
  String get obdCodeHint;

  /// No description provided for @obdDescLabel.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get obdDescLabel;

  /// No description provided for @obdDescHint.
  ///
  /// In en, this message translates to:
  /// **'Code description...'**
  String get obdDescHint;

  /// No description provided for @obdNoCodesYet.
  ///
  /// In en, this message translates to:
  /// **'No OBD codes yet'**
  String get obdNoCodesYet;

  /// No description provided for @bodyNotesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No body notes yet'**
  String get bodyNotesEmpty;

  /// No description provided for @obdReportSection.
  ///
  /// In en, this message translates to:
  /// **'OBD Report'**
  String get obdReportSection;

  /// No description provided for @obdOptionalBadge.
  ///
  /// In en, this message translates to:
  /// **'optional'**
  String get obdOptionalBadge;

  /// No description provided for @obdConnectDevice.
  ///
  /// In en, this message translates to:
  /// **'Connect device'**
  String get obdConnectDevice;

  /// No description provided for @obdDisconnect.
  ///
  /// In en, this message translates to:
  /// **'Disconnect'**
  String get obdDisconnect;

  /// No description provided for @obdReadFromDevice.
  ///
  /// In en, this message translates to:
  /// **'Read from device'**
  String get obdReadFromDevice;

  /// No description provided for @obdConnecting.
  ///
  /// In en, this message translates to:
  /// **'Connecting…'**
  String get obdConnecting;

  /// No description provided for @obdReadingCodes.
  ///
  /// In en, this message translates to:
  /// **'Reading codes…'**
  String get obdReadingCodes;

  /// No description provided for @obdConnectionFailed.
  ///
  /// In en, this message translates to:
  /// **'Connection failed'**
  String get obdConnectionFailed;

  /// No description provided for @obdEcuConnectFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t reach the vehicle ECU. Make sure the engine is running and the OBD-II port is properly seated.'**
  String get obdEcuConnectFailed;

  /// No description provided for @obdDeviceDisconnected.
  ///
  /// In en, this message translates to:
  /// **'Device disconnected'**
  String get obdDeviceDisconnected;

  /// No description provided for @obdReconnect.
  ///
  /// In en, this message translates to:
  /// **'Reconnect'**
  String get obdReconnect;

  /// No description provided for @obdNoCodesFromDevice.
  ///
  /// In en, this message translates to:
  /// **'No error codes found'**
  String get obdNoCodesFromDevice;

  /// No description provided for @obdNoNewCodes.
  ///
  /// In en, this message translates to:
  /// **'No new codes from device'**
  String get obdNoNewCodes;

  /// No description provided for @obdCodesAdded.
  ///
  /// In en, this message translates to:
  /// **'Added {count} code(s) from device'**
  String obdCodesAdded(int count);

  /// No description provided for @obdScanTitle.
  ///
  /// In en, this message translates to:
  /// **'Select OBD device'**
  String get obdScanTitle;

  /// No description provided for @obdBleNotSupported.
  ///
  /// In en, this message translates to:
  /// **'Bluetooth not supported on this device'**
  String get obdBleNotSupported;

  /// No description provided for @obdBleOff.
  ///
  /// In en, this message translates to:
  /// **'Please enable Bluetooth'**
  String get obdBleOff;

  /// No description provided for @obdBlePermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Bluetooth permission required'**
  String get obdBlePermissionDenied;

  /// No description provided for @obdConnectedTo.
  ///
  /// In en, this message translates to:
  /// **'Connected: {name}'**
  String obdConnectedTo(String name);

  /// No description provided for @obdAddManualCode.
  ///
  /// In en, this message translates to:
  /// **'Add Manually'**
  String get obdAddManualCode;

  /// No description provided for @obdScanStart.
  ///
  /// In en, this message translates to:
  /// **'Scan Devices'**
  String get obdScanStart;

  /// No description provided for @obdScanStop.
  ///
  /// In en, this message translates to:
  /// **'Stop Scan'**
  String get obdScanStop;

  /// No description provided for @obdScanEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No devices found'**
  String get obdScanEmptyTitle;

  /// No description provided for @obdScanEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'Tap \"Scan Devices\" to start'**
  String get obdScanEmptyHint;

  /// No description provided for @obdScanScanningTitle.
  ///
  /// In en, this message translates to:
  /// **'Scanning…'**
  String get obdScanScanningTitle;

  /// No description provided for @obdScanScanningHint.
  ///
  /// In en, this message translates to:
  /// **'Turn on Bluetooth and place the Veepeak device nearby to scan'**
  String get obdScanScanningHint;

  /// No description provided for @obdScanSectionNamed.
  ///
  /// In en, this message translates to:
  /// **'Available Devices'**
  String get obdScanSectionNamed;

  /// No description provided for @obdScanUnknownDevice.
  ///
  /// In en, this message translates to:
  /// **'Unknown Device'**
  String get obdScanUnknownDevice;

  /// No description provided for @obdScanRecommended.
  ///
  /// In en, this message translates to:
  /// **'Recommended'**
  String get obdScanRecommended;

  /// No description provided for @obdFromDevice.
  ///
  /// In en, this message translates to:
  /// **'Read from device'**
  String get obdFromDevice;

  /// No description provided for @obdAddedCodesList.
  ///
  /// In en, this message translates to:
  /// **'Added Codes'**
  String get obdAddedCodesList;

  /// No description provided for @obdPairNewDevice.
  ///
  /// In en, this message translates to:
  /// **'Pair Device'**
  String get obdPairNewDevice;

  /// No description provided for @stepLabel.
  ///
  /// In en, this message translates to:
  /// **'Step {step}'**
  String stepLabel(String step);

  /// No description provided for @submitValidationTitle.
  ///
  /// In en, this message translates to:
  /// **'Cannot Submit'**
  String get submitValidationTitle;

  /// No description provided for @submitValidationMsg.
  ///
  /// In en, this message translates to:
  /// **'Please complete all steps before submitting:'**
  String get submitValidationMsg;

  /// No description provided for @submitSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Submitted'**
  String get submitSuccessTitle;

  /// No description provided for @submitSuccessMsg.
  ///
  /// In en, this message translates to:
  /// **'Inspection submitted successfully'**
  String get submitSuccessMsg;

  /// No description provided for @stepIncomplete.
  ///
  /// In en, this message translates to:
  /// **'{step} is incomplete'**
  String stepIncomplete(String step);

  /// No description provided for @stepVehicleInfo.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Info'**
  String get stepVehicleInfo;

  /// No description provided for @stepPoints.
  ///
  /// In en, this message translates to:
  /// **'Inspection Points'**
  String get stepPoints;

  /// No description provided for @stepPhotos.
  ///
  /// In en, this message translates to:
  /// **'Photos'**
  String get stepPhotos;

  /// No description provided for @stepBody.
  ///
  /// In en, this message translates to:
  /// **'Body Notes'**
  String get stepBody;

  /// No description provided for @stepObd.
  ///
  /// In en, this message translates to:
  /// **'OBD'**
  String get stepObd;

  /// No description provided for @vehicleInfoRequired.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Info Required'**
  String get vehicleInfoRequired;

  /// No description provided for @vehicleInfoRequiredMsg.
  ///
  /// In en, this message translates to:
  /// **'Please fill in all vehicle information fields before proceeding'**
  String get vehicleInfoRequiredMsg;

  /// No description provided for @allPointsRequired.
  ///
  /// In en, this message translates to:
  /// **'All Points Required'**
  String get allPointsRequired;

  /// No description provided for @allPointsRequiredMsg.
  ///
  /// In en, this message translates to:
  /// **'Please fill in all inspection points before proceeding'**
  String get allPointsRequiredMsg;

  /// No description provided for @pointsRequired.
  ///
  /// In en, this message translates to:
  /// **'Points Required'**
  String get pointsRequired;

  /// No description provided for @pointsRequiredMsg.
  ///
  /// In en, this message translates to:
  /// **'At least one inspection point must be filled'**
  String get pointsRequiredMsg;

  /// No description provided for @photosRequired.
  ///
  /// In en, this message translates to:
  /// **'Photos Required'**
  String get photosRequired;

  /// No description provided for @photosRequiredMsg.
  ///
  /// In en, this message translates to:
  /// **'At least one photo must be uploaded before proceeding'**
  String get photosRequiredMsg;

  /// No description provided for @allPhotosRequired.
  ///
  /// In en, this message translates to:
  /// **'All Photos Required'**
  String get allPhotosRequired;

  /// No description provided for @allPhotosRequiredMsg.
  ///
  /// In en, this message translates to:
  /// **'Please upload all required photos before proceeding'**
  String get allPhotosRequiredMsg;

  /// No description provided for @generatDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Alert !'**
  String get generatDialogTitle;

  /// No description provided for @generatDialogContent.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to reset all points? This will delete all changes on the current points.'**
  String get generatDialogContent;

  /// No description provided for @generatDialogConfirmBtn.
  ///
  /// In en, this message translates to:
  /// **'Regenerate'**
  String get generatDialogConfirmBtn;

  /// No description provided for @generatDialogCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get generatDialogCancel;

  /// No description provided for @pageTitle.
  ///
  /// In en, this message translates to:
  /// **'Inspection No.{inspection}'**
  String pageTitle(String inspection);

  /// No description provided for @reviewNoteTitle.
  ///
  /// In en, this message translates to:
  /// **'Review Notes :'**
  String get reviewNoteTitle;

  /// No description provided for @vehicleInfoTile.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Information'**
  String get vehicleInfoTile;

  /// No description provided for @requestInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Request Information'**
  String get requestInfoTitle;

  /// No description provided for @inspectionPointResults.
  ///
  /// In en, this message translates to:
  /// **'Inspection Point Results'**
  String get inspectionPointResults;

  /// No description provided for @defaultValidationIfNull.
  ///
  /// In en, this message translates to:
  /// **'The value must be entered'**
  String get defaultValidationIfNull;

  /// No description provided for @defaultValidation.
  ///
  /// In en, this message translates to:
  /// **'The value must be of 3 characters or more'**
  String get defaultValidation;

  /// No description provided for @pointCategories.
  ///
  /// In en, this message translates to:
  /// **'Point Categories'**
  String get pointCategories;

  /// No description provided for @detailsVin.
  ///
  /// In en, this message translates to:
  /// **'VIN'**
  String get detailsVin;

  /// No description provided for @vinHint.
  ///
  /// In en, this message translates to:
  /// **'Enter VIN'**
  String get vinHint;

  /// No description provided for @vinValidationIfNull.
  ///
  /// In en, this message translates to:
  /// **'The VIN must be entered'**
  String get vinValidationIfNull;

  /// No description provided for @vinValidation.
  ///
  /// In en, this message translates to:
  /// **'The VIN length must be 17'**
  String get vinValidation;

  /// No description provided for @vinSearchBtn.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get vinSearchBtn;

  /// No description provided for @vinSearching.
  ///
  /// In en, this message translates to:
  /// **'Searching...'**
  String get vinSearching;

  /// No description provided for @vinFound.
  ///
  /// In en, this message translates to:
  /// **'Vehicle data found'**
  String get vinFound;

  /// No description provided for @vinFoundMsg.
  ///
  /// In en, this message translates to:
  /// **'Fields have been auto-filled. You can edit them.'**
  String get vinFoundMsg;

  /// No description provided for @vinNotFound.
  ///
  /// In en, this message translates to:
  /// **'Vehicle not found'**
  String get vinNotFound;

  /// No description provided for @vinNotFoundMsg.
  ///
  /// In en, this message translates to:
  /// **'No data for this VIN. You can fill in manually.'**
  String get vinNotFoundMsg;

  /// No description provided for @vinSearchError.
  ///
  /// In en, this message translates to:
  /// **'Search failed'**
  String get vinSearchError;

  /// No description provided for @vinSearchErrorMsg.
  ///
  /// In en, this message translates to:
  /// **'Could not search. Please try again.'**
  String get vinSearchErrorMsg;

  /// No description provided for @vinHelperTyping.
  ///
  /// In en, this message translates to:
  /// **'Enter 17 characters to search vehicle data automatically'**
  String get vinHelperTyping;

  /// No description provided for @vinHelperReady.
  ///
  /// In en, this message translates to:
  /// **'Tap search to auto-fill vehicle details'**
  String get vinHelperReady;

  /// No description provided for @sectionIdentification.
  ///
  /// In en, this message translates to:
  /// **'Identification'**
  String get sectionIdentification;

  /// No description provided for @sectionSpecifications.
  ///
  /// In en, this message translates to:
  /// **'Specifications'**
  String get sectionSpecifications;

  /// No description provided for @sectionInterior.
  ///
  /// In en, this message translates to:
  /// **'Colors & Seating'**
  String get sectionInterior;

  /// No description provided for @plateNumber.
  ///
  /// In en, this message translates to:
  /// **'Plate Number'**
  String get plateNumber;

  /// No description provided for @plateNumberHint.
  ///
  /// In en, this message translates to:
  /// **'Enter Plate Number'**
  String get plateNumberHint;

  /// No description provided for @plateNumberValidationIfNull.
  ///
  /// In en, this message translates to:
  /// **'The Car Plate must be entered'**
  String get plateNumberValidationIfNull;

  /// No description provided for @plateNumberValidation.
  ///
  /// In en, this message translates to:
  /// **'Please complete the plate: 3 letters and 4 digits required'**
  String get plateNumberValidation;

  /// No description provided for @plateLettersLabel.
  ///
  /// In en, this message translates to:
  /// **'Letters'**
  String get plateLettersLabel;

  /// No description provided for @plateNumbersLabel.
  ///
  /// In en, this message translates to:
  /// **'Numbers'**
  String get plateNumbersLabel;

  /// No description provided for @bodyType.
  ///
  /// In en, this message translates to:
  /// **'Body Type'**
  String get bodyType;

  /// No description provided for @bodyTypeValidation.
  ///
  /// In en, this message translates to:
  /// **'Automatic'**
  String get bodyTypeValidation;

  /// No description provided for @drivetrain.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Drivetrain'**
  String get drivetrain;

  /// No description provided for @drivetrainValidation.
  ///
  /// In en, this message translates to:
  /// **'Automatic'**
  String get drivetrainValidation;

  /// No description provided for @fuelType.
  ///
  /// In en, this message translates to:
  /// **'Fuel Type'**
  String get fuelType;

  /// No description provided for @fuelTypeValidation.
  ///
  /// In en, this message translates to:
  /// **'Automatic'**
  String get fuelTypeValidation;

  /// No description provided for @gasolineType.
  ///
  /// In en, this message translates to:
  /// **'Gasoline Type'**
  String get gasolineType;

  /// No description provided for @gasolineTypeValidation.
  ///
  /// In en, this message translates to:
  /// **'Automatic'**
  String get gasolineTypeValidation;

  /// No description provided for @milage.
  ///
  /// In en, this message translates to:
  /// **'Milage'**
  String get milage;

  /// No description provided for @milageHint.
  ///
  /// In en, this message translates to:
  /// **'Enter Milage'**
  String get milageHint;

  /// No description provided for @milageValidationIfNull.
  ///
  /// In en, this message translates to:
  /// **'The Milage must be entered'**
  String get milageValidationIfNull;

  /// No description provided for @milageValidation.
  ///
  /// In en, this message translates to:
  /// **'The Milage must be numbers'**
  String get milageValidation;

  /// No description provided for @detailsYearModel.
  ///
  /// In en, this message translates to:
  /// **'Year Model'**
  String get detailsYearModel;

  /// No description provided for @yearModelValidation.
  ///
  /// In en, this message translates to:
  /// **'Automatic'**
  String get yearModelValidation;

  /// No description provided for @exteriorColor.
  ///
  /// In en, this message translates to:
  /// **'Exterior Vehicle Color'**
  String get exteriorColor;

  /// No description provided for @exteriorColorHint.
  ///
  /// In en, this message translates to:
  /// **'Select exterior color'**
  String get exteriorColorHint;

  /// No description provided for @exteriorColorValidation.
  ///
  /// In en, this message translates to:
  /// **'Automatic'**
  String get exteriorColorValidation;

  /// No description provided for @interiorColor.
  ///
  /// In en, this message translates to:
  /// **'Interior Vehicle Color'**
  String get interiorColor;

  /// No description provided for @interiorColorHint.
  ///
  /// In en, this message translates to:
  /// **'Select interior color'**
  String get interiorColorHint;

  /// No description provided for @interiorColorValidation.
  ///
  /// In en, this message translates to:
  /// **'Automatic'**
  String get interiorColorValidation;

  /// No description provided for @colorSelectHint.
  ///
  /// In en, this message translates to:
  /// **'Select a color'**
  String get colorSelectHint;

  /// No description provided for @colorSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search colors...'**
  String get colorSearchHint;

  /// No description provided for @colorSearchEmpty.
  ///
  /// In en, this message translates to:
  /// **'No matching colors found'**
  String get colorSearchEmpty;

  /// No description provided for @gearboxType.
  ///
  /// In en, this message translates to:
  /// **'GearBox Type'**
  String get gearboxType;

  /// No description provided for @gearboxTypeValidation.
  ///
  /// In en, this message translates to:
  /// **'Automatic'**
  String get gearboxTypeValidation;

  /// No description provided for @cylindersNo.
  ///
  /// In en, this message translates to:
  /// **'Cylinders Number'**
  String get cylindersNo;

  /// No description provided for @cylindersNoValidation.
  ///
  /// In en, this message translates to:
  /// **'Automatic'**
  String get cylindersNoValidation;

  /// No description provided for @engineSize.
  ///
  /// In en, this message translates to:
  /// **'Engine Size CC'**
  String get engineSize;

  /// No description provided for @engineSizeHint.
  ///
  /// In en, this message translates to:
  /// **'Enter Engine Size (CC)'**
  String get engineSizeHint;

  /// No description provided for @engineSizeValidationIfNull.
  ///
  /// In en, this message translates to:
  /// **'The Engine Size must be entered'**
  String get engineSizeValidationIfNull;

  /// No description provided for @engineSizeValidation.
  ///
  /// In en, this message translates to:
  /// **'The Engine Size must be normal numbers or decimal'**
  String get engineSizeValidation;

  /// No description provided for @seatType.
  ///
  /// In en, this message translates to:
  /// **'Seat Type'**
  String get seatType;

  /// No description provided for @seatTypeValidation.
  ///
  /// In en, this message translates to:
  /// **'Automatic'**
  String get seatTypeValidation;

  /// No description provided for @seatNo.
  ///
  /// In en, this message translates to:
  /// **'Seats Number'**
  String get seatNo;

  /// No description provided for @seatNoValidation.
  ///
  /// In en, this message translates to:
  /// **'Automatic'**
  String get seatNoValidation;

  /// No description provided for @plateLastSixNumbers.
  ///
  /// In en, this message translates to:
  /// **'The last 6 charts in Car Plate must be numbers'**
  String get plateLastSixNumbers;

  /// No description provided for @plateFirstThreeLetters.
  ///
  /// In en, this message translates to:
  /// **'The First 3 charts in Car Plate must be letters'**
  String get plateFirstThreeLetters;

  /// No description provided for @typeYourNoteHere.
  ///
  /// In en, this message translates to:
  /// **'Enter your note here'**
  String get typeYourNoteHere;

  /// No description provided for @addNote.
  ///
  /// In en, this message translates to:
  /// **'Enter Note'**
  String get addNote;

  /// No description provided for @provideValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Provide valid Email'**
  String get provideValidEmail;

  /// No description provided for @notUpdated.
  ///
  /// In en, this message translates to:
  /// **'Not updated'**
  String get notUpdated;

  /// No description provided for @savedLocally.
  ///
  /// In en, this message translates to:
  /// **'Saved locally'**
  String get savedLocally;

  /// No description provided for @uploading.
  ///
  /// In en, this message translates to:
  /// **'Uploading ...'**
  String get uploading;

  /// No description provided for @downloading.
  ///
  /// In en, this message translates to:
  /// **'Downloading ...'**
  String get downloading;

  /// No description provided for @generalNote.
  ///
  /// In en, this message translates to:
  /// **'General Note'**
  String get generalNote;

  /// No description provided for @enterGeneralNote.
  ///
  /// In en, this message translates to:
  /// **'Enter general note ....'**
  String get enterGeneralNote;

  /// No description provided for @editGeneralNote.
  ///
  /// In en, this message translates to:
  /// **'Edit General Note'**
  String get editGeneralNote;

  /// No description provided for @typeGeneralNote.
  ///
  /// In en, this message translates to:
  /// **'Type General Note for the inspection'**
  String get typeGeneralNote;

  /// No description provided for @areYouSure.
  ///
  /// In en, this message translates to:
  /// **'Are You Sure?'**
  String get areYouSure;

  /// No description provided for @saveChangesConfirm.
  ///
  /// In en, this message translates to:
  /// **'Do you want to save all modified values? You can exit without saving.'**
  String get saveChangesConfirm;

  /// No description provided for @exitWithoutSaving.
  ///
  /// In en, this message translates to:
  /// **'Exit'**
  String get exitWithoutSaving;

  /// No description provided for @disconnectedMessage.
  ///
  /// In en, this message translates to:
  /// **'It seems like no internet connection, Please check from your internet connection and click on reload.'**
  String get disconnectedMessage;

  /// No description provided for @networkConnection.
  ///
  /// In en, this message translates to:
  /// **'Network Connection Status'**
  String get networkConnection;

  /// No description provided for @continueWithOffline.
  ///
  /// In en, this message translates to:
  /// **'Continue with offline'**
  String get continueWithOffline;

  /// No description provided for @noMoreRequests.
  ///
  /// In en, this message translates to:
  /// **'There is no more requests'**
  String get noMoreRequests;

  /// No description provided for @loggedOutOfflineWarning.
  ///
  /// In en, this message translates to:
  /// **'It\'s seems you are logged out, Offline mode is allowed while you are logged in'**
  String get loggedOutOfflineWarning;

  /// No description provided for @updateMessage.
  ///
  /// In en, this message translates to:
  /// **'There is a new update Version {newVer}, You {isShould} update it now.'**
  String updateMessage(String newVer, String isShould);

  /// No description provided for @thereUpdate.
  ///
  /// In en, this message translates to:
  /// **'Good News'**
  String get thereUpdate;

  /// No description provided for @haveTo.
  ///
  /// In en, this message translates to:
  /// **'have to'**
  String get haveTo;

  /// No description provided for @canText.
  ///
  /// In en, this message translates to:
  /// **'can'**
  String get canText;

  /// No description provided for @offlineNotEnabled.
  ///
  /// In en, this message translates to:
  /// **'It\'s seems you are logged out or the assets are not downloaded, Offline mode is allowed while you are logged in and assets are downloaded'**
  String get offlineNotEnabled;

  /// No description provided for @appSettings.
  ///
  /// In en, this message translates to:
  /// **'App Settings'**
  String get appSettings;

  /// No description provided for @generalSettings.
  ///
  /// In en, this message translates to:
  /// **'General Settings'**
  String get generalSettings;

  /// No description provided for @offlineModeSettings.
  ///
  /// In en, this message translates to:
  /// **'Offline Mode Settings'**
  String get offlineModeSettings;

  /// No description provided for @permissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Permission Required'**
  String get permissionRequired;

  /// No description provided for @cameraPermissionMsg.
  ///
  /// In en, this message translates to:
  /// **'You must to give a permission to can use camera or select image from gallery'**
  String get cameraPermissionMsg;

  /// No description provided for @rememberMeLabel.
  ///
  /// In en, this message translates to:
  /// **'Remember me'**
  String get rememberMeLabel;

  /// No description provided for @addOBDCode.
  ///
  /// In en, this message translates to:
  /// **'Add OBD code'**
  String get addOBDCode;

  /// No description provided for @typeOBDCodeHere.
  ///
  /// In en, this message translates to:
  /// **'Type OBD code here'**
  String get typeOBDCodeHere;

  /// No description provided for @searchingCodeDescription.
  ///
  /// In en, this message translates to:
  /// **'Searching Code Description...'**
  String get searchingCodeDescription;

  /// No description provided for @typeCodeDescription.
  ///
  /// In en, this message translates to:
  /// **'Type Code Description'**
  String get typeCodeDescription;

  /// No description provided for @fileNotPdf.
  ///
  /// In en, this message translates to:
  /// **'The file is not PDF, You should to upload PDF file.'**
  String get fileNotPdf;

  /// No description provided for @editNumber.
  ///
  /// In en, this message translates to:
  /// **'Edit phone number'**
  String get editNumber;

  /// No description provided for @chooseOne.
  ///
  /// In en, this message translates to:
  /// **'Choose One'**
  String get chooseOne;

  /// No description provided for @vehicleBody.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Body'**
  String get vehicleBody;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @code.
  ///
  /// In en, this message translates to:
  /// **'Code'**
  String get code;

  /// No description provided for @typeDescriptionHere.
  ///
  /// In en, this message translates to:
  /// **'Type description here'**
  String get typeDescriptionHere;

  /// No description provided for @successfulSaved.
  ///
  /// In en, this message translates to:
  /// **'Successful Saved'**
  String get successfulSaved;

  /// No description provided for @inspectionResultsSaved.
  ///
  /// In en, this message translates to:
  /// **'Your inspection results have saved successfully.'**
  String get inspectionResultsSaved;

  /// No description provided for @plateNumberLengthMax.
  ///
  /// In en, this message translates to:
  /// **'The Car Plate length must be less than 9'**
  String get plateNumberLengthMax;

  /// No description provided for @searchText.
  ///
  /// In en, this message translates to:
  /// **'Search...'**
  String get searchText;

  /// No description provided for @brand.
  ///
  /// In en, this message translates to:
  /// **'Brand'**
  String get brand;

  /// No description provided for @color.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get color;

  /// No description provided for @enterColor.
  ///
  /// In en, this message translates to:
  /// **'Enter Color'**
  String get enterColor;

  /// No description provided for @seatColor.
  ///
  /// In en, this message translates to:
  /// **'Seat Color'**
  String get seatColor;

  /// No description provided for @enterSeatColor.
  ///
  /// In en, this message translates to:
  /// **'Enter Seat Color'**
  String get enterSeatColor;

  /// No description provided for @interiorPhotos.
  ///
  /// In en, this message translates to:
  /// **'Interior Photos'**
  String get interiorPhotos;

  /// No description provided for @exteriorPhotos.
  ///
  /// In en, this message translates to:
  /// **'Exterior Photos'**
  String get exteriorPhotos;

  /// No description provided for @interiorNotes.
  ///
  /// In en, this message translates to:
  /// **'Interior Notes'**
  String get interiorNotes;

  /// No description provided for @exteriorNotes.
  ///
  /// In en, this message translates to:
  /// **'Exterior Notes'**
  String get exteriorNotes;

  /// No description provided for @addAdditionalPhoto.
  ///
  /// In en, this message translates to:
  /// **'Add an additional photo'**
  String get addAdditionalPhoto;

  /// No description provided for @validation.
  ///
  /// In en, this message translates to:
  /// **'Validation'**
  String get validation;

  /// No description provided for @enterOTPCode.
  ///
  /// In en, this message translates to:
  /// **'Enter OTP'**
  String get enterOTPCode;

  /// No description provided for @markerTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Note'**
  String get markerTitle;

  /// No description provided for @markerInputTitle.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get markerInputTitle;

  /// No description provided for @markerInputHint.
  ///
  /// In en, this message translates to:
  /// **'Describe the issue...'**
  String get markerInputHint;

  /// No description provided for @markerSelectTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Marker Type'**
  String get markerSelectTitle;

  /// No description provided for @markerNoteRequired.
  ///
  /// In en, this message translates to:
  /// **'Note Required'**
  String get markerNoteRequired;

  /// No description provided for @markerNoteRequiredMsg.
  ///
  /// In en, this message translates to:
  /// **'Please describe the issue'**
  String get markerNoteRequiredMsg;

  /// No description provided for @markerTypeRequired.
  ///
  /// In en, this message translates to:
  /// **'Type Required'**
  String get markerTypeRequired;

  /// No description provided for @markerTypeRequiredMsg.
  ///
  /// In en, this message translates to:
  /// **'Please select a marker type'**
  String get markerTypeRequiredMsg;

  /// No description provided for @markerAddPhoto.
  ///
  /// In en, this message translates to:
  /// **'Take Photo'**
  String get markerAddPhoto;

  /// No description provided for @markerChangePhoto.
  ///
  /// In en, this message translates to:
  /// **'Change Photo'**
  String get markerChangePhoto;

  /// No description provided for @bodyInspectionDetails.
  ///
  /// In en, this message translates to:
  /// **'Inspection Details'**
  String get bodyInspectionDetails;

  /// No description provided for @bodyTapHint.
  ///
  /// In en, this message translates to:
  /// **'Tap to add a marker'**
  String get bodyTapHint;

  /// No description provided for @bodyDragHint.
  ///
  /// In en, this message translates to:
  /// **'Drag a marker to reposition'**
  String get bodyDragHint;

  /// No description provided for @bodyPartTop.
  ///
  /// In en, this message translates to:
  /// **'Top'**
  String get bodyPartTop;

  /// No description provided for @bodyPartLeft.
  ///
  /// In en, this message translates to:
  /// **'Left'**
  String get bodyPartLeft;

  /// No description provided for @bodyPartRight.
  ///
  /// In en, this message translates to:
  /// **'Right'**
  String get bodyPartRight;

  /// No description provided for @bodyPartFront.
  ///
  /// In en, this message translates to:
  /// **'Front'**
  String get bodyPartFront;

  /// No description provided for @bodyPartBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get bodyPartBack;

  /// No description provided for @bodyPartInterior.
  ///
  /// In en, this message translates to:
  /// **'Interior'**
  String get bodyPartInterior;

  /// No description provided for @markerSavedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Note Saved'**
  String get markerSavedSuccess;

  /// No description provided for @markerSavedSuccessMsg.
  ///
  /// In en, this message translates to:
  /// **'The note has been saved successfully'**
  String get markerSavedSuccessMsg;

  /// No description provided for @markerMovedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Position Updated'**
  String get markerMovedSuccess;

  /// No description provided for @markerMovedSuccessMsg.
  ///
  /// In en, this message translates to:
  /// **'The note position has been updated successfully'**
  String get markerMovedSuccessMsg;

  /// No description provided for @markerDeletedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Note Deleted'**
  String get markerDeletedSuccess;

  /// No description provided for @markerDeletedSuccessMsg.
  ///
  /// In en, this message translates to:
  /// **'The note has been deleted successfully'**
  String get markerDeletedSuccessMsg;

  /// No description provided for @markerErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get markerErrorTitle;

  /// No description provided for @markerErrorMsg.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong, please try again'**
  String get markerErrorMsg;

  /// No description provided for @systemInspector.
  ///
  /// In en, this message translates to:
  /// **'System Inspector'**
  String get systemInspector;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @logoutBtn.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logoutBtn;

  /// No description provided for @logoutConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get logoutConfirmTitle;

  /// No description provided for @logoutConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to sign out?'**
  String get logoutConfirmMessage;

  /// No description provided for @loggingOutTitle.
  ///
  /// In en, this message translates to:
  /// **'Signing out'**
  String get loggingOutTitle;

  /// No description provided for @loggingOutSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Please wait...'**
  String get loggingOutSubtitle;

  /// No description provided for @profileName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get profileName;

  /// No description provided for @profileEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get profileEmail;

  /// No description provided for @profilePhone.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get profilePhone;

  /// No description provided for @profileCity.
  ///
  /// In en, this message translates to:
  /// **'Select City'**
  String get profileCity;

  /// No description provided for @profileUpdate.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get profileUpdate;

  /// No description provided for @profileNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter Name'**
  String get profileNameHint;

  /// No description provided for @profileEmailHint.
  ///
  /// In en, this message translates to:
  /// **'Enter Email'**
  String get profileEmailHint;

  /// No description provided for @profilePhoneHint.
  ///
  /// In en, this message translates to:
  /// **'Enter Phone Number'**
  String get profilePhoneHint;

  /// No description provided for @deleteAccountBtn.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccountBtn;

  /// No description provided for @deleteAccountConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccountConfirmTitle;

  /// No description provided for @deleteAccountConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to permanently delete your account? This action cannot be undone.'**
  String get deleteAccountConfirmMessage;

  /// No description provided for @deleteAccountError.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete account. Please try again.'**
  String get deleteAccountError;

  /// No description provided for @deleteAccountSuccess.
  ///
  /// In en, this message translates to:
  /// **'Your account has been deleted successfully.'**
  String get deleteAccountSuccess;

  /// No description provided for @stageAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get stageAll;

  /// No description provided for @stagePending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get stagePending;

  /// No description provided for @stageAccepted.
  ///
  /// In en, this message translates to:
  /// **'Accepted'**
  String get stageAccepted;

  /// No description provided for @stageInfo.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Info'**
  String get stageInfo;

  /// No description provided for @stagePoints.
  ///
  /// In en, this message translates to:
  /// **'Inspection Points'**
  String get stagePoints;

  /// No description provided for @stagePhotos.
  ///
  /// In en, this message translates to:
  /// **'Photos'**
  String get stagePhotos;

  /// No description provided for @stageBody.
  ///
  /// In en, this message translates to:
  /// **'Body Notes'**
  String get stageBody;

  /// No description provided for @stageObd.
  ///
  /// In en, this message translates to:
  /// **'OBD'**
  String get stageObd;

  /// No description provided for @stageFinished.
  ///
  /// In en, this message translates to:
  /// **'Finished'**
  String get stageFinished;

  /// No description provided for @stageRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get stageRejected;

  /// No description provided for @stageReviewed.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get stageReviewed;

  /// No description provided for @companies.
  ///
  /// In en, this message translates to:
  /// **'Companies'**
  String get companies;

  /// No description provided for @individuals.
  ///
  /// In en, this message translates to:
  /// **'Individuals'**
  String get individuals;

  /// No description provided for @requests.
  ///
  /// In en, this message translates to:
  /// **'requests'**
  String get requests;

  /// No description provided for @noCompanyRequests.
  ///
  /// In en, this message translates to:
  /// **'No company requests'**
  String get noCompanyRequests;

  /// No description provided for @noIndividualRequests.
  ///
  /// In en, this message translates to:
  /// **'No individual requests'**
  String get noIndividualRequests;

  /// No description provided for @noResultsFound.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get noResultsFound;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @noNotificationsYet.
  ///
  /// In en, this message translates to:
  /// **'No notifications yet'**
  String get noNotificationsYet;

  /// No description provided for @notificationsEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'You will see your notifications here'**
  String get notificationsEmptySubtitle;

  /// No description provided for @justNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get justNow;

  /// No description provided for @switchTeam.
  ///
  /// In en, this message translates to:
  /// **'Switch Team'**
  String get switchTeam;

  /// No description provided for @teams.
  ///
  /// In en, this message translates to:
  /// **'Teams'**
  String get teams;

  /// No description provided for @current.
  ///
  /// In en, this message translates to:
  /// **'Current'**
  String get current;

  /// No description provided for @teamSwitched.
  ///
  /// In en, this message translates to:
  /// **'Team Switched'**
  String get teamSwitched;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @failedToSwitchTeam.
  ///
  /// In en, this message translates to:
  /// **'Failed to switch team'**
  String get failedToSwitchTeam;

  /// No description provided for @changePhoto.
  ///
  /// In en, this message translates to:
  /// **'Change Photo'**
  String get changePhoto;

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @lightMode.
  ///
  /// In en, this message translates to:
  /// **'Light Mode'**
  String get lightMode;

  /// No description provided for @noPermission.
  ///
  /// In en, this message translates to:
  /// **'No Permission'**
  String get noPermission;

  /// No description provided for @unauthenticated.
  ///
  /// In en, this message translates to:
  /// **'Unauthenticated'**
  String get unauthenticated;

  /// No description provided for @noConnection.
  ///
  /// In en, this message translates to:
  /// **'No Connection'**
  String get noConnection;

  /// No description provided for @serverError.
  ///
  /// In en, this message translates to:
  /// **'Server Error'**
  String get serverError;

  /// No description provided for @invalidData.
  ///
  /// In en, this message translates to:
  /// **'Invalid data'**
  String get invalidData;

  /// No description provided for @notFound.
  ///
  /// In en, this message translates to:
  /// **'Not Found'**
  String get notFound;

  /// No description provided for @unknownError.
  ///
  /// In en, this message translates to:
  /// **'Unknown Error'**
  String get unknownError;

  /// No description provided for @selectTeamTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Team to Continue'**
  String get selectTeamTitle;

  /// No description provided for @selectTeamSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Please select a team to continue using the app'**
  String get selectTeamSubtitle;

  /// No description provided for @noTeamsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No teams available'**
  String get noTeamsAvailable;

  /// No description provided for @pullDownToRefresh.
  ///
  /// In en, this message translates to:
  /// **'Pull down to refresh'**
  String get pullDownToRefresh;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @onBoardingTitle1.
  ///
  /// In en, this message translates to:
  /// **'Manage Inspections'**
  String get onBoardingTitle1;

  /// No description provided for @onBoardingSubTitle1.
  ///
  /// In en, this message translates to:
  /// **'View and manage all your vehicle inspection requests in one place — easily and efficiently.'**
  String get onBoardingSubTitle1;

  /// No description provided for @onBoardingTitle2.
  ///
  /// In en, this message translates to:
  /// **'Inspect with Precision'**
  String get onBoardingTitle2;

  /// No description provided for @onBoardingSubTitle2.
  ///
  /// In en, this message translates to:
  /// **'Follow step-by-step inspection stages: photos, body check, OBD diagnostics, and more.'**
  String get onBoardingSubTitle2;

  /// No description provided for @onBoardingTitle3.
  ///
  /// In en, this message translates to:
  /// **'Stay Connected'**
  String get onBoardingTitle3;

  /// No description provided for @onBoardingSubTitle3.
  ///
  /// In en, this message translates to:
  /// **'Receive real-time notifications and stay updated on every inspection status change.'**
  String get onBoardingSubTitle3;

  /// No description provided for @enterOTP.
  ///
  /// In en, this message translates to:
  /// **'Enter Verification Code'**
  String get enterOTP;

  /// No description provided for @otpSentTo.
  ///
  /// In en, this message translates to:
  /// **'OTP has been sent to'**
  String get otpSentTo;

  /// No description provided for @otpSending.
  ///
  /// In en, this message translates to:
  /// **'Sending verification code to'**
  String get otpSending;

  /// No description provided for @otpSentMessage.
  ///
  /// In en, this message translates to:
  /// **'We sent a verification code to your number. Enter it below.'**
  String get otpSentMessage;

  /// No description provided for @resendOTP.
  ///
  /// In en, this message translates to:
  /// **'Resend Code'**
  String get resendOTP;

  /// No description provided for @resendIn.
  ///
  /// In en, this message translates to:
  /// **'Resend in '**
  String get resendIn;

  /// No description provided for @secondsShort.
  ///
  /// In en, this message translates to:
  /// **'s'**
  String get secondsShort;

  /// No description provided for @cameraRetake.
  ///
  /// In en, this message translates to:
  /// **'Retake'**
  String get cameraRetake;

  /// No description provided for @cameraUsePhoto.
  ///
  /// In en, this message translates to:
  /// **'Use Photo'**
  String get cameraUsePhoto;

  /// No description provided for @cameraRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get cameraRetry;

  /// No description provided for @cameraOk.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get cameraOk;

  /// No description provided for @imageSourceCamera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get imageSourceCamera;

  /// No description provided for @imageSourceGallery.
  ///
  /// In en, this message translates to:
  /// **'Album'**
  String get imageSourceGallery;

  /// No description provided for @cameraCaptureFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to capture photo, please try again'**
  String get cameraCaptureFailed;

  /// No description provided for @cameraPermissionDeniedTitle.
  ///
  /// In en, this message translates to:
  /// **'Camera Access Denied'**
  String get cameraPermissionDeniedTitle;

  /// No description provided for @cameraPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Please allow camera access in Settings to continue.'**
  String get cameraPermissionDenied;

  /// No description provided for @forceUpdateTitle.
  ///
  /// In en, this message translates to:
  /// **'Update Required'**
  String get forceUpdateTitle;

  /// No description provided for @forceUpdateMessage.
  ///
  /// In en, this message translates to:
  /// **'A new version of the app is available. Please update to continue using the app.'**
  String get forceUpdateMessage;

  /// No description provided for @forceUpdateButton.
  ///
  /// In en, this message translates to:
  /// **'Update Now'**
  String get forceUpdateButton;

  /// No description provided for @welcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Fahis'**
  String get welcomeTitle;

  /// No description provided for @welcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose how you would like to continue'**
  String get welcomeSubtitle;

  /// No description provided for @alreadyMember.
  ///
  /// In en, this message translates to:
  /// **'Already an inspector'**
  String get alreadyMember;

  /// No description provided for @requestMembership.
  ///
  /// In en, this message translates to:
  /// **'Apply to become an inspector'**
  String get requestMembership;

  /// No description provided for @requestFormTitle.
  ///
  /// In en, this message translates to:
  /// **'Inspector Application'**
  String get requestFormTitle;

  /// No description provided for @accessFullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get accessFullName;

  /// No description provided for @accessFullNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your full name'**
  String get accessFullNameHint;

  /// No description provided for @accessEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get accessEmail;

  /// No description provided for @accessEmailHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your email address'**
  String get accessEmailHint;

  /// No description provided for @accessPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get accessPhone;

  /// No description provided for @accessPhoneHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your phone number'**
  String get accessPhoneHint;

  /// No description provided for @accessCity.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get accessCity;

  /// No description provided for @accessCityHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your city'**
  String get accessCityHint;

  /// No description provided for @accessNote.
  ///
  /// In en, this message translates to:
  /// **'Additional Information (optional)'**
  String get accessNote;

  /// No description provided for @accessNoteHint.
  ///
  /// In en, this message translates to:
  /// **'Share any relevant experience'**
  String get accessNoteHint;

  /// No description provided for @submitAccessRequest.
  ///
  /// In en, this message translates to:
  /// **'Submit Application'**
  String get submitAccessRequest;

  /// No description provided for @requestSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Application Submitted Successfully'**
  String get requestSuccessTitle;

  /// No description provided for @requestSuccessSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your application has been received. Our team will review it and contact you soon.'**
  String get requestSuccessSubtitle;

  /// No description provided for @accessDoneBtn.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get accessDoneBtn;

  /// No description provided for @accessSubmissionFailed.
  ///
  /// In en, this message translates to:
  /// **'Submission Failed'**
  String get accessSubmissionFailed;

  /// No description provided for @accessSubmissionFailedMsg.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get accessSubmissionFailedMsg;

  /// No description provided for @pgStepTitle.
  ///
  /// In en, this message translates to:
  /// **'Paint Thickness'**
  String get pgStepTitle;

  /// No description provided for @pgScanTitle.
  ///
  /// In en, this message translates to:
  /// **'Connect Paint Gauge'**
  String get pgScanTitle;

  /// No description provided for @pgScanSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Turn on Bluetooth and place the Guoou device nearby to scan'**
  String get pgScanSubtitle;

  /// No description provided for @pgScanButton.
  ///
  /// In en, this message translates to:
  /// **'Scan Devices'**
  String get pgScanButton;

  /// No description provided for @pgStopScanButton.
  ///
  /// In en, this message translates to:
  /// **'Stop Scan'**
  String get pgStopScanButton;

  /// No description provided for @pgNoDevicesFound.
  ///
  /// In en, this message translates to:
  /// **'No devices found'**
  String get pgNoDevicesFound;

  /// No description provided for @pgNoDevicesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tap \"Scan Devices\" to start'**
  String get pgNoDevicesSubtitle;

  /// No description provided for @pgScanning.
  ///
  /// In en, this message translates to:
  /// **'Scanning...'**
  String get pgScanning;

  /// No description provided for @pgScanningSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Looking for nearby Bluetooth devices'**
  String get pgScanningSubtitle;

  /// No description provided for @pgNamedDevices.
  ///
  /// In en, this message translates to:
  /// **'Named Devices'**
  String get pgNamedDevices;

  /// No description provided for @pgUnnamedDevices.
  ///
  /// In en, this message translates to:
  /// **'Unknown / Unnamed'**
  String get pgUnnamedDevices;

  /// No description provided for @pgBtNotSupported.
  ///
  /// In en, this message translates to:
  /// **'Bluetooth not supported on this device'**
  String get pgBtNotSupported;

  /// No description provided for @pgBtNotEnabled.
  ///
  /// In en, this message translates to:
  /// **'Please enable Bluetooth'**
  String get pgBtNotEnabled;

  /// No description provided for @pgBtPermissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Bluetooth permissions required'**
  String get pgBtPermissionRequired;

  /// No description provided for @pgSkipStep.
  ///
  /// In en, this message translates to:
  /// **'Skip this step'**
  String get pgSkipStep;

  /// No description provided for @pgConnecting.
  ///
  /// In en, this message translates to:
  /// **'Connecting...'**
  String get pgConnecting;

  /// No description provided for @pgConnected.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get pgConnected;

  /// No description provided for @pgDisconnected.
  ///
  /// In en, this message translates to:
  /// **'Disconnected'**
  String get pgDisconnected;

  /// No description provided for @pgLostConnection.
  ///
  /// In en, this message translates to:
  /// **'Connection lost'**
  String get pgLostConnection;

  /// No description provided for @pgConnectionError.
  ///
  /// In en, this message translates to:
  /// **'Connection error'**
  String get pgConnectionError;

  /// No description provided for @pgGoBack.
  ///
  /// In en, this message translates to:
  /// **'Disconnect'**
  String get pgGoBack;

  /// No description provided for @pgConnectButton.
  ///
  /// In en, this message translates to:
  /// **'Connect Device'**
  String get pgConnectButton;

  /// No description provided for @pgConnectHint.
  ///
  /// In en, this message translates to:
  /// **'Tap to connect'**
  String get pgConnectHint;

  /// No description provided for @pgSessionReadingsOnly.
  ///
  /// In en, this message translates to:
  /// **'Session readings only — no historical data imported'**
  String get pgSessionReadingsOnly;

  /// No description provided for @pgMeasuredPanels.
  ///
  /// In en, this message translates to:
  /// **'Measured'**
  String get pgMeasuredPanels;

  /// No description provided for @pgNoMeasurementYet.
  ///
  /// In en, this message translates to:
  /// **'No measurement yet'**
  String get pgNoMeasurementYet;

  /// No description provided for @pgTapToMoveDevice.
  ///
  /// In en, this message translates to:
  /// **'Tap to move device here'**
  String get pgTapToMoveDevice;

  /// No description provided for @pgReadings.
  ///
  /// In en, this message translates to:
  /// **'readings'**
  String get pgReadings;

  /// No description provided for @pgAverage.
  ///
  /// In en, this message translates to:
  /// **'Average'**
  String get pgAverage;

  /// No description provided for @pgSubstrate.
  ///
  /// In en, this message translates to:
  /// **'Substrate'**
  String get pgSubstrate;

  /// No description provided for @pgHere.
  ///
  /// In en, this message translates to:
  /// **'HERE'**
  String get pgHere;

  /// No description provided for @pgClearPanel.
  ///
  /// In en, this message translates to:
  /// **'Clear Panel'**
  String get pgClearPanel;

  /// No description provided for @pgClearPanelConfirm.
  ///
  /// In en, this message translates to:
  /// **'This will clear all session readings for this panel.'**
  String get pgClearPanelConfirm;

  /// No description provided for @pgClearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear All Panels'**
  String get pgClearAll;

  /// No description provided for @pgClearAllConfirm.
  ///
  /// In en, this message translates to:
  /// **'This will remove all session readings from every panel.'**
  String get pgClearAllConfirm;

  /// No description provided for @pgClearSuccess.
  ///
  /// In en, this message translates to:
  /// **'Panel Cleared Successfully'**
  String get pgClearSuccess;

  /// No description provided for @pgClearFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to clear panel'**
  String get pgClearFailed;

  /// No description provided for @pgReviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Paint Thickness'**
  String get pgReviewTitle;

  /// No description provided for @pgReviewPanelsMeasured.
  ///
  /// In en, this message translates to:
  /// **'panels measured'**
  String get pgReviewPanelsMeasured;

  /// No description provided for @pgReviewNoData.
  ///
  /// In en, this message translates to:
  /// **'No measurements recorded'**
  String get pgReviewNoData;

  /// No description provided for @pgPanelHood.
  ///
  /// In en, this message translates to:
  /// **'Hood'**
  String get pgPanelHood;

  /// No description provided for @pgPanelRoof.
  ///
  /// In en, this message translates to:
  /// **'Roof'**
  String get pgPanelRoof;

  /// No description provided for @pgPanelTrunk.
  ///
  /// In en, this message translates to:
  /// **'Trunk Cover'**
  String get pgPanelTrunk;

  /// No description provided for @pgPanelLFF.
  ///
  /// In en, this message translates to:
  /// **'Left Front Fender'**
  String get pgPanelLFF;

  /// No description provided for @pgPanelLAP.
  ///
  /// In en, this message translates to:
  /// **'Left A-Pillar'**
  String get pgPanelLAP;

  /// No description provided for @pgPanelLFD.
  ///
  /// In en, this message translates to:
  /// **'Left Front Door'**
  String get pgPanelLFD;

  /// No description provided for @pgPanelLBP.
  ///
  /// In en, this message translates to:
  /// **'Left B-Pillar'**
  String get pgPanelLBP;

  /// No description provided for @pgPanelLRD.
  ///
  /// In en, this message translates to:
  /// **'Left Rear Door'**
  String get pgPanelLRD;

  /// No description provided for @pgPanelLCP.
  ///
  /// In en, this message translates to:
  /// **'Left C-Pillar'**
  String get pgPanelLCP;

  /// No description provided for @pgPanelLRF.
  ///
  /// In en, this message translates to:
  /// **'Left Rear Fender'**
  String get pgPanelLRF;

  /// No description provided for @pgPanelLDP.
  ///
  /// In en, this message translates to:
  /// **'Left D-Pillar'**
  String get pgPanelLDP;

  /// No description provided for @pgPanelRDP.
  ///
  /// In en, this message translates to:
  /// **'Right D-Pillar'**
  String get pgPanelRDP;

  /// No description provided for @pgPanelRRF.
  ///
  /// In en, this message translates to:
  /// **'Right Rear Fender'**
  String get pgPanelRRF;

  /// No description provided for @pgPanelRCP.
  ///
  /// In en, this message translates to:
  /// **'Right C-Pillar'**
  String get pgPanelRCP;

  /// No description provided for @pgPanelRRD.
  ///
  /// In en, this message translates to:
  /// **'Right Rear Door'**
  String get pgPanelRRD;

  /// No description provided for @pgPanelRBP.
  ///
  /// In en, this message translates to:
  /// **'Right B-Pillar'**
  String get pgPanelRBP;

  /// No description provided for @pgPanelRFD.
  ///
  /// In en, this message translates to:
  /// **'Right Front Door'**
  String get pgPanelRFD;

  /// No description provided for @pgPanelRAP.
  ///
  /// In en, this message translates to:
  /// **'Right A-Pillar'**
  String get pgPanelRAP;

  /// No description provided for @pgPanelRFF.
  ///
  /// In en, this message translates to:
  /// **'Right Front Fender'**
  String get pgPanelRFF;

  /// No description provided for @savedLocallyWillSync.
  ///
  /// In en, this message translates to:
  /// **'Saved — will sync when online'**
  String get savedLocallyWillSync;

  /// No description provided for @offlineNoCachedOrders.
  ///
  /// In en, this message translates to:
  /// **'You\'re offline — your inspections will load when you reconnect'**
  String get offlineNoCachedOrders;

  /// No description provided for @offlineBarMessage.
  ///
  /// In en, this message translates to:
  /// **'No connection — check your internet'**
  String get offlineBarMessage;

  /// No description provided for @backOnlineTitle.
  ///
  /// In en, this message translates to:
  /// **'Back online'**
  String get backOnlineTitle;

  /// No description provided for @backOnlineMessage.
  ///
  /// In en, this message translates to:
  /// **'Syncing your pending changes…'**
  String get backOnlineMessage;

  /// No description provided for @syncingOfflineChanges.
  ///
  /// In en, this message translates to:
  /// **'Syncing offline changes'**
  String get syncingOfflineChanges;

  /// No description provided for @offlineNoCacheMessage.
  ///
  /// In en, this message translates to:
  /// **'This inspection hasn\'t been downloaded yet. Reconnect and pull to refresh.'**
  String get offlineNoCacheMessage;

  /// No description provided for @savedLocallyTitle.
  ///
  /// In en, this message translates to:
  /// **'Saved locally'**
  String get savedLocallyTitle;

  /// No description provided for @savedLocallyMessage.
  ///
  /// In en, this message translates to:
  /// **'Will sync automatically when you\'re back online.'**
  String get savedLocallyMessage;

  /// No description provided for @queuedDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Queued for deletion'**
  String get queuedDeleteTitle;

  /// No description provided for @queuedDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'Will be removed from the server when you\'re back online.'**
  String get queuedDeleteMessage;

  /// No description provided for @reportNotCachedTitle.
  ///
  /// In en, this message translates to:
  /// **'Report not available offline'**
  String get reportNotCachedTitle;

  /// No description provided for @reportNotCachedMessage.
  ///
  /// In en, this message translates to:
  /// **'Connect to the internet to load the report for the first time.'**
  String get reportNotCachedMessage;

  /// No description provided for @obdCardDescriptionRequired.
  ///
  /// In en, this message translates to:
  /// **'Description required or data will be lost'**
  String get obdCardDescriptionRequired;

  /// No description provided for @obdCardTapToDescribe.
  ///
  /// In en, this message translates to:
  /// **'Tap to add description'**
  String get obdCardTapToDescribe;
}

class _SDelegate extends LocalizationsDelegate<S> {
  const _SDelegate();

  @override
  Future<S> load(Locale locale) {
    return SynchronousFuture<S>(lookupS(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_SDelegate old) => false;
}

S lookupS(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return SAr();
    case 'en':
      return SEn();
  }

  throw FlutterError(
    'S.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
