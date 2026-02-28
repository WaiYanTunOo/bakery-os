part of 'dashboard_screen.dart';

extension _DashboardScreenAuth on _DashboardScreenState {
  Future<void> _handleSignOut() async {
    await AuthService.instance.signOut();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const AuthGateScreen()),
    );
  }

  bool _isTabAllowed(String tabId) {
    final allowedIds = _getNavItems()
        .map((item) => item['id']?.toString())
        .whereType<String>()
        .toSet();
    return allowedIds.contains(tabId);
  }

  String _roleDutyTitle() {
    switch ((widget.currentUser['role'] ?? '').toString()) {
      case 'Owner':
        return 'Business Oversight';
      case 'FH':
        return 'Front House Operations';
      case 'BH':
        return 'Back House Production';
      default:
        return 'Assigned Duty';
    }
  }
}
