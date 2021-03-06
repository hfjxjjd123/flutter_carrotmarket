import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_practice1/data/user_model.dart';
import 'package:flutter_practice1/repo/user_service.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../consts/keys.dart';
import '../utils/logger.dart';

class UserProvider extends ChangeNotifier{
  bool _userLoggedIn =false;
  UserProvider(){
    initUser();
  }

  User? _user;
  UserModel? _userModel;

  void initUser() async {
    FirebaseAuth.instance.authStateChanges().listen((user) async{
      _user = user;
      await setNewUser(user);
      notifyListeners();
    });
  }

  Future setNewUser(User? user) async {
    _user = user;
    if(user != null && user.phoneNumber != null){
      SharedPreferences prefs = await SharedPreferences.getInstance();

      String address = prefs.getString(SHARED_ADDRESS)??"";
      double latitude = prefs.getDouble(SHARED_LAT)??0;
      double longitude = prefs.getDouble(SHARED_LOG)??0;
      String phoneNumber = user.phoneNumber??"";
      String userkey = user.uid;

      UserModel userModel = UserModel(
        userkey: userkey,
          phoneNumber: phoneNumber,
          address: address,
          geoFirePoint:GeoFirePoint(latitude,longitude),
          createdDate: DateTime.now().toUtc()
      );

      await UserService().createNewUser(userModel.toJson(),userkey);

      _userModel = await UserService().getUserModel(userkey);
      logger.d(_userModel!.toJson().toString());
    }
    }


  User? get user => _user;
  UserModel? get userModel => _userModel;
  }
