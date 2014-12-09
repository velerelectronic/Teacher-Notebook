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
  * Back: http://pixabay.com/es/flecha-verde-brillante-izquierda-145769/
  * Export: http://pixabay.com/en/box-open-taking-out-container-24557/
  * Select: http://pixabay.com/en/screen-capture-screenshot-app-23236/
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

    x: 0
    y: 0

    onXChanged: console.log('X changed to ' + mainApp.x)
    width: Screen.desktopAvailableWidth
    height: Screen.desktopAvailableHeight
    visible: true


    property string currentPageTitle: ''

    onClosing: {
        close.accepted = false;
        dpanel.getItemMainPanel.closeCurrentPage();
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

                source: (dpanel.getItemMainPanel.depth==1)?'qrc:///images/small-41255_150.png':'qrc:///icons/arrow-145769.svg'
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

        function getButtonsList() {
            var pageObj = dpanel.getItemMainPanel.currentItem;
            if ((pageObj) && (typeof(pageObj.buttons) !== 'undefined')) {
                return pageObj.buttons;
            } else {
                return undefined;
            }
        }

        function updatePageChange() {
            buttons.model = dpanel.getButtonsList();

            // Title
            var pageObj = dpanel.getItemMainPanel.currentItem;
            currentPageTitle = (pageObj.pageTitle)?pageObj.pageTitle:'';
        }

        function invokeMethod(method) {
            getItemMainPanel.currentItem[method]();
        }

        colorSubPanel: '#BCF5A9'
        expectedWidth: 8 * units.fingerUnit
        globalMargins: units.nailUnit

        SqlTableModel {
            id: nextEventsModel
            tableName: 'schedule'
            limit: 3
            filters: ["ifnull(state,'') != 'done'"]
            Component.onCompleted: {
                setSort(1,Qt.DescendingOrder); // Order by last inclusion
                select();
            }
        }
        SqlTableModel {
            id: lastAnnotationsModel
            tableName: 'annotations'
            limit: 3
            Component.onCompleted: {
                setSort(0,Qt.DescendingOrder);
                select();
            }
        }

        itemSubPanel: ListView {
            id: pageList

            spacing: units.fingerUnit
            model: VisualItemModel {
                Common.TimeViewer {
                    width: pageList.width
                    color: '#DDFFDD'
                }

                Item {
                    width: pageList.width
                    height: childrenRect.height + units.nailUnit
                    Text {
                        id: allPageTitles
                        anchors.top: parent.top
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.margins: units.nailUnit
                        height: contentHeight
                        font.pixelSize: units.readUnit
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        textFormat: Text.PlainText
                        Connections {
                            target: dpanel.getItemMainPanel
                            onCurrentItemChanged: {
                                var levels = dpanel.getItemMainPanel.depth;
                                if (levels>1) {
                                    allPageTitles.text = qsTr('Pàgines');
                                    for (var i=1; i<levels; i++) {
                                        var page = dpanel.getItemMainPanel.get(i,true);
                                        allPageTitles.text += ' > ';
                                        allPageTitles.text += (typeof (page.pageTitle) != 'undefined')?page.pageTitle:'Pàgina';
                                    }
                                } else {
                                    allPageTitles.text = '';
                                }
                            }
                        }
                    }
                }

                QuickAnnotation {
                    width: pageList.width
                    height: width
                    onSavedQuickAnnotation: {
                        if (lastAnnotationsModel.insertObject({title: 'Anotació ràpida',desc: contents})) {
                            annotationWasSaved();
                            messageBox.publishMessage(qsTr("S'ha desat l'anotacio rapida «" + contents + "»"));
                        }
                    }
                }

                Common.PreviewBox {
                    id: lastAnnotations
                    width: pageList.width
                    // height: buttonHeight

                    model: lastAnnotationsModel
                    delegate: Item {
                        width: parent.width
                        height: units.fingerUnit
                        Text {
                            id: textAnnot
                            anchors.fill: parent
                            anchors.margins: units.nailUnit
                            elide: Text.ElideRight
                            maximumLineCount: 1
                            font.pixelSize: units.readUnit
                            verticalAlignment: Text.AlignVCenter
                            text: '– ' + title + ' ' + desc
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: pageList.openNewMainPage('ShowAnnotation', {idAnnotation: id})
                        }
                    }
                    caption: qsTr('Darreres anotacions')
                    captionBackgroundColor: '#F3F781'
                    color: '#F7F8E0'
                    totalBackgroundColor: '#F2F5A9'
                    maxItems: 3
                    totalCount: -1
                    onPlusClicked: pageList.openNewMainPage('ShowAnnotation',{idAnnotation: -1})
                    onCaptionClicked: pageList.openNewMainPage('AnnotationsList')
                }

                Common.PreviewBox {
                    id: nextEvents
                    width: pageList.width
//                    height: buttonHeight

                    model: nextEventsModel

                    delegate: Item {
                        width: parent.width
                        height: units.fingerUnit
                        RowLayout {
                            id: textEvents
                            anchors.fill: parent
                            anchors.margins: units.nailUnit

                            Text {
                                Layout.fillHeight: true
                                text: model.endDate
                                font.bold: true
                                font.pixelSize: units.readUnit
                                verticalAlignment: Text.AlignVCenter
                            }

                            Text {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                elide: Text.ElideRight
                                maximumLineCount: 1
                                font.pixelSize: units.readUnit
                                verticalAlignment: Text.AlignVCenter
                                text: model.event
                            }
                        }
                        MouseArea {
                            anchors.fill: textEvents
                            onClicked: pageList.openNewMainPage('ShowEvent',{idEvent: model.id})
                        }
                    }
                    caption: qsTr("Últims esdeveniments")
                    captionBackgroundColor: '#F7BE81'
                    color: '#F8ECE0'
                    maxItems: 3
                    totalCount: -1
                    onPlusClicked: pageList.openNewMainPage('ShowEvent',{idEvent: -1})
                    onCaptionClicked: pageList.openNewMainPage('Schedule')
                }

                Common.PreviewBox {
                    id: directories
                    width: pageList.width
                    caption: qsTr('Directoris')
                    color: '#EEEEEE'
                    totalCount: -1
                    model: ListModel {
                        id: directoriesModel
                    }
                    delegate: Item {
                        height: units.fingerUnit
                        width: directories.width
                        Text {
                            anchors.fill: parent
                            anchors.margins: units.nailUnit
                            text: model.title
                            verticalAlignment: Text.verticalAlignment
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                pageList.openNewMainPage('DocumentsList',{initialDirectory: model.directory});
                            }
                        }
                    }

                    onCaptionClicked: pageList.openNewMainPage('DocumentsList')

                    StandardPaths {
                        id: paths
                    }

                    Component.onCompleted: {
                        directoriesModel.append({title: qsTr('Curs 14-15'), directory: 'file:///sdcard/Esquirol/Curs-14-15'})
                        directoriesModel.append({title: qsTr('Esquirol'), directory: 'file:///sdcard/Esquirol'});
                        directoriesModel.append({title: qsTr('Home'), directory: paths.home});
                        directoriesModel.append({title: qsTr('Documents'), directory: paths.documents});
                        directoriesModel.append({title: qsTr('Pel·lícules'), directory: paths.movies});
                        directoriesModel.append({title: qsTr('Imatges'), directory: paths.pictures});
                        directoriesModel.append({title: qsTr('Descàrregues'), directory: paths.downloads});
                        directoriesModel.append({title: qsTr('Escriptori'), directory: paths.desktop});
                    }
                }

                Common.BigButton {
                    width: pageList.width
                    height: units.fingerUnit
                    title: qsTr('MarkDown')
                    onClicked: pageList.openNewMainPage('MarkDownViewer')
                }

                Common.BigButton {
                    width: pageList.width
                    height: units.fingerUnit
                    title: qsTr('Pissarra')
                    onClicked: pageList.openNewMainPage('Whiteboard')
                }
            }

            function openNewMainPage(page, args) {
                dpanel.getItemMainPanel.openNewPage(page,args);
                dpanel.toggleSubPanel();
            }
        }

        itemMainPanel: StackView {
            id: pagesView

            initialItem: Qt.resolvedUrl('MenuPage.qml')

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
                onSavedAnnotation: {
                    messageBox.publishMessage(qsTr('Anotació desada: títol «') + annotation + '», descripció «' + desc + '»');
                    lastAnnotationsModel.select();
                }
                onDuplicatedAnnotation: {
                    messageBox.publishMessage(qsTr("S'ha creat un duplicat"));
                    lastAnnotationsModel.select();
                }
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
                onNewEvent: openNewPage('ShowEvent',{},'')
                onSavedEvent: {
                    messageBox.publishMessage(qsTr("S'ha desat l'esdeveniment"));
                    scheduleModel.select();
                    nextEventsModel.select();
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

                // MarkDown viewer
                onOpenLink: openNewPage('MarkDownViewer', {document: link});

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
                onOpenAssessmentList: openNewPage('AssessmentList', {})
                onExportedContents: messageBox.publishMessage("S'han exportat les dades i s'ha desat una copia al porta-retalls.")

                // Altres - revisar
                onOpenDocumentsList: openNewPage('DocumentsList',{},'')
                onRefusedCloseEditorRequest: messageBox.publishMessage(qsTr("Encara hi ha canvis sense desar! Desa'ls o descarta'ls abans."))
            }

            function closeCurrentPage() {
                pagesView.pop();
                dpanel.updatePageChange();
            }

            function requestClosePage() {
                var item = pagesView.currentItem;
                if (typeof item.requestClose == 'function') {
                    item.requestClose();
                } else {
                    closeCurrentPage();
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
        scheduleModel.select();

        dpanel.updatePageChange()
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

