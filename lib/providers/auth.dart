import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/http_exception.dart';
import '../constants.dart';

class Auth with ChangeNotifier {
  String _token;
  DateTime _expiryDate;
  String _userId;
  Timer _authTimer;

  bool get isAuth {
    return token != null;
  }

  String get token {
    if (_expiryDate != null && _expiryDate.isAfter(DateTime.now())) {
      return _token;
    }
    return null;
  }

  String get userId {
    return _userId;
  }

  Future _authenticate(String email, String password, String urlSegment) async {
    final url =
        'https://identitytoolkit.googleapis.com/v1/$urlSegment?key=${Constants.DatabaseApiKey}';
    final response = await http.post(
      url,
      body: json.encode({
        'email': email,
        'password': password,
        'returnSecureToken': true,
      }),
    );
    final responseData = json.decode(response.body);

    if (responseData['error'] != null) {
      throw HttpException(responseData['error']['message']);
    }
    _token = responseData['idToken'];
    _userId = responseData['localId'];
    _expiryDate = DateTime.now().add(Duration(
      seconds: int.parse(responseData['expiresIn']),
    ));
    _setupAutoLogout();
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final userData = json.encode({
      'token': _token,
      'userId': _userId,
      'expiryDate': _expiryDate.toIso8601String(),
    });
    prefs.setString(Constants.userDataKey, userData);
  }

  Future signUp(String email, String password) async {
    // https://firebase.google.com/docs/reference/rest/auth/#section-create-email-password
    _authenticate(email, password, 'accounts:signUp');
  }

  Future signIn(String email, String password) async {
    _authenticate(email, password, 'accounts:signInWithPassword');
  }

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey(Constants.userDataKey)) return false;

    final extractedUserData = json.decode(prefs.getString(Constants.userDataKey));
    final expiryDate = DateTime.parse(extractedUserData['expiryDate']);

    if (expiryDate.isBefore(DateTime.now())) {
      return false;
    }

    _token = extractedUserData['token'];
    _userId = extractedUserData['userId'];
    _expiryDate = expiryDate;
    notifyListeners();
    _setupAutoLogout();
    
    return true;
  }

  Future logout() async {
    _token = null;
    _expiryDate = null;
    _expiryDate = null;
    _authTimer?.cancel();
    _authTimer = null;

    final prefs = await SharedPreferences.getInstance();
    prefs.remove(Constants.userDataKey);

    notifyListeners();
  }

  void _setupAutoLogout() {
    _authTimer?.cancel();
    final timeToExpiry = _expiryDate.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: timeToExpiry), () => logout());
  }
}
