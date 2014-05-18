/* Licenses:

  CC0
  * Image: http://pixabay.com/es/peque%C3%B1os-bellota-dibujos-animados-41255/

  Altres:
  * http://pixabay.com/es/bloc-de-notas-nota-l%C3%A1piz-117597/
  * http://pixabay.com/es/pila-papeles-de-pila-notas-cuadro-156015/
  * http://pixabay.com/es/port%C3%A1til-oficina-por-escrito-151261/

*/


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
        spacing: 0

        Rectangle {
            id: header
            Layout.fillWidth: true
            Layout.preferredHeight: units.nailUnit * 5

            color: "#009900"
            visible: true
            clip: false
            z: 1

            RowLayout {
                anchors.fill: parent
                anchors.margins: units.nailUnit / 2

                Image {
                    Layout.preferredWidth: units.nailUnit * 4
                    Layout.preferredHeight: units.nailUnit * 4

                    source: 'res/small-41255_150.png'
                    fillMode: Image.PreserveAspectFit
                    MouseArea {
                        anchors.fill: parent
                        onClicked: mainApp.openMainPage()
                    }
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

        ListView {
            id: pageList
            Layout.fillWidth: true
            Layout.fillHeight: true
            orientation: ListView.Horizontal
            snapMode: ListView.SnapToItem
            highlightFollowsCurrentItem: true
            highlightRangeMode: ListView.StrictlyEnforceRange
            highlightMoveDuration: 500

            model: ListModel {
                id: pageModel
            }

            onCurrentIndexChanged: {
                console.log('Current item' + currentItem.showTitle)
//                title.text = pageList.currentItem.pageTitle
            }

            delegate: Rectangle {
                width: pageList.width
                height: pageList.height
                border.color: 'black'
                color: 'yellow'
                property bool showTitle: false
                onShowTitleChanged: {
                    if (showTitle) {
                        title.text = pageLoader.item.pageTitle
                        showTitle = false
                    }
                }

                Loader {
                    id: pageLoader
                    anchors.fill: parent
                    source: page + '.qml'
                    Connections {
                        target: pageLoader.item
                        ignoreUnknownSignals: true
                        // Signals
                        onOpenPage: openSubPage(page,{})
                        onOpenPageArgs: openSubPage(page,args)

                        // Annotations
                        onOpenAnnotations: openSubPage('AnnotationsList',{})
                        onEditAnnotation: openSubPage('ShowAnnotation',{idAnnotation: id, annotation: annotation, desc: desc})
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
                        onNewEvent: openSubPage('ShowEvent',{})
                        onEditEvent: {
                            openSubPage('ShowEvent',{idEvent: id, event: event,desc: desc,startDate: startDate,startTime: startTime,endDate: endDate,endTime: endTime});
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
                            forceOpenSubPage(lastRequestedPage,{})
                        }
                        onRefusedCloseEditorRequest: messageBox.publishMessage(qsTr("Encara hi ha canvis sense desar! Desa'ls o descarta'ls abans."))
                    }
                }
            }
        }

        /*
        Loader {
            id: pageLoader
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: false

            Connections {
                target: pageLoader.item
                ignoreUnknownSignals: true
            }
        }
        */
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

    function forceOpenSubPage(page,param,ident) {
//        pageLoader.setSource(page + '.qml', param);
//        title.text = pageLoader.item.pageTitle;
        pageModel.append({page: page, parameters: param, identification: ident});
        pageList.currentIndex = pageModel.count-1;
    }

    function openSubPage (page, param, ident) {
        var i=0;
        var found=false;
        while ((i<pageModel.count) && (!found)) {
            var obj = pageModel.get(i);
            if ((obj.page == page) && (obj.identification == ident))
                found = true;
            else
                i++;
        }

        console.log('Open subpage ' + page + ' with ' + param.toString());
        if (!found) {
            forceOpenSubPage(page,param,ident)
        } else {
            pageList.currentIndex = i;
            // Open existing page
        }
    }
}

