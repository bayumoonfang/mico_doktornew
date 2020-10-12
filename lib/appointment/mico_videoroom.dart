import 'dart:async';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:mico_doktornew/helper/checkconnection.dart';
import 'package:mico_doktornew/helper/session_login.dart';
import 'package:mico_doktornew/helper/setting.dart';
import 'package:mico_doktornew/mico_home.dart';
import 'package:mico_doktornew/mico_login.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:responsive_container/responsive_container.dart';
import 'package:toast/toast.dart';


class VideoChatHome extends StatefulWidget {
  final String getApp, getRoom;
  final ClientRole role = ClientRole.Broadcaster;


  const VideoChatHome(this.getApp, this.getRoom);

  @override
  _VideoChatHomeState createState() => _VideoChatHomeState();
}

class _VideoChatHomeState extends State<VideoChatHome> {
  static final _users = <int>[];
  final _infoStrings = <String>[];
  bool muted = false;
  String getRoomVideo,
      getPhoneNumber= '...';
  String getID = '';

  _VideoChatHomeState({this.getID});


  void showToast(String msg, {int duration, int gravity}) {
    Toast.show(msg, context, duration: duration, gravity: gravity);
  }

  void _getVideoDetail() async {
    final response = await http.get(
        "https://duakata-dev.com/miracle/api_script.php?do=getdata_videodetailuser&id="+widget.getApp);
    Map data = jsonDecode(response.body);
    setState(() {
      getRoomVideo = data["roomvideo"].toString();
    });
  }


  _connect() async {
    Checkconnection().check().then((internet){
      if (internet != null && internet) {
        // Internet Present Case
      } else {
        showToast("Koneksi terputus..", gravity: Toast.CENTER, duration: Toast.LENGTH_LONG);
      }
    });
  }

  _session() async {
    int value = await Session.getValue();
    getPhoneNumber = await Session.getPhone();
    if (value != 1) {
      Navigator.of(context).pushReplacement(new MaterialPageRoute(
          builder: (BuildContext context) => Login()));
    }
  }

  Future<void> _handleCameraAndMic() async {
    await PermissionHandler().requestPermissions(
      [PermissionGroup.camera, PermissionGroup.microphone],
    );
  }

  @override
  void dispose() {
    // clear users
    _users.clear();
    // destroy sdk
    AgoraRtcEngine.leaveChannel();
    AgoraRtcEngine.destroy();
    _timer.cancel();
    super.dispose();
  }

  int waktunya;
  int dd = DateTime.now().millisecondsSinceEpoch + 1000 * 60 * 60;

  @override
  void initState() {
    super.initState();
    _connect();
    _session();
    _handleCameraAndMic();
    _getVideoDetail();
    // initialize agora sdk
    initialize();
    //startTimer();
    //the birthday's date
    final birthday = DateTime(2020, 10, 26);
    final date2 = DateTime.now();
    final difference = date2.difference(birthday).inMilliseconds;

   /* final startTime = DateTime(2020, 10, 26, 10, 30);
    final currentTime = DateTime.now();

    final diff_dy = currentTime.difference(startTime).inDays;
    final diff_hr = currentTime.difference(startTime).inHours;
    final diff_mn = currentTime.difference(startTime).inMinutes;
    final diff_sc = currentTime.difference(startTime).inSeconds;

    waktunya = diff_sc;*/

    // showToast(dd.toString(), gravity: Toast.CENTER, duration: Toast.LENGTH_LONG);

    //showToast(difference.toString(), gravity: Toast.CENTER, duration: Toast.LENGTH_LONG);
  }

  Future<void> initialize() async {
    if (APP_ID.isEmpty) {
      setState(() {
        _infoStrings.add(
          'APP_ID missing, please provide your APP_ID in settings.dart',
        );
        _infoStrings.add('Agora Engine is not starting');
      });
      return;
    }

    await _initAgoraRtcEngine();
    _addAgoraEventHandlers();
    await AgoraRtcEngine.enableWebSdkInteroperability(true);
    VideoEncoderConfiguration configuration = VideoEncoderConfiguration();
    configuration.dimensions = Size(1920, 1080);
    await AgoraRtcEngine.setVideoEncoderConfiguration(configuration);
    await AgoraRtcEngine.joinChannel(null, widget.getRoom, null, 0);
  }

  /// Create agora sdk instance and initialize
  Future<void> _initAgoraRtcEngine() async {
    await AgoraRtcEngine.create(APP_ID);
    await AgoraRtcEngine.enableVideo();
    await AgoraRtcEngine.setChannelProfile(ChannelProfile.LiveBroadcasting);
    await AgoraRtcEngine.setClientRole(widget.role);
  }

