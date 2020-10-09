import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/components/loader/gf_loader.dart';
import 'package:getwidget/getwidget.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

import 'dart:async';
import 'dart:convert';

import 'file:///D:/PROJECT%20KANTOR/mico/lib/backup/mico_historytransaksi_BACKUP.dart';


class GetTransaksi extends StatefulWidget {
  final String getPhone;
  const GetTransaksi(this.getPhone);
  @override
  _GetTransaksiState createState() => new _GetTransaksiState(getPhoneState: this.getPhone);
}


class _GetTransaksiState extends State<GetTransaksi> {
  List data;
  String getAcc, getPhoneState;
  _GetTransaksiState({this.getPhoneState});


  @override
  void initState() {
    getData();
    super.initState();
  }


  Future<List> getData() async {
    final response = await http.get(
        "https://duakata-dev.com/miracle/api_script.php?do=getdata_appointmentdokter&id=" +
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
                                "Tidak ada Transaksi",
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
                                                    child:  Text(data[i]["c"],
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
                                                leading:         CircleAvatar(
                                                  backgroundImage: CachedNetworkImageProvider("https://duakata-dev.com/miracle/media/photo/" +
                                                      data[i]["e"],
                                                  ),
                                                  backgroundColor: Colors.white,
                                                  radius: 20,
                                                ),
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

