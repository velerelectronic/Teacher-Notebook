import QtQuick 2.0
import QtQuick.Layouts 1.1
import 'common' as Common

Rectangle {
    id: mainClock

    Common.UseUnits { id: units }

    border.color: 'green'
    border.width: units.nailUnit / 2
    color: 'black'

    Text {
        id: time
        color: 'white'
        fontSizeMode: Text.Fit
        font.bold: true
        anchors.fill: parent
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }

    Timer {
        id: waitTimer
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: mainClock.updateClock()
    }

    function updateClock() {
        var tempsara = new Date ();

        var hores = tempsara.getHours( );
        var minuts = tempsara.getMinutes( );
        var segons = tempsara.getSeconds( );

        // Pad the minutes and seconds with leading zeros, if required
        minuts = ( minuts < 10 ? "0" : "" ) + minuts;
        segons = ( segons < 10 ? "0" : "" ) + segons;

        // Choose either "AM" or "PM" as appropriate
        var timeOfDay = ( hores < 12 ) ? "AM" : "PM";

        // Convert the hours component to 12-hour format if needed
        hores = ( hores > 12 ) ? hores - 12 : hores;

        // Convert an hours component of "0" to "12"
        hores = ( hores == 0 ) ? 12 : hores;

        // Compose the string for display
        var cadenaTemps = hores + ":" + minuts + ":" + segons + " " + timeOfDay;

        // Update the time display
        time.text = cadenaTemps;
    }

}
