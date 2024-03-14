import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
class addToDoPage extends StatefulWidget {
  final Map? todo;
  const addToDoPage({
    super.key,
  this.todo,
  });

  @override
  State<addToDoPage> createState() => _addToDoPageState();
}

class _addToDoPageState extends State<addToDoPage> {
  TextEditingController titleController=TextEditingController();
  TextEditingController descriptionController=TextEditingController();
  bool isEdit=false;

  @override
  void initState() {

    super.initState();
    final todo=widget.todo;
    if(todo!=null){
      isEdit=true;
      final title=todo['title'];
      final description=todo['description'];
      titleController.text=title;
      descriptionController.text=description;
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:Text(
           isEdit?'Edit Todo' : 'Add Todo',
        ),
      ),
      body:ListView(
        padding: EdgeInsets.all(20),
        children: [
          TextField(
            controller: titleController,
            decoration: InputDecoration(hintText:'Title' ),
          ),
          SizedBox(height: 20),
          TextField(
            controller: descriptionController,
            decoration:InputDecoration(hintText: 'Description'),
            keyboardType: TextInputType.multiline,
            minLines: 5,
            maxLines: 10,
          ),
          SizedBox(height: 20),
          ElevatedButton(onPressed:isEdit? updateData : submitData,
            child: Text(
          isEdit? 'Update'  :  'Submit',
          ),)
        ],
      )
    );
  }

  Future<void>  updateData() async {
    final todo=widget.todo;
    if(todo==null){
      print('Update unsucces');
      return;
    }
    final id=todo['_id'];
    //final isCompleted =todo['is_completed'];
    final title = titleController.text;
    final description = descriptionController.text;
    final body = {
      "title": title,
      "description": description,
      "is_completed": false,

    };

    final url="https://api.nstack.in/v1/todos/$id";
    final uri=Uri.parse(url);
    final response =await http.put(uri,body:jsonEncode(body),headers: {'Content-Type':'application/json'});
    if(response.statusCode==200 ){
      titleController.text='';
      descriptionController.text='';
      showSuccesMessage('Update Succes');
    }else{
      showErrorMessage('Update Failed');
    }

  }

  Future<void>  submitData() async{
    final title =titleController.text;
    final description=descriptionController.text;
    final body= {
      "title":title,
      "description":description,
      "is_completed": false,
    };
    final url="https://api.nstack.in/v1/todos";
    final uri=Uri.parse(url);
    final response =await http.post(uri,body:jsonEncode(body),headers: {'Content-Type':'application/json'});
    if(response.statusCode==201){
      titleController.text='';
      descriptionController.text='';
      showSuccesMessage('Creation Succes');
    }else{
      showErrorMessage('Creation Failed');
    }
 }
 void showSuccesMessage(String message){
   final snackBar= SnackBar(content:Text(
     message,
     style: TextStyle(color:Colors.white),
   ),
     backgroundColor: Colors.green,
   );
   ScaffoldMessenger.of(context).showSnackBar(snackBar);
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

