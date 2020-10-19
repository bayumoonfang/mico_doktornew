





import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:intl/intl.dart';
import 'package:mico_doktornew/appointment/mico_cekroom.dart';
import 'package:mico_doktornew/appointment/mico_chatroom.dart';
import 'package:mico_doktornew/appointment/mico_videoroom.dart';
import 'package:mico_doktornew/mico_home.dart';
import 'package:responsive_container/responsive_container.dart';
import 'package:http/http.dart' as http;
import 'package:toast/toast.dart';

class DetailAppointment extends StatefulWidget {
  final String idAppointment;
  const DetailAppointment(this.idAppointment);
  @override
  _DetailAppointmentState createState() => new _DetailAppointmentState();
}



class _DetailAppointmentState extends State<DetailAppointment> {

  List data;
  Future<bool> _onWillPop() async {
    Navigator.pop(context);
  }

  void showToast(String msg, {int duration, int gravity}) {
    Toast.show(msg, context, duration: duration, gravity: gravity);
  }


  Future<List> getDetailAppDokter() async {
    final response = await http.get(
        "https://duakata-dev.com/miracle/api_script.php?do=getdata_detailappdokter&id=" +
            widget.idAppointment);
    setState(() {
      data =  json.decode(response.body);
    });
  }


  String getStatus = "...";
  _getDetail() async {
    final response = await http.get(
        "https://duakata-dev.com/miracle/api_script.php?do=getdata_statusappdokter&id=" +
            widget.idAppointment);
    Map data = jsonDecode(response.body);
    setState(() {
      getStatus = data["a"].toString();
    });
  }

  String getMessage2 = "";
  _doTerimaAppointment() async {
    final response = await http.post(
        "https://duakata-dev.com/miracle/api_script.php?do=act_accappointmentdokter",
        body: {"appkode": widget.idAppointment});
    Map data = jsonDecode(response.body);
    setState(() {
      String getMessage = data["message"].toString();
      String getRoom = data["room"].toString();
      String getJenis = data["type"].toString();
      if (getMessage == '1') {
        showToast("Maaf Room Konsultasi penuh , silahkan coba beberapa saat lagi..", gravity: Toast.CENTER, duration: Toast.LENGTH_LONG);
        return;
      } else if (getMessage == '2') {
        setState(() {
          _getDetail();
          showToast("Appointment berhasil anda terima , silahkan menunggu untuk pasien membayar biaya konsultasi ini", gravity: Toast.CENTER, duration: Toast.LENGTH_LONG);
          return;
        });
      }else if (getMessage == '3') {
        Navigator.of(context).pushReplacement(
            new MaterialPageRoute(
                builder: (BuildContext context) => CekRoomKonsultasi(widget.idAppointment, "2")));
      }
    });
  }


  _doTolakAppointment() async {
    final response = await http.post(
        "https://duakata-dev.com/miracle/api_script.php?do=act_declineappointmentdokter",
        body: {"appkode": widget.idAppointment});
    Map data = jsonDecode(response.body);
    setState(() {
      String getMessage3 = data["message"].toString();
      if (getMessage3 == '1') {
        Navigator.of(context).pushReplacement(
            new MaterialPageRoute(
                builder: (BuildContext context) => Home()));
      }
    });
  }


