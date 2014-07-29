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
import PersonalTypes 1.0
import 'qrc:///common' as Common

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
        height: units.fingerUnit * 1.5

        color: "#009900"
        visible: true
        clip: false
        z: 1

        RowLayout {
            anchors.fill: parent
            anchors.margins: units.nailUnit

            Image {
                Layout.preferredWidth: units.fingerUnit
                Layout.preferredHeight: units.fingerUnit

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
                font.pixelSize: units.readUnit
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
            sectionsHeight: units.fingerUnit * 2
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
        function sendMessage(page,message) {
            for (var i=0; i<pageListModel.count; i++) {
                if (get(i)['page'] == page) {
                    pagesView.contentItem.children[i].sendMessage(message);
                }
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

            property string pageTitle: pageLoader.pageTitle
            property bool closingBlocked: ((pageLoader.item) && (pageLoader.item.changes))?pageLoader.item.changes:false
            clip: true

            Loader {
                id: pageLoader
                anchors.fill: parent

                property string pageTitle: (item && item.pageTitle)?item.pageTitle:''
                onPageTitleChanged: pageListModel.setProperty(model.index,'pageTitle',pageTitle)

                Connections {
                    target: pageLoader.item
                    ignoreUnknownSignals: true
                    // Signals
                    onOpenPage: openSubPage(page,{})
                    onOpenPageArgs: openSubPage(page,args)

                    // Annotations
                    onOpenAnnotations: openSubPage('AnnotationsList',{annotationsModel: annotationsModel},'')
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

                    // Document list
                    onOpenDocument: {
                        var ext = /^.+\.([^\.]*)$/.exec(document);
                        var extensio = (ext == null)?'':ext[1];
                        console.log(extensio);

                        switch(extensio) {
                        case 'xml':
                            openSubPage('ProgramacioAula',{document: document});
                            break;
                        case 'jpg':
                        case 'png':
                        case 'svg':
                            openSubPage('ImageMapper',{background: document});
                            break;
                        case 'backup':
                            openSubPage('DataMan',{document: document});
                        }

                    }

                    // Backup
                    onSavedBackupToDirectory: messageBox.publishMessage(qsTr("S'ha desat una còpia de seguretat dins ") + directory)
                    onUnsavedBackup: messageBox.publishMessage(qsTr("No s'ha pogut desar la còpia de seguretat"))
                    onBackupReadFromFile: messageBox.publishMessage(qsTr("S'ha introduït el fitxer ") + file + qsTr(" dins la base de dades"))
                    onBackupNotReadFromFile: messageBox.publishMessage(qsTr("Error en intentar introduir el fitxer ") + file + qsTr(" dins la base de dades"))
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
        fontSize: units.readUnit
        interval: 2000
    }


    Component.onCompleted: {
        createTables();

        annotationsModel.tableName = 'annotations';
        annotationsModel.fieldNames =  ['created','id','title','desc','image'];
        annotationsModel.select();

        scheduleModel.tableName = 'schedule';
        scheduleModel.fieldNames = ['created','id','event','desc','startDate','startTime','endDate','endTime','state'];
        scheduleModel.setSort(5,Qt.AscendingOrder);

        mainApp.openMainPage();
    }

    DatabaseBackup {
        id: dataBck
    }

    function createTables() {
        //dataBck.dropTable('annotations');
        //dataBck.dropTable('schedule');
        dataBck.createTable('annotations','(id INTEGER PRIMARY KEY, created TEXT, title TEXT, desc TEXT, image BLOB, ref INTEGER)');
        dataBck.createTable('schedule','(id INTEGER PRIMARY KEY, created TEXT, event TEXT, desc TEXT, startDate TEXT, startTime TEXT, endDate TEXT, endTime TEXT, state TEXT, ref INTEGER)');
        annotationsModel.tableName = 'annotations';
        annotationsModel.fieldNames = ['id', 'created' ,'title', 'desc', 'image', 'ref'];
        annotationsModel.setSort(0,Qt.AscendingOrder);
        scheduleModel.tableName = 'schedule';
        scheduleModel.fieldNames = ['id', 'created', 'event', 'desc', 'startDate', 'startTime', 'endDate', 'endTime', 'state', 'ref'];
        scheduleModel.setSort(4,Qt.AscendingOrder);
    }

    function openMainPage() {
        openSubPage('MenuPage',{});
    }

    function forceOpenSubPage(page,param,ident) {

    }

    function openSubPage (page, param) {
        var i=0;
        var found = false;
        while ((!found) && (i<pageListModel.count)) {
            var obj = pageListModel.get(i);
            if (obj['qmlPage']==page) {
                found = true;
            } else {
                i++;
            }
        }

        if (found) {
            pagesView.currentIndex = i;
            pageListModel.setProperty(i,'param',param);
        } else {
            pageListModel.append({page: page, qmlPage: page, parameters: param});
            pagesView.currentIndex = pageListModel.count-1;
        }
    }

    function removeCurrentPage() {
        pageListModel.remove(pagesView.currentIndex);
    }

    /*
    ListView {
        anchors.fill: parent
        model: tmp
        delegate: Rectangle {
            width: units.fingerUnit *5
            height: units.fingerUnit *5
            color: '#643456'
            Text {
                anchors.fill: parent
                text: display
            }
        }
        Component.onCompleted: console.log(model)
    }
    */
}

