import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../data/local/cache_helper.dart';
import '../data/remote/url_api.dart';

class FirebaseApi {
  final _firebaseMessaging = FirebaseMessaging.instance;
  Future<void> initNotification() async{
    await _firebaseMessaging.requestPermission();
    final fcmToken = await _firebaseMessaging.getToken();
    print('kkkk token : $fcmToken');
    final data = json.encode({
      'id': CacheHelper.getData(key: 'id'),
      'token': fcmToken,
    });
    /*var response = await Dio().post(setFcmToken, data: data);

    print('kkkk token : ${response.data['status_code']}');*/
  }
}