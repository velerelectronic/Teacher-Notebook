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
                            if (pageList.model.count==0)
                                openMainPage();
                            (pageList.state == 'onewidget')?minimizeAllWidgets():maximizeCurrentWidget();
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

        GridView {
            id: pageList
            Layout.fillWidth: true
            Layout.fillHeight: true

            states: [
                State {
                    name: 'onewidget'
                    PropertyChanges {
                        target: pageList
                        interactive: false
                    }
                },
                State {
                    name: 'tableofwidgets'
                    PropertyChanges {
                        target: pageList
                        interactive: true
                    }
                }
            ]
            state: 'onewidget'
            snapMode: GridView.NoSnap

            highlightMoveDuration: 500
            highlightFollowsCurrentItem: true
            highlightRangeMode: GridView.ApplyRange
            onCurrentIndexChanged: {
                console.log('Changed index ' + pageList.currentIndex);
            }

            cellHeight: Math.round(height * 0.3)
            cellWidth: Math.round(width * 0.3)

            model: ListModel {
                id: pageModel
            }

            highlight: Rectangle {
                width: pageList.width
                height: pageList.height
                color: 'yellow'
            }

            delegate: widgetDelegate

            add: Transition {
                NumberAnimation { properties: "opacity"; from: 0; to: 1.0; duration: 500 }
            }
            remove: Transition {
                NumberAnimation { properties: "opacity"; from: 1.0; to: 0; duration: 1000 }
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

    Component {
        id: widgetDelegate
        Rectangle {
            id: widgetRect
            width: pageList.width
            height: pageList.height
            border.color: 'blue'
            border.width: units.nailUnit

            scale: 0.3
            transformOrigin: Item.TopLeft

            color: 'white'

            property string pageTitle: (pageLoader.item)?pageLoader.item.pageTitle:''
            property bool canClose: (pageLoader.item && pageLoader.item.canClose)?pageLoader.item.canClose:false
            clip: true

            states: [
                State {
                    name: 'maximized'
                    ParentChange {
                        target: pageLoader
                        parent: pageList
                        scale: 1
                    }
                },
                State {
                    name: 'twowidgets'
                },
                State {
                    name: 'minimized'
                    ParentChange {
                        target: pageLoader
                        parent: widgetRect
                    }
                }
            ]
            state: widgetState
            onStateChanged: console.log('nou estat: ' + widgetRect.state)

            transitions: [
                Transition {
                    ParentAnimation {
                        NumberAnimation { properties: 'scale'; easing.type: Easing.InOutQuad }
                        NumberAnimation { properties: 'x,y'; easing.type: Easing.InOutQuad; }
                    }
                }
            ]

            MouseArea {
                anchors.fill: parent
                z: 2
                onClicked: {
                    if (widgetRect.state == 'minimized') {
                        mouse.accepted = true;
                        pageList.currentIndex = index;
                        maximizeCurrentWidget();
                    }
                    else
                        mouse.accepted = false;
                }
                onPressAndHold: {
                    if (widgetRect.state == 'minimized') {
                        mouse.accepted = true;
                        removeCurrentPage(index);
                    }
                }
            }

            Loader {
                id: pageLoader
                anchors.fill: parent
                Component.onCompleted: {
                    pageLoader.setSource(page + '.qml', parameters);
                }

                Connections {
                    target: pageLoader.item
                    ignoreUnknownSignals: true
                    // Signals
                    onOpenPage: openSubPage(page,{},'')
                    onOpenPageArgs: openSubPage(page,args,'')

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

    Component.onCompleted: {
//        Storage.destroyDatabase();
//        Storage.removeAnnotationsTable();
        Storage.initDatabase();
        Storage.createEducationTables();
        mainApp.openMainPage();
        pageList.model.setProperty(0,'widgetState','maximized');
        Storage.exportDatabaseToText();
    }

    function openMainPage() {
        openSubPage('MenuPage',{})
    }

    function forceOpenSubPage(page,param,ident) {
        pageModel.append({page: page, parameters: param, identification: ident, widgetState: 'maximized'});
        pageList.currentIndex = pageModel.count-1;
        console.log('obrint ' + pageList.currentIndex);
    }

    function openSubPage (page, param, ident) {
        minimizeAllWidgets();
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
        maximizeCurrentWidget();
    }

    function removeCurrentPage(index) {
        minimizeAllWidgets();
        pageModel.remove(index);
        // maximizeCurrentWidget();
    }

    function minimizeAllWidgets() {
        pageList.state = 'tableofwidgets';
        for (var i=0; i<pageList.model.count; i++) {
            console.log('Canviant tots estats de ' + pageList.model.get(i).page + pageList.model.get(i).widgetState);
            pageList.model.setProperty(i,'widgetState','minimized');
        }
    }

    function maximizeCurrentWidget() {
        pageList.state = 'onewidget';
        if (!pageList.currentIndex)
            pageList.currentIndex = 0;
        pageList.model.setProperty(pageList.currentIndex,'widgetState','maximized');
        var obj = pageList.model.get(pageList.currentIndex);
        console.log('Canviant un sol estat ' + obj.page + '->' + obj.widgetState);
    }
}

