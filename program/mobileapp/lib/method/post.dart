import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import '../widget/imucontainer.dart';

class PostForm {
  String date;
  String time;
  User user;
  List<String> data;

  PostForm(
    this.date,
    this.time,
    this.user,
    this.data,
  );

  factory PostForm.fromJson(dynamic json) {
    return PostForm(
      "${json['date']}",
      "${json['time']}",
      User(
        name: "${json['name']}",
        age: int.parse("${json['age']}"),
        height: int.parse("${json['height']}"),
        weight: int.parse("${json['weight']}"),
      ),
      <String>[
        "${json['owas']}",
        "${json['oBack']}",
        "${json['oArms']}",
        "${json['oLegs']}",
        "${json['oLoad']}",
        "${json['s1r']}",
        "${json['s1p']}",
        "${json['s1y']}",
        "${json['s2r']}",
        "${json['s2p']}",
        "${json['s2y']}",
        "${json['s3r']}",
        "${json['s3p']}",
        "${json['s3y']}",
        "${json['s4r']}",
        "${json['s4p']}",
        "${json['s4y']}",
        "${json['s5r']}",
        "${json['s5p']}",
        "${json['s5y']}",
        "${json['s6r']}",
        "${json['s6p']}",
        "${json['s6y']}",
        "${json['s7r']}",
        "${json['s7p']}",
        "${json['s7y']}",
      ],
    );
  }

  // Method to make GET parameters.
  Map toJson() {
    List<List<String>> _data = List<List<String>>.generate(
        this.data.length, (index) => this.data[index].split(','));

    Map map = {
      'date': "'" + date,
      'time': "'" + time,
      'name': user.name,
      'age': user.age.toString(),
      'height': user.height.toString(),
      'weight': user.weight.toString(),
      'oBack': _data[0][0],
      'oArms': _data[0][1],
      'oLegs': _data[0][2],
      'oLoad': _data[0][3],
      'owas': _data[0][4],
    };

    for (var i = 1; i < _data.length; i++) {
      map.addAll({
        's${i}r': _data[i][0],
        's${i}p': _data[i][1],
        's${i}y': _data[i][2],
      });
    }

    return map;
  }
}

/// FormController is a class which does work of saving FeedbackForm in Google Sheets using
/// HTTP GET request on Google App Script Web URL and parses response and sends result callback.
class PostController {
  // Google App Script Web URL.
  static const String URL =
      "https://script.google.com/macros/s/AKfycbwhPy9gfXYQzjQ2wt6xHgwQfXmnWUgHPGE54hdMF8OqNSaFXAaMmr-6AQ/exec";

  // Success Status Message
  static const STATUS_SUCCESS = "SUCCESS";

  /// Async function which saves feedback, parses [feedbackForm] parameters
  /// and sends HTTP GET request on [URL]. On successful response, [callback] is called.
  submitForm(PostForm postForm, void Function(String) callback) async {
    try {
      await http.post(URL, body: postForm.toJson()).then((response) async {
        if (response.statusCode == 302) {
          var url = response.headers['location'];
          await http.get(url).then((response) {
            callback(convert.jsonDecode(response.body)['status']);
          });
        } else {
          callback(convert.jsonDecode(response.body)['status']);
        }
      });
    } catch (e) {
      print(e);
    }
  }

  Future<List<PostForm>> getData(String date) async {
    return await http.get(URL + '?arg=' + date).then((response) {
      var jsonFeedback = convert.jsonDecode(response.body) as List;
      return jsonFeedback.map((json) => PostForm.fromJson(json)).toList();
    });
  }

  String dateListFromJson(dynamic json) {
    return "${json['date']}";
  }

  Future<List<String>> getAvailableDate() async {
    return await http.get(URL + '?arg=getdate').then((response) {
      var jsonFeedback = convert.jsonDecode(response.body) as List;
      return jsonFeedback.map((json) => dateListFromJson(json)).toList();
    });
  }
}
