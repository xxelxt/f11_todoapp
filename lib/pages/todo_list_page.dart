import 'package:flutter/material.dart';
import '../models/todo.dart';
import '../services/api_services.dart';
import '../pages/add_edit_todo_list.dart';

class TodoListPage extends StatefulWidget {
  @override
  _TodoListPageState createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  final ApiService apiService = ApiService();
  List<Todo> todos = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchTodos();
  }

  void fetchTodos() async {
    try {
      final fetchedTodos = await apiService.fetchTodos();
      setState(() {
        todos = fetchedTodos;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching todos: $e');
    }
  }

  void toggleTodoCompletion(Todo todo) async {
    final updatedTodo = Todo(
      id: todo.id,
      title: todo.title,
      completed: !todo.completed,
    );
    await apiService.updateTodo(updatedTodo);

    setState(() {
      final index = todos.indexWhere((element) => element.id == todo.id);
      if (index != -1) {
        todos[index] = updatedTodo;
      }
    });
  }

  void deleteTodoItem(int id) async {
    await apiService.deleteTodo(id);
    setState(() {
      todos.removeWhere((todo) => todo.id == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('To-Do List')),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: todos.length,
        itemBuilder: (context, index) {
          final todo = todos[index];
          return ListTile(
            leading: Checkbox(
              value: todo.completed,
              onChanged: (_) => toggleTodoCompletion(todo),
            ),
            title: Text(
              todo.title,
              style: TextStyle(
                decoration: todo.completed
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
              ),
            ),
            trailing: IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () => deleteTodoItem(todo.id),
            ),
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddEditTodoPage(todo: todo),
                ),
              );
              if (result == true) {
                fetchTodos();
              }
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddEditTodoPage(),
            ),
          );
          if (result == true) {
            fetchTodos();
          }
        },
      ),
    );
  }
}
