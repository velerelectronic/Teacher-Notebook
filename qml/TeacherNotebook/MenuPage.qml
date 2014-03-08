import QtQuick 2.0
import 'common' as Common

Rectangle {
    id: menuPage
    property string pageTitle: qsTr('Teacher Notebook');

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
            mainMenuModel.append({title: qsTr('Anotacions'), page: 'AnnotationsList'});
            mainMenuModel.append({title: qsTr('Agenda'), page: 'Schedule'});
            mainMenuModel.append({title: qsTr('Pissarra'), page: 'Whiteboard'});
            mainMenuModel.append({title: qsTr('! Sistema de fitxers'), page: 'Filesystem'});
            mainMenuModel.append({title: qsTr('! Recerca de coneixement'), page: 'Researcher'});
            mainMenuModel.append({title: qsTr('! Document XML'), page: 'XmlViewer'});
            mainMenuModel.append({title: qsTr('! Documents'), page: 'DocumentsList'});
            mainMenuModel.append({title: qsTr('Rellotge'), page: 'TimeController'});
            mainMenuModel.append({title: qsTr('Gestor de dades'), page: 'DataMan'});
        }
    }
}
