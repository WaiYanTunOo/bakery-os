part of 'production_delivery_tab.dart';

extension _ProductionDeliveryTabStateHelpers on _ProductionDeliveryTabState {
  bool get _canRequestShowcase {
    final role = widget.currentUser['role'];
    return role == 'FH' || role == 'Owner';
  }

  bool get _canCompleteShowcase {
    final role = widget.currentUser['role'];
    return role == 'BH' || role == 'Owner';
  }

  void _setSelectedShowcaseItem(String? value) {
    _setProductionState(() => _fhReqItem = value);
  }

  void _setTargetDate(String value) {
    _setProductionState(() => _targetDate = value);
  }

  void _setPreOrderSummary({
    required Map<String, int> verified,
    required int pending,
    required int inProgress,
    required int ready,
  }) {
    _setProductionState(() {
      _verifiedPreOrders = verified;
      _pendingForDate = pending;
      _inProgressForDate = inProgress;
      _readyForDate = ready;
    });
  }
}
