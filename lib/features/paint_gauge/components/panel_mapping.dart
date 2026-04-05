import 'package:fahis_inspector/paint_gauge/protocol/models.dart';

/// Which car view a panel belongs to.
enum CarView { top, left, right }

/// Defines a tappable/highlightable region on a car illustration view.
///
/// All coordinates are normalized 0-100% relative to the image dimensions.
/// Tune [left], [top], [width], [height] visually against the backend car images.
class PanelRegion {
  final CarPart part;
  final CarView view;
  final double left;
  final double top;
  final double width;
  final double height;

  const PanelRegion({
    required this.part,
    required this.view,
    required this.left,
    required this.top,
    required this.width,
    required this.height,
  });
}

/// Canonical mapping of all 19 CarPart panels to their visual positions.
///
/// Coordinates are approximate starting values — tune against actual
/// backend car images for pixel-perfect alignment.
const List<PanelRegion> kPanelRegions = [
  // ── Top view (3 panels) ──
  PanelRegion(part: CarPart.frontHatch, view: CarView.top, left: 22, top: 2, width: 56, height: 28),
  PanelRegion(part: CarPart.roof, view: CarView.top, left: 18, top: 33, width: 64, height: 34),
  PanelRegion(part: CarPart.trunkCover, view: CarView.top, left: 22, top: 70, width: 56, height: 28),

  // ── Left view (8 panels, front-to-back) ──
  PanelRegion(part: CarPart.flWing, view: CarView.left, left: 0, top: 18, width: 14, height: 64),
  PanelRegion(part: CarPart.lAColumn, view: CarView.left, left: 14, top: 8, width: 6, height: 84),
  PanelRegion(part: CarPart.flDoor, view: CarView.left, left: 20, top: 18, width: 17, height: 64),
  PanelRegion(part: CarPart.lBColumn, view: CarView.left, left: 37, top: 8, width: 6, height: 84),
  PanelRegion(part: CarPart.blDoor, view: CarView.left, left: 43, top: 18, width: 17, height: 64),
  PanelRegion(part: CarPart.lCColumn, view: CarView.left, left: 60, top: 8, width: 6, height: 84),
  PanelRegion(part: CarPart.blWing, view: CarView.left, left: 66, top: 18, width: 14, height: 64),
  PanelRegion(part: CarPart.lDColumn, view: CarView.left, left: 80, top: 8, width: 6, height: 84),

  // ── Right view (8 panels, back-to-front) ──
  PanelRegion(part: CarPart.rDColumn, view: CarView.right, left: 14, top: 8, width: 6, height: 84),
  PanelRegion(part: CarPart.brWing, view: CarView.right, left: 20, top: 18, width: 14, height: 64),
  PanelRegion(part: CarPart.rCColumn, view: CarView.right, left: 34, top: 8, width: 6, height: 84),
  PanelRegion(part: CarPart.brDoor, view: CarView.right, left: 40, top: 18, width: 17, height: 64),
  PanelRegion(part: CarPart.rBColumn, view: CarView.right, left: 57, top: 8, width: 6, height: 84),
  PanelRegion(part: CarPart.frDoor, view: CarView.right, left: 63, top: 18, width: 17, height: 64),
  PanelRegion(part: CarPart.rAColumn, view: CarView.right, left: 80, top: 8, width: 6, height: 84),
  PanelRegion(part: CarPart.frWing, view: CarView.right, left: 86, top: 18, width: 14, height: 64),
];

/// Panels belonging to a specific car view.
List<PanelRegion> panelsForView(CarView view) =>
    kPanelRegions.where((r) => r.view == view).toList();
