import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('レビュー済みのお店'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('restaurants').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('エラーが発生しました'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('レビュー済みのお店が見つかりません'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var restaurant = snapshot.data!.docs[index];
              return RestaurantReviewCard(restaurant: restaurant);
            },
          );
        },
      ),
    );
  }
}

class RestaurantReviewCard extends StatelessWidget {
  final QueryDocumentSnapshot restaurant;

  const RestaurantReviewCard({Key? key, required this.restaurant}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var data = restaurant.data() as Map<String, dynamic>;
    return Card(
      margin: EdgeInsets.all(8),
      child: ExpansionTile(
        leading: data['photoUrls'] != null && (data['photoUrls'] as List).isNotEmpty
            ? Image.network(data['photoUrls'][0], width: 50, height: 50, fit: BoxFit.cover)
            : Icon(Icons.restaurant, size: 50),
        title: Text(data['name'] ?? '名称不明'),
        subtitle: Text(data['address'] ?? '住所不明'),
        children: [
          FutureBuilder<QuerySnapshot>(
            future: restaurant.reference.collection('reviews').get(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('レビューがありません'),
                );
              }
              return Column(
                children: snapshot.data!.docs.map((review) {
                  var reviewData = review.data() as Map<String, dynamic>;
                  return ListTile(
                    title: Text('評価: ${reviewData['rating']}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('カテゴリ: ${(reviewData['categories'] as List).join(", ")}'),
                        Text('価格帯: ${reviewData['priceRange']}'),
                        Text('コメント: ${reviewData['reviewText']}'),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}