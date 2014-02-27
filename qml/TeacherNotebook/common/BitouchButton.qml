import QtQuick 2.0
import '../common' as Common

Rectangle {
    id: bitouch
    Common.UseUnits { id: units }
    signal upClicked
    signal downClicked
    signal upLongClicked
    signal downLongClicked

    property alias content: label.text

    height: units.fingerUnit * 2
    border.color: 'black'

    Rectangle {
        id: upPlus
        anchors.top: parent.top
        height: units.nailUnit
        anchors.left: parent.left
        anchors.right: parent.right
        border.color: 'black'
        color: '#eeeeee'
        Text {
            anchors.fill: parent
            font.pixelSize: units.nailUnit
            text: '+'
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
    }

    Rectangle {
        id: upHalf
        anchors.top: upPlus.bottom
        anchors.bottom: parent.verticalCenter
        anchors.left: parent.left
        anchors.right: parent.right
        color: '#eeeeee'
    }

    Rectangle {
        id: downHalf
        anchors.top: parent.verticalCenter
        anchors.bottom: downMinus.top
        anchors.left: parent.left
        anchors.right: parent.right
        color: '#cccccc'
    }

    Rectangle {
        id: downMinus
        anchors.bottom: parent.bottom
        height: units.nailUnit
        anchors.left: parent.left
        anchors.right: parent.right
        color: '#cccccc'
        Text {
            anchors.fill: parent
            font.pixelSize: units.nailUnit
            text: '-'
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
        border.color: 'black'
    }

    MouseArea {
        anchors.top: upPlus.top
        anchors.bottom: upHalf.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        onClicked: bitouch.upClicked()
        onPressAndHold: bitouch.upLongClicked()
    }
    MouseArea {
        anchors.top: downHalf.top
        anchors.bottom: downMinus.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        onClicked: bitouch.downClicked()
        onPressAndHold: bitouch.downLongClicked()
    }
    Text {
        id: label
        anchors.top: upHalf.top
        anchors.bottom: downHalf.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        font.pixelSize: units.fingerUnit
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }
}
