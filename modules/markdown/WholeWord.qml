import QtQuick 2.7

Generic {
    requiredHeight: mainText.contentHeight
    requiredWidth: mainText.contentWidth

    property alias color: mainText.color
    property string text: ''

    Text {
        id: mainText
        anchors.fill: parent

        text: parent.text
    }
}
