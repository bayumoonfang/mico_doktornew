


import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:getwidget/components/badge/gf_badge.dart';
import 'package:getwidget/components/badge/gf_icon_badge.dart';
import 'package:getwidget/getwidget.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:mico_doktornew/appointment/mico_appointment.dart';
import 'package:mico_doktornew/helper/checkconnection.dart';
import 'package:mico_doktornew/helper/session_login.dart';
import 'package:mico_doktornew/mico_historytransaksi.dart';
import 'package:mico_doktornew/mico_loginstart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
class Home extends StatefulWidget{

  _HomeState createState() => new _HomeState();
}

enum LoginStatus { notSignIn, signIn }

class _HomeState extends State<Home> {
  List<Container> myList = new List();
  void showToast(String msg, {int duration, int gravity}) {
    Toast.show(msg, context, duration: duration, gravity: gravity);
  }

  String getEmail, getPhone, getBasedLogin;
  _session() async {
    int value = await Session.getValue();
    getEmail = await Session.getEmail();
    getPhone = await Session.getPhone();
    getBasedLogin = await Session.getBasedLogin();
    if (value != 1) {
      Navigator.of(context).pushReplacement(new MaterialPageRoute(
          builder: (BuildContext context) => LoginStart()));
    }
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


  String countmessage = '0';
  String countapp = "0";

  _getCountMessage() async {
    final response = await http.get(
        "https://duakata-dev.com/miracle/api_script.php?do=getdata_countmessage&id="+getPhone);
    Map data = jsonDecode(response.body);
    setState(() {
      countmessage = data["a"].toString();
    });
  }

  _getCountApp() async {
    final response = await http.get(
        "https://duakata-dev.com/miracle/api_script.php?do=getdata_countappdoctor&id="+getPhone);
    Map data2 = jsonDecode(response.body);
    setState(() {
      countapp = data2["a"].toString();
    });
  }


  void _loaddata() async {
    await  _connect();
    await _session();
    await _getCountApp();
    await _getCountMessage();
  }


  @override
  void initState() {
    super.initState();
    _loaddata();
  }

  signOut() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      preferences.setInt("value", null);
      preferences.setString("phone", null);
      preferences.setString("email", null);
      preferences.setInt("idcustomer", null);
      preferences.setInt("accnumber", null);
      preferences.commit();
      Navigator.of(context).pushReplacement(new MaterialPageRoute(
          builder: (BuildContext context) => LoginStart()));
    });
  }


  @override
  Widget build(BuildContext context) {
        return Scaffold(
          appBar:  new AppBar(
            backgroundColor: Hexcolor("#075e55"),
            leading: Builder(
              builder: (context) => IconButton(
                icon: new Icon(Icons.menu),
                color: Colors.white,
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
            ),
            title: new Text(
              "Miracle Aesthetic Clinic",
              style: new TextStyle(
                  fontFamily: 'VarelaRound', fontSize: 16, color: Colors.white),
            ),
            actions: [

            ],
          ),

          bottomNavigationBar: _bottomNavigationBar(),

        );
  }


  int _currentTabIndex = 0;
  Widget _bottomNavigationBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      items: [

        BottomNavigationBarItem(
            icon: FaIcon(
              FontAwesomeIcons.home,
              size: 22,
            ),
            title: Text("Home",
                style: TextStyle(
                  fontFamily: 'VarelaRound',
                ))),



        BottomNavigationBarItem(
          icon:   countapp == '0' ?
          FaIcon(
            FontAwesomeIcons.calendarCheck,
            size: 22,
          )
              :
          GFIconBadge(
              child:FaIcon(
                FontAwesomeIcons.calendarCheck,
                size: 22,
              ),
              counterChild: GFBadge(
                color: Colors.redAccent,
                size: 16,
                shape:
                GFBadgeShape.circle,
              )
          ),
          title: Text("Appointment",
              style: TextStyle(
                fontFamily: 'VarelaRound',
              )),
        ),

        BottomNavigationBarItem(
          icon: FaIcon(
            FontAwesomeIcons.fileAlt,
            size: 22,
          ),
          title: Text("History",
              style: TextStyle(
                fontFamily: 'VarelaRound',
              )),
        ),

        BottomNavigationBarItem(
          icon: FaIcon(
            FontAwesomeIcons.userCircle,
            size: 22,
          ),
          title: Text("Account",
              style: TextStyle(
                fontFamily: 'VarelaRound',
              )),
        )

      ],
      onTap: _onTap,
      currentIndex: _currentTabIndex,
      selectedItemColor: Hexcolor("#628b2c"),
    );
  }

  _onTap(int tabIndex) {
    switch (tabIndex) {
      case 0:
          Navigator.of(context).pushReplacement(
          new MaterialPageRoute(
          builder: (BuildContext context) => Home()));
          break;
      case 1:
          Navigator.of(context).pushReplacement(
          new MaterialPageRoute(
          builder: (BuildContext context) => AppointmentList(getPhone.toString())));
          break;
      case 2:
        Navigator.of(context).pushReplacement(
            new MaterialPageRoute(
                builder: (BuildContext context) => HistoryTransaksi(getPhone.toString())));
        break;
  }
    setState(() {
      _currentTabIndex = tabIndex;
    });
  }

  Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      default:
        return MaterialPageRoute(
            builder: (context) => Container(
                child: Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: GridView.count(
                      crossAxisCount: 2,
                      children: myList,
                    ))));
    }
  }



}