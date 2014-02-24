import QtQuick 2.0

Rectangle {
    id: menuPage
    property string title: qsTr('Teacher Notebook');
    property int esquirolGraphicalUnit: 100

    signal openPage (string page)
    property int globalDistance: height / 10

    ListView {
        anchors.fill: parent
        anchors.margins: menuPage.globalDistance
        clip: true
        model: ListModel { id: mainMenuModel }
        delegate: Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            height: menuPage.globalDistance
            anchors.margins: menuPage.globalDistance
            border.color: "green"
            color: "#d5ffcc"
            Text {
                anchors.centerIn: parent
                text: title
            }
            MouseArea {
                anchors.fill: parent
                onClicked: menuPage.openPage(page)
            }
        }

        Component.onCompleted: {
            mainMenuModel.append({title: qsTr('Anotacions'), page: 'Annotations.qml'});
            mainMenuModel.append({title: qsTr('Agenda'), page: 'Schedule.qml'});
            mainMenuModel.append({title: qsTr('Pissarra'), page: 'Whiteboard.qml'});
            mainMenuModel.append({title: qsTr('! Sistema de fitxers'), page: 'Filesystem.qml'});
            mainMenuModel.append({title: qsTr('! Recerca de coneixement'), page: 'Researcher.qml'});
            mainMenuModel.append({title: qsTr('! Document XML'), page: 'XmlViewer.qml'});
            mainMenuModel.append({title: qsTr('! Documents'), page: 'DocumentsList.qml'});
            mainMenuModel.append({title: qsTr('! Rellotge'), page: 'TimeController.qml'});
            mainMenuModel.append({title: qsTr('Gestio de dades'), page: 'DataMan.qml'});
        }
    }
}
