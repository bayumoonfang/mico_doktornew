

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class DetailScreen extends StatefulWidget {
  final String ImgFile;
  const DetailScreen(this.ImgFile);
  @override
  _DetailScreenState createState() => new _DetailScreenState(
      getImgFile: this.ImgFile);
}



class _DetailScreenState extends State<DetailScreen> {
  String getImgFile;
  _DetailScreenState({this.getImgFile});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        child: Center(
          child: Hero(
              tag: 'imagehero',
              child:
              PhotoView(
                imageProvider: NetworkImage("https://duakata-dev.com/miracle/media/imgchat/"+widget.ImgFile),
              )
            /* Image (
                    image: NetworkImage("https://duakata-dev.com/miracle/media/imgchat/"+widget.ImgFile),
                  )*/
          ),
        ),
        onTap: () {
          Navigator.pop(context);
        },
      ),
    );
  }
}