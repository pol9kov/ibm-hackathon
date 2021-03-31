import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'style.dart';



abstract class Symptom {
  String question;
  bool isGood;
  Symptom(this.question, this.isGood);
}

class Rated {
  bool getIsGood() {}
  double getRate() {}
  void setRate(double rate) {}
}

class RatedSymptom extends Symptom implements Rated {
  double rate;
  RatedSymptom(question, isGood, this.rate)
      : super(question, isGood);

  bool getIsGood() {
    return this.isGood;
  }
  double getRate() {
    return this.rate;
  }
  void setRate(double rate) {
    this.rate = rate;
  }

  int getResult(){
    return rate.toInt();
  }
}

class PossibleSymptom extends Symptom{
  var isExist;
  PossibleSymptom(question,isGood, this.isExist)
      : super(question, isGood);

  int getResult(){
    if (this.isExist) {
      return 1;
    } else {
      return 0;
    }
  }
}

class PossibleRatedSymptom extends PossibleSymptom implements Rated {
  double rate;
  PossibleRatedSymptom(question, isGood, isExist, this.rate)
      : super(question, isGood, isExist);
  bool getIsGood() {
    return this.isGood;
  }
  double getRate() {
    return this.rate;
  }
  void setRate(double rate) {
    this.rate = rate;
  }

  int getResult(){
    if (this.isExist) {
      return rate.toInt();
    } else {
      return 0;
    }
  }
}

class Daily  {
  final int health;
  final int dyspnea;
  final int fatigue;
  final int struggle;
  final int cough;
  final int smell;
  final int taste;

  Daily({
    this.health,
    this.dyspnea,
    this.fatigue,
    this.struggle,
    this.cough,
    this.smell,
    this.taste});


  Map<String, dynamic> toJson() {
    return {
      'health': health,
      'dyspnea': dyspnea,
      'fatigue': fatigue,
      'struggle': struggle,
      'cough': cough,
      'smell': smell,
      'taste': taste,
    };
  }
}

Future<dynamic> updateDaily(Daily daily) async {
  final response = await  http.put(
    Uri.https('q9bndu05v6.execute-api.eu-central-1.amazonaws.com',
        'Test/apiproxys3puthack5team/patient-data_UK18919201_'+new DateTime.now().toString()),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(daily),
  );

  if (response.statusCode == 200) {
    return response.body;
  } else {
    throw Exception('Failed to create album.');
  }

}

class DailyScreen extends StatefulWidget {
  DailyScreen({Key key}) : super(key: key);

  @override
  _DailyScreenState createState() {
    return _DailyScreenState();
  }
}

class _DailyScreenState extends State<DailyScreen> {

  double healthValue = 3;

  RatedSymptom health = new RatedSymptom("How are you feeling today?", true, 3);
  PossibleRatedSymptom dyspnea = new PossibleRatedSymptom("Are you breathless at rest?", false, false, 3);
  PossibleRatedSymptom fatigue = new PossibleRatedSymptom("Do you feel fatigue?", false, false, 3);
  PossibleRatedSymptom struggle = new PossibleRatedSymptom("Are you struggling to breathe?", false, false, 3);
  PossibleRatedSymptom cough = new PossibleRatedSymptom("Do you have a cough?", false, false, 3);
  PossibleSymptom smell = new PossibleSymptom("Have you lost your smell?", false, false);
  PossibleSymptom taste = new PossibleSymptom("Have you lost your taste?", false, false);

  bool isSmellLost = false;
  bool isTasteLost = false;

  SliderTheme rate(Rated symptom){

    LinearGradient g;
    if (!symptom.getIsGood()) {
      g = gradient;
    } else {
      g = contraGradient;
    }

    return SliderTheme(
        data: SliderThemeData(
          trackShape: GradientRectSliderTrackShape(gradient: g, darkenInactive: false),
        ),
        child: Slider(
          value: symptom.getRate(),
          min: 1,
          max: 5,
          divisions: 4,
          onChanged: (double value) {
            setState(() {
              symptom.setRate(value);
            });
          },
        )
    );
  }

  Column ratedSymptom(RatedSymptom symptom){

    return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Align(
            alignment: Alignment.centerLeft,
            child: Text(symptom.question)
          ),
          rate(symptom)]
    );
  }

  Row possibleSymptom (PossibleSymptom symptom) {
    return Row(
      children: [
        Text(symptom.question),
        Switch(
          value: symptom.isExist,
          onChanged: (value){
            setState(() {
              symptom.isExist=value;
            });
          },
        ),
      ],
    );
  }

  Column possibleRatedSymptom(PossibleRatedSymptom symptom){
    Row isExist = possibleSymptom(symptom);
    Visibility rateWrapper = Visibility(
      visible: symptom.isExist == true,
      maintainState: true,
      child: rate(symptom),
    );

    return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
        isExist,
        rateWrapper]
    );
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
          title: Text('Daily Health'),
        ),
        body: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(8.0),
          child: ListView(
            children: <Widget>[
              ratedSymptom(health),
              possibleRatedSymptom(dyspnea),
              possibleRatedSymptom(fatigue),
              possibleRatedSymptom(struggle),
              possibleRatedSymptom(cough),
              possibleSymptom(smell),
              possibleSymptom(taste),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: mainColor,
                  onPrimary: Colors.white,
                  side: BorderSide(color: secondColor, width: 2),
                ),
                child: Text('Send'),
                onPressed: () {
                  setState(() {
                    updateDaily(Daily(
                      health: health.getResult(),
                      dyspnea: dyspnea.getResult(),
                      fatigue: fatigue.getResult(),
                      struggle: struggle.getResult(),
                      cough: cough.getResult(),
                      smell: smell.getResult(),
                      taste: taste.getResult(),
                    ));
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
