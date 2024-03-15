import 'dart:convert';

import 'package:flutter/foundation.dart';
import'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:todoapp_flutter/screens/add_page.dart';
class toDoListPage extends StatefulWidget {
  const toDoListPage({super.key});

static int getCompletedTask(){
  return _toDoListPageState.numberOfCompletedTasks;
}
  static int getWaitingTask(){
    return _toDoListPageState.numberOfWaitingTasks;
  }
  @override
  State<toDoListPage> createState() => _toDoListPageState();

}

class _toDoListPageState extends State<toDoListPage> with SingleTickerProviderStateMixin {
  static int numberOfCompletedTasks = 0;
  static int numberOfWaitingTasks = 0;
  late TabController _tabController;
  bool isLoading = true;
  List<Map> completedTasks = [];
  List<Map> waitingTasks = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabSelection);
    fetchToDo();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabSelection() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('All To Do List'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Tamamlanan Görevler'),
            Tab(text: 'Bekleyen Görevler'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCompletedTasksTab(),
          _buildWaitingTasksTab(),
        ],
      ),
    );
  }

  Widget _buildCompletedTasksTab() {
    return _buildTaskList(completedTasks);
  }

  Widget _buildWaitingTasksTab() {
    return _buildTaskList(waitingTasks);
  }

  Widget _buildTaskList(List<Map> tasks) {
    return Visibility(
      visible: isLoading,
      child: Center(child: CircularProgressIndicator()),
      replacement: RefreshIndicator(
        onRefresh: fetchToDo,
        child: ListView.builder(
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            final item = tasks[index];
            final id = item['_id'] as String;
            return ListTile(
              leading: CircleAvatar(child: Text('${index + 1}')),
              title: Text(item['title'] ?? ''),
              subtitle: Text(item['description'] ?? ''),
              trailing: PopupMenuButton(
                onSelected: (value) {
                  if (value == 'edit') {
                    navigateToEditPage(item);
                  } else if (value == 'delete') {
                    deleteById(id);
                  } else if (value == 'tamamlandı') {
                    separateCompletedTasks(item);
                  }
                },
                itemBuilder: (context) {
                  return [
                    PopupMenuItem(child: Text('Edit'), value: 'edit'),
                    PopupMenuItem(child: Text('Delete'), value: 'delete'),
                    PopupMenuItem(child: Text('Tamamlandı'), value: 'tamamlandı'),
                  ];
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> fetchToDo() async {
    final url = 'https://api.nstack.in/v1/todos?page=1&limit=10';
    final uri = Uri.parse(url);
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map;
      final result = json['items'] as List;
      completedTasks.clear();
      waitingTasks.clear();
      for (var item in result) {
        if (item['is_completed'] == true) {
          completedTasks.add(item);
        } else {
          waitingTasks.add(item);
        }
      }
    }
    setState(() {
      numberOfCompletedTasks = completedTasks.length;
      numberOfWaitingTasks = waitingTasks.length;
      isLoading = false;
    });
  }

  Future<void> navigateToEditPage(Map item) async {
    final route = MaterialPageRoute(builder: (context) => addToDoPage(todo: item));
    await Navigator.push(context, route);
    setState(() {
      isLoading = true;
    });
    fetchToDo();
  }

  Future<void> deleteById(String id) async {
    final url = 'https://api.nstack.in/v1/todos/$id';
    final uri = Uri.parse(url);
    final response = await http.delete(uri);
    if (response.statusCode != 200) {
      showErrorMessage('Deletion Failed');
    }
  }

  void separateCompletedTasks(Map item) {
    final String id = item['_id'];
    final bool isCompleted = item['is_completed'] ?? false;
    final String url = 'https://api.nstack.in/v1/todos/$id';
    final uri = Uri.parse(url);
    http.put(uri, body: jsonEncode({'is_completed': !isCompleted}));
    if (isCompleted) {
      waitingTasks.add(item);
      completedTasks.remove(item);
      numberOfWaitingTasks++;
      numberOfCompletedTasks--;
    } else {
      waitingTasks.remove(item);
      completedTasks.add(item);
      numberOfWaitingTasks--;
      numberOfCompletedTasks++;
    }
    setState(() {});
  }

  void showErrorMessage(String message) {
    final snackBar = SnackBar(
      content: Text(message, style: TextStyle(color: Colors.white)),
      backgroundColor: Colors.red,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}