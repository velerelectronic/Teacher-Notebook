import QtQuick 2.0

Rectangle {
   id: stopWatch
   property int esquirolGraphicalUnit: 100
   width: 200
   height: timer.height * 2
   anchors.margins: 20
   color: 'green'

   Text {
       id: timer
       anchors.centerIn: parent
       text: "0:00:00.0"
       font.pointSize: 24
       color: 'white'
   }
   Rectangle {
       anchors.right: parent.right
       width: timer.height
       anchors.top: parent.top
       anchors.bottom: parent.bottom
       color: '#ff0000'
       Text {
           id: timerButton
           anchors.centerIn: parent
           text: 'Start'
           color: 'yellow'
           font.bold: true
       }
       MouseArea {
           anchors.fill: parent
           onClicked: stopWatch.timerStartStop()
       }

   }

   function timerStartStop() {
       if (chronoTimer.running) {
           chronoTimer.stop();
           timerButton.text = qsTr('Start!');
       } else {
           chronoTimer.startChrono();
           timerButton.text = qsTr('Stop!');
       }
   }

   Timer {
       id: chronoTimer
       property variant startTime: 0

       running: false
       repeat: true
       interval: 10
       triggeredOnStart: true
       onTriggered: chronoTimer.updateChrono()

       function startChrono() {
           chronoTimer.start();
           startTime = (new Date()).valueOf();
       }

       function updateChrono() {
           var end = (new Date()).valueOf();
           var diff = new Date(end - startTime);

           var msec = diff.getMilliseconds()
           var sec = diff.getSeconds()
           var min = diff.getMinutes()
           var hr = diff.getHours()-1;
           if (min < 10){
               min = "0" + min
           }
           if (sec < 10){
               sec = "0" + sec
           }
           if(msec < 10){
               msec = "00" +msec
           }
           else if(msec < 100){
               msec = "0" +msec
           }
           timer.text = hr + ':' + min + ':' + sec + '.' + msec;
       }
   }
}
