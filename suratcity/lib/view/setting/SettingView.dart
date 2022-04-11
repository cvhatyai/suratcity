import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:flutter_line_sdk/flutter_line_sdk.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cvapp/model/AllList.dart';
import 'package:cvapp/model/user.dart';
import 'package:cvapp/system/Info.dart';
import 'package:cvapp/view/menu/MenuView.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:toast/toast.dart';

import '../AppBarView.dart';
import '../FrontPageView.dart';
import 'ChangePasswordView.dart';
import 'ChangePhoneView.dart';

var data;

Map<String, String> _images;
Map<String, String> _dataFiles;
List<File> _filesAll = List<File>();

GoogleSignIn _googleSignIn = GoogleSignIn(
  //clientId: '8566559601-js6kpoddokr7g6ul8esholqtrk7k06h5.apps.googleusercontent.com',
  scopes: <String>[
    'email',
    //'https://www.googleapis.com/auth/contacts.readonly',
  ],
);

class SignInLine {
  void lineSDKInit() async {
    await LineSDK.instance.setup("1655954746").then((_) {
      print("LineSDK is Prepared");
    });
  }
}

typedef void OnPickImageCallback(
    double maxWidth, double maxHeight, int quality);

class SettingView extends StatefulWidget {
  SettingView({Key key, this.isHaveArrow = ""}) : super(key: key);
  final String isHaveArrow;

  @override
  _SettingViewState createState() => _SettingViewState();
}

class _SettingViewState extends State<SettingView> {
  var user = User();
  bool isLogin = false;
  bool isSwitched = false;

  final _fullname = TextEditingController();
  final _idCard = TextEditingController();
  bool _validateFullname = false;
  bool _validateIdCard = false;

  var userFullname = "";
  var userIdCard = "";
  var isBlindBlock = "1";
  var uid = "";

  var userFaceID = "";
  var userLineID = "";
  var userAppleID = "";
  var userGoogleID = "";
  var platform = "ios";

  var userAvatar = Info().baseUrl + "images/nopic-personal.jpg";

  bool isLoadingPath = false;
  String path;
  Map<String, String> paths;
  FileType fileType;
  List<String> extensions;
  String fileName;
  int filesImageTotal = 0;
  final ImagePicker _picker = ImagePicker();
  PickedFile _imageFile;
  dynamic _pickImageError;