  askTerima() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            //title: Text(),
            content: Text(
                "Berikan respon untuk permintaan appointment baru anda..",
                style: TextStyle(fontFamily: 'VarelaRound', fontSize: 14)),
            actions: [
              new FlatButton(
                  onPressed: () {
                    _doTerimaAppointment();
                    Navigator.pop(context);
                  },
                  child:
                  Text("Accept", style: TextStyle(fontFamily: 'VarelaRound',
                      fontWeight: FontWeight.bold,
                      fontSize: 16))),
              new FlatButton(
                  onPressed: () {
                    _doTolakAppointment();
                  },
                  child:
                  Text("Decline", style: TextStyle(fontFamily: 'VarelaRound',
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                      fontSize: 16))),
              new FlatButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child:
                  Text("Close", style: TextStyle(fontFamily: 'VarelaRound',
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontSize: 16)))
            ],
          );
        });
  }




  @override
  void initState() {
    super.initState();
    _getDetail();
  }


  Widget _datafield() {
    return
      FutureBuilder<List>(
        future: getDetailAppDokter(),
        builder: (context, snapshot) {
          if (data == null) {
            return Center(
                child: Image.asset(
                  "assets/loadingq.gif",
                  width: 100.0,
                )
            );
          } else {
            return ListView.builder(
                itemCount: data == null ? 0 : data.length,
                itemBuilder: (context, i) {
                          return Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 15,left: 15),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text("Appoint Kode", style: TextStyle(fontFamily: 'VarelaRound',fontSize: 11)),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 5,left: 15),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(widget.idAppointment, style: TextStyle(fontFamily: 'VarelaRound',fontSize: 15,fontWeight: FontWeight.bold)),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 10),
                                  child: Divider(height: 5,),
                                ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 15,top: 20),
                                      child:
                                      Align(
                                        alignment: Alignment.centerLeft,
                                          child : Text(
                                        "Detail  Appointment",
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                            fontFamily: 'VarelaRound',
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15),
                                      )),
                                    ),
                                    Padding(
                                    padding: const EdgeInsets.only(left: 15,top:20,right: 15),
                                    child: Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                      //mainAxisSize: MainAxisSize.max,
                                      children: <Widget>[
                                        Text(
                                          "Jenis Konsultasi",
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                              fontFamily: 'VarelaRound',
                                              fontSize: 14),
                                        ),
                                        Text("Konsultasi "+data[i]["a"],
                                            style: TextStyle(
                                                fontFamily: 'VarelaRound',
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14)),
                                      ],
                                    )
                                ),

                                Padding(
                                    padding: const EdgeInsets.only(left: 15,top:10,right: 15),
                                    child: Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                      //mainAxisSize: MainAxisSize.max,
                                      children: <Widget>[
                                        Text(
                                          "Hari Konsultasi",
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                              fontFamily: 'VarelaRound',
                                              fontSize: 14),
                                        ),
                                        Text(new DateFormat.EEEE().format(
                                            DateTime.parse(data[i]['b'])),
                                            style: TextStyle(
                                                fontFamily: 'VarelaRound',
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14)),
                                      ],
                                    )
                                ),

                                Padding(
                                    padding: const EdgeInsets.only(left: 15,top:10,right: 15),
                                    child: Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                      //mainAxisSize: MainAxisSize.max,
                                      children: <Widget>[
                                        Text(
                                          "Tanggal Konsultasi",
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                              fontFamily: 'VarelaRound',
                                              fontSize: 14),
                                        ),
                                        Text(
                                            data[i]["k"]+ " - "+  new DateFormat.MMMM().format(DateTime.parse(data[i]["b"])) + " - "+data[i]["i"],
                                            style: TextStyle(
                                                fontFamily: 'VarelaRound',
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14)),
                                      ],
                                    )
                                ),

                                Padding(
                                    padding: const EdgeInsets.only(left: 15,top:10,right: 15),
                                    child: Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                      //mainAxisSize: MainAxisSize.max,
                                      children: <Widget>[
                                        Text(
                                          "Jam Konsultasi",
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                              fontFamily: 'VarelaRound',
                                              fontSize: 14),
                                        ),
                                        Text(
                                            data[i]["c"],
                                            style: TextStyle(
                                                fontFamily: 'VarelaRound',
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14)),
                                      ],
                                    )
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 20,left: 15,right: 15),
                                  child: Divider(height: 5,),
                                ),

                                Padding(
                                  padding: const EdgeInsets.only(left: 15,top: 20),
                                  child:
                                  Align(
                                      alignment: Alignment.centerLeft,
                                      child : Text(
                                        "Detail Pasien",
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                            fontFamily: 'VarelaRound',
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15),
                                      )),
                                ),

                                Padding(
                                    padding: const EdgeInsets.only(left: 15,top:20,right: 15),
                                    child: Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                      //mainAxisSize: MainAxisSize.max,
                                      children: <Widget>[
                                        Text(
                                          "ID Pasien",
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                              fontFamily: 'VarelaRound',
                                              fontSize: 14),
                                        ),
                                        Text(data[i]["g"],
                                            style: TextStyle(
                                                fontFamily: 'VarelaRound',
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14)),
                                      ],
                                    )
                                ),


                                Padding(
                                    padding: const EdgeInsets.only(left: 15,top:10,right: 15),
                                    child: Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                      //mainAxisSize: MainAxisSize.max,
                                      children: <Widget>[
                                        Text(
                                          "Nama Pasien",
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                              fontFamily: 'VarelaRound',
                                              fontSize: 14),
                                        ),
                                        Text(data[i]["d"],
                                            style: TextStyle(
                                                fontFamily: 'VarelaRound',
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14)),
                                      ],
                                    )
                                ),

                                Padding(
                                    padding: const EdgeInsets.only(left: 15,top:10,right: 15),
                                    child: Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                      //mainAxisSize: MainAxisSize.max,
                                      children: <Widget>[
                                        Text(
                                          "Kota Pasien",
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                              fontFamily: 'VarelaRound',
                                              fontSize: 14),
                                        ),
                                        Text(data[i]["f"],
                                            style: TextStyle(
                                                fontFamily: 'VarelaRound',
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14)),
                                      ],
                                    )
                                ),

                              ],
                          );

                }
              );
          }
        });

  }

  @override
  Widget build(BuildContext context) {
    return new WillPopScope(
        onWillPop: _onWillPop,
        child: Scaffold(
          appBar: new AppBar(
            backgroundColor: HexColor("#075e55"),
            title: Text(
              "Detail Request Appointment",
              style: TextStyle(
                  color: Colors.white, fontFamily: 'VarelaRound', fontSize: 16),
            ),
            leading: Builder(
              builder: (context) => IconButton(
                  icon: new Icon(Icons.arrow_back),
                  color: Colors.white,
                  onPressed: () => {
                    Navigator.pop(context)
                  }),
            ),
          ),
          body: ResponsiveContainer(
            heightPercent: 100,
            widthPercent: 100,
            child: _datafield()
          ),
          bottomSheet: new

          Container (
              color: Colors.white,
              child :
              Row(
                children: [
                  Expanded(
                      child: Padding(
                          padding: const EdgeInsets.only(right: 15.0, left: 20.0, bottom:10),
                          child:

                          getStatus == 'ON REVIEW' ?
                          RaisedButton(
                            color: HexColor("#075e55"),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5.0),
                              //side: BorderSide(color: Colors.red)
                            ),
                            child: Text(
                              "Berikan Respon",
                              style: TextStyle(
                                  fontFamily: 'VarelaRound',
                                  fontSize: 14,
                                  color: Colors.white
                              ),
                            ),
                            onPressed: (){
        askTerima();
        
                            },
                          )

                              :

                          Opacity(
                              opacity: 0.9,
                              child :
                              OutlineButton(
                                color: Colors.red,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5.0),
                                    side: BorderSide(color: Colors.red)
                                ),
                                child: Text(
                                  getStatus.toString() == '' ? '...' : getStatus.toString(),
                                  style: TextStyle(
                                      fontFamily: 'VarelaRound',
                                      fontSize: 14,
                                      color: Colors.black
                                  ),
                                ),
                              ))



                      ))

                ],
              )
          ),
        )
    );
  }





}



