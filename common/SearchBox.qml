import QtQuick 2.0

Rectangle {
    id: searchBox
    signal performSearch(string text)
    signal introPressed()
    property alias text: searchText.text

    width: 300
    height: units.fingerUnit
    radius: height / 2
    border.color: 'black'
    clip: true
    TextInput {
        id: searchText
        anchors.left: parent.left
        anchors.right: emptySearch.left
        anchors.leftMargin: searchBox.radius
        anchors.verticalCenter: parent.verticalCenter
        text: ''
        font.pixelSize: units.readUnit
        inputMethodHints: Qt.ImhNoPredictiveText
        onTextChanged: {
            waitTimer.restart();
        }
        onAccepted: {
            waitTimer.stop();
            searchBox.performSearch(searchText.text);
            searchBox.introPressed();
        }

        Text {
            id: toolTip
            visible: searchText.text == ''
            anchors.fill: parent
            anchors.verticalCenter: parent.verticalCenter
            text: 'Cerca...'
            font.pointSize: parent.font.pointSize
            font.family: parent.font.family
            color: 'gray'
        }
    }
    Text {
        id: emptySearch
        anchors {
            top: parent.top
            bottom: parent.bottom
            right: parent.right
            rightMargin: searchBox.radius
        }
        width: contentWidth
        text: 'X'
        verticalAlignment: Text.AlignVCenter
        font.pixelSize: units.readUnit
        MouseArea {
            anchors.fill: parent
            onClicked: searchText.text = ''
        }
    }

    Timer {
        id: waitTimer
        interval: 500
        running: false
        repeat: false
        onTriggered: {
            searchBox.performSearch(searchText.text);
            searchText.forceActiveFocus()
        }
    }
}
