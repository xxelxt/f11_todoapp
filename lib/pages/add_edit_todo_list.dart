import 'package:flutter/material.dart';
import '../models/todo.dart';
import '../services/api_services.dart';
import '../globals.dart' as globals;

class AddEditTodoPage extends StatefulWidget {
  final Todo? todo;

  AddEditTodoPage({this.todo});

  @override
  _AddEditTodoPageState createState() => _AddEditTodoPageState();
}

class _AddEditTodoPageState extends State<AddEditTodoPage> {
  final _formKey = GlobalKey<FormState>();
  final ApiService apiService = ApiService();
  late TextEditingController _titleController;
  bool _completed = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
        text: widget.todo != null ? widget.todo!.title : '');
    _completed = widget.todo?.completed ?? false;
  }

  void saveTodo() async {
    if (_formKey.currentState!.validate()) {
      // Sử dụng currentMaxId để tạo ID nối tiếp
      final newTodo = Todo(
        id: widget.todo?.id ?? ++globals.currentMaxId,
        title: _titleController.text,
        completed: _completed,
      );

      try {
        if (widget.todo == null) {
          // Tạo mới todo
          await apiService.createTodo(newTodo);
          Navigator.pop(context, newTodo); // Trả về todo mới
        } else {
          // Cập nhật todo
          await apiService.updateTodo(newTodo);
          Navigator.pop(context, newTodo); // Trả về todo đã cập nhật
        }
      } catch (e) {
        print('Error saving todo: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving todo')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.todo == null ? 'Add Todo' : 'Edit Todo')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.symmetric(horizontal: 16.0),
                child: TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(labelText: 'Title'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
              ),
              SizedBox(height: 20),
              CheckboxListTile(
                value: _completed,
                onChanged: (value) {
                  setState(() {
                    _completed = value ?? false;
                  });
                },
                title: Text('Completed'),
              ),
              ElevatedButton(
                onPressed: saveTodo,
                child: Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}