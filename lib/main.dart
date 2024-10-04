import 'package:flutter/material.dart';
import 'db_helper.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '掲示板アプリ',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: PostListScreen(),
    );
  }
}

class PostListScreen extends StatefulWidget {
  @override
  _PostListScreenState createState() => _PostListScreenState();
}

class _PostListScreenState extends State<PostListScreen> {
  final DBHelper _dbHelper = DBHelper();
  List<Map<String, dynamic>> _posts = [];

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    final posts = await _dbHelper.getPosts();
    setState(() {
      _posts = posts;
    });
  }

  Future<void> _addPost() async {
    final titleController = TextEditingController();
    final contentController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('新しい投稿'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(labelText: 'タイトル'),
              ),
              TextField(
                controller: contentController,
                decoration: InputDecoration(labelText: '内容'),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('キャンセル'),
            ),
            TextButton(
              onPressed: () async {
                final title = titleController.text;
                final content = contentController.text;

                if (title.isNotEmpty && content.isNotEmpty) {
                  await _dbHelper.insertPost({
                    'title': title,
                    'content': content,
                  });
                  Navigator.of(context).pop();
                  _loadPosts();
                }
              },
              child: Text('投稿'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('掲示板'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _addPost,
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _posts.length,
        itemBuilder: (context, index) {
          final post = _posts[index];
          return ListTile(
            title: Text(post['title']),
            subtitle: Text(post['content']),
            trailing: Text(post['createdAt']),
          );
        },
      ),
    );
  }
}
