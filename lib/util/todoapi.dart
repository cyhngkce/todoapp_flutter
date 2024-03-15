import 'dart:convert';
import 'package:http/http.dart' as http;

Future<List<Map<dynamic, dynamic>>> fetchWaitingTasks() async {
  final url = 'https://api.nstack.in/v1/todos?page=1&limit=10';
  final uri = Uri.parse(url);
  final response = await http.get(uri);

  if (response.statusCode == 200) {
    final json = jsonDecode(response.body) as Map;
    final List<Map<dynamic, dynamic>> result = (json['items'] as List).cast<Map<dynamic, dynamic>>();

    List<Map<dynamic, dynamic>> waitingTasks = [];

    for (var item in result) {
      if (item['is_completed'] != true) {
        waitingTasks.add(item);
      }
    }

    return waitingTasks;
  } else {

    print('Error: ${response.statusCode}');
    return [];
  }
}