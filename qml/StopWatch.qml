import QtQuick 2.0
import QtQuick.Layouts 1.1
import 'qrc:///common' as Common


Rectangle {
    id: stopWatch
    color: 'green'

    Common.UseUnits { id: units }

    states: [
        State {
            name: 'started'
            PropertyChanges { target: timerButton; color: 'red'; label: qsTr('Stop!') }
        },
        State {
            name: 'stopped'
            PropertyChanges { target: timerButton; color: 'blue'; label: qsTr('Start!') }
        }
    ]
    state: 'stopped'

    RowLayout {
        anchors.fill: parent
        Text {
            id: timer
            Layout.preferredHeight: parent.height
            Layout.fillWidth: true

            text: "0:00:00.0"
            fontSizeMode: Text.Fit
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            color: 'white'
        }
        Rectangle {
            id: timerButton
            Layout.preferredHeight: parent.height
            Layout.preferredWidth: parent.height
            color: '#ff0000'
            property alias label: text.text
            Text {
                id: text
                anchors.fill: parent
                text: 'Start!'
                fontSizeMode: Text.HorizontalFit
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                color: 'yellow'
                font.bold: true
            }
            MouseArea {
                anchors.fill: parent
                onClicked: stopWatch.timerStartStop()
            }

        }
    }

    function timerStartStop() {
        if (chronoTimer.running) {
            chronoTimer.stop();
            stopWatch.state = 'stopped';
        } else {
            chronoTimer.startChrono();
            stopWatch.state = 'started'
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
