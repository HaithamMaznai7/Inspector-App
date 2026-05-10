// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class SAr extends S {
  SAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'فاحص';

  @override
  String get cancelBtn => 'إلغاء';

  @override
  String get skip => 'تخطي';

  @override
  String get refresh => 'جرب مره ثانيه';

  @override
  String get submitBtn => 'إرسال';

  @override
  String get nextBtn => 'التالي';

  @override
  String get backBtn => 'السابق';

  @override
  String get requestId => 'رقم الطلب';

  @override
  String get deleteBtn => 'حذف';

  @override
  String get signOut => 'تسجيل الخروج';

  @override
  String get updateAssets => 'تحديث الموارد';

  @override
  String get offlineMode => 'وضع عدم الاتصال';

  @override
  String get allItems => 'الكل';

  @override
  String get sessionExpired => 'انتهت الجلسة';

  @override
  String get sessionExpiredMsg =>
      'تم تسجيل الدخول من جهاز آخر. يرجى إعادة الدخول.';

  @override
  String get fieldRequired => 'هذا الحقل مطلوب.';

  @override
  String get vinMustBe17 => 'رقم الهيكل يجب أن يكون 17 حرف .';

  @override
  String get ccNumbersOnly => 'يسمح فقط بالأرقام.';

  @override
  String get colorNoNumbers => 'اللون لا يمكن أن يحتوي على أرقام.';

  @override
  String get milageNumbersOnly => 'يجب أن يكون رقمًا.';

  @override
  String get pendingStatus => 'معلقة';

  @override
  String get acceptedStatus => 'مقبولة';

  @override
  String get inProgressStatus => 'جاري فحصها';

  @override
  String get finishedStatus => 'منتهية';

  @override
  String get rejectedStatus => 'مرفوضة';

  @override
  String get reviewedStatus => 'تمت مراجعتها';

  @override
  String get settingsAndSupport => 'الإعدادات و الدعم';

  @override
  String get helpAndSupport => 'الإعدادات و الدعم';

  @override
  String get unSelected => 'غير محدد';

  @override
  String get more => 'المزيد';

  @override
  String get forgetSubTitle => 'ادخل رقم جوالك و راح نرسل لك رمز التحقق';

  @override
  String get saveBtn => 'حفظ';

  @override
  String get editBtn => 'تعديل';

  @override
  String get reviewBtn => 'مراجعة الفحص';

  @override
  String get add => 'إضافة';

  @override
  String get update => 'تحديث';

  @override
  String get skipBtn => 'تخطي';

  @override
  String get reload => 'إعادة المحاوله';

  @override
  String get goToSettings => 'الذهاب للإعدادات';

  @override
  String get welcomeBack => 'لقد كنا بإنتظارك';

  @override
  String get automatic => 'اوتوماتيك';

  @override
  String get manual => 'عادي';

  @override
  String get fabric => 'قماش';

  @override
  String get leather => 'جلد';

  @override
  String get inProgress => 'جاري الفحص';

  @override
  String get pended => 'معلق';

  @override
  String get approved => 'موثق';

  @override
  String get finished => 'منتهي';

  @override
  String get good => 'جيد';

  @override
  String get notes => 'ملاحظة';

  @override
  String get na => 'لا يوجد';

  @override
  String get loginTitle => 'تطبيق مراكز الفحص';

  @override
  String get loginSubTitle => 'مرحباً بعودتك';

  @override
  String get phoneNumber => 'رقم الجوال';

  @override
  String get phoneNumberValidation => 'يجب ان يكون رقم جوال صحيح';

  @override
  String get email => 'البريد الإلكتروني او الجوال';

  @override
  String get emailValidation => 'يجب ان تكون كلمة المرور اكبر من 8 رموز';

  @override
  String get password => 'كلمة المرور';

  @override
  String get passwordValidation => 'لازم تدخل الباسورد عشان السريه و كذا';

  @override
  String get rememberMe => 'تذكرني';

  @override
  String get login => 'تسجيل الدخول';

  @override
  String get verifyOTP => 'تحقق';

  @override
  String get resetPassword => 'إعادة تعيين كلمة المرور';

  @override
  String get resetPasswordSubtitle => 'أدخل كلمة المرور الجديدة أدناه.';

  @override
  String get newPassword => 'كلمة المرور الجديدة';

  @override
  String get confirmPassword => 'تأكيد كلمة المرور';

  @override
  String get passwordMismatch => 'كلمتا المرور غير متطابقتين';

  @override
  String get forgetBTN => 'نسيت كلمة المرور؟';

  @override
  String get loginWithEmail => 'الدخول بأستخدام البريد الإلكتروني';

  @override
  String get otpTitle => 'رمز التحقق';

  @override
  String resendBtnWithTime(int s) {
    return 'إعادة الإرسال (بعد $s ث)';
  }

  @override
  String get resendBtn => 'إعادة الإرسال';

  @override
  String get editPhoneNumber => 'تعدبل رقم الهاتف';

  @override
  String get processingTitle =>
      '...يتم تسجيل الدخول و تجهيز البيانات (لن يستغرق سوا ثواني)';

  @override
  String get searchHint => 'البحث باستخدام رقم اللوحة....';

  @override
  String get request => 'الطلبات';

  @override
  String get searchPlaceholder => 'أبحث...';

  @override
  String get history => 'سجل الطلبات';

  @override
  String get homePageOnEmpty => 'لا يوجد طلبات بعد';

  @override
  String get homePageOnError => 'حدث خطأ';

  @override
  String get homePageNoMore => 'لا يوجد لديك طلبات حالياً';

  @override
  String get generalInfo => 'المعلومات العامة';

  @override
  String get vehicleInfo => 'معلومات المركبة';

  @override
  String get connectPersonInfo => 'معلومات التواصل';

  @override
  String get inspectionPointReview => 'ملخص نقاط الفحص';

  @override
  String get inspectionType => 'نوع الفحص';

  @override
  String get inspectionCenter => 'مركز الفحص';

  @override
  String get centerBranch => 'فرع مركز الفحص';

  @override
  String get inspectionCity => 'مدينة المركز';

  @override
  String get bookingDate => 'تاريخ الحجز';

  @override
  String get assignedTo => 'إسناد الفحص لـ';

  @override
  String get inspector => 'أسم الفاحص';

  @override
  String get inspectedAt => 'تاريخ الفحص';

  @override
  String get reviewedAt => 'تاريخ المراجعة';

  @override
  String get createdAt => 'تاريخ الإنشاء';

  @override
  String get inspectorNote => 'ملاحظة الفاحص';

  @override
  String get reviewerNote => 'ملاحظة المراجع';

  @override
  String get notYet => 'لم يحدد بعد';

  @override
  String get anyInspector => 'كل الفاحصين';

  @override
  String get vin => 'رقم الهيكل';

  @override
  String get serialNo => 'رقم بيانات المركبة';

  @override
  String get make => 'الشركة المصنعة';

  @override
  String get model => 'الموديل';

  @override
  String get storageSize => 'حجم الصهريج';

  @override
  String get vehicleShape => 'شكل صهريج';

  @override
  String get yearModel => 'سنة الموديل';

  @override
  String get plate => 'رقم اللوحة';

  @override
  String get contactName => 'الاسم';

  @override
  String get contactEmail => 'البريد الإلكتروني';

  @override
  String get contactPhone => 'الجوال';

  @override
  String get contactCity => 'المدينة';

  @override
  String get inspectionPhotos => 'صور الفحص';

  @override
  String get inspectionBodyNotes => 'ملاحظات هيكل المركبة';

  @override
  String get inspectionOBDCodes => 'رموز OBD للفحص';

  @override
  String get loadingInspectionDetails => 'جاري تحميل تفاصيل الفحص...';

  @override
  String noteLabel(int index) {
    return 'ملاحظة $index';
  }

  @override
  String positionLabel(String dx, String dy) {
    return 'الموقع: ($dx, $dy)';
  }

  @override
  String notesCount(int count) {
    return '$count ملاحظات';
  }

  @override
  String get pointsReview => 'مراجعة النقاط';

  @override
  String get inspectionDetailsTitle => 'تفاصيل الفحص';

  @override
  String get doneBtn => 'تم';

  @override
  String get remaining => 'متبقية';

  @override
  String get imageRequired => 'الصورة مطلوبة';

  @override
  String get imageRequiredMsg => 'يجب توثيق الملاحظة بصورة توضح الحالة';

  @override
  String get noteRequired => 'الملاحظة مطلوبة';

  @override
  String get noteRequiredMsg => 'يجب وصف الحالة';

  @override
  String get resetPointsTitle => 'إعادة تعيين النقاط';

  @override
  String get resetPointsContent =>
      'هل أنت متأكد من إعادة تعيين جميع النقاط؟ سيتم حذف جميع التغييرات على النقاط الحالية.';

  @override
  String get resetPointsConfirm => 'إعادة تعيين';

  @override
  String get selectStatus => 'اختر الحالة';

  @override
  String get addNoteTitle => 'إضافة ملاحظة';

  @override
  String get noteSavedSuccessMsg => 'تم حفظ الملاحظة بنجاح';

  @override
  String get noteHint => 'اكتب ملاحظتك هنا...';

  @override
  String get noteFieldLabel => 'الملاحظة';

  @override
  String get noteValidation => 'الملاحظة مطلوبة';

  @override
  String get photosTitle => 'الصور';

  @override
  String get uploadedPhotos => 'تم الرفع';

  @override
  String get availablePhotos => 'متاحة';

  @override
  String get photoUploaded => 'تم الرفع';

  @override
  String get addPhoto => 'إضافة صورة';

  @override
  String get selectPhotoTitle => 'اختر الصورة لالتقاطها';

  @override
  String get noPhotosYet => 'لا توجد صور بعد';

  @override
  String photosProgress(int uploaded, int total) {
    return '$uploaded / $total صور';
  }

  @override
  String get takePhoto => 'التقاط صورة';

  @override
  String get deletePhoto => 'حذف الصورة';

  @override
  String get deletePhotoConfirm => 'هل أنت متأكد أنك تريد حذف هذه الصورة؟';

  @override
  String get photoDeletedSuccess => 'تم حذف الصورة بنجاح.';

  @override
  String get deleteAllPhotos => 'حذف جميع الصور';

  @override
  String get deleteAllPhotosConfirm =>
      'هل أنت متأكد؟ سيتم حذف جميع الصور المرفوعة وإعادة تعيينها.';

  @override
  String get deleteAllPhotosSuccess => 'تم حذف جميع الصور بنجاح.';

  @override
  String get deleteObdCode => 'حذف الكود';

  @override
  String get deleteObdCodeConfirm => 'هل أنت متأكد أنك تريد حذف هذا الكود؟';

  @override
  String get deleteBodyNote => 'حذف الملاحظة';

  @override
  String get deleteBodyNoteConfirm => 'هل أنت متأكد أنك تريد حذف هذه الملاحظة؟';

  @override
  String get photoCategoryExterior => 'خارجية';

  @override
  String get photoCategoryInterior => 'داخلية';

  @override
  String get startInspection => 'ابدأ الفحص';

  @override
  String get generalNoteTitle => 'إرسال الفحص';

  @override
  String get rejectionNoteTitle => 'رفض الفحص';

  @override
  String get noteOptionalHint => 'أضف ملاحظة (اختياري)...';

  @override
  String get confirmSubmit => 'تأكيد';

  @override
  String get inspectionCancelBtn => 'إلغاء';

  @override
  String get submitConfirmSubtitle => 'هل أنت متأكد من إرسال هذا الفحص؟';

  @override
  String get rejectConfirmSubtitle => 'هل أنت متأكد من رفض هذا الفحص؟';

  @override
  String get addNoteLabel => 'إضافة ملاحظة';

  @override
  String get optionalTag => 'اختياري';

  @override
  String get obdFileName => 'تقرير OBD';

  @override
  String get uploadObdReport => 'رفع تقرير OBD';

  @override
  String get obdCodesTitle => 'أكواد OBD';

  @override
  String get obdCodeRequired => 'الرمز مطلوب';

  @override
  String get obdCodeRequiredMsg => 'يرجى إدخال رمز OBD';

  @override
  String get obdDescRequired => 'الوصف مطلوب';

  @override
  String get obdDescRequiredMsg => 'يرجى إدخال وصف الرمز';

  @override
  String get finishOnlineRequired => 'الاتصال بالإنترنت مطلوب';

  @override
  String get finishOnlineRequiredMsg =>
      'إنهاء الفحص يتطلب اتصالاً بالإنترنت. يرجى إعادة الاتصال والمحاولة مرة أخرى.';

  @override
  String get finishObdIncomplete => 'أكواد OBD غير مكتملة';

  @override
  String get finishObdIncompleteMsg =>
      'بعض أكواد OBD ينقصها الوصف أو لا تزال قيد المزامنة. اضغط على كل كود معلّق لاستكماله قبل إنهاء الفحص.';

  @override
  String get obdDataRequired => 'بيانات OBD مطلوبة';

  @override
  String get obdDataRequiredMsg =>
      'يرجى رفع ملف التقرير أو إضافة رمز OBD واحد على الأقل قبل المتابعة';

  @override
  String get obdFileTooLarge => 'حجم الملف كبير';

  @override
  String get obdFileTooLargeMsg => 'يجب أن يكون حجم الملف أقل من 1 ميجابايت';

  @override
  String get obdUploadSuccess => 'تم رفع التقرير بنجاح';

  @override
  String get obdUploadFailed => 'فشل رفع التقرير';

  @override
  String get obdDeleteSuccess => 'تم حذف التقرير';

  @override
  String get obdDeleteReportTitle => 'حذف التقرير';

  @override
  String get obdDeleteReportConfirm => 'هل أنت متأكد أنك تريد حذف تقرير OBD؟';

  @override
  String get obdCodeDeletedSuccess => 'تم الحذف';

  @override
  String get obdCodeDeletedSuccessMsg => 'تم حذف رمز OBD بنجاح';

  @override
  String get obdCodeAddSuccess => 'تمت الإضافة';

  @override
  String get obdCodeAddSuccessMsg => 'تمت إضافة رمز OBD بنجاح';

  @override
  String get obdCodeEditSuccess => 'تم التعديل';

  @override
  String get obdCodeEditSuccessMsg => 'تم تعديل رمز OBD بنجاح';

  @override
  String get obdActionError => 'حدث خطأ، يرجى المحاولة مرة أخرى';

  @override
  String get obdAddCode => 'إضافة رمز OBD';

  @override
  String get obdEditCode => 'تعديل رمز OBD';

  @override
  String get obdCodeLabel => 'رمز OBD';

  @override
  String get obdCodeHint => 'مثال: P0300';

  @override
  String get obdDescLabel => 'الوصف';

  @override
  String get obdDescHint => 'وصف الرمز...';

  @override
  String get obdNoCodesYet => 'لا توجد أكواد OBD بعد';

  @override
  String get bodyNotesEmpty => 'لا توجد ملاحظات بعد';

  @override
  String get obdReportSection => 'تقرير OBD';

  @override
  String get obdOptionalBadge => 'اختياري';

  @override
  String get obdConnectDevice => 'ربط الجهاز';

  @override
  String get obdDisconnect => 'قطع الاتصال';

  @override
  String get obdReadFromDevice => 'قراءة من الجهاز';

  @override
  String get obdConnecting => 'جارٍ الاتصال…';

  @override
  String get obdReadingCodes => 'جارٍ قراءة الأكواد…';

  @override
  String get obdConnectionFailed => 'فشل الاتصال';

  @override
  String get obdEcuConnectFailed =>
      'تعذّر الاتصال بوحدة التحكم في السيارة. تأكد من تشغيل المحرك ومن تثبيت منفذ OBD-II بشكل صحيح.';

  @override
  String get obdDeviceDisconnected => 'تم قطع الجهاز';

  @override
  String get obdReconnect => 'إعادة الاتصال';

  @override
  String get obdNoCodesFromDevice => 'لم يتم العثور على أكواد أعطال';

  @override
  String get obdNoNewCodes => 'لا توجد أكواد جديدة من الجهاز';

  @override
  String obdCodesAdded(int count) {
    return 'تمت إضافة $count كود من الجهاز';
  }

  @override
  String get obdScanTitle => 'اختر جهاز OBD';

  @override
  String get obdBleNotSupported => 'البلوتوث غير مدعوم على هذا الجهاز';

  @override
  String get obdBleOff => 'يرجى تشغيل البلوتوث';

  @override
  String get obdBlePermissionDenied => 'يلزم إذن البلوتوث';

  @override
  String obdConnectedTo(String name) {
    return 'متصل: $name';
  }

  @override
  String get obdAddManualCode => 'إضافة يدوياً';

  @override
  String get obdScanStart => 'بحث عن الأجهزة';

  @override
  String get obdScanStop => 'إيقاف البحث';

  @override
  String get obdScanEmptyTitle => 'لم يتم العثور على أجهزة';

  @override
  String get obdScanEmptyHint => 'اضغط على \"بحث عن الأجهزة\" للبدء';

  @override
  String get obdScanScanningTitle => 'جارٍ البحث…';

  @override
  String get obdScanScanningHint =>
      'شغّل البلوتوث وضع جهاز Veepeak بالقرب منك للبحث';

  @override
  String get obdScanSectionNamed => 'الأجهزة المتاحة';

  @override
  String get obdScanUnknownDevice => 'جهاز غير معروف';

  @override
  String get obdScanRecommended => 'موصى به';

  @override
  String get obdFromDevice => 'من الجهاز';

  @override
  String get obdAddedCodesList => 'الأكواد المضافة';

  @override
  String get obdPairNewDevice => 'إقران جهاز';

  @override
  String stepLabel(String step) {
    return 'الخطوة $step';
  }

  @override
  String get submitValidationTitle => 'لا يمكن الإرسال';

  @override
  String get submitValidationMsg => 'يرجى إكمال جميع الخطوات قبل الإرسال:';

  @override
  String get submitSuccessTitle => 'تم الإرسال';

  @override
  String get submitSuccessMsg => 'تم إرسال الفحص بنجاح';

  @override
  String stepIncomplete(String step) {
    return '$step غير مكتمل';
  }

  @override
  String get stepVehicleInfo => 'معلومات المركبة';

  @override
  String get stepPoints => 'نقاط الفحص';

  @override
  String get stepPhotos => 'الصور';

  @override
  String get stepBody => 'ملاحظات الهيكل';

  @override
  String get stepObd => 'OBD';

  @override
  String get vehicleInfoRequired => 'معلومات المركبة مطلوبة';

  @override
  String get vehicleInfoRequiredMsg =>
      'يرجى ملء جميع حقول معلومات المركبة قبل المتابعة';

  @override
  String get allPointsRequired => 'جميع النقاط مطلوبة';

  @override
  String get allPointsRequiredMsg => 'يرجى ملء جميع نقاط الفحص قبل المتابعة';

  @override
  String get pointsRequired => 'النقاط مطلوبة';

  @override
  String get pointsRequiredMsg => 'يجب ملء نقطة فحص واحدة على الأقل';

  @override
  String get photosRequired => 'الصور مطلوبة';

  @override
  String get photosRequiredMsg => 'يجب رفع صورة واحدة على الأقل قبل المتابعة';

  @override
  String get allPhotosRequired => 'جميع الصور مطلوبة';

  @override
  String get allPhotosRequiredMsg =>
      'يرجى رفع جميع الصور المطلوبة قبل المتابعة';

  @override
  String get generatDialogTitle => 'تحذير !';

  @override
  String get generatDialogContent =>
      'هل أنت متاكد؟ هذا الإجراء سيحذف كل النقاط و يعيد بناءها من جديد, كل المعلومات المحفوظة سيتم حذفها.';

  @override
  String get generatDialogConfirmBtn => 'إعادة تعيين';

  @override
  String get generatDialogCancel => 'إلغاء';

  @override
  String pageTitle(String inspection) {
    return 'فحص رقم. $inspection';
  }

  @override
  String get reviewNoteTitle => 'ملاحظات المراجع : ';

  @override
  String get vehicleInfoTile => 'معلومات المركبة';

  @override
  String get requestInfoTitle => 'معلومات الطلب';

  @override
  String get inspectionPointResults => 'نتائج نقاط الفحص';

  @override
  String get defaultValidationIfNull => 'الحقل مطلوب';

  @override
  String get defaultValidation => 'الحقل يجب أن يكون 3 احرف او أكثر';

  @override
  String get pointCategories => 'تصنيف النقاط';

  @override
  String get detailsVin => 'الرقم التسلسلي للمركبة';

  @override
  String get vinHint => 'أدخل رقم التسلسلي للمركبة';

  @override
  String get vinValidationIfNull =>
      'مافي انسان بدون اثبات و أكيد مافي موتر بدون اثباته (;';

  @override
  String get vinValidation => '17 حرف و رقم يا ليت تكتبهم بالكامل';

  @override
  String get vinSearchBtn => 'بحث';

  @override
  String get vinSearching => 'جاري البحث...';

  @override
  String get vinFound => 'تم العثور على بيانات المركبة';

  @override
  String get vinFoundMsg => 'تم تعبئة الحقول تلقائياً، يمكنك التعديل عليها.';

  @override
  String get vinNotFound => 'لم يتم العثور على المركبة';

  @override
  String get vinNotFoundMsg =>
      'لا توجد بيانات لهذا الرقم، يمكنك الإدخال يدوياً.';

  @override
  String get vinSearchError => 'خطأ في البحث';

  @override
  String get vinSearchErrorMsg => 'تعذر البحث، حاول مرة أخرى.';

  @override
  String get vinHelperTyping => 'أدخل 17 حرف للبحث عن بيانات المركبة تلقائياً';

  @override
  String get vinHelperReady => 'اضغط على أيقونة البحث لتعبئة البيانات تلقائياً';

  @override
  String get sectionIdentification => 'التعريف';

  @override
  String get sectionSpecifications => 'المواصفات';

  @override
  String get sectionInterior => 'الألوان والمقاعد';

  @override
  String get plateNumber => 'رقم اللوحة';

  @override
  String get plateNumberHint => 'أدخل رقم اللوحة';

  @override
  String get plateNumberValidationIfNull => 'مطلوب ...';

  @override
  String get plateNumberValidation => 'أكمل اللوحة: مطلوب 3 أحرف و 4 أرقام';

  @override
  String get plateLettersLabel => 'الحروف';

  @override
  String get plateNumbersLabel => 'الأرقام';

  @override
  String get bodyType => 'هيكل المركبة';

  @override
  String get bodyTypeValidation => 'حدد هيكل المركبة ما راح نطقها عين';

  @override
  String get drivetrain => 'نظام الدفع';

  @override
  String get drivetrainValidation => 'أول سيارة تطير !';

  @override
  String get fuelType => 'نوع الوقود';

  @override
  String get fuelTypeValidation => 'ع الطاقة الشمسية ؟!';

  @override
  String get gasolineType => 'نوع البنزبن';

  @override
  String get gasolineTypeValidation => 'يمكن نحتاجها';

  @override
  String get milage => 'قراءة العداد';

  @override
  String get milageHint => 'كم ممشاها ؟!';

  @override
  String get milageValidationIfNull => 'أجل ليه تفحصها و عادها خرجت من الوكالة';

  @override
  String get milageValidation => 'يجب ان تكون بالارقام و بقياس ال كم';

  @override
  String get detailsYearModel => 'سنة الصنع';

  @override
  String get yearModelValidation => 'متى ولدت ؟ عشان نسوي لها عيد مبلاد !';

  @override
  String get exteriorColor => 'لون المركبة الخارجي';

  @override
  String get exteriorColorHint => 'اختر اللون الخارجي';

  @override
  String get exteriorColorValidation => 'تلقائي';

  @override
  String get interiorColor => 'لون المركبة الداخلي';

  @override
  String get interiorColorHint => 'اختر اللون الداخلي';

  @override
  String get interiorColorValidation => 'تلقائي';

  @override
  String get colorSelectHint => 'اختر لوناً';

  @override
  String get colorSearchHint => 'ابحث عن لون...';

  @override
  String get colorSearchEmpty => 'لا توجد ألوان مطابقة';

  @override
  String get gearboxType => 'نوع التروس';

  @override
  String get gearboxTypeValidation => 'تلقائي';

  @override
  String get cylindersNo => 'عدد السليندر';

  @override
  String get cylindersNoValidation => 'لازم تدخل العدد عشان الفحص';

  @override
  String get engineSize => 'مقاس المحرك CC';

  @override
  String get engineSizeHint => 'أدخل مقاس المحرك (CC) مثل: 2.4, 2400';

  @override
  String get engineSizeValidationIfNull => 'هل هناك مركبه لا تمتلك محرك ؟!';

  @override
  String get engineSizeValidation => 'مسموح بالارقام الصحيحه و العشريه فقط.';

  @override
  String get seatType => 'نوع المقاعد';

  @override
  String get seatTypeValidation => 'نوع المقاعد مطلوب';

  @override
  String get seatNo => 'عدد المقاعد';

  @override
  String get seatNoValidation => 'عدد المقاعد مطلوب';

  @override
  String get plateLastSixNumbers =>
      'أخر 6 رموز من لوحة السيارة يجب أن يكون ارقام';

  @override
  String get plateFirstThreeLetters =>
      'أول 3 رموز من لوحة السيارة يجب أن يكون حروف';

  @override
  String get typeYourNoteHere => 'أكتب ملاحظتك هنا';

  @override
  String get addNote => 'إضافة ملاحظة';

  @override
  String get provideValidEmail => 'البريد الإلكتروني غير صحيح';

  @override
  String get notUpdated => 'لم يرفع';

  @override
  String get savedLocally => 'محفوظ';

  @override
  String get uploading => 'جاري الرفع...';

  @override
  String get downloading => 'جاري التنزيل...';

  @override
  String get generalNote => 'ملاحظات عامة';

  @override
  String get enterGeneralNote => 'ادخل ملاحظة عامة';

  @override
  String get editGeneralNote => 'تحرير ملاحظات عامة';

  @override
  String get typeGeneralNote => 'أدخل ملاحظاتك العامه على طلب الفحص';

  @override
  String get areYouSure => 'هل تريد الحفظ';

  @override
  String get saveChangesConfirm =>
      'يوجد معلومات تم التعديل عليها، هل تريد حفظها؟ يمكنك الخروج دون حفظ المعلومات.';

  @override
  String get exitWithoutSaving => 'لا تحفظ';

  @override
  String get disconnectedMessage =>
      'لست متصل بالإنتارنت كما هو ظاهر، رجاء تحقق من اتصالك ثم اعد المحاوله.';

  @override
  String get networkConnection => 'حالة الاتصال بالشبكة';

  @override
  String get continueWithOffline => 'المتابع بدون اتصال';

  @override
  String get noMoreRequests => 'لم يعد هناك المزيد من الطلبات';

  @override
  String get loggedOutOfflineWarning =>
      'أنت لست مسجل دخول, وضع عدم الأتصال يحتاج الى تسجبل دخولك';

  @override
  String updateMessage(String newVer, String isShould) {
    return 'لقد توفر تحديث جديد للتطبيق إصدار : $newVer ,$isShould تحديثه الأن.';
  }

  @override
  String get thereUpdate => 'يوجد خبر سعيد';

  @override
  String get haveTo => 'ينبغي';

  @override
  String get canText => 'تستطيع';

  @override
  String get offlineNotEnabled =>
      'ربما لم تسجل دخولك او أنك لم تحمل البيانات الاساسية لإستخدام وضع عدم الإتصال، رجاء تأكد من إعدادات التطبيق';

  @override
  String get appSettings => 'إعدادات التطبق';

  @override
  String get generalSettings => 'إعدادات عامة';

  @override
  String get offlineModeSettings => 'إعدادات وضع عدم الإتصال';

  @override
  String get permissionRequired => 'صلاحية الوصول مطلوبة';

  @override
  String get cameraPermissionMsg =>
      'ساعدنا للحصول على تصريحك للوصول للكاميرا او البوم الصور الخاص بك من الإعدادات';

  @override
  String get rememberMeLabel => 'تذكرني';

  @override
  String get addOBDCode => 'إضافة رمز الOBD';

  @override
  String get typeOBDCodeHere => 'أدخل رمز الOBD هنا';

  @override
  String get searchingCodeDescription => 'جاري البحث عن الرمز...';

  @override
  String get typeCodeDescription => 'أدخل وصف الرمز هنا';

  @override
  String get fileNotPdf =>
      'الملف الذي حددته ليس من نوع PDF، فضلاً اختار ملف PDF';

  @override
  String get editNumber => 'تعديل رقم الجوال';

  @override
  String get chooseOne => 'حدد أختيار';

  @override
  String get vehicleBody => 'هيكل المركبة';

  @override
  String get description => 'وصف الرمز';

  @override
  String get code => 'الرمز';

  @override
  String get typeDescriptionHere => 'أكتب وصف الرمز هنا';

  @override
  String get successfulSaved => 'تم الحفظ بنجاح';

  @override
  String get inspectionResultsSaved =>
      'جميع نتائج الفحص الخاصة بك تم حفظها بنجاح.';

  @override
  String get plateNumberLengthMax =>
      'رقم لوحة السيارة يجب أن يكون أقل من 9 حروف و أرقام';

  @override
  String get searchText => 'بحث...';

  @override
  String get brand => 'شركة التصنيع';

  @override
  String get color => 'لون المركبة';

  @override
  String get enterColor => 'ادخل اللون الخارجي للمركبة';

  @override
  String get seatColor => 'اللون الداخلي';

  @override
  String get enterSeatColor => 'ادخل اللون الداخلي للمركبة';

  @override
  String get interiorPhotos => 'صور داخلية';

  @override
  String get exteriorPhotos => 'صور خارجية';

  @override
  String get interiorNotes => 'ملاحظات داخلية';

  @override
  String get exteriorNotes => 'ملاحظات خارجية';

  @override
  String get addAdditionalPhoto => 'دخال صوره إضافية';

  @override
  String get validation => 'التحقق';

  @override
  String get enterOTPCode => 'ادخل رمز التحقق';

  @override
  String get markerTitle => 'إضافة ملاحظة';

  @override
  String get markerInputTitle => 'الملاحظة';

  @override
  String get markerInputHint => 'صف المشكلة...';

  @override
  String get markerSelectTitle => 'حدد نوع الملاحظة';

  @override
  String get markerNoteRequired => 'الملاحظة مطلوبة';

  @override
  String get markerNoteRequiredMsg => 'يجب وصف المشكلة';

  @override
  String get markerTypeRequired => 'النوع مطلوب';

  @override
  String get markerTypeRequiredMsg => 'يجب تحديد نوع الملاحظة';

  @override
  String get markerAddPhoto => 'التقاط صورة';

  @override
  String get markerChangePhoto => 'تغيير الصورة';

  @override
  String get bodyInspectionDetails => 'تفاصيل الفحص';

  @override
  String get bodyTapHint => 'اضغط لإضافة علامة';

  @override
  String get bodyDragHint => 'اسحب العلامة لتغيير موضعها';

  @override
  String get bodyPartTop => 'أعلى';

  @override
  String get bodyPartLeft => 'يسار';

  @override
  String get bodyPartRight => 'يمين';

  @override
  String get bodyPartFront => 'أمام';

  @override
  String get bodyPartBack => 'خلف';

  @override
  String get bodyPartInterior => 'داخلي';

  @override
  String get markerSavedSuccess => 'تم الحفظ';

  @override
  String get markerSavedSuccessMsg => 'تم حفظ الملاحظة بنجاح';

  @override
  String get markerMovedSuccess => 'تم تحديث الموضع';

  @override
  String get markerMovedSuccessMsg => 'تم تحديث موضع الملاحظة بنجاح';

  @override
  String get markerDeletedSuccess => 'تم الحذف';

  @override
  String get markerDeletedSuccessMsg => 'تم حذف الملاحظة بنجاح';

  @override
  String get markerErrorTitle => 'خطأ';

  @override
  String get markerErrorMsg => 'حدث خطأ، يرجى المحاولة مرة أخرى';

  @override
  String get systemInspector => 'مفتش النظام';

  @override
  String get profileTitle => 'الملف الشخصي';

  @override
  String get logoutBtn => 'تسجيل الخروج';

  @override
  String get logoutConfirmTitle => 'تسجيل الخروج';

  @override
  String get logoutConfirmMessage => 'هل أنت متأكد أنك تريد تسجيل الخروج؟';

  @override
  String get loggingOutTitle => 'جاري تسجيل الخروج';

  @override
  String get loggingOutSubtitle => 'يرجى الانتظار...';

  @override
  String get profileName => 'الاسم';

  @override
  String get profileEmail => 'البريد الإلكتروني';

  @override
  String get profilePhone => 'رقم الجوال';

  @override
  String get profileCity => 'اختر المدينة';

  @override
  String get profileUpdate => 'تحديث';

  @override
  String get profileNameHint => 'أدخل الاسم';

  @override
  String get profileEmailHint => 'أدخل البريد الإلكتروني';

  @override
  String get profilePhoneHint => 'أدخل رقم الجوال';

  @override
  String get deleteAccountBtn => 'حذف الحساب';

  @override
  String get deleteAccountConfirmTitle => 'حذف الحساب';

  @override
  String get deleteAccountConfirmMessage =>
      'هل أنت متأكد من حذف حسابك بشكل نهائي؟ لا يمكن التراجع عن هذا الإجراء.';

  @override
  String get deleteAccountError => 'فشل حذف الحساب. يرجى المحاولة مرة أخرى.';

  @override
  String get deleteAccountSuccess => 'تم حذف حسابك بنجاح.';

  @override
  String get stageAll => 'الكل';

  @override
  String get stagePending => 'قيد الانتظار';

  @override
  String get stageAccepted => 'مقبول';

  @override
  String get stageInfo => 'معلومات المركبة';

  @override
  String get stagePoints => 'نقاط الفحص';

  @override
  String get stagePhotos => 'الصور';

  @override
  String get stageBody => 'ملاحظات الهيكل';

  @override
  String get stageObd => 'OBD';

  @override
  String get stageFinished => 'منتهي';

  @override
  String get stageRejected => 'مرفوض';

  @override
  String get stageReviewed => 'معتمد';

  @override
  String get companies => 'شركات';

  @override
  String get individuals => 'أفراد';

  @override
  String get requests => 'طلبات';

  @override
  String get noCompanyRequests => 'لا توجد طلبات شركات';

  @override
  String get noIndividualRequests => 'لا توجد طلبات أفراد';

  @override
  String get noResultsFound => 'لا توجد نتائج';

  @override
  String get notifications => 'الإشعارات';

  @override
  String get noNotificationsYet => 'لا توجد إشعارات بعد';

  @override
  String get notificationsEmptySubtitle => 'ستظهر إشعاراتك هنا';

  @override
  String get justNow => 'الآن';

  @override
  String get switchTeam => 'تبديل الفريق';

  @override
  String get teams => 'الفرق';

  @override
  String get current => 'الحالي';

  @override
  String get teamSwitched => 'تم تبديل الفريق';

  @override
  String get error => 'خطأ';

  @override
  String get failedToSwitchTeam => 'فشل تبديل الفريق';

  @override
  String get changePhoto => 'تغيير الصورة';

  @override
  String get camera => 'الكاميرا';

  @override
  String get gallery => 'المعرض';

  @override
  String get darkMode => 'الوضع الداكن';

  @override
  String get lightMode => 'الوضع الفاتح';

  @override
  String get noPermission => 'غير مسموح';

  @override
  String get unauthenticated => 'غير مصرح';

  @override
  String get noConnection => 'لا يوجد اتصال';

  @override
  String get serverError => 'خطأ في الخادم';

  @override
  String get invalidData => 'بيانات غير صالحة';

  @override
  String get notFound => 'غير موجود';

  @override
  String get unknownError => 'خطأ غير معروف';

  @override
  String get selectTeamTitle => 'اختر الفريق للمتابعة';

  @override
  String get selectTeamSubtitle =>
      'يرجى اختيار فريق للمتابعة في استخدام التطبيق';

  @override
  String get noTeamsAvailable => 'لا توجد فرق متاحة';

  @override
  String get pullDownToRefresh => 'اسحب للأسفل للتحديث';

  @override
  String get getStarted => 'ابدأ الآن';

  @override
  String get onBoardingTitle1 => 'إدارة الفحوصات';

  @override
  String get onBoardingSubTitle1 =>
      'عرض وإدارة جميع طلبات فحص المركبات في مكان واحد — بسهولة وكفاءة.';

  @override
  String get onBoardingTitle2 => 'افحص بدقة';

  @override
  String get onBoardingSubTitle2 =>
      'اتبع مراحل الفحص خطوة بخطوة: الصور، فحص الهيكل، تشخيص OBD، والمزيد.';

  @override
  String get onBoardingTitle3 => 'ابقَ على اطلاع';

  @override
  String get onBoardingSubTitle3 =>
      'استقبل الإشعارات الفورية وتابع كل تحديث على حالة الفحص.';

  @override
  String get enterOTP => 'أدخل رمز التحقق';

  @override
  String get otpSentTo => 'تم إرسال رمز التحقق إلى';

  @override
  String get otpSending => 'جاري إرسال رمز التحقق إلى';

  @override
  String get otpSentMessage => 'أرسلنا رمز التحقق إلى رقمك. يرجى إدخاله أدناه.';

  @override
  String get resendOTP => 'إعادة إرسال الرمز';

  @override
  String get resendIn => 'إعادة الإرسال خلال ';

  @override
  String get secondsShort => 'ث';

  @override
  String get cameraRetake => 'إعادة التقاط';

  @override
  String get cameraUsePhoto => 'استخدام الصورة';

  @override
  String get cameraRetry => 'إعادة المحاولة';

  @override
  String get cameraOk => 'موافق';

  @override
  String get imageSourceCamera => 'الكاميرا';

  @override
  String get imageSourceGallery => 'البوم الصور';

  @override
  String get cameraCaptureFailed => 'فشل التقاط الصورة، يرجى المحاولة مرة أخرى';

  @override
  String get cameraPermissionDeniedTitle => 'تم رفض الوصول إلى الكاميرا';

  @override
  String get cameraPermissionDenied =>
      'يرجى السماح بالوصول إلى الكاميرا من الإعدادات للمتابعة.';

  @override
  String get forceUpdateTitle => 'تحديث مطلوب';

  @override
  String get forceUpdateMessage =>
      'يتوفر إصدار جديد من التطبيق. يرجى التحديث للمتابعة في استخدام التطبيق.';

  @override
  String get forceUpdateButton => 'تحديث الآن';

  @override
  String get welcomeTitle => 'مرحبًا بك في فاحص';

  @override
  String get welcomeSubtitle => 'اختر كيف تود المتابعة';

  @override
  String get alreadyMember => 'لديك حساب بالفعل';

  @override
  String get requestMembership => 'التقديم للعمل كفني';

  @override
  String get requestFormTitle => 'طلب الانضمام كفني';

  @override
  String get accessFullName => 'الاسم الكامل';

  @override
  String get accessFullNameHint => 'أدخل اسمك الكامل';

  @override
  String get accessEmail => 'البريد الإلكتروني';

  @override
  String get accessEmailHint => 'أدخل بريدك الإلكتروني';

  @override
  String get accessPhone => 'رقم الهاتف';

  @override
  String get accessPhoneHint => 'أدخل رقم هاتفك';

  @override
  String get accessCity => 'المدينة';

  @override
  String get accessCityHint => 'أدخل مدينتك';

  @override
  String get accessNote => 'معلومات إضافية (اختياري)';

  @override
  String get accessNoteHint => 'اذكر أي خبرة ذات صلة';

  @override
  String get submitAccessRequest => 'إرسال الطلب';

  @override
  String get requestSuccessTitle => 'تم إرسال الطلب بنجاح';

  @override
  String get requestSuccessSubtitle =>
      'تم استلام طلبك. سيقوم فريقنا بمراجعته والتواصل معك قريبًا.';

  @override
  String get accessDoneBtn => 'تم';

  @override
  String get accessSubmissionFailed => 'فشل الإرسال';

  @override
  String get accessSubmissionFailedMsg => 'حدث خطأ ما، يرجى المحاولة مرة أخرى.';

  @override
  String get pgStepTitle => 'قياس البوية';

  @override
  String get pgScanTitle => 'توصيل جهاز القياس';

  @override
  String get pgScanSubtitle => 'شغّل البلوتوث وضع جهاز Guoou بالقرب منك للبحث';

  @override
  String get pgScanButton => 'بحث عن الأجهزة';

  @override
  String get pgStopScanButton => 'إيقاف البحث';

  @override
  String get pgNoDevicesFound => 'لم يتم العثور على أجهزة';

  @override
  String get pgNoDevicesSubtitle => 'اضغط على \"بحث عن الأجهزة\" للبدء';

  @override
  String get pgScanning => 'جاري البحث...';

  @override
  String get pgScanningSubtitle => 'يتم البحث عن أجهزة البلوتوث القريبة';

  @override
  String get pgNamedDevices => 'الأجهزة المعروفة';

  @override
  String get pgUnnamedDevices => 'أجهزة غير معروفة';

  @override
  String get pgBtNotSupported => 'البلوتوث غير مدعوم في هذا الجهاز';

  @override
  String get pgBtNotEnabled => 'يرجى تفعيل البلوتوث';

  @override
  String get pgBtPermissionRequired => 'يرجى منح صلاحية البلوتوث';

  @override
  String get pgSkipStep => 'تخطي هذه الخطوة';

  @override
  String get pgConnecting => 'جاري الاتصال...';

  @override
  String get pgConnected => 'متصل';

  @override
  String get pgDisconnected => 'غير متصل';

  @override
  String get pgLostConnection => 'انقطع الاتصال';

  @override
  String get pgConnectionError => 'خطأ في الاتصال';

  @override
  String get pgGoBack => 'إلغاء الاتصال';

  @override
  String get pgConnectButton => 'الاتصال بالجهاز';

  @override
  String get pgConnectHint => 'اضغط للاتصال بالجهاز';

  @override
  String get pgSessionReadingsOnly =>
      'قراءات الجلسة فقط — لم يتم استيراد بيانات سابقة';

  @override
  String get pgMeasuredPanels => 'تم قياسه';

  @override
  String get pgNoMeasurementYet => 'لا توجد قراءة بعد';

  @override
  String get pgTapToMoveDevice => 'اضغط لنقل الجهاز هنا';

  @override
  String get pgReadings => 'قراءات';

  @override
  String get pgAverage => 'المتوسط';

  @override
  String get pgSubstrate => 'نوع المادة';

  @override
  String get pgHere => 'هنا';

  @override
  String get pgClearPanel => 'مسح اللوحة';

  @override
  String get pgClearPanelConfirm =>
      'سيتم مسح جميع قراءات هذه اللوحة في الجلسة الحالية.';

  @override
  String get pgClearAll => 'مسح جميع اللوحات';

  @override
  String get pgClearAllConfirm => 'سيتم حذف جميع القراءات من كل اللوحات.';

  @override
  String get pgClearSuccess => 'تم الحذف بنجاح';

  @override
  String get pgClearFailed => 'فشل مسح اللوحة';

  @override
  String get pgReviewTitle => 'قياس البوية';

  @override
  String get pgReviewPanelsMeasured => 'لوحة تم قياسها';

  @override
  String get pgReviewNoData => 'لا توجد قراءات مسجلة';

  @override
  String get pgPanelHood => 'الكبوت';

  @override
  String get pgPanelRoof => 'السقف';

  @override
  String get pgPanelTrunk => 'الشنطة';

  @override
  String get pgPanelLFF => 'الرفرف الأمامي الأيسر';

  @override
  String get pgPanelLAP => 'العمود A الأيسر';

  @override
  String get pgPanelLFD => 'الباب الأمامي الأيسر';

  @override
  String get pgPanelLBP => 'العمود B الأيسر';

  @override
  String get pgPanelLRD => 'الباب الخلفي الأيسر';

  @override
  String get pgPanelLCP => 'العمود C الأيسر';

  @override
  String get pgPanelLRF => 'الرفرف الخلفي الأيسر';

  @override
  String get pgPanelLDP => 'العمود D الأيسر';

  @override
  String get pgPanelRDP => 'العمود D الأيمن';

  @override
  String get pgPanelRRF => 'الرفرف الخلفي الأيمن';

  @override
  String get pgPanelRCP => 'العمود C الأيمن';

  @override
  String get pgPanelRRD => 'الباب الخلفي الأيمن';

  @override
  String get pgPanelRBP => 'العمود B الأيمن';

  @override
  String get pgPanelRFD => 'الباب الأمامي الأيمن';

  @override
  String get pgPanelRAP => 'العمود A الأيمن';

  @override
  String get pgPanelRFF => 'الرفرف الأمامي الأيمن';

  @override
  String get savedLocallyWillSync => 'تم الحفظ — ستتم المزامنة عند الاتصال';

  @override
  String get offlineNoCachedOrders =>
      'أنت غير متصل — ستظهر الفحوصات عند عودة الاتصال';

  @override
  String get offlineBarMessage => 'لا يوجد اتصال — تحقق من الإنترنت';

  @override
  String get backOnlineTitle => 'عاد الاتصال';

  @override
  String get backOnlineMessage => 'جارٍ مزامنة التغييرات المعلّقة…';

  @override
  String get syncingOfflineChanges => 'جارٍ مزامنة التغييرات غير المتصلة';

  @override
  String get offlineNoCacheMessage =>
      'لم يتم تنزيل هذا الفحص بعد. أعد الاتصال واسحب للأسفل للتحديث.';

  @override
  String get savedLocallyTitle => 'تم الحفظ محليًا';

  @override
  String get savedLocallyMessage => 'ستتم المزامنة تلقائيًا عند عودة الاتصال.';

  @override
  String get queuedDeleteTitle => 'في قائمة الحذف';

  @override
  String get queuedDeleteMessage => 'سيتم حذفه عند عودة الاتصال.';

  @override
  String get reportNotCachedTitle => 'التقرير غير متاح دون اتصال';

  @override
  String get reportNotCachedMessage =>
      'اتصل بالإنترنت لتحميل التقرير لأول مرة.';

  @override
  String get obdCardDescriptionRequired => 'الوصف مطلوب وإلا ستضيع البيانات';

  @override
  String get obdCardTapToDescribe => 'اضغط لإضافة وصف';
}
