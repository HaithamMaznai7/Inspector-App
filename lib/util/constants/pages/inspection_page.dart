part of '../text_strings.dart';

class InspectionPage {
  // --- OnBoarding Texts
  static const String generatDialogContent =
      'Are You Sure You Want to Reset Points, That Will Delete All Changes on Current Points?';
  static const String generatDialogTitle = 'Alert !';
  static const String generatDialogConfirmBtn = 'Regenerate';
  static const String generatDialogCancel = 'Cancel';

  static const String generalInfo = 'generalInfo';
  static const String vehicleInfo = 'vehicleInfo';
  static const String connectPersonInfo = 'connectPersonInfo';
  static const String inspectionPointReview = 'inspectionPointReview';
  static const String inspectionType = 'Inspection Type';
  static const String center = 'Center';
  static const String centerBranch = 'Center Branch';
  static const String city = 'City';
  static const String bookingDate = 'Booking Date';
  static const String assignedTo = 'Assigned To';
  static const String inspector = 'Inspector';
  static const String inspectedAt = 'Inspected At';
  static const String reviewedAt = 'Reviewed At';
  static const String createdAt = 'Created At';
  static const String inspectorNote = 'Inspector Note';
  static const String reviewerNote = 'Reviewer Note';
  static const String notYet = 'notYet';
  static const String anyInspector = 'anyInspector';

  static const String vin = 'vin';
  static const String serialNo = 'serialNo';
  static const String make = 'make';
  static const String model = 'model';
  static const String storageSize = 'storageSize';
  static const String vehicleShape = 'vehicleShape';
  static const String yearModel = 'yearModel';
  static const String plate = 'plate';

  /// Connect person / customer
  static const String contactName = 'contactName';
  static const String contactEmail = 'contactEmail';
  static const String contactPhone = 'contactPhone';
  static const String contactCity = 'contactCity';

  /// Review card titles
  static const String inspectionPhotos = 'inspectionPhotos';
  static const String inspectionBodyNotes = 'inspectionBodyNotes';
  static const String inspectionOBDCodes = 'inspectionOBDCodes';
  static const String loadingInspectionDetails = 'loadingInspectionDetails';
  static const String noteLabel = 'noteLabel';
  static const String positionLabel = 'positionLabel';
  static const String notesCount = 'notesCount';

  /// Inspection Photos
  static const String photosTitle = 'photosTitle';
  static const String uploadedPhotos = 'uploadedPhotos';
  static const String availablePhotos = 'availablePhotos';
  static const String photoUploaded = 'photoUploaded';
  static const String addPhoto = 'Add Photo';
  static const String selectPhotoTitle = 'selectPhotoTitle';
  static const String noPhotosYet = 'noPhotosYet';
  static const String photosProgress = 'photosProgress';
  static const String takePhoto = 'takePhoto';
  static const String deletePhoto = 'deletePhoto';
  static const String deletePhotoConfirm = 'deletePhotoConfirm';
  static const String photoDeletedSuccess = 'photoDeletedSuccess';
  static const String deleteAllPhotos = 'deleteAllPhotos';
  static const String deleteAllPhotosConfirm = 'deleteAllPhotosConfirm';
  static const String deleteAllPhotosSuccess = 'deleteAllPhotosSuccess';
  static const String deleteObdCode = 'deleteObdCode';
  static const String deleteObdCodeConfirm = 'deleteObdCodeConfirm';
  static const String deleteBodyNote = 'deleteBodyNote';
  static const String deleteBodyNoteConfirm = 'deleteBodyNoteConfirm';
  static const String photoCategoryExterior = 'photoCategoryExterior';
  static const String photoCategoryInterior = 'photoCategoryInterior';

  /// Inspection Points
  static const String pointsReview = 'pointsReview';
  static const String inspectionDetailsTitle = 'inspectionDetailsTitle';
  static const String doneBtn = 'doneBtn';
  static const String remaining = 'remaining';
  static const String imageRequired = 'imageRequired';
  static const String imageRequiredMsg = 'imageRequiredMsg';
  static const String noteRequired = 'noteRequired';
  static const String noteRequiredMsg = 'noteRequiredMsg';
  static const String resetPointsTitle = 'resetPointsTitle';
  static const String resetPointsContent = 'resetPointsContent';
  static const String resetPointsConfirm = 'resetPointsConfirm';
  static const String selectStatus = 'selectStatus';
  static const String addNoteTitle = 'addNoteTitle';
  static const String noteHint = 'noteHint';
  static const String noteFieldLabel = 'noteFieldLabel';
  static const String noteValidation = 'noteValidation';
  static const String noteSavedSuccessMsg = 'noteSavedSuccessMsg';

