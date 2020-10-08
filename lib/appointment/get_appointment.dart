import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:mico_doktornew/appointment/mico_detailapp.dart';
import 'package:mico_doktornew/appointment/mico_chatroom.dart';
import 'dart:async';
import 'dart:convert';

import 'package:mico_doktornew/mico_home.dart';


class GetAppointment extends StatefulWidget {
  final String getPhone;
  const GetAppointment(this.getPhone);
  @override
  _GetAppointmentState createState() => new _GetAppointmentState(getPhoneState: this.getPhone);
}


class _GetAppointmentState extends State<GetAppointment> {
  List data;
  String getAcc, getPhoneState;
  _GetAppointmentState({this.getPhoneState});


  @override
  void initState() {
    getData();
    super.initState();
  }


  Future<List> getData() async {
    final response = await http.get(
        "https://duakata-dev.com/miracle/api_script.php?do=getdata_appointmentdoctor&id=" +
            getPhoneState);
    setState((){
      data = json.decode(response.body);
    });
  }

  Future<void> _getData() async {
    setState(() {
      getData();
    });
  }


  @override
  Widget build(BuildContext context) {
    return
      RefreshIndicator(
          onRefresh: _getData,
          child :
          Container(
              color: Hexcolor("#f5f5f5"),
              margin: EdgeInsets.all(10.0),
              child: new FutureBuilder<List>(
                  future: getData(),
                  builder : (context, snapshot) {
                    if (data == null) {
                      return Center(
                          child: Image.asset(
                            "assets/loadingq.gif",
                            width: 110.0,
                          )
                      );
                    } else {
                      return data.isEmpty
                          ?
                      Center(
                          child: new Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              new Text(
                                "Tidak ada appointment",
                                style: new TextStyle(
                                    fontFamily: 'VarelaRound', fontSize: 18),
                              ),
                            ],
                          ))
                          :
                      new ListView.builder(
                          padding: const EdgeInsets.only(top: 5.0),
                          itemCount: data == null ? 0 : data.length,
                          itemBuilder: (context, i) {
                            return
                              InkWell(
                                child : Card(
                                    child :
                                    Column(
                                        children: <Widget>[
                                          Padding(
                                              padding: const EdgeInsets.only(top: 15,left: 13,right: 10),
                                              child: Row(
                                                mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                                //mainAxisSize: MainAxisSize.max,
                                                children: <Widget>[
                                                  Text(
                                                    "Konsultasi " + data[i]["m"] + " dengan",
                                                    textAlign: TextAlign.left,
                                                    style: TextStyle(
                                                        fontFamily: 'VarelaRound',
                                                        fontSize: 14),
                                                  ),
                                                  Container(
                                                    decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.circular(5),
                                                      border: Border.all(
                                                        color:
                                                        data[i]["c"] == 'DONE' ? Hexcolor("#075e55") : Colors.red,
                                                        //                   <--- border color
                                                        width: 1.0,
                                                      ),
                                                    ),
                                                    padding: const EdgeInsets.all(5),
                                                    child:  Text(data[i]["c"] == 'ON REVIEW' ? 'Need Approval' : data[i]["c"] == 'PAID' ? 'On Going' : data[i]["c"],
                                                        style: TextStyle(
                                                            fontFamily: 'VarelaRound',
                                                            fontWeight: FontWeight.bold,
                                                            color:
                                                            data[i]["c"] == 'DECLINE' ? Colors.red : Colors.black,
                                                            fontSize: 12)),
                                                  )
                                                ],
                                              )
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(top: 10,bottom: 10),
                                            child: ListTile(
                                                title:  Align(
                                                  alignment: Alignment.centerLeft,
                                                  child: Text(
                                                    data[i]["f"],
                                                    style: TextStyle(
                                                        fontSize: 15,
                                                        fontFamily: 'VarelaRound'),
                                                  ),
                                                ),
                                                subtitle:
                                                Column(
                                                  children: [
                                                    Padding (
                                                        padding: const EdgeInsets.only(top: 2)
                                                        ,
                                                        child :
                                                        Align(
                                                          alignment: Alignment.centerLeft,
                                                          child: Text(
                                                            data[i]["g"],
                                                            style: TextStyle(
                                                                fontSize: 13,
                                                                fontFamily: 'VarelaRound'),
                                                          ),
                                                        )),
                                                    Padding (
                                                        padding: const EdgeInsets.only(top: 2),
                                                        child :
                                                        Align(
                                                          alignment: Alignment.centerLeft,
                                                          child: Text(
                                                            data[i]["k"]+ " - "+ new DateFormat.MMM().format(DateTime.parse(data[i]["l"]))
                                                                + " - "+ data[i]["i"] + " (" +data[i]["d"]+")",
                                                            style: TextStyle(
                                                                fontSize: 14,
                                                                color: Colors.black,
                                                                fontWeight: FontWeight.bold,
                                                                fontFamily: 'VarelaRound'),
                                                          ),
                                                        )),
                                                  ],
                                                )
                                            ),
                                          ),

                                        ]
                                    )
                                ),
                                onTap: () {
                                  data[i]["c"] == 'ON REVIEW'  ?
                                  Navigator.of(context).push(new MaterialPageRoute(
                                      builder: (BuildContext context) => DetailAppointment(data[i]["b"].toString())))
                                  : data[i]["c"] == 'PAID' && data[i]["m"] == 'CHAT' ?
                                  Navigator.of(context).push(new MaterialPageRoute(
                                  builder: (BuildContext context) => Chatroom(data[i]["b"].toString(), "2")))
                                  :
                                  data[i]["c"] == 'PAID' && data[i]["m"] == 'VIDEO' ?
                                      Navigator.of(context).push(new MaterialPageRoute(
                                      builder: (BuildContext context) => Chatroom(data[i]["b"].toString(), "2")))
                                      :
                                  Navigator.of(context).push(new MaterialPageRoute(
                                      builder: (BuildContext context) => Home()));
                                },
                              );
                          }
                      );
                    }
                  }
              )
          ));
  }

}

