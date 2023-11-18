import 'package:flutter/foundation.dart';

class MyImageProvider extends ChangeNotifier {
  String? _imageUrl;

  String? get imageUrl => _imageUrl;

  void setImageUrl(String? url) {
    _imageUrl = url;
    notifyListeners();
  }
}
