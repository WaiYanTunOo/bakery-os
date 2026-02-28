import 'dart:math';

import 'package:flutter/material.dart';

import '../../data/app_data.dart';
import '../../utils/audit_logger.dart';

part 'staff_manager_tab_actions.dart';
part 'staff_manager_tab_view.dart';

class StaffManagerTab extends StatefulWidget {
  final Map<String, dynamic> currentUser;
  final AppData appData;
  final VoidCallback onStateChanged;

  const StaffManagerTab({
    super.key,
    required this.currentUser,
    required this.appData,
    required this.onStateChanged,
  });

  @override
  State<StaffManagerTab> createState() => _StaffManagerTabState();
}

class _StaffManagerTabState extends State<StaffManagerTab> {
  final TextEditingController _stfNameCtrl = TextEditingController();
  String _stfRole = 'FH';
  bool _stfPerm = false;

  bool get _isOwnerOnlyContext {
    return widget.currentUser['role'] == 'Owner';
  }

  String get _actorName {
    return (widget.currentUser['name'] ?? 'unknown').toString();
  }

  @override
  void dispose() {
    _stfNameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _buildStaffManagerContent();
  }

  void _setStaffState(VoidCallback updater) {
    if (!mounted) return;
    setState(updater);
  }
}