  /// Add agora event handlers
  void _addAgoraEventHandlers() {
    AgoraRtcEngine.onError = (dynamic code) {
      setState(() {
        final info = 'onError: $code';
        _infoStrings.add(info);
      });
    };

    AgoraRtcEngine.onJoinChannelSuccess = (
        String channel,
        int uid,
        int elapsed,
        ) {
      setState(() {
        final info = 'onJoinChannel: $channel, uid: $uid';
        _infoStrings.add(info);
      });
    };

    AgoraRtcEngine.onLeaveChannel = () {
      setState(() {
        _infoStrings.add('onLeaveChannel');
        _users.clear();
      });
    };

    AgoraRtcEngine.onUserJoined = (int uid, int elapsed) {
      setState(() {
        final info = 'userJoined: $uid';
        _infoStrings.add(info);
        _users.add(uid);
      });
    };

    AgoraRtcEngine.onUserOffline = (int uid, int reason) {
      setState(() {
        final info = 'userOffline: $uid';
        _infoStrings.add(info);
        _users.remove(uid);
      });
    };

    AgoraRtcEngine.onFirstRemoteVideoFrame = (
        int uid,
        int width,
        int height,
        int elapsed,
        ) {
      setState(() {
        final info = 'firstRemoteVideo: $uid ${width}x $height';
        _infoStrings.add(info);
      });
    };
  }

  /// Helper function to get list of native views
  List<Widget> _getRenderViews() {
    final List<AgoraRenderWidget> list = [];
    if (widget.role == ClientRole.Broadcaster) {
      list.add(AgoraRenderWidget(0, local: true, preview: true));
    }
    _users.forEach((int uid) => list.add(AgoraRenderWidget(uid)));
    return list;
  }

  /// Video view wrapper
  Widget _videoView(view) {
    return Expanded(child: Container(child: view));
  }

  /// Video view row wrapper
  Widget _expandedVideoRow(List<Widget> views) {
    final wrappedViews = views.map<Widget>(_videoView).toList();
    return Expanded(
      child: Row(
        children: wrappedViews,
      ),
    );
  }

  /// Video layout wrapper
  Widget _viewRows() {
    final views = _getRenderViews();
    switch (views.length) {
      case 1:
        return Container(
            child: Column(
              children: <Widget>[_videoView(views[0])],
            ));

      case 2:
        return Container(
            child: Column(
              children: <Widget>[
                _expandedVideoRow([views[0]]),
                _expandedVideoRow([views[1]]),
              ],
            ));
      case 3:
        return Container(
            child: Column(
              children: <Widget>[
                _expandedVideoRow(views.sublist(0, 2)),
                _expandedVideoRow(views.sublist(2, 3))
              ],
            ));
      case 4:
        return Container(
            child: Column(
              children: <Widget>[
                _expandedVideoRow(views.sublist(0, 2)),
                _expandedVideoRow(views.sublist(2, 4))
              ],
            ));
      default:
    }
    return Container();
  }

