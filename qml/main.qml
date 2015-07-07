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

  * Today: http://pixabay.com/es/calendario-fechas-mes-hoy-en-d%C3%ADa-27560/
  * Quit: http://pixabay.com/es/eliminar-celular-cuadro-quitar-27201/

  * GanttDiagram: http://pixabay.com/es/por-ciento-40-bar-progreso-metro-40844/
  * Calendar: http://pixabay.com/es/calendario-mensual-oficina-23684/
  * Maximize: http://pixabay.com/es/windows-de-microsoft-maximizar-zoom-23242/
  * Minimize: http://pixabay.com/es/men%C3%BA-rojo-brillante-ventana-abajo-145772/
  * Multiple windows: http://pixabay.com/es/ventanas-equipo-escritorio-97883/

  * Categories: http://pixabay.com/es/jerarqu%C3%ADa-niveles-de-arreglos-35795/
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

    width: Screen.desktopAvailableWidth
    height: Screen.desktopAvailableHeight
    visible: true


    property string currentPageTitle: ''

    onClosing: {
        close.accepted = false;
        closeCurrentPage();
    }

    Common.UseUnits { id: units }

    Common.CollapsiblePanel {
        id: header
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        minimumSize: units.fingerUnit * 1.5
        maximumSize: units.fingerUnit * 4

        color: "#009900"
        visible: true
        clip: false
        z: 1

        RowLayout {
            anchors.fill: parent
            anchors.margins: units.nailUnit

            Image {
                Layout.preferredWidth: height
                Layout.preferredHeight: parent.height

                source: (pagesView.depth==1)?'qrc:///images/small-41255_150.png':'qrc:///icons/arrow-145769.svg'
                fillMode: Image.PreserveAspectFit
                MouseArea {
                    anchors.fill: parent
                    onClicked: pagesView.requestClosePage()
                }
            }
            Text {
                id: title
                Layout.preferredWidth: Math.max(contentWidth, units.fingerUnit * 3)
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
                clip: true

                interactive: header.state == 'maximized'
                LayoutMirroring.enabled: !interactive
                layoutDirection: (!interactive)?ListView.LeftToRight:ListView.RightToLeft

                spacing: units.nailUnit
                delegate: adjustableButton
            }

            ListModel {
                id: emptyButtonsList
            }
        }
    }

    Component {
        id: adjustableButton

        Rectangle {
            id: button

            states: [
                State {
                    name: 'simple'
                    PropertyChanges {
                        target: button
                        color: 'transparent'
                        width: button.height
                    }
                    PropertyChanges {
                        target: row
                        spacing: 0
                        anchors.margins: 0
                    }
                },
                State {
                    name: 'detailed'
                    PropertyChanges {
                        target: button
                        color: '#DDFFDD'
                        width: button.height * 3
                    }
                    PropertyChanges {
                        target: row
                        spacing: units.nailUnit
                        anchors.margins: units.nailUnit
                    }
                }
            ]

            transitions: Transition {
                PropertyAnimation {
                    target: button
                    properties: 'width'
                    duration: 500
                }
            }
            state: (header.state == 'minimized')?'simple':'detailed'
            height: buttons.height
            color: (checked)?'white':'transparent'
            opacity: (button.enabled)?1.0:0.2

            property bool enabled: (model.enabled)?model.enabled:true
            property bool checkable: (model.checkable)?model.checkable:false
            property bool checked: false

/*            Behavior on width {
                NumberAnimation { duration: 200 }
            }
            */

            RowLayout {
                id: row
                anchors.fill: parent
                Image {
                    Layout.fillHeight: true
                    Layout.preferredWidth: height
                    source: 'qrc:///icons/' + model.image + '.svg'
                    fillMode: Image.PreserveAspectFit
                }
                Text {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    clip: true
                    font.pixelSize: units.readUnit
                    verticalAlignment: Text.AlignVCenter
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    elide: Text.ElideRight
                    text: (model.title)?model.title:model.method
                }
            }

            MouseArea {
                anchors.fill: parent
                propagateComposedEvents: false
                onClicked: {
                    if (checkable)
                        checked = !checked;
                    pagesView.invokeMethod(model.method);
                    header.state = 'minimized';
                }
            }
        }

    }

    StackView {
        id: pagesView
        anchors.top: header.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom

        initialItem: Qt.resolvedUrl('MenuPage.qml')

        Connections {
            target: pagesView.currentItem
            ignoreUnknownSignals: true

            // State changes
            onStateChanged: buttons.model = pagesView.getButtonsList()

            // Page handling
            onOpenPage: openNewPage(page,{})
            onOpenPageArgs: openNewPage(page,args)
            onClosePage: {
                closeCurrentPage();
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
            onOpenTBook: openNewPage('Planning2', {document: document})
            onOpeningDocumentExternally: messageBox.publishMessage(qsTr("Obrint el document «") + document + "»")

            // Events
            onDeletedEvents: messageBox.publishMessage(qsTr("S'han esborrat ") + num + qsTr(' esdeveniments'))
            onEditEvent: openNewPage('ShowEvent',{idEvent: idEvent, event: event,desc: desc,startDate: startDate,startTime: startTime,endDate: endDate,endTime: endTime,project: project, projectsModel: projectsModel})
            onNewEvent: openNewPage('ShowEvent', {projectsModel: projectsModel})
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
                closeCurrentPage();
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

            // Rubrics
            onOpenRubricDetails: openNewPage('RubricDetailsEditor',{rubric: rubric, rubricsModel: rubricsModel})
            onOpenRubricEditor: openNewPage('Rubric',{rubric: id, rubricsModel: rubricsModel, state: 'edit'}, '')
            onOpenRubricGroupAssessment: {
                openNewPage('RubricGroupAssessment', {idAssessment: assessment, rubric: rubric, rubricsModel: rubricsModel, rubricsAssessmentModel: rubricsAssessmentModel})
            }
            onOpenRubricAssessmentDetails: openNewPage('RubricAssessmentEditor', {idAssessment: assessment, group: group, rubric: rubric, rubricsAssessmentModel: rubricsAssessmentModel})
            onEditCriterium: openNewPage('RubricCriteriumEditor',{idCriterium: idCriterium, rubric: rubric, title: title, desc: desc, ord: ord, weight: weight, criteriaModel: model})
            onEditLevel: openNewPage('RubricLevelEditor',{idLevel: idLevel, rubric: rubric, title: title, desc: desc, score: score, levelsModel: model})
            onEditRubricDetails: openNewPage('RubricDetailsEditor',{idRubric: idRubric, rubricsModel: model})
            onEditDescriptor: openNewPage('RubricDescriptorEditor',{idDescriptor: idDescriptor, criterium: criterium, level: level, definition: definition, descriptorsModel: model})
            onEditRubricAssessmentDescriptor: openNewPage('RubricAssessmentDescriptor',
                                                          {
                                                              assessment: idAssessment,
                                                              criterium: criterium,
                                                              individual: individual,
                                                              lastScoreId: lastScoreId,
                                                              scoresSaveModel: rubricIndividualScoresSaveModel,
                                                              scoresModel: rubricIndividualScoresModel,
                                                              levelDescriptorsModel: levelDescriptorsModel,
                                                              individualsModel: individualsModel,
                                                              lastScoresModel: lastScoresModel
                                                          });

            onEditGroupIndividual: openNewPage('GroupIndividualEditor', {individual: individual, groupsIndividualsModel: groupsIndividualsModel})

            onSavedAssessmentDescriptor: {
                messageBox.publishMessage(qsTr("S'han desat les dades del descriptor"));
                closeCurrentPage();
            }

            onSavedGroupIndividual: {
                messageBox.publishMessage(qsTr("S'han desat els canvis a l'individu"));
                closeCurrentPage();
            }

            onSavedCriterium: closeCurrentPage()
            onSavedLevel: closeCurrentPage()
            onSavedRubricDetails: closeCurrentPage()
            onSavedDescriptor: closeCurrentPage()
            onSavedRubricAssessment: {
                messageBox.publishMessage(qsTr("S'ha desat l'avaluació de rúbrica"));
                closeCurrentPage();
            }

            // Projects
            onNewProjectRequest: openNewPage('ProjectEditor',{projectsModel: model});
            onShowProject: openNewPage('ProjectEditor',{idProject: project, projectsModel: model})
            onSavedProjectDetails: {
                messageBox.publishMessage(qsTr("S'ha desat el projecte"));
                closeCurrentPage();
            }

            // Resources
            onCreateResource: openNewPage('ShowResource',{resourcesModel: model});
            onShowResource: openNewPage('ShowResource',{idResource: idResource, resourcesModel: model});
        }

        function requestClosePage() {
            var item = pagesView.currentItem;
            if (typeof item.requestClose == 'function') {
                item.requestClose();
            } else {
                closeCurrentPage();
            }
        }


        function getButtonsList() {
            var pageObj = pagesView.currentItem;
            if ((pageObj) && (typeof(pageObj.buttons) !== 'undefined')) {
                return pageObj.buttons;
            } else {
                return undefined;
            }
        }

        function updatePageChange() {
            buttons.model = pagesView.getButtonsList();

            // Title
            var pageObj = pagesView.currentItem;
            currentPageTitle = ((pageObj !== null) && (pageObj.pageTitle))?pageObj.pageTitle:'';
        }

        function invokeMethod(method) {
            currentItem[method]();
        }
    }

    Common.SidePanel2 {
        id: sidePanel

        anchors.top: header.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom

        panelWidth: 10 * units.fingerUnit
        panelHeight: height
        handleSize: units.fingerUnit

        mainItem: Rectangle {
            anchors.fill: parent
            color: '#BCF5A9'

            ListView {
                id: pageList
                anchors.fill: parent
                anchors.margins: units.nailUnit

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
                                target: pagesView
                                onCurrentItemChanged: {
                                    var levels = pagesView.depth;
                                    if (levels>1) {
                                        allPageTitles.text = qsTr('Pàgines');
                                        for (var i=1; i<levels; i++) {
                                            var page = pagesView.get(i,true);
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

                    Common.BigButton {
                        width: pageList.width
                        height: units.fingerUnit
                        title: qsTr('Espai de treball')
                        onClicked: openNewPage('WorkSpace',{})
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
                                onClicked: openNewPage('ShowAnnotation', {idAnnotation: id})
                            }
                        }
                        caption: qsTr('Darreres anotacions')
                        captionBackgroundColor: '#F3F781'
                        color: '#F7F8E0'
                        totalBackgroundColor: '#F2F5A9'
                        maxItems: 3
                        totalCount: -1
                        onPlusClicked: openNewPage('ShowAnnotation',{idAnnotation: -1})
                        onCaptionClicked: openNewPage('AnnotationsList',{})
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
                                onClicked: openNewPage('ShowEvent',{idEvent: model.id})
                            }
                        }
                        caption: qsTr("Últims esdeveniments")
                        captionBackgroundColor: '#F7BE81'
                        color: '#F8ECE0'
                        maxItems: 3
                        totalCount: -1
                        onPlusClicked: openNewPage('ShowEvent',{idEvent: -1})
                        onCaptionClicked: openNewPage('TasksSystem',{})
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
                                    openNewPage('DocumentsList',{initialDirectory: model.directory});
                                }
                            }
                        }

                        onCaptionClicked: openNewPage('DocumentsList',{})

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
                        onClicked: openNewPage('MarkDownViewer',{})
                    }

                    Common.BigButton {
                        width: pageList.width
                        height: units.fingerUnit
                        title: qsTr('Pissarra')
                        onClicked: openNewPage('Whiteboard',{})
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
        fontSize: units.readUnit
        interval: 2000
    }


    BasicDatabase {
        id: basicDatabase
    }

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

    function openMainPage() {
        openNewPage('MenuPage',{});
    }

    function closeCurrentPage() {
        header.state = 'minimized';
        pagesView.pop();
        pagesView.updatePageChange();
    }

    function openNewPage(page,param) {
        sidePanel.state = 'hidePanel';
        header.state = 'minimized';
        pagesView.push({item: Qt.resolvedUrl(page + '.qml'), properties: param});
        pagesView.updatePageChange();

        var pageObj = pagesView.currentItem;
    }


    SqlTableModel {
        id: auditModel
    }

    function auditTable(tableName, fields) {
        console.log('Audit table ' + tableName);

        auditModel.tableName = tableName;
        auditModel.fieldNames = fields;
        auditModel.select();
        console.log('# rows: ' + auditModel.count);
        for (var i=0; i<auditModel.count; i++) {
            console.log('Row ' + (i+1));
            var obj = auditModel.getObjectInRow(i);
            for (var prop in obj) {
                console.log(i + " " + prop + " -> " + obj[prop]);
            }
        }
    }

    Component.onCompleted: {

        basicDatabase.initEverything();
        console.log('Auditing 2');

        pagesView.updatePageChange()

        /*
        auditTable('rubrics_last_scores',[
                       'assessment',
                    'individual',
                    'name',
                    'surname',
                    '\"group\"',
                    'criteriumTitle',
                    'criteriumDesc',
                    'weight',
                    'descriptor',
                    'moment',
                    'comment',
                    'criterium',
                    'level',
                    'definition',
                    'lastScoreId',
                    'score']);
*/
        auditTable('rubrics_descriptors_scores',[
                       'assessment',
                       'rubric',
                       'individual',
                       'name',
                       'surname',
                       '\"group\"',

                       'criterium',
                       'criteriumTitle',
                       'criteriumDesc',
                       'weight',

                       'descriptor',
                       'moment',
                       'comment',

                       'level',
                       'definition',
                       'scoreId'
                   ]);
    }

}

