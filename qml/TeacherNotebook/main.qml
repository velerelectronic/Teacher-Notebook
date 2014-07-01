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
        id: column
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
                        onClicked: {
                            if (pageListModel.count==0)
                                openMainPage();
                        }
                    }
                }
                Text {
                    id: title
                    Layout.fillWidth: true
                    Layout.preferredHeight: parent.height
                    color: "#ffffff"
                    text: (pageList.currentItem)?pageList.currentItem.pageTitle:"Teacher Notebook"
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
            boundsBehavior: Flickable.StopAtBounds
            snapMode: ListView.SnapOneItem
            model: ListModel { id: pageListModel }
            delegate: widgetDelegate
        }

        Component {
            id: widgetDelegate

            Rectangle {
                id: widgetRect
                width: pageList.width
                height: pageList.height
                //anchors.left: pageList.left
                //anchors.right: pageList.right
                color: 'white'

                property string pageTitle: (pageLoader.item)?pageLoader.item.pageTitle:''
                property bool canClose: (pageLoader.item && pageLoader.item.canClose)?pageLoader.item.canClose:false
                clip: true

                Loader {
                    id: pageLoader
                    anchors.fill: parent
                    source: model.page + '.qml'

                    Connections {
                        target: pageLoader.item
                        ignoreUnknownSignals: true
                        // Signals
                        onOpenPage: openSubPage(page,{})
                        onOpenPageArgs: openSubPage(page,args)

                        // Annotations
                        onOpenAnnotations: openSubPage('AnnotationsList',{},'')
                        onEditAnnotation: openSubPage('ShowAnnotation',{idAnnotation: id, annotation: annotation, desc: desc},id)
                        onDeletedAnnotations: {
                            messageBox.publishMessage(qsTr("S'han esborrat ") + num + qsTr(' anotacions'));
                        }
                        onSavedAnnotation: {
                            messageBox.publishMessage('Anotació desada: títol «' + annotation + '», descripció «' + desc + '»')
                            removeCurrentPage();
                        }
                        onCanceledAnnotation: {
                            if (changes) {
                                messageBox.publishMessage(qsTr("S'han descartat els canvis en l'anotació"))
                            }
                            removeCurrentPage();
                        }

                        onOpenDocumentsList: openSubPage('DocumentsList',{},'')

                        // Events
                        onNewEvent: openSubPage('ShowEvent',{},'')
                        onEditEvent: {
                            openSubPage('ShowEvent',{idEvent: id, event: event,desc: desc,startDate: startDate,startTime: startTime,endDate: endDate,endTime: endTime},id);
                        }
                        onDeletedEvents: {
                            messageBox.publishMessage(qsTr("S'han esborrat ") + num + qsTr(' esdeveniments'))
                        }
                        onSavedEvent: {
                            messageBox.publishMessage(qsTr('Esdeveniment desat: títol «') + event + qsTr('», descripcio «') + desc + qsTr('»'))
                            removeCurrentPage();
                        }
                        onCanceledEvent: {
                            if (changes) {
                                messageBox.publishMessage(qsTr("S'han descartat els canvis a l'esdeveniment"))
                            }
                            removeCurrentPage();
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
        openSubPage('MenuPage',{});
    }

    function forceOpenSubPage(page,param,ident) {

    }

    function openSubPage (page, param) {
        pageListModel.append({page: page, parameters: param});
    }
}

