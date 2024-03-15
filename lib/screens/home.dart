import 'package:flutter/material.dart';
import 'package:todoapp_flutter/screens/add_page.dart';
import 'package:todoapp_flutter/screens/todo_list.dart';
import 'package:todoapp_flutter/util/todoapi.dart';
class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  Future<void> _refreshPage() async {

    setState(() {
      toDoListPage.getCompletedTask();
      toDoListPage.getWaitingTask();
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (_selectedIndex == 0) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => addToDoPage()),
      );
    } else if (_selectedIndex == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => toDoListPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("To Do List App"),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshPage,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Toplam Görev Sayısı:',
                style: TextStyle(fontSize: 20),
              ),
              Text(
                '${toDoListPage.getCompletedTask() + toDoListPage.getWaitingTask()}',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Text(
                'Tamamlanan Görev Sayısı:',
                style: TextStyle(fontSize: 20),
              ),
              Text(
                '${toDoListPage.getCompletedTask()}',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Text(
                'Bekleyen Görev Sayısı:',
                style: TextStyle(fontSize: 20),
              ),
              Text(
                '${toDoListPage.getWaitingTask()}',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Ana Sayfa',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Arama',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
  }

}