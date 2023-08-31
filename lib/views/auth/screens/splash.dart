

import 'package:flutter/material.dart';
import 'package:insta_node_app/common_widgets/image_helper.dart';
import 'package:insta_node_app/constants/asset_helper.dart';
import 'package:insta_node_app/providers/auth_provider.dart';
import 'package:insta_node_app/providers/theme.dart';
import 'package:insta_node_app/recources/auth_api.dart';
import 'package:insta_node_app/views/auth/screens/login.dart';
import 'package:insta_node_app/views/auth/screens/main_app.dart';
import 'package:insta_node_app/utils/socket_config.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashPage extends StatefulWidget {
  const  SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {

  @override
  void initState() {
    super.initState();
    redirectToLogin();
  }


  void redirectToLogin() async{
    final Future<SharedPreferences> asynPrefs = SharedPreferences.getInstance();
    final SharedPreferences prefs = await asynPrefs;
    final String? accessToken = prefs.getString('accessToken');
    final String? refreshToken = prefs.getString('refreshToken');
    final String? themeMode = prefs.getString('themeMode');
    if(themeMode != null) {
      print(themeMode);
      if(!mounted) return;
      Provider.of<ThemeModel>(context, listen: false).toggleTheme(themeMode);
    }
    if(accessToken != null && refreshToken != null) {
      final res = await AuthApi().refreshTokenUser(refreshToken);
      SocketConfig.joinUser(res.user);
      if(!mounted) return;
      Provider.of<AuthProvider>(context, listen: false).setAuth(res);
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => MainAppScreen()));
    } else {
      await Future.delayed(const Duration(seconds: 2), () {
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const LoginScreen()));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Spacer(),
          Expanded(
            flex: 3,
            child: Center(
              child: ImageHelper.loadImageAsset(
                AssetHelper.icLogo,
                width: 100,
                height: 100,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Column(
              children: const [
                Text('from', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),),
                SizedBox(
                  height: 4,
                ),
                Text('☂ Winter', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),),
              ],
            ),
          )
        ],
      )
    );
  }
}