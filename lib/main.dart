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
    return Options(headers: {
      HttpHeaders.authorizationHeader: "Bearer ${_token['auth_token']}",
      HttpHeaders.contentTypeHeader: "application/json"
    });
  }

  MyApp(var token) {
    _token = token;
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'RaaT',
      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
      ),
      home: H(),
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
            appBar: PreferredSize(
                preferredSize: Size.fromHeight(50.0),
                child: AppBar(
                    bottom: TabBar(
                        tabs: [Tab(text: "Reader"), Tab(text: "Editor")]))),
            body: TabBarView(children: [R(false), R(true)])));
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
  TextEditingController c1 = TextEditingController();

  String s;
  List<dynamic> j = List<dynamic>();
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
        return DropdownMenuItem<String>(
            value: map["id"].toString(),
            child: Text(map["receiverAddresses"] + " " + map["id"].toString()));
      }).toList();
    else
      return j.map((dynamic map) {
        return DropdownMenuItem<String>(
            value: map["id"].toString(),
            child: Text(
              map["id"].toString(),
            ));
      }).toList();
  }

  Widget r1(String bn){
    return  Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
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
                          if(e) {

                          s = v;
                          for (Map m in j) {
                            if (m["id"] == int.parse(v)) {
                              c.text = m['textContent'];
                            }
                          }
                          }else
                          {
                          s = v;
                          Dio()
                              .get(gUrl + "main/reader/" + s,
                                  options: MyApp.o())
                              .then((r) {
                                if(mounted){
                            setState(() {
                              t = r.data == null ? "" : r.data;
                              tl = t.split(" ");
                              p = List<bool>();
                              for (int i = 0; i < tl.length; i++) p.add(false);
                            });
                          }
                          }
                          );
                          }
                        });
                      }
                    },
                    items: buildList()),
              ),
              Container(
                margin: EdgeInsets.only(left: 5),
                child: RaisedButton(
                  color: Colors.blue,
                  child: Text(
                    bn,
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () {
                    Dio()
                          .post(gUrl + "second",
                              data: jsonEncode(getText()), options: MyApp.o())
                          .then(
                        (r) {
                          setState(() {
                            Scaffold.of(context).showSnackBar(new SnackBar(
                                content: new Text(r.data),
                              ));
                            Dio().get(gUrl + "main/readers", options: MyApp.o()).then((r) {
                            setState(() {
                              j = r.data;
                              t = "";
                              tl = t.split(" ");
                              p = List<bool>();
                              for (int i = 0; i < tl.length; i++) p.add(false);
                          });
                        },
                                             
                      );
                          
                    }
                   ); });
                  }
                ),
              ),
            ],
          );
  }

  Widget r2(String bn) {
    return Row(
            children: <Widget>[
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.only(bottom: 9),
                    border: UnderlineInputBorder(),
                  ),
                  controller: c1,
                ),
              ),
              Container(
                margin: EdgeInsets.only(left: 5),
                child: RaisedButton(
                    color: Colors.deepOrange,
                    child: Text(
                      bn,
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () {

                      String text=c.text;
                    Dio().post(gUrl + "main/text-create",
                        data: {"textContent": text, "receiverAddresses":c1.text} , options: MyApp.o()).then((r) {
                      if(mounted){
                        setState(() {
                              c.text="";
                              c1.text="";
                              Scaffold.of(context).showSnackBar(new SnackBar(
                                content: new Text("Text sent!"),
                              ));
                            });
                      }
                      });
                        
                    }),
              ),
            ],
          );
  }

Widget r3(){
  return Container(
            child: TextField(
              onTap: () {
                setState(() {});
              },
              decoration: const InputDecoration(
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.deepOrange, width: 0.5),
                ),
                hintText: 'Please enter text...',
              ),
              keyboardType: TextInputType.multiline,
              maxLines: null,
              controller: c,
            ),
          );
}


  @override
  Widget build(BuildContext context) {
    if (e)
      return ListView(
        children: <Widget>[
          r1('New'),
          r2('Send'),
          r3()
        ],
      );
    else
      return ListView(
        children: <Widget>[
          r1('Commit'),
          Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.deepOrange, width: 2.0),
                borderRadius: BorderRadius.circular(3),
              ),
              padding: EdgeInsets.all(16),
              child: buildTextForReading()),
        ],
      );
  }

  List<Widget> wl = List<Widget>();
  List<String> tl = List<String>();
  List<bool> p = List<bool>();
  String t = "";
  String sc;

  String getText() {
    String retval="";
    for(int i=0;i<tl.length;i++)
    {
        if(p[i]) retval+="<s>"+tl[i]+"</s>";
        else retval+=tl[i];
        retval+=" ";
    }
    return retval;
  }

  Widget buildTextForReading() {
    wl = List<Widget>();
    for (int i = 0; i < tl.length; i++) {
      var text = Text(
        tl[i],
        style: p[i]
            ? TextStyle(
                decoration: TextDecoration.lineThrough, color: Colors.purple)
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
