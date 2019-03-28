import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';

const String gUrl = "http://raatfb-dev.us-east-2.elasticbeanstalk.com/api/";

void main() {
  final facebookLogin = FacebookLogin();
  facebookLogin.logInWithReadPermissions(['email']).then((result) {
    switch (result.status) {
      case FacebookLoginStatus.loggedIn:
        Dio().post(gUrl + "externalauth/facebook",
            data: {"accessToken": result.accessToken.token}).then((result) {
            var token = jsonDecode(result.data);
          runApp(MyApp(token));
        });
        break;
      default:
        exit(0);
        break;
    }
  });
}

class MyApp extends StatelessWidget {

  static var _token;
  static Options o() {
    return Options(headers: {HttpHeaders.authorizationHeader: "Bearer ${_token['auth_token']}",HttpHeaders.contentTypeHeader: "application/json"}
    );
  }
  MyApp(var token){
    _token=token;
  }
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'RaaT Demo',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new H(),
    );
  }
}

class H extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return HS();
  }
}

class HS extends State<H> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          bottom: TabBar(
            tabs: [
              Tab(text: "Reader"),
              Tab(text: "Editor"),
            ],
          ),
          title: Text('RaaT Demo'),
        ),
        body: TabBarView(
          children: [R(false), R(true)],
        ),
      ),
    );
  }
}

class R extends StatefulWidget {
  final bool e;

  R(this.e);
  @override
  State<StatefulWidget> createState() {
    return _RState(this.e);
  }
}

class _RState extends State<R> {
  bool e;
  _RState(this.e);
  TextEditingController c = TextEditingController();

  String s;
  List<dynamic> j = new List<dynamic>();

  @override
  void initState() {
    if (mounted) {
      if (!e)
        Dio().get(gUrl + "main/readers", options: MyApp.o()).then((r) {
          setState(() {
            j = r.data;
          });
        });
      else
        Dio().get(gUrl + "main/texts", options: MyApp.o()).then((r1) {
          setState(() {
            j = r1.data;
          });
        });
    }
    super.initState();
  }

  List<DropdownMenuItem<String>> buildList() {
    if (e)
      return j.map((dynamic map) {
        return new DropdownMenuItem<String>(
            value: map["id"].toString(),
            child: new Text(
                map["receiverAddresses"] + " " + map["id"].toString()));
      }).toList();
    else
      return j.map((dynamic map) {
        return new DropdownMenuItem<String>(
            value: map["id"].toString(),
            child: new Text(
              map["id"].toString(),
            ));
      }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(16),
        margin: EdgeInsets.only(top: 20, bottom: 20),
        child: ListView(children: [
          Row(children: [
            DropdownButton<String>(
                hint: new Text("Select"),
                value: s,
                onChanged: (String v) {
                  if (mounted) {
                    setState(() {
                      if (!widget.e) {
                        s = v;
                        Dio()
                            .get(gUrl + "main/reader/" + s, options: MyApp.o())
                            .then((r) {
                          setState(() {
                            t = r.data == null ? "" : r.data;
                            tl = t.split(" ");
                            p = new List<bool>();
                            for (int i = 0; i < tl.length; i++) p.add(false);
                          });
                        });
                      } else {
                        s = v;
                        for (Map m in j) {
                          if (m["id"] == int.parse(v)) {
                            c.text = m['textContent'];
                          }
                        }
                      }
                    });
                  }
                },
                items: buildList()),
            RaisedButton(
                child: Text('Send'),
                onPressed: () {
                  Dio()
                      .post(gUrl + "second",
                          data: jsonEncode(getText()), options: MyApp.o())
                      .then(
                    (r) {
                      setState(() {
                        sc = r.data;
                      });
                    },
                  );
                })
          ]),
          Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.blue),
                  borderRadius: BorderRadius.all(Radius.circular(5.0))),
              child: buildTextFormField()),
        ]));
  }

  List<Widget> wl = new List<Widget>();
  List<String> tl = new List<String>();
  List<bool> p = new List<bool>();
  String t = "";
  String sc;

  String getText() {
    return t;
  }

  Widget buildTextFormField() {
    if (e)
      return TextFormField(
        decoration: const InputDecoration(
          border: InputBorder.none,
          hintText: 'Please enter text...',
        ),
        keyboardType: TextInputType.multiline,
        maxLines: null,
        controller: c,
      );
    else {
      wl = new List<Widget>();
      for (int i = 0; i < tl.length; i++) {
        var text = Text(
          tl[i],
          style: p[i]
              ? TextStyle(decoration: TextDecoration.lineThrough)
              : TextStyle(),
        );
        wl.add(InkWell(
          child: text,
          onDoubleTap: () {
            setState(() {
              if (mounted) {
                p[i] = !p[i];
              }
            });
          },
        ));
        wl.add(InkWell(child: Text(" ")));
      }
      return Wrap(spacing: 1.0, runSpacing: 1.0, children: wl);
    }
  }
}
