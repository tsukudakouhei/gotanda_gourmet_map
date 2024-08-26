import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  User? _user;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    User? user = _authService.getCurrentUser();
    setState(() {
      _user = user;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('プロフィール'),
      ),
      body: _user == null ? _buildLoginView() : _buildProfileView(),
    );
  }

  Widget _buildLoginView() {
    return Center(
      child: ElevatedButton(
        child: Text('Googleでログイン'),
        onPressed: () async {
          User? user = await _authService.signInWithGoogle();
          if (user != null) {
            setState(() {
              _user = user;
            });
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('ログインに失敗しました')),
            );
          }
        },
      ),
    );
  }

  Widget _buildProfileView() {
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundImage: _user?.photoURL != null
              ? NetworkImage(_user!.photoURL!)
              : null,
          child: _user?.photoURL == null
              ? Icon(Icons.person, size: 50, color: Colors.white)
              : null,
        ),
        SizedBox(height: 20),
        Text(_user?.displayName ?? 'ユーザー名',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        SizedBox(height: 20),
        ListTile(
          title: Text('投稿履歴'),
          subtitle: Text('最近の投稿はありません'),
        ),
        ListTile(
          title: Text('行ってみたいリスト'),
          subtitle: Text('保存したお店はありません'),
        ),
        SizedBox(height: 20),
        ElevatedButton(
          child: Text('ログアウト'),
          onPressed: () async {
            await _authService.signOut();
            setState(() {
              _user = null;
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red, // 'primary' の代わりに 'backgroundColor' を使用
            minimumSize: Size(200, 50), 
          ),
        ),
      ],
    );
  }
}