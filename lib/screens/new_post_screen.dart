import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'review_screen.dart';

class NewPostScreen extends StatefulWidget {
  @override
  _NewPostScreenState createState() => _NewPostScreenState();
}

class _NewPostScreenState extends State<NewPostScreen> {
  final _searchController = TextEditingController();
  List<dynamic> _predictions = [];
  // List<String> _photoUrls = [];

  Future<void> autoCompleteSearch(String input) async {
    String apiKey = '';
    String baseURL =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json';

    // 五反田駅の緯度と経度
    double lat = 35.6263;
    double lng = 139.7248;
    int radius = 500; // 検索半径（メートル）

    // 検索文字列の先頭に「五反田」を追加
    String searchInput = '五反田 $input';

    String request =
        '$baseURL?input=$searchInput&key=$apiKey&language=ja&components=country:jp&types=restaurant&location=$lat,$lng&radius=$radius';

    var response = await http.get(Uri.parse(request));
    print('Response: ${response.body}');
    if (response.statusCode == 200) {
      var predictions = json.decode(response.body)['predictions'];
      List<Map<String, dynamic>> updatedPredictions = [];
      // predictionsの要素数を表示
      print('Predictions: ${predictions.length}');
      for (var prediction in predictions) {
        List<String> photoUrls = await getPlacePhotos(prediction['place_id']);
        updatedPredictions.add({
          'description': prediction['description'],
          'place_id': prediction['place_id'],
          'structured_formatting': prediction['structured_formatting'],
          'photoUrls': photoUrls,
        });
      }

      setState(() {
        _predictions = updatedPredictions;
      });
    } else {
      print('Error: ${response.reasonPhrase}');
    }
  }

  Future<void> getPlaceDetails(String placeId) async {
    String apiKey = '';
    String baseURL = 'https://maps.googleapis.com/maps/api/place/details/json';
    String request = '$baseURL?place_id=$placeId&key=$apiKey';

    var response = await http.get(Uri.parse(request));

    if (response.statusCode == 200) {
      var details = json.decode(response.body)['result'];
      List<String> photoUrls = await getPlacePhotos(placeId);

      setState(() {
        _searchController.text = details['name'];
        var index = _predictions.indexWhere((p) => p['place_id'] == placeId);
        if (index != -1) {
          _predictions[index]['photoUrls'] = photoUrls.cast<String>();
        }
      });
    }
  }

  Future<List<String>> getPlacePhotos(String placeId) async {
    String apiKey = '';
    String baseURL = 'https://maps.googleapis.com/maps/api/place/details/json';
    String request = '$baseURL?place_id=$placeId&key=$apiKey';

    var response = await http.get(Uri.parse(request));

    if (response.statusCode == 200) {
      var details = json.decode(response.body)['result'];
      List<String> photoUrls = [];

      if (details != null && details.containsKey('photos')) {
        for (var photo in details['photos']) {
          String photoReference = photo['photo_reference'];
          String photoUrl =
              'https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=$photoReference&key=$apiKey';
          photoUrls.add(photoUrl);
        }
      }
      return photoUrls;
    } else {
      print('Error: ${response.reasonPhrase}');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('新規投稿'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: '店名を検索',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.search),
                ),
                onChanged: (value) {
                  if (value.isNotEmpty) {
                    autoCompleteSearch(value);
                  } else {
                    setState(() {
                      _predictions = [];
                    });
                  }
                },
              ),
              SizedBox(height: 16),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: _predictions.length,
                itemBuilder: (context, index) {
                  var photoUrls = (_predictions[index]['photoUrls'] as List?)
                          ?.cast<String>() ??
                      [];
                  return GestureDetector(
                    // この行を追加
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ReviewScreen(
                            restaurantName: _predictions[index]
                                ['structured_formatting']['main_text'],
                          ),
                        ),
                      );
                    }, // この行を追加
                    child: Container(
                      margin: EdgeInsets.only(bottom: 16),
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.restaurant, color: Colors.red),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _predictions[index]['structured_formatting']
                                      ['main_text'],
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Container(
                            height: 100,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount:
                                  photoUrls.isEmpty ? 1 : photoUrls.length,
                              itemBuilder: (context, photoIndex) {
                                return Container(
                                  width: 150,
                                  margin: EdgeInsets.only(right: 8),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    image: DecorationImage(
                                      fit: BoxFit.cover,
                                      image: photoUrls.isNotEmpty
                                          ? NetworkImage(photoUrls[photoIndex])
                                          : AssetImage('assets/placeholder.png')
                                              as ImageProvider,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.location_on, color: Colors.blue),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _predictions[index]['structured_formatting']
                                      ['secondary_text'],
                                  style: TextStyle(fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
