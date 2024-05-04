import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/state_provider.dart';
import '../shared/custom_bottom_navigation_bar_clubs.dart';

import 'package:fl_chart/fl_chart.dart';

import 'indicator.dart';

class ClubStatisticsView extends StatefulWidget{

  ClubStatisticsView({Key? key}) : super(key: key);

  @override
  State<ClubStatisticsView> createState() => _ClubStatisticsViewState();
}

class _ClubStatisticsViewState extends State<ClubStatisticsView> {
  String headLine = "Your Stats";

  int touchedIndex = -1;

  bool dialog = false;

  bool showAvg = false;

  List<Color> gradientColors = [
    const Color(0xff23b6e6),
    const Color(0xff02d39a),
  ];

  @override
  Widget build(BuildContext context) {

    final stateProvider = Provider.of<StateProvider>(context);

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;



    return Scaffold(

        extendBodyBehindAppBar: true,
        extendBody: true,

        bottomNavigationBar: CustomBottomNavigationBarClubs(),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Text(headLine,
            style: TextStyle(
              // color: Colors.purpleAccent
            ),
          ),
        ),
        body: Container(
            width: screenWidth,
            height: screenHeight,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    // Color(0xff11181f),
                    Color(0xff2b353d),
                    Color(0xff11181f)
                  ],
                  stops: [0.15, 0.6]
              ),
            ),
            child: SingleChildScrollView(
                child: Container(
                    child: Column(
                        children: [

                          SizedBox(
                            height: screenHeight*0.15,
                          ),

                          // Events headline
                          Container(
                            width: screenWidth,
                            // color: Colors.red,
                            padding: EdgeInsets.only(
                                left: screenWidth*0.05,
                                top: screenHeight*0.01
                            ),
                            child: const Text(
                              "Demographie",
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                  fontSize: 24
                              ),
                            ),
                          ),

                          SizedBox(
                            height: screenHeight*0.02,
                          ),

                          // Pie chart
                          Container(
                            width: screenWidth*0.9,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.white60
                              ),
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(30),
                                bottomLeft: Radius.circular(30)
                              )
                            ),
                            child: AspectRatio(
                              aspectRatio: 1.4,
                              child: Card(
                                color: Colors.transparent,//Colors.grey[850],
                                child: Column(
                                  children: <Widget>[
                                    SizedBox(
                                      height: screenHeight*0.05,
                                    ),
                                    Stack(
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: AspectRatio(
                                                aspectRatio: 2,
                                                child: PieChart(
                                                  PieChartData(
                                                      pieTouchData: PieTouchData(touchCallback:
                                                          (FlTouchEvent event, pieTouchResponse) {
                                                        setState(() {
                                                          if (!event.isInterestedForInteractions ||
                                                              pieTouchResponse == null ||
                                                              pieTouchResponse.touchedSection == null) {
                                                            touchedIndex = -1;
                                                            return;
                                                          }
                                                          touchedIndex = pieTouchResponse
                                                              .touchedSection!.touchedSectionIndex;
                                                          // _showClickPiePartDialog(touchedIndex, context);
                                                        });
                                                      }),
                                                      borderData: FlBorderData(
                                                        show: false,
                                                      ),
                                                      sectionsSpace: 0,
                                                      centerSpaceRadius: 40,
                                                      sections: showingSections()),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(
                                              top: screenHeight*0.02,
                                              left: screenWidth*0.03
                                          ),
                                          child: const Column(
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Indicator(
                                                color: Colors.lightGreen,
                                                text: '18-20',
                                                isSquare: true,
                                              ),
                                              SizedBox(
                                                height: 4,
                                              ),
                                              Indicator(
                                                color:Colors.blue,
                                                text: '20-25',
                                                isSquare: true,
                                              ),
                                              SizedBox(
                                                height: 4,
                                              ),
                                              Indicator(
                                                color: Colors.yellow,
                                                text: '25-30',
                                                isSquare: true,
                                              ),
                                              SizedBox(
                                                height: 4,
                                              ),
                                              Indicator(
                                                color: Colors.deepOrangeAccent,
                                                text: '30-40',
                                                isSquare: true,
                                              ),
                                              SizedBox(
                                                height: 4,
                                              ),
                                              Indicator(
                                                color: Colors.redAccent,
                                                text: '40-50',
                                                isSquare: true,
                                              ),
                                              SizedBox(
                                                height: 4,
                                              ),
                                              Indicator(
                                                color: Colors.black,
                                                text: '50-60',
                                                isSquare: true,
                                              ),
                                              SizedBox(
                                                height: 4,
                                              ),
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          SizedBox(
                            height: screenHeight*0.02,
                          ),

                          // Events headline
                          Container(
                            width: screenWidth,
                            // color: Colors.red,
                            padding: EdgeInsets.only(
                                left: screenWidth*0.05,
                                top: screenHeight*0.01
                            ),
                            child: const Text(
                              "Besucheranzahl",
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                  fontSize: 24
                              ),
                            ),
                          ),

                          SizedBox(
                            height: screenHeight*0.02,
                          ),

                          // Line Chart
                          Container(
                            width: screenWidth*0.9,
                            decoration: BoxDecoration(
                                border: Border.all(
                                    color: Colors.white60
                                ),
                                borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(30),
                                    bottomLeft: Radius.circular(30)
                                )
                            ),
                            child: AspectRatio(
                              aspectRatio: 1.15,
                              child: Container(
                                child: Stack(
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      children: [
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                right: 18.0, left: 12.0, top: 24, bottom: 12),
                                            child: LineChart(
                                              showAvg ? avgData() : mainData(),
                                            ),
                                          ),
                                        )
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),

                          SizedBox(
                            height: screenHeight*0.2,
                          )

                        ]
                    )
                )
            )
        )
    );
  }

  List<PieChartSectionData> showingSections() {
    return List.generate(6, (i) {
      final isTouched = i == touchedIndex;
      final fontSize = isTouched ? 25.0 : 16.0;
      final radius = isTouched ? 60.0 : 50.0;
      switch (i) {
        case 0:
          return PieChartSectionData(
            color: Colors.green,
            value: 10,
            title: '10%',
            radius: radius,
            titleStyle: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: const Color(0xffffffff)),
          );
        case 1:
          return PieChartSectionData(
            color: Colors.blue,
            value: 40,
            title: '40%',
            radius: radius,
            titleStyle: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: const Color(0xffffffff)),
          );
        case 2:
          return PieChartSectionData(
            color: Colors.yellowAccent,
            value: 20,
            title: '20%',
            radius: radius,
            titleStyle: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: Colors.black),
          );
        case 3:
          return PieChartSectionData(
            color: Colors.deepOrangeAccent,
            value: 15,
            title: '15%',
            radius: radius,
            titleStyle: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: const Color(0xffffffff)),
          );
        case 4:
          return PieChartSectionData(
            color: Colors.red,
            value: 10,
            title: '10%',
            radius: radius,
            titleStyle: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: const Color(0xffffffff)),
          );
        case 5:
          return PieChartSectionData(
            color: Colors.black,
            value: 5,
            title: '5%',
            radius: radius,
            titleStyle: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: const Color(0xffffffff)),
          );
        default:
          throw Error();
      }
    });
  }

  void _showClickPiePartDialog(int touchedIndex, BuildContext context){
    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('Add an equation step'),
          content:Container(
            height:200,
            child: Column(
              children: [
                Text("fewfewf")
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {Navigator.of(context).pop();},
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Accept'),
            ),
          ],
        )
    );
  }


  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Color(0xff68737d),
      fontWeight: FontWeight.bold,
      fontSize: 16,
    );
    Widget text;
    switch (value.toInt()) {
      case 3:
        text = const Text('FEB', style: style);
        break;
      case 9:
        text = const Text('APR', style: style);
        break;
      case 15:
        text = const Text('JUN', style: style);
        break;
      case 21:
        text = const Text('AUG', style: style);
        break;
      case 27:
        text = const Text('OCT', style: style);
        break;
      case 33:
        text = const Text('DEZ', style: style);
        break;
      default:
        text = const Text('', style: style);
        break;
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 8.0,
      child: text,
    );
  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Color(0xff67727d),
      fontWeight: FontWeight.bold,
      fontSize: 12,
    );
    String text;
    switch (value.toInt()) {
      case 50:
        text = '50';
        break;
      case 30:
        text = '30';
        break;
      case 10:
        text = '10';
        break;
      default:
        return Container();
    }

    return Text(text, style: style, textAlign: TextAlign.left);
  }

  LineChartData mainData() {
    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        horizontalInterval: 1,
        verticalInterval: 1,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: const Color(0xff37434d),
            strokeWidth: 1,
          );
        },
        getDrawingVerticalLine: (value) {
          return FlLine(
            color: const Color(0xff37434d),
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 1,
            getTitlesWidget: bottomTitleWidgets,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 1,
            getTitlesWidget: leftTitleWidgets,
            reservedSize: 30,
          ),
        ),
      ),
      borderData: FlBorderData(
          show: true,
          border: Border.all(color: const Color(0xff37434d), width: 1)),
      minX: 0,
      maxX: 39,
      minY: 0,
      maxY: 60,
      lineBarsData: [
        LineChartBarData(
          spots: const [
            FlSpot(0, 33),
            FlSpot(3, 26),
            FlSpot(6, 22),
            FlSpot(9, 55),
            FlSpot(12, 35),
            FlSpot(15, 33),
            FlSpot(18, 41),
            FlSpot(21, 46),
            FlSpot(24, 58),
            FlSpot(27, 43),
            FlSpot(30, 29),
            FlSpot(33, 44),
            FlSpot(36, 21),
            FlSpot(39, 34),
          ],
          isCurved: true,
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          barWidth: 5,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: false,
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: gradientColors
                  .map((color) => color.withOpacity(0.3))
                  .toList(),
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
      ],
    );
  }

  LineChartData avgData() {
    return LineChartData(
      lineTouchData: LineTouchData(enabled: false),
      gridData: FlGridData(
        show: true,
        drawHorizontalLine: true,
        verticalInterval: 1,
        horizontalInterval: 1,
        getDrawingVerticalLine: (value) {
          return FlLine(
            color: const Color(0xff37434d),
            strokeWidth: 1,
          );
        },
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: const Color(0xff37434d),
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            getTitlesWidget: bottomTitleWidgets,
            interval: 1,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: leftTitleWidgets,
            reservedSize: 42,
            interval: 1,
          ),
        ),
        topTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        rightTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      ),
      borderData: FlBorderData(
          show: true,
          border: Border.all(color: const Color(0xff37434d), width: 1)),
      minX: 0,
      maxX: 39,
      minY: 0,
      maxY: 6,
      lineBarsData: [
        LineChartBarData(
          spots: const [
            FlSpot(0, 2.5),
            FlSpot(6, 2.5),
            FlSpot(12, 2.5),
            FlSpot(18, 2.5),
            FlSpot(24, 2.5),
            FlSpot(30, 2.5),
            FlSpot(39, 2.5),
          ],
          isCurved: true,
          gradient: LinearGradient(
            colors: [
              ColorTween(begin: gradientColors[0], end: gradientColors[1])
                  .lerp(0.2)!,
              ColorTween(begin: gradientColors[0], end: gradientColors[1])
                  .lerp(0.2)!,
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          barWidth: 5,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: false,
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                ColorTween(begin: gradientColors[0], end: gradientColors[1])
                    .lerp(0.2)!
                    .withOpacity(0.1),
                ColorTween(begin: gradientColors[0], end: gradientColors[1])
                    .lerp(0.2)!
                    .withOpacity(0.1),
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
      ],
    );
  }
}
