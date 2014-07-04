import QtQuick 2.0

Rectangle {
    id: searchBox
    signal performSearch(string text)
    property alias text: searchText.text

    width: 300
    height: 40
    radius: height / 2
    border.color: 'black'
    clip: true
    TextInput {
        id: searchText
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: searchBox.radius
        anchors.rightMargin: searchBox.radius
        anchors.verticalCenter: parent.verticalCenter
        text: ''
        font.pointSize: 20
        inputMethodHints: Qt.ImhNoPredictiveText
        onTextChanged: {
            waitTimer.restart();
            toolTip.visible = (searchText.text == '')?true:false
        }
        onAccepted: searchBox.performSearch(searchText.text)

        Text {
            id: toolTip
            anchors.fill: parent
            anchors.verticalCenter: parent.verticalCenter
            text: 'Cerca...'
            font.pointSize: parent.font.pointSize
            font.family: parent.font.family
            color: 'gray'
        }
    }
    Timer {
        id: waitTimer
        interval: 500
        running: false
        onTriggered: searchBox.performSearch(searchText.text)
    }
}
