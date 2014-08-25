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

    property string lastRequestedPage: ''
    property string currentPageTitle: ''

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
                        dpanel.toggleSubPanel();
                        // pagesListMenu.switchState();
                        if (pageListModel.count==0)
                            openMainPage();
                    }
                }
            }
            Text {
                id: title
                Layout.preferredWidth: contentWidth
                Layout.preferredHeight: parent.height
                color: "#ffffff"
                text: currentPageTitle
                font.italic: false
                font.bold: true
                font.pixelSize: units.readUnit
                verticalAlignment: Text.AlignVCenter
                font.family: "Tahoma"
            }
            ListView {
                id: buttons
                Layout.fillWidth: true
                Layout.fillHeight: true
                orientation: ListView.Horizontal

                LayoutMirroring.enabled: true
                layoutDirection: ListView.LeftToRight
            }
        }
    }

    Common.DoublePanel {
        id: dpanel
        anchors.top: header.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom

        property int selectedPage: -1

        colorSubPanel: '#BCF5A9'
        globalMargins: 0

        itemSubPanel: ListView {
            id: pageList

            model: pageListModel
            cacheBuffer: Math.max(dpanel.width,dpanel.height) * 4

            Connections {
                target: pageListModel
                onCountChanged: {
                    var size = Math.max(dpanel.width,dpanel.height) * (pageListModel.count+1);
                    if (pageList.cacheBuffer < size) {
                        pageList.cacheBuffer = size;
                    }
                }
            }

            Connections {
                target: dpanel
                onSelectedPageChanged: {
                    if (pageList.currentIndex != dpanel.selectedPage) {
                        pageList.currentIndex = dpanel.selectedPage;
                    }
                }
            }

            delegate: Rectangle {
                height: units.fingerUnit * 2
                width: pageList.width
                color: (dpanel.selectedPage == model.index)?'#E3F6CE':'#BCF5A9'
                Text {
                    anchors.fill: parent
                    anchors.margins: units.nailUnit
                    font.pixelSize: units.readUnit
                    text: ('pageTitle' in (pageListModel.get(model.index)))?(pageListModel.get(model.index)['pageTitle']):''
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignLeft
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        dpanel.selectedPage = index;
                        dpanel.toggleSubPanel();
                    }

                    onPressAndHold: {
                        if (index>0) {
                            dpanel.selectedPage = index;
                            pageListModel.remove(index);
                        }
                        /*
                        if (pagesView.currentItem.closingBlocked)
                            dpanel.toggleSubPanel();
                        else
                            pageListModel.remove(index);
                        */
                    }
                }
            }
        }

        itemMainPanel: PageCollection {
            id: pagesView

            function attach(object,signalName,methodName) {
                if (object[signalName])
                    object[signalName].connect(methodName);
            }

            Connections {
                target: pageListModel
                onCountChanged: {
                    var obj = pageListModel.get(pageListModel.count-1);
                    var pageObj = pagesView.addPage(obj['page'],obj['parameters']);

                    var pageTitle = (pageObj.pageTitle)?pageObj.pageTitle:pageListModel.count;
                    console.log(pageTitle);
                    pageListModel.setProperty(pageListModel.count-1,'pageTitle',pageTitle);

                    // Annotations
                    pagesView.attach(pageObj,'canceledAnnotation', function(changes) {
                        if (changes) {
                            messageBox.publishMessage(qsTr("S'han descartat els canvis en l'anotació"))
                        }
                        removeCurrentPage();
                    });
                    pagesView.attach(pageObj,'closePageRequested', function() {
                        removeCurrentPage();
                    });
                    pagesView.attach(pageObj,'deletedAnnotations', function(num) {
                        messageBox.publishMessage(qsTr("S'han esborrat ") + num + qsTr(' anotacions'));
                    });
                    pagesView.attach(pageObj,'editAnnotation', function(id,annotation,desc) {
                        openSubPage('ShowAnnotation',{idAnnotation: id, annotation: annotation, desc: desc},id);
                    });
                    pagesView.attach(pageObj,'openAnnotations', function() {
                        openSubPage('AnnotationsList',{annotationsModel: annotationsModel},'');
                    });
                    pagesView.attach(pageObj,'savedAnnotation', function(annotation,desc) {
                        messageBox.publishMessage('Anotació desada: títol «' + annotation + '», descripció «' + desc + '»');
                        removeCurrentPage();
                    });

                    // Document list
                    pagesView.attach(pageObj,'openDocument', function(document) {
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
                            break;
                        default:
                            messageBox.publishMessage(qsTr("S'obrira el document «") + document + "»");
                            Qt.openUrlExternally(document);
                        }
                    });

                    // Events
                    pagesView.attach(pageObj,'deletedEvents',function (num) {
                        messageBox.publishMessage(qsTr("S'han esborrat ") + num + qsTr(' esdeveniments'));
                    });
                    pagesView.attach(pageObj,'editEvent',function (id,event,desc,startDate,startTime,endDate,endTime) {
                        openSubPage('ShowEvent',{idEvent: id, event: event,desc: desc,startDate: startDate,startTime: startTime,endDate: endDate,endTime: endTime},id);
                    });
                    pagesView.attach(pageObj,'newEvent',function () {
                        openSubPage('ShowEvent',{},'');
                    });
                    pagesView.attach(pageObj,'savedEvent',function (event, desc) {
                        messageBox.publishMessage(qsTr('Esdeveniment desat: títol «') + event + qsTr('», descripcio «') + desc + qsTr('»'));
                        removeCurrentPage();
                    });
                    pagesView.attach(pageObj,'canceledEvent',function (changes) {
                        if (changes) {
                            messageBox.publishMessage(qsTr("S'han descartat els canvis a l'esdeveniment"))
                        }
                        removeCurrentPage();
                    });

                    // Page handling
                    pagesView.attach(pageObj,'openPage', function (page) {
                        openSubPage(page,{});
                    });
                    pagesView.attach(pageObj,'openPageArgs', function (page,args) {
                        openSubPage(page,args);
                    });

                    // Quick annotations
                    pagesView.attach(pageObj,'savedQuickAnnotation', function (contents) {
                        messageBox.publishMessage(qsTr("S'ha desat l'anotacio rapida «" + contents + "»"));
                    });

                    // Teaching Planning
                    pagesView.attach(pageObj,'loadingDocument', function (document) {
                        messageBox.publishMessage(qsTr('Carregant el document «' + document + '»'));
                    });
                    pagesView.attach(pageObj,'loadedDocument', function (document) {
                        messageBox.publishMessage(qsTr("S'ha carregat el document «" + document + "»"));
                    });
                    pagesView.attach(pageObj,'documentSaved', function (document) {
                        messageBox.publishMessage(qsTr('Desat el document «') + document + '»');
                    });

                    // Backup
                    pagesView.attach(pageObj,'savedBackupToDirectory', function (directory) {
                        messageBox.publishMessage(qsTr("S'ha desat una còpia de seguretat dins ") + directory);
                    });
                    pagesView.attach(pageObj,'unsavedBackup', function () {
                        messageBox.publishMessage(qsTr("No s'ha pogut desar la còpia de seguretat"));
                    });
                    pagesView.attach(pageObj,'backupReadFromFile', function (file) {
                        messageBox.publishMessage(qsTr("S'ha introduït el fitxer ") + file + qsTr(" dins la base de dades"));
                    });
                    pagesView.attach(pageObj,'backupNotReadFromFile', function (file) {
                        messageBox.publishMessage(qsTr("Error en intentar introduir el fitxer ") + file + qsTr(" dins la base de dades"));
                    });

                    // Altres - revisar
                    pagesView.attach(pageObj,'openDocumentsList', function () {
                        openSubPage('DocumentsList',{},'');
                    });
                    pagesView.attach(pageObj,'acceptedCloseEditorRequest', function () {
                        forceOpenSubPage(lastRequestedPage,{});
                    });
                    pagesView.attach(pageObj,'refusedCloseEditorRequest', function () {
                        messageBox.publishMessage(qsTr("Encara hi ha canvis sense desar! Desa'ls o descarta'ls abans."));
                    });
                }
            }

            Connections {
                target: dpanel
                onSelectedPageChanged: {
                    var pageObj = pagesView.showPage(dpanel.selectedPage);

                    // Title
                    currentPageTitle = (pageObj.pageTitle)?pageObj.pageTitle:'';

                    // Buttons
                    if (typeof(pageObj.buttons) !== 'undefined') {
                        console.log('model de botons');
                        buttons.model = pageObj.buttons;
                    } else
                        buttons.model = undefined;
                }
            }
        }
    }

    ListModel {
        id: pageListModel
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
        dataBck.createTable('annotations','id INTEGER PRIMARY KEY, created TEXT, title TEXT, desc TEXT, image BLOB, ref INTEGER');
        dataBck.createTable('schedule','id INTEGER PRIMARY KEY, created TEXT, event TEXT, desc TEXT, startDate TEXT, startTime TEXT, endDate TEXT, endTime TEXT, state TEXT, ref INTEGER');
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
        console.log('Trying to open');

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
            dpanel.selectedPage = i;
            pageListModel.setProperty(i,'param',param);
        } else {
            pageListModel.append({page: page, qmlPage: page, parameters: param});
            dpanel.selectedPage = pageListModel.count-1;
        }
    }

    function removeCurrentPage() {
        pagesView.removePage(dpanel.selectedPage);
        pageListModel.remove(dpanel.selectedPage);
        dpanel.selectedPage = pagesView.currentPage;
    }
}

