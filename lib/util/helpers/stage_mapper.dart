import 'package:fahis_inspector/enums/inspection_stages.dart';

class StageMapper {
  static InspectionStage mapOrderItemStage(String stage) {
    switch (stage.toLowerCase()) {
      case 'pending':
        return InspectionStage.pending;
      case 'accepted':
        return InspectionStage.accepted;
      case 'completed':
        return InspectionStage.finished;
      case 'finished':
        return InspectionStage.finished;
      case 'rejected':
        return InspectionStage.rejected;
      case 'info':
        return InspectionStage.info;
      case 'points':
        return InspectionStage.points;
      case 'photos':
        return InspectionStage.photos;
      case 'body':
        return InspectionStage.body;
      case 'obd':
        return InspectionStage.obd;
      default:
        return InspectionStage.pending;
    }
  }
}
