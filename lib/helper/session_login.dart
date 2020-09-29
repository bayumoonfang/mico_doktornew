import 'package:shared_preferences/shared_preferences.dart';

class Session {
  static Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  var value;

  static Future<String> getPhone() async {
    final SharedPreferences preferences = await _prefs;
    return preferences.getString("phone");
  }

  static Future<String> getEmail() async {
    final SharedPreferences preferences = await _prefs;
    return preferences.getString("email");
  }

  static Future<String> getIDCust() async {
    final SharedPreferences preferences = await _prefs;
    return preferences.getString("idcustomer");
  }

  static Future<String> getAccnumber() async {
    final SharedPreferences preferences = await _prefs;
    return preferences.getString("accnumber");
  }

  static Future<int> getValue() async {
    final SharedPreferences preferences = await _prefs;
    return preferences.getInt("value");
  }

  static Future<String> getBasedLogin() async {
    final SharedPreferences preferences = await _prefs;
    return preferences.getString("basedlogin");
  }


}