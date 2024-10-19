import 'package:flutter/material.dart';
import '../models/todo.dart';
import '../services/api_services.dart';
import 'add_edit_todo_list.dart';

class TodoListPage extends StatefulWidget {
  @override
  _TodoListPageState createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  final ApiService apiService = ApiService();
  List<Todo> todos = [];
  bool isLoading = true;
  int currentMaxId = 200;

  @override
  void initState() {
    super.initState();
    fetchTodos();
  }

  void fetchTodos() async {
    try {
      final fetchedTodos = await apiService.fetchTodos();
      setState(() {
        // Chỉ lấy 10 todo đầu tiên
        todos = fetchedTodos.take(10).toList();
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching todos: $e');
    }
  }

  void addTodoLocally(Todo todo) {
    setState(() {
      todos.add(todo); // Thêm todo mới vào danh sách
    });
  }

  void updateTodoLocally(Todo updatedTodo) {
    setState(() {
      final index = todos.indexWhere((todo) => todo.id == updatedTodo.id);
      if (index != -1) {
        todos[index] = updatedTodo; // Cập nhật todo ở đúng vị trí
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
                      final updatedTodo = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddEditTodoPage(todo: todo),
                        ),
                      );
                      if (updatedTodo != null) {
                        updateTodoLocally(updatedTodo); // Cập nhật todo cục bộ
                      }
                    });
              },
            ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          final newTodo = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddEditTodoPage(),
            ),
          );
          if (newTodo != null) {
            addTodoLocally(newTodo); // Thêm todo mới vào danh sách cục bộ
          }
        },
      ),
    );
  }

  void toggleTodoCompletion(Todo todo) async {
    final updatedTodo = Todo(
      id: todo.id,
      title: todo.title,
      completed: !todo.completed,
    );

    try {
      await apiService.updateTodo(updatedTodo);
      updateTodoLocally(updatedTodo); // Cập nhật todo cục bộ sau khi đã cập nhật trên server
    } catch (e) {
      print('Error updating todo: $e');
    }
  }
}
