import 'dart:convert';
import 'package:http/http.dart' as http;

class ResendService {
  final String _apiKey;
  ResendService(this._apiKey);

  Future<void> sendAdminApprovalEmail({
    required String toEmail,
    required String newUserName,
    required String newUserEmail,
    required String newUserBio,
    required String approvalLink,
  }) async {
    final response = await http.post(
      Uri.parse('https://api.resend.com/emails'),
      headers: {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'from': 'Kitties FTW <admin@kittiesftw.com>',
        'to': [toEmail],
        'subject': 'New account request from $newUserName',
        'html': '''
          <div style="font-family: sans-serif; max-width: 480px; margin: 0 auto;">
            <h2>New Account Request</h2>
            <p>Someone wants to post on Kitties FTW!</p>
            <p><strong>Name:</strong> $newUserName</p>
            <p><strong>Email:</strong> $newUserEmail</p>
            <p><strong>Bio:</strong> ${newUserBio.isEmpty ? '(none provided)' : newUserBio}</p>
            <br/>
            <a href="$approvalLink"
               style="background:#F88379;color:white;padding:12px 24px;
                      border-radius:6px;text-decoration:none;font-weight:bold;">
              Approve Account
            </a>
            <br/><br/>
            <p style="color:#999;font-size:12px;">
              If you did not expect this request, ignore this email.
            </p>
          </div>
        ''',
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to send approval email: ${response.body}');
    }
  }
}
