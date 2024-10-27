class ClubOpenStatus{

  // returns a status, (0: closed, 1: going to open, 2: open, 3: open, but closes soon) and the time to display.

  ClubOpenStatus({
    required this.openingStatus,
    required this.textToDisplay
  });

  String textToDisplay;
  int openingStatus;

}