part of 'dashboard_screen.dart';

extension _DashboardScreenContent on _DashboardScreenState {
  Widget _buildActiveTabContent() {
    if (!_isTabAllowed(_activeTab)) {
      return const Center(
        child: Text(
          'Access denied for this duty scope.',
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.red),
        ),
      );
    }
    switch (_activeTab) {
      case 'home':
        return HomeTab(currentUser: widget.currentUser, appData: _appData, onStateChanged: _refresh);
      case 'production':
        return ProductionDeliveryTab(currentUser: widget.currentUser, appData: _appData, onStateChanged: _refresh);
      case 'preorder':
        return PreOrderTab(currentUser: widget.currentUser, appData: _appData, onStateChanged: _refresh);
      case 'eod':
        return EodTab(appData: _appData, onStateChanged: _refresh, onTabChanged: _setActiveTab);
      case 'expense':
        return ExpenseTab(currentUser: widget.currentUser, appData: _appData, onStateChanged: _refresh);
      case 'expense_book':
        return ExpenseLedgerTab(appData: _appData);
      case 'ledger':
        return VerifiedLedgerTab(appData: _appData);
      case 'catalog':
        return CatalogTab(appData: _appData, onStateChanged: _refresh);
      case 'staff':
        return StaffManagerTab(currentUser: widget.currentUser, appData: _appData, onStateChanged: _refresh);
      default:
        return const Center(child: Text('Work in progress'));
    }
  }
}