  static const String startInspection = 'startInspection';
  static const String generalNoteTitle = 'generalNoteTitle';
  static const String rejectionNoteTitle = 'rejectionNoteTitle';
  static const String noteOptionalHint = 'noteOptionalHint';
  static const String confirmSubmit = 'confirmSubmit';
  static const String cancelBtn = 'inspectionCancelBtn';
  static const String submitConfirmSubtitle = 'submitConfirmSubtitle';
  static const String rejectConfirmSubtitle = 'rejectConfirmSubtitle';
  static const String addNoteLabel = 'addNoteLabel';
  static const String optionalTag = 'optionalTag';

  /// OBD
  static const String obdFileName = 'obdFileName';
  static const String uploadObdReport = 'uploadObdReport';
  static const String obdCodesTitle = 'obdCodesTitle';
  static const String obdCodeRequired = 'obdCodeRequired';
  static const String obdCodeRequiredMsg = 'obdCodeRequiredMsg';
  static const String obdDescRequired = 'obdDescRequired';
  static const String obdDescRequiredMsg = 'obdDescRequiredMsg';
  static const String obdDataRequired = 'obdDataRequired';
  static const String obdDataRequiredMsg = 'obdDataRequiredMsg';
  static const String obdFileTooLarge = 'obdFileTooLarge';
  static const String obdFileTooLargeMsg = 'obdFileTooLargeMsg';
  static const String obdUploadSuccess = 'obdUploadSuccess';
  static const String obdUploadFailed = 'obdUploadFailed';
  static const String obdDeleteSuccess = 'obdDeleteSuccess';
  static const String obdDeleteReportTitle = 'obdDeleteReportTitle';
  static const String obdDeleteReportConfirm = 'obdDeleteReportConfirm';
  static const String obdCodeDeletedSuccess = 'obdCodeDeletedSuccess';
  static const String obdCodeDeletedSuccessMsg = 'obdCodeDeletedSuccessMsg';
  static const String obdCodeAddSuccess = 'obdCodeAddSuccess';
  static const String obdCodeAddSuccessMsg = 'obdCodeAddSuccessMsg';
  static const String obdCodeEditSuccess = 'obdCodeEditSuccess';
  static const String obdCodeEditSuccessMsg = 'obdCodeEditSuccessMsg';
  static const String obdActionError = 'obdActionError';
  static const String obdAddCode = 'obdAddCode';
  static const String obdEditCode = 'obdEditCode';
  static const String obdCodeLabel = 'obdCodeLabel';
  static const String obdCodeHint = 'obdCodeHint';
  static const String obdDescLabel = 'obdDescLabel';
  static const String obdDescHint = 'obdDescHint';
  static const String obdNoCodesYet = 'obdNoCodesYet';
  static const String obdReportSection = 'obdReportSection';
  static const String obdOptionalBadge = 'obdOptionalBadge';

  /// Steps
  static const String stepLabel = 'stepLabel';

  /// Submit validation
  static const String submitValidationTitle = 'submitValidationTitle';
  static const String submitValidationMsg = 'submitValidationMsg';
  static const String submitSuccessTitle = 'submitSuccessTitle';
  static const String submitSuccessMsg = 'submitSuccessMsg';
  static const String stepIncomplete = 'stepIncomplete';
  static const String stepVehicleInfo = 'stepVehicleInfo';
  static const String stepPoints = 'stepPoints';
  static const String stepPhotos = 'stepPhotos';
  static const String stepBody = 'stepBody';
  static const String stepObd = 'stepObd';

  /// Step validation
  static const String vehicleInfoRequired = 'vehicleInfoRequired';
  static const String vehicleInfoRequiredMsg = 'vehicleInfoRequiredMsg';
  static const String allPointsRequired = 'allPointsRequired';
  static const String allPointsRequiredMsg = 'allPointsRequiredMsg';
  static const String pointsRequired = 'pointsRequired';
  static const String pointsRequiredMsg = 'pointsRequiredMsg';
  static const String photosRequired = 'photosRequired';
  static const String photosRequiredMsg = 'photosRequiredMsg';
  static const String allPhotosRequired = 'allPhotosRequired';
  static const String allPhotosRequiredMsg = 'allPhotosRequiredMsg';
}
