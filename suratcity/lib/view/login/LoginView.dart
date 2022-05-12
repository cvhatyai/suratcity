import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:flutter_line_sdk/flutter_line_sdk.dart';
import 'package:http/http.dart' as http;
import 'package:cvapp/model/AllList.dart';
import 'package:cvapp/model/user.dart';
import 'package:cvapp/system/Info.dart';
import 'package:cvapp/view/register/RegisterView.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:toast/toast.dart';

import '../AppBarView.dart';
import '../FrontPageView.dart';
import 'ForgetPasswordView.dart';

GoogleSignIn _googleSignIn = GoogleSignIn(
  //clientId: '8566559601-js6kpoddokr7g6ul8esholqtrk7k06h5.apps.googleusercontent.com',
  scopes: <String>[
    'email',
    //'https://www.googleapis.com/auth/contacts.readonly',
  ],
  hostedDomain: "",
  clientId: "",
);

class SignInLine {
  void lineSDKInit() async {
    await LineSDK.instance.setup("1657127329").then((_) {
      print("LineSDK is Prepared");
    });
  }
}

class LoginView extends StatefulWidget {
  LoginView({Key key, this.isHaveArrow = ""}) : super(key: key);
  final String isHaveArrow;

  @override
  _LoginViewState createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _username = TextEditingController();
  final _password = TextEditingController();
  bool _validateUsername = false;
  bool _validatePassword = false;

  var icon = "";
  var isBlindBlock = "1";
  var isBlindBlockFace = "";
  var platform = "ios";

  //userData
  var user = User();
  GoogleSignInAccount _currentUser;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    SignInLine().lineSDKInit();

