import QtQuick 2.0
import 'common' as Common

Rectangle {
    id: menuPage
    property string title: qsTr('Teacher Notebook');
    property int esquirolGraphicalUnit: 100

    signal openPage (string page)

    Common.UseUnits { id: units }
    GridView {
        anchors.fill: parent
        anchors.margins: units.nailUnit
        clip: true
        model: ListModel { id: mainMenuModel }
        cellHeight: units.fingerUnit * 2 + units.nailUnit * 2
        cellWidth: units.fingerUnit * 4 + units.nailUnit * 2
        delegate: Rectangle {
            height: units.fingerUnit * 2
            width: units.fingerUnit * 4
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
            mainMenuModel.append({title: qsTr('Rellotge'), page: 'TimeController.qml'});
            mainMenuModel.append({title: qsTr('Gestor de dades'), page: 'DataMan.qml'});
        }
    }
}
