import QtQuick 2.0
import QtQuick.Layouts 1.1

Rectangle {
    property var weekDays: ['diumenge','dilluns','dimarts','dimecres','dijous','divendres','dissabte']
    property var monthNames: ['gener', 'febrer', 'març', 'abril', 'maig', 'juny', 'juliol', 'agost', 'setembre', 'octubre', 'novembre', 'desembre']
    height: childrenRect.height
    radius: units.fingerUnit

    ColumnLayout {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: parent.radius
        spacing: units.nailUnit
        Text {
            id: clock
            Layout.fillWidth: true
            Layout.preferredHeight: Math.max(contentHeight,units.fingerUnit)
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            font.pixelSize: units.readUnit
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        }
        Text {
            id: calendar
            Layout.fillWidth: true
            Layout.preferredHeight: Math.max(contentHeight,units.fingerUnit)
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            font.pixelSize: units.readUnit
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        }
    }

    Timer {
        function zeroPrefixPad(number) {
            return ((number<10)?'0':'') + number;
        }

        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            var now = new Date();
            clock.text = (now.getHours()) + ':' + zeroPrefixPad(now.getMinutes()) + ':' + zeroPrefixPad(now.getSeconds());
            calendar.text = weekDays[now.getDay()] + ' ' + (now.getDate()) + ' de ' + monthNames[now.getMonth()] + ' de ' + now.getFullYear();
        }
    }
}