  FirebaseMessaging firebaseMessaging = FirebaseMessaging();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    if (Platform.isIOS) {
      platform = "ios";
    } else {
      platform = "android";
    }
    SignInLine().lineSDKInit();
    getUsers();
    getSiteDetail();
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount account) {
      signOutWithGoogle();
    });
    //_initPackageInfo();
  }

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
      isBlindBlock = rs["loginBlock"].toString();
    });
  }

  @override
  void dispose() {
    super.dispose();
    if (_images != null) {
      _images.clear();
    }
  }

  getUsers() async {
    await user.init();
    setState(() {
      isLogin = user.isLogin;
      if (isLogin) {
        userFullname = user.fullname;
        userIdCard = user.citizen_id;
        userAvatar = user.avatar;
        uid = user.uid;

        userFaceID = user.facebook_id;
        userLineID = user.line_id;
        userAppleID = user.apple_id;
        userGoogleID = user.google_id;

        if (userFullname != "") {
          _fullname.text = userFullname;
        }

        if (userIdCard != "") {
          _idCard.text = userIdCard;
        }

        if (user.isNoti == "1") {
          isSwitched = true;
        } else {
          isSwitched = false;
        }

        print("userFaceID" + userFaceID);
        print("userLineID" + userLineID);
        print("password" + user.password);
      }
    });
  }

  updateData() async {
    if (isSwitched) {
      user.isNoti = "1";
      firebaseMessaging.subscribeToTopic("th.go.suratcity");
      firebaseMessaging.subscribeToTopic("news");
    } else {
      user.isNoti = "";
      firebaseMessaging.unsubscribeFromTopic("th.go.suratcity");
      firebaseMessaging.unsubscribeFromTopic("news");
    }

    if (_images != null) {
      _dataFiles = _images;
    }

    if (_dataFiles != null) {
      for (int i = 0; i < _dataFiles.length; i++) {
        var file = await getImageFileFromAsset(
            _dataFiles.values.toList()[i].toString());
        setState(() {
          _filesAll.add(file);
        });
      }
    }

    var uri = Uri.parse(Info().updateUserFullname);
    var request = http.MultipartRequest('POST', uri);

    var platform = "";
    if (Platform.isAndroid) {
      platform = "android";
    } else {
      platform = "ios";
    }

    request.fields['name'] = _fullname.text;
    request.fields['citizen_id'] = _idCard.text;
    request.fields['uid'] = uid;

    if (_filesAll.length > 0) {
      var len_file = _filesAll.length;
      print("wit len file $len_file");
      for (int i = 0; i < len_file; i++) {
        var ext = _filesAll[i].path.split('.').last;
        var file = await http.MultipartFile.fromPath(
            'file[$i]', _filesAll[i].path,
            contentType: MediaType('image', ext));
        //add multipart to request
        request.files.add(file);
      }
    }

    print("wit before submit");
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    print("wit after submit");
    if (response.statusCode == 200) {
      EasyLoading.dismiss();
      final data = jsonDecode(response.body);
      print('wit data: ' + data.toString());

      final status = data['status'].toString();
      final msg = data['msg'].toString();
      final avatarRs = data['avatar'].toString();
      if (status == 'success') {
        Toast.show(msg, context,
            duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
        EasyLoading.dismiss();
        updateUserPrefData(avatarRs);
      } else {
        showDialog(
          context: context,
          builder: (_) => new CupertinoAlertDialog(
            title: new Text(
              "ขออภัยค่ะ",
              textScaleFactor: 1.0,
              style: TextStyle(color: Colors.red),
            ),
            content: new Text(
              msg,
              textScaleFactor: 1.0,
            ),
            actions: <Widget>[
              FlatButton(
                child: Text(
                  'ตกลง',
                  textScaleFactor: 1.0,
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          ),
        );
      }
    }
  }

  updateUserPrefData(avatarRs) {
    print("avatarRsavatarRs" + avatarRs.toString());
    user.fullname = _fullname.text;
    user.citizen_id = _idCard.text;
    if (avatarRs != "") {
      user.avatar = avatarRs;
    }

    if (_images != null) {
      _images.clear();
    }
    if (_dataFiles != null) {
      _dataFiles.clear();
    }
    if (_filesAll != null) {
      _filesAll.clear();
    }

    /*Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => FrontPageView()),
      ModalRoute.withName("/"),
    );*/
  }

  Future<File> getImageFileFromAsset(String path) async {
    final file = File(path);
    return file;
  }

  Future<void> _handleClickFiles() async {
    return showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) {
        return CupertinoActionSheet(
          title: Text('อัพโหลดรูป',
              textScaleFactor: 1.0,
              style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold)),
          actions: <Widget>[
            CupertinoActionSheetAction(
              child: Text(
                'รูปภาพ',
                textScaleFactor: 1.0,
              ),
              onPressed: () {
                Navigator.pop(context);
                _openFileImagesExplorer();
              },
            ),
            CupertinoActionSheetAction(
              child: Text(
                'กล้อง',
                textScaleFactor: 1.0,
              ),
              onPressed: () {
                Navigator.pop(context);
                _openCameraExplorer(ImageSource.camera, context: context);
                //_imgFromCamera();
              },
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            isDefaultAction: true,
            child: Text('ยกเลิก',
                textScaleFactor: 1.0, style: TextStyle(color: Colors.red)),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        );
      },
    );
  }

  void _openCameraExplorer(ImageSource source, {BuildContext context}) async {
    await _displayPickImageDialog(context,
        (double maxWidth, double maxHeight, int quality) async {
      try {
        final pickedFile = await _picker.getImage(
          source: source,
          maxWidth: maxWidth,
          maxHeight: maxHeight,
          imageQuality: quality,
        );
        setState(() {
          _imageFile = pickedFile;
          var path = _imageFile.path;
          var name = _imageFile.path.split('/').last.toString();
          print("camera: $name : $path");
          _images = {name: path};
        });
      } catch (e) {
        setState(() {
          _pickImageError = e;
        });
      }
    });
  }

  /*_imgFromCamera() async {
    File image = await ImagePicker.pickImage(
        source: ImageSource.camera, imageQuality: 50
    );

    setState(() {
      print(image.toString());
      //_image = image;
    });
  }*/

  Future<void> _displayPickImageDialog(
      BuildContext context, OnPickImageCallback onPick) async {
    return onPick(null, null, null);
  }

  void _openFileImagesExplorer() async {
    setState(() => isLoadingPath = true);
    try {
      path = null;
      paths = await FilePicker.getMultiFilePath(
          type: fileType != null ? fileType : FileType.image,
          allowedExtensions: extensions);
    } on PlatformException catch (e) {
      print("Unsupported operation" + e.toString());
    }
    if (!mounted) return;
    setState(() {
      isLoadingPath = false;
      fileName = path != null
          ? path.split('/').last
          : paths != null
              ? paths.keys.toString()
              : '...';
      print("paths : $paths");
      if (paths != null) {
        _images = paths;
        filesImageTotal = _images.length;
      }
      print(_images);
    });
  }

  //ShowAlert
  Future<void> _showMyDialog(msg) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          //title: Text('AlertDialog Title'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(msg),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('ตกลง'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> showAlertBox(socialID, type) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          //title: Text('AlertDialog Title'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text("คุณต้องการยกเลิกการเชื่อมต่อนี้?"),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('ยกเลิก'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('ตกลง'),
              onPressed: () {
                Navigator.of(context).pop();
                cancelContectUser(socialID, type);
              },
            ),
          ],
        );
      },
    );
  }

  cancelContectUser(socialID, type) {
    Map _map = {};
    _map.addAll({
      "socialID": socialID,
      "type": type,
      "uid": user.uid,
    });

    print("_map" + _map.toString());

    var body = json.encode(_map);
    postCancelContectUser(http.Client(), body, _map, type);
  }

  Future<List<AllList>> postCancelContectUser(
      http.Client client, jsonMap, Map map, type) async {
    final response = await client.post(Uri.parse(Info().cancelContectUser),
        headers: {"Content-Type": "application/json"}, body: jsonMap);
    final _list = json.decode(response.body);
    _showMyDialog(_list["msg"]);

    print("status" + _list["status"].toString());
    if (_list["status"] == "success") {
      if (type == "facebook") {
        user.facebook_id = "";
      } else if (type == "line") {
        user.line_id = "";
      } else if (type == "apple") {
        user.apple_id = "";
      } else if (type == "google") {
        user.google_id = "";
      }
      getUsers();
    }
  }

  //checkFaceID
  final FacebookLogin facebookSignIn = new FacebookLogin();
  String _message = 'Log in/out by pressing the buttons below.';
  String faceID = '';
  var faceData = Map<String, dynamic>();

  checkFaceID() async {
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
      print("_message $_message");
      print("faceID $faceID");
      print("faceData $faceData");
      print("first_name " + faceData['first_name']);
      print("last_name " + faceData['last_name']);
      print("email " + faceData['email']);
      print("picture " + faceData['picture']["data"]["url"]);
      //type = "fb";
      if (faceID != "") {
        checkHasUserFace();
      }
    });
  }

  checkHasUserFace() {
    Map _map = {};
    _map.addAll({
      "facebook_id": faceID,
      "uid": user.uid,
    });

    print("_map" + _map.toString());

    var body = json.encode(_map);
    postFaceIDData(http.Client(), body, _map);
  }

  Future<List<AllList>> postFaceIDData(
      http.Client client, jsonMap, Map map) async {
    final response = await client.post(Uri.parse(Info().checkConnectedUser),
        headers: {"Content-Type": "application/json"}, body: jsonMap);
    final _list = json.decode(response.body);
    _showMyDialog(_list["msg"]);

    if (_list["status"] == "success") {
      user.facebook_id = faceID;
      getUsers();
    }
  }

  //checkLineID
  String lineID = '';
  String lineAvatar = '';

  void checkLineID() async {
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
      "uid": user.uid,
    });

    print("_map" + _map.toString());

    var body = json.encode(_map);
    postLineIDData(http.Client(), body, _map);
  }

  Future<List<AllList>> postLineIDData(
      http.Client client, jsonMap, Map map) async {
    final response = await client.post(Uri.parse(Info().checkConnectedUser),
        headers: {"Content-Type": "application/json"}, body: jsonMap);

    final _list = json.decode(response.body);
    _showMyDialog(_list["msg"]);

    if (_list["status"] == "success") {
      user.line_id = lineID;
      getUsers();
    }
  }

  /////////////////////////Apple
  String appleID = '';
  String appleFullname = '';
  String appleEmail = '';

  Future<void> checkAppleID() async {
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
      "uid": user.uid,
    });

    print("_map" + _map.toString());

    var body = json.encode(_map);
    postAppleIDData(http.Client(), body, _map);
  }

  Future<List<AllList>> postAppleIDData(
      http.Client client, jsonMap, Map map) async {
    final response = await client.post(Uri.parse(Info().checkConnectedUser),
        headers: {"Content-Type": "application/json"}, body: jsonMap);

    final _list = json.decode(response.body);
    _showMyDialog(_list["msg"]);

    if (_list["status"] == "success") {
      user.apple_id = appleID;
      getUsers();
    }
  }

  //checkGoogleID

  String googleID = '';
  String googleAvatar = '';
  GoogleSignInAccount _currentUser;

  void checkGoogleID() async {
    //EasyLoading.show(status: 'loading...');
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount account) {
      setState(() {
        _currentUser = account;
      });
      if (_currentUser != null) {
        _handleGetContact();
      }
    });
    _googleSignIn.signInSilently();
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
      "uid": user.uid,
    });

    print("_map" + _map.toString());

    var body = json.encode(_map);
    postGoogleIDData(http.Client(), body, _map);
  }

  Future<List<AllList>> postGoogleIDData(
      http.Client client, jsonMap, Map map) async {
    final response = await client.post(Uri.parse(Info().checkConnectedUser),
        headers: {"Content-Type": "application/json"}, body: jsonMap);

    final _list = json.decode(response.body);
    _showMyDialog(_list["msg"]);

    if (_list["status"] == "success") {
      user.google_id = googleID;
      getUsers();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBarView(
          title: "ตั้งค่าบัญชี",
          isHaveArrow: widget.isHaveArrow,
        ),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          color: Color(0xFFFFFFFF),
          child: SingleChildScrollView(
            child: Container(
              margin: EdgeInsets.only(top: 8),
              child: Column(
                children: [
                  //avatar
                  ClipOval(
                    child: Container(
                      width: 124,
                      height: 124,
                      color: Color(0xFFA6D6F2),
                      child: (_images != null)
                          ? Image.file(
                              File(_images.values.toList()[0]),
                              fit: BoxFit.cover,
                            )
                          : Image.network(
                              userAvatar,
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                  //avatarEdit
                  Container(
                    margin: EdgeInsets.only(top: 16),
                    child: GestureDetector(
                      onTap: () {
                        _handleClickFiles();
                      },
                      child: Text("แก้ไข"),
                    ),
                  ),
                  //userFullname
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Text("ชื่อ-สกุล"),
                        Expanded(
                          child: Container(
                            child: TextField(
                              controller: _fullname,
                              textAlign: TextAlign.right,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                disabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                errorText: _validateFullname
                                    ? 'กรุณากรอกชื่อ-นามสกุล'
                                    : null,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    Icons.edit,
                                    color: Colors.blue,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(),

                  //phone
                  if (user.password != "" && user.password != "null")
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Text("เปลี่ยนเบอร์โทรศัพท์"),
                          Expanded(
                            child: Container(
                              alignment: Alignment.centerRight,
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ChangePhoneView(),
                                    ),
                                  );
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(user.username),
                                    IconButton(
                                      icon: Icon(
                                        Icons.edit,
                                        color: Colors.blue,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (user.password != "" && user.password != "null") Divider(),

                  //idCard
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(
                            "หมายเลขบัตรประชาชน",
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Container(
                            child: TextField(
                              controller: _idCard,
                              maxLength: 13,
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.right,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                disabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                errorText: _validateIdCard
                                    ? 'กรุณากรอกหมายเลขบัตรประชาชน'
                                    : null,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    Icons.edit,
                                    color: Colors.blue,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(),

                  //pass
                  if (user.password != "" && user.password != "null")
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Text("เปลี่ยนรหัสผ่าน"),
                          Expanded(
                            child: Container(
                              alignment: Alignment.centerRight,
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          ChangePasswordView(),
                                    ),
                                  );
                                },
                                child: IconButton(
                                  icon: Icon(
                                    Icons.edit,
                                    color: Colors.blue,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (user.password != "" && user.password != "null") Divider(),

                  //social
                  Visibility(
                    visible: (isBlindBlock == "") ? true : false,
                    child: Container(
                      child: Column(
                        children: [
                          //facebook
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              children: [
                                Image.asset(
                                  'assets/images/facebook-ic.png',
                                  height: 48,
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Container(
                                    padding: EdgeInsets.only(right: 16),
                                    child: Text(
                                      "Facebook",
                                    ),
                                  ),
                                ),
                                (userFaceID == "null" || userFaceID == "")
                                    ? Expanded(
                                        flex: 1,
                                        child: ElevatedButton(
                                          onPressed: () {
                                            checkFaceID();
                                          },
                                          style: ButtonStyle(
                                            backgroundColor:
                                                MaterialStateProperty.all<
                                                    Color>(Colors.green),
                                          ),
                                          child: Text(
                                            "เชื่อมต่อ",
                                            style: TextStyle(
                                              fontSize: 12,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        ),
                                      )
                                    : Expanded(
                                        flex: 1,
                                        child: ElevatedButton(
                                          onPressed: () {
                                            showAlertBox(
                                                userFaceID, "facebook");
                                          },
                                          style: ButtonStyle(
                                            backgroundColor:
                                                MaterialStateProperty.all<
                                                    Color>(Colors.grey),
                                          ),
                                          child: Text(
                                            "ยกเลิกการเชื่อมต่อ",
                                            style: TextStyle(
                                              fontSize: 12,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        ),
                                      )
                              ],
                            ),
                          ),
                          Divider(),
                          //google
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              children: [
                                Image.asset(
                                  'assets/images/google-ic.png',
                                  height: 48,
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Container(
                                    padding: EdgeInsets.only(right: 16),
                                    child: Text(
                                      "Google",
                                    ),
                                  ),
                                ),
                                (userGoogleID == "null" || userGoogleID == "")
                                    ? Expanded(
                                        flex: 1,
                                        child: ElevatedButton(
                                          onPressed: () {
                                            checkGoogleID();
                                          },
                                          style: ButtonStyle(
                                            backgroundColor:
                                                MaterialStateProperty.all<
                                                    Color>(Colors.green),
                                          ),
                                          child: Text(
                                            "เชื่อมต่อ",
                                            style: TextStyle(
                                              fontSize: 12,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        ),
                                      )
                                    : Expanded(
                                        flex: 1,
                                        child: ElevatedButton(
                                          onPressed: () {
                                            showAlertBox(
                                                userGoogleID, "google");
                                          },
                                          style: ButtonStyle(
                                            backgroundColor:
                                                MaterialStateProperty.all<
                                                    Color>(Colors.grey),
                                          ),
                                          child: Text(
                                            "ยกเลิกการเชื่อมต่อ",
                                            style: TextStyle(
                                              fontSize: 12,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        ),
                                      )
                              ],
                            ),
                          ),
                          Divider(),
                          //line
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              children: [
                                Image.asset(
                                  'assets/images/line-ic.png',
                                  height: 48,
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Container(
                                    padding: EdgeInsets.only(right: 16),
                                    child: Text(
                                      "Line",
                                    ),
                                  ),
                                ),
                                (userLineID == "null" || userLineID == "")
                                    ? Expanded(
                                        flex: 1,
                                        child: ElevatedButton(
                                          onPressed: () {
                                            checkLineID();
                                          },
                                          style: ButtonStyle(
                                            backgroundColor:
                                                MaterialStateProperty.all<
                                                    Color>(Colors.green),
                                          ),
                                          child: Text(
                                            "เชื่อมต่อ",
                                            style: TextStyle(
                                              fontSize: 12,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        ),
                                      )
                                    : Expanded(
                                        flex: 1,
                                        child: ElevatedButton(
                                          onPressed: () {
                                            showAlertBox(userLineID, "line");
                                          },
                                          style: ButtonStyle(
                                            backgroundColor:
                                                MaterialStateProperty.all<
                                                    Color>(Colors.grey),
                                          ),
                                          child: Text(
                                            "ยกเลิกการเชื่อมต่อ",
                                            style: TextStyle(
                                              fontSize: 12,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        ),
                                      )
                              ],
                            ),
                          ),
                          Divider(),
                          //apple
                          if (platform == "ios")
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Row(
                                children: [
                                  Image.asset(
                                    'assets/images/apple-btn-sign.png',
                                    height: 48,
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Container(
                                      padding: EdgeInsets.only(right: 16),
                                      child: Text(
                                        "Apple",
                                      ),
                                    ),
                                  ),
                                  (userAppleID == "null" || userAppleID == "")
                                      ? Expanded(
                                          flex: 1,
                                          child: ElevatedButton(
                                            onPressed: () {
                                              checkAppleID();
                                            },
                                            style: ButtonStyle(
                                              backgroundColor:
                                                  MaterialStateProperty.all<
                                                      Color>(Colors.green),
                                            ),
                                            child: Text(
                                              "เชื่อมต่อ",
                                              style: TextStyle(
                                                fontSize: 12,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                            ),
                                          ),
                                        )
                                      : Expanded(
                                          flex: 1,
                                          child: ElevatedButton(
                                            onPressed: () {
                                              showAlertBox(
                                                  userAppleID, "apple");
                                            },
                                            style: ButtonStyle(
                                              backgroundColor:
                                                  MaterialStateProperty.all<
                                                      Color>(Colors.grey),
                                            ),
                                            child: Text(
                                              "ยกเลิกการเชื่อมต่อ",
                                              style: TextStyle(
                                                fontSize: 12,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                            ),
                                          ),
                                        )
                                  /*Expanded(
                                    child: ElevatedButton(
                                      onPressed: () {

                                      },
                                      style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.all<Color>(
                                                Colors.green),
                                      ),
                                      child: Text(
                                        "เชื่อมต่อ",
                                        style: TextStyle(
                                          fontSize: 12,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ),
                                  )*/
                                ],
                              ),
                            ),
                          if (platform == "ios") Divider(),
                        ],
                      ),
                    ),
                  ),

                  //noti
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Expanded(child: Text("การแจ้งเตือน")),
                        Switch(
                          value: isSwitched,
                          onChanged: (value) {
                            setState(() {
                              isSwitched = value;
                              print(isSwitched);
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  Divider(),
                  //save
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _fullname.text.isEmpty
                            ? _validateFullname = true
                            : _validateFullname = false;
                        _idCard.text.isEmpty
                            ? _validateIdCard = true
                            : _validateIdCard = false;
                        if (!_validateFullname && !_validateIdCard) {
                          EasyLoading.show(status: 'loading...');
                          updateData();
                        }
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(9),
                      ),
                    ),
                    child: Ink(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.lightBlue, Colors.blue],
                        ),
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: Container(
                        width: 150,
                        height: 40,
                        alignment: Alignment.center,
                        child: Text(
                          'บันทึก',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
