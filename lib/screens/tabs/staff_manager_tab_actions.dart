part of 'staff_manager_tab.dart';

extension _StaffManagerTabActions on _StaffManagerTabState {
  void _showMessage(String message, {required bool error}) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: error ? Colors.red : Colors.green,
      ),
    );
  }

  bool _isNameDuplicate(String name) {
    final normalized = name.trim().toLowerCase();
    return widget.appData.staffDirectory.any(
      (staff) => (staff['name'] ?? '').toString().trim().toLowerCase() == normalized,
    );
  }

  void _addStaff() {
    if (!_isOwnerOnlyContext) {
      _showMessage('Staff management is owner-only.', error: true);
      return;
    }

    final name = _stfNameCtrl.text.trim();
    if (name.length < 2 || name.length > 100) {
      _showMessage('Name must be 2-100 characters.', error: true);
      return;
    }
    if (_isNameDuplicate(name)) {
      _showMessage('A staff member with this name already exists.', error: true);
      return;
    }

    final selectedRole = _stfRole;
    final selectedPerm = _stfPerm;
    final staffId = 's${Random().nextInt(1000000).toString().padLeft(6, '0')}';
    final record = {
      'id': staffId,
      'name': name,
      'role': selectedRole,
      'can_manage_products': selectedPerm,
    };

    _setStaffState(() {
      widget.appData.staffDirectory.add(record);
      _stfNameCtrl.clear();
      _stfRole = 'FH';
      _stfPerm = false;
    });
    widget.onStateChanged();

    AuditLogger.action(
      actor: _actorName,
      role: 'Owner',
      action: 'create',
      entity: 'staff_member',
      entityId: staffId,
      metadata: {'role': selectedRole, 'can_manage_products': selectedPerm},
    );
    _showMessage('Staff member added.', error: false);
  }

  void _toggleMenuPermission(Map<String, dynamic> staff, bool value) {
    if (!_isOwnerOnlyContext) {
      _showMessage('Permission changes are owner-only.', error: true);
      return;
    }
    _setStaffState(() => staff['can_manage_products'] = value);
    widget.onStateChanged();

    AuditLogger.action(
      actor: _actorName,
      role: 'Owner',
      action: 'update',
      entity: 'staff_member',
      entityId: (staff['id'] ?? '').toString(),
      metadata: {'can_manage_products': value},
    );
  }
}
