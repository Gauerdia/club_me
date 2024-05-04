import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ClubListItem extends StatelessWidget {
  ClubListItem({
    Key? key,
    required this.clubName,
    required this.NOfPeople,
    required this.distance,
    required this.price
    // required clubsInProximity
  }) : super(key: key);

  String clubName;
  String price;
  String distance;
  String NOfPeople;

  // late ClubsInProximity clubInProximity;

  @override
  Widget build(BuildContext context) {

    // print(clubInProximity);

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Padding(
      padding: EdgeInsets.only(
          bottom: screenHeight*0.03
      ),
      child: Container(
        width: screenWidth*0.86,
        height: screenHeight*0.14,
        // color: Colors.grey,
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.grey[800]!,
                  Colors.grey[700]!,
                ],
                stops: const [0.3, 0.9]
            ),
            border: Border.all(
                color: Colors.white60
            ),
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                bottomRight: Radius.circular(20)
            )
        ),
        child: Row(
          children: [

            // Left Column with story button
            Container(
              width: screenWidth*0.2,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                      height: screenHeight*0.08,
                      width: screenWidth*0.16,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(
                            Radius.circular(45),
                          ),
                          border: Border(
                              left: BorderSide(color: Colors.purpleAccent),
                              right: BorderSide(color: Colors.purpleAccent),
                              top: BorderSide(color: Colors.purpleAccent)
                          ),
                          color: Colors.black.withOpacity(0.3)
                      ),
                      child: const Center(
                        child: Text("Club"),
                      )
                  )
                ],
              ),
            ),

            // Right column with content
            Column(
              children: [
                SizedBox(
                    width: screenWidth*0.65,
                    height: screenHeight*0.065,
                    // color: Colors.green,
                    child: Center(
                      child: Text(
                        clubName,
                        textAlign: TextAlign.left,
                        style: const TextStyle(
                          fontSize: 22,
                        ),
                      ),
                    )
                ),
                SizedBox(
                    width: screenWidth*0.6,
                    height: screenHeight*0.065,
                    // color: Colors.purpleAccent,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: screenWidth*0.5,
                          height: screenHeight*0.05,
                          // color: Colors.blue,
                          decoration: BoxDecoration(
                              color: Colors.grey[800],
                              borderRadius: const BorderRadius.all(
                                  Radius.circular(15)
                              ),
                              border: Border.all(color: Colors.purpleAccent)
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.route_outlined,
                                    color: Colors.purpleAccent,
                                  ),
                                  Text(
                                    distance,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold
                                    ),
                                  )
                                ],
                              ),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.person_pin,
                                    color: Colors.purpleAccent,
                                  ),
                                  Text(
                                    NOfPeople,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold
                                    ),
                                  )
                                ],
                              ),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.attach_money,
                                    color: Colors.purpleAccent,
                                  ),
                                  Text(
                                    price,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold
                                    ),
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                      ],
                    )
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}