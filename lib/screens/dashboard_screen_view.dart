part of 'dashboard_screen.dart';

extension _DashboardScreenView on _DashboardScreenState {
  Widget _buildDashboard() {
    final navItems = _getNavItems();
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(backgroundColor: Colors.white, elevation: 1, title: _buildAppBarTitle()),
      body: _isLoading ? _buildLoadingState() : _buildLoadedState(navItems),
    );
  }

  Widget _buildAppBarTitle() {
    return Row(children: [
      const Icon(Icons.storefront, color: Colors.indigo),
      const SizedBox(width: 8),
      const Text('BakeryOS', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)),
      const Spacer(),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(color: Colors.indigo.shade50, borderRadius: BorderRadius.circular(20)),
        child: Row(children: [const Icon(Icons.person, size: 16, color: Colors.indigo), const SizedBox(width: 8), Text('${widget.currentUser['name']} (${widget.currentUser['role']})', style: const TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold, fontSize: 14))]),
      ),
      const SizedBox(width: 8),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(20)),
        child: Text('Duty: ${_roleDutyTitle()}', style: TextStyle(color: Colors.green.shade900, fontWeight: FontWeight.w600, fontSize: 12)),
      ),
      const SizedBox(width: 16),
      IconButton(icon: const Icon(Icons.logout), tooltip: 'Sign out', onPressed: _handleSignOut),
    ]);
  }

  Widget _buildLoadingState() {
    return const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [CircularProgressIndicator(color: Colors.indigo), SizedBox(height: 16), Text('Syncing with Supabase...', style: TextStyle(color: Colors.grey))]));
  }

  Widget _buildLoadedState(List<Map<String, dynamic>> navItems) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _buildSidebar(navItems),
      const VerticalDivider(width: 1, thickness: 1),
      Expanded(child: Padding(padding: const EdgeInsets.all(24), child: SingleChildScrollView(child: _buildActiveTabContent()))),
    ]);
  }

  Widget _buildSidebar(List<Map<String, dynamic>> navItems) {
    return Container(width: 250, color: Colors.white, child: ListView(padding: const EdgeInsets.all(16), children: navItems.map(_buildNavItem).toList()));
  }

  Widget _buildNavItem(Map<String, dynamic> item) {
    final isSelected = _activeTab == item['id'];
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        selected: isSelected,
        selectedTileColor: Colors.indigo.shade50,
        leading: Icon(item['icon'], color: isSelected ? Colors.indigo : Colors.grey.shade600),
        title: Text(item['label'], style: TextStyle(color: isSelected ? Colors.indigo : Colors.grey.shade800, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
        onTap: () => _setActiveTab(item['id'].toString()),
      ),
    );
  }
}