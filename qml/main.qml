/* Licenses:

  CC0
  * Image: http://pixabay.com/es/peque%C3%B1os-bellota-dibujos-animados-41255/

  Altres:
  * http://pixabay.com/es/bloc-de-notas-nota-l%C3%A1piz-117597/
  * http://pixabay.com/es/pila-papeles-de-pila-notas-cuadro-156015/
  * http://pixabay.com/es/port%C3%A1til-oficina-por-escrito-151261/

  * Add: http://pixabay.com/es/plus-signo-verde-mark-icono-24844/
  * Save: http://pixabay.com/es/disquete-icono-disco-s%C3%ADmbolo-bot%C3%B3n-35952/
  * Close: http://pixabay.com/es/se%C3%B1al-de-tr%C3%A1fico-roadsign-no-147409/
  * Duplicate: http://pixabay.com/es/clon-duplicado-flecha-documentos-153447/
  * Edit: http://pixabay.com/es/editar-l%C3%A1piz-la-escuela-escribir-153612/
  * Edit: http://pixabay.com/es/l%C3%A1piz-pluma-naranja-rojo-190586/
  * Details: http://pixabay.com/es/info-informaci%C3%B3n-ayuda-icono-apoyo-147927/
*/

import QtQuick 2.2
import QtQuick.Controls 1.1
import QtQuick.Layouts 1.1
import QtQuick.Window 2.1
import QtQuick.Dialogs 1.1
import PersonalTypes 1.0
import 'qrc:///common' as Common

