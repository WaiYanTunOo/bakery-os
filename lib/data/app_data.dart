import 'mock_data.dart';

class AppData {
  List<Map<String, dynamic>> menuItems = List.from(initialMenuItems);
  List<Map<String, dynamic>> staffDirectory = List.from(initialStaff);
  List<Map<String, dynamic>> eodReports = [];
  List<Map<String, dynamic>> onlineOrders = [];
  List<Map<String, dynamic>> expenses = [];
  List<Map<String, dynamic>> showcaseRequests = [];
}