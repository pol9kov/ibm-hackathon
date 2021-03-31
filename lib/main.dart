
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

import 'package:graphic/graphic.dart' as graphic;
import 'package:http/http.dart' as http;

import 'src/style.dart';
import 'src/daily.dart';


Future<List<dynamic>> getIOT() async {
  final response = await  http.put(
    Uri.https('flwgbei0af.execute-api.eu-central-1.amazonaws.com',
        'default/getIoTData',
      {"devid":"UK19332101"}
    ),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'x-api-key': 'nq2Y8Gq1Mu3UkhLEkC7s219YYtG7CcG8aEthWCrz',
    }
  );

  var records = (jsonDecode(response.body)["iotdata"] as List).
    map((e) => e as Map<String, dynamic>)?.toList();

  records.sort((a, b) {
  return (a["ts"] as num).compareTo(b["ts"] as num);
  });
  if (response.statusCode == 200) {
    return records;
  } else {
    throw Exception('Failed to create album.');
  }

}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: MyHome()
    );
  }
}

class MyHome extends StatefulWidget {
  MyHome({Key key}) : super(key: key);

  @override
  _MyHomeState createState() {
    return _MyHomeState();
  }
}

var iot;

class _MyHomeState extends State<MyHome> {

  @override
  void initState() {
    super.initState();
    iot = getIOT();
  }

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      title: 'CircadianClock',
      theme: ThemeData(
        primarySwatch: mainColor,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Circadian Clock'),
        ),
        body: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(8.0),
          child: ListView(
            children: <Widget>[
              SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: mainColor,
                  onPrimary: Colors.white,
                  side: BorderSide(color: secondColor, width: 2),
                ),
                child: Text('Daily Health Form'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => DailyScreen()),
                  );
                  setState(() {

                  });
                },
              ),
              Padding(
                child: Text('Track your SpO2 (%)', style: TextStyle(fontSize: 20)),
                padding: EdgeInsets.fromLTRB(0, 40, 0, 0),
              ),
              Container(
                width: 350,
                height: 300,
                margin: const EdgeInsets.all(15.0),
                padding: const EdgeInsets.all(3.0),
                decoration: BoxDecoration(
                    border: Border.all(color: mainColor)
                ),
                child:
                FutureBuilder<List<dynamic>>(
                  future: iot,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return
                        graphic.Chart(
                          data: snapshot.data,// iot,
                          scales: {
                            'ts': graphic.CatScale(
                              accessor: (map) => DateFormat('MEd').format(DateTime.fromMillisecondsSinceEpoch((map['ts'] as num))).toString(),
                              tickCount: 5,
                            ),
                            'o': graphic.LinearScale(
                              accessor: (map) => map['o'] as num,
                              min: 40,
                              nice: true,
                            )
                          },
                          geoms: [graphic.IntervalGeom(
                            position: graphic.PositionAttr(field: 'ts*o'),
                            color: graphic.ColorAttr(
                                values: [secondColor],//[secondColor],
                                isTween: true,
                            ),
                            shape: graphic.ShapeAttr(values: [
                              graphic.RectShape(radius: Radius.circular(5))
                            ]),
                          )],
                          axes: {
                            'ts': graphic.Defaults.horizontalAxis,
                            'o': graphic.Defaults.verticalAxis,
                          },
                        );
                    } else if (snapshot.hasError) {
                      return Text("${snapshot.error}");
                    }

                    // By default, show a loading spinner.
                    return CircularProgressIndicator();
                  },
                ),
              ),
              Padding(
                child: Text('Track your Body Temperature', style: TextStyle(fontSize: 20)),
                padding: EdgeInsets.fromLTRB(0, 40, 0, 0),
              ),
              Container(
                width: 350,
                height: 300,
                margin: const EdgeInsets.all(15.0),
                padding: const EdgeInsets.all(3.0),
                decoration: BoxDecoration(
                    border: Border.all(color: mainColor)
                ),
                child:
                FutureBuilder<List<dynamic>>(
                  future: iot,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return
                        graphic.Chart(
                          data: snapshot.data,// iot,
                          scales: {
                            'ts': graphic.CatScale(
                              accessor: (map) => DateFormat('MEd').format(DateTime.fromMillisecondsSinceEpoch((map['ts'] as num))).toString(),
                              tickCount: 5,
                            ),
                            't': graphic.LinearScale(
                              accessor: (map) => (map['t'] as num)/100,
                              min: 32,
                              nice: true,
                            )
                          },
                          geoms: [graphic.IntervalGeom(
                            position: graphic.PositionAttr(field: 'ts*t'),
                            color: graphic.ColorAttr(
                              values: [secondColor],//[secondColor],
                              isTween: true,
                            ),
                            shape: graphic.ShapeAttr(values: [
                              graphic.RectShape(radius: Radius.circular(5))
                            ]),
                          )],
                          axes: {
                            'ts': graphic.Defaults.horizontalAxis,
                            't': graphic.Defaults.verticalAxis,
                          },
                        );
                    } else if (snapshot.hasError) {
                      return Text("${snapshot.error}");
                    }

                    // By default, show a loading spinner.
                    return CircularProgressIndicator();
                  },
                ),
              ),


            ],
          ),
        ),
      ),
    );
  }
}
