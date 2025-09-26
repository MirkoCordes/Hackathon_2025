import 'package:http/http.dart' as http;

class LoginRepository {
  static const String url = "http://localhost:8080/api/login";

  String getJwt() {
    return 'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJhZG1pbiIsImlhdCI6MTc1ODg3ODExMSwiZXhwIjoxNzU4OTY0NTExfQ.SBsI-H3oZHu79t7_AbnmLvWAskyFOJt2zWd5mqLDw3M';
  }

  void setJwt(String jwt) {}

  Future<void> login(String username, String pw) async {
    final response = await http.post(Uri.parse('$url'));
  }

  void register(String username, String pw, String email) {}
}
