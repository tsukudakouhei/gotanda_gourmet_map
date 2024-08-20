import 'package:flutter/material.dart';

class ReviewScreen extends StatefulWidget {
  final String restaurantName;

  ReviewScreen({required this.restaurantName});

  @override
  _ReviewScreenState createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  double _rating = 0;
  bool _isRatingModalOpen = false;

  Set<String> _selectedCategories = {};
  String _selectedPriceRange = '';
  String _reviewText = '';

  final List<String> _categories = [
    '昼',
    '夜',
    '喫煙可(席)',
    '分煙',
    '禁煙',
    '会食',
    '和食',
    '海鮮',
    '洋食',
    '中華',
    '個室あり',
    '完全個室'
  ];

  final List<String> _priceRanges = [
    '¥0~¥999',
    '¥1,000~¥1,999',
    '¥2,000~¥2,999',
    '¥3,000~¥3,999',
    '¥4,000~¥4,999',
    '¥5,000~¥5,999',
    '¥6,000~¥6,999',
    '¥7,000~¥7,999',
    '¥8,000~¥8,999',
    '¥9,000~¥9,999',
    '¥10,000~'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(widget.restaurantName),
        actions: [
          TextButton(
            child: Text('設定'),
            onPressed: () {/* 設定画面へ遷移 */},
          ),
        ],
      ),
      body: Stack(children: [
        SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildRatingSection(),
              SizedBox(height: 16),
              _buildCategorySection(),
              SizedBox(height: 16),
              _buildPriceRangeSection(),
              SizedBox(height: 16),
              _buildReviewTextField(),
              SizedBox(height: 16),
              _buildPhotoSection(),
            ],
          ),
        ),
        if (_isRatingModalOpen) _buildRatingModal(),
      ]),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              OutlinedButton(
                child: Text('下書き保存'),
                onPressed: () {/* 下書き保存の処理 */},
              ),
              ElevatedButton(
                child: Text('同意して投稿'),
                onPressed: () {/* 投稿の処理 */},
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRatingSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ...List.generate(5, (index) {
          int fullStars = _rating.floor();
          bool isHalfStar = (index == fullStars && _rating % 1 != 0);
          return GestureDetector(
            onTap: () {
              setState(() {
                if (index + 0.5 == _rating) {
                  _rating = index + 1.0;
                } else {
                  _rating = index + 0.5;
                }
              });
            },
            child: Icon(
              isHalfStar ? Icons.star_half : Icons.star,
              color: index < _rating ? Colors.orange : Colors.grey[300],
              size: 40,
            ),
          );
        }),
        SizedBox(width: 10),
        Text(
          _rating.toStringAsFixed(1),
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        IconButton(
          icon: Icon(Icons.arrow_drop_down),
          onPressed: () {
            setState(() {
              _isRatingModalOpen = true;
            });
          },
        ),
      ],
    );
  }

  Widget _buildRatingModal() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isRatingModalOpen = false;
        });
      },
      child: Container(
        color: Colors.black54,
        child: Center(
          child: Container(
            width: 300,
            height: 400,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: Icon(Icons.close),
                        onPressed: () {
                          setState(() {
                            _isRatingModalOpen = false;
                          });
                        },
                      ),
                      Text('評価を選択',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      TextButton(
                        child: Text('決定'),
                        onPressed: () {
                          setState(() {
                            _isRatingModalOpen = false;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: 10,
                    itemBuilder: (context, index) {
                      double value = 5 - index * 0.5;
                      return ListTile(
                        title: Text(value.toStringAsFixed(1),
                            style: TextStyle(fontSize: 20)),
                        tileColor: _rating == value ? Colors.grey[200] : null,
                        onTap: () {
                          setState(() {
                            _rating = value;
                          });
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('カテゴリー',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: _categories.map((category) {
            return FilterChip(
              label: Text(category),
              selected: _selectedCategories.contains(category),
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedCategories.add(category);
                  } else {
                    _selectedCategories.remove(category);
                  }
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPriceRangeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('使った金額（1人あたり）',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(4),
          ),
          child: DropdownButton<String>(
            value: _selectedPriceRange.isEmpty ? null : _selectedPriceRange,
            hint: Text('選択してください'),
            isExpanded: true,
            underline: SizedBox(), // 下線を削除
            items: _priceRanges.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  _selectedPriceRange = newValue;
                });
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildReviewTextField() {
    return TextField(
      decoration: InputDecoration(
        labelText: '美味しかったメニューや、お店の雰囲気はいかがでしたか？',
        border: OutlineInputBorder(),
      ),
      maxLines: 5,
      onChanged: (value) {
        setState(() {
          _reviewText = value;
        });
      },
    );
  }

  Widget _buildPhotoSection() {
    return OutlinedButton.icon(
      icon: Icon(Icons.camera_alt),
      label: Text('写真を追加'),
      onPressed: () {/* 写真追加の処理 */},
      style: OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}
