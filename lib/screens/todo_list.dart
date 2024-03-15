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

class _toDoListPageState extends State<toDoListPage> {
  static int numberOfCompletedTasks = 0;
  static int numberOfWaitingTasks = 0;


  bool isLoading=true;
  List items=[];
  @override
  void initState() {

    super.initState();
    fetchToDo();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(
        title: Text('All To Do List'),
      ),
      body: Visibility(
        visible:isLoading,
          child: Center(child:CircularProgressIndicator()),
        replacement:RefreshIndicator(
          onRefresh: fetchToDo,
          child: ListView.builder(
            itemCount: items.length,
              itemBuilder: (context,index){
              final item=items[index] as Map;
              final id=item['_id'] as String;
            return ListTile(
              leading: CircleAvatar(child:Text('${index+1}')),
              title: Text(item['title']),
              subtitle: Text(item['description']),
              trailing: PopupMenuButton(
                onSelected: (value){
                  if(value=='edit'){
                    navigateToEditPage(item);
                  }
                  else if(value=='delete'){
                    deleteById(id);
                  }
                  else if(value=='tamamlandı'){
                    separateCompletedTasks(id);
                  }

                },
                itemBuilder: (context){
                  return[
                    PopupMenuItem(child: Text('Edit'),value:'edit',),
                    PopupMenuItem(child: Text('Delete'),value:'delete',),
                    PopupMenuItem(child: Text('Tamamlandı'),value:'tamamlandı',),
                  ];
                },
              ),
            );
          }),
        ),
      ),
    );
  }
  Future<void> navigateToEditPage(Map item)async{
    final route=MaterialPageRoute(builder: (context)=>addToDoPage(todo:item),);
   await Navigator.push(context,route);
   setState(() {
     isLoading=true;
   });
   fetchToDo();
  }
  Future<void>deleteById(String id)async{

    final url='https://api.nstack.in/v1/todos/$id';
    final uri=Uri.parse(url);

    final response= await http.delete(uri);
    if(response.statusCode==200){
      final filtered=items.where((element)=>element['_id']!=id).toList();
      setState(() {
  items=filtered;
});

    }
    else{
      showErrorMessage('Deletion Failed');
    }
  }
  void separateCompletedTasks(String id) {
    int index = items.indexWhere((item) => item['_id'] == id);
    if (index != -1) {
      items[index]['is_completed'] = true;
    }
    numberOfCompletedTasks++;
    numberOfWaitingTasks--;

  }
  Future<void> fetchToDo()async {

    final url ='https://api.nstack.in/v1/todos?page=1&limit=10';
    final uri=Uri.parse(url);
    final response=await http.get(uri);
    if(response.statusCode==200){
     final json=jsonDecode(response.body) as Map;
     final result= json['items'] as List;
     setState(() {
       items=result;
     });
    }
    setState(() {
      isLoading=false;
    });
    List<Map> completedTasks = [];
    List<Map> waitingTasks = [];

    for (var item in items) {
      if (item['is_completed'] == true) {
        completedTasks.add(item);
      } else {
        waitingTasks.add(item);
      }
    }
    numberOfWaitingTasks=waitingTasks.length;
    numberOfCompletedTasks=completedTasks.length;

    setState(() {
      items = completedTasks + waitingTasks;
    });
  }

  void showErrorMessage(String message){
    final snackBar= SnackBar(content:Text(
      message,
      style: TextStyle(color:Colors.white),
    ),
      backgroundColor: Colors.red,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
