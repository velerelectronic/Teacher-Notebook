import QtQuick 2.5
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.4
import QtQuick.Dialogs 1.2
import PersonalTypes 1.0
import 'qrc:///common' as Common

Item {
    id: workingSpace

    property string pageTitle: basicList.pageTitle

    property string initialPage: ''
    property var initialProperties
    property bool canClose: true

    signal closeWorkingSpace()
    signal openMenu(int initialHeight, var menu, var options)
    signal showMessage(string message)

    property ListModel buttonsModel: ListModel { }

    Common.UseUnits { id: units }

    ListModel {
        id: newButtonsModel

        dynamicRoles: true
    }

    ListModel {
        id: pagesModel

        dynamicRoles: true
    }

    ColumnLayout {
        anchors.fill: parent
        ListView {
            id: basicList
            Layout.fillHeight: true
            Layout.fillWidth: true

            property string pageTitle: ((currentItem !== null) && (typeof currentItem.pageTitle !== 'undefined'))?currentItem.pageTitle:qsTr('Espai de treball')

            orientation: ListView.Horizontal
            model: pagesModel
            spacing: units.fingerUnit

            clip: true

            highlightRangeMode: ListView.StrictlyEnforceRange
            highlightMoveVelocity: basicList.width * 2

            snapMode: ListView.SnapOneItem

            displaced: Transition {
                NumberAnimation { properties: "x,y"; duration: 1000 }
            }

            delegate: Item {
                id: basicItem

                width: basicList.width
                height: basicList.height

                ListView.onRemove: SequentialAnimation {
                    ScriptAction { script: { console.log('Eliminant 1') }}
                    PropertyAction { target: basicList; property: "highlightFollowsCurrentItem"; value: false }
                    PropertyAction { target: basicItem; property: "ListView.delayRemove"; value: true }
                    NumberAnimation { target: basicItem; property: "opacity"; to: 0; duration: 1000; easing.type: Easing.InOutQuad }
                    PropertyAction { target: basicItem; property: "ListView.delayRemove"; value: false }
                    PropertyAction { target: basicList; property: "highlightFollowsCurrentItem"; value: true }
                    ScriptAction { script: { console.log('Eliminant 2') }}
                }

                Loader {
                    id: basicPage

                    anchors.fill: parent

                    property string mainPage: model.page
                    property var mainParameters: model.parameters

                    onMainPageChanged: basicPage.loadMainPage()
                    onMainParametersChanged: basicPage.loadMainPage()

                    function loadMainPage() {
                        console.log('we open',mainPage,mainParameters);
                        if ((mainPage !== '') && (mainParameters != undefined)) {
                            basicPage.setSource(mainPage,mainParameters);
                        }
                    }

                    Connections {
                        target: basicPage.item
                        ignoreUnknownSignals: true

                        // Close the current page
                        onClosePage: {
                            if (basicList.currentIndex>0) {
                                pagesModel.remove(model.index);
//                                basicList.currentIndex = model.index - 1;
                            }
                        }
                        // Slide menu
                        onOpenMenu: {
                            workingSpace.openMenu(initialHeight, menu, options);
                        }

                        // Page handling
                        onOpenPage: loadSubPage(page,{})
                        onOpenPageArgs: loadSubPage(page,args)

                        // Show messages
                        onShowMessage: workingSpace.showMessage(message)

                        // Search for annotations, resources, etc
                        onSearch: loadSubPage('OmniboxSearch.qml', options)


                        // Remove from this downwards

                        // Annotations
                        onCombineAnnotationsIntoTable: {
                            console.log('Compte 2', annotationsModel.count);
                            openNewPage('CombinedAnnotationsTable', {annotationsModel: annotationsModel});
                        }

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

                        // TimeTable
                        onOpenTimeTable: openNewPage('ShowTimeTable', {identifier: annnotation})

                    }

                }

                MouseArea {
                    anchors.fill: parent
                    enabled: model.index !== pagesModel.count-1
                    onClicked: basicList.currentIndex = pagesModel.count-1;
                }
            }
        }
        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: units.fingerUnit
            ListView {
                anchors.fill: parent
                orientation: ListView.Horizontal
                spacing: units.nailUnit
                model: pagesModel
                interactive: false

                delegate: Rectangle {
                    width: units.fingerUnit / 2
                    height: width
                    radius: width/2
                    color: (model.index == basicList.currentIndex)?'white':'green'
                    border.color: 'black'
                    border.width: 2
                }
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

    function loadFirstPage(page, param) {
        pagesModel.clear();
        loadSubPage(page, param);
    }

    function loadSubPage(page, param) {
        console.log('opening', page, param);
        pagesModel.append({page: Qt.resolvedUrl(page + '.qml'), parameters: param});
        basicList.currentIndex = pagesModel.count-1;
    }

    function requestClosePage() {
        var item = pagesStack.currentItem;
        if (pagesStack.depth>1) {
            if (typeof (item.requestClose) == 'function') {
                item.requestClose();
            } else {
                closeCurrentPage();
            }
        } else {
            if (typeof (item.requestClose) == 'function') {
                if (item.requestClose()) {
                    closeWorkingPageDialog.open();

                }
            } else {
                closeWorkingPageDialog.open();
            }
        }
    }

    function closeCurrentPage() {
        // Erase this function
    }

}

