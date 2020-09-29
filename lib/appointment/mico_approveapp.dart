





import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:intl/intl.dart';
import 'package:photo_view/photo_view.dart';
import 'package:responsive_container/responsive_container.dart';
import 'package:steps/steps.dart';
import 'package:steps_indicator/steps_indicator.dart';
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
  Future<List> getDetailInvoiced() async {
    final response = await http.get(
        "https://duakata-dev.com/miracle/api_script.php?do=getdata_invoiced&id=" +
            widget.idAppointment);
    setState(() {
      data =  json.decode(response.body);
    });
  }


  String getStatus = "...";
  _getDetail() async {
    final response = await http.get(
        "https://duakata-dev.com/miracle/api_script.php?do=getdata_statusinv&id=" +
            widget.idAppointment);
    Map data = jsonDecode(response.body);
    setState(() {
      getStatus = data["a"].toString();
    });
  }

  @override
  void initState() {
    super.initState();
    _getDetail();
  }


  @override
  Widget build(BuildContext context) {
    return new WillPopScope(
        onWillPop: _onWillPop,
        child: Scaffold(
          appBar: new AppBar(
            backgroundColor: Hexcolor("#075e55"),
            title: Text(
              "Detail Appointment",
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
            child: _datafield(),
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

                          getStatus == 'OPEN' ?
                          RaisedButton(
                            color: Hexcolor("#075e55"),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5.0),
                              //side: BorderSide(color: Colors.red)
                            ),
                            child: Text(
                              "Bayar",
                              style: TextStyle(
                                  fontFamily: 'VarelaRound',
                                  fontSize: 14,
                                  color: Colors.white
                              ),
                            ),
                            onPressed: (){

                            },
                          )

                              :

                          Opacity(
                              opacity: 0.5,
                              child :
                              OutlineButton(
                                color: Colors.red,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5.0),
                                    side: BorderSide(color: Colors.red)
                                ),
                                child: Text(
                                  "Bayar",
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

  Widget _datafield() {
    return FutureBuilder<List>(
        future: getDetailInvoiced(),
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
                          padding: const EdgeInsets.only(left: 15,top:20,right: 25),
                          child: Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            //mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                              Text(
                                "Kode Transaksi",
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    fontFamily: 'VarelaRound',
                                    fontSize: 14),
                              ),
                              Text(data[i]["a"],
                                  style: TextStyle(
                                      fontFamily: 'VarelaRound',
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14)),
                            ],
                          )
                      ),

                      Padding(
                          padding: const EdgeInsets.only(left: 15,top:10,right: 25),
                          child: Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            //mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                              Text(
                                "Biaya",
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    fontFamily: 'VarelaRound',
                                    fontSize: 14),
                              ),
                              Text("Rp "+
                                  NumberFormat.currency(locale: 'id', decimalDigits: 0, symbol: '').format(int.parse(data[i]["b"].toString())),
                                  style: TextStyle(
                                      fontFamily: 'VarelaRound',
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14)),
                            ],
                          )
                      ),

                      Padding(
                          padding: const EdgeInsets.only(left: 15,top:10,right: 25),
                          child: Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            //mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                              Text(
                                "Tanggal",
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    fontFamily: 'VarelaRound',
                                    fontSize: 14),
                              ),
                              Text(data[i]["c"],
                                  style: TextStyle(
                                      fontFamily: 'VarelaRound',
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14)),
                            ],
                          )
                      ),

                      Padding(
                          padding: const EdgeInsets.only(left: 15,top:10,right: 25),
                          child: Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            //mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                              Text(
                                "Status",
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    fontFamily: 'VarelaRound',
                                    fontSize: 14),
                              ),
                              Text(data[i]["d"] == 'OPEN' ? 'Belum Dibayar' : 'Dibayar',
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
        }
    );
  }



}



