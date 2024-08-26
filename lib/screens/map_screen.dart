import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'search_screen.dart';
import 'new_post_screen.dart';
import 'profile_screen.dart';
import 'list_screen.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _controller;
  Set<Marker> _markers = {};
  static final CameraPosition _initialPosition = CameraPosition(
    target: LatLng(35.6258, 139.7235), // 五反田駅の緯度経度
    zoom: 15.0,
  );

  @override
  void initState() {
    super.initState();
    _listenToRestaurants();
  }

  void _listenToRestaurants() {
    FirebaseFirestore.instance
        .collection('restaurants')
        .snapshots()
        .listen((snapshot) {
      _updateMarkers(snapshot.docs);
    });
  }

  void _updateMarkers(List<QueryDocumentSnapshot> documents) {
    Set<Marker> markers = {};
    for (var doc in documents) {
      final data = doc.data() as Map<String, dynamic>;
      final GeoPoint? location = data['location'] as GeoPoint?;
      if (location != null) {
        final marker = Marker(
          markerId: MarkerId(doc.id),
          position: LatLng(location.latitude, location.longitude),
          infoWindow: InfoWindow(
            title: data['name'] as String?,
            snippet: 'タップして詳細を表示',
          ),
          onTap: () => _showRestaurantDetails(doc.id, data),
        );
        markers.add(marker);
      }
    }
    setState(() {
      _markers = markers;
    });
    print('Updated markers: ${markers.length}');
  }

  Future<double> _calculateAverageRating(String restaurantId) async {
    final reviews = await FirebaseFirestore.instance
        .collection('restaurants')
        .doc(restaurantId)
        .collection('reviews')
        .get();

    if (reviews.docs.isEmpty) return 0.0;

    double totalRating = 0.0;
    for (var review in reviews.docs) {
      totalRating += review.data()['rating'] as double;
    }

    return totalRating / reviews.docs.length;
  }

  void _showRestaurantDetails(String restaurantId, Map<String, dynamic> data) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(data['name'] as String, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text(data['address'] as String),
              SizedBox(height: 8),
              FutureBuilder<double>(
                future: _calculateAverageRating(restaurantId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  }
                  return Text('平均評価: ${snapshot.data?.toStringAsFixed(1) ?? "N/A"}');
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('メシリンク'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => SearchScreen()));
            },
          ),
        ],
      ),
      body: GoogleMap(
        initialCameraPosition: _initialPosition,
        onMapCreated: (GoogleMapController controller) {
          _controller = controller;
        },
        markers: _markers,
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (context) => NewPostScreen()));
          // 新しい投稿が作成された後にマーカーを更新
          _listenToRestaurants();
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'マップ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'リスト',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: '投稿',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'プロフィール',
          ),
        ],
        currentIndex: 0,
        selectedItemColor: Colors.amber[800],
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          if (index == 3) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileScreen()));
          } else if (index == 2) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => NewPostScreen()));
          } else if (index == 1) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => ListScreen()));
          }
        },
      ),
    );
  }
}