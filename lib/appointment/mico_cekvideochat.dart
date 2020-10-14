import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:intl/intl.dart';
import 'package:mico_doktornew/appointment/mico_videoroom.dart';
import 'package:mico_doktornew/helper/session_login.dart';
import 'package:mico_doktornew/mico_login.dart';
import 'package:toast/toast.dart';
import 'package:getwidget/getwidget.dart';

import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:flutter/services.dart';


class CekVideoChat extends StatefulWidget {
  final String appKode;
  const CekVideoChat(this.appKode);
  @override
  _CekVideoChatState createState() =>
      _CekVideoChatState();
//_DokterSearchPageState createState() => _DokterSearchPageState();
}

class _CekVideoChatState extends State<CekVideoChat> {

  String getAcc = "";
  String getMessage = "";
  int setMessage = 0;
  String formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  String formattedTime = DateFormat('kk:mm').format(DateTime.now());
  String formattedJam = DateFormat('kk').format(DateTime.now());
  String formattedMenit = DateFormat('mm').format(DateTime.now());
  void showToast(String msg, {int duration, int gravity}) {
    Toast.show(msg, context, duration: duration, gravity: gravity);
  }


  _session() async {
    int value = await Session.getValue();
    getAcc = await Session.getPhone();
    if (value != 1) {
      Navigator.of(context).push(new MaterialPageRoute(
          builder: (BuildContext context) => Login()));
    }
  }

  String tahun, bulan, hari, jam, menit = "0";
  String fulldate, fulljam = "...";
   _getVideoDetail() async {
    final response = await http.get(
        "https://duakata-dev.com/miracle/api_script.php?do=getdata_videodetailuser&id="+widget.appKode);
    Map data = jsonDecode(response.body);
    setState(() {
      tahun = data["a"].toString();
      bulan = data["b"].toString();
      hari = data["c"].toString();
      jam = data["d"].toString();
      menit = data["e"].toString();
      fulldate = tahun+"-"+bulan+"-"+hari;
      fulljam = jam+":"+menit;
    });
  }

   _cekroom() async {
      if (formattedDate == fulldate) {
          if (int.parse(formattedJam) == int.parse(jam) || int.parse(formattedJam) > int.parse(jam)) {
            if (int.parse(formattedMenit) == int.parse(menit) || int.parse(formattedMenit) > int.parse(menit)) {
              setState(() {
                Navigator.of(context)
                    .pushReplacement(new MaterialPageRoute(builder: (BuildContext context) => VideoChatHome(widget.appKode)));
              });
            } else {
              setMessage = 2;
            }
          } else{
            setState(() {
              setMessage = 2;
            });
          }
      } else {
        setState(() {
          setMessage = 2;
        });
      }

  }


  @override
  void initState() {
    super.initState();
    _session();
    _getVideoDetail();
    startSplashScreen();
  }

  startSplashScreen() async {
    var duration = const Duration(seconds: 3);
    return Timer(duration, () {
      _cekroom();
    });
  }


  Future<bool> _onWillPop() async {
    //Toast.show("Toast plugin app", context, duration: Toast.LENGTH_SHORT, gravity:  Toast.BOTTOM);
  }

  @override
  Widget build(BuildContext context) {
    return new WillPopScope(
        onWillPop: _onWillPop,
        child: Scaffold(
            body: Container(
                height: double.infinity,
                width: double.infinity,
                child:

                setMessage == 0 ?
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                        width: 50, height: 50, child: CircularProgressIndicator()),
                    Padding(padding: const EdgeInsets.all(25.0)),
                    Text(
                      "Memeriksa appointment anda...",
                      style: TextStyle(fontFamily: 'VarelaRound', fontSize: 13),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top:2),
                      child:
                      Text(
                        "Mohon menunggu sebentar",
                        style: TextStyle(fontFamily: 'VarelaRound', fontSize: 13),
                      ),
                    )
                  ],
                )

                    : setMessage == 2 ?
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Mohon Maaf",
                      style: TextStyle(fontFamily: 'VarelaRound', fontSize: 25, fontWeight: FontWeight.bold),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top:20),
                      child:
                      Padding (
                          padding: const EdgeInsets.only(left: 25,right: 25,top: 5),
                          child :
                          Text(
                            "Jadwal appointment anda belum dimulai.",
                            style: TextStyle(fontFamily: 'VarelaRound', fontSize: 16),textAlign: TextAlign.center,
                          )
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top:2),
                      child:
                      Padding (
                          padding: const EdgeInsets.only(left: 25,right: 25,top: 5),
                          child :
                          Text(
                            "Appointment anda dimulai pada : ",
                            style: TextStyle(fontFamily: 'VarelaRound', fontSize: 16),textAlign: TextAlign.center,
                          )
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top:2),
                      child:
                      Padding (
                          padding: const EdgeInsets.only(left: 25,right: 25,top: 5),
                          child :
                          Text(
                           fulldate+ " | "+fulljam,
                            style: TextStyle(fontFamily: 'VarelaRound', fontSize: 16,fontWeight: FontWeight.bold),textAlign: TextAlign.center,
                          )
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top:10),
                      child:   RaisedButton(
                        color:  HexColor("#075e55"),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0),
                          //side: BorderSide(color: Colors.red, width: 2.0)
                        ),
                        child: Text(
                          "Kembali",
                          style: TextStyle(
                              fontFamily: 'VarelaRound',
                              fontSize: 14,
                              color: Colors.white
                          ),
                        ),
                        onPressed: (){
                          Navigator.pop(context);
                        },
                      ),
                    )
                  ],
                )

                    :
                Text("")
            )));
  }
}
