import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';

const String gUrl = "http://raatfb-dev.us-east-2.elasticbeanstalk.com/api/";
void main() {
  final fl = FacebookLogin();
  fl.logInWithReadPermissions(['email']).then((r) {
    switch (r.status) {
      case FacebookLoginStatus.loggedIn:
        Dio().post(gUrl + "externalauth/facebook",
            data: {"accessToken": r.accessToken.token}).then((result) {
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
    return Options(headers: {
      HttpHeaders.authorizationHeader: "Bearer ${_token['auth_token']}",
      HttpHeaders.contentTypeHeader: "application/json"
    });
  }

  MyApp(var token) {
    _token = token;
  }
  @override
  Widget build(BuildContext cx) {
    return MaterialApp(
      title: 'RaaT',
      theme: ThemeData(primaryColor: Colors.deepOrange),
      home: 
        DefaultTabController(
        length: 2,
        child: 
        Scaffold(
            appBar: AppBar(
                  title: Text("RaaT"),
                    bottom: TabBar(
                        tabs: [Tab(text: "Reader"), Tab(text: "Editor")]                
                        )
                        )
                        ,
                        
            body: TabBarView(children: [R(false), R(true)] ),
            ),
          )
        )
        ;
  }
}


class R extends StatefulWidget {
  final bool e;
  R(this.e);
  @override
  State<StatefulWidget> createState() {
    return RS(this.e);
  }
}

class RS extends State<R> {
  bool e;
  RS(this.e);
  TextEditingController c = TextEditingController();
  TextEditingController c1 = TextEditingController();
  String s;
  List<dynamic> j = List<dynamic>();
  @override
  void initState() {
    if (mounted) {
      if (!e) {
        Dio().get(gUrl + "main/readers", options: MyApp.o()).then((r) {
          setState(() {
            j = r.data;
          });
        });
      }
      else
      {
        Dio().get(gUrl + "main/texts", options: MyApp.o()).then((r1) {
          setState(() {
            j = r1.data;
          });
        });
      }
    }
    super.initState();
  }

  List<DropdownMenuItem<String>> buildList() {
    if (e)
      return j.map((dynamic map) {
        return DropdownMenuItem<String>(
            value: map["id"].toString(),
            child: Text(map["receiverAddresses"] + " " + map["id"].toString()));
      }).toList();
    else
      return j.map((dynamic map) {
        return DropdownMenuItem<String>(
            value: map["id"].toString(), child: Text(map["id"].toString()));
      }).toList();
  }

  Widget r1(String bn) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <
        Widget>[
      Expanded(
          child: DropdownButton<String>(
              isExpanded: true,
              hint: Text(
                "Select",
                style: TextStyle(color: Colors.white),
              ),
              value: s,
              onChanged: (String v) {
                if (mounted) {
                  setState(() {
                    if (e) {
                      s = v;
                      for (Map m in j) {
                        if (m["id"] == int.parse(v)) {
                          c.text = m['textContent'];
                        }
                      }
                    } else {
                      s = v;
                      Dio()
                          .get(gUrl + "main/reader/" + s, options: MyApp.o())
                          .then((r) {
                        if (mounted) {
                          setState(() {
                            t = r.data == null ? "" : r.data;
                            tl = t.split(" ");
                            p = List<bool>();
                            for (int i = 0; i < tl.length; i++) p.add(false);
                          });
                        }
                      });
                    }
                  });
                }
              },
              items: buildList())),
      Container(
          margin: EdgeInsets.only(left: 5),
          child: RaisedButton(
              color: Colors.blue,
              child: Text(bn),
              onPressed: () {
              if(e)
              {
                {
                    setState(() {
                      c.text = "";
                    });
                }
              }
              else
                Dio()
                    .post(gUrl + "second",
                        data: jsonEncode(gT()), options: MyApp.o())
                    .then((r) {
                  setState(() {
                    Scaffold.of(context)
                        .showSnackBar(new SnackBar(content: new Text(r.data)));
                    Dio()
                        .get(gUrl + "main/readers", options: MyApp.o())
                        .then((r) {
                      setState(() {
                        j = r.data;
                        t = "";
                        tl = t.split(" ");
                        p = List<bool>();
                        for (int i = 0; i < tl.length; i++) p.add(false);
                      });
                    });
                  });
                });
              }))
    ]);
  }

  Widget r2(String bn) {
    return Row(children: <Widget>[
      Expanded(
          child: TextField(
              decoration: InputDecoration(
                  contentPadding: EdgeInsets.only(bottom: 9),
                  border: UnderlineInputBorder()),
              controller: c1)),
      Container(
          margin: EdgeInsets.only(left: 5),
          child: RaisedButton(
              color: Colors.deepOrange,
              child: Text(bn),
              onPressed: () {
                Dio()
                    .post(gUrl + "main/text-create",
                        data: {
                          "textContent": c.text,
                          "receiverAddresses": c1.text
                        },
                        options: MyApp.o())
                    .then((r) {
                  if (mounted) {
                    setState(() {
                      c.text = "";
                      c1.text = "";
                      Scaffold.of(context)
                          .showSnackBar(SnackBar(content: Text("Text sent!")));
                    });
                  }
                }
                );
              }
              ))
    ]);
  }

  Widget r3() {
    return Container(
        child: TextField(
            onTap: () {
              setState(() {});
            },
            decoration: InputDecoration(
                border: OutlineInputBorder(
              borderSide: BorderSide(width: 0.5),
            )),
            keyboardType: TextInputType.multiline,
            maxLines: null,
            controller: c));
  }

  @override
  Widget build(BuildContext cx) {
    if (e)
      return Container(  decoration: BoxDecoration(color: Colors.white,image: new DecorationImage(image: new AssetImage("lib/assets/back.jpg"),fit: BoxFit.contain, colorFilter: new ColorFilter.mode(Colors.black.withOpacity(0.2), BlendMode.dstATop),)),
       child: ListView( children: <Widget>[r1('New'), r2('Send'), r3()]));
    else
      return  Container( decoration: BoxDecoration(color: Colors.white,image: new DecorationImage(image: new AssetImage("lib/assets/back.jpg"),fit: BoxFit.contain,colorFilter: new ColorFilter.mode(Colors.black.withOpacity(0.2), BlendMode.dstATop),)),
       child: ListView(children: <Widget>[
        r1('Commit'),
        Container(
            decoration: BoxDecoration(
                border: Border.all(width: 2.0),
                borderRadius: BorderRadius.circular(3)),
            padding: EdgeInsets.all(16),
            child: btf())
      ]));
  }

  List<Widget> wl = List<Widget>();
  List<String> tl = List<String>();
  List<bool> p = List<bool>();
  String t = "";
  String sc;
  String gT() {
    String retval = "";
    for (int i = 0; i < tl.length; i++) {
      if (p[i])
        retval += "<s>" + tl[i] + "</s>";
      else
        retval += tl[i];
      retval += " ";
    }
    return retval;
  }

  Widget btf() {
    wl = List<Widget>();
    for (int i = 0; i < tl.length; i++) {
      var text = Text(tl[i],
          style: p[i]
              ? TextStyle(
                  decoration: TextDecoration.lineThrough, color: Colors.purple)
              : TextStyle());
      wl.add(InkWell(
          child: text,
          onDoubleTap: () {
            setState(() {
              if (mounted) {
                p[i] = !p[i];
              }
            });
          }));
      wl.add(InkWell(child: Text(" ")));
    }
    return Wrap(spacing: 1.0, runSpacing: 1.0, children: wl);
  }
}
