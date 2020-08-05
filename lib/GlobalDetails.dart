class ServerDetails {
//  static final server = "http://10.130.154.50:8080/assignment8/";
  static final server = "http://10.130.155.12:8080/flutter/";
}

class User {
  static String _uid;
  static getUid() => _uid;
  static setUid(String uid) {
    _uid = uid;
  }
}