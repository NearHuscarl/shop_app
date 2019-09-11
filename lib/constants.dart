import 'package:flutter_dotenv/flutter_dotenv.dart';

class Constants {
  static final String DatabaseUrl = DotEnv().env['DATABASE_URL'];
  static final String DatabaseApiKey = DotEnv().env['API_KEY'];
  static const String userDataKey = 'ShopApp_UserData';
}