    if (Platform.isIOS) {
      platform = "ios";
    } else {
      platform = "android";
    }

    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount account) {
      signOutWithGoogle();
    });

    getSiteDetail();
  }

  Future<void> _handleSignOut() => _googleSignIn.disconnect();

  //siteIcon
  getSiteDetail() async {
    Map _map = {};
    _map.addAll({});
    var body = json.encode(_map);
    return postSiteDetail(http.Client(), body, _map);
  }

  Future<List<AllList>> postSiteDetail(
      http.Client client, jsonMap, Map map) async {
    final response = await client.post(Uri.parse(Info().siteDetail),
        headers: {"Content-Type": "application/json"}, body: jsonMap);
    var rs = json.decode(response.body);
    setState(() {
      icon = rs["icon"].toString();
      isBlindBlock = rs["loginBlock"].toString();
      isBlindBlockFace = rs["loginBlockFace"].toString();
    });
    print("isBlindBlockFace" + isBlindBlockFace);
  }

  //login
  login({socialID = "", type = ""}) async {
    Map _map = {};

    if (type == "line") {
      _map.addAll({
        "line_id": socialID,
        "login_type": "line",
      });
    } else if (type == "facebook") {
      _map.addAll({
        "facebook_id": socialID,
        "login_type": "fb",
      });
    } else if (type == "google") {
      _map.addAll({
        "google_id": socialID,
        "login_type": "google",
      });
    } else if (type == "apple") {
      _map.addAll({
        "apple_id": socialID,
        "login_type": "apple",
      });
    } else {
      _map.addAll({
        "username": _username.text,
        "password": _password.text,
      });
    }

    print("login : " + _map.toString());

    var body = json.encode(_map);
    return postLogin(http.Client(), body, _map);
  }

  Future<List<AllList>> postLogin(http.Client client, jsonMap, Map map) async {
    final response = await client.post(Uri.parse(Info().userLogin),
        headers: {"Content-Type": "application/json"}, body: jsonMap);
    var rs = json.decode(response.body);
    var status = rs["status"].toString();
    var msg = rs["msg"].toString();
    await user.init();
    if (status == "success") {
      user.isLogin = true;
      user.uid = rs["uid"].toString();
      user.fullname = rs["fullname"].toString();
      user.phone = rs["phone"].toString();
      user.avatar = rs["avatar"].toString();
      user.email = rs["email"].toString();
      user.priv = rs["priv"].toString();
      user.username = rs["username"].toString();
      user.password = rs["password"].toString();
      user.citizen_id = rs["citizen_id"].toString();
      user.authen_token = rs["authen_token"].toString();
      user.userclass = rs["userclass"].toString();

      print("userclass : " + rs["userclass"].toString());

      user.facebook_id = rs["facebook_id"].toString();
      user.line_id = rs["line_id"].toString();
      user.google_id = rs["google_id"].toString();
      user.apple_id = rs["apple_id"].toString();

      user.isNoti = "1";

      if (lineID == "") {
        Toast.show(msg, context,
            duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
      }

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => FrontPageView()),
        ModalRoute.withName("/"),
      );
    } else {
      if (lineID == "") {
        Toast.show(msg, context,
            duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
      }
    }
    if (FocusScope.of(context).isFirstFocus) {
      FocusScope.of(context).requestFocus(new FocusNode());
    }
    EasyLoading.dismiss();
  }

  ////////////////////////////Line
  String lineID = '';
  String lineAvatar = '';

  void _loginLine() async {
    //EasyLoading.show(status: 'loading...');
    try {
      final result = await LineSDK.instance
          .login(scopes: ["profile"], option: LoginOption(false, "normal"));
      setState(() {
        lineID = result.userProfile.userId;
        lineAvatar = result.userProfile.pictureUrl;
        if (lineID != "") {
          checkHasUserLine();
        }
      });
    } on PlatformException catch (e) {
      // Error handling.
      print(e);
    }
  }

  checkHasUserLine() {
    Map _map = {};
    _map.addAll({
      "line_id": lineID,
      "avatar": lineAvatar,
    });

    print("_map" + _map.toString());

    var body = json.encode(_map);
    postLineIDData(http.Client(), body, _map);
  }

  Future<List<AllList>> postLineIDData(
      http.Client client, jsonMap, Map map) async {
    final response = await client.post(Uri.parse(Info().checkHasUser),
        headers: {"Content-Type": "application/json"}, body: jsonMap);

    final _list = json.decode(response.body);

    print("_list" + _list.toString());

    if (_list['fullname'] == "") {
      //ไปสมัคร
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RegisterView(
            isHaveArrow: "1",
            socialID: lineID,
            type: "line",
          ),
        ),
      );
    } else {
      login(socialID: lineID, type: "line");
    }
  }

  ////////////////////////////Face

  final FacebookLogin facebookSignIn = new FacebookLogin();
  String _message = 'Log in/out by pressing the buttons below.';
  String faceID = '';
  var faceData = Map<String, dynamic>();

  Future _loginFace() async {
    EasyLoading.show(status: 'loading...');
    final FacebookLoginResult result = await facebookSignIn.logIn(['email']);

    print("aaaa" + result.status.toString());

    switch (result.status) {
      case FacebookLoginStatus.loggedIn:
        final FacebookAccessToken accessToken = result.accessToken;

        faceID = accessToken.userId;
        print("faceID $faceID");
        final graphResponse = await http.get(
            'https://graph.facebook.com/v2.12/me?fields=name,first_name,last_name,email,picture.width(300).height(300)&access_token=${accessToken.token}');
        final profile = json.decode(graphResponse.body);
        faceData = Map<String, dynamic>.from(profile);

        _showMessage('''
         Logged in!
         Token: ${accessToken.token}
         User id: ${accessToken.userId}
         Expires: ${accessToken.expires}
         Permissions: ${accessToken.permissions}
         Declined permissions: ${accessToken.declinedPermissions}
         ''');
        break;
      case FacebookLoginStatus.cancelledByUser:
        EasyLoading.dismiss();
        _showMessage('Login cancelled by the user.');
        break;
      case FacebookLoginStatus.error:
        EasyLoading.dismiss();
        _showMessage('Something went wrong with the login process.\n'
            'Here\'s the error Facebook gave us: ${result.errorMessage}');
        break;
    }
  }

  void _showMessage(String message) {
    EasyLoading.dismiss();

    setState(() {
      //_message = message;
      /*  print("_message $_message");
      print("faceID $faceID");
      print("faceData $faceData");
      print("first_name " + faceData['first_name']);
      print("last_name " + faceData['last_name']);
      print("email " + faceData['email']);
      print("picture " + faceData['picture']["data"]["url"]);*/
      //type = "fb";
      if (faceID != "") {
        checkHasUserFace();
      } else {
        print("message : " + message);
      }
    });
  }

  checkHasUserFace() {
    Map _map = {};
    _map.addAll({
      "facebook_id": faceID,
      "avatar": faceData['picture']["data"]["url"],
    });

    print("_map" + _map.toString());

    var body = json.encode(_map);
    postFaceIDData(http.Client(), body, _map);
  }

  Future<List<AllList>> postFaceIDData(
      http.Client client, jsonMap, Map map) async {
    final response = await client.post(Uri.parse(Info().checkHasUser),
        headers: {"Content-Type": "application/json"}, body: jsonMap);

    final _list = json.decode(response.body);

    print("_list" + _list.toString());

    if (_list['fullname'] == "") {
      //ไปสมัคร
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RegisterView(
            isHaveArrow: "1",
            socialID: faceID,
            type: "fb",
          ),
        ),
      );
    } else {
      login(socialID: faceID, type: "facebook");
    }
  }

  ////////////////////////////google
  //8566559601-hvkti42p1l2786kt8lkvjilhfcjrhuhk.apps.googleusercontent.com
  //8566559601-g267d19ckk3hlhgim6ot3sotsg36tpjb.apps.googleusercontent.com ios

  String googleID = '';
  String googleAvatar = '';

  Future<void> _loginGoogle() async {
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount account) {
      /*setState(() {
        _currentUser = account;
      });*/
      _currentUser = account;
      print("_currentUser : " + _currentUser.toString());
      if (_currentUser != null) {
        _handleGetContact();
      }
    });
    //_googleSignIn.signInSilently();
    try {
      await _googleSignIn.signIn();
    } catch (error) {
      print(error);
    }
  }

  Future<void> signOutWithGoogle() => _googleSignIn.disconnect();

  Future<void> _handleGetContact() async {
    print('_handleGetContact');
    if (_currentUser.id != "") {
      googleID = _currentUser.id;
      googleAvatar = _currentUser.photoUrl;
      checkHasUserGoogle();
    }
  }

  checkHasUserGoogle() {
    Map _map = {};
    _map.addAll({
      "google_id": googleID,
      "avatar": googleAvatar,
    });

    print("_map" + _map.toString());

    var body = json.encode(_map);
    postGoogleIDData(http.Client(), body, _map);
  }

  Future<List<AllList>> postGoogleIDData(
      http.Client client, jsonMap, Map map) async {
    final response = await client.post(Uri.parse(Info().checkHasUser),
        headers: {"Content-Type": "application/json"}, body: jsonMap);

    final _list = json.decode(response.body);

    print("_list" + _list.toString());

    if (_list['fullname'] == "") {
      //ไปสมัคร
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RegisterView(
            isHaveArrow: "1",
            socialID: googleID,
            type: "google",
          ),
        ),
      );
    } else {
      print("googleID" + googleID.toString());
      login(socialID: googleID, type: "google");
    }
  }

  /////////////////////////Apple
  String appleID = '';
  String appleFullname = '';
  String appleEmail = '';

  Future<void> _loginApple() async {
    final credential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      webAuthenticationOptions: WebAuthenticationOptions(
        clientId: 'c`om.wsflutter.cityvariety',
        redirectUri: Uri.parse(
          'https://flutter-sign-in-with-apple-example.glitch.me/callbacks/sign_in_with_apple',
        ),
      ),
      nonce: 'example-nonce',
      state: 'example-state',
    );

    final signInWithAppleEndpoint = Uri(
      scheme: 'https',
      host: 'flutter-sign-in-with-apple-example.glitch.me',
      path: '/sign_in_with_apple',
      queryParameters: <String, String>{
        'code': credential.authorizationCode,
        'firstName': credential.givenName,
        'lastName': credential.familyName,
        'useBundleId': Platform.isIOS || Platform.isMacOS ? 'true' : 'false',
        if (credential.state != null) 'state': credential.state,
      },
    );

    if (credential.userIdentifier != "") {
      appleID = credential.userIdentifier;

      if (credential.givenName != null && credential.familyName != null) {
        appleFullname = credential.givenName + " " + credential.familyName;
        appleEmail = credential.email;
      } else {
        appleFullname = "";
      }
      checkHasUserApple();
    }

    final session = await http.Client().post(
      signInWithAppleEndpoint,
    );
    print(session);
  }

  checkHasUserApple() {
    Map _map = {};
    _map.addAll({
      "apple_id": appleID,
      "appleFullname": appleFullname,
    });

    print("_map" + _map.toString());

    var body = json.encode(_map);
    postAppleIDData(http.Client(), body, _map);
  }

  Future<List<AllList>> postAppleIDData(
      http.Client client, jsonMap, Map map) async {
    final response = await client.post(Uri.parse(Info().checkHasUser),
        headers: {"Content-Type": "application/json"}, body: jsonMap);

    final _list = json.decode(response.body);

    print("_list" + _list.toString());

    if (_list['fullname'] == "") {
      Map _map = {};
      _map.addAll({
        "username": appleID,
        "name": appleFullname,
        "email": appleEmail,
        "socialID": appleID,
        "type": "apple"
      });
      print("_map_map" + _map.toString());
      var body = json.encode(_map);
      postUserRegistAdd(http.Client(), body, _map);

      //ไปสมัคร
      /*Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RegisterView(
            isHaveArrow: "1",
            socialID: appleID,
            type: "apple",
            appleFullname: appleFullname,
          ),
        ),
      );*/
    } else {
      login(socialID: appleID, type: "apple");
    }
  }

  Future<List<AllList>> postUserRegistAdd(
      http.Client client, jsonMap, Map map) async {
    final response = await client.post(Uri.parse(Info().userRegistAdd),
        headers: {"Content-Type": "application/json"}, body: jsonMap);
    var rs = json.decode(response.body);
    var status = rs["status"].toString();
    var msg = rs["msg"].toString();
    if (status == "success") {
      await user.init();
      user.isLogin = true;
      user.uid = rs["uid"].toString();
      user.fullname = rs["fullname"].toString();
      user.phone = rs["phone"].toString();
      user.avatar = rs["avatar"].toString();
      user.email = rs["email"].toString();
      user.priv = rs["priv"].toString();
      user.username = rs["username"].toString();
      user.citizen_id = rs["citizen_id"].toString();
      user.authen_token = rs["authen_token"].toString();
      user.userclass = rs["userclass"].toString();

      user.facebook_id = rs["facebook_id"].toString();
      user.line_id = rs["line_id"].toString();
      user.google_id = rs["google_id"].toString();
      user.apple_id = rs["apple_id"].toString();

      Toast.show(msg, context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => FrontPageView()),
        ModalRoute.withName("/"),
      );
    } else {
      Toast.show(msg, context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    }
  }

  @override
  Widget build(BuildContext context) {
    print("isHaveArrow : " + widget.isHaveArrow);

    return SafeArea(
        child: Scaffold(
      appBar: AppBarView(
        title: "เข้าสู่ระบบหรือสมัครสมาชิก",
        isHaveArrow: widget.isHaveArrow,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.white,
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 32),
            margin: EdgeInsets.only(top: 8),
            child: Column(
              children: [
                //logo
                if (icon != "")
                  Image.network(
                    icon,
                    height: 96,
                  ),
                //username
                Container(
                  height: 50,
                  margin: EdgeInsets.only(top: 16),
                  child: TextField(
                    controller: _username,
                    decoration: InputDecoration(
                      isDense: true,
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey, width: 1),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey, width: 1),
                      ),
                      hintText: 'ชื่อผู้ใช้ / เบอร์โทรศัพท์',
                      errorText: _validateUsername
                          ? 'กรุณากรอกชื่อผู้ใช้ / เบอร์โทรศัพท์'
                          : null,
                    ),
                  ),
                ),

                //password
                Container(
                  height: 50,
                  margin: EdgeInsets.only(top: 16),
                  child: TextField(
                    controller: _password,
                    obscureText: true,
                    decoration: InputDecoration(
                      isDense: true,
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey, width: 1),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey, width: 1),
                      ),
                      hintText: 'รหัสผ่าน',
                      errorText: _validatePassword ? 'กรุณากรอกรหัสผ่าน' : null,
                    ),
                  ),
                ),

                //btnLogin
                Container(
                  margin: EdgeInsets.only(top: 16),
                  height: 40,
                  width: MediaQuery.of(context).size.width,
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Color(0xFF8C1F78)),
                    ),
                    onPressed: () {
                      setState(() {
                        _username.text.isEmpty
                            ? _validateUsername = true
                            : _validateUsername = false;
                        _password.text.isEmpty
                            ? _validatePassword = true
                            : _validatePassword = false;

                        if (!_validateUsername && !_validatePassword) {
                          EasyLoading.show(status: 'loading...');
                          login();
                        }
                      });
                    },
                    child: Text("เข้าสู่ระบบ"),
                  ),
                ),

                //regis
                Container(
                  margin: EdgeInsets.only(top: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RegisterView(
                                isHaveArrow: "1",
                              ),
                            ),
                          );
                        },
                        child: Text("สมัครสมาชิกใหม่"),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ForgetPasswordView(
                                isHaveArrow: "1",
                              ),
                            ),
                          );
                        },
                        child: Text("ลืมรหัสผ่าน?"),
                      ),
                    ],
                  ),
                ),

                //or
                Visibility(
                  visible: (isBlindBlock == "") ? true : false,
                  child: Container(
                    margin: EdgeInsets.only(top: 32),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Divider(
                            color: Color(0xFF8C1F78),
                          ),
                        ),
                        Container(
                          child: Text("หรือ"),
                          margin: EdgeInsets.symmetric(horizontal: 16),
                        ),
                        Expanded(
                          child: Divider(
                            color: Color(0xFF8C1F78),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                //social
                Visibility(
                  visible: (isBlindBlock == "") ? true : false,
                  child: Container(
                    margin: EdgeInsets.only(top: 16),
                    child: Row(
                      children: [
                        (platform == "ios")
                            ? (isBlindBlockFace == "")
                                ? Expanded(
                                    child: GestureDetector(
                                      onTap: () {
                                        _loginFace();
                                      },
                                      child: Image.asset(
                                        'assets/images/facebook-ic.png',
                                        height: 64,
                                      ),
                                    ),
                                  )
                                : Container()
                            : Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    _loginFace();
                                  },
                                  child: Image.asset(
                                    'assets/images/facebook-ic.png',
                                    height: 64,
                                  ),
                                ),
                              ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              _loginGoogle();
                            },
                            child: Image.asset(
                              'assets/images/google-ic.png',
                              height: 64,
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              _loginLine();
                            },
                            child: Image.asset(
                              'assets/images/line-ic.png',
                              height: 64,
                            ),
                          ),
                        ),
                        if (platform == "ios")
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                _loginApple();
                              },
                              child: Image.asset(
                                'assets/images/apple-btn-sign.png',
                                height: 64,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ));
  }
}