Window {
    id: mainApp
    width: Screen.width
    height: Screen.height
    visible: true

    property string lastRequestedPage: ''
    property string currentPageTitle: ''

    onClosing: {
        close.accepted = false;
        dpanel.setSelectedPage(0);
    }

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
                    onClicked: dpanel.getItemMainPanel.requestClosePage()
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

                onModelChanged: console.log('Model changed')

                LayoutMirroring.enabled: true
                layoutDirection: ListView.LeftToRight

                spacing: units.nailUnit
                delegate: Rectangle {
                    id: button
                    height: buttons.height
                    width: height
                    color: (checked)?'white':'transparent'
                    opacity: (button.enabled)?1.0:0.2

                    property bool enabled: (model.enabled)?model.enabled:true
                    property bool checkable: (model.checkable)?model.checkable:false
                    property bool checked: false

                    Image {
                        anchors.fill: parent
                        source: 'qrc:///icons/' + model.image + '.svg'
                        fillMode: Image.PreserveAspectFit
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            if (checkable)
                                checked = !checked;
                            dpanel.invokeMethod(model.method);
                        }
                    }
                }

            }

            ListModel {
                id: emptyButtonsList
            }
        }
    }

    Common.DoublePanel {
        id: dpanel
        anchors.top: header.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom

        property int selectedPage: 0

        function setSelectedPage(index) {
            console.log('Index: ' + index);
            selectedPage = index;
            updatePageChange();
        }

        function getButtonsList() {
            var pageObj = dpanel.getItemMainPanel.currentItem;
            if ((pageObj) && (typeof(pageObj.buttons) !== 'undefined')) {
                return pageObj.buttons;
            } else {
                console.log('No buttons');
                return undefined;
            }
        }

        function updatePageChange() {
            buttons.model = dpanel.getButtonsList();

            // Title
            var pageObj = dpanel.getItemMainPanel.currentItem;
            currentPageTitle = (pageObj.pageTitle)?pageObj.pageTitle:'';
            console.log("CURRENT " + currentPageTitle);
        }

        function invokeMethod(method) {
            getItemMainPanel.currentItem[method]();
        }

        colorSubPanel: '#BCF5A9'
        globalMargins: 0

        itemSubPanel: ListView {
            id: pageList

            delegate: Rectangle {
                height: units.fingerUnit * 2
                width: pageList.width
                color: (dpanel.selectedPage == model.index)?'#E3F6CE':'#BCF5A9'
                Text {
                    anchors.fill: parent
                    anchors.margins: units.nailUnit
                    font.pixelSize: units.readUnit
                    text: (model.pageTitle)?model.pageTitle:'' // ('pageTitle' in (pageListModel.get(model.index)))?(pageListModel.get(model.index)['pageTitle']):''
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignLeft
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        dpanel.setSelectedPage(model.index);
                        if (!dpanel.canShowBothPanels())
                            dpanel.toggleSubPanel();
                    }

                    onPressAndHold: dpanel.getItemMainPanel.destroyPage(index)
                }
            }
        }

        itemMainPanel: StackView {
            id: pagesView

            initialItem: Rectangle { color: 'white' }

            Connections {
                target: pagesView.currentItem
                ignoreUnknownSignals: true

                // Page handling
                onOpenPage: openNewPage(page,{})
                onOpenPageArgs: openSubPage(page,args)
                onClosePage: {
                    pagesView.closeCurrentPage();
                    if (message != '')
                        messageBox.publishMessage(message);
                }

                // Annotations
                onDeletedAnnotations: messageBox.publishMessage(qsTr("S'han esborrat ") + num + qsTr(' anotacions'))
                onEditAnnotation: openNewPage('ShowAnnotation',{idAnnotation: id, annotation: annotation, desc: desc},id)
                onOpenAnnotations: openSubPage('AnnotationsList',{annotationsModel: annotationsModel},'')

                // Document list
                onCreatedFile: messageBox.publishMessage('Creat el fitxer «' + file + '»')
                onNotCreatedFile: messageBox.publishMessage('El fitxer «' + file + '» ja existeix')
                onOpenDocument: openNewPage(page, {document: document})
                onOpeningDocumentExternally: messageBox.publishMessage(qsTr("Obrint el document «") + document + "»")

                // Events
                onDeletedEvents: messageBox.publishMessage(qsTr("S'han esborrat ") + num + qsTr(' esdeveniments'))
                onEditEvent: openNewPage('ShowEvent',{idEvent: id, event: event,desc: desc,startDate: startDate,startTime: startTime,endDate: endDate,endTime: endTime},id)
                onNewEvent: openSubPage('ShowEvent',{},'')
                onSavedEvent: {
                    messageBox.publishMessage(qsTr('Esdeveniment desat: títol «') + event + qsTr('», descripcio «') + desc + qsTr('»'));
                    pagesView.closeCurrentPage();
                }
                onCanceledEvent: {
                    if (changes) {
                        messageBox.publishMessage(qsTr("S'han descartat els canvis a l'esdeveniment"))
                    }
                    pagesView.closeCurrentPage();
                }

                // Quick annotations
                onSavedQuickAnnotation: messageBox.publishMessage(qsTr("S'ha desat l'anotacio rapida «" + contents + "»"))

                // Teaching Planning
                onLoadingDocument: messageBox.publishMessage(qsTr('Carregant el document «' + document + '»'))
                onLoadedDocument: messageBox.publishMessage(qsTr("S'ha carregat el document «" + document + "»"))
                onDocumentSaved: messageBox.publishMessage(qsTr('Desat el document «') + document + '»')
                onDocumentDiscarded: {
                    if (changes)
                        messageBox.publishMessage(qsTr("S'han descartat els canvis fets al document «") + document + '»');
                    pagesView.closeCurrentPage();
                }

                // Text viewer
                onSavedDocument: messageBox.publishMessage(qsTr('Desat el document «') + document + '»')

                // Backup
                onSavedBackupToDirectory: {
                    var directory = document;
                    messageBox.publishMessage(qsTr("S'ha desat una còpia de seguretat dins ") + directory);
                }
                onUnsavedBackup: messageBox.publishMessage(qsTr("No s'ha pogut desar la còpia de seguretat"))
                onBackupReadFromFile: messageBox.publishMessage(qsTr("S'ha introduït el fitxer ") + file + qsTr(" dins la base de dades"))
                onBackupNotReadFromFile: messageBox.publishMessage(qsTr("Error en intentar introduir el fitxer ") + file + qsTr(" dins la base de dades"))

                // Assessment Grid
                onOpenTabularEditor: openNewPage('AssessmentGeneralEditor',{})
                onSavedGridValues: {
                    pagesView.closeCurrentPage();
                    messageBox.publishMessage(qsTr("S'han desat " + number + " valors a la graella d'avaluació"));
                    dpanel.getItemMainPanel.currentItem.updateGrid();
                }
                onCloseGridEditor: pagesView.closeCurrentPage()

                // Altres - revisar
                onOpenDocumentsList: openNewPage('DocumentsList',{},'')
                onRefusedCloseEditorRequest: messageBox.publishMessage(qsTr("Encara hi ha canvis sense desar! Desa'ls o descarta'ls abans."))
            }

            function attach(object,signalName,methodName) {
                if (object[signalName])
                    object[signalName].connect(methodName);
            }

            function closeCurrentPage() {
                pagesView.pop();
                dpanel.updatePageChange();
            }

            function requestClosePage() {
                var item = pagesView.currentItem;
                if (typeof item.requestClose != 'undefined') {
                    item.requestClose();
                } else {
                    messageBox.publishMessage(qsTr("No es pot tancar la pagina perque s'han realitzat canvis."))
                }
            }

            function openNewPage(page,param) {
                pagesView.push({item: Qt.resolvedUrl(page + '.qml'), properties: param});
                dpanel.updatePageChange();

                var pageObj = dpanel.getItemMainPanel.currentItem;


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
        dpanel.getItemMainPanel.openNewPage('MenuPage',{});
    }

    function openSubPage (page, param) {
    }

}

