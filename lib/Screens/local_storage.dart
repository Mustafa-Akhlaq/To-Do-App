import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static SharedPreferences? _preferences;

  static Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  static Future<void> createUser(
      String name, String email, String password) async {
    Map<String, dynamic> userData = {
      'name': name,
      'email': email,
      'password': password,
    };
    await _preferences?.setString(email, jsonEncode(userData));
  }

  static Future<bool> loginUser(String email, String password) async {
    String? userString = _preferences?.getString(email);
    if (userString != null) {
      Map<String, dynamic> userData = jsonDecode(userString);
      return userData['password'] == password;
    }
    return false;
  }

  static String? getCurrentUser() {
    return _preferences?.getString('currentUser');
  }

  static Future<void> setCurrentUser(String email) async {
    await _preferences?.setString('currentUser', email);
  }

  static Future<void> logout() async {
    await _preferences?.remove('currentUser');
    await _preferences?.setBool('isLoggedIn', false);
  }

  static Future<void> saveUserTasks(
      String email, List<Map<String, dynamic>> tasks) async {
    await _preferences?.setString('tasks_$email', jsonEncode(tasks));
  }

  static List<Map<String, dynamic>> loadUserTasks(String email) {
    String? tasksString = _preferences?.getString('tasks_$email');
    if (tasksString != null) {
      List<dynamic> taskList = jsonDecode(tasksString);
      return taskList.map((task) => Map<String, dynamic>.from(task)).toList();
    }
    return [];
  }

  static const String taskKey = 'tasks';

  static Future<List<Map<String, dynamic>>> loadTasks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? tasksString = prefs.getString(taskKey);
    if (tasksString != null) {
      List<dynamic> taskList = jsonDecode(tasksString);
      return taskList.map((task) => Map<String, dynamic>.from(task)).toList();
    }
    return [];
  }

  static Future<void> saveTasks(List<Map<String, dynamic>> tasks) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String tasksString = jsonEncode(tasks);
    await prefs.setString(taskKey, tasksString);
  }

  static Future<void> clearTasks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(taskKey);
  }
}
