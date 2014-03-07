// Licenses:
// Image: http://pixabay.com/es/peque%C3%B1os-bellota-dibujos-animados-41255/

import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Layouts 1.1
import 'common' as Common
import "Storage.js" as Storage

Rectangle {
    id: mainApp

    signal openAnnotations
    signal openPage(string page)

    Common.UseUnits { id: units }

    ColumnLayout {
        anchors.fill: parent

        Rectangle {
            id: header
            Layout.fillWidth: true
            Layout.preferredHeight: units.nailUnit * 4
            anchors.margins: units.nailUnit * 4

            color: "#009900"
            visible: true
            clip: false
            z: 1

            RowLayout {
                anchors.fill: parent

                Image {
                    Layout.preferredWidth: units.fingerUnit
                    Layout.preferredHeight: units.fingerUnit
                    source: 'res/small-41255.svg'
                    fillMode: Image.PreserveAspectFit
                }
                Text {
                    id: title
                    Layout.fillWidth: true
                    color: "#ffffff"
                    text: "Teacher Notebook"
                    font.italic: false
                    font.bold: true
                    font.pixelSize: units.nailUnit * 2
                    verticalAlignment: Text.AlignVCenter
                    font.family: "Tahoma"
                    MouseArea {
                        anchors.fill: parent
                        onClicked: mainApp.openMainPage()
                    }
                }
                Button {
                    id: exit
                    Layout.preferredWidth: units.fingerUnit
                    Layout.preferredHeight: units.fingerUnit
                    anchors.verticalCenter: parent.verticalCenter
                    text: qsTr("Surt")
                    onClicked: {
                        Qt.quit();
                    }
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
                onOpenPage: openSubPage(page,{})
                onOpenAnnotations: openSubPage('Annotations.qml',{})
                onOpenDocumentsList: openSubPage('DocumentsList.qml',{})
                onNewEvent: openSubPage('EditEvent.qml',{})
                onEditEvent: {
                    console.log('id: ' + id + '-' + event + '-' + desc + '-' + startDate + '-' + startTime + '-' + endDate + '-' + endTime);
                    openSubPage('EditEvent.qml',{idEvent: id, event: event,desc: desc,startDate: startDate,startTime: startTime,endDate: endDate,endTime: endTime});
                }
                onSaveEvent: openSubPage('Schedule.qml',{})
                onCancelEvent: openSubPage('Schedule.qml',{})
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
            Layout.preferredHeight: units.fingerUnit
            Layout.fillWidth: true
        }

    }
    Component.onCompleted: {
//        Storage.destroyDatabase();
//        Storage.removeAnnotationsTable();
        Storage.initDatabase();
        Storage.createEducationTables();
        mainApp.openMainPage();
        Storage.exportDatabaseToText();
    }

    function openMainPage() {
        openSubPage('MenuPage.qml',{})
    }

    function openSubPage (page, param) {
        pageLoader.setSource(page, param);
        title.text = pageLoader.item.title
    }
}

