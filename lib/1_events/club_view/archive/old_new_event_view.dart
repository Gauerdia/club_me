// Widget _buildNavigationBar(){
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
//         // Main Background
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
//         (isVideo || isImage) ? Padding(
//           padding: const EdgeInsets.only(),
//           child: _buildButtonRow(),
//         ) : Container(),
//
//         // Right button
//         isUploading ? Padding(
//           padding: EdgeInsets.only(
//               right: screenWidth*0.05,
//               bottom: screenHeight*0.03
//           ),
//           child: const Align(
//             alignment: AlignmentDirectional.bottomEnd,
//             child: CircularProgressIndicator(),
//           ),
//         ): (isVideo == false && isImage == false) ? Padding(
//           padding: EdgeInsets.only(
//               top: screenHeight*0.02
//             // right: screenWidth*0.04,
//             // bottom: screenHeight*0.015,
//           ),
//           child: Align(
//               alignment: AlignmentDirectional.center,
//               child: GestureDetector(
//                 child: Container(
//                   padding: EdgeInsets.symmetric(
//                       horizontal: screenWidth*0.055,
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
//                         stops: [0.2, 0.9]
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
//                     genreScreenActive ? "Speichern" : "Abschicken",
//                     style: customStyleClass.getFontStyle4Bold(),
//                   ),
//                 ),
//                 onTap: () => iterateScreen(),
//               )
//           ),
//         ): Container()
//       ],
//
//     ),
//   );
// }
//
// Widget _buildCheckOverview(){
//
//   _fixedExtentScrollController1 = FixedExtentScrollController(initialItem: selectedFirstElement);
//   _fixedExtentScrollController2 = FixedExtentScrollController(initialItem: selectedSecondElement);
//
//   return SizedBox(
//       height: screenHeight,
//       child: Stack(
//         children: [
//
//           // Main view
//           SingleChildScrollView(
//             keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
//             child: Column(
//               children: [
//
//                 // Events headline
//                 Container(
//                   width: screenWidth*0.9,
//                   padding: EdgeInsets.symmetric(
//                       vertical: screenHeight*0.04,
//                       horizontal: screenWidth*0.02
//                   ),
//                   child: Text(
//                     "Bitte gib die passenden Daten zu deinem Event an!",
//                     textAlign: TextAlign.center,
//                     style: customStyleClass.getFontStyle2Bold(),
//                   ),
//                 ),
//
//                 // Spacer
//                 SizedBox(
//                   height: screenHeight*0.05,
//                 ),
//
//                 _buildTitleTile(),
//
//                 // Spacer
//                 SizedBox(
//                   height: screenHeight*0.05,
//                 ),
//
//                 _buildDJTile(),
//
//                 // Spacer
//                 SizedBox(
//                   height: screenHeight*0.05,
//                 ),
//
//                 _buildDateTile(),
//
//                 // Spacer
//                 SizedBox(
//                   height: screenHeight*0.05,
//                 ),
//
//                 _buildPriceTile(),
//
//                 // Spacer
//                 SizedBox(
//                   height: screenHeight*0.05,
//                 ),
//
//                 _buildDescriptionTile(),
//
//                 // Spacer
//                 SizedBox(
//                   height: screenHeight*0.05,
//                 ),
//
//                 _buildGenresTile(),
//
//                 // Spacer
//                 SizedBox(
//                   height: screenHeight*0.05,
//                 ),
//
//                 _buildContentTile(),
//
//                 // Spacer
//                 SizedBox(
//                   height: screenHeight*0.05,
//                 ),
//
//                 isFromTemplate ? Container() : _buildTemplateTile(),
//
//                 // Spacer
//                 SizedBox(
//                   height: screenHeight*0.2,
//                 ),
//
//               ],
//             ),
//           ),
//
//           // opacity shadow
//
//           // window to ask for hours and minutes
//           // if(!pickHourAndMinuteIsActive)
//           Container(
//             width: screenWidth*0.4,
//             height: screenHeight*0.3,
//             color: Colors.red,
//           )
//
//         ],
//       )
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
//                             titleTileHeightFactor = originalFoldHeightFactor;
//                             titleUnfold = false;
//                           }else{
//                             titleTileHeightFactor = originalFoldHeightFactor*3.5;
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
//                 // indent: screenWidth*0.06,
//                 // endIndent: screenWidth*0.75,
//               ): Container(),
//
//               // Spacer
//               titleUnfold ?SizedBox(
//                 height: screenHeight*0.03,
//               ):Container(),
//
//               titleUnfold ? Text(
//                 "Wie soll das Event heißen?",
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
//                   controller: _eventTitleController,
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
// Widget _buildDJTile(){
//   return Stack(
//     children: [
//
//       // Colorful accent
//       Container(
//         width: screenWidth*0.91,
//         height: screenHeight*(djTileHeightFactor+0.004),
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
//         height: screenHeight*djTileHeightFactor,
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
//         height: screenHeight*djTileHeightFactor,
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
//             height: screenHeight*djTileHeightFactor,
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
//           height: screenHeight*djTileHeightFactor,
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
//                         "DJ",
//                         textAlign: TextAlign.left,
//                         style: customStyleClass.getFontStyle1Bold()
//                     ),
//                     IconButton(
//                       icon: Icon(
//                           djUnfold ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down
//                       ),
//                       onPressed: (){
//                         setState(() {
//                           if(djUnfold){
//                             djTileHeightFactor = originalFoldHeightFactor;
//                             djUnfold = false;
//                           }else{
//                             djTileHeightFactor = originalFoldHeightFactor*3.5;
//                             djUnfold = true;
//                           }
//                         });
//                       },
//                     )
//                   ],
//                 ),
//               ),
//
//               // Spacer
//               djUnfold ?SizedBox(
//                 height: screenHeight*0.01,
//               ):Container(),
//
//               // White line
//               djUnfold ?
//               const Divider(
//                 height:10,
//                 thickness: 1,
//                 color: Colors.grey,
//                 // indent: screenWidth*0.06,
//                 // endIndent: screenWidth*0.75,
//               ): Container(),
//
//               // Spacer
//               djUnfold ?SizedBox(
//                 height: screenHeight*0.03,
//               ):Container(),
//
//               djUnfold ? Text(
//                 "Wie heißt der DJ auf diesem Event?",
//                 style: customStyleClass.getFontStyle3(),
//               ):Container(),
//
//               // Spacer
//               djUnfold ?SizedBox(
//                 height: screenHeight*0.02,
//               ):Container(),
//
//               // Textfield
//               djUnfold ? Container(
//                 width: screenWidth*0.8,
//                 child: TextField(
//                   controller: _eventDJController,
//                   decoration: const InputDecoration(
//                     hintText: "z.B. DJ Guetta",
//                     label: Text("DJ-Name(n)"),
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
//                         "Datum und Uhrzeit",
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
//                             dateTileHeightFactor = originalFoldHeightFactor;
//                             dateUnfold = false;
//                           }else{
//                             dateTileHeightFactor = originalFoldHeightFactor*5;
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
//                 "Wann soll das Event stattfinden?",
//                 style: customStyleClass.getFontStyle3(),
//               ):Container(),
//
//               // Spacer
//               dateUnfold ?SizedBox(
//                 height: screenHeight*0.02,
//               ):Container(),
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
//               // Spacer
//               dateUnfold ?SizedBox(
//                 height: screenHeight*0.02,
//               ):Container(),
//
//               dateUnfold ? Text(
//                 "Um wie viel Uhr beginnt das Event?",
//                 style: customStyleClass.getFontStyle3(),
//               ):Container(),
//
//               // Spacer
//               dateUnfold ?SizedBox(
//                 height: screenHeight*0.02,
//               ):Container(),
//
//               // Starting hour
//               dateUnfold ?SizedBox(
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//
//                     SizedBox(
//                       width: screenWidth*0.2,
//                       child: CupertinoPicker(
//                           scrollController: _fixedExtentScrollController1,
//                           itemExtent: 50,
//                           onSelectedItemChanged: (int index){
//                             setState(() {
//                               selectedFirstElement = index;
//                             });
//                           },
//                           children: List<Widget>.generate(24, (index){
//                             return Center(
//                               child: Text(
//                                 index < 10 ?
//                                 "0${index.toString()}" :
//                                 index.toString(),
//                                 style: const TextStyle(
//                                     fontSize: 24
//                                 ),
//                               ),
//                             );
//                           })
//                       ),
//                     ),
//                     const Text(
//                       ":",
//                       style: TextStyle(
//                           fontSize: 22
//                       ),
//                     ),
//                     SizedBox(
//                       width: screenWidth*0.2,
//                       child: CupertinoPicker(
//                           scrollController: _fixedExtentScrollController2,
//                           itemExtent: 50,
//                           onSelectedItemChanged: (int index){
//                             setState(() {
//                               selectedSecondElement=index*15;
//                             });
//                           },
//                           children: List<Widget>.generate(4, (index){
//                             return Center(
//                               child: Text(
//                                 index == 0
//                                     ? "00"
//                                     :(index*15).toString(),
//                                 style: const TextStyle(
//                                     fontSize: 24
//                                 ),
//                               ),
//                             );
//                           })
//                       ),
//                     ),
//                   ],
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
// Widget _buildPriceTile(){
//   return Stack(
//     children: [
//
//       // Colorful accent
//       Container(
//         width: screenWidth*0.91,
//         height: screenHeight*(priceTileHeightFactor+0.004),
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
//         height: screenHeight*priceTileHeightFactor,
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
//         height: screenHeight*priceTileHeightFactor,
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
//             height: screenHeight*priceTileHeightFactor,
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
//           height: screenHeight*priceTileHeightFactor,
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
//                         "Preis",
//                         textAlign: TextAlign.left,
//                         style: customStyleClass.getFontStyle1Bold()
//                     ),
//                     IconButton(
//                       icon: Icon(
//                           priceUnfold ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down
//                       ),
//                       onPressed: (){
//                         setState(() {
//                           if(priceUnfold){
//                             priceTileHeightFactor = originalFoldHeightFactor;
//                             priceUnfold = false;
//                           }else{
//                             priceTileHeightFactor = originalFoldHeightFactor*3.5;
//                             priceUnfold = true;
//                           }
//                         });
//                       },
//                     )
//                   ],
//                 ),
//               ),
//
//               // Spacer
//               priceUnfold ?SizedBox(
//                 height: screenHeight*0.01,
//               ):Container(),
//
//               // White line
//               priceUnfold ?
//               const Divider(
//                 height:10,
//                 thickness: 1,
//                 color: Colors.grey,
//                 // indent: screenWidth*0.06,
//                 // endIndent: screenWidth*0.75,
//               ): Container(),
//
//               // Spacer
//               priceUnfold ?SizedBox(
//                 height: screenHeight*0.03,
//               ):Container(),
//
//               priceUnfold ? Text(
//                 "Wie teuer soll das Event sein?",
//                 style: customStyleClass.getFontStyle3(),
//               ):Container(),
//
//               // Spacer
//               priceUnfold ?SizedBox(
//                 height: screenHeight*0.02,
//               ):Container(),
//
//               // Textfield
//               priceUnfold ? Container(
//                 width: screenWidth*0.4,
//                 child: TextField(
//                   controller: _eventPriceController,
//                   keyboardType: TextInputType.number,
//                   decoration: const InputDecoration(
//                       border: OutlineInputBorder()
//                   ),
//                   style: customStyleClass.getFontStyle4(),
//                   maxLength: 5,
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
// Widget _buildGenresTile(){
//   return Stack(
//     children: [
//
//       // Colorful accent
//       Container(
//         width: screenWidth*0.91,
//         height: screenHeight*(genreTileHeightFactor+0.004),
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
//         height: screenHeight*genreTileHeightFactor,
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
//         height: screenHeight*genreTileHeightFactor,
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
//             height: screenHeight*genreTileHeightFactor,
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
//           height: screenHeight*genreTileHeightFactor,
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
//                         "Musikrichtungen",
//                         textAlign: TextAlign.left,
//                         style: customStyleClass.getFontStyle1Bold()
//                     ),
//                     IconButton(
//                       icon: Icon(
//                           genresUnfold ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down
//                       ),
//                       onPressed: (){
//                         setState(() {
//                           if(genresUnfold){
//                             genreTileHeightFactor = originalFoldHeightFactor;
//                             genresUnfold = false;
//                           }else{
//                             genreTileHeightFactor = originalFoldHeightFactor*5.5;
//                             genresUnfold = true;
//                           }
//                         });
//                       },
//                     )
//                   ],
//                 ),
//               ),
//
//               // Spacer
//               genresUnfold ?SizedBox(
//                 height: screenHeight*0.01,
//               ):Container(),
//
//               // White line
//               genresUnfold ?
//               const Divider(
//                 height:10,
//                 thickness: 1,
//                 color: Colors.grey,
//                 // indent: screenWidth*0.06,
//                 // endIndent: screenWidth*0.75,
//               ): Container(),
//
//               // Spacer
//               genresUnfold ?SizedBox(
//                 height: screenHeight*0.03,
//               ):Container(),
//
//               genresUnfold ? musicGenresChosen.isEmpty ?
//               SizedBox(
//                 height: screenHeight*0.05,
//                 child: Center(
//                   child: Text(
//                       "Noch keine Genres ausgewählt.",
//                       style: customStyleClass.getFontStyle4()
//                   ),
//                 ),
//               ):Container(
//                   padding: EdgeInsets.only(
//                     // left: screenWidth*0.1
//                   ),
//                   width: screenWidth,
//                   child: Center(
//                     child:  Wrap(
//                       direction: Axis.horizontal,
//                       children: musicGenresChosen.map((item){
//                         return Row(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             Padding(
//                               padding: EdgeInsets.symmetric(
//                                   vertical: screenHeight*0.01,
//                                   horizontal: screenWidth*0.01
//                               ),
//                               child: GestureDetector(
//                                 child: Container(
//                                   padding: EdgeInsets.symmetric(
//                                       horizontal: screenWidth*0.035,
//                                       vertical: screenHeight*0.02
//                                   ),
//                                   decoration: BoxDecoration(
//                                     borderRadius: const BorderRadius.all(
//                                         Radius.circular(10)
//                                     ),
//                                     gradient: LinearGradient(
//                                         colors: [
//                                           customStyleClass.primeColorDark,
//                                           customStyleClass.primeColor,
//                                         ],
//                                         begin: Alignment.topLeft,
//                                         end: Alignment.bottomRight,
//                                         stops: const [0.2, 0.9]
//                                     ),
//                                     boxShadow: [
//                                       BoxShadow(
//                                         color: Colors.black54,
//                                         spreadRadius: 1,
//                                         blurRadius: 7,
//                                         offset: Offset(3, 3), // changes position of shadow
//                                       ),
//                                     ],
//                                   ),
//                                   child: Text(
//                                       item,
//                                       style: customStyleClass.getFontStyle6Bold()
//                                   ),
//                                 ),
//                                 onTap: (){
//                                   setState(() {
//                                     if(musicGenresToCompare.contains(item)){
//                                       musicGenresOffer.add(item);
//                                     }
//                                     musicGenresChosen.remove(item);
//                                     eventMusicGenresString.replaceFirst("$item,", "");
//                                   });
//                                 },
//                               ),
//                             )
//                           ],
//                         );
//                       }).toList(),
//                     ),
//                   )
//               ): Container(),
//
//               // Spacer
//               genresUnfold ?SizedBox(
//                 height: screenHeight*0.03,
//               ):Container(),
//
//               // Icon
//               genresUnfold ? GestureDetector(
//                 child: Container(
//                   padding: const EdgeInsets.all(
//                       5
//                   ),
//                   decoration: BoxDecoration(
//                       color: customStyleClass.primeColorDark,
//                       borderRadius: const BorderRadius.all(
//                           Radius.circular(45)
//                       ),
//                       border: Border.all(color: Colors.white)
//                   ),
//                   child: const Icon(
//                       Icons.add
//                   ),
//                 ),
//                 onTap: (){
//                   setState(() {
//                     genreScreenActive = true;
//                   });
//                 },
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
//                             descriptionTileHeightFactor = originalFoldHeightFactor;
//                             descriptionUnfold = false;
//                           }else{
//                             descriptionTileHeightFactor = originalFoldHeightFactor*7.5;
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
//               // Explanation
//               descriptionUnfold ? Container(
//                   padding: const EdgeInsets.symmetric(
//                       horizontal: 10
//                   ),
//                   child: Text(
//                     "Erzähl deinen Kunden ein wenig über das Event!",
//                     textAlign: TextAlign.center,
//                     style: customStyleClass.getFontStyle3(),
//                   )
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
//                   controller: _eventDescriptionController,
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
// Widget _buildContentTile(){
//   return Stack(
//     children: [
//
//       // Colorful accent
//       Container(
//         width: screenWidth*0.91,
//         height: screenHeight*(contentTileHeightFactor+0.004),
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
//         height: screenHeight*contentTileHeightFactor,
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
//         height: screenHeight*contentTileHeightFactor,
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
//             height: screenHeight*contentTileHeightFactor,
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
//           height: screenHeight*contentTileHeightFactor,
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
//                         "Bild/Video",
//                         textAlign: TextAlign.left,
//                         style: customStyleClass.getFontStyle1Bold()
//                     ),
//                     IconButton(
//                       icon: Icon(
//                           contentUnfold ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down
//                       ),
//                       onPressed: (){
//                         setState(() {
//                           if(contentUnfold){
//                             contentTileHeightFactor = originalFoldHeightFactor;
//                             contentUnfold = false;
//                           }else{
//                             contentTileHeightFactor = originalFoldHeightFactor*4;
//                             contentUnfold = true;
//                           }
//                         });
//                       },
//                     )
//                   ],
//                 ),
//               ),
//
//               // Spacer
//               contentUnfold ?SizedBox(
//                 height: screenHeight*0.01,
//               ):Container(),
//
//               // White line
//               contentUnfold ?
//               const Divider(
//                 height:10,
//                 thickness: 1,
//                 color: Colors.grey,
//                 // indent: screenWidth*0.06,
//                 // endIndent: screenWidth*0.75,
//               ): Container(),
//
//               // Spacer
//               contentUnfold ?SizedBox(
//                 height: screenHeight*0.03,
//               ):Container(),
//
//               // Explanation
//               (contentUnfold && file == null) ? Container(
//                   padding: const EdgeInsets.symmetric(
//                       horizontal: 10
//                   ),
//                   child: Text(
//                     "Möchtest du ein Bild oder ein Video für das Event hinzufügen?",
//                     textAlign: TextAlign.center,
//                     style: customStyleClass.getFontStyle3(),
//                   )
//               ):Container(),
//
//               // Spacer
//               contentUnfold ?SizedBox(
//                 height: screenHeight*0.03,
//               ):Container(),
//
//               // Add content icon
//               (contentUnfold && file == null) ? SizedBox(
//                 width: screenWidth*0.8,
//                 child: GestureDetector(
//                     child: Container(
//                         decoration: const BoxDecoration(
//                             shape: BoxShape.circle,
//                             color: Color(0xff11181f)
//                         ),
//                         child: const Padding(
//                           padding: EdgeInsets.only(bottom: 15),
//                           child: Center(
//                             child: GradientIcon(
//                               icon: Icons.add,
//                               gradient: LinearGradient(
//                                   colors: [Colors.teal, Colors.tealAccent],
//                                   begin: Alignment.topLeft,
//                                   end: Alignment.bottomRight,
//                                   stops: [0.5, 0.55]
//                               ),
//                               size: 40,
//                             ),
//                           ),
//                         )
//                     ),
//                     onTap: () => clickedOnChooseContent()
//                 ),
//               ):Container(),
//
//               // Show uploaded content
//               (contentUnfold && file != null) ? Container(
//                   padding: const EdgeInsets.symmetric(
//                       horizontal: 10
//                   ),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                     children: [
//
//                       // The image
//                       contentType == 1 ? GestureDetector(
//                         child: SizedBox(
//                           width: 100,
//                           child: Image.file(file!),
//                         ),
//                         onTap: (){
//                           setState(() {
//                             isImage = true;
//                           });
//                         },
//                       ):Container(),
//
//                       // Video screenshot
//                       contentType == 2 ? GestureDetector(
//                         child: Image.memory(screenshot!.buffer.asUint8List()),
//                         onTap: (){
//                           setState(() {
//                             isVideo = true;
//                           });
//                         },
//                       ):Container(),
//
//                       IconButton(onPressed: (){
//                         setState(() {
//                           file = null;
//                         });
//                       }, icon: const Icon(CupertinoIcons.trash, color: Colors.red, size: 42,))
//                     ],
//                   )
//               ):Container(),
//
//             ],
//           ),
//         ),
//       )
//     ],
//   );
// }
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
//       // main Div
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
//               (templateUnfold && file == null) ? Container(
//                   padding: const EdgeInsets.symmetric(
//                       horizontal: 10
//                   ),
//                   child: Text(
//                     "Möchtest du dieses Event als Vorlage speichern?",
//                     textAlign: TextAlign.center,
//                     style: customStyleClass.getFontStyle3(),
//                   )
//               ):Container(),
//
//               // Spacer
//               templateUnfold ?SizedBox(
//                 width: screenWidth*0.4,
//                 height: screenHeight*0.1,
//                 child:  Center(
//                   child: ToggleSwitch(
//                     initialLabelIndex: isTemplate,
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
//                         isTemplate == 0 ? isTemplate = 1 : isTemplate = 0;
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
//
// Widget _buildButtonRow(){
//   return Row(
//     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//     children: [
//
//       // Left button
//       Padding(
//         padding: EdgeInsets.only(
//             top: screenHeight*0.02
//           // right: screenWidth*0.04,
//           // bottom: screenHeight*0.015,
//         ),
//         child: Align(
//             alignment: AlignmentDirectional.center,
//             child: GestureDetector(
//               child: Container(
//                 padding: EdgeInsets.symmetric(
//                     horizontal: screenWidth*0.055,
//                     vertical: screenHeight*0.02
//                 ),
//                 decoration: BoxDecoration(
//                   borderRadius: const BorderRadius.all(
//                       Radius.circular(10)
//                   ),
//                   gradient: LinearGradient(
//                       colors: [
//                         customStyleClass.primeColorDark,
//                         customStyleClass.primeColor,
//                       ],
//                       begin: Alignment.topLeft,
//                       end: Alignment.bottomRight,
//                       stops: const [0.2, 0.9]
//                   ),
//                   boxShadow: const [
//                     BoxShadow(
//                       color: Colors.black54,
//                       spreadRadius: 1,
//                       blurRadius: 7,
//                       offset: Offset(3, 3), // changes position of shadow
//                     ),
//                   ],
//                 ),
//                 child: Text(
//                   "Abbrechen",
//                   style: customStyleClass.getFontStyle4Bold(),
//                 ),
//               ),
//               onTap: () => deselectContent(),
//             )
//         ),
//       ),
//
//       // right button
//       Padding(
//         padding: EdgeInsets.only(
//             top: screenHeight*0.02
//           // right: screenWidth*0.04,
//           // bottom: screenHeight*0.015,
//         ),
//         child: Align(
//             alignment: AlignmentDirectional.center,
//             child: GestureDetector(
//               child: Container(
//                 padding: EdgeInsets.symmetric(
//                     horizontal: screenWidth*0.055,
//                     vertical: screenHeight*0.02
//                 ),
//                 decoration: BoxDecoration(
//                   borderRadius: const BorderRadius.all(
//                       Radius.circular(10)
//                   ),
//                   gradient: LinearGradient(
//                       colors: [
//                         customStyleClass.primeColorDark,
//                         customStyleClass.primeColor,
//                       ],
//                       begin: Alignment.topLeft,
//                       end: Alignment.bottomRight,
//                       stops: const [0.2, 0.9]
//                   ),
//                   boxShadow: const [
//                     BoxShadow(
//                       color: Colors.black54,
//                       spreadRadius: 1,
//                       blurRadius: 7,
//                       offset: Offset(3, 3), // changes position of shadow
//                     ),
//                   ],
//                 ),
//                 child: Text(
//                   "Übernehmen",
//                   style: customStyleClass.getFontStyle4Bold(),
//                 ),
//               ),
//               onTap: () => selectContent(),
//             )
//         ),
//       ),
//
//     ],
//   );
// }