  /// Toolbar layout
  Widget _toolbar() {
    final viewnya = _getRenderViews();
   /* if (viewnya.length == 1) {
      return Container(
        alignment: Alignment.bottomCenter,
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                    width: 60, height: 60, child: CircularProgressIndicator()),
                Padding(padding: const EdgeInsets.all(25.0)),
                Text(
                  "Menunggu Pasien",
                  style: TextStyle(
                      fontFamily: 'VarelaRound',
                      fontSize: 18,
                      color: Colors.white),
                ),
              ],
            )
          ],
        ),
      );
    } else {*/
      // if (widget.role == ClientRole.Audience || viewnya.length == 0)
      //return Container();
      return Container(
        alignment: Alignment.bottomCenter,
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            RawMaterialButton(
              onPressed: _onToggleMute,
              child: Icon(
                muted ? Icons.mic_off : Icons.mic,
                color: muted ? Colors.white : Colors.blueAccent,
                size: 20.0,
              ),
              shape: CircleBorder(),
              elevation: 2.0,
              fillColor: muted ? Colors.blueAccent : Colors.white,
              padding: const EdgeInsets.all(12.0),
            ),
            RawMaterialButton(
              onPressed: () => showAlert2(),
              child: Icon(
                Icons.call_end,
                color: Colors.white,
                size: 35.0,
              ),
              shape: CircleBorder(),
              elevation: 2.0,
              fillColor: Colors.redAccent,
              padding: const EdgeInsets.all(15.0),
            ),
            RawMaterialButton(
              onPressed: _onSwitchCamera,
              child: Icon(
                Icons.switch_camera,
                color: Colors.blueAccent,
                size: 20.0,
              ),
              shape: CircleBorder(),
              elevation: 2.0,
              fillColor: Colors.white,
              padding: const EdgeInsets.all(12.0),
            )
          ],
        ),
      );
  /*  }*/
  }

  int endTime2 = DateTime.now().millisecondsSinceEpoch + 1000 * 60 * 60;

  /// Info panel to show logs
  Widget _panel() {
    return
      Align(
        alignment: Alignment.topRight,
    child :      Padding(
      padding: const EdgeInsets.only(top: 20,right: 20),
      child:  Container(
          padding: const EdgeInsets.only(top: 30,right: 10),
          alignment: Alignment.topRight,
          child:
          WeekCountdown()
      ),
    )

      );
  }

  void _onCallEnd(BuildContext context) {
    //Navigator.pop(context);
    Navigator.of(context)
        .push(new MaterialPageRoute(builder: (BuildContext context) => Home()));
  }

  void _onToggleMute() {
    setState(() {
      muted = !muted;
    });
    AgoraRtcEngine.muteLocalAudioStream(muted);
  }

  void _onSwitchCamera() {
    AgoraRtcEngine.switchCamera();
  }

  Timer _timer;
  int _start = 900;

  void startTimer() {
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(
      oneSec,
          (Timer timer) => setState(
            () {
          if (_start < 1) {
            timer.cancel();
          } else {
            _start = _start - 1;
          }
        },
      ),
    );
  }

  void showAlert() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            //title: Text(),
            content: Text(
                "Apakah anda yakin untuk keluar dari video konsultasi ini ?",
                style: TextStyle(fontFamily: 'VarelaRound')),
            actions: [
              new FlatButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(new MaterialPageRoute(
                        builder: (BuildContext context) => Home()));
                  },
                  child:
                  Text("Iya", style: TextStyle(fontFamily: 'VarelaRound')))
            ],
          );
        });
  }



  void showAlert2() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            //title: Text(),
            content: Text(
                "Apakah anda yakin untuk mengakhiri konsultasi ini ?",
                style: TextStyle(fontFamily: 'VarelaRound')),
            actions: [
              new FlatButton(
                  onPressed: () {

                  },
                  child:
                  Text("Iya", style: TextStyle(fontFamily: 'VarelaRound')))
            ],
          );
        });
  }



  Future<bool> _onWillPop() async {
    //Toast.show("Toast plugin app", context, duration: Toast.LENGTH_SHORT, gravity:  Toast.BOTTOM);
    showAlert();
  }

  @override
  Widget build(BuildContext context) {
    return new WillPopScope(
        onWillPop: _onWillPop,
        child: Scaffold(
          backgroundColor: Colors.white,
          body: Center(
            child: Stack(
              children: <Widget>[
                /* Container(
                   alignment: Alignment.topRight,
                    child: Padding(
                        padding: const EdgeInsets.all(60.0),
                        child: Text("$_start" + " left",
                            style: TextStyle(
                                fontFamily: 'VarelaRound',
                                fontSize: 23,
                                color: Colors.blueAccent)))),*/
                _viewRows(),
                _panel(),
                _toolbar(),
              ],
            ),
          ),
        ));
  }
}



class WeekCountdown extends StatefulWidget {
  String ID;
  @override
  //State<StatefulWidget> createState() => _WeekCountdownState(this.ID);
  _WeekCountdownState createState() => new _WeekCountdownState();

}

class _WeekCountdownState extends State<WeekCountdown> {
  Timer _timer;
  DateTime _currentTime;
  String getPhone;
  int getVal;
  final _tokenVal = TextEditingController();

  @override
  void initState() {
    super.initState();
    _currentTime = DateTime.now();
    _timer = Timer.periodic(Duration(seconds: 1), _onTimeChange);
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _onTimeChange(Timer timer) {
    setState(() {
      _currentTime = DateTime.now();
    });
  }

  @override
  Widget build(BuildContext context) {
    final startOfNextWeek = calculateStartOfNextWeek(_currentTime);
    final remaining = startOfNextWeek.difference(_currentTime);

    final days = remaining.inDays;
    final hours = remaining.inHours - remaining.inDays * 24;
    final minutes = remaining.inMinutes - remaining.inHours * 60;
    final seconds = remaining.inSeconds - remaining.inMinutes * 60;

    final formattedRemaining = '$hours : $minutes : $seconds';

    return Text(formattedRemaining, style: TextStyle(color: Colors.white,fontSize: 24),);
  }
}

DateTime calculateStartOfNextWeek(DateTime time) {
  final daysUntilNextWeek = 8 - time.weekday;
  return DateTime(2020, 10, 12 , 18 , 00);
}
