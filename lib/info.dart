import 'dart:convert';
import 'dart:io';
import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';

class Info {
  static String userId = "";
  static String orgNo = "";
  static String password = "";
  static String baseUrl = "";
  static Dio dio = Dio();



  static  Future<dynamic> post(String action, Map<String, String> params) async {
    _setSafeString(params);

    dio.options.baseUrl = baseUrl;
    dio.options.connectTimeout = 5000; //5s
    dio.options.receiveTimeout = 3000;
    dio.options.contentType = Headers.formUrlEncodedContentType;

    Response<String> response2 = await dio.get(action, queryParameters: params);
    dynamic items=json.decode(response2.data);
    return items;
  }

  static void _setSafeString(Map<String, String> params) {
    String ms = DateTime.now().millisecondsSinceEpoch.toString();
    String dbPwd = null;

    params["susrnam"] = userId;
    params["timestamp"] = ms;
    params["appkey"] = "luculent";
    params["sign"] = _getSign(userId, password, dbPwd, ms);
    params["orgverno"] = "";
  }

  static String _getSign(userId, password, dbPwd, ms) {
    if (password != null) {
      dbPwd = _generateMd5(userId + password);
    }
    String sign = _generateMd5("luculentsecure" + userId + dbPwd + ms);
    return sign;
  }

  // md5 加密
  static String _generateMd5(String data) {
    var content = new Utf8Encoder().convert(data);
    var digest = md5.convert(content);
    // 这里其实就是 digest.toString()
    return hex.encode(digest.bytes);
  }
}
