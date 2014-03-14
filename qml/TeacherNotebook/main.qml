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

    property string lastRequestedPage: ''

    Common.UseUnits { id: units }

    ColumnLayout {
        anchors.fill: parent

        Rectangle {
            id: header
            Layout.fillWidth: true
            Layout.preferredHeight: units.nailUnit * 4

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
                    Layout.preferredHeight: parent.height
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
                onOpenPageArgs: openSubPage(page,args)

                // Annotations
                onOpenAnnotations: openSubPage('AnnotationsList',{})
                onEditAnnotation: openSubPage('AnnotationEditor',{idAnnotation: id, annotation: annotation, desc: desc})
                onDeletedAnnotations: {
                    messageBox.publishMessage(qsTr("S'han esborrat ") + num + qsTr(' anotacions'));
                }
                onSavedAnnotation: {
                    messageBox.publishMessage('Anotació desada: títol «' + annotation + '», descripció «' + desc + '»')
                    openSubPage('AnnotationsList',{});
                }
                onCanceledAnnotation: {
                    if (changes) {
                        messageBox.publishMessage(qsTr("S'han descartat els canvis en l'anotació"))
                    }
                    forceOpenSubPage('AnnotationsList',{});
                }

                onOpenDocumentsList: openSubPage('DocumentsList',{})

                // Events
                onNewEvent: openSubPage('EditEvent',{})
                onEditEvent: {
                    openSubPage('EditEvent',{idEvent: id, event: event,desc: desc,startDate: startDate,startTime: startTime,endDate: endDate,endTime: endTime});
                }
                onDeletedEvents: {
                    messageBox.publishMessage(qsTr("S'han esborrat ") + num + qsTr(' esdeveniments'))
                }
                onSavedEvent: {
                    messageBox.publishMessage(qsTr('Esdeveniment desat: títol «') + event + qsTr('», descripcio «') + desc + qsTr('»'))
                    forceOpenSubPage('Schedule',{})
                }
                onCanceledEvent: {
                    if (changes) {
                        messageBox.publishMessage(qsTr("S'han descartat els canvis a l'esdeveniment"))
                    }
                    forceOpenSubPage('Schedule',{})
                }

                // Editors
                onAcceptedCloseEditorRequest: {
                    console.log(lastRequestedPage)
                    forceOpenSubPage(lastRequestedPage,{})
                }
                onRefusedCloseEditorRequest: messageBox.publishMessage(qsTr("Encara hi ha canvis sense desar! Desa'ls o descarta'ls abans."))
            }
        }
    }
    Common.MessageBox {
        id: messageBox
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: units.nailUnit

        color: 'yellow'
        border.color: 'black'
        radius: units.nailUnit
        internalMargins: units.nailUnit
        fontSize: units.nailUnit
        interval: 2000
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
        openSubPage('MenuPage',{})
    }

    function forceOpenSubPage(page,param) {
        pageLoader.setSource(page + '.qml', param);
        title.text = pageLoader.item.pageTitle;
    }

    function openSubPage (page, param) {
        console.log('Open subpage: ' + page)
        var cont = false;
        lastRequestedPage = page;
        try {
            pageLoader.item.requestCloseEditor();
        }
        catch(err) {
            cont = true;
        }
        if (cont) {
            forceOpenSubPage(page,param)
        }
    }
}

