// bool dateUnfold = false;
// bool titleUnfold = false;
// bool genderUnfold = false;
// bool ageLimitUnfold = false;
// bool timeLimitUnfold = false;
// bool usageLimitUnfold = false;
// bool descriptionUnfold = false;
// bool templateUnfold = false;
//
// Widget _buildBottomNavigationBar(){
//   return SizedBox(
//     height: screenHeight*0.12,
//     child: Stack(
//       children: [
//
//         // Top accent
//         Align(
//           alignment: Alignment.bottomCenter,
//           child: Container(
//             height: screenHeight*0.105,
//             decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                     begin: Alignment.topCenter,
//                     end: Alignment.topRight,
//                     colors: [Colors.grey[600]!, Colors.grey[900]!],
//                     stops: const [0.1, 0.9]
//                 ),
//                 borderRadius: const BorderRadius.only(
//                     topLeft: Radius.circular(30),
//                     topRight: Radius.circular(30)
//                 )
//             ),
//           ),
//         ),
//
//         // Main background
//         Align(
//           alignment: Alignment.bottomCenter,
//           child: Container(
//             height: screenHeight*0.1,
//             decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                     begin: Alignment.topLeft,
//                     end: Alignment.bottomRight,
//                     colors: [
//                       Colors.grey[800]!.withOpacity(0.7),
//                       Colors.grey[900]!
//                     ],
//                     stops: const [0.1,0.9]
//                 ),
//                 borderRadius: const BorderRadius.only(
//                     topLeft: Radius.circular(30),
//                     topRight: Radius.circular(30)
//                 )
//             ),
//           ),
//         ),
//
//         // Right button
//         isUploading ? Padding(
//           padding: EdgeInsets.only(
//               top: screenHeight*0.02
//             // right: screenWidth*0.05,
//             // bottom: screenHeight*0.03
//           ),
//           child: const Align(
//             alignment: AlignmentDirectional.center,
//             child: CircularProgressIndicator(),
//           ),
//         ):Padding(
//           padding: EdgeInsets.only(
//               top: screenHeight*0.02
//             // right: screenWidth*0.04,
//             // bottom: screenHeight*0.015
//           ),
//           child: Align(
//               alignment: AlignmentDirectional.center,
//               child: GestureDetector(
//                 child: Container(
//                   padding: EdgeInsets.symmetric(
//                       horizontal: screenWidth*0.035,
//                       vertical: screenHeight*0.02
//                   ),
//                   decoration: BoxDecoration(
//                     borderRadius: const BorderRadius.all(
//                         Radius.circular(10)
//                     ),
//                     gradient: LinearGradient(
//                         colors: [
//                           customStyleClass.primeColorDark,
//                           customStyleClass.primeColor,
//                         ],
//                         begin: Alignment.topLeft,
//                         end: Alignment.bottomRight,
//                         stops: const [0.2, 0.9]
//                     ),
//                     boxShadow: const [
//                       BoxShadow(
//                         color: Colors.black54,
//                         spreadRadius: 1,
//                         blurRadius: 7,
//                         offset: Offset(3, 3),
//                       ),
//                     ],
//                   ),
//                   child: Text(
//                     "Coupon erstellen!",
//                     // creationIndex == 5 ? "Abschicken!":"Weiter!",
//                     style:customStyleClass.getFontStyle4Bold(),
//                   ),
//                 ),
//                 onTap: () => iterateScreen(),
//               )
//           ),
//         )
//       ],
//     ),
//   );
// }
//
// Widget _buildFinalOverview2(){
//
//   _fixedExtentScrollController1 = FixedExtentScrollController(initialItem: selectedFirstElement);
//   _fixedExtentScrollController2 = FixedExtentScrollController(initialItem: selectedSecondElement);
//
//   return SizedBox(
//     height: screenHeight,
//     child: SingleChildScrollView(
//       keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
//       child: Column(
//         children: [
//
//           // Headline 'Please check if everything is fine'
//           Container(
//             width: screenWidth*0.9,
//             padding: EdgeInsets.symmetric(
//                 vertical: screenHeight*0.04,
//                 horizontal: screenWidth*0.02
//             ),
//             child: Text(
//               "Bitte gib die passenden Daten zu deinem Coupon an!",
//               textAlign: TextAlign.center,
//               style: customStyleClass.getFontStyle2Bold(),
//             ),
//           ),
//
//           _buildTitleTile(),
//
//           // Spacer
//           SizedBox(
//             height: screenHeight*0.03,
//           ),
//
//           _buildDateTile(),
//
//           // Spacer
//           SizedBox(
//             height: screenHeight*0.03,
//           ),
//
//           _buildTimeLimitTile(),
//
//           // Spacer
//           SizedBox(
//             height: screenHeight*0.03,
//           ),
//
//           _buildUsageLimitTile(),
//
//           // Spacer
//           SizedBox(
//             height: screenHeight*0.03,
//           ),
//
//           _buildGenderTile(),
//
//           // Spacer
//           SizedBox(
//             height: screenHeight*0.03,
//           ),
//
//           _buildAgeLimitTile(),
//
//           // Spacer
//           SizedBox(
//             height: screenHeight*0.03,
//           ),
//
//           _buildDescriptionTile(),
//
//           // Spacer
//           SizedBox(
//             height: screenHeight*0.03,
//           ),
//
//           isTemplate == 1 ? Container() : _buildTemplateTile(),
//
//           // Spacer
//           SizedBox(
//             height: screenHeight*0.15,
//           ),
//
//
//         ],
//       ),
//     ),
//   );
// }
//
// Widget _buildTitleTile(){
//   return Stack(
//     children: [
//
//       // Colorful accent
//       Container(
//         width: screenWidth*0.91,
//         height: screenHeight*(titleTileHeightFactor+0.004),
//         decoration: BoxDecoration(
//             gradient: LinearGradient(
//                 begin: Alignment.bottomLeft,
//                 end: Alignment.bottomRight,
//                 colors: [
//                   Colors.grey[900]!,
//                   customStyleClass.primeColorDark.withOpacity(0.4)
//                 ],
//                 stops: const [0.6, 0.9]
//             ),
//             borderRadius: BorderRadius.circular(15)
//         ),
//       ),
//
//       // Colorful accent
//       Container(
//         width: screenWidth*0.91,
//         height: screenHeight*titleTileHeightFactor,
//         decoration: BoxDecoration(
//             gradient: LinearGradient(
//                 begin: Alignment.topRight,
//                 end: Alignment.bottomRight,
//                 colors: [
//                   Colors.grey[900]!,
//                   customStyleClass.primeColorDark.withOpacity(0.2)
//                 ],
//                 stops: const [0.6, 0.9]
//             ),
//             borderRadius: BorderRadius.circular(
//                 15
//             )
//         ),
//       ),
//
//       // light grey highlight
//       Container(
//         width: screenWidth*0.89,
//         height: screenHeight*titleTileHeightFactor,
//         decoration: BoxDecoration(
//             gradient: LinearGradient(
//                 begin: Alignment.topCenter,
//                 end: Alignment.bottomCenter,
//                 colors: [Colors.grey[600]!, Colors.grey[600]!],
//                 stops: const [0.1, 0.9]
//             ),
//             borderRadius: BorderRadius.circular(
//                 15
//             )
//         ),
//       ),
//
//       // light grey highlight
//       Padding(
//           padding: const EdgeInsets.only(
//               left:2
//           ),
//           child: Container(
//             width: screenWidth*0.9,
//             height: screenHeight*titleTileHeightFactor,
//             decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                     begin: Alignment.topLeft,
//                     end: Alignment.topRight,
//                     colors: [Colors.grey[600]!, Colors.grey[900]!],
//                     stops: const [0.1, 0.9]
//                 ),
//                 borderRadius: BorderRadius.circular(
//                     15
//                 )
//             ),
//           )
//       ),
//
//       // main Div
//       Padding(
//         padding: const EdgeInsets.only(
//             left:2,
//             top: 2
//         ),
//         child: Container(
//           width: screenWidth*0.9,
//           height: screenHeight*titleTileHeightFactor,
//           decoration: BoxDecoration(
//               gradient: LinearGradient(
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                   colors: [
//                     Colors.grey[800]!.withOpacity(0.7),
//                     Colors.grey[900]!
//                   ],
//                   stops: [0.1,0.9]
//               ),
//               borderRadius: BorderRadius.circular(
//                   15
//               )
//           ),
//           child: Column(
//             children: [
//
//               // Title + icon
//               Container(
//                 width: screenWidth*0.8,
//                 padding: EdgeInsets.only(
//                     top: screenHeight*0.01
//                 ),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                         "Titel",
//                         textAlign: TextAlign.left,
//                         style: customStyleClass.getFontStyle1Bold()
//                     ),
//                     IconButton(
//                       icon: Icon(
//                           titleUnfold ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down
//                       ),
//                       onPressed: (){
//                         setState(() {
//                           if(titleUnfold){
//                             titleTileHeightFactor = originalTitleTileHeightFactor;
//                             titleUnfold = false;
//                           }else{
//                             titleTileHeightFactor = originalTitleTileHeightFactor*3.5;
//                             titleUnfold = true;
//                           }
//                         });
//                       },
//                     )
//                   ],
//                 ),
//               ),
//
//               // Spacer
//               titleUnfold ?SizedBox(
//                 height: screenHeight*0.01,
//               ):Container(),
//
//               // White line
//               titleUnfold ?
//               const Divider(
//                 height:10,
//                 thickness: 1,
//                 color: Colors.grey,
//               ): Container(),
//
//               // Spacer
//               titleUnfold ?SizedBox(
//                 height: screenHeight*0.03,
//               ):Container(),
//
//               titleUnfold ? Text(
//                 "Wie soll der Coupon heißen?",
//                 style: customStyleClass.getFontStyle3(),
//               ):Container(),
//
//               // Spacer
//               titleUnfold ?SizedBox(
//                 height: screenHeight*0.02,
//               ):Container(),
//
//               // Textfield
//               titleUnfold ? Container(
//                 width: screenWidth*0.8,
//                 child: TextField(
//                   controller: _discountTitleController,
//                   decoration: const InputDecoration(
//                     hintText: "z.B. 2-für-1 Mojitos",
//                     label: Text("Eventtitel"),
//                     border: OutlineInputBorder(),
//                   ),
//                   style: customStyleClass.getFontStyle4(),
//                   maxLength: 35,
//                 ),
//               ): Container(),
//
//             ],
//           ),
//         ),
//       )
//
//     ],
//   );
// }
//
// Widget _buildDateTile(){
//   return Stack(
//     children: [
//
//       // Colorful accent
//       Container(
//         width: screenWidth*0.91,
//         height: screenHeight*(dateTileHeightFactor+0.004),
//         decoration: BoxDecoration(
//             gradient: LinearGradient(
//                 begin: Alignment.bottomLeft,
//                 end: Alignment.bottomRight,
//                 colors: [
//                   Colors.grey[900]!,
//                   customStyleClass.primeColorDark.withOpacity(0.4)
//                 ],
//                 stops: const [0.6, 0.9]
//             ),
//             borderRadius: BorderRadius.circular(15)
//         ),
//       ),
//
//       // Colorful accent
//       Container(
//         width: screenWidth*0.91,
//         height: screenHeight*dateTileHeightFactor,
//         decoration: BoxDecoration(
//             gradient: LinearGradient(
//                 begin: Alignment.topRight,
//                 end: Alignment.bottomRight,
//                 colors: [
//                   Colors.grey[900]!,
//                   customStyleClass.primeColorDark.withOpacity(0.2)
//                 ],
//                 stops: const [0.6, 0.9]
//             ),
//             borderRadius: BorderRadius.circular(
//                 15
//             )
//         ),
//       ),
//
//       // light grey highlight
//       Container(
//         width: screenWidth*0.89,
//         height: screenHeight*dateTileHeightFactor,
//         decoration: BoxDecoration(
//             gradient: LinearGradient(
//                 begin: Alignment.topCenter,
//                 end: Alignment.bottomCenter,
//                 colors: [Colors.grey[600]!, Colors.grey[600]!],
//                 stops: const [0.1, 0.9]
//             ),
//             borderRadius: BorderRadius.circular(
//                 15
//             )
//         ),
//       ),
//
//       // light grey highlight
//       Padding(
//           padding: const EdgeInsets.only(
//               left:2
//           ),
//           child: Container(
//             width: screenWidth*0.9,
//             height: screenHeight*dateTileHeightFactor,
//             decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                     begin: Alignment.topLeft,
//                     end: Alignment.topRight,
//                     colors: [Colors.grey[600]!, Colors.grey[900]!],
//                     stops: const [0.1, 0.9]
//                 ),
//                 borderRadius: BorderRadius.circular(
//                     15
//                 )
//             ),
//           )
//       ),
//
//       // main Div
//       Padding(
//         padding: const EdgeInsets.only(
//             left:2,
//             top: 2
//         ),
//         child: Container(
//           width: screenWidth*0.9,
//           height: screenHeight*dateTileHeightFactor,
//           decoration: BoxDecoration(
//               gradient: LinearGradient(
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                   colors: [
//                     Colors.grey[800]!.withOpacity(0.7),
//                     Colors.grey[900]!
//                   ],
//                   stops: [0.1,0.9]
//               ),
//               borderRadius: BorderRadius.circular(
//                   15
//               )
//           ),
//           child: Column(
//             children: [
//
//               Container(
//                 width: screenWidth*0.8,
//                 padding: EdgeInsets.only(
//                     top: screenHeight*0.01
//                 ),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                         "Datum",
//                         textAlign: TextAlign.left,
//                         style: customStyleClass.getFontStyle1Bold()
//                     ),
//                     IconButton(
//                       icon: Icon(
//                           dateUnfold ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down
//                       ),
//                       onPressed: (){
//                         setState(() {
//                           if(dateUnfold){
//                             dateTileHeightFactor = originalDateTileHeightFactor;
//                             dateUnfold = false;
//                           }else{
//                             dateTileHeightFactor = originalDateTileHeightFactor*3.5;
//                             dateUnfold = true;
//                           }
//                         });
//                       },
//                     )
//                   ],
//                 ),
//               ),
//
//               // Spacer
//               dateUnfold ?SizedBox(
//                 height: screenHeight*0.01,
//               ):Container(),
//
//               // White line
//               dateUnfold ?
//               const Divider(
//                 height:10,
//                 thickness: 1,
//                 color: Colors.grey,
//                 // indent: screenWidth*0.06,
//                 // endIndent: screenWidth*0.75,
//               ): Container(),
//
//               // Spacer
//               dateUnfold ?SizedBox(
//                 height: screenHeight*0.03,
//               ):Container(),
//
//               dateUnfold ? Text(
//                 "Wann soll der Coupon verfügbar sein?",
//                 style: customStyleClass.getFontStyle3(),
//               ):Container(),
//
//               // Spacer
//               dateUnfold ?SizedBox(
//                 height: screenHeight*0.02,
//               ):Container(),
//
//
//
//               dateUnfold ?SizedBox(
//                 width: screenWidth*0.6,
//                 height: screenHeight*0.07,
//                 child: OutlinedButton(
//                     onPressed: (){
//                       showDatePicker(
//                           context: context,
//                           locale: const Locale("de", "DE"),
//                           initialDate: newSelectedDate,
//                           firstDate: DateTime(2018),
//                           lastDate: DateTime(2030),
//                           builder: (BuildContext context, Widget? child) {
//                             return Theme(
//                               data: ThemeData.dark(),
//                               child: child!,
//                             );
//                           }).then((pickedDate){
//                         if( pickedDate == null){
//                           return;
//                         }
//                         setState(() {
//                           newSelectedDate = pickedDate;
//                         });
//                       });
//                     },
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         // Date as Text
//                         Text(
//                           formatSelectedDate(),
//                           style: customStyleClass.getFontStyle3(),
//                         ),
//                         // Spacer
//                         SizedBox(
//                           width: screenWidth*0.02,
//                         ),
//                         // Calendar icon
//                         Icon(
//                           Icons.calendar_month_outlined,
//                           color: customStyleClass.primeColor,
//                         )
//                       ],
//                     )
//                 ),
//               ):Container(),
//
//             ],
//           ),
//         ),
//       )
//
//     ],
//   );
// }
//
// Widget _buildTimeLimitTile(){
//   return Stack(
//     children: [
//
//       // Colorful accent
//       Container(
//         width: screenWidth*0.91,
//         height: screenHeight*(timeLimitTileHeightFactor+0.004),
//         decoration: BoxDecoration(
//             gradient: LinearGradient(
//                 begin: Alignment.bottomLeft,
//                 end: Alignment.bottomRight,
//                 colors: [
//                   Colors.grey[900]!,
//                   customStyleClass.primeColorDark.withOpacity(0.4)
//                 ],
//                 stops: const [0.6, 0.9]
//             ),
//             borderRadius: BorderRadius.circular(15)
//         ),
//       ),
//
//       // Colorful accent
//       Container(
//         width: screenWidth*0.91,
//         height: screenHeight*timeLimitTileHeightFactor,
//         decoration: BoxDecoration(
//             gradient: LinearGradient(
//                 begin: Alignment.topRight,
//                 end: Alignment.bottomRight,
//                 colors: [
//                   Colors.grey[900]!,
//                   customStyleClass.primeColorDark.withOpacity(0.2)
//                 ],
//                 stops: const [0.6, 0.9]
//             ),
//             borderRadius: BorderRadius.circular(
//                 15
//             )
//         ),
//       ),
//
//       // light grey highlight
//       Container(
//         width: screenWidth*0.89,
//         height: screenHeight*timeLimitTileHeightFactor,
//         decoration: BoxDecoration(
//             gradient: LinearGradient(
//                 begin: Alignment.topCenter,
//                 end: Alignment.bottomCenter,
//                 colors: [Colors.grey[600]!, Colors.grey[600]!],
//                 stops: const [0.1, 0.9]
//             ),
//             borderRadius: BorderRadius.circular(
//                 15
//             )
//         ),
//       ),
//
//       // light grey highlight
//       Padding(
//           padding: const EdgeInsets.only(
//               left:2
//           ),
//           child: Container(
//             width: screenWidth*0.9,
//             height: screenHeight*timeLimitTileHeightFactor,
//             decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                     begin: Alignment.topLeft,
//                     end: Alignment.topRight,
//                     colors: [Colors.grey[600]!, Colors.grey[900]!],
//                     stops: const [0.1, 0.9]
//                 ),
//                 borderRadius: BorderRadius.circular(
//                     15
//                 )
//             ),
//           )
//       ),
//
//       // main Div
//       Padding(
//         padding: const EdgeInsets.only(
//             left:2,
//             top: 2
//         ),
//         child: Container(
//           width: screenWidth*0.9,
//           height: screenHeight*timeLimitTileHeightFactor,
//           decoration: BoxDecoration(
//               gradient: LinearGradient(
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                   colors: [
//                     Colors.grey[800]!.withOpacity(0.7),
//                     Colors.grey[900]!
//                   ],
//                   stops: [0.1,0.9]
//               ),
//               borderRadius: BorderRadius.circular(
//                   15
//               )
//           ),
//           child: Column(
//             children: [
//
//               // Headline + Icon
//               Container(
//                 width: screenWidth*0.8,
//                 padding: EdgeInsets.only(
//                     top: screenHeight*0.01
//                 ),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                         "Zeitlimit",
//                         textAlign: TextAlign.left,
//                         style: customStyleClass.getFontStyle1Bold()
//                     ),
//                     IconButton(
//                       icon: Icon(
//                           timeLimitUnfold ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down
//                       ),
//                       onPressed: (){
//                         setState(() {
//                           if(timeLimitUnfold){
//                             timeLimitTileHeightFactor = originalFoldHeightFactor;
//                             timeLimitUnfold = false;
//                           }else{
//                             if( hasTimeLimit == 1){
//                               timeLimitTileHeightFactor = originalFoldHeightFactor*4.5;
//                             }else{
//                               timeLimitTileHeightFactor = originalFoldHeightFactor*3;
//                             }
//
//                             timeLimitUnfold = true;
//                           }
//                         });
//                       },
//                     )
//                   ],
//                 ),
//               ),
//
//               // Spacer
//               timeLimitUnfold ?SizedBox(
//                 height: screenHeight*0.01,
//               ):Container(),
//
//               // White line
//               timeLimitUnfold ?
//               const Divider(
//                 height:10,
//                 thickness: 1,
//                 color: Colors.grey,
//                 // indent: screenWidth*0.06,
//                 // endIndent: screenWidth*0.75,
//               ): Container(),
//
//               // Spacer
//               timeLimitUnfold ?SizedBox(
//                 height: screenHeight*0.03,
//               ):Container(),
//
//               // QUestion
//               timeLimitUnfold ? Text(
//                 "Ist der Coupon zeitlich begrenzt?",
//                 style: customStyleClass.getFontStyle3(),
//               ):Container(),
//
//               // Toggle switch
//               timeLimitUnfold ?SizedBox(
//                 width: screenWidth*0.4,
//                 height: screenHeight*0.08,
//                 child:  Center(
//                   child: ToggleSwitch(
//                     initialLabelIndex: hasTimeLimit,
//                     totalSwitches: 2,
//                     activeBgColor: [customStyleClass.primeColor],
//                     activeFgColor: Colors.white,
//                     inactiveBgColor: const Color(0xff11181f),
//                     labels: const [
//                       'Nein',
//                       'Ja',
//                     ],
//                     onToggle: (index) {
//                       setState(() {
//                         if(hasTimeLimit == 0){
//                           setState(() {
//                             hasTimeLimit = 1;
//                             timeLimitTileHeightFactor = originalFoldHeightFactor*4.5;
//                           });
//                         }else{
//                           setState(() {
//                             hasTimeLimit = 0;
//                             timeLimitTileHeightFactor = originalFoldHeightFactor*3;
//                           });
//                         }
//                         print('switched to: $index');
//                       });
//                     },
//                   ),
//                 ),
//               ):Container(),
//
//               (timeLimitUnfold && hasTimeLimit == 1) ? Text(
//                 "Bis wie viel Uhr soll der Coupon gültig sein?",
//                 style: customStyleClass.getFontStyle3(),
//               ):Container(),
//
//               // Spacer
//               (timeLimitUnfold && hasTimeLimit == 1) ?SizedBox(
//                 height: screenHeight*0.02,
//               ):Container(),
//
//               // Dropdown
//               (timeLimitUnfold && hasTimeLimit == 1) ? SizedBox(
//                 width: screenWidth*0.5,
//                 child: hasTimeLimit == 1? SizedBox(
//                   child:
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       SizedBox(
//                         width: screenWidth*0.2,
//                         child: CupertinoPicker(
//                             scrollController: _fixedExtentScrollController1,
//                             itemExtent: 50,
//                             onSelectedItemChanged: (int index){
//                               setState(() {
//                                 selectedFirstElement = index;
//                               });
//                             },
//                             children: List<Widget>.generate(24, (index){
//                               return Center(
//                                 child: Text(
//                                   index < 10 ?
//                                   "0${index.toString()}" :
//                                   index.toString(),
//                                   style: const TextStyle(
//                                       fontSize: 24
//                                   ),
//                                 ),
//                               );
//                             })
//                         ),
//                       ),
//                       const Text(
//                         ":",
//                         style: TextStyle(
//                             fontSize: 22
//                         ),
//                       ),
//                       SizedBox(
//                         width: screenWidth*0.2,
//                         child: CupertinoPicker(
//                             scrollController: _fixedExtentScrollController2,
//                             itemExtent: 50,
//                             onSelectedItemChanged: (int index){
//                               setState(() {
//                                 selectedSecondElement=index*15;
//                               });
//                             },
//                             children: List<Widget>.generate(4, (index){
//                               return Center(
//                                 child: Text(
//                                   index == 0 ?
//                                   "00" :
//                                   (index*15).toString(),
//                                   style: const TextStyle(
//                                       fontSize: 24
//                                   ),
//                                 ),
//                               );
//                             })
//                         ),
//                       ),
//                     ],
//                   ),
//                 ) :const Row(mainAxisAlignment: MainAxisAlignment.center,children: [],),
//               ): Container(),
//
//             ],
//           ),
//         ),
//       )
//
//     ],
//   );
// }
//
// Widget _buildUsageLimitTile(){
//   return Stack(
//     children: [
//
//       // Colorful accent
//       Container(
//         width: screenWidth*0.91,
//         height: screenHeight*(usageLimitTileHeightFactor+0.004),
//         decoration: BoxDecoration(
//             gradient: LinearGradient(
//                 begin: Alignment.bottomLeft,
//                 end: Alignment.bottomRight,
//                 colors: [
//                   Colors.grey[900]!,
//                   customStyleClass.primeColorDark.withOpacity(0.4)
//                 ],
//                 stops: const [0.6, 0.9]
//             ),
//             borderRadius: BorderRadius.circular(15)
//         ),
//       ),
//
//       // Colorful accent
//       Container(
//         width: screenWidth*0.91,
//         height: screenHeight*usageLimitTileHeightFactor,
//         decoration: BoxDecoration(
//             gradient: LinearGradient(
//                 begin: Alignment.topRight,
//                 end: Alignment.bottomRight,
//                 colors: [
//                   Colors.grey[900]!,
//                   customStyleClass.primeColorDark.withOpacity(0.2)
//                 ],
//                 stops: const [0.6, 0.9]
//             ),
//             borderRadius: BorderRadius.circular(
//                 15
//             )
//         ),
//       ),
//
//       // light grey highlight
//       Container(
//         width: screenWidth*0.89,
//         height: screenHeight*usageLimitTileHeightFactor,
//         decoration: BoxDecoration(
//             gradient: LinearGradient(
//                 begin: Alignment.topCenter,
//                 end: Alignment.bottomCenter,
//                 colors: [Colors.grey[600]!, Colors.grey[600]!],
//                 stops: const [0.1, 0.9]
//             ),
//             borderRadius: BorderRadius.circular(
//                 15
//             )
//         ),
//       ),
//
//       // light grey highlight
//       Padding(
//           padding: const EdgeInsets.only(
//               left:2
//           ),
//           child: Container(
//             width: screenWidth*0.9,
//             height: screenHeight*usageLimitTileHeightFactor,
//             decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                     begin: Alignment.topLeft,
//                     end: Alignment.topRight,
//                     colors: [Colors.grey[600]!, Colors.grey[900]!],
//                     stops: const [0.1, 0.9]
//                 ),
//                 borderRadius: BorderRadius.circular(
//                     15
//                 )
//             ),
//           )
//       ),
//
//       // main Div
//       Padding(
//         padding: const EdgeInsets.only(
//             left:2,
//             top: 2
//         ),
//         child: Container(
//           width: screenWidth*0.9,
//           height: screenHeight*usageLimitTileHeightFactor,
//           decoration: BoxDecoration(
//               gradient: LinearGradient(
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                   colors: [
//                     Colors.grey[800]!.withOpacity(0.7),
//                     Colors.grey[900]!
//                   ],
//                   stops: [0.1,0.9]
//               ),
//               borderRadius: BorderRadius.circular(
//                   15
//               )
//           ),
//           child: Column(
//             children: [
//
//               Container(
//                 width: screenWidth*0.8,
//                 padding: EdgeInsets.only(
//                     top: screenHeight*0.01
//                 ),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                         "Nutzungslimit",
//                         textAlign: TextAlign.left,
//                         style: customStyleClass.getFontStyle1Bold()
//                     ),
//                     IconButton(
//                       icon: Icon(
//                           usageLimitUnfold ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down
//                       ),
//                       onPressed: (){
//                         setState(() {
//                           if(usageLimitUnfold){
//                             usageLimitTileHeightFactor = originalDateTileHeightFactor;
//                             usageLimitUnfold = false;
//                           }else{
//                             if(hasUsageLimit == 1){
//                               usageLimitTileHeightFactor = originalDateTileHeightFactor*6;
//                             }else{
//                               usageLimitTileHeightFactor = originalDateTileHeightFactor*3.5;
//                             }
//                             usageLimitUnfold = true;
//                           }
//                         });
//                       },
//                     )
//                   ],
//                 ),
//               ),
//
//               // Spacer
//               usageLimitUnfold ?SizedBox(
//                 height: screenHeight*0.01,
//               ):Container(),
//
//               // White line
//               usageLimitUnfold ?
//               const Divider(
//                 height:10,
//                 thickness: 1,
//                 color: Colors.grey,
//                 // indent: screenWidth*0.06,
//                 // endIndent: screenWidth*0.75,
//               ): Container(),
//
//               // Spacer
//               usageLimitUnfold ?SizedBox(
//                 height: screenHeight*0.03,
//               ):Container(),
//
//               usageLimitUnfold ? Container(
//                 padding: const EdgeInsets.symmetric(
//                     horizontal: 10
//                 ),
//                 child: Text(
//                   "Darf der Coupon nur begrenzt oft genutzt werden?",
//                   textAlign: TextAlign.center,
//                   style: customStyleClass.getFontStyle3(),
//                 ),
//               ):Container(),
//
//               // Toggle switch
//               usageLimitUnfold ?SizedBox(
//                 width: screenWidth*0.4,
//                 height: screenHeight*0.1,
//                 child:  Center(
//                   child: ToggleSwitch(
//                     initialLabelIndex: hasUsageLimit,
//                     totalSwitches: 2,
//                     activeBgColor: [customStyleClass.primeColor],
//                     activeFgColor: Colors.white,
//                     inactiveBgColor: const Color(0xff11181f),
//                     labels: const [
//                       'Nein',
//                       'Ja',
//                     ],
//                     onToggle: (index) {
//                       setState(() {
//                         if(hasUsageLimit == 0){
//                           setState(() {
//                             hasUsageLimit = 1;
//                             usageLimitTileHeightFactor = originalFoldHeightFactor*6;
//                           });
//                         }else{
//                           setState(() {
//                             hasUsageLimit = 0;
//                             usageLimitTileHeightFactor = originalFoldHeightFactor*3.5;
//                           });
//                         }
//                         print('switched to: $index');
//                       });
//                     },
//                   ),
//                 ),
//               ):Container(),
//
//               (usageLimitUnfold && hasUsageLimit == 1) ? Text(
//                 "Wie oft darf der Coupon pro Person verwendet werden?",
//                 textAlign: TextAlign.center,
//                 style: customStyleClass.getFontStyle3(),
//               ):Container(),
//
//               // Spacer
//               (usageLimitUnfold && hasUsageLimit == 1)  ?SizedBox(
//                 height: screenHeight*0.02,
//               ):Container(),
//
//               // Textfield
//               (usageLimitUnfold && hasUsageLimit == 1) ? SizedBox(
//                 width: screenWidth*0.2,
//                 child: hasUsageLimit == 1 ?
//                 SizedBox(
//                   // width: screenWidth*0.1,
//                   child: TextField(
//                       textAlign: TextAlign.center,
//                       maxLength: 3,
//                       keyboardType: TextInputType.number,
//                       inputFormatters: [
//                         FilteringTextInputFormatter.digitsOnly
//                       ],
//                       decoration: const InputDecoration(
//                           border: OutlineInputBorder()
//                       ),
//                       controller: _discountNumberOfUsagesController,
//                       style: customStyleClass.sizeNumberFieldItem()
//                   ),
//                 ):Container(),
//               ):Container()
//             ],
//           ),
//         ),
//       )
//
//     ],
//   );
// }
//
// Widget _buildGenderTile(){
//   return Stack(
//     children: [
//
//       // Colorful accent
//       Container(
//         width: screenWidth*0.91,
//         height: screenHeight*(genderTileHeightFactor+0.004),
//         decoration: BoxDecoration(
//             gradient: LinearGradient(
//                 begin: Alignment.bottomLeft,
//                 end: Alignment.bottomRight,
//                 colors: [
//                   Colors.grey[900]!,
//                   customStyleClass.primeColorDark.withOpacity(0.4)
//                 ],
//                 stops: const [0.6, 0.9]
//             ),
//             borderRadius: BorderRadius.circular(15)
//         ),
//       ),
//
//       // Colorful accent
//       Container(
//         width: screenWidth*0.91,
//         height: screenHeight*genderTileHeightFactor,
//         decoration: BoxDecoration(
//             gradient: LinearGradient(
//                 begin: Alignment.topRight,
//                 end: Alignment.bottomRight,
//                 colors: [
//                   Colors.grey[900]!,
//                   customStyleClass.primeColorDark.withOpacity(0.2)
//                 ],
//                 stops: const [0.6, 0.9]
//             ),
//             borderRadius: BorderRadius.circular(
//                 15
//             )
//         ),
//       ),
//
//       // light grey highlight
//       Container(
//         width: screenWidth*0.89,
//         height: screenHeight*genderTileHeightFactor,
//         decoration: BoxDecoration(
//             gradient: LinearGradient(
//                 begin: Alignment.topCenter,
//                 end: Alignment.bottomCenter,
//                 colors: [Colors.grey[600]!, Colors.grey[600]!],
//                 stops: const [0.1, 0.9]
//             ),
//             borderRadius: BorderRadius.circular(
//                 15
//             )
//         ),
//       ),
//
//       // light grey highlight
//       Padding(
//           padding: const EdgeInsets.only(
//               left:2
//           ),
//           child: Container(
//             width: screenWidth*0.9,
//             height: screenHeight*genderTileHeightFactor,
//             decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                     begin: Alignment.topLeft,
//                     end: Alignment.topRight,
//                     colors: [Colors.grey[600]!, Colors.grey[900]!],
//                     stops: const [0.1, 0.9]
//                 ),
//                 borderRadius: BorderRadius.circular(
//                     15
//                 )
//             ),
//           )
//       ),
//
//       // main Div
//       Padding(
//         padding: const EdgeInsets.only(
//             left:2,
//             top: 2
//         ),
//         child: Container(
//           width: screenWidth*0.9,
//           height: screenHeight*genderTileHeightFactor,
//           decoration: BoxDecoration(
//               gradient: LinearGradient(
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                   colors: [
//                     Colors.grey[800]!.withOpacity(0.7),
//                     Colors.grey[900]!
//                   ],
//                   stops: [0.1,0.9]
//               ),
//               borderRadius: BorderRadius.circular(
//                   15
//               )
//           ),
//           child: Column(
//             children: [
//
//               Container(
//                 width: screenWidth*0.8,
//                 padding: EdgeInsets.only(
//                     top: screenHeight*0.01
//                 ),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                         "Geschlecht",
//                         textAlign: TextAlign.left,
//                         style: customStyleClass.getFontStyle1Bold()
//                     ),
//                     IconButton(
//                       icon: Icon(
//                           genderUnfold ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down
//                       ),
//                       onPressed: (){
//                         setState(() {
//                           if(genderUnfold){
//                             genderTileHeightFactor = originalDateTileHeightFactor;
//                             genderUnfold = false;
//                           }else{
//                             genderTileHeightFactor = originalDateTileHeightFactor*3.5;
//                             genderUnfold = true;
//                           }
//                         });
//                       },
//                     )
//                   ],
//                 ),
//               ),
//
//               // Spacer
//               genderUnfold ?SizedBox(
//                 height: screenHeight*0.01,
//               ):Container(),
//
//               // White line
//               genderUnfold ?
//               const Divider(
//                 height:10,
//                 thickness: 1,
//                 color: Colors.grey,
//                 // indent: screenWidth*0.06,
//                 // endIndent: screenWidth*0.75,
//               ): Container(),
//
//               // Spacer
//               genderUnfold ?SizedBox(
//                 height: screenHeight*0.03,
//               ):Container(),
//
//               genderUnfold ? Text(
//                 "Welchen Geschlechtern soll der Coupon vorgeschlagen werden?",
//                 textAlign: TextAlign.center,
//                 style: customStyleClass.getFontStyle3(),
//               ):Container(),
//
//               // Spacer
//               genderUnfold ?SizedBox(
//                 height: screenHeight*0.03,
//               ):Container(),
//
//
//               // toggle yes,no: gender
//               genderUnfold ?
//               SizedBox(
//                 width: screenWidth*0.8,
//                 child:  Center(
//                   child: ToggleSwitch(
//                     initialLabelIndex: targetGender,
//                     totalSwitches: 3,
//                     activeBgColor: [customStyleClass.primeColor],
//                     activeFgColor: Colors.black,
//                     inactiveFgColor: customStyleClass.primeColor,
//                     inactiveBgColor: const Color(0xff11181f),
//                     labels: const [
//                       'Alle',
//                       'Männer',
//                       'Frauen',
//                     ],
//                     fontSize:
//                     customStyleClass.getFontSize4(),
//                     //screenHeight*stateProvider.getFontSizeFactor6(),
//                     minWidth: screenWidth*0.25,
//                     onToggle: (index) {
//                       setState(() {
//                         targetGender = index!;
//                         print('switched taget gender to: $index');
//                       });
//                     },
//                   ),
//                 ),
//               ):Container()
//
//             ],
//           ),
//         ),
//       )
//
//     ],
//   );
// }
//
// Widget _buildAgeLimitTile(){
//   return Stack(
//     children: [
//
//       // Colorful accent
//       Container(
//         width: screenWidth*0.91,
//         height: screenHeight*(ageLimitTileHeightFactor+0.004),
//         decoration: BoxDecoration(
//             gradient: LinearGradient(
//                 begin: Alignment.bottomLeft,
//                 end: Alignment.bottomRight,
//                 colors: [
//                   Colors.grey[900]!,
//                   customStyleClass.primeColorDark.withOpacity(0.4)
//                 ],
//                 stops: const [0.6, 0.9]
//             ),
//             borderRadius: BorderRadius.circular(15)
//         ),
//       ),
//
//       // Colorful accent
//       Container(
//         width: screenWidth*0.91,
//         height: screenHeight*ageLimitTileHeightFactor,
//         decoration: BoxDecoration(
//             gradient: LinearGradient(
//                 begin: Alignment.topRight,
//                 end: Alignment.bottomRight,
//                 colors: [
//                   Colors.grey[900]!,
//                   customStyleClass.primeColorDark.withOpacity(0.2)
//                 ],
//                 stops: const [0.6, 0.9]
//             ),
//             borderRadius: BorderRadius.circular(
//                 15
//             )
//         ),
//       ),
//
//       // light grey highlight
//       Container(
//         width: screenWidth*0.89,
//         height: screenHeight*ageLimitTileHeightFactor,
//         decoration: BoxDecoration(
//             gradient: LinearGradient(
//                 begin: Alignment.topCenter,
//                 end: Alignment.bottomCenter,
//                 colors: [Colors.grey[600]!, Colors.grey[600]!],
//                 stops: const [0.1, 0.9]
//             ),
//             borderRadius: BorderRadius.circular(
//                 15
//             )
//         ),
//       ),
//
//       // light grey highlight
//       Padding(
//           padding: const EdgeInsets.only(
//               left:2
//           ),
//           child: Container(
//             width: screenWidth*0.9,
//             height: screenHeight*ageLimitTileHeightFactor,
//             decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                     begin: Alignment.topLeft,
//                     end: Alignment.topRight,
//                     colors: [Colors.grey[600]!, Colors.grey[900]!],
//                     stops: const [0.1, 0.9]
//                 ),
//                 borderRadius: BorderRadius.circular(
//                     15
//                 )
//             ),
//           )
//       ),
//
//       // main Div
//       Padding(
//         padding: const EdgeInsets.only(
//             left:2,
//             top: 2
//         ),
//         child: Container(
//           width: screenWidth*0.9,
//           height: screenHeight*ageLimitTileHeightFactor,
//           decoration: BoxDecoration(
//               gradient: LinearGradient(
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                   colors: [
//                     Colors.grey[800]!.withOpacity(0.7),
//                     Colors.grey[900]!
//                   ],
//                   stops: [0.1,0.9]
//               ),
//               borderRadius: BorderRadius.circular(
//                   15
//               )
//           ),
//           child: Column(
//             children: [
//
//               // Text + Icon
//               Container(
//                 width: screenWidth*0.8,
//                 padding: EdgeInsets.only(
//                     top: screenHeight*0.01
//                 ),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                         "Alter",
//                         textAlign: TextAlign.left,
//                         style: customStyleClass.getFontStyle1Bold()
//                     ),
//                     IconButton(
//                       icon: Icon(
//                           ageLimitUnfold ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down
//                       ),
//                       onPressed: (){
//                         setState(() {
//                           if(ageLimitUnfold){
//                             ageLimitTileHeightFactor = originalDateTileHeightFactor;
//                             ageLimitUnfold = false;
//                           }else{
//                             if(hasAgeLimit == 1){
//                               ageLimitTileHeightFactor = originalDateTileHeightFactor*7.5;
//                             }else{
//                               ageLimitTileHeightFactor = originalDateTileHeightFactor*3.5;
//                             }
//                             ageLimitUnfold = true;
//                           }
//                         });
//                       },
//                     )
//                   ],
//                 ),
//               ),
//
//               // Spacer
//               ageLimitUnfold ?SizedBox(
//                 height: screenHeight*0.01,
//               ):Container(),
//
//               // White line
//               ageLimitUnfold ?
//               const Divider(
//                 height:10,
//                 thickness: 1,
//                 color: Colors.grey,
//                 // indent: screenWidth*0.06,
//                 // endIndent: screenWidth*0.75,
//               ): Container(),
//
//               // Spacer
//               ageLimitUnfold ?SizedBox(
//                 height: screenHeight*0.03,
//               ):Container(),
//
//               // Question
//               ageLimitUnfold ? Text(
//                 "Soll es eine Altersbeschränkung geben?",
//                 textAlign: TextAlign.center,
//                 style: customStyleClass.getFontStyle3(),
//               ):Container(),
//
//               // Toggle switch
//               ageLimitUnfold ?SizedBox(
//                 width: screenWidth*0.4,
//                 height: screenHeight*0.1,
//                 child:  Center(
//                   child: ToggleSwitch(
//                     initialLabelIndex: hasAgeLimit,
//                     totalSwitches: 2,
//                     activeBgColor: [customStyleClass.primeColor],
//                     activeFgColor: Colors.black,
//                     inactiveFgColor: customStyleClass.primeColor,
//                     inactiveBgColor: const Color(0xff11181f),
//                     labels: const [
//                       'Nein',
//                       'Ja',
//                     ],
//                     onToggle: (index) {
//                       setState(() {
//                         if(hasAgeLimit == 0){
//                           setState(() {
//                             hasAgeLimit = 1;
//                             ageLimitTileHeightFactor = originalDateTileHeightFactor*7.5;
//                           });
//                         }else{
//                           setState(() {
//                             hasAgeLimit = 0;
//                             ageLimitTileHeightFactor = originalDateTileHeightFactor*3.5;
//                           });
//                         }
//                       });
//                     },
//                   ),
//                 ),
//               ):Container(),
//
//               // Spacer
//               ageLimitUnfold ?SizedBox(
//                 height: screenHeight*0.01,
//               ):Container(),
//
//               // Question
//               (ageLimitUnfold && hasAgeLimit == 1) ? Text(
//                 "Ab welchem Alter soll die Beschränkung gelten?",
//                 textAlign: TextAlign.center,
//                 style: customStyleClass.getFontStyle3(),
//               ):Container(),
//
//               // Spacer
//               (ageLimitUnfold && hasAgeLimit == 1) ?SizedBox(
//                 height: screenHeight*0.02,
//               ):Container(),
//
//               // Textfield
//               (ageLimitUnfold && hasAgeLimit == 1) ?SizedBox(
//                 width: screenWidth*0.2,
//                 child: hasAgeLimit == 1 ?
//                 SizedBox(
//                   // width: screenWidth*0.1,
//                   child: TextField(
//                       textAlign: TextAlign.center,
//                       maxLength: 3,
//                       keyboardType: TextInputType.number,
//                       inputFormatters: [
//                         FilteringTextInputFormatter.digitsOnly
//                       ],
//                       controller: _discountAgeLimitController,
//                       decoration: const InputDecoration(
//                           border: OutlineInputBorder()
//                       ),
//                       style: customStyleClass.sizeNumberFieldItem()
//                   ),
//                 ):Container(),
//               ):Container(),
//
//               // Spacer
//               (ageLimitUnfold && hasAgeLimit == 1) ?SizedBox(
//                 height: screenHeight*0.03,
//               ):Container(),
//
//               // Question
//               (ageLimitUnfold && hasAgeLimit == 1) ? Text(
//                 "Soll die Beschränkung ab oder bis zu diesem Alter gelten?",
//                 textAlign: TextAlign.center,
//                 style: customStyleClass.getFontStyle3(),
//               ):Container(),
//
//               // Spacer
//               (ageLimitUnfold && hasAgeLimit == 1) ?SizedBox(
//                 height: screenHeight*0.03,
//               ):Container(),
//
//               // toggle yes,no: ageLimitIsUpperLimit
//               ageLimitUnfold ? hasAgeLimit == 1 ?
//               SizedBox(
//                 width: screenWidth*0.8,
//                 child:  Center(
//                   child: ToggleSwitch(
//                     initialLabelIndex: ageLimitIsUpperLimit,
//                     totalSwitches: 2,
//                     activeBgColor: [customStyleClass.primeColor],
//                     activeFgColor: Colors.black,
//                     inactiveFgColor: customStyleClass.primeColor,
//                     inactiveBgColor: const Color(0xff11181f),
//                     labels: const [
//                       'Ab diesem Alter',
//                       'Bis zu diesem Alter',
//                     ],
//                     fontSize:
//                     customStyleClass.getFontSize4(),
//                     //screenHeight*stateProvider.getFontSizeFactor6(),
//                     minWidth: screenWidth*0.45,
//                     onToggle: (index) {
//                       setState(() {
//                         ageLimitIsUpperLimit = index!;
//                       });
//                     },
//                   ),
//                 ),
//               ):Container():Container(),
//
//             ],
//           ),
//         ),
//       )
//
//     ],
//   );
// }
//
// Widget _buildDescriptionTile(){
//   return Stack(
//     children: [
//
//       // Colorful accent
//       Container(
//         width: screenWidth*0.91,
//         height: screenHeight*(descriptionTileHeightFactor+0.004),
//         decoration: BoxDecoration(
//             gradient: LinearGradient(
//                 begin: Alignment.bottomLeft,
//                 end: Alignment.bottomRight,
//                 colors: [
//                   Colors.grey[900]!,
//                   customStyleClass.primeColorDark.withOpacity(0.4)
//                 ],
//                 stops: const [0.6, 0.9]
//             ),
//             borderRadius: BorderRadius.circular(15)
//         ),
//       ),
//
//       // Colorful accent
//       Container(
//         width: screenWidth*0.91,
//         height: screenHeight*descriptionTileHeightFactor,
//         decoration: BoxDecoration(
//             gradient: LinearGradient(
//                 begin: Alignment.topRight,
//                 end: Alignment.bottomRight,
//                 colors: [
//                   Colors.grey[900]!,
//                   customStyleClass.primeColorDark.withOpacity(0.2)
//                 ],
//                 stops: const [0.6, 0.9]
//             ),
//             borderRadius: BorderRadius.circular(
//                 15
//             )
//         ),
//       ),
//
//       // light grey highlight
//       Container(
//         width: screenWidth*0.89,
//         height: screenHeight*descriptionTileHeightFactor,
//         decoration: BoxDecoration(
//             gradient: LinearGradient(
//                 begin: Alignment.topCenter,
//                 end: Alignment.bottomCenter,
//                 colors: [Colors.grey[600]!, Colors.grey[600]!],
//                 stops: const [0.1, 0.9]
//             ),
//             borderRadius: BorderRadius.circular(
//                 15
//             )
//         ),
//       ),
//
//       // light grey highlight
//       Padding(
//           padding: const EdgeInsets.only(
//               left:2
//           ),
//           child: Container(
//             width: screenWidth*0.9,
//             height: screenHeight*descriptionTileHeightFactor,
//             decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                     begin: Alignment.topLeft,
//                     end: Alignment.topRight,
//                     colors: [Colors.grey[600]!, Colors.grey[900]!],
//                     stops: const [0.1, 0.9]
//                 ),
//                 borderRadius: BorderRadius.circular(
//                     15
//                 )
//             ),
//           )
//       ),
//
//       // main Div
//       Padding(
//         padding: const EdgeInsets.only(
//             left:2,
//             top: 2
//         ),
//         child: Container(
//           width: screenWidth*0.9,
//           height: screenHeight*descriptionTileHeightFactor,
//           decoration: BoxDecoration(
//               gradient: LinearGradient(
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                   colors: [
//                     Colors.grey[800]!.withOpacity(0.7),
//                     Colors.grey[900]!
//                   ],
//                   stops: [0.1,0.9]
//               ),
//               borderRadius: BorderRadius.circular(
//                   15
//               )
//           ),
//           child: Column(
//             children: [
//
//               Container(
//                 width: screenWidth*0.8,
//                 padding: EdgeInsets.only(
//                     top: screenHeight*0.01
//                 ),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                         "Beschreibung",
//                         textAlign: TextAlign.left,
//                         style: customStyleClass.getFontStyle1Bold()
//                     ),
//                     IconButton(
//                       icon: Icon(
//                           descriptionUnfold ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down
//                       ),
//                       onPressed: (){
//                         setState(() {
//                           if(descriptionUnfold){
//                             descriptionTileHeightFactor = originalDateTileHeightFactor;
//                             descriptionUnfold = false;
//                           }else{
//                             descriptionTileHeightFactor = originalDateTileHeightFactor*7;
//                             descriptionUnfold = true;
//                           }
//                         });
//                       },
//                     )
//                   ],
//                 ),
//               ),
//
//               // Spacer
//               descriptionUnfold ?SizedBox(
//                 height: screenHeight*0.01,
//               ):Container(),
//
//               // White line
//               descriptionUnfold ?
//               const Divider(
//                 height:10,
//                 thickness: 1,
//                 color: Colors.grey,
//                 // indent: screenWidth*0.06,
//                 // endIndent: screenWidth*0.75,
//               ): Container(),
//
//               // Spacer
//               descriptionUnfold ?SizedBox(
//                 height: screenHeight*0.03,
//               ):Container(),
//
//               descriptionUnfold ? Text(
//                 "Erzähl deinen Kunden ein wenig über den Coupon!",
//                 textAlign: TextAlign.center,
//                 style: customStyleClass.getFontStyle3(),
//               ):Container(),
//
//               // Spacer
//               descriptionUnfold ?SizedBox(
//                 height: screenHeight*0.03,
//               ):Container(),
//
//
//               descriptionUnfold ? SizedBox(
//                 width: screenWidth*0.8,
//                 child: TextField(
//                   controller: _discountDescriptionController,
//                   keyboardType: TextInputType.multiline,
//                   maxLines: null,
//                   decoration: const InputDecoration(
//                       border: OutlineInputBorder()
//                   ),
//                   maxLength: 300,
//                   minLines: 10,
//                   style:customStyleClass.getFontStyle4(),
//                 ),
//               ):Container(),
//
//
//             ],
//           ),
//         ),
//       )
//
//     ],
//   );
// }
//
// Widget _buildTemplateTile(){
//   return Stack(
//     children: [
//
//       // Colorful accent
//       Container(
//         width: screenWidth*0.91,
//         height: screenHeight*(templateTileHeightFactor+0.004),
//         decoration: BoxDecoration(
//             gradient: LinearGradient(
//                 begin: Alignment.bottomLeft,
//                 end: Alignment.bottomRight,
//                 colors: [
//                   Colors.grey[900]!,
//                   customStyleClass.primeColorDark.withOpacity(0.4)
//                 ],
//                 stops: const [0.6, 0.9]
//             ),
//             borderRadius: BorderRadius.circular(15)
//         ),
//       ),
//
//       // Colorful accent
//       Container(
//         width: screenWidth*0.91,
//         height: screenHeight*templateTileHeightFactor,
//         decoration: BoxDecoration(
//             gradient: LinearGradient(
//                 begin: Alignment.topRight,
//                 end: Alignment.bottomRight,
//                 colors: [
//                   Colors.grey[900]!,
//                   customStyleClass.primeColorDark.withOpacity(0.2)
//                 ],
//                 stops: const [0.6, 0.9]
//             ),
//             borderRadius: BorderRadius.circular(
//                 15
//             )
//         ),
//       ),
//
//       // light grey highlight
//       Container(
//         width: screenWidth*0.89,
//         height: screenHeight*templateTileHeightFactor,
//         decoration: BoxDecoration(
//             gradient: LinearGradient(
//                 begin: Alignment.topCenter,
//                 end: Alignment.bottomCenter,
//                 colors: [Colors.grey[600]!, Colors.grey[600]!],
//                 stops: const [0.1, 0.9]
//             ),
//             borderRadius: BorderRadius.circular(
//                 15
//             )
//         ),
//       ),
//
//       // light grey highlight
//       Padding(
//           padding: const EdgeInsets.only(
//               left:2
//           ),
//           child: Container(
//             width: screenWidth*0.9,
//             height: screenHeight*templateTileHeightFactor,
//             decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                     begin: Alignment.topLeft,
//                     end: Alignment.topRight,
//                     colors: [Colors.grey[600]!, Colors.grey[900]!],
//                     stops: const [0.1, 0.9]
//                 ),
//                 borderRadius: BorderRadius.circular(
//                     15
//                 )
//             ),
//           )
//       ),
//
//       // main Divhttps://drive.google.com/drive/folders/1oqke5-nK3PtNWRZ1MboS9tTc7ruCbocL?usp=drive_linkmänn
//       Padding(
//         padding: const EdgeInsets.only(
//             left:2,
//             top: 2
//         ),
//         child: Container(
//           width: screenWidth*0.9,
//           height: screenHeight*templateTileHeightFactor,
//           decoration: BoxDecoration(
//               gradient: LinearGradient(
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                   colors: [
//                     Colors.grey[800]!.withOpacity(0.7),
//                     Colors.grey[900]!
//                   ],
//                   stops: [0.1,0.9]
//               ),
//               borderRadius: BorderRadius.circular(
//                   15
//               )
//           ),
//           child: Column(
//             children: [
//
//               // Text+Icon
//               Container(
//                 width: screenWidth*0.8,
//                 padding: EdgeInsets.only(
//                     top: screenHeight*0.01
//                 ),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                         "Vorlage",
//                         textAlign: TextAlign.left,
//                         style: customStyleClass.getFontStyle1Bold()
//                     ),
//                     IconButton(
//                       icon: Icon(
//                           templateUnfold ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down
//                       ),
//                       onPressed: (){
//                         setState(() {
//                           if(templateUnfold){
//                             templateTileHeightFactor = originalFoldHeightFactor;
//                             templateUnfold = false;
//                           }else{
//                             templateTileHeightFactor = originalFoldHeightFactor*3.5;
//                             templateUnfold = true;
//                           }
//                         });
//                       },
//                     )
//                   ],
//                 ),
//               ),
//
//               // Spacer
//               templateUnfold ?SizedBox(
//                 height: screenHeight*0.01,
//               ):Container(),
//
//               // White line
//               templateUnfold ?
//               const Divider(
//                 height:10,
//                 thickness: 1,
//                 color: Colors.grey,
//                 // indent: screenWidth*0.06,
//                 // endIndent: screenWidth*0.75,
//               ): Container(),
//
//               // Spacer
//               templateUnfold ?SizedBox(
//                 height: screenHeight*0.03,
//               ):Container(),
//
//               // Explanation
//               templateUnfold ? Container(
//                   padding: const EdgeInsets.symmetric(
//                       horizontal: 10
//                   ),
//                   child: Text(
//                     "Möchtest du den Coupon als Vorlage speichern?",
//                     textAlign: TextAlign.center,
//                     style: customStyleClass.getFontStyle3(),
//                   )
//               ):Container(),
//
//               // Spacer
//               templateUnfold ?SizedBox(
//                 height: screenHeight*0.03,
//               ):Container(),
//
//               // Toggle
//               templateUnfold ?SizedBox(
//                 width: screenWidth*0.4,
//                 height: screenHeight*0.1,
//                 child:  Center(
//                   child: ToggleSwitch(
//                     initialLabelIndex: isSupposedToBeTemplate,
//                     totalSwitches: 2,
//                     activeBgColor: [customStyleClass.primeColor],
//                     activeFgColor: Colors.black,
//                     inactiveFgColor: customStyleClass.primeColor,
//                     inactiveBgColor: const Color(0xff11181f),
//                     labels: const [
//                       'Nein',
//                       'Ja',
//                     ],
//                     onToggle: (index) {
//                       setState(() {
//                         isSupposedToBeTemplate == 0 ? isSupposedToBeTemplate = 1 : isSupposedToBeTemplate = 0;
//                       });
//                     },
//                   ),
//                 ),
//               ):Container(),
//
//             ],
//           ),
//         ),
//       )
//     ],
//   );
// }