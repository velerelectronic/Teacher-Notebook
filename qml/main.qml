/* Licenses:

  CC0
  * Image: http://pixabay.com/es/peque%C3%B1os-bellota-dibujos-animados-41255/

  Altres:
  * http://pixabay.com/es/bloc-de-notas-nota-l%C3%A1piz-117597/
  * http://pixabay.com/es/pila-papeles-de-pila-notas-cuadro-156015/
  * http://pixabay.com/es/port%C3%A1til-oficina-por-escrito-151261/

*/

import QtQuick 2.2
import QtQuick.Controls 1.1
import QtQuick.Layouts 1.1
import QtQuick.Window 2.0
import 'qrc:///common' as Common
import "qrc:///javascript/Storage.js" as Storage

Window {
    id: mainApp
    width: Screen.width
    height: Screen.height
    visible: true

    signal openAnnotations
    signal openPage(string page)

    property string lastRequestedPage: ''

    Common.UseUnits { id: units }

    Rectangle {
        id: header
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        height: units.fingerUnit

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

                source: 'qrc:///images/small-41255_150.png'
                fillMode: Image.PreserveAspectFit
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        pagesListMenu.switchState();
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
                text: pageListModel.get(pagesView.currentIndex)['pageTitle']
                font.italic: false
                font.bold: true
                font.pixelSize: units.nailUnit * 2
                verticalAlignment: Text.AlignVCenter
                font.family: "Tahoma"
            }
        }
    }

    ListView {
        id: pagesView
        anchors.top: header.bottom
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right

        orientation: ListView.Horizontal
        boundsBehavior: Flickable.StopAtBounds
        snapMode: ListView.SnapOneItem
        model: ListModel { id: pageListModel }
        delegate: pageDelegate
        highlightMoveDuration: parent.width / 2
        highlightFollowsCurrentItem: true

        Common.BackShadow {
            anchors.fill: parent
            state: (pagesListMenu.state == 'show')?'active':'inactive'
            duration: pagesListMenu.durationEffect
            onClicked: pagesListMenu.state = 'hidden'
        }

        PagesListMenu {
            id: pagesListMenu
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.left: parent.left

            menuWidth: units.fingerUnit * 5
            sectionsHeight: units.fingerUnit
            readUnit: units.readUnit
            durationEffect: 200
            model: pagesView.model

            onPageSelected: {
                pagesView.currentIndex = index;
                pagesListMenu.state = 'hidden';
            }
            onPageCloseRequested: {
                pagesView.currentIndex = index;
                if (pagesView.currentItem.closingBlocked)
                    pagesListMenu.state = 'hidden';
                else
                    pageListModel.remove(index);
            }
        }
    }

    Component {
        id: pageDelegate

        Rectangle {
            id: pageRect
            width: pagesView.width
            height: pagesView.height
            //anchors.left: pageList.left
            //anchors.right: pageList.right
            color: 'white'

            property string pageTitle: (pageLoader.item)?pageLoader.item.pageTitle:''
            property bool closingBlocked: ((pageLoader.item) && (pageLoader.item.changes))?pageLoader.item.changes:false
            clip: true

            Loader {
                id: pageLoader
                anchors.fill: parent

                property string pageTitle: (item.pageTitle)?item.pageTitle:''
                onPageTitleChanged: pageListModel.setProperty(model.index,'pageTitle',pageTitle)

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
                    onClosePageRequested: removeCurrentPage()
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
            Component.onCompleted: pageLoader.setSource(model.page + '.qml',model.parameters)
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
        pagesView.currentIndex = pageListModel.count-1;
    }

    function removeCurrentPage() {
        pageListModel.remove(pagesView.currentIndex);
    }
}

