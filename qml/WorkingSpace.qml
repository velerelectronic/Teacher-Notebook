import QtQuick 2.5
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.4
import QtQuick.Dialogs 1.2
import PersonalTypes 1.0
import 'qrc:///common' as Common

Item {
    property string pageTitle: pagesStack.pageTitle

    property string initialPage: ''
    property var initialProperties

    signal closeWorkingSpace()
    signal openMenu(int initialHeight, var menu)

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Rectangle {
            id: mainBar

            Layout.fillWidth: true
            Layout.preferredHeight: units.fingerUnit * 1.5
            color: 'green'

            RowLayout {
                anchors.fill: parent
                anchors.margins: units.nailUnit
                spacing: units.nailUnit

                Image {
                    Layout.preferredWidth: height
                    Layout.preferredHeight: parent.height

                    source: (pagesStack.depth==1)?'qrc:///icons/road-sign-147409.svg':'qrc:///icons/arrow-145769.svg'
                    fillMode: Image.PreserveAspectFit
                    MouseArea {
                        anchors.fill: parent
                        onClicked: requestClosePage()
                    }
                }

                ListView {
                    id: buttons
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    orientation: ListView.Horizontal
                    clip: true

                    LayoutMirroring.enabled: !interactive
                    layoutDirection: (!interactive)?ListView.LeftToRight:ListView.RightToLeft

                    spacing: units.nailUnit
                    delegate: adjustableButton
                }
            }

            ListModel {
                id: emptyButtonsList
            }
        }

        StackView {
            id: pagesStack

            Layout.fillHeight: true
            Layout.fillWidth: true

            property string pageTitle: ((currentItem !== null) && (typeof currentItem.pageTitle !== 'undefined'))?currentItem.pageTitle:qsTr('Espai de treball')

            initialItem: {'item': Qt.resolvedUrl(initialPage), 'properties': initialProperties}

            onCurrentItemChanged: {
                buttons.model = getButtonsList();
            }

            function invokeMethod(method) {
                currentItem[method]();
            }
        }
    }

    Connections {
        target: pagesStack.currentItem
        ignoreUnknownSignals: true

        // Slide menu

        onOpenMenu: {
            openMenu(initialHeight, menu);
        }

        // Page handling
        onOpenPage: {
            console.log('Opening page ' + page);
            openNewPage(page,{});
        }
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
        onShowAnnotation: {
            openNewPage('ShowAnnotation',parameters);
        }
        onShowAnnotationsSearch: {
            openNewPage('AnnotationsList', parameters)
        }

        onOpenAnnotations: openSubPage('AnnotationsList',{annotationsModel: globalAnnotationsModel, projectsModel: globalProjectsModel})
        onOpenCamera: openNewPage('CameraShoot',{receiver: receiver})
        onImportAnnotations: openNewPage('ModelImporter',{fieldNames: fieldNames, writeModel: writeModel, fieldConstants: fieldConstants})
        onExportAnnotations: openNewPage('ModelImporter',{importData: false, fieldNames: fieldNames, writeModel: writeModel, fieldConstants: fieldConstants})

        // Document list
        onCreatedFile: messageBox.publishMessage('Creat el fitxer «' + file + '»')
        onNotCreatedFile: messageBox.publishMessage('El fitxer «' + file + '» ja existeix')
        onOpenDocument: openNewPage(page, {document: document})
        onOpenTBook: openNewPage('Planning2', {document: document})
        onOpeningDocumentExternally: messageBox.publishMessage(qsTr("Obrint el document «") + document + "»")

        // Events
        onShowEvents: openNewPage('TasksSystem', {project: project})
        onDeletedEvents: messageBox.publishMessage(qsTr("S'han esborrat ") + num + qsTr(' esdeveniments'))
        onShowEvent: openNewPage('ShowEvent', parameters)
        onNewEvent: openNewPage('ShowEvent', parameters)
        onSavedEvent: {
            messageBox.publishMessage(qsTr("S'ha desat l'esdeveniment"));
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
        onSelectDocument: openNewPage('DocumentsList', {initialDirectory: source, selectDocument: true, documentReceiver: documentReceiver})
        onRefusedCloseEditorRequest: messageBox.publishMessage(qsTr("Encara hi ha canvis sense desar! Desa'ls o descarta'ls abans."))

        // Rubrics
        onOpenRubricDetails: openNewPage('RubricDetailsEditor',{rubric: rubric, rubricsModel: rubricsModel})
        onOpenRubricEditor: openNewPage('Rubric',{rubric: id, rubricsModel: rubricsModel, state: 'edit'}, '')
        onOpenRubricGroupAssessment: {
            openNewPage('RubricGroupAssessment', {idAssessment: assessment, rubric: rubric, rubricsModel: rubricsModel, rubricsAssessmentModel: rubricsAssessmentModel})
        }
        onOpenRubricHistory: openNewPage('RubricAssessmentHistory',{group: group})
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
                                                          lastScoreId: lastScoreId
                                                      });

        onEditGroupIndividual: openNewPage('GroupIndividualEditor', {individual: individual, groupsIndividualsModel: groupsIndividualsModel})
        onEditRubricAssessmentByCriterium: openNewPage('ShowRubricGroupAssessmentByCriterium',{assessment: assessment,criterium: criterium})
        onEditRubricAssessmentByIndividual: openNewPage('ShowRubricGroupAssessmentByIndividual',{assessment: assessment,individual: individual})

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
        onNewProject: openNewPage('ProjectEditor')
        onNewProjectRequest: openNewPage('ProjectEditor');
        onShowProject: openNewPage('ProjectEditor',{idProject: project})
        onSavedProjectDetails: {
            messageBox.publishMessage(qsTr("S'ha desat el projecte"));
            closeCurrentPage();
        }

        // Resources
        onNewResource: openNewPage('ShowResource')
        onNewResourceAttachment: openNewPage('ResourceAttachment',parameters);
        onCreateResource: openNewPage('ShowResource',{resourcesModel: model});
        onInsertedResourceAttachment: {
            messageBox.publishMessage(message);
            closeCurrentPage();
        }

        onShowResource: openNewPage('ShowResource',{idResource: idResource, resourcesModel: model});
        onUpdatedResourceAttachment: {
            messageBox.publishMessage(message);
            closeCurrentPage();
        }

        // Characteristics
        onShowCharacteristics: {
            openNewPage('CharacteristicsList',{project: project});
        }
        onShowEventCharacteristics: {
            openNewPage('EventCharacteristicsEditor',{event: event, characteristicsModel: characteristicsModel, writeModel: writeModel})
        }

        // Data import
        onImportData: openNewPage('ModelImporter',{fieldNames: fieldNames, fieldConstants: fieldConstants, writeModel: writeModel})
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
                spacing: units.nailUnit
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
                    pagesStack.invokeMethod(model.method);
                    header.state = 'minimized';
                }
            }
        }

    }

    MessageDialog {
        id: closeWorkingPageDialog

        title: qsTr("Tancar aquest espai")
        text: qsTr("Vols tancar aquest espai de treball?")
        standardButtons: StandardButton.Ok | StandardButton.Cancel
        onAccepted: closeWorkingSpace()
    }

    function openNewPage(page,param) {
        pagesStack.push({item: Qt.resolvedUrl(page + '.qml'), properties: param});
    }

    function getButtonsList() {
        var pageObj = pagesStack.currentItem;
        if ((pageObj) && (typeof(pageObj.buttons) !== 'undefined')) {
            return pageObj.buttons;
        } else {
            return undefined;
        }
    }

    function requestClosePage() {
        if (pagesStack.depth>1) {
            var item = pagesStack.currentItem;
            if (typeof item.requestClose == 'function') {
                item.requestClose();
            } else {
                closeCurrentPage();
            }
        } else {
            closeWorkingPageDialog.open();
        }
    }

    function closeCurrentPage() {
        pagesStack.pop();
    }

}

