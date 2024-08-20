import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('プロフィール'),
      ),
      body: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.grey,
            child: Icon(Icons.person, size: 50, color: Colors.white),
          ),
          SizedBox(height: 20),
          Text('ユーザー名',
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
          // ElevatedButton(
          //   child: Text('設定'),
          //   onPressed: () {},
          //   style: ElevatedButton.styleFrom(
          //     primary: Colors.orange,
          //     minimumSize: Size(200, 50),
          //   ),
          // ),
        ],
      ),
    );
  }
}
