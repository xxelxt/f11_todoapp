import 'package:flutter/material.dart';
import '../models/todo.dart';
import '../services/api_services.dart';

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
    // Khởi tạo bộ điều khiển cho TextField với giá trị từ todo nếu tồn tại.
    _titleController = TextEditingController(
      text: widget.todo != null ? widget.todo!.title : '',
    );
    _completed = widget.todo?.completed ?? false;
  }

  // Hàm lưu công việc.
  void saveTodo() async {
    if (_formKey.currentState!.validate()) {
      final newTodo = Todo(
        id: widget.todo?.id ?? 0, // Nếu ID null thì dùng giá trị mặc định.
        title: _titleController.text,
        completed: _completed,
      );

      try {
        // Nếu không có todo thì tạo mới, ngược lại thì cập nhật.
        if (widget.todo == null) {
          await apiService.createTodo(newTodo);
        } else {
          await apiService.updateTodo(newTodo);
        }
        // Trở về màn hình trước đó và báo thành công.
        Navigator.pop(context, true);
      } catch (e) {
        // Hiển thị thông báo lỗi nếu có vấn đề xảy ra.
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving todo: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.todo == null ? 'Add Todo' : 'Edit Todo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Title'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
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
