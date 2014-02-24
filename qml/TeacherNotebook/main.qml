import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Layouts 1.1
import "Storage.js" as Storage

ColumnLayout {
    id: mainApp
    property int esquirolGraphicalUnit: Math.min(width,height) / 10

    signal openAnnotations
    signal openPage(string page)

    Rectangle {
        id: header
        Layout.fillWidth: true
        height: title.height * 2
        color: "#009900"
        visible: true
        clip: false
        z: 1

        Text {
            id: title
            anchors.verticalCenter: parent.verticalCenter
            color: "#ffffff"
            text: "Teacher Notebook"
            anchors.left: parent.left
            anchors.leftMargin: 10
            font.italic: false
            font.bold: true
            font.pointSize: 32
            verticalAlignment: Text.AlignVCenter
            font.family: "Tahoma"
            MouseArea {
                anchors.fill: parent
                onClicked: mainApp.openMainPage()
            }
        }
        Button {
            id: exit
            width: 50
            height: 50
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            text: "Surt"
            anchors.rightMargin: 10
            anchors.topMargin: 10
            anchors.bottomMargin: 10
            onClicked: {
                Qt.quit();
            }
        }
    }

    Loader {
        id: pageLoader
        Layout.fillWidth: true
        Layout.fillHeight: true

        Connections {
            target: pageLoader.item
            ignoreUnknownSignals: true
            // Signals
            onOpenPage: openSubPage(page)
            onOpenAnnotations: openSubPage('Annotations.qml')
            onOpenDocumentsList: openSubPage('DocumentsList.qml')
            onNewEvent: openSubPage('EditEvent.qml')
            onEditEvent: {
                console.log('id: ' + id);
                openSubPage('EditEvent.qml',{idEvent: id, title: event,desc: desc,startDate: startDate,startTime: startTime,endDate: endDate,endTime: endTime});
            }
            onSaveEvent: openSubPage('Schedule.qml')
            onCancelEvent: openSubPage('Schedule.qml')
        }
    }

    Menu {
        id: mainMenu
        title: 'Menú Teacher Notebook'

        MenuItem {
            text: qsTr("Inicial")
//            onTriggered:
        }

        MenuItem {
            text: qsTr("Anotacions")
        }
        MenuItem {
            text: qsTr("Valoracions")
        }
        MenuItem {
            text: qsTr("Documents")
        }
        MenuItem {
            text: qsTr("Rellotge")
        }
        enabled: true
    }

    StatusBar {
        id: statusBar
        height: 50
        Layout.fillWidth: true
    }

    /*
    ArisenWidget {
        anchors.centerIn: parent

        Rectangle {
            width: 50
            height: 50
            anchors.centerIn: parent
            color: "yellow"
        }
    }
    */
    Component.onCompleted: {
//        Storage.destroyDatabase();
//        Storage.removeAnnotationsTable();
        Storage.initDatabase();
        Storage.createEducationTables();
        mainApp.openMainPage();
        Storage.exportDatabaseToText();
    }

    function openMainPage() {
        openSubPage('MenuPage.qml')
    }

    function openSubPage (page) {
        pageLoader.setSource(page,{ esquirolGraphicalUnit: mainApp.esquirolGraphicalUnit });
        title.text = pageLoader.item.title
    }
}
