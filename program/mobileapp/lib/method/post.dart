import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import '../widget/imucontainer.dart';

class PostForm {
  String time;
  User user;
  List<String> data;

  PostForm(
    this.time,
    this.user,
    this.data,
  );

  /*
  factory PostForm.fromJson(dynamic json) {
    return PostForm(
      User(
        name: "${json['name']}",
        age: int.parse("${json['age']}"),
        height: int.parse("${json['height']}"),
        weight: int.parse("${json['weight']}"),
      ),
      /*
      "${json['owas']}",
      "${json['back']}",
      "${json['arms']}",
      "${json['legs']}",
      "${json['s1Roll']}",
      "${json['S1Pitch']}",
      "${json['S1Yaw']}",
      "${json['s2Roll']}",
      "${json['S2Pitch']}",
      "${json['S2Yaw']}",
      "${json['s3Roll']}",
      "${json['S3Pitch']}",
      "${json['S3Yaw']}",
      "${json['s4Roll']}",
      "${json['S4Pitch']}",
      "${json['S4Yaw']}",
      "${json['s5Roll']}",
      "${json['S5Pitch']}",
      "${json['S5Yaw']}",
      "${json['s6Roll']}",
      "${json['S6Pitch']}",
      "${json['S6Yaw']}",
      "${json['s7Roll']}",
      "${json['S7Pitch']}",
      "${json['S7Yaw']}",
      */
    );
  }
  */

  // Method to make GET parameters.
  Map toJson() {
    List<List<String>> _data = List<List<String>>.generate(
        this.data.length, (index) => this.data[index].split(','));

    Map map = {
      'time': time,
      'name': user.name,
      'age': user.age.toString(),
      'height': user.height.toString(),
      'weight': user.weight.toString(),
      'owas': _data[0][0],
      'oBack': _data[0][1],
      'oArms': _data[0][2],
      'oLegs': _data[0][3],
      'oLoad': _data[0][4],
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
}
