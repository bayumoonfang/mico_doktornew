import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/components/toast/gf_toast.dart';
import 'package:hexcolor/hexcolor.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:mico_doktornew/mico_loginverifikasi.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:toast/toast.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => new _LoginState();

}


class _LoginState extends State<Login> {
  //LoginStatus _loginStatus = LoginStatus.notSignIn;
  String email, phone;
  final _key = new GlobalKey<FormState>();
  final _phonecontrol = TextEditingController();
  final _emailcontroller = TextEditingController();
  String getMessage, getTextToast;
  void showToast(String msg, {int duration, int gravity}) {
    Toast.show(msg, context, duration: duration, gravity: gravity);
  }

  void verifikasi() async {
    if (_phonecontrol.text.isEmpty && _emailcontroller.text.isEmpty) {
      showToast("Form tidak boleh kosong", gravity: Toast.CENTER, duration: Toast.LENGTH_LONG);
      return;
    }

    if (_emailcontroller.text.isEmpty) {
      showToast("Email tidak boleh kosong", gravity: Toast.CENTER, duration: Toast.LENGTH_LONG);
      return;
    }

    if (_phonecontrol.text.isEmpty) {
      showToast("Telpon tidak boleh kosong", gravity: Toast.CENTER, duration: Toast.LENGTH_LONG);
      return;
    }
    final response = await http.post(
        "https://duakata-dev.com/miracle/api_script.php?do=act_gettokendoktor",
        body: {"phone": _phonecontrol.text.toString(), "email": _emailcontroller.text.toString()});
    Map showdata = jsonDecode(response.body);
    setState(() {
      getMessage = showdata["message"].toString();
      if (getMessage == '1') {
        showToast("Data anda tidak ditemukan", gravity: Toast.CENTER, duration: Toast.LENGTH_LONG);
        return;
      } else{
        Navigator.of(context).push(
            new MaterialPageRoute(
                builder: (BuildContext context) => VerifikasiLogin(_phonecontrol.text.toString(), _emailcontroller.text.toString())));
        return;
      }
    });
    //myFocusNode.requestFocus()}
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body:
        new Container(
          width: double.infinity,
          color: Colors.white,
          padding: const EdgeInsets.only(top: 70.0),
          child :
          Padding(
            padding: const EdgeInsets.only(left: 20.0,right: 30.0),
            child :
            Column(
              children: <Widget> [
                Align(
                    alignment: Alignment.centerLeft,
                    child :
                    Text("Masukkan nomor telpon dan email untuk login ke akun anda : ",textAlign: TextAlign.left,
                        style: TextStyle(
                            fontFamily: 'VarelaRound',fontSize: 14))),

                Padding(
                    padding: const EdgeInsets.only(top: 10.0)),

                TextFormField(
                  style: TextStyle(
                      fontFamily: 'VarelaRound', fontSize: 18),
                  validator: (e) {
                    if (e.isEmpty) {
                      return "Please insert phone number";
                    }
                  },
                  controller: _phonecontrol,
                  maxLength: 13,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: "Phone Number",
                  ),
                ),
                TextFormField(
                  style: TextStyle(
                      fontFamily: 'VarelaRound', fontSize: 18),
                  validator: (e) {
                    if (e.isEmpty) {
                      return "Please insert email";
                    }
                  },
                  //validator: _validateEmail,
                  controller: _emailcontroller,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: "Email",
                  ),
                )

                ,
                Expanded(
                  child: Align(
                      alignment: Alignment.bottomCenter,
                      child: ListTile(
                        title: Text("Dengan login ke aplikasi, saya akan menerima Syarat dan Ketentuan Pengguna yang berlaku di aplikasi mico ",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontFamily: 'VarelaRound', fontSize: 12)),
                        subtitle:
                        Padding (
                            padding: const EdgeInsets.only(top:15.0,bottom: 15.0),
                            child :
                            RaisedButton(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5.0),
                                ),
                                color: Hexcolor("#8cc63e"),
                                child: Text(
                                  "Selanjutnya",
                                  style: TextStyle(
                                      fontFamily: 'VarelaRound',
                                      fontSize: 14.5,
                                      color: Colors.white
                                  ),
                                ),
                                onPressed: () {
                                  verifikasi();
                                }
                            )
                        ),
                      )
                  ),
                )

              ],
            ),
          ),

        )

    );

  }

}