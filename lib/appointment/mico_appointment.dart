import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hexcolor/hexcolor.dart';

import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:getwidget/getwidget.dart';
import 'package:mico_doktornew/appointment/get_appointment.dart';
import 'package:mico_doktornew/mico_historytransaksi.dart';
import 'package:mico_doktornew/mico_home.dart';


class AppointmentList extends StatefulWidget {
  final String getPhone;
  const AppointmentList(this.getPhone);
  @override
  _AppointmentListState createState() => new _AppointmentListState(getPhoneState: this.getPhone);

}


class _AppointmentListState extends State<AppointmentList> with SingleTickerProviderStateMixin {
  TabController controller;
  String getAcc, getPhoneState;
  _AppointmentListState({this.getPhoneState});




  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop() async {

  }
  String countmessage = '0';
  String countapp = "0";

  _getCountMessage() async {
    final response = await http.get(
        "https://duakata-dev.com/miracle/api_script.php?do=getdata_countmessage&id="+getPhoneState);
    Map data = jsonDecode(response.body);
    setState(() {
      countmessage = data["a"].toString();
    });
  }

  _getCountApp() async {
    final response = await http.get(
        "https://duakata-dev.com/miracle/api_script.php?do=getdata_countappdoctor&id="+getPhoneState);
    Map data2 = jsonDecode(response.body);
    setState(() {
      countapp = data2["a"].toString();
    });
  }

  void _loaddata() async {
    await _getCountMessage();
    await _getCountApp();
  }

  @override
  void initState() {
    super.initState();
    controller = TabController(vsync: this, length: 1);
    _loaddata();//LENGTH = TOTAL TAB YANG AKAN DIBUAT
  }




  @override
  Widget build(BuildContext context) {
    return new WillPopScope(
        onWillPop: _onWillPop,
        child:  Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: HexColor("#075e55"),
            leading: Icon(Icons.clear,color: HexColor("#075e55"),),
            title: new Text("Appointment",style: TextStyle(color : Colors.white,fontFamily: 'VarelaRound',fontSize: 18),),
            elevation: 0.0,
            centerTitle: true,
          ),
          body:
          TabBarView(
            controller: controller,
            children: <Widget>[
              GetAppointment(getPhoneState),
            ],
          ),
          bottomNavigationBar: _bottomNavigationBar(),
        ));

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
      currentIndex: 1,
      selectedItemColor: HexColor("#628b2c"),
    );
  }

  _onTap(int tabIndex) {
    switch (tabIndex) {
      case 0:
      // _navigatorKey.currentState.pushReplacementNamed("Home");
        Navigator.of(context).pushReplacement(
            new MaterialPageRoute(
                builder: (BuildContext context) => Home()));
        break;
      case 1:
        Navigator.of(context).pushReplacement(
            new MaterialPageRoute(
                builder: (BuildContext context) => AppointmentList(getPhoneState)));
        break;
      case 2:
        Navigator.of(context).pushReplacement(
            new MaterialPageRoute(
                builder: (BuildContext context) => HistoryTransaksi(getPhoneState)));
        break;

    }
    setState(() {
      _currentTabIndex = tabIndex;
    });
  }

}