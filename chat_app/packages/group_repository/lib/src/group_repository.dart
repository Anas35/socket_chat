import 'dart:convert';
import 'dart:io';

import 'package:group_repository/group_repository.dart';
import 'package:http/http.dart' as http;
import 'package:models/models.dart';

class GroupRepository {

  static const _url = 'http://localhost:8080/group';

  Future<Group> createGroup(String groupName, String userId) async {
    final response = await http.post(
      Uri.parse('$_url/create'),
      body: jsonEncode({
        'groupName': groupName,
        'userId': userId,
      }),
    );

    if (response.statusCode != 201) {
      throw GroupException(response.body);
    } else {
      final result = jsonDecode(response.body) as Map<String, Object?>;
      return Group.fromJson(result);
    }
  }

  Future<Group> joinGroup(Participants participants) async {
    final response = await http.post(
      Uri.parse('$_url/join'),
      body: jsonEncode(participants.toJson()),
    );

    if (response.statusCode != HttpStatus.accepted) {
      throw GroupException(response.body);
    } else {
      final result = jsonDecode(response.body) as Map<String, Object?>;
      return Group.fromJson(result);
    }
  }

  Future<List<MessageDetails>> getGroupMessages(String groupId) async {
    final response = await http.get(
      Uri.parse('$_url/$groupId/messages'),
    );

    if (response.statusCode != 200) {
      throw GroupException(response.body);
    } else {
      final result = jsonDecode(response.body) as List<dynamic>;
      final messages = result.map(
        (message) => MessageDetails.fromJson(message as Map<String, dynamic>),
      ).toList();
      return messages;
    }
  }

}
