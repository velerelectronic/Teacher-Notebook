import QtQuick 2.0

Generic {
    property string text: ''
    property string address: ''
    requiredWidth: mainText.contentWidth
    requiredHeight: mainText.contentHeight

    WholeWord {
        id: mainText

        anchors.fill: parent
        //font.pixelSize: units.readUnit

        //wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        text: parent.text
    }
    MouseArea {
        anchors.fill: parent
    }
}
